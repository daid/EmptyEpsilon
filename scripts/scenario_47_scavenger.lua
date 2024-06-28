-- Name: Scurvy Scavenger
-- Description: Stay alive while scavenging treasures. Length: > 2 hours
---
--- Version 1
-- Type: Mission
-- Type: Replayable Mission
-- Setting[Enemies]: Configures strength and/or number of enemies in this scenario
-- Enemies[Easy]: Fewer or weaker enemies
-- Enemies[Normal|Default]: Normal number or strength of enemies
-- Enemies[Hard]: More or stronger enemies
-- Setting[Murphy]: Configures the perversity of the universe according to Murphy's law
-- Murphy[Easy]: Random factors are more in your favor
-- Murphy[Normal|Default]: Random factors are normal
-- Murphy[Hard]: Random factors are more against you

require("utils.lua")
require("cpu_ship_diversification_scenario_utility.lua")
require("place_station_scenario_utility.lua")
require("generate_call_sign_scenario_utility.lua")
require("spawn_ships_scenario_utility.lua")

function init()
	scenario_version = "1.1.2"
	ee_version = "2023.06.17"
	print(string.format("    ----    Scenario: Scurvy Scavenger    ----    Version %s    ----    Tested with EE version %s    ----",scenario_version,ee_version))
	print(_VERSION)
	stationCommsDiagnostic = false
	exuari_harass_diagnostic = false
	spawn_enemy_diagnostic = false
	efficient_battery_diagnostic = false
	prefix_length = 0
	suffix_index = 0
	contract_eligible = false			--should start out as false
	transition_contract_message = false	--should start out as false
	contract_station = {}
	setVariations()
	setConstants()	--missle type names, template names and scores, deployment directions, player ship names, etc.
	player = PlayerSpaceship():setFaction("Independent"):setTemplate("Striker"):setJumpDrive(false):setWarpDrive(false):setLongRangeRadarRange(25000)
	plot_faction = "Independent"
	setPlayer()
	allowNewPlayerShips(false)
	--stationCommunication could be nil (default), commsStation (embedded function) or comms_station_enhanced (external script)
	stationCommunication = "commsStation"
	stationStaticAsteroids = true
	primaryOrders = _("orders-comms", "No primary orders")
	plot1 = exuariHarassment
	plotH = healthCheck				--Damage to ship can kill repair crew members
	healthCheckTimer = 5
	healthCheckTimerInterval = 5
	independent_station = {}
	station_list = {}
--	print("init: place first station")
	--place first station where missions start
	first_station_angle = random(0,360)
	local player_to_station_distance = random(8000,15000)
	psx, psy = vectorFromAngle(first_station_angle,player_to_station_distance)
	first_station_x = psx
	first_station_y = psy
	local pStation = placeStation(psx,psy,nil,"Independent")
	table.insert(independent_station,pStation)
	table.insert(station_list,pStation)
	first_station = pStation
	first_station.comms_data.weapon_available.Homing = true
	first_station.comms_data.weapon_available.EMP = true
	first_station.comms_data.weapon_available.Nuke = true
	first_station.comms_data.weapon_cost = {Homing = 2, HV, HVLI = math.random(1,3), Mine = math.random(2,5), Nuke = 12, EMP = 9}
--	print("init: place first enemy station")
	--place first enemy station for first mission 
	exuari_station = {}
	local exuari_station_angle = first_station_angle + random(-20,20)
	local enemy_station_distance = random(11000,15000)
	cnx, cny = vectorFromAngle(exuari_station_angle,enemy_station_distance-2500)
	concealing_nebula = Nebula():setPosition(first_station_x+cnx,first_station_y+cny)
	nebula_list = {}
	table.insert(nebula_list,concealing_nebula)
	for i=1,math.random(2,2+difficulty*2) do
		local ref_x, ref_y = nebula_list[#nebula_list]:getPosition()
		local far_enough = true
		local expand_distance = 0
		local new_x, new_y = vectorFromAngle(random(0,360),random(4000,20000+expand_distance))
		repeat
			far_enough = true
			new_x, new_y = vectorFromAngle(random(0,360),random(4000,20000+expand_distance))
			new_x = new_x + ref_x
			new_y = new_y + ref_y
			for j=1,#nebula_list do
				if distance(nebula_list[j],new_x,new_y) < 4000 then
					far_enough = false
				end
			end
			expand_distance = expand_distance + 1000
		until(far_enough)
		local new_nebula = Nebula():setPosition(new_x,new_y)
		table.insert(nebula_list,new_nebula)
	end
	psx, psy = vectorFromAngle(exuari_station_angle,enemy_station_distance)
	psx = psx + first_station_x
	psy = psy + first_station_y
	pStation = placeStation(psx,psy,"Sinister","Exuari","Large Station")
	table.insert(exuari_station,pStation)
	table.insert(station_list,pStation)
	exuari_harassing_station = pStation
	evx, evy = vectorFromAngle(exuari_station_angle,20000)
	evx = evx + psx
	evy = evy + psy
	ev_angle = (exuari_station_angle + 180) % 360	--exuari vengeance attack angle
--	print("init: place research asteroids")
	local arx, ary, brx, bry, asteroids = curvaceousAsteroids1(first_station_x, first_station_y, player_to_station_distance)
	research_asteroids = asteroids
	--place artifact near asteroids
	local avx, avy = vectorFromAngle(random(0,360),350-(difficulty*100))
	beam_damage_artifact = Artifact():setPosition(arx+avx,ary+avy):setModel("artifact4"):setScanningParameters(difficulty*2,difficulty*2):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1))
	beam_damage_artifact:setDescriptions(_("scienceDescription-artifact", "Object of unknown origin"),_("scienceDescription-artifact", "Object of unknown origin, advanced technology detected")):allowPickup(true):onPickUp(beamDamageArtifactPickup)
	avx, avy = vectorFromAngle(random(0,360),350-(difficulty*100))
	burn_out_artifact = Artifact():setPosition(brx+avx,bry+avy):setModel("artifact4"):setScanningParameters(difficulty*2,difficulty*2):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1))
	burn_out_artifact:setDescriptions(_("scienceDescription-artifact", "Object of unknown origin"),_("scienceDescription-artifact", "Object of unknown origin, advanced technology detected")):allowPickup(true):onPickUp(burnOutArtifactPickup)
	if difficulty >= 1 then
		avx, avy = vectorFromAngle(random(0,360),350-(difficulty*100))
		burn_out_artifact_2 = Artifact():setPosition(crx+avx,cry+avy):setModel("artifact4"):setScanningParameters(difficulty*2,difficulty*2):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1))
		burn_out_artifact_2:setDescriptions(_("scienceDescription-artifact", "Object of unknown origin"),_("scienceDescription-artifact", "Object of unknown origin, advanced technology detected")):allowPickup(true):onPickUp(burnOutArtifactPickup)
	end
	if difficulty > 1 then
		avx, avy = vectorFromAngle(random(0,360),350-(difficulty*100))
		burn_out_artifact_3 = Artifact():setPosition(drx+avx,dry+avy):setModel("artifact4"):setScanningParameters(difficulty*2,difficulty*2):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1))
		burn_out_artifact_3:setDescriptions(_("scienceDescription-artifact", "Object of unknown origin"),_("scienceDescription-artifact", "Object of unknown origin, advanced technology detected")):allowPickup(true):onPickUp(burnOutArtifactPickup)
	end
--	print("init: place second and third stations")
	--place second and third stations
	local second_station_angle = first_station_angle + random(90,140)
	if second_station_angle > 360 then 
		second_station_angle = second_station_angle - 360
	end
	player_to_station_distance = player_to_station_distance + random(1000,8000)
	psx, psy = vectorFromAngle(second_station_angle,player_to_station_distance)
	pStation = placeStation(psx,psy,nil,"Independent")
	table.insert(independent_station,pStation)
	table.insert(station_list,pStation)
	setOptionalAddBeamMission(pStation)
	second_station_angle = first_station_angle - random(90,140)
	if second_station_angle < 0 then 
		second_station_angle = second_station_angle + 360
	end
	player_to_station_distance = player_to_station_distance + random(1000,8000)
	psx, psy = vectorFromAngle(second_station_angle,player_to_station_distance)
	pStation = placeStation(psx,psy,nil,"Independent")
	table.insert(independent_station,pStation)
	table.insert(station_list,pStation)
	setOptionalEfficientBatteriesMisison(pStation)
	setInitialContractDetails()
	first_station:setSharesEnergyWithDocked(true)
	first_station:setRepairDocked(true)
	first_station.comms_data.scan_repair =			true
	first_station.comms_data.jump_overcharge =		true
