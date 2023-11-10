-- Name: Locust Swarm
-- Description: What happens when you're attacked by a swarm of locusts?
--- 
--- Designed to run with one or more player ships with different terrain each time. 
---
--- Version 1
---
--- USN Discord: https://discord.gg/PntGG3a where you can join a game online. There's one every weekend. All experience levels are welcome. 
-- Type: Replayable Mission
-- Author: Xansta
-- Setting[Swarm]: Configures the size of the swarm
-- Swarm[Tiny]: Tiny sized swarm
-- Swarm[Small]: Small sized swarm
-- Swarm[Normal|Default]: Normal sized swarm
-- Swarm[Large]: Large sized swarm
-- Swarm[Huge]: Huge sized swarm
-- Setting[Basis]: Configures the ship that serves as the basis for the locusts
-- Basis[Fighter|Default]: The Fighter is the basis for the locusts
-- Basis[Hornet]: The Hornet is the basis for the locusts
-- Basis[Drone]: The Ktlitan Drone is the basis for the locusts
require("utils.lua")
require("place_station_scenario_utility.lua")
require("generate_call_sign_scenario_utility.lua")
require("cpu_ship_diversification_scenario_utility.lua")

function init()
	scenario_version = "0.0.3"
	ee_version = "2023.06.17"
	print(string.format("    ----    Scenario: Locust Swarm    ----    Version %s    ----    Tested with EE version %s    ----",scenario_version,ee_version))
	print(_VERSION)
	setVariations()	
	setConstants()	
	constructEnvironment()
	onNewPlayerShip(setPlayers)
end
function setVariations()
	local swarm_config = {
		["Tiny"] =		{rings = 3, slots = 36,	estimate = _("orders-comms","thirty")},
		["Small"] =		{rings = 4, slots = 58,	estimate = _("orders-comms","fifty")},
		["Normal"] =	{rings = 5, slots = 88,	estimate = _("orders-comms","eighty")},
		["Large"] =		{rings = 6, slots = 124,estimate = _("orders-comms","one hundred")},
		["Huge"] =		{rings = 7, slots = 166,estimate = _("orders-comms","one hundred and fifty")},
	}
	swarm_rings =		swarm_config[getScenarioSetting("Swarm")].rings
	swarm_slots =		swarm_config[getScenarioSetting("Swarm")].slots
	swarm_estimate =	swarm_config[getScenarioSetting("Swarm")].estimate
	local basis_config = {
		["Fighter"] =	{template = "Fighter", 			desc = _("orders-comms","fighter")},
		["Hornet"] =	{template = "MT52 Hornet",		desc = _("orders-comms","hornet")},
		["Drone"] =		{template = "Ktlitan Drone",	desc = _("orders-comms","drone")},
	}
	locust_template =	basis_config[getScenarioSetting("Basis")].template
	locust_template_desc = basis_config[getScenarioSetting("Basis")].desc
