--------	Spawn ships scenario utility
--	This utility adds a set of buttons to the GM screen allowing for the spawning of 
--	various ships. Originally designed to provide a mechanism to spawn ships of roughly
--	the same capability as the player ship or ships, it has been added to over time in 
--	the sandbox to include features such as a changing ratio of capability vs player
--	ships, filtering the ships by certain criteria, ship formations, etc.
--
--	In addition to requiring this file, you will need to add a line to call these buttons:
--		addGMFunction("+Spawn Ship(s)",spawnGMShips)
--	Further, you should put this call line in function mainGMButtons that can be returned to:
--		function mainGMButtons()
--			clearGMFunctions()
--			addGMFunction("+Spawn Ship(s)",spawnGMShips)
--		end
--
--	The plus sign at the start of the button label indicates that another set of 
--	buttons comes up when clicking the button. Similarly, the minus sign at the start of 
--	the button label indicates that the GM will return to a previous set of buttons when
--	clicking the button.
--
--	Version 1.2
require("utils.lua")
require("cpu_ship_diversification_scenario_utility.lua")
require("generate_call_sign_scenario_utility.lua")
function spawnGMShips()
	setSpawnShipGlobals()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main From Spawn Ships"),mainGMButtons)
	addGMFunction(_("buttonGM","+Spawn Fleet"),spawnGMFleet)
	addGMFunction(_("buttonGM","+Spawn a ship"),spawnGMShip)
	local object_list = getGMSelection()
	if #object_list == 1 then
		temp_carrier = object_list[1]
		if isObjectType(temp_carrier,"CpuShip") then
			addGMFunction(_("buttonGM","+Spawn Fighter Wing"),setFighterWing)
		end
	end
