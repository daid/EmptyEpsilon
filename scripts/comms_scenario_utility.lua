-- Name: Comms Utility
-- Description: Make external flexible utility for handling communications
-- Author: Xansta
--------------------------------------------------------------------------
--	General instructions for how to use this utility
--		Set booleans for the aspects you want to use.
--		Define any functions that work in conjunction with this utility.
--		Add any applicable lines in your update function to use enabled utility aspects.
--		The available booleans and functions are described in this utility just above
--      the function where they are used. If you are here trying to use this utility, then 
--		you will probably want to read the code that applies to the aspect you are 
--		interested in using.
--	Motivation
--		I'm mainly writing this for myself. I find I spend a significant amount of time
--		copying and pasting code from scenario to scenario related to communications.
--		With this utility, I hope to reduce the amount of time coding and reduce the
--		amount of time it takes to review new scenarios. Anyone is welcome to use
--		this utility. I made some effort to have it approachable, but I am fairly confident
--		that someone will find something they'd like to improve upon. If you decide to
--		make changes directly, be sure to test existing scenarios that use this utility.
--		I intend to start switching several scenarios to using this utility.
--	Scenarios that depend on this utility:
--		Liberation Day	scenario_27_liberation.lua
----------------------------------------------
--	Functions you may want to set up outside of this utility
--		setCommsStationFriendliness - returns a number between 0 and 100 representing the
--			station's friendliness. Useful if you have a category of stations that need
--			a range of friendliness other than a random value between 0 and 100.
--			Example of wanting the inner stations generally friendlier:
--				function setCommsStationFriendliness()
--					local friendliness = random(0,100)
--					for i,station in ipairs(inner_stations) do
--						if station ~= nil and station:isValid() and station == comms_target then
--							if comms_target.comms_data ~= nil and comms_target.comms_data.friendlyness ~= nil then
--								if comms_target.comms_data.friendlyness < 50 then
--									friendliness = random(50,100)
--								else
--									friendliness = comms_target.comms_data.friendlyness
--								end
--							end
--						end
--					end
--					return friendliness
--				end
--		handleEnemiesInRange - returns true if a message is sent about enemies being
--			too close to allow communication with the station. 
--			See handle_enemies_in_short_range boolean below.
--			Example:
--			function handleEnemiesInRange()
--				local short_range_radar = comms_target:getShortRangeRadarRange()
--				if comms_target:areEnemiesInRange(short_range_radar/3) then
--					setCommsMessage(string.format((_"station-comms","[Automated Response]\nWe're sorry, but we cannot take your call right now. All personnel are busy at emergency stations due to hostile entities within %.1f units"),short_range_radar/3/1000))
--					if isAllowedTo(comms_target.comms_data.services.activatedefensefleet) then
--						stationDefenseFleet()
--					end
--					return true
--				end
--			end
--	Booleans to set outside of this utility to control this utility. Default is false
--		fixed_ordnance_cost - sets the price for ordnance to fixed values. Default (false) 
--			is to set ordnance to range appropriate random values.
--		fixed_service_cost - sets the price for services to fixed values. Default (false)
--			is to set service costs to range appropriate random values.
--		add_station_to_database - puts the station in the science database when a player
--			contacts the station. Updates some of the values as applicable each contact.
--		set_players - calls function setPlayers() when the players contact the station.
--		handle_enemies_in_short_range - The default (false) is to respond to the player
--			that the station cannot talk when enemies are within 5u. If this boolean is
--			true, the short range radar range is used as the range at which the station
--			does not talk to players. This boolean is ignored if the handleEnemiesInRange
--			function exists.
--	Note: more booleans are listed before each function to which they apply
require("utils.lua")
require("generate_call_sign_scenario_utility.lua")
function commsStation()
	if comms_target.comms_data == nil then
		comms_target.comms_data = {}
	end
	local friendliness = random(0,100)
	if setCommsStationFriendliness ~= nil then
		friendliness = setCommsStationFriendliness()
	end
	local homing_cost = math.random(1,4)
	local hvli_cost = math.random(1,3)
	local mine_cost = math.random(2,5)
	local nuke_cost = math.random(12,18)
	local emp_cost = math.random(7,13)
	if fixed_ordnance_cost then
		homing_cost = 2
		hvli_cost = 2
		mine_cost = 2
		nuke_cost = 15
		emp_cost = 10
	end
	local supply_drop_cost = math.random(80,120)
	local jump_supply_drop_cost = math.random(110,140)
	local fling_supply_drop_cost = math.random(140,170)
	local reinforcements_cost = math.random(125,175)
	local phobos_reinforcements_cost = math.random(200,250)
	local stalker_reinforcements_cost = math.random(275,325)
	local amk3_reinforcement_cost = math.random(85,115)
	local hornet_reinforcement_cost = math.random(85,115)
	local amk8_reinforcement_cost = math.random(180,220)
	local activate_defense_fleet_cost = math.random(15,30)
	if fixed_service_cost then
		supply_drop_cost = 100
		jump_supply_drop_cost = 125
		fling_supply_drop_cost = 155
		reinforcements_cost = 150
		phobos_reinforcements_cost = 225
		stalker_reinforcements_cost = 300
		amk3_reinforcement_cost = 100
		hornet_reinforcement_cost = 100
		amk8_reinforcement_cost = 200
		activate_defense_fleet_cost = 20
	end
    mergeTables(comms_target.comms_data, {
        friendlyness = friendliness,
        weapons = {
            Homing = "neutral",
            HVLI = "neutral",
            Mine = "neutral",
            Nuke = "friend",
            EMP = "friend"
        },
        weapon_cost = {
            Homing = homing_cost,
            HVLI = hvli_cost,
            Mine = mine_cost,
            Nuke = nuke_cost,
            EMP = emp_cost,
        },
        services = {
            supplydrop = "friend",
			jumpsupplydrop = "friend",
			flingsupplydrop = "friend",
            reinforcements = "friend",
            activatedefensefleet = "neutral"
        },
        service_cost = {
            supplydrop = supply_drop_cost,
        	jumpsupplydrop = jump_supply_drop_cost,
        	flingsupplydrop = fling_supply_drop_cost,
            reinforcements = reinforcements_cost,
            phobos_reinforcements = phobos_reinforcements_cost,
            stalker_reinforcements = stalker_reinforcements_cost,
            amk3_reinforcements = amk3_reinforcement_cost,
            hornet_reinforcements = hornet_reinforcement_cost,
            amk8_reinforcements = amk8_reinforcement_cost,
            activatedefensefleet = activate_defense_fleet_cost,
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
--	comms_data = comms_target.comms_data
    if add_station_to_database then
		if not comms_source:isEnemy(comms_target) then
			if player_faction == nil then
				player_faction = comms_source:getFaction()
			end
			addStationToDatabase(comms_target)
		end
    end
    if set_players then
    	setPlayers()
    end
    if comms_source:isEnemy(comms_target) then
        return false
    end
	local no_relay_panic_responses = {
		_("station-comms","No communication officers available due to station emergency."),
		_("station-comms","Relay officers unavailable during station emergency."),
		_("station-comms","Relay officers reassigned for station emergency."),
		_("station-comms","Station emergency precludes response from relay officer."),
		_("station-comms","We are under attack! No time for chatting!"),
	}
	if handleEnemiesInRange ~= nil then
		handleEnemiesInRange()
	elseif handle_enemies_in_short_range then
		if comms_target:areEnemiesInRange(comms_target:getShortRangeRadarRange()) then
			setCommsMessage(tableSelectRandom(no_relay_panic_responses))
			return true
		end
	else
		if comms_target:areEnemiesInRange(5000) then
			setCommsMessage(tableSelectRandom(no_relay_panic_responses))
			return true
		end
	end
	if comms_source:isDocked(comms_target) then
		handleDockedState()
	else
		handleUndockedState()
	end
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
	angle = (angle + 270) % 360
	local x, y = vectorFromAngle(angle,distance)
	return x, y
end
--	Initialization utilities
function initializeGoodDescription()
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
end
function initializeCommonGoods()
	if commonGoods == nil then
		commonGoods = {"food","medicine","nickel","platinum","gold","dilithium","tritanium","luxury","cobalt","impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	end
	if componentGoods == nil then
		componentGoods = {"impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	end
	if mineralGoods == nil then
		mineralGoods = {"nickel","platinum","gold","dilithium","tritanium","cobalt"}
	end
	max_repeat_loop = 100
end
function initializeImprovementMissions()
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
    local player_faction = player_faction
    if player_faction == nil then
    	player_faction = comms_source:getFaction()
    end
	local tpa = Artifact():setFaction(player_faction)	--temporary player artifact
	local mission_stations = {}
	for i,station in ipairs(regionStations) do
		if station:isValid() then
			if not station:isEnemy(tpa) then
				local station_type = station:getTypeName()
				if station_type == "Small Station" or station_type == "Medium Station" or station_type == "Large Station" or station_type == "Huge Station" then
					table.insert(mission_stations,station)
				end
			end
		end
	end
	for i,station in ipairs(mission_stations) do
		if not station:isEnemy(tpa) then
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
	end
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
    for i,station in ipairs(mission_stations) do
    	if not station:isEnemy(tpa) then
			if station.comms_data ~= nil and station.comms_data.goods ~= nil then
				for station_good,details in pairs(station.comms_data.goods) do
					for mission,mission_goods in pairs(mission_goods) do
						for k,mission_good in ipairs(mission_goods) do
							if mission_good == station_good then
								if missions_stations_goods[mission] == nil then
									missions_stations_goods[mission] = {}
								end
								if missions_stations_goods[mission][station] == nil then
									missions_stations_goods[mission][station] = {}
								end
								table.insert(missions_stations_goods[mission][station],mission_good)
							end
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
			for i,station in ipairs(mission_stations) do
				if not station:isEnemy(tpa) then
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
    print("Missions and goods final:")
    for mission,details in pairs(mission_good) do
    	local out_station = "None"
    	if details.station ~= nil then
    		out_station = details.station:getCallSign()
    	end
    	print("Mission:",mission,"Good:",details.good,"Station:",out_station)
    end
	tpa:destroy()
end
function initializeCharacters()
	characters = {
		{name = "Frank Brown", subject_pronoun = _("characterInfo-comms","he"), object_pronoun = _("characterInfo-comms","him"), possessive_adjective = _("characterInfo-comms","his")},
		{name = "Joyce Miller", subject_pronoun = _("characterInfo-comms","she"), object_pronoun = _("characterInfo-comms","her"), possessive_adjective = _("characterInfo-comms","her")},
		{name = "Harry Jones", subject_pronoun = _("characterInfo-comms","he"), object_pronoun = _("characterInfo-comms","him"), possessive_adjective = _("characterInfo-comms","his")},
		{name = "Emma Davis", subject_pronoun = _("characterInfo-comms","she"), object_pronoun = _("characterInfo-comms","her"), possessive_adjective = _("characterInfo-comms","her")},
		{name = "Zhang Wei Chen", subject_pronoun = _("characterInfo-comms","he"), object_pronoun = _("characterInfo-comms","him"), possessive_adjective = _("characterInfo-comms","his")},
		{name = "Yu Yan Li", subject_pronoun = _("characterInfo-comms","she"), object_pronoun = _("characterInfo-comms","her"), possessive_adjective = _("characterInfo-comms","her")},
		{name = "Li Wei Wang", subject_pronoun = _("characterInfo-comms","he"), object_pronoun = _("characterInfo-comms","him"), possessive_adjective = _("characterInfo-comms","his")},
		{name = "Li Na Zhao", subject_pronoun = _("characterInfo-comms","she"), object_pronoun = _("characterInfo-comms","her"), possessive_adjective = _("characterInfo-comms","her")},
		{name = "Sai Laghari", subject_pronoun = _("characterInfo-comms","he"), object_pronoun = _("characterInfo-comms","him"), possessive_adjective = _("characterInfo-comms","his")},
		{name = "Anaya Khatri", subject_pronoun = _("characterInfo-comms","she"), object_pronoun = _("characterInfo-comms","her"), possessive_adjective = _("characterInfo-comms","her")},
		{name = "Vihaan Reddy", subject_pronoun = _("characterInfo-comms","he"), object_pronoun = _("characterInfo-comms","him"), possessive_adjective = _("characterInfo-comms","his")},
		{name = "Trisha Varma", subject_pronoun = _("characterInfo-comms","she"), object_pronoun = _("characterInfo-comms","her"), possessive_adjective = _("characterInfo-comms","her")},
		{name = "Henry Gunawan", subject_pronoun = _("characterInfo-comms","he"), object_pronoun = _("characterInfo-comms","him"), possessive_adjective = _("characterInfo-comms","his")},
		{name = "Putri Febrian", subject_pronoun = _("characterInfo-comms","she"), object_pronoun = _("characterInfo-comms","her"), possessive_adjective = _("characterInfo-comms","her")},
		{name = "Stanley Hartono", subject_pronoun = _("characterInfo-comms","he"), object_pronoun = _("characterInfo-comms","him"), possessive_adjective = _("characterInfo-comms","his")},
		{name = "Citra Mulyadi", subject_pronoun = _("characterInfo-comms","she"), object_pronoun = _("characterInfo-comms","her"), possessive_adjective = _("characterInfo-comms","her")},
		{name = "Bashir Pitafi", subject_pronoun = _("characterInfo-comms","he"), object_pronoun = _("characterInfo-comms","him"), possessive_adjective = _("characterInfo-comms","his")},
		{name = "Hania Kohli", subject_pronoun = _("characterInfo-comms","she"), object_pronoun = _("characterInfo-comms","her"), possessive_adjective = _("characterInfo-comms","her")},
		{name = "Gohar Lehri", subject_pronoun = _("characterInfo-comms","he"), object_pronoun = _("characterInfo-comms","him"), possessive_adjective = _("characterInfo-comms","his")},
		{name = "Sohelia Lau", subject_pronoun = _("characterInfo-comms","she"), object_pronoun = _("characterInfo-comms","her"), possessive_adjective = _("characterInfo-comms","her")},
		{name = "Gabriel Santos", subject_pronoun = _("characterInfo-comms","he"), object_pronoun = _("characterInfo-comms","him"), possessive_adjective = _("characterInfo-comms","his")},
		{name = "Ana Melo", subject_pronoun = _("characterInfo-comms","she"), object_pronoun = _("characterInfo-comms","her"), possessive_adjective = _("characterInfo-comms","her")},
		{name = "Lucas Barbosa", subject_pronoun = _("characterInfo-comms","he"), object_pronoun = _("characterInfo-comms","him"), possessive_adjective = _("characterInfo-comms","his")},
		{name = "Juliana Rocha", subject_pronoun = _("characterInfo-comms","she"), object_pronoun = _("characterInfo-comms","her"), possessive_adjective = _("characterInfo-comms","her")},
		{name = "Habib Oni", subject_pronoun = _("characterInfo-comms","he"), object_pronoun = _("characterInfo-comms","him"), possessive_adjective = _("characterInfo-comms","his")},
		{name = "Chinara Adebayo", subject_pronoun = _("characterInfo-comms","she"), object_pronoun = _("characterInfo-comms","her"), possessive_adjective = _("characterInfo-comms","her")},
		{name = "Tanimu Ali", subject_pronoun = _("characterInfo-comms","he"), object_pronoun = _("characterInfo-comms","him"), possessive_adjective = _("characterInfo-comms","his")},
		{name = "Naija Bello", subject_pronoun = _("characterInfo-comms","she"), object_pronoun = _("characterInfo-comms","her"), possessive_adjective = _("characterInfo-comms","her")},
		{name = "Shamim Khan", subject_pronoun = _("characterInfo-comms","he"), object_pronoun = _("characterInfo-comms","him"), possessive_adjective = _("characterInfo-comms","his")},
		{name = "Barsha Tripura", subject_pronoun = _("characterInfo-comms","she"), object_pronoun = _("characterInfo-comms","her"), possessive_adjective = _("characterInfo-comms","her")},
		{name = "Sumon Das", subject_pronoun = _("characterInfo-comms","he"), object_pronoun = _("characterInfo-comms","him"), possessive_adjective = _("characterInfo-comms","his")},
		{name = "Farah Munsi", subject_pronoun = _("characterInfo-comms","she"), object_pronoun = _("characterInfo-comms","her"), possessive_adjective = _("characterInfo-comms","her")},
		{name = "Denis Popov", subject_pronoun = _("characterInfo-comms","he"), object_pronoun = _("characterInfo-comms","him"), possessive_adjective = _("characterInfo-comms","his")},
		{name = "Pasha Sokolov", subject_pronoun = _("characterInfo-comms","she"), object_pronoun = _("characterInfo-comms","her"), possessive_adjective = _("characterInfo-comms","her")},
		{name = "Burian Ivanov", subject_pronoun = _("characterInfo-comms","he"), object_pronoun = _("characterInfo-comms","him"), possessive_adjective = _("characterInfo-comms","his")},
		{name = "Radka Vasiliev", subject_pronoun = _("characterInfo-comms","she"), object_pronoun = _("characterInfo-comms","her"), possessive_adjective = _("characterInfo-comms","her")},
		{name = "Jose Hernandez", subject_pronoun = _("characterInfo-comms","he"), object_pronoun = _("characterInfo-comms","him"), possessive_adjective = _("characterInfo-comms","his")},
		{name = "Victoria Garcia", subject_pronoun = _("characterInfo-comms","she"), object_pronoun = _("characterInfo-comms","her"), possessive_adjective = _("characterInfo-comms","her")},
		{name = "Miguel Lopez", subject_pronoun = _("characterInfo-comms","he"), object_pronoun = _("characterInfo-comms","him"), possessive_adjective = _("characterInfo-comms","his")},
		{name = "Renata Rodriguez", subject_pronoun = _("characterInfo-comms","she"), object_pronoun = _("characterInfo-comms","her"), possessive_adjective = _("characterInfo-comms","her")},
	}
end
function initializeStationCoolantEconomy()
	station_coolant_inventory_min = 0
	station_coolant_inventory_max = 5
	station_coolant_very_friendly_threshold = 66
	station_coolant_cost_excess_fee_min = 20
	station_coolant_cost_excess_fee_max = 40
	station_coolant_stranger_fee_min = 20
	station_coolant_stranger_fee_max = 40
	station_coolant_friendly_min = 30
	station_coolant_friendly_max = 60
	station_coolant_neutral_min = 45
	station_coolant_neutral_max = 90
end
function initializeStationRepairCrewEconomy()
	station_repair_crew_inventory_min = 0
	station_repair_crew_inventory_max = 5
	station_repair_crew_very_friendly_threshold = 66
	station_repair_crew_cost_excess_fee_min = 20
	station_repair_crew_cost_excess_fee_max = 40
	station_repair_crew_stranger_fee_min = 20
	station_repair_crew_stranger_fee_max = 40
	station_repair_crew_friendly_min = 30
	station_repair_crew_friendly_max = 60
	station_repair_crew_neutral_min = 45
	station_repair_crew_neutral_max = 90
end
function initializeCommsSourceMaxRepairCrew()
	comms_source.maxRepairCrew = comms_source:getRepairCrewCount()
end
function initializeCommsSourceInitialCoolant()
	comms_source.initialCoolant = comms_source:getMaxCoolant()
end
function initializePrettySystems()
	pretty_system = {
		["reactor"] = _("stationServices-comms","reactor"),
		["beamweapons"] = _("stationServices-comms","beam weapons"),
		["missilesystem"] = _("stationServices-comms","missile system"),
		["maneuver"] = _("stationServices-comms","maneuver"),
		["impulse"] = _("stationServices-comms","impulse engines"),
		["warp"] = _("stationServices-comms","warp drive"),
		["jumpdrive"] = _("stationServices-comms","jump drive"),
		["frontshield"] = _("stationServices-comms","front shield"),
		["rearshield"] = _("stationServices-comms","rear shield"),
	}
	pretty_short_system = {
		["reactor"] = _("stationServices-comms","reactor"),
		["beamweapons"] = _("stationServices-comms","beams"),
		["missilesystem"] = _("stationServices-comms","missiles"),
		["maneuver"] = _("stationServices-comms","maneuver"),
		["impulse"] = _("stationServices-comms","impulse"),
		["warp"] = _("stationServices-comms","warp"),
		["jumpdrive"] = _("stationServices-comms","jump"),
		["frontshield"] = _("stationServices-comms","front shield"),
		["rearshield"] = _("stationServices-comms","rear shield"),
	}
end
function initializeSystemList()
	system_list = {"reactor","beamweapons","missilesystem","maneuver","impulse","warp","jumpdrive","frontshield","rearshield"}
end
function initializeUpgradeDowngrade()
	upgrade_price = 3
end
-------------------------------------
--	Docked and undocked functions  --
-------------------------------------
function addStationToDatabase(station)
	--	Assumes all player ships will be the same faction
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
				if out == "" then
					out = string.format(_("scienceDB","General Information: %s"),station.comms_data.general)
				else
					out = string.format(_("scienceDB","%s\n\nGeneral Information: %s"),out,station.comms_data.general)
				end
			end
			if station.comms_data.history ~= nil and station.comms_data.history ~= "" then
				if out == "" then
					out = string.format(_("scienceDB","History: %s"),station.comms_data.history)
				else
					out = string.format(_("scienceDB","%s\n\nHistory: %s"),out,station.comms_data.history)
				end
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
		if station.roving then
			station_db:setKeyValue(location_key,string.format(_("scienceDB","Roving, %s"),station:getFaction()))
		else
			station_db:setKeyValue(location_key,string.format("%s, %s",station:getSectorName(),station:getFaction()))
		end
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
		local secondary_system_repair = {
			{name = "scan_repair",				key = _("scienceDB","Repair scanners")},
			{name = "combat_maneuver_repair",	key = _("scienceDB","Repair combat maneuver")},
			{name = "hack_repair",				key = _("scienceDB","Repair hacking")},
			{name = "probe_launch_repair",		key = _("scienceDB","Repair probe launch")},
			{name = "tube_slow_down_repair",	key = _("scienceDB","Repair slow tube")},
			{name = "self_destruct_repair",		key = _("scienceDB","Repair self destruct")},
		}
		for i,ssr in ipairs(secondary_system_repair) do
			if station.comms_data[ssr.name] then
				if station.comms_data.service_cost[ssr.name] ~= nil then
					local val = string.format(_("scienceDB","%s reputation"),station.comms_data.service_cost[ssr.name])
					station_db:setKeyValue(ssr.key,val)
				end
			end
		end
		if station.comms_data.service_available ~= nil then
			local general_service = {
				{name = "supplydrop",				key = _("scienceDB","Drop supplies")},
				{name = "jumpsupplydrop",			key = _("scienceDB","Jump ship drops supplies")},
				{name = "flingsupplydrop",			key = _("scienceDB","Flinger drops supplies")},
				{name = "reinforcements",			key = _("scienceDB","Standard reinforcements")},
				{name = "hornet_reinforcements",	key = _("scienceDB","Hornet reinforcements")},
				{name = "phobos_reinforcements",	key = _("scienceDB","Phobos reinforcements")},
				{name = "stalker_reinforcements",	key = _("scienceDB","Stalker reinforcements")},
				{name = "amk8_reinforcements",		key = _("scienceDB","Adder8 reinforcements")},
				{name = "activatedefensefleet",		key = _("scienceDB","Activate defense fleet")},
				{name = "servicejonque",			key = _("scienceDB","Provide service jonque")},
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
		if station.comms_data.upgrade_path ~= nil then
			local upgrade_service = {
				["beam"] = _("scienceDB","Beam weapons"),
				["missiles"] = _("scienceDB","Misslie systems"),
				["shield"] = _("scienceDB","Shield"),
				["hull"] = _("scienceDB","Hull"),
				["impulse"] = _("scienceDB","Impulse systems"),
				["ftl"] = _("scienceDB","FTL engines"),
				["sensors"] = _("scienceDB","Sensor systems"),
			}
			for template,upgrade in pairs(station.comms_data.upgrade_path) do
				for u_type, u_blob in pairs(upgrade) do
					local u_key = string.format("%s %s",template,upgrade_service[u_type])
					station_db:setKeyValue(u_key,string.format(_("scienceDB","Max upgrade level: %i"),u_blob.max))
				end
			end
		end
	end
	temp_artifact:destroy()
end
--	Booleans to set outside of this utility to control this utility. Default is false
--		include_major_systems_repair_in_status - set true if you want the status report 
--			to include a list of major systems that can be repaired at the station, eg
--			reactor, impulse, missiles, beams, shields, warp, jump, maneuver
--		include_minor_systems_repair_in_status - set true if you want the status report
--			to include a list of minor systems that can be repaired at the station, eg
--			combat maneuver, hacking, scanning, self destruct, probe launch
--		include_goods_for_sale_in_status - set true if you want the goods that a station
--			sells to appear in the status report
--		upgrade_button_in_status - set true if you want the status report to include a
--			list of systems that can be upgraded, eg beams, missiles, impulse, ftl,
--			shields. Stock player ships don't qualify for upgrades.
--		station_improvement_button_in_status - set true if you want a button to appear
--			showing what systems the station could have improved and what the player needs
--			to do to enable that system, eg, battery charging, hull repair, probe
--			replenishment, different kinds of ordnance replenishment (side quests). You
--			will probably want to also enable stations_sell_goods to complete the
--			side quests
function stationStatusReport()
	if system_list == nil then
		initializeSystemList()
	end
	if good_desc == nil then
		initializeGoodDescription()
	end
	local status_prompts = {
		_("situationReport-comms","Report status"),
		_("situationReport-comms","Report station status"),
		string.format(_("situationReport-comms","Report station %s status"),comms_target:getCallSign()),
		_("situationReport-comms","What is your status?"),
		string.format(_("situationReport-comms","What is the condition of station %s?"),comms_target:getCallSign()),
	}
	addCommsReply(tableSelectRandom(status_prompts), function()
		msg = string.format(_("situationReport-comms","Hull:%s%%"),math.floor(comms_target:getHull() / comms_target:getHullMax() * 100))
		local shields = comms_target:getShieldCount()
		if shields == 1 then
			msg = string.format(_("situationReport-comms","%s\nShield:%s%%"),msg,math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100))
		else
			msg = string.format(_("situationReport-comms","%s\nShields:"),msg)
			for n=0,shields-1 do
				msg = string.format(_("situationReport-comms","%s   %s:%s%%"),msg,n,math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100))
			end
		end
		local improvements = {}
		msg, improvements = catalogImprovements(msg)
		if include_major_systems_repair_in_status then
			system_list_desc = {
				["reactor"] = 		_("situationReport-comms","reactor"),
				["beamweapons"] =	_("situationReport-comms","beam weapons"),
				["missilesystem"] =	_("situationReport-comms","missile system"),
				["maneuver"] =		_("situationReport-comms","maneuver"),
				["impulse"] =		_("situationReport-comms","impulse"),
				["warp"] =			_("situationReport-comms","warp drive"),
				["jumpdrive"] =		_("situationReport-comms","jump drive"),
				["frontshield"] =	_("situationReport-comms","front shield"),
				["rearshield"] =	_("situationReport-comms","rear shield"),
			}
			local major_repairs = _("situationReport-comms","Repair these major systems:")
			for i,system in ipairs(system_list) do
				if comms_target.comms_data.system_repair[system] then
					if major_repairs == _("situationReport-comms","Repair these major systems:") then
						major_repairs = string.format("%s %s",major_repairs,system_list_desc[system])
					else
						major_repairs = string.format("%s, %s",major_repairs,system_list_desc[system])
					end
				end
			end
			if major_repairs ~= _("situationReport-comms","Repair these major systems:") then
				msg = string.format("%s\n%s.",msg,major_repairs)
			end
		end
		if include_minor_systems_repair_in_status then
			local secondary_system_repair_desc = {
				{name = "scan_repair",				desc = _("situationReport-comms","scanners")},
				{name = "combat_maneuver_repair",	desc = _("situationReport-comms","combat maneuver")},
				{name = "hack_repair",				desc = _("situationReport-comms","hacking")},
				{name = "probe_launch_repair",		desc = _("situationReport-comms","probe launch")},
				{name = "tube_slow_down_repair",	desc = _("situationReport-comms","slow tube")},
				{name = "self_destruct_repair",		desc = _("situationReport-comms","self destruct")},
			}
			local minor_repairs = _("situationReport-comms","Repair these minor systems:")
			for i,system in ipairs(secondary_system_repair_desc) do
				if comms_target.comms_data[system.name] then
					if minor_repairs == _("situationReport-comms","Repair these minor systems:") then
						minor_repairs = string.format("%s %s",minor_repairs,system.desc)
					else
						minor_repairs = string.format("%s, %s",minor_repairs,system.desc)
					end
				end
			end
			if minor_repairs ~= _("situationReport-comms","Repair these minor systems:") then
				msg = string.format("%s\n%s.",msg,minor_repairs)
			end
		end
		if include_goods_for_sale_in_status then
			local goods_available = false
			if comms_target.comms_data.goods ~= nil then
				for good, good_data in pairs(comms_target.comms_data.goods) do
					if good_data["quantity"] > 0 then
						goods_available = true
						break
					end
				end
			end
			if goods_available then
				msg = string.format(_("situationReport-comms","%s\nGoods or components available:"),msg)
				for good, good_data in pairs(comms_target.comms_data.goods) do
					if good_data["quantity"] > 0 then
						msg = string.format("%s %s@%s",msg,good_desc[good],good_data["cost"])
					end
				end
			end
		end
		setCommsMessage(msg)
		if upgrade_button_in_status then
			addCommsReply(_("situationReport-comms","Can your station perform upgrades on our ship?"),function()
				if comms_target.comms_data.upgrade_path ~= nil then
					local p_ship_type = comms_source:getTypeName()
					if comms_target.comms_data.upgrade_path[p_ship_type] ~= nil then
						local upgrade_count = 0
						local out = _(_("dockingServicesStatus-comms","We can provide the following upgrades:\n    system: description"))
						for u_type, u_blob in pairs(comms_target.comms_data.upgrade_path[p_ship_type]) do
							local p_upgrade_level = comms_source.upgrade_path[u_type]
							if u_blob.max > p_upgrade_level then
								upgrade_count = upgrade_count + 1
								out = string.format("%s\n        %s: %s",out,u_type,upgrade_path[p_ship_type][u_type][p_upgrade_level + 1].desc)
							end
						end
						if upgrade_count > 0 then
							setCommsMessage(out)
						else
							setCommsMessage(_("dockingServicesStatus-comms","No more ship upgrades available for your ship"))
						end
					else
						setCommsMessage(_("dockingServicesStatus-comms","No ship upgrades available for your ship"))
					end
				else
					setCommsMessage(_("dockingServicesStatus-comms","No ship upgrades available"))
				end
				addCommsReply(_("situationReport-comms","Explain ship upgrade categories"),explainShipUpgrades)
				addCommsReply(_("Back"), commsStation)
			end)
		end
		if station_improvement_button_in_status then
			if #improvements > 0 and (comms_target.comms_data.friendlyness > 33 or comms_source:isDocked(comms_target)) then
				improveStationService(improvements)
			end
		end
		addCommsReply(_("Back"), commsStation)
	end)
end
function explainShipUpgrades()
	setCommsMessage(_("dockingServicesStatus-comms","Which ship system upgrade category are you wondering about?"))
	--upgrade_path explained
	addCommsReply(_("dockingServicesStatus-comms","beam"),function()
		setCommsMessage(_("dockingServicesStatus-comms","Beam upgrades refer to the beam weapons systems. They might include additional beam mounts, longer range, faster recharge or cycle times, increased damage, wider beam firing arcs or faster beam turret rotation speed."))
		addCommsReply(_("dockingServicesStatus-comms","Back to ship upgrade category explanation list"), explainShipUpgrades)
		addCommsReply(_("Back"), commsStation)
	end)
	addCommsReply(_("dockingServicesStatus-comms","missiles"),function()
		setCommsMessage(_("dockingServicesStatus-comms","Missile upgrades refer to aspects of the missile weapons systems. They might include additional tubes, faster tube load times, increased tube size, additional missile types or additional missile storage capacity."))
		addCommsReply(_("dockingServicesStatus-comms","Back to ship upgrade category explanation list"), explainShipUpgrades)
		addCommsReply(_("Back"), commsStation)
	end)
	addCommsReply(_("dockingServicesStatus-comms","shield"),function()
		setCommsMessage(_("dockingServicesStatus-comms","Shield upgrades refer to the protective energy shields around your ship. They might include increased charge capacity (overall strength) for the front, rear or both shield arcs or the addition of a shield arc."))
		addCommsReply(_("dockingServicesStatus-comms","Back to ship upgrade category explanation list"), explainShipUpgrades)
		addCommsReply(_("Back"), commsStation)
	end)
	addCommsReply(_("dockingServicesStatus-comms","hull"),function()
		setCommsMessage(_("dockingServicesStatus-comms","Hull upgrades refer to strengthening the ship hull to withstand more damage in the form of armor plating or structural bolstering."))
		addCommsReply(_("dockingServicesStatus-comms","Back to ship upgrade category explanation list"), explainShipUpgrades)
		addCommsReply(_("Back"), commsStation)
	end)
	addCommsReply(_("dockingServicesStatus-comms","impulse"),function()
		setCommsMessage(_("dockingServicesStatus-comms","Impulse upgrades refer to changes related to the impulse engines. They might include improving the top speed or acceleration (forward, reverse or both), maneuvering speed or combat maneuver (boost, which is moving forward, or strafe, which is sideways motion or both)."))
		addCommsReply(_("dockingServicesStatus-comms","Back to ship upgrade category explanation list"), explainShipUpgrades)
		addCommsReply(_("Back"), commsStation)
	end)
	addCommsReply(_("dockingServicesStatus-comms","ftl"),function()
		setCommsMessage(_("dockingServicesStatus-comms","FTL (short for faster than light) upgrades refer to warp drive or jump drive enhancements. They might include the addition of an ftl drive, a change in the range of the jump drive or an increase in the top speed of the warp drive"))
		addCommsReply(_("dockingServicesStatus-comms","Back to ship upgrade category explanation list"), explainShipUpgrades)
		addCommsReply(_("Back"), commsStation)
	end)
	addCommsReply(_("dockingServicesStatus-comms","sensors"),function()
		setCommsMessage(_("dockingServicesStatus-comms","Sensor upgrades refer to the ship's ability to detect other objects. They might include increased long range sensors, increased short range sensors, automated proximity scanners for ships or improved range for automated proximity scanners."))
		addCommsReply(_("dockingServicesStatus-comms","Back to ship upgrade category explanation list"), explainShipUpgrades)
		addCommsReply(_("Back"), commsStation)
	end)
	addCommsReply(_("Back"), commsStation)
end
--	Booleans to set outside of this utility to control this utility. Default is false
--		include_ordnance_in_status - set this to true if you want ordnance information
--			to appear in the station status report. Default: the information is omitted
function catalogImprovements(msg)
	local improvements = {}
	if msg == nil then
		msg = ""
	end
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
	if include_ordnance_in_status then 
		local provides_some_missiles = false
		local missile_provision_msg = _("situationReport-comms","Ordnance available:")
		local missile_types_desc = {
			{name = "Nuke",		desc = _("situationReport-comms","nukes")},
			{name = "EMP",		desc = _("situationReport-comms","EMPs")},
			{name = "Homing",	desc = _("situationReport-comms","homings")},
			{name = "Mine",		desc = _("situationReport-comms","mines")},
			{name = "HVLI",		desc = _("situationReport-comms","HVLIs")},
		}
		for i,m_type in ipairs(missile_types_desc) do
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
	end
	return msg,improvements	
end
--	Booleans to set outside of this utility to control this utility. Default is false
--		generate_defense_fleet - set true if you want the station to have a defense fleet
--			if one was not already part of the station to begin with
function stationDefenseFleet()
	if comms_target.comms_data.idle_defense_fleet ~= nil then
		local defense_fleet_count = 0
		for name, template in pairs(comms_target.comms_data.idle_defense_fleet) do
			defense_fleet_count = defense_fleet_count + 1
		end
		if defense_fleet_count > 0 then
			local fleet_prompts = {
				string.format(_("station-comms","Activate station defense fleet (%s rep)"),getServiceCost("activatedefensefleet")),
				string.format(_("station-comms","Launch station defense fleet (%s rep)"),getServiceCost("activatedefensefleet")),
				string.format(_("station-comms","Send out station defense fleet (%s rep)"),getServiceCost("activatedefensefleet")),
				string.format(_("station-comms","Launch %s defenders (%s rep)"),comms_target:getCallSign(),getServiceCost("activatedefensefleet")),
				string.format(_("station-comms","Enable %s defenders (%s rep)"),comms_target:getCallSign(),getServiceCost("activatedefensefleet")),
			}
			addCommsReply(tableSelectRandom(fleet_prompts),function()
				if comms_source:takeReputationPoints(getServiceCost("activatedefensefleet")) then
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
						comms_target.comms_data.idle_defense_fleet[name] = nil
					end
					local launched_responses = {
						_("station-comms","Defense fleet activated"),
						_("station-comms","Defenders launched"),
						string.format(_("station-comms","%s defense fleet activated"),comms_target:getCallSign()),
						string.format(_("station-comms","Station %s defenders engaged"),comms_target:getCallSign()),
						string.format(_("station-comms","%s defenders enabled"),comms_target:getCallSign()),
					}
					setCommsMessage(tableSelectRandom(launched_responses))
				else
					local insufficient_rep_responses = {
						_("needRep-comms","Insufficient reputation"),
						_("needRep-comms","Not enough reputation"),
						_("needRep-comms","You need more reputation"),
						string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
						_("needRep-comms","You don't have enough reputation"),
						string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
					}
					setCommsMessage(tableSelectRandom(insufficient_rep_responses))
				end
				addCommsReply(_("Back"), commsStation)
			end)
		end
	else
		if generate_defense_fleet then
			local station_type = comms_target:getTypeName()
			local size_matters = {
				["Small Station"] = -5,
				["Medium Station"] = 0,
				["Large Station"] = 5,
				["Huge Station"] = 10,
			}
			local adjustment = size_matters[station_type]
			comms_target.comms_data.idle_defense_fleet = {["DF1"] =  "MT52 Hornet"}
			if random(1,100) < (95 + adjustment) then
				comms_target.comms_data.idle_defense_fleet["DF2"] = "MU52 Hornet"
				if random(1,100) < (90 + adjustment) then
					comms_target.comms_data.idle_defense_fleet["DF3"] = "Adder MK5"
					if random(1,100) < (85 + adjustment) then
						comms_target.comms_data.idle_defense_fleet["DF4"] = "Phobos T3"
						if random(1,100) < (80 + adjustment) then
							comms_target.comms_data.idle_defense_fleet["DF5"] = "Adder MK8"
							if random(1,100) < (75 + adjustment) then
								comms_target.comms_data.idle_defense_fleet["DF6"] = "Elara P2"
								if random(1,100) < (70 + adjustment) then
									comms_target.comms_data.idle_defense_fleet["DF7"] = "Nirvana R5"
									if random(1,100) < (65 + adjustment) then
										comms_target.comms_data.idle_defense_fleet["DF8"] = "WX-Lindworm"
										if random(1,100) < (60 + adjustment) then
											comms_target.comms_data.idle_defense_fleet["DF9"] = "Adder MK6"
											if random(1,100) < (55 + adjustment) then
												comms_target.comms_data.idle_defense_fleet["DF10"] = "Stalker Q7"
												if random(1,100) < (50 + adjustment) then
													comms_target.comms_data.idle_defense_fleet["DF11"] = "Ktlitan Drone"
													if random(1,100) < (45 + adjustment) then
														comms_target.comms_data.idle_defense_fleet["DF12"] = "Nirvana R5A"
														if random(1,100) < (40 + adjustment) then
															comms_target.comms_data.idle_defense_fleet["DF13"] = "Piranha F8"
															if random(1,100) < (35 + adjustment) then
																comms_target.comms_data.idle_defense_fleet["DF14"] = "Stalker R7"
																if random(1,100) < (30 + adjustment) then
																	comms_target.comms_data.idle_defense_fleet["DF15"] = "Atlantis X23"
																	if random(1,100) < (25 + adjustment) then
																		comms_target.comms_data.idle_defense_fleet["DF16"] = "Piranha F12"
																		if random(1,100) < (20 + adjustment) then
																			comms_target.comms_data.idle_defense_fleet["DF17"] = "Fiend G5"
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
								end
							end
						end
					end
				end
			end
			stationDefenseFleet()
		end
	end
end
function getServiceCost(service)
-- Return the number of reputation points that a specified service costs for
-- the current player.
    return math.ceil(comms_target.comms_data.service_cost[service])
end
--	Booleans to set outside of this utility to control this utility. Default is false
--		stations_sell_goods - set true if stations sell goods to players for reputation
function stellarCartographyBrochure()
	if comms_source:takeReputationPoints(getCartographerCost()) then
		local brochure_description = {
			_("cartographyOffice-comms","The brochure has a list of nearby stations and has a list of goods nearby."),
			_("cartographyOffice-comms","The brochure lists nearby stations and goods."),
			_("cartographyOffice-comms","Nearby stations and goods appear in the brochure."),
			_("cartographyOffice-comms","The brochure lists nearby stations and goods in attractive colors."),
		}
		setCommsMessage(tableSelectRandom(brochure_description))
		local brochure_station_list_prompts = {
			string.format(_("cartographyOffice-comms","Examine station list (%i reputation)"),getCartographerCost()),
			string.format(_("cartographyOffice-comms","Look at station list (%i reputation)"),getCartographerCost()),
			string.format(_("cartographyOffice-comms","Read station list (%i reputation)"),getCartographerCost()),
			string.format(_("cartographyOffice-comms","Check out station list (%i reputation)"),getCartographerCost()),
		}
		addCommsReply(tableSelectRandom(brochure_station_list_prompts), function()
			if comms_source:takeReputationPoints(getCartographerCost()) then
				local brochure_stations = ""
				local sx, sy = comms_target:getPosition()
				local nearby_objects = getObjectsInRadius(sx,sy,30000)
				for i, obj in ipairs(nearby_objects) do
					if obj.typeName == "SpaceStation" then
						if not obj:isEnemy(comms_source) then
							if brochure_stations == "" then
								brochure_stations = string.format(_("cartographyOffice-comms","%s %s %s"),obj:getSectorName(),obj:getFaction(),obj:getCallSign())
							else
								brochure_stations = string.format(_("cartographyOffice-comms","%s\n%s %s %s"),brochure_stations,obj:getSectorName(),obj:getFaction(),obj:getCallSign())
							end
							if obj.comms_data.orbit ~= nil then
								brochure_stations = string.format(_("cartographyOffice-comms","%s %s"),brochure_stations,obj.comms_data.orbit)
							end
						end
					end
				end
				if brochure_stations == "" then
					local no_nearby_stations = {
						_("cartographyOffice-comms","There are no nearby stations"),
						_("cartographyOffice-comms","The brochure lists no nearby stations"),
						_("cartographyOffice-comms","No nearby stations appear in the brochure"),
						_("cartographyOffice-comms","The brochure shows no nearby stations"),
					}
					setCommsMessage(tableSelectRandom(no_nearby_stations))
				else
					setCommsMessage(brochure_stations)
				end
			else
				local insufficient_rep_responses = {
					_("needRep-comms","Insufficient reputation"),
					_("needRep-comms","Not enough reputation"),
					_("needRep-comms","You need more reputation"),
					string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
					_("needRep-comms","You don't have enough reputation"),
					string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
				}
				setCommsMessage(tableSelectRandom(insufficient_rep_responses))
			end
			addCommsReply(_("Back"), commsStation)
		end)
		if stations_sell_goods then
			if good_desc == nil then
				initializeGoodDescription()
			end
			local brochure_goods_list_prompts = {
				string.format(_("cartographyOffice-comms","Examine goods list (%i reputation)"),getCartographerCost()),
				string.format(_("cartographyOffice-comms","Read goods list (%i reputation)"),getCartographerCost()),
				string.format(_("cartographyOffice-comms","Look at goods list (%i reputation)"),getCartographerCost()),
				string.format(_("cartographyOffice-comms","Check out goods list (%i reputation)"),getCartographerCost()),
			}
			addCommsReply(tableSelectRandom(brochure_goods_list_prompts), function()
				if comms_source:takeReputationPoints(getCartographerCost()) then
					local brochure_goods = ""
					local sx, sy = comms_target:getPosition()
					local nearby_objects = getObjectsInRadius(sx,sy,30000)
					for i, obj in ipairs(nearby_objects) do
						if obj.typeName == "SpaceStation" then
							if not obj:isEnemy(comms_target) then
								if obj.comms_data.goods ~= nil then
									for good, good_data in pairs(obj.comms_data.goods) do
										if brochure_goods == "" then
											brochure_goods = string.format(_("cartographyOffice-comms","Good, quantity, cost, station:\n%s, %i, %i, %s"),good_desc[good],good_data["quantity"],good_data["cost"],obj:getCallSign())
										else
											brochure_goods = string.format(_("cartographyOffice-comms","%s\n%s, %i, %i, %s"),brochure_goods,good_desc[good],good_data["quantity"],good_data["cost"],obj:getCallSign())
										end
									end
								end
							end
						end
					end
					if brochure_goods == "" then
						local no_nearby_goods = {
							_("cartographyOffice-comms","There are no nearby goods"),
							_("cartographyOffice-comms","The brochure lists no nearby goods"),
							_("cartographyOffice-comms","No nearby goods appear in the brochure"),
							_("cartographyOffice-comms","The brochure shows no nearby goods"),
						}
						setCommsMessage(tableSelectRandom(no_nearby_goods))
					else
						setCommsMessage(brochure_goods)
					end
				else
					local insufficient_rep_responses = {
						_("needRep-comms","Insufficient reputation"),
						_("needRep-comms","Not enough reputation"),
						_("needRep-comms","You need more reputation"),
						string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
						_("needRep-comms","You don't have enough reputation"),
						string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
					}
					setCommsMessage(tableSelectRandom(insufficient_rep_responses))
				end
				addCommsReply(_("Back"), commsStation)
			end)
		end
	else
		local insufficient_rep_responses = {
			_("needRep-comms","Insufficient reputation"),
			_("needRep-comms","Not enough reputation"),
			_("needRep-comms","You need more reputation"),
			string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
			_("needRep-comms","You don't have enough reputation"),
			string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
		}
		setCommsMessage(tableSelectRandom(insufficient_rep_responses))
	end
end
function getCartographerCost(service)
	local base_cost = 1	--brochure (default)
	if service == "apprentice" then
		if comms_target.comms_data.friendlyness < 33 then
			base_cost = 5
		elseif comms_target.comms_data.friendlyness < 66 then
			base_cost = 3
		end
	elseif service == "master" then
		if comms_target.comms_data.friendlyness < 33 then
			base_cost = 10
		elseif comms_target.comms_data.friendlyness < 66 then
			base_cost = 5
		elseif comms_target.comms_data.friendlyness < 80 then
			base_cost = 3
		elseif comms_target.comms_data.friendlyness < 90 then
			base_cost = 2
		end
	end
	return math.ceil(base_cost * comms_target.comms_data.reputation_cost_multipliers[getFriendStatus()])
end
function getFriendStatus()
    if comms_source:isFriendly(comms_target) then
        return "friend"
    else
        return "neutral"
    end
end
--------------------------
--	Undocked functions  --
--------------------------
--	Booleans to set outside of this utility to control this utility. Default is false
--		snub_if_less_friendly - if station friendliness is greater than 33, interact
--			normally with station relay officer, otherwise use automated station
--			communication. Default is normal relay officer interaction. 
function handleUndockedState()
	local short_range_radar = comms_target:getShortRangeRadarRange()
	local station_greeting_prompt = {
		{thresh = 95,	text = string.format(_("station-comms","This is %s. We read you loud and clear, %s. What's on your mind?"),comms_target:getCallSign(),comms_source:getCallSign())},
		{thresh = 90,	text = string.format(_("station-comms","This is %s's communications officer. Go ahead, %s. We're listening."),comms_target:getCallSign(),comms_source:getCallSign())},
		{thresh = 85,	text = string.format(_("station-comms","Station %s to %s, we have a clear communication connection. Proceed with your message."),comms_target:getCallSign(),comms_source:getCallSign())},
		{thresh = 80,	text = string.format(_("station-comms","%s to %s, receiving your communication. Proceed with your message."),comms_target:getCallSign(),comms_source:getCallSign())},
		{thresh = 75,	text = string.format(_("station-comms","Confirmed, %s. You have successfully connected to %s. Go ahead."),comms_source:getCallSign(),comms_target:getCallSign())},
		{thresh = 70,	text = string.format(_("station-comms","Confirmed, %s. You're connected to %s. Go ahead."),comms_source:getCallSign(),comms_target:getCallSign())},
		{thresh = 65,	text = string.format(_("station-comms","This is the %s communications officer on duty. Go ahead, %s."),comms_target:getCallSign(),comms_source:getCallSign())},
		{thresh = 60,	text = string.format(_("station-comms","This is the %s communications officer. Go ahead, %s."),comms_target:getCallSign(),comms_source:getCallSign())},
		{thresh = 55,	text = string.format(_("station-comms","%s confirms %s's communication connection. Please, don't keep us in suspense any longer."),comms_target:getCallSign(),comms_source:getCallSign())},
		{thresh = 50,	text = string.format(_("station-comms","%s acknowledges %s's communication. Pray, don't keep us in suspense any longer."),comms_target:getCallSign(),comms_source:getCallSign())},
		{thresh = 45,	text = string.format(_("station-comms","%s, it is absolutely thrilling to receive your undoubtably important message. Please enlighten us."),comms_source:getCallSign())},
		{thresh = 40,	text = string.format(_("station-comms","%s, it is positively thrilling to be the recipient of your undoubtably important message. Please enlighten us."),comms_source:getCallSign())},
		{thresh = 35,	text = string.format(_("station-comms","Communication connection acknowledged, %s. Try not to waste our time any more than you already have. What do you want?"),comms_source:getCallSign())},
		{thresh = 30,	text = string.format(_("station-comms","Acknowledged, %s. Try not to waste our time. What do you want?"),comms_source:getCallSign())},
		{thresh = 25,	text = string.format(_("station-comms","What is it, %s? Be quick about it; we're not here simply to chat."),comms_source:getCallSign())},
		{thresh = 20,	text = string.format(_("station-comms","What is it now, %s? Make it quick; we're not here for small talk."),comms_source:getCallSign())},
		{thresh = 15,	text = string.format(_("station-comms","Station %s reluctantly acknowledges your communication connection. Make it snappy, %s."),comms_target:getCallSign(),comms_source:getCallSign())},
		{thresh = 10,	text = string.format(_("station-comms","%s reluctantly acknowledges your communication. Make it snappy, %s."),comms_target:getCallSign(),comms_source:getCallSign())},
		{thresh = 5,	text = string.format(_("station-comms","Channel opened to %s. Briefly summarize your business, %s."),comms_target:getCallSign(),comms_source:getCallSign())},
	}
	local prompt_index = #station_greeting_prompt
	for i,prompt in ipairs(station_greeting_prompt) do
		if comms_target.comms_data.friendlyness > prompt.thresh then
			prompt_index = i
			break
		end
	end
	local prompt_pool = {}
	local lo = prompt_index - 2
	local hi = prompt_index + 2
	if prompt_index >= (#station_greeting_prompt - 2) then
		lo = #station_greeting_prompt - 4
		hi = #station_greeting_prompt
	elseif prompt_index <= 3 then
		lo = 1
		hi = 5
	end
	for i=lo,hi do
		table.insert(prompt_pool,station_greeting_prompt[i])
	end
	local add_on_prompt = tableSelectRandom(prompt_pool)
	local oMsg = string.format(_("station-comms","%s Communications Portal\n%s"),comms_target:getCallSign(),add_on_prompt.text)
	setCommsMessage(oMsg)
	if handleEnemiesInRange == nil then
		if snub_if_less_friendly then
			if comms_target.comms_data.friendlyness > 33 then
				interactiveUndockedStationComms()
			else
				androidUndockedStationComms()
			end
		else
			interactiveUndockedStationComms()
		end
	else
		local no_relay_panic_responses = {
			_("station-comms","No communication officers available due to station emergency."),
			_("station-comms","Relay officers unavailable during station emergency."),
			_("station-comms","Relay officers reassigned for station emergency."),
			_("station-comms","Station emergency precludes response from relay officer."),
		}
		if comms_target:areEnemiesInRange(short_range_radar/2) then
			if comms_target.comms_data.friendlyness > 20 then
				oMsg = string.format(_("station-comms","%s\n%s"),oMsg,tableSelectRandom(no_relay_panic_responses))
				setCommsMessage(oMsg)
			end
			androidUndockedStationComms()
		elseif comms_target:areEnemiesInRange(short_range_radar) then
			if comms_target.comms_data.friendlyness > 75 then
				local quick_relay_responses = {
					_("station-comms","Please be quick. Sensors detect enemies."),
					_("station-comms","I have to go soon since there are enemies nearby."),
					_("station-comms","Talk fast. Enemies approach."),
					_("station-comms","Enemies are coming so talk fast."),
				}
				oMsg = string.format(_("station-comms","%s\n%s"),oMsg,tableSelectRandom(quick_relay_responses))
				interactiveUndockedStationComms()
			else
				if comms_target.comms_data.friendlyness > 40 then
					oMsg = string.format(_("station-comms","%s\n%s"),oMsg,tableSelectRandom(no_relay_panic_responses))
					setCommsMessage(oMsg)
				end
				androidUndockedStationComms()
			end
		elseif comms_target:areEnemiesInRange(short_range_radar*2) then
			if comms_target.comms_data.friendlyness > 33 then
				if comms_target.comms_data.friendlyness > 75 then
					local distracted_units_responses = {
						string.format(_("station-comms","Please forgive us if we seem distracted. Our sensors detect enemies within %i units"),math.floor(short_range_radar*2/1000)),
						string.format(_("station-comms","Enemies at %i units. Things might get busy soon. Business?"),math.floor(short_range_radar*2/1000)),
						string.format(_("station-comms","A busy day here at %s: Enemies are %s units away and my boss is reviewing emergency procedures. I'm a bit distracted."),comms_target:getCallSign(),math.floor(short_range_radar*2/1000)),
						string.format(_("station-comms","If I seem distracted, it's only because of the enemies showing up at %i units."),math.floor(short_range_radar*2/1000)),
					}
					oMsg = string.format(_("station-comms","%s\n%s"),oMsg,tableSelectRandom(distracted_units_responses))
					setCommsMessage(oMsg)
				elseif comms_target.comms_data.friendlyness > 50 then
					local distracted_responses = {
						_("station-comms","Please forgive us if we seem distracted. Our sensors detect enemies nearby."),
						string.format(_("station-comms","Enemies are close to %s. We might get busy. Business?"),comms_target:getCallSign()),
						_("station-comms","We're quite busy preparing for enemies: evaluating cross training, checking emergency procedures, etc. I'm a little distracted."),
						string.format(_("station-comms","%s is likely going to be attacked soon. Everyone is running around getting ready, distracting me."),comms_target:getCallSign()),
					}
					oMsg = string.format(_("station-comms","%s\n%s"),oMsg,tableSelectRandom(distracted_responses))
					setCommsMessage(oMsg)
				end
				interactiveUndockedStationComms()
			else
				androidUndockedStationComms()
			end
		else
			if snub_if_less_friendly then
				if comms_target.comms_data.friendlyness > 33 then
					interactiveUndockedStationComms()
				else
					androidUndockedStationComms()
				end
			else
				interactiveUndockedStationComms()
			end
		end
	end	
end
--	Booleans to set outside of this utility to control this utility. Default is false
--		current_orders_button - set true if players can check with stations to get their
--			current orders.
--		defense_fleet_button - set true if players can launch station defense fleet
function androidUndockedStationComms()
	addCommsReply(_("station-comms","Automated station communication"),function()
		setCommsMessage(_("station-comms","Select:"))
		stationStatusReport()
		if current_orders_button then
			if comms_target:isFriendly(comms_source) then
				getCurrentOrders()
			end
		end
		if defense_fleet_button then
			if isAllowedTo(comms_target.comms_data.services.activatedefensefleet) then
				stationDefenseFleet()
			end
		end
		if isAllowedTo(comms_target.comms_data.services.reinforcements) then
			requestReinforcements()
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
--	Booleans to set outside of this utility to control this utility. Default is false
--		current_orders_button - set true if players can check with stations to get their
--			current orders.
--		defense_fleet_button - set true if players can launch station defense fleet
--		service_jonque_button - set true if players can request a service jonque. This
--			functionality requires additions to the update function
--		expedite_dock_button - set true if players can request an expedited dock. This 
--			functionality requires additions to the update function
--		stellar_cartography_button - set true if stations support stellar cartography
--		stations_sell_goods - set true if stations sell goods to players for reputation
--		stations_buy_goods - set true if stations buy goods from players for reputation
--		stations_trade_goods - set true if station will trade one good for another
--			Note: trade usually does not work well unless at least sell is enabled
--		stations_support_transport_missions - set true if stations handle transport missions
--		stations_support_cargo_missions - set true if stations handle cargo missions
--			Note: cargo missions usually require transport missions
--	Functions you may want to set up outside of this utility
--		scenarioMissionsUndocked - This allows the scenario writer to add situational 
--			comms options to interactive undocked station comms for the scenario
function interactiveUndockedStationComms()
	stationStatusReport()
	if current_orders_button then
		if comms_target:isFriendly(comms_source) then
			getCurrentOrders()
		elseif comms_target.comms_data.friendlyness > 80 then
			getCurrentOrders()
		end
	end
	if scenarioMissionsUndocked ~= nil then
		scenarioMissionsUndocked()
	end
	if defense_fleet_button then
		if isAllowedTo(comms_target.comms_data.services.activatedefensefleet) then
			stationDefenseFleet()
		end
	end
	requestSupplyDrop()
	if isAllowedTo(comms_target.comms_data.services.reinforcements) then
		requestReinforcements()
	end
	if service_jonque_button then
		if comms_target.comms_data.service_available ~= nil then
			if comms_target.comms_data.service_available.servicejonque ~= nil and comms_target.comms_data.service_available.servicejonque then
				requestJonque()
			end
		end
	end
	if expedite_dock_button then
		if comms_target:isFriendly(comms_source) and comms_target.comms_data.friendlyness > 33 then
			requestExpediteDock()
		elseif not comms_target:isEnemy(comms_source) and comms_target.comms_data.friendlyness > 66 then
			requestExpediteDock()
		end
	end
	if stations_sell_goods or stations_buy_goods or stations_trade_goods or stations_support_transport_missions or stations_support_cargo_missions then
		if comms_target.comms_data.friendlyness > 50 then
			commercialOptions()
		end
	end
	if stellar_cartography_button then
		local virtual_stellar_cartography_prompts = {
			string.format(_("station-comms","Access virtual stellar cartography brochure (%i rep)"),getCartographerCost()),
			string.format(_("station-comms","Examine virtual stellar cartography brochure (%i rep)"),getCartographerCost()),
			string.format(_("station-comms","Check out virtual stellar cartography brochure (%i rep)"),getCartographerCost()),
			string.format(_("station-comms","Read virtual stellar cartography brochure (%i rep)"),getCartographerCost()),
		}
		addCommsReply(tableSelectRandom(virtual_stellar_cartography_prompts),stellarCartographyBrochure)
	end
	addCommsReply(_("Back"), commsStation)
end
function requestReinforcements()
	local send_reinforcements_prompt = {
		_("stationAssist-comms","Send reinforcements"),
		_("stationAssist-comms","Request friendly warship"),
		_("stationAssist-comms","Send military help"),
		_("stationAssist-comms","Get a ship to help us"),
	}
	addCommsReply(tableSelectRandom(send_reinforcements_prompt),function()
		commsStationReinforcements()
	end)
end
--	Functions you may want to set up outside of this utility
--		scenarioReinforcements - a function where the scenario writer can insert comms
--			to request reinforcements not normally available
function commsStationReinforcements()
	local reinforcement_type = {
		_("stationAssist-comms","What kind of reinforcement ship?"),
		_("stationAssist-comms","What kind of ship should we send?"),
		_("stationAssist-comms","Specify ship type"),
		_("stationAssist-comms","Identify desired type of ship"),
	}
	setCommsMessage(tableSelectRandom(reinforcement_type))
	--	set costs if not already set
	if comms_target.comms_data.service_cost == nil then
		comms_target.comms_data.service_cost = {}
	end
	if comms_target.comms_data.service_cost.amk3_reinforcements == nil then
		comms_target.comms_data.service_cost.amk3_reinforcements = math.random(75,125)
	end
	if comms_target.comms_data.service_cost.hornet_reinforcements == nil then
		comms_target.comms_data.service_cost.hornet_reinforcements = math.random(75,125)
	end
	if comms_target.comms_data.service_cost.reinforcements == nil then
		comms_target.comms_data.service_cost.reinforcements = math.random(140,160)
	end
	if comms_target.comms_data.service_cost.amk8_reinforcements == nil then
		comms_target.comms_data.service_cost.amk8_reinforcements = math.random(150,200)
	end
	if comms_target.comms_data.service_cost.phobos_reinforcements == nil then
		comms_target.comms_data.service_cost.phobos_reinforcements = math.random(175,225)
	end
	if comms_target.comms_data.service_cost.stalker_reinforcements == nil then
		comms_target.comms_data.service_cost.stalker_reinforcements = math.random(275,325)
	end
	--	set availability if not already set
	if comms_target.comms_data.service_available == nil then
		comms_target.comms_data.service_available = {}
	end
	if comms_target.comms_data.service_available.amk3_reinforcements == nil then
		comms_target.comms_data.service_available.amk3_reinforcements = random(1,100) < 72
	end
	if comms_target.comms_data.service_available.hornet_reinforcements == nil then
		comms_target.comms_data.service_available.hornet_reinforcements = random(1,100) < 72
	end
	if comms_target.comms_data.service_available.reinforcements == nil then
		comms_target.comms_data.service_available.reinforcements = true
	end
	if comms_target.comms_data.service_available.amk8_reinforcements == nil then
		comms_target.comms_data.service_available.amk8_reinforcements = random(1,100) < 72
	end
	if comms_target.comms_data.service_available.phobos_reinforcements == nil then
		comms_target.comms_data.service_available.phobos_reinforcements = random(1,100) < 72
	end
	if comms_target.comms_data.service_available.stalker_reinforcements == nil then
		comms_target.comms_data.service_available.stalker_reinforcements = random(1,100) < 72
	end
	local reinforcement_info = {
		{desc = _("stationAssist-comms","Adder MK3"),			template = "Adder MK3",		threshold = 20,	cost = math.ceil(comms_target.comms_data.service_cost.amk3_reinforcements),		avail = comms_target.comms_data.service_available.amk3_reinforcements},
		{desc = _("stationAssist-comms","MU52 Hornet"),			template = "MU52 Hornet",	threshold = 50,	cost = math.ceil(comms_target.comms_data.service_cost.hornet_reinforcements),	avail = comms_target.comms_data.service_available.hornet_reinforcements},
		{desc = _("stationAssist-comms","Standard Adder MK5"),	template = "Adder MK5",		threshold = 0,	cost = math.ceil(comms_target.comms_data.service_cost.reinforcements),			avail = comms_target.comms_data.service_available.reinforcements},
		{desc = _("stationAssist-comms","Adder MK8"),			template = "Adder MK8",		threshold = 33,	cost = math.ceil(comms_target.comms_data.service_cost.amk8_reinforcements),		avail = comms_target.comms_data.service_available.amk8_reinforcements},
		{desc = _("stationAssist-comms","Phobos T3"),			template = "Phobos T3",		threshold = 66,	cost = math.ceil(comms_target.comms_data.service_cost.phobos_reinforcements),	avail = comms_target.comms_data.service_available.phobos_reinforcements},
		{desc = _("stationAssist-comms","Stalker R7"),			template = "Stalker R7",	threshold = 70,	cost = math.ceil(comms_target.comms_data.service_cost.stalker_reinforcements),	avail = comms_target.comms_data.service_available.stalker_reinforcements},
	}
	local avail_count = 0
	for i, info in ipairs(reinforcement_info) do
		if info.avail and comms_target.comms_data.friendlyness > info.threshold then
			avail_count = avail_count + 1
			addCommsReply(string.format(_("stationAssist-comms","%s (%d reputation)"),info.desc,info.cost), function()
				if comms_source:getWaypointCount() < 1 then
					local set_reinforcement_waypoint = {
						_("stationAssist-comms","You need to set a waypoint before you can request reinforcements."),
						_("stationAssist-comms","Set a waypoint so that we can direct your reinforcements."),
						_("stationAssist-comms","Reinforcements require a waypoint as a destination."),
						_("stationAssist-comms","Before requesting reinforcements, you need to set a waypoint."),
					}
					setCommsMessage(tableSelectRandom(set_reinforcement_waypoint))
				else
					local direct_to_what_waypoint = {
						_("stationAssist-comms","To which waypoint should we dispatch the reinforcements?"),
						_("stationAssist-comms","Where should we send the reinforcements?"),
						_("stationAssist-comms","Specify reinforcement rendezvous waypoint"),
						_("stationAssist-comms","Where should the reinforcements go?"),
					}
					setCommsMessage(tableSelectRandom(direct_to_what_waypoint))
					for n = 1, comms_source:getWaypointCount() do
						addCommsReply(string.format(_("stationAssist-comms", "Waypoint %d"), n),function()
							if comms_source:takeReputationPoints(info.cost) then
								local ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate(info.template):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
								suffix_index = math.random(11,77)
								ship:setCallSign(generateCallSign(nil,comms_target:getFaction()))
								local sent_reinforcements = {
									string.format(_("stationAssist-comms","We have dispatched %s to assist at waypoint %s"),ship:getCallSign(),n),
									string.format(_("stationAssist-comms","%s is heading for waypoint %s"),ship:getCallSign(),n),
									string.format(_("stationAssist-comms","%s has been sent to waypoint %s"),ship:getCallSign(),n),
									string.format(_("stationAssist-comms","We ordered %s to help at waypoint %s"),ship:getCallSign(),n),
								}
								setCommsMessage(tableSelectRandom(sent_reinforcements))
							else
								local insufficient_rep_responses = {
									_("needRep-comms","Insufficient reputation"),
									_("needRep-comms","Not enough reputation"),
									_("needRep-comms","You need more reputation"),
									string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
									_("needRep-comms","You don't have enough reputation"),
									string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
								}
								setCommsMessage(tableSelectRandom(insufficient_rep_responses))
							end
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end
	if scenarioReinforcements ~= nil then
		--return the count of reinforcements available
		local returned_count = scenarioReinforcements()
		if returned_count ~= nil then
			avail_count = avail_count + returned_count
		end
	end
	if avail_count < 1 then
		local insufficient_reinforcements = {
			_("stationAssist-comms","No reinforcements available"),
			_("stationAssist-comms","We don't have any reinforcements"),
			_("stationAssist-comms","No military ships in our inventory, sorry"),
			_("stationAssist-comms","Reinforcements unavailable"),
		}
		setCommsMessage(tableSelectRandom(insufficient_reinforcements))
	end
	addCommsReply(_("Back"), commsStation)
end
--	Booleans to set outside of this utility to control this utility. Default is false
--		jump_ship_supply_drops - set true if stations can send jump ships for supply drops
--		flinger_supply_drops - set true if stations can fling supply drops
--		add_repair_crew - set true if players can get more repair crew from stations
--		add_coolant - set true if players can get more coolant from stations
function requestSupplyDrop()
	local supply_drop_request = {
		_("stationAssist-comms","Request supply drop"),
		_("stationAssist-comms","We need some supplies delivered"),
		_("stationAssist-comms","Could you drop us some supplies?"),
		_("stationAssist-comms","We could really use a supply drop"),
	}
	addCommsReply(tableSelectRandom(supply_drop_request),function()
		local supply_drop_type = {
			_("stationAssist-comms","What kind of supply drop would you like?"),
			_("stationAssist-comms","Supply drop type?"),
			_("stationAssist-comms","In what way would you like your supplies delivered?"),
			_("stationAssist-comms","Supply drop method?"),
		}
		setCommsMessage(tableSelectRandom(supply_drop_type))
		local supply_drop_cost = math.ceil(getServiceCost("supplydrop"))
		local normal_drop_cost = {
			string.format(_("stationAssist-comms","Normal (%i reputation)"),supply_drop_cost),
			string.format(_("stationAssist-comms","Regular (%i reputation)"),supply_drop_cost),
			string.format(_("stationAssist-comms","Plain (%i reputation)"),supply_drop_cost),
			string.format(_("stationAssist-comms","Simple (%i reputation)"),supply_drop_cost),
		}
		addCommsReply(tableSelectRandom(normal_drop_cost),function()
			if comms_source:getWaypointCount() < 1 then
				local set_supply_waypoint = {
					_("stationAssist-comms","You need to set a waypoint before you can request supplies."),
					_("stationAssist-comms","Set a waypoint so that we can place your supplies."),
					_("stationAssist-comms","Supplies require a waypoint as a target."),
					_("stationAssist-comms","Before requesting supplies, you need to set a waypoint."),
				}
				setCommsMessage(tableSelectRandom(set_supply_waypoint))
			else
				local point_supplies = {
					_("stationAssist-comms","To which waypoint should we deliver your supplies?"),
					_("stationAssist-comms","Identify the supply delivery waypoint"),
					_("stationAssist-comms","Where do you want your supplies?"),
					_("stationAssist-comms","Where do the supplies go?"),
				}
				setCommsMessage(tableSelectRandom(point_supplies))
				for n=1,comms_source:getWaypointCount() do
					addCommsReply(string.format(_("stationAssist-comms","Waypoint %i"),n), function()
						if comms_source:takeReputationPoints(getServiceCost("supplydrop")) then
							local position_x, position_y = comms_target:getPosition()
							local target_x, target_y = comms_source:getWaypoint(n)
							local script = Script()
							script:setVariable("position_x", position_x):setVariable("position_y", position_y)
							script:setVariable("target_x", target_x):setVariable("target_y", target_y)
							script:setVariable("faction_id", comms_target:getFactionId()):run("supply_drop.lua")
							local supply_ship_en_route = {
								string.format(_("stationAssist-comms","We have dispatched a supply ship toward waypoint %d"),n),
								string.format(_("stationAssist-comms","We sent a supply ship to waypoint %i"),n),
								string.format(_("stationAssist-comms","There's a ship headed for %i with your supplies"),n),
								string.format(_("stationAssist-comms","A ship should be arriving soon at waypoint %i with your supplies"),n)
							}
							setCommsMessage(tableSelectRandom(supply_ship_en_route))
						else
							local insufficient_rep_responses = {
								_("needRep-comms","Insufficient reputation"),
								_("needRep-comms","Not enough reputation"),
								_("needRep-comms","You need more reputation"),
								string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
								_("needRep-comms","You don't have enough reputation"),
								string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
							}
							setCommsMessage(tableSelectRandom(insufficient_rep_responses))
						end
						addCommsReply(_("Back"), commsStation)
					end)
				end
			end
			addCommsReply(_("Back"), commsStation)
		end)
		if jump_ship_supply_drops then
			if comms_target.comms_data.friendlyness > 20 then
				local jump_drop_cost = {
					string.format(_("stationAssist-comms","Delivered by jump ship (%d reputation)"),getServiceCost("jumpsupplydrop")),
					string.format(_("stationAssist-comms","Jump ship drop (%i reputation)"),getServiceCost("jumpsupplydrop")),
					string.format(_("stationAssist-comms","Deliver with jump ship (%i reputation)"),getServiceCost("jumpsupplydrop")),
					string.format(_("stationAssist-comms","Jump ship supply drop (%i reputation)"),getServiceCost("jumpsupplydrop")),
				}
				addCommsReply(tableSelectRandom(jump_drop_cost),function()
					if comms_source:getWaypointCount() < 1 then
						local set_supply_waypoint = {
							_("stationAssist-comms","You need to set a waypoint before you can request supplies."),
							_("stationAssist-comms","Set a waypoint so that we can place your supplies."),
							_("stationAssist-comms","Supplies require a waypoint as a target."),
							_("stationAssist-comms","Before requesting supplies, you need to set a waypoint."),
						}
						setCommsMessage(tableSelectRandom(set_supply_waypoint))
					else
						local point_supplies = {
							_("stationAssist-comms","To which waypoint should we deliver your supplies?"),
							_("stationAssist-comms","Identify the supply delivery waypoint"),
							_("stationAssist-comms","Where do you want your supplies?"),
							_("stationAssist-comms","Where do the supplies go?"),
						}
						setCommsMessage(tableSelectRandom(point_supplies))
						for n=1,comms_source:getWaypointCount() do
							addCommsReply(string.format(_("stationAssist-comms","Waypoint %i"),n), function()
								if comms_source:takeReputationPoints(getServiceCost("jumpsupplydrop")) then
									local position_x, position_y = comms_target:getPosition()
									local target_x, target_y = comms_source:getWaypoint(n)
									local script = Script()
									script:setVariable("position_x", position_x):setVariable("position_y", position_y)
									script:setVariable("target_x", target_x):setVariable("target_y", target_y)
									script:setVariable("jump_freighter","yes")
									script:setVariable("faction_id", comms_target:getFactionId()):run("supply_drop.lua")
									local supply_ship_en_route = {
										string.format(_("stationAssist-comms","We have dispatched a supply ship with a jump drivetoward waypoint %d"),n),
										string.format(_("stationAssist-comms","We sent a supply ship with a jump drive to waypoint %i"),n),
										string.format(_("stationAssist-comms","There's a ship with a jump drive headed for %i with your supplies"),n),
										string.format(_("stationAssist-comms","A jump ship should be arriving soon at waypoint %i with your supplies"),n)
									}
									setCommsMessage(tableSelectRandom(supply_ship_en_route))
								else
									local insufficient_rep_responses = {
										_("needRep-comms","Insufficient reputation"),
										_("needRep-comms","Not enough reputation"),
										_("needRep-comms","You need more reputation"),
										string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
										_("needRep-comms","You don't have enough reputation"),
										string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
									}
									setCommsMessage(tableSelectRandom(insufficient_rep_responses))
								end
								addCommsReply(_("Back"), commsStation)
							end)
						end
					end
					addCommsReply(_("Back"), commsStation)
				end)
			end
		end
		if flinger_supply_drops then
			if comms_target.comms_data.friendlyness > 66 then
				local flinger_drop_cost = {
					string.format(_("stationAssist-comms","Delivered by flinger (%d reputation)"),getServiceCost("flingsupplydrop")),
					string.format(_("stationAssist-comms","Flinger drop (%i reputation)"),getServiceCost("flingsupplydrop")),
					string.format(_("stationAssist-comms","Flinger supply drop (%i reputation)"),getServiceCost("flingsupplydrop")),
					string.format(_("stationAssist-comms","Fling supplies to the drop point (%i reputation)"),getServiceCost("flingsupplydrop")),
				}
				addCommsReply(tableSelectRandom(flinger_drop_cost),function()
					local add_supplies_prompt = {
						_("stationAssist-comms","Do you want the standard 500 energy, 1 nuke, 4 homings, 2 mines, 1 EMP supply package or would you like to add something?"),
						_("stationAssist-comms","Would you like the standard package (500 energy, 1 nuke, 4 homings, 2 mines, 1 EMP) or would you like to add something?"),
						_("stationAssist-comms","Add to standard package (500 energy, 1 nuke, 4 homings, 2 mines, 1 EMP) or not?"),
						_("stationAssist-comms","Standard supply package (500 energy, 1 nuke, 4 homings, 2 mines, 1 EMP) or more?"),
					}
					setCommsMessage(tableSelectRandom(add_supplies_prompt))
					local standard_only = {
						string.format(_("stationAssist-comms","Standard (%d reputation, no change)"),getServiceCost("flingsupplydrop")),
						string.format(_("stationAssist-comms","Just the standard package (%i reputation)"),getServiceCost("flingsupplydrop")),
						string.format(_("stationAssist-comms","Standard only (%s reputation)"),getServiceCost("flingsupplydrop")),
						string.format(_("stationAssist-comms","Standard package alone (%s reputation)"),getServiceCost("flingsupplydrop")),
					}
					addCommsReply(tableSelectRandom(standard_only),function()
						if comms_source:getWaypointCount() < 1 then
							local set_supply_waypoint = {
								_("stationAssist-comms","You need to set a waypoint before you can request supplies."),
								_("stationAssist-comms","Set a waypoint so that we can place your supplies."),
								_("stationAssist-comms","Supplies require a waypoint as a target."),
								_("stationAssist-comms","Before requesting supplies, you need to set a waypoint."),
							}
							setCommsMessage(tableSelectRandom(set_supply_waypoint))
						else
							local point_supplies = {
								_("stationAssist-comms","To which waypoint should we deliver your supplies?"),
								_("stationAssist-comms","Identify the supply delivery waypoint"),
								_("stationAssist-comms","Where do you want your supplies?"),
								_("stationAssist-comms","Where do the supplies go?"),
							}
							setCommsMessage(tableSelectRandom(point_supplies))
							for n=1,comms_source:getWaypointCount() do
								addCommsReply(string.format(_("stationAssist-comms","Waypoint %i"),n), function()
									if comms_source:takeReputationPoints(getServiceCost("flingsupplydrop")) then
										local target_x, target_y = comms_source:getWaypoint(n)
										local target_angle = random(0,360)
										local flinger_miss = random(100,5000)
										local landing_x, landing_y = vectorFromAngleNorth(target_angle,flinger_miss)
										local sd = SupplyDrop():setFactionId(comms_target:getFactionId()):setPosition(target_x + landing_x, target_y + landing_y):setEnergy(500):setWeaponStorage("Nuke", 1):setWeaponStorage("Homing", 4):setWeaponStorage("Mine", 2):setWeaponStorage("EMP", 1)
										local supply_location = {
											string.format(_("stationAssist-comms","Supplies delivered %.1f units from waypoint, bearing %.1f."),flinger_miss/1000,target_angle),
											string.format(_("stationAssist-comms","Supplies have been launched. You can find them %.1f units from waypoint %i on bearing %.1f"),flinger_miss/1000,n,target_angle),
											string.format(_("stationAssist-comms","Our flinger has launched your supplies at waypoint %i. Look for them at %.1f units from waypoint, bearing %.1f"),n,flinger_miss/1000,target_angle),
											string.format(_("stationAssist-comms","Flung. Find supplies %.1f units from waypoint %i on bearing %.1f"),flinger_miss/1000,n,target_angle),
										}
										setCommsMessage(tableSelectRandom(supply_location))
									else
										local insufficient_rep_responses = {
											_("needRep-comms","Insufficient reputation"),
											_("needRep-comms","Not enough reputation"),
											_("needRep-comms","You need more reputation"),
											string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
											_("needRep-comms","You don't have enough reputation"),
											string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
										}
										setCommsMessage(tableSelectRandom(insufficient_rep_responses))
									end
								end)
							end
						end
					end)
					addCommsReply(string.format(_("stationAssist-comms","Add HVLIs (%d rep + %d rep = %d rep)"),getServiceCost("flingsupplydrop"),getWeaponCost("HVLI")*5,getServiceCost("flingsupplydrop") + (getWeaponCost("HVLI")*5)),function()
						if comms_source:getWaypointCount() < 1 then
							local set_supply_waypoint = {
								_("stationAssist-comms","You need to set a waypoint before you can request supplies."),
								_("stationAssist-comms","Set a waypoint so that we can place your supplies."),
								_("stationAssist-comms","Supplies require a waypoint as a target."),
								_("stationAssist-comms","Before requesting supplies, you need to set a waypoint."),
							}
							setCommsMessage(tableSelectRandom(set_supply_waypoint))
						else
							local point_supplies = {
								_("stationAssist-comms","To which waypoint should we deliver your supplies?"),
								_("stationAssist-comms","Identify the supply delivery waypoint"),
								_("stationAssist-comms","Where do you want your supplies?"),
								_("stationAssist-comms","Where do the supplies go?"),
							}
							setCommsMessage(tableSelectRandom(point_supplies))
							for n=1,comms_source:getWaypointCount() do
								addCommsReply(string.format(_("stationAssist-comms","Waypoint %i"),n), function()
									if comms_source:takeReputationPoints(getServiceCost("flingsupplydrop") + (getWeaponCost("HVLI")*5)) then
										local target_x, target_y = comms_source:getWaypoint(n)
										local target_angle = random(0,360)
										local flinger_miss = random(100,5000)
										local landing_x, landing_y = vectorFromAngleNorth(target_angle,flinger_miss)
										local sd = SupplyDrop():setFactionId(comms_target:getFactionId()):setPosition(target_x + landing_x, target_y + landing_y):setEnergy(500):setWeaponStorage("HVLI",5):setWeaponStorage("Nuke", 1):setWeaponStorage("Homing", 4):setWeaponStorage("Mine", 2):setWeaponStorage("EMP", 1)
										local supply_location = {
											string.format(_("stationAssist-comms","Supplies delivered %.1f units from waypoint, bearing %.1f."),flinger_miss/1000,target_angle),
											string.format(_("stationAssist-comms","Supplies have been launched. You can find them %.1f units from waypoint %i on bearing %.1f"),flinger_miss/1000,n,target_angle),
											string.format(_("stationAssist-comms","Our flinger has launched your supplies at waypoint %i. Look for them at %.1f units from waypoint, bearing %.1f"),n,flinger_miss/1000,target_angle),
											string.format(_("stationAssist-comms","Flung. Find supplies %.1f units from waypoint %i on bearing %.1f"),flinger_miss/1000,n,target_angle),
										}
										setCommsMessage(tableSelectRandom(supply_location))
									else
										local insufficient_rep_responses = {
											_("needRep-comms","Insufficient reputation"),
											_("needRep-comms","Not enough reputation"),
											_("needRep-comms","You need more reputation"),
											string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
											_("needRep-comms","You don't have enough reputation"),
											string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
										}
										setCommsMessage(tableSelectRandom(insufficient_rep_responses))
									end
								end)
							end
						end
					end)
					addCommsReply(string.format(_("stationAssist-comms","Add hull repair (%d rep + %d rep = %d rep)"),getServiceCost("flingsupplydrop"),100,getServiceCost("flingsupplydrop") + 100),function()
						if comms_source:getWaypointCount() < 1 then
							local set_supply_waypoint = {
								_("stationAssist-comms","You need to set a waypoint before you can request supplies."),
								_("stationAssist-comms","Set a waypoint so that we can place your supplies."),
								_("stationAssist-comms","Supplies require a waypoint as a target."),
								_("stationAssist-comms","Before requesting supplies, you need to set a waypoint."),
							}
							setCommsMessage(tableSelectRandom(set_supply_waypoint))
						else
							local point_supplies = {
								_("stationAssist-comms","To which waypoint should we deliver your supplies?"),
								_("stationAssist-comms","Identify the supply delivery waypoint"),
								_("stationAssist-comms","Where do you want your supplies?"),
								_("stationAssist-comms","Where do the supplies go?"),
							}
							setCommsMessage(tableSelectRandom(point_supplies))
							for n=1,comms_source:getWaypointCount() do
								addCommsReply(string.format(_("stationAssist-comms","Waypoint %i"),n), function()
									if comms_source:takeReputationPoints(getServiceCost("flingsupplydrop") + 100) then
										local target_x, target_y = comms_source:getWaypoint(n)
										local target_angle = random(0,360)
										local flinger_miss = random(100,5000)
										local landing_x, landing_y = vectorFromAngleNorth(target_angle,flinger_miss)
										local sd = SupplyDrop():setFactionId(comms_target:getFactionId()):setPosition(target_x + landing_x, target_y + landing_y):setEnergy(500):setWeaponStorage("Nuke", 1):setWeaponStorage("Homing", 4):setWeaponStorage("Mine", 2):setWeaponStorage("EMP", 1)
										sd:onPickUp(function(self,player)
											string.format("")
											player:setHull(player:getHullMax())
										end)
										local supply_location = {
											string.format(_("stationAssist-comms","Supplies delivered %.1f units from waypoint, bearing %.1f."),flinger_miss/1000,target_angle),
											string.format(_("stationAssist-comms","Supplies have been launched. You can find them %.1f units from waypoint %i on bearing %.1f"),flinger_miss/1000,n,target_angle),
											string.format(_("stationAssist-comms","Our flinger has launched your supplies at waypoint %i. Look for them at %.1f units from waypoint, bearing %.1f"),n,flinger_miss/1000,target_angle),
											string.format(_("stationAssist-comms","Flung. Find supplies %.1f units from waypoint %i on bearing %.1f"),flinger_miss/1000,n,target_angle),
										}
										setCommsMessage(tableSelectRandom(supply_location))
									else
										local insufficient_rep_responses = {
											_("needRep-comms","Insufficient reputation"),
											_("needRep-comms","Not enough reputation"),
											_("needRep-comms","You need more reputation"),
											string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
											_("needRep-comms","You don't have enough reputation"),
											string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
										}
										setCommsMessage(tableSelectRandom(insufficient_rep_responses))
									end
								end)
							end
						end
					end)
					addCommsReply(string.format(_("stationAssist-comms","Add probes (%d rep + %d rep = %d rep)"),getServiceCost("flingsupplydrop"),20,getServiceCost("flingsupplydrop") + 20),function()
						if comms_source:getWaypointCount() < 1 then
							local set_supply_waypoint = {
								_("stationAssist-comms","You need to set a waypoint before you can request supplies."),
								_("stationAssist-comms","Set a waypoint so that we can place your supplies."),
								_("stationAssist-comms","Supplies require a waypoint as a target."),
								_("stationAssist-comms","Before requesting supplies, you need to set a waypoint."),
							}
							setCommsMessage(tableSelectRandom(set_supply_waypoint))
						else
							local point_supplies = {
								_("stationAssist-comms","To which waypoint should we deliver your supplies?"),
								_("stationAssist-comms","Identify the supply delivery waypoint"),
								_("stationAssist-comms","Where do you want your supplies?"),
								_("stationAssist-comms","Where do the supplies go?"),
							}
							setCommsMessage(tableSelectRandom(point_supplies))
							for n=1,comms_source:getWaypointCount() do
								addCommsReply(string.format(_("stationAssist-comms","Waypoint %i"),n), function()
									if comms_source:takeReputationPoints(getServiceCost("flingsupplydrop") + 20) then
										local target_x, target_y = comms_source:getWaypoint(n)
										local target_angle = random(0,360)
										local flinger_miss = random(100,5000)
										local landing_x, landing_y = vectorFromAngleNorth(target_angle,flinger_miss)
										local sd = SupplyDrop():setFactionId(comms_target:getFactionId()):setPosition(target_x + landing_x, target_y + landing_y):setEnergy(500):setWeaponStorage("Nuke", 1):setWeaponStorage("Homing", 4):setWeaponStorage("Mine", 2):setWeaponStorage("EMP", 1)
										sd:onPickUp(function(self,player)
											string.format("")
											player:setScanProbeCount(player:getMaxScanProbeCount())
										end)
										local supply_location = {
											string.format(_("stationAssist-comms","Supplies delivered %.1f units from waypoint, bearing %.1f."),flinger_miss/1000,target_angle),
											string.format(_("stationAssist-comms","Supplies have been launched. You can find them %.1f units from waypoint %i on bearing %.1f"),flinger_miss/1000,n,target_angle),
											string.format(_("stationAssist-comms","Our flinger has launched your supplies at waypoint %i. Look for them at %.1f units from waypoint, bearing %.1f"),n,flinger_miss/1000,target_angle),
											string.format(_("stationAssist-comms","Flung. Find supplies %.1f units from waypoint %i on bearing %.1f"),flinger_miss/1000,n,target_angle),
										}
										setCommsMessage(tableSelectRandom(supply_location))
									else
										local insufficient_rep_responses = {
											_("needRep-comms","Insufficient reputation"),
											_("needRep-comms","Not enough reputation"),
											_("needRep-comms","You need more reputation"),
											string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
											_("needRep-comms","You don't have enough reputation"),
											string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
										}
										setCommsMessage(tableSelectRandom(insufficient_rep_responses))
									end
								end)
							end
						end
					end)
					if add_repair_crew then
						if comms_target.comms_data.available_repair_crew == nil then
							if station_repair_crew_inventory_min == nil then
								initializeStationRepairCrewEconomy()
							end
							comms_target.comms_data.available_repair_crew = math.random(station_repair_crew_inventory_min,station_repair_crew_inventory_max)
							comms_target.comms_data.available_repair_crew_cost_friendly = math.random(station_repair_crew_friendly_min,station_repair_crew_friendly_max)
							comms_target.comms_data.available_repair_crew_cost_neutral = math.random(station_repair_crew_neutral_min,station_repair_crew_neutral_max)
							comms_target.comms_data.available_repair_crew_excess = math.random(station_repair_crew_cost_excess_fee_min,station_repair_crew_cost_excess_fee_max)
							comms_target.comms_data.available_repair_crew_stranger = math.random(station_repair_crew_stranger_fee_min,station_repair_crew_stranger_fee_max)
						end
						if comms_target.comms_data.available_repair_crew > 0 then
							local hire_cost = 0
							if comms_source:isFriendly(comms_target) then
								hire_cost = comms_target.comms_data.available_repair_crew_cost_friendly
							else
								hire_cost = comms_target.comms_data.available_repair_crew_cost_neutral
							end
							if comms_target.comms_data.friendlyness <= station_repair_crew_very_friendly_threshold then
								hire_cost = hire_cost + comms_target.comms_data.available_repair_crew_stranger
							end
							if comms_source.maxRepairCrew == nil then
								initializeCommsSourceMaxRepairCrew()
							end
							if comms_source:getRepairCrewCount() >= comms_source.maxRepairCrew then
								hire_cost = hire_cost + comms_target.comms_data.available_repair_crew_excess
							end
							addCommsReply(string.format(_("stationAssist-comms","Add android repair crew (%d rep + %d rep = %d rep)"),getServiceCost("flingsupplydrop"),hire_cost,getServiceCost("flingsupplydrop") + hire_cost),function()
								if comms_source:getWaypointCount() < 1 then
									local set_supply_waypoint = {
										_("stationAssist-comms","You need to set a waypoint before you can request supplies."),
										_("stationAssist-comms","Set a waypoint so that we can place your supplies."),
										_("stationAssist-comms","Supplies require a waypoint as a target."),
										_("stationAssist-comms","Before requesting supplies, you need to set a waypoint."),
									}
									setCommsMessage(tableSelectRandom(set_supply_waypoint))
								else
									local point_supplies = {
										_("stationAssist-comms","To which waypoint should we deliver your supplies?"),
										_("stationAssist-comms","Identify the supply delivery waypoint"),
										_("stationAssist-comms","Where do you want your supplies?"),
										_("stationAssist-comms","Where do the supplies go?"),
									}
									setCommsMessage(tableSelectRandom(point_supplies))
									for n=1,comms_source:getWaypointCount() do
										addCommsReply(string.format(_("stationAssist-comms","Waypoint %i"),n), function()
											local hire_cost = 0
											if comms_source:isFriendly(comms_target) then
												hire_cost = comms_target.comms_data.available_repair_crew_cost_friendly
											else
												hire_cost = comms_target.comms_data.available_repair_crew_cost_neutral
											end
											if comms_target.comms_data.friendlyness <= station_repair_crew_very_friendly_threshold then
												hire_cost = hire_cost + comms_target.comms_data.available_repair_crew_stranger
											end
											if comms_source.maxRepairCrew == nil then
												initializeCommsSourceMaxRepairCrew()
											end
											if comms_source:getRepairCrewCount() >= comms_source.maxRepairCrew then
												hire_cost = hire_cost + comms_target.comms_data.available_repair_crew_excess
											end
											if comms_source:takeReputationPoints(getServiceCost("flingsupplydrop") + hire_cost) then
												local target_x, target_y = comms_source:getWaypoint(n)
												local target_angle = random(0,360)
												local flinger_miss = random(100,5000)
												local landing_x, landing_y = vectorFromAngleNorth(target_angle,flinger_miss)
												local sd = SupplyDrop():setFactionId(comms_target:getFactionId()):setPosition(target_x + landing_x, target_y + landing_y):setEnergy(500):setWeaponStorage("Nuke", 1):setWeaponStorage("Homing", 4):setWeaponStorage("Mine", 2):setWeaponStorage("EMP", 1)
												comms_target.comms_data.available_repair_crew = comms_target.comms_data.available_repair_crew - 1
												sd:onPickUp(function(self,player)
													string.format("")
													player:setRepairCrewCount(player:getRepairCrewCount() + 1)
												end)
												local supply_location = {
													string.format(_("stationAssist-comms","Supplies delivered %.1f units from waypoint, bearing %.1f."),flinger_miss/1000,target_angle),
													string.format(_("stationAssist-comms","Supplies have been launched. You can find them %.1f units from waypoint %i on bearing %.1f"),flinger_miss/1000,n,target_angle),
													string.format(_("stationAssist-comms","Our flinger has launched your supplies at waypoint %i. Look for them at %.1f units from waypoint, bearing %.1f"),n,flinger_miss/1000,target_angle),
													string.format(_("stationAssist-comms","Flung. Find supplies %.1f units from waypoint %i on bearing %.1f"),flinger_miss/1000,n,target_angle),
												}
												setCommsMessage(tableSelectRandom(supply_location))
											else
												local insufficient_rep_responses = {
													_("needRep-comms","Insufficient reputation"),
													_("needRep-comms","Not enough reputation"),
													_("needRep-comms","You need more reputation"),
													string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
													_("needRep-comms","You don't have enough reputation"),
													string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
												}
												setCommsMessage(tableSelectRandom(insufficient_rep_responses))
											end
										end)
									end
								end
							end)
						end
					end
					if add_coolant then
						if comms_target.comms_data.coolant_inventory == nil then
							if station_coolant_inventory_min == nil then
								initializeStationCoolantEconomy()
							end
							comms_target.comms_data.coolant_inventory = math.random(station_coolant_inventory_min,station_coolant_inventory_max)*2
							comms_target.comms_data.coolant_inventory_cost_friendly = math.random(station_coolant_friendly_min,station_coolant_friendly_max)
							comms_target.comms_data.coolant_inventory_cost_neutral = math.random(station_coolant_neutral_min,station_coolant_neutral_max)
							comms_target.comms_data.coolant_inventory_cost_excess = math.random(station_coolant_cost_excess_fee_min,station_coolant_cost_excess_fee_max)
							comms_target.comms_data.coolant_inventory_cost_stranger = math.random(station_coolant_stranger_fee_min,station_coolant_stranger_fee_max)
						end
						if comms_target.comms_data.coolant_inventory > 0 then
							local coolant_cost = 0
							if comms_source:isFriendly(comms_target) then
								coolant_cost = comms_target.comms_data.coolant_inventory_cost_friendly
							else
								coolant_cost = comms_target.comms_data.coolant_inventory_cost_neutral
							end
							if comms_target.comms_data.friendlyness <= station_coolant_very_friendly_threshold then
								coolant_cost = coolant_cost + comms_target.comms_data.coolant_inventory_cost_stranger
							end
							if comms_source.initialCoolant == nil then
								initializeCommsSourceInitialCoolant()
							end
							if comms_source:getMaxCoolant() >= comms_source.initialCoolant then
								coolant_cost = coolant_cost + comms_target.comms_data.coolant_inventory_cost_excess
							end
							addCommsReply(string.format(_("stationAssist-comms","Add coolant (%d rep + %d rep = %d rep)"),getServiceCost("flingsupplydrop"),coolant_cost,getServiceCost("flingsupplydrop") + coolant_cost),function()
								if comms_source:getWaypointCount() < 1 then
									local set_supply_waypoint = {
										_("stationAssist-comms","You need to set a waypoint before you can request supplies."),
										_("stationAssist-comms","Set a waypoint so that we can place your supplies."),
										_("stationAssist-comms","Supplies require a waypoint as a target."),
										_("stationAssist-comms","Before requesting supplies, you need to set a waypoint."),
									}
									setCommsMessage(tableSelectRandom(set_supply_waypoint))
								else
									local point_supplies = {
										_("stationAssist-comms","To which waypoint should we deliver your supplies?"),
										_("stationAssist-comms","Identify the supply delivery waypoint"),
										_("stationAssist-comms","Where do you want your supplies?"),
										_("stationAssist-comms","Where do the supplies go?"),
									}
									setCommsMessage(tableSelectRandom(point_supplies))
									for n=1,comms_source:getWaypointCount() do
										addCommsReply(string.format(_("stationAssist-comms","Waypoint %i"),n), function()
											local coolant_cost = 0
											if comms_source:isFriendly(comms_target) then
												coolant_cost = comms_target.comms_data.coolant_inventory_cost_friendly
											else
												coolant_cost = comms_target.comms_data.coolant_inventory_cost_neutral
											end
											if comms_target.comms_data.friendlyness <= station_coolant_very_friendly_threshold then
												coolant_cost = coolant_cost + comms_target.comms_data.coolant_inventory_cost_stranger
											end
											if comms_source.initialCoolant == nil then
												initializeCommsSourceInitialCoolant()
											end
											if comms_source:getMaxCoolant() >= comms_source.initialCoolant then
												coolant_cost = coolant_cost + comms_target.comms_data.coolant_inventory_cost_excess
											end
											if comms_source:takeReputationPoints(getServiceCost("flingsupplydrop") + coolant_cost) then
												local target_x, target_y = comms_source:getWaypoint(n)
												local target_angle = random(0,360)
												local flinger_miss = random(100,5000)
												local landing_x, landing_y = vectorFromAngleNorth(target_angle,flinger_miss)
												local sd = SupplyDrop():setFactionId(comms_target:getFactionId()):setPosition(target_x + landing_x, target_y + landing_y):setEnergy(500):setWeaponStorage("Nuke", 1):setWeaponStorage("Homing", 4):setWeaponStorage("Mine", 2):setWeaponStorage("EMP", 1)
												comms_target.comms_data.coolant_inventory = comms_target.comms_data.coolant_inventory - 2
												sd:onPickUp(function(self,player)
													string.format("")
													player:setMaxCoolant(player:getMaxCoolant() + 2)
												end)
												local supply_location = {
													string.format(_("stationAssist-comms","Supplies delivered %.1f units from waypoint, bearing %.1f."),flinger_miss/1000,target_angle),
													string.format(_("stationAssist-comms","Supplies have been launched. You can find them %.1f units from waypoint %i on bearing %.1f"),flinger_miss/1000,n,target_angle),
													string.format(_("stationAssist-comms","Our flinger has launched your supplies at waypoint %i. Look for them at %.1f units from waypoint, bearing %.1f"),n,flinger_miss/1000,target_angle),
													string.format(_("stationAssist-comms","Flung. Find supplies %.1f units from waypoint %i on bearing %.1f"),flinger_miss/1000,n,target_angle),
												}
												setCommsMessage(tableSelectRandom(supply_location))
											else
												local insufficient_rep_responses = {
													_("needRep-comms","Insufficient reputation"),
													_("needRep-comms","Not enough reputation"),
													_("needRep-comms","You need more reputation"),
													string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
													_("needRep-comms","You don't have enough reputation"),
													string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
												}
												setCommsMessage(tableSelectRandom(insufficient_rep_responses))
											end
										end)
									end
								end
							end)
						end
					end
					addCommsReply(_("Back"), commsStation)
				end)
				local deliver_type_explain_prompt = {
					_("stationAssist-comms","Explain supply drop delivery options"),
					_("stationAssist-comms","What's the difference between the supply drop options?"),
					_("stationAssist-comms","Please explain the different supply drop options"),
					_("stationAssist-comms","I don't understand the supply drop delivery options"),
				}
				addCommsReply(tableSelectRandom(deliver_type_explain_prompt),function()
					setCommsMessage(_("stationAssist-comms","A normal supply drop delivery is loaded onto a standard freighter and sent to the specified destination. Delivered by jump ship means it gets there quicker if it's farther away because the freighter is equipped with a jump drive. The flinger launches the supply drop using the station's flinger. The supply drop arrives quickly, but the flinger's not as accurate as a freighter."))
					addCommsReply(_("Back"), commsStation)
				end)
			end
		end
		addCommsReply(_("Back"), commsStation)
	end)
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
	end
    return math.ceil(comms_target.comms_data.weapon_cost[weapon] * comms_target.comms_data.reputation_cost_multipliers[getFriendStatus()])
end
--	External variables you may want to change outside of this utility
--		fast_dock_short_minutes - max # of minutes station will wait for a short fast dock
--			Default: 3 minutes
--		fast_dock_short_cost - reputation amount for a short fast dock
--			Default: 10 reputation
--		fast_dock_medium_minutes - max wait for medium fast dock,  Default: 5  minutes
--		fast_dock_medium_cost - reputation for a medium fast dock, Default: 15 reputation
--		fast_dock_long_minutes - max wait for a long fast dock,    Default: 8  minutes
--		fast_dock_long_cost - reputation for a long fast dock,     Default: 20 reputation
function requestExpediteDock()
	local expedite_dock_prompts = {
		_("station-comms","Expedite dock"),
		_("station-comms","Speedy dock"),
		_("station-comms","Fast dock"),
		_("station-comms","Decrease dock time"),
	}
	addCommsReply(tableSelectRandom(expedite_dock_prompts),function()
		if comms_source.expedite_dock == nil then
			local explain_expedite_dock = {
				_("station-comms","We can have workers standing by in the docking bay to rapidly service your ship when you dock. However, they won't wait around forever. When do you think you will dock?"),
				string.format(_("station-comms","We can direct dock workers to be ready to service your docked ship. They won't wait for long. How long before you dock with %s?"),comms_target:getCallSign()),
				_("station-comms","To expedite your dock, we can have dock workers ready to load supplies and service your ship as soon as you dock. The workers won't hang around forever. When will you dock?"),
				string.format(_("station-comms","To reduce time spent docked at %s, we can hire dock workers to rapidly load and service %s as soon as you dock. However, we can only hire them for a limited period of time. When are you docking?"),comms_target:getCallSign(),comms_source:getCallSign()),
			}
			setCommsMessage(tableSelectRandom(explain_expedite_dock))
			local short_minutes = 3
			if fast_dock_short_minutes ~= nil then short_minutes = fast_dock_short_minutes end
			local short_reputation = 10
			if fast_dock_short_cost ~= nil then short_reputation = fast_dock_short_cost end
			local short_prompts = {
				string.format(_("station-comms","Soon (%i minutes max, %i reputation)"),short_minutes,short_reputation),
				string.format(_("station-comms","Quickly (less than %i minutes, %i reputation)"),short_minutes,short_reputation),
				string.format(_("station-comms","Shortly (%i reputation, < %i minutes)"),short_reputation,short_minutes),
				string.format(_("station-comms","We're nearby (%i reputation, %i minutes max)"),short_reputation,short_minutes),
			}
			addCommsReply(tableSelectRandom(short_prompts),function()
				if comms_source:takeReputationPoints(short_reputation) then
					comms_source.expedite_dock = {["limit"] = short_minutes*60}
					setExpediteDock()
				else
					local insufficient_rep_responses = {
						_("needRep-comms","Insufficient reputation"),
						_("needRep-comms","Not enough reputation"),
						_("needRep-comms","You need more reputation"),
						string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
						_("needRep-comms","You don't have enough reputation"),
						string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
					}
					setCommsMessage(tableSelectRandom(insufficient_rep_responses))
					addCommsReply(_("Back"), commsStation)
				end
			end)
			local medium_minutes = 5
			if fast_dock_medium_minutes ~= nil then medium_minutes = fast_dock_medium_minutes end
			local medium_reputation = 15
			if fast_dock_medium_cost ~= nil then medium_reputation = fast_dock_medium_cost end
			local medium_prompts = {
				string.format(_("station-comms","In a little while (%i minutes max, %i reputation)"),medium_minutes,medium_reputation),
				string.format(_("station-comms","Soon-ish (less than %i minutes, %i reputation)"),medium_minutes,medium_reputation),
				string.format(_("station-comms","Less than %i minutes (%i reputation)"),medium_minutes,medium_reputation),
				string.format(_("station-comms","Soon, I think (%i reputation, < %i minutes)"),medium_reputation,medium_minutes),
			}
			addCommsReply(tableSelectRandom(medium_prompts),function()
				if comms_source:takeReputationPoints(medium_reputation) then
					comms_source.expedite_dock = {["limit"] = medium_minutes*60}
					setExpediteDock()
				else
					local insufficient_rep_responses = {
						_("needRep-comms","Insufficient reputation"),
						_("needRep-comms","Not enough reputation"),
						_("needRep-comms","You need more reputation"),
						string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
						_("needRep-comms","You don't have enough reputation"),
						string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
					}
					setCommsMessage(tableSelectRandom(insufficient_rep_responses))
					addCommsReply(_("Back"), commsStation)
				end
			end)
			local long_minutes = 8
			if fast_dock_long_minutes ~= nil then long_minutes = fast_dock_long_minutes end
			local long_reputation = 20
			if fast_dock_long_cost ~= nil then long_reputation = fast_dock_long_cost end
			local long_prompts = {
				string.format(_("station-comms","We're far away (%i minutes max, %i reputation)"),long_minutes,long_reputation),
				string.format(_("station-comms","Less than %i minutes (%i reputation)"),long_minutes,long_reputation),
				string.format(_("station-comms","Hard to tell (less than %i minutes, %i reputation)"),long_minutes,long_reputation),
				string.format(_("station-comms","It'll be a bit (< %i minutes, %i reputation)"),long_minutes,long_reputation),
			}
			addCommsReply(tableSelectRandom(long_prompts),function()
				if comms_source:takeReputationPoints(long_reputation) then
					comms_source.expedite_dock = {["limit"] = long_minutes*60}
					setExpediteDock()
				else
					local insufficient_rep_responses = {
						_("needRep-comms","Insufficient reputation"),
						_("needRep-comms","Not enough reputation"),
						_("needRep-comms","You need more reputation"),
						string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
						_("needRep-comms","You don't have enough reputation"),
						string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
					}
					setCommsMessage(tableSelectRandom(insufficient_rep_responses))
					addCommsReply(_("Back"), commsStation)
				end
			end)
			addCommsReply(_("Back"), commsStation)
		else
			setExpediteDock()
		end
	end)
end
--	Booleans to set outside of this utility to control this utility. Default is false
--		add_repair_crew - set true if players can get more repair crew from stations
--		add_coolant - set true if players can get more coolant from stations
function setExpediteDock()
	if comms_source.expedite_dock == nil then
		setCommsMessage(_("station-comms","Communications glitch. Please try again."))
		addCommsReply(_("Back"), commsStation)
	else
		if comms_source.expedite_dock.limit == nil then
			setCommsMessage(_("station-comms","Communications glitch. Please try again."))
			addCommsReply(_("Back"), commsStation)
		else
			local out = ""
			if comms_source.expedite_dock.expire == nil then
				comms_source.expedite_dock.expire = getScenarioTime() + comms_source.expedite_dock.limit
				if expedite_dock_players == nil then
					expedite_dock_players = {}
				end
				expedite_dock_players[comms_source] = true
				comms_source.expedite_dock.station = comms_target
				local standard_service_count = 0
				if comms_target:getSharesEnergyWithDocked() then
					comms_source.expedite_dock.energy = true
					standard_service_count = standard_service_count + 1
					out = _("station-comms","energy")
				end
				if comms_target:getRepairDocked() then
					comms_source.expedite_dock.hull = true
					standard_service_count = standard_service_count + 1
					if out == "" then
						out = _("station-comms","hull repair")
					else
						out = string.format(_("station-comms","%s, hull repair"),out)
					end
				end
				if comms_target:getRestocksScanProbes() then
					comms_source.expedite_dock.probes = true
					standard_service_count = standard_service_count + 1
					if out == "" then
						out = _("station-comms","restock probes")
					else
						out = string.format(_("station-comms","%s, restock probes"),out)
					end
				end
				local additional_services = {
					_("station-comms","What additional service would you like expedited?"),
					_("station-comms","Would you like to add a service to your expedited services list?"),
					_("station-comms","Might we expedite another service for you?"),
					_("station-comms","We could expedite another service if you wish."),
				}
				if standard_service_count > 1 then
					local plural_existing_services = {
						_("station-comms","Standard expedited services:"),
						_("station-comms","Normal expedited services:"),
						_("station-comms","Regular expedited services:"),
						_("station-comms","Complimentary expedited services:"),
					}
					out = string.format(_("station-comms","%s %s. %s"),tableSelectRandom(plural_existing_services),out,tableSelectRandom(additional_services))
				elseif standard_service_count > 0 then
					local singular_existing_service = {
						_("station-comms","Standard expedited service:"),
						_("station-comms","Normal expedited service:"),
						_("station-comms","Regular expedited service:"),
						_("station-comms","Complimentary expedited service:"),
					}
					out = string.format(_("station-comms","%s %s. %s"),tableSelectRandom(singular_existing_service),out,tableSelectRandom(additional_services))
				else
					local expedite_something = {
						_("station-comms","What service would you like expedited?"),
						_("station-comms","Can we expedite a service for you?"),
						_("station-comms","Is there a service you'd like expedited?"),
						_("station-comms","Specify the service to expedite"),
					}
					out = tableSelectRandom(expedite_something)
				end
			else
				if comms_source.expedite_dock.station ~= comms_target then
					if comms_source.expedite_dock.station:isValid() then
						local what_about_current_contract = {
							string.format(_("station-comms","I represent station %s.\nI see that you have an expedited docking contract with station %s.\nWould you like to cancel it?"),comms_target:getCallSign(),comms_source.expedite_dock.station:getCallSign()),
							string.format(_("station-comms","Considering an expedited docking contract with %s, eh? What should be done about your existing expedited contract with %s? Cancel it?"),comms_target:getCallSign(),comms_source.expedite_dock.station:getCallSign()),
							string.format(_("station-comms","Want a fast dock with %s? What should be done about your current agreement with %s? Should it be cancelled?"),comms_target:getCallSign(),comms_source.expedite_dock.station:getCallSign()),
							string.format(_("station-comms","You can't set up a quick dock with %s until your quick dock with %s is done or cancelled. Shall I cancel it?"),comms_target:getCallSign(),comms_source.expedite_dock.station:getCallSign()),
						}
						setCommsMessage(tableSelectRandom(what_about_current_contract))
						local cancel_fast_dock_prompt = {
							string.format(_("station-comms","Yes, cancel expedited docking contract with %s"),comms_source.expedite_dock.station:getCallSign()),
							string.format(_("station-comms","Abandon fast dock plan with %s"),comms_source.expedite_dock.station:getCallSign()),
							string.format(_("station-comms","Cancel planned quick dock with %s"),comms_source.expedite_dock.station:getCallSign()),
							string.format(_("station-comms","Please cancel the fast dock contract with %s"),comms_source.expedite_dock.station:getCallSign()),
						}
						addCommsReply(tableSelectRandom(cancel_fast_dock_prompt),function()
							local fast_dock_contract_cancelled = {
								string.format(_("station-comms","Expedited docking contract with %s has been cancelled."),comms_source.expedite_dock.station:getCallSign()),
								string.format(_("station-comms","Fast dock cancelled with %s"),comms_source.expedite_dock.station:getCallSign()),
								string.format(_("station-comms","Ok, we just cancelled your expedited docking contract with %s"),comms_source.expedite_dock.station:getCallSign()),
								string.format(_("station-comms","%s fast dock contract cancelled"),comms_source.expedite_dock.station:getCallSign()),
							}
							setCommsMessage(tableSelectRandom(fast_dock_contract_cancelled))
							expedite_dock_players[comms_source] = nil
							comms_source.expedite_dock = nil
							addCommsReply(_("Back"), commsStation)
						end)
						local keep_fast_dock_contract = {
							string.format(_("station-comms","No, keep existing expedited docking contract with %s"),comms_source.expedite_dock.station:getCallSign()),
							string.format(_("station-comms","Oops, I forgot about that. I need to keep the fast dock contract with %s"),comms_source.expedite_dock.station:getCallSign()),
							string.format(_("station-comms","I'd better keep the existing quick dock contract with %s"),comms_source.expedite_dock.station:getCallSign()),
							string.format(_("station-comms","Keep the fast dock plan with %s. Let's not waste the reputation already spent there"),comms_source.expedite_dock.station:getCallSign()),
						}
						addCommsReply(tableSelectRandom(keep_fast_dock_contract),function()
							local fast_dock_contract_kept = {
								string.format(_("station-comms","Ok, we left the fast dock contract in place with %s"),comms_source.expedite_dock.station:getCallSign()),
								string.format(_("station-comms","Kept the quick dock contract with %s"),comms_source.expedite_dock.station:getCallSign()),
								string.format(_("station-comms","The expedited dock contract with %s remains in effect"),comms_source.expedite_dock.station:getCallSign()),
								string.format(_("station-comms","Maintaining the fast dock contract with %s"),comms_source.expedite_dock.station:getCallSign()),
							}
							setCommsMessage(tableSelectRandom(fast_dock_contract_kept))
							addCommsReply(_("Back"), commsStation)
						end)
					else
						local handled_invalid_contract = {
							_("station-comms","An expedited docking contract with a now defunct station has been cancelled."),
							_("station-comms","The station you had a fast dock contract with is gone. Contract cancelled."),
							_("station-comms","Since the station you were planning to fast dock with no longer exists, the contract has been cancelled."),
							_("station-comms","Your former fast dock station has ceased to exist. Expedited contract cancelled."),
						}
						setCommsMessage(tableSelectRandom(handled_invalid_contract))
						expedite_dock_players[comms_source] = nil
						comms_source.expedite_dock = nil
						addCommsReply(_("Back"), commsStation)
					end
				end
			end
			if comms_source.expedite_dock.station == comms_target then
				local service_to_add_count = 0
				if out == "" then
					local minutes = 0
					local seconds = comms_source.expedite_dock.expire - getScenarioTime()
					if seconds > 60 then
						minutes = seconds / 60
						seconds = seconds % 60
						out = string.format(_("station-comms","Expected dock with %s in %i:%.2i"),comms_target:getCallSign(),math.floor(minutes),math.floor(seconds))
					else
						out = string.format(_("station-comms","Expected dock with %s in 0:%.2i"),comms_target:getCallSign(),math.floor(seconds))
					end
				end
				service_list = _("station-comms","Expedited service list:")
				if comms_source.expedite_dock.energy then
					service_list = string.format(_("station-comms","%s energy"),service_list)
				else
					local replenish_energy_fast_dock_prompt = {
						_("station-comms","Replenish energy (5 reputation)"),
						_("station-comms","Charge batteries (5 reputation)"),
						_("station-comms","Recharge power (5 reputation)"),
						_("station-comms","Replenish power reserves (5 reputation)"),
					}
					addCommsReply(tableSelectRandom(replenish_energy_fast_dock_prompt),function()
						if comms_source:takeReputationPoints(5) then
							comms_source.expedite_dock.energy = true
							setExpediteDock()
						else
							local insufficient_rep_responses = {
								_("needRep-comms","Insufficient reputation"),
								_("needRep-comms","Not enough reputation"),
								_("needRep-comms","You need more reputation"),
								string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
								_("needRep-comms","You don't have enough reputation"),
								string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
							}
							setCommsMessage(tableSelectRandom(insufficient_rep_responses))
							addCommsReply(_("station-comms","Back to expedited dock negotiation"),setExpediteDock)
							addCommsReply(_("station-comms","Back to station communication"),commsStation)
						end
					end)
					service_to_add_count = service_to_add_count + 1
				end
				if comms_source.expedite_dock.hull then
					if service_list == _("station-comms","Expedited service list:") then
						service_list = string.format(_("station-comms","%s hull"),service_list)
					else
						service_list = string.format(_("station-comms","%s, hull"),service_list)
					end
				else
					local repair_hull_fast_dock_prompt = {
						_("station-comms","Repair hull (10 reputation)"),
						_("station-comms","Fix hull (10 reputation)"),
						_("station-comms","Restore hull (10 reputation)"),
						_("station-comms","Refurbish hull (10 reputation)"),
					}
					addCommsReply(tableSelectRandom(repair_hull_fast_dock_prompt),function()
						if comms_source:takeReputationPoints(10) then
							comms_source.expedite_dock.hull = true
							setExpediteDock()
						else
							local insufficient_rep_responses = {
								_("needRep-comms","Insufficient reputation"),
								_("needRep-comms","Not enough reputation"),
								_("needRep-comms","You need more reputation"),
								string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
								_("needRep-comms","You don't have enough reputation"),
								string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
							}
							setCommsMessage(tableSelectRandom(insufficient_rep_responses))
							addCommsReply(_("station-comms","Back to expedited dock negotiation"),setExpediteDock)
							addCommsReply(_("station-comms","Back to station communication"),commsStation)
						end
					end)
					service_to_add_count = service_to_add_count + 1
				end
				if comms_source.expedite_dock.probes then
					if service_list == _("station-comms","Expedited service list:") then
						service_list = string.format(_("station-comms","%s probes"),service_list)
					else
						service_list = string.format(_("station-comms","%s, probes"),service_list)
					end
				else
					local restock_probes_fast_dock_prompt = {
						_("station-comms","Replenish probes (5 reputation)"),
						_("station-comms","Restock probes (5 reputation)"),
						_("station-comms","Refill probes (5 reputation)"),
						_("station-comms","Restore probe inventory (5 reputation)"),
					}
					addCommsReply(tableSelectRandom(restock_probes_fast_dock_prompt),function()
						if comms_source:takeReputationPoints(5) then
							comms_source.expedite_dock.probes = true
							setExpediteDock()
						else
							local insufficient_rep_responses = {
								_("needRep-comms","Insufficient reputation"),
								_("needRep-comms","Not enough reputation"),
								_("needRep-comms","You need more reputation"),
								string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
								_("needRep-comms","You don't have enough reputation"),
								string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
							}
							setCommsMessage(tableSelectRandom(insufficient_rep_responses))
							addCommsReply(_("station-comms","Back to expedited dock negotiation"),setExpediteDock)
							addCommsReply(_("station-comms","Back to station communication"),commsStation)
						end
					end)
					service_to_add_count = service_to_add_count + 1
				end
				if comms_source.expedite_dock.nuke ~= nil then
					if service_list == _("station-comms","Expedited service list:") then
						if comms_source.expedite_dock.nuke > 1 then
							service_list = string.format(_("station-comms","%s %s nukes"),service_list,comms_source.expedite_dock.nuke)
						else
							service_list = string.format(_("station-comms","%s one nuke"),service_list)
						end
					else
						if comms_source.expedite_dock.nuke > 1 then
							service_list = string.format(_("station-comms","%s, %s nukes"),service_list,comms_source.expedite_dock.nuke)
						else
							service_list = string.format(_("station-comms","%s, one nuke"),service_list)
						end
					end
				else
					if comms_target.comms_data.weapon_available.Nuke and isAllowedTo(comms_target.comms_data.weapons.Nuke) then
						local max_nuke = comms_source:getWeaponStorageMax("Nuke")
						if max_nuke > 0 then
							local current_nuke = comms_source:getWeaponStorage("Nuke")
							if current_nuke < max_nuke then
								local full_nuke = max_nuke - current_nuke
								local replenish_nukes_fast_dock_prompt = {
									string.format(_("station-comms","Replenish nukes (%d reputation)"),getWeaponCost("Nuke")*full_nuke),
									string.format(_("station-comms","Restock nukes (%s reputation)"),getWeaponCost("Nuke")*full_nuke),
									string.format(_("station-comms","Refill nukes (%s reputation)"),getWeaponCost("Nuke")*full_nuke),
									string.format(_("station-comms","Refill nukes (%s reputation, %i nuke(s))"),getWeaponCost("Nuke")*full_nuke,full_nuke),
								}
								addCommsReply(tableSelectRandom(replenish_nukes_fast_dock_prompt),function()
									if comms_source:takeReputationPoints(getWeaponCost("Nuke")*full_nuke) then
										comms_source.expedite_dock.nuke = full_nuke
										setExpediteDock()
									else
										local insufficient_rep_responses = {
											_("needRep-comms","Insufficient reputation"),
											_("needRep-comms","Not enough reputation"),
											_("needRep-comms","You need more reputation"),
											string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
											_("needRep-comms","You don't have enough reputation"),
											string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
										}
										setCommsMessage(tableSelectRandom(insufficient_rep_responses))
										addCommsReply(_("station-comms","Back to expedited dock negotiation"),setExpediteDock)
										addCommsReply(_("station-comms","Back to station communication"),commsStation)
									end
								end)
								service_to_add_count = service_to_add_count + 1
							end
						end
					end
				end
				if comms_source.expedite_dock.homing ~= nil then
					if service_list == _("station-comms","Expedited service list:") then
						if comms_source.expedite_dock.homing > 1 then
							service_list = string.format(_("station-comms","%s %s homing missiles"),service_list,comms_source.expedite_dock.homing)
						else
							service_list = string.format(_("station-comms","%s one homing missile"),service_list)
						end
					else
						if comms_source.expedite_dock.homing > 1 then
							service_list = string.format(_("station-comms","%s, %s homing missiles"),service_list,comms_source.expedite_dock.homing)
						else
							service_list = string.format(_("station-comms","%s, one homing missile"),service_list)
						end
					end
				else
					if comms_target.comms_data.weapon_available.Homing and isAllowedTo(comms_target.comms_data.weapons.Homing) then
						local max_homing = comms_source:getWeaponStorageMax("Homing")
						if max_homing > 0 then
							local current_homing = comms_source:getWeaponStorage("Homing")
							if current_homing < max_homing then
								local full_homing = max_homing - current_homing
								local refill_homing_fast_dock_prompt = {
									string.format(_("station-comms","Replenish homing missiles (%d reputation)"),getWeaponCost("Homing")*full_homing),
									string.format(_("station-comms","Restock homing missiles (%d reputation)"),getWeaponCost("Homing")*full_homing),
									string.format(_("station-comms","Refill homing missiles (%d reputation)"),getWeaponCost("Homing")*full_homing),
									string.format(_("station-comms","Restore homing missiles inventory (%d rep)"),getWeaponCost("Homing")*full_homing),
								}
								addCommsReply(tableSelectRandom(refill_homing_fast_dock_prompt),function()
									if comms_source:takeReputationPoints(getWeaponCost("Homing")*full_homing) then
										comms_source.expedite_dock.homing = full_homing
										setExpediteDock()
									else
										local insufficient_rep_responses = {
											_("needRep-comms","Insufficient reputation"),
											_("needRep-comms","Not enough reputation"),
											_("needRep-comms","You need more reputation"),
											string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
											_("needRep-comms","You don't have enough reputation"),
											string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
										}
										setCommsMessage(tableSelectRandom(insufficient_rep_responses))
										addCommsReply(_("station-comms","Back to expedited dock negotiation"),setExpediteDock)
										addCommsReply(_("station-comms","Back to station communication"),commsStation)
									end
								end)
								service_to_add_count = service_to_add_count + 1
							end
						end
					end
				end
				if comms_source.expedite_dock.emp ~= nil then
					if service_list == _("station-comms","Expedited service list:") then
						if comms_source.expedite_dock.emp > 1 then
							service_list = string.format(_("station-comms","%s %s EMP missiles"),service_list,comms_source.expedite_dock.emp)
						else
							service_list = string.format(_("station-comms","%s one EMP missile"),service_list)
						end
					else
						if comms_source.expedite_dock.emp > 1 then
							service_list = string.format(_("station-comms","%s, %s EMP missiles"),service_list,comms_source.expedite_dock.emp)
						else
							service_list = string.format(_("station-comms","%s, one EMP missile"),service_list)
						end
					end
				else
					if comms_target.comms_data.weapon_available.EMP and isAllowedTo(comms_target.comms_data.weapons.EMP) then
						local max_emp = comms_source:getWeaponStorageMax("EMP")
						if max_emp > 0 then
							local current_emp = comms_source:getWeaponStorage("EMP")
							if current_emp < max_emp then
								local full_emp = max_emp - current_emp
								local restock_emp_fast_dock_prompt = {
									string.format(_("station-comms","Replenish EMP missiles (%d reputation)"),getWeaponCost("EMP")*full_emp),
									string.format(_("station-comms","Restock EMP missiles (%d reputation)"),getWeaponCost("EMP")*full_emp),
									string.format(_("station-comms","Refill EMP missiles (%d reputation)"),getWeaponCost("EMP")*full_emp),
									string.format(_("station-comms","Restore EMP missiles inventory (%d rep)"),getWeaponCost("EMP")*full_emp),
								}
								addCommsReply(tableSelectRandom(restock_emp_fast_dock_prompt),function()
									if comms_source:takeReputationPoints(getWeaponCost("EMP")*full_emp) then
										comms_source.expedite_dock.emp = full_emp
										setExpediteDock()
									else
										local insufficient_rep_responses = {
											_("needRep-comms","Insufficient reputation"),
											_("needRep-comms","Not enough reputation"),
											_("needRep-comms","You need more reputation"),
											string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
											_("needRep-comms","You don't have enough reputation"),
											string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
										}
										setCommsMessage(tableSelectRandom(insufficient_rep_responses))
										addCommsReply(_("station-comms","Back to expedited dock negotiation"),setExpediteDock)
										addCommsReply(_("station-comms","Back to station communication"),commsStation)
									end
								end)
								service_to_add_count = service_to_add_count + 1
							end
						end
					end
				end
				if comms_source.expedite_dock.mine ~= nil then
					if service_list == _("station-comms","Expedited service list:") then
						if comms_source.expedite_dock.mine > 1 then
							service_list = string.format(_("station-comms","%s %s mines"),service_list,comms_source.expedite_dock.mine)
						else
							service_list = string.format(_("station-comms","%s one mine"),service_list)
						end
					else
						if comms_source.expedite_dock.mine > 1 then
							service_list = string.format(_("station-comms","%s, %s mines"),service_list,comms_source.expedite_dock.mine)
						else
							service_list = string.format(_("station-comms","%s, one mine"),service_list)
						end
					end
				else
					if comms_target.comms_data.weapon_available.Mine and isAllowedTo(comms_target.comms_data.weapons.Mine) then
						local max_mine = comms_source:getWeaponStorageMax("Mine")
						if max_mine > 0 then
							local current_mine = comms_source:getWeaponStorage("Mine")
							if current_mine < max_mine then
								local full_mine = max_mine - current_mine
								local restock_mines_fast_dock_prompt = {
									string.format(_("station-comms","Replenish mines (%d reputation)"),getWeaponCost("Mine")*full_mine),
									string.format(_("station-comms","Restock mines (%d reputation)"),getWeaponCost("Mine")*full_mine),
									string.format(_("station-comms","Refill mines (%d reputation)"),getWeaponCost("Mine")*full_mine),
									string.format(_("station-comms","Restore inventory of mines (%d rep)"),getWeaponCost("Mine")*full_mine),
								}
								addCommsReply(tableSelectRandom(restock_mines_fast_dock_prompt),function()
									if comms_source:takeReputationPoints(getWeaponCost("Mine")*full_mine) then
										comms_source.expedite_dock.mine = full_mine
										setExpediteDock()
									else
										local insufficient_rep_responses = {
											_("needRep-comms","Insufficient reputation"),
											_("needRep-comms","Not enough reputation"),
											_("needRep-comms","You need more reputation"),
											string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
											_("needRep-comms","You don't have enough reputation"),
											string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
										}
										setCommsMessage(tableSelectRandom(insufficient_rep_responses))
										addCommsReply(_("station-comms","Back to expedited dock negotiation"),setExpediteDock)
										addCommsReply(_("station-comms","Back to station communication"),commsStation)
									end
								end)
								service_to_add_count = service_to_add_count + 1
							end
						end
					end
				end
				if comms_source.expedite_dock.hvli ~= nil then
					if service_list == _("station-comms","Expedited service list:") then
						if comms_source.expedite_dock.hvli > 1 then
							service_list = string.format(_("station-comms","%s %s HVLI missiles"),service_list,comms_source.expedite_dock.hvli)
						else
							service_list = string.format(_("station-comms","%s one HVLI missile"),service_list)
						end
					else
						if comms_source.expedite_dock.mine > 1 then
							service_list = string.format(_("station-comms","%s, %s HVLI missiles"),service_list,comms_source.expedite_dock.hvli)
						else
							service_list = string.format(_("station-comms","%s, one HVLI missile"),service_list)
						end
					end
				else
					if comms_target.comms_data.weapon_available.HVLI and isAllowedTo(comms_target.comms_data.weapons.HVLI) then
						local max_hvli = comms_source:getWeaponStorageMax("HVLI")
						if max_hvli > 0 then
							local current_hvli = comms_source:getWeaponStorage("HVLI")
							if current_hvli < max_hvli then
								local full_hvli = max_hvli - current_hvli
								local refill_hvli_quick_dock_prompt = {
									string.format(_("station-comms","Replenish HVLI missiles (%d reputation)"),getWeaponCost("HVLI")*full_hvli),
									string.format(_("station-comms","Restock HVLI missiles (%d reputation)"),getWeaponCost("HVLI")*full_hvli),
									string.format(_("station-comms","Refill HVLI missiles (%d reputation)"),getWeaponCost("HVLI")*full_hvli),
									string.format(_("station-comms","Restore HVLI missiles inventory (%d rep)"),getWeaponCost("HVLI")*full_hvli),
								}
								addCommsReply(tableSelectRandom(refill_hvli_quick_dock_prompt),function()
									if comms_source:takeReputationPoints(getWeaponCost("HVLI")*full_hvli) then
										comms_source.expedite_dock.hvli = full_hvli
										setExpediteDock()
									else
										local insufficient_rep_responses = {
											_("needRep-comms","Insufficient reputation"),
											_("needRep-comms","Not enough reputation"),
											_("needRep-comms","You need more reputation"),
											string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
											_("needRep-comms","You don't have enough reputation"),
											string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
										}
										setCommsMessage(tableSelectRandom(insufficient_rep_responses))
										addCommsReply(_("station-comms","Back to expedited dock negotiation"),setExpediteDock)
										addCommsReply(_("station-comms","Back to station communication"),commsStation)
									end
								end)
								service_to_add_count = service_to_add_count + 1
							end
						end
					end
				end
				if add_repair_crew then
					if comms_source.expedite_dock.repair_crew then
						if service_list == _("station-comms","Expedited service list:") then
							service_list = string.format(_("station-comms","%s one repair crew"),service_list)
						else
							service_list = string.format(_("station-comms","%s, one repair crew"),service_list)
						end
					else
						if comms_target.comms_data.available_repair_crew == nil then
							if station_repair_crew_inventory_min == nil then
								initializeStationRepairCrewEconomy()
							end
							comms_target.comms_data.available_repair_crew = math.random(station_repair_crew_inventory_min,station_repair_crew_inventory_max)
							comms_target.comms_data.available_repair_crew_cost_friendly = math.random(station_repair_crew_friendly_min,station_repair_crew_friendly_max)
							comms_target.comms_data.available_repair_crew_cost_neutral = math.random(station_repair_crew_neutral_min,station_repair_crew_neutral_max)
							comms_target.comms_data.available_repair_crew_excess = math.random(station_repair_crew_cost_excess_fee_min,station_repair_crew_cost_excess_fee_max)
							comms_target.comms_data.available_repair_crew_stranger = math.random(station_repair_crew_stranger_fee_min,station_repair_crew_stranger_fee_max)
						end
						if comms_target.comms_data.available_repair_crew > 0 then	--station has repair crew available
							local hire_cost = 0
							if comms_source:isFriendly(comms_target) then
								hire_cost = comms_target.comms_data.available_repair_crew_cost_friendly
							else
								hire_cost = comms_target.comms_data.available_repair_crew_cost_neutral
							end
							if comms_target.comms_data.friendlyness <= station_repair_crew_very_friendly_threshold then
								hire_cost = hire_cost + comms_target.comms_data.available_repair_crew_stranger
							end
							if comms_source.maxRepairCrew == nil then
								initializeCommsSourceMaxRepairCrew()
							end
							if comms_source:getRepairCrewCount() >= comms_source.maxRepairCrew then
								hire_cost = hire_cost + comms_target.comms_data.available_repair_crew_excess
							end
							local hire_repair_crew_fast_dock_prompt = {
								string.format(_("station-comms","Hire one repair crew (%d reputation)"),hire_cost),
								string.format(_("station-comms","Add to repair crew (%d reputation)"),hire_cost),
								string.format(_("station-comms","Hire additional repair crew (%d reputation)"),hire_cost),
								string.format(_("station-comms","Get one repair crew (%d reputation)"),hire_cost),
							}
							addCommsReply(tableSelectRandom(hire_repair_crew_fast_dock_prompt),function()
								local hire_cost = 0
								if comms_source:isFriendly(comms_target) then
									hire_cost = comms_target.comms_data.available_repair_crew_cost_friendly
								else
									hire_cost = comms_target.comms_data.available_repair_crew_cost_neutral
								end
								if comms_target.comms_data.friendlyness <= station_repair_crew_very_friendly_threshold then
									hire_cost = hire_cost + comms_target.comms_data.available_repair_crew_stranger
								end
								if comms_source.maxRepairCrew == nil then
									initializeCommsSourceMaxRepairCrew()
								end
								if comms_source:getRepairCrewCount() >= comms_source.maxRepairCrew then
									hire_cost = hire_cost + comms_target.comms_data.available_repair_crew_excess
								end
								if comms_source:takeReputationPoints(hire_cost) then
									comms_source.expedite_dock.repair_crew = true
									setExpediteDock()
								else
									local insufficient_rep_responses = {
										_("needRep-comms","Insufficient reputation"),
										_("needRep-comms","Not enough reputation"),
										_("needRep-comms","You need more reputation"),
										string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
										_("needRep-comms","You don't have enough reputation"),
										string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
									}
									setCommsMessage(tableSelectRandom(insufficient_rep_responses))
									addCommsReply(_("station-comms","Back to expedited dock negotiation"),setExpediteDock)
									addCommsReply(_("station-comms","Back to station communication"),commsStation)
								end
							end)
							service_to_add_count = service_to_add_count + 1
						end
					end
				end
				if add_coolant then
					if comms_source.expedite_dock.coolant then
						if service_list == _("station-comms","Expedited service list:") then
							service_list = string.format(_("station-comms","%s add coolant"),service_list)
						else
							service_list = string.format(_("station-comms","%s, add coolant"),service_list)
						end
					else
						if comms_target.comms_data.coolant_inventory == nil then
							if station_coolant_inventory_min == nil then
								initializeStationCoolantEconomy()
							end
							comms_target.comms_data.coolant_inventory = math.random(station_coolant_inventory_min,station_coolant_inventory_max)*2
							comms_target.comms_data.coolant_inventory_cost_friendly = math.random(station_coolant_friendly_min,station_coolant_friendly_max)
							comms_target.comms_data.coolant_inventory_cost_neutral = math.random(station_coolant_neutral_min,station_coolant_neutral_max)
							comms_target.comms_data.coolant_inventory_cost_excess = math.random(station_coolant_cost_excess_fee_min,station_coolant_cost_excess_fee_max)
							comms_target.comms_data.coolant_inventory_cost_stranger = math.random(station_coolant_stranger_fee_min,station_coolant_stranger_fee_max)
						end
						if comms_target.comms_data.coolant_inventory > 0 then
							local coolant_cost = 0
							if comms_source:isFriendly(comms_target) then
								coolant_cost = comms_target.comms_data.coolant_inventory_cost_friendly
							else
								coolant_cost = comms_target.comms_data.coolant_inventory_cost_neutral
							end
							if comms_target.comms_data.friendlyness <= station_coolant_very_friendly_threshold then
								coolant_cost = coolant_cost + comms_target.comms_data.coolant_inventory_cost_stranger
							end
							if comms_source.initialCoolant == nil then
								initializeCommsSourceInitialCoolant()
							end
							if comms_source:getMaxCoolant() >= comms_source.initialCoolant then
								coolant_cost = coolant_cost + comms_target.comms_data.coolant_inventory_cost_excess
							end
							local get_coolant_fast_dock_prompt = {
								string.format(_("station-comms","Get additional coolant (%d rep)"),coolant_cost),
								string.format(_("station-comms","Get more coolant (%d rep)"),coolant_cost),
								string.format(_("station-comms","Add coolant (%d rep)"),coolant_cost),
								string.format(_("station-comms","Acquire coolant (%d rep)"),coolant_cost),
							}
							addCommsReply(tableSelectRandom(get_coolant_fast_dock_prompt),function()
								local coolant_cost = 0
								if comms_source:isFriendly(comms_target) then
									coolant_cost = comms_target.comms_data.coolant_inventory_cost_friendly
								else
									coolant_cost = comms_target.comms_data.coolant_inventory_cost_neutral
								end
								if comms_target.comms_data.friendlyness <= station_coolant_very_friendly_threshold then
									coolant_cost = coolant_cost + comms_target.comms_data.coolant_inventory_cost_stranger
								end
								if comms_source.initialCoolant == nil then
									initializeCommsSourceInitialCoolant()
								end
								if comms_source:getMaxCoolant() >= comms_source.initialCoolant then
									coolant_cost = coolant_cost + comms_target.comms_data.coolant_inventory_cost_excess
								end
								if comms_source:takeReputationPoints(coolant_cost) then
									comms_source.expedite_dock.coolant = true
									setExpediteDock()
								else
									local insufficient_rep_responses = {
										_("needRep-comms","Insufficient reputation"),
										_("needRep-comms","Not enough reputation"),
										_("needRep-comms","You need more reputation"),
										string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
										_("needRep-comms","You don't have enough reputation"),
										string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
									}
									setCommsMessage(tableSelectRandom(insufficient_rep_responses))
									addCommsReply(_("station-comms","Back to expedited dock negotiation"),setExpediteDock)
									addCommsReply(_("station-comms","Back to station communication"),commsStation)
								end
							end)
							service_to_add_count = service_to_add_count + 1
						end
					end
				end
				if service_to_add_count > 0 then
					local more_services_addendum = {
						_("station-comms","Would you like some additional expedited docking services?"),
						_("station-comms","Do you want to expedite another service?"),
						_("station-comms","Would you like to add to your list of expedited services?"),
						_("station-comms","How about another expedited service?"),
					}
					if service_list == _("station-comms","Expedited service list:") then
						out = string.format(_("station-comms","%s\n%s"),out,tableSelectRandom(more_services_addendum))
					else
						out = string.format(_("station-comms","%s\n%s.\n%s"),out,service_list,tableSelectRandom(more_services_addendum))
					end
				else
					local no_more_services_addendum = {
						_("station-comms","There are no additional expedited docking services available."),
						_("station-comms","There are no more expeditable services available."),
						_("station-comms","We cannot expedite any more services."),
						_("station-comms","No more services are available for fast dock."),
					}
					if service_list == _("station-comms","Expedited service list:") then
						out = string.format(_("station-comms","%s\n%s"),out,tableSelectRandom(no_more_services_addendum))					
					else
						out = string.format(_("station-comms","%s\n%s.\n%s"),out,service_list,tableSelectRandom(no_more_services_addendum))
					end
				end
				setCommsMessage(out)
				addCommsReply(_("Back"), commsStation)
			end
		end
	end
end
--	Booleans to set outside of this utility to control this utility. Default is false
--		stations_sell_goods - set true if stations sell goods to players for reputation
--		stations_buy_goods - set true if stations buy goods from players for reputation
--		stations_trade_goods - set true if station will trade one good for another
--			Note: trade usually does not work well unless at least sell is enabled
--		stations_support_transport_missions - set true if stations handle transport missions
--		stations_support_cargo_missions - set true if stations handle cargo missions
--			Note: cargo missions usually require transport missions
--	Functions you may want to set up outside of this utility
--		scenarioUndockedCommercialOptions - This allows the scenario writer to add comms 
--			options to the undocked commercial options for the scenario
function commercialOptions()
	local commercial_options_prompt = {
		string.format(_("station-comms","Investigate commercial options at %s"),comms_target:getCallSign()),
		string.format(_("station-comms","Look into %s commercial options"),comms_target:getCallSign()),
		string.format(_("station-comms","Check out %s commercial options"),comms_target:getCallSign()),
		string.format(_("station-comms","Explore commercial options at %s"),comms_target:getCallSign()),
	}
	addCommsReply(tableSelectRandom(commercial_options_prompt),function()
		local out = ""
		if stations_sell_goods then
			if good_desc == nil then
				initializeGoodDescription()
			end
			local good_sale_count = 0
			local good_sale_list = ""
			if comms_target.comms_data.goods ~= nil then
				for good, good_data in pairs(comms_target.comms_data.goods) do
					if good_data.quantity ~= nil and good_data.quantity > 0 then
						good_sale_count = good_sale_count + 1
						if good_sale_list == "" then
							good_sale_list = good_desc[good]
						else
							good_sale_list = string.format("%s, %s",good_sale_list,good_desc[good])
						end
					end
				end
			end
			if good_sale_count > 0 then
				out = string.format(_("station-comms","We sell goods (%s)."),good_sale_list)
				local buy_prompt = {
					string.format(_("station-comms","Buy %s"),good_sale_list),
					string.format(_("station-comms","Buy %s info"),good_sale_list),
					string.format(_("station-comms","Buy %s details"),good_sale_list),
					string.format(_("station-comms","Buy %s report"),good_sale_list),
				}
				addCommsReply(tableSelectRandom(buy_prompt),function()
					local sell_header = {
						_("station-comms","Goods for sale (good name, quantity, reputation cost):"),
						string.format(_("station-comms","List of goods being sold by %s:\n(good name, quantity, reputation cost)"),comms_target:getCallSign()),
						string.format(_("station-comms","%s sells these goods:\n(good name, quantity, reputation cost)"),comms_target:getCallSign()),
						string.format(_("station-comms","You can buy these goods at %s:\n(good name, quantity, reputation cost)"),comms_target:getCallSign()),
					}
					local sell_out = tableSelectRandom(sell_header)
					for good, good_data in pairs(comms_target.comms_data.goods) do
						sell_out = string.format(_("station-comms","%s\n%s, %s, %s"),sell_out,good_desc[good],good_data.quantity,good_data.cost)
					end
					setCommsMessage(sell_out)
					addCommsReply(_("station-comms","Back to investigate commercial options"),function()
						setCommsMessage(out)
						commercialOptions()
					end)
					addCommsReply(_("station-comms","Back to station communication"),commsStation)
				end)
			end
		end
		if stations_buy_goods then
			if comms_target.comms_data.buy ~= nil then
				local good_buy_list = ""
				local match_good_buy_list = ""
				for good, price in pairs(comms_target.comms_data.buy) do
					if good_buy_list == "" then
						good_buy_list = good_desc[good]
					else
						string.format("%s, %s",good_buy_list,good_desc[good])
					end
					if comms_source.goods ~= nil and comms_source.goods[good] ~= nil and comms_source.goods[good] > 0 then
						if match_good_buy_list == "" then
							match_good_buy_list = good_desc[good]
						else
							match_good_buy_list = string.format("%s, %s",match_good_buy_list,good_desc[good])
						end
					end
				end
				if out == "" then
					out = string.format(_("station-comms","We buy goods (%s)."),good_buy_list)
				else
					out = string.format(_("station-comms","%s We buy goods (%s)."),out,good_buy_list)
				end
				local sell_prompt = {
					string.format(_("station-comms","Sell %s"),good_buy_list),
					string.format(_("station-comms","Sell %s info"),good_buy_list),
					string.format(_("station-comms","Sell %s details"),good_buy_list),
					string.format(_("station-comms","Sell %s report"),good_buy_list),
				}
				addCommsReply(tableSelectRandom(sell_prompt),function()
					local buy_header = {
						string.format(_("station-comms","Goods station %s will buy (good name, reputation):"),comms_target:getCallSign()),
						string.format(_("station-comms","List of goods %s will buy:\n(good name, reputation)"),comms_target:getCallSign()),
						string.format(_("station-comms","%s will buy these goods:\n(good name, reputation)"),comms_target:getCallSign()),
						string.format(_("station-comms","You can sell these goods to %s:(good name, reputation)"),comms_target:getCallSign()),
					}
					local buy_out = tableSelectRandom(buy_header)
					for good, price in pairs(comms_target.comms_data.buy) do
						buy_out = string.format(_("station-comms","%s\n%s, %s"),buy_out,good_desc[good],price)
					end
					if match_good_buy_list == "" then
						local no_matching_good_addendum = {
							_("station-comms","You do not have any matching goods in your cargo hold."),
							_("station-comms","Nothing in your cargo hold matches what they want."),
							string.format(_("station-comms","You have nothing in your cargo hold that %s wants"),comms_target:getCallSign()),
							string.format(_("station-comms","%s is not interested in anything in your cargo hold"),comms_target:getCallSign()),
						}
						buy_out = string.format(_("station-comms","%s\n\n%s"),buy_out,tableSelectRandom(no_matching_good_addendum))
					else
						local matching_good_addendum = {
							_("station-comms","Matching goods in your cargo hold"),
							string.format(_("station-comms","%s would buy these goods"),comms_target:getCallSign()),
							string.format(_("station-comms","This cargo matches %s's interests"),comms_target:getCallSign()),
							string.format(_("station-comms","%s is interested in this cargo"),comms_target:getCallSign()),
						}
						buy_out = string.format(_("station-comms","%s\n\n%s: %s"),buy_out,tableSelectRandom(matching_good_addendum),match_good_buy_list)
					end
					setCommsMessage(buy_out)
					addCommsReply(_("station-comms","Back to investigate commercial options"),function()
						setCommsMessage(out)
						commercialOptions()
					end)
					addCommsReply(_("station-comms","Back to station communication"),commsStation)
				end)
			end
		end
		if stations_trade_goods then
			local trade_good_list = ""
			if comms_target.comms_data.trade ~= nil then
				if comms_target.comms_data.trade.food then
					trade_good_list = good_desc["food"]
				end
				if comms_target.comms_data.trade.medicine then
					if trade_good_list == "" then
						trade_good_list = good_desc["medicine"]
					else
						trade_good_list = string.format("%s, %s",trade_good_list,good_desc["medicine"])
					end
				end
				if comms_target.comms_data.trade.luxury then
					if trade_good_list == "" then
						trade_good_list = good_desc["luxury"]
					else
						trade_good_list = string.format("%s, %s",trade_good_list,good_desc["luxury"])
					end
				end
			end
			if trade_good_list ~= "" then
				if out == "" then
					out = string.format(_("station-comms","We trade our goods for %s."),trade_good_list)
				else
					out = string.format(_("station-comms","%s We trade our goods for %s."),out,trade_good_list)
				end
			end
		end
		if stations_support_transport_missions then
			local transport_mission_available = false
			if comms_source.transport_mission == nil then
				transport_mission_available = true
			else
				if comms_source.transport_mission.destination == nil or not comms_source.transport_mission.destination:isValid() then
					transport_mission_available = true
				end
			end
			if characters == nil then
				initializeCharacters()
			end
			if transport_mission_available and #characters > 0 then
				if out == "" then
					out = _("station-comms","We have potential passengers.")
				else
					out = string.format(_("station-comms","%s We have potential passengers."),out)
				end
			end
		end
		if stations_support_cargo_missions then
			local cargo_mission_available = false
			if comms_source.cargo_mission == nil then
				if comms_target.residents ~= nil and #comms_target.residents > 0 then
					cargo_mission_available = true
				end
			else
				if comms_source.cargo_mission.loaded then
					if comms_source.cargo_mission.destination == nil or not comms_source.cargo_mission.destination:isValid() then
						cargo_mission_available = true
					end
				else
					if comms_source.cargo_mission.origin == nil or not comms_source.cargo_mission.origin:isValid() then
						cargo_mission_available = true
					end
				end
			end
			if cargo_mission_available then
				local resident_list = ""
				for i,resident in ipairs(comms_target.residents) do
					if resident_list == "" then
						resident_list = resident
					else
						resident_list = string.format("%s, %s",resident_list,resident)
					end
				end
				if out == "" then
					if #comms_target.residents > 1 then
						out = string.format(_("station-comms","We have residents (%s) wishing to transport cargo."),resident_list)
					else
						out = string.format(_("station-comms","We have a resident (%s) wishing to transport cargo."),resident_list)
					end
				else
					if #comms_target.residents > 1 then
						out = string.format(_("station-comms","%s We have residents (%s) wishing to transport cargo."),out,resident_list)
					else
						out = string.format(_("station-comms","%s We have a resident (%s) wishing to transport cargo."),out,resident_list)
					end
				end
			end
		end
		if out == "" then
			local no_commerce_here = {
				_("station-comms","No commerce options here."),
				_("station-comms","There are no commercial options here."),
				_("station-comms","There's nothing here of commercial interest."),
				_("station-comms","Nothing commercially interesting here."),
			}
			setCommsMessage(tableSelectRandom(no_commerce_here))
		else
			local interest_query_addendum = {
				_("station-comms","What are you interested in?"),
				_("station-comms","Does any of this interest you?"),
				_("station-comms","See anything interesting?"),
				_("station-comms","Are any of these commercial ventures interesting?"),
			}
			setCommsMessage(string.format("%s\n%s",out,tableSelectRandom(interest_query_addendum)))
		end
		if scenarioUndockedCommercialOptions ~= nil then
			scenarioUndockedCommercialOptions()
		end
		if stations_sell_goods or stations_buy_goods then
			local external_commerce = {
				_("station-comms","What about commerce options at other stations?"),
				_("station-comms","Do you know of commercial options at other stations?"),
				_("station-comms","Tell me about commercial ventures at other stations"),
				_("station-comms","How about commerce at other stations?"),
			}
			addCommsReply(tableSelectRandom(external_commerce),function()
				if comms_target.comms_data.friendlyness > 66 then
					if comms_target.comms_data.other_station_commerce == nil then
						comms_target.comms_data.other_station_commerce = {}
						if improvement_mission_stations == nil then
							improvement_mission_stations = {}
							for i,object in ipairs(getAllObjects()) do
								if object:isValid() and object.typeName == "SpaceStation" then
									table.insert(improvement_mission_stations,object)
								end
							end
						end
						local station_pool = {}
						for i,station in ipairs(improvement_mission_stations) do
							if station ~= nil and station:isValid() and station ~= comms_target and not station:isEnemy(comms_source) then
								table.insert(station_pool,station)
							end
						end
						table.insert(comms_target.comms_data.other_station_commerce,tableRemoveRandom(station_pool))
						if comms_target.comms_data.friendlyness > 70 then
							table.insert(comms_target.comms_data.other_station_commerce,tableRemoveRandom(station_pool))
						end
						if comms_target.comms_data.friendlyness > 80 then
							table.insert(comms_target.comms_data.other_station_commerce,tableRemoveRandom(station_pool))
						end
						if comms_target.comms_data.friendlyness > 90 then
							table.insert(comms_target.comms_data.other_station_commerce,tableRemoveRandom(station_pool))
						end
						if comms_target.comms_data.friendlyness > 95 then
							table.insert(comms_target.comms_data.other_station_commerce,tableRemoveRandom(station_pool))
						end
					end
					local other_stations = ""
					for i,station in ipairs(comms_target.comms_data.other_station_commerce) do
						if station ~= nil and station:isValid() then
							local this_station = ""
							if stations_sell_goods then
								local good_sale_count = 0
								local good_sale_list = ""
								if station.comms_data.goods ~= nil then
									for good, good_data in pairs(station.comms_data.goods) do
										if good_data.quantity ~= nil and good_data.quantity > 0 then
											good_sale_count = good_sale_count + 1
											if good_sale_list == "" then
												good_sale_list = good_desc[good]
											else
												good_sale_list = string.format("%s, %s",good_sale_list,good_desc[good])
											end
										end
									end
								end
								if good_sale_count > 0 then
									this_station = string.format(_("station-comms","%s in %s sells %s"),station:getCallSign(),station:getSectorName(),good_sale_list)
								end
							end
							if stations_buy_goods then
								if station.comms_data.buy ~= nil then
									local good_buy_list = ""
									local match_good_buy_list = ""
									if station.comms_data.buy ~= nil then
										for good, price in pairs(station.comms_data.buy) do
											if good_buy_list == "" then
												good_buy_list = good_desc[good]
											else
												string.format("%s, %s",good_buy_list,good_desc[good])
											end
											if comms_source.goods ~= nil and comms_source.goods[good] ~= nil and comms_source.goods[good] > 0 then
												if match_good_buy_list == "" then
													match_good_buy_list = good_desc[good]
												else
													match_good_buy_list = string.format("%s, %s",match_good_buy_list,good_desc[good])
												end
											end
										end
									end
									if this_station == "" then
										this_station = string.format(_("station-comms","%s in %s buys %s"),station:getCallSign(),station:getSectorName(),good_buy_list)
										if match_good_buy_list == "" then
											this_station = string.format(_("station-comms","%s (none in cargo hold)"),this_station)
										else
											this_station = string.format(_("station-comms","%s (%s in cargo hold)"),this_station,match_good_buy_list)
										end
									else
										this_station = string.format(_("station-comms","%s and buys %s"),this_station,good_buy_list)
										if match_good_buy_list == "" then
											this_station = string.format(_("station-comms","%s (none in cargo hold)"),this_station)
										else
											this_station = string.format(_("station-comms","%s (%s in cargo hold)"),this_station,match_good_buy_list)
										end
									end
								end
							end
							local other_commerce_header = {
								_("station-comms","This is what I know about commerce options at other stations:"),
								_("station-comms","Here's what I know about commerce at other stations:"),
								_("station-comms","My knowledge of commercial ventures at other stations consists of:"),
								_("station-comms","Here's my summation of what you can find in the way of commerce at other stations:"),
							}
							if this_station == "" then
								if other_stations == "" then
									other_stations = string.format(_("station-comms","%s\n%s in %s does not buy or sell goods."),tableSelectRandom(other_commerce_header),station:getCallSign(),station:getSectorName())
								else
									other_stations = string.format(_("station-comms","%s\n%s in %s does not buy or sell goods."),other_stations,station:getCallSign(),station:getSectorName())
								end
							else
								if other_stations == "" then
									other_stations = string.format(_("station-comms","%s\n%s."),tableSelectRandom(other_commerce_header),this_station)
								else
									other_stations = string.format(_("station-comms","%s\n%s."),other_stations,this_station)
								end
							end
						end
					end
					if other_stations == "" then
						local commercially_clueless = {
							_("station-comms","I don't know about commerce options at other stations."),
							_("station-comms","I know nothing about commercial options anywhere else."),
							string.format(_("station-comms","I only know about %s. Other stations are too far away."),comms_target:getCallSign()),
							string.format(_("station-comms","My knowledge does not extend beyond %s."),comms_target:getCallSign()),
						}
						setCommsMessage(tableSelectRandom(commercially_clueless))
					else
						setCommsMessage(other_stations)
					end
				else
					local commercially_clueless = {
						_("station-comms","I don't know about commerce options at other stations."),
						_("station-comms","I know nothing about commercial options anywhere else."),
						string.format(_("station-comms","I only know about %s. Other stations are too far away."),comms_target:getCallSign()),
						string.format(_("station-comms","My knowledge does not extend beyond %s."),comms_target:getCallSign()),
					}
					setCommsMessage(tableSelectRandom(commercially_clueless))
				end
				addCommsReply(_("station-comms","Back to investigate commercial options"),function()
					setCommsMessage(out)
					commercialOptions()
				end)
				addCommsReply(_("station-comms","Back to station communication"),commsStation)
			end)
		end
	end)
end
------------------------
--	Docked functions  --
------------------------
function handleDockedState()
	local oMsg = ""
	local friendly_station_greeting_prompt = {
		{thresh = 96,	text = string.format(_("station-comms","Hello, space traveler! It's a pleasure to see %s docking with us. How can we make your stay on %s more comfortable?"),comms_source:getCallSign(),comms_target:getCallSign())},
		{thresh = 92,	text = string.format(_("station-comms","Greetings, cosmic colleague! %s's docking is a cause for celebration here on %s. Any messages or updates to share?"),comms_source:getCallSign(),comms_target:getCallSign())},
		{thresh = 88,	text = string.format(_("station-comms","Good day, starfaring friend! Your arrival is like a cosmic reunion for %s. Any tales from your travels?"),comms_target:getCallSign())},
		{thresh = 84,	text = string.format(_("station-comms","Salutations, fellow communicator! %s has reached %s safe and sound. Anything exciting to share from your journey?"),comms_source:getCallSign(),comms_target:getCallSign())},
		{thresh = 80,	text = string.format(_("station-comms","Hello there! Welcome to %s. It's fantastic to have you on board."),comms_target:getCallSign())},
		{thresh = 76,	text = string.format(_("station-comms","Hello, astral envoy! %s has made a stellar entrance. Any interesting discoveries on your voyage to %s?"),comms_source:getCallSign(),comms_target:getCallSign())},
		{thresh = 72,	text = string.format(_("station-comms","Salutations, space traveler! %s's arrival marks another chapter in %s's cosmic adventures. How can we assist you today?"),comms_source:getCallSign(),comms_target:getCallSign())},
		{thresh = 68,	text = string.format(_("station-comms","Welcome, %s! It's a pleasure to see you docking with %s. How's the cosmic voyage treating you?"),comms_source:getCallSign(),comms_target:getCallSign())},
		{thresh = 64,	text = string.format(_("station-comms","Hello there, %s! Your arrival brings a new energy to %s. How was your journey?"),comms_source:getCallSign(),comms_target:getCallSign())},
		{thresh = 60,	text = string.format(_("station-comms","Greetings, %s! Welcome to our space station. It's an honor to have you on board."),comms_source:getCallSign())},
		{thresh = 56,	text = string.format(_("station-comms","Hello, relay officer. I suppose we should acknowledge the docking of %s, as unremarkable as it may be."),comms_source:getCallSign())},
		{thresh = 52,	text = string.format(_("station-comms","Welcome, spacefaring communicator. %s docks, and the cosmos barely flinches. How typical."),comms_source:getCallSign())},
		{thresh = 48,	text = string.format(_("station-comms","Ah, the celestial messenger has arrived. Do enlighten us with tales of %s's travels, if you must."),comms_source:getCallSign())},
		{thresh = 44,	text = string.format(_("station-comms","Well, well, if it isn't %s. I trust your journey was at least mildly tolerable."),comms_source:getCallSign())},
		{thresh = 40,	text = string.format(_("station-comms","Ah, the starship %s graces us with its presence. How quaint. Welcome to our humble space station."),comms_source:getCallSign())},
		{thresh = 36,	text = string.format(_("station-comms","Welcome, spacefaring communicator. I hope %s's visit won't disrupt %s's delicate equilibrium too much."),comms_source:getCallSign(),comms_target:getCallSign())},
		{thresh = 32,	text = string.format(_("station-comms","Salutations, celestial correspondent. %s's docking disrupted our routine. What urgent message do you bring, if any?"),comms_source:getCallSign())},
		{thresh = 28,	text = string.format(_("station-comms","Hello there, %s. Your arrival was as eagerly anticipated as a space debris collision. What's the news?"),comms_source:getCallSign())},
		{thresh = 24,	text = string.format(_("station-comms","Well, look who decided to drop by. What cosmic inconvenience brings %s to %s today?"),comms_source:getCallSign(),comms_target:getCallSign())},
		{thresh = 20,	text = string.format(_("station-comms","Oh, joy. The starship %s has graced us with their presence. What brings you here?"),comms_source:getCallSign())},
		{thresh = 16,	text = string.format(_("station-comms","Greetings, stellar correspondent. %s's docking is a source of mild irritation. What cosmic drama unfolds now?"),comms_source:getCallSign())},
		{thresh = 12,	text = string.format(_("station-comms","Welcome aboard, cosmic messenger. %s's docking better have a good reason. We have enough on our plate without your cosmic theatrics."),comms_source:getCallSign())},
		{thresh = 8,	text = string.format(_("station-comms","Hello, starbound emissary. %s's presence is less of a pleasure and more of a cosmic headache. What brings you to %s?"),comms_source:getCallSign(),comms_target:getCallSign())},
		{thresh = 4,	text = string.format(_("station-comms","Salutations, interstellar nuisance. %s's docking is the last thing we needed. What pressing crisis are you here to address?"),comms_source:getCallSign())},
	}
	local prompt_index = #friendly_station_greeting_prompt
	for i,prompt in ipairs(friendly_station_greeting_prompt) do
		if comms_target.comms_data.friendlyness > prompt.thresh then
			prompt_index = i
			break
		end
	end
	local prompt_pool = {}
	local lo = prompt_index - 2
	local hi = prompt_index + 2
	if prompt_index >= (#friendly_station_greeting_prompt - 2) then
		lo = #friendly_station_greeting_prompt - 4
		hi = #friendly_station_greeting_prompt
	elseif prompt_index <= 3 then
		lo = 1
		hi = 5
	end
	for i=lo,hi do
		table.insert(prompt_pool,friendly_station_greeting_prompt[i])
	end
	local prompt = tableSelectRandom(prompt_pool)
	oMsg = string.format(_("station-comms","%s Communications Portal\n%s"),comms_target:getCallSign(),prompt.text)
	setCommsMessage(oMsg)
	if handleEnemiesInRange == nil then
		if snub_if_less_friendly then
			if comms_target:isFriendly(comms_source) then
				interactiveDockedStationComms()
			elseif not comms_target:isEnemy(comms_source) then
				if comms_target.comms_data.friendlyness > 15 then
					interactiveDockedStationComms()
				else
					androidDockedStationComms()
				end
			end
		else
			interactiveDockedStationComms()
		end
	else
		local short_range_radar = comms_target:getShortRangeRadarRange()
		local no_relay_panic_responses = {
			_("station-comms","No communication officers available due to station emergency."),
			_("station-comms","Relay officers unavailable during station emergency."),
			_("station-comms","Relay officers reassigned for station emergency."),
			_("station-comms","Station emergency precludes response from relay officer."),
		}
		if comms_target:areEnemiesInRange(short_range_radar/2) then
			if comms_target.comms_data.friendlyness > 10 then
				oMsg = string.format(_("station-comms","%s\n%s"),oMsg,tableSelectRandom(no_relay_panic_responses))
				setCommsMessage(oMsg)
			end
			androidDockedStationComms()
		elseif comms_target:areEnemiesInRange(short_range_radar) then
			if comms_target.comms_data.friendlyness > 70 then
				local quick_relay_responses = {
					_("station-comms","Please be quick. Sensors detect enemies."),
					_("station-comms","I have to go soon since there are enemies nearby."),
					_("station-comms","Talk fast. Enemies approach."),
					_("station-comms","Enemies are coming so talk fast."),
				}
				oMsg = string.format(_("station-comms","%s\n%s"),oMsg,tableSelectRandom(quick_relay_responses))
				setCommsMessage(oMsg)
				interactiveDockedStationComms()
			else
				if comms_target.comms_data.friendlyness > 20 then
					oMsg = string.format(_("station-comms","%s\n%s"),oMsg,tableSelectRandom(no_relay_panic_responses))
					setCommsMessage(oMsg)
				end
				androidDockedStationComms()
			end
		elseif comms_target:areEnemiesInRange(short_range_radar*2) then
			if comms_target.comms_data.friendlyness > 20 then
				if comms_target.comms_data.friendlyness > 60 then
					local distracted_units_responses = {
						string.format(_("station-comms","Please forgive us if we seem distracted. Our sensors detect enemies within %i units"),math.floor(short_range_radar*2/1000)),
						string.format(_("station-comms","Enemies at %i units. Things might get busy soon. Business?"),math.floor(short_range_radar*2/1000)),
						string.format(_("station-comms","A busy day here at %s: Enemies are %s units away and my boss is reviewing emergency procedures. I'm a bit distracted."),comms_target:getCallSign(),math.floor(short_range_radar*2/1000)),
						string.format(_("station-comms","If I seem distracted, it's only because of the enemies showing up at %i units."),math.floor(short_range_radar*2/1000)),
					}
					oMsg = string.format(_("station-comms","%s\n%s"),oMsg,tableSelectRandom(distracted_units_responses))
					setCommsMessage(oMsg)
				elseif comms_target.comms_data.friendlyness > 25 then
					local distracted_responses = {
						_("station-comms","Please forgive us if we seem distracted. Our sensors detect enemies nearby."),
						string.format(_("station-comms","Enemies are close to %s. We might get busy. Business?"),comms_target:getCallSign()),
						_("station-comms","We're quite busy preparing for enemies: evaluating cross training, checking emergency procedures, etc. I'm a little distracted."),
						string.format(_("station-comms","%s is likely going to be attacked soon. Everyone is running around getting ready, distracting me."),comms_target:getCallSign()),
					}
					oMsg = string.format(_("station-comms","%s\n%s"),oMsg,tableSelectRandom(distracted_responses))
					setCommsMessage(oMsg)
				end
				interactiveDockedStationComms()
			else
				androidDockedStationComms()
			end
		else
			if snub_if_less_friendly then
				if comms_target:isFriendly(comms_source) then
					interactiveDockedStationComms()
				elseif not comms_target:isEnemy(comms_source) then
					if comms_target.comms_data.friendlyness > 15 then
						interactiveDockedStationComms()
					else
						androidDockedStationComms()
					end
				end
			else
				interactiveDockedStationComms()
			end
		end
	end
end
--	Booleans to set outside of this utility to control this utility. Default is false
--		current_orders_button - set true if players can check with stations to get their
--			current orders.
--		defense_fleet_button - set true if players can launch station defense fleet
--		stations_sell_goods - set true if stations sell goods to players for reputation
--		stations_buy_goods - set true if stations buy goods from players for reputation
--		stations_trade_goods - set true if station will trade one good for another
--			Note: trade usually does not work well unless at least sell is enabled
function androidDockedStationComms()
	addCommsReply(_("station-comms","Automated station communication"),function()
		local comms_option_presented = false
		setCommsMessage(_("station-comms","Select:"))
		stationStatusReport()
		if current_orders_button then
			if comms_target:isFriendly(comms_source) then
				comms_option_presented = true
				getCurrentOrders()
			end
		end
		if defense_fleet_button then
			if isAllowedTo(comms_target.comms_data.services.activatedefensefleet) then
				comms_option_presented = true
				stationDefenseFleet()
			end
		end
		if stations_sell_goods or stations_buy_goods or stations_trade_goods then
			if comms_source.goods ~= nil then
				if good_desc == nil then
					initializeGoodDescription()
				end
				local good_count = 0
				for good, good_quantity in pairs(comms_source.goods) do
					good_count = good_count + good_quantity
				end
				if good_count > 0 then
					local deposit_goods_prompt = {
						_("station-comms","Place goods in deposit hatch"),
						_("station-comms","Put goods in hatch marked 'deposits'"),
						_("station-comms","Insert goods in external deposit hatch"),
						string.format(_("station-comms","Put goods in %s's external storage facility"),comms_target:getCallSign()),
					}
					addCommsReply(tableSelectRandom(deposit_goods_prompt),giveGoodsToStation)
					comms_option_presented = true
				end
			end
		end
		if not comms_option_presented then
			local no_automation_responses = {
				_("station_comms","Android malfunction"),
				_("station_comms","Computer malfunction"),
				_("station_comms","Call back later (like maybe never)"),
				_("station_comms","...Zzzt..."),
			}
			setCommsMessage(tableSelectRandom(no_automation_responses))
		end
		addCommsReply(_("Back"), commsStation)
	end)
end
function giveGoodsToStation()
	local donate_prompt = {
		_("trade-comms","What should we give to the station?"),
		_("trade-comms","What should we give to the station out of the goodness of our heart?"),
		_("trade-comms","What should we donate to the station?"),
		_("trade-comms","What can we give the station that will help them the most?"),
	}
	setCommsMessage(tableSelectRandom(donate_prompt))
	local goods_to_give_count = 0
	for good, good_quantity in pairs(comms_source.goods) do
		if good_quantity > 0 then
			goods_to_give_count = goods_to_give_count + 1
			addCommsReply(good_desc[good], function()
				string.format("")
				comms_source.goods[good] = comms_source.goods[good] - 1
				comms_source.cargo = comms_source.cargo + 1
				local want_it = false
				if comms_target.comms_data.buy ~= nil then
					for good_buy, price in pairs(comms_target.comms_data.buy) do
						if good == good_buy then
							comms_target.comms_data.friendlyness = math.min(100,comms_target.comms_data.friendlyness + price/2)
							comms_source:addReputationPoints(math.floor(price/2))
							want_it = true
							break
						end
					end
				end
				if not want_it then
					comms_target.comms_data.friendlyness = math.min(100,comms_target.comms_data.friendlyness + random(3,9))
				end
				local donated_confirmed = {
					string.format(_("trade-comms","One %s donated"),good_desc[good]),
					string.format(_("trade-comms","We gave one %s to %s"),good_desc[good],comms_target:getCallSign()),
					string.format(_("trade-comms","We donated a %s"),good_desc[good]),
					string.format(_("trade-comms","We provided %s with one %s"),comms_target:getCallSign(),good_desc[good]),
				}
				setCommsMessage(tableSelectRandom(donated_confirmed))
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end
	if goods_to_give_count == 0 then
		local out_of_goods = {
			_("trade-comms","No more goods to donate"),
			_("trade-comms","There is nothing left in the cargo hold to donate"),
			_("trade-comms","You've got nothing more available to donate"),
			_("trade-comms","Your cargo hold is empty, so you cannot donate anything else"),
		}
		setCommsMessage(tableSelectRandom(out_of_goods))
		addCommsReply(_("Back"), commsStation)
	end
	addCommsReply(_("Back"), commsStation)
end
--	Booleans to set outside of this utility to control this utility. Default is false
--		stations_repair_ships - set true if players can get repairs from stations. Implies
--			that ships can take non-standard damage
--		stations_improve_ships - set true if players can get major or minor ship upgrades
--			from stations
--		stations_sell_goods - set true if stations sell goods to players for reputation
--		stations_buy_goods - set true if stations buy goods from players for reputation
--		stations_trade_goods - set true if station will trade one good for another
--			Note: trade usually does not work well unless at least sell is enabled
function interactiveDockedStationComms()
	local information_prompts = {
		_("station-comms","Information"),
		_("station-comms","I need information"),
		_("station-comms","Ask questions"),
		_("station-comms","I need to know what you know"),
	}
	addCommsReply(tableSelectRandom(information_prompts),stationInformation)
	local dispatch_prompts = {
		_("station-comms","Dispatch office"),
		_("station-comms","Visit the dispatch office"),
		_("station-comms","Check on possible missions"),
		_("station-comms","Start or complete a mission"),
	}
	addCommsReply(tableSelectRandom(dispatch_prompts),dispatchOffice)
	local restock_prompts = {
		_("station-comms","Restock ship"),
		string.format(_("station-comms","Restock %s"),comms_source:getCallSign()),
		_("station-comms","Refill ordnance and other things on the ship"),
		string.format(_("station-comms","Replenish supplies on %s"),comms_source:getCallSign()),
	}
	addCommsReply(tableSelectRandom(restock_prompts),restockShip)
	if stations_repair_ships then
		local repair_ship_prompts = {
			_("station-comms","Repair ship"),
			string.format(_("station-comms","Repair %s"),comms_source:getCallSign()),
			_("station-comms","Fix broken things on the ship"),
			string.format(_("station-comms","Conduct repairs on %s"),comms_source:getCallSign()),
		}
		addCommsReply(tableSelectRandom(repair_ship_prompts),repairShip)
	end
	if stations_improve_ships then
		local enhance_ship_prompts = {
			_("station-comms","Enhance ship"),
			string.format(_("station-comms","Enhance %s"),comms_source:getCallSign()),
			_("station-comms","Make improvements to ship"),
			string.format(_("station-comms","Improve %s's capabilities"),comms_source:getCallSign()),
		}
		addCommsReply(tableSelectRandom(enhance_ship_prompts),enhanceShip)
	end
	if isAllowedTo(comms_target.comms_data.services.activatedefensefleet) then
		stationDefenseFleet()
	end
	if stations_sell_goods or stations_buy_goods or stations_trade_goods then
		local goods_commerce_prompts = {
			_("station-comms","Buy, sell, trade goods, etc."),
			_("station-comms","Buy, sell, trade, etc."),
			_("station-comms","Goods commerce, etc."),
			_("station-comms","Buy, sell, trade, donate, jettison goods"),
		}
		addCommsReply(tableSelectRandom(goods_commerce_prompts),goodsCommerce)
	end
end
--	Booleans to set outside of this utility to control this utility. Default is false
--		current_orders_button - set true if players can check with stations to get their
--			current orders.
--		stellar_cartography_button - set true if stations support stellar cartography
--		station_gossip - set true if stations gossip about stuff
--		station_general_information - set true if stations talk about themselves
--		station_history - set true if stations provide history about themselves
--	Functions you may want to set up outside of this utility
--		scenarioInformation - a function where the scenario writer can insert comms
--			to provide information about the scenario: clues, hints, background, etc.
function stationInformation()
	local information_type_prompt = {
		_("station-comms","What kind of information do you want?"),
		_("station-comms","What kind of information do you need?"),
		_("station-comms","What kind of information do you seek?"),
		_("station-comms","What kind of information are you looking for?"),
		_("station-comms","What kind of information are you interested in?"),
	}
	setCommsMessage(tableSelectRandom(information_type_prompt))
	stationStatusReport()
	if current_orders_button then
		if comms_target:isFriendly(comms_source) then
			getCurrentOrders()
		elseif comms_target.comms_data.friendlyness > 50 then
			getCurrentOrders()
		end
	end
	if stellar_cartography_button then
		stellarCartography()
	end
	if station_gossip or station_general_information or station_history then
		stationTalk()
	end
	if scenarioInformation ~= nil then
		scenarioInformation()
	end
end
function stellarCartography()
	addCommsReply(_("cartographyOffice-comms","Visit cartography office"), function()
		if comms_target.cartographer_description == nil then
			local clerk = {
				_("cartographyOffice-comms","The clerk behind the desk looks up briefly at you then goes back to filing her nails."),
				_("cartographyOffice-comms","The clerk behind the desk examines you then returns to grooming her tentacles."),
				_("cartographyOffice-comms","The clerk behind the desk glances at you then returns to preening her feathers."),
				_("cartographyOffice-comms","The clerk behind the desk pauses, points a cluster of antennae at you, then continues manipulating an elaborate keyboard."),
			}
			comms_target.cartographer_description = clerk[math.random(1,#clerk)]
		end
		local cartography_option_list = {
			_("cartographyOffice-comms","You can examine the virtual brochure on the coffee table, talk to the apprentice cartographer or talk to the master cartographer"),
			_("cartographyOffice-comms","You may read the virtual brochure on the coffee table, talk to the apprentice cartographer or talk to the master cartographer"),
			_("cartographyOffice-comms","You can look at the virtual brochure on the coffee table, speak with the apprentice cartographer or seek an audience with the master cartographer"),
			_("cartographyOffice-comms","Options: Examine the virtual brochure at the kiosk, talk to the apprentice cartographer, or talk to the master cartographer"),
		}
		setCommsMessage(string.format("%s\n\n%s",comms_target.cartographer_description,tableSelectRandom(cartography_option_list)))
		local cartography_skill_difference_prompts = {
			_("cartographyOffice-comms","What's the difference between the apprentice and the master?"),
			_("cartographyOffice-comms","Why both an apprentice and a master?"),
			_("cartographyOffice-comms","Apprentice, master... what's the difference?"),
			_("cartographyOffice-comms","Why choose between apprentice and master?"),
		}
		addCommsReply(tableSelectRandom(cartography_skill_difference_prompts), function()
			local cartography_differences_explanation = {
				_("cartographyOffice-comms","The clerk responds in a bored voice, 'The apprentice knows the local area and is learning the broader area. The master knows the local and the broader area but can't be bothered with the local area.'"),
				_("cartographyOffice-comms","The clerk pipes up enthusiastically, 'The apprentice knows the local area and is learning the broader area. The master knows the local and the broader area but feels as if the local area is beneath notice. You pay more to gain knowledge of the broader area.'"),
				_("cartographyOffice-comms","The clerk points to a sign on the wall that reads, 'The apprentice knows the local area and is learning the broader area. The master knows the local and the broader area but defers inquiries about the local area to the apprentice.'"),
				_("cartographyOffice-comms","The clerk responds in a neutral voice, 'The apprentice knows the local area and is learning the broader area. The master knows the local and the broader area but can't be bothered with the local area. I trust you feel much more enlightened now.'"),
			}
			setCommsMessage(tableSelectRandom(cartography_differences_explanation))
			addCommsReply(_("Back"), commsStation)
		end)
		local brochure_prompts = {
			string.format(_("cartographyOffice-comms","Examine brochure (%i reputation)"),getCartographerCost()),
			string.format(_("cartographyOffice-comms","Look at brochure (%i reputation)"),getCartographerCost()),
			string.format(_("cartographyOffice-comms","View brochure (%i reputation)"),getCartographerCost()),
			string.format(_("cartographyOffice-comms","Read brochure (%i reputation)"),getCartographerCost()),
		}
		addCommsReply(tableSelectRandom(brochure_prompts),function()
			stellarCartographyBrochure()
			addCommsReply(_("Back"), commsStation)
		end)
		if comms_target.comms_data.friendlyness > 50 then
			local talk_to_apprentice_prompts = {
				string.format(_("cartographyOffice-comms","Talk to apprentice cartographer (%i reputation)"),getCartographerCost("apprentice")),
				string.format(_("cartographyOffice-comms","Speak to apprentice cartographer (%i reputation)"),getCartographerCost("apprentice")),
				string.format(_("cartographyOffice-comms","Meet with apprentice cartographer (%i reputation)"),getCartographerCost("apprentice")),
				string.format(_("cartographyOffice-comms","Talk to apprentice (%i reputation)"),getCartographerCost("apprentice")),
			}
			addCommsReply(tableSelectRandom(talk_to_apprentice_prompts), function()
				if comms_source:takeReputationPoints(getCartographerCost("apprentice")) then
					local apprentice_stations_or_goods = {
						_("cartographyOffice-comms","Hi, would you like for me to locate a station or some goods for you?"),
						_("cartographyOffice-comms","Hello, would you like me to locate a station or some goods for you?"),
						_("cartographyOffice-comms","Greetings, are you more interested in stations or goods?"),
						_("cartographyOffice-comms","Hi, would you prefer for me to locate a station or some goods for you?"),
					}
					setCommsMessage(tableSelectRandom(apprentice_stations_or_goods))
					local apprentice_station_prompts = {
						_("cartographyOffice-comms","Locate station"),
						_("cartographyOffice-comms","Locate station, please"),
						_("cartographyOffice-comms","I'd like for you to locate a station"),
						_("cartographyOffice-comms","I prefer a station location"),
					}
					addCommsReply(tableSelectRandom(apprentice_station_prompts), function()
						local apprentice_station_list = {
							_("cartographyOffice-comms","These are stations I have learned about"),
							_("cartographyOffice-comms","My lessons covered these stations"),
							_("cartographyOffice-comms","I know about these stations"),
							_("cartographyOffice-comms","These are the stations I know about"),
						}
						setCommsMessage(tableSelectRandom(apprentice_station_list))
						local sx, sy = comms_target:getPosition()
						local nearby_objects = getObjectsInRadius(sx,sy,50000)
						local stations_known = 0
						for i, obj in ipairs(nearby_objects) do
							if obj.typeName == "SpaceStation" then
								if not obj:isEnemy(comms_source) then
									stations_known = stations_known + 1
									addCommsReply(obj:getCallSign(),function()
										local station_details = string.format(_("cartographyOffice-comms","%s %s %s"),obj:getSectorName(),obj:getFaction(),obj:getCallSign())
										if obj.comms_data.orbit ~= nil then
											station_details = string.format(_("cartographyOffice-comms","%s %s"),station_details,obj.comms_data.orbit)
										end
										if obj.comms_data.goods ~= nil then
											station_details = string.format(_("cartographyOffice-comms","%s\nGood, quantity, cost"),station_details)
											for good, good_data in pairs(obj.comms_data.goods) do
												station_details = string.format(_("cartographyOffice-comms","%s\n   %s, %i, %i"),station_details,good_desc[good],good_data["quantity"],good_data["cost"])
											end
										end
										if obj.comms_data.general_information ~= nil then
											station_details = string.format(_("stationGeneralInfo-comms","%s\nGeneral Information:\n   %s"),station_details,obj.comms_data.general_information)
										end
										if obj.comms_data.history ~= nil then
											station_details = string.format(_("stationStory-comms","%s\nHistory:\n   %s"),station_details,obj.comms_data.history)
										end
										if obj.comms_data.gossip ~= nil then
											station_details = string.format(_("gossip-comms","%s\nGossip:\n   %s"),station_details,obj.comms_data.gossip)
										end
										setCommsMessage(station_details)
										addCommsReply(_("Back"), commsStation)
									end)
								end
							end
						end
						if stations_known == 0 then
							local apprentice_knows_nothing = {
								_("cartographyOffice-comms","I have learned of no stations yet."),
								_("cartographyOffice-comms","I have not learned of any stations yet."),
								_("cartographyOffice-comms","My lessons have not covered stations yet."),
								_("cartographyOffice-comms","I don't know of any stations. We have not gotten that far yet."),
							}
							setCommsMessage(tableSelectRandom(apprentice_knows_nothing))
						end
						addCommsReply(_("Back"), commsStation)
					end)
					local apprentice_locate_goods_prompts = {
						_("cartographyOffice-comms","Locate goods"),
						_("cartographyOffice-comms","Locate goods, please"),
						_("cartographyOffice-comms","I'd like for you to locate goods"),
						_("cartographyOffice-comms","I prefer goods locations"),
					}
					addCommsReply(tableSelectRandom(apprentice_locate_goods_prompts), function()
						local apprentice_goods_list = {
							_("cartographyOffice-comms","These are the goods I know about"),
							_("cartographyOffice-comms","My lessons covered these goods"),
							_("cartographyOffice-comms","I know about these goods"),
							_("cartographyOffice-comms","These are the goods I have learned about"),
						}
						setCommsMessage(tableSelectRandom(apprentice_goods_list))
						local sx, sy = comms_target:getPosition()
						local nearby_objects = getObjectsInRadius(sx,sy,50000)
						local button_count = 0
						local by_goods = {}
						for i, obj in ipairs(nearby_objects) do
							if obj.typeName == "SpaceStation" then
								if not obj:isEnemy(comms_target) then
									if obj.comms_data.goods ~= nil then
										for good, good_data in pairs(obj.comms_data.goods) do
											by_goods[good] = obj
										end
									end
								end
							end
						end
						for good, obj in pairs(by_goods) do
							addCommsReply(good_desc[good], function()
								local station_details = string.format(_("cartographyOffice-comms","%s %s %s"),obj:getSectorName(),obj:getFaction(),obj:getCallSign())
								if obj.comms_data.orbit ~= nil then
									station_details = string.format(_("cartographyOffice-comms","%s %s"),station_details,obj.comms_data.orbit)
								end
								if obj.comms_data.goods ~= nil then
									station_details = string.format(_("cartographyOffice-comms","%s\nGood, quantity, cost"),station_details)
									for good, good_data in pairs(obj.comms_data.goods) do
										station_details = string.format(_("cartographyOffice-comms","%s\n   %s, %i, %i"),station_details,good_desc[good],good_data["quantity"],good_data["cost"])
									end
								end
								if obj.comms_data.general_information ~= nil then
									station_details = string.format(_("stationGeneralInfo-comms","%s\nGeneral Information:\n   %s"),station_details,obj.comms_data.general_information)
								end
								if obj.comms_data.history ~= nil then
									station_details = string.format(_("stationStory-comms","%s\nHistory:\n   %s"),station_details,obj.comms_data.history)
								end
								if obj.comms_data.gossip ~= nil then
									station_details = string.format(_("gossip-comms","%s\nGossip:\n   %s"),station_details,obj.comms_data.gossip)
								end
								setCommsMessage(station_details)
								addCommsReply(_("Back"), commsStation)
							end)
							button_count = button_count + 1
							if button_count >= 20 then
								break
							end
						end
						if button_count == 0 then
							local apprentice_knows_nothing = {
								_("cartographyOffice-comms","I have learned of no stations yet."),
								_("cartographyOffice-comms","I have not learned of any stations yet."),
								_("cartographyOffice-comms","My lessons have not covered stations yet."),
								_("cartographyOffice-comms","I don't know of any stations. We have not gotten that far yet."),
							}
							setCommsMessage(tableSelectRandom(apprentice_knows_nothing))
						end
						addCommsReply(_("Back"), commsStation)
					end)
				else
					local insufficient_rep_responses = {
						_("needRep-comms","Insufficient reputation"),
						_("needRep-comms","Not enough reputation"),
						_("needRep-comms","You need more reputation"),
						string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
						_("needRep-comms","You don't have enough reputation"),
						string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
					}
					setCommsMessage(tableSelectRandom(insufficient_rep_responses))
				end
				addCommsReply(_("Back"), commsStation)
			end)
		end
		if comms_target.comms_data.friendlyness > 75 or (comms_target.comms_data.friendlyness > 25 and comms_target.comms_data.friendlyness < 50) then
			local talk_to_master_prompts = {
				string.format(_("cartographyOffice-comms","Talk to master cartographer (%i reputation)"),getCartographerCost("master")),
				string.format(_("cartographyOffice-comms","Speak to master cartographer (%i reputation)"),getCartographerCost("master")),
				string.format(_("cartographyOffice-comms","Meet with master cartographer (%i reputation)"),getCartographerCost("master")),
				string.format(_("cartographyOffice-comms","Talk to master (%i reputation)"),getCartographerCost("master")),
			}
			addCommsReply(tableSelectRandom(talk_to_master_prompts), function()
				if comms_source:getWaypointCount() >= 9 then
					local no_waypoint_warning = {
						_("cartographyOffice-comms","The clerk clears her throat:\n\nMy indicators show you have zero available waypoints. To get the most from the master cartographer, you should delete one or more so that he can update your systems appropriately.\n\nI just want you to get the maximum benefit for the time you spend with him"),
						_("cartographyOffice-comms","The clerk subtly gets your attention:\n\nMy indicators show you have zero available waypoints. To get the most from the master cartographer, you should delete one or more so that he can update your systems appropriately.\n\nI just want you to get the maximum benefit for the time you spend with him"),
						string.format(_("cartographyOffice-comms","The clerk clears her throat:\n\nMy information on %s show you have zero available waypoints. To get the most from the master cartographer, you should delete one or more so that he can update your systems appropriately.\n\nI just want you to get the maximum benefit for the time you spend with him"),comms_source:getCallSign()),
						string.format(_("cartographyOffice-comms","The clerk clears her throat:\n\n%s has zero available waypoints. To get the most from the master cartographer, you should delete one or more so that he can update your systems appropriately.\n\nI just want you to get the maximum benefit for the time you spend with him"),comms_source:getCallSign()),
					}
					setCommsMessage(tableSelectRandom(no_waypoint_warning))
					local ignore_warning = {
						_("cartographyOffice-comms","Continue to master cartographer"),
						_("cartographyOffice-comms","Ignore warning. Continue to master cartographer"),
						_("cartographyOffice-comms","I know what I'm doing. Continue to master"),
						_("cartographyOffice-comms","Don't care. Continue to master cartographer"),
					}
					addCommsReply(tableSelectRandom(ignore_warning), masterCartographer)
				else
					masterCartographer()
				end
				addCommsReply(_("Back"), commsStation)
			end)
		end
		addCommsReply(_("Back"), commsStation)
	end)	
end
function masterCartographer()
	if comms_source:takeReputationPoints(getCartographerCost("master")) then
		local master_stations_or_goods = {
			_("cartographyOffice-comms","Greetings,\nMay I help you find a station or goods?"),
			_("cartographyOffice-comms","Hello,\nWould you like me to locate a station or some goods for you?"),
			_("cartographyOffice-comms","Salutations,\nAre you more interested in stations or goods?"),
			_("cartographyOffice-comms","Greetings,\nWould you prefer for me to locate a station or some goods for you?"),
		}
		setCommsMessage(tableSelectRandom(master_stations_or_goods))
		local master_station_prompts = {
			_("cartographyOffice-comms","Find station"),
			_("cartographyOffice-comms","Locate station, please"),
			_("cartographyOffice-comms","I'd like for you to find a station"),
			_("cartographyOffice-comms","I prefer a station location"),
		}
		addCommsReply(tableSelectRandom(master_station_prompts), function()
			local master_station_list = {
				_("cartographyOffice-comms","What station?"),
				_("cartographyOffice-comms","Which station?"),
				_("cartographyOffice-comms","Choose a station"),
				_("cartographyOffice-comms","Pick a station"),
			}
			setCommsMessage(tableSelectRandom(master_station_list))
			local nearby_objects = getAllObjects()
			local stations_known = 0
			for i, obj in ipairs(nearby_objects) do
				if obj.typeName == "SpaceStation" then
					if not obj:isEnemy(comms_source) then
						local station_distance = distance(comms_target,obj)
						if station_distance > 50000 then
							stations_known = stations_known + 1
							addCommsReply(obj:getCallSign(),function()
								local station_details = string.format(_("cartographyOffice-comms","%s %s %s Distance:%.1fU"),obj:getSectorName(),obj:getFaction(),obj:getCallSign(),station_distance/1000)
								if obj.comms_data.orbit ~= nil then
									station_details = string.format(_("cartographyOffice-comms","%s %s"),station_details,obj.comms_data.orbit)
								end
								if obj.comms_data.goods ~= nil then
									station_details = string.format(_("cartographyOffice-comms","%s\nGood, quantity, cost"),station_details)
									for good, good_data in pairs(obj.comms_data.goods) do
										station_details = string.format(_("cartographyOffice-comms","%s\n   %s, %i, %i"),station_details,good_desc[good],good_data["quantity"],good_data["cost"])
									end
								end
								if obj.comms_data.general_information ~= nil then
									station_details = string.format(_("stationGeneralInfo-comms","%s\nGeneral Information:\n   %s"),station_details,obj.comms_data.general_information)
								end
								if obj.comms_data.history ~= nil then
									station_details = string.format(_("stationStory-comms","%s\nHistory:\n   %s"),station_details,obj.comms_data.history)
								end
								if obj.comms_data.gossip ~= nil then
									station_details = string.format(_("gossip-comms","%s\nGossip:\n   %s"),station_details,obj.comms_data.gossip)
								end
								local dsx, dsy = obj:getPosition()
								comms_source:commandAddWaypoint(dsx,dsy)
								station_details = string.format(_("cartographyOffice-comms","%s\nAdded waypoint %i to your navigation system for %s"),station_details,comms_source:getWaypointCount(),obj:getCallSign())
								if obj.comms_data.orbit ~= nil then
									station_details = string.format(_("cartographyOffice-comms","%s\nNote: this waypoint will be out of date shortly since %s is in motion"),station_details,obj:getCallSign())
								end
								setCommsMessage(station_details)
								addCommsReply(_("Back"), commsStation)
							end)
						end
					end
				end
			end
			if stations_known == 0 then
				local no_stations_from_master = {
					_("cartographyOffice-comms","Try the apprentice, I'm tired"),
					_("cartographyOffice-comms","Try the apprentice, I'm busy"),
					_("cartographyOffice-comms","Try the apprentice, I have other priorities"),
					_("cartographyOffice-comms","Try the apprentice, I can't be bothered right now"),
				}
				setCommsMessage(tableSelectRandom(no_stations_from_master))
			end
			addCommsReply(_("Back"), commsStation)
		end)
		local master_locate_goods_prompts = {
			_("cartographyOffice-comms","Locate goods"),
			_("cartographyOffice-comms","Find goods, please"),
			_("cartographyOffice-comms","I'd like for you to find goods"),
			_("cartographyOffice-comms","I prefer goods locations"),
		}
		addCommsReply(tableSelectRandom(master_locate_goods_prompts), function()
			local master_goods_list = {
				_("cartographyOffice-comms","What goods are you looking for?"),
				_("cartographyOffice-comms","Do any of these goods strike your fancy?"),
				_("cartographyOffice-comms","Are you interested in any of these goods?"),
				_("cartographyOffice-comms","What about these goods?"),
			}
			setCommsMessage(tableSelectRandom(master_goods_list))
			local nearby_objects = getAllObjects()
			local by_goods = {}
			for i, obj in ipairs(nearby_objects) do
				if obj.typeName == "SpaceStation" then
					if not obj:isEnemy(comms_target) then
						local station_distance = distance(comms_target,obj)
						if station_distance > 50000 then
							if obj.comms_data.goods ~= nil then
								for good, good_data in pairs(obj.comms_data.goods) do
									by_goods[good] = obj
								end
							end
						end
					end
				end
			end
			if good_desc == nil then
				initializeGoodDescription()
			end
			for good, obj in pairs(by_goods) do
				addCommsReply(good_desc[good], function()
					local station_distance = distance(comms_target,obj)
					local station_details = string.format(_("cartographyOffice-comms","%s %s %s Distance:%.1fU"),obj:getSectorName(),obj:getFaction(),obj:getCallSign(),station_distance/1000)
					if obj.comms_data.orbit ~= nil then
						station_details = string.format(_("cartographyOffice-comms","%s %s"),station_details,obj.comms_data.orbit)
					end
					if obj.comms_data.goods ~= nil then
						station_details = string.format(_("cartographyOffice-comms","%s\nGood, quantity, cost"),station_details)
						for good, good_data in pairs(obj.comms_data.goods) do
							station_details = string.format(_("cartographyOffice-comms","%s\n   %s, %i, %i"),station_details,good_desc[good],good_data["quantity"],good_data["cost"])
						end
					end
					if obj.comms_data.general_information ~= nil then
						station_details = string.format(_("stationGeneralInfo-comms","%s\nGeneral Information:\n   %s"),station_details,obj.comms_data.general_information)
					end
					if obj.comms_data.history ~= nil then
						station_details = string.format(_("stationStory-comms","%s\nHistory:\n   %s"),station_details,obj.comms_data.history)
					end
					if obj.comms_data.gossip ~= nil then
						station_details = string.format(_("gossip-comms","%s\nGossip:\n   %s"),station_details,obj.comms_data.gossip)
					end
					local dsx, dsy = obj:getPosition()
					comms_source:commandAddWaypoint(dsx,dsy)
					station_details = string.format(_("cartographyOffice-comms","%s\nAdded waypoint %i to your navigation system for %s"),station_details,comms_source:getWaypointCount(),obj:getCallSign())
					if obj.comms_data.orbit ~= nil then
						station_details = string.format(_("cartographyOffice-comms","%s\nNote: this waypoint will be out of date shortly since %s is in motion"),station_details,obj:getCallSign())
					end
					setCommsMessage(station_details)
					addCommsReply(_("Back"), commsStation)
				end)
			end
			addCommsReply(_("Back"), commsStation)
		end)
	else
		local insufficient_rep_responses = {
			_("needRep-comms","Insufficient reputation"),
			_("needRep-comms","Not enough reputation"),
			_("needRep-comms","You need more reputation"),
			string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
			_("needRep-comms","You don't have enough reputation"),
			string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
		}
		setCommsMessage(tableSelectRandom(insufficient_rep_responses))
	end
end
--	Booleans to set outside of this utility to control this utility. Default is false
--		station_gossip - set true if stations gossip about stuff
--		station_general_information - set true if stations talk about themselves
--		station_history - set true if stations provide history about themselves
function stationTalk()
	addCommsReply(_("station-comms","I'm not sure. What do you know?"),function()
		local knowledge_talk_prompt = {
			_("station-comms","I know about the following:"),
			_("station-comms","I know these things:"),
			_("station-comms","I can tell you about the following:"),
			_("station-comms","We could talk about..."),
		}
		setCommsMessage(tableSelectRandom(knowledge_talk_prompt))
		local knowledge_count = 0
		if station_gossip then
			if comms_target.comms_data.gossip ~= nil then
				if comms_target.comms_data.friendlyness > 50 + (difficulty * 15) then
					knowledge_count = knowledge_count + 1
					stationGossip()
				end
			end
		end
		if station_general_information then
			if comms_target.comms_data.general ~= nil then
				knowledge_count = knowledge_count + 1
				stationGeneralInformation()
			end
		end
		if station_history then
			if comms_target.comms_data.history ~= nil then
				knowledge_count = knowledge_count + 1
				stationHistory()
			end
		end
		if knowledge_count == 0 then
			local lack_of_knowledge_response = {
				_("station-comms","I have no additional knowledge."),
				_("station-comms","I don't know enough to talk about anything."),
				_("station-comms","Nothing interesting."),
			}
			setCommsMessage(tableSelectRandom(lack_of_knowledge_response))
		end
	end)
end
function stationGossip()
	local gossip_prompts = {
		_("gossip-comms","Gossip"),
		_("gossip-comms","What dirty little secrets can you share?"),
		_("gossip-comms","I'm looking for inside information"),
		_("gossip-comms","Got any juicy tidbits?"),
	}
	addCommsReply(tableSelectRandom(gossip_prompts), function()
		setCommsMessage(comms_target.comms_data.gossip)
		addCommsReply(_("Back"), commsStation)
	end)
end
function stationGeneralInformation()
	local general_information_prompts = {
		_("stationGeneralInfo-comms","General information"),
		_("stationGeneralInfo-comms","Regular information"),
		_("stationGeneralInfo-comms","Standard information"),
		_("stationGeneralInfo-comms","The usual information"),
	}
	addCommsReply(tableSelectRandom(general_information_prompts), function()
		setCommsMessage(comms_target.comms_data.general)
		addCommsReply(_("Back"), commsStation)
	end)
end
function stationHistory()
	local history_prompts = {
		_("stationStory-comms","Station history"),
		_("stationStory-comms","Station historical archives"),
		string.format(_("stationStory-comms","%s history"),comms_target:getCallSign()),
		string.format(_("stationStory-comms","Historical information on %s"),comms_target:getCallSign()),
	}
	addCommsReply(tableSelectRandom(history_prompts), function()
		if comms_target.comms_data.history == nil or comms_target.comms_data.history == "" then
			local no_history_responses = {
				_("stationStory-comms","No history available"),
				_("stationStory-comms","No history recorded"),
				string.format(_("stationStory-comms","%s has no recorded history"),comms_target:getCallSign()),
				string.format(_("stationStory-comms","No history for %s"),comms_target:getCallSign()),
			}
			setCommsMessage(tableSelectRandom(no_history_responses))
		else
			setCommsMessage(comms_target.comms_data.history)
		end
		addCommsReply(_("Back"), commsStation)
	end)
end
--	Booleans to set outside of this utility to control this utility. Default is false
--		stations_support_transport_missions - set true if stations handle transport missions
--		stations_support_cargo_missions - set true if stations handle cargo missions
--			Note: cargo missions usually require transport missions
--	Functions you may want to set up outside of this utility
--		scenarioMissions - returns a number representing how many addCommsReply options
--			were given to the user. This allows the scenario writer to add situational 
--			comms options to the dispatch office for the scenario
function dispatchOffice()
	local mission_select_prompts = {
		_("station-comms","Which of these missions and/or tasks are you interested in?"),
		_("station-comms","Are you interested in any of thises missions/tasks?"),
		_("station-comms","You may select from one of these missions or tasks:"),
		_("station-comms","Do any of these missions or tasks interest you?"),
	}
	setCommsMessage(tableSelectRandom(mission_select_prompts))
	local improvements = {}
	local msg = ""
	msg, improvements = catalogImprovements(msg)
	if #improvements > 0 and (comms_target.comms_data.friendlyness > 33 or comms_source:isDocked(comms_target)) then
		improveStationService(improvements)
	end
	local mission_options_presented_count = #improvements
	local transport_and_cargo_mission_count = 0
	if stations_support_transport_missions or stations_support_cargo_missions then
		transport_and_cargo_mission_count = transportAndCargoMissions()
	end
	mission_options_presented_count = mission_options_presented_count + transport_and_cargo_mission_count
	if scenarioMissions ~= nil then
		local scenario_permission_option_count = scenarioMissions()
		mission_options_presented_count = mission_options_presented_count + scenario_permission_option_count
	end
	if mission_options_presented_count == 0 then
		local no_missions_responses = {
			_("station-comms","No missions or tasks available here."),
			string.format(_("station-comms","No missions or tasks are available here at %s."),comms_target:getCallSign()),
			string.format(_("station-comms","%s has no missions or tasks available."),comms_target:getCallSign()),
			_("station-comms","There are currently no missions or tasks available here."),
		}
		setCommsMessage(tableSelectRandom(no_missions_responses))
	end
	addCommsReply(_("Back"), commsStation)
end
--	Booleans to set outside of this utility to control this utility. Default is false
--		stations_support_transport_missions - set true if stations handle transport missions
--		stations_support_cargo_missions - set true if stations handle cargo missions
--			Note: cargo missions usually require transport missions
--	If your scenario supports transport and cargo missions, this function assumes:
--		array table exist for the following:
--			inner_stations contains stations close to the player's starting position
--			outer_stations contains stations further away from the player's starting position
--			friendly_spike_stations contains friendly stations in a far off region
function transportAndCargoMissions()
	if characters == nil then
		initializeCharacters()
	end
	local mission_character = nil
	local mission_type = nil
	local mission_options_presented_count = 0
	if comms_source.transport_mission ~= nil then
		if comms_source.transport_mission.destination ~= nil and comms_source.transport_mission.destination:isValid() then
			if comms_source.transport_mission.destination == comms_target then
				mission_options_presented_count = mission_options_presented_count + 1
				local who_destination_prompts = {
					string.format(_("station-comms","Deliver %s to %s"),comms_source.transport_mission.character.name,comms_target:getCallSign()),
					string.format(_("station-comms","Escort %s off of %s"),comms_source.transport_mission.character.name,comms_source:getCallSign()),
					string.format(_("station-comms","Direct %s off the ship to %s"),comms_source.transport_mission.character.name,comms_target:getCallSign()),
					string.format(_("station-comms","Inform %s of arrival at %s"),comms_source.transport_mission.character.name,comms_target:getCallSign()),
				}
				addCommsReply(tableSelectRandom(who_destination_prompts),function()
					if not comms_source:isDocked(comms_target) then 
						local stay_docked_to_disembark = {
							_("station-comms","You need to stay docked for that action."),
							string.format(_("station-comms","You need to stay docked for %s to disembark."),comms_source.transport_mission.character.name),
							string.format(_("station-comms","You must stay docked long enough for %s to get off of %s on to station %s."),comms_source.transport_mission.character.name,comms_source:getCallSign(),comms_target:getCallSign()),
							string.format(_("station-comms","You undocked before %s could get off the ship."),comms_source.transport_mission.character.name),
						}
						setCommsMessage(tableSelectRandom(stay_docked_to_disembark))
						return mission_options_presented_count
					end
					local thanks_for_ride_responses = {
						string.format(_("station-comms","%s disembarks at %s and thanks you"),comms_source.transport_mission.character.name,comms_target:getCallSign()),
						string.format(_("station-comms","As %s leaves %s at %s, they turn and say, 'Thanks for the ride.'"),comms_source.transport_mission.character.name,comms_source:getCallSign(),comms_target:getCallSign()),
						string.format(_("station-comms","%s thanks you as they walk away from %s down the short connecting tunnel to %s."),comms_source.transport_mission.character.name,comms_source:getCallSign(),comms_target:getCallSign()),
						string.format(_("station-comms","%s disembarks at %s. You hear, 'I'll miss %s,' as footsteps echo back to %s."),comms_source.transport_mission.character.name,comms_target:getCallSign(),comms_source:getCallSign(),comms_source:getCallSign()),
					}
					setCommsMessage(tableSelectRandom(thanks_for_ride_responses))
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
			local alternate_disembarkation = {
				string.format(_("shipLog","%s disembarks at %s because %s has been destroyed. You receive %s reputation for your efforts."),comms_source.transport_mission.character.name,comms_target:getCallSign(),comms_source.transport_mission.destination_name,math.floor(comms_source.transport_mission.reward/2)),
				string.format(_("shipLog","%s leaves %s here at %s due to the destruction of %s. You still get %s reputation."),comms_source.transport_mission.character.name,comms_source:getCallSign(),comms_target:getCallSign(),comms_source.transport_mission.destination_name,math.floor(comms_source.transport_mission.reward/2)),
				string.format(_("shipLog","%s, %s's original destination, has been destroyed. %s disembarks here. You get %s reputation for trying."),comms_source.transport_mission.destination_name,comms_source.transport_mission.character.name,comms_source.transport_mission.character.name,math.floor(comms_source.transport_mission.reward/2)),
				string.format(_("shipLog","Since %s has been destroyed, %s gets off here at %s. Your reputation goes up by %s."),comms_source.transport_mission.destination_name,comms_source.transport_mission.character.name,comms_target:getCallSign(),math.floor(comms_source.transport_mission.reward/2)),
			}
			comms_source:addToShipLog(tableSelectRandom(alternate_disembarkation),"Yellow")
			comms_source:addReputationPoints(comms_source.transport_mission.reward/2)
			if comms_target.residents == nil then
				comms_target.residents = {}
			end
			table.insert(comms_target.residents,comms_source.transport_mission.character)
			comms_source.transport_mission = nil
		end
	else	--player ship transport mission is nil
		if comms_target.transport_mission == nil then
			mission_character = tableRemoveRandom(characters)	--character_names
			local mission_target = nil
			local reward = 0
			if mission_character ~= nil then
				mission_type = random(1,100)
				local destination_pool = {}
				local clean_list = true
				repeat
					clean_list = true
					for i,station in ipairs(inner_stations) do
						if station ~= nil then
							if not station:isValid() then
								inner_stations[i] = inner_stations[#inner_stations]
								inner_stations[#inner_stations] = nil
								clean_list = false
								break
							end
						else
							inner_stations[i] = inner_stations[#inner_stations]
							inner_stations[#inner_stations] = nil
							clean_list = false
							break
						end
					end
				until(clean_list)
				repeat
					clean_list = true
					for i,station in ipairs(outer_stations) do
						if station ~= nil then
							if not station:isValid() then
								outer_stations[i] = outer_stations[#outer_stations]
								outer_stations[#outer_stations] = nil
								clean_list = false
								break
							end
						else
							outer_stations[i] = outer_stations[#outer_stations]
							outer_stations[#outer_stations] = nil
							clean_list = false
							break
						end
					end
				until(clean_list)
				repeat
					clean_list = true
					for i,station in ipairs(friendly_spike_stations) do
						if station ~= nil then
							if not station:isValid() then
								friendly_spike_stations[i] = friendly_spike_stations[#friendly_spike_stations]
								friendly_spike_stations[#friendly_spike_stations] = nil
								clean_list = false
								break
							end
						else
							friendly_spike_stations[i] = friendly_spike_stations[#friendly_spike_stations]
							friendly_spike_stations[#friendly_spike_stations] = nil
							clean_list = false
							break
						end
					end
				until(clean_list)				
				if mission_type < 20 then
					for _, station in ipairs(inner_stations) do
						if station ~= nil and station:isValid() and station ~= comms_target then
							table.insert(destination_pool,station)
						end
					end
					mission_target = tableRemoveRandom(destination_pool)
					if mission_target ~= nil then
						reward = 40
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
				elseif mission_type < 50 then
					for _, station in ipairs(outer_stations) do
						if station ~= nil and station:isValid() and station ~= comms_target and comms_source:isFriendly(station) then
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
						for _, station in ipairs(outer_stations) do
							if station ~= nil and station:isValid() and station ~= comms_target and not comms_source:isEnemy(station) then
								table.insert(destination_pool,station)
							end
						end
						mission_target = tableRemoveRandom(destination_pool)
						if mission_target ~= nil then
							comms_target.transport_mission = {
								["destination"] = mission_target,
								["destination_name"] = mission_target:getCallSign(),
								["reward"] = 50,
								["character"] = mission_character,
							}
						end
					end
				elseif mission_type < 75 then
					for _, station in ipairs(outer_stations) do
						if station ~= nil and station:isValid() and station ~= comms_target and not comms_source:isFriendly(station) and not comms_source:isEnemy(station) then
							table.insert(destination_pool,station)
						end
					end
					mission_target = tableRemoveRandom(destination_pool)
					if mission_target ~= nil then
						comms_target.transport_mission = {
							["destination"] = mission_target,
							["destination_name"] = mission_target:getCallSign(),
							["reward"] = 50,
							["character"] = mission_character,
						}
					end
				else
					for _, station in ipairs(friendly_spike_stations) do
						if station ~= nil and station:isValid() and station ~= comms_target then
							table.insert(destination_pool,station)
						end
					end
					mission_target = tableRemoveRandom(destination_pool)
					if mission_target ~= nil then
						comms_target.transport_mission = {
							["destination"] = mission_target,
							["destination_name"] = mission_target:getCallSign(),
							["reward"] = 60,
							["character"] = mission_character,
						}
					else
						for _, station in ipairs(outer_stations) do
							if station ~= nil and station:isValid() and station ~= comms_target and not comms_source:isEnemy(station) then
								table.insert(destination_pool,station)
							end
						end
						mission_target = tableRemoveRandom(destination_pool)
						if mission_target ~= nil then
							reward = 50
							if mission_target:isFriendly(comms_source) then
								reward = 40
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
		else	--station transport mission not nil
			if not comms_target.transport_mission.destination:isValid() then
				if comms_target.residents == nil then
					comms_target.residents = {}
				end
				table.insert(comms_target.residents,comms_target.transport_mission.character)
				comms_target.transport_mission = nil
			end
		end
		if comms_target.transport_mission ~= nil then
			mission_options_presented_count = mission_options_presented_count + 1
			local transport_passenger_prompts = {
				_("station-comms","Transport Passenger"),
				_("station-comms","Give passenger a ride"),
				string.format(_("station-comms","Transport %s"),comms_target.transport_mission.character.name),
				_("station-comms","Take on a passenger"),
			}
			addCommsReply(tableSelectRandom(transport_passenger_prompts),function()
				local transport_info = {
					string.format(_("station-comms","%s wishes to be transported to %s station %s in sector %s."),comms_target.transport_mission.character.name,comms_target.transport_mission.destination:getFaction(),comms_target.transport_mission.destination_name,comms_target.transport_mission.destination:getSectorName()),
					string.format(_("station-comms","%s needs a ride to sector %s, specifically to %s station %s."),comms_target.transport_mission.character.name,comms_target.transport_mission.destination:getSectorName(),comms_target.transport_mission.destination:getFaction(),comms_target.transport_mission.destination_name),
					string.format(_("station-comms","%s needs to get to station %s. It's a %s station in sector %s."),comms_target.transport_mission.character.name,comms_target.transport_mission.destination_name,comms_target.transport_mission.destination:getFaction(),comms_target.transport_mission.destination:getSectorName()),
					string.format(_("station-comms","Can you take %s to %s station %s in sector %s?"),comms_target.transport_mission.character.name,comms_target.transport_mission.destination:getFaction(),comms_target.transport_mission.destination_name,comms_target.transport_mission.destination:getSectorName()),
				}
				local transport_reputation_info = {
					string.format(_("station-comms","Transporting %s would increase your reputation by %s."),comms_target.transport_mission.character.name,comms_target.transport_mission.reward),
					string.format(_("station-comms","If you take %s to %s, you'd increase your reputation by %s."),comms_target.transport_mission.character.name,comms_target.transport_mission.destination_name,comms_target.transport_mission.reward),
					string.format(_("station-comms","You'd get %s reputation if you transported %s."),comms_target.transport_mission.reward,comms_target.transport_mission.character.name),
					string.format(_("station-comms","This transportation mission is worth %s reputation."),comms_target.transport_mission.reward),
				}
				local out = string.format("%s %s",tableSelectRandom(transport_info),tableSelectRandom(transport_reputation_info))
				setCommsMessage(out)
				local transport_agree_prompts = {
					string.format(_("station-comms","Agree to transport %s to %s station %s"),comms_target.transport_mission.character.name,comms_target.transport_mission.destination:getFaction(),comms_target.transport_mission.destination_name),
					string.format(_("station-comms","Agree to transport mission to %s in %s"),comms_target.transport_mission.destination_name,comms_target.transport_mission.destination:getSectorName()),
					string.format(_("station-comms","%s will transport %s to %s in %s"),comms_source:getCallSign(),comms_target.transport_mission.character.name,comms_target.transport_mission.destination_name,comms_target.transport_mission.destination:getSectorName()),
					string.format(_("station-comms","Take on passenger transport mission to %s"),comms_target.transport_mission.destination_name),
				}
				addCommsReply(tableSelectRandom(transport_agree_prompts),function()
					if not comms_source:isDocked(comms_target) then
						local stay_docked_to_start_transport = {
							_("station-comms","You need to stay docked for that action."),
							string.format(_("station-comms","You need to stay docked for %s to embark."),comms_source.transport_mission.character.name),
							string.format(_("station-comms","You must stay docked long enough for %s to board %s from station %s."),comms_source.transport_mission.character.name,comms_source:getCallSign(),comms_target:getCallSign()),
							string.format(_("station-comms","You undocked before %s could get on the ship."),comms_source.transport_mission.character.name),
						}
						setCommsMessage(tableSelectRandom(stay_docked_to_start_transport))
						return mission_options_presented_count
					end
					comms_source.transport_mission = comms_target.transport_mission
					comms_target.transport_mission = nil
					local boarding_confirmation = {
						string.format(_("station-comms","You direct %s to guest quarters and say, 'Welcome aboard the %s'"),comms_source.transport_mission.character.name,comms_source:getCallSign()),
						string.format(_("station-comms","You welcome %s aboard the %s. 'Let me show you our guest quarters.'"),comms_source.transport_mission.character.name,comms_source:getCallSign()),
						string.format(_("station-comms","%s boards %s. 'Allow me to show you the guest quarters where you will stay for our journey to %s'"),comms_source.transport_mission.character.name,comms_source:getCallSign(),comms_source.transport_mission.destination_name),
						string.format(_("station-comms","%s is aboard. You show %s to %s's guest quarters."),comms_source.transport_mission.character.name,comms_source.transport_mission.character.name,comms_source:getCallSign()),
					}
					setCommsMessage(tableSelectRandom(boarding_confirmation))
					addCommsReply(_("Back"), commsStation)
				end)
				local decline_transportation_prompts = {
					_("station-comms","Decline transportation request"),
					_("station-comms","Refuse transportation request"),
					_("station-comms","Decide against transportation mission"),
					_("station-comms","Decline transportation mission"),
				}
				addCommsReply(tableSelectRandom(decline_transportation_prompts),function()
					local refusal_responses = {
						string.format(_("station-comms","You tell %s that you cannot take on any transportation missions at this time."),comms_target.transport_mission.character.name),
						string.format(_("station-comms","You inform %s that you are unable to transport %s at this time."),comms_target.transport_mission.character.name,comms_target.transport_mission.character.object_pronoun),
						string.format(_("station-comms","'Sorry, %s. We can't transport you at this time.'"),comms_target.transport_mission.character.name),
						string.format(_("station-comms","'%s can't transport you right now, %s. Sorry about that. Good luck.'"),comms_source:getCallSign(),comms_target.transport_mission.character.name),
					}
					local mission_gone = {
						_("station-comms","The offer disappears from the message board."),
						_("station-comms","The transport mission offer no longer appears on the message board."),
						string.format(_("station-comms","%s removes %s transport mission offer from the message board."),comms_target.transport_mission.character.name,comms_target.transport_mission.character.possessive_adjective),
						string.format(_("station-comms","%s gestures and %s transport mission offer disappears from the message board."),comms_target.transport_mission.character.name,comms_target.transport_mission.character.possessive_adjective),
					}
					if random(1,5) <= 1 then
						setCommsMessage(string.format("%s %s",tableSelectRandom(refusal_responses),tableSelectRandom(mission_gone)))
						comms_target.transport_mission = nil
					else
						setCommsMessage(string.format("%s",tableSelectRandom(refusal_responses)))
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
					mission_options_presented_count = mission_options_presented_count + 1
					local cargo_delivery_prompts = {
						string.format(_("station-comms","Deliver cargo to %s on %s"),comms_source.cargo_mission.character.name,comms_target:getCallSign()),
						string.format(_("station-comms","Give cargo to %s here on %s"),comms_source.cargo_mission.character.name,comms_target:getCallSign()),
						string.format(_("station-comms","Offload %s's cargo to station %s"),comms_source.cargo_mission.character.name,comms_target:getCallSign()),
						string.format(_("station-comms","Unload cargo to %s and inform %s"),comms_target:getCallSign(),comms_source.cargo_mission.character.name),
					}
					addCommsReply(tableSelectRandom(cargo_delivery_prompts),function()
						if not comms_source:isDocked(comms_target) then 
							local stay_docked_to_deliver = {
								_("station-comms","You need to stay docked for that action."),
								string.format(_("station-comms","You need to stay docked to deliver %s's cargo."),comms_source.transport_mission.character.name),
								string.format(_("station-comms","You must stay docked long enough to unload %s's cargo to %s."),comms_source.transport_mission.character.name,comms_target:getCallSign()),
								string.format(_("station-comms","You undocked before we could deliver cargo for %s."),comms_source.transport_mission.character.name),
							}
							setCommsMessage(tableSelectRandom(stay_docked_to_deliver))
							return
						end
						local cargo_delivery_confirmation_and_thanks = {
							string.format(_("station-comms","%s thanks you for retrieving %s cargo."),comms_source.cargo_mission.character.name,comms_target.transport_mission.character.possessive_adjective),
							string.format(_("station-comms","%s says, 'Thanks for bringing me my stuff.'"),comms_source.cargo_mission.character.name),
							string.format(_("station-comms","%s grabs %s cargo and waves, clearly happy to have it."),comms_source.cargo_mission.character.name,comms_target.transport_mission.character.possessive_adjective),
							string.format(_("station-comms","%s takes receipt of %s cargo and is clearly grateful."),comms_source.cargo_mission.character.name,comms_target.transport_mission.character.possessive_adjective),
						}
						setCommsMessage(tableSelectRandom(cargo_delivery_confirmation_and_thanks))
						comms_source:addReputationPoints(comms_source.cargo_mission.reward)
						comms_source.cargo_mission = nil
						addCommsReply(_("Back"), commsStation)
					end)
				end
			else
				local station_destroyed_mid_mission = {
					string.format(_("shipLog","Automated systems on %s have informed you of the destruction of station %s. Your mission to deliver cargo for %s to %s is no longer valid. You unloaded the cargo and requested the station authorities handle it for the family of %s. You received %s reputation for your efforts. The mission has been removed from your mission log."),comms_target:getCallSign(),comms_source.cargo_mission.destination_name,comms_source.cargo_mission.character.name,comms_source.cargo_mission.destination_name,comms_source.cargo_mission.character,math.floor(comms_source.cargo_mission.reward/2)),
					string.format(_("shipLog","Records on %s inform you that %s has been destroyed. Thus, your cargo mission for %s is no longer valid. You unload %s's cargo for %s authorities to handle it for %s family. You receive %s reputation for your efforts. The cargo mission has been removed from your mission log."),comms_target:getCallSign(),comms_source.cargo_mission.destination_name,comms_source.cargo_mission.character.name,comms_source.cargo_mission.character.name,comms_target:getCallSign(),comms_source.transport_mission.character.possessive_adjective,math.floor(comms_source.cargo_mission.reward/2)),
					string.format(_("shipLog","You see on %s's status board that %s was destroyed. So, you can't deliver %s's cargo. You unload it, asking %s's personnel to take care of it for the %s family. You still get %s reputation. You remove the mission from your task list."),comms_target:getCallSign(),comms_source.cargo_mission.destination_name,comms_source.cargo_mission.character.name,comms_target:getCallSign(),comms_source.transport_mission.character.possessive_adjective,math.floor(comms_source.cargo_mission.reward/2)),
					string.format(_("shipLog","%s requests %s's cargo on behalf of their family. %s has been destroyed. You unload the cargo and post a message of condolences for %s family. You receive %s reputation and delete the mission from your task list."),comms_target:getCallSign(),comms_source.cargo_mission.character.name,comms_source.cargo_mission.destination_name,comms_source.transport_mission.character.possessive_adjective,math.floor(comms_source.cargo_mission.reward/2)),
				}
				comms_source:addToShipLog(tableSelectRandom(station_destroyed_mid_mission),"Yellow")
				comms_source:addReputationPoints(comms_source.cargo_mission.reward/2)
				comms_source.cargo_mission = nil
			end
		else	--cargo not loaded
			if comms_source.cargo_mission.origin ~= nil and comms_source.cargo_mission.origin:isValid() then
				if comms_source.cargo_mission.origin == comms_target then
					mission_options_presented_count = mission_options_presented_count + 1
					local mid_cargo_mission_pickup_prompts = {
						string.format(_("station-comms","Pick up cargo for %s"),comms_source.cargo_mission.character.name),
						string.format(_("station-comms","Get cargo for %s"),comms_source.cargo_mission.character.name),
						string.format(_("station-comms","Load cargo from %s for %s"),comms_target:getCallSign(),comms_source.cargo_mission.character.name),
						string.format(_("station-comms","Load cargo on %s for %s"),comms_source:getCallSign(),comms_source.cargo_mission.character.name),
					}
					addCommsReply(tableSelectRandom(mid_cargo_mission_pickup_prompts),function()
						if not comms_source:isDocked(comms_target) then 
							local stay_docked_to_get_cargo = {
								_("station-comms","You need to stay docked for that action."),
								string.format(_("station-comms","You need to stay docked to get %s's cargo."),comms_source.transport_mission.character.name),
								string.format(_("station-comms","You must stay docked long enough to load %s's cargo on %s."),comms_source.transport_mission.character.name,comms_source:getCallSign()),
								string.format(_("station-comms","You undocked before we could load cargo for %s."),comms_source.transport_mission.character.name),
							}
							setCommsMessage(tableSelectRandom(stay_docked_to_get_cargo))
							return
						end
						local cargo_loaded_confirmation = {
							string.format(_("station-comms","The cargo for %s has been loaded on %s."),comms_source.cargo_mission.character.name,comms_source:getCallSign()),
							string.format(_("station-comms","%s's cargo has been loaded from %s to %s."),comms_source.cargo_mission.character.name,comms_target:getCallSign(),comms_source:getCallSign()),
							string.format(_("station-comms","You take receipt of cargo from %s destined for %s."),comms_target:getCallSign(),comms_source.cargo_mission.character.name),
							string.format(_("station-comms","You load %s's cargo from %s"),comms_source.cargo_mission.character.name,comms_target:getCallSign()),
						}
						setCommsMessage(tableSelectRandom(cargo_loaded_confirmation))
						comms_source.cargo_mission.loaded = true
						addCommsReply(_("Back"), commsStation)
					end)
				end
			else
				local station_destroyed_before_getting_cargo = {
					string.format(_("shipLog","Automated systems on %s have informed you of the destruction of station %s. Your mission to retrieve cargo for %s from %s is no longer valid and has been removed from your mission log."),comms_target:getCallSign(),comms_source.cargo_mission.origin_name,comms_source.cargo_mission.character.name,comms_source.cargo_mission.origin_name),
					string.format(_("shipLog","Records on %s inform you that %s has been destroyed. Thus, your cargo retrieval mission for %s is no longer valid. It's been removed from your mission task list."),comms_target:getCallSign(),comms_source.cargo_mission.origin_name,comms_source.cargo_mission.character.name),
					string.format(_("shipLog","You see on %s's status board that %s was destroyed. So, you can't pick up %s's cargo. You remove the mission from your task list."),comms_target:getCallSign(),comms_source.cargo_mission.origin_name,comms_source.cargo_mission.character.name),
					string.format(_("shipLog","%s informs you that %s was destroyed. This invalidates your mission to get %s's cargo from %s. You delete the mission from your task list and send an explanatory message to %s"),comms_target:getCallSign(),comms_source.cargo_mission.origin_name,comms_source.cargo_mission.character.name,comms_source.cargo_mission.origin_name,comms_source.cargo_mission.character.name),
				}
				comms_source:addToShipLog(tableSelectRandom(station_destroyed_before_getting_cargo),"Yellow")
				if comms_source.cargo_mission.destination:isValid() then
					table.insert(comms_source.cargo_mission.destination.residents,comms_source.cargo_mission.character)
				end
				comms_source.cargo_mission = nil
			end
		end
	else	--no cargo mission
		if comms_target.cargo_mission == nil then
			if comms_target.residents ~= nil then
				mission_character = tableRemoveRandom(comms_target.residents)
				local mission_origin = nil
				if mission_character ~= nil then
					mission_type = random(1,100)
					local origin_pool = {}
					if mission_type < 20 then
						for _, station in ipairs(inner_stations) do
							if station ~= nil and station:isValid() and station ~= comms_target and not comms_source:isEnemy(station) then
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
							for _, station in ipairs(outer_stations) do
								if station ~= nil and station:isValid() and station ~= comms_target and not comms_source:isEnemy(station) then
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
							end
						end
					elseif mission_type < 50 then
						for _, station in ipairs(outer_stations) do
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
							for _, station in ipairs(outer_stations) do
								if station ~= nil and station:isValid() and station ~= comms_target and not comms_source:isEnemy(station) then
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
					elseif mission_type < 75 then
						for _, station in ipairs(station_list) do
							if station ~= nil and station:isValid() and station ~= comms_target and not comms_source:isEnemy(station) then
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
						end
					else
						for _, station in ipairs(friendly_spike_stations) do
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
								["reward"] = 40,
								["character"] = mission_character,
							}
						else
							for _, station in ipairs(outer_stations) do
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
		else	--cargo mission exists
			if not comms_target.cargo_mission.origin:isValid() then
				table.insert(comms_target.residents,comms_target.cargo_mission.character)
				comms_target.cargo_mission = nil
			end
		end
		if comms_target.cargo_mission ~= nil then
			mission_options_presented_count = mission_options_presented_count + 1
			local retrieve_cargo_prompts = {
				_("station-comms","Retrieve Cargo"),
				string.format(_("station-comms","Retrieve cargo for %s"),comms_target.cargo_mission.character.name),
				string.format(_("station-comms","Get cargo from %s"),comms_target.cargo_mission.origin_name),
				string.format(_("station-comms","Get cargo for %s from %s"),comms_target.cargo_mission.character.name,comms_target.cargo_mission.origin_name),
			}
			addCommsReply(tableSelectRandom(retrieve_cargo_prompts),function()
				local cargo_parameters = {
					string.format(_("station-comms","%s wishes you to pick up %s cargo from %s station %s in sector %s and deliver it here."),comms_target.cargo_mission.character.name,comms_target.cargo_mission.character.possessive_adjective,comms_target.cargo_mission.origin:getFaction(),comms_target.cargo_mission.origin_name,comms_target.cargo_mission.origin:getSectorName()),
					string.format(_("station-comms","%s wants to hire you to get cargo from %s station %s in %s and deliver it here (%s)."),comms_target.cargo_mission.character.name,comms_target.cargo_mission.origin:getFaction(),comms_target.cargo_mission.origin_name,comms_target.cargo_mission.origin:getSectorName(),comms_target:getCallSign()),
					string.format(_("station-comms","Mission: Get cargo from %s station %s in sector %s for %s and bring it back here."),comms_target.cargo_mission.origin:getFaction(),comms_target.cargo_mission.origin_name,comms_target.cargo_mission.origin:getSectorName(),comms_target.cargo_mission.character.name),
					string.format(_("station-comms","Task: Get cargo for %s from %s and deliver it here. %s is a %s station in sector %s."),comms_target.cargo_mission.character.name,comms_target.cargo_mission.origin_name,comms_target.cargo_mission.origin_name,comms_target.cargo_mission.origin:getFaction(),comms_target.cargo_mission.origin:getSectorName()),
				}
				local cargo_mission_reputation = {
					string.format(_("station-comms","Retrieving and delivering %s cargo would increase your reputation by %s."),comms_target.cargo_mission.character.possessive_adjective,comms_target.cargo_mission.reward),
					string.format(_("station-comms","Getting %s cargo from %s would boost your reputation by %s."),comms_target.cargo_mission.character.possessive_adjective,comms_target.cargo_mission.origin_name,comms_target.cargo_mission.reward),
					string.format(_("station-comms","Your reputation would go up by %s if you completed this cargo mission for %s."),comms_target.cargo_mission.reward,comms_target.cargo_mission.character.name),
					string.format(_("station-comms","You would get %s reputation for getting %s cargo from %s"),comms_target.cargo_mission.reward,comms_target.cargo_mission.character.possessive_adjective,comms_target.cargo_mission.origin_name),
				}
				setCommsMessage(string.format("%s %s",tableSelectRandom(cargo_parameters),tableSelectRandom(cargo_mission_reputation)))
				local agree_to_cargo_mission = {
					string.format(_("station-comms","Agree to retrieve cargo for %s"),comms_target.cargo_mission.character.name),
					string.format(_("station-comms","Sign up to get cargo for %s"),comms_target.cargo_mission.character.name),
					string.format(_("station-comms","Take on mission to get cargo for %s"),comms_target.cargo_mission.character.name),
					string.format(_("station-comms","Inform %s that %s will get %s cargo"),comms_target.cargo_mission.character.name,comms_source:getCallSign(),comms_target.cargo_mission.character.possessive_adjective)
				}
				addCommsReply(tableSelectRandom(agree_to_cargo_mission),function()
					if not comms_source:isDocked(comms_target) then 
						local stay_docked_to_start_cargo_mission = {
							_("station-comms","You need to stay docked for that action."),
							string.format(_("station-comms","You need to stay docked to agree to get %s's cargo."),comms_source.transport_mission.character.name),
							string.format(_("station-comms","You must stay docked long enough to consent to %s's cargo mission."),comms_source.transport_mission.character.name),
							string.format(_("station-comms","You undocked before we could agree to retrieve cargo for %s."),comms_source.transport_mission.character.name),
						}
						setCommsMessage(tableSelectRandom(stay_docked_to_start_cargo_mission))
						return
					end
					comms_source.cargo_mission = comms_target.cargo_mission
					comms_source.cargo_mission.loaded = false
					comms_target.cargo_mission = nil
					local cargo_agreement_confirmation = {
						string.format(_("station-comms","%s thanks you and contacts station %s to let them know that %s will be picking up %s cargo."),comms_source.cargo_mission.character.name,comms_source.cargo_mission.origin_name,comms_source:getCallSign(),comms_source.cargo_mission.character.possessive_adjective),
						string.format(_("station-comms","%s contacts station %s to let them know that %s will be retrieving %s cargo."),comms_source.cargo_mission.character.name,comms_source.cargo_mission.origin_name,comms_source:getCallSign(),comms_source.cargo_mission.character.possessive_adjective),
						string.format(_("station-comms","%s says, 'Thanks %s. I'll let %s know you're picking up my cargo.'"),comms_source.cargo_mission.character.name,comms_source:getCallSign(),comms_source.cargo_mission.origin_name),
						string.format(_("station-comms","%s says, 'I'll let %s know you're coming for my cargo. Thank you %s.'"),comms_source.cargo_mission.character.name,comms_source.cargo_mission.origin_name,comms_source:getCallSign()),
					}
					setCommsMessage(tableSelectRandom(cargo_agreement_confirmation))
					addCommsReply(_("Back"), commsStation)
				end)
				local decline_cargo_mission = {
					_("station-comms","Decline cargo retrieval request"),
					_("station-comms","Decline cargo mission"),
					_("station-comms","Refuse cargo retrieval request"),
					_("station-comms","Decide against cargo retrieval request"),
				}
				addCommsReply(tableSelectRandom(decline_cargo_mission),function()
					local cargo_refusal_responses = {
						string.format(_("station-comms","You tell %s that you cannot take on any cargo missions at this time."),comms_target.transport_mission.character.name),
						string.format(_("station-comms","You inform %s that you are unable to get any cargo for %s at this time."),comms_target.transport_mission.character.name,comms_target.transport_mission.character.object_pronoun),
						string.format(_("station-comms","'Sorry, %s. We can't retrieve your cargo at this time.'"),comms_target.transport_mission.character.name),
						string.format(_("station-comms","'%s can't get cargo for you you right now, %s. Sorry about that. Good luck.'"),comms_source:getCallSign(),comms_target.transport_mission.character.name),
					}
					local cargo_mission_gone = {
						_("station-comms","The offer disappears from the message board."),
						_("station-comms","The cargo mission offer no longer appears on the message board."),
						string.format(_("station-comms","%s removes %s cargo retrieval mission offer from the message board."),comms_target.transport_mission.character.name,comms_target.transport_mission.character.possessive_adjective),
						string.format(_("station-comms","%s gestures and %s cargo mission offer disappears from the message board."),comms_target.transport_mission.character.name,comms_target.transport_mission.character.possessive_adjective),
					}
					if random(1,5) <= 1 then
						setCommsMessage(string.format("%s %s",tableSelectRandom(cargo_refusal_responses),tableSelectRandom(cargo_mission_gone)))
						comms_target.cargo_mission = nil
					else
						setCommsMessage(tableSelectRandom(cargo_refusal_responses))
					end
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end
	return mission_options_presented_count
end
function possibleImprovementGoods(improvement,station)
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
	local goods_list = {}
	local reason_list = {}
	if improvement == "restock_probes" then
		if station.probe_fail_reason == nil then
			reason_list = {
				_("situationReport-comms", "Cannot replenish scan probes due to fabrication unit failure."),
				_("situationReport-comms", "Parts shortage prevents scan probe replenishment."),
				_("situationReport-comms", "Station management has curtailed scan probe replenishment for cost cutting reasons."),
			}
			station.probe_fail_reason = reason_list[math.random(1,#reason_list)]
		end
		goods_list = mission_reasons["restock_probes"][station.probe_fail_reason]
	elseif improvement == "hull" then
		if station.repair_fail_reason == nil then
			reason_list = {
				_("situationReport-comms", "We're out of the necessary materials and supplies for hull repair."),
				_("situationReport-comms", "Hull repair automation unavailable while it is undergoing maintenance."),
				_("situationReport-comms", "All hull repair technicians quarantined to quarters due to illness."),
			}
			station.repair_fail_reason = reason_list[math.random(1,#reason_list)]
		end
		goods_list = mission_reasons["hull"][station.repair_fail_reason]
	elseif improvement == "energy" then
		if station.energy_fail_reason == nil then
			reason_list = {
				_("situationReport-comms", "A recent reactor failure has put us on auxiliary power, so we cannot recharge ships."),
				_("situationReport-comms", "A damaged power coupling makes it too dangerous to recharge ships."),
				_("situationReport-comms", "An asteroid strike damaged our solar cells and we are short on power, so we can't recharge ships right now."),
			}
			station.energy_fail_reason = reason_list[math.random(1,#reason_list)]
		end
		goods_list = mission_reasons["energy"][station.energy_fail_reason]
	else
		goods_list = {"nickel","platinum","gold","dilithium","tritanium","cobalt","circuit","filament"}
		if improvement == "EMP" or improvement == "Nuke" or improvement == "Homing" then
			table.insert(goods_list,"sensor")
		end
	end
	if station.comms_data ~= nil and station.comms_data.goods ~= nil then
		for station_good,details in pairs(station.comms_data.goods) do
			local match = false
			repeat
				match = false
				for i,good in ipairs(goods_list) do
					if good == station_good then
						goods_list[i] = goods_list[#goods_list]
						goods_list[#goods_list] = nil
						match = true
						break
					end
				end
			until(not match)
		end
	end
	return goods_list
end
function improveStationService(improvements)
	addCommsReply(_("situationReport-comms","Improve station services"),function()
		local improve_what_service_prompts = {
			_("situationReport-comms","What station service would you like to improve?"),
			_("situationReport-comms","Which of these station services would you like to improve?"),
			_("situationReport-comms","You could improve any of these station services:"),
			_("situationReport-comms","Certain station services could use improvement. Which one are you interested in?"),
			string.format(_("situationReport-comms","Which %s service can %s help improve?"),comms_target:getCallSign(),comms_source:getCallSign()),
		}
		if #improvements == 1 then
			improve_what_service_prompts = {
				_("situationReport-comms","Would you like to improve this service?"),
				_("situationReport-comms","This service could use improvement:"),
				string.format(_("situationReport-comms","%s can help %s by improving this service:"),comms_source:getCallSign(),comms_target:getCallSign()),
				_("situationReport-comms","Can you help by improving this service?"),
			}
		end
		setCommsMessage(tableSelectRandom(improve_what_service_prompts))
		local improvement_prompt = {
			["restock_probes"] = {
				_("situationReport-comms","Restocking of docked ship's scan probes"),
				_("situationReport-comms","Replenishing docked ship's scan probes"),
				_("situationReport-comms","Resupplying scan probes of docked ship"),
			},
			["hull"] = {
				_("situationReport-comms","Repairing of docked ship's hull"),
				_("situationReport-comms","Repairing hull of docked ship"),
				_("situationReport-comms","Fixing docked ship's hull"),
			},
			["energy"] = {
				_("situationReport-comms","Charging of docked ship's energy reserves"),
				_("situationReport-comms","Charge batteries of docked ship"),
				_("situationReport-comms","Restore energy reserves on docked ship"),
			},
			["Nuke"] = {
				_("situationReport-comms","Replenishment of nuclear ordnance on docked ship"),
				_("situationReport-comms","Replenish docked ship's nukes"),
				_("situationReport-comms","Restock nukes of docked ship"),
				_("situationReport-comms","Resupply nukes on docked ship"),
			},
			["EMP"] = {
				_("situationReport-comms","Replenishment of EMP missiles on docked ship"),
				_("situationReport-comms","Replenish docked ship's EMPs"),
				_("situationReport-comms","Provide replacement Electro-Magnetic Pulse missiles"),
				_("situationReport-comms","Restock EMPs on docked ship"),
			},
			["Homing"] = {
				_("situationReport-comms","Replenishment of homing missiles"),
				_("situationReport-comms","Restock homing missiles of docked ship"),
				_("situationReport-comms","Resupply homing missiles for docked ship"),
				_("situationReport-comms","Provide homing missiles to docked ship"),
			},
			["HVLI"] = {
				_("situationReport-comms","Replenishment of High Velocity Lead Impactors"),
				_("situationReport-comms","Restock HVLI missiles for docked ship"),
				_("situationReport-comms","Resupply High Velocity Lead Impactors on docked ship"),
				_("situationReport-comms","Provide HVLIs for docked ship"),
			},
			["Mine"] = {
				_("situationReport-comms","Replenishment of mines"),
				_("situationReport-comms","Replace mines on docked ship"),
				_("situationReport-comms","Restock mines on docked ship"),
				_("situationReport-comms","Resupply mines to docked ship"),
			},
		}
		if improvement_mission_stations == nil then
			improvement_mission_stations = {}
			for i,object in ipairs(getAllObjects()) do
				if object:isValid() and object.typeName == "SpaceStation" then
					table.insert(improvement_mission_stations,object)
				end
			end
		end
		if #improvement_mission_stations == 0 then
			setCommsMessage("Resources unavailable for improvements")
		else
			for i,improvement in ipairs(improvements) do
				if improvement_prompt[improvement] == nil then
					print("Unable to show improvements. Improvement value:",improvement)
				else
					addCommsReply(tableSelectRandom(improvement_prompt[improvement]),function()
						if comms_target.improvement_goods == nil then
							comms_target.improvement_goods = {}
						end
						local needed_good = comms_target.improvement_goods[improvement]
						if needed_good == nil then
							local improvement_goods = possibleImprovementGoods(improvement,comms_target)
							local improvement_mission_station_pool = {}
							for i,station in ipairs(improvement_mission_stations) do
								if station ~= nil and station:isValid() and not station:isEnemy(comms_source) and station ~= comms_target then
									table.insert(improvement_mission_station_pool,station)
								end
							end
							local mission_goods = {}
							for i,station in ipairs(improvement_mission_station_pool) do
								if station.comms_data ~= nil and station.comms_data.goods ~= nil then
									for station_good,details in pairs(station.comms_data.goods) do
										for j,good in ipairs(improvement_goods) do
											if good == station_good and details.quantity > 0 then
												local found = false
												for k,already_identified in ipairs(mission_goods) do
													if good == already_identified then
														found = true
														break
													end
												end
												if not found then
													table.insert(mission_goods,good)
												end
											end
										end
									end
								end
							end
							needed_good = tableSelectRandom(mission_goods)
							if needed_good == nil then
								needed_good = tableSelectRandom(improvement_goods)
								print("needed good selected from possible improvement goods:",needed_good)
								local commerce_stations = {}
								for i,station in ipairs(improvement_mission_station_pool) do
									if station.comms_data ~= nil and station.comms_data.goods ~= nil then
										local goods_diversity_count = 0
										for station_good,details in pairs(station.comms_data.goods) do
											if details.quantity > 0 then
												goods_diversity_count = goods_diversity_count + 1
											end
										end
										table.insert(commerce_stations,{station=station, goods_count = goods_diversity_count})
									else
										table.insert(commerce_stations,{station=station, goods_count = 0})
									end
								end
								table.sort(commerce_stations, function(a,b)
									return a.goods_count < b.goods_count
								end)
								local commerce_station = commerce_stations[1].station
								if commerce_station ~= nil then
									if commerce_station.comms_data.goods == nil then
										commerce_station.comms_data.goods = {}
									end
									commerce_station.comms_data.goods[needed_good] = {quantity = math.random(5,9), cost = math.random(30,90)}
									print(needed_good,"added to those goods offered by",commerce_station:getCallSign())
								end
							end
							comms_target.improvement_goods[improvement] = needed_good
						end
						local pi = math.random(1,#improvement_prompt[improvement])
						setCommsMessage(string.format(_("situationReport-comms","%s could be improved with %s. You may be able to get %s from stations or transports."),improvement_prompt[improvement][pi],needed_good,needed_good))
						if comms_source.goods ~= nil then
							if comms_source.goods[needed_good] ~= nil and comms_source.goods[needed_good] > 0 and comms_source:isDocked(comms_target) then
								addCommsReply(string.format(_("situationReport-comms","Provide %s to station %s"),needed_good,comms_target:getCallSign()),function()
									if comms_source:isDocked(comms_target) then
										comms_source.goods[needed_good] = comms_source.goods[needed_good] - 1
										comms_source.cargo = comms_source.cargo + 1
										local improvement_msg = _("situationReport-comms","There was a problem with the improvement process")
										local friendliness_bonus_lo = 3
										local friendliness_bonus_hi = 9
										if improvement == "energy" then
											if comms_source.instant_energy == nil then
												comms_source.instant_energy = {}
											end
											table.insert(comms_source.instant_energy,comms_target)
											comms_target:setSharesEnergyWithDocked(true)
											improvement_msg = _("situationReport-comms","We can recharge again! Come back any time to have your batteries instantly recharged.")
											comms_target.comms_data.friendlyness = math.min(comms_target.comms_data.friendlyness + random(friendliness_bonus_lo,friendliness_bonus_hi),100)
										elseif improvement == "hull" then
											if comms_source.instant_hull == nil then
												comms_source.instant_hull = {}
											end
											table.insert(comms_source.instant_hull,comms_target)
											comms_target:setRepairDocked(true)
											improvement_msg = _("situationReport-comms","We can repair hulls again! Come back any time to have your hull instantly repaired.")
											comms_target.comms_data.friendlyness = math.min(comms_target.comms_data.friendlyness + random(friendliness_bonus_lo,friendliness_bonus_hi),100)
										elseif improvement == "restock_probes" then
											if comms_source.instant_probes == nil then
												comms_source.instant_probes = {}
											end
											table.insert(comms_source.instant_probes,comms_target)
											comms_target:setRestocksScanProbes(true)
											improvement_msg = _("situationReport-comms","We can restock scan probes again! Come back any time to have your scan probes instantly restocked.")
											comms_target.comms_data.friendlyness = math.min(comms_target.comms_data.friendlyness + random(friendliness_bonus_lo,friendliness_bonus_hi),100)
										elseif improvement == "Nuke" then
											if comms_source.nuke_discount == nil then
												comms_source.nuke_discount = {}
											end
											table.insert(comms_source.nuke_discount,comms_target)
											comms_target.comms_data.weapon_available.Nuke = true
											comms_target.comms_data.weapons["Nuke"] = "neutral"
											comms_target.comms_data.max_weapon_refill_amount.neutral = 1
											improvement_msg = _("situationReport-comms","We can replenish nukes again! Come back any time to have your supply of nukes replenished.")
											comms_target.comms_data.friendlyness = math.min(comms_target.comms_data.friendlyness + random(friendliness_bonus_lo,friendliness_bonus_hi),100)
										elseif improvement == "EMP" then
											if comms_source.emp_discount == nil then
												comms_source.emp_discount = {}
											end
											table.insert(comms_source.emp_discount,comms_target)
											comms_target.comms_data.weapon_available.EMP = true
											comms_target.comms_data.weapons["EMP"] = "neutral"
											comms_target.comms_data.max_weapon_refill_amount.neutral = 1
											improvement_msg = _("situationReport-comms","We can replenish EMPs again! Come back any time to have your supply of EMPs replenished.")
											comms_target.comms_data.friendlyness = math.min(comms_target.comms_data.friendlyness + random(friendliness_bonus_lo,friendliness_bonus_hi),100)
										elseif improvement == "Homing" then
											if comms_source.homing_discount == nil then
												comms_source.homing_discount = {}
											end
											table.insert(comms_source.homing_discount,comms_target)
											comms_target.comms_data.weapon_available.Homing = true
											comms_target.comms_data.max_weapon_refill_amount.neutral = 1
											improvement_msg = _("situationReport-comms","We can replenish homing missiles again! Come back any time to have your supply of homing missiles replenished.")
											comms_target.comms_data.friendlyness = math.min(comms_target.comms_data.friendlyness + random(friendliness_bonus_lo,friendliness_bonus_hi),100)
										elseif improvement == "Mine" then
											if comms_source.mine_discount == nil then
												comms_source.mine_discount = {}
											end
											table.insert(comms_source.mine_discount,comms_target)
											comms_target.comms_data.weapon_available.Mine = true
											comms_target.comms_data.weapons["Mine"] = "neutral"
											comms_target.comms_data.max_weapon_refill_amount.neutral = 1
											improvement_msg = _("situationReport-comms","We can replenish mines again! Come back any time to have your supply of mines replenished.")
											comms_target.comms_data.friendlyness = math.min(comms_target.comms_data.friendlyness + random(friendliness_bonus_lo,friendliness_bonus_hi),100)
										elseif improvement == "HVLI" then
											if comms_source.hvli_discount == nil then
												comms_source.hvli_discount = {}
											end
											table.insert(comms_source.hvli_discount,comms_target)
											comms_target.comms_data.weapon_available.HVLI = true
											comms_target.comms_data.max_weapon_refill_amount.neutral = 1
											improvement_msg = _("situationReport-comms","We can replenish HVLIs again! Come back any time to have your supply of high velocity lead impactors replenished.")
											comms_target.comms_data.friendlyness = math.min(comms_target.comms_data.friendlyness + random(friendliness_bonus_lo,friendliness_bonus_hi),100)
										end
										setCommsMessage(improvement_msg)
									else
										local stay_docked_to_improve_service = {
											_("situationReport-comms","Can't do that when you're not docked"),
											_("situationReport-comms","Stay docked to improve station service"),
											string.format(_("situationReport-comms","You can't improve a service on %s if you're not docked"),comms_target:getCallSign()),
											string.format(_("situationReport-comms","Stay docked with %s if you want to improve a service offerred by %s"),comms_target:getCallSign(),comms_target:getCallSign()),
										}
										setCommsMessage(tableSelectRandom(stay_docked_to_improve_service))
									end
									addCommsReply(_("Back"), commsStation)
								end)
							end
						end
						addCommsReply(_("Back"), commsStation)
					end)
				end
			end
		end
		addCommsReply(_("Back"), commsStation)
	end)
end
--	Booleans to set outside of this utility to control this utility. Default is false
--		add_repair_crew - set true if players can get more repair crew from stations
--		add_coolant - set true if players can get more coolant from stations
function restockShip()
	local restock_type_prompt = {
		_("station-comms","What does your ship need to restock?"),
		_("station-comms","What kind of supplies do you need?"),
		_("station-comms","What type of resupply does your ship need?"),
		_("station-comms","What are you low on?"),
	}
	setCommsMessage(tableSelectRandom(restock_type_prompt))
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
				restockOrdnance()
		end
	end	
	if add_repair_crew then
		getRepairCrewFromStation()
	end
	if add_coolant then
		getCoolantFromStation()
	end
end
function restockOrdnance()
	local ordnance_restock_prompt = {
		_("ammo-comms","I need ordnance restocked"),
		_("ammo-comms","Restock ordnance"),
		string.format(_("ammo-comms","%s needs more ordnance"),comms_source:getCallSign()),
		string.format(_("ammo-comms","Please provide ordnance for %s"),comms_source:getCallSign()),
	}
	addCommsReply(tableSelectRandom(ordnance_restock_prompt), function()
		setCommsMessage(_("ammo-comms", "What type of ordnance do you need?"))
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
		local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
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
end
function handleWeaponRestock(weapon)
    if not comms_source:isDocked(comms_target) then 
		local stay_docked_for_weapons_restock = {
			_("ammo-comms","You need to stay docked for that action."),
			string.format(_("ammo-comms","You need to stay docked to get weapon restock from %s."),comms_target:getCallSign()),
			string.format(_("ammo-comms","You must stay docked long enough to receive ordnance restock from %s."),comms_target:getCallSign()),
			string.format(_("ammo-comms","You undocked before we could load ordnance from %s."),comms_target:getCallSign()),
		}
		setCommsMessage(tableSelectRandom(stay_docked_for_weapons_restock))
		return
	end
    if not isAllowedTo(comms_target.comms_data.weapons[weapon]) then
    	local no_nukes_on_principle = {
    		_("ammo-comms","We do not deal in weapons of mass destruction."),
    		_("ammo-comms","We don't deal in nukes on principle."),
    		_("ammo-comms","We don't deal in nukes in protest of their misuse."),
    		_("ammo-comms","It's against our beliefs to deal in weapons of mass destruction."),
    	}
    	local no_emps_on_principle = {
    		_("ammo-comms","We do not deal in weapons of mass disruption."),
    		_("ammo-comms","It's against our beliefs to deal in weapons of mass disruption."),
    		_("ammo-comms","We don't deal in EMPs on principle."),
    		_("ammo-comms","We protest the use of EMPs, so we don't deal in them."),
    	}
    	local no_weapon_type_on_principle = {
    		_("ammo-comms","We do not deal in those weapons."),
    		_("ammo-comms","We do not deal in those weapons on principle."),
    		_("ammo-comms","Those weapons are anathema to us, so we don't deal in them."),
    		_("ammo-comms","We hate those weapons, so we don't deal in them."),
    	}
        if weapon == "Nuke" then setCommsMessage(tableSelectRandom(no_nukes_on_principle))
        elseif weapon == "EMP" then setCommsMessage(tableSelectRandom(no_emps_on_principle))
        else setCommsMessage(tableSelectRandom(no_weapon_type_on_principle)) end
        return
    end
    local points_per_item = getWeaponCost(weapon)
    local item_amount = math.floor(comms_source:getWeaponStorageMax(weapon) * comms_target.comms_data.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage(weapon)
    if item_amount <= 0 then
        if weapon == "Nuke" then
			local full_on_nukes = {
				_("ammo-comms","All nukes are charged and primed for destruction."),
				_("ammo-comms","All nukes are already charged and primed for destruction."),
				_("ammo-comms","We double checked and all of your nukes are primed, charged and ready to destroy their targets."),
				_("ammo-comms","Every one of your nukes are already fully prepared for launch. Happy explosions to you!"),
			}
			setCommsMessage(tableSelectRandom(full_on_nukes))
        else
			local full_on_ordnance = {
				_("ammo-comms","Sorry, sir, but you are as fully stocked as I can allow."),
				_("ammo-comms","Your magazine is already completely full."),
				_("ammo-comms","We can't give you any more because you are already fully loaded."),
				string.format(_("ammo-comms","Sorry, but there is no more space on %s for this ordnance type."),comms_source:getCallSign()),
			}
			setCommsMessage(tableSelectRandom(full_on_ordnance))
        end
        addCommsReply(_("Back"), commsStation)
    else
		if comms_source:getReputationPoints() > points_per_item * item_amount then
			if comms_source:takeReputationPoints(points_per_item * item_amount) then
				comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + item_amount)
				if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
					local restocked_on_ordnance = {
						_("ammo-comms","You are fully loaded and ready to explode things."),
						_("ammo-comms","You are fully restocked and ready to make things explode."),
						string.format(_("ammo-comms","%s's %s magazine has been fully restocked"),comms_source:getCallSign(),weapon),
						string.format(_("ammo-comms","We made sure your %s magazine was completely restocked"),weapon),
					}
					setCommsMessage(tableSelectRandom(restocked_on_ordnance))
				else
					local partial_ordnance_restock = {
						_("ammo-comms","We generously resupplied you with some weapon charges."),
						_("ammo-comms","We gave you some of the ordnance you requested"),
						_("ammo-comms","You got some of the weapon charges you asked for."),
						_("ammo-comms","We were able to provide you with some of the ordnance you requested."),
					}
					local good_use = {
						_("ammo-comms","Put them to good use."),
						_("ammo-comms","Use them well."),
						_("ammo-comms","Make good use of them."),
						_("ammo-comms","Do the best you can with them."),
					}
					setCommsMessage(string.format("%s\n%s",tableSelectRandom(partial_ordnance_restock),tableSelectRandom(good_use)))
				end
			else
				local insufficient_rep_responses = {
					_("needRep-comms","Insufficient reputation"),
					_("needRep-comms","Not enough reputation"),
					_("needRep-comms","You need more reputation"),
					string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
					_("needRep-comms","You don't have enough reputation"),
					string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
				}
				setCommsMessage(tableSelectRandom(insufficient_rep_responses))
				return
			end
		else
			if comms_source:getReputationPoints() > points_per_item then
				local complete_refill_unavailable = {
					string.format(_("ammo-comms","You can't afford as many %ss as I'd like to provide to you"),weapon),
					string.format(_("ammo-comms","A full restock of %s costs more than your current reputation"),weapon),
					string.format(_("ammo-comms","You don't have enough reputation for a full restock of %s"),weapon),
					string.format(_("ammo-comms","%i reputation is not enough for a full restock of %s"),math.floor(comms_source:getReputationPoints()),weapon),
				}
				setCommsMessage(tableSelectRandom(complete_refill_unavailable))
				local max_affordable = math.floor(comms_source:getReputationPoints()/points_per_item)
				for i=1,max_affordable do
					addCommsReply(string.format(_("ammo-comms","Get %i (%i x %i = %i reputation)"),i,i,item_amount,i*item_amount),function()
						string.format("")
						if comms_source:takeReputationPoints(i*item_amount) then
							comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + i)
							if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
								local restocked_on_selected_ordnance = {
									_("ammo-comms","We loaded the ordnance you requested so you're ready to explode things."),
									string.format(_("ammo-comms","We provided the ordnance requested (amount: %i) You are ready to make things explode."),i),
									string.format(_("ammo-comms","%s's %s magazine has been restocked as requested (amount:%i)"),comms_source:getCallSign(),weapon,i),
									string.format(_("ammo-comms","We stocked your %s magazine (amount: %i)"),weapon,i),
								}
								setCommsMessage(tableSelectRandom(restocked_on_selected_ordnance))
							else
								if i == 1 then
									local single_restock = {
										_("ammo-comms","We generously resupplied you with one weapon charge."),
										_("ammo-comms","We gave you one of the ordnance type you requested"),
										_("ammo-comms","You got one weapon charge of the type you asked for."),
										_("ammo-comms","We were able to provide you with one of the ordnance type you requested."),
									}
									local one_good_use = {
										_("ammo-comms","Put it to good use."),
										_("ammo-comms","Use it well."),
										_("ammo-comms","Make good use of it."),
										_("ammo-comms","Do the best you can with it."),
									}
									setCommsMessage(string.format("%s\n%s",tableSelectRandom(single_restock),tableSelectRandom(one_good_use)))
								else
									local partial_numeric_ordnance_restock = {
										string.format(_("ammo-comms","We generously resupplied you with %i weapon charges."),i),
										string.format(_("ammo-comms","We gave you %i of the ordnance type you requested"),i),
										string.format(_("ammo-comms","You got %i of the weapon charges you asked for."),i),
										string.format(_("ammo-comms","We were able to provide you with %i of the ordnance type you requested."),i),
									}
									local good_use = {
										_("ammo-comms","Put them to good use."),
										_("ammo-comms","Use them well."),
										_("ammo-comms","Make good use of them."),
										_("ammo-comms","Do the best you can with them."),
									}
									setCommsMessage(string.format("%s\n%s",tableSelectRandom(partial_numeric_ordnance_restock),tableSelectRandom(good_use)))
								end
							end
						else
							local insufficient_rep_responses = {
								_("needRep-comms","Insufficient reputation"),
								_("needRep-comms","Not enough reputation"),
								_("needRep-comms","You need more reputation"),
								string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
								_("needRep-comms","You don't have enough reputation"),
								string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
							}
							setCommsMessage(tableSelectRandom(insufficient_rep_responses))
						end
						addCommsReply(_("Back"), commsStation)
					end)
				end
			else
				local insufficient_rep_responses = {
					_("needRep-comms","Insufficient reputation"),
					_("needRep-comms","Not enough reputation"),
					_("needRep-comms","You need more reputation"),
					string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
					_("needRep-comms","You don't have enough reputation"),
					string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
				}
				setCommsMessage(tableSelectRandom(insufficient_rep_responses))
				addCommsReply(_("Back"), commsStation)				
			end
		end
        addCommsReply(_("Back"), commsStation)
    end
end
function getRepairCrewFromStation()
	if comms_target.comms_data.available_repair_crew == nil then
		if station_repair_crew_inventory_min == nil then
			initializeStationRepairCrewEconomy()
		end
		comms_target.comms_data.available_repair_crew = math.random(station_repair_crew_inventory_min,station_repair_crew_inventory_max)
		comms_target.comms_data.available_repair_crew_cost_friendly = math.random(station_repair_crew_friendly_min,station_repair_crew_friendly_max)
		comms_target.comms_data.available_repair_crew_cost_neutral = math.random(station_repair_crew_neutral_min,station_repair_crew_neutral_max)
		comms_target.comms_data.available_repair_crew_excess = math.random(station_repair_crew_cost_excess_fee_min,station_repair_crew_cost_excess_fee_max)
		comms_target.comms_data.available_repair_crew_stranger = math.random(station_repair_crew_stranger_fee_min,station_repair_crew_stranger_fee_max)
	end
	if comms_target.comms_data.available_repair_crew > 0 then	--station has repair crew available
		local get_repair_crew_prompts = {
			_("trade-comms","Recruit repair crew member"),
			_("trade-comms","Hire repair crew member"),
			_("trade-comms","Get repair crew member"),
			_("trade-comms","Add crew member to repair team"),
		}
		addCommsReply(tableSelectRandom(get_repair_crew_prompts),function()
			if comms_target.comms_data.crew_available_delay == nil or getScenarioTime() > comms_target.comms_data.crew_available_delay then
				local hire_cost = 0
				if comms_source:isFriendly(comms_target) then
					hire_cost = comms_target.comms_data.available_repair_crew_cost_friendly
				else
					hire_cost = comms_target.comms_data.available_repair_crew_cost_neutral
				end
				if comms_target.comms_data.friendlyness <= station_repair_crew_very_friendly_threshold then
					hire_cost = hire_cost + comms_target.comms_data.available_repair_crew_stranger
				end
				if comms_source.maxRepairCrew == nil then
					initializeCommsSourceMaxRepairCrew()
				end
				if comms_source:getRepairCrewCount() >= comms_source.maxRepairCrew then
					hire_cost = hire_cost + comms_target.comms_data.available_repair_crew_excess
				end
				local consider_repair_crew = {
					_("trade-comms","We have a repair crew candidate for you to consider"),
					_("trade-comms","There's a repair crew candidate here for you to consider"),
					_("trade-comms","Consider hiring this repair crew candidate"),
					_("trade-comms","Would you like to hire this repair crew candidate?"),
				}
				setCommsMessage(tableSelectRandom(consider_repair_crew))
				local recruit_repair_crew_prompt = {
					string.format(_("trade-comms","Recruit repair crew member for %i reputation"),hire_cost),
					string.format(_("trade-comms","Hire repair crew member for %i reputation"),hire_cost),
					string.format(_("trade-comms","Spend %i reputation to recruit repair crew member"),hire_cost),
					string.format(_("trade-comms","Spend %i reuptation to hire repair crew member"),hire_cost),
				}
				addCommsReply(tableSelectRandom(recruit_repair_crew_prompt), function()
					if not comms_source:isDocked(comms_target) then 
						local stay_docked_to_get_repair_crew = {
							_("trade-comms","You need to stay docked for that action."),
							_("trade-comms","You need to stay docked to hire repair crew."),
							string.format(_("trade-comms","You must stay docked long enough for your repair crew to board %s"),comms_source:getCallSign()),
							string.format(_("trade-comms","You undocked before the repair crew you wanted to hire could come aboard from %s"),comms_target:getCallSign()),
						}
						setCommsMessage(tableSelectRandom(stay_docked_to_get_repair_crew))
						return
					end
					if not comms_source:takeReputationPoints(hire_cost) then
						local insufficient_rep_responses = {
							_("needRep-comms","Insufficient reputation"),
							_("needRep-comms","Not enough reputation"),
							_("needRep-comms","You need more reputation"),
							string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
							_("needRep-comms","You don't have enough reputation"),
							string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
						}
						setCommsMessage(tableSelectRandom(insufficient_rep_responses))
					else
						comms_source:setRepairCrewCount(comms_source:getRepairCrewCount() + 1)
						comms_target.comms_data.available_repair_crew = comms_target.comms_data.available_repair_crew - 1
						if comms_target.comms_data.available_repair_crew <= 0 then
							comms_target.comms_data.new_repair_crew_delay = getScenarioTime() + random(200,500)
						end
						local repair_crew_hired = {
							_("trade-comms","Repair crew member hired"),
							_("trade-comms","Repair crew member recruited"),
							string.format(_("trade-comms","%s has a new repair crew member"),comms_source:getCallSign()),
							string.format(_("trade-comms","Your new repair crew member boards %s and heads down to damage control"),comms_source:getCallSign()),
						}
						setCommsMessage(tableSelectRandom(repair_crew_hired))
						comms_target.comms_data.crew_available_delay_reason = nil
					end
					addCommsReply(_("Back"), commsStation)
				end)
				comms_target.comms_data.crew_available_delay = getScenarioTime() + random(90,300)
			else
				local delay_reason = {
					_("trade-comms","A possible repair recruit is awaiting final certification. They should be available in "),
					_("trade-comms","There's one repair crew candidate completing their license application. They should be available in "),
					_("trade-comms","One repair crew should be getting here from their medical checkout in "),
				}
				if comms_target.comms_data.crew_available_delay_reason == nil then
					comms_target.comms_data.crew_available_delay_reason = delay_reason[math.random(1,#delay_reason)]
				end
				local delay_seconds = math.floor(comms_target.comms_data.crew_available_delay - getScenarioTime())
				setCommsMessage(string.format(_("trade-comms","%s %i seconds"),comms_target.comms_data.crew_available_delay_reason,delay_seconds))
			end
			addCommsReply(_("Back"), commsStation)
		end)
	end
end
function getCoolantFromStation()
	if comms_target.comms_data.coolant_inventory == nil then
		if station_coolant_inventory_min == nil then
			initializeStationCoolantEconomy()
		end
		comms_target.comms_data.coolant_inventory = math.random(station_coolant_inventory_min,station_coolant_inventory_max)*2
		comms_target.comms_data.coolant_inventory_cost_friendly = math.random(station_coolant_friendly_min,station_coolant_friendly_max)
		comms_target.comms_data.coolant_inventory_cost_neutral = math.random(station_coolant_neutral_min,station_coolant_neutral_max)
		comms_target.comms_data.coolant_inventory_cost_excess = math.random(station_coolant_cost_excess_fee_min,station_coolant_cost_excess_fee_max)
		comms_target.comms_data.coolant_inventory_cost_stranger = math.random(station_coolant_stranger_fee_min,station_coolant_stranger_fee_max)
	end
	if comms_source.initialCoolant == nil then
		initializeCommsSourceInitialCoolant()
	end
	if comms_target.comms_data.coolant_inventory > 0 then
		local get_coolant_prompts = {
			_("trade-comms","Purchase coolant"),
			_("trade-comms","Get more coolant"),
			string.format(_("trade-comms","Get coolant from %s"),comms_target:getCallSign()),
			string.format(_("trade-comms","Ask for more coolant from %s"),comms_target:getCallSign()),
		}
		addCommsReply(tableSelectRandom(get_coolant_prompts),function()
			if comms_target.comms_data.coolant_inventory_delay == nil or getScenarioTime() > comms_target.comms_data.coolant_inventory_delay then
				local coolant_cost = 0
				if comms_source:isFriendly(comms_target) then
					coolant_cost = comms_target.comms_data.coolant_inventory_cost_friendly
				else
					coolant_cost = comms_target.comms_data.coolant_inventory_cost_neutral
				end
				if comms_target.comms_data.friendlyness <= station_coolant_very_friendly_threshold then
					coolant_cost = coolant_cost + comms_target.comms_data.coolant_inventory_cost_stranger
				end
				if comms_source:getMaxCoolant() >= comms_source.initialCoolant then
					coolant_cost = coolant_cost + comms_target.comms_data.coolant_inventory_cost_excess
				end
				local coolant_banter = {
					_("trade-comms","So you want to cool off even more, eh?"),
					_("trade-comms","Ship getting too hot for you?"),
					string.format(_("trade-comms","What makes %s so hot that you need more coolant?"),comms_source:getCallSign()),
					string.format(_("trade-comms","Is %s experiencing drought conditions?"),comms_source:getCallSign()),
				}
				setCommsMessage(tableSelectRandom(coolant_banter))
				local purchase_coolant_prompts = {
					string.format(_("trade-comms","Purchase coolant for %i reputation"),coolant_cost),
					string.format(_("trade-comms","Get additional coolant for %i reputation"),coolant_cost),
					string.format(_("trade-comms","Purchase coolant from %s (%i reputation)"),comms_target:getCallSign(),coolant_cost),
					string.format(_("trade-comms","Get coolant from %s for %i reputation"),comms_target:getCallSign(),coolant_cost),
				}
				addCommsReply(tableSelectRandom(purchase_coolant_prompts),function()
					if not comms_source:isDocked(comms_target) then 
						local stay_docked_to_get_coolant = {
							_("trade-comms","You need to stay docked for that action."),
							_("trade-comms","You need to stay docked to get coolant."),
							string.format(_("trade-comms","You must stay docked long enough for your coolant to be loaded on to %s"),comms_source:getCallSign()),
							string.format(_("trade-comms","You undocked before the coolant you wanted could be loaded from %s"),comms_target:getCallSign()),
						}
						setCommsMessage(tableSelectRandom(stay_docked_to_get_coolant))
						return
					end
					if not comms_source:takeReputationPoints(coolant_cost) then
						local insufficient_rep_responses = {
							_("needRep-comms","Insufficient reputation"),
							_("needRep-comms","Not enough reputation"),
							_("needRep-comms","You need more reputation"),
							string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
							_("needRep-comms","You don't have enough reputation"),
							string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
						}
						setCommsMessage(tableSelectRandom(insufficient_rep_responses))
					else
						comms_source:setMaxCoolant(comms_source:getMaxCoolant() + 2)
						comms_target.comms_data.coolant_inventory = comms_target.comms_data.coolant_inventory - 2
						local got_coolant_confirmation = {
							_("trade-comms","Additional coolant purchased"),
							_("trade-comms","You got more coolant"),
							string.format(_("trade-comms","%s has loaded additional coolant onto %s"),comms_target:getCallSign(),comms_source:getCallSign()),
							string.format(_("trade-comms","%s has provided you with some additional coolant"),comms_target:getCallSign()),
						}
						setCommsMessage(tableSelectRandom(got_coolant_confirmation))
						comms_target.comms_date.coolant_delay_reason = nil
					end
					addCommsReply(_("Back"), commsStation)
				end)
				comms_target.comms_data.coolant_inventory_delay = getScenarioTime() + random(90,300)
			else
				local coolant_delay_reason = {
					_("trade-comms","We are in the process of making more coolant. It should be available in "),
					_("trade-comms","More coolant should be available in "),
					_("trade-comms","We can get more coolant. Check back in "),
				}
				if comms_target.comms_data.coolant_delay_reason == nil then
					comms_target.comms_data.coolant_delay_reason = tableSelectRandom(coolant_delay_reason)
				end
				local delay_seconds = math.floor(comms_target.comms_data.coolant_inventory_delay - getScenarioTime())
				setCommsMessage(string.format(_("trade-comms","%s %i seconds"),comms_target.comms_data.coolant_delay_reason,delay_seconds))
			end
			addCommsReply(_("Back"), commsStation)
		end)
	end
end
function repairShip()
	if pretty_system == nil then
		initializePrettySystems()
	end
	if system_list == nil then
		initializeSystemList()
	end
	local repair_type_prompt = {
		_("station-comms","What kind of repairs do you need?"),
		_("station-comms","What kind of repairs can we help you with?"),
		_("station-comms","We might be able to help. Let us know what you need."),
	}
	setCommsMessage(tableSelectRandom(repair_type_prompt))
	local options_presented_count = 0
	--	secondary system repair
	local secondary_system = {
		{prompt = _("stationServices-comms","Repair probe launch system (%s Rep)"),	capable = true,									station_avail = comms_target.comms_data.probe_launch_repair,	cost = comms_target.comms_data.service_cost.probe_launch_repair,	ship_avail = comms_source:getCanLaunchProbe(),		enable = "setCanLaunchProbe",	response = _("stationServices-comms", "Your probe launch system has been repaired.")},
		{prompt = _("stationServices-comms","Repair hacking system (%s Rep)"),		capable = true,									station_avail = comms_target.comms_data.hack_repair,			cost = comms_target.comms_data.service_cost.hack_repair,			ship_avail = comms_source:getCanHack(),				enable = "setCanHack",			response = _("stationServices-comms", "Your hacking system has been repaired.")},
		{prompt = _("stationServices-comms","Repair scanning system (%s Rep)"),		capable = true,									station_avail = comms_target.comms_data.scan_repair,			cost = comms_target.comms_data.service_cost.scan_repair,			ship_avail = comms_source:getCanScan(),				enable = "setCanScan",			response = _("stationServices-comms", "Your scanners have been repaired.")},
		{prompt = _("stationServices-comms","Repair combat maneuver (%s Rep)"),		capable = comms_source.combat_maneuver_capable,	station_avail = comms_target.comms_data.combat_maneuver_repair,	cost = comms_target.comms_data.service_cost.combat_maneuver_repair,	ship_avail = comms_source:getCanCombatManeuver(),	enable = "setCanCombatManeuver",response = _("stationServices-comms", "Your combat maneuver has been repaired.")},
		{prompt = _("stationServices-comms","Repair self destruct system (%s Rep)"),capable = true,									station_avail = comms_target.comms_data.self_destruct_repair,	cost = comms_target.comms_data.service_cost.self_destruct_repair,	ship_avail = comms_source:getCanSelfDestruct(),		enable = "setCanSelfDestruct",	response = _("stationServices-comms", "Your self destruct system has been repaired.")},
	}
	local offer_repair = false
	for i,secondary in ipairs(secondary_system) do
		if secondary.station_avail and not secondary.ship_avail and secondary.capable then
			offer_repair = true
			break
		end
	end
	if offer_repair then
		options_presented_count = options_presented_count + 1
		local repair_secondary_prompts = {
			_("stationServices-comms","Repair secondary ship system"),
			_("stationServices-comms","Make repairs to secondary ship system"),
			_("stationServices-comms","Fix secondary ship system"),
			_("stationServices-comms","Request repairs to secondary ship system"),
		}
		addCommsReply(tableSelectRandom(repair_secondary_prompts),function()
			local which_secondary_system = {
				_("dockingServicesStatus-comms","What system would you like repaired?"),
				_("dockingServicesStatus-comms","What system needs fixing?"),
				_("dockingServicesStatus-comms","Please identify the secondary system that is in need of repair"),
				string.format(_("dockingServicesStatus-comms","Poor, poor %s. What part of her is hurting now?"),comms_source:getCallSign()),
			}
			setCommsMessage(tableSelectRandom(which_secondary_system))
			local secondary_options_presented_count = 0
			for i,secondary in ipairs(secondary_system) do
				if not secondary.ship_avail then
					if secondary.capable then
						secondary_options_presented_count = secondary_options_presented_count + 1
						addCommsReply(string.format(secondary.prompt,secondary.cost),function()
							if not comms_source:isDocked(comms_target) then
								local stay_docked_to_repair = {
									_("trade-comms","You need to stay docked for that action."),
									_("trade-comms","You need to stay docked to trade for the repair."),
									string.format(_("trade-comms","You must stay docked long enough for the repair by %s to %s to be completed."),comms_target:getCallSign(),comms_source:getCallSign()),
									string.format(_("trade-comms","You undocked before %s could complete the repair you requested."),comms_target:getCallSign()),
								}
								setCommsMessage(tableSelectRandom(stay_docked_to_repair))
								return
							end
							if comms_source:takeReputationPoints(secondary.cost) then
								if secondary.enable == "setCanLaunchProbe" then
									comms_source:setCanLaunchProbe(true)
								elseif secondary.enable == "setCanHack" then
									comms_source:setCanHack(true)
								elseif secondary.enable == "setCanScan" then
									comms_source:setCanScan(true)
								elseif secondary.enable == "setCanCombatManeuver" then
									comms_source:setCanCombatManeuver(true)
								elseif secondary.enable == "setCanSelfDestruct" then
									comms_source:setCanSelfDestruct(true)
								end
								setCommsMessage(secondary.response)
							else
								local insufficient_rep_responses = {
									_("needRep-comms","Insufficient reputation"),
									_("needRep-comms","Not enough reputation"),
									_("needRep-comms","You need more reputation"),
									string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
									_("needRep-comms","You don't have enough reputation"),
									string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
								}
								setCommsMessage(tableSelectRandom(insufficient_rep_responses))
							end
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
			end
		end)
	end
	--	primary system repair
	local system_repair_list = {}
	offer_repair = false
	if comms_target.comms_data.system_repair ~= nil then
		for i, system in ipairs(system_list) do
			if comms_source:hasSystem(system) then
				if comms_source:getSystemHealthMax(system) < 1 then
					if comms_target.comms_data.system_repair[system].avail then
						if comms_target.comms_data.system_repair[system].cost > 0 then
							if comms_target.player_system_repair_service == nil then
								offer_repair = true
								table.insert(system_repair_list,system)
							else
								if comms_target.player_system_repair_service[comms_source] == nil then
									offer_repair = true
									table.insert(system_repair_list,system)
								else
									if comms_target.player_system_repair_service[comms_source][system] == nil then
										offer_repair = true
										table.insert(system_repair_list,system)
									end
								end
							end
						end
					end
				end
			end
		end
	end
	if offer_repair then
		options_presented_count = options_presented_count + 1
		local primary_repair_prompt = {
			_("stationServices-comms","Repair primary ship system"),
			_("stationServices-comms","Make repairs to primary ship system"),
			string.format(_("stationServices-comms","Fix primary system on %s"),comms_source:getCallSign()),
			_("stationServices-comms","Fix primary ship system"),
		}
		addCommsReply(tableSelectRandom(primary_repair_prompt),function()
			local what_primary_system = {
				_("stationServices-comms","What system would you like repaired?"),
				_("stationServices-comms","What system is in need of repair?"),
				string.format(_("stationServices-comms","What severe wounds on %s can %s help heal?"),comms_source:getCallSign(),comms_target:getCallSign()),
				string.format(_("stationServices-comms","What primary ship system can %s work on to bring %s back into good working order?"),comms_target:getCallSign(),comms_source:getCallSign()),
			}
			setCommsMessage(tableSelectRandom(what_primary_system))
			for index, system in ipairs(system_repair_list) do
				addCommsReply(string.format(_("stationServices-comms","Repair %s max health up to %.1f%% (%i rep)"),pretty_system[system],comms_target.comms_data.system_repair[system].max*100,comms_target.comms_data.system_repair[system].cost), function()
					if comms_source:takeReputationPoints(comms_target.comms_data.system_repair[system].cost) then
						if comms_target.player_system_repair_service == nil then
							comms_target.player_system_repair_service = {}
						end
						if comms_target.player_system_repair_service[comms_source] == nil then
							comms_target.player_system_repair_service[comms_source] = {}
						end
						comms_target.player_system_repair_service[comms_source][system] = true
						local working_on_system = {
							string.format(_("stationServices-comms","We'll start working on your %s maximum health right away."),pretty_system[system]),
							string.format(_("stationServices-comms","We will put %s repair technicians to work on your %s maximum health immediately."),comms_target:getCallSign(),pretty_system[system]),
							string.format(_("stationServices-comms","%s has put repair technicians to work on %s's %s maximum health."),comms_target:getCallSign(),comms_source:getCallSign(),pretty_system[system]),
							string.format(_("stationServices-comms","We put our most qualified repair technicians to work on your %s maximum health."),pretty_system[system]),
						}
						setCommsMessage(tableSelectRandom(working_on_system))
					else
						local insufficient_rep_responses = {
							_("needRep-comms","Insufficient reputation"),
							_("needRep-comms","Not enough reputation"),
							_("needRep-comms","You need more reputation"),
							string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
							_("needRep-comms","You don't have enough reputation"),
							string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
						}
						setCommsMessage(tableSelectRandom(insufficient_rep_responses))
					end
					addCommsReply(_("Back"), commsStation)
				end)
			end
		end)
	end
	local offer_tune = false
	local tune_system_list = {}
	local tune_coolant_systems = _("stationServices-comms","none")
	local tune_power_systems = _("stationServices-comms","none")
	local tune_heat_systems = _("stationServices-comms","none")
	for i,system in ipairs(system_list) do
		if comms_source:hasSystem(system) then
			if comms_source.coolant_rate ~= nil then
				if comms_source.coolant_rate[system] ~= nil then
					if comms_source.coolant_rate[system] ~= comms_source:getSystemCoolantRate(system) then
						if comms_target.player_system_tune_coolant_service == nil then
							comms_target.player_system_tune_coolant_service = {}
						end
						if comms_target.player_system_tune_coolant_service[system] == nil then
							if random(1,100) < comms_target.comms_data.friendlyness then
								comms_target.player_system_tune_coolant_service[system] = {avail = true, cost = math.random(5,15)}
							else
								comms_target.player_system_tune_coolant_service[system] = {avail = false}
							end
						end
						if comms_target.player_system_tune_coolant_service[system].avail then
							offer_tune = true
							if tune_coolant_systems == _("stationServices-comms","none") then
								tune_coolant_systems = pretty_system[system]
							else
								tune_coolant_systems = string.format("%s, %s",tune_coolant_systems,pretty_system[system])
							end
						end
					end
				end
			end
			if comms_source.power_rate ~= nil then
				if comms_source.power_rate[system] ~= comms_source:getSystemPowerRate(system) then
					if comms_target.player_system_tune_power_service == nil then
						comms_target.player_system_tune_power_service = {}
					end
					if comms_target.player_system_tune_power_service[system] == nil then
						if random(1,100) < comms_target.comms_data.friendlyness then
							comms_target.player_system_tune_power_service[system] = {avail = true, cost = math.random(5,15)}
						else
							comms_target.player_system_tune_power_service[system] = {avail = false}
						end
					end
					if comms_target.player_system_tune_power_service[system].avail then
						offer_tune = true
						if tune_power_systems == _("stationServices-comms","none") then
							tune_power_systems = pretty_system[system]
						else
							tune_power_systems = string.format("%s, %s",tune_power_systems,pretty_system[system])
						end
					end
				end
			end
			if comms_source.heat_rate ~= nil then
				if comms_source.heat_rate[system] ~= comms_source:getSystemHeatRate(system) then
					if comms_target.player_system_tune_heat_service == nil then
						comms_target.player_system_tune_heat_service = {}
					end
					if comms_target.player_system_tune_heat_service[system] == nil then
						if random(1,100) < comms_target.comms_data.friendlyness then
							comms_target.player_system_tune_heat_service[system] = {avail = true, cost = math.random(5,15)}
						else
							comms_target.player_system_tune_heat_service[system] = {avail = false}
						end
					end
					if comms_target.player_system_tune_heat_service[system].avail then
						offer_tune = true
						if tune_heat_systems == _("stationServices-comms","none") then
							tune_heat_systems = pretty_system[system]
						else
							tune_heat_systems = string.format("%s, %s",tune_heat_systems,pretty_system[system])
						end
					end
				end
			end
		end
	end
	if offer_tune then
		options_presented_count = options_presented_count + 1
		local tune_primary_ship_system_prompts = {
			_("stationServices-comms","Tune primary ship system"),
			_("stationServices-comms","Tweak primary ship system"),
			_("stationServices-comms","Tune up primary ship system"),
			_("stationServices-comms","Conduct a tune up on primary ship system"),
		}
		addCommsReply(tableSelectRandom(tune_primary_ship_system_prompts),function()
			local tune_these_systems = {
				_("stationServices-comms","We can tune these systems for you:"),
				_("stationServices-comms","We can tune up these systems for you:"),
				string.format(_("stationServices-comms","%s can tune these systems for you:"),comms_target:getCallSign()),
				_("stationServices-comms","We can tweak these systems for you:"),
			}
			local coolant_pump_label = {
				string.format(_("stationServices-comms","    coolant pump for %s"),tune_coolant_systems),
				string.format(_("stationServices-comms","    coolant pump feeding %s"),tune_coolant_systems),
				string.format(_("stationServices-comms","    coolant pump that cools %s"),tune_coolant_systems),
				string.format(_("stationServices-comms","    coolant pump serving %s"),tune_coolant_systems),
			}
			local power_transfer_label = {
				string.format(_("stationServices-comms","    power transfer for %s"),tune_power_systems),
				string.format(_("stationServices-comms","    power transfer speed for %s"),tune_power_systems),
				string.format(_("stationServices-comms","    power transfer serving %s"),tune_power_systems),
				string.format(_("stationServices-comms","    power transfer affecting %s"),tune_power_systems),
			}
			local heat_sensitivity_label = {
				string.format(_("stationServices-comms","    heat sensitivity of %s"),tune_heat_systems),
				string.format(_("stationServices-comms","    heat sensitivity for %s"),tune_heat_systems),
				string.format(_("stationServices-comms","    heat sensitivity in %s"),tune_heat_systems),
				string.format(_("stationServices-comms","    heat sensitivity affecting %s"),tune_heat_systems),
			}
			setCommsMessage(string.format("%s\n%s\n%s\n%s",tableSelectRandom(tune_these_systems),tableSelectRandom(coolant_pump_label),tableSelectRandom(power_transfer_label),tableSelectRandom(heat_sensitivity_label)))
			if tune_coolant_systems ~= _("stationServices-comms","none") then
				local tune_coolant_pump_prompts = {
					_("stationServices-comms","Tune coolant pump"),
					_("stationServices-comms","Tweak coolant pump"),
					_("stationServices-comms","Tune up the coolant pump"),
					_("stationServices-comms","Conduct a tune up on the coolant pump"),
				}
				addCommsReply(tableSelectRandom(tune_coolant_pump_prompts),function()
					local coolant_pump_system_list_header = {
						_("stationServices-comms","We can tune the coolant pump for these systems:"),
						_("stationServices-comms","We can tweak the coolant pump for these systems:"),
						_("stationServices-comms","We can tune up the coolant pump for the following systems:"),
						string.format(_("stationServices-comms","%s can tune the coolant pump for these systems:"),comms_target:getCallSign()),
					}
					setCommsMessage(tableSelectRandom(coolant_pump_system_list_header))
					for i,system in ipairs(system_list) do
						if comms_source:hasSystem(system) then
							if comms_source.coolant_rate ~= nil then
								if comms_source.coolant_rate[system] ~= nil then
									if comms_source.coolant_rate[system] ~= comms_source:getSystemCoolantRate(system) then
										if comms_target.player_system_tune_coolant_service[system].avail then
											addCommsReply(string.format(_("stationServices-comms","%s (%i reputation)"),pretty_system[system],comms_target.player_system_tune_coolant_service[system].cost),function()
												if comms_source:takeReputationPoints(comms_target.player_system_tune_coolant_service[system].cost) then
													comms_source:setSystemCoolantRate(system,comms_source.coolant_rate[system])
													local coolant_tuned = {
														string.format(_("stationServices-comms","The coolant pump for %s has been tuned to original specifications."),pretty_system[system]),
														string.format(_("stationServices-comms","The %s coolant pump has been tuned to original specifications."),pretty_system[system]),
														string.format(_("stationServices-comms","We've returned the %s coolant pump to its manufacturer's specifications."),pretty_system[system]),
														string.format(_("stationServices-comms","%s tuned the %s coolant pump to its original specifications."),comms_target:getCallSign(),pretty_system[system]),
													}
													setCommsMessage(tableSelectRandom(coolant_tuned))
												else
													local insufficient_rep_responses = {
														_("needRep-comms","Insufficient reputation"),
														_("needRep-comms","Not enough reputation"),
														_("needRep-comms","You need more reputation"),
														string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
														_("needRep-comms","You don't have enough reputation"),
														string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
													}
													setCommsMessage(tableSelectRandom(insufficient_rep_responses))
												end
												addCommsReply(_("Back"), commsStation)
											end)
										end
									end
								end
							end
						end
					end
					addCommsReply(_("Back"), commsStation)
				end)
			end
			if tune_power_systems ~= _("stationServices-comms","none") then
				local tune_power_transfer_prompts = {
					_("stationServices-comms","Tune power transfer"),
					_("stationServices-comms","Tweak power transfer"),
					_("stationServices-comms","Tune up power transfer"),
					_("stationServices-comms","Conduct a tune up on the power transfer system"),
				}
				addCommsReply(tableSelectRandom(tune_power_transfer_prompts),function()
					local power_transfer_system_list_header = {
						_("stationServices-comms","We can tune the power transfer rate for these systems:"),
						_("stationServices-comms","We can tweak the power transfer rate for these systems:"),
						_("stationServices-comms","We can tune up the power transfer rate for the following systems:"),
						string.format(_("stationServices-comms","%s can tune the power transfer rate for these systems:"),comms_target:getCallSign()),
					}
					setCommsMessage(tableSelectRandom(power_transfer_system_list_header))
					for i,system in ipairs(system_list) do
						if comms_source:hasSystem(system) then
							if comms_source.power_rate ~= nil then
								if comms_source.power_rate[system] ~= nil then
									if comms_source.power_rate[system] ~= comms_source:getSystemPowerRate(system) then
										if comms_target.player_system_tune_power_service[system].avail then
											addCommsReply(string.format(_("stationServices-comms","%s (%i reputation)"),pretty_system[system],comms_target.player_system_tune_power_service[system].cost),function()
												if comms_source:takeReputationPoints(comms_target.player_system_tune_power_service[system].cost) then
													comms_source:setSystemPowerRate(system,comms_source.power_rate[system])
													local power_transfer_tuned = {
														string.format(_("stationServices-comms","The power transfer rate for %s has been tuned to original specifications."),pretty_system[system]),
														string.format(_("stationServices-comms","The %s power transfer rate has been tuned to original specifications."),pretty_system[system]),
														string.format(_("stationServices-comms","We've returned the %s power transfer rate to its manufacturer's specifications."),pretty_system[system]),
														string.format(_("stationServices-comms","%s technicians have tuned the %s power transfer rate to its original specifications."),comms_target:getCallSign(),pretty_system[system]),
													}
													setCommsMessage(tableSelectRandom(power_transfer_tuned))
												else
													local insufficient_rep_responses = {
														_("needRep-comms","Insufficient reputation"),
														_("needRep-comms","Not enough reputation"),
														_("needRep-comms","You need more reputation"),
														string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
														_("needRep-comms","You don't have enough reputation"),
														string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
													}
													setCommsMessage(tableSelectRandom(insufficient_rep_responses))
												end
												addCommsReply(_("Back"), commsStation)
											end)
										end
									end
								end
							end
						end
					end
					addCommsReply(_("Back"), commsStation)
				end)
			end
			if tune_heat_systems ~= _("stationServices-comms","none") then
				local tune_heat_sensitivity_prompts = {
					_("stationServices-comms","Tune heat sensitivity"),
					_("stationServices-comms","Tweak heat sensitivity"),
					_("stationServices-comms","Tune up heat sensitivity"),
					_("stationServices-comms","Conduct a tune up on heat sensitivity"),
				}
				addCommsReply(tableSelectRandom(tune_heat_sensitivity_prompts),function()
					local heat_sensitivity_system_list_header = {
						_("stationServices-comms","We can tune the heat sensitivity for these systems:"),
						_("stationServices-comms","We can tweak the heat sensitivity for these systems:"),
						_("stationServices-comms","We can tune up the heat sensitivity for the following systems:"),
						string.format(_("stationServices-comms","%s can tune the heat sensitivity for these systems:"),comms_target:getCallSign()),
					}
					setCommsMessage(tableSelectRandom(heat_sensitivity_system_list_header))
					for i,system in ipairs(system_list) do
						if comms_source:hasSystem(system) then
							if comms_source.heat_rate ~= nil then
								if comms_source.heat_rate[system] ~= nil then
									if comms_source.heat_rate[system] ~= comms_source:getSystemHeatRate(system) then
										if comms_target.player_system_tune_heat_service[system].avail then
											addCommsReply(string.format(_("stationServices-comms","%s (%i reputation)"),pretty_system[system],comms_target.player_system_tune_heat_service[system].cost),function()
												if comms_source:takeReputationPoints(comms_target.player_system_tune_heat_service[system].cost) then
													comms_source:setSystemHeatRate(system,comms_source.heat_rate[system])
													local heat_sensitivity_tuned = {
														string.format(_("stationServices-comms","The heat sensitivity for %s has been tuned to original specifications."),pretty_system[system]),
														string.format(_("stationServices-comms","The %s heat sensitivity has been tuned to original specifications."),pretty_system[system]),
														string.format(_("stationServices-comms","We've returned the %s heat sensitivity to its manufacturer's specifications."),pretty_system[system]),
														string.format(_("stationServices-comms","%s technicians have tuned the %s heat sensitivity to its original specifications."),comms_target:getCallSign(),pretty_system[system]),
													}
													setCommsMessage(tableSelectRandom(heat_sensitivity_tuned))
												else
													local insufficient_rep_responses = {
														_("needRep-comms","Insufficient reputation"),
														_("needRep-comms","Not enough reputation"),
														_("needRep-comms","You need more reputation"),
														string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
														_("needRep-comms","You don't have enough reputation"),
														string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
													}
													setCommsMessage(tableSelectRandom(insufficient_rep_responses))
												end
												addCommsReply(_("Back"), commsStation)
											end)
										end
									end
								end
							end
						end
					end
					addCommsReply(_("Back"), commsStation)
				end)
			end
		end)
	end
	if options_presented_count == 0 then
		local no_applicable_repair_service = {
			_("stationServices-comms","No applicable repair service available"),
			string.format(_("stationServices-comms","%s has no repair service that %s can use"),comms_target:getCallSign(),comms_source:getCallSign()),
			_("stationServices-comms","There's no repair service here that applies to your ship"),
			string.format(_("stationServices-comms","There's nothing on %s that %s can repair"),comms_source:getCallSign(),comms_target:getCallSign()),
		}
		setCommsMessage(tableSelectRandom(no_applicable_repair_service))
	end
end
--	Booleans to set outside of this utility to control this utility. Default is false
--		upgrade_downgrade_path - set true when player ships follow the upgrade/downgrade
--			path in player_ship_upgrade_downgrade_path_scenario_utility.lua
--		overcharge_jump_drive - set if stations can overcharge player ship's jump drives
--		overcharge_shields - set if stations can overcharge player ship's shields
function enhanceShip()
	local enhance_type_prompt = {
		_("station-comms","What kind of enhancements are you interested in?"),
		_("station-comms","Which of these enhancements might you interested in?"),
		_("station-comms","Which kind of enhancement do you crave?"),
		_("station-comms","What enhancement type do you want?"),
	}
	setCommsMessage(tableSelectRandom(enhance_type_prompt))
	if add_repair_crew then
		getRepairCrewFromStation()
	end
	if add_coolant then
		getCoolantFromStation()
	end
	if upgrade_downgrade_path then
		upgradeShip()
	end
	minorUpgrades()
	if overcharge_jump_drive or overcharge_shields then
		overchargeShipSystems()
	end
	addCommsReply(_("Back"), commsStation)
end
function upgradeShip()
	if system_list == nil then
		initializeSystemList()
	end
	if upgrade_price == nil then
		initializeUpgradeDowngrade()
	end
	local good_count = 0
	if comms_target.comms_data.goods ~= nil then
		for good, good_data in pairs(comms_target.comms_data.goods) do
			good_count = good_count + 1
		end
	end
	if comms_target.comms_data.upgrade_path ~= nil then
		local p_ship_type = comms_source:getTypeName()
		if comms_target.comms_data.upgrade_path[p_ship_type] ~= nil then
			local upgrade_primary_ship_systems_prompts = {
				_("upgrade-comms","Upgrade primary ship systems"),
				_("upgrade-comms","Primary ship systems upgrade"),
				string.format(_("upgrade-comms","Upgrade primary systems on %s"),comms_source:getCallSign()),
				string.format(_("upgrade-comms","Upgrade %s's primary systems"),comms_source:getCallSign()),
			}
			addCommsReply(tableRemoveRandom(upgrade_primary_ship_systems_prompts),function()
				local outer_upgrade_count = 0
				local inner_upgrade_count = 0
				for u_type, u_blob in pairs(comms_target.comms_data.upgrade_path[p_ship_type]) do
					local p_upgrade_level = comms_source.upgrade_path[u_type]
					if u_blob.max > p_upgrade_level then
						outer_upgrade_count = outer_upgrade_count + 1
						if upgrade_path[p_ship_type][u_type][p_upgrade_level + 1] ~= nil then
							inner_upgrade_count = inner_upgrade_count + 1
							addCommsReply(string.format("%s: %s",u_type,upgrade_path[p_ship_type][u_type][p_upgrade_level + 1].desc),function()
								if comms_target.good_traded_for_upgrade == nil then
									comms_target.good_traded_for_upgrade = {"food","medicine"}
								end
								if good_count > 0 then
									if comms_source.goods ~= nil then
										local trade_good_list = {}
										for good, good_quantity in ipairs(comms_source.goods) do
											if good_quantity > 0 then
												local traded = false
												for i,traded_good in ipairs(comms_target.good_traded_for_upgrade) do
													if traded_good == good then
														traded = true
														break
													end
												end
												if not traded then
													table.insert(trade_good_list,good)
												end
											end
										end
									end
								end
								local tandem_modified_system = nil
								local random_system = nil
								if upgrade_path[p_ship_type][u_type][1].downgrade ~= nil then
									local upgraded_systems = {}
									for p_u_system, p_u_level in pairs(comms_source.upgrade_path) do
										if p_u_system ~= u_type and p_u_level > 1 then
											table.insert(upgraded_systems,{sys=p_u_system,lvl=p_u_level,desc=upgrade_path[p_ship_type][p_u_system][p_u_level - 1].downgrade})
										end
									end
									table.sort(upgraded_systems,function(a,b)
										return a.lvl > b.lvl
									end)
									if #upgraded_systems > 0 then
										tandem_modified_system = upgraded_systems[1]
										random_system = upgraded_systems[math.random(1,#upgraded_systems)]
									end
								end
								local provide_type = {
									{desc = _("upgrade-comms","Premium: certified and supervised technician performs the upgrade."),												trade = false,	avail = false,	prompt = _("upgrade-comms","Premium (%s reputation)"),		cost = math.ceil(base_upgrade_cost+30+((p_upgrade_level+1)*upgrade_price))},	--1
									{desc = _("upgrade-comms","Premium Trade Good: certified and supervised technician performs the upgrade in exchange for cargo on your ship."),	trade = true,	avail = false,	prompt = _("upgrade-comms","Premium trade good (%s)"),		},																				--2
									{desc = _("upgrade-comms","Standard: certified technician performs the upgrade."),																trade = false,	avail = false,	prompt = _("upgrade-comms","Standard (%s reputation)"),		cost = math.ceil(base_upgrade_cost+20+((p_upgrade_level+1)*upgrade_price))},	--3
									{desc = _("upgrade-comms","Trade Off: freelance technician performs the upgrade, but another system will be modified."),						trade = false,	avail = false,	prompt = _("upgrade-comms","Trade off (%s reputation)"),	cost = math.ceil(base_upgrade_cost+10+((p_upgrade_level+1)*upgrade_price))},	--4
									{desc = _("upgrade-comms","Pit Droid: upgrade guaranteed, but another system may be modified."),												trade = false,	avail = true,	prompt = _("upgrade-comms","Pit droid (%s reputation)"),	cost = math.ceil(base_upgrade_cost+((p_upgrade_level+1)*upgrade_price))},		--5
								}
								if comms_target.comms_data.premium_thresh == nil then
									comms_target.comms_data.premium_thresh = random(30,75)
								end
								if comms_target.comms_data.friendlyness > comms_target.comms_data.premium_thresh then
									provide_type[1].avail = true
								end
								if trade_good_list ~= nil and #trade_good_list > 0 then
									if comms_target.comms_data.premium_trade_thresh == nil then
										comms_target.comms_data.premium_trade_thresh = random(10,30)
									end
									if comms_target.comms_data.friendlyness > comms_target.comms_data.premium_trade_thresh then
										provide_type[2].avail = true
									end
								end
								if comms_target.comms_data.standard_thresh == nil then
									comms_target.comms_data.standard_thresh = random(15,60)
								end
								if comms_target.comms_data.friendlyness > comms_target.comms_data.standard_thresh then
									provide_type[3].avail = true
								end
								if tandem_modified_system ~= nil then
									if comms_target.comms_data.trade_off_thresh == nil then
										comms_target.comms_data.trade_off_thresh = random(20,75)
									end
									if comms_target.comms_data.friendlyness > comms_target.comms_data.trade_off_thresh then
										provide_type[4].avail = true
									end
								end
								local provide_count = 0
								local provide_out = ""
								for i,provide in ipairs(provide_type) do
									if provide.avail then
										provide_count = provide_count + 1
										if provide_out == "" then
											provide_out = provide.desc
										else
											provide_out = string.format("%s\n%s",provide_out,provide.desc)
										end
									end
								end
								if provide_count > 1 then
									local multiple_provision_ways = {
										string.format(_("upgrade-comms","We've got %i ways to provide the %s upgrade (%s):\n%s"),provide_count,u_type,upgrade_path[p_ship_type][u_type][p_upgrade_level + 1].desc,provide_out),
										string.format(_("upgrade-comms","There are %i ways for you to get the %s upgrade (%s):\n%s"),provide_count,u_type,upgrade_path[p_ship_type][u_type][p_upgrade_level + 1].desc,provide_out),
										string.format(_("upgrade-comms","%s has %i ways to provide the %s upgrade (%s):\n%s"),comms_target:getCallSign(),provide_count,u_type,upgrade_path[p_ship_type][u_type][p_upgrade_level + 1].desc,provide_out),
										string.format(_("upgrade-comms","%s can provide the %s upgrade (%s) in %i different ways:\n%s"),comms_target:getCallSign(),u_type,upgrade_path[p_ship_type][u_type][p_upgrade_level + 1].desc,provide_count,provide_out),
									}
									provide_out = tableRemoveRandom(multiple_provision_ways)
								else
									local one_provision_way = {
										string.format(_("upgrade-comms","We've got one way to provide the %s upgrade (%s):\n%s"),u_type,upgrade_path[p_ship_type][u_type][p_upgrade_level + 1].desc,provide_out),
										string.format(_("upgrade-comms","There is one way for you to get the %s upgrade (%s):\n%s"),u_type,upgrade_path[p_ship_type][u_type][p_upgrade_level + 1].desc,provide_out),
										string.format(_("upgrade-comms","%s has one way to provide the %s upgrade (%s):\n%s"),comms_target:getCallSign(),u_type,upgrade_path[p_ship_type][u_type][p_upgrade_level + 1].desc,provide_out),
										string.format(_("upgrade-comms","%s can provide the %s upgrade (%s) in one way:\n%s"),comms_target:getCallSign(),u_type,upgrade_path[p_ship_type][u_type][p_upgrade_level + 1].desc,provide_out),
									}
									provide_out = tableRemoveRandom(one_provision_way)
								end
								setCommsMessage(provide_out)
								for i,provide in ipairs(provide_type) do
									if provide.avail then
										if provide.trade then
											for j, trade_good in ipairs(trade_good_list) do
												addCommsReply(string.format(_("upgrade-comms","Trade (%s)"),trade_good),function()
													if not comms_source:isDocked(comms_target) then 
														local stay_docked_to_trade = {
															_("trade-comms","You need to stay docked for that action."),
															_("trade-comms","You need to stay docked to trade for upgrade."),
															string.format(_("trade-comms","You must stay docked long enough for a trade for upgrade between %s and %s to be completed."),comms_target:getCallSign(),comms_source:getCallSign()),
															string.format(_("trade-comms","You undocked before %s could complete the trade for upgrade you requested."),comms_target:getCallSign()),
														}
														setCommsMessage(tableRemoveRandom(stay_docked_to_trade))
														return
													end
													if comms_source.goods[trade_good] ~= nil and comms_source.goods[trade_good] > 0 then
														comms_source.goods[trade_good] = comms_source.goods[trade_good] - 1
														table.insert(comms_target.good_traded_for_upgrade,trade_good)
														upgradePlayerShip(comms_source,u_type)
														local upgrade_complete_confirmation = {
															_("upgrade-comms","Upgrade complete"),
															_("upgrade-comms","Upgraded"),
															string.format(_("upgrade-comms","%s has completed your upgrade"),comms_target:getCallSign()),
															string.format(_("upgrade-comms","%s has been upgraded"),comms_source:getCallSign()),
														}
														setCommsMessage(tableRemoveRandom(upgrade_complete_confirmation))
													else
														local not_enough_cargo = {
															_("upgrade-comms","Insufficient cargo"),
															_("upgrade-comms","You don't have enough cargo"),
															_("upgrade-comms","Not enough cargo"),
															string.format(_("upgrade-comms","%s does not have what %s wants"),comms_source:getCallSign(),comms_target:getCallSign()),
														}
														setCommsMessage(tableRemoveRandom(not_enough_cargo))
													end
													addCommsReply(_("Back"), commsStation)
												end)
											end
										else
											addCommsReply(string.format(provide.prompt,provide.cost),function()
												if not comms_source:isDocked(comms_target) then 
													local stay_docked_to_upgrade = {
														_("upgrade-comms","You need to stay docked for that action."),
														_("upgrade-comms","You need to stay docked to upgrade."),
														string.format(_("upgrade-comms","You must stay docked long enough for %s to upgrade upgrade %s."),comms_target:getCallSign(),comms_source:getCallSign()),
														string.format(_("upgrade-comms","You undocked before %s could complete the upgrade you requested."),comms_target:getCallSign()),
													}
													setCommsMessage(tableRemoveRandom(stay_docked_to_upgrade))
													return
												end
												if comms_source:takeReputationPoints(provide.cost) then
													upgradePlayerShip(comms_source,u_type)
													local upgrade_complete_confirmation = {
														_("upgrade-comms","Upgrade complete"),
														_("upgrade-comms","Upgraded"),
														string.format(_("upgrade-comms","%s has completed your upgrade"),comms_target:getCallSign()),
														string.format(_("upgrade-comms","%s has been upgraded"),comms_source:getCallSign()),
													}
													setCommsMessage(tableRemoveRandom(upgrade_complete_confirmation))
													if i == 3 then
														if random(1,100) < (50 - (difficulty * 10)) then
															local impact_system = {}
															for i,system in ipairs(system_list) do
																if comms_source:hasSystem(system) then
																	table.insert(impact_system,system)
																end
															end
															local selected_system = tableRemoveRandom(impact_system)
															local cool_power_heat = math.random(1,3)
															if cool_power_heat == 1 then
																if comms_source.coolant_rate == nil then
																	comms_source.coolant_rate = {}
																	for i,system in ipairs(system_list) do
																		comms_source.coolant_rate[system] = comms_source:getSystemCoolantRate(system)
																	end
																end
																comms_source:setSystemCoolantRate(selected_system,comms_source:getSystemCoolantRate(selected_system) - .2)
															elseif cool_power_heat == 2 then
																if comms_source.power_rate == nil then
																	comms_source.power_rate = {}
																	for i,system in ipairs(system_list) do
																		comms_source.power_rate[system] = comms_source:getSystemPowerRate(system)
																	end
																end
																comms_source:setSystemPowerRate(selected_system,comms_source:getSystemPowerRate(selected_system) - .1)
															else	--heat
																if comms_source.heat_rate == nil then
																	comms_source.heat_rate = {}
																	for i,system in ipairs(system_list) do
																		comms_source.heat_rate[system] = comms_source:getSystemHeatRate(system)
																	end
																end
																comms_source:setSystemHeatRate(selected_system,comms_source:getSystemHeatRate(selected_system) + .02)
															end
														end
													elseif i == 4 then
														downgradePlayerShip(comms_source,tandem_modified_system.sys)
														local upgrade_complete_confirmation = {
															_("upgrade-comms","Upgrade complete"),
															_("upgrade-comms","Upgraded"),
															string.format(_("upgrade-comms","%s has completed your upgrade"),comms_target:getCallSign()),
															string.format(_("upgrade-comms","%s has been upgraded"),comms_source:getCallSign()),
														}
														local upgrade_prefix = tableRemoveRandom(upgrade_complete_confirmation)
														setCommsMessage(string.format(_("upgrade-comms","%s. The upgrade has %s on your %s system."),upgrade_prefix,tandem_modified_system.desc,tandem_modified_system.sys))
													elseif i == 5 then
														local upgrade_consequence = ""
														if random(1,100) < (50 - (difficulty * 10)) and random_system ~= nil then
															downgradePlayerShip(comms_source,random_system.sys)
															upgrade_consequence = string.format(_("upgrade-comms"," The upgrade has %s on your %s system."),random_system.desc,random_system.sys)
														end
														local upgrade_complete_confirmation = {
															_("upgrade-comms","Upgrade complete"),
															_("upgrade-comms","Upgraded"),
															string.format(_("upgrade-comms","%s has completed your upgrade"),comms_target:getCallSign()),
															string.format(_("upgrade-comms","%s has been upgraded"),comms_source:getCallSign()),
														}
														local upgrade_prefix = tableRemoveRandom(upgrade_complete_confirmation)
														setCommsMessage(string.format(_("upgrade-comms","%s.%s"),upgrade_prefix,upgrade_consequence))
													end
												else
													local insufficient_rep_responses = {
														_("needRep-comms","Insufficient reputation"),
														_("needRep-comms","Not enough reputation"),
														_("needRep-comms","You need more reputation"),
														string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
														_("needRep-comms","You don't have enough reputation"),
														string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
													}
													setCommsMessage(tableRemoveRandom(insufficient_rep_responses))
												end
												addCommsReply(_("Back"), commsStation)
											end)
										end
									end
								end
								addCommsReply(_("Back"), commsStation)
							end)
						end
					end
					--	print("outer upgrade count:",outer_upgrade_count,"inner upgrade count:",inner_upgrade_count)
					if inner_upgrade_count > 0 then
						local what_upgrade = {
							_("upgrade-comms","What kind of upgrade are you interested in? We can provide the following upgrades\nsystem: description"),
							_("upgrade-comms","Which of these upgrades are you interested in?\nsystem: description"),
							_("upgrade-comms","Are you interested in any of these upgrades?\nsystem: description"),
							_("upgrade-comms","These are the upgrades available here. Which of them interest you?\nsystem: description"),
						}
						setCommsMessage(tableRemoveRandom(what_upgrade))
					else
						local no_applicable_upgrade = {
							_("upgrade-comms","Alas, we cannot upgrade any of your systems"),
							_("upgrade-comms","Sorry, we can't upgrade any of your systems"),
							_("upgrade-comms","We are unable to upgrade any of your systems"),
							_("upgrade-comms","We don't have any upgrades available for your systems"),
						}
						setCommsMessage(tableRemoveRandom(no_applicable_upgrade))
					end
				end
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end
end
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
function downgradePlayerShip(p,u_type)
	local tempTypeName = p:getTypeName()
	local current_level = p.upgrade_path[u_type]
	if u_type == "beam" then
		for i=0,15 do
			p:setBeamWeapon(i,0,0,0,0,0)
			p:setBeamWeaponTurret(i,0,0,0)
		end
		for i,b in ipairs(upgrade_path[tempTypeName].beam[current_level-1]) do
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
			p:setWeaponTubeExclusiveFor(i-1,"HVLI")
			p:weaponTubeDisallowMissle(i-1,"HVLI")
		end
		local tube_level = upgrade_path[tempTypeName].missiles[current_level-1].tube
		local ordnance_level = upgrade_path[tempTypeName].missiles[current_level-1].ord
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
		if #upgrade_path[tempTypeName].shield[current_level-1] > 1 then
			p:setShieldsMax(upgrade_path[tempTypeName].shield[current_level-1][1].max,upgrade_path[tempTypeName].shield[current_level-1][2].max)
			p:setShields(upgrade_path[tempTypeName].shield[current_level-1][1].max,upgrade_path[tempTypeName].shield[current_level-1][2].max)
		else
			p:setShieldsMax(upgrade_path[tempTypeName].shield[current_level-1][1].max)
			p:setShields(upgrade_path[tempTypeName].shield[current_level-1][1].max)
		end
	elseif u_type == "hull" then
		p:setHullMax(upgrade_path[tempTypeName].hull[current_level-1].max)
		p:setHull(upgrade_path[tempTypeName].hull[current_level-1].max)
	elseif u_type == "impulse" then
		p:setImpulseMaxSpeed(upgrade_path[tempTypeName].impulse[current_level-1].max_front,upgrade_path[tempTypeName].impulse[current_level-1].max_back)
		p:setAcceleration(upgrade_path[tempTypeName].impulse[current_level-1].accel_front,upgrade_path[tempTypeName].impulse[current_level-1].accel_back)
		p:setRotationMaxSpeed(upgrade_path[tempTypeName].impulse[current_level-1].turn)
		if upgrade_path[tempTypeName].impulse[current_level-1].boost > 0 or upgrade_path[tempTypeName].impulse[current_level-1].strafe > 0 then
			p:setCanCombatManeuver(true)
			p:setCombatManeuver(upgrade_path[tempTypeName].impulse[current_level-1].boost,upgrade_path[tempTypeName].impulse[current_level-1].strafe)
			p.combat_maneuver_capable = true
		else
			p:setCanCombatManeuver(false)
			p.combat_maneuver_capable = false
		end
	elseif u_type == "ftl" then
		if upgrade_path[tempTypeName].ftl[current_level-1].jump_long > 0 then
			p:setJumpDrive(true)
			p.max_jump_range = upgrade_path[tempTypeName].ftl[current_level-1].jump_long
			p.min_jump_range = upgrade_path[tempTypeName].ftl[current_level-1].jump_short
			p:setJumpDriveRange(p.min_jump_range,p.max_jump_range)
			p:setJumpDriveCharge(p.max_jump_range)
		else
			p:setJumpDrive(false)
		end
		if upgrade_path[tempTypeName].ftl[current_level-1].warp > 0 then
			p:setWarpDrive(true)
			p:setWarpSpeed(upgrade_path[tempTypeName].ftl[current_level-1].warp)
		else
			p:setWarpDrive(false)
		end
	elseif u_type == "sensors" then		
		p:setLongRangeRadarRange(upgrade_path[tempTypeName].sensors[current_level-1].long)
		p.normal_long_range_radar = upgrade_path[tempTypeName].sensors[current_level-1].long
		p:setShortRangeRadarRange(upgrade_path[tempTypeName].sensors[current_level-1].short)
		p.prox_scan = upgrade_path[tempTypeName].sensors[current_level-1].prox_scan
	end
	p.upgrade_path[u_type] = current_level-1
	p.shipScore = p.shipScore - 1
end
--	Booleans to set outside of this utility to control this utility. Default is false
--		hull_banner - set true if stations offer an engineering upgrade to show hull points
--		shield_banner - set true if stations offer an engineering upgrade to show shield points
--		way_dist - set true if stations offer a helm upgrade to calculate
--			distances between waypoints
--		proximity_scanner - set true if stations offer an upgrade to automatically
--			single scan ships within a certain range
--		max_health_widgets - set true if stations offer widgets on engineering to
--			continuously track the maximum health of their primary systems
--		powered_sensor_boost - set true if stations offer engineering the ability to put
--			additional power into the sensors to increase their range
function minorUpgrades()
	local minor_upgrades = {}
	--	set minor upgrade booleans on station if not already set
	if shield_banner then
		if comms_target.shield_banner == nil then
			if random(1,100) < 55 then
				comms_target.shield_banner = true
			else
				comms_target.shield_banner = false
			end
		end
	else
		comms_target.shield_banner = false
	end
	if hull_banner then
		if comms_target.hull_banner == nil then
			if random(1,100) < 50 then
				comms_target.hull_banner = true
			else
				comms_target.hull_banner = false
			end
		end
	else
		comms_target.hull_banner = false
	end
	if way_dist then
		if comms_target.way_dist == nil then
			if random(1,100) < 50 then
				comms_target.way_dist = true
			else
				comms_target.way_dist = false
			end
		end
	else
		comms_target.way_dist = false
	end
	if proximity_scanner then
		if comms_target.proximity_scanner == nil then
			if random(1,100) < 55 then
				comms_target.proximity_scanner = true
			else
				comms_target.proximity_scanner = false
			end
		end
	else
		comms_target.proximity_scanner = false
	end
	if max_health_widgets then
		if comms_target.max_health_widgets == nil then
			if random(1,100) < 50 then
				comms_target.max_health_widgets = true
			else
				comms_target.max_health_widgets = false
			end
		end
	else
		comms_target.max_health_widgets = false
	end
	if powered_sensor_boost then
		if comms_target.powered_sensor_boost == nil then
			if random(1,100) < 32 then
				comms_target.powered_sensor_boost = true
				comms_target.installable_sensor_boost_ranges = {}
				local sensor_boost_ranges_pool = {}
				for i=5,9,.5 do
					table.insert(sensor_boost_ranges_pool,{interval = i,cost=math.random(3,6)*2*i})
				end
				for i=1,3 do
					table.insert(comms_target.installable_sensor_boost_ranges,tableRemoveRandom(sensor_boost_ranges_pool))
				end
			else
				comms_target.powered_sensor_boost = false
			end
		end
	else
		comms_target.powered_sensor_boost = false
	end
	-- build minor upgrades list
	if comms_target.shield_banner then
		if comms_target:isFriendly(comms_source) then
			if comms_target.comms_data.friendlyness > 20 then
				table.insert(minor_upgrades,"shield_banner")
			end
		elseif not comms_target:isEnemy(comms_source) then
			if comms_target.comms_data.friendlyness > 50 then
				table.insert(minor_upgrades,"shield_banner")
			end
		end
	else
		if comms_source.shield_banner then
			table.insert(minor_upgrades,"remove_shield_banner")
		end
	end
	if comms_target.hull_banner then
		if comms_target:isFriendly(comms_source) then
			if comms_target.comms_data.friendlyness > 30 then
				table.insert(minor_upgrades,"hull_banner")
			end
		elseif not comms_target:isEnemy(comms_source) then
			if comms_target.comms_data.friendlyness > 60 then
				table.insert(minor_upgrades,"hull_banner")
			end
		end
	else
		if comms_source.hull_banner then
			table.insert(minor_upgrades,"remove_hull_banner")
		end
	end
	if comms_target.way_dist then
		if comms_target:isFriendly(comms_source) then
			if comms_target.comms_data.friendlyness > 10 then
				table.insert(minor_upgrades,"way_dist")
			end
		elseif not comms_target:isEnemy(comms_source) then
			if comms_target.comms_data.friendlyness > 20 then
				table.insert(minor_upgrades,"way_dist")
			end
		end
	else
		if comms_source.way_dist then
			table.insert(minor_upgrades,"remove_way_dist")
		end
	end
	if comms_target.proximity_scanner then
		if comms_target:isFriendly(comms_source) then
			if comms_target.comms_data.friendlyness > 50 then
				table.insert(minor_upgrades,"prox_scan")
			end
		elseif not comms_target:isEnemy(comms_source) then
			if comms_target.comms_data.friendlyness > 15 then
				table.insert(minor_upgrades,"prox_scan")
			end
		end
	end
	if comms_target.max_health_widgets then
		if comms_target:isFriendly(comms_source) then
			if comms_target.comms_data.friendlyness > 25 then
				table.insert(minor_upgrades,"max_health_widgets")
			end
		elseif not comms_target:isEnemy(comms_source) then
			if comms_target.comms_data.friendlyness > 45 then
				table.insert(minor_upgrades,"max_health_widgets")
			end
		end
	else
		if comms_source.max_health_widgets then
			table.insert(minor_upgrades,"remove_max_health_widgets")
		end
	end
	if comms_target.powered_sensor_boost then
		if comms_target.installable_sensor_boost_ranges ~= nil and #comms_target.installable_sensor_boost_ranges > 0 then
			if comms_target:isFriendly(comms_source) then
				if comms_target.comms_data.friendlyness > 30 then
					table.insert(minor_upgrades,"powered_sensor_boost")
				end
			elseif not comms_target:isEnemy(comms_source) then
				if comms_target.comms_data.friendlyness > 40 then
					table.insert(minor_upgrades,"powered_sensor_boost")
				end
			end
		end
	end
	if #minor_upgrades > 0 then
		local minor_upgrade_prompt = {
			_("upgrade-comms","Minor upgrade"),
			_("upgrade-comms","Get a minor upgrade"),
			string.format(_("upgrade-comms","Minor upgrade for %s"),comms_source:getCallSign()),
			string.format(_("upgrade-comms","Check minor upgrades on %s"),comms_target:getCallSign()),
		}
		addCommsReply(tableSelectRandom(minor_upgrade_prompt),function()
			string.format("")
			local minor_upgrades_available = {
				_("upgrade-comms","Which of these are you interested in?"),
				_("upgrade-comms","What minor upgrades might you be interested in?"),
				_("upgrade-comms","Do any of these minor upgrades interest you?"),
				string.format(_("upgrade-comms","Here are some minor upgrades available here on %s. Let me know if any of these seem interesting."),comms_target:getCallSign()),
			}
			setCommsMessage(tableSelectRandom(minor_upgrades_available))
			for i,minor_upgrade in ipairs(minor_upgrades) do
				if minor_upgrade == "shield_banner" then
					local shield_diagnostic_prompts = {
						_("upgrade-comms","Spare portable shield diagnostic"),
						_("upgrade-comms","Detachable shield diagnostic"),
						_("upgrade-comms","Off the shelf shield diagnostic"),
						_("upgrade-comms","After market shield diagnostic"),
					}
					addCommsReply(tableSelectRandom(shield_diagnostic_prompts),function()
						local shield_diagnostic_explained = {
							_("upgrade-comms","We've got a spare portable shield diagnostic if you're interested. Engineers use these to get raw data on shield status. Why? well, sometimes they prefer the raw numbers over the normal percentages that appear. Would you like to get this for your engineer?"),
							_("upgrade-comms","We have a shield diagnostic unit without a home. Engineers that prefer raw numbers over the standard percentage values like this tool. Would you like to get this for your engineer?"),
							string.format(_("upgrade-comms","There's a shield diagnostic unit here that could be installed on %s. Some engineers like the raw numbers it provides better than the standard percentage values. Do you want it installed for your engineer?"),comms_source:getCallSign()),
							_("upgrade-comms","We've got a shield diagnostic unit without a designated ship installation slot. What does it do? Well, it provides a readout in raw numbers for the state of the shields rather than the typical percentage value. Some engineers prefer the raw numbers. Do you think your engineer might want this tool?"),
						}
						setCommsMessage(tableSelectRandom(shield_diagnostic_explained))
						local install_shield_diagnostic_confirmation_prompt = {
							_("upgrade-comms","Yes, that's a perfect gift (5 reputation)"),
							_("upgrade-comms","Yes! Our engineer would love that (5 reputation)"),
							_("upgrade-comms","We'll take it (5 reputation)"),
							_("upgrade-comms","Please install it (5 reputation)"),
						}
						addCommsReply(tableSelectRandom(install_shield_diagnostic_confirmation_prompt),function()
							if comms_source:takeReputationPoints(5) then
								comms_source.shield_banner = true
								comms_target.shield_banner = false
								local shield_diagnostic_installed_confirmation = {
									_("upgrade-comms","Installed"),
									string.format(_("upgrade-comms","%s has installed the shield diagnostic unit"),comms_target:getCallSign()),
									_("upgrade-comms","It's installed"),
									string.format(_("upgrade-comms","%s now has a shield diagnostic unit"),comms_source:getCallSign()),
								}
								setCommsMessage(tableSelectRandom(shield_diagnostic_installed_confirmation))
							else
								local insufficient_rep_responses = {
									_("needRep-comms","Insufficient reputation"),
									_("needRep-comms","Not enough reputation"),
									_("needRep-comms","You need more reputation"),
									string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
									_("needRep-comms","You don't have enough reputation"),
									string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
								}
								setCommsMessage(tableSelectRandom(insufficient_rep_responses))
							end
							addCommsReply(_("Back"), commsStation)
						end)
					end)
				end
				if minor_upgrade == "remove_shield_banner" then
					local remove_shield_diagnostic_prompt = {
						_("upgrade-comms","Give portable shield diagnostic to repair technicians"),
						string.format(_("upgrade-comms","Donate shield diagnostic unit to %s"),comms_target:getCallSign()),
						_("upgrade-comms","Remove shield diagnostic unit. Give it to station"),
						string.format(_("upgrade-comms","Transfer shield diagnostic unit from %s to station %s"),comms_source:getCallSign(),comms_target:getCallSign()),
					}
					addCommsReply(tableSelectRandom(remove_shield_diagnostic_prompt),function()
						local shield_diagnostic_donation_confirmed = {
							string.format(_("upgrade-comms","%s thanks you and says they will put it to good use."),comms_target:getCallSign()),
							string.format(_("upgrade-comms","Shield diagnostic unit uninstalled from %s. The technicians at %s say, 'Thanks %s. There are a number of other ships that have been asking for this.'"),comms_source:getCallSign(),comms_target:getCallSign(),comms_source:getCallSign()),
							string.format(_("upgrade-comms","%s thanks you for the donation of the shield diagnostic unit"),comms_target:getCallSign()),
							string.format(_("upgrade-comms","The shield diagnostic unit has been transferred from your ship to the parts inventory on station %s. They express their gratitude for your donation."),comms_target:getCallSign()),
						}
						setCommsMessage(tableSelectRandom(shield_diagnostic_donation_confirmed))
						comms_source.shield_banner = false
						comms_target.shield_banner = true
						comms_target.comms_data.friendlyness = math.min(100,comms_target.comms_data.friendlyness + random(3,9))
						addCommsReply(_("Back"), commsStation)
					end)
				end
				if minor_upgrade == "hull_banner" then
					local hull_diagnostic_prompts = {
						_("upgrade-comms","Spare portable hull diagnostic"),
						_("upgrade-comms","Detachable hull diagnostic"),
						_("upgrade-comms","Off the shelf hull diagnostic"),
						_("upgrade-comms","After market hull diagnostic"),
					}
					addCommsReply(tableSelectRandom(hull_diagnostic_prompts),function()
						local hull_diagnostic_explained = {
							_("upgrade-comms","We've got a spare portable hull diagnostic if you're interested. Engineers use these to get raw data on hull status. Why? well, sometimes they prefer the raw numbers over the normal percentages that appear. Would you like to get this for your engineer?"),
							_("upgrade-comms","We have a hull diagnostic unit without a home. Engineers that prefer raw hull status numbers over the standard percentage values like this tool. Would you like to get this for your engineer?"),
							string.format(_("upgrade-comms","There's a hull diagnostic unit here that could be installed on %s. Some engineers like the raw numbers it provides better than the standard percentage values. Do you want it installed for your engineer?"),comms_source:getCallSign()),
							_("upgrade-comms","We've got a hull diagnostic unit without a designated ship installation slot. What does it do? Well, it provides a readout in raw numbers for the state of the hull rather than the typical percentage value. Some engineers prefer the raw numbers. Do you think your engineer might want this tool?"),
						}
						setCommsMessage(tableSelectRandom(hull_diagnostic_explained))
							local install_hull_diagnostic_confirmation_prompt = {
								_("upgrade-comms","Yes, that's a perfect gift (5 reputation)"),
								_("upgrade-comms","Yes! Our engineer would love that (5 reputation)"),
								_("upgrade-comms","We'll take it (5 reputation)"),
								_("upgrade-comms","Please install it (5 reputation)"),
							}
							addCommsReply(tableSelectRandom(install_hull_diagnostic_confirmation_prompt),function()
							if comms_source:takeReputationPoints(5) then
								comms_source.hull_banner = true
								comms_target.hull_banner = false
								local hull_diagnostic_installed_confirmation = {
									_("upgrade-comms","Installed"),
									string.format(_("upgrade-comms","%s has installed the hull diagnostic unit"),comms_target:getCallSign()),
									_("upgrade-comms","It's installed"),
									string.format(_("upgrade-comms","%s now has a hull diagnostic unit"),comms_source:getCallSign()),
								}
								setCommsMessage(tableSelectRandom(hull_diagnostic_installed_confirmation))
							else
								local insufficient_rep_responses = {
									_("needRep-comms","Insufficient reputation"),
									_("needRep-comms","Not enough reputation"),
									_("needRep-comms","You need more reputation"),
									string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
									_("needRep-comms","You don't have enough reputation"),
									string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
								}
								setCommsMessage(tableSelectRandom(insufficient_rep_responses))
							end
							addCommsReply(_("Back"), commsStation)
						end)
					end)
				end
				if minor_upgrade == "remove_hull_banner" then
					local remove_hull_diagnostic_prompt = {
						_("upgrade-comms","Give portable hull diagnostic to repair technicians"),
						string.format(_("upgrade-comms","Donate hull diagnostic unit to %s"),comms_target:getCallSign()),
						_("upgrade-comms","Remove hull diagnostic unit. Give it to station"),
						string.format(_("upgrade-comms","Transfer hull diagnostic unit from %s to station %s"),comms_source:getCallSign(),comms_target:getCallSign()),
					}
					addCommsReply(tableSelectRandom(remove_hull_diagnostic_prompt),function()
						local hull_diagnostic_donation_confirmed = {
							string.format(_("upgrade-comms","%s thanks you and says they will put it to good use."),comms_target:getCallSign()),
							string.format(_("upgrade-comms","Hull diagnostic unit uninstalled from %s. The technicians at %s say, 'Thanks %s. There are a number of other ships that have been asking for this.'"),comms_source:getCallSign(),comms_target:getCallSign(),comms_source:getCallSign()),
							string.format(_("upgrade-comms","%s thanks you for the donation of the hull diagnostic unit"),comms_target:getCallSign()),
							string.format(_("upgrade-comms","The hull diagnostic unit has been transferred from your ship to the parts inventory on station %s. They express their gratitude for your donation."),comms_target:getCallSign()),
						}
						setCommsMessage(tableSelectRandom(hull_diagnostic_donation_confirmed))
						comms_source.hull_banner = false
						comms_target.hull_banner = true
						comms_target.comms_data.friendlyness = math.min(100,comms_target.comms_data.friendlyness + random(3,9))
						addCommsReply(_("Back"), commsStation)
					end)
				end
				if minor_upgrade == "way_dist" then
					local waypoint_distance_calc_prompts = {
						_("upgrade-comms","Spare waypoint distance calculator"),
						_("upgrade-comms","Detachable waypoint distance calculator"),
						_("upgrade-comms","Off the shelf waypoint distance calculator"),
						_("upgrade-comms","After market waypoint distance calculator"),
					}
					addCommsReply(tableSelectRandom(waypoint_distance_calc_prompts),function()
						local waypoint_distance_calc_explained = {
							_("upgrade-comms","We've got a spare portable waypoint distance calculator if you're interested. Helm or Tactical officers use this to get hyper accurate distance calculations for waypoints placed by Relay or Operations. Would you like to get this for helm/tactical?"),
							_("upgrade-comms","We have an unused waypoint distance calculator. Your helm or tactical officer could use this to get hyper-accurate distance calculations for any waypoints placed by your relay or operations officer. Would you like this installed for helm/tactical?"),
							_("upgrade-comms","There's a waypoint distance calculator here that could use a home. It's a device used by helm or tactical to calculat hyper accurate distances for waypoints. Interested?"),
							string.format(_("upgrade-comms","We have a waypoint distance calculator begging to be installed on %s. Helm or Tactical use it for extremely accurate distance calculations on waypoints placed by Relay or Operations. Would this be useful for you?"),comms_source:getCallSign()),
						}
						setCommsMessage(tableSelectRandom(waypoint_distance_calc_explained))
						local install_waypoint_distance_calc_confirmation_prompt = {
							_("upgrade-comms","Yes, that's a perfect gift (5 reputation)"),
							_("upgrade-comms","We'll take it (5 reputation)"),
							_("upgrade-comms","Please install it (5 reputation)"),
						}
						if comms_source:hasPlayerAtPosition("Helms") then
							if comms_source:hasPlayerAtPosition("Tactical") then
								table.insert(install_waypoint_distance_calc_confirmation_prompt,_("upgrade-comms","Yes! Helm/Tactical would love that (5 reputation)"))
							else
								table.insert(install_waypoint_distance_calc_confirmation_prompt,_("upgrade-comms","Yes! Helm would love that (5 reputation)"))
							end
						elseif comms_source:hasPlayerAtPosition("Tactical") then
							table.insert(install_waypoint_distance_calc_confirmation_prompt,_("upgrade-comms","Yes! Tactical would love that (5 reputation)"))
						end
						addCommsReply(tableSelectRandom(install_waypoint_distance_calc_confirmation_prompt),function()
							if comms_source:takeReputationPoints(5) then
								comms_source.way_dist = true
								comms_target.way_dist = false
								local waypoint_distance_calc_installed_confirmation = {
									_("upgrade-comms","Installed"),
									string.format(_("upgrade-comms","%s has installed the waypoint distance calculator"),comms_target:getCallSign()),
									_("upgrade-comms","It's installed"),
									string.format(_("upgrade-comms","%s now has a waypoint distance calculator"),comms_source:getCallSign()),
								}
								setCommsMessage(tableSelectRandom(waypoint_distance_calc_installed_confirmation))
							else
								local insufficient_rep_responses = {
									_("needRep-comms","Insufficient reputation"),
									_("needRep-comms","Not enough reputation"),
									_("needRep-comms","You need more reputation"),
									string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
									_("needRep-comms","You don't have enough reputation"),
									string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
								}
								setCommsMessage(tableSelectRandom(insufficient_rep_responses))
							end
							addCommsReply(_("Back"), commsStation)
						end)
					end)
				end
				if minor_upgrade == "remove_way_dist" then
					local remove_waypoint_dist_calc_prompt = {
						_("upgrade-comms","Give waypoint distance calculator to repair technicians"),
						string.format(_("upgrade-comms","Donate waypoint distance calculator to %s"),comms_target:getCallSign()),
						_("upgrade-comms","Remove waypoint distance calculator. Give it to station"),
						string.format(_("upgrade-comms","Transfer waypoint distance calculator from %s to station %s"),comms_source:getCallSign(),comms_target:getCallSign()),
					}
					addCommsReply(tableSelectRandom(remove_waypoint_dist_calc_prompt),function()
						local waypoint_distance_calculator_explained = {
							_("upgrade-comms","Not every ship in the fleet has a portable waypoint distance calculator. If you were to give us yours, we could install it on another ship if they wanted it. Would you like to give us your waypoint distance calculator?"),
							_("upgrade-comms","If you were to donate your waypoint distance calculator, we could install it on another ship in the fleet. Not every ship has one, you know. Do you want to give us yours?"),
							_("upgrade-comms","The waypoint distance calculator is not standard equipment on every ship in the fleet. Giving us yours allows us to install it on another ship. Would you like to donate yours? It's for a worthy cause."),
							_("upgrade-comms","Consider that not every ship has a waypoint distance calculator. We could give another ship in the fleet one if you were to give us yours. What about it?"),
						}
						setCommsMessage(tableSelectRandom(waypoint_distance_calculator_explained))
						local confirm_waypoint_dist_donation_prompt = {
							_("upgrade-comms","Yes, we like to help the fleet (add 5 rep)"),
							_("upgrade-comms","Yes, we'll donate ours (add 5 rep)"),
							_("upgrade-comms","Ok, we will give you ours (add 5 rep)"),
							_("upgrade-comms","We'll help the fleet and give you ours (add 5 rep)"),
						}
						addCommsReply(tableSelectRandom(confirm_waypoint_dist_donation_prompt),function()
							comms_source:addReputationPoints(5)
							comms_source.way_dist = false
							comms_target.way_dist = true
							comms_target.comms_data.friendlyness = math.min(100,comms_target.comms_data.friendlyness + random(3,9))
							if comms_source.way_distance_button_hlm ~= nil then
								comms_source:removeCustom(comms_source.way_distance_button_hlm)
								comms_source:removeCustom(comms_source.way_distance_button_tac)
								comms_source.way_distance_button_hlm = nil
								comms_source.way_distance_button_tac = nil
							end
							local confirm_uninstalled_waypoint_dist_calc = {
								_("upgrade-comms","Thanks. I'll be sure to give this to the next fleet member that asks."),
								_("upgrade-comms","You have done the fleet an appreciated service. We'll be sure the waypoint distance calculator gets put to good use."),
								string.format(_("upgrade-comms","The %s will go down in our records as a generous ship. We'll make sure another fleet member gets good use from your waypoint distance calculator"),comms_source:getCallSign()),
								_("upgrade-comms","Your contribution is greatly appreciated. This waypoint distance calculator will make some helm officer very happy"),
							}
							setCommsMessage(tableSelectRandom(confirm_uninstalled_waypoint_dist_calc))
							addCommsReply(_("Back"), commsStation)
						end)
						addCommsReply(_("Back"), commsStation)
					end)
				end
				if minor_upgrade == "prox_scan" then
					local prox_scan_prompts = {
						_("upgrade-comms","Spare portable automatic proximity scanner"),
						_("upgrade-comms","Detachable automatic proximity scanner"),
						_("upgrade-comms","Off the shelf automatic proximity scanner"),
						_("upgrade-comms","After market automatic proximity scanner"),
					}
					addCommsReply(tableSelectRandom(prox_scan_prompts),function()
						if comms_target.proximity_scanner_range == nil then
							comms_target.proximity_scanner_range = math.random(1,5)
						end
						local install_cost = 20 * comms_target.proximity_scanner_range
						local explain_prox_scan_response = {
							string.format(_("upgrade-comms","We've got this portable automatic proximity scanner here. They are very popular. It automatically performs a simple scan on ships in range (%sU). Would you like to have this installed?"),comms_target.proximity_scanner_range),
							string.format(_("upgrade-comms","We have an automatic proximity scanner that we are not using. These things are pretty popular right now. When a ship gets in range (%sU), it automatically and instantly performs a simple scan on the ship. Would you like for us to install it on %s?"),comms_target.proximity_scanner_range,comms_source:getCallSign()),
							string.format(_("upgrade-comms","Available for a limited time, we have the ever popular automatic proximity scanner. Install this baby and ships are instantly and automatically simple scanned when they get in range (%sU). Do you want it installed?"),comms_target.proximity_scanner_range),
							string.format(_("upgrade-comms","The %s quartermaster tells me that there's a spare automatic proximity scanner without a ship designated for installation. These automated proximity scanners are very popular. They instantly and automatically scan ships that are in range (%sU). Would you like it installed on %s?"),comms_target:getCallSign(),comms_target.proximity_scanner_range,comms_source:getCallSign()),
						}
						setCommsMessage(tableSelectRandom(explain_prox_scan_response))
						local prox_scan_install_prompt = {
							string.format(_("upgrade-comms","We'll take it (%i reputation)"),install_cost),
							string.format(_("upgrade-comms","Install it, please (%i reputation)"),install_cost),
							string.format(_("upgrade-comms","It's perfect! Install it (%i reputation)"),install_cost),
							string.format(_("upgrade-comms","We could use that. Please install it (%i reputation)"),install_cost),
						}
						addCommsReply(tableSelectRandom(prox_scan_install_prompt),function()
							if comms_source:takeReputationPoints(install_cost) then
								local temp_prox_scan = comms_source.prox_scan
								comms_source.prox_scan = comms_target.proximity_scanner_range
								if temp_prox_scan ~= nil and temp_prox_scan > 0 then
									comms_target.proximity_scanner_range = temp_prox_scan
								else
									comms_target.proximity_scanner = false
									comms_target.proximity_scanner_range = nil
								end
								local prox_scan_install_confirm_response = {
									_("upgrade-comms","Installed"),
									string.format(_("upgrade-comms","%s has installed the automatic proximity scanner"),comms_target:getCallSign()),
									_("upgrade-comms","It's installed"),
									string.format(_("upgrade-comms","%s now has an automatic proximity scanner"),comms_source:getCallSign()),
								}
								setCommsMessage(tableSelectRandom(prox_scan_install_confirm_response))
							else
								local insufficient_rep_responses = {
									_("needRep-comms","Insufficient reputation"),
									_("needRep-comms","Not enough reputation"),
									_("needRep-comms","You need more reputation"),
									string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
									_("needRep-comms","You don't have enough reputation"),
									string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
								}
								setCommsMessage(tableSelectRandom(insufficient_rep_responses))
							end
							addCommsReply(_("Back"), commsStation)
						end)
					end)
				end
				if minor_upgrade == "max_health_widgets" then
					local max_health_widgets_prompt = {
						_("upgrade-comms","Spare portable max health diagnostic"),
						_("upgrade-comms","Detachable max health diagnostic"),
						_("upgrade-comms","Off the shelf max health diagnostic"),
						_("upgrade-comms","After market max health diagnostic"),
					}
					addCommsReply(tableSelectRandom(max_health_widgets_prompt),function()
						local explain_max_health_widgets = {
							_("upgrade-comms","There's a portable max health diagnostic here that we are not using. Engineers use these to keep close watch on severely damaged systems. Would you like to get this for your engineer?"),
							_("upgrade-comms","We've got a max health diagnostic unit here that we are not using. Engineers use these things to keep a close eye on systems that have been severely damaged. Do you think your engineer might want this?"),
							_("upgrade-comms","We've got an unused max health diagnostic. It's used by engineers to monitor severely damaged systems. Do you want to get this for your engineer?"),
							_("upgrade-comms","We have a spare max health diagnostic unit. Your engineer can use it to monitor severely damaged systems. Interested?"),
						}
						setCommsMessage(tableSelectRandom(explain_max_health_widgets))
						local install_max_health_widgets_prompt = {
							_("upgrade-comms","Yes, that's a great gift (5 reputation)"),
							_("upgrade-comms","Yes! Our engineer would love that (5 reputation)"),
							_("upgrade-comms","We'll take it (5 reputation)"),
							_("upgrade-comms","Please install it (5 reputation)"),
						}
						addCommsReply(tableSelectRandom(install_max_health_widgets_prompt),function()
							if comms_source:takeReputationPoints(5) then
								comms_source.max_health_widgets = true
								comms_target.max_health_widgets = false
								local install_max_health_widgets_confirm = {
									_("upgrade-comms","Installed"),
									string.format(_("upgrade-comms","%s has installed the max health diagnostic unit"),comms_target:getCallSign()),
									_("upgrade-comms","It's installed"),
									string.format(_("upgrade-comms","%s now has a max health diagnostic unit"),comms_source:getCallSign()),
								}
								setCommsMessage(tableSelectRandom(install_max_health_widgets_confirm))
							else
								local insufficient_rep_responses = {
									_("needRep-comms","Insufficient reputation"),
									_("needRep-comms","Not enough reputation"),
									_("needRep-comms","You need more reputation"),
									string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
									_("needRep-comms","You don't have enough reputation"),
									string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
								}
								setCommsMessage(tableSelectRandom(insufficient_rep_responses))
							end
						end)
					end)
				end
				if minor_upgrade == "remove_max_health_widgets" then
					local remove_max_health_widgets_prompt = {
						_("upgrade-comms","Give portable max health diagnostic to repair technicians"),
						string.format(_("upgrade-comms","Donate max health diagnostic unit to %s"),comms_target:getCallSign()),
						_("upgrade-comms","Remove max health diagnostic unit. Give it to station"),
						string.format(_("upgrade-comms","Transfer max health diagnostic unit from %s to station %s"),comms_source:getCallSign(),comms_target:getCallSign()),
					}
					addCommsReply(tableSelectRandom(remove_max_health_widgets_prompt),function()
						comms_source.max_health_widgets = false
						comms_target.max_health_widgets = true
						comms_target.comms_data.friendlyness = math.min(100,comms_target.comms_data.friendlyness + random(3,9))
						local remove_max_health_widgets_confirm = {
							string.format(_("upgrade-comms","%s thanks you and says they will put it to good use."),comms_target:getCallSign()),
							string.format(_("upgrade-comms","Max health diagnostic unit uninstalled from %s. The technicians at %s say, 'Thanks %s. There are a number of other ships that have been asking for this.'"),comms_source:getCallSign(),comms_target:getCallSign(),comms_source:getCallSign()),
							string.format(_("upgrade-comms","%s thanks you for the donation of the max health diagnostic unit"),comms_target:getCallSign()),
							string.format(_("upgrade-comms","The max health diagnostic unit has been transferred from your ship to the parts inventory on station %s. They express their gratitude for your donation."),comms_target:getCallSign()),
						}
						setCommsMessage(tableSelectRandom(remove_max_health_widgets_confirm))
						addCommsReply(_("Back"), commsStation)
					end)
				end
				if minor_upgrade == "powered_sensor_boost" then
					local powered_sensor_boost_prompt = {
						_("upgrade-comms","Sensor power boost"),
						_("upgrade-comms","Funnel power to sensors"),
						_("upgrade-comms","Power boost to sensors"),
						_("upgrade-comms","Use energy to increase sensor range"),
					}
					addCommsReply(tableSelectRandom(powered_sensor_boost_prompt),function()
						local powered_sensor_boost_explain = {
							_("upgrade-comms","We've got a device that can draw power from your batteries into the sensors in order to increase sensor range. It's a way for Science and Engineering to work together to temporarily give Science better situational awareness. The device draws a significant amount of power when it's enabled, but it can be enabled and disabled according to the situation. The device has three boost levels to add to current sensor range: level 1 = interval, level 2 = interval X 2, level 3 = interval X 3. The higher the level the more power used. Would you like this device installed?"),
							_("upgrade-comms","There is a sensor boosting device here that draws power from the batteries to increase sensor range. Engineering controls whether it is on or off and how strong it is. Science gets a better sensor range while it is enabled. It draws lots of power while enabled, so Engineering should monitor energy use carefully. The device has three boost levels to add to current sensor range: level 1 = interval, level 2 = interval X 2, level 3 = interval X 3. The higher the level the more power used. Interested in installing it?"),
							_("upgrade-comms","We can install a device that uses ship batteries to increase sensor range. Engineering activates the device, sets a level and then Science takes advantage of the increased range. If you install it, be careful since it uses a large amount of power. The device has three boost levels to add to current sensor range: level 1 = interval, level 2 = interval X 2, level 3 = interval X 3. The higher the level the more power used. Interested?"),
							_("upgrade-comms","We've got a sensor range booster available. It siphons a large amount of power out of the batteries into the sensors to increase sensor range. Engineering activates it, sets the level and deactivates it so that Science can take advantage of the longer sensor range. The sensor range booster has three boost levels to add to current sensor range: level 1 = interval, level 2 = interval X 2, level 3 = interval X 3. The higher the level the more power used. Is this something you are interested in having installed?"),
						}
						setCommsMessage(tableSelectRandom(powered_sensor_boost_explain))
						for j,sensor_booster in ipairs(comms_target.installable_sensor_boost_ranges) do
							addCommsReply(string.format(_("upgrade-comms","Range interval:%sU Reputation:%s"),sensor_booster.interval,sensor_booster.cost),function()
								if comms_source:takeReputationPoints(sensor_booster.cost) then
									comms_source.power_sensor_interval = sensor_booster.interval
									comms_target.installable_sensor_boost_ranges[i] = comms_target.installable_sensor_boost_ranges[#comms_target.installable_sensor_boost_ranges]
									comms_target.installable_sensor_boost_ranges[#comms_target.installable_sensor_boost_ranges] = nil
									if #comms_target.installable_sensor_boost_ranges == 0 then
										comms_target.installable_sensor_boost = false
									end
									local install_powered_sendor_boost_confirm = {
										_("upgrade-comms","Installed"),
										string.format(_("upgrade-comms","%s has installed the sensor booster device"),comms_target:getCallSign()),
										_("upgrade-comms","It's installed"),
										string.format(_("upgrade-comms","%s now has a powered sensor booster"),comms_source:getCallSign()),
									}
									setCommsMessage(tableSelectRandom(install_powered_sendor_boost_confirm))
								else
									local insufficient_rep_responses = {
										_("needRep-comms","Insufficient reputation"),
										_("needRep-comms","Not enough reputation"),
										_("needRep-comms","You need more reputation"),
										string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
										_("needRep-comms","You don't have enough reputation"),
										string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
									}
									setCommsMessage(tableSelectRandom(insufficient_rep_responses))
								end
							end)
						end
					end)
				end
			end
		end)
	end
end
--	Functions you may want to set up outside of this utility
--		scenarioGoodsCommerce - Allows the scenario writer to add situational 
--			comms options to goods commerce for the scenario
function goodsCommerce()
	if good_desc == nil then
		initializeGoodDescription()
	end
	local commerce_available = false
	local station_sells = false
	local station_buys = false
	local station_trades = false
	local player_has_goods = false
	local goods_for_sale = ""
	local will_buy_goods = ""
	local trade_goods = ""
	local player_goods = ""
	if comms_target.comms_data.goods ~= nil then
		for good, good_data in pairs(comms_target.comms_data.goods) do
			if good_data.quantity ~= nil and good_data.quantity > 0 then
				station_sells = true
				commerce_available = true
				if goods_for_sale == "" then
					goods_for_sale = good_desc[good]
				else
					goods_for_sale = string.format("%s, %s",goods_for_sale,good_desc[good])
				end
			end
		end
	end
	if comms_target.comms_data.buy ~= nil then
		commerce_available = true
		station_buys = true
		for good, price in pairs(comms_target.comms_data.buy) do
			if will_buy_goods == "" then
				will_buy_goods = good_desc[good]
			else
				will_buy_goods = string.format("%s, %s",will_buy_goods,good_desc[good])
			end
		end
	end
	if comms_target.comms_data.trade ~= nil then
		if station_sells then
			for good,trade_bool in pairs(comms_target.comms_data.trade) do
				if trade_bool then
					station_trades = true
					if trade_goods == "" then
						trade_goods = good_desc[good]
					else
						trade_goods = string.format("%s, %s",trade_goods,good_desc[good])
					end
				end
			end
		end
	end
	if comms_source.goods ~= nil then
		for good, good_quantity in pairs(comms_source.goods) do
			if good_quantity > 0 then
				player_has_goods = true
				commerce_available = true
				if player_goods == "" then
					player_goods = good_desc[good]
				else
					player_goods = string.format("%s, %s",player_goods,good_desc[good])
				end
			end
		end
	end
	if commerce_available then
		local commerce_out = ""
		if station_sells then
			commerce_out = string.format(_("trade-comms","%s sells %s."),comms_target:getCallSign(),goods_for_sale)
			local buy_goods_prompts = {
				_("trade-comms","Buy goods"),
				_("trade-comms","Purchase goods"),
				string.format(_("trade-comms","Buy goods from %s"),comms_target:getCallSign()),
				string.format(_("trade-comms","Purchase goods from %s"),comms_target:getCallSign()),
			}
			addCommsReply(tableRemoveRandom(buy_goods_prompts),buyGoodsFromStation)
		end
		if station_buys then
			if commerce_out == "" then
				commerce_out = string.format(_("trade-comms","%s buys %s."),comms_target:getCallSign(),will_buy_goods)
			else
				commerce_out = string.format(_("trade-comms","%s\n%s buys %s."),commerce_out,comms_target:getCallSign(),will_buy_goods)
			end
			local buy_match = false
			if player_has_goods then
				for buy_good, price in pairs(comms_target.comms_data.buy) do
					for good, good_quantity in pairs(comms_source.goods) do
						if good == buy_good then
							buy_match = true
							break
						end
					end
				end
			end
			if buy_match then
				local sell_goods_prompts = {
					_("trade-comms","Sell goods"),
					_("trade-comms","Sell goods for reputation"),
					string.format(_("trade-comms","Sell goods to %s"),comms_target:getCallSign()),
					string.format(_("trade-comms","Sell goods to %s for reputation"),comms_target:getCallSign()),
				}
				addCommsReply(tableRemoveRandom(sell_goods_prompts),sellGoodsToStation)
			end
		end
		if station_trades then
			if commerce_out == "" then
				commerce_out = string.format(_("trade-comms","%s trades %s for %s."),comms_target:getCallSign(),goods_for_sale,trade_goods)
			else
				commerce_out = string.format(_("trade-comms","%s\n%s trades %s for %s."),commerce_out,comms_target:getCallSign(),goods_for_sale,trade_goods)
			end
			local trade_match = false
			if player_has_goods then
				for trade_good,trade_bool in pairs(comms_target.comms_data.trade) do
					for good, good_quantity in pairs(comms_source.goods) do
						if good == trade_good then
							trade_match = true
							break
						end
					end
				end 
			end
			if trade_match then
				local trade_goods_prompts = {
					_("trade-comms","Trade goods"),
					_("trade-comms","Exchange goods"),
					_("trade-comms","Barter goods"),
					string.format(_("trade-comms","Trade goods with %s"),comms_target:getCallSign()),
				}
				addCommsReply(tableRemoveRandom(trade_goods_prompts),tradeGoodsWithStation)
			end
		end
		if player_has_goods then
			if commerce_out == "" then
				commerce_out = string.format(_("trade-comms","%s has %s aboard."),comms_source:getCallSign(),player_goods)
			else
				commerce_out = string.format(_("trade-comms","%s\n%s has %s aboard."),commerce_out,comms_source:getCallSign(),player_goods)
			end
			local jettison_goods_prompts = {
				_("trade-comms","Jettison goods"),
				_("trade-comms","Throw goods out the airlock"),
				_("trade-comms","Dispose of goods"),
				_("trade-comms","Destroy goods"),
			}
			addCommsReply(tableRemoveRandom(jettison_goods_prompts),jettisonGoodsFromShip)
			local donate_goods_prompts = {
				_("trade-comms","Give goods to station"),
				_("trade-comms","Donate goods to station"),
				string.format(_("trade-comms","Give goods to %s"),comms_target:getCallSign()),
				string.format(_("trade-comms","Donate goods to %s"),comms_target:getCallSign()),
			}
			addCommsReply(tableRemoveRandom(donate_goods_prompts),giveGoodsToStation)
		end
		local commerce_options_for_goods = {
			string.format(_("trade-comms","%s\nWhich of these actions related to goods do you wish to take?"),commerce_out),
			string.format(_("trade-comms","%s\nWhich of these goods related actions do you want to take?"),commerce_out),
			string.format(_("trade-comms","%s\nSelect a goods related action"),commerce_out),
			string.format(_("trade-comms","%s\nIn terms of goods, what would you like to do?"),commerce_out),
		}
		setCommsMessage(tableRemoveRandom(commerce_options_for_goods))
	else
		local no_commerce_options = {
			_("trade-comms","No commercial options available"),
			_("trade-comms","Commerce options not available"),
			string.format(_("trade-comms","No commercial options available at %s"),comms_target:getCallSign()),
			string.format(_("trade-comms","%s has no available commercial options"),comms_target:getCallSign()),
		}
		setCommsMessage(tableRemoveRandom(no_commerce_options))
	end
	if scenarioGoodsCommerce ~= nil then
		scenarioGoodsCommerce()
	end
	addCommsReply(_("Back"), commsStation)
end
function buyGoodsFromStation()
	if comms_source.cargo == nil then
		comms_source.maxCargo = 3
		comms_source.cargo = comms_source.maxCargo
	end
	local buy_goods_prompt = {
		_("trade-comms","Which one of these goods would you like to buy?"),
		_("trade-comms","Which one would you like to buy?"),
		_("trade-comms","You can choose to buy one of these."),
		_("trade-comms","What do you want to buy?"),
	}
	setCommsMessage(tableRemoveRandom(buy_goods_prompt))
	if comms_target.comms_data.goods ~= nil then
		for good, good_data in pairs(comms_target.comms_data.goods) do
			local buy_goods_at_price_prompts = {
				string.format(_("trade-comms","Buy one %s for %i reputation"),good_desc[good],good_data["cost"]),
				string.format(_("trade-comms","Buy a %s for %i reputation"),good_desc[good],good_data["cost"]),
				string.format(_("trade-comms","Buy %s from %s for %i rep"),good_desc[good],comms_target:getCallSign(),good_data["cost"]),
				string.format(_("trade-comms","Purchase %s for %i reputation"),good_desc[good],good_data["cost"]),
			}
			addCommsReply(tableRemoveRandom(buy_goods_at_price_prompts), function()
				if not comms_source:isDocked(comms_target) then 
					local stay_docked_to_buy = {
						_("trade-comms","You need to stay docked for that action."),
						_("trade-comms","You need to stay docked to buy."),
						string.format(_("trade-comms","You must stay docked long enough for a sale between %s and %s to be completed."),comms_target:getCallSign(),comms_source:getCallSign()),
						string.format(_("trade-comms","You undocked before %s could complete the sale you requested."),comms_target:getCallSign()),
					}
					setCommsMessage(tableRemoveRandom(stay_docked_to_buy))
					return
				end
				local good_type_label = {
					string.format(_("trade-comms","Type: %s"),good_desc[good]),
					string.format(_("trade-comms","Type of good: %s"),good_desc[good]),
					string.format(_("trade-comms","Good type: %s"),good_desc[good]),
					string.format(_("trade-comms","Kind of good: %s"),good_desc[good]),
				}
				local reputation_price_of_good = {
					string.format(_("trade-comms","Reputation price: %i"),good_data["cost"]),
					string.format(_("trade-comms","Price in reputation points: %i"),good_data["cost"]),
					string.format(_("trade-comms","Reputation sale price: %i"),good_data["cost"]),
					string.format(_("trade-comms","Priced at %i reputation"),good_data["cost"]),
				}
				local quantity_of_good = {
					string.format(_("trade-comms","Quantity: %s"),good_data["quantity"]),
					string.format(_("trade-comms","How much inventory: %s"),good_data["quantity"]),
					string.format(_("trade-comms","%s's quantity: %s"),comms_target:getCallSign(),good_data["quantity"]),
					string.format(_("trade-comms","Quantity on hand: %s"),good_data["quantity"]),
				}
				local purchase_results = {
					_("trade-comms","One bought"),
					_("trade-comms","You bought one"),
					string.format(_("trade-comms","You purchased one from %s"),comms_target:getCallSign()),
					string.format(_("trade-comms","%s sold one to you"),comms_target:getCallSign()),
				}
				local goodTransactionMessage = string.format("%s\n%s\n%s",tableRemoveRandom(good_type_label),tableRemoveRandom(reputation_price_of_good),tableRemoveRandom(quantity_of_good))
				if comms_source.cargo < 1 then
					local insufficient_cargo_space_addendum = {
						_("trade-comms","Insufficient cargo space for purchase"),
						_("trade-comms","You don't have enough room in your cargo hold"),
						string.format(_("trade-comms","Insufficient room in %s's cargo hold"),comms_source:getCallSign()),
						string.format(_("trade-comms","%s does not have enough available cargo space"),comms_source:getCallSign()),
					}
					goodTransactionMessage = string.format("%s\n%s",goodTransactionMessage,tableRemoveRandom(insufficient_cargo_space_addendum))
				elseif good_data["cost"] > math.floor(comms_source:getReputationPoints()) then
					local insufficient_rep_responses = {
						_("needRep-comms","Insufficient reputation"),
						_("needRep-comms","Not enough reputation"),
						_("needRep-comms","You need more reputation"),
						string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
						_("needRep-comms","You don't have enough reputation"),
						string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
					}
					goodTransactionMessage = string.format("%s\n%s",goodTransactionMessage,tableRemoveRandom(insufficient_rep_responses))
				elseif good_data["quantity"] < 1 then
					local insufficient_station_inventory = {
						_("trade-comms","Insufficient station inventory"),
						_("trade-comms","Not enough inventory on the station"),
						string.format(_("trade-comms","%s does not have enough inventory"),comms_target:getCallSign()),
						string.format(_("trade-comms","Not enough inventory on %s"),comms_target:getCallSign()),
					}
					goodTransactionMessage = string.format("%s\n%s",goodTransactionMessage,tableRemoveRandom(insufficient_station_inventory))
				else
					if comms_source:takeReputationPoints(good_data["cost"]) then
						comms_source.cargo = comms_source.cargo - 1
						good_data["quantity"] = good_data["quantity"] - 1
						if comms_source.goods == nil then
							comms_source.goods = {}
						end
						if comms_source.goods[good] == nil then
							comms_source.goods[good] = 0
						end
						comms_source.goods[good] = comms_source.goods[good] + 1
						goodTransactionMessage = string.format("%s\n%s",goodTransactionMessage,tableRemoveRandom(purchase_results))
					else
						local insufficient_rep_responses = {
							_("needRep-comms","Insufficient reputation"),
							_("needRep-comms","Not enough reputation"),
							_("needRep-comms","You need more reputation"),
							string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
							_("needRep-comms","You don't have enough reputation"),
							string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
						}
						goodTransactionMessage = string.format("%s\n%s",goodTransactionMessage,tableRemoveRandom(insufficient_rep_responses))
					end
				end
				setCommsMessage(goodTransactionMessage)
				addCommsReply(_("trade-comms","Back to buy goods from station options"),buyGoodsFromStation)
				addCommsReply(_("trade-comms","Back to commercial options"),goodsCommerce)
				addCommsReply(_("Back to station communication"), commsStation)
			end)
		end
	else
		local insufficient_station_inventory = {
			_("trade-comms","Insufficient station inventory"),
			_("trade-comms","Not enough inventory on the station"),
			string.format(_("trade-comms","%s does not have enough inventory"),comms_target:getCallSign()),
			string.format(_("trade-comms","Not enough inventory on %s"),comms_target:getCallSign()),
		}
		setCommsMessage(tableRemoveRandom(insufficient_station_inventory))
	end
	addCommsReply(_("Back"), commsStation)
end
function sellGoodsToStation()
	local sell_goods_prompt = {
		_("trade-comms","Which one of these goods would you like to sell?"),
		_("trade-comms","Which one would you like to sell?"),
		_("trade-comms","You may choose from these to sell."),
		_("trade-comms","What do you want to sell?"),
	}
	local good_match_count = 0
	if comms_target.comms_data.buy ~= nil then
		for good, price in pairs(comms_target.comms_data.buy) do
			if comms_source.goods[good] ~= nil and comms_source.goods[good] > 0 then
				good_match_count = good_match_count + 1
				local sell_a_good_prompt = {
					string.format(_("trade-comms","Sell one %s for %i reputation"),good_desc[good],price),
					string.format(_("trade-comms","Sell a %s for %i reputation"),good_desc[good],price),
					string.format(_("trade-comms","Sell %s and get %i reputation"),good_desc[good],price),
					string.format(_("trade-comms","For %s reputation, sell a %s"),price,good_desc[good]),
				}
				addCommsReply(tableRemoveRandom(sell_a_good_prompt), function()
					if not comms_source:isDocked(comms_target) then 
						local stay_docked_to_sell = {
							_("trade-comms","You need to stay docked for that action."),
							_("trade-comms","You need to stay docked to sell."),
							string.format(_("trade-comms","You must stay docked long enough for a sale between %s and %s to be completed."),comms_source:getCallSign(),comms_target:getCallSign()),
							string.format(_("trade-comms","You undocked before %s could complete the sale you requested."),comms_target:getCallSign()),
						}
						setCommsMessage(tableRemoveRandom(stay_docked_to_sell))
						return
					end
					local good_type_label = {
						string.format(_("trade-comms","Type: %s"),good_desc[good]),
						string.format(_("trade-comms","Type of good: %s"),good_desc[good]),
						string.format(_("trade-comms","Good type: %s"),good_desc[good]),
						string.format(_("trade-comms","Kind of good: %s"),good_desc[good]),
					}
					local reputation_price_of_good = {
						string.format(_("trade-comms","Reputation price: %i"),price),
						string.format(_("trade-comms","Price in reputation points: %i"),price),
						string.format(_("trade-comms","Reputation sale price: %i"),price),
						string.format(_("trade-comms","Priced at %i reputation"),price),
					}
					local sale_results = {
						_("trade-comms","One sold"),
						_("trade-comms","You sold one"),
						string.format(_("trade-comms","You sold one to %s"),comms_target:getCallSign()),
						string.format(_("trade-comms","%s bought one from you"),comms_target:getCallSign()),
					}
					setCommsMessage(string.format(_("trade-comms","%s, %s\n%s"),tableRemoveRandom(good_type_label),tableRemoveRandom(reputation_price_of_good),tableRemoveRandom(sale_results)))
					comms_source.goods[good] = comms_source.goods[good] - 1
					comms_source:addReputationPoints(price)
					comms_source.cargo = comms_source.cargo + 1
					addCommsReply(_("trade-comms","Back to sell to station options"),sellGoodsToStation)
					addCommsReply(_("trade-comms","Back to commercial options"),goodsCommerce)
					addCommsReply(_("trade-comms","Back to station communication"), commsStation)
				end)
			end
		end
	else
		local no_goods_to_buy = {
			_("trade-comms","This station is no longer in the market to buy goods"),
			string.format(_("trade-comms","%s is no longer in the market to buy goods"),comms_target:getCallSign()),
			string.format(_("trade-comms","%s has left the goods buying market"),comms_target:getCallSign()),
			string.format(_("trade-comms","%s no longer wants to buy any goods"),comms_target:getCallSign()),
		}
		setCommsMessage(tableRemoveRandom(no_goods_to_buy))
	end
	if good_match_count == 0 then
		local no_matching_sellable_goods = {
			_("trade-comms","You no longer have anything the station is interested in."),
			string.format(_("trade-comms","You have nothing %s is interested in."),comms_target:getCallSign()),
			string.format(_("trade-comms","%s is not interested in any goods you have."),comms_target:getCallSign()),
			string.format(_("trade-comms","[%s purchasing agent]\n'Sorry, %s. You have nothing that interests us.'\nYou hear the sound of a ledger book closing just before the mic cuts off."),comms_target:getCallSign(),comms_source:getCallSign()),
		}
		setCommsMessage(tableRemoveRandom(no_matching_sellable_goods))
	end
	addCommsReply(_("Back"), commsStation)
end
function jettisonGoodsFromShip()
	local jettison_prompt = {
		_("trade-comms","What should be jettisoned?"),
		_("trade-comms","You pick it and out the airlock it will go."),
		_("trade-comms","What do you want to chunk out the airlock?"),
		_("trade-comms","What shall we toss out the airlock?"),
	}
	setCommsMessage(tableRemoveRandom(jettison_prompt))
	local goods_to_toss_count = 0
	for good, good_quantity in pairs(comms_source.goods) do
		if good_quantity > 0 then
			goods_to_toss_count = goods_to_toss_count + 1
			addCommsReply(good_desc[good], function()
				comms_source.goods[good] = comms_source.goods[good] - 1
				comms_source.cargo = comms_source.cargo + 1
				local jettisoned_confirmed = {
					string.format(_("trade-comms","One %s jettisoned"),good_desc[good]),
					string.format(_("trade-comms","One %s has been destroyed"),good_desc[good]),
					string.format(_("trade-comms","One %s has been tossed out of the airlock"),good_desc[good]),
					string.format(_("trade-comms","One %s has been placed in the arms of the vacuum of space"),good_desc[good]),
				}
				setCommsMessage(tableRemoveRandom(jettisoned_confirmed))
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end
	if goods_to_toss_count == 0 then
		local nothing_to_jettison = {
			_("trade-comms","No more goods to toss"),
			_("trade-comms","You've got nothing left to jettison"),
			_("trade-comms","Your cargo hold is empty so there's nothing else to get rid of"),
			_("trade-comms","No more goods to jettison"),
		}
		setCommsMessage(tableRemoveRandom(nothing_to_jettison))
		addCommsReply(_("Back"), commsStation)
	end
	addCommsReply(_("Back"), commsStation)
end
function giveGoodsToStation()
	local donate_prompt = {
		_("trade-comms","What should we give to the station?"),
		_("trade-comms","What should we give to the station out of the goodness of our heart?"),
		_("trade-comms","What should we donate to the station?"),
		_("trade-comms","What can we give the station that will help them the most?"),
	}
	setCommsMessage(tableRemoveRandom(donate_prompt))
	local goods_to_give_count = 0
	for good, good_quantity in pairs(comms_source.goods) do
		if good_quantity > 0 then
			goods_to_give_count = goods_to_give_count + 1
			addCommsReply(good_desc[good], function()
				string.format("")
				comms_source.goods[good] = comms_source.goods[good] - 1
				comms_source.cargo = comms_source.cargo + 1
				local want_it = false
				if comms_target.comms_data.buy ~= nil then
					for good_buy, price in pairs(comms_target.comms_data.buy) do
						if good == good_buy then
							comms_target.comms_data.friendlyness = math.min(100,comms_target.comms_data.friendlyness + price/2)
							comms_source:addReputationPoints(math.floor(price/2))
							want_it = true
							break
						end
					end
				end
				if not want_it then
					comms_target.comms_data.friendlyness = math.min(100,comms_target.comms_data.friendlyness + random(3,9))
				end
				local donated_confirmed = {
					string.format(_("trade-comms","One %s donated"),good_desc[good]),
					string.format(_("trade-comms","We gave one %s to %s"),good_desc[good],comms_target:getCallSign()),
					string.format(_("trade-comms","We donated a %s"),good_desc[good]),
					string.format(_("trade-comms","We provided %s with one %s"),comms_target:getCallSign(),good_desc[good]),
				}
				setCommsMessage(tableRemoveRandom(donated_confirmed))
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end
	if goods_to_give_count == 0 then
		local out_of_goods = {
			_("trade-comms","No more goods to donate"),
			_("trade-comms","There is nothing left in the cargo hold to donate"),
			_("trade-comms","You've got nothing more available to donate"),
			_("trade-comms","Your cargo hold is empty, so you cannot donate anything else"),
		}
		setCommsMessage(tableRemoveRandom(out_of_goods))
		addCommsReply(_("Back"), commsStation)
	end
	addCommsReply(_("Back"), commsStation)
end
function overchargeShipSystems()
	local overcharge_available = false
	local jump_overcharge_available = false
	local front_shield_overcharge_available = false
	local rear_shield_overcharge_available = false
	if comms_target.comms_data.jump_overcharge and comms_source:hasJumpDrive() then
		local max_charge = comms_source.max_jump_range
		if max_charge == nil then
			max_charge = 50000
		end
		if comms_source:getJumpDriveCharge() >= max_charge then
			if comms_target:isFriendly(comms_source) then
				if comms_target.comms_data.friendlyness > 20 then
					overcharge_available = true
					jump_overcharge_available = true
				end
			elseif not comms_target:isEnemy(comms_source) then
				if comms_target.comms_data.friendlyness > 33 then
					overcharge_available = true
					jump_overcharge_available = true
				end
			end
		end
	end
	if comms_target.comms_data.shield_overcharge and comms_source:getShieldCount() > 0 then
		if comms_source:getShieldLevel(0) == comms_source:getShieldMax(0) then
			if comms_target:isFriendly(comms_source) then
				if comms_target.comms_data.friendlyness > 15 then
					overcharge_available = true
					front_shield_overcharge_available = true
				end
			elseif not comms_target:isEnemy(comms_source) then
				if comms_target.comms_data.friendlyness > 30 then
					overcharge_available = true
					front_shield_overcharge_available = true
				end
			end
		end
		if comms_source:getShieldCount() > 1 and comms_source:getShieldLevel(1) == comms_source:getShieldMax(1) then
			if comms_target:isFriendly(comms_source) then
				if comms_target.comms_data.friendlyness > 20 then
					overcharge_available = true
					rear_shield_overcharge_available = true
				end
			elseif not comms_target:isEnemy(comms_source) then
				if comms_target.comms_data.friendlyness > 40 then
					overcharge_available = true
					rear_shield_overcharge_available = true
				end
			end
		end
	end
	if overcharge_available then
		local overcharge_system_prompt = {
			_("upgrade-comms","Overcharge ship system"),
			_("upgrade-comms","Put extra power in ship system"),
			_("upgrade-comms","Bank energy in ship system"),
			string.format(_("upgrade-comms","Overcharge %s's system"),comms_source:getCallSign()),
		}
		addCommsReply(tableSelectRandom(overcharge_system_prompt),function()
			local explain_general_overcharge = {
				_("upgrade-comms","Some ship systems are designed to handle more than the standard amount of power."),
				_("upgrade-comms","You can overcharge some systems to make them more effective."),
				string.format(_("upgrade-comms","You can put additional power into some of the systems on %s."),comms_source:getCallSign()),
				string.format(_("upgrade-comms","%s can add power to some of the systems on %s."),comms_target:getCallSign(),comms_source:getCallSign()),
			}
			local explain_out = tableSelectRandom(explain_general_overcharge)
			if jump_overcharge_available then
				local explain_jump_overcharge = {
					_("upgrade-comms","Overcharging your jump drive means you don't have to wait for the ship battery to recharge the jump drive for the next jump."),
					_("upgrade-comms","Putting extra power in your jump drive means you don't have to wait for the ship battery to recharge the jump drive for the next jump."),
					_("upgrade-comms","Adding power your jump drive means you don't have to wait for the ship battery to recharge the jump drive for the next jump."),
					_("upgrade-comms","If you add power your jump drive, you won't have to wait for the ship battery to recharge the jump drive for the next jump."),
				}
				explain_out = string.format("%s %s",explain_out,tableSelectRandom(explain_jump_overcharge))
				local overcharge_cost = 10
				if comms_target.comms_data.friendlyness > 66 then
					overcharge_cost = 5
				end
				local overcharge_jump_prompt = {
					string.format(_("upgrade-comms","Overcharge Jump Drive (%i rep)"),overcharge_cost),
					string.format(_("upgrade-comms","Add power to jump drive (%i rep)"),overcharge_cost),
					string.format(_("upgrade-comms","Spend %i reputation to overcharge jump drive"),overcharge_cost),
					string.format(_("upgrade-comms","Inject power into the jump drive (%i rep)"),overcharge_cost),
				}
				addCommsReply(tableSelectRandom(overcharge_jump_prompt),function()
					if comms_source:takeReputationPoints(overcharge_cost) then
						local max_charge = comms_source.max_jump_range
						if max_charge == nil then
							max_charge = 50000
						end
						comms_source:setJumpDriveCharge(comms_source:getJumpDriveCharge() + max_charge)
						local overcharge_jump_confirmation = {
							string.format(_("upgrade-comms","Your jump drive has been overcharged to %ik"),math.floor(comms_source:getJumpDriveCharge()/1000)),
							string.format(_("upgrade-comms","Your jump drive is not at overcharge level %ik"),math.floor(comms_source:getJumpDriveCharge()/1000)),
							string.format(_("upgrade-comms","%s now has a jump drive charge of %ik"),comms_source:getCallSign(),math.floor(comms_source:getJumpDriveCharge()/1000)),
							string.format(_("upgrade-comms","%s has overcharged the jump drive on %s to %ik"),comms_target:getCallSign(),comms_source:getCallSign(),math.floor(comms_source:getJumpDriveCharge()/1000)),
						}
						setCommsMessage(tableSelectRandom(overcharge_jump_confirmation))
					else
						local insufficient_rep_responses = {
							_("needRep-comms","Insufficient reputation"),
							_("needRep-comms","Not enough reputation"),
							_("needRep-comms","You need more reputation"),
							string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
							_("needRep-comms","You don't have enough reputation"),
							string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
						}
						setCommsMessage(tableSelectRandom(insufficient_rep_responses))
					end
					addCommsReply(_("Back"), commsStation)
				end)
			end
			if front_shield_overcharge_available then
				local base_front_shield_overcharge_cost = 10
				if comms_target:isFriendly(comms_source) then
					if comms_target.comms_data.friendlyness > 80 then
						base_front_shield_overcharge_cost = 5
					elseif comms_target.comms_data.friendlyness > 70 then
						base_front_shield_overcharge_cost = 7
					end
				elseif not comms_target:isEnemy(comms_source) then
					if comms_target.comms_data.friendlyness > 90 then
						base_front_shield_overcharge_cost = 5
					elseif comms_target.comms_data.friendlyness > 75 then
						base_front_shield_overcharge_cost = 7
					end
				end
				if comms_source:getReputationPoints() > 2*base_front_shield_overcharge_cost then
					local overcharge_front_shield_multiple_prompt = {
						string.format(_("upgrade-comms","Overcharge front shield (%i to %i rep)"),base_front_shield_overcharge_cost,base_front_shield_overcharge_cost*4),
						string.format(_("upgrade-comms","Boost front shield (%i to %i rep)"),base_front_shield_overcharge_cost,base_front_shield_overcharge_cost*4),
						string.format(_("upgrade-comms","Juice up front shield (%i to %i rep)"),base_front_shield_overcharge_cost,base_front_shield_overcharge_cost*4),
						string.format(_("upgrade-comms","Spend %i to %i rep to overcharge front shield"),base_front_shield_overcharge_cost,base_front_shield_overcharge_cost*4),
					}
					addCommsReply(tableSelectRandom(overcharge_front_shield_multiple_prompt),function()
						local specify_front_shield_overcharge = {
							_("upgrade-comms","How much of an overcharge would you like on your front shields?"),
							_("upgrade-comms","What kind of an overcharge would you like on your front shields?"),
							_("upgrade-comms","How much of an overcharge would you like to apply to your front shields?"),
							string.format(_("upgrade-comms","How much overcharge should put into %s's front shields?"),comms_source:getCallSign()),
						}
						setCommsMessage(tableSelectRandom(specify_front_shield_overcharge))
						for i=1,4 do
							if i*base_front_shield_overcharge_cost <= comms_source:getReputationPoints() then
								addCommsReply(string.format(_("upgrade-comms","%i%% overcharge (%i rep)"),i*5,i*base_front_shield_overcharge_cost),function()
									if comms_source:takeReputationPoints(i*base_front_shield_overcharge_cost) then
										if comms_source:getShieldCount() == 1 then
											comms_source:setShields(comms_source:getShieldMax(0)*(1 + i*5/100))
										else
											comms_source:setShields(comms_source:getShieldMax(0)*(1 + i*5/100),comms_source:getShieldLevel(1))
										end
										local front_shield_overcharge_confirm = {
											_("upgrade-comms","Your front shield has been overcharged"),
											_("upgrade-comms","We overcharged your front shield"),
											string.format(_("upgrade-comms","%s now has an overcharged front shield"),comms_source:getCallSign()),
											string.format(_("upgrade-comms","%s has overcharged the front shield of %s"),comms_target:getCallSign(),comms_source:getCallSign()),
										}
										setCommsMessage(tableSelectRandom(front_shield_overcharge_confirm))
									else
										local insufficient_rep_responses = {
											_("needRep-comms","Insufficient reputation"),
											_("needRep-comms","Not enough reputation"),
											_("needRep-comms","You need more reputation"),
											string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
											_("needRep-comms","You don't have enough reputation"),
											string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
										}
										setCommsMessage(tableSelectRandom(insufficient_rep_responses))
									end
									addCommsReply(_("Back"), commsStation)
								end)
							end
						end
					end)
				else
					local overcharge_front_shield_single_prompt = {
						string.format(_("upgrade-comms","Overcharge front shield (%i rep)"),base_front_shield_overcharge_cost),
						string.format(_("upgrade-comms","Boost front shield (%i rep)"),base_front_shield_overcharge_cost),
						string.format(_("upgrade-comms","Juice up front shield (%i rep)"),base_front_shield_overcharge_cost),
						string.format(_("upgrade-comms","Spend %i rep to overcharge front shield"),base_front_shield_overcharge_cost),
					}
					addCommsReply(tableSelectRandom(overcharge_front_shield_single_prompt),function()
						if comms_source:takeReputationPoints(base_front_shield_overcharge_cost) then
							if comms_source:getShieldCount() == 1 then
								comms_source:setShields(comms_source:getShieldMax(0)*1.05)
							else
								comms_source:setShields(comms_source:getShieldMax(0)*1.05,comms_source:getShieldLevel(1))
							end
							local front_shield_overcharge_confirm = {
								_("upgrade-comms","Your front shield has been overcharged"),
								_("upgrade-comms","We overcharged your front shield"),
								string.format(_("upgrade-comms","%s now has an overcharged front shield"),comms_source:getCallSign()),
								string.format(_("upgrade-comms","%s has overcharged the front shield of %s"),comms_target:getCallSign(),comms_source:getCallSign()),
							}
							setCommsMessage(tableSelectRandom(front_shield_overcharge_confirm))
						else
							local insufficient_rep_responses = {
								_("needRep-comms","Insufficient reputation"),
								_("needRep-comms","Not enough reputation"),
								_("needRep-comms","You need more reputation"),
								string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
								_("needRep-comms","You don't have enough reputation"),
								string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
							}
							setCommsMessage(tableSelectRandom(insufficient_rep_responses))
						end
						addCommsReply(_("Back"), commsStation)
					end)
				end
			end
			if rear_shield_overcharge_available then
				local base_rear_shield_overcharge_cost = 10
				if comms_target:isFriendly(comms_source) then
					if comms_target.comms_data.friendlyness > 80 then
						base_rear_shield_overcharge_cost = 5
					elseif comms_target.comms_data.friendlyness > 70 then
						base_rear_shield_overcharge_cost = 7
					end
				elseif not comms_target:isEnemy(comms_source) then
					if comms_target.comms_data.friendlyness > 90 then
						base_rear_shield_overcharge_cost = 5
					elseif comms_target.comms_data.friendlyness > 75 then
						base_rear_shield_overcharge_cost = 7
					end
				end
				if comms_source:getReputationPoints() > 2*base_rear_shield_overcharge_cost then
					local overcharge_rear_shield_multiple_prompt = {
						string.format(_("upgrade-comms","Overcharge rear shield (%i to %i rep)"),base_rear_shield_overcharge_cost,base_rear_shield_overcharge_cost*4),
						string.format(_("upgrade-comms","Boost rear shield (%i to %i rep)"),base_rear_shield_overcharge_cost,base_rear_shield_overcharge_cost*4),
						string.format(_("upgrade-comms","Juice up rear shield (%i to %i rep)"),base_rear_shield_overcharge_cost,base_rear_shield_overcharge_cost*4),
						string.format(_("upgrade-comms","Spend %i to %i rep to overcharge rear shield"),base_rear_shield_overcharge_cost,base_rear_shield_overcharge_cost*4),
					}
					addCommsReply(tableSelectRandom(overcharge_rear_shield_multiple_prompt),function()
						local specify_rear_shield_overcharge = {
							_("upgrade-comms","How much of an overcharge would you like on your rear shields?"),
							_("upgrade-comms","What kind of an overcharge would you like on your rear shields?"),
							_("upgrade-comms","How much of an overcharge would you like to apply to your rear shields?"),
							string.format(_("upgrade-comms","How much overcharge should put into %s's rear shields?"),comms_source:getCallSign()),
						}
						setCommsMessage(tableSelectRandom(specify_rear_shield_overcharge))
						for i=1,4 do
							if i*base_rear_shield_overcharge_cost <= comms_source:getReputationPoints() then
								addCommsReply(string.format(_("upgrade-comms","%i%% overcharge (%i rep)"),i*5,i*base_rear_shield_overcharge_cost),function()
									if comms_source:takeReputationPoints(i*base_rear_shield_overcharge_cost) then
										comms_source:setShields(comms_source:getShieldLevel(0),comms_source:getShieldMax(1)*(1 + i*5/100))
										local rear_shield_overcharge_confirm = {
											_("upgrade-comms","Your rear shield has been overcharged"),
											_("upgrade-comms","We overcharged your rear shield"),
											string.format(_("upgrade-comms","%s now has an overcharged rear shield"),comms_source:getCallSign()),
											string.format(_("upgrade-comms","%s has overcharged the rear shield of %s"),comms_target:getCallSign(),comms_source:getCallSign()),
										}
										setCommsMessage(tableSelectRandom(rear_shield_overcharge_confirm))
									else
										local insufficient_rep_responses = {
											_("needRep-comms","Insufficient reputation"),
											_("needRep-comms","Not enough reputation"),
											_("needRep-comms","You need more reputation"),
											string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
											_("needRep-comms","You don't have enough reputation"),
											string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
										}
										setCommsMessage(tableSelectRandom(insufficient_rep_responses))
									end
									addCommsReply(_("Back"), commsStation)
								end)
							end
						end
					end)
				else
					local overcharge_rear_shield_single_prompt = {
						string.format(_("upgrade-comms","Overcharge rear shield (%i rep)"),base_rear_shield_overcharge_cost),
						string.format(_("upgrade-comms","Boost rear shield (%i rep)"),base_rear_shield_overcharge_cost),
						string.format(_("upgrade-comms","Juice up rear shield (%i rep)"),base_rear_shield_overcharge_cost),
						string.format(_("upgrade-comms","Spend %i rep to overcharge rear shield"),base_rear_shield_overcharge_cost),
					}
					addCommsReply(tableSelectRandom(overcharge_rear_shield_single_prompt),function()
						if comms_source:takeReputationPoints(base_rear_shield_overcharge_cost) then
							comms_source:setShields(comms_source:getShieldLevel(0),comms_source:getShieldMax(1)*1.05)
							local rear_shield_overcharge_confirm = {
								_("upgrade-comms","Your rear shield has been overcharged"),
								_("upgrade-comms","We overcharged your rear shield"),
								string.format(_("upgrade-comms","%s now has an overcharged rear shield"),comms_source:getCallSign()),
								string.format(_("upgrade-comms","%s has overcharged the rear shield of %s"),comms_target:getCallSign(),comms_source:getCallSign()),
							}
							setCommsMessage(tableSelectRandom(rear_shield_overcharge_confirm))
						else
							local insufficient_rep_responses = {
								_("needRep-comms","Insufficient reputation"),
								_("needRep-comms","Not enough reputation"),
								_("needRep-comms","You need more reputation"),
								string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
								_("needRep-comms","You don't have enough reputation"),
								string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
							}
							setCommsMessage(tableSelectRandom(insufficient_rep_responses))
						end
						addCommsReply(_("Back"), commsStation)
					end)
				end
			end
			if front_shield_overcharge_available or rear_shield_overcharge_available then
				local explain_shield_overcharge = {
					_("upgrade-comms","Overcharging your shield makes it stronger."),
					_("upgrade-comms","Overcharging your shield makes it resist damage better."),
					_("upgrade-comms","Overcharging your shield makes it more effective."),
					_("upgrade-comms","Overcharging your shield makes it last longer."),
				}
				explain_out = string.format("%s %s",explain_out,tableSelectRandom(explain_shield_overcharge))
			end
			setCommsMessage(explain_out)
		end)
	end
end
---------------------------
--	Ship Communications  --
---------------------------
function commsShip()
	if comms_target.comms_data == nil then
		comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
	end
--	comms_data = comms_target.comms_data
	if comms_target.comms_data.goods == nil then
		if stations_sell_goods then
			goodsOnShip(comms_target)
		end
	end
	if comms_source:isFriendly(comms_target) then
		return friendlyShipComms()
	end
	if comms_source:isEnemy(comms_target) and comms_target:isFriendOrFoeIdentifiedBy(comms_source) then
		return enemyComms()
	end
	return neutralComms()
end
function goodsOnShip(comms_target)
	comms_target.comms_data.goods = {}
	initializeCommonGoods()
	comms_target.comms_data.goods[tableSelectRandom(commonGoods)] = {quantity = 1, cost = math.random(20,80)}
	local ship_type = comms_target:getTypeName()
	if ship_type:find("Freighter") ~= nil then
		if ship_type:find("Goods") ~= nil or ship_type:find("Equipment") ~= nil then
			local count_repeat_loop = 0
			repeat
				comms_target.comms_data.goods[tableSelectRandom(commonGoods)] = {quantity = 1, cost = math.random(20,80)}
				local goodCount = 0
				for good, goodData in pairs(comms_target.comms_data.goods) do
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
--	Functions you may want to set up outside of this utility
--		scenarioShipMissions - Allows the scenario writer to add situational ship comms
function friendlyShipComms()
	if comms_target.comms_data.friendlyness < 20 then
		local bad_mood_greeting = {
			_("shipAssist-comms", "What do you want?"),
			_("shipAssist-comms", "Why did you contact us?"),
			_("shipAssist-comms", "What is it?"),
			_("shipAssist-comms", "Yeah?"),
		}
		setCommsMessage(tableSelectRandom(bad_mood_greeting))
	elseif comms_target.comms_data.friendlyness < 70 then
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
	if scenarioShipMissions ~= nil then
		scenarioShipMissions()
	end
	local defend_waypoint_prompts = {
		_("shipAssist-comms", "Defend a waypoint"),
		_("shipAssist-comms", "Defend waypoint"),
		_("shipAssist-comms", "Please defend a waypoint"),
		_("shipAssist-comms", "Defend a designated waypoint"),
	}
	addCommsReply(tableSelectRandom(defend_waypoint_prompts), function()
		if comms_source:getWaypointCount() == 0 then
			local set_waypoint_first = {
				_("shipAssist-comms", "No waypoints set. Please set a waypoint first."),
				_("shipAssist-comms", "It is impossible to defend a waypoint when none are set."),
				_("shipAssist-comms", "We can't defend a waypoint when there are no waypoints set"),
				_("shipAssist-comms", "You need to set a waypoint first so that we can defend it."),
			}
			setCommsMessage(tableSelectRandom(set_waypoint_first))
		else
			local defend_what_waypoint = {
				_("shipAssist-comms", "Which waypoint should we defend?"),
				_("shipAssist-comms", "What waypoint should we defend?"),
				_("shipAssist-comms", "Designate the waypoint we should defend"),
				string.format(_("shipAssist-comms", "Identify the waypoint for %s to defend"),comms_target:getCallSign()),
			}
			setCommsMessage(tableSelectRandom(defend_what_waypoint))
			for n=1,comms_source:getWaypointCount() do
				addCommsReply(string.format(_("shipAssist-comms", "Defend waypoint %d"), n), function()
					comms_target:orderDefendLocation(comms_source:getWaypoint(n))
					local defend_wp_confirmation = {
						string.format(_("shipAssist-comms", "We are heading to assist at waypoint %d."), n),
						string.format(_("shipAssist-comms", "Changing course to assist at waypoint %d."), n),
						string.format(_("shipAssist-comms", "Moving to assist at waypoint %d."), n),
						string.format(_("shipAssist-comms", "%s is changing course to assist at waypoint %d."),comms_target:getCallSign(), n),
					}
					setCommsMessage(tableSelectRandom(defend_wp_confirmation));
					addCommsReply(_("Back"), commsShip)
				end)
			end
		end
		addCommsReply(_("Back"), commsShip)
	end)
	if comms_target.comms_data.friendlyness > 0.2 then
		local assist_me_prompts = {
			_("shipAssist-comms", "Assist me"),
			_("shipAssist-comms", "Help me"),
			string.format(_("shipAssist-comms", "Assist %s"),comms_source:getCallSign()),
			string.format(_("shipAssist-comms", "Move to %s to assist"),comms_source:getCallSign()),
		}
		addCommsReply(tableSelectRandom(assist_me_prompts), function()
			local assist_confirmation = {
				_("shipAssist-comms", "Heading toward you to assist."),
				_("shipAssist-comms", "Moving to you to assist."),
				string.format(_("shipAssist-comms", "Setting course for %s to assist."),comms_source:getCallSign()),
				string.format(_("shipAssist-comms", "%s is changing course in order to move to %s to help."),comms_target:getCallSign(),comms_source:getCallSign()),
			}
			setCommsMessage(tableSelectRandom(assist_confirmation))
			comms_target:orderDefendTarget(comms_source)
			addCommsReply(_("Back"), commsShip)
		end)
	end
	local report_status_prompts = {
		_("shipAssist-comms", "Report status"),
		_("shipAssist-comms", "Report your ship status"),
		_("shipAssist-comms", "Report status of your ship"),
		string.format(_("shipAssist-comms", "Report %s status"),comms_target:getCallSign()),
	}
	addCommsReply(tableSelectRandom(report_status_prompts), function()
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
		setCommsMessage(msg);
		addCommsReply(_("Back"), commsShip)
	end)
	for index, obj in ipairs(comms_target:getObjectsInRange(5000)) do
		if obj.typeName == "SpaceStation" and not comms_target:isEnemy(obj) then
			local dock_at_station_prompts = {
				string.format(_("shipAssist-comms", "Dock at %s"), obj:getCallSign()),
				string.format(_("shipAssist-comms", "Dock at station %s"), obj:getCallSign()),
				string.format(_("shipAssist-comms", "Dock at nearby station %s"), obj:getCallSign()),
				string.format(_("shipAssist-comms", "Please dock at %s"), obj:getCallSign()),
			}
			addCommsReply(tableSelectRandom(dock_at_station_prompts), function()
				local dock_confirmation = {
					string.format(_("shipAssist-comms", "Docking at %s."), obj:getCallSign()),
					string.format(_("shipAssist-comms", "Docking at station %s."), obj:getCallSign()),
					string.format(_("shipAssist-comms", "Docking at nearby station %s."), obj:getCallSign()),
					string.format(_("shipAssist-comms", "%s is changing course to dock at station %s."),comms_target:getCallSign(), obj:getCallSign()),
				}
				setCommsMessage(tableSelectRandom(dock_confirmation))
				comms_target:orderDock(obj)
				addCommsReply(_("Back"), commsShip)
			end)
		end
	end
	if stations_sell_goods then
		local ship_type = comms_target:getTypeName()
		if ship_type:find("Freighter") ~= nil then
			if distance(comms_source, comms_target) < 5000 then
				local goodCount = 0
				if comms_source.goods ~= nil then
					for good, goodQuantity in pairs(comms_source.goods) do
						goodCount = goodCount + 1
					end
				end
				if goodCount > 0 then
					local jettison_goods_prompts = {
						_("trade-comms","Jettison goods"),
						_("trade-comms","Throw goods out the airlock"),
						_("trade-comms","Dispose of goods"),
						_("trade-comms","Destroy goods"),
					}
					addCommsReply(tableSelectRandom(jettison_goods_prompts),function()
						local jettison_prompt = {
							string.format(_("trade-comms","Available space: %i\nWhat should be jettisoned?"),comms_source.cargo),
							string.format(_("trade-comms","Available space: %i\nYou pick it and out the airlock it will go."),comms_source.cargo),
							string.format(_("trade-comms","Available space: %i\nWhat do you want to chunk out the airlock?"),comms_source.cargo),
							string.format(_("trade-comms","Available space: %i\nWhat shall we toss out the airlock?"),comms_source.cargo),
						}
						setCommsMessage(tableSelectRandom(jettison_prompt))
						for good, good_quantity in pairs(comms_source.goods) do
							if good_quantity > 0 then
								addCommsReply(good_desc[good], function()
									comms_source.goods[good] = comms_source.goods[good] - 1
									comms_source.cargo = comms_source.cargo + 1
									local jettisoned_confirmed = {
										string.format(_("trade-comms","One %s jettisoned"),good_desc[good]),
										string.format(_("trade-comms","One %s has been destroyed"),good_desc[good]),
										string.format(_("trade-comms","One %s has been tossed out of the airlock"),good_desc[good]),
										string.format(_("trade-comms","One %s has been placed in the arms of the vacuum of space"),good_desc[good]),
									}
									setCommsMessage(tableSelectRandom(jettisoned_confirmed))
									addCommsReply("Back", commsShip)
								end)
							end
						end
						addCommsReply(_("Back"), commsShip)
					end)
				end
				if comms_target.comms_data.friendlyness > 66 then
					if ship_type:find("Goods") ~= nil or ship_type:find("Equipment") ~= nil then
						if comms_source.goods ~= nil and comms_source.goods.luxury ~= nil and comms_source.goods.luxury > 0 then
							for good, goodData in pairs(comms_target.comms_data.goods) do
								if goodData.quantity > 0 and good ~= "luxury" then
									addCommsReply(string.format(_("trade-comms", "Trade luxury for %s"),good_desc[good]), function()
										goodData.quantity = goodData.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.goods.luxury = comms_source.goods.luxury - 1
										local trade_confirmation = {
											string.format(_("trade-comms","Traded a %s for a %s"),good_desc["luxury"],good_desc[good]),
											string.format(_("trade-comms","You traded one %s for one %s"),good_desc["luxury"],good_desc[good]),
											string.format(_("trade-comms","%s agreed to trade a %s for a %s"),comms_target:getCallSign(),good_desc["luxury"],good_desc[good]),
											string.format(_("trade-comms","You successfully traded a %s for a %s"),good_desc["luxury"],good_desc[good]),
										}
										setCommsMessage(tableSelectRandom(trade_confirmation))
										comms_target.comms_data.friendlyness = math.min(100,comms_target.comms_data.friendlyness + random(2,5))
										addCommsReply(_("Back"), commsShip)
									end)
								end
							end	--freighter goods loop
						end	--player has luxury branch
					end	--goods or equipment freighter
					if comms_source.cargo > 0 then
						for good, goodData in pairs(comms_target.comms_data.goods) do
							if goodData.quantity > 0 then
								local buy_goods_at_price_prompts = {
									string.format(_("trade-comms","Buy one %s for %i reputation"),good_desc[good],math.floor(goodData.cost)),
									string.format(_("trade-comms","Buy a %s for %i reputation"),good_desc[good],math.floor(goodData.cost)),
									string.format(_("trade-comms","Buy %s from %s for %i rep"),good_desc[good],comms_target:getCallSign(),math.floor(goodData.cost)),
									string.format(_("trade-comms","Purchase %s for %i reputation"),good_desc[good],math.floor(goodData.cost)),
								}
								addCommsReply(tableSelectRandom(buy_goods_at_price_prompts), function()
									if comms_source:takeReputationPoints(math.floor(goodData.cost)) then
										goodData.quantity = goodData.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.cargo = comms_source.cargo - 1
										local purchase_results = {
											string.format(_("trade-comms","One %s bought"),good_desc[good]),
											string.format(_("trade-comms","You bought one %s"),good_desc[good]),
											string.format(_("trade-comms","You purchased one %s from %s"),good_desc[good],comms_target:getCallSign()),
											string.format(_("trade-comms","%s sold one %s to you"),comms_target:getCallSign(),good_desc[good]),
										}
										setCommsMessage(tableSelectRandom(purchase_results))
									else
										local insufficient_rep_responses = {
											_("needRep-comms","Insufficient reputation"),
											_("needRep-comms","Not enough reputation"),
											_("needRep-comms","You need more reputation"),
											string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
											_("needRep-comms","You don't have enough reputation"),
											string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
										}
										setCommsMessage(tableSelectRandom(insufficient_rep_responses))
									end
									addCommsReply(_("Back"), commsShip)
								end)
							end
						end	--freighter goods loop
					end	--player has cargo space branch
				elseif comms_target.comms_data.friendlyness > 33 then
					if comms_source.cargo > 0 then
						if ship_type:find("Goods") ~= nil or ship_type:find("Equipment") ~= nil then
							for good, goodData in pairs(comms_target.comms_data.goods) do
								if goodData.quantity > 0 then
									local buy_goods_at_price_prompts = {
										string.format(_("trade-comms","Buy one %s for %i reputation"),good_desc[good],math.floor(goodData.cost)),
										string.format(_("trade-comms","Buy a %s for %i reputation"),good_desc[good],math.floor(goodData.cost)),
										string.format(_("trade-comms","Buy %s from %s for %i rep"),good_desc[good],comms_target:getCallSign(),math.floor(goodData.cost)),
										string.format(_("trade-comms","Purchase %s for %i reputation"),good_desc[good],math.floor(goodData.cost)),
									}
									addCommsReply(tableSelectRandom(buy_goods_at_price_prompts), function()
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
											local purchase_results = {
												string.format(_("trade-comms","One %s bought"),good_desc[good]),
												string.format(_("trade-comms","You bought one %s"),good_desc[good]),
												string.format(_("trade-comms","You purchased one %s from %s"),good_desc[good],comms_target:getCallSign()),
												string.format(_("trade-comms","%s sold one %s to you"),comms_target:getCallSign(),good_desc[good]),
											}
											setCommsMessage(tableSelectRandom(purchase_results))
										else
											local insufficient_rep_responses = {
												_("needRep-comms","Insufficient reputation"),
												_("needRep-comms","Not enough reputation"),
												_("needRep-comms","You need more reputation"),
												string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
												_("needRep-comms","You don't have enough reputation"),
												string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
											}
											setCommsMessage(tableSelectRandom(insufficient_rep_responses))
										end
										addCommsReply(_("Back"), commsShip)
									end)
								end	--freighter has something to sell branch
							end	--freighter goods loop
						else	--not goods or equipment freighter
							for good, goodData in pairs(comms_target.comms_data.goods) do
								if goodData.quantity > 0 then
									local buy_goods_at_price_prompts = {
										string.format(_("trade-comms","Buy one %s for %i reputation"),good_desc[good],math.floor(goodData.cost*2)),
										string.format(_("trade-comms","Buy a %s for %i reputation"),good_desc[good],math.floor(goodData.cost*2)),
										string.format(_("trade-comms","Buy %s from %s for %i rep"),good_desc[good],comms_target:getCallSign(),math.floor(goodData.cost*2)),
										string.format(_("trade-comms","Purchase %s for %i reputation"),good_desc[good],math.floor(goodData.cost*2)),
									}
									addCommsReply(tableSelectRandom(buy_goods_at_price_prompts), function()
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
											local purchase_results = {
												string.format(_("trade-comms","One %s bought"),good_desc[good]),
												string.format(_("trade-comms","You bought one %s"),good_desc[good]),
												string.format(_("trade-comms","You purchased one %s from %s"),good_desc[good],comms_target:getCallSign()),
												string.format(_("trade-comms","%s sold one %s to you"),comms_target:getCallSign(),good_desc[good]),
											}
											setCommsMessage(tableSelectRandom(purchase_results))
										else
											local insufficient_rep_responses = {
												_("needRep-comms","Insufficient reputation"),
												_("needRep-comms","Not enough reputation"),
												_("needRep-comms","You need more reputation"),
												string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
												_("needRep-comms","You don't have enough reputation"),
												string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
											}
											setCommsMessage(tableSelectRandom(insufficient_rep_responses))
										end
										addCommsReply(_("Back"), commsShip)
									end)
								end	--freighter has something to sell branch
							end	--freighter goods loop
						end
					end	--player has room for cargo branch
				else	--least friendly
					if comms_source.cargo > 0 then
						if ship_type:find("Goods") ~= nil or ship_type:find("Equipment") ~= nil then
							for good, goodData in pairs(comms_target.comms_data.goods) do
								if goodData.quantity > 0 then
									local buy_goods_at_price_prompts = {
										string.format(_("trade-comms","Buy one %s for %i reputation"),good_desc[good],math.floor(goodData.cost*2)),
										string.format(_("trade-comms","Buy a %s for %i reputation"),good_desc[good],math.floor(goodData.cost*2)),
										string.format(_("trade-comms","Buy %s from %s for %i rep"),good_desc[good],comms_target:getCallSign(),math.floor(goodData.cost*2)),
										string.format(_("trade-comms","Purchase %s for %i reputation"),good_desc[good],math.floor(goodData.cost*2)),
									}
									addCommsReply(tableSelectRandom(buy_goods_at_price_prompts), function()
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
											local purchase_results = {
												string.format(_("trade-comms","One %s bought"),good_desc[good]),
												string.format(_("trade-comms","You bought one %s"),good_desc[good]),
												string.format(_("trade-comms","You purchased one %s from %s"),good_desc[good],comms_target:getCallSign()),
												string.format(_("trade-comms","%s sold one %s to you"),comms_target:getCallSign(),good_desc[good]),
											}
											setCommsMessage(tableSelectRandom(purchase_results))
										else
											local insufficient_rep_responses = {
												_("needRep-comms","Insufficient reputation"),
												_("needRep-comms","Not enough reputation"),
												_("needRep-comms","You need more reputation"),
												string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
												_("needRep-comms","You don't have enough reputation"),
												string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
											}
											setCommsMessage(tableSelectRandom(insufficient_rep_responses))
										end
										addCommsReply(_("Back"), commsShip)
									end)
								end	--freighter has something to sell branch
							end	--freighter goods loop
						end	--goods or equipment freighter
					end	--player has room to get goods
				end	--various friendliness choices
			else	--not close enough to sell
				local cargo_to_sell_prompts = {
					_("trade-comms","Do you have cargo you might sell?"),
					_("trade-comms","What cargo do you have for sale?"),
					_("trade-comms","Are you selling cargo?"),
					_("trade-comms","Do you have cargo for sale?"),
				}
				addCommsReply(tableSelectRandom(cargo_to_sell_prompts), function()
					local goodCount = 0
					local cargoMsg = _("trade-comms","We've got ")
					for good, goodData in pairs(comms_target.comms_data.goods) do
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
	end
	return true
end
--	Booleans to set outside of this utility to control this utility. Default is false
--		ship_reversion - set true if enemy might revert to previous orders after taunt
--		ship_immolation - set true if enemy might self destruct in rage to damage player
--	Functions you may want to set up outside of this utility
--		plotContinuum, checkContinuum for ships that will self destruct in rage
function enemyComms()
	local faction = comms_target:getFaction()
	local tauntable = false
	local amenable = false
	if comms_target.comms_data.friendlyness >= 33 then	--final: 33
		--taunt logic
		local taunt_option = _("shipEnemy-comms", "We will see to your destruction!")
		local taunt_success_reply = _("shipEnemy-comms", "Your bloodline will end here!")
		local taunt_failed_reply = _("shipEnemy-comms", "Your feeble threats are meaningless.")
		local taunt_threshold = 30		--base chance of being taunted
		local immolation_threshold = 5	--base chance that taunting will enrage to the point of revenge immolation
		local faction_taunt_options = {
			["Kraylor"] = {threshold = 35, immolation = 6, 
				hail_response = {
					_("shipEnemy-comms", "Ktzzzsss.\nYou will DIEEee weaklingsss!"),
					_("shipEnemy-comms", "Prepare to suffer at our handssss!"),
				},
				taunt_groups = {
					{
						prompt =	_("shipEnemy-comms","We will destroy you"),
						success =	_("shipEnemy-comms","We think not. It is you who will experience destruction!"),
						failure =	_("shipEnemy-comms", "Your feeble threats are meaningless."),
					},
					{
						prompt =	_("shipEnemy-comms","You have no honor"),
						success =	_("shipEnemy-comms","Your insult has brought our wrath upon you. Prepare to die."),
						failure =	_("shipEnemy-comms","Your comments about honor have no meaning to us"),
					},
					{
						prompt =	_("shipEnemy-comms","We pity your pathetic race"),
						success =	_("shipEnemy-comms","Pathetic? You will regret your disparagement!"),
						failure =	_("shipEnemy-comms","We don't care what you think of us"),
					},
				},
			},
			["Arlenians"] = {threshold = 25, immolation = 4,
				hail_response = {
					_("shipEnemy-comms","We wish you no harm, but will harm you if we must.\nEnd of transmission."),
					_("shipEnemy-comms","Stay away or we will be forced to harm you against our better natures."),
				},
				taunt_groups = {
					{
						prompt =	_("shipEnemy-comms", "We will see to your destruction!"),
						success =	_("shipEnemy-comms", "Your bloodline will end here!"),
						failure =	_("shipEnemy-comms", "Your feeble threats are meaningless."),
					},
				},
			},
			["Exuari"] = {threshold = 40, immolation = 7,
				hail_response = {
					_("shipEnemy-comms","Stay out of our way, or your death will amuse us extremely!"),
					_("shipEnemy-comms","Are you our comic relief? Good. Start dying, our drinks are getting stale."),
				},
				taunt_groups = {
					{
						prompt =	_("shipEnemy-comms", "We will see to your destruction!"),
						success =	_("shipEnemy-comms", "Your bloodline will end here!"),
						failure =	_("shipEnemy-comms", "Your feeble threats are meaningless."),
					},
				},
			},
			["Ghosts"] = {threshold = 20, immolation = 3,
				hail_response = {
					_("shipEnemy-comms","One zero one.\nNo binary communication detected.\nSwitching to universal speech.\nGenerating appropriate response for target from human language archives.\n:Do not cross us:\nCommunication halted."),
					_("shipEnemy-comms","1101 1011 0010 1100\nNo response. Switching to universal translator\nGo away\nEnd Of Line"),
				},
				taunt_groups = {
					{
						prompt =	_("shipEnemy-comms","EXECUTE: SELFDESTRUCT"),
						success =	_("shipEnemy-comms","Rogue command received. Targeting source."),
						failure =	_("shipEnemy-comms","External command ignored."),
					},
					{
						prompt =	_("shipEnemy-comms","EXECUTE: LEVEL5DIAGNOSTIC"),
						success =	_("shipEnemy-comms","Targeting source of rogue command."),
						failure =	_("shipEnemy-comms","Command failed basic security check. Ignoring."),
					},
				},
			},
			["Ktlitans"] = {threshold = 30, immolation = 5,
				hail_response = {
					_("shipEnemy-comms","The hive suffers no threats. Opposition to any of us is opposition to us all.\nStand down or prepare to donate your corpses toward our nutrition."),
					_("shipEnemy-comms","You oppose one of us, you oppose all of us.\nLeave or prepare to donate your corpses toward our nutrition."),
				},
				taunt_groups = {
					{
						prompt =	_("shipEnemy-comms","<Transmit 'The Itsy-Bitsy Spider' on all wavelengths>"),
						success =	_("shipEnemy-comms","We do not need permission to pluck apart such an insignificant threat."),
						failure =	_("shipEnemy-comms","The hive has greater priorities than exterminating pests."),
					},
					{
						prompt =	_("shipEnemy-comms","You remind me of the spider next to little Miss Muffet: Ugly. Mean enough to frighten a little girl. No redeeming virtue."),
						success =	_("shipEnemy-comms","You will die to regret such an insult."),
						failure =	_("shipEnemy-comms","Your comparisons are meaningless."),
					},
				},
			},
			["TSN"] = {threshold = 15, immolation = 2,
				hail_response = {
					_("shipEnemy-comms","State your business"),					
					_("shipEnemy-comms","What is your intent"),					
				},
				taunt_groups = {
					{
						prompt =	_("shipEnemy-comms", "We will ensure your destruction"),
						success =	_("shipEnemy-comms", "Prepare to meet your maker"),
						failure =	_("shipEnemy-comms", "You can try (and fail)"),
					},
				},
			},
			["USN"] = {threshold = 15, immolation = 2,
				hail_response = {
					_("shipEnemy-comms","What do you want? (not that we care)"),
					_("shipEnemy-comms","Why are you bothering us?"),
				},
				taunt_groups = {
					{
						prompt =	_("shipEnemy-comms", "We will make sure you are destroyed."),
						success =	_("shipEnemy-comms", "Actually, we will destroy you before you can do anything."),
						failure =	_("shipEnemy-comms", "Is that all you've got? Pathetic. (click)"),
					},
				},
			},
			["CUF"] = {threshold = 15, immolation = 2,
				hail_response = {
					_("shipEnemy-comms","Don't waste our time"),
					_("shipEnemy-comms","What do *you* want?"),
				},
				taunt_groups = {
					{
						prompt =	_("shipEnemy-comms", "Your destruction is imminent"),
						success =	_("shipEnemy-comms", "Get them!"),
						failure =	_("shipEnemy-comms", "We ignore such pathetic threats."),
					},
				},
			},
		}
		if faction_taunt_options[faction] ~= nil then
			taunt_threshold = faction_taunt_options[faction].threshold
			immolation_threshold = faction_taunt_options[faction].immolation
			setCommsMessage(tableSelectRandom(faction_taunt_options[faction].hail_response))
			local taunt_choice = tableSelectRandom(faction_taunt_options[faction].taunt_groups)
			taunt_option = taunt_choice.prompt
			taunt_success_reply = taunt_choice.success
			taunt_failed_reply = taunt_choice.failure
		else
			setCommsMessage(_("shipEnemy-comms","Mind your own business!"))
		end
		comms_target.comms_data.friendlyness = comms_target.comms_data.friendlyness - random(0, 10)	--reduce friendlyness after each interaction
		addCommsReply(taunt_option, function()
			if random(0, 100) <= taunt_threshold then
				if ship_reversion then
					local current_order = comms_target:getOrder()
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
				end
				comms_target:orderAttack(comms_source)	--consider alternative options besides attack in future refactoring
				setCommsMessage(taunt_success_reply);
			else
				--possible alternative consequences when taunt fails
				if ship_immolation then
					if random(1,100) < (immolation_threshold + difficulty) then	--final: immolation_threshold (set to 100 for testing)
						setCommsMessage(_("shipEnemy-comms","Subspace and time continuum disruption authorized"))
						comms_source.continuum_target = true
						comms_source.continuum_initiator = comms_target
						plotContinuum = checkContinuum
					else
						setCommsMessage(taunt_failed_reply)
					end
				else
					setCommsMessage(taunt_failed_reply)
				end
			end
		end)
		tauntable = true
	end
	local enemy_health = getEnemyHealth(comms_target)
	if change_enemy_order_diagnostic then print(string.format("   enemy health:    %.2f",enemy_health)) end
	if change_enemy_order_diagnostic then print(string.format("   friendliness:    %.1f",comms_target.comms_data.friendlyness)) end
	if comms_target.comms_data.friendlyness >= 66 or enemy_health < .5 then	--final: 66, .5
		--amenable logic
		local amenable_chance = comms_target.comms_data.friendlyness/3 + (1 - enemy_health)*30
		if change_enemy_order_diagnostic then print(string.format("   amenability:     %.1f",amenable_chance)) end
		addCommsReply(_("shipEnemy-comms","Stop your actions"),function()
			local amenable_roll = random(1,100)
			if change_enemy_order_diagnostic then print(string.format("   amenable roll:   %.1f",amenable_roll)) end
			if amenable_roll < amenable_chance then
				if ship_reversion then
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
				end
				comms_target:orderIdle()
				comms_target:setFaction("Independent")
				setCommsMessage(_("shipEnemy-comms","Just this once, we'll take your advice"))
			else
				setCommsMessage(_("shipEnemy-comms","No"))
			end
		end)
		comms_target.comms_data.friendlyness = comms_target.comms_data.friendlyness - random(0, 10)	--reduce friendlyness after each interaction
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
	local enemy_hull = enemy:getHull()/enemy:getHullMax()
	local enemy_reactor = enemy:getSystemHealth("reactor")
	local enemy_maneuver = enemy:getSystemHealth("maneuver")
	local enemy_impulse = enemy:getSystemHealth("impulse")
	local enemy_beam = 0
	if enemy:getBeamWeaponRange(0) > 0 then
		enemy_beam = enemy:getSystemHealth("beamweapons")
	else
		enemy_beam = 1
	end
	local enemy_missile = 0
	if enemy:getWeaponTubeCount() > 0 then
		enemy_missile = enemy:getSystemHealth("missilesystem")
	else
		enemy_missile = 1
	end
	local enemy_warp = 0
	if enemy:hasWarpDrive() then
		enemy_warp = enemy:getSystemHealth("warp")
	else
		enemy_warp = 1
	end
	local enemy_jump = 0
	if enemy:hasJumpDrive() then
		enemy_jump = enemy:getSystemHealth("jumpdrive")
	else
		enemy_jump = 1
	end
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
function neutralComms()
	if scenarioShipMissions ~= nil then
		scenarioShipMissions()
	end
	local ship_type = comms_target:getTypeName()
	if ship_type:find("Freighter") ~= nil and stations_sell_goods then
		local neutral_freighter_greetings = {
			_("trade-comms","Yes?"),
			_("trade-comms","What?"),
			_("trade-comms","Hmm?"),
			_("trade-comms","State your business."),
		}
		setCommsMessage(tableSelectRandom(neutral_freighter_greetings))
		local cargo_to_sell_prompts = {
			_("trade-comms","Do you have cargo you might sell?"),
			_("trade-comms","What cargo do you have for sale?"),
			_("trade-comms","Are you selling cargo?"),
			_("trade-comms","Do you have cargo for sale?"),
		}
		addCommsReply(tableSelectRandom(cargo_to_sell_prompts), function()
			local goodCount = 0
			local cargoMsg = _("trade-comms","We've got ")
			for good, goodData in pairs(comms_target.comms_data.goods) do
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
		if distance(comms_source,comms_target) < 5000 then
			local goodCount = 0
			if comms_source.goods ~= nil then
				for good, goodQuantity in pairs(comms_source.goods) do
					goodCount = goodCount + 1
				end
			end
			if goodCount > 0 then
				local jettison_goods_prompts = {
					_("trade-comms","Jettison cargo"),
					_("trade-comms","Throw goods out the airlock"),
					_("trade-comms","Dispose of goods"),
					_("trade-comms","Destroy goods"),
				}
				addCommsReply(tableSelectRandom(jettison_goods_prompts),function()
					local jettison_prompt = {
						string.format(_("trade-comms","Available space: %i\nWhat should be jettisoned?"),comms_source.cargo),
						string.format(_("trade-comms","Available space: %i\nYou pick it and out the airlock it will go."),comms_source.cargo),
						string.format(_("trade-comms","Available space: %i\nWhat do you want to chunk out the airlock?"),comms_source.cargo),
						string.format(_("trade-comms","Available space: %i\nWhat shall we toss out the airlock?"),comms_source.cargo),
					}
					setCommsMessage(tableSelectRandom(jettison_prompt))
					for good, good_quantity in pairs(comms_source.goods) do
						if good_quantity > 0 then
							addCommsReply(good_desc[good], function()
								comms_source.goods[good] = comms_source.goods[good] - 1
								comms_source.cargo = comms_source.cargo + 1
								local jettisoned_confirmed = {
									string.format(_("trade-comms","One %s jettisoned"),good_desc[good]),
									string.format(_("trade-comms","One %s has been destroyed"),good_desc[good]),
									string.format(_("trade-comms","One %s has been tossed out of the airlock"),good_desc[good]),
									string.format(_("trade-comms","One %s has been placed in the arms of the vacuum of space"),good_desc[good]),
								}
								setCommsMessage(tableSelectRandom(jettisoned_confirmed))
								addCommsReply(_("Back"), commsShip)
							end)
						end
					end
					addCommsReply(_("Back"), commsShip)
				end)
			end
			if comms_source.cargo > 0 then
				if comms_target.comms_data.friendlyness > 66 then
					if ship_type:find("Goods") ~= nil or ship_type:find("Equipment") ~= nil then
						if comms_target.comms_data.goods ~= nil then
							for good, goodData in pairs(comms_target.comms_data.goods) do
								if goodData.quantity > 0 then
									local buy_goods_at_price_prompts = {
										string.format(_("trade-comms","Buy one %s for %i reputation"),good_desc[good],math.floor(goodData.cost)),
										string.format(_("trade-comms","Buy a %s for %i reputation"),good_desc[good],math.floor(goodData.cost)),
										string.format(_("trade-comms","Buy %s from %s for %i rep"),good_desc[good],comms_target:getCallSign(),math.floor(goodData.cost)),
										string.format(_("trade-comms","Purchase %s for %i reputation"),good_desc[good],math.floor(goodData.cost)),
									}
									addCommsReply(tableSelectRandom(buy_goods_at_price_prompts), function()
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
											local purchase_results = {
												string.format(_("trade-comms","One %s bought"),good_desc[good]),
												string.format(_("trade-comms","You bought one %s"),good_desc[good]),
												string.format(_("trade-comms","You purchased one %s from %s"),good_desc[good],comms_target:getCallSign()),
												string.format(_("trade-comms","%s sold one %s to you"),comms_target:getCallSign(),good_desc[good]),
											}
											setCommsMessage(tableSelectRandom(purchase_results))
										else
											local insufficient_rep_responses = {
												_("needRep-comms","Insufficient reputation"),
												_("needRep-comms","Not enough reputation"),
												_("needRep-comms","You need more reputation"),
												string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
												_("needRep-comms","You don't have enough reputation"),
												string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
											}
											setCommsMessage(tableSelectRandom(insufficient_rep_responses))
										end
										addCommsReply(_("Back"), commsShip)
									end)
								end
							end	--freighter goods loop
						end
					else
						if comms_target.comms_data.goods ~= nil then
							for good, goodData in pairs(comms_target.comms_data.goods) do
								if goodData.quantity > 0 then
									local buy_goods_at_price_prompts = {
										string.format(_("trade-comms","Buy one %s for %i reputation"),good_desc[good],math.floor(goodData.cost*2)),
										string.format(_("trade-comms","Buy a %s for %i reputation"),good_desc[good],math.floor(goodData.cost*2)),
										string.format(_("trade-comms","Buy %s from %s for %i rep"),good_desc[good],comms_target:getCallSign(),math.floor(goodData.cost*2)),
										string.format(_("trade-comms","Purchase %s for %i reputation"),good_desc[good],math.floor(goodData.cost*2)),
									}
									addCommsReply(tableSelectRandom(buy_goods_at_price_prompts), function()
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
											local purchase_results = {
												string.format(_("trade-comms","One %s bought"),good_desc[good]),
												string.format(_("trade-comms","You bought one %s"),good_desc[good]),
												string.format(_("trade-comms","You purchased one %s from %s"),good_desc[good],comms_target:getCallSign()),
												string.format(_("trade-comms","%s sold one %s to you"),comms_target:getCallSign(),good_desc[good]),
											}
											setCommsMessage(tableSelectRandom(purchase_results))
										else
											local insufficient_rep_responses = {
												_("needRep-comms","Insufficient reputation"),
												_("needRep-comms","Not enough reputation"),
												_("needRep-comms","You need more reputation"),
												string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
												_("needRep-comms","You don't have enough reputation"),
												string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
											}
											setCommsMessage(tableSelectRandom(insufficient_rep_responses))
										end
										addCommsReply(_("Back"), commsShip)
									end)
								end
							end	--freighter goods loop
						end
					end
				elseif comms_target.comms_data.friendlyness > 33 then
					if ship_type:find("Goods") ~= nil or ship_type:find("Equipment") ~= nil then
						if comms_target.comms_data.goods ~= nil then
							for good, goodData in pairs(comms_target.comms_data.goods) do
								if goodData.quantity > 0 then
									local buy_goods_at_price_prompts = {
										string.format(_("trade-comms","Buy one %s for %i reputation"),good_desc[good],math.floor(goodData.cost*2)),
										string.format(_("trade-comms","Buy a %s for %i reputation"),good_desc[good],math.floor(goodData.cost*2)),
										string.format(_("trade-comms","Buy %s from %s for %i rep"),good_desc[good],comms_target:getCallSign(),math.floor(goodData.cost*2)),
										string.format(_("trade-comms","Purchase %s for %i reputation"),good_desc[good],math.floor(goodData.cost*2)),
									}
									addCommsReply(tableSelectRandom(buy_goods_at_price_prompts), function()
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
											local purchase_results = {
												string.format(_("trade-comms","One %s bought"),good_desc[good]),
												string.format(_("trade-comms","You bought one %s"),good_desc[good]),
												string.format(_("trade-comms","You purchased one %s from %s"),good_desc[good],comms_target:getCallSign()),
												string.format(_("trade-comms","%s sold one %s to you"),comms_target:getCallSign(),good_desc[good]),
											}
											setCommsMessage(tableSelectRandom(purchase_results))
										else
											local insufficient_rep_responses = {
												_("needRep-comms","Insufficient reputation"),
												_("needRep-comms","Not enough reputation"),
												_("needRep-comms","You need more reputation"),
												string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
												_("needRep-comms","You don't have enough reputation"),
												string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
											}
											setCommsMessage(tableSelectRandom(insufficient_rep_responses))
										end
										addCommsReply(_("Back"), commsShip)
									end)
								end
							end	--freighter goods loop
						end
					else
						if comms_target.comms_data.goods ~= nil then
							for good, goodData in pairs(comms_target.comms_data.goods) do
								if goodData.quantity > 0 then
									local buy_goods_at_price_prompts = {
										string.format(_("trade-comms","Buy one %s for %i reputation"),good_desc[good],math.floor(goodData.cost*3)),
										string.format(_("trade-comms","Buy a %s for %i reputation"),good_desc[good],math.floor(goodData.cost*3)),
										string.format(_("trade-comms","Buy %s from %s for %i rep"),good_desc[good],comms_target:getCallSign(),math.floor(goodData.cost*3)),
										string.format(_("trade-comms","Purchase %s for %i reputation"),good_desc[good],math.floor(goodData.cost*3)),
									}
									addCommsReply(tableSelectRandom(buy_goods_at_price_prompts), function()
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
											local purchase_results = {
												string.format(_("trade-comms","One %s bought"),good_desc[good]),
												string.format(_("trade-comms","You bought one %s"),good_desc[good]),
												string.format(_("trade-comms","You purchased one %s from %s"),good_desc[good],comms_target:getCallSign()),
												string.format(_("trade-comms","%s sold one %s to you"),comms_target:getCallSign(),good_desc[good]),
											}
											setCommsMessage(tableSelectRandom(purchase_results))
										else
											local insufficient_rep_responses = {
												_("needRep-comms","Insufficient reputation"),
												_("needRep-comms","Not enough reputation"),
												_("needRep-comms","You need more reputation"),
												string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
												_("needRep-comms","You don't have enough reputation"),
												string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
											}
											setCommsMessage(tableSelectRandom(insufficient_rep_responses))
										end
										addCommsReply(_("Back"), commsShip)
									end)
								end
							end	--freighter goods loop
						end
					end
				else	--least friendly
					if ship_type:find("Goods") ~= nil or ship_type:find("Equipment") ~= nil then
						if comms_target.comms_data.goods ~= nil then
							for good, goodData in pairs(comms_target.comms_data.goods) do
								if goodData.quantity > 0 then
									local buy_goods_at_price_prompts = {
										string.format(_("trade-comms","Buy one %s for %i reputation"),good_desc[good],math.floor(goodData.cost*3)),
										string.format(_("trade-comms","Buy a %s for %i reputation"),good_desc[good],math.floor(goodData.cost*3)),
										string.format(_("trade-comms","Buy %s from %s for %i rep"),good_desc[good],comms_target:getCallSign(),math.floor(goodData.cost*3)),
										string.format(_("trade-comms","Purchase %s for %i reputation"),good_desc[good],math.floor(goodData.cost*3)),
									}
									addCommsReply(tableSelectRandom(buy_goods_at_price_prompts), function()
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
											local purchase_results = {
												string.format(_("trade-comms","One %s bought"),good_desc[good]),
												string.format(_("trade-comms","You bought one %s"),good_desc[good]),
												string.format(_("trade-comms","You purchased one %s from %s"),good_desc[good],comms_target:getCallSign()),
												string.format(_("trade-comms","%s sold one %s to you"),comms_target:getCallSign(),good_desc[good]),
											}
											setCommsMessage(tableSelectRandom(purchase_results))
										else
											local insufficient_rep_responses = {
												_("needRep-comms","Insufficient reputation"),
												_("needRep-comms","Not enough reputation"),
												_("needRep-comms","You need more reputation"),
												string.format(_("needRep-comms","You need more than %i reputation"),math.floor(comms_source:getReputationPoints())),
												_("needRep-comms","You don't have enough reputation"),
												string.format(_("needRep-comms","%i reputation is insufficient"),math.floor(comms_source:getReputationPoints())),
											}
											setCommsMessage(tableSelectRandom(insufficient_rep_responses))
										end
										addCommsReply(_("Back"), commsShip)
									end)
								end
							end	--freighter goods loop
						end
					end
				end	--end friendly branches
			end	--player has room for cargo
		end	--close enough to sell
	else	--not a freighter or goods not for sale
		if comms_target.comms_data.friendlyness > 50 then
			local friendly_brush_off = {
				_("ship-comms", "Sorry, we have no time to chat with you.\nWe are on an important mission."),
				_("ship-comms", "Sorry, we are too busy to chat.\nWe have important business to attend to."),
				_("ship-comms", "We'd love to chat, but we're in too much of a hurry right now.\nWe are on an important mission."),
				_("ship-comms", "No time to chat right now.\nOur mission takes priority."),
			}
			setCommsMessage(tableSelectRandom(friendly_brush_off))
		else
			local unfriendly_brush_off = {
				_("ship-comms", "We have nothing for you.\nGood day."),
				_("ship-comms", "We have nothing to say to you.\nGood bye."),
				_("ship-comms", "No communication for you.\nGood day."),
				_("ship-comms", "We have nothing for you.\nFare well."),
			}
			setCommsMessage(tableSelectRandom(unfriendly_brush_off))
		end
	end	--end non-freighter communications else branch
	return true
end	--end neutral communications function
--	In your update function, you'll need a line for each possible minor upgrade. You
--	will also need to add a line for other features such as expedited docking.
--	For example:
--	function update(delta)
--		for i,p in ipairs(getActivePlayerShips()) do
--			updatePlayerImprovedStationServiceUtility(p)
--			updatePlayerInventoryButtonUtility(p)
--			updatePlayerHullBannerUtility(p)
--			updatePlayerShieldBannerUtility(p)
--			updatePlayerWaypointDistanceButtonUtility(p)
--			updatePlayerProximityScanUtility(p)
--			updatePlayerMaxHealthWidgetsUtility(p)
--			updatePlayerLongRangeSensorsUtility(delta,p)
--			updatePowerSensorButtons(p)
--			powerSensorEnabledButtons(p)
--			powerSensorStandbyButtons(p)
--			powerSensorConfigButtons(p)
--		end
--		expeditedDockingServices()
--	end
function expeditedDockingServices()
	if expedite_dock_players ~= nil then
		local function removeTimer(p)
			if p.expedite_dock_time_msg_hlm ~= nil then
				p:removeCustom(p.expedite_dock_time_msg_hlm)
				p.expedite_dock_time_msg_hlm = nil
			end
			if p.expedite_dock_time_msg_tac ~= nil then
				p:removeCustom(p.expedite_dock_time_msg_tac)
				p.expedite_dock_time_msg_tac = nil
			end
		end
		for p,rest in pairs(expedite_dock_players) do
			if p:isValid() then
				if p.expedite_dock ~= nil then
					if p.expedite_dock.expire ~= nil then
						if getScenarioTime() > p.expedite_dock.expire then
							p.expedite_dock = nil
							removeTimer(p)
							expedite_dock_players[p] = nil
						else
							if p.expedite_dock.station ~= nil then
								if p.expedite_dock.station:isValid() then
									if p:isDocked(p.expedite_dock.station) then
										for service,val in pairs(p.expedite_dock) do
											if service == "energy" then
												p:setEnergyLevel(p:getEnergyLevelMax())
											elseif service == "hull" then
												p:setHull(p:getHullMax())
											elseif service == "probes" then
												p:setScanProbeCount(p:getScanProbeCount())
											elseif service == "nuke" then
												p:setWeaponStorage("Nuke",p:getWeaponStorage("Nuke") + val)
											elseif service == "homing" then
												p:setWeaponStorage("Homing",p:getWeaponStorage("Homing") + val)
											elseif service == "mine" then
												p:setWeaponStorage("Mine",p:getWeaponStorage("Mine") + val)
											elseif service == "emp" then
												p:setWeaponStorage("EMP",p:getWeaponStorage("EMP") + val)
											elseif service == "hvli" then
												p:setWeaponStorage("HVLI",p:getWeaponStorage("HVLI") + val)
											elseif service == "repair_crew" then
												p:setRepairCrewCount(p:getRepairCrewCount() + 1)
												p.expedite_dock.station.comms_data.available_repair_crew = p.expedite_dock.station.comms_data.available_repair_crew - 1
											elseif service == "coolant" then
												p:setMaxCoolant(p:getMaxCoolant() + 2)
												p.expedite_dock.station.comms_data.coolant_inventory = p.expedite_dock.station.comms_data.coolant_inventory - 2
											end
										end
										removeTimer(p)
										expedite_dock_players[p] = nil
										p.expedite_dock = nil
										p:addToShipLog(_("shipLog","Expedited docking services complete."),"Yellow")
									else
										local expedite_dock_timer = p.expedite_dock.expire - getScenarioTime()
										if expedite_dock_timer > 60 then
											local minutes = expedite_dock_timer / 60
											local seconds = expedite_dock_timer % 60
											expedite_dock_timer = string.format("%i:%.2i",math.floor(minutes),math.floor(seconds))
										else
											expedite_dock_timer = string.format("0:%.2i",math.floor(expedite_dock_timer))
										end
										local expedite_dock_banner = string.format(_("tabHelm","Dock@%s %s"),p.expedite_dock.station:getCallSign(),expedite_dock_timer)
										p.expedite_dock_time_msg_hlm = "expedite_dock_time_msg_hlm"
										p:addCustomInfo("Helms",p.expedite_dock_time_msg_hlm,expedite_dock_banner,50)
										p.expedite_dock_time_msg_tac = "expedite_dock_time_msg_tac"
										p:addCustomInfo("Tactical",p.expedite_dock_time_msg_tac,expedite_dock_banner,50)
									end
								else
									removeTimer(p)
									expedite_dock_players[p] = nil
									p.expedite_dock = nil
								end
							else
								removeTimer(p)
								expedite_dock_players[p] = nil
								p.expedite_dock = nil
							end
						end
					else
						removeTimer(p)
						expedite_dock_players[p] = nil
					end
				else
					removeTimer(p)
					expedite_dock_players[p] = nil
				end
			end
		end
	end
end
function updatePlayerImprovedStationServiceUtility(p)
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
function updatePlayerInventoryButtonUtility(p)
	local good_count = 0
	if p.goods ~= nil then
		for good, good_quantity in pairs(p.goods) do
			good_count = good_count + good_quantity
		end
	end
	if good_count > 0 then
		p.inventory_button_rel = "inventory_button_rel"
		p:addCustomButton("Relay",p.inventory_button_rel,_("inventory-buttonRelay","Inventory"),function() 
			string.format("")
			local out = playerShipCargoInventory(p)
			p.inventory_message_rel = "inventory_message_rel"
			p:addCustomMessage("Relay",p.inventory_message_rel,out)
		end,23)
		p.inventory_button_ops = "inventory_button_ops"
		p:addCustomButton("Operations",p.inventory_button_ops,_("inventory-buttonOperations","Inventory"),function() 
			string.format("")
			local out = playerShipCargoInventory(p)
			p.inventory_message_ops = "inventory_message_ops"
			p:addCustomMessage("Operations",p.inventory_message_ops,out)
		end,23)
	else
		if p.inventory_button_rel ~= nil then
			p:removeCustom(p.inventory_button_rel)
			p.inventory_button_rel = nil
		end
		if p.inventory_button_ops ~= nil then
			p:removeCustom(p.inventory_button_ops)
			p.inventory_button_ops = nil
		end
	end
end
function playerShipCargoInventory(p)
	local out = string.format(_("msgRelay","%s Current cargo:"),p:getCallSign())
	local good_count = 0
	if p.goods ~= nil then
		for good, good_quantity in pairs(p.goods) do
			good_count = good_count + good_quantity
			out = string.format("%s\n     %s: %i",out,good_desc[good],good_quantity)
		end
	end
	if good_count < 1 then
		out = string.format(_("msgRelay","%s\n     Empty"),out)
	end
	out = string.format(_("msgRelay","%s\nAvailable space: %i"),out,p.cargo)
	return out
end
function updatePlayerHullBannerUtility(p)
	if p.hull_banner then
		local hull_status = string.format(_("tabEngineer","Hull:%.1f/%i"),p:getHull(),p:getHullMax())
		p.hull_banner_eng = "hull_banner_eng"
		p:addCustomInfo("Engineering",p.hull_banner_eng,hull_status,8)
		p.hull_banner_epl = "hull_banner_epl"
		p:addCustomInfo("Engineering+",p.hull_banner_epl,hull_status,8)
	else
		if p.hull_banner_eng ~= nil then
			p:removeCustom(p.hull_banner_eng)
			p.hull_banner_eng = nil
		end
		if p.hull_banner_epl ~= nil then
			p:removeCustom(p.hull_banner_epl)
			p.hull_banner_epl = nil
		end
	end
end
function updatePlayerShieldBannerUtility(p)
	if p.shield_banner then
		local shield_status = ""
		if p:getShieldCount() > 1 then
			shield_status = string.format(_("tabEngineer","F:%.1f/%i R:%.1f/%i"),p:getShieldLevel(0),p:getShieldMax(0),p:getShieldLevel(1),p:getShieldMax(1))
		elseif p:getShieldCount() == 1 then
			shield_status = string.format(_("tabEngineer","Shield:%.1f/%i"),p:getShieldLevel(0),p:getShieldMax(0))
		end
		if shield_status ~= "" then
			p.shield_banner_eng = "shield_banner_eng"
			p:addCustomInfo("Engineering",p.shield_banner_eng,shield_status,7)
			p.shield_banner_epl = "shield_banner_epl"
			p:addCustomInfo("Engineering+",p.shield_banner_epl,shield_status,7)
		else
			if p.shield_banner_eng ~= nil then
				p:removeCustom(p.shield_banner_eng)
				p.shield_banner_eng = nil
			end
			if p.shield_banner_epl ~= nil then
				p:removeCustom(p.shield_banner_epl)
				p.shield_banner_epl = nil
			end
		end
	else
		if p.shield_banner_eng ~= nil then
			p:removeCustom(p.shield_banner_eng)
			p.shield_banner_eng = nil
		end
		if p.shield_banner_epl ~= nil then
			p:removeCustom(p.shield_banner_epl)
			p.shield_banner_epl = nil
		end		
	end
end
function updatePlayerWaypointDistanceButtonUtility(p)
	if p:getWaypointCount() > 0 then
		if p.way_distance_button_hlm == nil then
			if p.way_dist then
				p.way_distance_button_hlm = "way_distance_button_hlm"
				p:addCustomButton("Helms",p.way_distance_button_hlm,_("buttonHelm","Waypoint Distance"),function()
					string.format("")
					waypointDistanceUtility(p,"Helms")
				end,15)
				p.way_distance_button_tac = "way_distance_button_tac"
				p:addCustomButton("Tactical",p.way_distance_button_tac,_("buttonTactical","Waypoint Distance"),function()
					string.format("")
					waypointDistanceUtility(p,"Tactical")
				end,15)
			end
		end
	else
		if p.way_distance_button_hlm ~= nil then
			p:removeCustom(p.way_distance_button_hlm)
			p:removeCustom(p.way_distance_button_tac)
			p.way_distance_button_hlm = nil
			p.way_distance_button_tac = nil
		end
	end
end
function waypointDistanceUtility(p,console)
	if p:getWaypointCount() > 0 then
		local seq = _("msgHelms","Waypoint distance sequence report:")
		local node = _("msgHelms","Waypoint distance node report:")
		local prev_x = nil
		local prev_y = nil
		for i=1,p:getWaypointCount() do
			local wx, wy = p:getWaypoint(i)
			local px, py = p:getPosition()
			if prev_x == nil then
				seq = string.format(_("msgHelms","%s\n    From current to waypoint %i: %.1f Units"),seq,i,distance(px,py,wx,wy)/1000)
			else
				seq = string.format(_("msgHelms","%s\n    From waypoint %i to waypoint %i: %.1f Units"),seq,i-1,i,distance(prev_x,prev_y,wx,wy)/1000)
			end
			node = string.format(_("msgHelms","%s\n    To waypoint %i: %.1f Units (Bearing: %.1f)"),node,i,distance(px,py,wx,wy)/1000,angleFromVectorNorth(wx,wy,px,py))
			prev_x = wx
			prev_y = wy
		end
		p.waypoint_distance_msg = string.format("waypoint_distance_message_%s",console)
		p:addCustomMessage(console,p.waypoint_distance_msg,string.format("%s\n%s",node,seq))
	end
end
function updatePlayerProximityScanUtility(p)
	if p.prox_scan ~= nil and p.prox_scan > 0 then
		local obj_list = p:getObjectsInRange(p.prox_scan*1000)
		if obj_list ~= nil and #obj_list > 0 then
			for _, obj in ipairs(obj_list) do
				if obj:isValid() and obj.typeName == "CpuShip" and not obj:isFullyScannedBy(p) then
					obj:setScanState("simplescan")
				end
			end
		end
	end
end
function updatePlayerMaxHealthWidgetsUtility(p)
	if system_list == nil then
		initializeSystemList()
	end
	if pretty_short_system == nil then
		initializePrettySystems()
	end
	local function removeWidgets(p)
		if p.hide_max_health_button_eng ~= nil then
			p:removeCustom(p.hide_max_health_button_eng)
			p.hide_max_health_button_eng = nil
		end
		if p.hide_max_health_button_epl ~= nil then
			p:removeCustom(p.hide_max_health_button_epl)
			p.hide_max_health_button_epl = nil
		end
		if p.show_max_health_button_eng ~= nil then
			p:removeCustom(p.show_max_health_button_eng)
			p.show_max_health_button_eng = nil
		end
		if p.show_max_health_button_epl ~= nil then
			p:removeCustom(p.show_max_health_button_epl)
			p.show_max_health_button_epl = nil
		end
		if p.max_health_info_eng ~= nil then
			for i,banner in ipairs(p.max_health_info_eng) do
				p:removeCustom(banner)
			end
			p.max_health_info_eng = {}
		end
		if p.max_health_info_epl ~= nil then
			for i,banner in ipairs(p.max_health_info_epl) do
				p:removeCustom(banner)
			end
			p.max_health_info_epl = {}
		end
	end
	if p.max_health_widgets then
		local damaged_systems = {}
		if p.show_max_health_banners == nil then
			p.show_max_health_banners = false
		end
		for i,system in ipairs(system_list) do
			if p:hasSystem(system) then
				if p:getSystemHealthMax(system) < 1 then
					table.insert(damaged_systems,{name=system,max=p:getSystemHealthMax(system)})
				end
			end
		end
		if #damaged_systems > 0 then
			if p.show_max_health_banners then
				if p.hide_max_health_button_eng == nil then
					p.hide_max_health_button_eng = "hide_max_health_button_eng"
					p:addCustomButton("Engineering",p.hide_max_health_button_eng,_("buttonEngineer","Hide max health"),function()
						p:removeCustom(p.hide_max_health_button_eng)
						p.hide_max_health_button_eng = nil
						p.show_max_health_banners = false
						if p.max_health_info_eng ~= nil then
							for i,banner in ipairs(p.max_health_info_eng) do
								p:removeCustom(banner)
							end
							p.max_health_info_eng = {}
						end
					end,70)
				end
				if p.hide_max_health_button_epl == nil then
					p.hide_max_health_button_epl = "hide_max_health_button_epl"
					p:addCustomButton("Engineering+",p.hide_max_health_button_epl,_("buttonEngineer+","Hide max health"),function()
						p:removeCustom(p.hide_max_health_button_epl)
						p.hide_max_health_button_epl = nil
						p.show_max_health_banners = false
						if p.max_health_info_epl ~= nil then
							for i,banner in ipairs(p.max_health_info_epl) do
								p:removeCustom(banner)
							end
							p.max_health_info_epl = {}
						end
					end,70)
				end
				local max_out = ""
				if p.max_health_info_eng == nil then
					p.max_health_info_eng = {}
					p.max_health_info_epl = {}
				end
				local info_banner_count = 0
				for i,dmg in ipairs(damaged_systems) do
					if max_out == "" then
						max_out = string.format("%s:%i%%",pretty_short_system[dmg.name],math.floor(dmg.max*100))
					else
						max_out = string.format("%s %s:%i%%",max_out,pretty_short_system[dmg.name],math.floor(dmg.max*100))
						info_banner_count = info_banner_count + 1
						p.max_health_info_eng[info_banner_count] = string.format("max_health_info_eng_%i",info_banner_count)
						p:addCustomInfo("Engineering",p.max_health_info_eng[info_banner_count],max_out,70 + info_banner_count)
						p.max_health_info_epl[info_banner_count] = string.format("max_health_info_epl_%i",info_banner_count)
						p:addCustomInfo("Engineering+",p.max_health_info_epl[info_banner_count],max_out,70 + info_banner_count)
						max_out = ""
					end
				end
				if max_out ~= "" then
					info_banner_count = info_banner_count + 1
					p.max_health_info_eng[info_banner_count] = string.format("max_health_info_eng_%i",info_banner_count)
					p:addCustomInfo("Engineering",p.max_health_info_eng[info_banner_count],max_out,70 + info_banner_count)
					p.max_health_info_epl[info_banner_count] = string.format("max_health_info_epl_%i",info_banner_count)
					p:addCustomInfo("Engineering+",p.max_health_info_epl[info_banner_count],max_out,70 + info_banner_count)
				end
				if p.max_health_info_eng[info_banner_count + 1] ~= nil then
					p:removeCustom(p.max_health_info_eng[info_banner_count + 1])
					p.max_health_info_eng[info_banner_count + 1] = nil
					p:removeCustom(p.max_health_info_epl[info_banner_count + 1])
					p.max_health_info_epl[info_banner_count + 1] = nil
				end
			else
				if p.show_max_health_button_eng == nil then
					p.show_max_health_button_eng = "show_max_health_button_eng"
					p:addCustomButton("Engineering",p.show_max_health_button_eng,_("buttonEngineer","Show max health"),function()
						p:removeCustom(p.show_max_health_button_eng)
						p.show_max_health_button_eng = nil
						p.show_max_health_banners = true
					end,70)
				end
				if p.show_max_health_button_epl == nil then
					p.show_max_health_button_epl = "show_max_health_button_epl"
					p:addCustomButton("Engineering+",p.show_max_health_button_epl,_("buttonEngineer+","Show max health"),function()
						p:removeCustom(p.show_max_health_button_epl)
						p.show_max_health_button_epl = nil
						p.show_max_health_banners = true
					end,70)
				end
			end
		else
			removeWidgets(p)
		end
	else
		removeWidgets(p)
	end
end
function updatePlayerLongRangeSensorsUtility(delta,p)
	--	handle any sensor boost a station might provide while docked
	local sensor_station = p:getDockedWith()
	if p.station_sensor_boost == nil then
		if sensor_station ~= nil and sensor_station:isValid() then
			if sensor_station.comms_data ~= nil and sensor_station.comms_data.sensor_boost ~= nil then
				if sensor_station.comms_data.sensor_boost.cost ~= nil and sensor_station.comms_data.sensor_boost.cost < 1 then
					if sensor_station.comms_data.sensor_boost.value ~= nil then
						p.station_sensor_boost = sensor_station.comms_data.sensor_boost.value
					end
				end
			end
		end
	end
	if p.normal_long_range_radar == nil then
		p.normal_long_range_radar = p:getLongRangeRadarRange()
	end
	local base_range = p.normal_long_range_radar
	if p.station_sensor_boost ~= nil then
		base_range = base_range + p.station_sensor_boost
	end
	if p:getDockedWith() == nil then
		base_range = p.normal_long_range_radar
		p.station_sensor_boost = nil
	end
	--	handle any player ship powered sensor boost
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
			p:setEnergyLevel(p:getEnergyLevel() - power_decrement)
		end
	else
		if p.power_sensor_state ~= nil then
			p.power_sensor_state = "disabled"
			updatePowerSensorButtons(p)
		end
	end
	local impact_range = math.max(base_range,p:getShortRangeRadarRange())
	--	handle any sensor jammer sensor range impact
	local sensor_jammer_impact = 0
	if sensor_jammer_list ~= nil then
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
	end
	impact_range = math.max(p:getShortRangeRadarRange(),impact_range - sensor_jammer_impact)
	--	handle any sensor boost from a specialized probe with sensor boost
	local probe_scan_boost_impact = 0
	if boost_probe_list ~= nil then
		for boost_probe_index, boost_probe in ipairs(boost_probe_list) do
			if boost_probe ~= nil and boost_probe:isValid() then
				local boost_probe_distance = distance(boost_probe,p)
				if boost_probe_distance < boost_probe.range*1000 then
					if boost_probe_distance < boost_probe.range*1000/2 then
						probe_scan_boost_impact = math.max(probe_scan_boost_impact,boost_probe.boost*1000)
					else
						local best_boost = boost_probe.boost*1000
						local adjusted_range = boost_probe.range*1000
						local half_adjusted_range = adjusted_range/2
						local raw_scan_gradient = boost_probe_distance/half_adjusted_range
						local scan_gradient = 2 - raw_scan_gradient
						probe_scan_boost_impact = math.max(probe_scan_boost_impact,best_boost * scan_gradient)
					end
				end
			else
				boost_probe_list[boost_probe_index] = boost_probe_list[#boost_probe_list]
				boost_probe_list[#boost_probe_list] = nil
				break
			end
		end
	end
	impact_range = math.max(p:getShortRangeRadarRange(),impact_range + probe_scan_boost_impact)
	--	apply the results
	p:setLongRangeRadarRange(impact_range)
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
function powerSensorEnabledButtons(p)
	p.power_sensor_state = "enabled"
	updatePowerSensorButtons(p)
end
function powerSensorStandbyButtons(p)
	p.power_sensor_state = "standby"
	updatePowerSensorButtons(p)
end
function powerSensorConfigButtons(p)
	p.power_sensor_state = "configure"
	updatePowerSensorButtons(p)
end