end
function setConstants()
	hex_ring_positions = {
		{angle = 0,		dist = 1},					--1
		{angle = 120,	dist = 1},					--2
		{angle = 240,	dist = 1},					--3
		{angle = 60,	dist = 1},					--4
		{angle = 180,	dist = 1},					--5
		{angle = 300,	dist = 1},					--6
		{angle = 0,		dist = 2},					--7
		{angle = 120,	dist = 2},					--8
		{angle = 240,	dist = 2},					--9
		{angle = 60,	dist = 2},					--10
		{angle = 180,	dist = 2},					--11
		{angle = 300,	dist = 2},					--12
		{angle = 30,	dist = 1.7320508075689},	--13
		{angle = 150,	dist = 1.7320508075689},	--14
		{angle = 270,	dist = 1.7320508075689},	--15
		{angle = 90,	dist = 1.7320508075689},	--16
		{angle = 210,	dist = 1.7320508075689},	--17
		{angle = 330,	dist = 1.7320508075689},	--18
		{angle = 0,		dist = 3},					--19
		{angle = 120,	dist = 3},					--20
		{angle = 240,	dist = 3},					--21
		{angle = 60,	dist = 3},					--22
		{angle = 180,	dist = 3},					--23
		{angle = 300,	dist = 3},					--24
		{angle = 20,	dist = 2.645751310646},		--25
		{angle = 140,	dist = 2.645751310646},		--26
		{angle = 260,	dist = 2.645751310646},		--27
		{angle = 80,	dist = 2.645751310646},		--28
		{angle = 200,	dist = 2.645751310646},		--29
		{angle = 320,	dist = 2.645751310646},		--30
		{angle = 40,	dist = 2.645751310646},		--31
		{angle = 160,	dist = 2.645751310646},		--32
		{angle = 280,	dist = 2.645751310646},		--33
		{angle = 100,	dist = 2.645751310646},		--34
		{angle = 220,	dist = 2.645751310646},		--35
		{angle = 340,	dist = 2.645751310646},		--36
		{angle = 0,		dist = 4},					--37
		{angle = 120,	dist = 4},					--37
		{angle = 240,	dist = 4},					--37
		{angle = 60,	dist = 4},					--38
		{angle = 180,	dist = 4},					--39
		{angle = 300,	dist = 4},					--40
		{angle = 30,	dist = 3.4641016151378},	--41
		{angle = 150,	dist = 3.4641016151378},	--42
		{angle = 270,	dist = 3.4641016151378},	--43
		{angle = 90,	dist = 3.4641016151378},	--44
		{angle = 210,	dist = 3.4641016151378},	--45
		{angle = 330,	dist = 3.4641016151378},	--46
		{angle = 15,	dist = 3.605551275464},		--47
		{angle = 135,	dist = 3.605551275464},		--48
		{angle = 255,	dist = 3.605551275464},		--49
		{angle = 75,	dist = 3.605551275464},		--50
		{angle = 195,	dist = 3.605551275464},		--51
		{angle = 315,	dist = 3.605551275464},		--52
		{angle = 45,	dist = 3.605551275464},		--53
		{angle = 165,	dist = 3.605551275464},		--54
		{angle = 285,	dist = 3.605551275464},		--55
		{angle = 105,	dist = 3.605551275464},		--56
		{angle = 225,	dist = 3.605551275464},		--57
		{angle = 345,	dist = 3.605551275464},		--58
		{angle = 0,		dist = 5},					--59
		{angle = 120,	dist = 5},					--60
		{angle = 240,	dist = 5},					--61
		{angle = 60,	dist = 5},					--62
		{angle = 180,	dist = 5},					--63
		{angle = 300,	dist = 5},					--64
		{angle = 12,	dist = 4.5825756949558},	--65
		{angle = 132,	dist = 4.5825756949558},	--66
		{angle = 252,	dist = 4.5825756949558},	--67
		{angle = 72,	dist = 4.5825756949558},	--68
		{angle = 192,	dist = 4.5825756949558},	--69
		{angle = 312,	dist = 4.5825756949558},	--70
		{angle = 48,	dist = 4.5825756949558},	--71
		{angle = 168,	dist = 4.5825756949558},	--72
		{angle = 288,	dist = 4.5825756949558},	--73
		{angle = 108,	dist = 4.5825756949558},	--74
		{angle = 228,	dist = 4.5825756949558},	--75
		{angle = 348,	dist = 4.5825756949558},	--76
		{angle = 24,	dist = 4.3588989435407},	--77
		{angle = 144,	dist = 4.3588989435407},	--78
		{angle = 264,	dist = 4.3588989435407},	--79
		{angle = 84,	dist = 4.3588989435407},	--80
		{angle = 204,	dist = 4.3588989435407},	--81
		{angle = 324,	dist = 4.3588989435407},	--82
		{angle = 36,	dist = 4.3588989435407},	--83
		{angle = 156,	dist = 4.3588989435407},	--84
		{angle = 276,	dist = 4.3588989435407},	--85
		{angle = 96,	dist = 4.3588989435407},	--86
		{angle = 216,	dist = 4.3588989435407},	--87
		{angle = 336,	dist = 4.3588989435407},	--88
		{angle = 0,		dist = 6},					--89
		{angle = 120,	dist = 6},					--90
		{angle = 240,	dist = 6},					--91
		{angle = 60,	dist = 6},					--92
		{angle = 180,	dist = 6},					--93
		{angle = 300,	dist = 6},					--94
		{angle = 10,	dist = 5.56776436283},		--95
		{angle = 130,	dist = 5.56776436283},		--96
		{angle = 250,	dist = 5.56776436283},		--97
		{angle = 70,	dist = 5.56776436283},		--98
		{angle = 190,	dist = 5.56776436283},		--99
		{angle = 310,	dist = 5.56776436283},		--100
		{angle = 50,	dist = 5.56776436283},		--101
		{angle = 170,	dist = 5.56776436283},		--102
		{angle = 290,	dist = 5.56776436283},		--103
		{angle = 110,	dist = 5.56776436283},		--104
		{angle = 230,	dist = 5.56776436283},		--105
		{angle = 350,	dist = 5.56776436283},		--106
		{angle = 20,	dist = 5.2915026221292},	--107
		{angle = 140,	dist = 5.2915026221292},	--108
		{angle = 260,	dist = 5.2915026221292},	--109
		{angle = 80,	dist = 5.2915026221292},	--110
		{angle = 200,	dist = 5.2915026221292},	--111
		{angle = 320,	dist = 5.2915026221292},	--112
		{angle = 40,	dist = 5.2915026221292},	--113
		{angle = 160,	dist = 5.2915026221292},	--114
		{angle = 280,	dist = 5.2915026221292},	--115
		{angle = 100,	dist = 5.2915026221292},	--116
		{angle = 220,	dist = 5.2915026221292},	--117
		{angle = 340,	dist = 5.2915026221292},	--118
		{angle = 30,	dist = 5.1961524227066},	--119
		{angle = 150,	dist = 5.1961524227066},	--120
		{angle = 270,	dist = 5.1961524227066},	--121
		{angle = 90,	dist = 5.1961524227066},	--122
		{angle = 210,	dist = 5.1961524227066},	--123
		{angle = 330,	dist = 5.1961524227066},	--124
		{angle = 0,			dist = 7},				--125
		{angle = 120,		dist = 7},				--126
		{angle = 240,		dist = 7},				--127
		{angle = 60,		dist = 7},				--128
		{angle = 180,		dist = 7},				--129
		{angle = 300,		dist = 7},				--130
		{angle = 60/7,		dist = 6.557438524302},	--131
		{angle = 60/7+120,	dist = 6.557438524302},	--132
		{angle = 60/7+240,	dist = 6.557438524302},	--133
		{angle = 60/7+60,	dist = 6.557438524302},	--134
		{angle = 60/7+180,	dist = 6.557438524302},	--135
		{angle = 60/7+300,	dist = 6.557438524302},	--136
		{angle = 60/7*6,	dist = 6.557438524302},	--137
		{angle = 60/7*6+120,dist = 6.557438524302},	--138
		{angle = 60/7*6+240,dist = 6.557438524302},	--139
		{angle = 60/7*6+60,	dist = 6.557438524302},	--140
		{angle = 60/7*6+180,dist = 6.557438524302},	--141
		{angle = 60/7*6+300,dist = 6.557438524302},	--142
		{angle = 60/7*2,	dist = 6.2449979983984},--143
		{angle = 60/7*2+120,dist = 6.2449979983984},--144
		{angle = 60/7*2+240,dist = 6.2449979983984},--145
		{angle = 60/7*2+60,	dist = 6.2449979983984},--146
		{angle = 60/7*2+180,dist = 6.2449979983984},--147
		{angle = 60/7*2+300,dist = 6.2449979983984},--148
		{angle = 60/7*5,	dist = 6.2449979983984},--149
		{angle = 60/7*5+120,dist = 6.2449979983984},--150
		{angle = 60/7*5+240,dist = 6.2449979983984},--151
		{angle = 60/7*5+60,	dist = 6.2449979983984},--152
		{angle = 60/7*5+180,dist = 6.2449979983984},--153
		{angle = 60/7*5+300,dist = 6.2449979983984},--154
		{angle = 60/7*3,	dist = 6.0827625302982},--155
		{angle = 60/7*3+120,dist = 6.0827625302982},--156
		{angle = 60/7*3+240,dist = 6.0827625302982},--157
		{angle = 60/7*3+60,	dist = 6.0827625302982},--158
		{angle = 60/7*3+180,dist = 6.0827625302982},--159
		{angle = 60/7*3+300,dist = 6.0827625302982},--160
		{angle = 60/7*4,	dist = 6.0827625302982},--161
		{angle = 60/7*4+120,dist = 6.0827625302982},--162
		{angle = 60/7*4+240,dist = 6.0827625302982},--163
		{angle = 60/7*4+60,	dist = 6.0827625302982},--164
		{angle = 60/7*4+180,dist = 6.0827625302982},--165
		{angle = 60/7*4+300,dist = 6.0827625302982},--166
	}
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
	defense_platforms = {
		["Small Station"] =	{count = math.random(3,4), dist = 2500, chance = 15},
		["Medium Station"] ={count = math.random(3,5), dist = 3300, chance = 25},
		["Large Station"] =	{count = math.random(4,6), dist = 4000, chance = 40},
		["Huge Station"] =	{count = math.random(4,7), dist = 4500, chance = 65}, 
	}
	station_defend_dist = {
		["Small Station"] = 2800,	--2620
		["Medium Station"] = 4200,	--4000
		["Large Station"] = 4800,	--4590
		["Huge Station"] = 5200,	--4985
	}
	faction_letter = {
		["Human Navy"] = "H",
		["Independent"] = "I",
		["Kraylor"] = "K",
		["Ktlitans"] = "B",	--Bugs
		["Exuari"] = "E",
		["Ghosts"] = "G",
		["Arlenians"] = "A",
		["TSN"] = "T",
		["CUF"] = "C",
		["USN"] = "U",
	}
	center_x = random(400000,1200000)
	center_y = random(60000,260000)
	station_list = {}
	deployed_factions = {}
	factions = {}
