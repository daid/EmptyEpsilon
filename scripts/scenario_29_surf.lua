-- Name: Surf's Up!
-- Description: Wave after wave of enemy ships attack, each wave harder than the previous wave. Single or multiple player ships may participate. Scenario is over when the friendly bases are destroyed. Loosely based on the Waves scenario. The differences between Waves and Surf's Up: Initial configuration options (faster moving enemy ships, set the start wave), random wave type (normal, hunt enemy base, formation flying, asteroid storm), services split between friendly stations, side missions to enhance stations, enemies may drop deadly warp jammers. 
---
--- No victory condition. How many waves can you complete?
---
--- Version 1
---
--- USN Discord: https://discord.gg/PntGG3a where you can join a game online. There's one almost every weekend. All experience levels are welcome. 
-- Type: Basic
-- Setting[Enemies]: Configures strength and/or number of enemies in this scenario
-- Enemies[Easy]: Fewer or weaker enemies
-- Enemies[Normal|Default]: Normal number or strength of enemies
-- Enemies[Hard]: More or stronger enemies
-- Enemies[Extreme]: Much stronger, many more enemies
-- Enemies[Quixotic]: Insanely strong and/or inordinately large numbers of enemies
-- Setting[Prototype]: Use alternative player ship or not
-- Prototype[None|Default]: Select a normal player ship from the next screen
-- Prototype[Cruiser]: Spawn a player cruiser
-- Prototype[Missile Cruiser]: Spawn a player missile cruiser (no beams)
-- Prototype[Fighter]: Spawn a player fighter (no warp or jump)
-- Setting[Pace]: Configures how fast the enemy ships move
-- Pace[Normal|Default]: Enemy ships move at their normal speed
-- Pace[10]: Enemy ships move ten percent faster than normal
-- Pace[20]: Enemy ships move twenty percent faster than normal
-- Pace[30]: Enemy ships move thirty percent faster than normal
-- Pace[40]: Enemy ships move forty percent faster than normal
-- Pace[50]: Enemy ships move fifty percent faster than normal
-- Setting[Advance]: Configure the simulated wave level. Default is one
-- Advance[1|Default]: Normal wave start point
-- Advance[2]: Advance wave start to 2
-- Advance[3]: Advance wave start to 3
-- Advance[4]: Advance wave start to 4
-- Advance[5]: Advance wave start to 5
-- Advance[6]: Advance wave start to 6
-- Advance[7]: Advance wave start to 7
-- Advance[8]: Advance wave start to 8
-- Advance[9]: Advance wave start to 9

require("utils.lua")
-- For this scenario, utils.lua provides:
--   vectorFromAngle(angle, length)
--      Returns a relative vector (x, y coordinates)
--   setCirclePos(obj, x, y, angle, distance)
--      Returns the object with its position set to the resulting coordinates.
require("place_station_scenario_utility.lua")
require("cpu_ship_diversification_scenario_utility.lua")
require("generate_call_sign_scenario_utility.lua")
require("comms_scenario_utility.lua")

function init()
	scenario_version = "1.0.8"
	ee_version = "2024.12.08"
	print(string.format("    ----    Scenario: Surf's Up!    ----    Version %s    ----    Tested with EE version %s    ----",scenario_version,ee_version))
	if _VERSION ~= nil then
		print("Lua version:",_VERSION)
	end
	setGlobals()
    constructEnvironment()
    setVariations()
	onNewPlayerShip(setPlayer)
end
function setVariations()
	enemy_config = {
		["Easy"] =		{number = .5,	desc = _("msgMainscreen","Easy")},
		["Normal"] =	{number = 1,	desc = _("msgMainscreen","Normal")},
		["Hard"] =		{number = 2,	desc = _("msgMainscreen","Hard")},
		["Extreme"] =	{number = 3,	desc = _("msgMainscreen","Extreme")},
		["Quixotic"] =	{number = 5,	desc = _("msgMainscreen","Quixotic")},
	}
	enemy_power =	enemy_config[getScenarioSetting("Enemies")].number
	local enemy_speed = {
		["Normal"] = 1,
		["10"] = 1.1,
		["20"] = 1.2,
		["30"] = 1.3,
		["40"] = 1.4,
		["50"] = 1.5
	}
	speed_factor = enemy_speed[getScenarioSetting("Pace")]
	local advance_config = {
		["1"] = 0,
		["2"] = 1,
		["3"] = 2,
		["4"] = 3,
		["5"] = 4,
		["6"] = 5,
		["7"] = 6,
		["8"] = 7,
		["9"] = 8,
	}
	wave_advance = advance_config[getScenarioSetting("Advance")]
    --	Alternative player ship
    local prototype_config = {
    	["None"] = "None",
    	["Cruiser"] = "Player Cruiser",
    	["Missile Cruiser"] = "Player Missile Cr.",
    	["Fighter"] = "Player Fighter",
    }
    if getScenarioSetting("Prototype") ~= "None" then
    	local ship = PlayerSpaceship():setTemplate(prototype_config[getScenarioSetting("Prototype")])
    	if prototype_config[getScenarioSetting("Prototype")] == "Player Fighter" then
--       		          		 Arc, Dir,Range,Cycle, Dmg
			ship:setBeamWeapon(0, 65,   0,  700,	4, 4)
			ship:setBeamWeapon(1, 40, -10, 1000,	6, 6)
			ship:setBeamWeapon(2, 40,  10, 1000,	6, 6)	
    	end
    end