--	print("init: set work transports")
	--Independent trio transports
	plotT = workingTransports
	transports_around_independent_trio = {}
	transportCheckDelayInterval = 4
	transportCheckDelayTimer = transportCheckDelayInterval
	local transportType = {"Personnel","Goods","Garbage","Equipment","Fuel"}
	local name = nil
	local prefix = generateCallSignPrefix(1)
	for i=1,3 do
		j = i + 2
		if j > 3 then
			j = j - 3
		end
		name = transportType[math.random(1,#transportType)]
		if random(1,100) < 30 then
			name = name .. " Jump Freighter " .. math.random(3, 5)
		else
			name = name .. " Freighter " .. math.random(1, 5)
		end
		psx, psy = independent_station[i]:getPosition()
		local tempTransport = CpuShip():setTemplate(name):setPosition(psx,psy):setFaction(independent_station[i]:getFaction()):setCommsScript(""):setCommsFunction(commsShip)
		tempTransport.targetStart = independent_station[i]
		tempTransport.targetEnd = independent_station[j]
		if random(1,100) < 50 then
			tempTransport:orderDock(tempTransport.targetStart)
		else
			tempTransport:orderDock(tempTransport.targetEnd)
		end
		tempTransport:setCallSign(generateCallSign(prefix))
		table.insert(transports_around_independent_trio,tempTransport)
	end
	mainGMButtons()
--	print("end of init")
	allowNewPlayerShips(false)
end
--	Initialization
function setVariations()
	local enemy_config = {
		["Easy"] =		{number = .5},
		["Normal"] =	{number = 1},
		["Hard"] =		{number = 2},
	}
	enemy_power =	enemy_config[getScenarioSetting("Enemies")].number
	local murphy_config = {
		["Easy"] =		{number = .5,	rep = 70,	adverse = .999,	lose_coolant = .99999,	gain_coolant = .005},
		["Normal"] =	{number = 1,	rep = 50,	adverse = .995,	lose_coolant = .99995,	gain_coolant = .001},
		["Hard"] =		{number = 2,	rep = 30,	adverse = .99,	lose_coolant = .9999,	gain_coolant = .0001},
	}
	difficulty =	murphy_config[getScenarioSetting("Murphy")].number
	gameTimeLimit = 0
	playWithTimeLimit = false
end
function setConstants()
	repeatExitBoundary = 100
	scarceResources = false
	missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	pool_selectivity = "full"
	ship_template = {	--ordered by relative strength
		["Gnat"] =				{strength = 2,	short_range_radar = 4500,	create = gnat},
		["Lite Drone"] =		{strength = 3,	short_range_radar = 5000,	create = droneLite},
		["Jacket Drone"] =		{strength = 4,	short_range_radar = 5000,	create = droneJacket},
		["Ktlitan Drone"] =		{strength = 4,	short_range_radar = 5000,	create = stockTemplate},
		["Heavy Drone"] =		{strength = 5,	short_range_radar = 5500,	create = droneHeavy},
		["Adder MK3"] =			{strength = 5,	short_range_radar = 5000,	create = stockTemplate},
		["MT52 Hornet"] =		{strength = 5,	short_range_radar = 5000,	create = stockTemplate},
		["MU52 Hornet"] =		{strength = 5,	short_range_radar = 5000,	create = stockTemplate},
		["Dagger"] =			{strength = 6,	short_range_radar = 5000,	create = stockTemplate},
		["MV52 Hornet"] =		{strength = 6,	short_range_radar = 5000,	create = hornetMV52},
		["MT55 Hornet"] =		{strength = 6,	short_range_radar = 5000,	create = hornetMT55},
		["Adder MK4"] =			{strength = 6,	short_range_radar = 5000,	create = stockTemplate},
		["Fighter"] =			{strength = 6,	short_range_radar = 5000,	create = stockTemplate},
		["Ktlitan Fighter"] =	{strength = 6,	short_range_radar = 5000,	create = stockTemplate},
		["FX64 Hornet"] =		{strength = 7,	short_range_radar = 5000,	create = hornetFX64},
		["Blade"] =				{strength = 7,	short_range_radar = 5000,	create = stockTemplate},
		["Gunner"] =			{strength = 7,	short_range_radar = 5000,	create = stockTemplate},
		["K2 Fighter"] =		{strength = 7,	short_range_radar = 5000,	create = k2fighter},
		["Adder MK5"] =			{strength = 7,	short_range_radar = 5000,	create = stockTemplate},
		["WX-Lindworm"] =		{strength = 7,	short_range_radar = 5500,	create = stockTemplate},
		["K3 Fighter"] =		{strength = 8,	short_range_radar = 5000,	create = k3fighter},
		["Shooter"] =			{strength = 8,	short_range_radar = 5000,	create = stockTemplate},
		["Jagger"] =			{strength = 8,	short_range_radar = 5000,	create = stockTemplate},
		["Adder MK6"] =			{strength = 8,	short_range_radar = 5000,	create = stockTemplate},
		["Ktlitan Scout"] =		{strength = 8,	short_range_radar = 7000,	create = stockTemplate},
		["WZ-Lindworm"] =		{strength = 9,	short_range_radar = 5500,	create = wzLindworm},
		["Adder MK7"] =			{strength = 9,	short_range_radar = 5000,	create = stockTemplate},
		["Adder MK8"] =			{strength = 10,	short_range_radar = 5500,	create = stockTemplate},
		["Adder MK9"] =			{strength = 11,	short_range_radar = 6000,	create = stockTemplate},
		["Nirvana R3"] =		{strength = 12,	short_range_radar = 5000,	create = stockTemplate},
		["Phobos R2"] =			{strength = 13,	short_range_radar = 5000,	create = phobosR2},
		["Missile Cruiser"] =	{strength = 14,	short_range_radar = 7000,	create = stockTemplate},
		["Waddle 5"] =			{strength = 15,	short_range_radar = 5000,	create = waddle5},
		["Jade 5"] =			{strength = 15,	short_range_radar = 5000,	create = jade5},
		["Phobos T3"] =			{strength = 15,	short_range_radar = 5000,	create = stockTemplate},
		["Guard"] =				{strength = 15,	short_range_radar = 5000,	create = stockTemplate},
		["Piranha F8"] =		{strength = 15,	short_range_radar = 6000,	create = stockTemplate},
		["Piranha F12"] =		{strength = 15,	short_range_radar = 6000,	create = stockTemplate},
		["Piranha F12.M"] =		{strength = 16,	short_range_radar = 6000,	create = stockTemplate},
		["Phobos M3"] =			{strength = 16,	short_range_radar = 5500,	create = stockTemplate},
		["Farco 3"] =			{strength = 16,	short_range_radar = 8000,	create = farco3},
		["Farco 5"] =			{strength = 16,	short_range_radar = 8000,	create = farco5},
		["Karnack"] =			{strength = 17,	short_range_radar = 5000,	create = stockTemplate},
		["Gunship"] =			{strength = 17,	short_range_radar = 5000,	create = stockTemplate},
		["Phobos T4"] =			{strength = 18,	short_range_radar = 5000,	create = phobosT4},
		["Cruiser"] =			{strength = 18,	short_range_radar = 6000,	create = stockTemplate},
		["Nirvana R5"] =		{strength = 19,	short_range_radar = 5000,	create = stockTemplate},
		["Farco 8"] =			{strength = 19,	short_range_radar = 8000,	create = farco8},
		["Nirvana R5A"] =		{strength = 20,	short_range_radar = 5000,	create = stockTemplate},
		["Adv. Gunship"] =		{strength = 20,	short_range_radar = 7000,	create = stockTemplate},
		["Ktlitan Worker"] =	{strength = 20,	short_range_radar = 5000,	create = stockTemplate},
		["Farco 11"] =			{strength = 21,	short_range_radar = 8000,	create = farco11},
		["Storm"] =				{strength = 22,	short_range_radar = 6000,	create = stockTemplate},
		["Warden"] =			{strength = 22,	short_range_radar = 6000,	create = stockTemplate},
		["Racer"] =				{strength = 22,	short_range_radar = 5000,	create = stockTemplate},
		["Strike"] =			{strength = 23,	short_range_radar = 5500,	create = stockTemplate},
		["Dash"] =				{strength = 23,	short_range_radar = 5500,	create = stockTemplate},
		["Farco 13"] =			{strength = 24,	short_range_radar = 5000,	create = farco13},
		["Sentinel"] =			{strength = 24,	short_range_radar = 5000,	create = stockTemplate},
		["Ranus U"] =			{strength = 25,	short_range_radar = 6000,	create = stockTemplate},
		["Flash"] =				{strength = 25,	short_range_radar = 6000,	create = stockTemplate},
		["Ranger"] =			{strength = 25,	short_range_radar = 6000,	create = stockTemplate},
		["Buster"] =			{strength = 25,	short_range_radar = 6000,	create = stockTemplate},
		["Stalker Q7"] =		{strength = 25,	short_range_radar = 5000,	create = stockTemplate},
		["Stalker R7"] =		{strength = 25,	short_range_radar = 5000,	create = stockTemplate},
		["Whirlwind"] =			{strength = 26,	short_range_radar = 6000,	create = whirlwind},
		["Hunter"] =			{strength = 26,	short_range_radar = 5500,	create = stockTemplate},
		["Adv. Striker"] =		{strength = 27,	short_range_radar = 5000,	create = stockTemplate},
		["Tempest"] =			{strength = 30,	short_range_radar = 6000,	create = tempest},
		["Strikeship"] =		{strength = 30,	short_range_radar = 5000,	create = stockTemplate},
		["Maniapak"] =			{strength = 34,	short_range_radar = 6000,	create = maniapak},
		["Fiend G4"] =			{strength = 35,	short_range_radar = 6500,	create = stockTemplate},
		["Cucaracha"] =			{strength = 36,	short_range_radar = 5000,	create = cucaracha},
		["Fiend G6"] =			{strength = 39,	short_range_radar = 6500,	create = stockTemplate},
		["Predator"] =			{strength = 42,	short_range_radar = 7500,	create = predator},
		["Ktlitan Breaker"] =	{strength = 45,	short_range_radar = 5000,	create = stockTemplate},
		["Hurricane"] =			{strength = 46,	short_range_radar = 6000,	create = hurricane},
		["Ktlitan Feeder"] =	{strength = 48,	short_range_radar = 5000,	create = stockTemplate},
		["Atlantis X23"] =		{strength = 50,	short_range_radar = 10000,	create = stockTemplate},
		["Ktlitan Destroyer"] =	{strength = 50,	short_range_radar = 9000,	create = stockTemplate},
		["K2 Breaker"] =		{strength = 55,	short_range_radar = 5000,	create = k2breaker},
		["Atlantis Y42"] =		{strength = 60,	short_range_radar = 10000,	create = atlantisY42},
		["Blockade Runner"] =	{strength = 63,	short_range_radar = 5500,	create = stockTemplate},
		["Starhammer II"] =		{strength = 70,	short_range_radar = 10000,	create = stockTemplate},
		["Enforcer"] =			{strength = 75,	short_range_radar = 9000,	create = enforcer},
		["Dreadnought"] =		{strength = 80,	short_range_radar = 9000,	create = stockTemplate},
		["Starhammer III"] =	{strength = 85,	short_range_radar = 12000,	create = starhammerIII},
		["Starhammer V"] =		{strength = 90,	short_range_radar = 15000,	create = starhammerV},
		["Tyr"] =				{strength = 150,short_range_radar = 9500,	create = tyr},
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
	--Player ship name lists to supplant standard randomized call sign generation
	playerShipNamesForMP52Hornet = {"Dragonfly","Scarab","Mantis","Yellow Jacket","Jimminy","Flik","Thorny","Buzz"}
	playerShipNamesForPiranha = {"Razor","Biter","Ripper","Voracious","Carnivorous","Characid","Vulture","Predator"}
	playerShipNamesForFlaviaPFalcon = {"Ladyhawke","Hunter","Seeker","Gyrefalcon","Kestrel","Magpie","Bandit","Buccaneer"}
	playerShipNamesForPhobosM3P = {"Blinder","Shadow","Distortion","Diemos","Ganymede","Castillo","Thebe","Retrograde"}
	playerShipNamesForAtlantis = {"Excaliber","Thrasher","Punisher","Vorpal","Protang","Drummond","Parchim","Coronado"}
	playerShipNamesForCruiser = {"Excelsior","Velociraptor","Thunder","Kona","Encounter","Perth","Aspern","Panther"}
	playerShipNamesForMissileCruiser = {"Projectus","Hurlmeister","Flinger","Ovod","Amatola","Nakhimov","Antigone"}
	playerShipNamesForFighter = {"Buzzer","Flitter","Zippiticus","Hopper","Molt","Stinger","Stripe"}
	playerShipNamesForBenedict = {"Elizabeth","Ford","Vikramaditya","Liaoning","Avenger","Naruebet","Washington","Lincoln","Garibaldi","Eisenhower"}
	playerShipNamesForKiriya = {"Cavour","Reagan","Gaulle","Paulo","Truman","Stennis","Kuznetsov","Roosevelt","Vinson","Old Salt"}
	playerShipNamesForStriker = {"Sparrow","Sizzle","Baza","Crow","Phoenix","Snowbird","Hawk"}
	playerShipNamesForLindworm = {"Seagull","Catapult","Blowhard","Flapper","Nixie","Pixie","Tinkerbell"}
	playerShipNamesForRepulse = {"Fiddler","Brinks","Loomis","Mowag","Patria","Pandur","Terrex","Komatsu","Eitan"}
	playerShipNamesForEnder = {"Mongo","Godzilla","Leviathan","Kraken","Jupiter","Saturn"}
	playerShipNamesForNautilus = {"October", "Abdiel", "Manxman", "Newcon", "Nusret", "Pluton", "Amiral", "Amur", "Heinkel", "Dornier"}
	playerShipNamesForHathcock = {"Hayha", "Waldron", "Plunkett", "Mawhinney", "Furlong", "Zaytsev", "Pavlichenko", "Pegahmagabow", "Fett", "Hawkeye", "Hanzo"}
	playerShipNamesForAtlantisII = {"Spyder", "Shelob", "Tarantula", "Aragog", "Charlotte"}
	playerShipNamesForProtoAtlantis = {"Narsil", "Blade", "Decapitator", "Trisect", "Sabre"}
	playerShipNamesForSurkov = {"Sting", "Sneak", "Bingo", "Thrill", "Vivisect"}
	playerShipNamesForRedhook = {"Headhunter", "Thud", "Troll", "Scalper", "Shark"}
	playerShipNamesForLeftovers = {"Foregone","Righteous","Masher"}
	commonGoods = {"food","medicine","nickel","platinum","gold","dilithium","tritanium","luxury","cobalt","impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	componentGoods = {"impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	mineralGoods = {"nickel","platinum","gold","dilithium","tritanium","cobalt"}
	characterNames = {"Frank Brown",
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
					  "Renata Rodriguez"}
end
function setPlayer()
	player = getPlayerShip(-1)
	if not player.name_assigned then
		if player:getTypeName() == "Striker" then
			if #playerShipNamesForStriker > 0 then
				local name_index = math.random(1,#playerShipNamesForStriker)
				player:setCallSign(playerShipNamesForStriker[name_index])
				table.remove(playerShipNamesForStriker,name_index)
			end
			player:setImpulseMaxSpeed(60)
			player.shipScore = 8
			player.maxCargo = 4
			player:setFaction(plot_faction)
		else
			if #playerShipNamesForLeftovers > 0 then
				name_index = math.random(1,#playerShipNamesForLeftovers)
				player:setCallSign(playerShipNamesForLeftovers[name_index])
				table.remove(playerShipNamesForLeftovers,name_index)
			end
			player.shipScore = 24
			player.maxCargo = 5
		end
		player.cargo = player.maxCargo
		player.maxRepairCrew = player:getRepairCrewCount()
		player.healthyShield = 1.0
		player.prevShield = 1.0
		player.healthyReactor = 1.0
		player.prevReactor = 1.0
		player.healthyManeuver = 1.0
		player.prevManeuver = 1.0
		player.healthyImpulse = 1.0
		player.prevImpulse = 1.0
		if player:getBeamWeaponRange(0) > 0 then
			player.healthyBeam = 1.0
			player.prevBeam = 1.0
		end
		if player:getWeaponTubeCount() > 0 then
			player.healthyMissile = 1.0
			player.prevMissile = 1.0
		end
		if player:hasWarpDrive() then
			player.healthyWarp = 1.0
			player.prevWarp = 1.0
		end
		if player:hasJumpDrive() then
			player.healthyJump = 1.0
			player.prevJump = 1.0
		end
		player:addReputationPoints(20)
		player.name_assigned = true
	end
end
function setInitialContractDetails()
	--contract details: first to second station
	first_station.comms_data.contract = {}
	first_station.comms_data.contract["one_to_two"] = {
		type = "start",
		prompt = string.format(_("contract-comms", "Deliver three %s to %s. Upon delivery, they will increase your hull strength"),independent_station[2].comms_data.characterGood,independent_station[2]:getCallSign()), 
		short_prompt = string.format(_("contract-comms", "Three %s to %s"),independent_station[2].comms_data.characterGood,independent_station[2]:getCallSign()),
		accepted = false,
		func = start1to2delivery,
	}
	independent_station[2].comms_data.contract = {}
	independent_station[2].comms_data.contract["one_to_two"] = {
		type = "fulfill",
		prompt = string.format(_("contract-comms", "Fulfill %s 3 %s %s contract"),first_station:getCallSign(),independent_station[2].comms_data.characterGood,independent_station[2]:getCallSign()),
		short_prompt = string.format(_("contract-comms", "Three %s from %s"),independent_station[2].comms_data.characterGood,first_station:getCallSign()),
		fulfilled = false,
		func = complete1to2delivery,
	}
	--contract details: second to third station
	independent_station[2].comms_data.contract["two_to_three"] = {
		type = "start",
		prompt = string.format(_("contract-comms", "Deliver two %s to %s. Upon delivery, they will increase your shield strength"),independent_station[3].comms_data.characterGood,independent_station[3]:getCallSign()),
		short_prompt = string.format(_("contract-comms", "Two %s to %s"),independent_station[3].comms_data.characterGood,independent_station[3]:getCallSign()),
		accepted = false,
		func = start2to3delivery,
	}
	independent_station[3].comms_data.contract = {}
	independent_station[3].comms_data.contract["two_to_three"] = {
		type = "fulfill",
		prompt = string.format(_("contract-comms", "Fulfill %s 2 %s %s contract"),independent_station[2]:getCallSign(),independent_station[3].comms_data.characterGood,independent_station[3]:getCallSign()),
		short_prompt = string.format(_("contract-comms", "Two %s from %s"),independent_station[3].comms_data.characterGood,independent_station[2]:getCallSign()),
		fulfilled = false,
		func = complete2to3delivery,
	}
end
function mainGMButtons()
	clearGMFunctions()
	addGMFunction(_("buttonGM", "+Missions"),missionSelection)
	addGMFunction(_("buttonGM","+Spawn Ship(s)"),spawnGMShips)
--	addGMFunction("Explode test",function()
--		plot7 = explodingPlanetDebris
--	end)
end
function missionSelection()
	clearGMFunctions()
	addGMFunction(_("buttonGM", "-Main from missions"),mainGMButtons)
	addGMFunction(_("buttonGM","Mission Status"),function()
		local out = _("msgGM","Plot 1:")
		if plot1 == nil then
			out = string.format(_("msgGM","%s nil"),out)
		else
			if plot1 == kraylorDiversionarySabotage then
				out = string.format(_("msgGM","%s Kraylor diversionary sabotage"),out)
			elseif plot1 == longDistanceCargo then
				out = string.format(_("msgGM","%s long distance cargo"),out)
			elseif plot1 == transitionContract then
				out = string.format(_("msgGM","%s transition contract"),out)
			elseif plot1 == exuariHarassment then
				out = string.format(_("msgGM","%s Exuari harassment"),out)
			end
			if plot1_type ~= nil and plot1_type == "optional" then
				out = string.format(_("msgGM","%s (optional)"),out)
			end
			if plot1 == exuariHarassment then
				if plot1_time ~= nil then
					out = string.format(_("msgGM","%s\n    seconds remaining until next harassment wave:%i"),out,math.floor(plot1_time - getScenarioTime()))
				end
				if plot1_defensive_fleet_spawned ~= nil and plot1_defensive_fleet_spawned then
					if plot1_defensive_fleet ~= nil then
						out = string.format(_("msgGM","%s\n    defensive fleet size:%i"),out,#plot1_defensive_fleet)
					end
				else
					if plot1_defensive_time ~= nil then
						out = string.format(_("msgGM","%s\n    seconds remaining until next defensive fleet:%i"),out,math.floor(plot1_defensive_time - getScenarioTime()))
					end
				end
				if plot1_danger ~= nil then
					out = string.format(_("msgGM","%s\n    danger:%.2f"),out,plot1_danger)
				end
				if plot1_fleets_destroyed ~= nil then
					out = string.format(_("msgGM","%s\n    fleets destroyed:%i"),out,plot1_fleets_destroyed)
				end
				if plot1_last_defense ~= nil and plot1_last_defense then
					if plot1_last_defense_fleet ~= nil then
						local fleet_count = 0
						for i,ship in pairs(plot1_last_defense_fleet) do
							if ship:isValid() then
								fleet_count = fleet_count + 1
							end
						end
						out = string.format(_("msgGM","%s\n    last defense fleet size:%i"),out,fleet_count)
					end
				end
			end
			if plot1 == kraylorDiversionarySabotage then
				if diversionary_sabotage_fleet ~= nil then
					local fleet_count = 0
					for i,ship in ipairs(diversionary_sabotage_fleet) do
						if ship:isValid() then
							fleet_count = fleet_count + 1
						end
					end
					out = string.format(_("msgGM","%s\n    Kraylor diversionary fleet size:%i"),out,fleet_count)
				end
				if kraylor_sabotage_diversion_time ~= nil then
					out = string.format(_("msgGM","%s\n    seconds remaining until next check for reinforcements:%i"),out,math.floor(kraylor_sabotage_diversion_time - getScenarioTime()))
				end
				if kraylor_diversion_danger ~= nil then
					out = string.format(_("msgGM","%s\n    Kraylor diversion danger:%i"),out,kraylor_diversion_danger)
				end
				if defend_against_kraylor_fleet ~= nil then
					local fleet_count = 0
					for i,ship in ipairs(defend_against_kraylor_fleet) do
						if ship:isValid() then
							fleet_count = fleet_count + 1
						end
					end
					out = string.format(_("msgGM","%s/n    defend against Kraylor fleet size:%i"),out,fleet_count)
				end
				if supply_depot_station ~= nil and supply_depot_station:isValid() then
					if supply_depot_station.sabotaged ~= nil and supply_depot_station.sabotaged then
						out = string.format(_("msgGM","%s\n    supply depot station %s has been sabotaged."),out,supply_depot_station:getCallSign())
					end
				else
					out = string.format(_("msgGM","%s\n    supply depot station has been destroyed"),out)
				end
			end
			if plot1 == longDistanceCargo then
				if supply_depot_station ~= nil and supply_depot_station:isValid() then
					out = string.format(_("msgGM","%s    distance between %s and %s:%i units"),out,player:getCallSign(),supply_depot_station:getCallSign(),math.floor(distance(player,supply_depot_station)/1000))
				end
				if supply_sabotage_fleet ~= nil then
					local sabotage_fleet_count = 0
					for i,ship in ipairs(supply_sabotage_fleet) do
						if ship:isValid() then
							sabotage_fleet_count = sabotage_fleet_count + 1
						end
					end
					out = string.format(_("msgGM","%s\n    supply sabotage fleet size:%i"),out,sabotage_fleet_count)
				end
			end
		end
		out = string.format(_("msgGM","%s\nPlot 2:"),out)
		if plot2 == nil then
			out = string.format(_("msgGM","%s nil"),out)
		else
			out = string.format(_("msgGM","%s contract target"),out)
			if exuari_vengance_fleet_time ~= nil then
				out = string.format(_("msgGM","%s\n    seconds remaining until next Exuari vengance fleet:%i"),out,math.floor(exuari_vengance_fleet_time - getScenarioTime()))
			end
			for i,station in ipairs(contract_station) do
				if station ~= nil and station:isValid() then
					out = string.format(_("msgGM","%s\n    contract target station %s"),out,station:getCallSign())
					if station.harass_fleet ~= nil then
						local fleet_count = 0
						for i,ship in pairs(station.harass_fleet) do
							if ship ~= nil and ship:isValid() then
								fleet_count = fleet_count + 1
							end
						end
						out = string.format(_("msgGM","%s, harassing Exuari fleet size:%i"),out,fleet_count)
					else
						if station.delay_timer ~= nil then
							out = string.format(_("msgGM","%s, seconds until next harassment check:%i"),out,math.floor(station.delay_timer - getScenarioTime()))
						end
					end
				end
			end
			for i,station in ipairs(independent_station) do
				if station:isValid() then
					if station.comms_data.contract ~= nil then
						for contract,details in pairs(station.comms_data.contract) do
							local status = ""
							if details.type == "start" then
								if details.accepted then
									status = _("msgGM","accepted")
								else
									status = _("msgGM","not accepted")
								end
							else
								if details.fulfilled then
									status = _("msgGM","fulfilled")
								else
									status = _("msgGM","not fulfilled")
								end
							end
							out = string.format(_("msgGM","%s\n    contract at %s: %s status: %s"),out,station:getCallSign(),contract,status)
						end
					end
				end
			end
			if transition_contract_delay ~= nil then
				out = string.format(_("msgGM","%s\n    seconds until transition contract:%i"),out,math.floor(transition_contract_delay - getScenarioTime()))
			end
		end
		out = string.format(_("msgGM","%s\nPlot 3:"),out)
		if plot3 == nil then
			out = string.format(_("msgGM","%s nil"),out)
		else
			out = string.format(_("msgGM","%s Jenny asteroid (optional)"),out)
			if player.asteroid_start_time ~= nil then
				if getScenarioTime() - player.asteroid_start_time > 300 then
					out = string.format(_("msgGM","%s\n    asteroid structure in notes"),out)
				end
			end
			if player.asteroid_identified ~= nil and player.asteroid_identified then
				out = string.format(_("msgGM","%s\n    asteroid identified"),out)
				if player.jenny_aboard ~= nil and player.jenny_aboard then
					out = string.format(_("msgGM","%s\n    Jenny is aboard"),out)
					if first_station:isValid() then
						if first_station.asteroid_upgrade ~= nil and first_station.asteroid_upgrade then
							out = string.format(_("msgGM","%s\n    asteroid research reward is available on %s"),out,first_station:getCallSign())
							if player.asteroid_upgrade == nil then
								out = string.format(_("msgGM","%s\n    asteroid research reward has not yet been claimed by %s"),out,player:getCallSign())
							end
						else
							out = string.format(_("msgGM","%s\n    asteroid research reward is not yet available on %s"),out,first_station:getCallSign())
						end
					else
						out = string.format(_("msgGM","%s\n    mission cannot be completed due to the destruction of the first mission station."),out)
					end
				else
					out = string.format(_("msgGM","%s\n    Jenny has not yet boarded %s"),out,player:getCallSign())
				end
			else
				out = string.format(_("msgGM","%s\n    asteroid has not yet been identified"),out)
			end
		end
		out = string.format(_("msgGM","%s\nPlot 4:"),out)
		if plot4 == nil then
			out = string.format(_("msgGM","%s nil"),out)
		else
			if plot4 == highwaymen then
				out = string.format(_("msgGM","%s highwaymen"),out)
			elseif plot4 == highwaymenAlerted then
				out = string.format(_("msgGM","%s highwaymen alerted"),out)
			elseif plot4 == highwaymenPounce then
				out = string.format(_("msgGM","%s highwaymen pounce"),out)
			elseif plot4 == highwaymenAftermath then
				out = string.format(_("msgGM","%s highwaymen aftermath"),out)
			elseif plot4 == highwaymenReset then
				out = string.format(_("msgGM","%s highwaymen reset"),out)
			end
			if highway_time ~= nil then
				out = string.format(_("msgGM","%s\n    seconds until next event:%i"),out,math.floor(highway_time - getScenarioTime()))
			end
			if highwaymen_fleet ~= nil then
				local fleet_count = 0
				for i,ship in ipairs(highwaymen_fleet) do
					if ship:isValid() then
						fleet_count = fleet_count + 1
					end
				end
				out = string.format(_("msgGM","%s\n    highwaymen fleet size:%i"),out,fleet_count)
			end
		end
		out = string.format(_("msgGM","%s\nPlot 5:"),out)
		if plot5 == nil then
			out = string.format(_("msgGM","%s nil"),out)
		else
			out = string.format(_("msgGM","%s highwaymen warning zone"),out)
			if zone_time ~= nil then
				out = string.format(_("msgGM","%s: seconds until zone removal:%i"),out,math.floor(zone_time - getScenarioTime()))
			end
		end
		out = string.format(_("msgGM","%s\nPlot 6:"),out)
		if plot6 == nil then
			out = string.format(_("msgGM","%s nil"),out)
		else
			if plot6 == worldEnd then
				out = string.format(_("msgGM","%s world end"),out)
			elseif plot6 == kraylorPlanetBuster then
				out = string.format(_("msgGM","%s Kraylor planet buster"),out)
				if kraylor_planet_buster_time ~= nil then
					out = string.format(_("msgGM","%s\n    seconds until next fleet check:%i"),out,math.floor(kraylor_planet_buster_time - getScenarioTime()))
				end
				if planetary_attack_fleet_adjust_time ~= nil then
					out = string.format(_("msgGM","%s\n    seconds until next fleet target adjustment/planet check:%i"),out,math.floor(planetary_attack_fleet_adjust_time - getScenarioTime()))
				end
				if planetary_attack_fleet ~= nil then
					local fleet_count = 0
					local fleet_ships = ""
					for i,ship in ipairs(planetary_attack_fleet) do
						if ship:isValid() then
							fleet_count = fleet_count + 1
							if fleet_ships == "" then
								fleet_ships = string.format(_("msgGM","Ships: %s"),ship:getCallSign())
							else
								fleet_ships = string.format(_("msgGM","%s, %s"),fleet_ships,ship:getCallSign())
							end
						end
					end
					out = string.format(_("msgGM","%s\n    planetary attack fleet size:%i"),out,fleet_count)
					if fleet_count > 0 then
						out = string.format(_("msgGM","%s\n    %s"),out,fleet_ships)
					end
				end
				if kraylor_planetary_danger ~= nil then
					out = string.format(_("msgGM","%s\n    Kraylor planetary danger:%i"),out,kraylor_planetary_danger)
				end
			end
		end
		out = string.format(_("msgGM","%s\nPlot 7:"),out)
		if plot7 == nil then
			out = string.format(_("msgGM","%s nil"),out)
		else
			out = string.format(_("msgGM","%s exploding planet debris"),out)
			if exploding_planet_time ~= nil then
				out = string.format(_("msgGM","%s\n    seconds remaining until explosion actions are done:%i"),out,math.floor(exploding_planet_time - getScenarioTime()))
			end
		end
		out = string.format(_("msgGM","%s\nPlot 8:"),out)
		if plot8 == nil then
			out = string.format(_("msgGM","%s nil"),out)
		else
			out = string.format(_("msgGM","%s opportunistic pirates"),out)
			if greedy_pirate_fleet ~= nil then
				local pirate_count = 0
				for i,ship in ipairs(greedy_pirate_fleet) do
					if ship:isValid() then
						pirate_count = pirate_count + 1
					end
				end
				out = string.format(_("msgGM","%s\n    greedy pirate fleet size:%i"),out,pirate_count)
			end
			if pirate_adjust_time ~= nil then
				out = string.format(_("msgGM","%s\n    seconds remaining until next pirate fleet adjustment check:%i"),out,math.floor(pirate_adjust_time - getScenarioTime()))
			end
			if greedy_pirate_danger ~= nil then
				out = string.format(_("msgGM","%s\n    greedy pirate danger:%i"),out,greedy_pirate_danger)
			end
		end
		addGMMessage(out)
	end)
	if plot1 ~= nil and plot1 ~= kraylorDiversionarySabotage then
		addGMFunction(_("buttonGM", "Skip Harassment"),function()
			player = getPlayerShip(-1)
			impulseUpgrade(player)
			missileTubeUpgrade(player)
			--	beamUpgrade(damage,cycle_time,power_use,heat_generated,artifact_scanned)
			beamUpgrade(true,nil,true,true)
			player.beam_damage_upgrade = true
			jumpDriveUpgrade(player)
			player:addReputationPoints(200)
			plot1 = nil
			plot1_type = nil
			plot1_time = nil
			plot1_defensive_time = nil
			plot1_danger = nil
			plot1_fleet_spawned = nil
			plot1_defensive_fleet_spawned = nil
			exuari_harassment_upgrade = true
			plot2 = contractTarget
			addGMMessage(_("msgGM", "Harassment skipped"))
			missionSelection()
		end)
	end
	if plot2 == contractTarget then
		addGMFunction(_("buttonGM", "Skip Local Contracts"),function()
			player = getPlayerShip(-1)
			--add forward beam
			local beam_index = 0
			repeat
				beam_index = beam_index + 1
			until(player:getBeamWeaponRange(beam_index) < 1)
			player:setBeamWeapon(beam_index,20,0,1200,6,5)
			--add energy
			player:setMaxEnergy(player:getMaxEnergy()*1.5)
			player:setEnergy(player:getMaxEnergy())
			--strengthen hull
			player:setHullMax(player:getHullMax()*1.5)
			player:setHull(player:getHullMax())
			--strengthen shields
			if player:getShieldCount() == 1 then
				player:setShieldsMax(player:getShieldMax(0)*1.25)
			else
				player:setShieldsMax(player:getShieldMax(0)*1.25,player:getShieldMax(1)*1.25)
			end
			player:addToShipLog(string.format(_("contract-shipLog", "A rare long range contract has been posted at station %s"),first_station:getCallSign()),"Magenta")
			transition_contract_message = true
			plot2 = nil
			addGMMessage(_("msgGM", "Local contracts skipped"))
			missionSelection()
		end)
	end
	addGMFunction(_("buttonGM", "Mark asteroids"),function()
		for i,asteroid in pairs(research_asteroids) do
			if asteroid.osmium ~= nil and asteroid.iridium ~= nil then
				local ax, ay = asteroid:getPosition()
				local d = 250
				Zone():setPoints(ax-d,ay-d,ax+d,ay-d,ax+d,ay+d,ax-d,ay+d):setColor(128,0,0)
			end
		end
	end)
end
-----------------
--	Utilities  --
-----------------
function createRandomAlongArc(object_type, amount, x, y, distance, startArc, endArcClockwise, randomize)
-- Create amount of objects of type object_type along arc
-- Center defined by x and y
-- Radius defined by distance
-- Start of arc between 0 and 360 (startArc), end arc: endArcClockwise
-- Use randomize to vary the distance from the center point. Omit to keep distance constant
-- Example:
--   createRandomAlongArc(Asteroid, 100, 500, 3000, 65, 120, 450)
	local function asteroidSize()
		return random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
	end
	local object_list = {}
	if randomize == nil then randomize = 0 end
	if amount == nil then amount = 1 end
	local arcLen = endArcClockwise - startArc
	if startArc > endArcClockwise then
		endArcClockwise = endArcClockwise + 360
		arcLen = arcLen + 360
	end
	local last_object = nil
	local asteroid_size = 0
	if amount > arcLen then
		for ndex=1,arcLen do
			local radialPoint = startArc+ndex
			local pointDist = distance + random(-randomize,randomize)
			last_object = object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist)			
			if last_object.typeName == "Asteroid" then
				last_object:setSize(asteroidSize())
			end
			table.insert(object_list,last_object)
		end
		for ndex=1,amount-arcLen do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
			last_object = object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist)			
			if last_object.typeName == "Asteroid" then
				last_object:setSize(asteroidSize())
			end
			table.insert(object_list,last_object)
		end
	else
		for ndex=1,amount do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
			last_object = object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist)
			if last_object.typeName == "Asteroid" then
				last_object:setSize(asteroidSize())
			end
			table.insert(object_list,last_object)
		end
	end
	local last_x, last_y = last_object:getPosition()
	return last_x, last_y, object_list
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
function curvaceousAsteroids1(fsx, fsy, player_to_station_distance)
	local first_station_angle_inverted = first_station_angle + 180
	if first_station_angle_inverted > 360 then
		first_station_angle_inverted = first_station_angle_inverted - 360
	end
	local min_leg = 5000
	local max_leg = 100000
	local arc_leg = random(min_leg,max_leg)
	local min_seg = 20
	local max_seg = 60
	local arc_segment = random(min_seg,max_seg)
	local asteroid_density = 2*difficulty
	local width_divisor = 6
	local arx = nil
	local ary = nil
	local brx = nil
	local bry = nil
	local asteroid_list = {}
	local temp_list = nil
--	print("curvaceous asteroids: above asteroids")
	if random(1,100) <= 47 then	--center closer to station
		local aax, aay = vectorFromAngle(first_station_angle,arc_leg) 
		if random(1,100) <= 47 then	--right curve
			arx, ary, temp_list = createRandomAlongArc(Asteroid, math.floor(asteroid_density*arc_segment), (fsx/2)+aax, (fsy/2)+aay, arc_leg, first_station_angle_inverted, first_station_angle_inverted + arc_segment, player_to_station_distance/width_divisor)
			asteroid_list = add_to_list(temp_list,asteroid_list)
			arc_leg = random(min_leg,max_leg)
			arc_segment = random(min_seg,max_seg)
			if random(1,100) <= 47 then	--center closer to station, left curve
				aax, aay = vectorFromAngle(first_station_angle,arc_leg)
				local start_arc = first_station_angle_inverted - arc_segment
				if start_arc < 0 then
					start_arc = start_arc + 360
					first_station_angle_inverted = first_station_angle_inverted + 360
				end
				brx, bry, temp_list = createRandomAlongArc(Asteroid, math.floor(asteroid_density*arc_segment), (fsx/2)+aax, (fsy/2)+aay, arc_leg, start_arc, first_station_angle_inverted, player_to_station_distance/width_divisor)
				asteroid_list = add_to_list(temp_list,asteroid_list)
			else	--center closer to player right curve
				aax, aay = vectorFromAngle(first_station_angle_inverted,arc_leg)
				brx, bry, temp_list = createRandomAlongArc(Asteroid, math.floor(asteroid_density*arc_segment), (fsx/2)+aax, (fsy/2)+aay, arc_leg, first_station_angle, first_station_angle + arc_segment, player_to_station_distance/width_divisor)
				asteroid_list = add_to_list(temp_list,asteroid_list)
			end
		else	--left curve
			start_arc = first_station_angle_inverted - arc_segment
			if start_arc < 0 then
				start_arc = start_arc + 360
				first_station_angle_inverted = first_station_angle_inverted + 360
			end
			arx, ary, temp_list = createRandomAlongArc(Asteroid, math.floor(asteroid_density*arc_segment), (fsx/2)+aax, (fsy/2)+aay, arc_leg, start_arc, first_station_angle_inverted, player_to_station_distance/width_divisor)
			asteroid_list = add_to_list(temp_list,asteroid_list)
			arc_leg = random(min_leg,max_leg)
			arc_segment = random(min_seg,max_seg)
			if random(1,100) <= 47 then	--center closer to station, right curve
				aax, aay = vectorFromAngle(first_station_angle,arc_leg)
				brx, bry, temp_list = createRandomAlongArc(Asteroid, math.floor(asteroid_density*arc_segment), (fsx/2)+aax, (fsy/2)+aay, arc_leg, first_station_angle_inverted, first_station_angle_inverted + arc_segment, player_to_station_distance/width_divisor)
				asteroid_list = add_to_list(temp_list,asteroid_list)
			else	--center closer to player, left curve
				start_arc = first_station_angle - arc_segment
				local arc_end = first_station_angle
				if start_arc < 0 then
					start_arc = start_arc + 360
					arc_end = first_station_angle + 360
				end
				aax, aay = vectorFromAngle(first_station_angle_inverted,arc_leg)
				brx, bry, temp_list = createRandomAlongArc(Asteroid, math.floor(asteroid_density*arc_segment), (fsx/2)+aax, (fsy/2)+aay, arc_leg, start_arc, arc_end, player_to_station_distance/width_divisor)
				asteroid_list = add_to_list(temp_list,asteroid_list)
			end
		end			
	else	--center closer to player
		aax, aay = vectorFromAngle(first_station_angle_inverted,arc_leg) 
		if random(1,100) <= 47 then	--right curve
			arx, ary, temp_list = createRandomAlongArc(Asteroid, math.floor(asteroid_density*arc_segment), (fsx/2)+aax, (fsy/2)+aay, arc_leg, first_station_angle, first_station_angle + arc_segment, player_to_station_distance/width_divisor)
			asteroid_list = add_to_list(temp_list,asteroid_list)
			arc_leg = random(min_leg,max_leg)
			arc_segment = random(min_seg,max_seg)
			if random(1,100) <= 47 then	--center closer to station, right curve
				aax, aay = vectorFromAngle(first_station_angle,arc_leg)
				brx, bry, temp_list = createRandomAlongArc(Asteroid, math.floor(asteroid_density*arc_segment), (fsx/2)+aax, (fsy/2)+aay, arc_leg, first_station_angle_inverted, first_station_angle_inverted + arc_segment, player_to_station_distance/width_divisor)
				asteroid_list = add_to_list(temp_list,asteroid_list)
			else	--center closer to player, left curve
				start_arc = first_station_angle - arc_segment
				arc_end = first_station_angle
				if start_arc < 0 then
					start_arc = start_arc + 360
					arc_end = first_station_angle + 360
				end
				aax, aay = vectorFromAngle(first_station_angle_inverted,arc_leg)
				brx, bry, temp_list = createRandomAlongArc(Asteroid, math.floor(asteroid_density*arc_segment), (fsx/2)+aax, (fsy/2)+aay, arc_leg, start_arc, arc_end, player_to_station_distance/width_divisor)
				asteroid_list = add_to_list(temp_list,asteroid_list)
			end
		else	--left curve
			start_arc = first_station_angle - arc_segment
			arc_end = first_station_angle
			if start_arc < 0 then
				start_arc = start_arc + 360
				arc_end = first_station_angle + 360
			end
			arx, ary, temp_list = createRandomAlongArc(Asteroid, math.floor(asteroid_density*arc_segment), (fsx/2)+aax, (fsy/2)+aay, arc_leg, start_arc, arc_end, player_to_station_distance/width_divisor)
			asteroid_list = add_to_list(temp_list,asteroid_list)
			arc_leg = random(min_leg,max_leg)
			arc_segment = random(min_seg,max_seg)
			if random(1,100) <= 47 then	--center closer to player, right curve
				aax, aay = vectorFromAngle(first_station_angle_inverted,arc_leg)
				brx, bry, temp_list = createRandomAlongArc(Asteroid, math.floor(asteroid_density*arc_segment), (fsx/2)+aax, (fsy/2)+aay, arc_leg, first_station_angle, first_station_angle + arc_segment, player_to_station_distance/width_divisor)
				asteroid_list = add_to_list(temp_list,asteroid_list)
			else	--center closer to station, left curve
				start_arc = first_station_angle_inverted - arc_segment
				arc_end = first_station_angle_inverted
				if start_arc < 0 then
					start_arc = start_arc + 360
					arc_end = first_station_angle_inverted + 360
				end
				aax, aay = vectorFromAngle(first_station_angle,arc_leg)
				brx, bry, temp_list = createRandomAlongArc(Asteroid, math.floor(asteroid_density*arc_segment), (fsx/2)+aax, (fsy/2)+aay, arc_leg, start_arc, arc_end, player_to_station_distance/width_divisor)
				asteroid_list = add_to_list(temp_list,asteroid_list)
			end
		end
	end
--	print("curvaceous asteroids: below asteroids")
	local full_list = {}
	for i=1,#asteroid_list do
		table.insert(full_list,asteroid_list[i])
	end
--	print("curvaceous asteroids: list replicated")
	if difficulty >= 1 then
		repeat
			crx, cry = asteroid_list[math.random(1,#asteroid_list)]:getPosition()
		until(crx ~= arx and cry ~= ary and crx ~= brx and cry ~= bry)
	end
	if difficulty > 1 then
		repeat
			drx, dry = asteroid_list[math.random(1,#asteroid_list)]:getPosition()
		until(drx ~= arx and dry ~= ary and drx ~= brx and dry ~= bry and drx ~= crx and dry ~= cry)
	end
	--Composition: Rock and metal
	--Iron asteroid: Iron 91%, Nickel 8.5%, Cobalt
	--Stone asteroid: Oxygen, Silicon, Magnesium, Calcium
	--Other components: olivine, pyroxene, nickel-iron, water-ice
	--					carbon, Nitrogen, Hydrogen, Oxygen
	--					nickel, iridium, palladium, platinum, gold, magnesium, osmium, ruthenium, rhodium
	--Asteroid structures: most are solid, rubble, binary
	--Sizes:	30 > 200km
	--			250 > 100km
	--			million > 1 km
	--Types: 	C: 75% Carbonaceous Chondrite, Carbon
	--			S: 17% Nickel-iron mixed with iron and magnesium silicates
	--			M: most of the rest: nickel-iron
	for i=1,#asteroid_list do
		local selected_asteroid_index = math.random(1,#asteroid_list)
		local selected_asteroid = asteroid_list[selected_asteroid_index]
		table.remove(asteroid_list,selected_asteroid_index)
		local unscanned_description = ""
		if random(0,100) < 65 then
			unscanned_description = _("scienceDescription-asteroid", "Structure: solid")
		elseif random(0,100) < 70 then
			unscanned_description = _("scienceDescription-asteroid", "Structure: rubble")
		else
			unscanned_description = _("scienceDescription-asteroid", "Structure: binary")
		end
		local scanned_description = ""
		selected_asteroid.composition = 0
		if i == 1 then
			selected_asteroid.osmium = math.random(1,20)/10
			scanned_description = string.format(_("scienceDescription-asteroid", "%sosmium:%.1f%% "),scanned_description,selected_asteroid.osmium)
			selected_asteroid.iridium = math.random(1,70)/10
			scanned_description = string.format(_("scienceDescription-asteroid", "%siridium:%.1f%% "),scanned_description,selected_asteroid.iridium)
			selected_asteroid.olivine = math.random(1,150)/10
			scanned_description = string.format(_("scienceDescription-asteroid", "%solivine:%.1f%% "),scanned_description,selected_asteroid.olivine)
			selected_asteroid.nickel = math.random(1,190)/10
			scanned_description = string.format(_("scienceDescription-asteroid", "%snickel:%.1f%% "),scanned_description,selected_asteroid.nickel)
			scanned_description = string.format(_("scienceDescription-asteroid", "%s, %srock:remainder"),unscanned_description, scanned_description)
			target_asteroid = selected_asteroid
			target_asteroid_x, target_asteroid_y = target_asteroid:getPosition()
			print(string.format("Target Asteroid: Sector:%s X:%i Y:%i Osmium:%.1f, Iridium:%.1f, Olivine:%.1f, Nickel:%.1f",target_asteroid:getSectorName(),math.floor(target_asteroid_x),math.floor(target_asteroid_y),target_asteroid.osmium,target_asteroid.iridium,target_asteroid.olivine,target_asteroid.nickel))
		else
			if random(0,100) < 2 and selected_asteroid.composition < 100 then
				selected_asteroid.osmium = math.random(1,20)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.osmium
				scanned_description = string.format(_("scienceDescription-asteroid", "%sosmium:%.1f%% "),scanned_description,selected_asteroid.osmium)
			end
			if random(0,100) < 3 and selected_asteroid.composition < 100 then
				selected_asteroid.ruthenium = math.random(1,30)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.ruthenium
				scanned_description = string.format(_("scienceDescription-asteroid", "%sruthenium:%.1f%% "),scanned_description,selected_asteroid.ruthenium)
			end
			if random(0,100) < 4 and selected_asteroid.composition < 100 then
				selected_asteroid.rhodium = math.random(1,40)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.rhodium
				scanned_description = string.format(_("scienceDescription-asteroid", "%srhodium:%.1f%% "),scanned_description,selected_asteroid.rhodium)
			end
			if random(0,100) < 5 and selected_asteroid.composition < 100 then
				selected_asteroid.magnesium = math.random(1,50)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.magnesium
				scanned_description = string.format(_("scienceDescription-asteroid", "%smagnesium:%.1f%% "),scanned_description,selected_asteroid.magnesium)
			end
			if random(0,100) < 6 and selected_asteroid.composition < 100 then
				selected_asteroid.platinum = math.random(1,60)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.platinum
				scanned_description = string.format(_("scienceDescription-asteroid", "%splatinum:%.1f%% "),scanned_description,selected_asteroid.platinum)
			end
			if random(0,100) < 7 and selected_asteroid.composition < 100 then
				selected_asteroid.iridium = math.random(1,70)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.iridium
				scanned_description = string.format(_("scienceDescription-asteroid", "%siridium:%.1f%% "),scanned_description,selected_asteroid.iridium)
			end
			if random(0,100) < 8 and selected_asteroid.composition < 100 then
				selected_asteroid.gold = math.random(1,80)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.gold
				scanned_description = string.format(_("scienceDescription-asteroid", "%sgold:%.1f%% "),scanned_description,selected_asteroid.gold)
			end
			if random(0,100) < 9 and selected_asteroid.composition < 100 then
				selected_asteroid.palladium = math.random(1,90)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.palladium
				scanned_description = string.format(_("scienceDescription-asteroid", "%spalladium:%.1f%% "),scanned_description,selected_asteroid.palladium)
			end
			if random(0,100) < 10 and selected_asteroid.composition < 100 then
				selected_asteroid.oxygen = math.random(1,100)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.oxygen
				scanned_description = string.format(_("scienceDescription-asteroid", "%soxygen:%.1f%% "),scanned_description,selected_asteroid.oxygen)
			end
			if random(0,100) < 11 and selected_asteroid.composition < 100 then
				selected_asteroid.silicon = math.random(1,110)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.silicon
				scanned_description = string.format(_("scienceDescription-asteroid", "%ssilicon:%.1f%% "),scanned_description,selected_asteroid.silicon)
			end
			if random(0,100) < 12 and selected_asteroid.composition < 100 then
				selected_asteroid.hydrogen = math.random(1,120)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.hydrogen
				scanned_description = string.format(_("scienceDescription-asteroid", "%shydrogen:%.1f%% "),scanned_description,selected_asteroid.hydrogen)
			end
			if random(0,100) < 13 and selected_asteroid.composition < 100 then
				selected_asteroid.nitrogen = math.random(1,130)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.nitrogen
				scanned_description = string.format(_("scienceDescription-asteroid", "%snitrogen:%.1f%% "),scanned_description,selected_asteroid.nitrogen)
			end
			if random(0,100) < 14 and selected_asteroid.composition < 100 then
				selected_asteroid.pyroxene = math.random(1,140)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.pyroxene
				if selected_asteroid.composition >= 100 then
					scanned_description = string.format(_("scienceDescription-asteroid", "%spyroxene:remainder"),scanned_description)				
				else
					scanned_description = string.format(_("scienceDescription-asteroid", "%spyroxene:%.1f%% "),scanned_description,selected_asteroid.pyroxene)
				end
			end
			if random(0,100) < 15 and selected_asteroid.composition < 100 then
				selected_asteroid.olivine = math.random(1,150)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.olivine
				if selected_asteroid.composition >= 100 then
					scanned_description = string.format(_("scienceDescription-asteroid", "%solivine:remainder"),scanned_description)				
				else
					scanned_description = string.format(_("scienceDescription-asteroid", "%solivine:%.1f%% "),scanned_description,selected_asteroid.olivine)
				end
			end
			if random(0,100) < 16 and selected_asteroid.composition < 100 then
				selected_asteroid.cobalt = math.random(1,160)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.cobalt
				if selected_asteroid.composition >= 100 then
					scanned_description = string.format(_("scienceDescription-asteroid", "%scobalt:remainder"),scanned_description)				
				else
					scanned_description = string.format(_("scienceDescription-asteroid", "%scobalt:%.1f%% "),scanned_description,selected_asteroid.cobalt)
				end
			end
			if random(0,100) < 17 and selected_asteroid.composition < 100 then
				selected_asteroid.dilithium = math.random(1,170)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.dilithium
				if selected_asteroid.composition >= 100 then
					scanned_description = string.format(_("scienceDescription-asteroid", "%sdilithium:remainder"),scanned_description)				
				else
					scanned_description = string.format(_("scienceDescription-asteroid", "%sdilithium:%.1f%% "),scanned_description,selected_asteroid.dilithium)
				end
			end
			if random(0,100) < 18 and selected_asteroid.composition < 100 then
				selected_asteroid.calcium = math.random(1,180)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.calcium
				if selected_asteroid.composition >= 100 then
					scanned_description = string.format(_("scienceDescription-asteroid", "%scalcium:remainder"),scanned_description)				
				else
					scanned_description = string.format(_("scienceDescription-asteroid", "%scalcium:%.1f%% "),scanned_description,selected_asteroid.calcium)
				end
			end
			if random(0,100) < 19 and selected_asteroid.composition < 100 then
				selected_asteroid.nickel = math.random(1,190)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.nickel
				if selected_asteroid.composition >= 100 then
					scanned_description = string.format(_("scienceDescription-asteroid", "%snickel:remainder"),scanned_description)				
				else
					scanned_description = string.format(_("scienceDescription-asteroid", "%snickel:%.1f%% "),scanned_description,selected_asteroid.nickel)
				end
			end
			if random(0,100) < 20 and selected_asteroid.composition < 100 then
				selected_asteroid.iron = math.random(1,200)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.iron
				if selected_asteroid.composition >= 100 then
					scanned_description = string.format(_("scienceDescription-asteroid", "%siron:remainder"),scanned_description)				
				else
					scanned_description = string.format(_("scienceDescription-asteroid", "%siron:%.1f%% "),scanned_description,selected_asteroid.iron)
				end
			end
			if selected_asteroid.composition > 0 then
				if selected_asteroid.composition < 100 then
					scanned_description = string.format(_("scienceDescription-asteroid", "%s, %srock:remainder"),unscanned_description, scanned_description)
				end
			else
				scanned_description = string.format(_("scienceDescription-asteroid", "%s, just rock"),unscanned_description, scanned_description)			
			end
		end
		selected_asteroid:setDescriptions(unscanned_description,scanned_description)
		local scan_parameter_tier_chance = 50
		if difficulty < 1 then
			scan_parameter_tier_chance = 25
		elseif difficulty > 1 then
			scan_parameter_tier_chance = 70
		end
		local scan_complexity = 1
		if random(0,100) < scan_parameter_tier_chance then
			if random(0,100) < scan_parameter_tier_chance then
				scan_complexity = 3
			else
				scan_complexity = 2
			end
		end
		local scan_depth = 1
		if random(0,100) < scan_parameter_tier_chance then
			if random(0,100) < scan_parameter_tier_chance then
				if random(0,100) < scan_parameter_tier_chance then
					scan_depth = 4
				else
					scan_depth = 3
				end
			else
				scan_depth = 2
			end
		end
		selected_asteroid:setScanningParameters(scan_complexity,scan_depth)
	end
--	print("curvaceous asteroids: just before return")
	--return coordinates for asteroids: one in each arc
	return arx, ary, brx, bry, full_list
end
function beamUpgrade(damage,cycle_time,power_use,heat_generated,artifact_scanned)
	if beam_upgrade_damage_level == nil then
		beam_upgrade_damage_level = 0
	end
	local beam_levels = {
		["Easy"] = 	{dmg = 5,	cyc = .7},
		["Normal"] ={dmg = 3,	cyc = .75},
		["Hard"] =	{dmg = 1,	cyc = .8},
	}
	if damage ~= nil then
		local damage_increment = beam_levels[getScenarioSetting("Murphy")].dmg
		if artifact_scanned ~= nil and artifact_scanned then
			damage_increment = damage_increment + 1 
		end
		local beam_index = 0
		repeat
			local tempArc = player:getBeamWeaponArc(beam_index)
			local tempDir = player:getBeamWeaponDirection(beam_index)
			local tempRng = player:getBeamWeaponRange(beam_index)
			local tempCyc = player:getBeamWeaponCycleTime(beam_index)
			local tempDmg = player:getBeamWeaponDamage(beam_index)
			local heat_change = 1
			if heat_generated ~= nil and heat_generated then
				heat_change = (tempDmg + damage_increment)/tempDmg
			end
			local power_change = 1
			if power_use ~= nil and power_use then
				power_change = (tempDmg + damage_increment)/tempDmg
			end
			player:setBeamWeapon(beam_index,tempArc,tempDir,tempRng,tempCyc,tempDmg + damage_increment)
			player:setBeamWeaponHeatPerFire(beam_index,player:getBeamWeaponHeatPerFire(beam_index)*heat_change)
			player:setBeamWeaponEnergyPerFire(beam_index,player:getBeamWeaponEnergyPerFire(beam_index)*power_change)
			beam_index = beam_index + 1
		until(player:getBeamWeaponRange(beam_index) < 1)
	end
	if cycle_time ~= nil then
		local cyc_change = beam_levels[getScenarioSetting("Murphy")].cyc
		local bi = 0
		repeat
			local tempArc = comms_source:getBeamWeaponArc(bi)
			local tempDir = comms_source:getBeamWeaponDirection(bi)
			local tempRng = comms_source:getBeamWeaponRange(bi)
			local tempCyc = comms_source:getBeamWeaponCycleTime(bi)
			local tempDmg = comms_source:getBeamWeaponDamage(bi)
			comms_source:setBeamWeapon(bi,tempArc,tempDir,tempRng,tempCyc * cyc_change,tempDmg)
			bi = bi + 1
		until(player:getBeamWeaponRange(bi) < 1)
	end
end
function playerShipCargoInventory(p)
	p:addToShipLog(string.format(_("inventory-shipLog", "%s Current cargo:"),p:getCallSign()),"Yellow")
	local goodCount = 0
	if p.goods ~= nil then
		for good, goodQuantity in pairs(p.goods) do
			goodCount = goodCount + 1
			p:addToShipLog(string.format(_("inventory-shipLog", "     %s: %i"),good,goodQuantity),"Yellow")
		end
	end
	if goodCount < 1 then
		p:addToShipLog(_("inventory-shipLog", "     Empty"),"Yellow")
	end
	p:addToShipLog(string.format(_("inventory-shipLog", "Available space: %i"),p.cargo),"Yellow")
end
--	Spawning
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
		for idx, current_ship_template in ipairs(ship_template_by_strength) do
			if ship_template[current_ship_template].strength <= max_strength then
				table.insert(template_pool,current_ship_template)
			end
			if #template_pool >= 5 then
				break
			end
		end
	elseif pool_selectivity == "more/light" then
		for i=#ship_template_by_strength,1,-1 do
			local current_ship_template = ship_template_by_strength[i]
			if ship_template[current_ship_template].strength <= max_strength then
				table.insert(template_pool,current_ship_template)
			end
			if #template_pool >= 20 then
				break
			end
		end
	else	--full
		for current_ship_template, details in pairs(ship_template) do
			if details.strength <= max_strength then
				table.insert(template_pool,current_ship_template)
			end
		end
	end
	return template_pool
end
function spawnEnemies(xOrigin, yOrigin, danger, enemyFaction, perimeter_min, perimeter_max, shape)
	if enemyFaction == nil then
		enemyFaction = "Kraylor"
	end
	if danger == nil then 
		danger = 1
	end
	local enemyStrength = math.max(danger * enemy_power * playerPower(),5)
	local template_pool = getTemplatePool(enemyStrength)
	if #template_pool < 1 then
		addGMMessage(_("msgGM", "Empty Template pool: fix excludes or other criteria"))
		return enemyList
	end
	local enemy_position = 0
	local sp = irandom(400,900)			--random spacing of spawned group
	if shape == nil then
		local shape_choices = {"square","hexagonal"}
		shape = shape_choices[math.random(1,#shape_choices)]
	end
	local enemyList = {}
	while enemyStrength > 0 do
		local selected_template = template_pool[math.random(1,#template_pool)]
		local ship = ship_template[selected_template].create(enemyFaction,selected_template)
		enemy_position = enemy_position + 1
		ship:setPosition(xOrigin + formation_delta[shape].x[enemy_position] * sp, yOrigin + formation_delta[shape].y[enemy_position] * sp)
		ship:setCallSign(generateCallSign(nil,enemyFaction))
		ship:setCommsScript(""):setCommsFunction(commsShip)
		ship:orderRoaming()
		table.insert(enemyList, ship)
		enemyStrength = enemyStrength - ship_template[selected_template].strength
	end
	if perimeter_min ~= nil then
		local enemy_angle = random(0,360)
		local circle_increment = 360/#enemyList
		local perimeter_deploy = perimeter_min
		if perimeter_max ~= nil then
			perimeter_deploy = random(perimeter_min,perimeter_max)
		end
		for i, enemy in pairs(enemyList) do
			local dex, dey = vectorFromAngle(enemy_angle,perimeter_deploy)
			enemy:setPosition(xOrigin+dex, yOrigin+dey)
			enemy_angle = enemy_angle + circle_increment
		end
	end
	return enemyList
end
function playerPower()
--evaluate the players for enemy strength and size spawning purposes
	local playerShipScore = 0
	for p5idx=1,8 do
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
------------
--	Plot  --
------------
--	Contract for increased hull strength functions  --
function start1to2delivery()
	if independent_station[2] ~= nil and independent_station[2]:isValid() then
		if comms_source.cargo < 3 then
			setCommsMessage(string.format(_("contract-comms", "Your available cargo space, %i, is insufficient for this contract. You need at least 3"),comms_source.cargo))
		else
			comms_source.cargo = comms_source.cargo - 3
			if comms_source.goods == nil then
				comms_source.goods = {}
			end
			local good = independent_station[2].comms_data.characterGood
			if comms_source.goods[good] == nil then
				comms_source.goods[good] = 0
			end
			comms_source.goods[good] = comms_source.goods[good] + 3
			setCommsMessage(string.format(_("contract-comms", "Cargo of three %s has been loaded onto your ship. Deliver to %s in %s"),good,independent_station[2]:getCallSign(),independent_station[2]:getSectorName()))
			first_station.comms_data.contract["one_to_two"].accepted = true
			table.insert(contract_station,independent_station[2])
		end
	else
		setCommsMessage(string.format(_("contract-comms", "This contract is no longer valid since the destination, %s, no longer exists. Sorry for the clerical error. Have a nice day"),independent_station[2]:getCallSign()))
		first_station.comms_data.contract["one_to_two"].accepted = true
	end
	addCommsReply(_("Back"),commsStation)
end
function complete1to2delivery()
	local good = independent_station[2].comms_data.characterGood
	if comms_source.goods ~= nil and comms_source.goods[good] ~= nil and comms_source.goods[good] >= 3 then
		comms_source:setHullMax(comms_source:getHullMax()*1.5)
		comms_source:setHull(comms_source:getHullMax())
		comms_source.goods[good] = comms_source.goods[good] - 3
		comms_source.cargo = comms_source.cargo + 3
		independent_station[2].comms_data.contract["one_to_two"].fulfilled = true
		for i=1,#contract_station do
			if contract_station[i] == comms_target then
				table.remove(contract_station,i)
				break
			end
		end
		comms_source:addReputationPoints(50)
		setCommsMessage(string.format(_("contract-comms", "Thanks for the %s, %s. We increased your hull strength by 50%%"),good,comms_source:getCallSign()))
	else
		setCommsMessage(string.format(_("contract-comms", "The terms of the contract require the delivery of three %s. This has not been met"),good))
	end
	addCommsReply(_("Back"),commsStation)
end
function start2to3delivery()
	if independent_station[3] ~= nil and independent_station[3]:isValid() then
		if comms_source.cargo < 2 then
			setCommsMessage(string.format(_("contract-comms", "Your available cargo space, %i, is insufficient for this contract. You need at least 3"),comms_source.cargo))
		else
			comms_source.cargo = comms_source.cargo - 2
			if comms_source.goods == nil then
				comms_source.goods = {}
			end
			local good = independent_station[3].comms_data.characterGood
			if comms_source.goods[good] == nil then
				comms_source.goods[good] = 0
			end
			comms_source.goods[good] = comms_source.goods[good] + 2
			setCommsMessage(string.format(_("contract-comms", "Cargo of two %s has been loaded onto your ship. Deliver to %s in %s"),good,independent_station[3]:getCallSign(),independent_station[3]:getSectorName()))
			independent_station[2].comms_data.contract["two_to_three"].accepted = true
			table.insert(contract_station,independent_station[3])
		end
	else
		setCommsMessage(string.format(_("contract-comms", "This contract is no longer valid since the destination, %s, no longer exists. Sorry for the clerical error. Have a nice day"),independent_station[3]:getCallSign()))
		independent_station[2].comms_data.contract["two_to_three"].accepted = true
	end
	addCommsReply(_("Back"),commsStation)
end
function complete2to3delivery()
	local good = independent_station[3].comms_data.characterGood
	if comms_source.goods ~= nil and comms_source.goods[good] ~= nil and comms_source.goods[good] >= 2 then
		if comms_source:getShieldCount() == 1 then
			comms_source:setShieldsMax(comms_source:getShieldMax(0)*1.25)
		else
			comms_source:setShieldsMax(comms_source:getShieldMax(0)*1.25,comms_source:getShieldMax(1)*1.25)
		end
		comms_source.goods[good] = comms_source.goods[good] - 2
		comms_source.cargo = comms_source.cargo + 2
		independent_station[3].comms_data.contract["two_to_three"].fulfilled = true
		for i=1,#contract_station do
			if contract_station[i] == comms_target then
				table.remove(contract_station,i)
				break
			end
		end
		comms_source:addReputationPoints(50)
		setCommsMessage(string.format(_("contract-comms", "Thanks for the %s, %s. We increased your shield strength by 25%%"),good,comms_source:getCallSign()))
	else
		setCommsMessage(string.format(_("contract-comms", "The terms of the contract require the delivery of two %s. This has not been met"),good))
	end
	addCommsReply(_("Back"),commsStation)
end
--	Optional missions
function setOptionalAddBeamMission(beam_station)
	if efficient_battery_diagnostic then print("top of setOptionalAddBeamMission") end
	if beam_station == nil then
		return
	end
	beam_station.comms_data.character = "Bob Fairchilde"
	beam_station.comms_data.characterDescription = _("characterInfo-comms", "His penchant for miniaturization and tinkering allows him to add a beam weapon to any ship")
	beam_station.comms_data.characterFunction = "addForwardBeam"
	if efficient_battery_diagnostic then print(string.format("first station: %s",first_station:getCallSign())) end
	local mineral_good = stationMineralGood(first_station)
	if efficient_battery_diagnostic then print("determined mineral good: " .. mineral_good) end
	beam_station.comms_data.characterGood = mineral_good
	--add clue station here	
end
function stationMineralGood(mineral_station)
	if mineral_station == nil then
		return "gold pressed latinum"
	end
	local ctd = mineral_station.comms_data
	for good, goodData in pairs(ctd.goods) do
		if mineralGoods[good] ~= nil then
			return good
		end
	end
	local mineral = mineralGoods[math.random(1,#mineralGoods)]
	mineral_station.comms_data.goods[mineral] = {quantity = math.random(5,10), cost = math.random(25,60)}
	return mineral
end
function setOptionalEfficientBatteriesMisison(battery_station)
	if efficient_battery_diagnostic then print("top of setOptionalEfficientBatteriesMisison") end
	if battery_station == nil then
		return
	end
	battery_station.comms_data.character = "Norma Tarigan"
	battery_station.comms_data.characterDescription = _("characterInfo-comms", "She knows how to increase your maximum energy capacity by improving battery efficiency")
	battery_station.comms_data.characterFunction = "efficientBatteries"
	if efficient_battery_diagnostic then print(string.format("independent station 2: %s",independent_station[2]:getCallSign())) end
	local component_good = stationComponentGood(independent_station[2],"battery")
	if efficient_battery_diagnostic then print("determined component good: " .. component_good) end
	battery_station.comms_data.characterGood = component_good
	if efficient_battery_diagnostic then print(string.format("character good: %s",battery_station.comms_data.characterGood)) end
	battery_station.comms_data.characterGood2 = independent_station[2].comms_data.characterGood
	if efficient_battery_diagnostic then print(string.format("character good 2: %s",battery_station.comms_data.characterGood2)) end
end
function stationComponentGood(component_station,preferred_good)
	if efficient_battery_diagnostic then print("top of stationComponentGood") end
	if component_station == nil then
		return
	end
	if efficient_battery_diagnostic then print(string.format("component station: %s",component_station:getCallSign())) end
	local ctd = component_station.comms_data
	for good, goodData in pairs(ctd.goods) do
		if componentGoods[good] ~= nil then
			if efficient_battery_diagnostic then print("determined good from station: " .. good) end
			return good
		end
	end
	if preferred_good == nil then
		preferred_good = componentGoods[math.random(1,#componentGoods)]
		if efficient_battery_diagnostic then print("No good passed to function, chosen good at random: " .. preferred_good) end
	end
	component_station.comms_data.goods[preferred_good] = {quantity = math.random(5,10), cost = math.random(50,80)}
	if efficient_battery_diagnostic then print("Good added to station: " .. preferred_good) end
	return preferred_good
end
--	Artifact pick up functions
function burnOutArtifactPickup(self, picker)
	if self:isScannedBy(picker) then
		picker:setSystemHealth("beamweapons",picker:getSystemHealth("beamweapons") - random(.5,1))
		if difficulty >= 1 then
			picker:setSystemHealth("frontshield",picker:getSystemHealth("frontshield") - random(.5,1))			
		end
		if difficulty >= 2 then
			picker:setSystemHealth("maneuver",picker:getSystemHealth("maneuver") - random(.5,1))			
		end
	else
		picker:setSystemHealth("beamweapons",-1)
		if difficulty >= 1 then
			picker:setSystemHealth("frontshield",-1)			
		end
		if difficulty >= 2 then
			picker:setSystemHealth("maneuver",-1)			
		end
	end
	picker:addToShipLog(_("artifact-shipLog", "The artifact we picked up has damaged our ship"),"Magenta")
end
function beamDamageArtifactPickup(self, picker)
	local damage_factor = 0
	local increased_heat_and_energy = 0
	beamUpgrade(true,nil,true,true,self:isScannedBy(picker))
	picker:addToShipLog(_("artifact-shipLog", "The technology gleaned from the artifact has allowed our technicians to increase the damage inflicted by our beam weapons"),"Magenta")
end
function maneuverArtifactPickup(self, picker)
	local maneuver_factor = 1
	if self:isScannedBy(picker) then
		maneuver_factor = 1.5 + (2 - difficulty)/2
	else
		maneuver_factor = 1.2 + (2 - difficulty)/2
	end
	picker:setRotationMaxSpeed(picker:getRotationMaxSpeed()*maneuver_factor)
	picker:addToShipLog(string.format(_("artifact-shipLog", "The technology gleaned from the artifact has allowed our technicians to increase our maneuver speed by %.1f%%"),(maneuver_factor - 1)*100),"Magenta")
end
------------------------------
--	Station communications  --
------------------------------
function impulseUpgrade(ship)
	ship.impulse_upgrade = true
	ship:setImpulseMaxSpeed(90)
end
function missileTubeUpgrade(ship)
	ship.missile_upgrade = true
	local tube_count = ship:getWeaponTubeCount()
	if tube_count == 0 then
		ship:setWeaponTubeCount(2)
		ship:setWeaponTubeDirection(0,-60)
		ship:setWeaponTubeDirection(1,60)
		ship:weaponTubeDisallowMissle(0,"Mine")
		ship:weaponTubeDisallowMissle(1,"Mine")
		ship:setWeaponStorageMax("Homing",6)
		ship:setWeaponStorage("Homing",6)
		ship:setWeaponStorageMax("EMP",2)
		ship:setWeaponStorage("EMP",2)
		ship:setWeaponStorageMax("Nuke",2)
		ship:setWeaponStorage("Nuke",2)
	else
		--handle case where the rear mine tube has already been obtained
	end
end
function addMineTube(ship)
	ship.mine_tube_upgrade = true
	local tube_count = ship:getWeaponTubeCount()
	if tube_count == 2 then
		ship:setWeaponTubeCount(3)
		ship:setWeaponTubeDirection(2,180)
		ship:setWeaponTubeExclusiveFor(2,"Mine")
		ship:setWeaponStorageMax("Mine",2)
		ship:setWeaponStorage("Mine",2)
	elseif tube_count == 0 then
		ship:setWeaponTubeCount(1)
		ship:setWeaponTubeDirection(0,180)
		ship:setWeaponTubeExclusiveFor(0,"Mine")
		ship:setWeaponStorageMax("Mine",2)
		ship:setWeaponStorage("Mine",2)
	end
end
function jumpDriveUpgrade(ship)
	ship.add_small_jump = true
	contract_eligible = true
	transition_contract_delay_max = 300 + (difficulty*50)
	transition_contract_delay = getScenarioTime() + transition_contract_delay_max
	transition_contract_delay_msg = getScenarioTime() + transition_contract_delay_max*.8
	ship:setJumpDrive(true)
	ship.max_jump_range = 25000
	ship.min_jump_range = 2000
	ship:setJumpDriveRange(ship.min_jump_range,ship.max_jump_range)
	ship:setJumpDriveCharge(ship.max_jump_range)
end
function commsStation()
	if stationCommsDiagnostic then print("function station comms") end
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
    if stationCommsDiagnostic then print("set player") end
	setPlayer()
	if stationCommsDiagnostic then print("set local variable player from comms source") end
	local playerCallSign = comms_source:getCallSign()
	if stationCommsDiagnostic then print(string.format("commsStation derived name: %s",playerCallSign)) end
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
function add_to_list(from_list,to_list)
	for i=1,#from_list do
		table.insert(to_list,from_list[i])
	end
	return to_list
end
function handleDockedState()
	local playerCallSign = comms_source:getCallSign()
	local ctd = comms_target.comms_data
	if stationCommsDiagnostic then print(string.format("handleDockedState derived name: %s",playerCallSign)) end
    if comms_source:isFriendly(comms_target) then
    	if ctd.friendlyness > 66 then
    		oMsg = string.format(_("station-comms", "Greetings %s!\nHow may we help you today?"),comms_source:getCallSign())
    	elseif ctd.friendlyness > 33 then
			oMsg = _("station-comms", "Good day, officer!\nWhat can we do for you today?")
		else
			oMsg = _("station-comms", "Hello, may I help you?")
		end
    else
		oMsg = _("station-comms", "Welcome to our lovely station.")
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. _("station-comms", " Forgive us if we seem a little distracted. We are carefully monitoring the enemies nearby.")
	end
	setCommsMessage(oMsg)
	local goodCount = 0
	for good, goodData in pairs(ctd.goods) do
		goodCount = goodCount + 1
	end
	local missilePresence = 0
	local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	for i, missile_type in ipairs(missile_types) do
		missilePresence = missilePresence + comms_source:getWeaponStorageMax(missile_type)
	end
	if missilePresence > 0 then
		if 	(ctd.weapon_available.Nuke   and comms_source:getWeaponStorageMax("Nuke") > 0)   or 
			(ctd.weapon_available.EMP    and comms_source:getWeaponStorageMax("EMP") > 0)    or 
			(ctd.weapon_available.Homing and comms_source:getWeaponStorageMax("Homing") > 0) or 
			(ctd.weapon_available.Mine   and comms_source:getWeaponStorageMax("Mine") > 0)   or 
			(ctd.weapon_available.HVLI   and comms_source:getWeaponStorageMax("HVLI") > 0)   then
			addCommsReply(_("ammo-comms", "I need ordnance restocked"), function()
				local ctd = comms_target.comms_data
				if stationCommsDiagnostic then print("in restock function") end
				setCommsMessage(_("ammo-comms", "What type of ordnance?"))
				if stationCommsDiagnostic then print(string.format("player nuke weapon storage max: %.1f",comms_source:getWeaponStorageMax("Nuke"))) end
				if comms_source:getWeaponStorageMax("Nuke") > 0 then
					if stationCommsDiagnostic then print("player can fire nukes") end
					if ctd.weapon_available.Nuke then
						if stationCommsDiagnostic then print("station has nukes available") end
						if math.random(1,10) <= 5 then
							nukePrompt = _("ammo-comms", "Can you supply us with some nukes? (")
						else
							nukePrompt = _("ammo-comms", "We really need some nukes (")
						end
						if stationCommsDiagnostic then print("nuke prompt: " .. nukePrompt) end
						addCommsReply(string.format(_("ammo-comms", "%s%d rep each)"), nukePrompt, getWeaponCost("Nuke")), function()
							if stationCommsDiagnostic then print("going to handle weapon restock function") end
							handleWeaponRestock("Nuke")
						end)
					end	--end station has nuke available if branch
				end	--end player can accept nuke if branch
				if comms_source:getWeaponStorageMax("EMP") > 0 then
					if ctd.weapon_available.EMP then
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
					if ctd.weapon_available.Homing then
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
					if ctd.weapon_available.Mine then
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
					if ctd.weapon_available.HVLI then
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
	addCommsReply(_("station-comms", "I need information"),function()
		setCommsMessage(_("station-comms", "What kind of information are you looking for?"))
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
		local has_gossip = random(1,100) < (100 - (30 * (difficulty - .5)))
		if (comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "") or
			(comms_target.comms_data.history ~= nil and comms_target.comms_data.history ~= "") or
			(comms_source:isFriendly(comms_target) and comms_target.comms_data.gossip ~= nil and comms_target.comms_data.gossip ~= "" and has_gossip) then
			addCommsReply(_("station-comms", "Tell me more about your station"), function()
				setCommsMessage(_("station-comms", "What would you like to know?"))
				if comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "" then
					addCommsReply(_("stationGeneralInfo-comms","General information"), function()
						setCommsMessage(ctd.general)
						addCommsReply(_("Back"), commsStation)
					end)
				end
				if ctd.history ~= nil and comms_target.comms_data.history ~= "" then
					addCommsReply(_("stationStory-comms", "Station history"), function()
						setCommsMessage(ctd.history)
						addCommsReply(_("Back"), commsStation)
					end)
				end
				if comms_source:isFriendly(comms_target) then
					if ctd.gossip ~= nil then
						if random(1,100) < (100 - (30 * (difficulty - .5))) then
							addCommsReply(_("gossip-comms", "Gossip"), function()
								setCommsMessage(ctd.gossip)
								addCommsReply(_("Back"), commsStation)
							end)
						end
					end
				end
				addCommsReply(_("Back"),commsStation)
			end)	--end station info comms reply branch
		end	--end public relations if branch
		if stationCommsDiagnostic then print(ctd.character) end
		if ctd.character ~= nil then
			addCommsReply(string.format(_("characterInfo-comms", "Tell me about %s"),ctd.character), function()
				if ctd.characterDescription ~= nil then
					setCommsMessage(ctd.characterDescription)
				else
					if ctd.characterDeadEnd == nil then
						local deadEndChoice = math.random(1,5)
						if deadEndChoice == 1 then
							ctd.characterDeadEnd = string.format(_("characterInfo-comms", "Never heard of %s"), ctd.character)
						elseif deadEndChoice == 2 then
							ctd.characterDeadEnd = string.format(_("characterInfo-comms", "%s died last week. The funeral was yesterday"), ctd.character)
						elseif deadEndChoice == 3 then
							ctd.characterDeadEnd = string.format(_("characterInfo-comms", "%s? Who's %s? There's nobody here named %s"),ctd.character,ctd.character,ctd.character)
						elseif deadEndChoice == 4 then
							ctd.characterDeadEnd = string.format(_("characterInfo-comms", "We don't talk about %s. They are gone and good riddance"),ctd.character)
						else
							ctd.characterDeadEnd = string.format(_("characterInfo-comms", "I think %s moved away"),ctd.character)
						end
					end
					setCommsMessage(ctd.characterDeadEnd)
				end
				if ctd.characterFunction == "addForwardBeam" then
					addForwardBeam()
				end
				if ctd.characterFunction == "shrinkBeamCycle" then
					shrinkBeamCycle()
				end
				if ctd.characterFunction == "increaseSpin" then
					increaseSpin()
				end
				if ctd.characterFunction == "addAuxTube" then
					addAuxTube()
				end
				if ctd.characterFunction == "coolBeam" then
					coolBeam()
				end
				if ctd.characterFunction == "longerBeam" then
					longerBeam()
				end
				if ctd.characterFunction == "damageBeam" then
					damageBeam()
				end
				if ctd.characterFunction == "moreMissiles" then
					moreMissiles()
				end
				if ctd.characterFunction == "fasterImpulse" then
					fasterImpulse()
				end
				if ctd.characterFunction == "strongerHull" then
					strongerHull()
				end
				if ctd.characterFunction == "efficientBatteries" then
					efficientBatteries()
				end
				if ctd.characterFunction == "strongerShields" then
					strongerShields()
				end
				addCommsReply(_("Back"), commsStation)
			end)
		end
		if comms_target:isFriendly(comms_source) then
			addCommsReply(_("orders-comms", "What are my current orders?"), function()
				setOptionalOrders()
				setSecondaryOrders()
				ordMsg = primaryOrders .. _("orders-comms", "\n") .. secondaryOrders .. optionalOrders
				if playWithTimeLimit then
					ordMsg = ordMsg .. string.format(_("orders-comms", "\n   %i Minutes remain in game"),math.floor(gameTimeLimit/60))
				end
				setCommsMessage(ordMsg)
				addCommsReply(_("Back"), commsStation)
			end)
		end
		if goodCount > 0 then
			addCommsReply(_("explainGoods-comms", "No tutorial covered goods or cargo. Explain"), function()
				setCommsMessage(_("explainGoods-comms", "Different types of cargo or goods may be obtained from stations, freighters or other sources. They go by one word descriptions such as dilithium, optic, warp, etc. Certain mission goals may require a particular type or types of cargo. Each player ship differs in cargo carrying capacity. Goods may be obtained by spending reputation points or by trading other types of cargo (typically food, medicine or luxury)"))
				addCommsReply(_("Back"), commsStation)
			end)
		end
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
	if comms_target == transition_station then
		if plot1 == nil then
			addCommsReply(_("contract-comms", "Check long distance contract"),function()
				createHumanNavySystem()
				setCommsMessage(string.format(_("contract-comms", "Contract Details:\nTravel to %s system to deliver cargo to supply station %s. Distance to system: %i units. Upon delivery, %s technicians will upgrade your battery efficiency and beam cycle time."),planet_star:getCallSign(),supply_depot_station:getCallSign(),math.floor(distance(comms_target,planet_star)/1000),supply_depot_station:getCallSign()))
				addCommsReply("Accept",function()
					local p = getPlayerShip(-1)
					addMineTube(p)
					local acceptance_message = string.format(_("contract-comms", "The Human Navy requires all armed ships be equipped with the ability to drop mines. We have modified %s with a rear facing mining tube. Due to ship size constraints, we were only able to provide you with two mines."),comms_source:getCallSign())
					--remove/add cargo here
					if comms_source.cargo < 4 then
						local remove_list = ""
						for good, good_quantity in pairs(comms_source.goods) do
							if good_quantity > 0 then
								comms_source.goods[good] = 0
								if remove_list == "" then
									remove_list = remove_list .. _("contract-comms", "\n\nYour current cargo (") .. good
								else
									remove_list = remove_list .. _("contract-comms", ", ") .. good
								end
							end
						end
						remove_list = remove_list .. _("contract-comms", ") has been removed to make room for your contract cargo and to help defray the cost of upgrading your ship to Human Navy standards.")
						acceptance_message = acceptance_message .. remove_list
					end
					if comms_source.goods == nil then
						comms_source.goods = {}
					end
					comms_source.goods["food"] = 1
					comms_source.goods["medicine"] = 1
					comms_source.goods["dilithium"] = 1
					comms_source.goods["tritanium"] = 1
					comms_source.cargo = 0
					acceptance_message = acceptance_message .. string.format(_("contract-comms", "\n\nCritical cargo has been loaded aboard your ship, %s. Take the cargo to the %s system centered in sector %s. Find %s, the second planet out from star %s. Dock at station %s in orbit around %s's moon, %s to deliver the cargo. They will have crew standing by to immediately offload the cargo"),p:getCallSign(),planet_star:getCallSign(),planet_star:getSectorName(),planet_secondus:getCallSign(),planet_star:getCallSign(),supply_depot_station:getCallSign(),planet_secondus:getCallSign(),planet_secondus_moon:getCallSign())
					setCommsMessage(acceptance_message)
					plot1 = longDistanceCargo
					addCommsReply(_("Back"),commsStation)
				end)
				addCommsReply(_("Back"),commsStation)
			end)
		else	--all the bad guys need to be shot down before anyone will talk about the contract
			addCommsReply(_("contract-comms", "Check long distance contract"),function()
				setCommsMessage(_("contract-comms","No long distance contract here."))
				addCommsReply(_("contract-comms","I was told there was a long distance contract that started here"),nervousAdministrators)
				addCommsReply(_("contract-comms","You mean I came all this way for nothing?"),nervousAdministrators)
				addCommsReply(_("contract-comms","I risked my ship for a contract that does not exist?"),nervousAdministrators)
			end)
		end
	end
	if comms_target == first_station then
		if plot1_fleets_destroyed ~= nil then
			if plot1_fleets_destroyed > 0 then
				if not comms_source.impulse_upgrade then
					addCommsReply(_("ridExuari-comms", "Upgrade impulse engines"), function()
						impulseUpgrade(comms_source)
						setCommsMessage(_("ridExuari-comms", "Thanks for taking care of those Exuari. We've upgraded the topspeed of your impulse engines"))
						addCommsReply(_("Back"),commsStation)
					end)
				end
				if plot1_fleets_destroyed > 1 and not comms_source.missile_upgrade then
					addCommsReply(_("ridExuari-comms", "Add missile tubes"), function()
						missileTubeUpgrade(comms_source)
						setCommsMessage(_("ridExuari-comms", "Thanks for continuing to shoot down those Exuari. We've added some missile tubes to help you destroy the Exuari station"))
						plot1_message = string.format(_("ridExuari-", "%s has asked for help against Exuari forces and has provided your ship with missile weapons to help you destroy %s"),first_station:getCallSign(),exuari_harassing_station:getCallSign())
						addCommsReply(_("Back"),commsStation)
					end)
				end
				if plot1_fleets_destroyed > 2 and not comms_source.beam_damage_upgrade then
					addCommsReply(_("ridExuari-comms", "Upgrade beam damage"), function()
						comms_source.beam_damage_upgrade = true
						beamUpgrade(true,nil,true,true)
						-- beamUpgrade(damage,cycle_time,power_use,heat_generated,artifact_scanned)
						setCommsMessage(_("ridExuari-comms", "Looks like you're having a hard time with those Exuari. We've increased the damage your beam weapons deal out"))
						addCommsReply(_("Back"),commsStation)
					end)
				end
			end
		end
		if exuari_harassment_upgrade and not comms_source.add_small_jump then
			addCommsReply(_("ridExuari-comms", "Add jump drive"), function()
				jumpDriveUpgrade(comms_source)
				setCommsMessage(_("ridExuari-comms", "That Exuari station was a pain. Thanks for getting rid of it. We have fitted your ship with a 25 unit jump drive as a token of our gratitude.\n\nWe have also formally recognized your competence. This allows you to enter into contracts with independent entities in the area. There may even be contracts available originating from this station."))
				addCommsReply(_("Back"),commsStation)
			end)
		end
		if exuari_harassment_upgrade then
			if player.asteroid_search == nil then
				addCommsReply(_("Jenny-comms", "Asteroid research request"), function()
					setCommsMessage(_("Jenny-comms", "Posted on the station electronic request board:\n\nRequest services of vessel in the area to scan asteroids in search of asteroid with particular characteristics. Substantial reward. No formal contract available. For further details, contact Jenny McGuire"))
					addCommsReply(_("Jenny-comms", "Contact Jenny McGuire"),function()
						setCommsMessage(string.format(_("Jenny-comms", "Hi %s, I'm so glad you contacted me. I've been researching many of the nearby asteroids. There is one in particular that I am interested in. Unfortunately, I lost access to sensors with enough detail to scan from a distance and my research ship was shot out from under me by pirates. I was lucky to escape with my life. I would like to locate my special asteroid, but I did not record location details, only sensor details. The asteroid I am interested in has traces of osmium and iridium, both of which are fairly rare, but together, they are exceptionally rare. If you run across an asteroid like that, could you let me know? If I were able to continue my research, I would be very appreciative. I know several technicians that would be more than willing to provide your ship with a valuable upgrade."),player:getCallSign()))
						addCommsReply(_("Jenny-comms", "We will look, but can't promise anything"),function()
							setCommsMessage(_("Jenny-comms", "Thanks. I understand about priorities. Please contact me if you find anything"))
							player.asteroid_search = "enabled"
							player.asteroid_identified = false
							player.jenny_aboard = false
							first_station.asteroid_upgrade = false
							plot3 = jennyAsteroid
							player.asteroid_start_time = getScenarioTime()
							addCommsReply(_("Back"),commsStation)
						end)
						addCommsReply(_("Back"),commsStation)
					end)
					addCommsReply(_("Back"),commsStation)
				end)
			else
				if player.asteroid_identified then
					contactJennyMcguireAfterAsteroidIdentified()
				else
					contactJennyMcguire()
				end
			end
			if first_station.asteroid_upgrade then
				if player.asteroid_upgrade == nil then
					addCommsReply(_("Jenny-comms", "Get ship upgrade promised by Jenny McGuire"),function()
						setCommsMessage(_("Jenny-comms", "Choose one of these upgrades from Jenny McGuire's friends"))
						addCommsReply(_("Jenny-comms", "Decrease beam cycle time"),function()
							player.asteroid_upgrade = "done"
							beamUpgrade(nil,true)
							--	beamUpgrade(damage,cycle_time,power_use,heat_generated,artifact_scanned)
							setCommsMessage(string.format(_("Jenny-comms", "Your beam cycle time has been reduced. Jenny McGuire thanks you again and leaves %s to resume her work on %s"),player:getCallSign(),first_station:getCallSign()))
							plot3 = nil
							addCommsReply(_("Back"),commsStation)
						end)
						addCommsReply(_("Jenny-comms", "Decrease heat generated per beam fired"),function()
							player.asteroid_upgrade = "done"
							local bi = 0
							repeat
								comms_source:setBeamWeaponHeatPerFire(bi,comms_source:getBeamWeaponHeatPerFire(bi)*.8)
								bi = bi + 1
							until(comms_source:getBeamWeaponRange(bi) < 1)
							setCommsMessage(string.format(_("Jenny-comms", "The heat generated when firing your beams has been reduced. Jenny McGuire thanks you again and leaves %s to resume her work on %s"),player:getCallSign(),first_station:getCallSign()))
							plot3 = nil
							addCommsReply(_("Back"),commsStation)
						end)
						addCommsReply(_("Jenny-comms", "Increase ship acceleration"),function()
							player.asteroid_upgrade = "done"
							comms_source:setAcceleration(comms_source:getAcceleration() + 10)
							setCommsMessage(string.format(_("Jenny-comms", "Your ship acceleration has been increased. Jenny McGuire thanks you again and leaves %s to resume her work on %s"),player:getCallSign(),first_station:getCallSign()))
							plot3 = nil
							addCommsReply(_("Back"),commsStation)
						end)
					end)
				end
			end
		end
		if transition_contract_message and plot1 ~= transitionContract then
			addCommsReply(_("contract-comms", "Check long range contract"),function()
				createTransitionSystem()
				local distance_to_start = distance(first_station,transition_station)
				setCommsMessage(string.format(_("contract-comms", "The contract outline indicates that the contract starts at station %s, a Human Navy station %i units from here. It looks like a relatively straighforward delivery to another Human Navy station between 100 and 200 units away. It also mentions that only Human Navy ships may fulfill this contract. That should not be a problem since station %s will gladly fit your ship with a Human Navy squawker if you desire based on the service you've already provided in this area."),transition_station:getCallSign(),math.floor(distance_to_start/1000),first_station:getCallSign()))
				addCommsReply(_("contract-comms", "Accept"),function()
					local current_rep = comms_source:getReputationPoints()
					comms_source:setFaction("Human Navy"):setLongRangeRadarRange(30000):setJumpDriveRange(3000,30000)
					comms_source:setReputationPoints(current_rep)
					local accept_message = string.format(_("contract-comms", "Station %s has fitted you with a Human Navy Identification Friend or Foe (IFF) and increased your jump drive and sensor ranges to 30 units."),first_station:getCallSign())
					if comms_source:getWaypointCount() < 9 then
						local dsx, dsy = transition_station:getPosition()
						comms_source:commandAddWaypoint(dsx,dsy)
						accept_message = string.format(_("contract-comms", "%s\nThey also placed waypoint %i in your navigation system for station %s in sector %s."),accept_message,comms_source:getWaypointCount(),transition_station:getCallSign(),transition_station:getSectorName())
					else
						accept_message = string.format(_("contract-comms", "%s\nYou can find station %s in sector %s."),accept_message,transition_station:getCallSign(),transition_station:getSectorName())
					end
					plot1 = transitionContract
					setCommsMessage(accept_message)
					addCommsReply(_("Back"),commsStation)
				end)
				addCommsReply(_("Back"),commsStation)
			end)
		end
	end
	if contract_eligible then
		local ctd = comms_target.comms_data
		if ctd.contract ~= nil then
			local contract_available = false
			for contract, details in pairs(ctd.contract) do
				if details.type == "start" then
					if not details.accepted then
						contract_available = true
					end
				end
				if details.type == "fulfill" then
					if not details.fulfilled then
						contract_available = true
					end
				end
			end
			local contract_report = string.format(_("contract-comms", "Contract report from station %s:"),comms_target:getCallSign())
			if contract_available then
				addCommsReply(_("contract-comms", "Browse Contracts"), function()
					for contract, details in pairs(ctd.contract) do
						if details.type == "start" then
							if details.accepted ~= nil and not details.accepted and details.prompt ~= nil then
								contract_report = contract_report .. _("contract-comms", "\nTo Accept: ") .. details.prompt
								addCommsReply(string.format(_("contract-comms", "Accept %s contract"),details.short_prompt),details.func)
							end
						end
						if details.type == "fulfill" then
							if details.fulfilled ~= nil and not details.fulfilled and details.prompt ~= nil then
								contract_report = contract_report .. _("contract-comms", "\nTo Fulfill: ") .. details.prompt
								addCommsReply(string.format(_("contract-comms", "Fulfill %s contract"),details.short_prompt),details.func)
							end
						end
					end
					setCommsMessage(contract_report)
					addCommsReply(_("Back"),commsStation)
				end)
			end
		end
	end
	if comms_source:isFriendly(comms_target) then
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
				addCommsReply(_("Back"), commsStation)
			end)
		end
	else	--neutral 
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
	end	--end friendly/neutral 
	if goodCount > 0 then
		addCommsReply(_("trade-comms", "Buy, sell, trade"), function()
			local ctd = comms_target.comms_data
			local goodsReport = string.format(_("trade-comms", "Station %s:\nGoods or components available for sale: quantity, cost in reputation\n"),comms_target:getCallSign())
			for good, goodData in pairs(ctd.goods) do
				goodsReport = goodsReport .. string.format(_("trade-comms", "     %s: %i, %i\n"),good,goodData["quantity"],goodData["cost"])
			end
			if ctd.buy ~= nil then
				goodsReport = goodsReport .. _("trade-comms", "Goods or components station will buy: price in reputation\n")
				for good, price in pairs(ctd.buy) do
					goodsReport = goodsReport .. string.format(_("trade-comms", "     %s: %i\n"),good,price)
				end
			end
			goodsReport = goodsReport .. string.format(_("trade-comms", "Current cargo aboard %s:\n"),comms_source:getCallSign())
			local cargoHoldEmpty = true
			local goodCount = 0
			if comms_source.goods ~= nil then
				for good, goodQuantity in pairs(comms_source.goods) do
					goodCount = goodCount + 1
					goodsReport = goodsReport .. string.format(_("trade-comms", "     %s: %i\n"),good,goodQuantity)
				end
			end
			if goodCount < 1 then
				goodsReport = goodsReport .. _("trade-comms", "     Empty\n")
			end
			goodsReport = goodsReport .. string.format(_("trade-comms", "Available Space: %i, Available Reputation: %i\n"),comms_source.cargo,math.floor(comms_source:getReputationPoints()))
			setCommsMessage(goodsReport)
			for good, goodData in pairs(ctd.goods) do
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
			if ctd.trade.food ~= nil and ctd.trade.food and comms_source.goods ~= nil and comms_source.goods.food ~= nil and comms_source.goods.food.quantity > 0 then
				for good, goodData in pairs(ctd.goods) do
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
			if ctd.trade.medicine ~= nil and ctd.trade.medicine and comms_source.goods ~= nil and comms_source.goods.medicine ~= nil and comms_source.goods.medicine.quantity > 0 then
				for good, goodData in pairs(ctd.goods) do
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
			if ctd.trade.luxury ~= nil and ctd.trade.luxury and comms_source.goods ~= nil and comms_source.goods.luxury ~= nil and comms_source.goods.luxury.quantity > 0 then
				for good, goodData in pairs(ctd.goods) do
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
			--[[
			if ctd.buy ~= nil then
				for good, price in pairs(ctd.buy) do
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
			--]]
			addCommsReply(_("Back"), commsStation)
		end)
	end
end
function nervousAdministrators()
	setCommsMessage(_("contract-comms","I'm sure there will be one soon, but the administrators are nervously watching enemies fly around. I suggest you make a good name for yourself and go kill those enemies."))
	addCommsReply(_("Back"),commsStation)
end
function createTransitionSystem()
	if transition_station == nil then
		psx = first_station_x + random(100000,120000)
		psy = first_station_y + random(-60000,80000)
		if difficulty < 1 then
			stationSize = "Large Station"
		elseif difficulty > 1 then
			stationSize = "Small Station"
		else
			stationSize = "Medium Station"
		end
		pStation = placeStation(psx,psy,nil,"Human Navy",stationSize)
		table.insert(station_list,pStation)
		transition_station = pStation
		stationSize = nil
		transition_station:onDestroyed(transitionStationDestroyed)
		local gas_planet_name = {"Bespin","Aldea","Bersallis","Alpha Omicron","Farius Prime","Deneb","Mordan","Nelvana"}
		local gas_planet_distance = random(5000,15000)
		local gas_planet_angle = random(0,360)
		local plx, ply = vectorFromAngle(gas_planet_angle,gas_planet_distance)
		gas_planet = Planet():setPosition(psx+plx,psy+ply):setPlanetRadius(random(2500,4000)):setDistanceFromMovementPlane(random(-2500,-1500)):setPlanetSurfaceTexture("planets/gas-1.png"):setAxialRotationTime(random(200,400))
		local gas_planet_moon_distance = random(4000,8000)
		local mlx, mly = vectorFromAngle(gas_planet_angle+180,gas_planet_moon_distance)
		gas_planet_moon = Planet():setPosition(psx+mlx,psy+mly):setPlanetRadius(random(250,500)):setDistanceFromMovementPlane(random(-500,-200)):setAxialRotationTime(random(60,100)):setPlanetSurfaceTexture("planets/moon-1.png"):setOrbit(gas_planet,random(200,300))
		local direct_angle = angleFromVectorNorth(first_station_x,first_station_y,psx,psy) + 90
		local asteroid_list = {}
		local lax, lay, temp_list = createRandomAlongArc(Asteroid,100,first_station_x,first_station_y,60000,direct_angle-30,direct_angle+30,1800)
		asteroid_list = add_to_list(temp_list,asteroid_list)
		local la_2_x, la_2_y = createRandomAlongArc(Asteroid,1,first_station_x,first_station_y,60000,direct_angle-30,direct_angle+30,1800)
		asteroid_list = add_to_list(temp_list,asteroid_list)
		local avx, avy = vectorFromAngle(random(0,360),350-(difficulty*100))
		Artifact():setModel("artifact4"):setScanningParameters(difficulty*2,difficulty*2):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setDescriptions(_("scienceDescription-artifact", "Object of unknown origin"),_("scienceDescription-artifact", "Object of unknown origin, advanced technology detected")):allowPickup(true):onPickUp(maneuverArtifactPickup):setPosition(lax+avx,lay+avy)
		Artifact():setModel("artifact4"):setScanningParameters(difficulty*2,difficulty*2):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setDescriptions(_("scienceDescription-artifact", "Object of unknown origin"),_("scienceDescription-artifact", "Object of unknown origin, advanced technology detected")):allowPickup(true):onPickUp(burnOutArtifactPickup):setPosition(la_2_x+avx,la_2_y+avy)
		if difficulty >= 1 then
			repeat
				crx, cry = asteroid_list[math.random(1,#asteroid_list)]:getPosition()
			until(crx ~= lax and cry ~= lay and crx ~= la_2_x and cry ~= la_2_y)
			Artifact():setModel("artifact4"):setScanningParameters(difficulty*2,difficulty*2):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setDescriptions(_("scienceDescription-artifact", "Object of unknown origin"),_("scienceDescription-artifact", "Object of unknown origin, advanced technology detected")):allowPickup(true):onPickUp(burnOutArtifactPickup):setPosition(crx+avx,cry+avy)
		end
		if difficulty > 1 then
			repeat
				drx, dry = asteroid_list[math.random(1,#asteroid_list)]:getPosition()
			until(drx ~= lax and dry ~= lay and drx ~= la_2_x and dry ~= la_2_y and drx ~= crx and dry ~= cry)
			Artifact():setModel("artifact4"):setScanningParameters(difficulty*2,difficulty*2):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setDescriptions(_("scienceDescription-artifact", "Object of unknown origin"),_("scienceDescription-artifact", "Object of unknown origin, advanced technology detected")):allowPickup(true):onPickUp(burnOutArtifactPickup):setPosition(drx+avx,dry+avy)
		end
		local etx, ety = vectorFromAngle(direct_angle,57000)
		etx = etx + first_station_x
		ety = ety + first_station_y
		drop_bait = SupplyDrop():setFaction("Exuari"):setPosition(etx,ety):setDescriptions(_("scienceDescription-supply", "Supply Drop"),_("scienceDescription-supply", "Supply Drop containing energy, missiles and various ship system repair parts")):setScanningParameters(math.ceil(difficulty + .2),math.random(1,3))
		plot4 = highwaymen
		highway_time = getScenarioTime() + 30
		local nebula_list = {}
		local neb = Nebula():setPosition(etx + random(-500,500), ety + random(-500,500))
		table.insert(nebula_list,neb)
		for i=1,math.random(2,5) do
			local positioned_correctly = nil
			local neb_x = nil
			local neb_y = nil
			repeat
				positioned_correctly = true
				neb_x, neb_y = vectorFromAngle(random(0,360),random(5000,10000))
				local enx, eny = nebula_list[#nebula_list]:getPosition()
				neb_x = neb_x + enx
				neb_y = neb_y + eny
				for j=1,#nebula_list do
					if distance(nebula_list[j],neb_x,neb_y) < 5000 then
						positioned_correctly = false
						break
					end
				end
			until(positioned_correctly)
			neb = Nebula():setPosition(neb_x, neb_y)
			table.insert(nebula_list,neb)
		end
	end
end
function createHumanNavySystem()
	if supply_depot_station == nil then
		final_system_station_list = {}
		star_x = first_station_x + random(250000,270000)
		star_y = first_station_y + random(-20000,80000)
		local star_names = {"Rigel","Dagoba","Groombridge 34","Tau Ceti","Wolf 1061","Gliese 876","Barnard"}
		planet_star = Planet():setCallSign(star_names[math.random(1,#star_names)]):setPosition(star_x,star_y):setPlanetRadius(random(800,1100)):setDistanceFromMovementPlane(random(-2000,-1000)):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0,1.0,random(.5,1))
		local primus_distance = random(10000,20000)
		local primus_x, primus_y = vectorFromAngle(random(0,360),primus_distance)
		local primus_names = {"Minos","Talos","Thor","Minotaur","Thanatos","Hades","Tartarus","Erebus","Primus"}
		local primus_radius = random(800,1500)
		planet_primus = Planet():setCallSign(primus_names[math.random(1,#primus_names)]):setPosition(star_x+primus_x,star_y+primus_y):setPlanetRadius(primus_radius):setDistanceFromMovementPlane(random(-1500,-900)):setPlanetSurfaceTexture("planets/planet-2.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.5,0.5,random(.1,.4)):setOrbit(planet_star,random(400,500)):setAxialRotationTime(random(200,500))
		secondus_distance = random(25000,40000)
		local secondus_x, secondus_y = vectorFromAngle(random(0,360),secondus_distance)
		local secondus_names = {"New Terra","Gaia","Home","Secondus","Thulcandra","Territa","Garth","Aurora","Covenant"}
		planet_secondus_radius = random(2000,3000)
		planet_secondus = Planet():setCallSign(secondus_names[math.random(1,#secondus_names)]):setPosition(star_x+secondus_x,star_y+secondus_y):setPlanetRadius(planet_secondus_radius):setDistanceFromMovementPlane(random(-1500,-500)):setPlanetSurfaceTexture("planets/planet-1.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(random(.1,.4),random(.1,.4),1.0):setOrbit(planet_star,random(1500,2500)):setAxialRotationTime(random(200,500))
		local secondus_moon_x, secondus_moon_y = vectorFromAngle(random(0,360),random(7500,8000))
		local secondus_moon_names = {"Deimos","Europa","Tethys","Umbriel","Janus","Amalthea","Leda","Remus","Pandia"}
		secondus_moon_radius = random(250,550)
		planet_secondus_moon = Planet():setCallSign(secondus_moon_names[math.random(1,#secondus_moon_names)]):setPosition(star_x+secondus_x+secondus_moon_x,star_y+secondus_y+secondus_moon_y):setPlanetRadius(secondus_moon_radius):setDistanceFromMovementPlane(-secondus_moon_radius/2):setPlanetSurfaceTexture("planets/moon-1.png"):setAxialRotationTime(random(120,400)):setOrbit(planet_secondus,random(200,500))
		psx, psy = planet_secondus_moon:getPosition()
		psy = psy + secondus_moon_radius + 1500
		local pStation = placeStation(psx,psy,nil,"Human Navy")
		table.insert(station_list,pStation)
		table.insert(final_system_station_list,pStation)
		supply_depot_station = pStation
		--add the rest of the new terrain here
		local asteroid_start_angle = random(0,40)
		local asteroid_end_angle = random(120,300)
		local asteroid_list = createRandomAlongArc(Asteroid,100,star_x,star_y,primus_distance - primus_radius - 2000,asteroid_start_angle,asteroid_end_angle,2000)
		local nebulae = createRandomAlongArc(Nebula,math.random(3,8),star_x,star_y,25000,1,359,10000)
		local bh_angle = random(0,360)
		local bhx, bhy = vectorFromAngle(bh_angle,random(secondus_distance + planet_secondus_radius + 11000,secondus_distance + planet_secondus_radius + 20000))
		local black_hole = BlackHole():setPosition(star_x+bhx,star_y+bhy)
		local wh_x, wh_y = vectorFromAngle(bh_angle + random(120,250),random(secondus_distance + planet_secondus_radius + 11000,secondus_distance + planet_secondus_radius + 20000))
		supply_worm_hole = WormHole():setPosition(star_x+wh_x,star_y+wh_y)
		local sdx, sdy = supply_depot_station:getPosition()
		supply_worm_hole:setTargetPosition(sdx,sdy)
		--put in some stations
		local isx, isy = vectorFromAngle(random(0,360),6100)
		pStation = placeStation(star_x+bhx+isx,star_y+bhy+isy,nil,"Independent")
		table.insert(station_list,pStation)
		table.insert(final_system_station_list,pStation)
		isx, isy = vectorFromAngle(random(0,360),6100)
		pStation = placeStation(star_x+wh_x+isx,star_y+wh_y+isy,nil,"Independent")
		table.insert(station_list,pStation)
		table.insert(final_system_station_list,pStation)
		isx, isy = vectorFromAngle(bh_angle + random(20,60),random(secondus_distance + planet_secondus_radius + 11000,secondus_distance + planet_secondus_radius + 20000))
		pStation = placeStation(star_x+isx,star_y+isy,nil,"Human Navy")
		table.insert(station_list,pStation)
		table.insert(final_system_station_list,pStation)
		isx, isy = vectorFromAngle(bh_angle + random(300,320),random(secondus_distance + planet_secondus_radius + 11000,secondus_distance + planet_secondus_radius + 20000))
		pStation = placeStation(star_x+isx,star_y+isy,nil,"Human Navy")
		table.insert(station_list,pStation)
		table.insert(final_system_station_list,pStation)
		isx, isy = vectorFromAngle((asteroid_start_angle + asteroid_end_angle)/2,primus_distance - primus_radius - 2000)
		pStation = placeStation(star_x+isx,star_y+isy,nil,"Independent")
		table.insert(station_list,pStation)
		table.insert(final_system_station_list,pStation)
	end
end
function contactJennyMcguire()
	addCommsReply(_("Jenny-comms", "Contact Jenny McGuire"), function()
		setCommsMessage(_("Jenny-comms", "Were you able to find an asteroid with osmium and iridium?"))
		addCommsReply(_("Jenny-comms", "We think so"),function()
			local asteroid_note_prompt = _("Jenny-comms", "Excellent! I found my notes on the asteroid composition. Let's compare your readings to the ones I took. Overall, the asteroid had osmium, iridium, olivine and nickel. The rest was rock.\n\nWhat was your reading on osmium?\nEnter the 10's digit. For example, for 23.5, the 10's digit is 2")
			if getScenarioTime() - player.asteroid_start_time > 300 then
				local asteroid_structure = target_asteroid:getDescription("notscanned")
				asteroid_note_prompt = string.format(_("Jenny-comms", "Excellent! I found my notes on the asteroid composition. Let's compare your readings to the ones I took. %s, the asteroid had osmium, iridium, olivine and nickel. The rest was rock.\n\nWhat was your reading on osmium?\nEnter the 10's digit. For example, for 23.5, the 10's digit is 2"),asteroid_structure)
			end
			setCommsMessage(asteroid_note_prompt)
			for i=0,9 do
				addCommsReply(string.format(_("Jenny-comms", "10's digit %i"),i),function()
					print("input osmium 10's:",i)
					setCommsMessage(_("Jenny-comms", "Now for the osmium 1's digit. For example, for 23.5, the 1's digit is 3"))
					for j=0,9 do
						addCommsReply(string.format(_("Jenny-comms", "1's digit %i"),j),function()
							print("input osmium 1's:",j)
							setCommsMessage(_("Jenny-comms", "And one digit after the decimal point. For example, for 23.5, the digit after the decimal point is 5"))
							for k=0,9 do
								addCommsReply(string.format(_("Jenny-comms", "after decimal digit %i"),k),function()
									print("input osmium after decimal:",k)
									print(string.format("Osmium: %.1f",i*10 + j + k/10))
									--setCommsMessage(string.format("osmium: %.1f",i*10 + j + k/10))
									setCommsMessage(string.format(_("Jenny-comms", "Osmium: %.1f\nThe Iridium 10's digit. For example, for 23.5, the 10's digit is 2"),i*10 + j + k/10))
									for l=0,9 do
										addCommsReply(string.format(_("Jenny-comms", "10's digit %i"),l),function()
											print("input iridium 10's:",l)
											setCommsMessage(_("Jenny-comms", "Now for the iridium 1's digit. For example, for 23.5, the 1's digit is 3"))
											for m=0,9 do
												addCommsReply(string.format(_("Jenny-comms", "1's digit %i"),m),function()
													print("input iridium 1's:",m)
													setCommsMessage(_("Jenny-comms", "And one digit after the decimal point. For example, for 23.5, the digit after the decimal point is 5"))
													for n=0,9 do
														addCommsReply(string.format(_("Jenny-comms", "after decimal digit %i"),n),function()
															print("input iridium after decimal:",n)
															print(string.format("iridium: %.1f",l*10 + m + n/10))
															--setCommsMessage(string.format("iridium: %.1f",l*10 + m + n/10))
															setCommsMessage(string.format(_("Jenny-comms", "Osmium: %.1f\nIridium: %.1f\nThe Olivine 10's digit. For example, for 23.5, the 10's digit is 2"),i*10 + j + k/10,l*10 + m + n/10))
															for o=0,9 do
																addCommsReply(string.format(_("Jenny-comms", "10's digit %i"),o),function()
																	print("input olivine 10's:",o)
																	setCommsMessage(_("Jenny-comms", "Now for the olivine 1's digit. For example, for 23.5, the 1's digit is 3"))
																	for p=0,9 do
																		addCommsReply(string.format(_("Jenny-comms", "1's digit %i"),p),function()
																			print("input olivine 1's:",p)
																			setCommsMessage(_("Jenny-comms", "And one digit after the decimal point. For example, for 23.5, the digit after the decimal point is 5"))
																			for q=0,9 do
																				addCommsReply(string.format(_("Jenny-comms", "after decimal digit %i"),q),function()
																					print("input olivine after decimal:",q)
																					print(string.format("olivine: %.1f",o*10 + p + q/10))
																					--setCommsMessage(string.format(_("Jenny-comms", "osmium: %.1f\niridium: %.1f\nOlivine: %.1f"),i*10 + j + k/10,l*10 + m + n/10,o*10 + p + q/10))
																					setCommsMessage(string.format(_("Jenny-comms", "Osmium: %.1f\nIridium: %.1f\nOlivine: %.1f\nThe Nickel 10's digit. For example, for 23.5, the 10's digit is 2"),i*10 + j + k/10,l*10 + m + n/10,o*10 + p + q/10))
																					for r=0,9 do
																						addCommsReply(string.format(_("Jenny-comms", "10's digit %i"),r),function()
																							print("input nickel 10's:",r)
																							setCommsMessage(_("Jenny-comms", "Now for the nickel 1's digit. For example, for 23.5, the 1's digit is 3"))
																							for s=0,9 do
																								addCommsReply(string.format(_("Jenny-comms", "1's digit %i"),s),function()
																									print("input nickel 1's:",s)
																									setCommsMessage(_("Jenny-comms", "And one digit after the decimal point. For example, for 23.5, the digit after the decimal point is 5"))
																									for t=0,9 do
																										addCommsReply(string.format(_("Jenny-comms", "after decimal digit %i"),t),function()
																											print("input nickel after decimal:",t)
																											print(string.format("nickel: %.1f",r*10 + s + t/10))
																											--setCommsMessage(string.format(_("Jenny-comms", "osmium: %.1f\niridium: %.1f\nOlivine: %.1f\nNickel: %.1f"),i*10 + j + k/10,l*10 + m + n/10,o*10 + p + q/10,r*10 + s + t/10))
																											local reported_percentages = string.format(_("Jenny-comms", "osmium: %.1f\niridium: %.1f\nOlivine: %.1f\nNickel: %.1f"),i*10 + j + k/10,l*10 + m + n/10,o*10 + p + q/10,r*10 + s + t/10)
																											if target_asteroid.osmium == i*10 + j + k/10 and
																												target_asteroid.iridium == l*10 + m + n/10 and
																												target_asteroid.olivine == o*10 + p + q/10 and
																												target_asteroid.nickel == r*10 + s + t/10 then
																												setCommsMessage(string.format(_("Jenny-comms", "That's it! Your reported compositional percentages:\n%s\n...exactly match my recorded compositional percentages! Now I need you to take me to within 5 units of the asteroid. You may want to put a waypoint on it"),reported_percentages))
																												player.asteroid_identified = true
																											else
																												setCommsMessage(string.format(_("Jenny-comms", "Unfortunately, those compositional percentages you provided:\n%s\n...do not match the asteroid I am looking for. But don't give up! Please keep looking and contact me when you find another asteroid candidate."),reported_percentages))
																											end
																											addCommsReply(_("Back"),commsStation)
																										end)
																									end
																									addCommsReply(_("Back"),commsStation)
																								end)
																							end
																							addCommsReply(_("Back"),commsStation)
																						end)
																					end
																					addCommsReply(_("Back"),commsStation)
																				end)
																			end
																			addCommsReply(_("Back"),commsStation)
																		end)
																	end
																	addCommsReply(_("Back"),commsStation)
																end)
															end
															addCommsReply(_("Back"),commsStation)
														end)
													end
													addCommsReply(_("Back"),commsStation)
												end)
											end
											addCommsReply(_("Back"),commsStation)
										end)
									end
									addCommsReply(_("Back"),commsStation)
								end)
							end
							addCommsReply(_("Back"),commsStation)
						end)
					end
					addCommsReply(_("Back"),commsStation)
				end)
			end
			addCommsReply(_("Back"),commsStation)
		end)
		addCommsReply(_("Back"),commsStation)
	end)
end
function contactJennyMcguireAfterAsteroidIdentified()
	if target_asteroid ~= nil then
		if player.asteroid_upgrade == nil then
			addCommsReply(_("Jenny-comms", "Contact Jenny McGuire"),function()
				if player.jenny_data_revealed == nil then
					local jenny_prompt = ""
					if player.jenny_aboard then
						jenny_prompt = string.format(_("Jenny-comms", "Communication routed to guest quarters aboard %s\n\n"),player:getCallSign())
					end
					setCommsMessage(string.format(_("Jenny-comms", "%sYes? What can I do for you?"),jenny_prompt))
					addCommsReply(_("Jenny-comms", "What were those asteroid compositional percentages?"),function()
						setCommsMessage(string.format(_("Jenny-comms", "Osmium: %.1f\nIridium: %.1f\nOlivine: %.1f\nNickel: %.1f"),target_asteroid.osmium,target_asteroid.iridium,target_asteroid.olivine,target_asteroid.nickel))
						addCommsReply(_("Back"),commsStation)
					end)
					if target_asteroid ~= nil and target_asteroid:isValid() then
						if distance(player,target_asteroid) < 1500 then
							addCommsReply(_("Jenny-comms", "Asteroid under 1.5 units away"),function()
								local vx, vy = player:getVelocity()
								if vx ~= 0 or vy ~= 0 then
									setCommsMessage(string.format(_("Jenny-comms", "%s must come to a complete stop before I can deactivate the cloaking mechanism"),player:getCallSign()))
								else
									setCommsMessage(_("Jenny-comms", "Cloaking mechanism deactivated, please retrieve my data store"))
									local px, py = player:getPosition()
									player.jenny_data_revealed = true
									Artifact():setDescriptions(_("scienceDescription-artifact", "Stasis container"),_("scienceDescription-artifact", "Stasis container with a high density data store inside")):setScanningParameters(1,2):allowPickup(true):setPosition((px+target_asteroid_x)/2,(py+target_asteroid_y)/2):setModel("SensorBuoyMKI"):onPickUp(function(self,grabber)
										grabber:addToShipLog(string.format(_("Jenny-shipLog", "[Jenny McGuire] Thank you for picking up my research for me, %s. Next time you dock with %s you can get the upgrade I promised"),grabber:getCallSign(),first_station:getCallSign()),"Magenta")
										first_station.asteroid_upgrade = true
									end)
								end
								addCommsReply(_("Back"),commsStation)
							end)
						else
							addCommsReply(_("Jenny-comms", "What is the asteroid approach procedure?"),function()
								if player.jenny_aboard then
									setCommsMessage(_("Jenny-comms", "Get within 1.5 units of the asteroid and contact me. I will deactivate the cloaking mechanism on my research data store so that you can then pick it up"))
								else
									setCommsMessage(string.format(_("Jenny-comms", "First, you have to pick me up from %s"),first_station:getCallSign()))
								end
								addCommsReply(_("Back"),commsStation)
							end)
						end
					else
						addCommsReply(_("Jenny-comms", "The asteroid may have been destroyed"),function()
							setCommsMessage(_("Jenny-comms", "So it seems. Looks like I'll have to find another asteroid. Thanks for your help."))
							addCommsReply(_("Back"),commsStation)
						end)
					end
				else
					if first_station.asteroid_upgrade then
						setCommsMessage(string.format(_("Jenny-comms", "Thanks for getting my research for me. Dock with %s to get the upgrade"),first_station:getCallSign()))
					else
						setCommsMessage(_("Jenny-comms", "Please retrieve my data store"))
					end
				end
				addCommsReply(_("Back"),commsStation)
			end)
		end
	end
end
function setOptionalOrders()
	optionalOrders = ""
	if plot1_type == "optional" then
		optionalOrders = plot1_message
	end
end
function setSecondaryOrders()
	secondaryOrders = ""
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
				setCommsMessage(_("ammo-comms", "You can't afford as much as I'd like to give you"))
				addCommsReply(_("ammo-comms", "Get just one"), function()
					if comms_source:takeReputationPoints(points_per_item) then
						comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + 1)
						if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
							setCommsMessage(_("ammo-comms", "You are fully loaded and ready to explode things."))
						else
							setCommsMessage(_("ammo-comms", "We generously resupplied you with one weapon charge.\nPut it to good use."))
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
    if stationCommsDiagnostic then print("handleUndockedState") end
    local player = comms_source
    local ctd = comms_target.comms_data
    if comms_source:isFriendly(comms_target) then
        oMsg = _("station-comms", "Good day, officer.\nIf you need supplies, please dock with us first.")
    else
        oMsg = _("station-comms", "Greetings.\nIf you want to do business, please dock with us first.")
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. _("station-comms", "\nBe aware that if enemies in the area get much closer, we will be too busy to conduct business with you.")
	end
	setCommsMessage(oMsg)
	if exuari_harassment_upgrade then
		if player.asteroid_search ~= nil then
			if player.asteroid_identified then
				contactJennyMcguireAfterAsteroidIdentified()
			else
				contactJennyMcguire()
			end
		end
	end
 	addCommsReply(_("station-comms", "I need information"), function()
		setCommsMessage(_("station-comms", "What kind of information do you need?"))
		if stationCommsDiagnostic then print("requesting information") end
		local ctd = comms_target.comms_data
		if stationCommsDiagnostic then print(ctd.character) end
		if ctd.character ~= nil then
			addCommsReply(string.format(_("characterInfo-comms", "Tell me about %s"),ctd.character), function()
				if ctd.characterDescription ~= nil then
					setCommsMessage(ctd.characterDescription)
				else
					if ctd.characterDeadEnd == nil then
						local deadEndChoice = math.random(1,5)
						if deadEndChoice == 1 then
							ctd.characterDeadEnd = string.format(_("characterInfo-comms", "Never heard of %s"), ctd.character)
						elseif deadEndChoice == 2 then
							ctd.characterDeadEnd = string.format(_("characterInfo-comms", "%s died last week. The funeral was yesterday"), ctd.character)
						elseif deadEndChoice == 3 then
							ctd.characterDeadEnd = string.format(_("characterInfo-comms", "%s? Who's %s? There's nobody here named %s"),ctd.character,ctd.character,ctd.character)
						elseif deadEndChoice == 4 then
							ctd.characterDeadEnd = string.format(_("characterInfo-comms", "We don't talk about %s. They are gone and good riddance"),ctd.character)
						else
							ctd.characterDeadEnd = string.format(_("characterInfo-comms", "I think %s moved away"),ctd.character)
						end
					end
					setCommsMessage(ctd.characterDeadEnd)
				end
				addCommsReply(_("Back"), commsStation)
			end)
		end
	    if comms_source:isFriendly(comms_target) then
			addCommsReply(_("orders-comms", "What are my current orders?"), function()
				setOptionalOrders()
				setSecondaryOrders()
				ordMsg = primaryOrders .. _("orders-comms", "\n") .. secondaryOrders .. optionalOrders
				if playWithTimeLimit then
					ordMsg = ordMsg .. string.format(_("orders-comms", "\n   %i Minutes remain in game"),math.floor(gameTimeLimit/60))
				end
				setCommsMessage(ordMsg)
				addCommsReply(_("Back"), commsStation)
			end)
		end
		addCommsReply(_("ammo-comms", "What ordnance do you have available for restock?"), function()
			local ctd = comms_target.comms_data
			local missileTypeAvailableCount = 0
			local ordnanceListMsg = ""
			if ctd.weapon_available.Nuke then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. _("ammo-comms", "\n   Nuke")
			end
			if ctd.weapon_available.EMP then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. _("ammo-comms", "\n   EMP")
			end
			if ctd.weapon_available.Homing then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. _("ammo-comms", "\n   Homing")
			end
			if ctd.weapon_available.Mine then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. _("ammo-comms", "\n   Mine")
			end
			if ctd.weapon_available.HVLI then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. _("ammo-comms", "\n   HVLI")
			end
			if missileTypeAvailableCount == 0 then
				ordnanceListMsg = _("ammo-comms", "We have no ordnance available for restock")
			elseif missileTypeAvailableCount == 1 then
				ordnanceListMsg = string.format(_("ammo-comms", "We have the following type of ordnance available for restock:%s"), ordnanceListMsg)
			else
				ordnanceListMsg = string.format(_("ammo-comms", "We have the following types of ordnance available for restock:%s"), ordnanceListMsg)
			end
			setCommsMessage(ordnanceListMsg)
			addCommsReply(_("Back"), commsStation)
		end)
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
		local goodsAvailable = false
		if ctd.goods ~= nil then
			for good, goodData in pairs(ctd.goods) do
				if goodData["quantity"] > 0 then
					goodsAvailable = true
				end
			end
		end
		if goodsAvailable then
			addCommsReply(_("trade-comms", "What goods do you have available for sale or trade?"), function()
				local ctd = comms_target.comms_data
				local goodsAvailableMsg = string.format(_("trade-comms", "Station %s:\nGoods or components available: quantity, cost in reputation"),comms_target:getCallSign())
				for good, goodData in pairs(ctd.goods) do
					goodsAvailableMsg = goodsAvailableMsg .. string.format(_("trade-comms", "\n   %14s: %2i, %3i"),good,goodData["quantity"],goodData["cost"])
				end
				setCommsMessage(goodsAvailableMsg)
				addCommsReply(_("Back"), commsStation)
			end)
		end
		local has_gossip = random(1,100) < (100 - (30 * (difficulty - .5)))
		if (comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "") or
			(comms_target.comms_data.history ~= nil and comms_target.comms_data.history ~= "") or
			(comms_source:isFriendly(comms_target) and comms_target.comms_data.gossip ~= nil and comms_target.comms_data.gossip ~= "" and has_gossip) then
			addCommsReply(_("station-comms", "Tell me more about your station"), function()
				local ctd = comms_target.comms_data
				setCommsMessage(_("station-comms", "What would you like to know?"))
				if comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "" then
					addCommsReply(_("stationGeneralInfo-comms", "General information"), function()
						setCommsMessage(ctd.general)
						addCommsReply(_("Back"), commsStation)
					end)
				end
				if ctd.history ~= nil and ctd.history ~= "" then
					addCommsReply(_("stationStory-comms", "Station history"), function()
						setCommsMessage(ctd.history)
						addCommsReply(_("Back"), commsStation)
					end)
				end
				if ctd.gossip ~= nil then
					if random(1,100) < 80 then
						addCommsReply(_("gossip-comms", "Gossip"), function()
							setCommsMessage(ctd.gossip)
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
			end)	--end station info comms reply branch
		end	--end public relations if branch
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
        addCommsReply(string.format(_("stationAssist-comms", "Please send Adder MK5 reinforcements! (%d rep)"),getServiceCost("reinforcements")), function()
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage(_("stationAssist-comms", "You need to set a waypoint before you can request reinforcements."));
            else
                setCommsMessage(_("stationAssist-comms", "To which waypoint should we dispatch the reinforcements?"));
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply(string.format(_("stationAssist-comms", "WP %d"),n), function()
						if comms_source:takeReputationPoints(getServiceCost("reinforcements")) then
							ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
							ship:setCommsScript(""):setCommsFunction(commsShip)
							setCommsMessage(string.format(_("stationAssist-comms", "We have dispatched %s to assist at waypoint %d"),ship:getCallSign(),n))
						else
							setCommsMessage(_("needRep-comms", "Not enough reputation!"));
						end
                        addCommsReply(_("Back"), commsStation)
                    end)
                end
            end
            addCommsReply(_("Back"), commsStation)
        end)
        addCommsReply(string.format(_("stationAssist-comms", "Please send Phobos T3 reinforcements! (%d rep)"),getServiceCost("phobosReinforcements")), function()
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage(_("stationAssist-comms", "You need to set a waypoint before you can request reinforcements."));
            else
                setCommsMessage(_("stationAssist-comms", "To which waypoint should we dispatch the reinforcements?"));
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply(string.format(_("stationAssist-comms", "WP %d"),n), function()
						if comms_source:takeReputationPoints(getServiceCost("phobosReinforcements")) then
							ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Phobos T3"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
							ship:setCommsScript(""):setCommsFunction(commsShip)
							setCommsMessage(string.format(_("stationAssist-comms", "We have dispatched %s to assist at waypoint %d"),ship:getCallSign(),n))
						else
							setCommsMessage(_("needRep-comms", "Not enough reputation!"));
						end
                        addCommsReply(_("Back"), commsStation)
                    end)
                end
            end
            addCommsReply(_("Back"), commsStation)
        end)
        addCommsReply(string.format(_("stationAssist-comms", "Please send Stalker Q7 reinforcements! (%d rep)"),getServiceCost("stalkerReinforcements")), function()
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage(_("stationAssist-comms", "You need to set a waypoint before you can request reinforcements."));
            else
                setCommsMessage(_("stationAssist-comms", "To which waypoint should we dispatch the reinforcements?"));
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply(string.format(_("stationAssist-comms", "WP %d"),n), function()
						if comms_source:takeReputationPoints(getServiceCost("stalkerReinforcements")) then
							ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Stalker Q7"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
							ship:setCommsScript(""):setCommsFunction(commsShip)
							setCommsMessage(string.format(_("stationAssist-comms", "We have dispatched %s to assist at waypoint %d"),ship:getCallSign(),n))
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
-- Return the number of reputation points that a specified service costs for the current player.
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
--	Ship communication  --
--------------------------
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
	setPlayer()
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
		setCommsMessage(_("shipAssist-comms", "What do you want?"));
	else
		setCommsMessage(_("shipAssist-comms", "Sir, how can we assist?"));
	end
	local nearby_enemy_ships = {}
	local obj_list = comms_target:getObjectsInRange(6000)
	for i,obj in ipairs(obj_list) do
		if obj.typeName == "CpuShip" then
			if obj:isEnemy(comms_target) then
				local ship = {ship = ship, name = obj:getCallSign()}
				if obj:isFullyScannedBy(comms_source) then
					ship.shield = obj:getShieldsFrequency()
					ship.beam = obj:getBeamFrequency()
				end
				table.insert(nearby_enemy_ships,ship)
			end
		end
	end
	if #nearby_enemy_ships > 0 then
		--[[	--setBeamFrequency is not available
		if comms_target:getBeamWeaponRange(0) > 1 then
			addCommsReply("Set your beam frequency",function()
				local out = "Enemy ships nearby:"
				for i, ship in ipairs(nearby_enemy_ships) do
					if ship.shield ~= nil then
						out = string.format("%s\n%s: Shields best against beams at %i THz",out,ship.name,ship.shield * 20 + 400)
					else
						out = string.format("%s\n%s",out,ship.name)
					end
				end
				setCommsMessage(out)
				for i=0,20 do
					addCommsReply(string.format("Set beams to frequency %i THz",i * 20 + 400),function()
						comms_target:setBeamFrequency(i)
					end)
				end
			end)
		end
		--]]
		addCommsReply(_("shipAssist-comms","Set your shield frequency"),function()
			local out = _("shipAssist-comms","Enemy ships nearby:")
			for i, ship in ipairs(nearby_enemy_ships) do
				if ship.beam ~= nil then
					out = string.format(_("shipAssist-comms","%s\n%s: Beams penetrate best against shields at %i THz"),out,ship.name,ship.beam * 20 + 400)
				else
					out = string.format("%s\n%s",out,ship.name)
				end
			end
			setCommsMessage(out)
			for i=0,20 do
				addCommsReply(string.format(_("shipAssist-comms","Set shields to frequency %i THz"),i * 20 + 400),function()
					comms_target:setShieldsFrequency(i)
					setCommsMessage(string.format(_("shipAssist-comms","Shields set to %i THz"),i * 20 + 400))
					addCommsReply(_("Back"), commsShip)
				end)
			end
			addCommsReply(_("Back"), commsShip)
		end)
	end
	addCommsReply(_("shipAssist-comms", "Defend a waypoint"), function()
		if comms_source:getWaypointCount() == 0 then
			setCommsMessage(_("shipAssist-comms", "No waypoints set. Please set a waypoint first."));
			addCommsReply(_("Back"), commsShip)
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
	for i, obj in ipairs(comms_target:getObjectsInRange(5000)) do
		if obj.typeName == "SpaceStation" and not comms_target:isEnemy(obj) then
			addCommsReply(string.format(_("shipAssist-comms", "Dock at %s"), obj:getCallSign()), function()
				setCommsMessage(string.format(_("shipAssist-comms", "Docking at %s."), obj:getCallSign()));
				comms_target:orderDock(obj)
				addCommsReply(_("Back"), commsShip)
			end)
		end
	end
	if comms_target.fleet ~= nil then
		addCommsReply(string.format(_("shipAssist-comms", "Direct %s"),comms_target.fleet), function()
			setCommsMessage(string.format(_("shipAssist-comms", "What command should be given to %s?"),comms_target.fleet))
			addCommsReply(_("shipAssist-comms", "Report hull and shield status"), function()
				msg = _("shipAssist-comms", "Fleet status:")
				for i, fleetShip in ipairs(friendlyDefensiveFleetList[comms_target.fleet]) do
					if fleetShip ~= nil and fleetShip:isValid() then
						msg = msg .. string.format(_("shipAssist-comms", "\n %s:"), fleetShip:getCallSign())
						msg = msg .. string.format(_("shipAssist-comms", "\n    Hull: %d%%"), math.floor(fleetShip:getHull() / fleetShip:getHullMax() * 100))
						local shields = fleetShip:getShieldCount()
						if shields == 1 then
							msg = msg .. string.format(_("shipAssist-comms", "\n    Shield: %d%%"), math.floor(fleetShip:getShieldLevel(0) / fleetShip:getShieldMax(0) * 100))
						else
							msg = msg .. _("shipAssist-comms", "\n    Shields: ")
							if shields == 2 then
								msg = msg .. string.format(_("shipAssist-comms", "Front: %d%% Rear: %d%%"), math.floor(fleetShip:getShieldLevel(0) / fleetShip:getShieldMax(0) * 100), math.floor(fleetShip:getShieldLevel(1) / fleetShip:getShieldMax(1) * 100))
							else
								for n=0,shields-1 do
									msg = msg .. string.format(_("shipAssist-comms", " %d:%d%%"), n, math.floor(fleetShip:getShieldLevel(n) / fleetShip:getShieldMax(n) * 100))
								end
							end
						end
					end
				end
				setCommsMessage(msg)
				addCommsReply(_("Back"), commsShip)
			end)
			addCommsReply(_("shipAssist-comms", "Report missile status"), function()
				msg = _("shipAssist-comms", "Fleet missile status:")
				for i, fleetShip in ipairs(friendlyDefensiveFleetList[comms_target.fleet]) do
					if fleetShip ~= nil and fleetShip:isValid() then
						msg = msg .. string.format(_("shipAssist-comms", "\n %s:"), fleetShip:getCallSign())
						local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
						missileMsg = ""
						for j, missile_type in ipairs(missile_types) do
							if fleetShip:getWeaponStorageMax(missile_type) > 0 then
								missileMsg = missileMsg .. string.format(_("shipAssist-comms", "\n      %s: %d/%d"), missile_type, math.floor(fleetShip:getWeaponStorage(missile_type)), math.floor(fleetShip:getWeaponStorageMax(missile_type)))
							end
						end
						if missileMsg ~= "" then
							msg = msg .. string.format(_("shipAssist-comms", "\n    Missiles: %s"), missileMsg)
						end
					end
				end
				setCommsMessage(msg)
				addCommsReply(_("Back"), commsShip)
			end)
			addCommsReply(_("shipAssist-comms", "Assist me"), function()
				for i, fleetShip in ipairs(friendlyDefensiveFleetList[comms_target.fleet]) do
					if fleetShip ~= nil and fleetShip:isValid() then
						fleetShip:orderDefendTarget(comms_source)
					end
				end
				setCommsMessage(string.format(_("shipAssist-comms", "%s heading toward you to assist"),comms_target.fleet))
				addCommsReply(_("Back"), commsShip)
			end)
			addCommsReply(_("shipAssist-comms", "Defend a waypoint"), function()
				if comms_source:getWaypointCount() == 0 then
					setCommsMessage(_("shipAssist-comms", "No waypoints set. Please set a waypoint first."));
					addCommsReply(_("Back"), commsShip)
				else
					setCommsMessage(_("shipAssist-comms", "Which waypoint should we defend?"));
					for n=1,comms_source:getWaypointCount() do
						addCommsReply(string.format(_("shipAssist-comms", "Defend WP %d"), n), function()
							for i, fleetShip in ipairs(friendlyDefensiveFleetList[comms_target.fleet]) do
								if fleetShip ~= nil and fleetShip:isValid() then
									fleetShip:orderDefendLocation(comms_source:getWaypoint(n))
								end
							end
							setCommsMessage(string.format(_("shipAssist-comms", "We are heading to assist at WP %d."), n));
							addCommsReply(_("Back"), commsShip)
						end)
					end
				end
			end)
		end)
	end
	if shipCommsDiagnostic then print("done with fleet buttons") end
	local shipType = comms_target:getTypeName()
	if shipCommsDiagnostic then print("got ship type") end
	if shipType:find("Freighter") ~= nil then
		if shipCommsDiagnostic then print("it's a freighter") end
		if distance(comms_source, comms_target) < 5000 then
			if shipCommsDiagnostic then print("close enough to trade or sell") end
			if comms_data.friendlyness > 66 then
				if shipCommsDiagnostic then print("friendliest branch") end
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					if shipCommsDiagnostic then print("goods or equipment freighter") end
					if comms_source.goods ~= nil and comms_source.goods.luxury ~= nil and comms_source.goods.luxury > 0 then
						if shipCommsDiagnostic then print("player has luxury to trade") end
						for good, goodData in pairs(comms_data.goods) do
							if shipCommsDiagnostic then print("in freighter goods loop") end
							if goodData.quantity > 0 and good ~= "luxury" then
								if shipCommsDiagnostic then print("has something other than luxury") end
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
									setCommsMessage(string.format(_("trade-comms", "Traded your luxury for %s from %s"),good,comms_target:getCallSign()))
									addCommsReply(_("Back"), commsShip)
								end)
							end
						end	--freighter goods loop
					end	--player has luxury branch
				end	--goods or equipment freighter
				if comms_source.cargo > 0 then
					if shipCommsDiagnostic then print("player has room to purchase") end
					for good, goodData in pairs(comms_data.goods) do
						if shipCommsDiagnostic then print("in freighter goods loop") end
						if goodData.quantity > 0 then
							if shipCommsDiagnostic then print("found something to sell") end
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
				if shipCommsDiagnostic then print("average frienliness branch") end
				if comms_source.cargo > 0 then
					if shipCommsDiagnostic then print("player has room to purchase") end
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						if shipCommsDiagnostic then print("goods or equipment type freighter") end
						for good, goodData in pairs(comms_data.goods) do
							if shipCommsDiagnostic then print("in freighter cargo loop") end
							if goodData.quantity > 0 then
								if shipCommsDiagnostic then print("Found something to sell") end
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
						if shipCommsDiagnostic then print("not a goods or equipment freighter") end
						for good, goodData in pairs(comms_data.goods) do
							if shipCommsDiagnostic then print("in freighter cargo loop") end
							if goodData.quantity > 0 then
								if shipCommsDiagnostic then print("found something to sell") end
								addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),good,math.floor(goodData.cost*2)), function()
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
				if shipCommsDiagnostic then print("least friendly branch") end
				if comms_source.cargo > 0 then
					if shipCommsDiagnostic then print("player has room for purchase") end
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						if shipCommsDiagnostic then print("goods or equipment freighter") end
						for good, goodData in pairs(comms_data.goods) do
							if shipCommsDiagnostic then print("in freighter cargo loop") end
							if goodData.quantity > 0 then
								if shipCommsDiagnostic then print("found something to sell") end
								addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),good,math.floor(goodData.cost*2)), function()
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
			addCommsReply(_("trade-comms", "Do you have cargo you might sell?"), function()
				local goodCount = 0
				local cargoMsg = _("trade-comms", "We've got ")
				for good, goodData in pairs(comms_data.goods) do
					if goodData.quantity > 0 then
						if goodCount > 0 then
							cargoMsg = cargoMsg .. _("trade-comms", ", ") .. good
						else
							cargoMsg = cargoMsg .. good
						end
					end
					goodCount = goodCount + goodData.quantity
				end
				if goodCount == 0 then
					cargoMsg = cargoMsg .. _("trade-comms", "nothing")
				end
				setCommsMessage(cargoMsg)
				addCommsReply(_("Back"), commsShip)
			end)
		end
	end
	return true
end
function enemyComms(comms_data)
	if comms_data.friendlyness > 50 then
		local faction = comms_target:getFaction()
		local taunt_option = _("shipEnemy-comms", "We will see to your destruction!")
		local taunt_success_reply = _("shipEnemy-comms", "Your bloodline will end here!")
		local taunt_failed_reply = _("shipEnemy-comms", "Your feeble threats are meaningless.")
		if faction == "Kraylor" then
			setCommsMessage(_("shipEnemy-comms", "Ktzzzsss.\nYou will DIEEee weaklingsss!"));
			local kraylorTauntChoice = math.random(1,3)
			if kraylorTauntChoice == 1 then
				taunt_option = _("shipEnemy-comms", "We will destroy you")
				taunt_success_reply = _("shipEnemy-comms", "We think not. It is you who will experience destruction!")
			elseif kraylorTauntChoice == 2 then
				taunt_option = _("shipEnemy-comms", "You have no honor")
				taunt_success_reply = _("shipEnemy-comms", "Your insult has brought our wrath upon you. Prepare to die.")
				taunt_failed_reply = _("shipEnemy-comms", "Your comments about honor have no meaning to us")
			else
				taunt_option = _("shipEnemy-comms", "We pity your pathetic race")
				taunt_success_reply = _("shipEnemy-comms", "Pathetic? You will regret your disparagement!")
				taunt_failed_reply = _("shipEnemy-comms", "We don't care what you think of us")
			end
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
		comms_data.friendlyness = comms_data.friendlyness - random(0, 10)
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
function neutralComms(comms_data)
	local shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
		setCommsMessage(_("trade-comms", "Yes?"))
		addCommsReply(_("trade-comms", "Do you have cargo you might sell?"), function()
			local goodCount = 0
			local cargoMsg = _("trade-comms", "We've got ")
			for good, goodData in pairs(comms_data.goods) do
				if goodData.quantity > 0 then
					if goodCount > 0 then
						cargoMsg = cargoMsg .. _("trade-comms", ", ") .. good
					else
						cargoMsg = cargoMsg .. good
					end
				end
				goodCount = goodCount + goodData.quantity
			end
			if goodCount == 0 then
				cargoMsg = cargoMsg .. _("trade-comms", "nothing")
			end
			setCommsMessage(cargoMsg)
		end)
		if distance(comms_source,comms_target) < 5000 then
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
								addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),good,math.floor(goodData.cost*2)), function()
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
								addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),good,math.floor(goodData.cost*2)), function()
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
								addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),good,math.floor(goodData.cost*3)), function()
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
								addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),good,math.floor(goodData.cost*3)), function()
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
--	Player ship improvements
function addForwardBeam()
	if comms_source.add_forward_beam == nil then
		addCommsReply(_("upgrade-comms", "Add beam weapon"), function()
			local ctd = comms_target.comms_data
			local part_quantity = 0
			if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
				part_quantity = comms_source.goods[ctd.characterGood]
			end
			if part_quantity > 0 then
				comms_source.add_forward_beam = "done"
				comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
				comms_source.cargo = comms_source.cargo + 1
				local beam_index = 0
				repeat
					beam_index = beam_index + 1
				until(comms_source:getBeamWeaponRange(beam_index) < 1)
				comms_source:setBeamWeapon(beam_index,20,0,1200,6,5)
				setCommsMessage(_("upgrade-comms", "A beam wepon has been added to your ship"))
			else
				setCommsMessage(string.format(_("upgrade-comms", "%s cannot add a beam weapon to your ship unless you provide %s"),ctd.character,ctd.characterGood))
			end
			addCommsReply(_("Back"), commsStation)
		end)
	end
end
function efficientBatteries()
	if comms_source.efficientBatteriesUpgrade == nil then
		addCommsReply(_("upgrade-comms", "Increase battery efficiency"), function()
			local ctd = comms_target.comms_data
			local partQuantity = 0
			local partQuantity2 = 0
			if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
				partQuantity = comms_source.goods[ctd.characterGood]
			end
			if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood2] ~= nil and comms_source.goods[ctd.characterGood2] > 0 then
				partQuantity2 = comms_source.goods[ctd.characterGood2]
			end
			if partQuantity > 0 and partQuantity2 > 0 then
				comms_source.efficientBatteriesUpgrade = "done"
				comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
				comms_source.goods[ctd.characterGood2] = comms_source.goods[ctd.characterGood2] - 1
				comms_source.cargo = comms_source.cargo + 2
				comms_source:setMaxEnergy(comms_source:getMaxEnergy()*1.5)
				comms_source:setEnergy(comms_source:getMaxEnergy())
				setCommsMessage(string.format(_("upgrade-comms", "%s: I appreciate the %s and %s. You have a 50%% greater energy capacity due to increased battery efficiency"),ctd.character,ctd.characterGood,ctd.characterGood2))
			else
				setCommsMessage(string.format(_("upgrade-comms", "%s: You need to bring me some %s and %s before I can increase your battery efficiency"),ctd.character,ctd.characterGood,ctd.characterGood2))
			end
			addCommsReply(_("Back"), commsStation)
		end)
	end
end
function shrinkBeamCycle()
	if comms_source.shrinkBeamCycleUpgrade == nil then
		addCommsReply(_("upgrade-comms", "Reduce beam cycle time"), function()
			local ctd = comms_target.comms_data
			if comms_source:getBeamWeaponRange(0) > 0 then
				if	payForUpgrade() then
					local partQuantity = 0
					if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
						partQuantity = comms_source.goods[ctd.characterGood]
					end
					if partQuantity > 0 then
						comms_source.shrinkBeamCycleUpgrade = "done"
						comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
						comms_source.cargo = comms_source.cargo + 1
						beamUpgrade(nil,true)
						--	beamUpgrade(damage,cycle_time,power_use,heat_generated,artifact_scanned)
						setCommsMessage(_("upgrade-comms", "After accepting your gift, he reduced your Beam cycle time."))
					else
						setCommsMessage(string.format(_("upgrade-comms", "%s requires %s for the upgrade"),ctd.character,ctd.characterGood))
					end
				else
					comms_source.shrinkBeamCycleUpgrade = "done"
					beamUpgrade(nil,true)
					--	beamUpgrade(damage,cycle_time,power_use,heat_generated,artifact_scanned)
					setCommsMessage(string.format(_("upgrade-comms", "%s reduced your Beam cycle time at no cost in trade with the message, 'Go get those Kraylors.'"),ctd.character))
				end
			else
				setCommsMessage(_("upgrade-comms", "Your ship type does not support a beam weapon upgrade."))				
			end
		end)
	end
end
--	Mortal repair crew functions. Includes coolant loss as option to losing repair crew
function healthCheck(delta)
	healthCheckTimer = healthCheckTimer - delta
	if healthCheckTimer < 0 then
		if healthDiagnostic then print("health check timer expired") end
		local p = player
		if p ~= nil and p:isValid() then
			if p:getRepairCrewCount() > 0 then
				local fatalityChance = 0
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
				elseif p:getRepairCrewCount() == 2 then
					fatalityChance = fatalityChance * .75
				end
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
						p:addCustomMessage("Engineering","probe_launch_damage_message",_("damage-msgEngineer", "The probe launch system has been damaged"))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","probe_launch_damage_message_plus",_("damage-msgEngineer+", "The probe launch system has been damaged"))
					end
				elseif named_consequence == "hack" then
					p:setCanHack(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","hack_damage_message",_("damage-msgEngineer", "The hacking system has been damaged"))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","hack_damage_message_plus",_("damage-msgEngineer+", "The hacking system has been damaged"))
					end
				elseif named_consequence == "scan" then
					p:setCanScan(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","scan_damage_message",_("damage-msgEngineer", "The scanners have been damaged"))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","scan_damage_message_plus",_("damage-msgEngineer+", "The scanners have been damaged"))
					end
				elseif named_consequence == "combat_maneuver" then
					p:setCanCombatManeuver(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","combat_maneuver_damage_message",_("damage-msgEngineer", "Combat maneuver has been damaged"))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","combat_maneuver_damage_message_plus",_("damage-msgEngineer+", "Combat maneuver has been damaged"))
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
		end
	end
end
-------------------------------
--	Working transports plot  --
-------------------------------
function workingTransports(delta)
	transportCheckDelayTimer = transportCheckDelayTimer - delta
	if transportCheckDelayTimer < 0 then
		for i, wt in pairs(transports_around_independent_trio) do
			if wt ~= nil and wt:isValid() then
				if wt.targetStart ~= nil and wt.targetStart:isValid() then
					if wt:isDocked(wt.targetStart) then
						if wt.targetEnd ~= nil and wt.targetEnd:isValid() then
							wt:orderDock(wt.targetEnd)
						end
					end
				end
				if wt.targetEnd ~= nil and wt.targetEnd:isValid() then
					if wt:isDocked(wt.targetEnd) then
						if wt.targetStart ~= nil and wt.targetStart:isValid() then
							wt:orderDock(wt.targetStart)
						end
					end
				end
			end
		end
		transportCheckDelayTimer = delta + transportCheckDelayInterval
	end
end
-------------------------------------------------------------
--	Plot 1 Initial Exuari harassment, transition contract  --
-------------------------------------------------------------
function exuariHarassment(delta)
	if player.captain_log == nil then
		player.captain_log = 0
	end
	if exuari_harass_diagnostic then print("top of exuariHarassment function") end
	player = getPlayerShip(-1)
	if plot1_message == nil then
		if exuari_harass_diagnostic then print("message not sent yet") end
		local help_message = string.format(_("ridExuari-incCall", "[%s in %s] Hostile Exuari approach. Help us, please. We cannot defend ourselves. Your ship is the only thing that stands between us and destruction."),first_station:getCallSign(),first_station:getSectorName())
		if difficulty < 1 then
			help_message = string.format(_("ridExuari-incCall", "%s\n\nWe think there is an Exuari base hiding in a nebula in sector %s"),help_message,concealing_nebula:getSectorName())
		end
		player.harass_message_sent = first_station:sendCommsMessageNoLog(player,help_message)
		if player.harass_message_sent then
			plot1_message = string.format(_("ridExuari-incCall", "%s has asked for help against the Exuari"),first_station:getCallSign())
			plot1_type = "optional"
			plot1_danger = .5
			plot1_fleets_destroyed = 0
			plot1_fleets_spawned = 0
			plot1_defeat_message = string.format(_("ridExuari-msgMainscreen", "Station %s destroyed"),first_station:getCallSign())
		end
	end
	if player.captain_log < 1 then
		if getScenarioTime() > 90 and player.harass_message_sent then
			player:addToShipLog(string.format(_("ridExuari-shipLog", "[Captain's Log] We have started our initial shakedown cruise of %s, a %s class ship. The crew are glad to be moving up from the class three freighter we used to run. After several years of doing cargo delivery runs and personnel transfers, it's nice to be on a ship with more self reliance. We've got beam weapons! Our previous ship was defenseless. Unfortunately, our impulse engines are not as fast as our previous ship, but we might be able to fix that. That's the kind of compromise you make when you purchase surplus military hardware. I suspect that we got such a good deal on the ship because the previous owner, the governer of station %s, has an ulterior motive. After all, we are the best qualified to run this ship in the sector and we have not seen any other friendly armed ships around here."),player:getCallSign(),player:getTypeName(),first_station:getCallSign()),"Green")
			player.captain_log = 1
		end
	end
	if player.help_with_exuari_base_message == nil then
		if getScenarioTime() > 600 and exuari_harassing_station ~= nil and exuari_harassing_station:isValid() then
			player:addToShipLog(string.format(_("ridExuari-shipLog", "[Station %s] Based on our observation of the Exuari base %s in %s, we think it will continue to launch harassing spacecraft in our direction. We know it's a large target for a small fighter, but we believe you can destroy it, %s. We would be very grateful if you would do just that. Our defenses are very limited."),first_station:getCallSign(),exuari_harassing_station:getCallSign(),exuari_harassing_station:getSectorName(),player:getCallSign()),"Magenta")
			player.help_with_exuari_base_message = "sent"
		end
	end
	if first_station == nil or not first_station:isValid() then
		globalMessage(plot1_defeat_message)
		victory("Exuari")
	end
	if plot1_fleet_spawned then
		if exuari_harass_diagnostic then print("fleet spawned") end
		local plot1_fleet_count = 0
		for i, enemy in pairs(plot1_fleet) do
			if enemy ~= nil and enemy:isValid() then
				plot1_fleet_count = plot1_fleet_count + 1
				break
			end
		end
		if plot1_fleet_count < 1 then
			if exuari_harassing_station ~= nil and exuari_harassing_station:isValid() then
				if plot1_time == nil then
					plot1_time = getScenarioTime() + 500 + random(1,30) - (difficulty * 100)
					plot1_fleets_destroyed = plot1_fleets_destroyed + 1
				end
				if getScenarioTime() > plot1_time then
					plot1_danger = plot1_danger + .75
					plot1_fleet_spawned = false
					plot1_time = nil
				end
			else
				plot1 = nil
				plot1_type = nil
				plot1_time = nil
				plot1_defensive_time = nil
				plot1_danger = nil
				plot1_fleet_spawned = nil
				plot1_defensive_fleet_spawned = nil
				player:addReputationPoints(100)
				first_station:sendCommsMessage(player,_("ridExuari-incCall", "Thanks for taking care of that Exuari base and all the Exuari ships it deployed. Dock with us for a token of our appreciation"))
				exuari_harassment_upgrade = true
				plot2 = contractTarget
			end
		end
		if difficulty >= 1 then
			if exuari_harassing_station ~= nil and exuari_harassing_station:isValid() then
				local rotation_increment = .1
				if difficulty > 1 then
					rotation_increment = .15
				end
				exuari_harassing_station:setRotation(exuari_harassing_station:getRotation()+rotation_increment)
				if exuari_harassing_station:getRotation() >= 360 then
					exuari_harassing_station:setRotation(exuari_harassing_station:getRotation() - 360)
				end
			end
		end
	else
		if exuari_harass_diagnostic then print("fleet not spawned") end
		local spx, spy = first_station:getPosition()
		local efx, efy = vectorFromAngle(first_station_angle,distance(player,first_station))
		if exuari_harassing_station ~= nil and exuari_harassing_station:isValid() then
			efx, efy = exuari_harassing_station:getPosition()
			efx = (efx+spx)/2
			efy = (efy+spy)/2
		else
			efx = efx + spx
			efy = efy + spy
		end
		plot1_fleet = spawnEnemies(efx,efy,plot1_danger,"Exuari")
		for i, enemy in pairs(plot1_fleet) do
			enemy:orderFlyTowards(spx,spy)
		end
		plot1_fleet_spawned = true
		plot1_fleets_spawned = plot1_fleets_spawned + 1
	end
	if plot1_independent_fleet_spawned then
		plot1_fleet_count = 0
		for i, enemy in pairs(plot1_independent_fleet) do
			if enemy ~= nil and enemy:isValid() then
				plot1_fleet_count = plot1_fleet_count + 1
			end
		end
		if plot1_fleet_count < 1 then
			plot1_independent_fleet_spawned = false
		end
	else
		if exuari_harassing_station ~= nil and exuari_harassing_station:isValid() then
			if (math.floor(plot1_danger) % 2) == 0 then
				spx, spy = first_station:getPosition()
				plot1_independent_fleet = spawnEnemies(spx,spy,plot1_danger,"Independent",2000)
				for i, enemy in pairs(plot1_independent_fleet) do
					enemy:orderDefendTarget(first_station)
					enemy:setScannedByFaction("Independent",true)
				end
				plot1_independent_fleet_spawned = true
			end
		end
	end
	if plot1_defensive_fleet_spawned then
		if exuari_harass_diagnostic then print("defensive fleet spawned") end
		local clean_list = true
		for i,enemy in ipairs(plot1_defensive_fleet) do
			if enemy == nil or not enemy:isValid() then
				plot1_defensive_fleet[i] = plot1_defensive_fleet[#plot1_defensive_fleet]
				plot1_defensive_fleet[#plot1_defensive_fleet] = nil
				clean_list = false
				break
			end
		end
		if clean_list then
			for i, enemy in ipairs(plot1_defensive_fleet) do
				local current_order = enemy:getOrder()
				if current_order == "Defend Target" then
					if enemy:getWeaponTubeCount() > 0 then
						local low_on_missiles = false
						local zero_missiles = true
						for j, missile_type in ipairs(missile_types) do
							local max_missile = enemy:getWeaponStorageMax(missile_type)
							if max_missile > 0 then
								local current_count = enemy:getWeaponStorage(missile_type)
								if current_count <= (max_missile/2) then
									low_on_missiles = true
								end
								if current_count > 0 then
									zero_missiles = false
								end
							end
						end
						local evaluate_objects = enemy:getObjectsInRange(7500)
						local enemy_in_range = false
						for j, obj in pairs(evaluate_objects) do
							if obj.components.player_control ~= nil then
								if obj:getFactionId() ~= enemy:getFactionId() then
									enemy_in_range = true
									break									
								end
							end
						end
						if low_on_missiles and not enemy_in_range then
							enemy:orderDock(exuari_harassing_station)
						end
						evaluate_objects = enemy:getObjectsInRange(5000)
						enemy_in_range = false
						for j, obj in pairs(evaluate_objects) do
							if obj.components.player_control ~= nil then
								if obj:getFactionId() ~= enemy:getFactionId() then
									enemy_in_range = true
									break									
								end
							end
						end
						if zero_missiles and not enemy_in_range then
							enemy:orderDock(exuari_harassing_station)
						end
					end
				end
				if current_order == "Dock" then
					evaluate_objects = enemy:getObjectsInRange(7500)
					enemy_in_range = false
					for j, obj in pairs(evaluate_objects) do
						if obj.components.player_control ~= nil then
							if obj:getFactionId() ~= enemy:getFactionId() then
								enemy_in_range = true
								break									
							end
						end
					end
					if enemy_in_range then
						if enemy:getBeamWeaponRange(0) > 0 then
							enemy:orderDefendTarget(exuari_harassing_station)
						else
							if enemy:getWeaponTubeCount() > 0 then
								for k, missile_type in ipairs(missile_types) do
									if enemy:getWeaponStorage(missile_type) > 0 then
										enemy:orderDefendTarget(exuari_harassing_station)
										break
									end
								end
							end
						end
					else
						local full_on_missiles = true
						for j, missile_type in ipairs(missile_types) do
							local max_missile = enemy:getWeaponStorageMax(missile_type)
							if max_missile > 0 then
								if enemy:getWeaponStorage(missile_type) < max_missile then
									full_on_missiles = false
								end
							end
						end
						if full_on_missiles then
							enemy:orderDefendTarget(exuari_harassing_station)
						end
					end
				end
			end
			if #plot1_defensive_fleet < 1 then
				if exuari_harassing_station ~= nil and exuari_harassing_station:isValid() then
					if plot1_defensive_time == nil then
						plot1_defensive_time = getScenarioTime() + 500 + random(1,30) - (difficulty * 100)
					end
					if getScenarioTime() > plot1_defensive_time then
						plot1_defensive_fleet_spawned = false
						plot1_defensive_time = nil
					end
				end
			end
		end
	else
		if exuari_harassing_station ~= nil and exuari_harassing_station:isValid() then
			spx, spy = exuari_harassing_station:getPosition()
			plot1_defensive_fleet = spawnEnemies(spx,spy,1,"Exuari",2000)
			for i, enemy in pairs(plot1_defensive_fleet) do
				enemy:orderDefendTarget(exuari_harassing_station)
			end
			plot1_defensive_fleet_spawned = true
		end
	end
	if plot1_last_defense then
		if exuari_harassing_station ~= nil and exuari_harassing_station:isValid() then
			for i, enemy in pairs(plot1_last_defense_fleet) do
				if enemy ~= nil and enemy:isValid() then
					currrent_order = enemy:getOrder()
					if current_order == "Defend Target" then
						if enemy:getWeaponTubeCount() > 0 then
							low_on_missiles = false
							zero_missiles = true
							for j, missile_type in ipairs(missile_types) do
								max_missile = enemy:getWeaponStorageMax(missile_type)
								if max_missile > 0 then
									current_count = enemy:getWeaponStorage(missile_type)
									if current_count <= (max_missile/2) then
										low_on_missiles = true
									end
									if current_count > 0 then
										zero_missiles = false
									end
								end
							end
							evaluate_objects = enemy:getObjectsInRange(7500)
							enemy_in_range = false
							for j, obj in pairs(evaluate_objects) do
								if obj.components.player_control ~= nil then
									if obj:getFactionId() ~= enemy:getFactionId() then
										enemy_in_range = true
										break									
									end
								end
							end
							if low_on_missiles and not enemy_in_range then
								enemy:orderDock(exuari_harassing_station)
							end
							evaluate_objects = enemy:getObjectsInRange(5000)
							enemy_in_range = false
							for j, obj in pairs(evaluate_objects) do
								if obj.components.player_control ~= nil then
									if obj:getFactionId() ~= enemy:getFactionId() then
										enemy_in_range = true
										break									
									end
								end
							end
							if zero_missiles and not enemy_in_range then
								enemy:orderDock(exuari_harassing_station)
							end
						end
					end
					if current_order == "Dock" then
						evaluate_objects = enemy:getObjectsInRange(7500)
						enemy_in_range = false
						for j, obj in pairs(evaluate_objects) do
							if obj.components.player_control ~= nil then
								if obj:getFactionId() ~= enemy:getFactionId() then
									enemy_in_range = true
									break									
								end
							end
						end
						if enemy_in_range then
							if enemy:getBeamWeaponRange(0) > 0 then
								enemy:orderDefendTarget(exuari_harassing_station)
							else
								if enemy:getWeaponTubeCount() > 0 then
									for j, missile_type in ipairs(missile_types) do
										if enemy:getWeaponStorage(missile_type) > 0 then
											enemy:orderDefendTarget(exuari_harassing_station)
											break
										end
									end
								end
							end
						else
							full_on_missiles = true
							for j, missile_type in ipairs(missile_types) do
								local max_missile = enemy:getWeaponStorageMax(missile_type)
								if max_missile > 0 then
									if enemy:getWeaponStorage(missile_type) < max_missile then
										full_on_missiles = false
									end
								end
							end
							if full_on_missiles then
								enemy:orderDefendTarget(exuari_harassing_station)
							end
						end
					end
				end
			end
		end
	else
		if exuari_harassing_station ~= nil and exuari_harassing_station:isValid() then
			if exuari_harassing_station:getHull() < exuari_harassing_station:getHullMax() then
				spx, spy = exuari_harassing_station:getPosition()
				plot1_last_defense_fleet = spawnEnemies(spx,spy,5,"Exuari",2000)
				if difficulty <= 1 then
					local alert_level = player:getAlertLevel()
					if alert_level == "Normal" then
						player:commandSetAlertLevel("yellow")
					end
				end
				if difficulty < 1 then
					player:commandSetShields(true)
				end
				local ship_call_signs = ""
				for i, enemy in ipairs(plot1_last_defense_fleet) do
					enemy:orderDefendTarget(exuari_harassing_station)
					if ship_call_signs == "" then
						ship_call_signs = enemy:getCallSign()
					else
						ship_call_signs = ship_call_signs .. ", " .. enemy:getCallSign()
					end
				end
				if #plot1_last_defense_fleet > 1 then
					player:addToShipLog(string.format(_("ridExuari-shipLog", "%s just launched these ships: %s"),exuari_harassing_station:getCallSign(),ship_call_signs),"Red")
				else
					player:addToShipLog(string.format(_("ridExuari-shipLog", "%s just launched %s"),exuari_harassing_station:getCallSign(),ship_call_signs),"Red")
				end
				plot1_last_defense = true
			end
		end
	end
end
function transitionContract(delta)
	local p = player
	local sx, sy = transition_station:getPosition()
	if p.captain_log < 3 then
		if transition_log_time == nil then
			transition_log_time = getScenarioTime() + random(60,120)
		end
		if getScenarioTime() > transition_log_time then
			p.captain_log = 3
			p:addToShipLog(string.format(_("contract-shipLog","Our first contract to a station far away from 'home' marks a significant change in our development as a crew. %s and the rest of the stations know us now as self-sufficient contractors, capable of more than mere deliveries. We now go to develop further standing with the Human Navy."),first_station:getCallSign()),"Green")
		end
	end
	if transition_station.in_fleet == nil then
		if distance(p,transition_station) <= 45000 then
			local px, py = p:getPosition()
			transition_station.in_fleet = spawnEnemies((sx+px)/2,(sy+py)/2,2,"Exuari")
			for i,enemy in ipairs(transition_station.in_fleet) do
				enemy:orderFlyTowards(sx,sy)
			end
			transition_station.out_fleet = spawnEnemies((sx+px)/2,(sy+py)/2,2,"Exuari")
			for i,enemy in ipairs(transition_station.out_fleet) do
				enemy:orderFlyTowards(px,py)
			end
		end
	else
		local fleet_count = 0
		for i,enemy in pairs(transition_station.out_fleet) do
			if enemy ~= nil and enemy:isValid() then
				fleet_count = fleet_count + 1
				if string.find(enemy:getOrder(),"Defend") then
					enemy:orderFlyTowards(sx,sy)
				end
			end
		end
		for i,enemy in pairs(transition_station.in_fleet) do
			if enemy ~= nil and enemy:isValid() then
				fleet_count = fleet_count + 1
			end
		end
		if fleet_count == 0 then
			plot1 = nil
		end
	end
end
function longDistanceCargo(delta)
	if supply_depot_station ~= nil and supply_depot_station:isValid() then
		local p = player
		if p:isDocked(supply_depot_station) then
			local missing_good = false
			if p.goods ~= nil then
				if p.goods["food"] == nil or p.goods["food"] < 1 then
					missing_good = true
				end		
				if p.goods["medicine"] == nil or p.goods["medicine"] < 1 then
					missing_good = true
				end		
				if p.goods["dilithium"] == nil or p.goods["dilithium"] < 1 then
					missing_good = true
				end		
				if p.goods["tritanium"] == nil or p.goods["tritanium"] < 1 then
					missing_good = true
				end	
			else
				missing_good = true
			end
			if missing_good then
				if p.missing_good_message == nil then
					p:addToShipLog(string.format(_("cargo-shipLog", "[%s] Your delivery contract calls for food, medicine, dilithium and tritanium. Return when you have all four of these and we'll consider your contract fulfilled"),comms_target:getCallSign()),"Magenta")
					p.missing_good_message = "sent"
				end
			else
				if p.long_distance_upgrade == nil then
					p.goods["food"] = 0
					p.goods["medicine"] = 0
					p.goods["dilithium"] = 0
					p.goods["tritanium"] = 0
					p.cargo = 4
					p:setMaxEnergy(p:getMaxEnergy() + 100)
					p:setEnergy(p:getMaxEnergy())
					beamUpgrade(nil,true)
					--	beamUpgrade(damage,cycle_time,power_use,heat_generated,artifact_scanned)
					p:addToShipLog(string.format(_("cargo-shipLog", "[%s] Thanks for the cargo, %s. We'll make good use of it. We've added 100 units to your battery capacity and reduced your beam cycle time. Enjoy your visit to the %s system"),supply_depot_station:getCallSign(),p:getCallSign(),planet_star:getCallSign()),"Magenta")
					p.long_distance_upgrade = true
					plot1 = kraylorDiversionarySabotage
					plot2 = nil
					plot8 = opportunisticPirates
				end
			end
		end
		if supply_sabotage_fleet == nil then
			if distance(p,supply_depot_station) < 30000 then
				supply_sabotage_fleet = {}
				local sdx, sdy = supply_depot_station:getPosition()
				local spx, spy = vectorFromAngle(random(0,360),random(15000,25000) - (difficulty*3000))
				local enemy_fleet = spawnEnemies(sdx+spx,sdy+spy,3,"Exuari")
				for i, enemy in ipairs(enemy_fleet) do
					enemy:orderAttack(supply_depot_station)
					table.insert(supply_sabotage_fleet,enemy)
				end
				spx, spy = vectorFromAngle(random(0,360),random(15000,25000) - (difficulty*3000))
				enemy_fleet = spawnEnemies(sdx+spx,sdy+spy,3,"Exuari")
				for i, enemy in ipairs(enemy_fleet) do
					enemy:orderAttack(p)
					table.insert(supply_sabotage_fleet,enemy)
				end
				spx, spy = vectorFromAngle(random(0,360),random(15000,25000) - (difficulty*3000))
				enemy_fleet = spawnEnemies(sdx+spx,sdy+spy,3,"Exuari")
				for i, enemy in ipairs(enemy_fleet) do
					enemy:orderRoaming()
					table.insert(supply_sabotage_fleet,enemy)
				end
			end
		else
			local fleet_count = 0
			for i,enemy in pairs(supply_sabotage_fleet) do
				if enemy ~= nil and enemy:isValid() then
					fleet_count = fleet_count + 1
				end
			end
			if fleet_count == 0 then
				supply_sabotage_fleet = nil
			end
		end
	else
		globalMessage(_("msgMainscreen", "The supply depot station has been destroyed"))
		victory("Exuari")
	end
end
function opportunisticPirates(delta)
	local pirate_target_pool = {}
	local pirate_target = nil
	if greedy_pirate_fleet == nil then
		if greedy_pirate_danger == nil then
			greedy_pirate_danger = 1
		else
			greedy_pirate_danger = greedy_pirate_danger + 1
		end
		for i,station in ipairs(final_system_station_list) do
			if station:isValid() then
				table.insert(pirate_target_pool,station)
			end
		end
		repeat
			pirate_target = tableRemoveRandom(pirate_target_pool)
			if not pirate_target:isValid() then
				pirate_target = nil
			end
		until(pirate_target ~= nil or #pirate_target_pool == 0)
		local ptx = star_x
		local pty = star_y
		if pirate_target ~= nil then
			ptx, pty = pirate_target:getPosition()
		end
		local gpx, gpy = vectorFromAngle(random(0,360),random(10000,30000))
		greedy_pirate_fleet = spawnEnemies(ptx+gpx,pty+gpy,greedy_pirate_danger,"Exuari")
		for i, enemy in ipairs(greedy_pirate_fleet) do
			enemy:orderFlyTowards(ptx,pty)
		end
	 else
	 	if pirate_adjust_time == nil then
	 		pirate_adjust_time = getScenarioTime() + 7
	 	end
	 	if getScenarioTime() > pirate_adjust_time then
	 		pirate_adjust_time = getScenarioTime() + 7
	 		local adjustment_needed = false
	 		for i,ship in ipairs(greedy_pirate_fleet) do
				if string.find(ship:getOrder(),"Defend") then
					adjustment_needed = true
					break
				end
	 		end
			for i,station in ipairs(final_system_station_list) do
				if station:isValid() then
					table.insert(pirate_target_pool,station)
				end
			end
			repeat
				pirate_target = tableRemoveRandom(pirate_target_pool)
				if not pirate_target:isValid() then
					pirate_target = nil
				end
			until(pirate_target ~= nil or #pirate_target_pool == 0)
			if pirate_target ~= nil then
		 		for i,ship in ipairs(greedy_pirate_fleet) do
		 			if ship:isValid() then
		 				ship:orderAttack(pirate_target)
		 			end
		 		end
		 	else
		 		for i,ship in ipairs(greedy_pirate_fleet) do
		 			if ship:isValid() then
		 				ship:orderRoaming()
		 			end
		 		end
			end
	 	end
		local pirate_count = 0
		for i, enemy in ipairs(greedy_pirate_fleet) do
			if enemy ~= nil and enemy:isValid() then
				pirate_count = pirate_count + 1
				break
			end
		end
		if pirate_count < 1 then
			if random(0,5000) <= 1 then
				greedy_pirate_fleet = nil
			end
		end
	end
end
function kraylorDiversionarySabotage(delta)
	if kraylor_diversion_danger == nil then
		kraylor_diversion_danger = 3
	end
	local target_x, target_y = 0
	if supply_depot_station ~= nil and supply_depot_station:isValid() then
		target_x, target_y = supply_depot_station:getPosition()
	elseif planet_secondus_moon ~= nil and planet_secondus_moon:isValid() then
		target_x, target_y = planet_secondus_moon:getPosition()
	elseif planet_secondus ~= nil and planet_secondus:isValid() then
		target_x, target_y = planet_secondus:getPosition()
	end
	if diversionary_sabotage_fleet ~= nil then
		if diversionary_sabotage_fleet_adjust_time == nil then
			diversionary_sabotage_fleet_adjust_time = getScenarioTime() + 5
		end
		if getScenarioTime() > diversionary_sabotage_fleet_adjust_time then
			diversionary_sabotage_fleet_adjust_time = nil
			if supply_depot_station ~= nil and supply_depot_station:isValid() then
				local enemy_close_to_supply = 0
				local obj_list = supply_depot_station:getObjectsInRadius(target_x, target_y, 7500)
				for i,obj in ipairs(obj_list) do
					if obj.typeName == "CpuShip" then
						if obj:getFaction() == "Kraylor" then
							enemy_close_to_supply = enemy_close_to_supply + 1
							if distance(ship,supply_depot_station) < 1500 then
								supply_depot_station.sabotaged = true
								if kraylor_planet_buster_time == nil then
									kraylor_planet_buster_time = getScenarioTime() + 300
									plot6 = kraylorPlanetBuster
								end
							end
						end
					end
				end
			else
				if kraylor_planet_buster_time == nil then
					kraylor_planet_buster_time = getScenarioTime() + 300
					plot6 = kraylorPlanetBuster
				end
			end
			for i,ship in ipairs(diversionary_sabotage_fleet) do
				if ship:isValid() then
					ship:orderFlyTowards(target_x, target_y)
				end
			end
			if kraylor_diversion_danger >= 10 and enemy_close_to_supply > 0 and plot6 == nil then
				globalMessage(_("msgMainscreen", "You successfully handled the Kraylor threat"))
				victory("Human Navy")
			end
		end
	end
	if kraylor_sabotage_diversion_time == nil then
		kraylor_sabotage_diversion_interval = 30
		kraylor_sabotage_diversion_time = getScenarioTime() + kraylor_sabotage_diversion_interval
	end
	if getScenarioTime() > kraylor_sabotage_diversion_time then
		kraylor_sabotage_diversion_time = getScenarioTime() + kraylor_sabotage_diversion_interval
		if player.diversion_orders == nil then
			player.diversion_orders = "sent"
			player:addToShipLog(_("Kraylor-shipLog", "[Human Navy Regional Headquarters] All Human Navy vessels are hereby ordered to assist in the repelling of inbound Kraylor ships. We are not sure of their intent, but we are sure it is not good. Destroy them before they can destroy us"),"Red")
			player:addToShipLog(string.format(_("Kraylor-shipLog", "This includes you, %s"),player:getCallSign()),"Magenta")
			primaryOrders = _("KraylorOrders-comms", "Repel Kraylor")
		end
		if diversionary_sabotage_fleet == nil then
			if planet_secondus_moon ~= nil and planet_secondus_moon:isValid() then 
				local base_range = 10000
				local player_scanner_range = player:getLongRangeRadarRange()
				local rvx,rvy = vectorFromAngle(random(0,360),random(base_range,player_scanner_range + base_range))
				local spawn_x, spawn_y = 0
				repeat
					rvx,rvy = vectorFromAngle(random(0,360),random(base_range,player_scanner_range + base_range))
					spawn_x = target_x + rvx
					spawn_y = target_y + rvy
					base_range = base_range + 1000
				until(distance(player,spawn_x,spawn_y) > player_scanner_range)
				diversionary_sabotage_fleet = spawnEnemies(spawn_x,spawn_y,kraylor_diversion_danger,"Kraylor")
				for i,enemy in ipairs(diversionary_sabotage_fleet) do
					if enemy:isValid() then
						enemy:orderFlyTowards(target_x,target_y)
					end
				end
			end
		else
			local enemy_count = 0
			local enemy_close_to_target = 0
			for i,enemy in ipairs(diversionary_sabotage_fleet) do
				if enemy ~= nil and enemy:isValid() then
					enemy_count = enemy_count + 1
					if distance(enemy,target_x,target_y) < 1500 then
						enemy_close_to_target = enemy_close_to_target + 1
					end
				end
			end
			if enemy_count < 1 then
				kraylor_diversion_danger = kraylor_diversion_danger + 1
				diversionary_sabotage_fleet = nil
			end
			if enemy_count < (difficulty * 10) then
				if enemy_close_to_target < 1 then
					kraylor_diversion_danger = kraylor_diversion_danger + 1
					local kraylor_fleet = spawnEnemies(target_x,target_y,kraylor_diversion_danger,"Kraylor")
					for i, enemy in ipairs(kraylor_fleet) do
						rvx, rvy = vectorFromAngle(random(0,360),random(10000,20000))
						enemy:setPosition(target_x+rvx,target_y+rvy)
						enemy:orderFlyTowards(target_x,target_y)
						table.insert(diversionary_sabotage_fleet,enemy)
					end
				end
			else
				local angle = random(0,360)
				local angle_increment = 0
				if defend_against_kraylor_fleet == nil then
					defend_against_kraylor_fleet = spawnEnemies(target_x,target_y,kraylor_diversion_danger-2,"Human Navy")
					angle = random(0,360)
					angle_increment = 360/#defend_against_kraylor_fleet
					for i, ship in ipairs(defend_against_kraylor_fleet) do
						if supply_depot_station ~= nil and supply_depot_station:isValid() then
							rvx, rvy = vectorFromAngle(angle,1200)
							ship:setPosition(target_x+rvx,target_y+rvy)
							ship:orderDefendTarget(supply_depot_station)
						elseif planet_secondus_moon ~= nil and planet_secondus_moon:isValid() then
							rvx, rvy = vectorFromAngle(angle,secondus_moon_radius + 500)
							ship:setPosition(target_x+rvx,target_y+rvy)
							ship:orderDefendTarget(player)
						else
							rvx, rvy = vectorFromAngle(angle,planet_secondus_radius + 500)
							ship:setPosition(target_x+rvx,target_y+rvy)
							ship:orderDefendTarget(player)
						end
						angle = (angle + angle_increment) % 360
					end
				else
					local defensive_ships = 0
					for i, ship in pairs(defend_against_kraylor_fleet) do
						if ship ~= nil and ship:isValid() then
							defensive_ships = defensive_ships + 1
						end
					end
					if defensive_ships < (enemy_count/3) then
						more_friendlies = spawnEnemies(target_x,target_y,kraylor_diversion_danger-2,"Human Navy")
						angle_increment = 360/#more_friendlies
						for i,ship in ipairs(more_friendlies) do
							if supply_depot_station ~= nil and supply_depot_station:isValid() then
								rvx, rvy = vectorFromAngle(angle,1200)
								ship:setPosition(target_x+rvx,target_y+rvy)
								ship:orderDefendTarget(supply_depot_station)
							elseif planet_secondus_moon ~= nil and planet_secondus_moon:isValid() then
								rvx, rvy = vectorFromAngle(angle,secondus_moon_radius + 500)
								ship:setPosition(target_x+rvx,target_y+rvy)
								ship:orderDefendTarget(player)
							else
								rvx, rvy = vectorFromAngle(angle,planet_secondus_radius + 500)
								ship:setPosition(target_x+rvx,target_y+rvy)
								ship:orderDefendTarget(player)
							end
							angle = (angle + angle_increment) % 360
							table.insert(defend_against_kraylor_fleet,ship)
						end
					end
				end
			end
		end
	end
end
function kraylorPlanetBuster(delta)
	local target_x, target_y = 0
	local target_planet = nil
	local target_planet_radius = 0
	if planet_secondus_moon ~= nil and planet_secondus_moon:isValid() then
		target_x, target_y = planet_secondus_moon:getPosition()
		target_planet = planet_secondus_moon
		target_planet_radius = secondus_moon_radius
	elseif planet_secondus ~= nil and planet_secondus:isValid() then
		target_x, target_y = planet_secondus:getPosition()
		target_planet = planet_secondus
		target_planet_radius = planet_secondus_radius
	end
	if planetary_attack_fleet ~= nil then
		if planetary_attack_fleet_adjust_time == nil then
			planetary_attack_fleet_adjust_time = getScenarioTime() + 5
		end
		if getScenarioTime() > planetary_attack_fleet_adjust_time then
			planetary_attack_fleet_adjust_time = nil
			local enemy_close_to_planet_count = 0
			local obj_list = target_planet:getObjectsInRadius(target_x, target_y, 1500 + target_planet_radius)
			for i,obj in ipairs(obj_list) do
				if obj.typeName == "CpuShip" then
					if obj:getFaction() == "Kraylor" then
						enemy_close_to_planet_count = enemy_close_to_planet_count + 1
					end
				end
			end
			for i,ship in ipairs(planetary_attack_fleet) do
				if ship:isValid() then
					ship:orderFlyTowards(target_x, target_y)
				end
			end
			if planet_secondus_moon ~= nil and planet_secondus_moon:isValid() then
				if enemy_close_to_planet_count > 0 then
					local explosion_x, explosion_y = planet_secondus_moon:getPosition()
					local moon_name = planet_secondus_moon:getCallSign()
					planet_secondus_moon:destroy()
					ExplosionEffect():setPosition(explosion_x,explosion_y):setSize(secondus_moon_radius*2)
					exploding_planet_x = explosion_x
					exploding_planet_y = explosion_y
					exploding_planet_time = getScenarioTime() + 5
					planetary_attack_fleet_adjust_time = getScenarioTime() + 30
					plot7 = explodingPlanetDebris
					player:addToShipLog(string.format(_("Kraylor-shipLog", "Looks like the Kraylor have developed some kind of planet busting weapon. They just destroyed %s with it. Keep them away from %s!"),moon_name,planet_secondus:getCallSign()),"Magenta")
					primaryOrders = string.format(_("KraylorOrders-comms","Save planet %s from Kraylor destruction like they destroyed %s by keeping the Kraylor away from %s."),planet_secondus:getCallSign(),moon_name,planet_secondus:getCallSign())
				end
			elseif planet_secondus ~= nil and planet_secondus:isValid() then
				if enemy_close_to_planet_count > 3 then
					local exp_x, exp_y = planet_secondus:getPosition()
					planet_name = planet_secondus:getCallSign()
					planet_secondus:destroy()
					ExplosionEffect():setPosition(exp_x, exp_y):setSize(planet_secondus_radius*2)
					exploding_planet_x = exp_x
					exploding_planet_y = exp_y
					exploding_planet_time = getScenarioTime() + 4
					plot7 = explodingPlanetDebris
					plot6 = worldEnd
					world_end_time = getScenarioTime() + 5
					player:addToShipLog(string.format(_("Kraylor-shipLog","Oops, there goes %s"),planet_name),"Magenta")
				elseif enemy_close_to_planet_count > 1 and kraylor_planetary_danger > 10 then
					globalMessage(string.format(_("msgMainscreen", "You've saved planet %s"),planet_secondus:getCallSign()))
					victory("Human Navy")
				end
			end
		end
	end
	if getScenarioTime() > kraylor_planet_buster_time then
		kraylor_planet_buster_timer_interval = 60
		kraylor_planet_buster_time = getScenarioTime() + kraylor_planet_buster_timer_interval
		if kraylor_planetary_danger == nil then
			kraylor_planetary_danger = 4
		end
		if planetary_attack_fleet == nil then
			local base_range = 10000
			local player_scanner_range = player:getLongRangeRadarRange()
			local rvx,rvy = vectorFromAngle(random(0,360),random(base_range,player_scanner_range + base_range))
			local spawn_x, spawn_y = 0
			repeat
				rvx,rvy = vectorFromAngle(random(0,360),random(base_range,player_scanner_range + base_range))
				spawn_x = target_x + rvx
				spawn_y = target_y + rvy
				base_range = base_range + 1000
			until(distance(player,spawn_x,spawn_y) > player_scanner_range)
			planetary_attack_fleet = spawnEnemies(spawn_x,spawn_y,kraylor_planetary_danger,"Kraylor")
			for i,enemy in ipairs(planetary_attack_fleet) do
				if enemy:isValid() then
					enemy:orderFlyTowards(target_x,target_y)
				end
			end
		else
			local enemy_count = 0
			for i,enemy in ipairs(planetary_attack_fleet) do
				if enemy ~= nil and enemy:isValid() then
					enemy_count = enemy_count + 1
				end
			end
			if enemy_count < 1 then
				kraylor_planetary_danger = kraylor_planetary_danger + 1
				planetary_attack_fleet = nil
			end
		end
	end
end
function worldEnd(delta)
	if getScenarioTime() > world_end_time then
		globalMessage(string.format(_("msgMainscreen", "Planet %s was destroyed"),planet_name))
		victory("Kraylor")
	end
end
function transitionStationDestroyed(self,instigator)
	globalMessage(string.format(_("msgMainscreen", "station %s destroyed"),self:getCallSign()))
	victory("Exuari")
end
---------------------------------
--	Plot 2 Contract targeting  --
---------------------------------
function contractTarget(delta)
	if exuari_vengance_fleet_time == nil then
		if exuari_vengance_danger == nil then
			exuari_vengance_danger = 2
		else
			exuari_vengance_danger = exuari_vengance_danger + .5
		end
		local vengance_target = false
		for i,station in ipairs(independent_station) do
			if station ~= nil and station:isValid() then
				vengance_target = true
				break
			end
		end
		if vengance_target then
			local ev_fleet = spawnEnemies(evx,evy,exuari_vengance_danger,"Exuari")
			for i, enemy in ipairs(ev_fleet) do
				enemy:orderFlyTowards(first_station_x,first_station_y)
			end
			local evs_x, evs_y = vectorFromAngle((ev_angle+90)%360,8000)
			ev_fleet = spawnEnemies(evx+evs_x,evy+evs_y,exuari_vengance_danger,"Exuari")
			local evd_x, evd_y = vectorFromAngle(ev_angle,40000)
			for i, enemy in ipairs(ev_fleet) do
				enemy:orderFlyTowards(evx+evs_x+evd_x,evy+evs_y+evd_y)
			end
			evs_x, evs_y = vectorFromAngle((ev_angle+270)%360,8000)
			ev_fleet = spawnEnemies(evx+evs_x,evy+evs_y,exuari_vengance_danger,"Exuari")
			for i, enemy in ipairs(ev_fleet) do
				enemy:orderFlyTowards(evx+evs_x+evd_x,evy+evs_y+evd_y)
			end
			evs_x, evs_y = vectorFromAngle((ev_angle+270)%360,16000)
			local is_x, is_y = independent_station[2]:getPosition()
			ev_fleet = spawnEnemies(evx+evs_x,evy+evs_y,exuari_vengance_danger,"Exuari")
			for i, enemy in ipairs(ev_fleet) do
				enemy:orderFlyTowards(is_x, is_y)
			end
			evs_x, evs_y = vectorFromAngle((ev_angle+90)%360,16000)
			is_x, is_y = independent_station[3]:getPosition()
			ev_fleet = spawnEnemies(evx+evs_x,evy+evs_y,exuari_vengance_danger,"Exuari")
			for i, enemy in ipairs(ev_fleet) do
				enemy:orderFlyTowards(is_x, is_y)
			end
		end
		exuari_vengance_fleet_time = getScenarioTime() + 650 - (difficulty*100)
	else
		if getScenarioTime() > exuari_vengance_fleet_time then
			exuari_vengance_fleet_time = nil
		end
	end
	for i, target_station in pairs(contract_station) do
		if target_station ~= nil and target_station:isValid() then
			if target_station.delay_timer == nil then
				target_station.delay_timer = getScenarioTime() + random(5,30)
			end
			if getScenarioTime() > target_station.delay_timer then
				if target_station.harass_fleet == nil then
					if random(1,100) < 80 then
						local hfx, hfy = target_station:getPosition()
						target_station.harass_fleet = spawnEnemies(hfx, hfy, 2, "Exuari", 3000, 5000)
						for j,ship in ipairs(target_station.harass_fleet) do
							if ship:isValid() then
								ship:orderFlyTowards(hfx,hfy)
							end
						end
					else
						target_station.delay_timer = getScenarioTime() + random(5,30)
					end
				else
					local fleet_count = 0
					for j, enemy in pairs(target_station.harass_fleet) do
						if enemy ~= nil and enemy:isValid() then
							fleet_count = fleet_count + 1
						end
					end
					if fleet_count < 1 then
						target_station.delay_timer = getScenarioTime() + random(60,200)
						target_station.harass_fleet = nil
					end
				end
			end
		else
			if supply_depot_station == nil then
				globalMessage(_("msgMainscreen", "A contract destination station was destroyed"))
				victory("Exuari")
			end
		end
	end
	if not transition_contract_message then
		if transition_contract_delay ~= nil then
			if getScenarioTime() > transition_contract_delay then
				if first_station ~= nil and first_station:isValid() then
					player:addToShipLog(string.format(_("contract-shipLog", "A rare long range contract has been posted at station %s"),first_station:getCallSign()),"Magenta")
				else
					globalMessage(_("msgMainscreen", "Mourning over the loss of the station has halted all business\nThe mission is over"))
					victory("Exuari")
				end
				transition_contract_message = true
	--			plot2 = nil
			else
				if player.captain_log < 2 then
					if getScenarioTime() < transition_contract_delay_msg then
						if independent_station[1]:isValid() and independent_station[2]:isValid() and independent_station[3]:isValid() then
							player:addToShipLog(string.format(_("contract-shipLog", "[Captain's Log] Why can't the Exuari just leave us alone? I don't understand what it is about them that makes them want to prey on everyone.\nThe upgrades for %s are very nice. They certainly came in handy. With the confidence of stations %s, %s and %s, I feel we will succeed as the space entrepeneurs we want to be."),player:getCallSign(),first_station:getCallSign(),independent_station[2]:getCallSign(),independent_station[3]:getCallSign()),"Green")
						end
						player.captain_log = 2
					end
				end
				local contract_remains = false
				for i, station in pairs(independent_station) do
					if station:isValid() then
						if station.comms_data.contract ~= nil then
							for contract, details in pairs(station.comms_data.contract) do
								if details.type == "start" then
									if not details.accepted then
										contract_remains = true
										break
									end
								end
								if details.type == "fulfill" then
									if not details.fulfilled then
										contract_remains = true
										break							
									end
								end
							end
						end
					end
					if contract_remains then
						break
					end
				end
				if not contract_remains then
					if first_station ~= nil and first_station:isValid() then
						player:addToShipLog(string.format(_("contract-shipLog", "A rare long range contract has been posted at station %s"),first_station:getCallSign()),"Magenta")
					else
						globalMessage(_("msgMainscreen", "Mourning over the loss of the station has halted all business\nThe mission is over"))
						victory("Exuari")
					end
					transition_contract_message = true
--					plot2 = nil
				end
			end
		end
	end
end
function jennyAsteroid(delta)
	if not player.jenny_aboard then
		if player.asteroid_identified then
			if player:isDocked(first_station) then
				player.jenny_aboard = true
				player:addToShipLog(string.format(_("Jenny-shipLog", "Jenny McGuire is now aboard. She's a bit paranoid and has sealed the door to her quarters. You'll have to contact %s to talk to her"),first_station:getCallSign()),"Magenta")
			end
		end
	end
end
-------------------------
--	Plot 4 Highwaymen  --
-------------------------
function highwaymen(delta)
	if distance(player,drop_bait) < 30000 then
		if getScenarioTime() > highway_time then
			highway_time = getScenarioTime() + 150
			plot4 = highwaymenAlerted
		end
	end
end
function highwaymenAlerted(delta)
	if distance(player,drop_bait) < 10000 then
		highway_time = getScenarioTime() + 5
		plot4 = highwaymenPounce
	end
	if getScenarioTime() > highway_time then
		highway_time = getScenarioTime() + 10
		plot4 = highwaymenPounce
	end
	if distance(player,drop_bait) < 30000 then
		if player.prev_jump_charge == nil then
			player.prev_jump_charge = player:getJumpDriveCharge()
		end
		if player:getJumpDriveCharge() < 30000 then
			local current_charge = player:getJumpDriveCharge()
			local charge_difference = current_charge - player.prev_jump_charge
			if charge_difference > 0 then
				charge_difference = charge_difference/2*difficulty
				player:setJumpDriveCharge(current_charge - charge_difference)
			end
			player:setJumpDriveCharge((player.prev_jump_charge + player:getJumpDriveCharge())/2)
			player.prev_jump_charge = player:getJumpDriveCharge()
		end
		if player:getJumpDriveCharge() >= 30000 then
			highway_time = getScenarioTime() + 10
			plot4 = highwaymenPounce
		end
	end
end
function highwaymenPounce(delta)
	if player.highwaymen_warning == nil then
		player.highwaymen_warning = "sent"
		if drop_bait:isScannedBy(player) then
			if player:hasPlayerAtPosition("Science") then
				player.highwaymen_warning_message = "highwaymen_warning_message"
				player:addCustomMessage("Science",player.highwaymen_warning_message,_("energy-msgScience", "Energy surge from supply drop"))
			end
			if player:hasPlayerAtPosition("Operations") then
				player.highwaymen_warning_message_ops = "highwaymen_warning_message_ops"
				player:addCustomMessage("Operations",player.highwaymen_warning_message_ops,_("energy-msgOperations", "Energy surge from supply drop"))
			end
		else
			local etx, ety = drop_bait:getPosition()
			highwaymen_warning_zone = Zone():setPoints(etx-1000,ety-1000,etx+1000,ety-1000,etx+1000,ety+1000,etx-1000,ety+1000):setColor(255,255,0)
			zone_time = getScenarioTime() + 30
			plot5 = removeZone
			if player:hasPlayerAtPosition("Science") then
				player.highwaymen_warning_message = "highwaymen_warning_message"
				player:addCustomMessage("Science",player.highwaymen_warning_message,_("energy-msgScience", "Energy surge from area highlighted in yellow"))
			end
			if player:hasPlayerAtPosition("Operations") then
				player.highwaymen_warning_message_ops = "highwaymen_warning_message_ops"
				player:addCustomMessage("Operations",player.highwaymen_warning_message_ops,_("energy-msgOperations", "Energy surge from area highlighted in yellow"))
			end
		end
	end
	if getScenarioTime() > highway_time then
		local etx, ety = drop_bait:getPosition()
		highwaymen_fleet = spawnEnemies(etx, ety,4,"Exuari")
		local px, py = player:getPosition()
		local angle_increment = 360/#highwaymen_fleet
		local angle = random(0,360)
		for i,enemy in ipairs(highwaymen_fleet) do
			local eax, eay = vectorFromAngle(angle,random(7200,7900) - (difficulty * 500))
			enemy:setPosition(px+eax,py+eay):orderAttack(player)
			angle = (angle + angle_increment) % 360
		end
		local jam_range = distance(drop_bait,player) + 5000
		local jx, jy = drop_bait:getPosition()
		drop_bait:destroy()
		highwaymen_jammer = WarpJammer():setRange(jam_range):setPosition(jx,jy):setFaction("Exuari")
		highway_time = getScenarioTime() + 8
		plot4 = highwaymenAftermath
	end
end
function highwaymenAftermath(delta)
	local enemy_count = 0
	for i,enemy in pairs(highwaymen_fleet) do
		if enemy ~= nil and enemy:isValid() then
			enemy_count = enemy_count + 1
			break
		end
	end
	if enemy_count < 1 then
		if getScenarioTime() > highway_time then
			highwaymen_jammer:setRange(5000):setDescriptions(_("scienceDescription-jammer", "Jump and Warp Jammer"),_("scienceDescription-jammer", "Jump and Warp Jammer with external dynamic range control and sensor decoy mechanism")):setScanningParameters(1,2)
			plot4 = highwaymenReset
			highway_time = getScenarioTime() + 200
			local etx, ety = highwaymen_jammer:getPosition()
			highwaymen_fleet = spawnEnemies(etx, ety,4,"Exuari")
			for i,enemy in ipairs(highwaymen_fleet) do
				enemy:orderAttack(player)
			end
			local temp_fleet = spawnEnemies(etx, ety,4,"Exuari")
			for i,enemy in ipairs(temp_fleet) do
				table.insert(highwaymen_fleet,enemy)
				enemy:orderRoaming()
			end
		end
	end
end
function highwaymenReset(delta)
	if getScenarioTime() > highway_time then
		if highwaymen_jammer ~= nil then
			local enemy_count = 0
			for i,enemy in pairs(highwaymen_fleet) do
				if enemy ~= nil and enemy:isValid() then
					enemy_count = enemy_count + 1
					break
				end
			end
			if enemy_count > 0 then
				highwaymen_jammer:setRange(30000)
			end
		end
		plot4 = nil
	end
end
function removeZone(delta)
	if getScenarioTime() > zone_time then
		highwaymen_warning_zone:destroy()
		plot5 = nil
	end
end
function explodingPlanetDebris()
	if exploding_planet_x == nil then
		exploding_planet_x = 0
		exploding_planet_y = 0
		exploding_planet_time = getScenarioTime() + 5
	end
	if getScenarioTime() > exploding_planet_time then
		if #ejecta > 0 then
			for i,ej in ipairs(ejecta) do
				local obj = ej.obj
				if ej.action == "dissipate" then
					if obj.typeName == "Artifact" then
						obj:explode()
					else
						obj:destroy()
					end
				else
					if obj.typeName == "Artifact" then
						obj:onCollision(function(self,collider)
							string.format("")
							collider:takeDamage(100)
							self:explode()
						end)
					end
				end
			end
		end
		ejecta = nil
		exploding_planet_x = nil
		exploding_planet_y = nil
		plot7 = nil
	else
		if ejecta == nil then
			ejecta = {}
			local ejecta_count = 200
			local lo_speed = 100
			local hi_speed = 1000
			local max_neb = 7
			local neb_count = 0
			for i=1,ejecta_count do
				local angle = random((i-1)*360/ejecta_count,i*360/ejecta_count)
				local speed = random(lo_speed,hi_speed)
				local dist = random(10000,300000)
				local actions = {"dissipate","stop"}
				local iterations = math.floor(dist/speed)
				local ejecta_kinds = {Asteroid,VisualAsteroid,VisualAsteroid,VisualAsteroid,Nebula,Artifact}
				local ejecta_kind = ejecta_kinds[math.random(1,#ejecta_kinds)]
				if ejecta_kind == "Nebula" then
					neb_count = neb_count + 1
					if neb_count >= max_neb then
						ejecta_kind = VisualAsteroid
					end
				end
				local obj = ejecta_kind()
				obj:setPosition(exploding_planet_x,exploding_planet_y)
				if obj.typeName == "Asteroid" or obj.typeName == "VisualAsteroid" then
					obj:setSize(random(5,50) + random(5,50) + random(5,200))
				end
				if obj.typeName == "Artifact" then
					obj:setRadarTraceColor(math.random(1,255),math.random(1,255),math.random(1,255))
					if unscanned_descriptions == nil or #unscanned_descriptions == 0 then
						unscanned_descriptions = {
							_("scienceDescription-artifact","Unknown tech device"),
							_("scienceDescription-artifact","Partly melted machinery"),
							_("scienceDescription-artifact","Device of unknown purpose"),
							_("scienceDescription-artifact","Fragment of advanced technology"),
						}
					end
					if scanned_descriptions == nil or #scanned_descriptions == 0 then
						scanned_descriptions = {
							_("scienceDescription-artifact","Origin: Kraylor. Purpose: unknown."),
							_("scienceDescription-artifact","Source: Kraylor. Possibly a remnant of a planet-busting device."),
							_("scienceDescription-artifact","Purpose: unknown. Volatile material detected."),
							_("scienceDescription-artifact","Origin: Kraylor."),
						}
					end
					local unscanned_description = tableRemoveRandom(unscanned_descriptions)
					local scanned_description = tableRemoveRandom(scanned_descriptions)
					obj:setDescriptions(unscanned_description,scanned_description)
					obj:setScanningParameters(math.random(1,3),math.random(1,3))
				end
				table.insert(ejecta,{obj=obj,dir=angle,speed=speed,dist=dist,action=actions[math.random(1,#actions)],iterations=iterations,del=false})
			end
		else
			if #ejecta > 0 then
				for i,ej in ipairs(ejecta) do
					local obj = ej.obj
					if obj ~= nil and obj:isValid() then
						local ox,oy = obj:getPosition()
						local dx,dy = vectorFromAngle(ej.dir,ej.speed)
						obj:setPosition(ox + dx, oy + dy)
						ej.iterations = ej.iterations - 1
						if ej.iterations <= 0 then
							if ej.action == "dissipate" then
								if obj.typeName == "Artifact" then
									obj:explode()
								else
									obj:destroy()
								end
								ej.obj = nil
								ej.del = true
							elseif ej.action == "stop" then
								if obj.typeName == "Artifact" then
									obj:onCollision(function(self,collider)
										string.format("")
										collider:takeDamage(100)
										self:explode()
									end)
								end
								ej.obj = nil
								ej.del = true
							end
						else
							ej.speed = math.max(ej.speed - random(0,5),1)
						end
					else
						ej.obj = nil
						ej.del = true
					end
				end
				for i=#ejecta,1,-1 do
					if ejecta[i].del then
						ejecta[i] = ejecta[#ejecta]
						ejecta[#ejecta] = nil
					end
				end
			end
		end
	end
end
function update(delta)
	if delta == 0 then	--game paused
		setPlayer()
		return
	end
	if planet_secondus_moon ~= nil and planet_secondus_moon:isValid() then
		if supply_depot_station ~= nil and supply_depot_station:isValid() then
			if supply_depot_station.sabotaged == nil then
				local mx, my = planet_secondus_moon:getPosition()
				supply_depot_station:setPosition(mx, my + secondus_moon_radius + 1500)
				local sdx, sdy = supply_depot_station:getPosition()
				supply_worm_hole:setTargetPosition(sdx,sdy)
			else
				if player.supply_sabotage_message == nil then
					player.supply_sabotage_message = "sent"
					player:addToShipLog(string.format(_("Kraylor-shipLog", "Kraylor have sabotaged station %s. It can no longer maintain orbit around %s. Fortunately, it looks to be in no danger from %s or %s, but the Kraylor pose a more significant threat"),supply_depot_station:getCallSign(),planet_secondus_moon:getCallSign(),planet_secondus:getCallSign(),planet_secondus_moon:getCallSign()),"Magenta")
				end
			end
		end
	end
	if plot1 ~= nil then	--various primary plot lines (harassment, transition contract, long discance cargo)
		if player ~= nil and player:isValid() then
			plot1(delta)
		else
			globalMessage(_("ridExuari-msgMainscreen","Dash your hopes and dreams again?"))
			victory("Exuari")
		end
	end
	local cargo_hold_empty = true
	if player.goods ~= nil then
		for good, quantity in pairs(player.goods) do
			if quantity > 0 then
				cargo_hold_empty = false
				break
			end
		end
	end
	if not cargo_hold_empty then
		if player.inventory_button_rel == nil then
			player.inventory_button_rel = "inventory_button_rel"
			player:addCustomButton("Relay",player.inventory_button_rel,_("inventory-buttonRelay", "Inventory"),function()
				string.format("")
				playerShipCargoInventory(player)
			end)
		end
		if player.inventory_button_ops == nil then
			player.inventory_button_ops = "inventory_button_ops"
			player:addCustomButton("Operations",player.inventory_button_ops,_("inventory-buttonOperations", "Inventory"),function()
				string.format("")
				playerShipCargoInventory(player)
			end)
		end
	end
	if plot2 ~= nil then	--contract target
		plot2(delta)
	end
	if plot3 ~= nil then	--Jenny asteroid
		plot3(delta)
	end
	if plot4 ~= nil then	--highwaymen
		plot4(delta)
	end
	if plot5 ~= nil then	--remove zone
		plot5(delta)
	end
	if plot6 ~= nil then	--planet buster
		plot6(delta)
	end
	if plot7 ~= nil then	--exploding planet
		plot7(delta)
	end
	if plot8 ~= nil then	--pirates
		plot8(delta)
	end
	if plotH ~= nil then	--health
		plotH(delta)
	end
	if plotT ~= nil then	--transports
		plotT(delta)
	end
end