end
--	Terrain
function constructEnvironment()
	local common_scattered_objects = 0
	local obj_type_sizes = {
		{typ = "Planet",		siz = 10000},
		{typ = "BlackHole",		siz = 6000},
		{typ = "WormHole",		siz = 5500},
		{typ = "WarpJammer",	siz = 5000},
		{typ = "mineblob",		siz = 4000},
		{typ = "asteroidblob",	siz = 3500},
		{typ = "Mine",			siz = 2000},
		{typ = "Asteroid",		siz = 1000},
	}
	local common_obj_type_sizes = {
		{typ = "WarpJammer",	siz = 5000},
		{typ = "mineblob",		siz = 4000},
		{typ = "asteroidblob",	siz = 3500},
		{typ = "Mine",			siz = 2000},
		{typ = "Asteroid",		siz = 1000},
	}
	local planet_list = {
		{
			name = {"Biju","Aldea","Bersallis"},
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
	local moon_list = {
		{
			name = {"Ganymede", "Europa", "Deimos", "Callisto", "Amalthea"},
			texture = {
				surface = "planets/moon-1.png"
			}
		},
		{
			name = {"Himalia", "Ananke", "Pasiphe", "Sinope", "Lysithea"},
			texture = {
				surface = "planets/moon-2.png"
			}
		},
		{
			name = {"Leda", "Adrastea", "Arinome", "Metis", "Chaldene"},
			texture = {
				surface = "planets/moon-3.png"
			}
		},
	}
	for faction,letter in pairs(faction_letter) do
		table.insert(factions,faction)
		deployed_factions[faction] = false
	end
	player_factions = {"Human Navy","CUF","USN","TSN"}
	player_faction = player_factions[math.random(1,#player_factions)]
	repeat
		local ox, oy = vectorFromAngleNorth(random(0,360),random(2000,66000) + random(2000,66000) + random(2000,66000))
		ox = ox + center_x
		oy = oy + center_y
		local obj_list = getObjectsInRadius(ox, oy, 20000)
		local closest_distance = 20000
		local closest_obj = nil
		for i,obj in ipairs(obj_list) do
			local obj_dist = distance(obj,ox,oy)
			if obj_dist < closest_distance then
				closest_distance = obj_dist
				closest_obj = obj
			end
		end
		local type_list = {}
		for i,type_size in ipairs(common_obj_type_sizes) do
			if type_size.siz < closest_distance then
				table.insert(type_list,type_size.typ)
			end
		end
		if #type_list > 0 then
			local insert_type = type_list[math.random(1,#type_list)]
			if insert_type == "WarpJammer" then
				closest_distance = math.min(closest_distance * .95,20000)
				WarpJammer():setPosition(ox,oy):setRange(closest_distance)
			elseif insert_type == "mineblob" then
				closest_distance = math.min(closest_distance,15000)
				placeMinefieldBlob(ox,oy,closest_distance*.37)
			elseif insert_type == "asteroidblob" then
				closest_distance = math.min(closest_distance,15000)
				placeAsteroidBlob(ox,oy,closest_distance*.37)
			elseif insert_type == "Mine" then
				Mine():setPosition(ox,oy)
			elseif insert_type == "Asteroid" then
				Asteroid():setPosition(ox,oy):setSize(random(20,950))
			end
		end
		common_scattered_objects = common_scattered_objects + 1
	until(common_scattered_objects > 100)
	swarm_ships = {}
	repeat
		local ox, oy = vectorFromAngleNorth(random(0,360),random(6000,200000))
		ox = ox + center_x
		oy = oy + center_y
		local obj_list = getObjectsInRadius(ox, oy, 20000)
		local closest_distance = 20000
		local closest_obj = nil
		for i,obj in ipairs(obj_list) do
			local obj_dist = distance(obj,ox,oy)
			if obj_dist < closest_distance then
				closest_distance = obj_dist
				closest_obj = obj
			end
		end
		if closest_distance > 1500 then
			local ship = CpuShip():setTemplate(locust_template):setFaction("Exuari"):setPosition(ox,oy)
			ship:onTakingDamage(organicSystems)
			ship:setTypeName("Locust")
			ship:setImpulseMaxSpeed(300)
			ship:setRotationMaxSpeed(30)
			ship:orderStandGround()
			table.insert(swarm_ships,ship)
		end
	until(#swarm_ships > swarm_slots)
	uncommon_obj_type_sizes = {
		{typ = "Planet",		siz = 10000},
		{typ = "BlackHole",		siz = 6000},
		{typ = "WormHole",		siz = 5500},
		{typ = "Station",		siz = 3000},
	}
	local filled_out = false
	local planet_count = 0
	local blackhole_count = 0
	local wormhole_count = 0
	local placement_attempt_count = 0
	repeat
		local ox, oy = vectorFromAngleNorth(random(0,360),random(6000,200000))
		ox = ox + center_x
		oy = oy + center_y
		local obj_list = getObjectsInRadius(ox, oy, 20000)
		local closest_distance = 20000
		local closest_obj = nil
		for i,obj in ipairs(obj_list) do
			local obj_dist = distance(obj,ox,oy)
			if obj_dist < closest_distance then
				closest_distance = obj_dist
				closest_obj = obj
			end
		end
		local type_list = {}
		for i,type_size in ipairs(uncommon_obj_type_sizes) do
			if type_size.siz < closest_distance then
				if type_size.typ == "Planet" and planet_count < 3 then
					table.insert(type_list,type_size.typ)
				elseif type_size.typ == "BlackHole" and blackhole_count < 3 then
					table.insert(type_list,type_size.typ)
				elseif type_size.typ == "WormHole" and wormhole_count < 3 then
					table.insert(type_list,type_size.typ)
				elseif type_size.typ == "Station" then
					table.insert(type_list,type_size.typ)
				end 
			end
		end
		if #type_list > 0 then
			local insert_type = type_list[math.random(1,#type_list)]
			if insert_type == "Planet" and planet_count < 3 then
				closest_distance = math.min(closest_distance * .95,20000)
				selected_planet = tableRemoveRandom(planet_list)
				if selected_planet ~= nil then
					local scattered_planet = Planet():setPlanetRadius(closest_distance/2):setPosition(ox,oy)
					scattered_planet:setCallSign(selected_planet.name[math.random(1,#selected_planet.name)])
					scattered_planet:setPlanetSurfaceTexture(selected_planet.texture.surface)
					if selected_planet.texture.atmosphere ~= nil then
						scattered_planet:setPlanetAtmosphereTexture(selected_planet.texture.atmosphere)
					end
					if selected_planet.texture.cloud ~= nil then
						scattered_planet:setPlanetCloudTexture(selected_planet.texture.cloud)
					end
					if selected_planet.color ~= nil then
						scattered_planet:setPlanetAtmosphereColor(selected_planet.color.red,selected_planet.color.green,selected_planet.color.blue)
					end
					scattered_planet:setAxialRotationTime(random(350,500))
					selected_moon = tableRemoveRandom(moon_list)
					if selected_moon ~= nil then
						local scattered_moon = Planet():setPlanetRadius(closest_distance/8):setPosition(ox,oy + closest_distance - closest_distance/16)
						scattered_moon:setCallSign(selected_moon.name[math.random(1,#selected_moon.name)])
						scattered_moon:setPlanetSurfaceTexture(selected_moon.texture.surface)
						scattered_moon:setAxialRotationTime(random(500,900))
						scattered_moon:setOrbit(scattered_planet,random(100,200))
					end
				end
				planet_count = planet_count + 1
			elseif insert_type == "BlackHole" and blackhole_count < 3 then
				BlackHole():setPosition(ox,oy)
				blackhole_count = blackhole_count + 1
			elseif insert_type == "WormHole" and wormhole_count < 3 then
				local wh = WormHole():setPosition(ox,oy)
				wh:setTargetPosition(center_x, center_y):onTeleportation(wormholeTax)
				wormhole_count = wormhole_count + 1
			elseif insert_type == "Station" then
				local station_size = szt()
				local spaced_station = true
				local closest_station_distance = 999999
				local closest_station = nil
				for _, station in ipairs(station_list) do
					local current_distance = distance(station, ox, oy)
					if current_distance < closest_station_distance then
						closest_station_distance = current_distance
						closest_station = station
					end
					if current_distance < 20000 then
						spaced_station = false
						break
					end
				end
				if spaced_station then
					local faction_selection_list = {}
					for faction,deployed in pairs(deployed_factions) do
						if not deployed then
							table.insert(faction_selection_list,faction)
						end
					end
					if #faction_selection_list > 0 then
						selected_faction = faction_selection_list[math.random(1,#faction_selection_list)]
					else
						filled_out = true
					end
					if station_defend_dist[station_size] < closest_distance then
						local name_group = "RandomHumanNeutral"
						local tsa = Artifact():setFaction(selected_faction)
						local tpa = Artifact():setFaction(player_faction)
						if tsa:isEnemy(tpa) then
							name_group = "Sinister"
						end
						tsa:destroy()
						tpa:destroy()
						local station = placeStation(ox, oy, name_group, selected_faction, station_size, true)
						table.insert(station_list,station)
						deployed_factions[selected_faction] = true
						if random(1,100) < defense_platforms[station_size].chance then
							local dp_angle = random(0,360)
							for j=1,defense_platforms[station_size].count do
								local dp_x, dp_y = vectorFromAngle(dp_angle,defense_platforms[station_size].dist)
								local dp = CpuShip():setTemplate("Defense platform"):setFaction(selected_faction):setPosition(ox + dp_x, oy + dp_y):orderStandGround()
								dp:setCallSign(string.format("%sDP%i%s",faction_letter[selected_faction],j,string.char(96+math.random(1,26))))
								dp_angle = (dp_angle + (360/defense_platforms[station_size].count)) % 360
							end
						end
					elseif defense_platforms[station_size].dist < closest_distance then
						local name_group = "RandomHumanNeutral"
						local tsa = Artifact():setFaction(selected_faction)
						local tpa = Artifact():setFaction(player_faction)
						if tsa:isEnemy(tpa) then
							name_group = "Sinister"
						end
						tsa:destroy()
						tpa:destroy()
						local station = placeStation(ox, oy, name_group, selected_faction, station_size, true)
						table.insert(station_list,station)
						deployed_factions[selected_faction] = true
					end
				end
			end
		end
		placement_attempt_count = placement_attempt_count + 1
	until(filled_out or placement_attempt_count > 500)
	beginning_enemy_station_count = 0
	beginning_friendly_station_count = 0
	beginning_neutral_station_count = 0
	local tpa = Artifact():setFaction(player_faction)
	for i,station in ipairs(station_list) do
		if tpa:isEnemy(station) then
			beginning_enemy_station_count = beginning_enemy_station_count + 1
		elseif tpa:isFriendly(station) then
			beginning_friendly_station_count = beginning_friendly_station_count + 1
		else
			beginning_neutral_station_count = beginning_neutral_station_count + 1
		end
	end
	tpa:destroy()
	for i=1,math.random(10,15) do
		local ox, oy = vectorFromAngle(random(0,360),random(2000,66000) + random(2000,66000) + random(2000,66000))
		Nebula():setPosition(center_x + ox, center_y + oy)
		if random(1,100) < 77 then
			local n_angle = random(0,360)
			local nx, ny = vectorFromAngle(n_angle,random(5000,10000))
			Nebula():setPosition(center_x + ox + nx, center_y + oy + ny)
			if random(1,100) < 41 then
				local n2_angle = (n_angle + random(120,240)) % 360
				nx, ny = vectorFromAngle(n2_angle,random(5000,10000))
				ox = ox + nx
				oy = oy + ny
				Nebula():setPosition(center_x + ox, center_y + oy)
				if random(1,100) < 32 then
					nx, ny = vectorFromAngle(n2_angle + random(120,240),random(5000,10000))
					Nebula():setPosition(center_x + ox + nx, center_y + oy + ny)
				end
			end
		end
	end
--	testFormation()
end
function placeAsteroidBlob(x,y,field_radius)
	local asteroid_list = {}
	local a = Asteroid():setPosition(x,y)
	local size = random(10,400) + random(10,400)
	a:setSize(size)
	table.insert(asteroid_list,a)
	local visual_angle = random(0,360)
	local vx, vy = vectorFromAngle(visual_angle,random(0,field_radius))
	local va = VisualAsteroid():setPosition(x + vx, y + vy)
	va:setSize(random(10,300) + random(5,300))
	visual_angle = visual_angle + random(120,240)
	vx, vy = vectorFromAngle(visual_angle,random(0,field_radius))
	va = VisualAsteroid():setPosition(x + vx, y + vy)
	va:setSize(random(10,300) + random(5,300))
	local reached_the_edge = false
	repeat
		local overlay = false
		local nax = nil
		local nay = nil
		repeat
			overlay = false
			local base_asteroid_index = math.random(1,#asteroid_list)
			local base_asteroid = asteroid_list[base_asteroid_index]
			local bax, bay = base_asteroid:getPosition()
			local angle = random(0,360)
			size = random(10,400) + random(10,400)
			local asteroid_space = (base_asteroid:getSize() + size)*random(1.05,1.25)
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
		a = Asteroid():setPosition(nax,nay)
		a:setSize(size)
		table.insert(asteroid_list,a)
		visual_angle = random(0,360)
		vx, vy = vectorFromAngle(visual_angle,random(0,field_radius))
		va = VisualAsteroid():setPosition(nax + vx,nay + vy)
		va:setSize(random(10,300) + random(5,300))
		visual_angle = visual_angle + random(120,240)
		vx, vy = vectorFromAngle(visual_angle,random(0,field_radius))
		va = VisualAsteroid():setPosition(nax + vx, nay + vy)
		va:setSize(random(10,300) + random(5,300))
		if distance(x,y,nax,nay) > field_radius then
			reached_the_edge = true
		end
	until(reached_the_edge)
	return asteroid_list
end
function placeMinefieldBlob(x,y,mine_blob_radius)
	local mine_list = {}
	table.insert(mine_list,Mine():setPosition(x,y))
	local reached_the_edge = false
	local mine_space = 1400
	repeat
		local overlay = false
		local nmx = nil
		local nmy = nil
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
		if distance(x, y, nmx, nmy) > mine_blob_radius then
			reached_the_edge = true
		end
	until(reached_the_edge)
	return mine_list
end
--	Player
function setPlayers(p)
	string.format("")
	if p == nil then
		return
	end
	local player_spawn_x, player_spawn_y = vectorFromAngleNorth(random(0,360),random(0,5000))
	player_spawn_x = player_spawn_x + center_x
	player_spawn_y = player_spawn_y + center_y
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
	p:onDestruction(playerDestruction)
	if p:getReputationPoints() == 0 then
		p:setReputationPoints(50)
	end
end
function updatePlayerSoftTemplate(p)
	local tempTypeName = p:getTypeName()
	if tempTypeName ~= nil then
		if playerShipStats[tempTypeName] ~= nil then
			p.shipScore = playerShipStats[tempTypeName].strength
			p.maxCargo = playerShipStats[tempTypeName].cargo
			p.cargo = p.maxCargo
			p:setMaxScanProbeCount(playerShipStats[tempTypeName].probes)
			p:setScanProbeCount(p:getMaxScanProbeCount())
			p.tractor = playerShipStats[tempTypeName].tractor
			p.tractor_target_lock = false
			p.mining = playerShipStats[tempTypeName].mining
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
	p.swarm_status_rel = "swarm_status_rel"
	p:addCustomButton("Relay",p.swarm_status_rel,_("buttonRelay","Locust Status"),function()
		string.format("")
		locustStatus(p,"Relay")
	end,20)
	p.swarm_status_ops = "swarm_status_ops"
	p:addCustomButton("Operations",p.swarm_status_ops,_("buttonOperations","Locust Status"),function()
		string.format("")
		locustStatus(p,"Operations")
	end,20)
end
function locustStatus(p,console)
	string.format("")
	local ship_count = 0
	local closest_distance = 500000
	local closest_ship = nil
	for i,ship in pairs(swarm_ships) do
		if ship ~= nil and ship:isValid() then
			ship_count = ship_count + 1
			local current_distance = distance(p,ship)
			if current_distance < closest_distance then
				closest_distance = current_distance
				closest_ship = ship
			end
		end
	end
	local out = string.format(_("msgRelay","%i Locusts remain."),ship_count)
	if ship_count == 1 then
		out = string.format(_("msgRelay","One Locust remains in sector %s"),closest_ship:getSectorName())
	else
		out = string.format(_("msgRelay","%s\nThe closest is in sector %s"),out,closest_ship:getSectorName())
	end
	if p.locust_status_message == nil then
		p.locust_status_message = {}
	end
	p.locust_status_message[console] = string.format("locust_status_message_%s",console)
	p:addCustomMessage(console,p.locust_status_message[console],out)
end
--	Events
function wormholeTax(self,teleportee)
	string.format("")
	if teleportee.typeName == "CpuShip" or teleportee.typeName == "PlayerSpaceship" then
		teleportee:setSystemHealth("beamweapons",teleportee:getSystemHealth("beamweapons") - .5)
		teleportee:setSystemHealth("missilesystem",teleportee:getSystemHealth("missilesystem") - .5)
		if teleportee.typeName == "PlayerSpaceship" then
			teleportee:setEnergy(teleportee:getEnergy()/2)
		end
	end
end
function playerDestruction()
	string.format("")
end
function organicSystems(self,instigator)
	if locust_template == "Fighter" then
		--						Arc Dir	Range	Cycle time			Damage
		self:setBeamWeapon(0,	60,	0,	1000,	4 + random(-1,1),	4 + random(-1,1))
		self:setRotationMaxSpeed(28 + random(-2,2))
	elseif locust_template == "MT52 Hornet" then
		--						Arc Dir	Range	Cycle time			Damage
		self:setBeamWeapon(0,	30,	0,	700,	4 + random(-1,1),	3 + random(-2,3))
		self:setRotationMaxSpeed(28 + random(-2,2))
	elseif locust_template == "Ktlitan Drone" then
		--						Arc Dir	Range	Cycle time			Damage
		self:setBeamWeapon(0,	40,	0,	600,	4 + random(-1,1),	6 + random(-1,1))
		self:setRotationMaxSpeed(15 + random(-2,2))
	end
end
--	Utility 
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
function testFormation()
	swarm_x = 0
	swarm_y = 0
	leader = CpuShip():setTemplate("MT52 Hornet"):setPosition(swarm_x,swarm_y)
	first_ring = {}
	second_ring = {}
	second_interspersed_ring = {}
	third_ring = {}
	fourth_ring = {}
	fifth_ring = {}
	sixth_ring = {}
	seventh_ring = {}
	ship_spacing = 1000
	for i=0,5 do
		local rx, ry = vectorFromAngleNorth(60*i,ship_spacing)
		rx = rx + swarm_x
		ry = ry + swarm_y
		local ship = CpuShip():setTemplate("MT52 Hornet"):setPosition(rx,ry)
		table.insert(first_ring,{ship = ship, x = rx, y = ry, dist = ship_spacing, angle = 60 * i})
		local r2x, r2y = vectorFromAngleNorth(60*i,ship_spacing*2)
		r2x = r2x + swarm_x
		r2y = r2y + swarm_y
		ship = CpuShip():setTemplate("MT52 Hornet"):setPosition(r2x,r2y)
		table.insert(second_ring,{ship = ship, x = r2x, y = r2y, dist = ship_spacing * 2, angle = 60 * i})
		local r4x, r4y = vectorFromAngleNorth(60*i,ship_spacing*3)
		r4x = r4x + swarm_x
		r4y = r4y + swarm_y
		ship = CpuShip():setTemplate("MT52 Hornet"):setPosition(r4x,r4y)
		table.insert(third_ring,{ship = ship, x = r4x, y = r4y, dist = ship_spacing * 3, angle = 60 * i})
		local r5x, r5y = vectorFromAngleNorth(60 * i + 120,ship_spacing)
		r5x = r5x + r4x
		r5y = r5y + r4y
		ship = CpuShip():setTemplate("MT52 Hornet"):setPosition(r5x,r5y)
		local angle = angleFromVectorNorth(r5x,r5y,swarm_x,swarm_y)
		local dist = distance(r5x,r5y,swarm_x,swarm_y)
		table.insert(third_ring,{ship = ship, x = r5x, y = r5y, dist = dist, angle = angle})
		r5x, r5y = vectorFromAngleNorth(60 * i + 120,ship_spacing * 2)
		r5x = r5x + r4x
		r5y = r5y + r4y
		ship = CpuShip():setTemplate("MT52 Hornet"):setPosition(r5x,r5y)
		angle = angleFromVectorNorth(r5x,r5y,swarm_x,swarm_y)
		dist = distance(r5x,r5y,swarm_x,swarm_y)
		table.insert(third_ring,{ship = ship, x = r5x, y = r5y, dist = dist, angle = angle})
		local r6x, r6y = vectorFromAngleNorth(60*i,ship_spacing*4)
		r6x = r6x + swarm_x
		r6y = r6y + swarm_y
		ship = CpuShip():setTemplate("MT52 Hornet"):setPosition(r6x,r6y)
		table.insert(fourth_ring,{ship = ship, x = r6x, y = r6y, dist = ship_spacing * 4, angle = 60 * i})

		local r7x, r7y = vectorFromAngleNorth(60 * i + 120,ship_spacing)
		r7x = r7x + r6x
		r7y = r7y + r6y
		ship = CpuShip():setTemplate("MT52 Hornet"):setPosition(r7x,r7y)
		angle = angleFromVectorNorth(r7x,r7y,swarm_x,swarm_y)
		dist = distance(r7x,r7y,swarm_x,swarm_y)
		table.insert(fourth_ring,{ship = ship, x = r7x, y = r7y, dist = dist, angle = angle})
		r7x, r7y = vectorFromAngleNorth(60 * i + 120,ship_spacing * 2)
		r7x = r7x + r6x
		r7y = r7y + r6y
		ship = CpuShip():setTemplate("MT52 Hornet"):setPosition(r7x,r7y)
		angle = angleFromVectorNorth(r7x,r7y,swarm_x,swarm_y)
		dist = distance(r7x,r7y,swarm_x,swarm_y)
		table.insert(fourth_ring,{ship = ship, x = r7x, y = r7y, dist = dist, angle = angle})
		r7x, r7y = vectorFromAngleNorth(60 * i + 120,ship_spacing * 3)
		r7x = r7x + r6x
		r7y = r7y + r6y
		ship = CpuShip():setTemplate("MT52 Hornet"):setPosition(r7x,r7y)
		angle = angleFromVectorNorth(r7x,r7y,swarm_x,swarm_y)
		dist = distance(r7x,r7y,swarm_x,swarm_y)
		table.insert(fourth_ring,{ship = ship, x = r7x, y = r7y, dist = dist, angle = angle})
		
		local r8x, r8y = vectorFromAngleNorth(60*i,ship_spacing*5)
		r8x = r8x + swarm_x
		r8y = r8y + swarm_y
		ship = CpuShip():setTemplate("MT52 Hornet"):setPosition(r8x,r8y)
		table.insert(fifth_ring,{ship = ship, x = r8x, y = r8y, dist = ship_spacing * 5, angle = 60 * i})
		for j=1,4 do
			local r9x, r9y = vectorFromAngleNorth(60 * i + 120,ship_spacing * j)
			r9x = r9x + r8x
			r9y = r9y + r8y
			ship = CpuShip():setTemplate("MT52 Hornet"):setPosition(r9x,r9y)
			angle = angleFromVectorNorth(r9x,r9y,swarm_x,swarm_y)
			dist = distance(r9x,r9y,swarm_x,swarm_y)
			table.insert(fifth_ring,{ship = ship, x = r9x, y = r9y, dist = dist, angle = angle})
		end
		r8x, r8y = vectorFromAngleNorth(60*i,ship_spacing*6)
		r8x = r8x + swarm_x
		r8y = r8y + swarm_y
		ship = CpuShip():setTemplate("MT52 Hornet"):setPosition(r8x,r8y)
		table.insert(sixth_ring,{ship = ship, x = r8x, y = r8y, dist = ship_spacing * 6, angle = 60 * i})
		for j=1,5 do
			local r9x, r9y = vectorFromAngleNorth(60 * i + 120,ship_spacing * j)
			r9x = r9x + r8x
			r9y = r9y + r8y
			ship = CpuShip():setTemplate("MT52 Hornet"):setPosition(r9x,r9y)
			angle = angleFromVectorNorth(r9x,r9y,swarm_x,swarm_y)
			dist = distance(r9x,r9y,swarm_x,swarm_y)
			table.insert(sixth_ring,{ship = ship, x = r9x, y = r9y, dist = dist, angle = angle})
		end
		r8x, r8y = vectorFromAngleNorth(60*i,ship_spacing*7)
		r8x = r8x + swarm_x
		r8y = r8y + swarm_y
		ship = CpuShip():setTemplate("MT52 Hornet"):setPosition(r8x,r8y)
		table.insert(seventh_ring,{ship = ship, x = r8x, y = r8y, dist = ship_spacing * 7, angle = 60 * i})
		for j=1,6 do
			local r9x, r9y = vectorFromAngleNorth(60 * i + 120,ship_spacing * j)
			r9x = r9x + r8x
			r9y = r9y + r8y
			ship = CpuShip():setTemplate("MT52 Hornet"):setPosition(r9x,r9y)
			angle = angleFromVectorNorth(r9x,r9y,swarm_x,swarm_y)
			dist = distance(r9x,r9y,swarm_x,swarm_y)
			table.insert(seventh_ring,{ship = ship, x = r9x, y = r9y, dist = dist, angle = angle})
		end		
		if i > 0 then
			local r3x = (r2x + second_ring[i].x) / 2
			local r3y = (r2y + second_ring[i].y) / 2
			ship = CpuShip():setTemplate("MT52 Hornet"):setPosition(r3x,r3y)
			local angle = angleFromVectorNorth(r3x,r3y,swarm_x,swarm_y)
			local dist = distance(r3x,r3y,swarm_x,swarm_y)
			table.insert(second_interspersed_ring,{ship = ship, x = r3x, y = r3y, dist = dist, angle = angle})
		end
	end
	print("First ring:")
	for i,first in ipairs(first_ring) do
		print("x:",first.x,"y:",first.y,"dist:",first.dist,"angle:",first.angle)
	end
	print("Second ring:")
	for i,second in ipairs(second_ring) do
		print("x:",second.x,"y:",second.y,"dist:",second.dist,"angle:",second.angle)
	end
	for i,second in ipairs(second_interspersed_ring) do
		print("x:",second.x,"y:",second.y,"dist:",second.dist,"angle:",second.angle)
	end
	print("Third ring:")
	for i,third in ipairs(third_ring) do
		print("x:",third.x,"y:",third.y,"dist:",third.dist,"angle:",third.angle)
	end
	print("Fourth ring:")
	for i,fourth in ipairs(fourth_ring) do
		print("x:",fourth.x,"y:",fourth.y,"dist:",fourth.dist,"angle:",fourth.angle)
	end
	print("Fifth ring:")
	for i,fifth in ipairs(fifth_ring) do
		print("x:",fifth.x,"y:",fifth.y,"dist:",fifth.dist,"angle:",fifth.angle)
	end
	print("Sixth ring:")
	for i,sixth in ipairs(sixth_ring) do
		print("x:",sixth.x,"y:",sixth.y,"dist:",sixth.dist,"angle:",sixth.angle)
	end
	print("Seventh ring:")
	for i,seventh in ipairs(seventh_ring) do
		print("x:",seventh.x,"y:",seventh.y,"dist:",seventh.dist,"angle:",seventh.angle)
	end
	--	
	swarm_x = 40000
	swarm_y = 40000
	local flight_angle = 135
	local spawn_distance = 1000
	local ship = CpuShip():setTemplate("MT52 Hornet"):setPosition(swarm_x,swarm_y):setHeading(flight_angle)
	local leader_ship = ship
	for i, form in ipairs(hex_ring_positions) do
		local form_x, form_y = vectorFromAngleNorth(flight_angle + form.angle, form.dist * spawn_distance)
		local form_prime_x, form_prime_y = vectorFromAngle(form.angle, form.dist * spawn_distance)
		ship = CpuShip():setTemplate("MT52 Hornet"):setPosition(swarm_x + form_x, swarm_y + form_y):setHeading(flight_angle):orderFlyFormation(leader_ship,form_prime_x,form_prime_y)
	end
	leader_ship:orderFlyTowards(100000,100000)
end
--	Communications 
function commsBriefing()
	string.format("")
	setCommsMessage(string.format(_("orders-comms","Hello %s,\nOur sensors have picked up numerous Exuari ships."),comms_source:getCallSign()))
	addCommsReply(_("orders-comms","How many is numerous?"),function()
		setCommsMessage(string.format(_("orders-comms","Approximately %s"),swarm_estimate))
		addCommsReply(_("orders-comms","That's quite a few. What kind of ships?"),function()
			setCommsMessage(string.format(_("orders-comms","They look like %ss. The computer calls them locusts. They're very fast."),locust_template_desc))
			addCommsReply(_("orders-comms","Should we be worried?"),function()
				setCommsMessage(_("orders-comms","Individually, they should be easy to handle. As a group, they could be a problem."))
				addCommsReply(_("orders-comms","What do you want us to do about them?"),function()
					setCommsMessage(_("orders-comms","Get rid of them. Every last one of them."))
					comms_target:setCommsFunction(nil)
					comms_target:setCommsScript("comms_station.lua")
				end)
			end)
		end)
	end)
	return true
end
function commsGatherBriefing()
	string.format("")
	setCommsMessage(string.format(_("orders-comms","Greetings %s,\nWe've got an update for you on those Exuari Locusts."),comms_source:getCallSign()))
	addCommsReply(_("orders-comms","Tell us about it."),function()
		setCommsMessage(_("orders-comms","All the Exuari on our sensors have started moving."))
		addCommsReply(_("orders-comms","Where are they going?"),function()
			setCommsMessage(_("orders-comms","We are not quite sure, but they seem to be converging on a central location."))
			addCommsReply(_("orders-comms","That could make it harder for us to get rid of them."),function()
				setCommsMessage(_("orders-comms","How perceptive of you! We are so glad you are out there working to rid us of these Locusts. Keep up the good work!"))
				comms_target:setCommsFunction(nil)
				comms_target:setCommsScript("comms_station.lua")
			end)
		end)
	end)
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
		return false
	end
	if p:isCommsScriptOpen() then
		return false
	end
	return true
end
function getBriefingStation(p)
	local briefing_stations = {}
	local alternate_briefing_stations = {}
	local station_briefing = nil
	for i,station in ipairs(station_list) do
		if station ~= nil and station:isValid() then
			if station:getFaction() == player_faction then
				station_briefing = station
			end
			if station:isFriendly(p) then
				table.insert(briefing_stations,station)
			elseif not station:isEnemy(p) then
				table.insert(alternate_briefing_stations,station)
			end
		end
	end
	if station_briefing == nil then
		if #briefing_stations > 0 then
			station_briefing = briefing_stations[math.random(1,#briefing_stations)]
		else
			station_briefing = alternate_briefing_stations[math.random(1,#alternate_briefing_stations)]
		end
	end
	return station_briefing
end
--	Update 
function gatherSwarm()
	if swarm_gather == nil then
		local total_x = 0
		local total_y = 0
		local ship_count = 0
		for i,ship in ipairs(swarm_ships) do
			if ship:isValid() then
				local x, y = ship:getPosition()
				total_x = total_x + x
				total_y = total_y + y
				ship_count = ship_count + 1
			end
		end
		gather_x = total_x/ship_count
		gather_y = total_y/ship_count
		for i,ship in ipairs(swarm_ships) do
			if ship:isValid() then
				ship:orderFlyTowards(gather_x,gather_y)
			end
		end
		swarm_gather = "started"
	elseif swarm_gather == "started" then
		local swarmed_count = 0
		for i,ship in ipairs(swarm_ships) do
			if ship:isValid() then
				if distance(ship,gather_x,gather_y) < 10000 then
					swarmed_count = swarmed_count + 1
				end
			end
		end
		if swarmed_count > swarm_slots/swarm_rings then
			local closest_ship = nil
			local closest_ship_dist = 10000
			for i,ship in ipairs(swarm_ships) do
				if ship:isValid() then
					local current_dist = distance(ship,gather_x,gather_y)
					if current_dist < closest_ship_dist then
						closest_ship_dist = current_dist
						closest_ship = ship
					end
				end
			end
			lead_ship = closest_ship
			lead_ship:orderRoaming():setImpulseMaxSpeed(110):setRotationMaxSpeed(20)
			local flight_angle = lead_ship:getHeading()
			local spawn_distance = 1000
			local j = 0
			for i,ship in ipairs(swarm_ships) do
				if ship ~= lead_ship then
					j = j + 1
					local form = hex_ring_positions[j]
					local form_prime_x, form_prime_y = vectorFromAngle(form.angle, form.dist * spawn_distance)
					ship:orderFlyFormation(lead_ship,form_prime_x,form_prime_y)
				end
			end
			swarm_gather = "gathered"
		end
	elseif swarm_gather == "gathered" then
		if lead_ship == nil or not lead_ship:isValid() then
			local total_x = 0
			local total_y = 0
			local ship_count = 0
			for i,ship in ipairs(swarm_ships) do
				if ship:isValid() then
					local x, y = ship:getPosition()
					total_x = total_x + x
					total_y = total_y + y
					ship_count = ship_count + 1
				end
			end
			gather_x = total_x/ship_count
			gather_y = total_y/ship_count
			local closest_ship = nil
			local closest_ship_dist = 500000
			for i,ship in ipairs(swarm_ships) do
				if ship:isValid() then
					local current_dist = distance(ship,gather_x,gather_y)
					if current_dist < closest_ship_dist then
						closest_ship_dist = current_dist
						closest_ship = ship
					end
				end
			end
			lead_ship = closest_ship
			if lead_ship ~= nil and lead_ship:isValid() then
				lead_ship:orderRoaming():setImpulseMaxSpeed(110):setRotationMaxSpeed(20)
				local flight_angle = lead_ship:getHeading()
				local spawn_distance = 1000
				local j = 0
				for i,ship in ipairs(swarm_ships) do
					if ship ~= lead_ship then
						j = j + 1
						local form = hex_ring_positions[j]
						local form_prime_x, form_prime_y = vectorFromAngle(form.angle, form.dist * spawn_distance)
						ship:orderFlyFormation(lead_ship,form_prime_x,form_prime_y)
					end
				end
			end
		end
	end
end
function modifyLocustBehavior()
	if behavior_modified == nil then
		for i,ship in pairs(swarm_ships) do
			if ship:isValid() then
				ship:setAI("default")
			end
		end
		behavior_modified = "done"
	end
end
function update(delta)
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
	for pidx, p in ipairs(getActivePlayerShips()) do
		if p.pidx == nil then
			p.pidx = pidx
			setPlayers(p)
		end
		if p.briefing == nil then
			local station_briefing = getBriefingStation(p)
			if station_briefing ~= nil and availableForComms(p) then
				station_briefing:setCommsScript("")
				station_briefing:setCommsFunction(commsBriefing)
				station_briefing:openCommsTo(p)
				p.briefing = "first"
			end
		elseif p.briefing == "first" and getScenarioTime() > 660 then
			local station_briefing = getBriefingStation(p)
			if station_briefing ~= nil and availableForComms(p) then
				station_briefing:setCommsScript("")
				station_briefing:setCommsFunction(commsGatherBriefing)
				station_briefing:openCommsTo(p)
				p.briefing = "second"
			end
		end
		if swarm_ships ~= nil then
			if #swarm_ships > 0 then
				for i,ship in ipairs(swarm_ships) do
					if ship ~= nil and ship:isValid() then
						if distance(ship,p) < 5000 then
							ship:orderRoaming()
						end
					else
						swarm_ships[i] = swarm_ships[#swarm_ships]
						swarm_ships[#swarm_ships] = nil
						break
					end
				end
			else
				local tpa = Artifact():setFaction(player_faction)
				local surviving_station_count = 0
				local final_enemy_station_count = 0
				local final_friendly_station_count = 0
				local final_neutral_station_count = 0
				for i,station in pairs(station_list) do
					if station ~= nil and station:isValid() then
						surviving_station_count = surviving_station_count + 1
						if tpa:isEnemy(station) then
							final_enemy_station_count = final_enemy_station_count + 1
						elseif tpa:isFriendly(station) then
							final_friendly_station_count = final_friendly_station_count + 1
						else
							final_neutral_station_count = final_neutral_station_count + 1
						end
					end
				end
				tpa:destroy()
				globalMessage(string.format(_("msgMainscreen","Surviving stations: %i\nFriendly: %i out of %i\nNeutral: %i out of %i\nEnemy: %i out of %i"),surviving_station_count,final_friendly_station_count,beginning_friendly_station_count,final_neutral_station_count,beginning_neutral_station_count,final_enemy_station_count,beginning_enemy_station_count))
				victory("Human Navy")
			end
		end
	end
	local clean_list = true
	local friendly_stations = 0
	local player = getPlayerShip(-1)
	for i,station in ipairs(station_list) do
		if station ~= nil and station:isValid() then
			if player ~= nil and player:isValid() then
				if station:isFriendly(player) then
					friendly_stations = friendly_stations + 1
				end
			end
		else
			station_list[i] = station_list[#station_list]
			station_list[#station_list] = nil
			clean_list = false
			break
		end
	end
	if clean_list and player ~= nil and player:isValid() and friendly_stations < 1 then
		globalMessage(_("msgMainscreen","All friendly stations have been destroyed."))
		victory("Exuari")
	end
	if getScenarioTime() > 600 then
		gatherSwarm()
	end
	if getScenarioTime() > 1800 then
		modifyLocustBehavior()
	end
end