end
function setGlobals()
    wave_number = 0
    spawn_wave_delay = nil
	add_station_to_database = true
    include_goods_for_sale_in_status = true
    include_ordnance_in_status = true
    stations_sell_goods = true
    current_orders_button = true
    primary_orders = _("orders-comms","Defend friendly stations.")
    secondary_orders = ""
    enemy_list = {}
    friendly_stations = {}
    neutral_stations = {}
    station_list = {}
    transport_list = {}
    nebulas = {}
    check_zones = {}
    mission_good = {}
    mission_goods = {}
    asteroid_storm = false
    storm_asteroids = {}
    player_spawn_count = 0
    name_categories = {
    	"Science",
    	"History",
    	"Pop Sci Fi",
    	"Spec Sci Fi",
    	"Generic",
    }
	mission_reasons = {
		["energy"] = {
			[_("situationReport-comms", "A recent reactor failure has put us on auxiliary power, so we cannot recharge ships.")] = {
				"nickel","platinum","gold","dilithium","tritanium","cobalt","optic","filament","sensor","lifter","software","circuit","battery"
			},
			[_("situationReport-comms", "A damaged power coupling makes it too dangerous to recharge ships.")] = {
				"nickel","platinum","gold","dilithium","tritanium","cobalt","optic","filament","sensor","lifter","circuit","battery"
			},
			[_("situationReport-comms", "An asteroid strike damaged our solar cells and we are short on power, so we can't recharge ships right now.")] = {
				"nickel","platinum","gold","dilithium","tritanium","cobalt","optic","filament","sensor","circuit","battery"
			},
		},
		["hull"] = {
			[_("situationReport-comms", "We're out of the necessary materials and supplies for hull repair.")] = {
				"nickel","platinum","dilithium","tritanium","cobalt","lifter","filament","sensor","circuit","repulsor","nanites","shield"
			},
			[_("situationReport-comms", "Hull repair automation unavailable while it is undergoing maintenance.")] = {
				"nickel","platinum","gold","dilithium","tritanium","cobalt","optic","filament","sensor","lifter","software","circuit","android","robotic","nanites"
			},
			[_("situationReport-comms", "All hull repair technicians quarantined to quarters due to illness.")] = {
				"medicine","transporter","sensor","communication","autodoc","android","nanites"
			},
		},
		["restock_probes"] = {
			[_("situationReport-comms", "Cannot replenish scan probes due to fabrication unit failure.")] = {
				"nickel","platinum","gold","dilithium","tritanium","cobalt","optic","filament","sensor","lifter","software","circuit","battery"
			},
			[_("situationReport-comms", "Parts shortage prevents scan probe replenishment.")] = {
				"optic","filament","shield","impulse","warp","sensor","lifter","circuit","battery","communication"
			},
			[_("situationReport-comms", "Station management has curtailed scan probe replenishment for cost cutting reasons.")] = {
				"nickel","platinum","gold","dilithium","tritanium","cobalt","luxury"
			},
		}
	}
	ship_templates = {
		{name = "Gnat",				warp_jammer = "none",		strength = 2,	create = gnat},
		{name = "MT52 Hornet",		warp_jammer = "none",		strength = 5,	create = stockTemplate},
		{name = "MU52 Hornet",		warp_jammer = "none",		strength = 5,	create = stockTemplate},
		{name = "Adder MK5",		warp_jammer = "none",		strength = 7,	create = stockTemplate},
		{name = "WX-Lindworm",		warp_jammer = "none",		strength = 7,	create = stockTemplate},
		{name = "Adder MK9",		warp_jammer = "none",		strength = 11,	create = stockTemplate},
		{name = "Phobos T3",		warp_jammer = "none",		strength = 15,	create = stockTemplate},
		{name = "Piranha F12",		warp_jammer = "beam",		strength = 15,	create = stockTemplate},
		{name = "Farco 11",			warp_jammer = "plain",		strength = 21,	create = farco11},
		{name = "Ranus U",			warp_jammer = "beam",		strength = 25,	create = stockTemplate},
		{name = "Stalker Q7",		warp_jammer = "missile",	strength = 25,	create = stockTemplate},
		{name = "Stalker R7",		warp_jammer = "missile",	strength = 25,	create = stockTemplate},
		{name = "Maniapak",			warp_jammer = "none",		strength = 34,	create = maniapak},
		{name = "Cucaracha",		warp_jammer = "plain",		strength = 36,	create = cucaracha},
		{name = "Atlantis X23",		warp_jammer = "none",		strength = 50,	create = stockTemplate},
		{name = "Atlantis Y42",		warp_jammer = "plain",		strength = 60,	create = atlantisY42},
		{name = "Enforcer",			warp_jammer = "none",		strength = 75,	create = enforcer},
		{name = "Starhammer III",	warp_jammer = "none",		strength = 85,	create = starhammerIII},
		{name = "Starhammer V",		warp_jammer = "plain",		strength = 90,	create = starhammerV},
		{name = "Tyr",				warp_jammer = "none",		strength = 150,	create = tyr},
	}
    -- Player ship(s)
	player_ship_stats = {	
		["Atlantis"]			= { strength = 52,	cargo = 6,	long_range_radar = 30000, short_range_radar = 5000, 	},
		["Benedict"]			= { strength = 10,	cargo = 9,	long_range_radar = 30000, short_range_radar = 5000, 	},
		["Crucible"]			= { strength = 45,	cargo = 5,	long_range_radar = 20000, short_range_radar = 6000, 	},
		["Ender"]				= { strength = 100,	cargo = 20,	long_range_radar = 45000, short_range_radar = 7000, 	},
		["Flavia P.Falcon"]		= { strength = 13,	cargo = 15,	long_range_radar = 40000, short_range_radar = 5000, 	},
		["Hathcock"]			= { strength = 30,	cargo = 6,	long_range_radar = 35000, short_range_radar = 6000, 	},
		["Kiriya"]				= { strength = 10,	cargo = 9,	long_range_radar = 35000, short_range_radar = 5000, 	},
		["MP52 Hornet"] 		= { strength = 7, 	cargo = 3,	long_range_radar = 18000, short_range_radar = 4000, 	},
		["Maverick"]			= { strength = 45,	cargo = 5,	long_range_radar = 20000, short_range_radar = 4000, 	},
		["Nautilus"]			= { strength = 12,	cargo = 7,	long_range_radar = 22000, short_range_radar = 4000, 	},
		["Phobos M3P"]			= { strength = 19,	cargo = 10,	long_range_radar = 25000, short_range_radar = 5000, 	},
		["Piranha"]				= { strength = 16,	cargo = 8,	long_range_radar = 25000, short_range_radar = 6000, 	},
		["Player Cruiser"]		= { strength = 40,	cargo = 6,	long_range_radar = 30000, short_range_radar = 5000, 	},
		["Player Fighter"]		= { strength = 7,	cargo = 3,	long_range_radar = 15000, short_range_radar = 4500, 	},
		["Player Missile Cr."]	= { strength = 45,	cargo = 8,	long_range_radar = 35000, short_range_radar = 6000, 	},
		["Repulse"]				= { strength = 14,	cargo = 12,	long_range_radar = 38000, short_range_radar = 5000, 	},
		["Striker"]				= { strength = 8,	cargo = 4,	long_range_radar = 35000, short_range_radar = 5000, 	},
		["ZX-Lindworm"]			= { strength = 8,	cargo = 3,	long_range_radar = 18000, short_range_radar = 5500, 	},
	}	
    player_ship_names = {
    	["Atlantis"] =			{"Excaliber","Thrasher","Punisher","Vorpal","Protang","Drummond","Parchim","Coronado"},
    	["Benedict"] =			{"Elizabeth","Ford","Vikramaditya","Liaoning","Avenger","Naruebet","Washington","Lincoln","Garibaldi","Eisenhower"},
    	["Crucible"] =			{"Sling", "Stark", "Torrid", "Kicker", "Flummox", "3rd Charm"},
    	["Ender"] =				{"Mongo","Godzilla","Leviathan","Kraken","Jupiter","Saturn"},
    	["Flavia P.Falcon"] =	{"Ladyhawke","Hunter","Seeker","Gyrefalcon","Kestrel","Magpie","Bandit","Buccaneer"},
    	["Hathcock"] = 			{"Hayha", "Waldron", "Plunkett", "Mawhinney", "Furlong", "Zaytsev", "Pavlichenko", "Pegahmagabow", "Fett", "Hawkeye", "Hanzo"},
    	["Kiriya"] = 			{"Cavour","Reagan","Gaulle","Paulo","Truman","Stennis","Kuznetsov","Roosevelt","Vinson","Old Salt"},
    	["MP52 Hornet"] =		{"Dragonfly","Scarab","Mantis","Yellow Jacket","Jimminy","Flik","Thorny","Buzz"},
    	["Maverick"] =			{"Angel", "Thunderbird", "Roaster", "Magnifier", "Hedge"},
    	["Nautilus"] = 			{"October", "Abdiel", "Manxman", "Newcon", "Nusret", "Pluton", "Amiral", "Amur", "Heinkel", "Dornier"},
    	["Phobos M3P"] =		{"Blinder","Shadow","Distortion","Diemos","Ganymede","Castillo","Thebe","Retrograde"},
    	["Piranha"] =			{"Razor","Biter","Ripper","Voracious","Carnivorous","Characid","Vulture","Predator"},
    	["Player Cruiser"] =	{"Excelsior","Velociraptor","Thunder","Kona","Encounter","Perth","Aspern","Panther"},
    	["Player Fighter"] =	{"Buzzer","Flitter","Zippiticus","Hopper","Molt","Stinger","Stripe"},
    	["Player Missile Cr."] ={"Projectus","Hurlmeister","Flinger","Ovod","Amatola","Nakhimov","Antigone"},
		["Repulse"] = 			{"Fiddler","Brinks","Loomis","Mowag","Patria","Pandur","Terrex","Komatsu","Eitan"},
    	["Striker"] =			{"Sparrow","Sizzle","Squawk","Crow","Phoenix","Snowbird","Hawk"},
    	["ZX-Lindworm"] =		{"Seagull","Catapult","Blowhard","Flapper","Nixie","Pixie","Tinkerbell"},
		["Player Cruiser"] =	{"Excelsior","Velociraptor","Thunder","Kona","Encounter","Perth","Aspern","Panther"},
		["Player Missile Cr."] ={"Projectus","Hurlmeister","Flinger","Ovod","Amatola","Nakhimov","Antigone"},
		["Player Fighter"] =	{"Buzzer","Flitter","Zippiticus","Hopper","Molt","Stinger","Stripe"},
    	["Leftovers"] =			{"Foregone","Righteous","Masher"},
    }
