-- Name: Surf's Up!
-- Description: Waves with some additions.
--- No victory condition. How many waves can you survive?
---
--- Version 1
---
--- USN Discord: https://discord.gg/PntGG3a where you can join a game online. There's one every weekend. All experience levels are welcome. 
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

function init()
	scenario_version = "1.0.4"
	ee_version = "2023.06.17"
	print(string.format("    ----    Scenario: Surf's Up!    ----    Version %s    ----    Tested with EE version %s    ----",scenario_version,ee_version))
	print(_VERSION)
    -- global variables:
    wave_number = 0
    spawn_wave_delay = nil
    enemy_list = {}
    friendly_stations = {}
    neutral_stations = {}
    station_list = {}
    transport_list = {}
    nebulas = {}
    check_zones = {}
    
    -- Random friendly stations
    local name_categories = {
    	"Science",
    	"History",
    	"Pop Sci Fi",
    	"Spec Sci Fi",
    	"Generic",
    }
    local station_angle = random(0,360)
    local station_x, station_y = vectorFromAngle(station_angle,random(2000,5000))
    local name_category = tableRemoveRandom(name_categories)
    local station = placeStation(station_x, station_y,name_category,"Human Navy")
    table.insert(friendly_stations, station)
    table.insert(station_list, station)
    local dx, dy = vectorFromAngle(station_angle + random(-60,60),random(2000,5000))
    name_category = tableRemoveRandom(name_categories)
    station = placeStation(station_x + dx, station_y + dy,name_category,"Human Navy")
    table.insert(friendly_stations, station)
    spreadServiceToStations(friendly_stations)
    table.insert(station_list, station)
	local mission_reasons = {
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
    mission_goods = {}
	for i,station in ipairs(friendly_stations) do
		if not station:getRestocksScanProbes() then
			if station.probe_fail_reason == nil then
				local reason_list = {
					_("situationReport-comms", "Cannot replenish scan probes due to fabrication unit failure."),
					_("situationReport-comms", "Parts shortage prevents scan probe replenishment."),
					_("situationReport-comms", "Station management has curtailed scan probe replenishment for cost cutting reasons."),
				}
				station.probe_fail_reason = reason_list[math.random(1,#reason_list)]
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
				station.repair_fail_reason = reason_list[math.random(1,#reason_list)]
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
				station.energy_fail_reason = reason_list[math.random(1,#reason_list)]
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
    asteroid_storm = false
    storm_asteroids = {}
    
    -- Enemy strength configuration and primary enemy type list
	local enemy_config = {
		["Easy"] =		{number = .5},
		["Normal"] =	{number = 1},
		["Hard"] =		{number = 2},
		["Extreme"] =	{number = 3},
		["Quixotic"] =	{number = 5},
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

    -- Random neutral stations
    neutral_stations = {}
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
    mission_good = {}
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
    print("Missions and goods final:")
    for mission,details in pairs(mission_good) do
    	local out_station = "None"
    	if details.station ~= nil then
    		out_station = details.station:getCallSign()
    	end
    	print("Mission:",mission,"Good:",details.good,"Station:",out_station)
    end
    
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
    player_spawn_count = 0
	onNewPlayerShip(setPlayer)

    --	Alternative player ship
    local prototype_config = {
    	["None"] = "None",
    	["Cruiser"] = "Player Cruiser",
    	["Missile Cruiser"] = "Player Missile Cr.",
    	["Fighter"] = "Player Fighter",
    }
    if getScenarioSetting("Prototype") ~= "None" then
    	PlayerSpaceship():setTemplate(prototype_config[getScenarioSetting("Prototype")])
    end
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
			for _,station in ipairs(stations) do
				table.insert(station_pool,station)
			end
		end
		local station_1 = tableRemoveRandom(station_pool)
		if #station_pool < 1 then
			for _,station in ipairs(stations) do
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
				p:addToShipLog(string.format(_("shipLog","We picked up an anomalous chroniton particle reading near %s. Encoded within the anomalous reading is a designated point along the timeline in the future. We are still working on the decoding rest of the information, but initial efforts hint at some major military action being taken by the Ghosts. We have placed countdown timers on some of your consoles indicating when this event is supposed to occur."),friendly_stations[1]:getCallSign()),"Magenta")
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
					if #friendly_stations > 1 then
						local station_pool = {}
						for i,station in ipairs(friendly_stations) do
							table.insert(station_pool,station)
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
						local fx, fy = friendly_stations[1]:getPosition()
						local ox, oy = vectorFromAngle(random(0,360),4000)
						endOdin = CpuShip():setTemplate("Odin"):setFaction("Ghosts")
						endOdin:setPosition(fx + ox, fy + oy):orderRoaming()
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
	enemy_strength = math.pow((wave_number + wave_advance),1.3) * 10 * enemy_power + player_power
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
	print("Roll:",roll,"Wave number:",wave_number,"Enemy strength:",enemy_strength,"Player power:",player_power,"Advance:",wave_advance + 1)
	for i, wave in ipairs(wave_styles) do
		if roll <= wave.chance then
			print("Wave type selected:",wave.style)
			wave_style = wave
			break
		end
	end
	local wave_message = wave_style.msg
	if asteroid_storm then
		wave_message = string.format(_("shipLog","%s Asteroid storm reported."),wave_style.msg)
	end
	for i,p in ipairs(getActivePlayerShips()) do
		p:addToShipLog(wave_message,"Green")
		p:addReputationPoints(50 + wave_number * 10)
		local wave_number_out = string.format("Wave %i",wave_number)
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
				if asteroid.typeName == "Asteroid" then
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
									p:addCustomMessage("Science",p.zone_warn_msg_sci,"In addition to jamming our FTL drive, there's a warp jammer that is damaging our beam weapons")
									p.zone_warn_msg_ops = "zone_warn_msg_ops"
									p:addCustomMessage("Operations",p.zone_warn_msg_ops,"In addition to jamming our FTL drive, there's a warp jammer that is damaging our beam weapons")
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
									p:addCustomMessage("Science",p.zone_warn_msg_sci,"In addition to jamming our FTL drive, there's a warp jammer that is damaging our missile systems")
									p.zone_warn_msg_ops = "zone_warn_msg_ops"
									p:addCustomMessage("Operations",p.zone_warn_msg_ops,"In addition to jamming our FTL drive, there's a warp jammer that is damaging our missile systems")
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
	if not comms_source:isEnemy(comms_target) then
		addStationToDatabase(comms_target)
	end
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
function handleUndockedState()
    --Handle communications when we are not docked with the station.
    if comms_source:isFriendly(comms_target) then
        oMsg = _("station-comms", "Good day, officer.\nIf you need supplies, please dock with us first.")
    else
        oMsg = _("station-comms", "Greetings.\nIf you want to do business, please dock with us first.")
    end
	setCommsMessage(oMsg)
	oMsg = nil
	commsInformationStation()
	if isAllowedTo(comms_target.comms_data.services.supplydrop) then
        addCommsReply(string.format(_("stationAssist-comms", "Can you send a supply drop? (%d rep)"), getServiceCost("supplydrop")), function()
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage(_("stationAssist-comms", "You need to set a waypoint before you can request backup."));
            else
                setCommsMessage(_("stationAssist-comms", "To which waypoint should we deliver your supplies?"));
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply(string.format(_("stationAssist-comms","Waypoint %i"),n), function()
						if comms_source:takeReputationPoints(getServiceCost("supplydrop")) then
							local position_x, position_y = comms_target:getPosition()
							local target_x, target_y = comms_source:getWaypoint(n)
							local script = Script()
							script:setVariable("position_x", position_x):setVariable("position_y", position_y)
							script:setVariable("target_x", target_x):setVariable("target_y", target_y)
							script:setVariable("faction_id", comms_target:getFactionId()):run("supply_drop.lua")
                            setCommsMessage(string.format(_("stationAssist-comms", "We have dispatched a supply ship toward waypoint %d"), n));
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
        addCommsReply(string.format(_("stationAssist-comms", "Please send reinforcements! (%d rep)"), getServiceCost("reinforcements")), commsStationReinforcements)
    end
end
function commsStationReinforcements()
	setCommsMessage(_("stationAssist-comms", "What kind of reinforcement ship would you like?"))
	if comms_target.comms_data.service_cost == nil then
		comms_target.comms_data.service_cost = {}
		comms_target.comms_data.service_cost.amk3_reinforcements = math.random(75,125)
		comms_target.comms_data.service_cost.hornet_reinforcements = math.random(75,125)
		comms_target.comms_data.service_cost.reinforcements = math.random(140,160)
		comms_target.comms_data.service_cost.amk8_reinforcements = math.random(150,200)
		comms_target.comms_data.service_cost.phobos_reinforcements = math.random(175,225)
	end
	if comms_target.comms_data.service_available == nil then
		comms_target.comms_data.service_available = {}
		comms_target.comms_data.service_available.amk3_reinforcements = random(1,100) < 72
		comms_target.comms_data.service_available.hornet_reinforcements = random(1,100) < 72
		comms_target.comms_data.service_available.reinforcements = true
		comms_target.comms_data.service_available.amk8_reinforcements = random(1,100) < 72
		comms_target.comms_data.service_available.phobos_reinforcements = random(1,100) < 72
	end
	local reinforcement_info = {
		{desc = _("stationAssist-comms","Adder MK3"),			template = "Adder MK3",		cost = math.ceil(comms_target.comms_data.service_cost.amk3_reinforcements),		avail = comms_target.comms_data.service_available.amk3_reinforcements},
		{desc = _("stationAssist-comms","MU52 Hornet"),			template = "MU52 Hornet",	cost = math.ceil(comms_target.comms_data.service_cost.hornet_reinforcements),	avail = comms_target.comms_data.service_available.hornet_reinforcements},
		{desc = _("stationAssist-comms","Standard Adder MK5"),	template = "Adder MK5",		cost = math.ceil(comms_target.comms_data.service_cost.reinforcements),			avail = comms_target.comms_data.service_available.reinforcements},
		{desc = _("stationAssist-comms","Adder MK8"),			template = "Adder MK8",		cost = math.ceil(comms_target.comms_data.service_cost.amk8_reinforcements),		avail = comms_target.comms_data.service_available.amk8_reinforcements},
		{desc = _("stationAssist-comms","Phobos T3"),			template = "Phobos T3",		cost = math.ceil(comms_target.comms_data.service_cost.phobos_reinforcements),	avail = comms_target.comms_data.service_available.phobos_reinforcements},
	}
	local avail_count = 0
	for i, info in ipairs(reinforcement_info) do
		if info.avail then
			avail_count = avail_count + 1
			addCommsReply(string.format(_("stationAssist-comms","%s (%d reputation)"),info.desc,info.cost), function()
				if comms_source:getWaypointCount() < 1 then
					setCommsMessage(_("stationAssist-comms", "You need to set a waypoint before you can request reinforcements."))
				else
					setCommsMessage(_("stationAssist-comms", "To which waypoint should we dispatch the reinforcements?"))
					for n = 1, comms_source:getWaypointCount() do
						addCommsReply(string.format(_("stationAssist-comms", "Waypoint %d"), n),function()
							if comms_source:takeReputationPoints(info.cost) then
								local ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate(info.template):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
								local forward, reverse = ship:getImpulseMaxSpeed()
								ship:setImpulseMaxSpeed(forward*speed_factor,reverse*speed_factor)
								ship:setRotationMaxSpeed(ship:getRotationMaxSpeed()*speed_factor)
								ship:setAcceleration(ship:getAcceleration()*speed_factor)
								if ship:hasWarpDrive() then
									ship:setWarpSpeed(ship:getWarpSpeed()*speed_factor)
								end
								suffix_index = math.random(11,77)
								ship:setCallSign(generateCallSign(nil,comms_target:getFaction()))
								setCommsMessage(string.format(_("stationAssist-comms","We have dispatched %s to assist at waypoint %s"),ship:getCallSign(),n))
							else
								setCommsMessage(_("stationAssist-comms","Insufficient reputation"))
							end
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end
	if avail_count < 1 then
		setCommsMessage(_("stationAssist-comms","No reinforcements available"))
	end
	addCommsReply(_("Back"), commsStation)
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
	local missilePresence = 0
	local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	for i, missile_type in ipairs(missile_types) do
		missilePresence = missilePresence + comms_source:getWeaponStorageMax(missile_type)
	end
	if missilePresence > 0 then
		if 	(comms_target.comms_data.weapon_available.Nuke   and comms_source:getWeaponStorageMax("Nuke") > 0)   or 
			(comms_target.comms_data.weapon_available.EMP    and comms_source:getWeaponStorageMax("EMP") > 0)    or 
			(comms_target.comms_data.weapon_available.Homing and comms_source:getWeaponStorageMax("Homing") > 0) or 
			(comms_target.comms_data.weapon_available.Mine   and comms_source:getWeaponStorageMax("Mine") > 0)   or 
			(comms_target.comms_data.weapon_available.HVLI   and comms_source:getWeaponStorageMax("HVLI") > 0)   then
			addCommsReply(_("ammo-comms","I need ordnance restocked"), function()
				setCommsMessage("What type of ordnance do you need?")
				local prompts = {
					["Nuke"] = {
						_("ammo-comms","Can you supply us with some nukes?"),
						_("ammo-comms","We really need some nukes."),
						_("ammo-comms","Can you restock our nuclear missiles?"),
					},
					["EMP"] = {
						_("ammo-comms","Please restock our EMP missiles."),
						_("ammo-comms","Got any EMPs?"),
						_("ammo-comms","We need Electro-Magnetic Pulse missiles."),
					},
					["Homing"] = {
						_("ammo-comms","Do you have spare homing missiles for us?"),
						_("ammo-comms","Do you have extra homing missiles?"),
						_("ammo-comms","Please replenish our homing missiles."),
					},
					["Mine"] = {
						_("ammo-comms","We could use some mines."),
						_("ammo-comms","How about mines?"),
						_("ammo-comms","Got mines for us?"),
					},
					["HVLI"] = {
						_("ammo-comms","What about HVLI?"),
						_("ammo-comms","Could you provide HVLI?"),
						_("ammo-comms","We need High Velocity Lead Impactors."),
					},
				}
				for i, missile_type in ipairs(missile_types) do
					if comms_source:getWeaponStorageMax(missile_type) > 0 and comms_target.comms_data.weapon_available[missile_type] then
						addCommsReply(string.format(_("ammo-comms","%s (%d rep each)"),prompts[missile_type][math.random(1,#prompts[missile_type])],getWeaponCost(missile_type)), function()
							string.format("")
							handleWeaponRestock(missile_type)
						end)
					end
				end
				addCommsReply(_("Back"), commsStation)
			end)
		else
			oMsg = string.format(_("station-comms","%s\nWe don't have ordnance for you."),oMsg)
		end
	end
	setCommsMessage(oMsg)
	local good_count = 0
	for good, goodData in pairs(comms_target.comms_data.goods) do
		good_count = good_count + 1
	end
	if good_count > 0 and not comms_target:isFriendly(comms_source) then
		addCommsReply(_("trade-comms", "Buy, sell, trade"), function()
			local goodsReport = string.format(_("trade-comms", "Station %s:\nGoods or components available for sale: quantity, cost in reputation\n"),comms_target:getCallSign())
			for good, goodData in pairs(comms_target.comms_data.goods) do
				goodsReport = goodsReport .. string.format(_("trade-comms", "     %s: %i, %i\n"),good,goodData["quantity"],goodData["cost"])
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
			goodsReport = goodsReport .. string.format(_("trade-comms", "Available Space: %i"),comms_source.cargo)
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
			addCommsReply(_("Back"), commsStation)
		end)	
	end
	if comms_target.coolant_inventory == nil then
		comms_target.coolant_inventory = math.random(0,5)
	end
	if comms_target.coolant_inventory > 0 then
		if comms_target.coolant_price == nil then
			if comms_target:isFriendly(comms_source) then
				comms_target.coolant_price = math.random(20,40)
			else
				comms_target.coolant_price = math.random(40,80)
			end
		end
		addCommsReply(string.format(_("trade-comms","Purchase coolant (%s reputation)"),comms_target.coolant_price),function()
			if comms_source:takeReputationPoints(comms_target.coolant_price) then
				comms_source:setMaxCoolant(comms_source:getMaxCoolant() + 1)
				comms_target.coolant_inventory = comms_target.coolant_inventory - 1
				setCommsMessage(_("trade-comms", "Additional coolant purchased"))
			else
				setCommsMessage(_("needRep-comms","Insufficient reputation"))
			end
			addCommsReply(_("Back"), commsStation)
		end)
	end
	commsInformationStation()
end
function getServiceCost(service)
    return math.ceil(comms_target.comms_data.service_cost[service])
end
function commsInformationStation()
	addCommsReply(_("station-comms","I need information"),function()
		setCommsMessage(_("station-comms","What do you need to know?"))
		stationStatusReport()
		if (comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "") or
			(comms_target.comms_data.history ~= nil and comms_target.comms_data.history ~= "") then
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
				addCommsReply(_("Back"), commsStation)
			end)	--end station info comms reply branch
		end
		addCommsReply(_("Back"), commsStation)
	end)
end
function stationStatusReport()
	addCommsReply(_("situationReport-comms","Report status"), function()
		msg = string.format(_("situationReport-comms","Hull:%s"),math.floor(comms_target:getHull() / comms_target:getHullMax() * 100))
		local shields = comms_target:getShieldCount()
		if shields == 1 then
			msg = string.format(_("situationReport-comms","%s\nShield:%s"),msg,math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100))
		else
			for n=0,shields-1 do
				msg = string.format(_("situationReport-comms","%s\nShield %s:%s"),msg,n,math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100))
			end
		end
		local improvements = {}
		if comms_target:getRestocksScanProbes() then
			msg = string.format(_("situationReport-comms","%s\nReplenish scan probes: nominal."),msg)
		else
			if comms_target.probe_fail_reason == nil then
				local reason_list = {
					_("situationReport-comms", "Cannot replenish scan probes due to fabrication unit failure."),
					_("situationReport-comms", "Parts shortage prevents scan probe replenishment."),
					_("situationReport-comms", "Station management has curtailed scan probe replenishment for cost cutting reasons."),
				}
				comms_target.probe_fail_reason = reason_list[math.random(1,#reason_list)]
			end
			msg = string.format("%s\n%s",msg,comms_target.probe_fail_reason)
			table.insert(improvements,"restock_probes")
		end
		if comms_target:getRepairDocked() then
			msg = string.format(_("situationReport-comms","%s\nRepair ship hull: nominal."),msg)
		else
			if comms_target.repair_fail_reason == nil then
				reason_list = {
					_("situationReport-comms", "We're out of the necessary materials and supplies for hull repair."),
					_("situationReport-comms", "Hull repair automation unavailable while it is undergoing maintenance."),
					_("situationReport-comms", "All hull repair technicians quarantined to quarters due to illness."),
				}
				comms_target.repair_fail_reason = reason_list[math.random(1,#reason_list)]
			end
			msg = string.format("%s\n%s",msg,comms_target.repair_fail_reason)
			table.insert(improvements,"hull")
		end
		if comms_target:getSharesEnergyWithDocked() then
			msg = string.format(_("situationReport-comms","%s\nRecharge ship energy stores: nominal."),msg)
		else
			if comms_target.energy_fail_reason == nil then
				reason_list = {
					_("situationReport-comms", "A recent reactor failure has put us on auxiliary power, so we cannot recharge ships."),
					_("situationReport-comms", "A damaged power coupling makes it too dangerous to recharge ships."),
					_("situationReport-comms", "An asteroid strike damaged our solar cells and we are short on power, so we can't recharge ships right now."),
				}
				comms_target.energy_fail_reason = reason_list[math.random(1,#reason_list)]
			end
			msg = string.format("%s\n%s",msg,comms_target.energy_fail_reason)
			table.insert(improvements,"energy")
		end
		local provides_some_missiles = false
		local missile_provision_msg = "Ordnance available:"
		local missile_types = {
			{name = "Nuke",		desc = _("situationReport-comms","nukes")},
			{name = "EMP",		desc = _("situationReport-comms","EMPs")},
			{name = "Homing",	desc = _("situationReport-comms","homings")},
			{name = "Mine",		desc = _("situationReport-comms","mines")},
			{name = "HVLI",		desc = _("situationReport-comms","HVLIs")},
		}
		for i,m_type in ipairs(missile_types) do
			if comms_target.comms_data.weapon_available[m_type.name] then
				if missile_provision_msg == _("situationReport-comms","Ordnance available:") then
					missile_provision_msg = string.format(_("situationReport-comms","%s %s@%i rep"),missile_provision_msg,m_type.desc,getWeaponCost(m_type.name))
				else
					missile_provision_msg = string.format(_("situationReport-comms","%s, %s@%i rep"),missile_provision_msg,m_type.desc,getWeaponCost(m_type.name))
				end
			else
				table.insert(improvements,m_type.name)
			end
		end
		if missile_provision_msg == _("situationReport-comms","Ordnance available:") then
			msg = string.format(_("situationReport-comms","%s\nNo ordnance available."),msg)
		else
			msg = string.format("%s\n%s.",msg,missile_provision_msg)
		end
		setCommsMessage(msg)
		if #improvements > 0 and comms_target:isFriendly(comms_source) then
			addCommsReply(_("situationReport-comms","Improve station services"),function()
				setCommsMessage(_("situationReport-comms","What station services would you like to improve?"))
				local improvement_prompt = {
					["restock_probes"] = _("situationReport-comms","Restocking of docked ship's scan probes"),
					["hull"] = _("situationReport-comms","Repairing of docked ship's hull"),
					["energy"] = "Charging of docked ship's energy reserves",
					["Nuke"] = _("situationReport-comms","Replenishment of nuclear ordnance"),
					["EMP"] = _("situationReport-comms","Replenishment of EMP missiles"),
					["Homing"] = _("situationReport-comms","Replenishment of homing missiles"),
					["HVLI"] = _("situationReport-comms","Replenishment of High Velocity Lead Impactors"),
					["Mine"] = _("situationReport-comms","Replenishment of mines"),
				}
				for i,improvement in ipairs(improvements) do
					if improvement_prompt[improvement] == nil then
						print("Unable to show improvements. Improvement value:",improvement)
					else
						addCommsReply(improvement_prompt[improvement],function()	--bad argument #1 to addCommsReply: string expected, got nil
							local mission_line = mission_good[improvement]
							print("improvement:",improvement,"mission_line:",mission_line)
							for mission,details in pairs(mission_line) do
								print("mission:",mission,"details:",details)
							end
							local needed_good = mission_line.good
							print("needed good:",needed_good)
							needed_good = mission_good[improvement].good
	--						local needed_good = mission_good[improvement]["good"]
							setCommsMessage(string.format(_("situationReport-comms","%s could be improved with %s. You may be able to get %s from independent stations or transports."),improvement_prompt[improvement],needed_good,needed_good))
							if comms_source.goods ~= nil then
								if comms_source.goods[needed_good] ~= nil and comms_source.goods[needed_good] > 0 and comms_source:isDocked(comms_target) then
									addCommsReply(string.format(_("situationReport-comms","Provide %s to station %s"),needed_good,comms_target:getCallSign()),function()
										if comms_source:isDocked(comms_target) then
											comms_source.goods[needed_good] = comms_source.goods[needed_good] - 1
											comms_source.cargo = comms_source.cargo + 1
											local improvement_msg = _("situationReport-comms","There was a problem with the improvement process")
											if improvement == "energy" then
												if comms_source.instant_energy == nil then
													comms_source.instant_energy = {}
												end
												table.insert(comms_source.instant_energy,comms_target)
												comms_target:setSharesEnergyWithDocked(true)
												improvement_msg = _("situationReport-comms","We can recharge again! Come back any time to have your batteries instantly recharged.")
											elseif improvement == "hull" then
												if comms_source.instant_hull == nil then
													comms_source.instant_hull = {}
												end
												table.insert(comms_source.instant_hull,comms_target)
												comms_target:setRepairDocked(true)
												improvement_msg = _("situationReport-comms","We can repair hulls again! Come back any time to have your hull instantly repaired.")
											elseif improvement == "restock_probes" then
												if comms_source.instant_probes == nil then
													comms_source.instant_probes = {}
												end
												table.insert(comms_source.instant_probes,comms_target)
												comms_target:setRestocksScanProbes(true)
												improvement_msg = _("situationReport-comms","We can restock scan probes again! Come back any time to have your scan probes instantly restocked.")
											elseif improvement == "Nuke" then
												if comms_source.nuke_discount == nil then
													comms_source.nuke_discount = {}
												end
												table.insert(comms_source.nuke_discount,comms_target)
												comms_target.comms_data.weapon_available.Nuke = true
												comms_target.comms_data.weapons["Nuke"] = "neutral"
												comms_target.comms_data.max_weapon_refill_amount.neutral = 1
												improvement_msg = _("situationReport-comms","We can replenish nukes again! Come back any time to have your supply of nukes replenished.")
											elseif improvement == "EMP" then
												if comms_source.emp_discount == nil then
													comms_source.emp_discount = {}
												end
												table.insert(comms_source.emp_discount,comms_target)
												comms_target.comms_data.weapon_available.EMP = true
												comms_target.comms_data.weapons["EMP"] = "neutral"
												comms_target.comms_data.max_weapon_refill_amount.neutral = 1
												improvement_msg = _("situationReport-comms","We can replenish EMPs again! Come back any time to have your supply of EMPs replenished.")
											elseif improvement == "Homing" then
												if comms_source.homing_discount == nil then
													comms_source.homing_discount = {}
												end
												table.insert(comms_source.homing_discount,comms_target)
												comms_target.comms_data.weapon_available.Homing = true
												comms_target.comms_data.max_weapon_refill_amount.neutral = 1
												improvement_msg = _("situationReport-comms","We can replenish homing missiles again! Come back any time to have your supply of homing missiles replenished.")
											elseif improvement == "Mine" then
												if comms_source.mine_discount == nil then
													comms_source.mine_discount = {}
												end
												table.insert(comms_source.mine_discount,comms_target)
												comms_target.comms_data.weapon_available.Mine = true
												comms_target.comms_data.weapons["Mine"] = "neutral"
												comms_target.comms_data.max_weapon_refill_amount.neutral = 1
												improvement_msg = _("situationReport-comms","We can replenish mines again! Come back any time to have your supply of mines replenished.")
											elseif improvement == "HVLI" then
												if comms_source.hvli_discount == nil then
													comms_source.hvli_discount = {}
												end
												table.insert(comms_source.hvli_discount,comms_target)
												comms_target.comms_data.weapon_available.HVLI = true
												comms_target.comms_data.max_weapon_refill_amount.neutral = 1
												improvement_msg = _("situationReport-comms","We can replenish HVLIs again! Come back any time to have your supply of high velocity lead impactors replenished.")
											end
											setCommsMessage(improvement_msg)
										else
											setCommsMessage(_("situationReport-comms","Can't do that when you're not docked"))
										end
										addCommsReply(_("Back"), commsStation)
									end)
								end
							end
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
				addCommsReply(_("Back"), commsStation)
			end)
		end
		addCommsReply(_("Back"), commsStation)
	end)
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
	if comms_data.weapons == nil then
        comms_data.weapons = {
            Homing = "neutral",
            HVLI = "neutral",
            Mine = "neutral",
            Nuke = "friend",
            EMP = "friend"
        }
	end
    if not isAllowedTo(comms_data.weapons[weapon]) then	--attempt to index a nil value weapons
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
					addCommsReply(_("Back"), commsStation)
				end)
			else
	            setCommsMessage(_("needRep-comms", "Not enough reputation."))
			end
		end
        addCommsReply(_("Back"), commsStation)
    end
end
function getWeaponCost(weapon)
	local discounts = {
		["Homing"] = {tbl = comms_source.homing_discount, rep = 1},
		["Nuke"] = {tbl = comms_source.nuke_discount, rep = 5},
		["EMP"] = {tbl = comms_source.emp_discount, rep = 5},
		["Mine"] = {tbl = comms_source.mine_discount, rep = 1},
		["HVLI"] = {tbl = comms_source.hvli_discount, rep = 1},
	}
	if discounts[weapon].tbl ~= nil then
		for i,station in ipairs(discounts[weapon].tbl) do
			if station == comms_target then
				return discounts[weapon].rep
			end
		end
	end		--line below: attempt to index a nil value field weapon_cost
	if comms_data.weapon_cost == nil then
        comms_data.weapon_cost = {
            Homing = math.random(1,4),
            HVLI = math.random(1,3),
            Mine = math.random(2,5),
            Nuke = math.random(12,18),
            EMP = math.random(7,13)
        }
	end
	if comms_data.reputation_cost_multipliers == nil then
        comms_data.reputation_cost_multipliers = {
            friend = 1.0,
            neutral = 3.0
        }
	end
    return math.ceil(comms_data.weapon_cost[weapon] * comms_data.reputation_cost_multipliers[getFriendStatus()])
end
function getFriendStatus()
    if comms_source:isFriendly(comms_target) then
        return "friend"
    else
        return "neutral"
    end
end
function addStationToDatabase(station)
	--	Assumes all player ships will be the same faction
	local player_faction = "Human Navy"
	local stations_key = _("scienceDB","Stations")
	local stations_db = queryScienceDatabase(stations_key)
	if stations_db == nil then
		stations_db = ScienceDatabase():setName(stations_key)
	end
	local station_db = nil
	local station_key = station:getCallSign()
	local temp_artifact = Artifact():setFaction(player_faction)
	local first_time_entry = false
	if station:isFriendly(temp_artifact) then
		local friendly_key = _("scienceDB","Friendly")
		local friendly_db = queryScienceDatabase(stations_key,friendly_key)
		if friendly_db == nil then
			stations_db:addEntry(friendly_key)
			friendly_db = queryScienceDatabase(stations_key,friendly_key)
			friendly_db:setLongDescription(_("scienceDB","Friendly stations share their short range telemetry with your ship on the Relay and Strategic Map consoles. These are the known friendly stations."))
		end
		station_db = queryScienceDatabase(stations_key,friendly_key,station_key)
		if station_db == nil then
			friendly_db:addEntry(station_key)
			station_db = queryScienceDatabase(stations_key,friendly_key,station_key)
			first_time_entry = true
		end
	elseif not station:isEnemy(temp_artifact) then
		local neutral_key = "Neutral"
		local neutral_db = queryScienceDatabase(stations_key,neutral_key)
		if neutral_db == nil then
			stations_db:addEntry(neutral_key)
			neutral_db = queryScienceDatabase(stations_key,neutral_key)
			neutral_db:setLongDescription(_("scienceDB","Neutral stations don't share their short range telemetry with your ship, but they do allow for docking. These are the known neutral stations."))
		end
		station_db = queryScienceDatabase(stations_key,neutral_key,station_key)
		if station_db == nil then
			neutral_db:addEntry(station_key)
			station_db = queryScienceDatabase(stations_key,neutral_key,station_key)
			first_time_entry = true
		end
	end
	if first_time_entry then
		local out = ""
		if station:getDescription() ~= nil then
			out = station:getDescription()
		end
		if station.comms_data ~= nil then
			if station.comms_data.general ~= nil and station.comms_data.general ~= "" then
				out = string.format(_("scienceDB","%s\n\nGeneral Information: %s"),out,station.comms_data.general)
			end
			if station.comms_data.history ~= nil and station.comms_data.history ~= "" then
				out = string.format(_("scienceDB","%s\n\nHistory: %s"),out,station.comms_data.history)
			end
		end
		if out ~= "" then
			station_db:setLongDescription(out)
		end
		local station_type = station:getTypeName()
		local size_value = ""
		local small_station_key = _("scienceDB","Small Station")
		local medium_station_key = _("scienceDB","Medium Station")
		local large_station_key = _("scienceDB","Large Station")
		local huge_station_key = _("scienceDB","Huge Station")
		if station_type == small_station_key then
			size_value = _("scienceDB","Small")
			local small_db = queryScienceDatabase(stations_key,small_station_key)
			if small_db ~= nil then
				station_db:setImage(small_db:getImage())
			end
			station_db:setModelDataName("space_station_4")
		elseif station_type == medium_station_key then
			size_value = _("scienceDB","Medium")
			local medium_db = queryScienceDatabase(stations_key,medium_station_key)
			if medium_db ~= nil then
				station_db:setImage(medium_db:getImage())
			end
			station_db:setModelDataName("space_station_3")
		elseif station_type == large_station_key then
			size_value = _("scienceDB","Large")
			local large_db = queryScienceDatabase(stations_key,large_station_key)
			if large_db ~= nil then
				station_db:setImage(large_db:getImage())
			end
			station_db:setModelDataName("space_station_2")
		elseif station_type == huge_station_key then
			size_value = _("scienceDB","Huge")
			local huge_db = queryScienceDatabase(stations_key,huge_station_key)
			if huge_db ~= nil then
				station_db:setImage(huge_db:getImage())
			end
			station_db:setModelDataName("space_station_1")
		end
		if size_value ~= "" then
			local size_key = _("scienceDB","Size")
			station_db:setKeyValue(size_key,size_value)
		end
		local location_key = _("scienceDB","Location, Faction")
		station_db:setKeyValue(location_key,string.format("%s, %s",station:getSectorName(),station:getFaction()))
	end
	local dock_service = ""
	local service_count = 0
	if station:getSharesEnergyWithDocked() then
		dock_service = _("scienceDB","share energy")
		service_count = service_count + 1
	end
	if station:getRepairDocked() then
		if dock_service == "" then
			dock_service = _("scienceDB","repair hull")
		else
			dock_service = string.format(_("scienceDB","%s, repair hull"),dock_service)
		end
		service_count = service_count + 1
	end
	if station:getRestocksScanProbes() then
		if dock_service == "" then
			dock_service = _("scienceDB","replenish probes")
		else
			dock_service = string.format(_("scienceDB","%s, replenish probes"),dock_service)
		end
		service_count = service_count + 1
	end
	if service_count > 0 then
		local docking_services_key = _("scienceDB","Docking Services")
		if service_count == 1 then
			docking_services_key = _("scienceDB","Docking Service")
		end
		station_db:setKeyValue(docking_services_key,dock_service)
	end
	if station.comms_data ~= nil then
		if station.comms_data.weapon_available ~= nil then
			if station.comms_data.weapon_cost == nil then
				station.comms_data.weapon_cost = {
					Homing = math.random(1,4),
					HVLI = math.random(1,3),
					Mine = math.random(2,5),
					Nuke = math.random(12,18),
					EMP = math.random(7,13),
				}
			end
			if station.comms_data.reputation_cost_multipliers == nil then
				station.comms_data.reputation_cost_multipliers = {
					friend = 1.0,
					neutral = 3.0,
				}
			end
			local station_missiles = {
				{name = "Homing",	key = _("scienceDB","Restock Homing")},
				{name = "HVLI",		key = _("scienceDB","Restock HVLI")},
				{name = "Mine",		key = _("scienceDB","Restock Mine")},
				{name = "Nuke",		key = _("scienceDB","Restock Nuke")},
				{name = "EMP",		key = _("scienceDB","Restock EMP")},
			}
			for i,sm in ipairs(station_missiles) do
				if station.comms_data.weapon_available[sm.name] then
					if station.comms_data.weapon_cost[sm.name] ~= nil then
						local val = string.format(_("scienceDB","%i reputation each"),math.ceil(station.comms_data.weapon_cost[sm.name] * station.comms_data.reputation_cost_multipliers["friend"]))
						station_db:setKeyValue(sm.key,val)
					end
				end
			end
		end
		if station.comms_data.service_available ~= nil then
			local general_service = {
				{name = "supplydrop",				key = _("scienceDB","Drop supplies")},
				{name = "reinforcements",			key = _("scienceDB","Standard reinforcements")},
				{name = "hornet_reinforcements",	key = _("scienceDB","Hornet reinforcements")},
				{name = "phobos_reinforcements",	key = _("scienceDB","Phobos reinforcements")},
				{name = "amk3_reinforcements",		key = _("scienceDB","Adder3 reinforcements")},
				{name = "amk8_reinforcements",		key = _("scienceDB","Adder8 reinforcements")},
				{name = "shield_overcharge",		key = _("scienceDB","Shield overcharge")},
			}
			for i,gs in ipairs(general_service) do
				if station.comms_data.service_available[gs.name] then
					if station.comms_data.service_cost[gs.name] ~= nil then
						local val = string.format(_("scienceDB","%s reputation"),station.comms_data.service_cost[gs.name])
						station_db:setKeyValue(gs.key,val)
					end
				end
			end
		end
		if station.comms_data.goods ~= nil and not temp_artifact:isFriendly(station) then
			for good, details in pairs(station.comms_data.goods) do
				if details.quantity > 0 then
					local sell_key = string.format(_("scienceDB","Sells %s"),good)
					local sell_value = string.format(_("scienceDB","for %s reputation each"),details.cost)
					station_db:setKeyValue(sell_key,sell_value)
				end
			end
		end
	end
	temp_artifact:destroy()
end
--------------------------
--	Ship Communication  --
--------------------------
function commsShip()
	if comms_target.comms_data == nil then
		comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
	end
	if comms_target.comms_data.goods == nil then
		comms_target.comms_data.goods = {}
		local goods_pool = {}
		for mission,details in pairs(mission_good) do
			table.insert(goods_pool,details.good)
		end
		local good = tableRemoveRandom(goods_pool)
		comms_target.comms_data.goods[good] = {quantity = 1, cost = math.random(20,80)}
		if comms_target:getTypeName():find("Freighter") ~= nil then
			good = tableRemoveRandom(goods_pool)
			comms_target.comms_data.goods[good] = {quantity = 1, cost = math.random(20,80)}
			good = tableRemoveRandom(goods_pool)
			comms_target.comms_data.goods[good] = {quantity = 1, cost = math.random(20,80)}
		end
	end
	comms_data = comms_target.comms_data
	if comms_source:isFriendly(comms_target) then
		return friendlyComms(comms_data)
	elseif comms_source:isEnemy(comms_target) then
		return enemyComms(comms_data)
	else
		return neutralComms(comms_data)
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
		local current_order = comms_target:getOrder()
		if current_order == "Dock" then
			local current_dock_target = comms_target:getOrderTarget()
			msg = string.format(_("shipAssist-comms","%sCurrently on course to dock with %s station %s in %s"),msg,current_dock_target:getFaction(),current_dock_target:getCallSign(),current_dock_target:getSectorName())
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
	return true
end
function enemyComms(comms_data)
	local faction = comms_target:getFaction()
	local tauntable = false
	local amenable = false
	if comms_data.friendlyness >= 33 then	--final: 33
		--taunt logic
		local taunt_option = _("shipEnemy-comms","We will see to your destruction!")
		local taunt_success_reply = _("shipEnemy-comms","Your bloodline will end here!")
		local taunt_failed_reply = _("shipEnemy-comms","Your feeble threats are meaningless.")
		local taunt_threshold = 30		--base chance of being taunted
		local immolation_threshold = 5	--base chance that taunting will enrage to the point of revenge immolation
		if faction == "Kraylor" then
			taunt_threshold = 35
			immolation_threshold = 6
			setCommsMessage(_("shipEnemy-comms","Ktzzzsss.\nYou will DIEEee weaklingsss!"));
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
			setCommsMessage(_("shipEnemy-comms","We wish you no harm, but will harm you if we must.\nEnd of transmission."));
		elseif faction == "Exuari" then
			taunt_threshold = 40
			immolation_threshold = 7
			setCommsMessage(_("shipEnemy-comms","Stay out of our way, or your death will amuse us extremely!"));
		elseif faction == "Ghosts" then
			taunt_threshold = 20
			immolation_threshold = 3
			setCommsMessage(_("shipEnemy-comms","One zero one.\nNo binary communication detected.\nSwitching to universal speech.\nGenerating appropriate response for target from human language archives.\n:Do not cross us:\nCommunication halted."));
			taunt_option = _("shipEnemy-comms","EXECUTE: SELFDESTRUCT")
			taunt_success_reply = _("shipEnemy-comms","Rogue command received. Targeting source.")
			taunt_failed_reply = _("shipEnemy-comms","External command ignored.")
		elseif faction == "Ktlitans" then
			setCommsMessage(_("shipEnemy-comms","The hive suffers no threats. Opposition to any of us is opposition to us all.\nStand down or prepare to donate your corpses toward our nutrition."));
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
			setCommsMessage(_("shipEnemy-comms","Mind your own business!"));
		end
		comms_data.friendlyness = comms_data.friendlyness - random(0, 10)	--reduce friendlyness after each interaction
		addCommsReply(taunt_option, function()
			if random(0, 100) <= taunt_threshold then
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
					end
					if current_order == "Attack" or current_order == "Dock" or current_order == "Defend Target" then
						local original_target = comms_target:getOrderTarget()
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
	if tauntable or amenable then
		return true
	else
		return false
	end
end
function neutralComms(comms_data)
	local shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil or shipType:find("Transport") ~= nil then
		if comms_target:getOrder() == "Dock" then
			local dock_target = comms_target:getOrderTarget()
			if dock_target ~= nil and dock_target:isValid() and not dock_target:isEnemy(comms_source) then
				addCommsReply(_("ship-comms","Please tell me about your destination"),function()
					setCommsMessage(string.format(_("ship-comms","We are going to station %s in sector %s. We'll pick stuff up, drop stuff off, the usual commercial activity. Here, let me send you the data on the station for your science database."),dock_target:getCallSign(),dock_target:getSectorName()))
					addStationToDatabase(dock_target)
					addCommsReply(_("Back"), commsShip)
				end)
			end
		end
		setCommsMessage(_("ship-comms","Yes?"))
		if distance(comms_source,comms_target) < 5000 then
			local will_sell = false
			local cost_multiplier = 1
			if comms_data.friendlyness > 66 then
				will_sell = true
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					cost_multiplier = 1
				else
					cost_multiplier = 2
				end
			elseif comms_data.friendlyness > 33 then
				will_sell = true
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					cost_multiplier = 2
				else
					cost_multiplier = 3
				end
			else	--least friendly
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					will_sell = true
					cost_multiplier = 3
				end
			end
			if comms_source.cargo > 0 and will_sell then
				for good, goodData in pairs(comms_data.goods) do
					if goodData.quantity > 0 then
						local good_cost = math.floor(goodData.cost*cost_multiplier)
						addCommsReply(string.format(_("ship-comms","Buy one %s for %i reputation"),good,good_cost), function()
							if comms_source:takeReputationPoints(good_cost) then
								goodData.quantity = goodData.quantity - 1
								if comms_source.goods == nil then
									comms_source.goods = {}
								end
								if comms_source.goods[good] == nil then
									comms_source.goods[good] = 0
								end
								comms_source.goods[good] = comms_source.goods[good] + 1
								comms_source.cargo = comms_source.cargo - 1
								setCommsMessage(string.format(_("ship-comms","Purchased %s from %s"),good,comms_target:getCallSign()))
							else
								setCommsMessage(_("ship-comms","Insufficient reputation for purchase"))
							end
							addCommsReply(_("Back"), commsShip)
						end)
					end
				end	--freighter goods loop
			end	--player has room for cargo
		else	--not close enough to sell
			addCommsReply(_("ship-comms","Do you have cargo you might sell?"), function()
				local goodCount = 0
				local cargoMsg = _("ship-comms","We've got ")
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
					cargoMsg = cargoMsg .. _("ship-comms","nothing")
				end
				setCommsMessage(cargoMsg)
				addCommsReply(_("Back"), commsShip)
			end)
		end
	else	--not a freighter
		if comms_data.friendlyness > 50 then
			setCommsMessage(_("ship-comms","Sorry, we have no time to chat with you.\nWe are busy."));
		else
			setCommsMessage(_("ship-comms","We have nothing for you.\nGood day."));
		end
	end	--end non-freighter communications else branch
	return true
end	--end neutral communications function

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
            if enemy.typeName == "SpaceStation" or enemy:getTypeName() == "Defense platform" then
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
    		msg = string.format(_("msgMainscreen","%s\n%i waves completed at the %s setting."),msg,completed_waves,getScenarioSetting("Enemies"))
    	elseif completed_waves > 0 then
    		msg = string.format(_("msgMainscreen","%s\nOne wave completed at the %s setting."),msg,completed_waves,getScenarioSetting("Enemies"))
    	else
    		msg = string.format(_("msgMainscreen","%s\nNo waves completed at the %s setting."),msg,getScenarioSetting("Enemies"))
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