end
function setSpawnShipGlobals()
	if spawn_ship_globals == nil then
		spawn_ship_globals = "set"
		if fleetSpawnFaction == nil then
			fleetSpawnFaction = "Exuari"
		end
		if fleet_spawn_type == nil then
			fleet_spawn_type = "relative"
		end
		if fleetStrengthByPlayerStrength == nil then
			fleetStrengthByPlayerStrength = 1
		end
		if fleetStrengthFixedValue == nil then
			fleetStrengthFixedValue = 250
		end
		if fleet_exclusions == nil then
			fleet_exclusions = {
				["Nuke"]	= {letter = "N", exclude = false},
				["Warp"]	= {letter = "W", exclude = false},
				["Jump"]	= {letter = "J", exclude = false},
				["Unusual"]	= {letter = "U", exclude = true},
			}
		end
		if fleetComposition == nil then
			fleetComposition = "Random"
			fleet_composition_labels = {
				["Random"] = _("buttonGM","Random"),
				["Fighters"] = _("buttonGM","Fighters"),
				["Chasers"] = _("buttonGM","Chasers"),
				["Frigates"] = _("buttonGM","Frigates"),
				["Beamers"] = _("buttonGM","Beamers"),
				["Missilers"] = _("buttonGM","Missilers"),
				["Adders"] = _("buttonGM","Adders"),
				["Non-DB"] = _("buttonGM","Non-DB"),
				["Drones"] = _("buttonGM","Drones"),
			}
		end
		if fleetChange == nil then
			fleetChange = "unmodified"
			fleet_change_labels = {
				["unmodified"] = _("buttonGM","Unmodified"),
				["improved"] = _("buttonGM","Improved"),
				["degraded"] = _("buttonGM","Degraded"),
				["tinkered"] = _("buttonGM","Tinkered"),
			}
		end
		if fleetChangeChance == nil then
			fleetChangeChance = 20
		end
		if fleetOrders == nil then
			fleetOrders = "Stand Ground"
			fleet_order_labels = {
				["Stand Ground"] = _("buttonGM","Stand Ground"),
				["Roaming"] = _("buttonGM","Roaming"),
				["Idle"] = _("buttonGM","Idle"),
			}
		end
		if fleetSpawnLocation == nil then
			fleetSpawnLocation = "At Click"
			fleet_spawn_location_labels = {
				["At Click"] = _("buttonGM","At Click"),
				["Ambush"] = _("buttonGM","Ambush"),
			}
		end
		if fleetAmbushDistance == nil then
			fleetAmbushDistance = 5
		end
		if pool_selectivity == nil then
			pool_selectivity = "full"
			pool_selectivity_labels = {
				["full"] = _("buttonGM","full"),
				["less/heavy"] = _("buttonGM","less/heavy"),
				["more/light"] = _("buttonGM","more/light"),
			}
		end
		if template_pool_size == nil then
			template_pool_size = 5
		end
		if formation_delta == nil then
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
		end
		if fleet_group == nil then
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
		end
		local spawn_utility_ship_template = {
			-- unarmed
			["Courier"] =			{strength = 1,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = true,		base = false,	short_range_radar = 8000,	hop_angle = 0,	hop_range = 1000,	dist = 600,	create = courier},
			["Laden Lorry"] =		{strength = 1,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = true,		base = false,	short_range_radar = 4000,	hop_angle = 0,	hop_range = 1000,	dist = 600,	create = ladenLorry},
			["Omnibus"] =			{strength = 1,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = true,		base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 1000,	dist = 600,	create = omnibus},
			["Physics Research"] =	{strength = 1,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = true,		base = false,	short_range_radar = 6500,	hop_angle = 0,	hop_range = 1000,	dist = 600,	create = physicsResearch},
			["Service Jonque"] =	{strength = 1,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = true,		base = false,	short_range_radar = 4500,	hop_angle = 0,	hop_range = 1000,	dist = 800,	create = serviceJonque},
			["Space Sedan"] =		{strength = 1,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = true,		base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1000,	dist = 600,	create = spaceSedan},
			["Work Wagon"] =		{strength = 1,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = true,		base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 1000,	dist = 600,	create = workWagon},
			-- normal ships that are part of the fleet spawn process
			["Gnat"] =				{strength = 2,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true,		drone = true,	unusual = false,	base = false,	short_range_radar = 4500,	hop_angle = 0,	hop_range = 580,	dist = 300,	create = gnat},
			["Lite Drone"] =		{strength = 3,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = true,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	dist = 300,	create = droneLite},
			["Jacket Drone"] =		{strength = 4,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = true,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	dist = 300,	create = droneJacket},
			["Ktlitan Drone"] =		{strength = 4,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = true,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	dist = 300,	create = stockTemplate},
			["Heavy Drone"] =		{strength = 5,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = true,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 580,	dist = 300,	create = droneHeavy},
			["Adder MK3"] =			{strength = 5,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	dist = 100,	create = stockTemplate},
			["MT52 Hornet"] =		{strength = 5,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 680,	dist = 100,	create = stockTemplate},
			["MU52 Hornet"] =		{strength = 5,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 880,	dist = 100,	create = stockTemplate},
			["Dagger"] =			{strength = 6,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	dist = 100,	create = stockTemplate},
			["MV52 Hornet"] =		{strength = 6,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	dist = 100,	create = hornetMV52},
			["MT55 Hornet"] =		{strength = 6,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 680,	dist = 100,	create = hornetMT55},
			["Adder MK4"] =			{strength = 6,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	dist = 100,	create = stockTemplate},
			["Fighter"] =			{strength = 6,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	dist = 100,	create = stockTemplate},
			["Ktlitan Fighter"] =	{strength = 6,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	dist = 300,	create = stockTemplate},
			["Shepherd"] =			{strength = 6,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 2880,	dist = 100,	create = shepherd},
			["Touchy"] =			{strength = 7,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 2000,	dist = 100,	create = touchy},
			["FX64 Hornet"] =		{strength = 7,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = true,		drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1480,	dist = 100,	create = hornetFX64},
			["Blade"] =				{strength = 7,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	dist = 300,	create = stockTemplate},
			["Gunner"] =			{strength = 7,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	dist = 100,	create = stockTemplate},
			["K2 Fighter"] =		{strength = 7,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	dist = 300,	create = k2fighter},
			["Adder MK5"] =			{strength = 7,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	dist = 100,	create = stockTemplate},
			["WX-Lindworm"] =		{strength = 7,	adder = false,	missiler = true,	beamer = false,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 2500,	dist = 100,	create = stockTemplate},
			["K3 Fighter"] =		{strength = 8,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	dist = 300,	create = k3fighter},
			["Shooter"] =			{strength = 8,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	dist = 100,	create = stockTemplate},
			["Jagger"] =			{strength = 8,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	dist = 100,	create = stockTemplate},
			["Adder MK6"] =			{strength = 8,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	dist = 100,	create = stockTemplate},
			["Ktlitan Scout"] =		{strength = 8,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 7000,	hop_angle = 0,	hop_range = 580,	dist = 300,	create = stockTemplate},
			["WZ-Lindworm"] =		{strength = 9,	adder = false,	missiler = true,	beamer = false,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 2500,	dist = 100,	create = wzLindworm},
			["Adder MK7"] =			{strength = 9,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	dist = 100,	create = stockTemplate},
			["Adder MK8"] =			{strength = 10,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 580,	dist = 100,	create = stockTemplate},
			["Adder MK9"] =			{strength = 11,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 580,	dist = 100,	create = stockTemplate},
			["Nirvana R3"] =		{strength = 12,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	dist = 200,	create = stockTemplate},
			["Phobos R2"] =			{strength = 13,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	dist = 200,	create = phobosR2},
			["Missile Cruiser"] =	{strength = 14,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 7000,	hop_angle = 0,	hop_range = 2500,	dist = 200,	create = stockTemplate},
			["Waddle 5"] =			{strength = 15,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	dist = 100,	create = waddle5},
			["Jade 5"] =			{strength = 15,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	dist = 100,	create = jade5},
			["Phobos T3"] =			{strength = 15,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	dist = 200,	create = stockTemplate},
			["Guard"] =				{strength = 15,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	dist = 600,	create = stockTemplate},
			["Piranha F8"] =		{strength = 15,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 90,	hop_range = 2500,	dist = 200,	create = stockTemplate},
			["Piranha F12"] =		{strength = 15,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 90,	hop_range = 2500,	dist = 200,	create = stockTemplate},
			["Piranha F12.M"] =		{strength = 16,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 90,	hop_range = 2500,	dist = 200,	create = stockTemplate},
			["Phobos M3"] =			{strength = 16,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 1180,	dist = 200,	create = stockTemplate},
			["Farco 3"] =			{strength = 16,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 8000,	hop_angle = 0,	hop_range = 1480,	dist = 200,	create = farco3},
			["Farco 5"] =			{strength = 16,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 8000,	hop_angle = 0,	hop_range = 1180,	dist = 200,	create = farco5},
			["Karnack"] =			{strength = 17,	adder = false,	missiler = false,	beamer = true,	frigate = true,		chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	dist = 200,	create = stockTemplate},
			["Gunship"] =			{strength = 17,	adder = false,	missiler = false,	beamer = false,	frigate = true,		chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	dist = 400,	create = stockTemplate},
			["Phobos T4"] =			{strength = 18,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1480,	dist = 200,	create = phobosT4},
			["Cruiser"] =			{strength = 18,	adder = true,	missiler = false,	beamer = true,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 980,	dist = 200,	create = stockTemplate},
			["Nirvana R5"] =		{strength = 19,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	dist = 200,	create = stockTemplate},
			["Farco 8"] =			{strength = 19,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 8000,	hop_angle = 0,	hop_range = 1480,	dist = 200,	create = farco8},
			["Nirvana R5A"] =		{strength = 20,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	dist = 200,	create = stockTemplate},
			["Adv. Gunship"] =		{strength = 20,	adder = false,	missiler = false,	beamer = false,	frigate = true,		chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 7000,	hop_angle = 0,	hop_range = 980,	dist = 400,	create = stockTemplate},
			["Ktlitan Worker"] =	{strength = 20,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 90,	hop_range = 580,	dist = 300,	create = stockTemplate},
			["Farco 11"] =			{strength = 21,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 8000,	hop_angle = 0,	hop_range = 1480,	dist = 200,	create = farco11},
			["Stalker R5"] =		{strength = 22,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	dist = 200,	create = stockTemplate},
			["Stalker Q5"] =		{strength = 22,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	dist = 200,	create = stockTemplate},
			["Storm"] =				{strength = 22,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 1180,	dist = 200,	create = stockTemplate},
			["Warden"] =			{strength = 22,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 1180,	dist = 600,	create = stockTemplate},
			["Racer"] =				{strength = 22,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	dist = 200,	create = stockTemplate},
			["Strike"] =			{strength = 23,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 980,	dist = 200,	create = stockTemplate},
			["Dash"] =				{strength = 23,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 980,	dist = 200,	create = stockTemplate},
			["Farco 13"] =			{strength = 24,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1480,	dist = 200,	create = farco13},
			["Sentinel"] =			{strength = 24,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	dist = 600,	create = stockTemplate},
			["Ranus U"] =			{strength = 25,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 2500,	dist = 200,	create = stockTemplate},
			["Flash"] =				{strength = 25,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 2500,	dist = 100,	create = stockTemplate},
			["Ranger"] =			{strength = 25,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 2500,	dist = 100,	create = stockTemplate},
			["Buster"] =			{strength = 25,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 2500,	dist = 100,	create = stockTemplate},
			["Stalker Q7"] =		{strength = 25,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	dist = 200,	create = stockTemplate},
			["Stalker R7"] =		{strength = 25,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	dist = 200,	create = stockTemplate},
			["Whirlwind"] =			{strength = 26,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 90,	hop_range = 2500,	dist = 200,	create = whirlwind},
			["Hunter"] =			{strength = 26,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 980,	dist = 200,	create = stockTemplate},
			["Adv. Striker"] =		{strength = 27,	adder = false,	missiler = false,	beamer = true,	frigate = true,		chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	dist = 300,	create = stockTemplate},
			["Tempest"] =			{strength = 30,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 90,	hop_range = 2500,	dist = 200,	create = tempest},
			["Strikeship"] =		{strength = 30,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	dist = 200,	create = stockTemplate},
			["Fiend G3"] =			{strength = 33,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6500,	hop_angle = 0,	hop_range = 980,	dist = 400,	create = stockTemplate},
			["Maniapak"] =			{strength = 34,	adder = true,	missiler = false,	beamer = false,	frigate = false, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 580,	dist = 100,	create = maniapak},
			["Fiend G4"] =			{strength = 35,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6500,	hop_angle = 0,	hop_range = 980,	dist = 400,	create = stockTemplate},
			["Cucaracha"] =			{strength = 36,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1480,	dist = 200,	create = cucaracha},
			["Fiend G5"] =			{strength = 37,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6500,	hop_angle = 0,	hop_range = 980,	dist = 400,	create = stockTemplate},
			["Fiend G6"] =			{strength = 39,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6500,	hop_angle = 0,	hop_range = 980,	dist = 400,	create = stockTemplate},
			["Barracuda"] =			{strength = 40,	adder = false,	missiler = false,	beamer = false,	frigate = true,		chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 1180,	dist = 200,	create = barracuda},
			["Ryder"] =				{strength = 41, adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 8000,	hop_angle = 90,	hop_range = 1180,	dist = 2000,create = stockTemplate},
			["Predator"] =			{strength = 42,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 7500,	hop_angle = 0,	hop_range = 980,	dist = 200,	create = predator},
			["Ktlitan Breaker"] =	{strength = 45,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 780,	dist = 300,	create = stockTemplate},
			["Hurricane"] =			{strength = 46,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 15,	hop_range = 2500,	dist = 200,	create = hurricane},
			["Ktlitan Feeder"] =	{strength = 48,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	dist = 300,	create = stockTemplate},
			["Atlantis X23"] =		{strength = 50,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 10000,	hop_angle = 0,	hop_range = 1480,	dist = 400,	create = stockTemplate},
			["Ktlitan Destroyer"] =	{strength = 50,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 9000,	hop_angle = 0,	hop_range = 980,	dist = 500,	create = stockTemplate},
			["K2 Breaker"] =		{strength = 55,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 780,	dist = 300,	create = k2breaker},
			["Atlantis Y42"] =		{strength = 60,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 10000,	hop_angle = 0,	hop_range = 1480,	dist = 400,	create = atlantisY42},
			["Blockade Runner"] =	{strength = 63,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 980,	dist = 400,	create = stockTemplate},
			["Starhammer II"] =		{strength = 70,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 10000,	hop_angle = 0,	hop_range = 1480,	dist = 400,	create = stockTemplate},
			["Enforcer"] =			{strength = 75,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 9000,	hop_angle = 0,	hop_range = 1480,	dist = 400,	create = enforcer},
			["Dreadnought"] =		{strength = 80,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 9000,	hop_angle = 0,	hop_range = 980,	dist = 400,	create = stockTemplate},
			["Starhammer III"] =	{strength = 85,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 12000,	hop_angle = 0,	hop_range = 1480,	dist = 400,	create = starhammerIII},
			["Starhammer V"] =		{strength = 90,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 15000,	hop_angle = 0,	hop_range = 1480,	dist = 400,	create = starhammerV},
			["Battlestation"] =		{strength = 100,adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 9000,	hop_angle = 90,	hop_range = 2480,	dist = 2000,create = stockTemplate},
			["Fortress"] =			{strength = 130,adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 9000,	hop_angle = 90,	hop_range = 2380,	dist = 2000,create = stockTemplate},
			["Tyr"] =				{strength = 150,adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 9500,	hop_angle = 90,	hop_range = 2480,	dist = 2000,create = tyr},
			["Odin"] =				{strength = 250,adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 20000,	hop_angle = 0,	hop_range = 3180,	dist = 1500,create = stockTemplate},
		}		
		if ship_template == nil then
			ship_template = {}
			for ship,details in pairs(spawn_utility_ship_template) do
				ship_template[ship] = details
			end
		else
			for ship,details in pairs(ship_template) do
				if details.adder == nil then
					if spawn_utility_ship_template[ship] ~= nil then
						details.adder = spawn_utility_ship_template[ship].adder
					else
						details.adder = false
					end
				end
				if details.missiler == nil then
					if spawn_utility_ship_template[ship] ~= nil then
						details.missiler = spawn_utility_ship_template[ship].missiler
					else
						details.missiler = false
					end
				end
				if details.beamer == nil then
					if spawn_utility_ship_template[ship] ~= nil then
						details.beamer = spawn_utility_ship_template[ship].beamer
					else
						details.beamer = false
					end
				end
				if details.frigate == nil then
					if spawn_utility_ship_template[ship] ~= nil then
						details.frigate = spawn_utility_ship_template[ship].frigate
					else
						details.frigate = false
					end
				end
				if details.chaser == nil then
					if spawn_utility_ship_template[ship] ~= nil then
						details.chaser = spawn_utility_ship_template[ship].chaser
					else
						details.chaser = false
					end
				end
				if details.fighter == nil then
					if spawn_utility_ship_template[ship] ~= nil then
						details.fighter = spawn_utility_ship_template[ship].fighter
					else
						details.fighter = false
					end
				end
				if details.drone == nil then
					if spawn_utility_ship_template[ship] ~= nil then
						details.drone = spawn_utility_ship_template[ship].drone
					else
						details.drone = false
					end
				end
				if details.dist == nil then
					if spawn_utility_ship_template[ship] ~= nil then
						details.dist = spawn_utility_ship_template[ship].dist
					else
						details.dist = 400
					end
				end
			end
		end
		if individual_ship == nil then
			for ship,details in pairs(ship_template) do
				if details.create ~= stockTemplate then
					individual_ship = ship
					break
				end
			end
		end
		--	formation globals
		if formation_shape == nil then
			formation_shape = "V"
		end
		if prebuilt_leader == nil then
			prebuilt_leader = "Nirvana R5"	--default
		end
		local spawn_utility_prebuilt_leaders = {		
									--130			140		120			125				120		140					140			140			150				100				70			70				45
			["Cucaracha"] =			{"Lite Drone","Gnat","MT52 Hornet","MU52 Hornet","Fighter","Ktlitan Fighter","K2 Fighter","K3 Fighter","Ktlitan Scout"},
			["Dreadnought"] =		{"Lite Drone","Gnat","MT52 Hornet","MU52 Hornet","Fighter","Ktlitan Fighter","K2 Fighter","K3 Fighter","Ktlitan Scout","Cucaracha","Nirvana R5","Nirvana R5A","Equipment Freighter 3"},
			["Dread No More"] =		{"Lite Drone","Gnat","MT52 Hornet","MU52 Hornet","Fighter","Ktlitan Fighter","K2 Fighter","K3 Fighter","Ktlitan Scout","Cucaracha","Nirvana R5","Nirvana R5A"},
			["MT52 Hornet"] =		{"Lite Drone","Gnat","MU52 Hornet",																	   "Ktlitan Scout"},
			["Heavy Drone"] =		{"Lite Drone","Gnat","MU52 Hornet",																	   "Ktlitan Scout"},
			["Nirvana R3"] =		{"Lite Drone","Gnat","MT52 Hornet","MU52 Hornet","Fighter","Ktlitan Fighter","K2 Fighter","K3 Fighter","Ktlitan Scout","Cucaracha"},
			["Nirvana R5"] =		{"Lite Drone","Gnat","MT52 Hornet","MU52 Hornet","Fighter","Ktlitan Fighter","K2 Fighter","K3 Fighter","Ktlitan Scout","Cucaracha"},
			["Nirvana R5A"] =		{"Lite Drone","Gnat","MT52 Hornet","MU52 Hornet","Fighter","Ktlitan Fighter","K2 Fighter","K3 Fighter","Ktlitan Scout","Cucaracha"},
			["Blockade Runner"] =	{"Lite Drone","Gnat","MT52 Hornet","MU52 Hornet","Fighter","Ktlitan Fighter","K2 Fighter","K3 Fighter","Ktlitan Scout","Cucaracha","Nirvana R5","Nirvana R5A"},
			["Supervisor"] =		{"Lite Drone","Gnat","MT52 Hornet","MU52 Hornet","Fighter","Ktlitan Fighter","K2 Fighter","K3 Fighter","Ktlitan Scout","Cucaracha","Nirvana R5","Nirvana R5A"},
			["Sentinel"] =			{"Lite Drone","Gnat","MT52 Hornet","MU52 Hornet","Fighter","Ktlitan Fighter","K2 Fighter","K3 Fighter","Ktlitan Scout","Cucaracha"},
			["Strongarm"] =			{"Lite Drone","Gnat","MT52 Hornet","MU52 Hornet","Fighter","Ktlitan Fighter","K2 Fighter","K3 Fighter","Ktlitan Scout","Cucaracha"},
			["Phobos T3"] =			{"Lite Drone","Gnat","MT52 Hornet","MU52 Hornet","Fighter","Ktlitan Fighter","K2 Fighter","K3 Fighter","Ktlitan Scout","Cucaracha","Nirvana R5","Nirvana R5A"},
			["Phobos T4"] =			{"Lite Drone","Gnat","MT52 Hornet","MU52 Hornet","Fighter","Ktlitan Fighter","K2 Fighter","K3 Fighter","Ktlitan Scout","Cucaracha","Nirvana R5","Nirvana R5A"},
			["Phobos R2"] =			{"Lite Drone","Gnat","MT52 Hornet","MU52 Hornet","Fighter","Ktlitan Fighter","K2 Fighter","K3 Fighter","Ktlitan Scout","Cucaracha","Nirvana R5","Nirvana R5A"},
			["Farco 3"] =			{"Lite Drone","Gnat","MT52 Hornet","MU52 Hornet","Fighter","Ktlitan Fighter","K2 Fighter","K3 Fighter","Ktlitan Scout","Cucaracha","Nirvana R5","Nirvana R5A"},
			["Farco 5"] =			{"Lite Drone","Gnat","MT52 Hornet","MU52 Hornet","Fighter","Ktlitan Fighter","K2 Fighter","K3 Fighter","Ktlitan Scout","Cucaracha","Nirvana R5","Nirvana R5A"},
			["Farco 8"] =			{"Lite Drone","Gnat","MT52 Hornet","MU52 Hornet","Fighter","Ktlitan Fighter","K2 Fighter","K3 Fighter","Ktlitan Scout","Cucaracha","Nirvana R5","Nirvana R5A"},
			["Farco 11"] =			{"Lite Drone","Gnat","MT52 Hornet","MU52 Hornet","Fighter","Ktlitan Fighter","K2 Fighter","K3 Fighter","Ktlitan Scout","Cucaracha","Nirvana R5","Nirvana R5A"},
			["Farco 13"] =			{"Lite Drone","Gnat","MT52 Hornet","MU52 Hornet","Fighter","Ktlitan Fighter","K2 Fighter","K3 Fighter","Ktlitan Scout","Cucaracha","Nirvana R5","Nirvana R5A"},
			["Gunship"] =			{"Lite Drone","Gnat","MT52 Hornet","MU52 Hornet","Fighter","Ktlitan Fighter","K2 Fighter","K3 Fighter","Ktlitan Scout","Cucaracha","Nirvana R5","Nirvana R5A"},
			["Adv. Gunship"] =		{"Lite Drone","Gnat","MT52 Hornet","MU52 Hornet","Fighter","Ktlitan Fighter","K2 Fighter","K3 Fighter","Ktlitan Scout","Cucaracha","Nirvana R5","Nirvana R5A"},
			["Adder MK4"] =			{"Lite Drone","Gnat","MT52 Hornet","MU52 Hornet","Fighter","Ktlitan Fighter","K2 Fighter","K3 Fighter","Ktlitan Scout","Cucaracha",							 "Nirvana R5","Nirvana R5A"},
			["Adder MK5"] =			{"Lite Drone","Gnat","MT52 Hornet","MU52 Hornet","Fighter","Ktlitan Fighter","K2 Fighter","K3 Fighter","Ktlitan Scout","Cucaracha"},
			["Adder MK6"] =			{"Lite Drone","Gnat","MT52 Hornet","MU52 Hornet","Fighter","Ktlitan Fighter","K2 Fighter","K3 Fighter","Ktlitan Scout","Cucaracha"},
			["Adder MK7"] =			{"Lite Drone","Gnat","MT52 Hornet","MU52 Hornet","Fighter","Ktlitan Fighter","K2 Fighter","K3 Fighter","Ktlitan Scout","Cucaracha"},
		}
		if prebuilt_leaders == nil then
			prebuilt_leaders = {}
			for template,details in pairs(spawn_utility_prebuilt_leaders) do
				if ship_template[template] ~= nil then
					local followers = {}
					for i,follower in ipairs(details) do
						if ship_template[follower] ~= nil then
							table.insert(followers,follower)
						end
					end
					if #followers > 0 then
						prebuilt_leaders[template] = followers
					end
				end
			end
		end
		if prebuilt_follower == nil then
			prebuilt_follower = "MT52 Hornet"	--default
		end
		local spawn_utility_prebuilt_followers = {
										--100			30				65			60					60				70			70			50				75			70				60			60		60			60			60			60			60				55			60			60				60			80			80			80				120
				["MT52 Hornet"] =		{"Cucaracha", "Dreadnought", "Nirvana R3", "Blockade Runner", "Supervisor", "Sentinel", "Nirvana R5", "Dread No More", "Strongarm", "Nirvana R5A", "Farco 3", "Farco 5", "Farco 8", "Farco 11", "Farco 13", "Phobos T3", "Phobos T4", "Phobos R2", "Gunship", "Adv. Gunship", "Adder MK4", "Adder MK5", "Adder MK6", "Adder MK7",				  "Heavy Drone"},
				["MU52 Hornet"] =		{"Cucaracha", "Dreadnought", "Nirvana R3", "Blockade Runner", "Supervisor", "Sentinel", "Nirvana R5", "Dread No More", "Strongarm", "Nirvana R5A", "Farco 3", "Farco 5", "Farco 8", "Farco 11", "Farco 13", "Phobos T3", "Phobos T4", "Phobos R2", "Gunship", "Adv. Gunship", "Adder MK4", "Adder MK5", "Adder MK6", "Adder MK7", "MT52 Hornet"},
				["Fighter"] =			{"Cucaracha", "Dreadnought", "Nirvana R3", "Blockade Runner", "Supervisor", "Sentinel", "Nirvana R5", "Dread No More", "Strongarm", "Nirvana R5A", "Farco 3", "Farco 5", "Farco 8", "Farco 11", "Farco 13", "Phobos T3", "Phobos T4", "Phobos R2", "Gunship", "Adv. Gunship", "Adder MK4", "Adder MK5", "Adder MK6", "Adder MK7"},
				["Ktlitan Fighter"] =	{"Cucaracha", "Dreadnought", "Nirvana R3", "Blockade Runner", "Supervisor", "Sentinel", "Nirvana R5", "Dread No More", "Strongarm", "Nirvana R5A", "Farco 3", "Farco 5", "Farco 8", "Farco 11", "Farco 13", "Phobos T3", "Phobos T4", "Phobos R2", "Gunship", "Adv. Gunship", "Adder MK4", "Adder MK5", "Adder MK6", "Adder MK7"},
				["K2 Fighter"] =		{"Cucaracha", "Dreadnought", "Nirvana R3", "Blockade Runner", "Supervisor", "Sentinel", "Nirvana R5", "Dread No More", "Strongarm", "Nirvana R5A", "Farco 3", "Farco 5", "Farco 8", "Farco 11", "Farco 13", "Phobos T3", "Phobos T4", "Phobos R2", "Gunship", "Adv. Gunship", "Adder MK4", "Adder MK5", "Adder MK6", "Adder MK7"},
				["K3 Fighter"] =		{"Cucaracha", "Dreadnought", "Nirvana R3", "Blockade Runner", "Supervisor", "Sentinel", "Nirvana R5", "Dread No More", "Strongarm", "Nirvana R5A", "Farco 3", "Farco 5", "Farco 8", "Farco 11", "Farco 13", "Phobos T3", "Phobos T4", "Phobos R2", "Gunship", "Adv. Gunship", "Adder MK4", "Adder MK5", "Adder MK6", "Adder MK7"},
				["Ktlitan Scout"] =		{"Cucaracha", "Dreadnought", "Nirvana R3", "Blockade Runner", "Supervisor", "Sentinel", "Nirvana R5", "Dread No More", "Strongarm", "Nirvana R5A", "Farco 3", "Farco 5", "Farco 8", "Farco 11", "Farco 13", "Phobos T3", "Phobos T4", "Phobos R2", "Gunship", "Adv. Gunship", "Adder MK4", "Adder MK5", "Adder MK6", "Adder MK7", "MT52 Hornet", "Heavy Drone"},
				["Cucaracha"] =			{			  "Dreadnought", "Nirvana R3", "Blockade Runner", "Supervisor", "Sentinel", "Nirvana R5", "Dread No More", "Strongarm", "Nirvana R5A", "Farco 3", "Farco 5", "Farco 8", "Farco 11", "Farco 13", "Phobos T3", "Phobos T4", "Phobos R2", "Gunship", "Adv. Gunship", "Adder MK4", "Adder MK5", "Adder MK6", "Adder MK7"},
				["Gnat"] =				{"Cucaracha", "Dreadnought", "Nirvana R3", "Blockade Runner", "Supervisor", "Sentinel", "Nirvana R5", "Dread No More", "Strongarm", "Nirvana R5A", "Farco 3", "Farco 5", "Farco 8", "Farco 11", "Farco 13", "Phobos T3", "Phobos T4", "Phobos R2", "Gunship", "Adv. Gunship", "Adder MK4", "Adder MK5", "Adder MK6", "Adder MK7", "MT52 Hornet", "Heavy Drone"},
				["Lite Drone"] =		{"Cucaracha", "Dreadnought", "Nirvana R3", "Blockade Runner", "Supervisor", "Sentinel", "Nirvana R5", "Dread No More", "Strongarm", "Nirvana R5A", "Farco 3", "Farco 5", "Farco 8", "Farco 11", "Farco 13", "Phobos T3", "Phobos T4", "Phobos R2", "Gunship", "Adv. Gunship", "Adder MK4", "Adder MK5", "Adder MK6", "Adder MK7", "MT52 Hornet", "Heavy Drone"},
				["Nirvana R5"] =		{			  "Dreadnought", 			   "Blockade Runner", "Supervisor", 						  "Dread No More", 							   "Farco 3", "Farco 5", "Farco 8", "Farco 11", "Farco 13", "Phobos T3", "Phobos T4", "Phobos R2", "Gunship", "Adv. Gunship", "Adder MK4"},
				["Nirvana R5A"] =		{			  "Dreadnought", 			   "Blockade Runner", "Supervisor", 						  "Dread No More", 							   "Farco 3", "Farco 5", "Farco 8", "Farco 11", "Farco 13", "Phobos T3", "Phobos T4", "Phobos R2", "Gunship", "Adv. Gunship", "Adder MK4"},
				["Equipment Freighter 3"] = {		  "Dreadnought"},
		}
		if prebuilt_followers == nil then
			prebuilt_followers = {}
			for template,details in pairs(spawn_utility_prebuilt_followers) do
				if ship_template[template] ~= nil then
					local leaders = {}
					for i,leader in ipairs(details) do
						if ship_template[leader] ~= nil then
							table.insert(leaders,leader)
						end
					end
					if #leaders > 0 then
						prebuilt_followers[template] = leaders
					end
				end
			end
		end
		local spawn_utility_prebuilt_relative = {
			{strength = 9,	leader = "MT52 Hornet",		follower = "Gnat",				shape = "V"},	--5,	2
			{strength = 10,	leader = "Adder MK4",		follower = "Gnat",				shape = "V"},	--6,	2
			{strength = 11,	leader = "MT52 Hornet",		follower = "Light Drone",		shape = "V"},	--5,	3
			{strength = 12,	leader = "Adder MK4",		follower = "Light Drone",		shape = "V4"},	--6,	3
			{strength = 13,	leader = "MT52 Hornet",		follower = "Gnat",				shape = "V4"},	--5,	2
			{strength = 14,	leader = "Adder MK4",		follower = "Gnat",				shape = "V4"},	--6,	2
			{strength = 15,	leader = "MT52 Hornet",		follower = "MU52 Hornet",		shape = "V"},	--5,	5
			{strength = 16,	leader = "Nirvana R3",		follower = "Gnat",				shape = "V"},	--12,	2
			{strength = 17,	leader = "Phobos R2",		follower = "Gnat",				shape = "V"},	--13,	2
			{strength = 18,	leader = "Nirvana R3",		follower = "Lite Drone",		shape = "V"},	--12,	3
			{strength = 19,	leader = "Phobos T3",		follower = "Gnat",				shape = "V"},	--15,	2
			{strength = 20,	leader = "Farco 3",			follower = "Gnat",				shape = "V"},	--16,	2
			{strength = 21,	leader = "MT52 Hornet",		follower = "Ktlitan Scout",		shape = "V"},	--5,	8
			{strength = 22,	leader = "Nirvana R3",		follower = "MT52 Hornet",		shape = "V"},	--12,	5
			{strength = 23,	leader = "Phobos R2",		follower = "MU52 Hornet",		shape = "V"},	--13,	5
			{strength = 24,	leader = "Nirvana R3",		follower = "Fighter",			shape = "V"},	--12,	6
			{strength = 25,	leader = "Phobos T3",		follower = "MU52 Hornet",		shape = "V"},	--15,	5
			{strength = 26,	leader = "Farco 3",			follower = "MU52 Hornet",		shape = "V"},	--16,	5
			{strength = 27,	leader = "Gunship",			follower = "MU52 Hornet",		shape = "V"},	--17,	5
			{strength = 28,	leader = "Phobos T4",		follower = "MU52 Hornet",		shape = "V"},	--18,	5
			{strength = 29,	leader = "Phobos T3",		follower = "K2 Fighter",		shape = "V"},	--15,	7
			{strength = 30,	leader = "Farco 3",			follower = "K2 Fighter",		shape = "V"},	--16,	7
			{strength = 31,	leader = "Gunship",			follower = "K2 Fighter",		shape = "V"},	--17,	7
			{strength = 32,	leader = "Nirvana R3",		follower = "MT52 Hornet",		shape = "V4"},	--12,	5
			{strength = 33,	leader = "Phobos R2",		follower = "MT52 Hornet",		shape = "V4"},	--13,	5
			{strength = 34,	leader = "Adv. Gunship",	follower = "K2 Fighter",		shape = "V"},	--20,	7
			{strength = 35,	leader = "Phobos T3",		follower = "MU52 Hornet",		shape = "V4"},	--15,	5
			{strength = 36,	leader = "Nirvana R3",		follower = "Fighter",			shape = "V4"},	--12,	6
			{strength = 37,	leader = "Phobos R2",		follower = "Fighter",			shape = "V4"},	--13,	6
			{strength = 38,	leader = "Phobos T4",		follower = "MU52 Hornet",		shape = "V4"},	--18,	5
			{strength = 39,	leader = "Phobos T3",		follower = "Ktlitan Fighter",	shape = "V4"},	--15,	6
			{strength = 40,	leader = "Sentinel",		follower = "K3 Fighter",		shape = "V"},	--24,	8
			{strength = 41,	leader = "Farco 11",		follower = "MT52 Hornet",		shape = "V4"},	--21,	5
			{strength = 42,	leader = "Phobos T4",		follower = "Fighter",			shape = "V4"},	--18,	6
			{strength = 43,	leader = "Phobos T3",		follower = "K2 Fighter",		shape = "V4"},	--15,	7
			{strength = 44,	leader = "Nirvana R3",		follower = "K3 Fighter",		shape = "V4"},	--12,	8
			{strength = 45,	leader = "Phobos R2",		follower = "Ktlitan Scout",		shape = "V4"},	--13,	8
			{strength = 46,	leader = "Cucaracha",		follower = "MT52 Hornet",		shape = "V"},	--36,	5
			{strength = 47,	leader = "Gunship",			follower = "MU52 Hornet",		shape = "M6"},	--17,	5
			{strength = 48,	leader = "Sentinel",		follower = "Fighter",			shape = "V4"},	--24,	6
			{strength = 49,	leader = "Phobos R2",		follower = "Fighter",			shape = "M6"},	--13,	6
			{strength = 50,	leader = "Adv. Gunship",	follower = "MU52 Hornet",		shape = "M6"},	--20,	5
			{strength = 51,	leader = "Phobos T3",		follower = "Fighter",			shape = "M6"},	--15,	6
			{strength = 52,	leader = "Adv. Gunship",	follower = "K3 Fighter",		shape = "V4"},	--20,	8
			{strength = 53,	leader = "MT52 Hornet",		follower = "Ktlitan Scout",		shape = "M6"},	--5,	8
			{strength = 54,	leader = "Nirvana R3",		follower = "K2 Fighter",		shape = "M6"},	--12,	7
			{strength = 55,	leader = "Phobos R2",		follower = "K2 Fighter",		shape = "M6"},	--13,	7
			{strength = 56,	leader = "Nirvana R5A",		follower = "Fighter",			shape = "M6"},	--20,	6
			{strength = 57,	leader = "Farco 11",		follower = "Ktlitan Fighter",	shape = "M6"},	--21,	6
			{strength = 58,	leader = "Farco 3",			follower = "K2 Fighter",		shape = "M6"},	--16,	7
			{strength = 59,	leader = "Nirvana R5",		follower = "MU52 Hornet",		shape = "X8"},	--19,	5
			{strength = 60,	leader = "Cucaracha",		follower = "Fighter",			shape = "V4"},	--36,	6
			{strength = 61,	leader = "Farco 8",			follower = "K2 Fighter",		shape = "M6"},	--19,	7
			{strength = 62,	leader = "Adv. Gunship",	follower = "K2 Fighter",		shape = "M6"},	--20,	7
			{strength = 63,	leader = "Phobos T3",		follower = "Ktlitan Fighter",	shape = "X8"},	--15,	6
			{strength = 64,	leader = "Sentinel",		follower = "MU52 Hornet",		shape = "X8"},	--24,	5
			{strength = 65,	leader = "Gunship",			follower = "K3 Fighter",		shape = "M6"},	--17,	8
			{strength = 66,	leader = "Cucaracha",		follower = "MT52 Hornet",		shape = "M6"},	--36,	5
			{strength = 67,	leader = "Blockade Runner",	follower = "Gnat",				shape = "V"},	--63,	2
			{strength = 68,	leader = "Cucaracha",		follower = "Ktlitan Scout",		shape = "V4"},	--36,	8
			{strength = 69,	leader = "Blockade Runner",	follower = "Light Drone",		shape = "V"},	--63,	3
			{strength = 70,	leader = "Adder MK4",		follower = "K3 Fighter",		shape = "X8"},	--6,	8
			{strength = 71,	leader = "Blockade Runner",	follower = "Gnat",				shape = "V4"},	--63,	2
			{strength = 72,	leader = "Supervisor",		follower = "Gnat",				shape = "V"},	--68,	2
			{strength = 73,	leader = "Gunship",			follower = "K2 Fighter",		shape = "X8"},	--17,	7
			{strength = 74,	leader = "Supervisor",		follower = "Light Drone",		shape = "V"},	--68,	3
			{strength = 75,	leader = "Nirvana R5",		follower = "K2 Fighter",		shape = "X8"},	--19,	7
			{strength = 76,	leader = "Supervisor",		follower = "Gnat",				shape = "V4"},	--68,	2
			{strength = 77,	leader = "Farco 11",		follower = "K2 Fighter",		shape = "X8"},	--21,	7
			{strength = 78,	leader = "Adder MK4",		follower = "Cucaracha",			shape = "V"},	--6,	36
			{strength = 79,	leader = "Phobos T3",		follower = "K3 Fighter",		shape = "X8"},	--15,	8
			{strength = 80,	leader = "Farco 3",			follower = "Ktlitan Scout",		shape = "X8"},	--16,	8
			{strength = 81,	leader = "Gunship",			follower = "K3 Fighter",		shape = "X8"},	--17,	8
			{strength = 82,	leader = "Phobos T4",		follower = "Ktlitan Scout",		shape = "X8"},	--18,	8
			{strength = 83,	leader = "Farco 8",			follower = "K3 Fighter",		shape = "X8"},	--19,	8
			{strength = 84,	leader = "Dreadnought",		follower = "Gnat",				shape = "V"},	--80,	2
			{strength = 85,	leader = "Phobos R2",		follower = "Cucaracha",			shape = "V"},	--13,	36
			{strength = 86,	leader = "Dreadnought",		follower = "Light Drone",		shape = "V"},	--80,	3
			{strength = 87,	leader = "Phobos T3",		follower = "Cucaracha",			shape = "V"},	--15,	36
			{strength = 88,	leader = "Dreadnought",		follower = "Gnat",				shape = "V4"},	--80,	2
			{strength = 89,	leader = "Gunship",			follower = "Cucaracha",			shape = "V"},	--17,	36
			{strength = 90,	leader = "Dreadnought",		follower = "MU52 Hornet",		shape = "V"},	--80,	5
			{strength = 91,	leader = "Nirvana R5",		follower = "Cucaracha",			shape = "V"},	--19,	36
			{strength = 92,	leader = "Supervisor",		follower = "Fighter",			shape = "V4"},	--68,	6
			{strength = 93,	leader = "Blockade Runner",	follower = "MU52 Hornet",		shape = "M6"},	--63,	5
			{strength = 94,	leader = "Dreadnought",		follower = "K2 Fighter",		shape = "V"},	--80,	7
			{strength = 95,	leader = "Blockade Runner",	follower = "K3 Fighter",		shape = "V4"},	--63,	8
			{strength = 96,	leader = "Supervisor",		follower = "K2 Fighter",		shape = "V4"},	--68,	7
			{strength = 97,	leader = "Dread No More",	follower = "MT52 Hornet",		shape = "V"},	--87,	5
			{strength = 98,	leader = "Supervisor",		follower = "MT52 Hornet",		shape = "M6"},	--68,	5
			{strength = 99,	leader = "Dread No More",	follower = "Ktlitan Fighter",	shape = "V"},	--87,	6
			{strength = 100,leader = "Supervisor",		follower = "K3 Fighter",		shape = "V4"},	--68,	8
			{strength = 101,leader = "Dread No More",	follower = "K2 Fighter",		shape = "V"},	--87,	7
			{strength = 102,leader = "Atlantis X23",	follower = "Broom",				shape = "V4"},	--50,	13
			{strength = 103,leader = "Dread No More",	follower = "K3 Fighter",		shape = "V"},	--87,	8
			{strength = 104,leader = "Dreadnought",		follower = "Fighter",			shape = "V4"},	--80,	6
			{strength = 105,leader = "Blockade Runner",	follower = "K2 Fighter",		shape = "M6"},	--63,	7
			{strength = 106,leader = "Dreadnought",		follower = "Broom",				shape = "V"},	--80,	13
			{strength = 107,leader = "Strongarm",		follower = "Fighter",			shape = "V"},	--95,	6
			{strength = 108,leader = "Dreadnought",		follower = "K2 Fighter",		shape = "V4"},	--80,	7
			{strength = 109,leader = "Strongarm",		follower = "K2 Fighter",		shape = "V"},	--95,	7
			{strength = 110,leader = "Atlantis X23",	follower = "Brush",				shape = "W6"},	--50,	10
			{strength = 111,leader = "Strongarm",		follower = "Ktlitan Scout",		shape = "V"},	--95,	8
			{strength = 112,leader = "Dreadnought",		follower = "K3 Fighter",		shape = "V4"},	--80,	8
			{strength = 113,leader = "Dread No More",	follower = "Broom",				shape = "V"},	--87,	13
			{strength = 114,leader = "Atlantis X23",	follower = "Ktlitan Scout",		shape = "X8"},	--50,	8
			{strength = 115,leader = "Dread No More",	follower = "K2 Fighter",		shape = "V4"},	--87,	7
			{strength = 116,leader = "Dreadnought",		follower = "Fighter",			shape = "M6"},	--80,	6
			{strength = 117,leader = "Dread No More",	follower = "MT52 Hornet",		shape = "M6"},	--87,	5
			{strength = 118,leader = "Farco 3",			follower = "Sweeper",			shape = "W6"},	--16,	17
			{strength = 119,leader = "Dread No More",	follower = "K3 Fighter",		shape = "V4"},	--87,	8
			{strength = 120,leader = "Dreadnought",		follower = "MT52 Hornet",		shape = "X8"},	--80,	5
			{strength = 121,leader = "Strongarm",		follower = "Broom",				shape = "V"},	--95,	13
			{strength = 122,leader = "Dreadnought",		follower = "K2 Fighter",		shape = "M6"},	--80,	7
			{strength = 123,leader = "Strongarm",		follower = "K2 Fighter",		shape = "V4"},	--95,	7
			{strength = 124,leader = "Nirvana R5A",		follower = "Broom",				shape = "X8"},	--20,	13
			{strength = 125,leader = "Strongarm",		follower = "MU52 Hornet",		shape = "M6"},	--95,	5
			{strength = 126,leader = "Atlantis X23",	follower = "Nirvana R5",		shape = "V4"},	--50,	19
			{strength = 127,leader = "Strongarm",		follower = "Ktlitan Scout",		shape = "V4"},	--95,	8
			{strength = 128,leader = "Dreadnought",		follower = "K3 Fighter",		shape = "M6"},	--80,	8
			{strength = 129,leader = "Strongarm",		follower = "Sweeper",			shape = "V"},	--95,	17
			{strength = 130,leader = "Atlantis X23",	follower = "Nirvana R5A",		shape = "V4"},	--50,	20
			{strength = 131,leader = "Gunship",			follower = "Nirvana R5",		shape = "M6"},	--17,	19
		}
		if prebuilt_relative == nil then
			prebuilt_relative = {}
			for i,details in ipairs(spawn_utility_prebuilt_relative) do
				if ship_template[details.leader] ~= nil and ship_template[details.follower] ~= nil then
					table.insert(prebuilt_relative,details)
				end
			end
		end
		if fly_formation == nil then
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
				["H"] =		{
								{angle = 90	, dist = 1	},
								{angle = 270, dist = 1	},
								{angle = 45 , dist = math.sqrt(2) },
								{angle = 135, dist = math.sqrt(2) },
								{angle = 225, dist = math.sqrt(2) },
								{angle = 315, dist = math.sqrt(2) },
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
								{angle = 305, dist = 1.7},
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
				["*"] =		{
								{angle = 30	, dist = 1	},
								{angle = 90	, dist = 1	},
								{angle = 330, dist = 1	},
								{angle = 150, dist = 1	},
								{angle = 210, dist = 1	},
								{angle = 270, dist = 1	},
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
				["O"] =		{
								{angle = 0,		dist = 1},					--1
								{angle = 120,	dist = 1},					--2
								{angle = 240,	dist = 1},					--3
								{angle = 60,	dist = 1},					--4
								{angle = 180,	dist = 1},					--5
								{angle = 300,	dist = 1},					--6
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
				["O3R"] =	{
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
							},
				["O4R"] =	{
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
							},
				["O5R"] =	{
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
							},
				["O6R"] =	{
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
							},
				["O7R"] =	{
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
							},
			}
		end
		if formation_spacing == nil then
			formation_spacing = 1000
		end
		if wing_type == nil then
			wing_type = "MT52 Hornet"
		end
		if wing_count == nil then
			wing_count = 3
		end
		gm_click_mode_names = {
			["fleet spawn"] = 			_("msgGM","fleet spawn"),
			["set prebuilt target"] =	_("msgGM","set prebuilt target"),
			["spawn prebuilt fleet"] =	_("msgGM","spawn prebuilt fleet"),
			["ship spawn"] = 			_("msgGM","ship spawn"),
		}
	end
end
--	Utilities
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
--	Spawn fleet functions
function spawnGMFleet()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main From Flt Spwn"),mainGMButtons)
	addGMFunction(_("buttonGM","-Fleet or Ship"),spawnGMShips)
	addGMFunction(string.format("+%s",fleetSpawnFaction),setGMFleetFaction)
	local button_label = ""
	if fleet_spawn_type == "relative" then
		local calculated_strength = math.floor(playerPower()*fleetStrengthByPlayerStrength)
		button_label = string.format(_("buttonGM","+%s*player strength: %s"),fleetStrengthByPlayerStrength,calculated_strength)
		if fleetStrengthByPlayerStrength == .25 then
			button_label = string.format(_("buttonGM","+1/4 player strength: %s"),calculated_strength)
		elseif fleetStrengthByPlayerStrength == .5 then
			button_label = string.format(_("buttonGM","+1/2 player strength: %s"),calculated_strength)
		end
		addGMFunction(button_label,setGMFleetStrength)
	elseif fleet_spawn_type == "fixed" then
		addGMFunction(string.format(_("buttonGM","+Fixed Strength %i"),fleetStrengthFixedValue),setFixedFleetStrength)
	elseif fleet_spawn_type == "formation" then
		--calculate fleet strength
		button_label = _("buttonGM","+Formation")
		if formation_shape ~= nil then
			local leader_strength = ship_template[prebuilt_leader].strength
			local follower_strength = ship_template[prebuilt_follower].strength
			local formation_strength = leader_strength + (follower_strength * #fly_formation[formation_shape])
			button_label = string.format("%s %i",button_label,formation_strength)
		end
		addGMFunction(button_label,setPrebuiltFleet)
	end
	if fleet_spawn_type ~= "formation" then
		local exclusion_string = ""
		for name, details in pairs(fleet_exclusions) do
			if details.exclude then
				if exclusion_string == "" then
					exclusion_string = "-"
				end
				exclusion_string = exclusion_string .. details.letter
			end
		end
		addGMFunction(string.format("+%s%s",fleet_composition_labels[fleetComposition],exclusion_string),function()
			setFleetComposition(spawnGMFleet)
		end)
		addGMFunction(string.format("+%s",fleet_change_labels[fleetChange]),setFleetChange)
		addGMFunction(string.format("+%s",fleet_order_labels[fleetOrders]),setFleetOrders)
		returnFromFleetSpawnLocation = spawnGMFleet
		addGMFunction(string.format("+%s",fleet_spawn_location_labels[fleetSpawnLocation]),setFleetSpawnLocation)
		if gm_click_mode == "fleet spawn" then
			addGMFunction(_("buttonGM",">Spawn<"),parmSpawnFleet)
		else
			addGMFunction(_("buttonGM","Spawn"),parmSpawnFleet)
		end
	end
end
function playerPower()
--evaluate the players for enemy strength and size spawning purposes
	local player_ship_score = 0
	for i,p in ipairs(getActivePlayerShips()) do
		if p.shipScore == nil then
			local spawn_player_score = {
				["Atlantis"]			= 52,	
				["Benedict"]			= 10,	
				["Crucible"]			= 45,	
				["Ender"]				= 100,	
				["Flavia P.Falcon"]		= 13,	
				["Hathcock"]			= 30,	
				["Kiriya"]				= 10,	
				["MP52 Hornet"] 		= 7, 	
				["Maverick"]			= 45,	
				["Nautilus"]			= 12,	
				["Phobos M3P"]			= 19,	
				["Piranha"]				= 16,	
				["Repulse"]				= 14,	
				["Striker"]				= 8,	
				["ZX-Lindworm"]			= 8,	
				["Player Cruiser"]		= 40,	
				["Player Missile Cr."]	= 45,	
				["Player Fighter"]		= 7,	
			}
			if spawn_player_score[p:getTypeName()] ~= nil then
				player_ship_score = player_ship_score + spawn_player_score[p:getTypeName()]
			else
				player_ship_score = player_ship_score + 24
			end
		else
			player_ship_score = player_ship_score + p.shipScore
		end
	end
	return player_ship_score
end
function setGMFleetFaction()
	clearGMFunctions()
	local fleet_factions = {
		"Arlenians",
		"Exuari",
		"Ghosts",
		"Human Navy",
		"Kraylor",
		"Ktlitans",
		"Independent",
		"TSN",
		"USN",
		"CUF",
	}
	for i,faction in ipairs(fleet_factions) do
		local button_label = faction
		if fleetSpawnFaction == faction then
			button_label = button_label .. "*"
		end
		addGMFunction(button_label,function()
			fleetSpawnFaction = faction
			spawnGMFleet()
		end)
	end
end
function setGMFleetStrength()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main from Rel Str"),mainGMButtons)
	addGMFunction(_("buttonGM","-Fleet or Ship"),spawnGMShips)
	addGMFunction(_("buttonGM","-Fleet Spawn"),spawnGMFleet)
	local calculated_strength = math.floor(playerPower()*fleetStrengthByPlayerStrength)
	local button_label = string.format(_("buttonGM","-%s*player strength: %s"),fleetStrengthByPlayerStrength,calculated_strength)
	if fleetStrengthByPlayerStrength == .25 then
		button_label = string.format(_("buttonGM","+1/4 player strength: %s"),calculated_strength)
	elseif fleetStrengthByPlayerStrength == .5 then
		button_label = string.format(_("buttonGM","+1/2 player strength: %s"),calculated_strength)
	end
	addGMFunction(button_label,spawnGMFleet)
	addGMFunction(_("buttonGM","Switch to Fixed Strength"),function()
		fleet_spawn_type = "fixed"
		fleetStrengthFixed = true
		spawnGMFleet()
	end)
	addGMFunction(_("buttonGM","Switch to Formation"),function()
		fleet_spawn_type = "formation"
		fleetStrengthFixed = false
		spawnGMFleet()
	end)
	setFleetStrength(setGMFleetStrength)
end
function setFleetStrength(caller)
	local relative_strength_list = {
		{"1/4", .25},
		{"1/2", .5},
		{"1", 1},
		{"2", 2},
		{"3", 3},
		{"4", 4},
		{"5", 5},
		{"6", 6},
		{"7", 7},
		{"8", 8},
	}
	local matching_index = 0
	for index, item in ipairs(relative_strength_list) do
		if item[2] == fleetStrengthByPlayerStrength then
			matching_index = index
		end
	end
	if matching_index == 1 then
		for i=1,3 do
			local button_label = relative_strength_list[i][1]
			if i == matching_index then
				button_label = button_label .. "*"
			end
			addGMFunction(button_label,function()
				fleetStrengthByPlayerStrength = relative_strength_list[i][2]
				caller()
			end)
		end
	elseif matching_index == #relative_strength_list then
		for i=#relative_strength_list-2,#relative_strength_list do
			local button_label = relative_strength_list[i][1]
			if i == matching_index then
				button_label = button_label .. "*"
			end
			addGMFunction(button_label,function()
				fleetStrengthByPlayerStrength = relative_strength_list[i][2]
				caller()
			end)
		end
	else
		for i=matching_index-1,matching_index+1 do
			local button_label = relative_strength_list[i][1]
			if i == matching_index then
				button_label = button_label .. "*"
			end
			addGMFunction(button_label,function()
				fleetStrengthByPlayerStrength = relative_strength_list[i][2]
				caller()
			end)
		end
	end
end
function setFixedFleetStrength()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main from Fix Str"),mainGMButtons)
	addGMFunction(_("buttonGM","-Fleet or Ship"),spawnGMShips)
	addGMFunction(_("buttonGM","-Fleet Spawn"),spawnGMFleet)
	addGMFunction(_("buttonGM","-Fixed Strength ") .. fleetStrengthFixedValue,spawnGMFleet)
	addGMFunction(_("buttonGM","Switch to Relative"),function()
		fleet_spawn_type = "relative"
		fleetStrengthFixed = false
		spawnGMFleet()
	end)
	addGMFunction(_("buttonGM","Switch to Formation"),function()
		fleet_spawn_type = "formation"
		fleetStrengthFixed = false
		spawnGMFleet()
	end)
	fixFleetStrength(setFixedFleetStrength)
end
function fixFleetStrength(caller)
	if fleetStrengthFixedValue > 50 then
		addGMFunction(string.format("%i - %i = %i",fleetStrengthFixedValue,50,fleetStrengthFixedValue-50),function()
			fleetStrengthFixedValue = fleetStrengthFixedValue - 50
			caller()
		end)
	end
	if fleetStrengthFixedValue < 2000 then
		addGMFunction(string.format("%i + %i = %i",fleetStrengthFixedValue,50,fleetStrengthFixedValue+50),function()
			fleetStrengthFixedValue = fleetStrengthFixedValue + 50
			caller()
		end)
	end	
end
function setFleetChange()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main from Flt Chng"),mainGMButtons)
	addGMFunction(_("buttonGM","-Fleet Spawn"),spawnGMFleet)
	local button_label = fleet_change_labels["unmodified"]
	if fleetChange == "unmodified" then
		button_label = button_label .. "*"
	end
	addGMFunction(button_label,function()
		fleetChange = "unmodified"
		setFleetChange()
	end)
	button_label = fleet_change_labels["improved"]
	if fleetChange == "improved" then
		button_label = button_label .. "*"
	end
	addGMFunction(button_label,function()
		fleetChange = "improved"
		setFleetChange()
	end)
	button_label = fleet_change_labels["degraded"]
	if fleetChange == "degraded" then
		button_label = button_label .. "*"
	end
	addGMFunction(button_label,function()
		fleetChange = "degraded"
		setFleetChange()
	end)
	button_label = fleet_change_labels["tinkered"]
	if fleetChange == "tinkered" then
		button_label = button_label .. "*"
	end
	addGMFunction(button_label,function()
		fleetChange = "tinkered"
		setFleetChange()
	end)
	if fleetChange ~= "unmodified" then
		local chances = {
			10, 20, 30, 40, 50, 60, 70, 80, 90, 100			
		}
		local index = 0
		for i,chance in ipairs(chances) do
			if chance == fleetChangeChance then
				index = i
				break
			end
		end
		if index == 1 then
			addGMFunction(string.format(_("buttonGM","Change Chance %s%%*"),chances[index]),function()
				fleetChangeChance = chances[index]
				setFleetChange()
			end)
			addGMFunction(string.format(_("buttonGM","Change Chance %s%%"),chances[index+1]),function()
				fleetChangeChance = chances[index+1]
				setFleetChange()
			end)
			addGMFunction(string.format(_("buttonGM","Change Chance %s%%"),chances[index+2]),function()
				fleetChangeChance = chances[index+2]
				setFleetChange()
			end)
		elseif index == #chances then
			addGMFunction(string.format(_("buttonGM","Change Chance %s%%"),chances[index-2]),function()
				fleetChangeChance = chances[index-2]
				setFleetChange()
			end)
			addGMFunction(string.format(_("buttonGM","Change Chance %s%%"),chances[index-1]),function()
				fleetChangeChance = chances[index-1]
				setFleetChange()
			end)
			addGMFunction(string.format(_("buttonGM","Change Chance %s%%*"),chances[index]),function()
				fleetChangeChance = chances[index]
				setFleetChange()
			end)
		else
			addGMFunction(string.format(_("buttonGM","Change Chance %s%%"),chances[index-1]),function()
				fleetChangeChance = chances[index-1]
				setFleetChange()
			end)
			addGMFunction(string.format(_("buttonGM","Change Chance %s%%*"),chances[index]),function()
				fleetChangeChance = chances[index]
				setFleetChange()
			end)
			addGMFunction(string.format(_("buttonGM","Change Chance %s%%"),chances[index+1]),function()
				fleetChangeChance = chances[index+1]
				setFleetChange()
			end)
		end
	end
end
function setFleetOrders()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main from Flt Ord"),mainGMButtons)
	addGMFunction(_("buttonGM","-Fleet or Ship"),spawnGMShips)
	addGMFunction(_("buttonGM","-Fleet Spawn"),spawnGMFleet)
	local button_label = fleet_order_labels["Roaming"]
	if fleetOrders == "Roaming" then
		button_label = button_label .. "*"
	end
	addGMFunction(button_label,function()
		fleetOrders = "Roaming"
		setFleetOrders()
	end)
	button_label = fleet_order_labels["Idle"]
	if fleetOrders == "Idle" then
		button_label = button_label .. "*"
	end
	addGMFunction(button_label,function()
		fleetOrders = "Idle"
		setFleetOrders()
	end)
	button_label = fleet_order_labels["Stand Ground"]
	if fleetOrders == "Stand Ground" then
		button_label = button_label .. "*"
	end
	addGMFunction(button_label,function()
		fleetOrders = "Stand Ground"
		setFleetOrders()
	end)
end
function setFleetSpawnLocation()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main from Flt Loctn"),mainGMButtons)
	addGMFunction(_("buttonGM","-Fleet or Ship"),spawnGMShips)
	local return_label = _("buttonGM","-Fleet Spawn")
	if returnFromFleetSpawnLocation == spawnGMShip then
		return_label = _("buttonGM","-Ship Spawn")
	end
	addGMFunction(return_label,returnFromFleetSpawnLocation)
	local button_label = string.format(_("buttonGM","Ambush %i"),fleetAmbushDistance)
	if fleetSpawnLocation == "Ambush" then
		button_label = string.format("%s* %i",fleet_spawn_location_labels[fleetSpawnLocation],fleetAmbushDistance)
	end
	addGMFunction(string.format("+%s",button_label),function()
		fleetSpawnLocation = "Ambush"
		setFleetAmbushDistance()
	end)
	button_label = fleet_spawn_location_labels["At Click"]
	if fleetSpawnLocation == "At Click" then
		button_label = button_label .. "*"
	end
	addGMFunction(button_label,function()
		fleetSpawnLocation = "At Click"
		setFleetSpawnLocation()
	end)
end
function setFleetAmbushDistance()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-From Ambush Dist"),setFleetSpawnLocation)
	local ambush_distance = {
		3,4,5,6,7,
	}
	for i,dist in ipairs(ambush_distance) do
		local button_label = string.format(_("buttonGM","Ambush Dist:%su"),dist)
		if dist == fleetAmbushDistance then
			button_label = button_label .. "*"
		end
		addGMFunction(button_label,function()
			fleetAmbushDistance = dist
			setFleetAmbushDistance()
		end)
	end	
end
function parmSpawnFleet()
	local fsx = 0
	local fsy = 0
	local fleet = nil
	if fleetSpawnLocation == "At Click" then
		if gm_click_mode == nil then
			gm_click_mode = "fleet spawn"
			onGMClick(gmClickFleetSpawn)
		elseif gm_click_mode == "fleet spawn" then
			gm_click_mode = nil
			onGMClick(nil)
		else
			local prev_mode = gm_click_mode
			gm_click_mode = "fleet spawn"
			onGMClick(gmClickFleetSpawn)
			addGMMessage(string.format(_("msgGM","Cancelled current GM Click mode\n   %s\nIn favor of\n   %s\nGM click mode."),gm_click_mode_names[prev_mode],gm_click_mode_names[gm_click_mode]))
		end
		spawnGMFleet()
	else
		local objectList = getGMSelection()
		if #objectList < 1 then
			addGMMessage(_("msgGM","Fleet spawn failed: nothing selected for spawn location determination"))
			return
		end
		fsx, fsy = objectList[1]:getPosition()
		fleet = spawnRandomArmed(fsx, fsy, "ambush", fleetAmbushDistance)
	end
end
function gmClickFleetSpawn(x,y)
	spawnRandomArmed(x, y)
end
function spawnRandomArmed(x, y, shape, spawn_distance, spawn_angle, px, py)
--x and y are central spawn coordinates
--fleetIndex is the number of the fleet to be spawned
--sl (was) the score list, nl is the name list, bl is the boolean list
--spawn_distance optional - used for ambush or pyramid
--spawn_angle optional - used for ambush or pyramid
--px and py are the player coordinates or the pyramid fly towards point coordinates
	local enemyStrength = math.max(fleetStrengthByPlayerStrength * playerPower(),5)
	if fleetStrengthFixed then
		enemyStrength = fleetStrengthFixedValue
	end
	local enemyPosition = 0
	local sp = irandom(500,1000)			--random spacing of spawned group
	if shape == nil then
		shape = "square"
		if random(1,100) < 50 then
			shape = "hexagonal"
		end
	end
	local enemy_position = 0
	local enemyList = {}
	local template_pool = getTemplatePool(enemyStrength)
	if #template_pool < 1 then
		addGMMessage(_("msgGM","Empty Template pool: fix excludes or other criteria"))
		return enemyList
	end
	local fleet_prefix = generateCallSignPrefix(2)
	while enemyStrength > 0 do
		local selected_template = template_pool[math.random(1,#template_pool)]
		local ship = ship_template[selected_template].create(fleetSpawnFaction,selected_template)
		ship:setCallSign(generateCallSign(fleet_prefix))
		if ship_template[selected_template].base then
			if commsStation ~= nil then
				ship:setCommsScript(""):setCommsFunction(commsStation)
			end
		else
			if commsShip ~= nil then
				ship:setCommsScript(""):setCommsFunction(commsShip)
			end
		end
		ship:orderRoaming()
		if fleetOrders == "Roaming" then
			ship:orderRoaming()
		elseif fleetOrders == "Idle" then
			ship:orderIdle()
		elseif fleetOrders == "Stand Ground" then
			ship:orderStandGround()
		end
		enemy_position = enemy_position + 1
		if shape == "none" or shape == "pyramid" or shape == "ambush" then
			ship:setPosition(x,y)
		else
			ship:setPosition(x + formation_delta[shape].x[enemy_position] * sp, y + formation_delta[shape].y[enemy_position] * sp)
		end
		ship.fleetIndex = fleetIndex
		if fleetChange ~= "unmodified" then
			modifyShip(ship)
		end
		table.insert(enemyList, ship)
		enemyStrength = enemyStrength - ship_template[selected_template].strength
	end
	if shape == "ambush" then
		if spawn_distance == nil then
			spawn_distance = 5
		end
		if spawn_angle == nil then
			spawn_angle = random(0,360)
		end
		local circle_increment = 360/#enemyList
		for idx, enemy in ipairs(enemyList) do
			local dex, dey = vectorFromAngleNorth(spawn_angle,spawn_distance*1000)
			enemy:setPosition(x+dex,y+dey):setHeading(spawn_angle + 180)
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
		for i, current_ship_template in ipairs(ship_template_by_strength) do
			if not excludeShip(current_ship_template) then
				if ship_template[current_ship_template].strength <= max_strength then
					if fleetComposition == "Non-DB" then
						if ship_template[current_ship_template].create ~= stockTemplate then
							table.insert(template_pool,current_ship_template)
						end
					elseif fleetComposition == "Random" then
						table.insert(template_pool,current_ship_template)
					else
						local ship_cat = fleet_group[fleetComposition]
						if ship_template[current_ship_template][ship_cat] then
							table.insert(template_pool,current_ship_template)							
						end
					end
				end
			end
			if #template_pool >= template_pool_size then
				break
			end
		end
	elseif pool_selectivity == "more/light" then
		for i=#ship_template_by_strength,1,-1 do
			local current_ship_template = ship_template_by_strength[i]
			if not excludeShip(current_ship_template) then
				if ship_template[current_ship_template].strength <= max_strength then
					if fleetComposition == "Non-DB" then
						if ship_template[current_ship_template].create ~= stockTemplate then
							table.insert(template_pool,current_ship_template)
						end
					elseif fleetComposition == "Random" then
						table.insert(template_pool,current_ship_template)
					else
						local ship_cat = fleet_group[fleetComposition]
						if ship_template[current_ship_template][ship_cat] then
							table.insert(template_pool,current_ship_template)							
						end
					end
				end
			end
			if #template_pool >= template_pool_size then
				break
			end
		end
	else	--full
		for current_ship_template,details in pairs(ship_template) do
			if not excludeShip(current_ship_template) then
				if details.strength <= max_strength then
					if fleetComposition == "Non-DB" then
						if ship_template[current_ship_template].create ~= stockTemplate then
							table.insert(template_pool,current_ship_template)
						end
					elseif fleetComposition == "Random" then
						table.insert(template_pool,current_ship_template)
					else
						local ship_cat = fleet_group[fleetComposition]
						if ship_template[current_ship_template][ship_cat] then
							table.insert(template_pool,current_ship_template)							
						end
					end
				end
			end
		end
	end
	return template_pool
end
function excludeShip(current_ship_template)
	assert(type(current_ship_template)=="string") -- the template name we are spawning from ship_template	
	local ship = nil
	if ship_template[current_ship_template] == nil then
		print("ship template does not have an entry for",current_ship_template)
		return true
	elseif ship_template[current_ship_template].create == nil then
		print(current_ship_template,"does not have a create entry in ship_template")
		return true
	end
	ship = ship_template[current_ship_template].create("Independent",current_ship_template)
	ship:orderIdle()
	local exclude = false
	for name, details in pairs(fleet_exclusions) do
		if details.exclude then
			if name == "Unusual" then
				if ship_template[current_ship_template].unusual == true then
					exclude = true
				end
			end
			if name == "Nuke" then
				if ship:getWeaponStorageMax("Nuke") > 0 then
					exclude = true
				end
			end
			if name == "Warp" then
				if ship:hasWarpDrive() then
					exclude = true
				end
			end
			if name == "Jump" then
				if ship:hasJumpDrive() then
					exclude = true
				end
			end
		end
	end
	ship:destroy()
	return exclude
end
function modifyShip(ship)
	local modVal = modifiedValue()
	if modVal ~= 1 then
		ship:setHullMax(ship:getHullMax()*modVal)
		ship:setHull(ship:getHullMax())
	end
	modVal = modifiedValue()
	if modVal ~= 1 then
		local shieldCount = ship:getShieldCount()
		if shieldCount > 0 then
			if shieldCount == 1 then
				ship:setShieldsMax(ship:getShieldMax(0)*modVal)
				ship:setShields(ship:getShieldMax(0))
			elseif shieldCount == 2 then
				ship:setShieldsMax(ship:getShieldMax(0)*modVal,ship:getShieldMax(1)*modVal)
				ship:setShields(ship:getShieldMax(0),ship:getShieldMax(1))
			elseif shieldCount == 3 then
				ship:setShieldsMax(ship:getShieldMax(0)*modVal,ship:getShieldMax(1)*modVal,ship:getShieldMax(2)*modVal)
				ship:setShields(ship:getShieldMax(0),ship:getShieldMax(1),ship:getShieldMax(2))
			elseif shieldCount == 4 then
				ship:setShieldsMax(ship:getShieldMax(0)*modVal,ship:getShieldMax(1)*modVal,ship:getShieldMax(2)*modVal,ship:getShieldMax(3)*modVal)
				ship:setShields(ship:getShieldMax(0),ship:getShieldMax(1),ship:getShieldMax(2),ship:getShieldMax(3))
			elseif shieldCount == 5 then
				ship:setShieldsMax(ship:getShieldMax(0)*modVal,ship:getShieldMax(1)*modVal,ship:getShieldMax(2)*modVal,ship:getShieldMax(3)*modVal,ship:getShieldMax(4)*modVal)
				ship:setShields(ship:getShieldMax(0),ship:getShieldMax(1),ship:getShieldMax(2),ship:getShieldMax(3),ship:getShieldMax(4))
			elseif shieldCount == 6 then
				ship:setShieldsMax(ship:getShieldMax(0)*modVal,ship:getShieldMax(1)*modVal,ship:getShieldMax(2)*modVal,ship:getShieldMax(3)*modVal,ship:getShieldMax(4)*modVal,ship:getShieldMax(5)*modVal)
				ship:setShields(ship:getShieldMax(0),ship:getShieldMax(1),ship:getShieldMax(2),ship:getShieldMax(3),ship:getShieldMax(4),ship:getShieldMax(5))
			elseif shieldCount == 7 then
				ship:setShieldsMax(ship:getShieldMax(0)*modVal,ship:getShieldMax(1)*modVal,ship:getShieldMax(2)*modVal,ship:getShieldMax(3)*modVal,ship:getShieldMax(4)*modVal,ship:getShieldMax(5)*modVal,ship:getShieldMax(6)*modVal)
				ship:setShields(ship:getShieldMax(0),ship:getShieldMax(1),ship:getShieldMax(2),ship:getShieldMax(3),ship:getShieldMax(4),ship:getShieldMax(5),ship:getShieldMax(6))
			elseif shieldCount == 8 then
				ship:setShieldsMax(ship:getShieldMax(0)*modVal,ship:getShieldMax(1)*modVal,ship:getShieldMax(2)*modVal,ship:getShieldMax(3)*modVal,ship:getShieldMax(4)*modVal,ship:getShieldMax(5)*modVal,ship:getShieldMax(6)*modVal,ship:getShieldMax(7)*modVal)
				ship:setShields(ship:getShieldMax(0),ship:getShieldMax(1),ship:getShieldMax(2),ship:getShieldMax(3),ship:getShieldMax(4),ship:getShieldMax(5),ship:getShieldMax(6),ship:getShieldMax(7))
			end
		end
	end
	local maxNuke = ship:getWeaponStorageMax("Nuke")
	if maxNuke > 0 then
		modVal = modifiedValue()
		if modVal ~= 1 then
			if modVal > 1 then
				ship:setWeaponStorageMax("Nuke",math.ceil(maxNuke*modVal))
			else
				ship:setWeaponStorageMax("Nuke",math.floor(maxNuke*modVal))
			end
			ship:setWeaponStorage("Nuke",ship:getWeaponStorageMax("Nuke"))
		end
	end
	local maxEMP = ship:getWeaponStorageMax("EMP")
	if maxEMP > 0 then
		modVal = modifiedValue()
		if modVal ~= 1 then
			if modVal > 1 then
				ship:setWeaponStorageMax("EMP",math.ceil(maxEMP*modVal))
			else
				ship:setWeaponStorageMax("EMP",math.floor(maxEMP*modVal))
			end
			ship:setWeaponStorage("EMP",ship:getWeaponStorageMax("EMP"))
		end
	end
	local maxMine = ship:getWeaponStorageMax("Mine")
	if maxMine > 0 then
		modVal = modifiedValue()
		if modVal ~= 1 then
			if modVal > 1 then
				ship:setWeaponStorageMax("Mine",math.ceil(maxMine*modVal))
			else
				ship:setWeaponStorageMax("Mine",math.floor(maxMine*modVal))
			end
			ship:setWeaponStorage("Mine",ship:getWeaponStorageMax("Mine"))
		end
	end
	local maxHoming = ship:getWeaponStorageMax("Homing")
	if maxHoming > 0 then
		modVal = modifiedValue()
		if modVal ~= 1 then
			if modVal > 1 then
				ship:setWeaponStorageMax("Homing",math.ceil(maxHoming*modVal))
			else
				ship:setWeaponStorageMax("Homing",math.floor(maxHoming*modVal))
			end
			ship:setWeaponStorage("Homing",ship:getWeaponStorageMax("Homing"))
		end
	end
	local maxHVLI = ship:getWeaponStorageMax("HVLI")
	if maxHVLI > 0 then
		modVal = modifiedValue()
		if modVal ~= 1 then
			if modVal > 1 then
				maxHVLI = math.ceil(maxHVLI*modVal)
			else
				maxHVLI = math.floor(maxHVLI*modVal)
			end
			ship:setWeaponStorageMax("HVLI",maxHVLI)
			ship:setWeaponStorage("HVLI",maxHVLI)
		end
	end
	modVal = modifiedValue()
	if modVal ~= 1 then
		ship:setImpulseMaxSpeed(ship:getImpulseMaxSpeed()*modVal)
	end
	modVal = modifiedValue()
	if modVal ~= 1 then
		ship:setRotationMaxSpeed(ship:getRotationMaxSpeed()*modVal)
	end
	if ship:getBeamWeaponRange(0) > 0 then
		local beamIndex = 0
		local modArc = modifiedValue()
		local modRange = modifiedValue()
		local modCycle = 1/modifiedValue()
		local modDamage = modifiedValue()
		local modEnergy = 1/modifiedValue()
		local modHeat = 1/modifiedValue()
		repeat
			local beamArc = ship:getBeamWeaponArc(beamIndex)
			local beamDirection = ship:getBeamWeaponDirection(beamIndex)
			local beamRange = ship:getBeamWeaponRange(beamIndex)
			local beamCycle = ship:getBeamWeaponCycleTime(beamIndex)
			local beamDamage = ship:getBeamWeaponDamage(beamIndex)
			ship:setBeamWeapon(beamIndex,beamArc*modArc,beamDirection,beamRange*modRange,beamCycle*modCycle,beamDamage*modDamage)
			ship:setBeamWeaponEnergyPerFire(beamIndex,ship:getBeamWeaponEnergyPerFire(beamIndex)*modEnergy)
			ship:setBeamWeaponHeatPerFire(beamIndex,ship:getBeamWeaponHeatPerFire(beamIndex)*modHeat)
			beamIndex = beamIndex + 1
		until(ship:getBeamWeaponRange(beamIndex) < 1)
	end
end
function modifiedValue()
	local modChance = random(1,100)
	local modValue = 1
	if fleetChange == "improved" then
		if modChance <= fleetChangeChance then
			modValue = modValue + random(10,25)/100
		end
	elseif fleetChange == "degraded" then
		if modChance <= fleetChangeChance then
			modValue = modValue - random(10,25)/100
		end
	else	--tinkered
		if modChance <= fleetChangeChance then
			if random(1,100) <= 50 then
				modValue = modValue + random(10,25)/100
			else
				modValue = modValue - random(10,25)/100
			end
		end
	end
	return modValue
end
--	Spawn formation functions
function setPrebuiltFleet()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main from Formation"),mainGMButtons)
	addGMFunction(_("buttonGM","-Fleet or Ship"),spawnGMShips)
	addGMFunction(_("buttonGM","-Fleet Spawn"),spawnGMFleet)
	addGMFunction(_("buttonGM","Switch to Fixed Strength"),function()
		fleet_spawn_type = "fixed"
		fleetStrengthFixed = true
		spawnGMFleet()
	end)
	addGMFunction(_("buttonGM","Switch to Relative"),function()
		fleet_spawn_type = "relative"
		fleetStrengthFixed = false
		spawnGMFleet()
	end)
	button_label = _("buttonGM","+Shape")
	if formation_shape ~= nil then
		local leader_strength = ship_template[prebuilt_leader].strength
		if ship_template[prebuilt_follower] == nil then
			addGMMessage(string.format(_("msgGM","No entry in ship template for %s"),prebuilt_follower))
			return
		end
		local follower_strength = ship_template[prebuilt_follower].strength
		local formation_strength = leader_strength + (follower_strength * #fly_formation[formation_shape])	
		button_label = string.format("%s %s %s",button_label,formation_shape,formation_strength)
	end
	addGMFunction(button_label,setPrebuiltFormationShape)
	addGMFunction(_("buttonGM","+Composition"),setPrebuiltComposition)
	local leader_dist = 500
	if ship_template[prebuilt_leader].dist ~= nil then
		leader_dist = ship_template[prebuilt_leader].dist
	end
	local follower_dist = 500
	if ship_template[prebuilt_follower].dist ~= nil then
		follower_dist = ship_template[prebuilt_follower].dist
	end
	local minimum_spacing = leader_dist + follower_dist + 300
	if formation_spacing == nil or formation_spacing < minimum_spacing then
		formation_spacing = minimum_spacing
	end
	addGMFunction(string.format(_("buttonGM","+Spacing %.1fu"),formation_spacing/1000),setPrebuiltFormationSpacing)
	if formation_shape ~= nil then
		if gm_click_mode == "set prebuilt target" then
			addGMFunction(_("buttonGM",">Set Fleet Target<"),setPrebuiltFleetTarget)
		else
			local button_label = _("buttonGM","Spawn Fleet")
			if gm_click_mode == "spawn prebuilt fleet" then
				button_label = string.format(">%s<",button_label)
			end
			addGMFunction(button_label,spawnPrebuiltFleet)
		end
	end
end
function setFleetComposition(caller)
	clearGMFunctions()
	addGMFunction(_("buttonGM","-From composition"),function()
		string.format("")	--necessary to have global reference for Serious Proton engine
		caller()
	end)
	addGMFunction(string.format(_("buttonGM","+Group %s"),fleet_composition_labels[fleetComposition]),function()
		setFleetGroupComposition(caller)
	end)
	local exclusion_string = ""
	for name, details in pairs(fleet_exclusions) do
		if details.exclude then
			if exclusion_string == "" then
				exclusion_string = "-"
			end
			exclusion_string = exclusion_string .. details.letter
		end
	end
	addGMFunction(string.format(_("buttonGM","+Exclude%s"),exclusion_string),function()
		setFleetExclusions(caller)
	end)
	addGMFunction(string.format(_("buttonGM","selectivity: %s"),pool_selectivity_labels[pool_selectivity]),function()
		if pool_selectivity == "full" then
			pool_selectivity = "less/heavy"
		elseif pool_selectivity == "less/heavy" then
			pool_selectivity = "more/light"
		elseif pool_selectivity == "more/light" then
			pool_selectivity = "full"
		end
		setFleetComposition(caller)
	end)
	if pool_selectivity ~= "full" then
		addGMFunction(string.format(_("buttonGM","Increase Pool: %i"),template_pool_size),function()
			if template_pool_size < 20 then
				template_pool_size = template_pool_size + 1
			else
				addGMMessage(_("msgGM","Reached maximum ship template selection pool size of 20"))
			end
			setFleetComposition(caller)
		end)
		addGMFunction(string.format(_("buttonGM","Decrease Pool: %i"),template_pool_size),function()
			if template_pool_size > 1 then
				template_pool_size = template_pool_size - 1
			else
				addGMMessage(_("msgGM","Reached minimum ship template selection pool size of 1"))
			end
			setFleetComposition(caller)
		end)
	end
end
function setFleetGroupComposition(caller)
	clearGMFunctions()
	addGMFunction(_("buttonGM","-From composition group"),function()
		string.format("")	--necessary to have global reference for Serious Proton engine
		setFleetComposition(caller)
	end)
	for cat,desc in pairs(fleet_composition_labels) do
		local button_label = desc
		if fleetComposition == cat then
			button_label = button_label .. "*"
		end
		addGMFunction(button_label,function()
			fleetComposition = cat
			caller()
		end)
	end
end
function setFleetExclusions(caller)
	clearGMFunctions()
	addGMFunction(_("buttonGM","-From composition"),function()
		string.format("")	--necessary to have global reference for Serious Proton engine
		caller()
	end)
	addGMFunction(_("buttonGM","-From Exclusions"),function()
		string.format("")	--necessary to have global reference for Serious Proton engine
		setFleetComposition(caller)
	end)
	for name, details in pairs(fleet_exclusions) do
		local button_label = name
		if details.exclude then
			button_label = button_label .. "*"
		end
		addGMFunction(button_label,function()
			if details.exclude then
				details.exclude = false
			else
				details.exclude = true
			end
			setFleetExclusions(caller)
		end)
	end
end
function setPrebuiltFormationShape()
	clearGMFunctions()
	addGMFunction("+V",setPrebuiltFormationCategoryV)
	addGMFunction("+A",setPrebuiltFormationCategoryA)
	addGMFunction(_("buttonGM","+Line"),setPrebuiltFormationCategoryLine)
	addGMFunction("+M",setPrebuiltFormationCategoryM)
	addGMFunction("+W",setPrebuiltFormationCategoryW)
	addGMFunction("+X",setPrebuiltFormationCategoryX)
	addGMFunction("+H",setPrebuiltFormationCategoryH)
	addGMFunction("+*",setPrebuiltFormationCategorySplat)
	addGMFunction("+O",setPrebuiltFormationCategoryOh)	
end
function setPrebuiltFormationCategoryOh()
	clearGMFunctions()
	local form_list = {"O","O2R","O3R","O4R","O5R","O6R","O7R"}
	for idx, form in ipairs(form_list) do
		local button_label = form
		if form == formation_shape then
			button_label = button_label .. "*"
		end
		addGMFunction(button_label,function()
			formation_shape = form
			setPrebuiltFleet()
		end)
	end
end
function setPrebuiltFormationCategorySplat()
	clearGMFunctions()
	local form_list = {"*","*12","*18"}
	for idx, form in ipairs(form_list) do
		local button_label = form
		if form == formation_shape then
			button_label = button_label .. "*"
		end
		addGMFunction(button_label,function()
			formation_shape = form
			setPrebuiltFleet()
		end)
	end
end
function setPrebuiltFormationCategoryH()
	clearGMFunctions()
	local form_list = {"H"}
	for idx, form in ipairs(form_list) do
		local button_label = form
		if form == formation_shape then
			button_label = button_label .. "*"
		end
		addGMFunction(button_label,function()
			formation_shape = form
			setPrebuiltFleet()
		end)
	end
end
function setPrebuiltFormationCategoryX()
	clearGMFunctions()
	local form_list = {"X","X8","Xac","Xac8","X12","Xac12","X16","Xac16"}
	for idx, form in ipairs(form_list) do
		local button_label = form
		if form == formation_shape then
			button_label = button_label .. "*"
		end
		addGMFunction(button_label,function()
			formation_shape = form
			setPrebuiltFleet()
		end)
	end
end
function setPrebuiltFormationCategoryW()
	clearGMFunctions()
	local form_list = {"W","W6","Wac","Wac6"}
	for idx, form in ipairs(form_list) do
		local button_label = form
		if form == formation_shape then
			button_label = button_label .. "*"
		end
		addGMFunction(button_label,function()
			formation_shape = form
			setPrebuiltFleet()
		end)
	end
end
function setPrebuiltFormationCategoryM()
	clearGMFunctions()
	local form_list = {"M","M6","Mac","Mac6"}
	for idx, form in ipairs(form_list) do
		local button_label = form
		if form == formation_shape then
			button_label = button_label .. "*"
		end
		addGMFunction(button_label,function()
			formation_shape = form
			setPrebuiltFleet()
		end)
	end
end
function setPrebuiltFormationCategoryLine()
	clearGMFunctions()
	local form_list = {"/","/ac","-","-4","\\","\\ac","|","|4"}
	for idx, form in ipairs(form_list) do
		local button_label = form
		if form == formation_shape then
			button_label = button_label .. "*"
		end
		addGMFunction(button_label,function()
			formation_shape = form
			setPrebuiltFleet()
		end)
	end
end
function setPrebuiltFormationCategoryA()
	clearGMFunctions()
	local form_list = {"A","A4","Aac","Aac4"}
	for idx, form in ipairs(form_list) do
		local button_label = form
		if form == formation_shape then
			button_label = button_label .. "*"
		end
		addGMFunction(button_label,function()
			formation_shape = form
			setPrebuiltFleet()
		end)
	end
end
function setPrebuiltFormationCategoryV()
	clearGMFunctions()
	local form_list = {"V","V4","Vac","Vac4"}
	for idx, form in ipairs(form_list) do
		local button_label = form
		if form == formation_shape then
			button_label = button_label .. "*"
		end
		addGMFunction(button_label,function()
			formation_shape = form
			setPrebuiltFleet()
		end)
	end
end
function setPrebuiltComposition()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main from Composition"),mainGMButtons)
	addGMFunction(_("buttonGM","-Fleet or Ship"),spawnGMShips)
	addGMFunction(_("buttonGM","-Fleet Spawn"),spawnGMFleet)
	addGMFunction(_("buttonGM","-Formation"),setPrebuiltFleet)
	addGMFunction(string.format(_("buttonGM","+Lead:%s"),prebuilt_leader),setPrebuiltLeader)
	addGMFunction(string.format(_("buttonGM","+Follow:%s"),prebuilt_follower),setPrebuiltFollower)
end
function setPrebuiltFollower()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main from Follow"),mainGMButtons)
	addGMFunction(_("buttonGM","-Fleet or Ship"),spawnGMShips)
	addGMFunction(_("buttonGM","-Fleet Spawn"),spawnGMFleet)
	addGMFunction(_("buttonGM","-Formation"),setPrebuiltFleet)
	--sort
	for follower, leader_list in pairs(prebuilt_followers) do
		local follower_suffix = ""
		if follower == prebuilt_follower then
			follower_suffix = "*"
		end
		local leader_suffix = ""
		for idx, leader in ipairs(leader_list) do
			if leader == prebuilt_leader then
				leader_suffix = "*"
				break
			end
		end
		addGMFunction(string.format("%s%s%s",follower,leader_suffix,follower_suffix),function()
			prebuilt_follower = follower
			local leader_list = prebuilt_followers[prebuilt_follower]
			local leader_in_list = false
			for idx, leader in ipairs(leader_list) do
				if leader == prebuilt_leader then
					leader_in_list = true
					break
				end
			end
			if not leader_in_list then
				prebuilt_leader = leader_list[1]
			end
			setPrebuiltComposition()
		end)
	end
end
function setPrebuiltLeader()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main from Lead"),mainGMButtons)
	addGMFunction(_("buttonGM","-Fleet or Ship"),spawnGMShips)
	addGMFunction(_("buttonGM","-Fleet Spawn"),spawnGMFleet)
	addGMFunction(_("buttonGM","-Formation"),setPrebuiltFleet)
	--sort
	for leader, follower_list in pairs(prebuilt_leaders) do
		local leader_suffix = ""
		if leader == prebuilt_leader then
			leader_suffix = "*"
		end
		local follower_suffix = ""
		for idx, follower in ipairs(follower_list) do
			if follower == prebuilt_follower then
				follower_suffix = "*"
				break
			end
		end
		addGMFunction(string.format("%s%s%s",leader,leader_suffix,follower_suffix),function()
			prebuilt_leader = leader
			local follower_list = prebuilt_leaders[prebuilt_leader]
			local follower_in_list = false
			for idx, follower in ipairs(follower_list) do
				if follower == prebuilt_follower then
					follower_in_list = true
					break
				end
			end
			if not follower_in_list then
				prebuilt_follower = follower_list[1]
			end
			setPrebuiltComposition()
		end)
	end
end
function setPrebuiltFormationSpacing()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main from Spacing"),mainGMButtons)
	addGMFunction(_("buttonGM","-Fleet or Ship"),spawnGMShips)
	addGMFunction(_("buttonGM","-Fleet Spawn"),spawnGMFleet)
	addGMFunction(_("buttonGM","-Formation"),setPrebuiltFleet)
	local minimum_spacing = ship_template[prebuilt_leader].dist + ship_template[prebuilt_follower].dist + 300
	local maximum_spacing = 3000
	if formation_spacing == minimum_spacing then
		for i=minimum_spacing,minimum_spacing+400,100 do
			local button_label = string.format(_("buttonGM","Spacing %.1fu"),i/1000)
			if i == formation_spacing then
				button_label = button_label .. "*"
			end
			addGMFunction(button_label,function()
				formation_spacing = i
				setPrebuiltFormationSpacing()
			end)
		end
	elseif formation_spacing == minimum_spacing + 100 then
		for i=minimum_spacing+100,minimum_spacing+500,100 do
			local button_label = string.format(_("buttonGM","Spacing %.1fu"),i/1000)
			if i == formation_spacing then
				button_label = button_label .. "*"
			end
			addGMFunction(button_label,function()
				formation_spacing = i
				setPrebuiltFormationSpacing()
			end)
		end
	elseif formation_spacing == maximum_spacing then
		for i=maximum_spacing-400,maximum_spacing,100 do
			local button_label = string.format(_("buttonGM","Spacing %.1fu"),i/1000)
			if i == formation_spacing then
				button_label = button_label .. "*"
			end
			addGMFunction(button_label,function()
				formation_spacing = i
				setPrebuiltFormationSpacing()
			end)
		end
	elseif formation_spacing == maximum_spacing - 100 then
		for i=maximum_spacing-500,maximum_spacing-100,100 do
			local button_label = string.format(_("buttonGM","Spacing %.1fu"),i/1000)
			if i == formation_spacing then
				button_label = button_label .. "*"
			end
			addGMFunction(button_label,function()
				formation_spacing = i
				setPrebuiltFormationSpacing()
			end)
		end
	else
		for i=formation_spacing-200,formation_spacing+200,100 do
			local button_label = string.format(_("buttonGM","Spacing %.1fu"),i/1000)
			if i == formation_spacing then
				button_label = button_label .. "*"
			end
			addGMFunction(button_label,function()
				formation_spacing = i
				setPrebuiltFormationSpacing()
			end)
		end
	end
end
function setPrebuiltFleetTarget()
	if gm_click_mode == "set prebuilt target" then
		gm_click_mode = nil
		onGMClick(nil)
	else
		local prev_mode = gm_click_mode
		gm_click_mode = "set prebuilt target"
		onGMClick(gmClicksetPrebuiltFleetTarget)
		if prev_mode ~= nil then
			addGMMessage(string.format(_("msgGM","Cancelled current GM Click mode\n   %s\nIn favor of\n   %s\nGM click mode."),gm_click_mode_names[prev_mode],gm_click_mode_names[gm_click_mode]))
		end
	end
	setPrebuiltFleet()
end
function gmClicksetPrebuiltFleetTarget(x,y)
	local leader_ship = ship_template[prebuilt_leader].create(fleetSpawnFaction,prebuilt_leader)
	local fleet_prefix = generateCallSignPrefix()
	leader_ship:setPosition(prebuilt_fleet_x,prebuilt_fleet_y)
	local prebuilt_angle = angleFromVectorNorth(x,y,prebuilt_fleet_x,prebuilt_fleet_y)
	leader_ship:setHeading(prebuilt_angle)
	leader_ship.formation_ships = {}
	for idx, form in ipairs(fly_formation[formation_shape]) do
		local ship = ship_template[prebuilt_follower].create(fleetSpawnFaction,prebuilt_follower)
		local form_x, form_y = vectorFromAngleNorth(prebuilt_angle + form.angle, form.dist * formation_spacing)
		local form_prime_x, form_prime_y = vectorFromAngle(form.angle, form.dist * formation_spacing)
		ship:setPosition(prebuilt_fleet_x + form_x, prebuilt_fleet_y + form_y):setHeading(prebuilt_angle):orderFlyFormation(leader_ship,form_prime_x,form_prime_y)
		ship:setCallSign(generateCallSign(fleet_prefix))
		table.insert(leader_ship.formation_ships,ship)
	end
	leader_ship:orderFlyTowards(x,y)
	gm_click_mode = nil
	onGMClick(nil)
	setPrebuiltFleet()
end
function spawnPrebuiltFleet()
	if gm_click_mode == "spawn prebuilt fleet" then
		gm_click_mode = nil
		onGMClick(nil)
	else
		local prev_mode = gm_click_mode
		gm_click_mode = "spawn prebuilt fleet"
		onGMClick(gmClickSpawnPrebuiltFleet)
		if prev_mode ~= nil then
			addGMMessage(string.format(_("msgGM","Cancelled current GM Click mode\n   %s\nIn favor of\n   %s\nGM click mode."),gm_click_mode_names[prev_mode],gm_click_mode_names[gm_click_mode]))
		end
	end
	setPrebuiltFleet()
end
function gmClickSpawnPrebuiltFleet(x,y)
	prebuilt_fleet_x = x
	prebuilt_fleet_y = y
	gm_click_mode = "set prebuilt target"
	onGMClick(gmClicksetPrebuiltFleetTarget)
	setPrebuiltFleet()
end
--	Spawn single non-stock ship functions
function spawnGMShip()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main From Ship Spawn"),mainGMButtons)
	addGMFunction(_("buttonGM","-Fleet or Ship"),spawnGMShips)
	returnFromFleetSpawnLocation = spawnGMShip
	addGMFunction(string.format("+%s",fleet_spawn_location_labels[fleetSpawnLocation]),setFleetSpawnLocation)
	if gm_click_mode == "ship spawn" then
		addGMFunction(string.format(_("buttonGM",">Spawn %s<"),individual_ship),parmSpawnShip)
	else
		addGMFunction(string.format(_("buttonGM","Spawn %s"),individual_ship),parmSpawnShip)
	end
	sandbox_templates = {}
	for name, details in pairs(ship_template) do
		if details.create ~= stockTemplate then
			local sort_name = name
			if details.unusual then
				sort_name = "a" .. name
			else
				sort_name = "b" .. name
			end
			table.insert(sandbox_templates,sort_name)
		end
	end
	table.sort(sandbox_templates)
	for idx, name in ipairs(sandbox_templates) do
		local short_name = string.sub(name,2)
		local button_label = short_name
		if string.sub(name,1,1) == "a" then
			button_label = "U-" .. short_name
		end
		if short_name == individual_ship then
			button_label = button_label .. "*"
		end
		addGMFunction(button_label,function()
			individual_ship = short_name
			spawnGMShip()
		end)
	end
end
function parmSpawnShip()
	local fsx = 0
	local fsy = 0
	if fleetSpawnLocation == "At Click" then
		if gm_click_mode == nil then
			gm_click_mode = "ship spawn"
			onGMClick(gmClickShipSpawn)
		elseif gm_click_mode == "ship spawn" then
			gm_click_mode = nil
			onGMClick(nil)
		else
			local prev_mode = gm_click_mode
			gm_click_mode = "ship spawn"
			onGMClick(gmClickShipSpawn)
			addGMMessage(string.format(_("msgGM","Cancelled current GM Click mode\n   %s\nIn favor of\n   %s\nGM click mode."),gm_click_mode_names[prev_mode],gm_click_mode_names[gm_click_mode]))
		end
		spawnGMShip()
	else
		local object_list = getGMSelection()
		if #object_list < 1 then
			addGMMessage(_("msgGM","Fleet spawn failed: nothing selected for spawn location determination"))
			return
		end 
		local ship = ship_template[individual_ship].create(fleetSpawnFaction,individual_ship)
		if fleetOrders == "Roaming" then
			ship:orderRoaming()
		elseif fleetOrders == "Idle" then
			ship:orderIdle()
		elseif fleetOrders == "Stand Ground" then
			ship:orderStandGround()
		end
		if fleetChange ~= "unmodified" then
			modifyShip(ship)
		end
		if fleetSpawnLocation == "Ambush" then
			fsx, fsy = object_list[1]:getPosition()
			local ambush_angle = random(0,360)
			local dex, dey = vectorFromAngleNorth(ambush_angle,fleetAmbushDistance*1000)
			ship:setPosition(fsx+dex,fsy+dey):setHeading(ambush_angle + 180)
		else
			ship:setPosition(fsx,fsy)
		end
	end
end
function gmClickShipSpawn(x,y)
	local ship = ship_template[individual_ship].create(fleetSpawnFaction,individual_ship)
	ship:setCallSign(generateCallSign())
	if ship_template[individual_ship].base then
		if commsStation ~= nil then
			ship:setCommsScript(""):setCommsFunction(commsStation)
		end
	else
		if commsShip ~= nil then
			ship:setCommsScript(""):setCommsFunction(commsShip)
		end
	end
	ship:setPosition(x,y)
	ship:orderRoaming()
	if fleetOrders == "Roaming" then
		ship:orderRoaming()
	elseif fleetOrders == "Idle" then
		ship:orderIdle()
	elseif fleetOrders == "Stand Ground" then
		ship:orderStandGround()
	end
	if fleetChange ~= "unmodified" then
		modifyShip(ship)
	end
end
--	Transform CPU ship into a carrier by having it spawn fighters
function setFighterWing()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main From Ftr Wing"),mainGMButtons)
	addGMFunction(_("buttonGM","-Spawn Ships"),spawnGMShips)
	addGMFunction(string.format(_("buttonGM","+Type %s"),wing_type),function()
		local wing_types = {}
		local wing_type_candidates = {
			"MT52 Hornet",
			"MU52 Hornet",
			"MV52 Hornet",
			"MT55 Hornet",
			"Dagger",
			"Fighter",
			"K3 Fighter",
			"K2 Fighter",
		}
		for i,wing in ipairs(wing_type_candidates) do
			if ship_template[wing] ~= nil then
				table.insert(wing_types,wing)
			end
		end
		clearGMFunctions()
		for idx, fighter in ipairs(wing_types) do
			local button_label = fighter
			if fighter == wing_type then
				button_label = button_label .. "*"
			end
			addGMFunction(button_label,function()
				wing_type = fighter
				setFighterWing()
			end)
		end
	end)
	addGMFunction(string.format(_("buttonGM","+Count %s"),wing_count),function()
		clearGMFunctions()
		for i=2,9 do
			local button_label = _("buttonGM","Wing Count ") .. i
			if i == wing_count then
				button_label = button_label .. "*"
			end
			addGMFunction(button_label, function()
				wing_count = i
				setFighterWing()
			end)
		end
	end)
	if temp_carrier ~= nil and temp_carrier:isValid() then
		addGMFunction(string.format(_("buttonGM","Spawn Wing:%s"),temp_carrier:getCallSign()),function()
			local start_angle = random(0,360)
			local spawn_dist = nil
			if temp_carrier ~= nil and temp_carrier:isValid() then
				local template_name = temp_carrier:getTypeName()
				if template_name ~= nil then
					spawn_dist = ship_template[template_name].dist
					if spawn_dist ~= nil then
					else
						addGMMessage(string.format(_("msgGM","The ship template table does not have a dist entry for %s. Defaulting to 400 distance"),template_name))
						spawn_dist = 400
					end
				else
					addGMMessage(string.format(_("msgGM","No template for %s. Defaulting to 400 distance"),temp_carrier:getCallSign()))
					spawn_dist = 400
				end
				local fleet_prefix = generateCallSignPrefix()
				for i=1,wing_count do
					local fwc_x, fwc_y = temp_carrier:getPosition()
					local spawn_angle = start_angle + 360/wing_count*i
					local dc_x, dc_y = vectorFromAngleNorth(spawn_angle,spawn_dist)
					local ship = ship_template[wing_type].create(temp_carrier:getFaction(),wing_type)
					ship:setPosition(fwc_x + dc_x, fwc_y + dc_y):setHeading(spawn_angle):orderDefendTarget(temp_carrier)
					ship:setCallSign(generateCallSign(fleet_prefix))
				end
			else
				addGMMessage(_("msgGM","Selected carrier object is no longer valid. Select another. No action taken"))
			end
			spawnGMShips()
		end)
	end
end