end
function constructEnvironment()
    -- Random friendly stations
    local station_angle = random(0,360)
    local station_x, station_y = vectorFromAngle(station_angle,random(2000,5000))
    local name_category = tableRemoveRandom(name_categories)
    local station = placeStation(station_x, station_y,name_category,"Human Navy")
    setReinforcements(station)
    table.insert(friendly_stations, station)
    table.insert(station_list, station)
    local dx, dy = vectorFromAngle(station_angle + random(-60,60),random(2000,5000))
    name_category = tableRemoveRandom(name_categories)
    station = placeStation(station_x + dx, station_y + dy,name_category,"Human Navy")
    setReinforcements(station)
    table.insert(friendly_stations, station)
    spreadServiceToStations(friendly_stations)
    table.insert(station_list, station)
	local reason_list = {}
	for i,station in ipairs(friendly_stations) do
		if not station:getRestocksScanProbes() then
			if station.probe_fail_reason == nil then
				reason_list = {
					_("situationReport-comms", "Cannot replenish scan probes due to fabrication unit failure."),
					_("situationReport-comms", "Parts shortage prevents scan probe replenishment."),
					_("situationReport-comms", "Station management has curtailed scan probe replenishment for cost cutting reasons."),
				}
				station.probe_fail_reason = tableSelectRandom(reason_list)
				mission_goods["restock_probes"] = mission_reasons["restock_probes"][station.probe_fail_reason]
			end
		end
		if not station:getRepairDocked() then
			if station.repair_fail_reason == nil then
				reason_list = {
					_("situationReport-comms", "We're out of the necessary materials and supplies for hull repair."),
					_("situationReport-comms", "Hull repair automation unavailable while it is undergoing maintenance."),
					_("situationReport-comms", "All hull repair technicians quarantined to quarters due to illness."),
				}
				station.repair_fail_reason = tableSelectRandom(reason_list)
				mission_goods["hull"] = mission_reasons["hull"][station.repair_fail_reason]
			end
		end
		if not station:getSharesEnergyWithDocked() then
			if station.energy_fail_reason == nil then
				reason_list = {
					_("situationReport-comms", "A recent reactor failure has put us on auxiliary power, so we cannot recharge ships."),
					_("situationReport-comms", "A damaged power coupling makes it too dangerous to recharge ships."),
					_("situationReport-comms", "An asteroid strike damaged our solar cells and we are short on power, so we can't recharge ships right now."),
				}
				station.energy_fail_reason = tableSelectRandom(reason_list)
				mission_goods["energy"] = mission_reasons["energy"][station.energy_fail_reason]
			end
		end
	end
    -- Random nebulae
    local neb_x, neb_y = vectorFromAngle(random(0, 360), 15000)
    for n = 1, 5 do
        local d_neb_x, d_neb_y = vectorFromAngle(random(0, 360), random(2500, 10000))
        table.insert(nebulas,Nebula():setPosition(neb_x + d_neb_x, neb_y + d_neb_y))
    end
    -- Random asteroids
    for cnt = 1, random(2, 7) do
        local major_angle = random(0, 360)
        local minor_angle = random(0, 360)
        local dist = random(3000, 15000 + cnt * 5000)
        local base_x, base_y = vectorFromAngle(major_angle, dist)
        for a_cnt = 1, 25 do
            dx1, dy1 = vectorFromAngle(minor_angle, random(-1000, 1000))
            dx2, dy2 = vectorFromAngle(minor_angle + 90, random(-10000, 10000))
            Asteroid():setPosition(base_x + dx1 + dx2, base_y + dy1 + dy2):setSize(random(4,300) + random(4,300) + random(4,300))
        end
        for a_cnt = 1, 50 do
            dx1, dy1 = vectorFromAngle(minor_angle, random(-1500, 1500))
            dx2, dy2 = vectorFromAngle(minor_angle + 90, random(-10000, 10000))
            VisualAsteroid():setPosition(base_x + dx1 + dx2, base_y + dy1 + dy2):setSize(random(4,300) + random(4,300) + random(4,300))
        end
    end
    -- Random neutral stations
    for n = 1, 6 do
		name_category = tableRemoveRandom(name_categories)
		if name_category == nil then
			name_category = "RandomHumanNeutral"
		end
    	local station = placeStation(0,0,name_category,"Independent")
    	setCirclePos(station, 0, 0, random(0,360), random(15000,30000))
    	table.insert(neutral_stations,station)
	    table.insert(station_list, station)
    end
    spreadServiceToStationPairs(neutral_stations)
    setImprovementMissions()
end
function setImprovementMissions()
    --	set up ad hoc improvement missions
    local ordnance_missions = {
		"Homing","Nuke","EMP","Mine","HVLI",
    }
    for i,mission in ipairs(ordnance_missions) do
    	mission_goods[mission] = {"nickel","platinum","gold","dilithium","tritanium","cobalt","circuit","filament"}
    end
    table.insert(mission_goods.Homing,"sensor")
    table.insert(mission_goods.Nuke,"sensor")
    table.insert(mission_goods.EMP,"sensor")
    local missions_stations_goods = {}
    for i,neutral_station in ipairs(neutral_stations) do
    	if neutral_station.comms_data ~= nil and neutral_station.comms_data.goods ~= nil then
			for station_good,details in pairs(neutral_station.comms_data.goods) do
				for mission,mission_goods in pairs(mission_goods) do
					for k,mission_good in ipairs(mission_goods) do
						if mission_good == station_good then
							if missions_stations_goods[mission] == nil then
								missions_stations_goods[mission] = {}
							end
							if missions_stations_goods[mission][neutral_station] == nil then
								missions_stations_goods[mission][neutral_station] = {}
							end
							table.insert(missions_stations_goods[mission][neutral_station],mission_good)
						end
					end
				end
			end
		end
    end
    --	Pick goods for missions
    local already_selected_station = {}
    local already_selected_good = {}
    for mission,stations_goods in pairs(missions_stations_goods) do
    	local station_pool = {}
    	for station,goods in pairs(stations_goods) do
    		if #already_selected_station > 0 then
    			local exclude = false
    			for i,previous_station in ipairs(already_selected_station) do
    				if station == previous_station then
    					exclude = true
    				end
    			end
    			if not exclude then
    				table.insert(station_pool,station)
    			end
    		else
    			table.insert(station_pool,station)
    		end
    	end
    	if #station_pool > 0 then
			local selected_station = station_pool[math.random(1,#station_pool)]
			table.insert(already_selected_station,selected_station)
			local good = stations_goods[selected_station][math.random(1,#stations_goods[selected_station])]
			if #already_selected_good > 0 then
				local good_selected = false
				for i,previous_good in ipairs(already_selected_good) do
					if previous_good == good then
						good_selected = true
						break
					end
				end
				if not good_selected then
					mission_good[mission] = {good = good, station = selected_station}
					mission_goods[mission] = {good}
					table.insert(already_selected_good,good)
					selected_station.selected_mission_good = good
				end
			else
				mission_good[mission] = {good = good, station = selected_station}
				mission_goods[mission] = {good}
				table.insert(already_selected_good,good)
				selected_station.selected_mission_good = good
			end
		end
    end
    --	complete goods selection for missions
    for mission,goods in pairs(mission_goods) do
    	local selected_good = nil
    	if #goods > 1 then
    		local good_pool = {}
    		for i,good in ipairs(goods) do
    			local good_selected = false
    			for j,previous_good in ipairs(already_selected_good) do
    				if good == previous_good then
    					good_selected = true
    					break
    				end
    			end
    			if not good_selected then
    				table.insert(good_pool,good)
    			end
    		end
    		if #good_pool > 0 then
    			selected_good = good_pool[math.random(1,#good_pool)]
    			mission_good[mission] = {good = selected_good}
    			table.insert(already_selected_good,selected_good)
    		else
	    		selected_good = goods[math.random(1,#goods)]
    			mission_good[mission] = {good = selected_good}
    		end
    	else
    		selected_good = goods[1]
    	end
    end
    for mission,details in pairs(mission_good) do
    	if details.station == nil then
			for i,station in ipairs(neutral_stations) do
				if station.selected_mission_good == nil then
					if station.comms_data.goods == nil then
						station.comms_data.goods = {}
					end
					station.comms_data.goods[details.good] = {quantity = math.random(3,8), cost = math.random(40,80)}
					station.selected_mission_good = details.good
					details.station = station
					break
				end
			end
		end
    end
end
function setReinforcements(station)
	station.comms_data = {}
	station.comms_data.service_cost = {}
	station.comms_data.service_cost.amk3_reinforcements = math.random(75,125)
	station.comms_data.service_cost.hornet_reinforcements = math.random(75,125)
	station.comms_data.service_cost.reinforcements = math.random(140,160)
	station.comms_data.service_cost.amk8_reinforcements = math.random(150,200)
	station.comms_data.service_cost.phobos_reinforcements = math.random(175,225)
	station.comms_data.service_cost.stalker_reinforcements = math.random(275,325)
	station.comms_data.service_available = {}
	station.comms_data.service_available.amk3_reinforcements = random(1,100) < 72
	station.comms_data.service_available.hornet_reinforcements = random(1,100) < 72
	station.comms_data.service_available.reinforcements = true
	station.comms_data.service_available.amk8_reinforcements = random(1,100) < 72
	station.comms_data.service_available.phobos_reinforcements = random(1,100) < 72
	station.comms_data.service_available.stalker_reinforcements = random(1,100) < 72
end
--------------------------------
--	Initialization utilities  --
--------------------------------
function setPlayer(p)
	player_spawn_count = player_spawn_count + 1
	local player_ship_name = tableRemoveRandom(player_ship_names[p:getTypeName()])
	if player_ship_name == nil then
		player_ship_name = tableRemoveRandom(player_ship_names["Leftovers"])
	end
	if player_ship_name ~= nil then
		p:setCallSign(player_ship_name)
	end
	p.maxCargo = 5
	p.cargo = p.maxCargo
end
function spreadServiceToStationPairs(stations)
	for _,station in ipairs(stations) do
		station:setSharesEnergyWithDocked(false)
		station:setRepairDocked(false)
		station:setRestocksScanProbes(false)
		station.comms_data.weapon_available.Homing = false
		station.comms_data.weapon_available.Nuke = false
		station.comms_data.weapon_available.EMP = false
		station.comms_data.weapon_available.Mine = false
		station.comms_data.weapon_available.HVLI = false
        station.comms_data.service_available = {
        	supplydrop =			false, 
        	reinforcements =		false,
   			hornet_reinforcements =	false,
			phobos_reinforcements =	false,
			amk3_reinforcements =	false,
			amk8_reinforcements =	false,
		}
        station.comms_data.service_cost = {
        	supplydrop = math.random(90,110), 
        	reinforcements = math.random(140,160),
   			hornet_reinforcements =	math.random(75,125),
			phobos_reinforcements =	math.random(175,225),
			amk3_reinforcements = math.random(75,125),
			amk8_reinforcements = math.random(150,200),
        }
	end
	local station_service_pool = {
		"energy","hull","restock_probes","homing","nuke","emp","mine","hvli",
		"supply_drop","reinforcements","hornet_reinforcements","phobos_reinforcements","amk3_reinforcements","amk8_reinforcements",
	}
	local station_pool = {}
	while(#station_service_pool > 0) do
		local service = tableRemoveRandom(station_service_pool)
		if #station_pool < 1 then
			for i,station in ipairs(stations) do
				table.insert(station_pool,station)
			end
		end
		local station_1 = tableRemoveRandom(station_pool)
		if #station_pool < 1 then
			for i,station in ipairs(stations) do
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
		end
	end
end
function spreadServiceToStations(stations)
	for _,station in ipairs(stations) do
		station:setSharesEnergyWithDocked(false)
		station:setRepairDocked(false)
		station:setRestocksScanProbes(false)
		station.comms_data.weapon_available = {}
		station.comms_data.weapon_available.Homing = false
		station.comms_data.weapon_available.Nuke = false
		station.comms_data.weapon_available.EMP = false
		station.comms_data.weapon_available.Mine = false
		station.comms_data.weapon_available.HVLI = false
        station.comms_data.service_available = {
        	supplydrop =			false, 
        	reinforcements =		false,
   			hornet_reinforcements =	false,
			phobos_reinforcements =	false,
			amk3_reinforcements =	false,
			amk8_reinforcements =	false,
		}
        station.comms_data.service_cost = {
        	supplydrop = math.random(90,110), 
        	reinforcements = math.random(140,160),
   			hornet_reinforcements =	math.random(75,125),
			phobos_reinforcements =	math.random(175,225),
			amk3_reinforcements = math.random(75,125),
			amk8_reinforcements = math.random(150,200),
        }
	end
	local station_service_pool = {
		"energy","hull","restock_probes","homing","nuke","emp","mine","hvli",
		"supply_drop","reinforcements","hornet_reinforcements","phobos_reinforcements","amk3_reinforcements","amk8_reinforcements",
	}
	local station_pool = {}
	while(#station_service_pool > 0) do
		local service = tableRemoveRandom(station_service_pool)
		if #station_pool < 1 then
			for _,station in ipairs(stations) do
				table.insert(station_pool,station)
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
		end
	end
end
-------------------------
--	General utilities  --
-------------------------
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
function tableSelectRandom(array)
	local array_item_count = #array
    if array_item_count == 0 then
        return nil
    end
	return array[math.random(1,#array)]	
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
function vectorFromAngleNorth(angle,distance)
--	print("input angle to vectorFromAngleNorth:")
--	print(angle)
	angle = (angle + 270) % 360
	local x, y = vectorFromAngle(angle,distance)
	return x, y
end
function getDuration()
	local duration = getScenarioTime()
	local duration_string = math.floor(duration)
	if duration > 60 then
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
			duration_string = string.format(_("msgMainscreen","%s minute and %s seconds"),minutes,seconds)
		end
	else
		duration_string = string.format(_("msgMainscreen","%s seconds"),duration_string)
	end
	return duration_string
end
function nameBanner(p)
	local banner = string.format(_("name-tab","%s in %s"),p:getCallSign(),p:getSectorName())
	p.name_tag_hlm = "name_tag_hlm"
	p:addCustomInfo("Helms",p.name_tag_hlm,banner,1)
	p.name_tag_tac = "name_tag_tac"
	p:addCustomInfo("Tactical",p.name_tag_tac,banner,1)
	p.name_tag_rel = "name_tag_rel"
	p:addCustomInfo("Relay",p.name_tag_rel,banner,1)
	p.name_tag_alt = "name_tag_alt"
	p:addCustomInfo("AltRelay",p.name_tag_alt,banner,1)
	p.name_tag_com = "name_tag_com"
	p:addCustomInfo("CommsOnly",p.name_tag_com,banner,1)
	p.name_tag_log = "name_tag_log"
	p:addCustomInfo("ShipLog",p.name_tag_log,banner,1)
end
function earlyEnd()
	if trigger_end_status == nil then
		trigger_end_status = "button created"
		addGMFunction(_("buttonGM","End with Odin"),function()
			for i,p in ipairs(getActivePlayerShips()) do
				p:addToShipLog(_("shipLog","We picked up an anomalous chroniton particle reading nearby. Encoded within the anomalous reading is a designated point along the timeline in the future. We are still working on the decoding rest of the information, but initial efforts hint at some major military action being taken by the Ghosts. We have placed countdown timers on some of your consoles indicating when this event is supposed to occur."),"Magenta")
			end
			trigger_end_status = "started"
			odin_spawn_time = getScenarioTime() + 30
			addGMMessage(_("msgGM","30 second countdown to Odin spawn has begun."))
			clearGMFunctions()
		end)
	elseif trigger_end_status == "started" then
		if getScenarioTime() > odin_spawn_time then
			if friendly_stations ~= nil then
				if endOdin == nil then
					local station_pool = {}
					for i,station in ipairs(friendly_stations) do
						if station ~= nil and station:isValid() then
							table.insert(station_pool,station)
						end
					end
					if #station_pool > 1 then
						local station_pool = {}
						for i,station in ipairs(friendly_stations) do
							if station ~= nil and station:isValid() then
								table.insert(station_pool,station)
							end
						end
						local first_station = tableRemoveRandom(station_pool)
						local second_station = tableRemoveRandom(station_pool)
						local fx, fy = first_station:getPosition()
						local sx, sy = second_station:getPosition()
						local ox = (fx + sx)/2
						local oy = (fy + sy)/2
						endOdin = CpuShip():setTemplate("Odin"):setFaction("Ghosts")
						endOdin:setPosition(ox, oy):orderRoaming()
					else
						if #station_pool > 0 then
							local fx, fy = station_pool[1]:getPosition()
							local ox, oy = vectorFromAngle(random(0,360),4000)
							endOdin = CpuShip():setTemplate("Odin"):setFaction("Ghosts")
							endOdin:setPosition(fx + ox, fy + oy):orderRoaming()
						else
							endOdin = CpuShip():setTemplate("Odin"):setFaction("Ghosts"):orderRoaming()
						end
					end
					endOdin:setImpulseMaxSpeed(30):setRotationMaxSpeed(5):setAcceleration(5)
					local forward, reverse = endOdin:getImpulseMaxSpeed()
					endOdin:setImpulseMaxSpeed(forward*speed_factor,reverse*speed_factor)
					endOdin:setRotationMaxSpeed(endOdin:getRotationMaxSpeed()*speed_factor)
					endOdin:setAcceleration(endOdin:getAcceleration()*speed_factor)
					trigger_end_status = "spawned"
				end
			end
			for i,p in ipairs(getActivePlayerShips()) do
				p:removeCustom(p.odin_time_rel)
				p:removeCustom(p.odin_time_ops)
				p:removeCustom(p.odin_time_log)
				p:removeCustom(p.odin_time_alt)
			end
		else
			local out_time = math.floor(odin_spawn_time - getScenarioTime())
			local banner = string.format(_("timer-tab","Anomalous Time:%s"),out_time)
			for i,p in ipairs(getActivePlayerShips()) do
				p.odin_time_rel = "odin_time_rel"
				p:addCustomInfo("Relay",p.odin_time_rel,banner,2)
				p.odin_time_ops = "odin_time_ops"
				p:addCustomInfo("Operations",p.odin_time_ops,banner,2)
				p.odin_time_log = "odin_time_log"
				p:addCustomInfo("ShipLog",p.odin_time_log,banner,2)
				p.odin_time_alt = "odin_time_alt"
				p:addCustomInfo("AltRelay",p.odin_time_alt,banner,2)
			end
		end
	end
end
----------------------
--	Plot functions  --
----------------------
function getCurrentOrders()
	addCommsReply(_("orders-comms", "What are my current orders?"), function()
		ordMsg = primary_orders .. "\n" .. secondary_orders
		setCommsMessage(ordMsg)
		addCommsReply(_("Back"), commsStation)
	end)
end
function spawnWave()
	wave_number = wave_number + 1
	if not asteroid_storm then
		if random(1,100) - (wave_number + wave_advance) < 27 and #storm_asteroids == 0 then
			asteroid_storm = true
		end
	end
	enemy_list = {}
	local player_power = 0
	for i,p in ipairs(getActivePlayerShips()) do
		local template_name = p:getTypeName()
		if template_name ~= nil then
			local player_strength = player_ship_stats[template_name].strength
			if player_strength ~= nil then
				player_power = player_power + player_strength
			else
				player_power = player_power + 24
			end
		else
			player_power = player_power + 24
		end
	end
	enemy_strength = math.pow((wave_number + wave_advance),1.35) * 10 * enemy_power + player_power
	current_enemy_strength = 0
	spawn_angle = random(0,360)
	spawn_range = random(20000,25000 + 1000 * (wave_number + wave_advance))
	base_spawn_x, base_spawn_y = vectorFromAngle(spawn_angle,spawn_range)
	local wave_styles = {
		{style = "defense",		chance = 10,	msg = string.format(_("shipLog","Wave %i. Hunt down enemy base."),wave_number),	func = spawnDefense},
		{style = "base",		chance = 20,	msg = string.format(_("shipLog","Wave %i. Hunt down enemy base."),wave_number),	func = spawnBase},
		{style = "formation",	chance = 50,	msg = string.format(_("shipLog","Wave %i."),wave_number),						func = spawnFormation},
		{style = "simple",		chance = 100,	msg = string.format(_("shipLog","Wave %i."),wave_number),						func = spawnSimple},
	}
	local roll = random(1,100) - (wave_number + wave_advance)
	local wave_style = nil
--	print("Roll:",roll,"Wave number:",wave_number,"Enemy strength:",enemy_strength,"Player power:",player_power,"Advance:",wave_advance + 1)
	for i, wave in ipairs(wave_styles) do
		if roll <= wave.chance then
--			print("Wave type selected:",wave.style)
			wave_style = wave
			break
		end
	end
	if wave_style.style == "defense" or wave_style.style == "base" then
		secondary_orders = _("orders-comms","Hunt down enemy base.")
	else
		secondary_orders = ""
	end
	local wave_message = wave_style.msg
	if asteroid_storm then
		wave_message = string.format(_("shipLog","%s Asteroid storm reported."),wave_style.msg)
	end
	for i,p in ipairs(getActivePlayerShips()) do
		p:addToShipLog(wave_message,"Green")
		p:addReputationPoints(50 + wave_number * 10)
		local wave_number_out = string.format(_("tabRelay&Ops","Wave %i"),wave_number)
		p.wave_number_banner_rel = "wave_number_banner_rel"
		p:addCustomInfo("Relay",p.wave_number_banner_rel,wave_number_out,5)
		p.wave_number_banner_ops = "wave_number_banner_ops"
		p:addCustomInfo("Operations",p.wave_number_banner_ops,wave_number_out,5)
	end
	globalMessage(wave_message)
	wave_style.func()
end
function spawnSimple()
	local spawn_point_leader = nil
	local split = false
	while enemy_strength > 0 do
		local attempts = 0
		local selected_ship = nil
		repeat
			selected_ship = ship_templates[math.random(1,#ship_templates)]
			attempts = attempts + 1
		until(selected_ship.strength < (enemy_strength + 3) or attempts > 50)
		local ship = selected_ship.create("Ghosts",selected_ship.name)
		local forward, reverse = ship:getImpulseMaxSpeed()
		ship:setImpulseMaxSpeed(forward*speed_factor,reverse*speed_factor)
		ship:setRotationMaxSpeed(ship:getRotationMaxSpeed()*speed_factor)
		ship:setAcceleration(ship:getAcceleration()*speed_factor)
		if ship:hasWarpDrive() then
			ship:setWarpSpeed(ship:getWarpSpeed()*speed_factor)
		end
		suffix_index = math.random(11,70)
		ship:setCallSign(generateCallSign(nil,"Ghosts"))
		if selected_ship.warp_jammer ~= nil and selected_ship.warp_jammer ~= "none" then
			ship.warp_jammer_count = math.random(0,2)
			ship.warp_jammer_type = selected_ship.warp_jammer
		end
		table.insert(enemy_list,ship)
		if not split then
			if current_enemy_strength >= enemy_strength then
				local angle = random(0,360)
				local dist = random(30000,35000 + 1000 * (wave_number + wave_advance))
				base_spawn_x, base_spawn_y = vectorFromAngle(angle,dist)
				spawn_point_leader = nil
				split = true
			end
		end
		if spawn_point_leader == nil then
			ship:setPosition(base_spawn_x, base_spawn_y)
			spawn_point_leader = ship
			ship:orderRoaming()
		else
			ship:orderDefendTarget(spawn_point_leader)
			local defend_x, defend_y = vectorFromAngle(random(0,360),5000)
			ship:setPosition(base_spawn_x + defend_x, base_spawn_y + defend_y)
		end
		current_enemy_strength = current_enemy_strength + selected_ship.strength
		enemy_strength = enemy_strength - selected_ship.strength
	end
end
function spawnBase()
	for i,p in ipairs(getActivePlayerShips()) do
		local px, py = p:getPosition()
		if distance(px, py, base_spawn_x, base_spawn_y) < p:getLongRangeRadarRange() then
			base_spawn_x, base_spawn_y = vectorFromAngle(spawn_angle,spawn_range + p:getLongRangeRadarRange())
			break
		end
	end
	enemy_station = placeStation(base_spawn_x, base_spawn_y, "Sinister", "Ghosts")
	enemy_station:onDestruction(baseDestroyed)
	table.insert(enemy_list,enemy_station)
	spawnSimple()
end
function spawnDefense()
	for i,p in ipairs(getActivePlayerShips()) do
		local px, py = p:getPosition()
		if distance(px, py, base_spawn_x, base_spawn_y) < p:getLongRangeRadarRange() then
			base_spawn_x, base_spawn_y = vectorFromAngle(spawn_angle,spawn_range + p:getLongRangeRadarRange())
			break
		end
	end
	enemy_station = placeStation(base_spawn_x, base_spawn_y, "Sinister", "Ghosts")
	enemy_station:onDestruction(baseDestroyed)
	table.insert(enemy_list,enemy_station)
	local defense_count = math.random(3,6)
	local defense_angle = random(0,360)
	local fleet_prefix = string.format("DP%s",generateCallSignPrefix())
	for i=1,defense_count do
		local def_x, def_y = vectorFromAngle(defense_angle,4000)
		local dp = CpuShip():setTemplate("Defense platform"):setFaction("Ghosts")
		dp:setRotationMaxSpeed(dp:getRotationMaxSpeed()*speed_factor)
		dp:setAcceleration(dp:getAcceleration()*speed_factor)
		dp:setPosition(base_spawn_x + def_x, base_spawn_y + def_y):orderStandGround()
		dp:setCallSign(generateCallSign(fleet_prefix))
		table.insert(enemy_list,dp)
		defense_angle = defense_angle + (360/defense_count)
	end
	spawnSimple()
end
function baseDestroyed(self,instigator)
	string.format("")
	sub_wave_time = getScenarioTime() + 7
	local destruct_warning = false
	for i,enemy in ipairs(enemy_list) do
		if enemy ~= nil and enemy:isValid() and enemy:getTypeName() == "Defense platform" then
			destruct_warning = true
			break
		end
	end
	if destruct_warning then
		for i,p in ipairs(getActivePlayerShips()) do
			p:addToShipLog(_("shipLog","Defense platform self destruct activated."),"Red")
		end
	end
end
function subWave()
	if sub_wave_time == nil then
		if sub_wave_interval == nil then
			sub_wave_interval = 60
		end
		sub_wave_time = getScenarioTime() + sub_wave_interval
		sub_wave_interval = math.max(sub_wave_interval - 10,0)
	elseif getScenarioTime() > sub_wave_time then
		sub_wave_time = nil
		enemy_strength = math.pow((wave_number + wave_advance),1.3) * 10 * enemy_power
		if enemy_station ~= nil and enemy_station:isValid() then
			base_spawn_x, base_spawn_y = enemy_station:getPosition()
			local spawn_point_leader = nil
			while enemy_strength > 0 do
				local attempts = 0
				local selected_ship = nil
				repeat
					selected_ship = ship_templates[math.random(1,#ship_templates)]
					attempts = attempts + 1
				until(selected_ship.strength < enemy_strength or attempts > 10)
				local ship = selected_ship.create("Ghosts",selected_ship.name)
				suffix_index = math.random(11,70)
				ship:setCallSign(generateCallSign(nil,"Ghosts"))
				table.insert(enemy_list,ship)
				if spawn_point_leader == nil then
					ship:setPosition(base_spawn_x, base_spawn_y)
					spawn_point_leader = ship
					ship:orderRoaming()
				else
					local defend_x, defend_y = vectorFromAngle(random(0,360),5000)
					ship:setPosition(base_spawn_x + defend_x, base_spawn_y + defend_y)
					ship:orderDefendTarget(spawn_point_leader)
				end
				enemy_strength = enemy_strength - selected_ship.strength
			end
		else
			for i,enemy in ipairs(enemy_list) do
				if enemy ~= nil and enemy:isValid() then
					if enemy:getTypeName() == "Defense platform" then
						local explode_it = false
						for j,p in ipairs(getActivePlayerShips()) do
							if distance(enemy,p) < p:getLongRangeRadarRange() then
								explode_it = true
								break
							end
						end
						if explode_it then
							local ex, ey = enemy:getPosition()
							ExplosionEffect():setPosition(ex,ey):setSize(5000):setOnRadar(true)
							for j,p in ipairs(getActivePlayerShips()) do
								if distance(p,enemy) < 5000 then
									p:takeDamage(50,"kinetic")
								end
							end
						end
					end
					enemy:destroy()
				end
			end
			enemy_list = {}
			enemy_station = nil
			sub_wave_interval = nil
		end
	end
end
function spawnFormation()
	local fly_formation = {
		["*18"] =	{
						{angle = 30	, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 330, dist = 1	},
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
						{angle = 270, dist = 1	},
						{angle = 30	, dist = 2	},
						{angle = 90	, dist = 2	},
						{angle = 330, dist = 2	},
						{angle = 150, dist = 2	},
						{angle = 210, dist = 2	},
						{angle = 270, dist = 2	},
						{angle = 30	, dist = 3	},
						{angle = 90	, dist = 3	},
						{angle = 330, dist = 3	},
						{angle = 150, dist = 3	},
						{angle = 210, dist = 3	},
						{angle = 270, dist = 3	},
					},
		["Xac16"] =	{
						{angle = 30	, dist = 1	},
						{angle = 330, dist = 1	},
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
						{angle = 30	, dist = 2	},
						{angle = 330, dist = 2	},
						{angle = 150, dist = 2	},
						{angle = 210, dist = 2	},
						{angle = 30	, dist = 3	},
						{angle = 330, dist = 3	},
						{angle = 150, dist = 3	},
						{angle = 210, dist = 3	},
						{angle = 30	, dist = 4	},
						{angle = 330, dist = 4	},
						{angle = 150, dist = 4	},
						{angle = 210, dist = 4	},
					},
		["O2R"] =	{
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
					},
		["Xac12"] =	{
						{angle = 30	, dist = 1	},
						{angle = 330, dist = 1	},
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
						{angle = 30	, dist = 2	},
						{angle = 330, dist = 2	},
						{angle = 150, dist = 2	},
						{angle = 210, dist = 2	},
						{angle = 30	, dist = 3	},
						{angle = 330, dist = 3	},
						{angle = 150, dist = 3	},
						{angle = 210, dist = 3	},
					},
		["X16"] =	{
						{angle = 60	, dist = 1	},
						{angle = 300, dist = 1	},
						{angle = 120, dist = 1	},
						{angle = 240, dist = 1	},
						{angle = 60	, dist = 2	},
						{angle = 300, dist = 2	},
						{angle = 120, dist = 2	},
						{angle = 240, dist = 2	},
						{angle = 60	, dist = 3	},
						{angle = 300, dist = 3	},
						{angle = 120, dist = 3	},
						{angle = 240, dist = 3	},
						{angle = 60	, dist = 4	},
						{angle = 300, dist = 4	},
						{angle = 120, dist = 4	},
						{angle = 240, dist = 4	},
					},
		["X12"] =	{
						{angle = 60	, dist = 1	},
						{angle = 300, dist = 1	},
						{angle = 120, dist = 1	},
						{angle = 240, dist = 1	},
						{angle = 60	, dist = 2	},
						{angle = 300, dist = 2	},
						{angle = 120, dist = 2	},
						{angle = 240, dist = 2	},
						{angle = 60	, dist = 3	},
						{angle = 300, dist = 3	},
						{angle = 120, dist = 3	},
						{angle = 240, dist = 3	},
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
		["*12"] =	{
						{angle = 30	, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 330, dist = 1	},
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
						{angle = 270, dist = 1	},
						{angle = 30	, dist = 2	},
						{angle = 90	, dist = 2	},
						{angle = 330, dist = 2	},
						{angle = 150, dist = 2	},
						{angle = 210, dist = 2	},
						{angle = 270, dist = 2	},
					},
		["H"] =		{
						{angle = 90	, dist = 1	},
						{angle = 270, dist = 1	},
						{angle = 45 , dist = math.sqrt(2) },
						{angle = 135, dist = math.sqrt(2) },
						{angle = 225, dist = math.sqrt(2) },
						{angle = 315, dist = math.sqrt(2) },
					},
		["M6"] =	{
						{angle = 60	, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 300, dist = 1	},
						{angle = 270, dist = 1	},
						{angle = 120, dist = 1.3},
						{angle = 240, dist = 1.3},
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
		["Wac"] =	{
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 270, dist = 1	},
					},
		["Mac"] =	{
						{angle = 30	, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 330, dist = 1	},
						{angle = 270, dist = 1	},
					},
		["Xac"] =	{
						{angle = 30	, dist = 1	},
						{angle = 330, dist = 1	},
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
					},
		["W"] =		{
						{angle = 120, dist = 1	},
						{angle = 240, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 270, dist = 1	},
					},
		["M"] =		{
						{angle = 60	, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 300, dist = 1	},
						{angle = 270, dist = 1	},
					},
		["A"] =		{
						{angle = 120, dist = 1	},
						{angle = 240, dist = 1	},
					},
		["Vac"] =	{
						{angle = 30	, dist = 1	},
						{angle = 330, dist = 1	},
					},
		["X"] =		{
						{angle = 60	, dist = 1	},
						{angle = 300, dist = 1	},
						{angle = 120, dist = 1	},
						{angle = 240, dist = 1	},
					},
		["V"] =		{
						{angle = 60	, dist = 1	},
						{angle = 300, dist = 1	},
					},
		}
	local leader_templates = {
		{name = "Dreadnought",		strength = 80,	create = stockTemplate},
		{name = "Blockade Runner",	strength = 63,	create = stockTemplate},
		{name = "Ktlitan Destroyer",strength = 50,	create = stockTemplate},
		{name = "Cucaracha",		strength = 36,	create = cucaracha},
		{name = "Farco 13",			strength = 24,	create = farco13},
		{name = "Nirvana R5A",		strength = 20,	create = stockTemplate},
		{name = "Farco 8",			strength = 19,	create = farco8},
		{name = "Farco 3",			strength = 16,	create = farco3},
		{name = "Adder MK4",		strength = 6,	create = stockTemplate},
	}
	local form_list = {
		{form = "Xac16",template = "K3 Fighter",	create = k3fighter,		strength = 128},	--16*8
		{form = "*18",	template = "K2 Fighter",	create = k2fighter,		strength = 126},	--18*7
		{form = "X16",	template = "K2 Fighter",	create = k2fighter,		strength = 112},	--16*7
		{form = "O2R",	template = "MT55 Hornet",	create = hornetMT55,	strength = 108},	--18*6
		{form = "Xac16",template = "MT55 Hornet",	create = hornetMT55,	strength = 96},		--16*6
		{form = "O2R",	template = "MU52 Hornet",	create = stockTemplate,	strength = 90},		--18*5
		{form = "Xac12",template = "K2 Fighter",	create = k2fighter,		strength = 84},		--12*7
		{form = "X16",	template = "MU52 Hornet",	create = stockTemplate,	strength = 80},		--16*5
		{form = "X12",	template = "MT55 Hornet",	create = hornetMT55,	strength = 72},		--12*6
		{form = "Xac8",	template = "K3 Fighter",	create = k3fighter,		strength = 64},		--8*8
		{form = "*12",	template = "MU52 Hornet",	create = stockTemplate,	strength = 60},		--12*5
		{form = "H",	template = "FX64 Hornet",	create = hornetFX64,	strength = 54},		--6*9
		{form = "M6",	template = "K3 Fighter",	create = k3fighter,		strength = 48},		--6*8
		{form = "X8",	template = "MU52 Hornet",	create = stockTemplate,	strength = 40},		--8*5
		{form = "Wac",	template = "FX64 Hornet",	create = hornetFX64,	strength = 36},		--4*9
		{form = "Mac",	template = "K3 Fighter",	create = k3fighter,		strength = 32},		--4*8
		{form = "Xac",	template = "K2 Fighter",	create = k2fighter,		strength = 28},		--4*7
		{form = "W",	template = "MT55 Hornet",	create = hornetMT55,	strength = 24},		--4*6
		{form = "M",	template = "MU52 Hornet",	create = stockTemplate,	strength = 20},		--4*5
		{form = "A",	template = "K2 Fighter",	create = k2fighter,		strength = 14},		--2*7
		{form = "Vac",	template = "MU52 Hornet",	create = stockTemplate,	strength = 10},		--2*5
		{form = "X",	template = "Gnat",			create = gnat,			strength = 8},		--4*2
		{form = "V",	template = "Gnat",			create = gnat,			strength = 4},		--2*2
	}
	--	Determine lead ship template
	local lead_pool = {}
	for i,lead in ipairs(leader_templates) do
		if lead.strength < enemy_strength then
			table.insert(lead_pool,lead)
		end
		if #lead_pool >= 5 then
			break
		end
	end
	local lead_pool_index = math.random(1,#lead_pool)
	local lead = lead_pool[lead_pool_index]
	--	Determine formation
	local form_pool = {}
	for i,form in ipairs(form_list) do
		if form.strength <= (enemy_strength - lead.strength) then
			table.insert(form_pool,form)
		end
		if #form_pool >= 3 then
			break
		end
	end
	local selected_form = form_list[#form_list]	--default to weakest formation
	if #form_pool > 0 then
		selected_form = form_pool[math.random(1,#form_pool)]
		print("Formation pool was not empty. Selected formation:",selected_form.form,selected_form.template,"strength:",selected_form.strength)
	else
		print("Formation pool was empty. Weakest formation selected:",selected_form.form,selected_form.template,"strength:",selected_form.strength)
	end
	--	Spawn lead ship
	local leader_ship = lead.create("Ghosts",lead.name)
	leader_ship:setPosition(base_spawn_x, base_spawn_y)
	suffix_index = math.random(11,70)
	leader_ship:setCallSign(generateCallSign(nil,"Ghosts"))
	--	Determine target station
	local selected_target = nil
	local target_pool = {}
	for i,station in ipairs(friendly_stations) do
		if station ~= nil and station:isValid() then
			table.insert(target_pool,station)
		end
	end
	local target_x = 0
	local target_y = 0
	if #target_pool > 0 then
		local target = target_pool[math.random(1,#target_pool)]
		target_x, target_y = target:getPosition()
	end
	--	Point lead ship to target station
	local fly_angle = angleFromVectorNorth(target_x, target_y, base_spawn_x, base_spawn_y)
	leader_ship:setHeading(fly_angle)
	leader_ship:orderFlyTowards(target_x, target_y)
	current_enemy_strength = current_enemy_strength + lead.strength
	table.insert(enemy_list,leader_ship)
	--	Spawn followers in formation
	local fleet_prefix = generateCallSignPrefix()
	local formation_spacing = random(800,1200)
	for i, form in ipairs(fly_formation[selected_form.form]) do
		local ship = selected_form.create("Ghosts",selected_form.template)
		local form_x, form_y = vectorFromAngleNorth(fly_angle + form.angle, form.dist * formation_spacing)
		local form_prime_x, form_prime_y = vectorFromAngle(form.angle, form.dist * formation_spacing)
		ship:setPosition(base_spawn_x + form_x, base_spawn_y + form_y):setHeading(fly_angle):orderFlyFormation(leader_ship,form_prime_x,form_prime_y)
		ship:setCallSign(generateCallSign(fleet_prefix))
		table.insert(enemy_list,ship)
	end
	enemy_strength = enemy_strength - lead.strength - selected_form.strength
	if enemy_strength > 10 then
		spawnSimple()
	end
end
function asteroidStorm()
	local clean_list = true
	local real = 0
	local visual = 0
	if #storm_asteroids > 0 then
		for i,asteroid in ipairs(storm_asteroids) do
			if asteroid ~= nil and asteroid:isValid() then
				if isObjectType(asteroid,"Asteroid") then
					real = real + 1
				else
					visual = visual + 1
				end
				local ax, ay = asteroid:getPosition()
				if distance(0,0,ax,ay) > asteroid.dist then
					storm_asteroids[i] = storm_asteroids[#storm_asteroids]
					storm_asteroids[#storm_asteroids] = nil
					asteroid:destroy()
					clean_list = false
					break
				end
			else
				storm_asteroids[i] = storm_asteroids[#storm_asteroids]
				storm_asteroids[#storm_asteroids] = nil
				clean_list = false
				break
			end
		end
	end
	if clean_list then
		if asteroid_storm then
			if #storm_asteroids < 150 then
				if storm_asteroid_time == nil then
					storm_asteroid_time = getScenarioTime() + 1
				end
				if getScenarioTime() > storm_asteroid_time then
					storm_asteroid_time = nil
					if asteroid_angle == nil then
						asteroid_angle = random(0,360)
					end
					local edge_start_x, edge_start_y = vectorFromAngleNorth(asteroid_angle,80000)
					local launch_x, launch_y = vectorFromAngleNorth(asteroid_angle + 90,random(-80000,80000))
					local asteroid_kind = {}
					if real < 50 then
						table.insert(asteroid_kind,"real")
					end
					if visual < 100 then
						table.insert(asteroid_kind,"visual")
						table.insert(asteroid_kind,"visual")
					end
					local storm_asteroid = nil
					if asteroid_kind[math.random(1,#asteroid_kind)] == "real" then
						storm_asteroid = Asteroid():setSize(random(4,300) + random(4,300) + random(4,300))
					else
						storm_asteroid = VisualAsteroid():setSize(random(4,300) + random(4,300) + random(4,300))
					end
					storm_asteroid:setPosition(edge_start_x + launch_x, edge_start_y + launch_y)
					storm_asteroid.trajectory = asteroid_angle + 180
					storm_asteroid.speed = random(10,100)
					storm_asteroid.dist = distance(0,0,edge_start_x + launch_x,edge_start_y + launch_y)
					table.insert(storm_asteroids,storm_asteroid)
				end
			end
		else
			if #storm_asteroids == 0 then
				asteroid_angle = nil
			end
		end
		for i,asteroid in ipairs(storm_asteroids) do
			local dx, dy = vectorFromAngleNorth(asteroid.trajectory,asteroid.speed)
			local ax, ay = asteroid:getPosition()
			asteroid:setPosition(ax + dx, ay + dy)
		end
	end
end
function randomTransports()
	local clean_list = true
	for i,station in ipairs(station_list) do
		if station == nil or not station:isValid() then
			station_list[i] = station_list[#station_list]
			station_list[#station_list] = nil
			clean_list = false
			break
		end
	end
	if clean_list then
		for i,transport in ipairs(transport_list) do
			if transport == nil or not transport:isValid() then
				transport_list[i] = transport_list[#transport_list]
				transport_list[#transport_list] = nil
				clean_list = false
				break
			end
		end
	end
	if clean_list then
		for i,transport in ipairs(transport_list) do
			if transport:isDocked(transport.target) then
				if transport.undock_time == nil then
					transport.undock_time = getScenarioTime() + random(5,30)
				end
				if getScenarioTime() > transport.undock_time then
					transport.undock_time = nil
					transport.target = station_list[math.random(1,#station_list)]
					transport:orderDock(transport.target)
				end
			end
		end
		if transport_spawn_time == nil then
			transport_spawn_time = getScenarioTime() + random(30,50)
		end
		if getScenarioTime() > transport_spawn_time then
			transport_spawn_time = nil
			if #transport_list < #station_list then
				local transport_name = {
					"Personnel","Goods","Garbage","Equipment","Fuel"
				}
				local name = string.format("%s Freighter %i",transport_name[math.random(1,#transport_name)],math.random(1,5))
				if random(1,100) < 15 then
					name = string.format("%s Jump Freighter %i",transport_name[math.random(1,#transport_name)],math.random(3,5))
				end
				local transport = CpuShip():setTemplate(name):setFaction("Independent")
				transport:setCommsScript(""):setCommsFunction(commsShip)
				transport.target = station_list[math.random(1,#station_list)]
				transport:orderDock(transport.target)
				local tx, ty = vectorFromAngle(random(0,360),random(25000,40000))
				transport:setPosition(tx,ty)
				suffix_index = math.random(11,70)
				transport:setCallSign(generateCallSign(nil,"Independent"))
				table.insert(transport_list,transport)
			end
		end
	end
end
function dropWarpJammer(enemy)
	if enemy.warp_jammer_count ~= nil and enemy.warp_jammer_count > 0 then
		if enemy.active_warp_jammer == nil then
			local close_player_count = 0
			for j,p in ipairs(getActivePlayerShips()) do
				local dist = distance(enemy,p)
				if distance(p,enemy) < 5000 then
					close_player_count = close_player_count + 1
					if enemy.jammer_drop_time == nil then
						enemy.jammer_drop_time = getScenarioTime() + random(5,10)
					end
					if getScenarioTime() > enemy.jammer_drop_time then
						enemy.jammer_drop_time = nil
						local ex, ey = enemy:getPosition()
						enemy.active_warp_jammer = WarpJammer():setPosition(ex,ey):setRange(20000):setFaction("Ghosts")
						enemy.active_warp_jammer.creator = enemy
						enemy.warp_jammer_count = enemy.warp_jammer_count - 1
						if enemy.warp_jammer_type == "plain" then
							enemy.active_warp_jammer:setHull(100)
						else
							local angle = random(0,60)
							local zone_points = {}
							for k=1,6 do
								local zx, zy = vectorFromAngle(angle,20000)
								zone_points[k] = {x = ex + zx, y = ey + zy}
								angle = angle + 60
							end
							local shade = {
								["missile"] = 64,
								["beam"] = 128,
							}
							local zone = Zone()
							zone:setPoints(
								zone_points[1].x,zone_points[1].y,
								zone_points[2].x,zone_points[2].y,
								zone_points[3].x,zone_points[3].y,
								zone_points[4].x,zone_points[4].y,
								zone_points[5].x,zone_points[5].y,
								zone_points[6].x,zone_points[6].y
							)
							zone:setColor(shade[enemy.warp_jammer_type],0,0)
							zone.detriment = enemy.warp_jammer_type
							enemy.active_warp_jammer.zone = zone
							table.insert(check_zones,zone)
						end
						enemy.active_warp_jammer:onDestruction(loseWarpJammer)
					end
				end
			end
			if close_player_count == 0 then
				enemy.jammer_drop_time = nil
			end
		end
	end
end
function loseWarpJammer(self,instigator)
	string.format("")
	if self.zone ~= nil then
		self.zone:destroy()
	end
	if self.creator ~= nil and self.creator:isValid() then
		self.creator.active_warp_jammer = nil
	end
end
function improvedStationService(p)
	if p.instant_energy ~= nil then
		if #p.instant_energy > 0 then
			for i,station in ipairs(p.instant_energy) do
				if station:isValid() then
					if p:isDocked(station) then
						p:setEnergyLevel(p:getEnergyLevelMax())
					end
				else
					p.instant_energy[i] = p.instant_energy[#p.instant_energy]
					p.instant_energy[#p.instant_energy] = nil
					break
				end
			end
		else
			p.instant_energy = nil
		end
	end
	if p.instant_hull ~= nil then
		if #p.instant_hull > 0 then
			for i,station in ipairs(p.instant_hull) do
				if station:isValid() then
					if p:isDocked(station) then
						p:setHull(p:getHullMax())
					end
				else
					p.instant_hull[i] = p.instant_hull[#p.instant_hull]
					p.instant_hull[#p.instant_hull] = nil
					break
				end
			end
		else
			p.instant_hull = nil
		end
	end
	if p.instant_probes ~= nil then
		if #p.instant_probes > 0 then
			for i,station in ipairs(p.instant_probes) do
				if station:isValid() then
					if p:isDocked(station) then
						p:setScanProbeCount(p:getMaxScanProbeCount())
					end
				else
					p.instant_probes[i] = p.instant_probes[#p.instant_probes]
					p.instant_probes[#p.instant_probes] = nil
				end
			end
		else
			p.instant_probes = nil
		end
	end
end
function checkZones(p,delta)
	for j,zone in ipairs(check_zones) do
		if zone ~= nil and zone:isValid() then
			if zone:isInside(p) then
				if zone.detriment == "beam" then
					p:setSystemHealth("beamweapons",p:getSystemHealth("beamweapons")*.999)
					if zone.player_warn == nil then
						zone.player_warn = {}
					else
						if zone.player_warn[p] == nil then
							zone.player_warn[p] = {time = getScenarioTime() + 5, sent = false}
						else
							if not zone.player_warn[p].sent then
								if getScenarioTime() > zone.player_warn[p].time then
									p.zone_warn_msg_sci = "zone_warn_msg_sci"
									p:addCustomMessage("Science",p.zone_warn_msg_sci,_("msgScience","In addition to jamming our FTL drive, there's a warp jammer that is damaging our beam weapons"))
									p.zone_warn_msg_ops = "zone_warn_msg_ops"
									p:addCustomMessage("Operations",p.zone_warn_msg_ops,_("msgOperations","In addition to jamming our FTL drive, there's a warp jammer that is damaging our beam weapons"))
									zone.player_warn[p].sent = true
								end
							end
						end
					end
				elseif zone.detriment == "missile" then
					p:setSystemHealth("missilesystem",p:getSystemHealth("missilesystem")*.999)
					if zone.player_warn == nil then
						zone.player_warn = {}
					else
						if zone.player_warn[p] == nil then
							zone.player_warn[p] = {time = getScenarioTime() + 5, sent = false}
						else
							if not zone.player_warn[p].sent then
								if getScenarioTime() > zone.player_warn[p].time then
									p.zone_warn_msg_sci = "zone_warn_msg_sci"
									p:addCustomMessage("Science",p.zone_warn_msg_sci,_("msgScience","In addition to jamming our FTL drive, there's a warp jammer that is damaging our missile systems"))
									p.zone_warn_msg_ops = "zone_warn_msg_ops"
									p:addCustomMessage("Operations",p.zone_warn_msg_ops,_("msgOperations","In addition to jamming our FTL drive, there's a warp jammer that is damaging our missile systems"))
									zone.player_warn[p].sent = true
								end
							end
						end
					end
				end
			end
		else
			check_zones[j] = check_zones[#check_zones]
			check_zones[#check_zones] = nil
			break
		end
	end
end

function update(delta)
	if delta == 0 then
		return
	end
    asteroidStorm()
    for i,p in ipairs(getActivePlayerShips()) do
	    improvedStationService(p)
	    checkZones(p,delta)
	    nameBanner(p)
    end
    randomTransports()
    -- Show countdown, spawn wave
    if spawn_wave_delay ~= nil then
        spawn_wave_delay = spawn_wave_delay - delta
        if spawn_wave_delay < 5 then
            globalMessage(math.ceil(spawn_wave_delay))
        end
        if spawn_wave_delay < 0 then
            spawn_wave_delay = nil
            spawnWave()
        end
        return
    end
    -- Count enemies and friends
    local enemy_count = 0
    local friendly_count = 0
    local enemy_base_count = 0
    for i, enemy in ipairs(enemy_list) do
        if enemy ~= nil and enemy:isValid() then
            enemy_count = enemy_count + 1
            if isObjectType(enemy,"SpaceStation") or enemy:getTypeName() == "Defense platform" then
            	enemy_base_count = enemy_base_count + 1
            else
            	if enemy:getOrder() == "Idle" or enemy:getOrder() == "Defend Location" then
            		enemy:orderRoaming()
            	end
            end
            dropWarpJammer(enemy)
        end
    end
	for i, friendly in ipairs(friendly_stations) do
		if friendly ~= nil and friendly:isValid() then
			friendly_count = friendly_count + 1
		end
	end
    -- Continue ...
    if enemy_count == 0 then
        spawn_wave_delay = 15.0
        if wave_number == 0 then
        	globalMessage(_("msgMainscreen","Surf's up! Let the waves begin."))
        else
	        globalMessage(_("msgMainscreen","Wave cleared!"))
	        for i,p in ipairs(getActivePlayerShips()) do
	        	p:addToShipLog(string.format(_("msgMainscreen","Wave %i cleared."),wave_number), "Green")
	        end
	        if asteroid_storm then
	        	asteroid_storm = false
	        end
    	end
    elseif enemy_count == enemy_base_count then
    	subWave()
    end
    -- ... or lose
	if friendly_count == 0 then
		local completed_waves = wave_number - 1
		local msg = _("msgMainscreen","All friendly bases destroyed.")
		if player_spawn_count > 1 then
			msg = string.format(_("msgMainscreen","%s\n%i player ships deployed."),msg,player_spawn_count)
		else
			msg = string.format(_("msgMainscreen","%s\nOne player ship deployed."),msg)
		end
		if completed_waves > 1 then
			msg = string.format(_("msgMainscreen","%s\n%i waves completed at the %s setting."),msg,completed_waves,enemy_config[getScenarioSetting("Enemies")].desc)
		elseif completed_waves > 0 then
			msg = string.format(_("msgMainscreen","%s\nOne wave completed at the %s setting."),msg,completed_waves,enemy_config[getScenarioSetting("Enemies")].desc)
		else
			msg = string.format(_("msgMainscreen","%s\nNo waves completed at the %s setting."),msg,enemy_config[getScenarioSetting("Enemies")].desc)
		end
		local duration_string = getDuration()
		msg = string.format(_("msgMainscreen","%s\nDuration: %s."),msg,duration_string)
		if wave_advance > 0 then
			msg = string.format(_("msgMainscreen","%s\nWave advance setting: %s"),msg,wave_advance + 1)
		end
		if getScenarioSetting("Pace") ~= "Normal" then
			msg = string.format(_("msgMainscreen","%s\nPace setting: %s"),msg,getScenarioSetting("Pace"))
		end
		globalMessage(msg)
		victory("Ghosts") -- Victory for the Ghosts (= defeat for the players)
	end
    if getScenarioTime() > 60*15 then
    	earlyEnd()
    end
end