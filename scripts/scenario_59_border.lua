-- Name: Borderline Fever
-- Description: War temperature rises along the border between Human Navy space and Kraylor space. The treaty holds for now, but the diplomats and intelligence operatives fear the Kraylors are about to break the treaty. We must maintain the treaty despite provocation until war is formally declared.
---
--- Version 5
-- Type: Replayable Mission
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
-- Murphy[Quixotic]: No need for paranoia, the universe *is* out to get you
-- Setting[Ending]: Sets the conditions for ending the war: absolute strength % when friendly and Kraylor give up, relative strength % difference when friendly and Kraylor give up
-- Ending[Easy]: Cutoffs 10% easier than normal
-- Ending[Normal|Default]: Kraylor surrender if < 70% of their original strength, friendly surrender if < 50% of their original strength, either will surrender if < 20% relative strength difference
-- Ending[Hard]: Cutoffs 10% harder than normal
-- Ending[Quixotic]: Cutoffs 20% harder than normal
-- Setting[Timed]: Sets whether or not the scenario has a time limit. Default is no time limit
-- Timed[None|Default]: No time limit
-- Timed[30]: Scenario ends in 30 minutes
-- Timed[40]: Scenario ends in 40 minutes
-- Timed[45]: Scenario ends in 45 minutes
-- Timed[50]: Scenario ends in 50 minutes
-- Timed[55]: Scenario ends in 55 minutes
-- Timed[60]: Scenario ends in 60 minutes
-- Timed[70]: Scenario ends in 70 minutes
-- Timed[80]: Scenario ends in 80 minutes
-- Timed[90]: Scenario ends in 90 minutes
-- Setting[Reputation]: Starting reputation per player ship. The more initial reputation, the easier the scenario. Default: Hero = 400 reputation
-- Reputation[Unknown]: Nobody knows you. Zero reputation
-- Reputation[Nice]: 200 reputation - you've helped a few people
-- Reputation[Hero|Default]: 400 reputation - you've helped important people or lots of people
-- Reputation[Major Hero"]: 700 reputation - you're well known by nearly everyone as a force for good
-- Reputation[Super Hero"]: 1000 reputation - everyone knows you and relies on you for help
-- Setting[Unique Ship]: Choose player ship outside of standard player ship list
-- Unique Ship[None|Default]: None: just use standard player ship list on spawn screen
-- Unique Ship[Spinstar]: Based on Atlantis, has spinal beam: narrow, long range, rapid firing, 5 second duration, 30 second recharge, fewer tubes, weaker shields and hull, warp, faster maneuver
-- Unique Ship[Narsil]: Based on Atlantis, slower impulse, faster maneuver, warp, weaker hull and shields, add forward HVLI tube and side beam turrets
-- Unique Ship[Blazon]: Based on Striker, faster impulse and maneuver, stronger shields, narrower beams, add beam, add missiles
-- Unique Ship[Headhunter]: Based on Piranha, shorter jump, stronger hull and shields, add beam, one fewer mining tube, fewer mines and nukes, more EMPs
-- Unique Ship[Simian]: Based on missile cruiser, 20k jump, add beam, weaker hull, fewer tubes and missiles
-- Unique Ship[Spyder]: Based on Atlantis, slower impulse, extra tube, angled tubes
-- Unique Ship[Sting]: Based on Hathcock, faster impulse, warp, add mining tube, no nukes or EMPs

-- to do items:
-- Station warning of enemies in area (helpful warnings - shuffle stations)

require("utils.lua")
require("generate_call_sign_scenario_utility.lua")
require("place_station_scenario_utility.lua")
require("cpu_ship_diversification_scenario_utility.lua")

--------------------
-- Initialization --
--------------------
function init()
	popupGMDebug = "once"
	scenario_version = "5.6.4"
	ee_version = "2024.12.08"
	print(string.format("    ----    Scenario: Borderline Fever    ----    Version %s    ----    Tested with EE version %s    ----",scenario_version,ee_version))
	if _VERSION ~= nil then
		print("Lua version:",_VERSION)
	end
	--print("Example of calling a function via http API, assuming you start EE with parameter httpserver=8080 (or it's in options.ini):")
	--print('curl --data "getScriptStorage().scenario.createPlayerShipSting()" http://localhost:8080/exec.lua')
	setGlobals()
	setVariations()
	setConstants()
	constructEnvironment()
	----------------------------------------------------------------------------------------------
	--	Plot functions that swap in and out of the update loop either in a line or in a circle  --
	----------------------------------------------------------------------------------------------
	--	Main plot
	plot1 = treatyHolds				--start main plot with the treaty in place
	treaty = true
	initialAssetsEvaluated = false
	
	--	Ship health plot
	healthCheckTimer = 5
	healthCheckTimerInterval = 5
	
	plotPB = playerBorderCheck		--monitor players positions relative to neutral border zone
	plotMF = muckAndFlies
	
	--	Enemy border check plot
	enemyEverDetected = false
	enemyBorderCheckInterval = 3
	enemyBorderCheckTimer = enemyBorderCheckInterval
	
	plotVT = kraylorTransportPlot	--start of kraylor, independent and friendly transport plots
	kraylorTransportList = {}
	independentTransportList = {}
	friendlyTransportList = {}
	
	--	End war plot
	endWarTimerInterval = 3
	endWarTimer = endWarTimerInterval
	
	plotPA = personalAmbush
	
	--	Enemy reversion
	enemy_reverts = {}
	revert_timer_interval = 7
	revert_timer = revert_timer_interval
	plotRevert = revertWait
	
	mainGMButtons()
end
function setGlobals()
	game_state = "paused"
	-- Make the createPlayerShip... functions accessible from other scripts (including exec.lua)
	local scenario = {}
	scenario.createPlayerShipBlazon = createPlayerShipBlazon
	scenario.createPlayerShipHeadhunter = createPlayerShipHeadhunter
	scenario.createPlayerShipNarsil = createPlayerShipNarsil
	scenario.createPlayerShipSimian = createPlayerShipSimian
	scenario.createPlayerShipSpinstar = createPlayerShipSpinstar
	scenario.createPlayerShipSpyder = createPlayerShipSpyder
	scenario.createPlayerShipSting = createPlayerShipSting
	scenario.gatherStats = gatherStats
	local storage = getScriptStorage()
	storage.scenario = scenario
	-- starryUtil v2
	starryUtil={
		math={
			-- linear interpolation
			-- mostly intended as an aid to make code more readable
			lerp=function(a,b,t)
				assert(type(a)=="number")
				assert(type(b)=="number")
				assert(type(t)=="number")
				return a + t * (b - a);
			end
		},
	}
	stored_fixed_names = {	--change table name to predefined_player_ships to default to fixed names
		{name = "Phoenix",		control_code = "BURN265"},
		{name = "Callisto",		control_code = "MOON558"},
		{name = "Charybdis",	control_code = "JACKPOT777"},
		{name = "Sentinel",		control_code = "FERENGI432"},
		{name = "Omnivore",		control_code = "EQUILATERAL180"},
		{name = "Tarquin",		control_code = "TIME909"},
	}
	banner = {}
	banner["number_of_players"] = 0
	banner["player_strength"] = 0
	banner["player"] = {}
	banner["Human Navy"] = {}
	banner["Kraylor"] = {}
	defaultGameTimeLimitInMinutes = 30	--final: 30 (lowered for test)
	rawKraylorShipStrength = 0
	rawHumanShipStrength = 0
	primaryOrders = ""
	secondaryOrders = ""
	optionalOrders = ""
	--	Ship type selection
	pool_selectivity = "full"
	template_pool_size = 5
	--	Tracking ships and stations
	enemyVesselDestroyedNameList = {}
	enemyVesselDestroyedType = {}
	enemyVesselDestroyedValue = {}
	friendlyVesselDestroyedNameList = {}
	friendlyVesselDestroyedType = {}
	friendlyVesselDestroyedValue = {}
	friendlyStationDestroyedNameList = {}
	friendlyStationDestroyedValue = {}
	enemyStationDestroyedNameList = {}
	enemyStationDestroyedValue = {}
	neutralStationDestroyedNameList = {}
	neutralStationDestroyedValue = {}
	show_player_info = true
	show_only_player_name = true
	info_choice = 0
	info_choice_max = 5
	wreck_debris_label_count = 1
end
function setVariations()
	--default or initial end of game victory/defeat values
	enemyDestructionVictoryCondition = 70		--final: 70
	friendlyDestructionDefeatCondition = 50		--final: 50
	destructionDifferenceEndCondition = 20		--final: 20
	if getScenarioSetting == nil or getScenarioSetting("Enemies") == "" then
		enemy_power = 1
		difficulty = 1
		adverseEffect = .995
		coolant_loss = .99995
		coolant_gain = .001
		ersAdj = 0
		starting_reputation = 400
	else
		local enemy_config = {
			["Easy"] =		{number = .5},
			["Normal"] =	{number = 1},
			["Hard"] =		{number = 2},
			["Quixotic"] =	{number = 5},
		}
		enemy_power =	enemy_config[getScenarioSetting("Enemies")].number
		local murphy_config = {
			["Easy"] =		{number = .5,	adverse = .999,	lose_coolant = .99999,	gain_coolant = .01,		ers_adj = 10},
			["Normal"] =	{number = 1,	adverse = .995,	lose_coolant = .99995,	gain_coolant = .001,	ers_adj = 0},
			["Hard"] =		{number = 2,	adverse = .99,	lose_coolant = .9999,	gain_coolant = .0001,	ers_adj = -5},
			["Quixotic"] =	{number = 5,	adverse = .9,	lose_coolant = .999,	gain_coolant = .0001,	ers_adj = -10},
		}
		difficulty =	murphy_config[getScenarioSetting("Murphy")].number
		--	difficulty impacts several things including:
		--		mining drain on power
		--		benefit or detriment chance of items dropped by destroyed enemies
		--		degree of effect of scanning items dropped by destroyed enemies as to their benefit or detriment
		--		whether warnings about enemies include ship type
		--		the chance of retrieving minerals when mining asteroids
		--		the amount of heat generated when mining
		--		the amount of damage given when attacking armored warp jammers
		--		the delay before a sleeper awakes and attacks
		--		the type of missile a sleeper is armed with
		--		delay between muck and fly attacks
		--		the number of flies in a muck and fly attack
		--		strength of muck armor in muck and fly attack
		--		size of jammer fleet
		--		speed of station defense deployment
		--		speed of station defense orbiting defense platform or warp jammer
		--		strength of station defense drone fleet or fighter fleet
		--		chance of repair crew recovering when zero repair crew remain
		--		degree of damage when space time continuum disrupted
		--		chance of space time continuum disruption
		--		chance of getting information about upgrade characters
		--		chance of coolant and repair crew availability
		--		when upgrades are free
		--		reputation cost of ordnance
		--		scanning difficulty for intel artifacts
		adverseEffect =	murphy_config[getScenarioSetting("Murphy")].adverse
		coolant_loss =	murphy_config[getScenarioSetting("Murphy")].lose_coolant
		coolant_gain =	murphy_config[getScenarioSetting("Murphy")].gain_coolant
		ersAdj =		murphy_config[getScenarioSetting("Murphy")].ers_adj
		mining_drain = .00025 * difficulty
		local completion_conditions = {
			["Easy"] =		{enemy_destruction = enemyDestructionVictoryCondition*1.1,	friendly_destruction = friendlyDestructionDefeatCondition*.9,	destruction_difference = destructionDifferenceEndCondition*1.1},
			["Normal"] =	{enemy_destruction = enemyDestructionVictoryCondition,		friendly_destruction = friendlyDestructionDefeatCondition,		destruction_difference = destructionDifferenceEndCondition},
			["Hard"] =		{enemy_destruction = enemyDestructionVictoryCondition*.9,	friendly_destruction = friendlyDestructionDefeatCondition*1.1,	destruction_difference = destructionDifferenceEndCondition*.9},
			["Quixotic"] =	{enemy_destruction = enemyDestructionVictoryCondition*.8,	friendly_destruction = friendlyDestructionDefeatCondition*1.2,	destruction_difference = destructionDifferenceEndCondition*.8},
		}
		enemyDestructionVictoryCondition = completion_conditions[getScenarioSetting("Ending")].enemy_destruction
		friendlyDestructionDefeatCondition = completion_conditions[getScenarioSetting("Ending")].friendly_destruction
		destructionDifferenceEndCondition = completion_conditions[getScenarioSetting("Ending")].destruction_difference
		local timed_config = {
			["None"] =	{limit = 0,	limited = false,	plot = nil},
			["30"] =	{limit = 30,limited = true,		plot = timedGame},
			["40"] =	{limit = 40,limited = true,		plot = timedGame},
			["45"] =	{limit = 45,limited = true,		plot = timedGame},
			["50"] =	{limit = 50,limited = true,		plot = timedGame},
			["55"] =	{limit = 55,limited = true,		plot = timedGame},
			["60"] =	{limit = 60,limited = true,		plot = timedGame},
			["70"] =	{limit = 70,limited = true,		plot = timedGame},
			["80"] =	{limit = 80,limited = true,		plot = timedGame},
			["90"] =	{limit = 90,limited = true,		plot = timedGame},
		}
		playWithTimeLimit =				timed_config[getScenarioSetting("Timed")].limited
		defaultGameTimeLimitInMinutes =	timed_config[getScenarioSetting("Timed")].limit
		gameTimeLimit =					defaultGameTimeLimitInMinutes*60
		plot2 =							timed_config[getScenarioSetting("Timed")].plot
		local reputation_config = {
			["Unknown"] =	0,
			["Nice"] =		200,
			["Hero"] =		400,
			["Major Hero"] =700,
			["Super Hero"] =1000,
		}
		starting_reputation = reputation_config[getScenarioSetting("Reputation")]
		local player_ship_config = {
			["Spinstar"] =		createPlayerShipSpinstar,
			["Narsil"] =		createPlayerShipNarsil,
			["Blazon"] =		createPlayerShipBlazon,
			["Simian"] =		createPlayerShipSimian,
			["Spyder"] =		createPlayerShipSpyder,
			["Sting"] =			createPlayerShipSting,
			["Headhunter"] =	createPlayerShipHeadhunter,
		}
		if getScenarioSetting("Unique Ship") ~= "None" then
			player_ship_config[getScenarioSetting("Unique Ship")]()
		end
	end
end
function setConstants()
	--	various testing diagnostics
	initDiagnostic = false
	diagnostic = false
	mf_diagnostic = false
	stationCommsDiagnostic = false
	shipCommsDiagnostic = false
	optionalMissionDiagnostic = false
	paDiagnostic = false
	plot3diagnostic = false
	plot1Diagnostic = false
	updateDiagnostic = false
	station_warning_diagnostic = false
	healthDiagnostic = false
	plot2diagnostic = false
	endStatDiagnostic = false
	change_enemy_order_diagnostic = false
	distance_diagnostic = false
	repair_system_diagnostic = false

	--These random range values are in seconds, not minutes
	--Place in variables to facilitate testing and tinkering
	--random range 1 final: 120, 300 (lowered for test) initial attack, pincer attack, vengence
	lrr1 = 120		--lower random range
	urr1 = 300		--upper random range
	--random range 2 final: 120, 500 (lowered for test) initial attack, pincer attack, vengence
	lrr2 = 120		--lower random range
	urr2 = 500		--upper random range
	--random range 3 final: 120, 180 (lowered for test) initial attack, pincer attack, vengence
	lrr3 = 120		--lower random range
	urr3 = 180		--upper random range
	--random range 4 final: 30, 300 (lowered for test)	treaty for timed game
	lrr4 = 30
	urr4 = 300
	--random range 4 final: 240, 540 (lowered for test) treaty for game with no time limit
	lrr5 = 240
	urr5 = 540
	--station placement setup values
	station_sizes = {
		["Huge Station"] =		{strength = 10,	short_lo = 150,	short_hi = 500},
		["Large Station"] =		{strength = 5,	short_lo = 90,	short_hi = 300},
		["Medium Station"] =	{strength = 3,	short_lo = 60,	short_hi = 200},
		["Small Station"] =		{strength = 1,	short_lo = 35,	short_hi = 100},
	}
	--enemy strength evaluation; ratio of stations to ships. Must add up to 1
	enemyStationComponentWeight = .65
	enemyShipComponentWeight = .35
	--friendly strength evaluation; ratio of friendly stations, neutral stations and friendly ships. Must add up to 1
	friendlyStationComponentWeight = .5
	neutralStationComponentWeight = .1
	friendlyShipComponentWeight = .4
	repeatExitBoundary = 100
	printDetailedStats = true

	missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	system_list = {"reactor","beamweapons","missilesystem","maneuver","impulse","warp","jumpdrive","frontshield","rearshield"}
	ship_template = {	--ordered by relative strength
		["Gnat"] =				{strength = 2,		create = gnat},
		["Lite Drone"] =		{strength = 3,		create = droneLite},
		["Jacket Drone"] =		{strength = 4,		create = droneJacket},
		["Ktlitan Drone"] =		{strength = 4,		create = stockTemplate},
		["Heavy Drone"] =		{strength = 5,		create = droneHeavy},
		["MT52 Hornet"] =		{strength = 5,		create = stockTemplate},
		["MU52 Hornet"] =		{strength = 5,		create = stockTemplate},
		["MV52 Hornet"] =		{strength = 6,		create = hornetMV52},
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
		["Phobos R2"] =			{strength = 13,		create = phobosR2},
		["Missile Cruiser"] =	{strength = 14,		create = stockTemplate},
		["Waddle 5"] =			{strength = 15,		create = waddle5},
		["Jade 5"] =			{strength = 15,		create = jade5},
		["Phobos T3"] =			{strength = 15,		create = stockTemplate},
		["Piranha F8"] =		{strength = 15,		create = stockTemplate},
		["Piranha F12"] =		{strength = 15,		create = stockTemplate},
		["Farco 3"] =			{strength = 16,		create = farco3},
		["Farco 5"] =			{strength = 16,		create = farco5},
		["Piranha F12.M"] =		{strength = 16,		create = stockTemplate},
		["Phobos M3"] =			{strength = 16,		create = stockTemplate},
		["Karnack"] =			{strength = 17,		create = stockTemplate},
		["Gunship"] =			{strength = 17,		create = stockTemplate},
		["Karnack MK2"] =			{strength = 18,		create = stockTemplate},
		["Phobos T4"] =			{strength = 18,		create = phobosT4},
		["Farco 8"] =			{strength = 19,		create = farco8},
		["Nirvana R5"] =		{strength = 19,		create = stockTemplate},
		["Nirvana R5A"] =		{strength = 20,		create = stockTemplate},
		["Adv. Gunship"] =		{strength = 20,		create = stockTemplate},
		["Farco 11"] =			{strength = 21,		create = farco11},
		["Ktlitan Worker"] =	{strength = 21,		create = stockTemplate},
		["Storm"] =				{strength = 22,		create = stockTemplate},
		["Farco 13"] =			{strength = 24,		create = farco13},
		["Ranus U"] =			{strength = 25,		create = stockTemplate},
		["Stalker Q7"] =		{strength = 25,		create = stockTemplate},
		["Stalker R7"] =		{strength = 25,		create = stockTemplate},
		["Whirlwind"] =			{strength = 26,		create = whirlwind},
		["Adv. Striker"] =		{strength = 27,		create = stockTemplate},
		["Tempest"] =			{strength = 30,		create = tempest},
		["Strikeship"] =		{strength = 30,		create = stockTemplate},
		["Maniapak"] =			{strength = 34,		create = maniapak},
		["Cucaracha"] =			{strength = 36,		create = cucaracha},
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
	playerShipStats = {	["MP52 Hornet"] 		= { strength = 7, 	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 4000, tractor = false,	mining = false,	cm_boost = 600, cm_strafe = 0,	},
						["Piranha"]				= { strength = 16,	cargo = 8,	distance = 200,	long_range_radar = 25000, short_range_radar = 6000, tractor = false,	mining = false,	cm_boost = 200, cm_strafe = 150,	},
						["Flavia P.Falcon"]		= { strength = 13,	cargo = 15,	distance = 200,	long_range_radar = 40000, short_range_radar = 5000, tractor = true,		mining = true,	cm_boost = 250, cm_strafe = 150,	},
						["Phobos M3P"]			= { strength = 19,	cargo = 10,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = true,		mining = false,	cm_boost = 400, cm_strafe = 250,	},
						["Atlantis"]			= { strength = 52,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = true,		mining = true,	cm_boost = 400, cm_strafe = 250,	},
						["Player Cruiser"]		= { strength = 40,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = false,	mining = false,	cm_boost = 400, cm_strafe = 250,	},
						["Player Missile Cr."]	= { strength = 45,	cargo = 8,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, tractor = false,	mining = false,	cm_boost = 450, cm_strafe = 150,	},
						["Player Fighter"]		= { strength = 7,	cargo = 3,	distance = 100,	long_range_radar = 15000, short_range_radar = 4500, tractor = false,	mining = false,	cm_boost = 600, cm_strafe = 0,	},
						["Benedict"]			= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = true,		mining = true,	cm_boost = 400, cm_strafe = 250,	},
						["Kiriya"]				= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 35000, short_range_radar = 5000, tractor = true,		mining = true,	cm_boost = 400, cm_strafe = 250,	},
						["Striker"]				= { strength = 8,	cargo = 4,	distance = 200,	long_range_radar = 35000, short_range_radar = 5000, tractor = false,	mining = false,	cm_boost = 250, cm_strafe = 150,	},
						["ZX-Lindworm"]			= { strength = 8,	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 5500, tractor = false,	mining = false,	cm_boost = 250, cm_strafe = 150,	},
						["Repulse"]				= { strength = 14,	cargo = 12,	distance = 200,	long_range_radar = 38000, short_range_radar = 5000, tractor = true,		mining = false,	cm_boost = 250, cm_strafe = 150,	},
						["Ender"]				= { strength = 100,	cargo = 20,	distance = 2000,long_range_radar = 45000, short_range_radar = 7000, tractor = true,		mining = false,	cm_boost = 800, cm_strafe = 500,	},
						["Nautilus"]			= { strength = 12,	cargo = 7,	distance = 200,	long_range_radar = 22000, short_range_radar = 4000, tractor = false,	mining = false,	cm_boost = 250, cm_strafe = 150,	},
						["Hathcock"]			= { strength = 30,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, tractor = false,	mining = true,	cm_boost = 200, cm_strafe = 150,	},
						["Maverick"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000, tractor = false,	mining = true,	cm_boost = 400, cm_strafe = 250,	},
						["Crucible"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, tractor = false,	mining = false,	cm_boost = 400, cm_strafe = 250,	},
						["Proto-Atlantis"]		= { strength = 40,	cargo = 4,	distance = 400,	long_range_radar = 30000, short_range_radar = 4500, tractor = false,	mining = true,	cm_boost = 400, cm_strafe = 250,	},
						["Stricken"]			= { strength = 40,	cargo = 4,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000, tractor = false,	mining = false,	cm_boost = 250, cm_strafe = 150,	},
						["Surkov"]				= { strength = 35,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, tractor = false,	mining = false,	cm_boost = 200, cm_strafe = 150,	},
						["Redhook"]				= { strength = 11,	cargo = 8,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, tractor = false,	mining = false,	cm_boost = 200, cm_strafe = 150,	},
						["Pacu"]				= { strength = 18,	cargo = 7,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, tractor = false,	mining = false,	cm_boost = 200, cm_strafe = 150,	},
						["Phobos T2"]			= { strength = 19,	cargo = 9,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = true,		mining = false,	cm_boost = 400, cm_strafe = 250,	},
						["Wombat"]				= { strength = 13,	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 6000, tractor = false,	mining = false,	cm_boost = 250, cm_strafe = 150,	},
						["Holmes"]				= { strength = 35,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 4000, tractor = true,		mining = false,	cm_boost = 400, cm_strafe = 250,	},
						["Focus"]				= { strength = 35,	cargo = 4,	distance = 200,	long_range_radar = 32000, short_range_radar = 5000, tractor = false,	mining = true,	cm_boost = 400, cm_strafe = 250,	},
						["Flavia 2C"]			= { strength = 25,	cargo = 12,	distance = 200,	long_range_radar = 30000, short_range_radar = 5000, tractor = false,	mining = true,	cm_boost = 250, cm_strafe = 150,	},
						["Destroyer IV"]		= { strength = 25,	cargo = 5,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = false,	mining = false,	cm_boost = 400, cm_strafe = 250,	},
						["Destroyer III"]		= { strength = 25,	cargo = 7,	distance = 200,	long_range_radar = 30000, short_range_radar = 5000, tractor = false,	mining = false,	cm_boost = 450, cm_strafe = 150,	},
						["MX-Lindworm"]			= { strength = 10,	cargo = 3,	distance = 100,	long_range_radar = 30000, short_range_radar = 5000, tractor = false,	mining = false,	cm_boost = 250, cm_strafe = 150,	},
						["Striker LX"]			= { strength = 16,	cargo = 4,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000, tractor = false,	mining = false,	cm_boost = 250, cm_strafe = 150,	},
						["Maverick XP"]			= { strength = 23,	cargo = 5,	distance = 200,	long_range_radar = 25000, short_range_radar = 7000, tractor = true,		mining = false,	cm_boost = 400, cm_strafe = 250,	},
						["Era"]					= { strength = 14,	cargo = 14,	distance = 200,	long_range_radar = 50000, short_range_radar = 5000, tractor = true,		mining = true,	cm_boost = 250, cm_strafe = 150,	},
						["Squid"]				= { strength = 14,	cargo = 8,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = false,	mining = false,	cm_boost = 200, cm_strafe = 150,	},
						["Atlantis II"]			= { strength = 60,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = true,		mining = true,	cm_boost = 400, cm_strafe = 250,	},
					}	
	--Player ship name lists to supplant standard randomized call sign generation
	playerShipNamesFor = {}
	playerShipNamesFor["MP52 Hornet"] = {"Dragonfly","Scarab","Mantis","Yellow Jacket","Jimminy","Flik","Thorny","Buzz"}
	playerShipNamesFor["Piranha"] = {"Razor","Biter","Ripper","Voracious","Carnivorous","Characid","Vulture","Predator"}
	playerShipNamesFor["Flavia P.Falcon"] = {"Ladyhawke","Hunter","Seeker","Gyrefalcon","Kestrel","Magpie","Bandit","Buccaneer"}
	playerShipNamesFor["Phobos M3P"] = {"Blinder","Shadow","Distortion","Diemos","Ganymede","Castillo","Thebe","Retrograde"}
	playerShipNamesFor["Atlantis"] = {"Excaliber","Thrasher","Punisher","Vorpal","Protang","Drummond","Parchim","Coronado"}
	playerShipNamesFor["Player Cruiser"] = {"Excelsior","Velociraptor","Thunder","Kona","Encounter","Perth","Aspern","Panther"}
	playerShipNamesFor["Player Missile Cr."] = {"Projectus","Hurlmeister","Flinger","Ovod","Amatola","Nakhimov","Antigone"}
	playerShipNamesFor["Player Fighter"] = {"Buzzer","Flitter","Zippiticus","Hopper","Molt","Stinger","Stripe"}
	playerShipNamesFor["Benedict"] = {"Elizabeth","Ford","Vikramaditya","Liaoning","Avenger","Naruebet","Washington","Lincoln","Garibaldi","Eisenhower"}
	playerShipNamesFor["Kiriya"] = {"Cavour","Reagan","Gaulle","Paulo","Truman","Stennis","Kuznetsov","Roosevelt","Vinson","Old Salt"}
	playerShipNamesFor["Striker"] = {"Sparrow","Sizzle","Squawk","Crow","Phoenix","Snowbird","Hawk"}
	playerShipNamesFor["ZX-Lindworm"] = {"Seagull","Catapult","Blowhard","Flapper","Nixie","Pixie","Tinkerbell"}
	playerShipNamesFor["Repulse"] = {"Fiddler","Brinks","Loomis","Mowag","Patria","Pandur","Terrex","Komatsu","Eitan"}
	playerShipNamesFor["Ender"] = {"Mongo","Godzilla","Leviathan","Kraken","Jupiter","Saturn"}
	playerShipNamesFor["Nautilus"] = {"October", "Abdiel", "Manxman", "Newcon", "Nusret", "Pluton", "Amiral", "Amur", "Heinkel", "Dornier"}
	playerShipNamesFor["Hathcock"] = {"Hayha", "Waldron", "Plunkett", "Mawhinney", "Furlong", "Zaytsev", "Pavlichenko", "Pegahmagabow", "Fett", "Hawkeye", "Hanzo"}
	playerShipNamesFor["Proto-Atlantis"] = {"Narsil", "Blade", "Decapitator", "Trisect", "Sabre"}
	playerShipNamesFor["Maverick"] = {"Angel", "Thunderbird", "Roaster", "Magnifier", "Hedge"}
	playerShipNamesFor["Crucible"] = {"Sling", "Stark", "Torrid", "Kicker", "Flummox"}
	playerShipNamesFor["Surkov"] = {"Sting", "Sneak", "Bingo", "Thrill", "Vivisect"}
	playerShipNamesFor["Stricken"] = {"Blazon", "Streaker", "Pinto", "Spear", "Javelin"}
	playerShipNamesFor["Atlantis II"] = {"Spyder", "Shelob", "Tarantula", "Aragog", "Charlotte"}
	playerShipNamesFor["Redhook"] = {"Headhunter", "Thud", "Troll", "Scalper", "Shark"}
	playerShipNamesFor["Destroyer III"] = {"Trebuchet", "Pitcher", "Mutant", "Gronk", "Methuselah"}
	playerShipNamesFor["Leftovers"] = {"Foregone","Righteous","Masher"}
	commonGoods = {"food","medicine","nickel","platinum","gold","dilithium","tritanium","luxury","cobalt","impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	componentGoods = {"impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	mineralGoods = {"nickel","platinum","gold","dilithium","tritanium","cobalt"}
	vapor_goods = {"gold pressed latinum","unobtanium","eludium","impossibrium"}
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
	hitZonePermutations = {
		{"warp","beamweapons","reactor"},
		{"jumpdrive","beamweapons","reactor"},
		{"impulse","beamweapons","reactor"},
		{"warp","missilesystem","reactor"},
		{"jumpdrive","missilesystem","reactor"},
		{"impulse","missilesystem","reactor"},
		{"warp","beamweapons","maneuver"},
		{"jumpdrive","beamweapons","maneuver"},
		{"impulse","beamweapons","maneuver"},
		{"warp","missilesystem","maneuver"},
		{"jumpdrive","missilesystem","maneuver"},
		{"impulse","missilesystem","maneuver"},
		{"warp","beamweapons","frontshield"},
		{"jumpdrive","beamweapons","frontshield"},
		{"impulse","beamweapons","frontshield"},
		{"warp","missilesystem","frontshield"},
		{"jumpdrive","missilesystem","frontshield"},
		{"impulse","missilesystem","frontshield"},
		{"warp","beamweapons","rearshield"},
		{"jumpdrive","beamweapons","rearshield"},
		{"impulse","beamweapons","rearshield"},
		{"warp","missilesystem","rearshield"},
		{"jumpdrive","missilesystem","rearshield"},
		{"impulse","missilesystem","rearshield"},
		{"warp","reactor","maneuver"},
		{"jumpdrive","reactor","maneuver"},
		{"impulse","reactor","maneuver"},
		{"warp","reactor","frontshield"},
		{"jumpdrive","reactor","frontshield"},
		{"impulse","reactor","frontshield"},
		{"warp","reactor","rearshield"},
		{"jumpdrive","reactor","rearshield"},
		{"impulse","reactor","rearshield"},
		{"warp","maneuver","frontshield"},
		{"jumpdrive","maneuver","frontshield"},
		{"impulse","maneuver","frontshield"},
		{"warp","maneuver","rearshield"},
		{"jumpdrive","maneuver","rearshield"},
		{"impulse","maneuver","rearshield"},
		{"beamweapons","beamweapons","maneuver"},
		{"missilesystem","beamweapons","maneuver"},
		{"beamweapons","beamweapons","frontshield"},
		{"missilesystem","beamweapons","frontshield"},
		{"beamweapons","beamweapons","rearshield"},
		{"missilesystem","beamweapons","rearshield"},
		{"beamweapons","maneuver","frontshield"},
		{"missilesystem","maneuver","frontshield"},
		{"beamweapons","maneuver","rearshield"},
		{"missilesystem","maneuver","rearshield"},
		{"reactor","maneuver","frontshield"},
		{"reactor","maneuver","rearshield"}
	}
	--minutes and danger
	enemyReinforcementSchedule = {
		{30, 1},
		{20, 1},
		{15, 2},
		{12, 2},
		{15, 3},
		{15, 3},
		{20, 4}
	}
	mining_beam_string = {
		"beam_orange.png",
		"beam_yellow.png",
		"fire_sphere_texture.png"
	}
	wreck_mod_debris = {}
	base_wreck_mod_positive = 80
	wreck_mod_interval = 20
	wreck_mod_type = {
		{func=wreckModHealthBeam,		desc="Primary ship system component",	scan_desc="Beam system component"},					--1
		{func=wreckModHealthMissile,	desc="Primary ship system component",	scan_desc="Missile system component"},				--2
		{func=wreckModHealthImpulse,	desc="Primary ship system component",	scan_desc="Impulse engine component"},				--3
		{func=wreckModHealthWarp,		desc="Primary ship system component",	scan_desc="Warp engine component"},					--4
		{func=wreckModHealthJump,		desc="Primary ship system component",	scan_desc="Jump drive component"},					--5
		{func=wreckModHealthShield,		desc="Primary ship system component",	scan_desc="Shield component"},						--6
		{func=wreckModHealthSpin,		desc="Primary ship system component",	scan_desc="Maneuver system component"},				--7
		{func=wreckModHealthReactor,	desc="Primary ship system component",	scan_desc="Reactor system component"},				--8
		{func=wreckModBoolScan,			desc="Secondary ship system component",	scan_desc="Scanner system component"},				--9
		{func=wreckModBoolCombat,		desc="Secondary ship system component",	scan_desc="Combat maneuver system component"},		--10
		{func=wreckModBoolProbe,		desc="Secondary ship system component",	scan_desc="Probe launch system component"},			--11
		{func=wreckModBoolHack,			desc="Secondary ship system component",	scan_desc="Hacking system component"},				--12
		{func=wreckModChangeScan,		desc="Secondary ship system component",	scan_desc="Scan range system component"},			--13
		{func=wreckModChangeCoolant,	desc="Secondary ship system component",	scan_desc="System coolant container"},				--14
		{func=wreckModChangeRepair,		desc="Secondary ship system component",	scan_desc="Robotic repair crew"},					--15
		{func=wreckModChangeHull,		desc="Secondary ship system component",	scan_desc="Modular hull plating"},					--16
		{func=wreckModChangeShield,		desc="Secondary ship system component",	scan_desc="Shield charging component"},				--17 can overcharge
		{func=wreckModChangePower,		desc="Secondary ship system component",	scan_desc="Power source"},							--18
		{func=wreckModCombatBoost,		desc="Secondary ship system component",	scan_desc="Maneuver boost thruster"},				--19 timed
		{func=wreckModCombatStrafe,		desc="Secondary ship system component",	scan_desc="Maneuver strafe thruster"},				--20 timed
		{func=wreckModProbeStock,		desc="Secondary ship system component",	scan_desc="Probe container"},						--21 
		{func=wreckModBeamDamage,		desc="Primary ship system component",	scan_desc="Beam system optics"},					--22 timed
		{func=wreckModBeamCycle,		desc="Primary ship system component",	scan_desc="Beam system power capacitors"},			--23 timed
		{func=wreckModMissileStock,		desc="Primary ship system component",	scan_desc="Missile container"},						--24
		{func=wreckModImpulseSpeed,		desc="Primary ship system component",	scan_desc="Impulse engine regulator"},				--25 timed
		{func=wreckModWarpSpeed,		desc="Primary ship system component",	scan_desc="Alternate warp drive envelope shape"},	--26 timed
		{func=wreckModJumpRange,		desc="Primary ship system component",	scan_desc="Jump drive range ringer"},				--27 timed
		{func=wreckModShieldMax,		desc="Primary ship system component",	scan_desc="Shield capacitor"},						--28 timed
		{func=wreckModSpinSpeed,		desc="Primary ship system component",	scan_desc="Maneuvering thrusters"},					--29 timed
		{func=wreckModBatteryMax,		desc="Primary ship system component",	scan_desc="Main power battery"},					--30 timed
		{func=wreckCargo,				desc="Cargo",							scan_desc="Cargo"},									--31
		{func=wreckModCoolantPump,		desc="Primary ship system component",	scan_desc="Coolant pump component"},				--32
--		{func=wreckModPowerRegulator,	desc="Primary ship system component",	scan_desc="Power Regulator component"},				--33
	}
end
-- Terrain and environment creation functions
function constructEnvironment()
	local rpt_counter = 0
	local spawnInInnerZone = false
	repeat
		rpt_counter = rpt_counter + 1
		setGossipSnippets()
		populateStationPool()
		setBorderZones()	--establish neutral border zone and other zones
		buildStationsPlus()	--put stations and other things in and out of the neutral border zone
		if initDiagnostic then print("weird zone adjustment count: " .. wzac) end
		--be sure initial spawn point (0,0) is inside the inner zone defining human territory
		spawnInInnerZone = false
		local spawnMarker = VisualAsteroid():setPosition(0,0)
		spawnInInnerZone = innerZone:isInside(spawnMarker)
		spawnMarker:destroy()
		--be sure each side has at least a minimal number of stations
		if wzac > 0 or #kraylorStationList < 5 or #humanStationList < 5 or not spawnInInnerZone then
			print("resetting stations, counter:",rpt_counter)
			resetStationsPlus()
		end
	until(wzac < 1 and #kraylorStationList >= 5 and #humanStationList >= 5 and spawnInInnerZone)
	if not diagnostic then	--get rid of temporary set up zones
		for i=1,#innerZoneList do
			innerZoneList[i]:destroy()
		end
		for i=1,#outerZoneList do
			outerZoneList[i]:destroy()
		end
	end
	setFleets()						--give each side some ships
	setEnemyStationDefenses()		--give enemy stations defensive mechanisms
	setOptionalMissions()			--scatter upgrade missions around the stations
	setCharacterNames()				--add decoy character names to stations
end
function setGossipSnippets()
	gossipSnippets = {}
	table.insert(gossipSnippets,"I hear the head of operations has a thing for his administrative assistant")	--1
	table.insert(gossipSnippets,"My mining friends tell me Krak or Kruk is about to strike it rich")			--2
	table.insert(gossipSnippets,"Did you know you can usually hire replacement repair crew cheaper at friendly stations?")		--3
	table.insert(gossipSnippets,"Under their uniforms, the Kraylors have an extra appendage. I wonder what they use it for")	--4
	table.insert(gossipSnippets,"The Kraylors may be human navy enemies, but they make some mighty fine BBQ Mynock")			--5
	table.insert(gossipSnippets,"The Kraylors and the Ktlitans may be nearing a cease fire from what I hear. That'd be bad news for us")		--6
	table.insert(gossipSnippets,"Docking bay 7 has interesting mind altering substances for sale, but they're monitored between 1900 and 2300")	--7
	table.insert(gossipSnippets,"Watch the sky tonight in quadrant J around 2243. It should be spectacular")					--8
	table.insert(gossipSnippets,"I think the shuttle pilot has a tame miniature Ktlitan caged in his quarters. Sometimes I hear it at night")	--9
	table.insert(gossipSnippets,"Did you hear the screaming chase in the corridors on level 4 last night? Three Kraylors were captured and put in the brig")	--10
	table.insert(gossipSnippets,"Rumor has it that the two Lichten brothers are on the verge of a new discovery. And it's not another wine flavor either")		--11
end
function setCharacterNames()
	for i=1,#humanStationList do
		curStation = humanStationList[i]
		if curStation.comms_data.character == nil then
			if #characterNames > 0 then
				nameChoice = math.random(1,#characterNames)
				curStation.comms_data.character = characterNames[nameChoice]
				table.remove(characterNames,nameChoice)
			end
		end
	end
end
function setBorderZones()
	local borderStartAngle = random(0,360)	--gross orientation of default spawn point to neutral border zone
	local borderStartX, borderStartY = vectorFromAngle(borderStartAngle,random(3500,4900))
	local halfLength = random(8000,15000)
	local zoneLimit = 150000
	borderZone = {}
	innerZoneList = {}
	outerZoneList = {}
	local bzi = 1		--border zone index
	--Note: "left" and "right" refer to someone standing on the 2D board at the spawn point (0,0) looking at the zones being added;
	--		"inner" means closer to the spawn point, "outer" means further away from the spawn point
	local borderZoneLeftInnerX = {}
	local borderZoneLeftInnerY = {}
	local borderZoneRightInnerX = {}
	local borderZoneRightInnerY = {}
	local borderZoneLeftOuterX = {}
	local borderZoneLeftOuterY = {}
	local borderZoneRightOuterX = {}
	local borderZoneRightOuterY = {}
	local bzsx, bzsy = vectorFromAngle(borderStartAngle+270,halfLength)	--border zone start x and y coordinates
	table.insert(borderZoneLeftInnerX, borderStartX+bzsx)
	table.insert(borderZoneLeftInnerY, borderStartY+bzsy)
	bzsx, bzsy = vectorFromAngle(borderStartAngle+90,halfLength)	--border sone start x and y coordinates
	table.insert(borderZoneRightInnerX, borderStartX+bzsx)
	table.insert(borderZoneRightInnerY, borderStartY+bzsy)
	local bendAngle = random(1,30)	--inner and outer edges are parallel, connecting edges are bent
	local negativeBendCount = 0
	local positiveBendCount = 0
	if random(1,100) < 50 then
		negativeBendCount = negativeBendCount + bendAngle
		bendAngle = -1*bendAngle
	else
		positiveBendCount = positiveBendCount + bendAngle
	end
	bendAngle = borderStartAngle + bendAngle
	if bendAngle < 0 then
		bendAngle = bendAngle + 360
	end
	local borderZoneWidth = random(10000,15000)
	bzsx, bzsy = vectorFromAngle(bendAngle,borderZoneWidth)		--border zone start x and y coordinates
	table.insert(borderZoneLeftOuterX,borderZoneLeftInnerX[bzi]+bzsx)
	table.insert(borderZoneLeftOuterY,borderZoneLeftInnerY[bzi]+bzsy)
	table.insert(borderZoneRightOuterX,borderZoneRightInnerX[bzi]+bzsx)
	table.insert(borderZoneRightOuterY,borderZoneRightInnerY[bzi]+bzsy)
	local cbz = Zone():setPoints(borderZoneLeftInnerX[bzi],borderZoneLeftInnerY[bzi],		--current border zone
						   borderZoneLeftOuterX[bzi],borderZoneLeftOuterY[bzi],
						   borderZoneRightOuterX[bzi],borderZoneRightOuterY[bzi],
						   borderZoneRightInnerX[bzi],borderZoneRightInnerY[bzi])
		cbz:setColor(0,0,255)
	cbz.detect = 0
	table.insert(borderZone,cbz)
	intelGatherArtifacts = {}
	local igax, igay = vectorFromAngle(borderStartAngle+180,borderZoneWidth*2+random(1,30000))
	local iga = Artifact():setPosition(borderStartX+igax,borderStartY+igay):setScanningParameters(difficulty*2,difficulty*2):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setModel("SensorBuoyMKIII"):setCallSign("Sensor Buoy"):setFaction("Human Navy")
	table.insert(intelGatherArtifacts,iga)
	local ilx, ily = vectorFromAngle(borderStartAngle+210,zoneLimit)		--inner left x and y coordinates
	local irx, iry = vectorFromAngle(borderStartAngle+150,zoneLimit)		--inner right x and y coordinates
	local ciz = Zone():setPoints(borderZoneLeftInnerX[bzi],borderZoneLeftInnerY[bzi],		--current inner zone
						   borderZoneRightInnerX[bzi],borderZoneRightInnerY[bzi],
						   borderZoneRightInnerX[bzi]+irx,borderZoneRightInnerY[bzi]+iry,
						   borderZoneLeftInnerX[bzi]+ilx,borderZoneLeftInnerY[bzi]+ily)
	if initDiagnostic then ciz:setColor(50,50,50) end
	table.insert(innerZoneList,ciz)
	local olx, oly = vectorFromAngle(borderStartAngle+330,zoneLimit)		--outer left x and y coordinates
	local orx, ory = vectorFromAngle(borderStartAngle+30,zoneLimit)		--outer right x and y coordinates
	local coz = Zone():setPoints(borderZoneRightOuterX[bzi],borderZoneRightOuterY[bzi],	--current outer zone
						   borderZoneLeftOuterX[bzi],borderZoneLeftOuterY[bzi],
						   borderZoneLeftOuterX[bzi]+olx,borderZoneLeftOuterY[bzi]+oly,
						   borderZoneRightOuterX[bzi]+orx,borderZoneRightOuterY[bzi]+ory)
	if initDiagnostic then coz:setColor(0,128,0) end
	table.insert(outerZoneList,coz)
	--new zone on the left
	bzi = bzi + 1
	table.insert(borderZoneRightInnerX,borderZoneLeftInnerX[bzi-1])
	table.insert(borderZoneRightInnerY,borderZoneLeftInnerY[bzi-1])
	table.insert(borderZoneRightOuterX,borderZoneLeftOuterX[bzi-1])
	table.insert(borderZoneRightOuterY,borderZoneLeftOuterY[bzi-1])
	local bzx, bzy = vectorFromAngle(bendAngle+270,random(20000,30000))		--border zone x and y corrdinates
	table.insert(borderZoneLeftInnerX,borderZoneRightInnerX[bzi]+bzx)
	table.insert(borderZoneLeftInnerY,borderZoneRightInnerY[bzi]+bzy)
	local upBound = 2 + negativeBendCount + positiveBendCount
	local cutOff = math.min(positiveBendCount,negativeBendCount)
	local newBend = random(1,30)
	if negativeBendCount < positiveBendCount then
		if random(1,upBound) <= cutOff then
			negativeBendCount = negativeBendCount + newBend
			newBend = -1*newBend
		else
			positiveBendCount = positiveBendCount + newBend
		end
	else
		if random(1,upBound) <= cutOff then
			positiveBendCount = positiveBendCount + newBend
		else
			negativeBendCount = negativeBendCount + newBend
			newBend = -1*newBend
		end
	end
	newBend = bendAngle + newBend
	if newBend < 0 then
		newBend = newBend + 360
	end
	bzx, bzy = vectorFromAngle(newBend,borderZoneWidth)
	table.insert(borderZoneLeftOuterX,borderZoneLeftInnerX[bzi]+bzx)
	table.insert(borderZoneLeftOuterY,borderZoneLeftInnerY[bzi]+bzy)
	--new zone on the right
	table.insert(borderZoneLeftInnerX,borderZoneRightInnerX[bzi-1])
	table.insert(borderZoneLeftInnerY,borderZoneRightInnerY[bzi-1])
	table.insert(borderZoneLeftOuterX,borderZoneRightOuterX[bzi-1])
	table.insert(borderZoneLeftOuterY,borderZoneRightOuterY[bzi-1])
	bzx, bzy = vectorFromAngle(bendAngle+90,random(20000,30000))
	table.insert(borderZoneRightInnerX,borderZoneRightInnerX[bzi-1]+bzx)
	table.insert(borderZoneRightInnerY,borderZoneRightInnerY[bzi-1]+bzy)
	bzx, bzy = vectorFromAngle(newBend,borderZoneWidth)
	table.insert(borderZoneRightOuterX,borderZoneRightInnerX[bzi+1]+bzx)
	table.insert(borderZoneRightOuterY,borderZoneRightInnerY[bzi+1]+bzy)
	--establish current border zone (cbz)
	cbz = Zone():setPoints(borderZoneLeftInnerX[bzi],borderZoneLeftInnerY[bzi],
						   borderZoneLeftOuterX[bzi],borderZoneLeftOuterY[bzi],
						   borderZoneRightOuterX[bzi],borderZoneRightOuterY[bzi],
						   borderZoneRightInnerX[bzi],borderZoneRightInnerY[bzi])
		cbz:setColor(0,0,255)
	cbz.detect = 0
	table.insert(borderZone,cbz)
	igax, igay = vectorFromAngle(bendAngle+180,borderZoneWidth*2+random(1,30000))
	iga = Artifact():setPosition((borderZoneLeftInnerX[2]+borderZoneRightInnerX[2])/2+igax,(borderZoneLeftInnerY[2]+borderZoneRightInnerY[2])/2+igay):setScanningParameters(difficulty*2,difficulty*2):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setModel("SensorBuoyMKIII"):setCallSign("Sensor Buoy"):setFaction("Human Navy")
	table.insert(intelGatherArtifacts,iga)
	ilx, ily = vectorFromAngle(bendAngle+210,zoneLimit)
	irx, iry = vectorFromAngle(bendAngle+150,zoneLimit)
	ciz = Zone():setPoints(borderZoneLeftInnerX[bzi],borderZoneLeftInnerY[bzi],
						   borderZoneRightInnerX[bzi],borderZoneRightInnerY[bzi],
						   borderZoneRightInnerX[bzi]+irx,borderZoneRightInnerY[bzi]+iry,
						   borderZoneLeftInnerX[bzi]+ilx,borderZoneLeftInnerY[bzi]+ily)
	if initDiagnostic then ciz:setColor(100,100,100) end
	table.insert(innerZoneList,ciz)
	olx, oly = vectorFromAngle(bendAngle+330,zoneLimit)
	orx, ory = vectorFromAngle(bendAngle+30,zoneLimit)
	coz = Zone():setPoints(borderZoneRightOuterX[bzi],borderZoneRightOuterY[bzi],
						   borderZoneLeftOuterX[bzi],borderZoneLeftOuterY[bzi],
						   borderZoneLeftOuterX[bzi]+olx,borderZoneLeftOuterY[bzi]+oly,
						   borderZoneRightOuterX[bzi]+orx,borderZoneRightOuterY[bzi]+ory)
	if initDiagnostic then coz:setColor(0,192,0) end
	table.insert(outerZoneList,coz)
	bzi = bzi + 1
	cbz = Zone():setPoints(borderZoneLeftInnerX[bzi],borderZoneLeftInnerY[bzi],
						   borderZoneLeftOuterX[bzi],borderZoneLeftOuterY[bzi],
						   borderZoneRightOuterX[bzi],borderZoneRightOuterY[bzi],
						   borderZoneRightInnerX[bzi],borderZoneRightInnerY[bzi])
		cbz:setColor(0,0,255)
	cbz.detect = 0
	table.insert(borderZone,cbz)
	igax, igay = vectorFromAngle(bendAngle+180,borderZoneWidth*2+random(1,30000))
	iga = Artifact():setPosition((borderZoneLeftInnerX[3]+borderZoneRightInnerX[3])/2+igax,(borderZoneLeftInnerY[3]+borderZoneRightInnerY[3])/2+igay):setScanningParameters(difficulty*2,difficulty*2):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setModel("SensorBuoyMKIII"):setCallSign("Sensor Buoy"):setFaction("Human Navy")
	table.insert(intelGatherArtifacts,iga)
	ilx, ily = vectorFromAngle(bendAngle+210,zoneLimit)
	irx, iry = vectorFromAngle(bendAngle+150,zoneLimit)
	ciz = Zone():setPoints(borderZoneLeftInnerX[bzi],borderZoneLeftInnerY[bzi],
						   borderZoneRightInnerX[bzi],borderZoneRightInnerY[bzi],
						   borderZoneRightInnerX[bzi]+irx,borderZoneRightInnerY[bzi]+iry,
						   borderZoneLeftInnerX[bzi]+ilx,borderZoneLeftInnerY[bzi]+ily)
	if initDiagnostic then ciz:setColor(150,150,150) end
	table.insert(innerZoneList,ciz)
	olx, oly = vectorFromAngle(bendAngle+330,zoneLimit)
	orx, ory = vectorFromAngle(bendAngle+30,zoneLimit)
	coz = Zone():setPoints(borderZoneRightOuterX[bzi],borderZoneRightOuterY[bzi],
						   borderZoneLeftOuterX[bzi],borderZoneLeftOuterY[bzi],
						   borderZoneLeftOuterX[bzi]+olx,borderZoneLeftOuterY[bzi]+oly,
						   borderZoneRightOuterX[bzi]+orx,borderZoneRightOuterY[bzi]+ory)
	if initDiagnostic then coz:setColor(0,255,0) end
	table.insert(outerZoneList,coz)
	for i=1,20 do
		bendAngle = newBend
		--new bend applies to both left and right zones to be added
		upBound = 2 + negativeBendCount + positiveBendCount
		cutOff = math.max(positiveBendCount,negativeBendCount)
		newBend = random(1,30)
		if negativeBendCount < positiveBendCount then
			if random(1,upBound) <= cutOff then
				negativeBendCount = negativeBendCount + newBend
				newBend = -1*newBend
			else
				positiveBendCount = positiveBendCount + newBend
			end
		else
			if random(1,upBound) <= cutOff then
				positiveBendCount = positiveBendCount + newBend
			else
				negativeBendCount = negativeBendCount + newBend
				newBend = -1*newBend
			end
		end
		newBend = bendAngle + newBend
		if newBend < 0 then
			newBend = newBend + 360
		end
		if initDiagnostic then print(string.format("i: %i, bend angle: %.1f, new bend angle: %.1f, upBound: %.1f, pos: %.1f, neg: %.1f, cutoff: %.1f",i,bendAngle,newBend,upBound,positiveBendCount,negativeBendCount,cutOff)) end
		--new zone on the left
		table.insert(borderZoneRightInnerX,borderZoneLeftInnerX[bzi-1])
		table.insert(borderZoneRightInnerY,borderZoneLeftInnerY[bzi-1])
		table.insert(borderZoneRightOuterX,borderZoneLeftOuterX[bzi-1])
		table.insert(borderZoneRightOuterY,borderZoneLeftOuterY[bzi-1])
		bzx, bzy = vectorFromAngle(bendAngle+270,random(20000,30000))
		table.insert(borderZoneLeftInnerX,borderZoneRightInnerX[bzi+1]+bzx)
		table.insert(borderZoneLeftInnerY,borderZoneRightInnerY[bzi+1]+bzy)
		bzx, bzy = vectorFromAngle(newBend,borderZoneWidth)
		table.insert(borderZoneLeftOuterX,borderZoneLeftInnerX[bzi+1]+bzx)
		table.insert(borderZoneLeftOuterY,borderZoneLeftInnerY[bzi+1]+bzy)
		bzi = bzi + 1
		cbz = Zone():setPoints(borderZoneLeftInnerX[bzi],borderZoneLeftInnerY[bzi],
							   borderZoneLeftOuterX[bzi],borderZoneLeftOuterY[bzi],
							   borderZoneRightOuterX[bzi],borderZoneRightOuterY[bzi],
							   borderZoneRightInnerX[bzi],borderZoneRightInnerY[bzi])
		cbz:setColor(0,0,255)
		cbz.detect = 0
		table.insert(borderZone,cbz)
		if i == 1 then
			igax, igay = vectorFromAngle(bendAngle+180,borderZoneWidth*2+random(1,30000))
			iga = Artifact():setPosition((borderZoneLeftInnerX[4]+borderZoneRightInnerX[4])/2+igax,(borderZoneLeftInnerY[4]+borderZoneRightInnerY[4])/2+igay):setScanningParameters(difficulty*2,difficulty*2):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setModel("SensorBuoyMKIII"):setCallSign("Sensor Buoy"):setFaction("Human Navy")
			table.insert(intelGatherArtifacts,iga)
		end
		if i == 2 then
			igax, igay = vectorFromAngle(bendAngle+180,borderZoneWidth*2+random(1,30000))
			iga = Artifact():setPosition((borderZoneLeftInnerX[5]+borderZoneRightInnerX[5])/2+igax,(borderZoneLeftInnerY[5]+borderZoneRightInnerY[5])/2+igay):setScanningParameters(difficulty*2,difficulty*2):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setModel("SensorBuoyMKIII"):setCallSign("Sensor Buoy"):setFaction("Human Navy")
			table.insert(intelGatherArtifacts,iga)
		end
		if i < 3 then
			ilx, ily = vectorFromAngle(bendAngle+210,100000)
			irx, iry = vectorFromAngle(bendAngle+150,100000)
			ciz = Zone():setPoints(borderZoneLeftInnerX[bzi],borderZoneLeftInnerY[bzi],
								   borderZoneRightInnerX[bzi],borderZoneRightInnerY[bzi],
								   borderZoneRightInnerX[bzi]+irx,borderZoneRightInnerY[bzi]+iry,
								   borderZoneLeftInnerX[bzi]+ilx,borderZoneLeftInnerY[bzi]+ily)
			if initDiagnostic then ciz:setColor(50,50,50) end
			table.insert(innerZoneList,ciz)
			olx, oly = vectorFromAngle(bendAngle+330,100000)
			orx, ory = vectorFromAngle(bendAngle+30,100000)
			coz = Zone():setPoints(borderZoneRightOuterX[bzi],borderZoneRightOuterY[bzi],
								   borderZoneLeftOuterX[bzi],borderZoneLeftOuterY[bzi],
								   borderZoneLeftOuterX[bzi]+olx,borderZoneLeftOuterY[bzi]+oly,
								   borderZoneRightOuterX[bzi]+orx,borderZoneRightOuterY[bzi]+ory)
			if initDiagnostic then coz:setColor(0,128,0) end
			table.insert(outerZoneList,coz)
		end
		--new zone on the right
		table.insert(borderZoneLeftInnerX,borderZoneRightInnerX[bzi-1])
		table.insert(borderZoneLeftInnerY,borderZoneRightInnerY[bzi-1])
		table.insert(borderZoneLeftOuterX,borderZoneRightOuterX[bzi-1])
		table.insert(borderZoneLeftOuterY,borderZoneRightOuterY[bzi-1])
		bzx, bzy = vectorFromAngle(bendAngle+90,random(20000,30000))
		table.insert(borderZoneRightInnerX,borderZoneRightInnerX[bzi-1]+bzx)
		table.insert(borderZoneRightInnerY,borderZoneRightInnerY[bzi-1]+bzy)
		bzx, bzy = vectorFromAngle(newBend,borderZoneWidth)
		table.insert(borderZoneRightOuterX,borderZoneRightInnerX[bzi+1]+bzx)
		table.insert(borderZoneRightOuterY,borderZoneRightInnerY[bzi+1]+bzy)
		bzi = bzi + 1
		cbz = Zone():setPoints(borderZoneLeftInnerX[bzi],borderZoneLeftInnerY[bzi],
							   borderZoneLeftOuterX[bzi],borderZoneLeftOuterY[bzi],
							   borderZoneRightOuterX[bzi],borderZoneRightOuterY[bzi],
							   borderZoneRightInnerX[bzi],borderZoneRightInnerY[bzi])
		cbz:setColor(0,0,255)
		cbz.detect = 0
		table.insert(borderZone,cbz)
		if i < 3 then
			ilx, ily = vectorFromAngle(bendAngle+210,100000)
			irx, iry = vectorFromAngle(bendAngle+150,100000)
			ciz = Zone():setPoints(borderZoneLeftInnerX[bzi],borderZoneLeftInnerY[bzi],
								   borderZoneRightInnerX[bzi],borderZoneRightInnerY[bzi],
								   borderZoneRightInnerX[bzi]+irx,borderZoneRightInnerY[bzi]+iry,
								   borderZoneLeftInnerX[bzi]+ilx,borderZoneLeftInnerY[bzi]+ily)
			if initDiagnostic then ciz:setColor(50,50,50) end
			table.insert(innerZoneList,ciz)
			olx, oly = vectorFromAngle(bendAngle+330,100000)
			orx, ory = vectorFromAngle(bendAngle+30,100000)
			coz = Zone():setPoints(borderZoneRightOuterX[bzi],borderZoneRightOuterY[bzi],
								   borderZoneLeftOuterX[bzi],borderZoneLeftOuterY[bzi],
								   borderZoneLeftOuterX[bzi]+olx,borderZoneLeftOuterY[bzi]+oly,
								   borderZoneRightOuterX[bzi]+orx,borderZoneRightOuterY[bzi]+ory)
			if initDiagnostic then coz:setColor(0,128,0) end
			table.insert(outerZoneList,coz)
		end
	end
	if initDiagnostic then print(string.format("border zones created: %i",bzi)) end
	local bzlx, bzly = vectorFromAngle(borderStartAngle+225,900000)
	local bzrx, bzry = vectorFromAngle(borderStartAngle+135,900000)
	innerZone = Zone():setPoints(borderZoneLeftInnerX[1],borderZoneLeftInnerY[1],
								 borderZoneRightInnerX[1],borderZoneRightInnerY[1],
								 borderZoneRightInnerX[3],borderZoneRightInnerY[3],
								 borderZoneRightInnerX[5],borderZoneRightInnerY[5],
								 borderZoneRightInnerX[7],borderZoneRightInnerY[7],
								 borderZoneRightInnerX[9],borderZoneRightInnerY[9],
								 borderZoneRightInnerX[11],borderZoneRightInnerY[11],
								 borderZoneRightInnerX[13],borderZoneRightInnerY[13],
								 borderZoneRightInnerX[15],borderZoneRightInnerY[15],
								 borderZoneRightInnerX[17],borderZoneRightInnerY[17],
								 borderZoneRightInnerX[19],borderZoneRightInnerY[19],
								 borderZoneRightInnerX[21],borderZoneRightInnerY[21],
								 borderZoneRightInnerX[23],borderZoneRightInnerY[23],
								 borderZoneRightInnerX[25],borderZoneRightInnerY[25],
								 borderZoneRightInnerX[27],borderZoneRightInnerY[27],
								 borderZoneRightInnerX[29],borderZoneRightInnerY[29],
								 borderZoneRightInnerX[31],borderZoneRightInnerY[31],
								 borderZoneRightInnerX[33],borderZoneRightInnerY[33],
								 borderZoneRightInnerX[35],borderZoneRightInnerY[35],
								 borderZoneRightInnerX[37],borderZoneRightInnerY[37],
								 borderZoneRightInnerX[39],borderZoneRightInnerY[39],
								 borderZoneRightInnerX[41],borderZoneRightInnerY[41],
								 borderZoneRightInnerX[43],borderZoneRightInnerY[43],
								 borderZoneRightInnerX[43]+bzrx,borderZoneRightInnerY[43]+bzry,
								 borderZoneLeftInnerX[42]+bzlx,borderZoneLeftInnerY[42]+bzly,
								 borderZoneLeftInnerX[42],borderZoneLeftInnerY[42],
								 borderZoneLeftInnerX[40],borderZoneLeftInnerY[40],
								 borderZoneLeftInnerX[38],borderZoneLeftInnerY[38],
								 borderZoneLeftInnerX[36],borderZoneLeftInnerY[36],
								 borderZoneLeftInnerX[34],borderZoneLeftInnerY[34],
								 borderZoneLeftInnerX[32],borderZoneLeftInnerY[32],
								 borderZoneLeftInnerX[30],borderZoneLeftInnerY[30],
								 borderZoneLeftInnerX[28],borderZoneLeftInnerY[28],
								 borderZoneLeftInnerX[26],borderZoneLeftInnerY[26],
								 borderZoneLeftInnerX[24],borderZoneLeftInnerY[24],
								 borderZoneLeftInnerX[22],borderZoneLeftInnerY[22],
								 borderZoneLeftInnerX[20],borderZoneLeftInnerY[20],
								 borderZoneLeftInnerX[18],borderZoneLeftInnerY[18],
								 borderZoneLeftInnerX[16],borderZoneLeftInnerY[16],
								 borderZoneLeftInnerX[14],borderZoneLeftInnerY[14],
								 borderZoneLeftInnerX[12],borderZoneLeftInnerY[12],
								 borderZoneLeftInnerX[10],borderZoneLeftInnerY[10],
								 borderZoneLeftInnerX[8],borderZoneLeftInnerY[8],
								 borderZoneLeftInnerX[6],borderZoneLeftInnerY[6],
								 borderZoneLeftInnerX[4],borderZoneLeftInnerY[4],
								 borderZoneLeftInnerX[2],borderZoneLeftInnerY[2])
	if initDiagnostic then innerZone:setColor(204,0,204) end
	bzrx, bzry = vectorFromAngle(borderStartAngle+45,900000)
	bzlx, bzly = vectorFromAngle(borderStartAngle+315,900000)
	outerZone = Zone():setPoints(borderZoneRightOuterX[2],borderZoneRightOuterY[2],
								 borderZoneRightOuterX[4],borderZoneRightOuterY[4],
								 borderZoneRightOuterX[6],borderZoneRightOuterY[6],
								 borderZoneRightOuterX[8],borderZoneRightOuterY[8],
								 borderZoneRightOuterX[10],borderZoneRightOuterY[10],
								 borderZoneRightOuterX[12],borderZoneRightOuterY[12],
								 borderZoneRightOuterX[14],borderZoneRightOuterY[14],
								 borderZoneRightOuterX[16],borderZoneRightOuterY[16],
								 borderZoneRightOuterX[18],borderZoneRightOuterY[18],
								 borderZoneRightOuterX[20],borderZoneRightOuterY[20],
								 borderZoneRightOuterX[22],borderZoneRightOuterY[22],
								 borderZoneRightOuterX[24],borderZoneRightOuterY[24],
								 borderZoneRightOuterX[26],borderZoneRightOuterY[26],
								 borderZoneRightOuterX[28],borderZoneRightOuterY[28],
								 borderZoneRightOuterX[30],borderZoneRightOuterY[30],
								 borderZoneRightOuterX[32],borderZoneRightOuterY[32],
								 borderZoneRightOuterX[34],borderZoneRightOuterY[34],
								 borderZoneRightOuterX[36],borderZoneRightOuterY[36],
								 borderZoneRightOuterX[38],borderZoneRightOuterY[38],
								 borderZoneRightOuterX[40],borderZoneRightOuterY[40],
								 borderZoneRightOuterX[42],borderZoneRightOuterY[42],
								 borderZoneLeftOuterX[42],borderZoneLeftOuterY[42],
								 borderZoneLeftOuterX[42]+bzlx,borderZoneLeftOuterY[42]+bzly,
								 borderZoneRightOuterX[43]+bzrx,borderZoneRightOuterY[43]+bzry,
								 borderZoneRightOuterX[43],borderZoneRightOuterY[43],
								 borderZoneRightOuterX[41],borderZoneRightOuterY[41],
								 borderZoneRightOuterX[39],borderZoneRightOuterY[39],
								 borderZoneRightOuterX[37],borderZoneRightOuterY[37],
								 borderZoneRightOuterX[35],borderZoneRightOuterY[35],
								 borderZoneRightOuterX[33],borderZoneRightOuterY[33],
								 borderZoneRightOuterX[31],borderZoneRightOuterY[31],
								 borderZoneRightOuterX[29],borderZoneRightOuterY[29],
								 borderZoneRightOuterX[27],borderZoneRightOuterY[27],
								 borderZoneRightOuterX[25],borderZoneRightOuterY[25],
								 borderZoneRightOuterX[23],borderZoneRightOuterY[23],
								 borderZoneRightOuterX[21],borderZoneRightOuterY[21],
								 borderZoneRightOuterX[19],borderZoneRightOuterY[19],
								 borderZoneRightOuterX[17],borderZoneRightOuterY[17],
								 borderZoneRightOuterX[15],borderZoneRightOuterY[15],
								 borderZoneRightOuterX[13],borderZoneRightOuterY[13],
								 borderZoneRightOuterX[11],borderZoneRightOuterY[11],
								 borderZoneRightOuterX[9],borderZoneRightOuterY[9],
								 borderZoneRightOuterX[7],borderZoneRightOuterY[7],
								 borderZoneRightOuterX[5],borderZoneRightOuterY[5],
								 borderZoneRightOuterX[3],borderZoneRightOuterY[3],
								 borderZoneRightOuterX[1],borderZoneRightOuterY[1])
	if initDiagnostic then outerZone:setColor(255,165,0) end
end
function resetStationsPlus()
	for i=1,#stationList do
		stationList[i]:destroy()
	end
	allObjects = getAllObjects()
	local player_list = getActivePlayerShips()
	for i, obj in ipairs(allObjects) do
		local player_ship = false
		for j,p in ipairs(player_list) do
			if obj == p then
				player_ship = true
				break
			end
		end
		if not player_ship then
			obj:destroy()
		end
	end
end
function buildStationsPlus()
	stationFaction = ""
	stationList = {}
	humanStationList = {}
	humanStationsRemain = true
	kraylorStationList = {}
	kraylorStationsRemain = true
	neutralStationList = {}
	neutralStationsRemain = true
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
	wzac = 0	--weird zone adjustment count
	local planet1 = false
	local blackHole1 = false
	local planet2 = false
	local blackHole2 = false
	humanStationStrength = 0
	kraylorStationStrength = 0
	neutralStationStrength = 0
	repeat
		if gp > 7 and random(1,100) < 20 and not planet1 then
			planet1 = true
			insertPlanet1()
		end
		if planet1 and gp > 19 and random(1,100) < 16 and not blackHole1 then
			blackHole1 = true
			insertBlackHole()
		end
		if planet1 and blackHole1 and gp > 34 and random(1,100) < 23 and not planet2 then
			planet2 = true
			insertPlanet2()
		end
		if planet1 and blackHole1 and planet2 and gp > 55 and random(1,100) < 11 and not blackHole2 then
			blackHole2 = true
			insertBlackHole()
		end
		tSize = math.random(2,5)	--tack on to region size (3-6 since first is outside loop)
		grid[gx][gy] = gp			--set current grid location to grid position list index
		local gRegion = {}			--grow region
		table.insert(gRegion,{gx,gy})
		for i=1,tSize do
			adjList = getAdjacentGridLocations(gx,gy)
			if #adjList < 1 then	--exit loop if there are no more adjacent spaces available
				break
			end
			local rd = math.random(1,#adjList)	--random direction to grow from adjacent list
			grid[adjList[rd][1]][adjList[rd][2]] = gp
			table.insert(gRegion,{adjList[rd][1],adjList[rd][2]})
		end
		--get adjacent list after done growing region
		adjList = getAdjacentGridLocations(gx,gy)
		if #adjList < 1 then
			adjList = getAllAdjacentGridLocations(gx,gy)	
		else
			if random(1,100) < 63 then
				adjList = getAllAdjacentGridLocations(gx,gy)
			end
		end
		local sri = math.random(1,#gRegion)				--select station random region index
		psx = (gRegion[sri][1] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station x coordinate
		psy = (gRegion[sri][2] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station y coordinate
		local ta = VisualAsteroid():setPosition(psx,psy)
		inBorderZone = false
		bzPosCount = 0
		for i=1,#borderZone do
			if borderZone[i]:isInside(ta) then
				inBorderZone = true
				bzPosCount = bzPosCount + 1
			end
		end
		inInnerZone = false
		izPosCount = 0
		for i=1,#innerZoneList do
			if innerZoneList[i]:isInside(ta) then
				inInnerZone = true
				izPosCount = izPosCount + 1
			end
		end
		inOuterZone = false
		ozPosCount = 0
		for i=1,#outerZoneList do
			if outerZoneList[i]:isInside(ta) then
				inOuterZone = true
				ozPosCount = ozPosCount + 1
			end
		end
		pStation = nil
		if inBorderZone then
			placeBorder()
		elseif innerZone:isInside(ta) and outerZone:isInside(ta) then
			wzac = wzac + 1
			if izPosCount > ozPosCount then
				placeInner()
			elseif ozPosCount > izPosCount then
				placeOuter()
			else
				placeBorder()
			end
		elseif innerZone:isInside(ta) then
			placeInner()
		elseif outerZone:isInside(ta) then
			placeOuter()
		elseif inInnerZone and inOuterZone then
			wzac = wzac + 1
			if izPosCount > ozPosCount then
				placeInner()
			elseif ozPosCount > izPosCount then
				placeOuter()
			else
				placeBorder()
			end
		elseif inInnerZone then
			placeInner()
		elseif inOuterZone then
			placeOuter()
		else
			placeBorder()
		end
		if initDiagnostic then
			if pStation ~= nil then
				print(string.format("bz: %i, %s; iz: (%s) %i, %s; oz: (%s) %i, %s, %s faction: %s",bzPosCount,tostring(inBorderZone),tostring(innerZone:isInside(ta)),izPosCount,tostring(inInnerZone),tostring(outerZone:isInside(ta)),ozPosCount,tostring(inOuterZone),pStation:getCallSign(),stationFaction))
			end
		end
		ta:destroy()
		if #gossipSnippets > 0 and stationFaction == "Human Navy" and pStation ~= nil then
			if gp % 2 == 0 then
				ni = math.random(1,#gossipSnippets)
				pStation.comms_data.gossip = gossipSnippets[ni]
				table.remove(gossipSnippets,ni)
			end
		end
		gp = gp + 1						--set next station number
		local rn = math.random(1,#adjList)	--random next station start location
		gx = adjList[rn][1]
		gy = adjList[rn][2]
	until(not neutralStationsRemain or not humanStationsRemain or not kraylorStationsRemain)
	if diagnostic then print(string.format("Human stations: %i, Kraylor stations: %i, Neutral stations: %i",#humanStationList,#kraylorStationList,#neutralStationList)) end
	if not diagnostic then
		local nebula_count = math.random(7,25)
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
	end
end
function insertPlanet1()
	local tSize = 15
	grid[gx][gy] = gp
	local gRegion = {}
	table.insert(gRegion,{gx,gy})
	for i=1,tSize do
		adjList = getAdjacentGridLocations(gx,gy)
		if #adjList < 1 then
			break
		end
		local rd = math.random(1,#adjList)
		grid[adjList[rd][1]][adjList[rd][2]] = gp
		table.insert(gRegion,{adjList[rd][1],adjList[rd][2]})
	end
	adjList = getAdjacentGridLocations(gx,gy)
	if #adjList < 1 then
		adjList = getAllAdjacentGridLocations(gx,gy)	
	end
	local sri = math.random(1,#gRegion)
	local bwx = (gRegion[sri][1] - (gbHigh/2))*gSize
	local bwy = (gRegion[sri][2] - (gbHigh/2))*gSize
	planetBespin = Planet():setPosition(bwx,bwy):setPlanetRadius(3000):setDistanceFromMovementPlane(-2000):setCallSign("Bespin")
	planetBespin:setPlanetSurfaceTexture("planets/gas-1.png"):setAxialRotationTime(300):setDescription(_("scienceDescription-planet", "Mining and Gambling"))
	gp = gp + 1
	local rn = math.random(1,#adjList)
	gx = adjList[rn][1]
	gy = adjList[rn][2]
end
function insertPlanet2()
	local tSize = 15
	grid[gx][gy] = gp
	local gRegion = {}
	table.insert(gRegion,{gx,gy})
	for i=1,tSize do
		adjList = getAdjacentGridLocations(gx,gy)
		if #adjList < 1 then
			break
		end
		local rd = math.random(1,#adjList)
		grid[adjList[rd][1]][adjList[rd][2]] = gp
		table.insert(gRegion,{adjList[rd][1],adjList[rd][2]})
	end
	adjList = getAdjacentGridLocations(gx,gy)
	if #adjList < 1 then
		adjList = getAllAdjacentGridLocations(gx,gy)	
	end
	local sri = math.random(1,#gRegion)
	local msx = (gRegion[sri][1] - (gbHigh/2))*gSize
	local msy = (gRegion[sri][2] - (gbHigh/2))*gSize
	planetHel = Planet():setPosition(msx,msy):setPlanetRadius(3000):setDistanceFromMovementPlane(-2000):setCallSign("Helicon")
	planetHel:setPlanetSurfaceTexture("planets/planet-1.png"):setPlanetCloudTexture("planets/clouds-1.png")
	planetHel:setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.2,0.2,1.0)
	planetHel:setAxialRotationTime(400.0):setDescription(_("scienceDescription-planet", "M class planet"))
	gp = gp + 1
	local rn = math.random(1,#adjList)
	gx = adjList[rn][1]
	gy = adjList[rn][2]
end
function insertBlackHole()
	local tSize = 22
	grid[gx][gy] = gp
	local gRegion = {}
	table.insert(gRegion,{gx,gy})
	for i=1,tSize do
		adjList = getAdjacentGridLocations(gx,gy)
		if #adjList < 1 then
			break
		end
		local rd = math.random(1,#adjList)
		grid[adjList[rd][1]][adjList[rd][2]] = gp
		table.insert(gRegion,{adjList[rd][1],adjList[rd][2]})
	end
	adjList = getAdjacentGridLocations(gx,gy)
	if #adjList < 1 then
		adjList = getAllAdjacentGridLocations(gx,gy)	
	else
		if random(1,100) >= 35 then
			adjList = getAllAdjacentGridLocations(gx,gy)
		end
	end
	local sri = math.random(1,#gRegion)
	local bhx = (gRegion[sri][1] - (gbHigh/2))*gSize
	local bhy = (gRegion[sri][2] - (gbHigh/2))*gSize
	BlackHole():setPosition(bhx,bhy)
	gp = gp + 1
	local rn = math.random(1,#adjList)
	gx = adjList[rn][1]
	gy = adjList[rn][2]
end
function placeInner()
	if stationFaction ~= "Human Navy" then
		fb = gp									--set faction boundary
	end
	stationFaction = "Human Navy"				--set station faction
	local si = 0
	pStation = placeBFStation(psx,psy,nil,stationFaction)
	if pStation == nil then
		humanStationsRemain = false
	end
	if humanStationsRemain then
		humanStationStrength = humanStationStrength + station_sizes[sizeTemplate].strength
		pStation.strength = station_sizes[sizeTemplate].strength
		pStation:setShortRangeRadarRange(math.random(station_sizes[sizeTemplate].short_lo,station_sizes[sizeTemplate].short_hi)*100)
		pStation:onDestroyed(friendlyStationDestroyed)
		table.insert(stationList,pStation)			--save station in general station list
		table.insert(humanStationList,pStation)		--save station in friendly station list
	end
end
function placeOuter()
	if stationFaction ~= "Kraylor" then
		fb = gp									--set faction boundary
	end
	stationFaction = "Kraylor"
	local si = 0
	pStation = placeBFStation(psx,psy,nil,stationFaction)
	if pStation == nil then
		kraylorStationsRemain = false
	end
	if kraylorStationsRemain then
		kraylorStationStrength = kraylorStationStrength + station_sizes[sizeTemplate].strength
		pStation.strength = station_sizes[sizeTemplate].strength
		pStation:setShortRangeRadarRange(math.random(station_sizes[sizeTemplate].short_lo,station_sizes[sizeTemplate].short_hi)*100)
		pStation:onDestroyed(enemyStationDestroyed)
		table.insert(stationList,pStation)			--save station in general station list
		table.insert(kraylorStationList,pStation)	--save station in enemy station list
	end
end
function placeBorder()
	if stationFaction ~= "Independent" then
		fb = gp									--set faction boundary
	end
	stationFaction = "Independent"				--set station faction
	local si = 0
	pStation = placeBFStation(psx,psy,nil,stationFaction)
	if pStation == nil then
		neutralStationsRemain = false
	end
	if neutralStationsRemain then
		neutralStationStrength = neutralStationStrength + station_sizes[sizeTemplate].strength
		pStation.strength = station_sizes[sizeTemplate].strength
		pStation:setShortRangeRadarRange(math.random(station_sizes[sizeTemplate].short_lo,station_sizes[sizeTemplate].short_hi)*100)
		pStation:onDestroyed(neutralStationDestroyed)
		table.insert(stationList,pStation)			--save station in general station list
		table.insert(neutralStationList,pStation)	--save station in neutral station list
	end
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
--	Modifications from wreck artifact functions
function wreckModCommonArtifact(wma)
	wma:setScanningParameters(math.random(1,2),math.random(1,3))
	wma:setRadarTraceScale(.5)
	local color_scheme = math.random(1,3)
	if color_scheme == 1 then
		wma:setRadarTraceColor(0,255,0)
		wma:setModel("ammo_box")
	elseif color_scheme == 2 then
		wma:setRadarTraceColor(255,200,100)	--asteroid color
		wma:setModel("artifact1")
	else
		wma:setModel("artifact2")
	end
end
function wreckModHealthBeam(x,y)
	local full_desc = wreck_mod_type[1].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[1].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		local max_health = p:getSystemHealthMax("beamweapons")
		local health = p:getSystemHealth("beamweapons")
		local scan_bonus = 0
		if self:isScannedByFaction(p:getFaction()) then
			scan_bonus = difficulty * 5
		end
		if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
			if max_health < 1 then
				p:setSystemHealthMax("beamweapons",math.min(1, max_health + .05))
				if p:hasPlayerAtPosition("Engineering") then
					p.artifact_improved_max_beam_health_message = "artifact_improved_max_beam_health_message"
					p:addCustomMessage("Engineering",p.artifact_improved_max_beam_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has improved the beam system maximum health"),full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.artifact_improved_max_beam_health_message_plus = "artifact_improved_max_beam_health_message_plus"
					p:addCustomMessage("Engineering+",p.artifact_improved_max_beam_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has improved the beam system maximum health"),full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.artifact_improved_max_beam_health_message_dmg = "artifact_improved_max_beam_health_message_dmg"
					p:addCustomMessage("DamageControl",p.artifact_improved_max_beam_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has improved the beam system maximum health"),full_desc))
				end
			elseif health < 1 then
				p:setSystemHealth("beamweapons",math.min(1, health + .05))
				if p:hasPlayerAtPosition("Engineering") then
					p.artifact_improved_beam_health_message = "artifact_improved_beam_health_message"
					p:addCustomMessage("Engineering",p.artifact_improved_beam_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has improved the beam system health"),full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.artifact_improved_beam_health_message_plus = "artifact_improved_beam_health_message_plus"
					p:addCustomMessage("Engineering+",p.artifact_improved_beam_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has improved the beam system health"),full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.artifact_improved_beam_health_message_dmg = "artifact_improved_beam_health_message_dmg"
					p:addCustomMessage("DamageControl",p.artifact_improved_beam_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has improved the beam system health"),full_desc))
				end
			else
				if p:hasPlayerAtPosition("Engineering") then
					p.artifact_beam_health_message = "artifact_beam_health_message"
					p:addCustomMessage("Engineering",p.artifact_beam_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has had no impact on an already healthy beam system"),full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.artifact_beam_health_message_plus = "artifact_beam_health_message_plus"
					p:addCustomMessage("Engineering+",p.artifact_beam_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has had no impact on an already healthy beam system"),full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.artifact_beam_health_message_dmg = "artifact_beam_health_message_dmg"
					p:addCustomMessage("DamageControl",p.artifact_beam_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has had no impact on an already healthy beam system"),full_desc))
				end
			end
		else
			if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
				p:setSystemHealth("beamweapons",math.max(-1, health - .05))
				if p:hasPlayerAtPosition("Engineering") then
					p.artifact_damaged_beam_health_message = "artifact_damaged_beam_health_message"
					p:addCustomMessage("Engineering",p.artifact_damaged_beam_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has damaged the beam system health"),full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.artifact_damaged_beam_health_message_plus = "artifact_damaged_beam_health_message_plus"
					p:addCustomMessage("Engineering+",p.artifact_damaged_beam_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has damaged the beam system health"),full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.artifact_damaged_beam_health_message_dmg = "artifact_damaged_beam_health_message_dmg"
					p:addCustomMessage("DamageControl",p.artifact_damaged_beam_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has damaged the beam system health"),full_desc))
				end
			else
				p:setSystemHealthMax("beamweapons",math.max(-1, max_health - .05))
				if p:hasPlayerAtPosition("Engineering") then
					p.artifact_damaged_max_beam_health_message = "artifact_damaged_max_beam_health_message"
					p:addCustomMessage("Engineering",p.artifact_damaged_max_beam_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has damaged the beam system maximum health"),full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.artifact_damaged_max_beam_health_message_plus = "artifact_damaged_max_beam_health_message_plus"
					p:addCustomMessage("Engineering+",p.artifact_damaged_max_beam_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has damaged the beam system maximum health"),full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.artifact_damaged_max_beam_health_message_dmg = "artifact_damaged_max_beam_health_message_dmg"
					p:addCustomMessage("DamageControl",p.artifact_damaged_max_beam_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has damaged the beam system maximum health"),full_desc))
				end
			end
		end
	end)
	return wma
end
function wreckModHealthMissile(x,y)
	local full_desc = wreck_mod_type[2].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[2].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		local max_health = p:getSystemHealthMax("missilesystem")
		local health = p:getSystemHealth("missilesystem")
		local scan_bonus = 0
		if self:isScannedByFaction(p:getFaction()) then
			scan_bonus = difficulty * 5
		end
		if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
			if max_health < 1 then
				p:setSystemHealthMax("missilesystem",math.min(1, max_health + .05))
				if p:hasPlayerAtPosition("Engineering") then
					p.artifact_improved_max_missile_health_message = "artifact_improved_max_missile_health_message"
					p:addCustomMessage("Engineering",p.artifact_improved_max_missile_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has improved the missile system maximum health"),full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.artifact_improved_max_missile_health_message_plus = "artifact_improved_max_missile_health_message_plus"
					p:addCustomMessage("Engineering+",p.artifact_improved_max_missile_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has improved the missile system maximum health"),full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.artifact_improved_max_missile_health_message_dmg = "artifact_improved_max_missile_health_message_dmg"
					p:addCustomMessage("DamageControl",p.artifact_improved_max_missile_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has improved the missile system maximum health"),full_desc))
				end
			elseif health < 1 then
				p:setSystemHealth("missilesystem",math.min(1, health + .05))
				if p:hasPlayerAtPosition("Engineering") then
					p.artifact_improved_missile_health_message = "artifact_improved_missile_health_message"
					p:addCustomMessage("Engineering",p.artifact_improved_missile_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has improved the missile system health"),full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.artifact_improved_missile_health_message_plus = "artifact_improved_missile_health_message_plus"
					p:addCustomMessage("Engineering+",p.artifact_improved_missile_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has improved the missile system health"),full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.artifact_improved_missile_health_message_dmg = "artifact_improved_missile_health_message_dmg"
					p:addCustomMessage("DamageControl",p.artifact_improved_missile_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has improved the missile system health"),full_desc))
				end
			else
				if p:hasPlayerAtPosition("Engineering") then
					p.artifact_missile_health_message = "artifact_missile_health_message"
					p:addCustomMessage("Engineering",p.artifact_missile_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has had no impact on an already healthy missile system"),full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.artifact_missile_health_message_plus = "artifact_missile_health_message_plus"
					p:addCustomMessage("Engineering+",p.artifact_missile_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has had no impact on an already healthy missile system"),full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.artifact_missile_health_message_dmg = "artifact_missile_health_message_dmg"
					p:addCustomMessage("DamageControl",p.artifact_missile_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has had no impact on an already healthy missile system"),full_desc))
				end
			end
		else
			if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
				p:setSystemHealth("missilesystem",math.max(-1, health - .05))
				if p:hasPlayerAtPosition("Engineering") then
					p.artifact_damaged_missile_health_message = "artifact_damaged_missile_health_message"
					p:addCustomMessage("Engineering",p.artifact_damaged_missile_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has damaged the missile system health"),full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.artifact_damaged_missile_health_message_plus = "artifact_damaged_missile_health_message_plus"
					p:addCustomMessage("Engineering+",p.artifact_damaged_missile_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has damaged the missile system health"),full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.artifact_damaged_missile_health_message_dmg = "artifact_damaged_missile_health_message_dmg"
					p:addCustomMessage("DamageControl",p.artifact_damaged_missile_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has damaged the missile system health"),full_desc))
				end
			else
				p:setSystemHealthMax("missilesystem",math.max(-1, max_health - .05))
				if p:hasPlayerAtPosition("Engineering") then
					p.artifact_damaged_max_missile_health_message = "artifact_damaged_max_missile_health_message"
					p:addCustomMessage("Engineering",p.artifact_damaged_max_missile_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has damaged the missile system maximum health"),full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.artifact_damaged_max_missile_health_message_plus = "artifact_damaged_max_missile_health_message_plus"
					p:addCustomMessage("Engineering+",p.artifact_damaged_max_missile_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has damaged the missile system maximum health"),full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.artifact_damaged_max_missile_health_message_dmg = "artifact_damaged_max_missile_health_message_dmg"
					p:addCustomMessage("DamageControl",p.artifact_damaged_max_missile_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has damaged the missile system maximum health"),full_desc))
				end
			end
		end
	end)
	return wma
end
function wreckModHealthImpulse(x,y)
	local full_desc = wreck_mod_type[3].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[3].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		local max_health = p:getSystemHealthMax("impulse")
		local health = p:getSystemHealth("impulse")
		local scan_bonus = 0
		if self:isScannedByFaction(p:getFaction()) then
			scan_bonus = difficulty * 5
		end
		if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
			if max_health < 1 then
				p:setSystemHealthMax("impulse",math.min(1, max_health + .05))
				if p:hasPlayerAtPosition("Engineering") then
					p.artifact_improved_max_impulse_health_message = "artifact_improved_max_impulse_health_message"
					p:addCustomMessage("Engineering",p.artifact_improved_max_impulse_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has improved the impulse system maximum health"),full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.artifact_improved_max_impulse_health_message_plus = "artifact_improved_max_impulse_health_message_plus"
					p:addCustomMessage("Engineering+",p.artifact_improved_max_impulse_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has improved the impulse system maximum health"),full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.artifact_improved_max_impulse_health_message_dmg = "artifact_improved_max_impulse_health_message_dmg"
					p:addCustomMessage("DamageControl",p.artifact_improved_max_impulse_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has improved the impulse system maximum health"),full_desc))
				end
			elseif health < 1 then
				p:setSystemHealth("impulse",math.min(1, health + .05))
				if p:hasPlayerAtPosition("Engineering") then
					p.artifact_improved_impulse_health_message = "artifact_improved_impulse_health_message"
					p:addCustomMessage("Engineering",p.artifact_improved_impulse_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has improved the impulse system health"),full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.artifact_improved_impulse_health_message_plus = "artifact_improved_impulse_health_message_plus"
					p:addCustomMessage("Engineering+",p.artifact_improved_impulse_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has improved the impulse system health"),full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.artifact_improved_impulse_health_message_dmg = "artifact_improved_impulse_health_message_dmg"
					p:addCustomMessage("DamageControl",p.artifact_improved_impulse_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has improved the impulse system health"),full_desc))
				end
			else
				if p:hasPlayerAtPosition("Engineering") then
					p.artifact_impulse_health_message = "artifact_impulse_health_message"
					p:addCustomMessage("Engineering",p.artifact_impulse_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has had no impact on an already healthy impulse system"),full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.artifact_impulse_health_message_plus = "artifact_impulse_health_message_plus"
					p:addCustomMessage("Engineering+",p.artifact_impulse_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has had no impact on an already healthy impulse system"),full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.artifact_impulse_health_message_dmg = "artifact_impulse_health_message_dmg"
					p:addCustomMessage("DamageControl",p.artifact_impulse_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has had no impact on an already healthy impulse system"),full_desc))
				end
			end
		else
			if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
				p:setSystemHealth("impulse",math.max(-1, health - .05))
				if p:hasPlayerAtPosition("Engineering") then
					p.artifact_damaged_impulse_health_message = "artifact_damaged_impulse_health_message"
					p:addCustomMessage("Engineering",p.artifact_damaged_impulse_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has damaged the impulse system health"),full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.artifact_damaged_impulse_health_message_plus = "artifact_damaged_impulse_health_message_plus"
					p:addCustomMessage("Engineering+",p.artifact_damaged_impulse_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has damaged the impulse system health"),full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.artifact_damaged_impulse_health_message_dmg = "artifact_damaged_impulse_health_message_dmg"
					p:addCustomMessage("DamageControl",p.artifact_damaged_impulse_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has damaged the impulse system health"),full_desc))
				end
			else
				p:setSystemHealthMax("impulse",math.max(-1, max_health - .05))
				if p:hasPlayerAtPosition("Engineering") then
					p.artifact_damaged_max_impulse_health_message = "artifact_damaged_max_impulse_health_message"
					p:addCustomMessage("Engineering",p.artifact_damaged_max_impulse_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has damaged the impulse system maximum health"),full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.artifact_damaged_max_impulse_health_message_plus = "artifact_damaged_max_impulse_health_message_plus"
					p:addCustomMessage("Engineering+",p.artifact_damaged_max_impulse_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has damaged the impulse system maximum health"),full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.artifact_damaged_max_impulse_health_message_dmg = "artifact_damaged_max_impulse_health_message_dmg"
					p:addCustomMessage("DamageControl",p.artifact_damaged_max_impulse_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has damaged the impulse system maximum health"),full_desc))
				end
			end
		end
	end)
	return wma
end
function wreckModHealthWarp(x,y)
	local full_desc = wreck_mod_type[4].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[4].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		if p:hasSystem("warp") then
			local max_health = p:getSystemHealthMax("warp")
			local health = p:getSystemHealth("warp")
			local scan_bonus = 0
			if self:isScannedByFaction(p:getFaction()) then
				scan_bonus = difficulty * 5
			end
			if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
				if max_health < 1 then
					p:setSystemHealthMax("warp",math.min(1, max_health + .05))
					if p:hasPlayerAtPosition("Engineering") then
						p.artifact_improved_max_warp_health_message = "artifact_improved_max_warp_health_message"
						p:addCustomMessage("Engineering",p.artifact_improved_max_warp_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has improved the warp system maximum health"),full_desc))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p.artifact_improved_max_warp_health_message_plus = "artifact_improved_max_warp_health_message_plus"
						p:addCustomMessage("Engineering+",p.artifact_improved_max_warp_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has improved the warp system maximum health"),full_desc))
					end
					if p:hasPlayerAtPosition("DamageControl") then
						p.artifact_improved_max_warp_health_message_dmg = "artifact_improved_max_warp_health_message_dmg"
						p:addCustomMessage("DamageControl",p.artifact_improved_max_warp_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has improved the warp system maximum health"),full_desc))
					end
				elseif health < 1 then
					p:setSystemHealth("warp",math.min(1, health + .05))
					if p:hasPlayerAtPosition("Engineering") then
						p.artifact_improved_warp_health_message = "artifact_improved_warp_health_message"
						p:addCustomMessage("Engineering",p.artifact_improved_warp_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has improved the warp system health"),full_desc))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p.artifact_improved_warp_health_message_plus = "artifact_improved_warp_health_message_plus"
						p:addCustomMessage("Engineering+",p.artifact_improved_warp_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has improved the warp system health"),full_desc))
					end
					if p:hasPlayerAtPosition("DamageControl") then
						p.artifact_improved_warp_health_message_dmg = "artifact_improved_warp_health_message_dmg"
						p:addCustomMessage("DamageControl",p.artifact_improved_warp_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has improved the warp system health"),full_desc))
					end
				else
					if p:hasPlayerAtPosition("Engineering") then
						p.artifact_warp_health_message = "artifact_warp_health_message"
						p:addCustomMessage("Engineering",p.artifact_warp_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has had no impact on an already healthy warp system"),full_desc))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p.artifact_warp_health_message_plus = "artifact_warp_health_message_plus"
						p:addCustomMessage("Engineering+",p.artifact_warp_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has had no impact on an already healthy warp system"),full_desc))
					end
					if p:hasPlayerAtPosition("DamageControl") then
						p.artifact_warp_health_message_dmg = "artifact_warp_health_message_dmg"
						p:addCustomMessage("DamageControl",p.artifact_warp_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has had no impact on an already healthy warp system"),full_desc))
					end
				end
			else
				if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
					p:setSystemHealth("warp",math.max(-1, health - .05))
					if p:hasPlayerAtPosition("Engineering") then
						p.artifact_damaged_warp_health_message = "artifact_damaged_warp_health_message"
						p:addCustomMessage("Engineering",p.artifact_damaged_warp_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has damaged the warp system health"),full_desc))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p.artifact_damaged_warp_health_message_plus = "artifact_damaged_warp_health_message_plus"
						p:addCustomMessage("Engineering+",p.artifact_damaged_warp_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has damaged the warp system health"),full_desc))
					end
					if p:hasPlayerAtPosition("DamageControl") then
						p.artifact_damaged_warp_health_message_dmg = "artifact_damaged_warp_health_message_dmg"
						p:addCustomMessage("DamageControl",p.artifact_damaged_warp_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has damaged the warp system health"),full_desc))
					end
				else
					p:setSystemHealthMax("warp",math.max(-1, max_health - .05))
					if p:hasPlayerAtPosition("Engineering") then
						p.artifact_damaged_max_warp_health_message = "artifact_damaged_max_warp_health_message"
						p:addCustomMessage("Engineering",p.artifact_damaged_max_warp_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has damaged the warp system maximum health"),full_desc))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p.artifact_damaged_max_warp_health_message_plus = "artifact_damaged_max_warp_health_message_plus"
						p:addCustomMessage("Engineering+",p.artifact_damaged_max_warp_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has damaged the warp system maximum health"),full_desc))
					end
					if p:hasPlayerAtPosition("DamageControl") then
						p.artifact_damaged_max_warp_health_message_dmg = "artifact_damaged_max_warp_health_message_dmg"
						p:addCustomMessage("DamageControl",p.artifact_damaged_max_warp_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has damaged the warp system maximum health"),full_desc))
					end
				end
			end
		end
	end)
	return wma
end
function wreckModHealthJump(x,y)
	local full_desc = wreck_mod_type[5].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[5].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		if p:hasSystem("jumpdrive") then
			local max_health = p:getSystemHealthMax("jumpdrive")
			local health = p:getSystemHealth("jumpdrive")
			local scan_bonus = 0
			if self:isScannedByFaction(p:getFaction()) then
				scan_bonus = difficulty * 5
			end
			if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
				if max_health < 1 then
					p:setSystemHealthMax("jumpdrive",math.min(1, max_health + .05))
					if p:hasPlayerAtPosition("Engineering") then
						p.artifact_improved_max_jump_health_message = "artifact_improved_max_jump_health_message"
						p:addCustomMessage("Engineering",p.artifact_improved_max_jump_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has improved the jump system maximum health"),full_desc))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p.artifact_improved_max_jump_health_message_plus = "artifact_improved_max_jump_health_message_plus"
						p:addCustomMessage("Engineering+",p.artifact_improved_max_jump_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has improved the jump system maximum health"),full_desc))
					end
					if p:hasPlayerAtPosition("DamageControl") then
						p.artifact_improved_max_jump_health_message_dmg = "artifact_improved_max_jump_health_message_dmg"
						p:addCustomMessage("DamageControl",p.artifact_improved_max_jump_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has improved the jump system maximum health"),full_desc))
					end
				elseif health < 1 then
					p:setSystemHealth("jumpdrive",math.min(1, health + .05))
					if p:hasPlayerAtPosition("Engineering") then
						p.artifact_improved_jump_health_message = "artifact_improved_jump_health_message"
						p:addCustomMessage("Engineering",p.artifact_improved_jump_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has improved the jump system health"),full_desc))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p.artifact_improved_jump_health_message_plus = "artifact_improved_jump_health_message_plus"
						p:addCustomMessage("Engineering+",p.artifact_improved_jump_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has improved the jump system health"),full_desc))
					end
					if p:hasPlayerAtPosition("DamageControl") then
						p.artifact_improved_jump_health_message_dmg = "artifact_improved_jump_health_message_dmg"
						p:addCustomMessage("DamageControl",p.artifact_improved_jump_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has improved the jump system health"),full_desc))
					end
				else
					if p:hasPlayerAtPosition("Engineering") then
						p.artifact_jump_health_message = "artifact_jump_health_message"
						p:addCustomMessage("Engineering",p.artifact_jump_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has had no impact on an already healthy jump system"),full_desc))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p.artifact_jump_health_message_plus = "artifact_jump_health_message_plus"
						p:addCustomMessage("Engineering+",p.artifact_jump_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has had no impact on an already healthy jump system"),full_desc))
					end
					if p:hasPlayerAtPosition("DamageControl") then
						p.artifact_jump_health_message_dmg = "artifact_jump_health_message_dmg"
						p:addCustomMessage("DamageControl",p.artifact_jump_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has had no impact on an already healthy jump system"),full_desc))
					end
				end
			else
				if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
					p:setSystemHealth("jumpdrive",math.max(-1, health - .05))
					if p:hasPlayerAtPosition("Engineering") then
						p.artifact_damaged_jump_health_message = "artifact_damaged_jump_health_message"
						p:addCustomMessage("Engineering",p.artifact_damaged_jump_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has damaged the jump system health"),full_desc))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p.artifact_damaged_jump_health_message_plus = "artifact_damaged_jump_health_message_plus"
						p:addCustomMessage("Engineering+",p.artifact_damaged_jump_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has damaged the jump system health"),full_desc))
					end
					if p:hasPlayerAtPosition("DamageControl") then
						p.artifact_damaged_jump_health_message_dmg = "artifact_damaged_jump_health_message_dmg"
						p:addCustomMessage("DamageControl",p.artifact_damaged_jump_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has damaged the jump system health"),full_desc))
					end
				else
					p:setSystemHealthMax("jumpdrive",math.max(-1, max_health - .05))
					if p:hasPlayerAtPosition("Engineering") then
						p.artifact_damaged_max_jump_health_message = "artifact_damaged_max_jump_health_message"
						p:addCustomMessage("Engineering",p.artifact_damaged_max_jump_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has damaged the jump system maximum health"),full_desc))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p.artifact_damaged_max_jump_health_message_plus = "artifact_damaged_max_jump_health_message_plus"
						p:addCustomMessage("Engineering+",p.artifact_damaged_max_jump_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has damaged the jump system maximum health"),full_desc))
					end
					if p:hasPlayerAtPosition("DamageControl") then
						p.artifact_damaged_max_jump_health_message_dmg = "artifact_damaged_max_jump_health_message_dmg"
						p:addCustomMessage("DamageControl",p.artifact_damaged_max_jump_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has damaged the jump system maximum health"),full_desc))
					end
				end
			end
		end
	end)
	return wma
end
function wreckModHealthShield(x,y)
	local full_desc = wreck_mod_type[6].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[6].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		if p:getShieldCount() > 1 then
			local max_health_front = p:getSystemHealthMax("frontshield")
			local health_front = p:getSystemHealth("frontshield")
			local max_health_rear = p:getSystemHealthMax("rearshield")
			local health_rear = p:getSystemHealth("rearshield")
			local scan_bonus = 0
			if self:isScannedByFaction(p:getFaction()) then
				scan_bonus = difficulty * 5
			end
			if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
				if max_health_front < 1 then
					p:setSystemHealthMax("frontshield",math.min(1, max_health + .05))
					if p:hasPlayerAtPosition("Engineering") then
						p.artifact_improved_max_front_shield_health_message = "artifact_improved_max_front_shield_health_message"
						p:addCustomMessage("Engineering",p.artifact_improved_max_front_shield_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has improved the front shield system maximum health"),full_desc))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p.artifact_improved_max_front_shield_health_message_plus = "artifact_improved_max_front_shield_health_message_plus"
						p:addCustomMessage("Engineering+",p.artifact_improved_max_front_shield_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has improved the front shield system maximum health"),full_desc))
					end
					if p:hasPlayerAtPosition("DamageControl") then
						p.artifact_improved_max_front_shield_health_message_dmg = "artifact_improved_max_front_shield_health_message_dmg"
						p:addCustomMessage("DamageControl",p.artifact_improved_max_front_shield_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has improved the front shield system maximum health"),full_desc))
					end
				elseif max_health_rear < 1 then
					p:setSystemHealthMax("rearshield",math.min(1, max_health + .05))
					if p:hasPlayerAtPosition("Engineering") then
						p.artifact_improved_max_rear_shield_health_message = "artifact_improved_max_rear_shield_health_message"
						p:addCustomMessage("Engineering",p.artifact_improved_max_rear_shield_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has improved the rear shield system maximum health"),full_desc))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p.artifact_improved_max_rear_shield_health_message_plus = "artifact_improved_max_rear_shield_health_message_plus"
						p:addCustomMessage("Engineering+",p.artifact_improved_max_rear_shield_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has improved the rear shield system maximum health"),full_desc))
					end
					if p:hasPlayerAtPosition("DamageControl") then
						p.artifact_improved_max_rear_shield_health_message_dmg = "artifact_improved_max_rear_shield_health_message_dmg"
						p:addCustomMessage("DamageControl",p.artifact_improved_max_rear_shield_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has improved the rear shield system maximum health"),full_desc))
					end
				elseif health_front < 1 then
					p:setSystemHealth("frontshield",math.min(1, health + .05))
					if p:hasPlayerAtPosition("Engineering") then
						p.artifact_improved_front_shield_health_message = "artifact_improved_front_shield_health_message"
						p:addCustomMessage("Engineering",p.artifact_improved_front_shield_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has improved the front shield system health"),full_desc))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p.artifact_improved_front_shield_health_message_plus = "artifact_improved_front_shield_health_message_plus"
						p:addCustomMessage("Engineering+",p.artifact_improved_front_shield_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has improved the front shield system health"),full_desc))
					end
					if p:hasPlayerAtPosition("DamageControl") then
						p.artifact_improved_front_shield_health_message_dmg = "artifact_improved_front_shield_health_message_dmg"
						p:addCustomMessage("DamageControl",p.artifact_improved_front_shield_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has improved the front shield system health"),full_desc))
					end
				elseif health_rear < 1 then
					p:setSystemHealth("rearshield",math.min(1, health + .05))
					if p:hasPlayerAtPosition("Engineering") then
						p.artifact_improved_rear_shield_health_message = "artifact_improved_rear_shield_health_message"
						p:addCustomMessage("Engineering",p.artifact_improved_rear_shield_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has improved the rear shield system health"),full_desc))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p.artifact_improved_rear_shield_health_message_plus = "artifact_improved_rear_shield_health_message_plus"
						p:addCustomMessage("Engineering+",p.artifact_improved_rear_shield_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has improved the rear shield system health"),full_desc))
					end
					if p:hasPlayerAtPosition("DamageControl") then
						p.artifact_improved_rear_shield_health_message_dmg = "artifact_improved_rear_shield_health_message_dmg"
						p:addCustomMessage("DamageControl",p.artifact_improved_rear_shield_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has improved the rear shield system health"),full_desc))
					end
				else
					if p:hasPlayerAtPosition("Engineering") then
						p.artifact_shield_health_message = "artifact_shield_health_message"
						p:addCustomMessage("Engineering",p.artifact_shield_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has had no impact on an already healthy shield system"),full_desc))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p.artifact_shield_health_message_plus = "artifact_shield_health_message_plus"
						p:addCustomMessage("Engineering+",p.artifact_shield_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has had no impact on an already healthy shield system"),full_desc))
					end
					if p:hasPlayerAtPosition("DamageControl") then
						p.artifact_shield_health_message_dmg = "artifact_shield_health_message_dmg"
						p:addCustomMessage("DamageControl",p.artifact_shield_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has had no impact on an already healthy shield system"),full_desc))
					end
				end
			else
				if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
					if random(1,100) <= 50 then
						p:setSystemHealth("frontshield",math.max(-1, health - .05))
						if p:hasPlayerAtPosition("Engineering") then
							p.artifact_damaged_front_shield_health_message = "artifact_damaged_front_shield_health_message"
							p:addCustomMessage("Engineering",p.artifact_damaged_front_shield_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has damaged the front shield system health"),full_desc))
						end
						if p:hasPlayerAtPosition("Engineering+") then
							p.artifact_damaged_front_shield_health_message_plus = "artifact_damaged_front_shield_health_message_plus"
							p:addCustomMessage("Engineering+",p.artifact_damaged_front_shield_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has damaged the front shield system health"),full_desc))
						end
						if p:hasPlayerAtPosition("DamageControl") then
							p.artifact_damaged_front_shield_health_message_dmg = "artifact_damaged_front_shield_health_message_dmg"
							p:addCustomMessage("DamageControl",p.artifact_damaged_front_shield_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has damaged the front shield system health"),full_desc))
						end
					else
						p:setSystemHealth("rearshield",math.max(-1, health - .05))
						if p:hasPlayerAtPosition("Engineering") then
							p.artifact_damaged_rear_shield_health_message = "artifact_damaged_rear_shield_health_message"
							p:addCustomMessage("Engineering",p.artifact_damaged_rear_shield_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has damaged the rear shield system health"),full_desc))
						end
						if p:hasPlayerAtPosition("Engineering+") then
							p.artifact_damaged_rear_shield_health_message_plus = "artifact_damaged_rear_shield_health_message_plus"
							p:addCustomMessage("Engineering+",p.artifact_damaged_rear_shield_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has damaged the rear shield system health"),full_desc))
						end
						if p:hasPlayerAtPosition("DamageControl") then
							p.artifact_damaged_rear_shield_health_message_dmg = "artifact_damaged_rear_shield_health_message_dmg"
							p:addCustomMessage("DamageControl",p.artifact_damaged_rear_shield_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has damaged the rear shield system health"),full_desc))
						end
					end
				else
					if random(1,100) <= 50 then
						p:setSystemHealthMax("frontshield",math.max(-1, max_health - .05))
						if p:hasPlayerAtPosition("Engineering") then
							p.artifact_damaged_max_front_shield_health_message = "artifact_damaged_max_front_shield_health_message"
							p:addCustomMessage("Engineering",p.artifact_damaged_max_front_shield_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has damaged the front shield system maximum health"),full_desc))
						end
						if p:hasPlayerAtPosition("Engineering+") then
							p.artifact_damaged_max_front_shield_health_message_plus = "artifact_damaged_max_front_shield_health_message_plus"
							p:addCustomMessage("Engineering+",p.artifact_damaged_max_front_shield_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has damaged the front shield system maximum health"),full_desc))
						end
						if p:hasPlayerAtPosition("DamageControl") then
							p.artifact_damaged_max_front_shield_health_message_dmg = "artifact_damaged_max_front_shield_health_message_dmg"
							p:addCustomMessage("DamageControl",p.artifact_damaged_max_front_shield_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has damaged the front shield system maximum health"),full_desc))
						end
					else
						p:setSystemHealthMax("rearshield",math.max(-1, max_health - .05))
						if p:hasPlayerAtPosition("Engineering") then
							p.artifact_damaged_max_rear_shield_health_message = "artifact_damaged_max_rear_shield_health_message"
							p:addCustomMessage("Engineering",p.artifact_damaged_max_rear_shield_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has damaged the rear shield system maximum health"),full_desc))
						end
						if p:hasPlayerAtPosition("Engineering+") then
							p.artifact_damaged_max_rear_shield_health_message_plus = "artifact_damaged_max_rear_shield_health_message_plus"
							p:addCustomMessage("Engineering+",p.artifact_damaged_max_rear_shield_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has damaged the rear shield system maximum health"),full_desc))
						end
						if p:hasPlayerAtPosition("DamageControl") then
							p.artifact_damaged_max_rear_shield_health_message_dmg = "artifact_damaged_max_rear_shield_health_message_dmg"
							p:addCustomMessage("DamageControl",p.artifact_damaged_max_rear_shield_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has damaged the rear shield system maximum health"),full_desc))
						end
					end
				end
			end
		else	--only one shield
			local max_health = p:getSystemHealthMax("frontshield")
			local health = p:getSystemHealth("frontshield")
			if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
				if max_health < 1 then
					p:setSystemHealthMax("frontshield",math.min(1, max_health + .05))
					if p:hasPlayerAtPosition("Engineering") then
						p.artifact_improved_max_shield_health_message = "artifact_improved_max_shield_health_message"
						p:addCustomMessage("Engineering",p.artifact_improved_max_shield_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has improved the shield system maximum health"),full_desc))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p.artifact_improved_max_shield_health_message_plus = "artifact_improved_max_shield_health_message_plus"
						p:addCustomMessage("Engineering+",p.artifact_improved_max_shield_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has improved the shield system maximum health"),full_desc))
					end
					if p:hasPlayerAtPosition("DamageControl") then
						p.artifact_improved_max_shield_health_message_dmg = "artifact_improved_max_shield_health_message_dmg"
						p:addCustomMessage("DamageControl",p.artifact_improved_max_shield_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has improved the shield system maximum health"),full_desc))
					end
				elseif health < 1 then
					p:setSystemHealth("frontshield",math.min(1, health + .05))
					if p:hasPlayerAtPosition("Engineering") then
						p.artifact_improved_shield_health_message = "artifact_improved_shield_health_message"
						p:addCustomMessage("Engineering",p.artifact_improved_shield_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has improved the shield system health"),full_desc))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p.artifact_improved_shield_health_message_plus = "artifact_improved_shield_health_message_plus"
						p:addCustomMessage("Engineering+",p.artifact_improved_shield_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has improved the shield system health"),full_desc))
					end
					if p:hasPlayerAtPosition("DamageControl") then
						p.artifact_improved_shield_health_message_dmg = "artifact_improved_shield_health_message_dmg"
						p:addCustomMessage("DamageControl",p.artifact_improved_shield_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has improved the shield system health"),full_desc))
					end
				else
					if p:hasPlayerAtPosition("Engineering") then
						p.artifact_shield_health_message = "artifact_shield_health_message"
						p:addCustomMessage("Engineering",p.artifact_shield_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has had no impact on an already healthy shield system"),full_desc))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p.artifact_shield_health_message_plus = "artifact_shield_health_message_plus"
						p:addCustomMessage("Engineering+",p.artifact_shield_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has had no impact on an already healthy shield system"),full_desc))
					end
					if p:hasPlayerAtPosition("DamageControl") then
						p.artifact_shield_health_message_dmg = "artifact_shield_health_message_dmg"
						p:addCustomMessage("DamageControl",p.artifact_shield_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has had no impact on an already healthy shield system"),full_desc))
					end
				end
			else
				if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
					p:setSystemHealth("frontshield",math.max(-1, health - .05))
					if p:hasPlayerAtPosition("Engineering") then
						p.artifact_damaged_shield_health_message = "artifact_damaged_shield_health_message"
						p:addCustomMessage("Engineering",p.artifact_damaged_shield_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has damaged the shield system health"),full_desc))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p.artifact_damaged_shield_health_message_plus = "artifact_damaged_shield_health_message_plus"
						p:addCustomMessage("Engineering+",p.artifact_damaged_shield_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has damaged the shield system health"),full_desc))
					end
					if p:hasPlayerAtPosition("DamageControl") then
						p.artifact_damaged_shield_health_message_dmg = "artifact_damaged_shield_health_message_dmg"
						p:addCustomMessage("DamageControl",p.artifact_damaged_shield_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has damaged the shield system health"),full_desc))
					end
				else
					p:setSystemHealthMax("frontshield",math.max(-1, max_health - .05))
					if p:hasPlayerAtPosition("Engineering") then
						p.artifact_damaged_max_shield_health_message = "artifact_damaged_max_shield_health_message"
						p:addCustomMessage("Engineering",p.artifact_damaged_max_shield_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has damaged the shield system maximum health"),full_desc))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p.artifact_damaged_max_shield_health_message_plus = "artifact_damaged_max_shield_health_message_plus"
						p:addCustomMessage("Engineering+",p.artifact_damaged_max_shield_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has damaged the shield system maximum health"),full_desc))
					end
					if p:hasPlayerAtPosition("DamageControl") then
						p.artifact_damaged_max_shield_health_message_dmg = "artifact_damaged_max_shield_health_message_dmg"
						p:addCustomMessage("DamageControl",p.artifact_damaged_max_shield_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has damaged the shield system maximum health"),full_desc))
					end
				end
			end
		end
	end)
	return wma
end
function wreckModHealthSpin(x,y)
	local full_desc = wreck_mod_type[7].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[7].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		local max_health = p:getSystemHealthMax("maneuver")
		local health = p:getSystemHealth("maneuver")
		local scan_bonus = 0
		if self:isScannedByFaction(p:getFaction()) then
			scan_bonus = difficulty * 5
		end
		if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
			if max_health < 1 then
				p:setSystemHealthMax("maneuver",math.min(1, max_health + .05))
				if p:hasPlayerAtPosition("Engineering") then
					p.artifact_improved_max_maneuver_health_message = "artifact_improved_max_maneuver_health_message"
					p:addCustomMessage("Engineering",p.artifact_improved_max_maneuver_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has improved the maneuver system maximum health"),full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.artifact_improved_max_maneuver_health_message_plus = "artifact_improved_max_maneuver_health_message_plus"
					p:addCustomMessage("Engineering+",p.artifact_improved_max_maneuver_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has improved the maneuver system maximum health"),full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.artifact_improved_max_maneuver_health_message_dmg = "artifact_improved_max_maneuver_health_message_dmg"
					p:addCustomMessage("DamageControl",p.artifact_improved_max_maneuver_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has improved the maneuver system maximum health"),full_desc))
				end
			elseif health < 1 then
				p:setSystemHealth("maneuver",math.min(1, health + .05))
				if p:hasPlayerAtPosition("Engineering") then
					p.artifact_improved_maneuver_health_message = "artifact_improved_maneuver_health_message"
					p:addCustomMessage("Engineering",p.artifact_improved_maneuver_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has improved the maneuver system health"),full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.artifact_improved_maneuver_health_message_plus = "artifact_improved_maneuver_health_message_plus"
					p:addCustomMessage("Engineering+",p.artifact_improved_maneuver_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has improved the maneuver system health"),full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.artifact_improved_maneuver_health_message_dmg = "artifact_improved_maneuver_health_message_dmg"
					p:addCustomMessage("DamageControl",p.artifact_improved_maneuver_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has improved the maneuver system health"),full_desc))
				end
			else
				if p:hasPlayerAtPosition("Engineering") then
					p.artifact_maneuver_health_message = "artifact_maneuver_health_message"
					p:addCustomMessage("Engineering",p.artifact_maneuver_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has had no impact on an already healthy maneuver system"),full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.artifact_maneuver_health_message_plus = "artifact_maneuver_health_message_plus"
					p:addCustomMessage("Engineering+",p.artifact_maneuver_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has had no impact on an already healthy maneuver system"),full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.artifact_maneuver_health_message_dmg = "artifact_maneuver_health_message_dmg"
					p:addCustomMessage("DamageControl",p.artifact_maneuver_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has had no impact on an already healthy maneuver system"),full_desc))
				end
			end
		else
			if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
				p:setSystemHealth("maneuver",math.max(-1, health - .05))
				if p:hasPlayerAtPosition("Engineering") then
					p.artifact_damaged_maneuver_health_message = "artifact_damaged_maneuver_health_message"
					p:addCustomMessage("Engineering",p.artifact_damaged_maneuver_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has damaged the maneuver system health"),full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.artifact_damaged_maneuver_health_message_plus = "artifact_damaged_maneuver_health_message_plus"
					p:addCustomMessage("Engineering+",p.artifact_damaged_maneuver_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has damaged the maneuver system health"),full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.artifact_damaged_maneuver_health_message_dmg = "artifact_damaged_maneuver_health_message_dmg"
					p:addCustomMessage("DamageControl",p.artifact_damaged_maneuver_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has damaged the maneuver system health"),full_desc))
				end
			else
				p:setSystemHealthMax("maneuver",math.max(-1, max_health - .05))
				if p:hasPlayerAtPosition("Engineering") then
					p.artifact_damaged_max_maneuver_health_message = "artifact_damaged_max_maneuver_health_message"
					p:addCustomMessage("Engineering",p.artifact_damaged_max_maneuver_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has damaged the maneuver system maximum health"),full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.artifact_damaged_max_maneuver_health_message_plus = "artifact_damaged_max_maneuver_health_message_plus"
					p:addCustomMessage("Engineering+",p.artifact_damaged_max_maneuver_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has damaged the maneuver system maximum health"),full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.artifact_damaged_max_maneuver_health_message_dmg = "artifact_damaged_max_maneuver_health_message_dmg"
					p:addCustomMessage("DamageControl",p.artifact_damaged_max_maneuver_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has damaged the maneuver system maximum health"),full_desc))
				end
			end
		end
	end)
	return wma
end
function wreckModHealthReactor(x,y)
	local full_desc = wreck_mod_type[8].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[8].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		local max_health = p:getSystemHealthMax("reactor")
		local health = p:getSystemHealth("reactor")
		local scan_bonus = 0
		if self:isScannedByFaction(p:getFaction()) then
			scan_bonus = difficulty * 5
		end
		if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
			if max_health < 1 then
				p:setSystemHealthMax("reactor",math.min(1, max_health + .05))
				if p:hasPlayerAtPosition("Engineering") then
					p.artifact_improved_max_reactor_health_message = "artifact_improved_max_reactor_health_message"
					p:addCustomMessage("Engineering",p.artifact_improved_max_reactor_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has improved the reactor system maximum health"),full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.artifact_improved_max_reactor_health_message_plus = "artifact_improved_max_reactor_health_message_plus"
					p:addCustomMessage("Engineering+",p.artifact_improved_max_reactor_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has improved the reactor system maximum health"),full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.artifact_improved_max_reactor_health_message_dmg = "artifact_improved_max_reactor_health_message_dmg"
					p:addCustomMessage("DamageControl",p.artifact_improved_max_reactor_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has improved the reactor system maximum health"),full_desc))
				end
			elseif health < 1 then
				p:setSystemHealth("reactor",math.min(1, health + .05))
				if p:hasPlayerAtPosition("Engineering") then
					p.artifact_improved_reactor_health_message = "artifact_improved_reactor_health_message"
					p:addCustomMessage("Engineering",p.artifact_improved_reactor_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has improved the reactor system health"),full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.artifact_improved_reactor_health_message_plus = "artifact_improved_reactor_health_message_plus"
					p:addCustomMessage("Engineering+",p.artifact_improved_reactor_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has improved the reactor system health"),full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.artifact_improved_reactor_health_message_dmg = "artifact_improved_reactor_health_message_dmg"
					p:addCustomMessage("DamageControl",p.artifact_improved_reactor_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has improved the reactor system health"),full_desc))
				end
			else
				if p:hasPlayerAtPosition("Engineering") then
					p.artifact_reactor_health_message = "artifact_reactor_health_message"
					p:addCustomMessage("Engineering",p.artifact_reactor_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has had no impact on an already healthy reactor system"),full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.artifact_reactor_health_message_plus = "artifact_reactor_health_message_plus"
					p:addCustomMessage("Engineering+",p.artifact_reactor_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has had no impact on an already healthy reactor system"),full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.artifact_reactor_health_message_dmg = "artifact_reactor_health_message_dmg"
					p:addCustomMessage("DamageControl",p.artifact_reactor_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has had no impact on an already healthy reactor system"),full_desc))
				end
			end
		else
			if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
				p:setSystemHealth("reactor",math.max(-1, health - .05))
				if p:hasPlayerAtPosition("Engineering") then
					p.artifact_damaged_reactor_health_message = "artifact_damaged_reactor_health_message"
					p:addCustomMessage("Engineering",p.artifact_damaged_reactor_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has damaged the reactor system health"),full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.artifact_damaged_reactor_health_message_plus = "artifact_damaged_reactor_health_message_plus"
					p:addCustomMessage("Engineering+",p.artifact_damaged_reactor_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has damaged the reactor system health"),full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.artifact_damaged_reactor_health_message_dmg = "artifact_damaged_reactor_health_message_dmg"
					p:addCustomMessage("DamageControl",p.artifact_damaged_reactor_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has damaged the reactor system health"),full_desc))
				end
			else
				p:setSystemHealthMax("reactor",math.max(-1, max_health - .05))
				if p:hasPlayerAtPosition("Engineering") then
					p.artifact_damaged_max_reactor_health_message = "artifact_damaged_max_reactor_health_message"
					p:addCustomMessage("Engineering",p.artifact_damaged_max_reactor_health_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has damaged the reactor system maximum health"),full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.artifact_damaged_max_reactor_health_message_plus = "artifact_damaged_max_reactor_health_message_plus"
					p:addCustomMessage("Engineering+",p.artifact_damaged_max_reactor_health_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has damaged the reactor system maximum health"),full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.artifact_damaged_max_reactor_health_message_dmg = "artifact_damaged_max_reactor_health_message_dmg"
					p:addCustomMessage("DamageControl",p.artifact_damaged_max_reactor_health_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has damaged the reactor system maximum health"),full_desc))
				end
			end
		end
	end)
	return wma
end
function wreckModBoolScan(x,y)
	local full_desc = wreck_mod_type[9].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[9].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		local enabled = p:getCanScan()
		local scan_bonus = 0
		if self:isScannedByFaction(p:getFaction()) then
			scan_bonus = difficulty * 5
		end
		if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
			if not enabled then
				p:setCanScan(true)
				if p:hasPlayerAtPosition("Science") then
					p.artifact_enabled_scan_message = "artifact_enabled_scan_message"
					p:addCustomMessage("Science",p.artifact_enabled_scan_message,string.format(_("artifactEffect-msgScience", "The %s retrieved has enabled the scanners"),full_desc))
				end
				if p:hasPlayerAtPosition("Operations") then
					p.artifact_enabled_scan_message_ops = "artifact_enabled_scan_message_ops"
					p:addCustomMessage("Operations",p.artifact_enabled_scan_message_ops,string.format(_("artifactEffect-msgOperations", "The %s retrieved has enabled the scanners"),full_desc))
				end
			else
				if p:hasPlayerAtPosition("Science") then
					p.artifact_scan_message = "artifact_scan_message"
					p:addCustomMessage("Science",p.artifact_scan_message,string.format(_("artifactEffect-msgScience", "The %s retrieved does not effect the scanners"),full_desc))
				end
				if p:hasPlayerAtPosition("Operations") then
					p.artifact_scan_message_ops = "artifact_scan_message_ops"
					p:addCustomMessage("Operations",p.artifact_scan_message_ops,string.format(_("artifactEffect-msgOperations", "The %s retrieved does not effect the scanners"),full_desc))
				end
			end
		else
			if enabled then
				p:setCanScan(false)
				if p:hasPlayerAtPosition("Science") then
					p.artifact_disabled_scan_message = "artifact_disabled_scan_message"
					p:addCustomMessage("Science",p.artifact_disabled_scan_message,string.format(_("artifactEffect-msgScience", "The %s retrieved has disabled the scanners"),full_desc))
				end
				if p:hasPlayerAtPosition("Operations") then
					p.artifact_disabled_scan_message_ops = "artifact_disabled_scan_message_ops"
					p:addCustomMessage("Operations",p.artifact_disabled_scan_message_ops,string.format(_("artifactEffect-msgOperations", "The %s retrieved has disabled the scanners"),full_desc))
				end
			else
				if p:hasPlayerAtPosition("Science") then
					p.artifact_scan_message = "artifact_scan_message"
					p:addCustomMessage("Science",p.artifact_scan_message,string.format(_("artifactEffect-msgScience", "The %s retrieved does not effect the scanners"),full_desc))
				end
				if p:hasPlayerAtPosition("Operations") then
					p.artifact_scan_message_ops = "artifact_scan_message_ops"
					p:addCustomMessage("Operations",p.artifact_scan_message_ops,string.format(_("artifactEffect-msgOperations", "The %s retrieved does not effect the scanners"),full_desc))
				end
			end
		end
	end)
	return wma
end
function wreckModBoolCombat(x,y)
	local full_desc = wreck_mod_type[10].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[10].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		local enabled = p:getCanCombatManeuver()
		local scan_bonus = 0
		if self:isScannedByFaction(p:getFaction()) then
			scan_bonus = difficulty * 5
		end
		if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
			if not enabled then
				p:setCanCombatManeuver(true)
				if p:hasPlayerAtPosition("Helms") then
					p.artifact_enabled_cm_message = "artifact_enabled_cm_message"
					p:addCustomMessage("Helms",p.artifact_enabled_cm_message,string.format(_("artifactEffect-msgHelms", "The %s retrieved has enabled combat maneuver"),full_desc))
				end
				if p:hasPlayerAtPosition("Tactical") then
					p.artifact_enabled_cm_message_tac = "artifact_enabled_cm_message_tac"
					p:addCustomMessage("Tactical",p.artifact_enabled_cm_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved has enabled combat maneuver"),full_desc))
				end
			else
				if p:hasPlayerAtPosition("Helms") then
					p.artifact_cm_message = "artifact_cm_message"
					p:addCustomMessage("Helms",p.artifact_cm_message,string.format(_("artifactEffect-msgHelms", "The %s retrieved does not effect combat maneuver"),full_desc))
				end
				if p:hasPlayerAtPosition("Tactical") then
					p.artifact_cm_message_tac = "artifact_cm_message_tac"
					p:addCustomMessage("Tactical",p.artifact_cm_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved does not effect combat maneuver"),full_desc))
				end
			end
		else
			if enabled then
				p:setCanCombatManeuver(false)
				if p:hasPlayerAtPosition("Helms") then
					p.artifact_disabled_cm_message = "artifact_disabled_cm_message"
					p:addCustomMessage("Helms",p.artifact_disabled_cm_message,string.format(_("artifactEffect-msgHelms", "The %s retrieved has disabled combat maneuver"),full_desc))
				end
				if p:hasPlayerAtPosition("Tactical") then
					p.artifact_disabled_cm_message_tac = "artifact_disabled_cm_message_tac"
					p:addCustomMessage("Tactical",p.artifact_disabled_cm_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved has disabled combat maneuver"),full_desc))
				end
			else
				if p:hasPlayerAtPosition("Helms") then
					p.artifact_cm_message = "artifact_cm_message"
					p:addCustomMessage("Helms",p.artifact_cm_message,string.format(_("artifactEffect-msgHelms", "The %s retrieved does not effect combat maneuver"),full_desc))
				end
				if p:hasPlayerAtPosition("Tactical") then
					p.artifact_cm_message_tac = "artifact_cm_message_tac"
					p:addCustomMessage("Tactical",p.artifact_cm_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved does not effect combat maneuver"),full_desc))
				end
			end
		end
	end)
	return wma
end
function wreckModBoolProbe(x,y)
	local full_desc = wreck_mod_type[11].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[11].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		local enabled = p:getCanLaunchProbe()
		local scan_bonus = 0
		if self:isScannedByFaction(p:getFaction()) then
			scan_bonus = difficulty * 5
		end
		if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
			if not enabled then
				p:setCanLaunchProbe(true)
				if p:hasPlayerAtPosition("Relay") then
					p.artifact_enabled_probe_message = "artifact_enabled_probe_message"
					p:addCustomMessage("Relay",p.artifact_enabled_probe_message,string.format(_("artifactEffect-msgRelay", "The %s retrieved has enabled probe launch"),full_desc))
				end
				if p:hasPlayerAtPosition("Operations") then
					p.artifact_enabled_probe_message_ops = "artifact_enabled_probe_message_ops"
					p:addCustomMessage("Operations",p.artifact_enabled_probe_message_ops,string.format(_("artifactEffect-msgOperations", "The %s retrieved has enabled probe launch"),full_desc))
				end
			else
				if p:hasPlayerAtPosition("Relay") then
					p.artifact_probe_message = "artifact_probe_message"
					p:addCustomMessage("Relay",p.artifact_probe_message,string.format(_("artifactEffect-msgRelay", "The %s retrieved does not effect probe launch"),full_desc))
				end
				if p:hasPlayerAtPosition("Operations") then
					p.artifact_probe_message_ops = "artifact_probe_message_ops"
					p:addCustomMessage("Operations",p.artifact_probe_message_ops,string.format(_("artifactEffect-msgOperations", "The %s retrieved does not effect probe launch"),full_desc))
				end
			end
		else
			if enabled then
				p:setCanLaunchProbe(false)
				if p:hasPlayerAtPosition("Relay") then
					p.artifact_disabled_probe_message = "artifact_disabled_probe_message"
					p:addCustomMessage("Relay",p.artifact_disabled_probe_message,string.format(_("artifactEffect-msgRelay", "The %s retrieved has disabled probe launch"),full_desc))
				end
				if p:hasPlayerAtPosition("Operations") then
					p.artifact_disabled_probe_message_ops = "artifact_disabled_probe_message_ops"
					p:addCustomMessage("Operations",p.artifact_disabled_probe_message_ops,string.format(_("artifactEffect-msgOperations", "The %s retrieved has disabled probe launch"),full_desc))
				end
			else
				if p:hasPlayerAtPosition("Relay") then
					p.artifact_probe_message = "artifact_probe_message"
					p:addCustomMessage("Relay",p.artifact_probe_message,string.format(_("artifactEffect-msgRelay", "The %s retrieved does not effect probe launch"),full_desc))
				end
				if p:hasPlayerAtPosition("Operations") then
					p.artifact_probe_message_ops = "artifact_probe_message_ops"
					p:addCustomMessage("Operations",p.artifact_probe_message_ops,string.format(_("artifactEffect-msgOperations", "The %s retrieved does not effect probe launch"),full_desc))
				end
			end
		end
	end)
	return wma
end
function wreckModBoolHack(x,y)
	local full_desc = wreck_mod_type[12].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[12].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		local enabled = p:getCanHack()
		local scan_bonus = 0
		if self:isScannedByFaction(p:getFaction()) then
			scan_bonus = difficulty * 5
		end
		if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
			if not enabled then
				p:setCanHack(true)
				if p:hasPlayerAtPosition("Relay") then
					p.artifact_enabled_hack_message = "artifact_enabled_hack_message"
					p:addCustomMessage("Relay",p.artifact_enabled_hack_message,string.format(_("artifactEffect-msgRelay", "The %s retrieved has enabled hacking"),full_desc))
				end
				if p:hasPlayerAtPosition("Operations") then
					p.artifact_enabled_hack_message_ops = "artifact_enabled_hack_message_ops"
					p:addCustomMessage("Operations",p.artifact_enabled_hack_message_ops,string.format(_("artifactEffect-msgOperations", "The %s retrieved has enabled hacking"),full_desc))
				end
			else
				if p:hasPlayerAtPosition("Relay") then
					p.artifact_hack_message = "artifact_hack_message"
					p:addCustomMessage("Relay",p.artifact_hack_message,string.format(_("artifactEffect-msgRelay", "The %s retrieved does not effect hacking"),full_desc))
				end
				if p:hasPlayerAtPosition("Operations") then
					p.artifact_hack_message_ops = "artifact_hack_message_ops"
					p:addCustomMessage("Operations",p.artifact_hack_message_ops,string.format(_("artifactEffect-msgOperations", "The %s retrieved does not effect hacking"),full_desc))
				end
			end
		else
			if enabled then
				p:setCanHack(false)
				if p:hasPlayerAtPosition("Relay") then
					p.artifact_disabled_hack_message = "artifact_disabled_hack_message"
					p:addCustomMessage("Relay",p.artifact_disabled_hack_message,string.format(_("artifactEffect-msgRelay", "The %s retrieved has disabled hacking"),full_desc))
				end
				if p:hasPlayerAtPosition("Operations") then
					p.artifact_disabled_hack_message_ops = "artifact_disabled_hack_message_ops"
					p:addCustomMessage("Operations",p.artifact_disabled_hack_message_ops,string.format(_("artifactEffect-msgOperations", "The %s retrieved has disabled hacking"),full_desc))
				end
			else
				if p:hasPlayerAtPosition("Relay") then
					p.artifact_hack_message = "artifact_hack_message"
					p:addCustomMessage("Relay",p.artifact_hack_message,string.format(_("artifactEffect-msgRelay", "The %s retrieved does not effect hacking"),full_desc))
				end
				if p:hasPlayerAtPosition("Operations") then
					p.artifact_hack_message_ops = "artifact_hack_message_ops"
					p:addCustomMessage("Operations",p.artifact_hack_message_ops,string.format(_("artifactEffect-msgOperations", "The %s retrieved does not effect hacking"),full_desc))
				end
			end
		end
	end)
	return wma
end
function wreckModChangeScan(x,y)
	local full_desc = wreck_mod_type[13].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[13].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		local current_range = p:getLongRangeRadarRange()
		local scan_bonus = 0
		if self:isScannedByFaction(p:getFaction()) then
			scan_bonus = difficulty * 5
		end
		if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
			p:setLongRangeRadarRange(current_range*1.1)
			if p:hasPlayerAtPosition("Science") then
				p.artifact_increase_sensor_range_message = "artifact_increase_sensor_range_message"
				p:addCustomMessage("Science",p.artifact_increase_sensor_range_message,string.format(_("artifactEffect-msgScience", "The %s retrieved has increased our sensor range"),full_desc))
			end
			if p:hasPlayerAtPosition("Operations") then
				p.artifact_increase_sensor_range_message_ops = "artifact_increase_sensor_range_message_ops"
				p:addCustomMessage("Operations",p.artifact_increase_sensor_range_message_ops,string.format(_("artifactEffect-msgOperations", "The %s retrieved has increased our sensor range"),full_desc))
			end
		else
			p:setLongRangeRadarRange(current_range*.9)
			if p:hasPlayerAtPosition("Science") then
				p.artifact_decrease_sensor_range_message = "artifact_decrease_sensor_range_message"
				p:addCustomMessage("Science",p.artifact_decrease_sensor_range_message,string.format(_("artifactEffect-msgScience", "The %s retrieved has decreased our sensor range"),full_desc))
			end
			if p:hasPlayerAtPosition("Operations") then
				p.artifact_decrease_sensor_range_message_ops = "artifact_decrease_sensor_range_message_ops"
				p:addCustomMessage("Operations",p.artifact_decrease_sensor_range_message_ops,string.format(_("artifactEffect-msgOperations", "The %s retrieved has decreased our sensor range"),full_desc))
			end
		end
	end)
	return wma
end
function wreckModChangeCoolant(x,y)
	local full_desc = wreck_mod_type[14].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[14].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		local current_coolant = p:getMaxCoolant()
		local scan_bonus = 0
		if self:isScannedByFaction(p:getFaction()) then
			scan_bonus = difficulty * 5
		end
		if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
			p:setMaxCoolant(current_coolant*1.1)
			if p:hasPlayerAtPosition("Engineering") then
				p.artifact_increase_coolant_message = "artifact_increase_coolant_message"
				p:addCustomMessage("Engineering",p.artifact_increase_coolant_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has increased our coolant"),full_desc))
			end
			if p:hasPlayerAtPosition("Engineering+") then
				p.artifact_increase_coolant_message_plus = "artifact_increase_coolant_message_plus"
				p:addCustomMessage("Engineering+",p.artifact_increase_coolant_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has increased our coolant"),full_desc))
			end
			if p:hasPlayerAtPosition("DamageControl") then
				p.artifact_increase_coolant_message_dmg = "artifact_increase_coolant_message_dmg"
				p:addCustomMessage("DamageControl",p.artifact_increase_coolant_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has increased our coolant"),full_desc))
			end
		else
			p:setMaxCoolant(current_coolant*.9)
			if p:hasPlayerAtPosition("Engineering") then
				p.artifact_decrease_coolant_message = "artifact_decrease_coolant_message"
				p:addCustomMessage("Engineering",p.artifact_decrease_coolant_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has decreased our coolant: incompatible, corrosive reaction"),full_desc))
			end
			if p:hasPlayerAtPosition("Engineering+") then
				p.artifact_decrease_coolant_message_plus = "artifact_decrease_coolant_message_plus"
				p:addCustomMessage("Engineering+",p.artifact_decrease_coolant_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has decreased our coolant: incompatible, corrosive reaction"),full_desc))
			end
			if p:hasPlayerAtPosition("DamageControl") then
				p.artifact_decrease_coolant_message_dmg = "artifact_decrease_coolant_message_dmg"
				p:addCustomMessage("DamageControl",p.artifact_decrease_coolant_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has decreased our coolant: incompatible, corrosive reaction"),full_desc))
			end
		end
	end)
	return wma
end
function wreckModChangeRepair(x,y)
	local full_desc = wreck_mod_type[15].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[15].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		local current_repair_crew_count = p:getRepairCrewCount()
		local scan_bonus = 0
		if self:isScannedByFaction(p:getFaction()) then
			scan_bonus = difficulty * 5
		end
		if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
			p:setRepairCrewCount(current_repair_crew_count + 1)
			if p:hasPlayerAtPosition("Engineering") then
				p.artifact_increase_repair_crew_message = "artifact_increase_repair_crew_message"
				p:addCustomMessage("Engineering",p.artifact_increase_repair_crew_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has increased the number of repair crew"),full_desc))
			end
			if p:hasPlayerAtPosition("Engineering+") then
				p.artifact_increase_repair_crew_message_plus = "artifact_increase_repair_crew_message_plus"
				p:addCustomMessage("Engineering+",p.artifact_increase_repair_crew_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has increased the number of repair crew"),full_desc))
			end
			if p:hasPlayerAtPosition("DamageControl") then
				p.artifact_increase_repair_crew_message_dmg = "artifact_increase_repair_crew_message_dmg"
				p:addCustomMessage("DamageControl",p.artifact_increase_repair_crew_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has increased the number of repair crew"),full_desc))
			end
		else
			if current_repair_crew_count > 0 then
				p:setRepairCrewCount(current_repair_crew_count - 1)
				if p:hasPlayerAtPosition("Engineering") then
					p.artifact_decrease_repair_crew_message = "artifact_decrease_repair_crew_message"
					p:addCustomMessage("Engineering",p.artifact_decrease_repair_crew_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has decreased the number of repair crew: assassination malware"),full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.artifact_decrease_repair_crew_message_plus = "artifact_decrease_repair_crew_message_plus"
					p:addCustomMessage("Engineering+",p.artifact_decrease_repair_crew_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has decreased the number of repair crew: assassination malware"),full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.artifact_decrease_repair_crew_message_dmg = "artifact_decrease_repair_crew_message_dmg"
					p:addCustomMessage("DamageControl",p.artifact_decrease_repair_crew_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has decreased the number of repair crew: assassination malware"),full_desc))
				end
			else
				if p:hasPlayerAtPosition("Engineering") then
					p.artifact_repair_crew_message = "artifact_repair_crew_message"
					p:addCustomMessage("Engineering",p.artifact_repair_crew_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has had no effect on the number of repair crew: malfunction"),full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.artifact_repair_crew_message_plus = "artifact_repair_crew_message_plus"
					p:addCustomMessage("Engineering+",p.artifact_repair_crew_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has had no effect on the number of repair crew: malfunction"),full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.artifact_repair_crew_message_dmg = "artifact_repair_crew_message_dmg"
					p:addCustomMessage("DamageControl",p.artifact_repair_crew_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has had no effect on the number of repair crew: malfunction"),full_desc))
				end
			end
		end
	end)
	return wma
end
function wreckModChangeHull(x,y)
	local full_desc = wreck_mod_type[16].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[16].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		local current_hull = p:getHull()
		local scan_bonus = 0
		if self:isScannedByFaction(p:getFaction()) then
			scan_bonus = difficulty * 5
		end
		if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
			p:setHull(current_hull*1.1)
			if p:hasPlayerAtPosition("Engineering") then
				p.artifact_increase_hull_message = "artifact_increase_hull_message"
				p:addCustomMessage("Engineering",p.artifact_increase_hull_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has repaired some hull damage"),full_desc))
			end
			if p:hasPlayerAtPosition("Engineering+") then
				p.artifact_increase_hull_message_plus = "artifact_increase_hull_message_plus"
				p:addCustomMessage("Engineering+",p.artifact_increase_hull_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has repaired some hull damage"),full_desc))
			end
			if p:hasPlayerAtPosition("DamageControl") then
				p.artifact_increase_hull_message_dmg = "artifact_increase_hull_message_dmg"
				p:addCustomMessage("DamageControl+",p.artifact_increase_hull_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has repaired some hull damage"),full_desc))
			end
		else
			p:setHull(current_hull*.9)
			if p:hasPlayerAtPosition("Engineering") then
				p.artifact_decrease_hull_message = "artifact_decrease_hull_message"
				p:addCustomMessage("Engineering",p.artifact_decrease_hull_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has damaged the hull: poor integration"),full_desc))
			end
			if p:hasPlayerAtPosition("Engineering+") then
				p.artifact_decrease_hull_message_plus = "artifact_decrease_hull_message_plus"
				p:addCustomMessage("Engineering+",p.artifact_decrease_hull_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has damaged the hull: poor integration"),full_desc))
			end
			if p:hasPlayerAtPosition("DamageControl") then
				p.artifact_decrease_hull_message_dmg = "artifact_decrease_hull_message_dmg"
				p:addCustomMessage("DamageControl",p.artifact_decrease_hull_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has damaged the hull: poor integration"),full_desc))
			end
		end
	end)
	return wma
end
function wreckModChangeShield(x,y)
	local full_desc = wreck_mod_type[17].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[17].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		local scan_bonus = 0
		if self:isScannedByFaction(p:getFaction()) then
			scan_bonus = difficulty * 5
		end
		if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
			if p:getShieldCount() > 1 then
				p:setShields(p:getShieldLevel(0)*1.1,p:getShieldLevel(1)*1.1)
			else
				p:setShields(p:getShieldLevel(0)*1.1)
			end
			if p:hasPlayerAtPosition("Engineering") then
				p.artifact_increase_shield_message = "artifact_increase_shield_message"
				p:addCustomMessage("Engineering",p.artifact_increase_shield_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has added charge to the shields"),full_desc))
			end
			if p:hasPlayerAtPosition("Engineering+") then
				p.artifact_increase_shield_message_plus = "artifact_increase_shield_message_plus"
				p:addCustomMessage("Engineering+",p.artifact_increase_shield_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has added charge to the shields"),full_desc))
			end
			if p:hasPlayerAtPosition("DamageControl") then
				p.artifact_increase_shield_message_dmg = "artifact_increase_shield_message_dmg"
				p:addCustomMessage("DamageControl",p.artifact_increase_shield_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has added charge to the shields"),full_desc))
			end
		else
			if p:getShieldCount() > 1 then
				p:setShields(p:getShieldLevel(0)*.9,p:getShieldLevel(1)*.9)
			else
				p:setShields(p:getShieldLevel(0)*.9)
			end
			if p:hasPlayerAtPosition("Engineering") then
				p.artifact_decrease_shield_message = "artifact_decrease_shield_message"
				p:addCustomMessage("Engineering",p.artifact_decrease_shield_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has reduced shield charge: corroded couplings"),full_desc))
			end
			if p:hasPlayerAtPosition("Engineering+") then
				p.artifact_decrease_shield_message_plus = "artifact_decrease_shield_message_plus"
				p:addCustomMessage("Engineering+",p.artifact_decrease_shield_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has reduced shield charge: corroded couplings"),full_desc))
			end
			if p:hasPlayerAtPosition("DamageControl") then
				p.artifact_decrease_shield_message_dmg = "artifact_decrease_shield_message_dmg"
				p:addCustomMessage("DamageControl",p.artifact_decrease_shield_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has reduced shield charge: corroded couplings"),full_desc))
			end
		end
	end)
	return wma
end
function wreckModChangePower(x,y)
	local full_desc = wreck_mod_type[18].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[18].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		local current_energy = p:getEnergy()
		local scan_bonus = 0
		if self:isScannedByFaction(p:getFaction()) then
			scan_bonus = difficulty * 5
		end
		if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
			p:setEnergy(current_energy + p:getMaxEnergy()*.1)
			if p:hasPlayerAtPosition("Engineering") then
				p.artifact_increase_energy_message = "artifact_increase_energy_message"
				p:addCustomMessage("Engineering",p.artifact_increase_energy_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has added energy to our reserves"),full_desc))
			end
			if p:hasPlayerAtPosition("Engineering+") then
				p.artifact_increase_energy_message_plus = "artifact_increase_energy_message_plus"
				p:addCustomMessage("Engineering+",p.artifact_increase_energy_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has added energy to our reserves"),full_desc))
			end
			if p:hasPlayerAtPosition("DamageControl") then
				p.artifact_increase_energy_message_dmg = "artifact_increase_energy_message_dmg"
				p:addCustomMessage("DamageControl",p.artifact_increase_energy_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has added energy to our reserves"),full_desc))
			end
		else
			p:setEnergy(current_energy - p:getMaxEnergy()*.1)
			if p:hasPlayerAtPosition("Engineering") then
				p.artifact_decrease_energy_message = "artifact_decrease_energy_message"
				p:addCustomMessage("Engineering",p.artifact_decrease_energy_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved has drained some energy: incompatibility"),full_desc))
			end
			if p:hasPlayerAtPosition("Engineering+") then
				p.artifact_decrease_energy_message_plus = "artifact_decrease_energy_message_plus"
				p:addCustomMessage("Engineering+",p.artifact_decrease_energy_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved has drained some energy: incompatibility"),full_desc))
			end
			if p:hasPlayerAtPosition("DamageControl") then
				p.artifact_decrease_energy_message_dmg = "artifact_decrease_energy_message_dmg"
				p:addCustomMessage("DamageControl",p.artifact_decrease_energy_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved has drained some energy: incompatibility"),full_desc))
			end
		end
	end)
	return wma
end
function wmCombatBoostButton(p,console)
	if console == "Helms" then
		if p:hasPlayerAtPosition("Helms") then
			if p.activate_cm_boost_button == nil then
				p.activate_cm_boost_button = "activate_cm_boost_button"
				p:addCustomButton("Helms",p.activate_cm_boost_button,_("upgrade-buttonHelms", "C.M. Boost"),function()
					string.format("")	--global context for serious proton
					if p.cm_boost_count > 0 then
						p.cm_boost_active = true
						p:setCombatManeuver(playerShipStats[p:getTypeName()].cm_boost + 200,playerShipStats[p:getTypeName()].cm_strafe)
						p.cm_boost_timer = 300
						p.cm_boost_count = p.cm_boost_count - 1
						p.cm_boost_activated_message = "cm_boost_activated_message"
						p:addCustomMessage("Helms",p.cm_boost_activated_message,_("upgrade-msgHelms", "Combat maneuver boost (forward direction) ability increased"))
					end
					p:removeCustom(p.activate_cm_boost_button)
					p.activate_cm_boost_button = nil
					if p.activate_cm_boost_button_tac ~= nil then
						p:removeCustom(p.activate_cm_boost_button_tac)
						p.activate_cm_boost_button_tac = nil
					end
				end)
			end
		end
	elseif console == "Tactical" then
		if p:hasPlayerAtPosition("Tactical") then
			if p.activate_cm_boost_button_tac == nil then
				p.activate_cm_boost_button_tac = "activate_cm_boost_button_tac"
				p:addCustomButton("Tactical",p.activate_cm_boost_button_tac,_("upgrade-buttonTactical", "C.M. Boost"),function()
					string.format("")	--global context for serious proton
					if p.cm_boost_count > 0 then
						p.cm_boost_active = true
						p:setCombatManeuver(playerShipStats[p:getTypeName()].cm_boost + 200,playerShipStats[p:getTypeName()].cm_strafe)
						p.cm_boost_timer = 300
						p.cm_boost_count = p.cm_boost_count - 1
						p.cm_boost_activated_message_tac = "cm_boost_activated_message_tac"
						p:addCustomMessage("Tactical",p.cm_boost_activated_message_tac,_("upgrade-msgTactical", "Combat maneuver boost (forward direction) ability increased"))
					end
					p:removeCustom(p.activate_cm_boost_button_tac)
					p.activate_cm_boost_button_tac = nil
					if p.activate_cm_boost_button ~= nil then
						p:removeCustom(p.activate_cm_boost_button)
						p.activate_cm_boost_button = nil
					end
				end)
			end
		end
	end
end
function wmCombatStrafeButton(p,console)
	if console == "Helms" then
		if p:hasPlayerAtPosition("Helms") then
			if p.activate_cm_strafe_button == nil then
				p.activate_cm_strafe_button = "activate_cm_strafe_button"
				p:addCustomButton("Helms",p.activate_cm_strafe_button,_("upgrade-buttonHelms", "C.M. Strafe"),function()
					string.format("")	--global context for serious proton
					if p.cm_strafe_count > 0 then
						p.cm_strafe_active = true
						p:setCombatManeuver(playerShipStats[p:getTypeName()].cm_boost,playerShipStats[p:getTypeName()].cm_strafe + 200)
						p.cm_strafe_timer = 300
						p.cm_strafe_count = p.cm_strafe_count - 1
						p.cm_strafe_activated_message = "cm_strafe_activated_message"
						p:addCustomMessage("Helms",p.cm_strafe_activated_message,_("upgrade-msgHelms", "Combat maneuver strafe (sideways direction) ability increased"))
					end
					p:removeCustom(p.activate_cm_strafe_button)
					p.activate_cm_strafe_button = nil
					if p.activate_cm_strafe_button_tac ~= nil then
						p:removeCustom(p.activate_cm_strafe_button_tac)
						p.activate_cm_strafe_button_tac = nil
					end
				end)
			end
		end
	elseif console == "Tactical" then
		if p:hasPlayerAtPosition("Tactical") then
			if p.activate_cm_strafe_button_tac == nil then
				p.activate_cm_strafe_button_tac = "activate_cm_strafe_button_tac"
				p:addCustomButton("Tactical",p.activate_cm_strafe_button_tac,_("upgrade-buttonTactical", "C.M. Strafe"),function()
					string.format("")	--global context for serious proton
					if p.cm_strafe_count > 0 then
						p.cm_strafe_active = true
						p:setCombatManeuver(playerShipStats[p:getTypeName()].cm_boost,playerShipStats[p:getTypeName()].cm_strafe + 200)
						p.cm_strafe_timer = 300
						p.cm_strafe_count = p.cm_strafe_count - 1
						p.cm_strafe_activated_message_tac = "cm_strafe_activated_message_tac"
						p:addCustomMessage("Tactical",p.cm_strafe_activated_message_tac,_("upgrade-msgTactical", "Combat maneuver strafe (sideways direction) ability increased"))
					end
					p:removeCustom(p.activate_cm_strafe_button_tac)
					p.activate_cm_strafe_button_tac = nil
					if p.activate_cm_strafe_button ~= nil then
						p:removeCustom(p.activate_cm_strafe_button)
						p.activate_cm_strafe_button = nil
					end
				end)
			end
		end
	end
end
function wmBeamDamageButton(p,console)
	if console == "Weapons" then
		if p:hasPlayerAtPosition("Weapons") then
			if p.activate_beam_damage_button == nil then
				p.activate_beam_damage_button = "activate_beam_damage_button"
				p:addCustomButton("Weapons",p.activate_beam_damage_button,_("upgrade-buttonWeapons", "Beam Damage"),function()
					string.format("")	--global context for serious proton
					if p.beam_damage_count > 0 then
						p.beam_damage_active = true
						local bi = 0
						repeat
							p:setBeamWeapon(bi,p:getBeamWeaponArc(bi),p:getBeamWeaponDirection(bi),p:getBeamWeaponRange(bi),p:getBeamWeaponCycleTime(bi),p:getBeamWeaponDamage(bi)*1.1)
							bi = bi + 1
						until(p:getBeamWeaponRange(bi) < 1)
						p.beam_damage_timer = 300
						p.beam_damage_count = p.beam_damage_count - 1
						p.beam_damage_activated_message = "beam_damage_activated_message"
						p:addCustomMessage("Weapons",p.beam_damage_activated_message,_("upgrade-msgWeapons", "Damage applied by beam weapons increased"))
					end
					p:removeCustom(p.activate_beam_damage_button)
					p.activate_beam_damage_button = nil
					if p.activate_beam_damage_button_tac ~= nil then
						p:removeCustom(p.activate_beam_damage_button_tac)
						p.activate_beam_damage_button_tac = nil
					end
				end)
			end
		end
	elseif console == "Tactical" then
		if p:hasPlayerAtPosition("Tactical") then
			if p.activate_beam_damage_button_tac == nil then
				p.activate_beam_damage_button_tac = "activate_beam_damage_button_tac"
				p:addCustomButton("Tactical",p.activate_beam_damage_button_tac,_("upgrade-buttonTactical", "Beam Damage"),function()
					string.format("")	--global context for serious proton
					if p.beam_damage_count > 0 then
						p.beam_damage_active = true
						local bi = 0
						repeat
							p:setBeamWeapon(bi,p:getBeamWeaponArc(bi),p:getBeamWeaponDirection(bi),p:getBeamWeaponRange(bi),p:getBeamWeaponCycleTime(bi),p:getBeamWeaponDamage(bi)*1.1)
							bi = bi + 1
						until(p:getBeamWeaponRange(bi) < 1)
						p.beam_damage_timer = 300
						p.beam_damage_count = p.beam_damage_count - 1
						p.beam_damage_activated_message_tac = "beam_damage_activated_message_tac"
						p:addCustomMessage("Tactical",p.beam_damage_activated_message_tac,_("upgrade-msgTactical", "Damage applied by beam weapons increased"))
					end
					p:removeCustom(p.activate_beam_damage_button_tac)
					p.activate_beam_damage_button_tac = nil
					if p.activate_beam_damage_button ~= nil then
						p:removeCustom(p.activate_beam_damage_button)
						p.activate_beam_damage_button = nil
					end
				end)
			end
		end
	end
end
function wmBeamCycleButton(p,console)
	if console == "Weapons" then
		if p:hasPlayerAtPosition("Weapons") then
			if p.activate_beam_cycle_button == nil then
				p.activate_beam_cycle_button = "activate_beam_cycle_button"
				p:addCustomButton("Weapons",p.activate_beam_cycle_button,_("upgrade-buttonWeapons", "Beam Cycle"),function()
					string.format("")	--global context for serious proton
					if p.beam_cycle_count > 0 then
						p.beam_cycle_active = true
						local bi = 0
						repeat
							p:setBeamWeapon(bi,p:getBeamWeaponArc(bi),p:getBeamWeaponDirection(bi),p:getBeamWeaponRange(bi),p:getBeamWeaponCycleTime(bi)*.9,p:getBeamWeaponDamage(bi))
							bi = bi + 1
						until(p:getBeamWeaponRange(bi) < 1)
						p.beam_cycle_timer = 300
						p.beam_cycle_count = p.beam_cycle_count - 1
						p.beam_cycle_activated_message = "beam_cycle_activated_message"
						p:addCustomMessage("Weapons",p.beam_cycle_activated_message,_("upgrade-msgWeapons", "The time it takes to cycle the beams between firing has been reduced"))
					end
					p:removeCustom(p.activate_beam_cycle_button)
					p.activate_beam_cycle_button = nil
					if p.activate_beam_cycle_button_tac ~= nil then
						p:removeCustom(p.activate_beam_cycle_button_tac)
						p.activate_beam_cycle_button_tac = nil
					end
				end)
			end
		end
	elseif console == "Tactical" then
		if p:hasPlayerAtPosition("Tactical") then
			if p.activate_beam_cycle_button_tac == nil then
				p.activate_beam_cycle_button_tac = "activate_beam_cycle_button_tac"
				p:addCustomButton("Tactical",p.activate_beam_cycle_button_tac,_("upgrade-buttonTactical", "Beam Cycle"),function()
					string.format("")	--global context for serious proton
					if p.beam_cycle_count > 0 then
						p.beam_cycle_active = true
						local bi = 0
						repeat
							p:setBeamWeapon(bi,p:getBeamWeaponArc(bi),p:getBeamWeaponDirection(bi),p:getBeamWeaponRange(bi),p:getBeamWeaponCycleTime(bi)*.9,p:getBeamWeaponDamage(bi))
							bi = bi + 1
						until(p:getBeamWeaponRange(bi) < 1)
						p.beam_cycle_timer = 300
						p.beam_cycle_count = p.beam_cycle_count - 1
						p.beam_cycle_activated_message_tac = "beam_cycle_activated_message_tac"
						p:addCustomMessage("Tactical",p.beam_cycle_activated_message_tac,_("upgrade-msgTactical", "The time it takes to cycle the beams between firing has been reduced"))
					end
					p:removeCustom(p.activate_beam_cycle_button_tac)
					p.activate_beam_cycle_button_tac = nil
					if p.activate_beam_cycle_button ~= nil then
						p:removeCustom(p.activate_beam_cycle_button)
						p.activate_beam_cycle_button = nil
					end
				end)
			end
		end
	end
end
function wmImpulseButton(p,console)
	if console == "Helms" then
		if p:hasPlayerAtPosition("Helms") then
			if p.activate_impulse_button == nil then
				p.activate_impulse_button = "activate_impulse_button"
				p:addCustomButton("Helms",p.activate_impulse_button,_("upgrade-buttonHelms", "Impulse Speed"),function()
					string.format("")	--global context for serious proton
					if p.impulse_count > 0 then
						p.impulse_active = true
						p:setImpulseMaxSpeed(p:getImpulseMaxSpeed()*1.1)
						p.impulse_timer = 300
						p.impulse_count = p.impulse_count - 1
						p.impulse_activated_message = "impulse_activated_message"
						p:addCustomMessage("Helms",p.impulse_activated_message,_("upgrade-msgHelms", "The maximum impulse speed has been increased"))
					end
					p:removeCustom(p.activate_impulse_button)
					p.activate_impulse_button = nil
					if p.activate_impulse_button_tac ~= nil then
						p:removeCustom(p.activate_impulse_button_tac)
						p.activate_impulse_button_tac = nil
					end
				end)
			end
		end
	elseif console == "Tactical" then
		if p:hasPlayerAtPosition("Tactical") then
			if p.activate_impulse_button_tac == nil then
				p.activate_impulse_button_tac = "activate_impulse_button_tac"
				p:addCustomButton("Tactical",p.activate_impulse_button_tac,_("upgrade-buttonTactical", "Impulse Speed"),function()
					string.format("")	--global context for serious proton
					if p.impulse_count > 0 then
						p.impulse_active = true
						p:setImpulseMaxSpeed(p:getImpulseMaxSpeed()*1.1)
						p.impulse_timer = 300
						p.impulse_count = p.impulse_count - 1
						p.impulse_activated_message_tac = "impulse_activated_message_tac"
						p:addCustomMessage("Tactical",p.impulse_activated_message_tac,_("upgrade-msgTactical", "The maximum impulse speed has been increased"))
					end
					p:removeCustom(p.activate_impulse_button_tac)
					p.activate_impulse_button_tac = nil
					if p.activate_impulse_button ~= nil then
						p:removeCustom(p.activate_impulse_button)
						p.activate_impulse_button = nil
					end
				end)
			end
		end
	end
end
function wmWarpButton(p,console)
	if console == "Helms" then
		if p:hasPlayerAtPosition("Helms") then
			if p.activate_warp_button == nil then
				p.activate_warp_button = "activate_warp_button"
				p:addCustomButton("Helms",p.activate_warp_button,_("upgrade-buttonHelms", "Warp Speed"),function()
					string.format("")	--global context for serious proton
					if p.warp_count > 0 then
						p.warp_active = true
						p:setWarpSpeed(p:getWarpSpeed()*1.1)
						p.warp_timer = 300
						p.warp_count = p.warp_count - 1
						p.warp_activated_message = "warp_activated_message"
						p:addCustomMessage("Helms",p.warp_activated_message,_("upgrade-msgHelms", "The maximum warp speed has been increased"))
					end
					p:removeCustom(p.activate_warp_button)
					p.activate_warp_button = nil
					if p.activate_warp_button_tac ~= nil then
						p:removeCustom(p.activate_warp_button_tac)
						p.activate_warp_button_tac = nil
					end
				end)
			end
		end
	elseif console == "Tactical" then
		if p:hasPlayerAtPosition("Tactical") then
			if p.activate_warp_button_tac == nil then
				p.activate_warp_button_tac = "activate_warp_button_tac"
				p:addCustomButton("Tactical",p.activate_warp_button_tac,_("upgrade-buttonTactical", "Warp Speed"),function()
					string.format("")	--global context for serious proton
					if p.warp_count > 0 then
						p.warp_active = true
						p:setWarpSpeed(p:getWarpSpeed()*1.1)
						p.warp_timer = 300
						p.warp_count = p.warp_count - 1
						p.warp_activated_message_tac = "warp_activated_message_tac"
						p:addCustomMessage("Tactical",p.warp_activated_message_tac,_("upgrade-msgTactical", "The maximum warp speed has been increased"))
					end
					p:removeCustom(p.activate_warp_button_tac)
					p.activate_warp_button_tac = nil
					if p.activate_warp_button ~= nil then
						p:removeCustom(p.activate_warp_button)
						p.activate_warp_button = nil
					end
				end)
			end
		end
	end
end
function wmJumpButton(p,console)
	if console == "Helms" then
		if p:hasPlayerAtPosition("Helms") then
			if p.activate_jump_button == nil then
				p.activate_jump_button = "activate_jump_button"
				p:addCustomButton("Helms",p.activate_jump_button,_("upgrade-buttonHelms", "Jump Range"),function()
					string.format("")	--global context for serious proton
					if p.jump_count > 0 then
						p.jump_active = true
						if p.max_jump_range == nil then
							p.max_jump_range = 50000
							p.min_jump_range = 5000
						end
						p:setJumpDriveRange(p.min_jump_range,p.max_jump_range*1.1)
						p.max_jump_range = p.max_jump_range*1.1
						p.jump_timer = 300
						p.jump_count = p.jump_count - 1
						p.jump_activated_message = "jump_activated_message"
						p:addCustomMessage("Helms",p.jump_activated_message,_("upgrade-msgHelms", "The maximum jump range has been increased"))
					end
					p:removeCustom(p.activate_jump_button)
					p.activate_jump_button = nil
					if p.activate_jump_button_tac ~= nil then
						p:removeCustom(p.activate_jump_button_tac)
						p.activate_jump_button_tac = nil
					end
				end)
			end
		end
	elseif console == "Tactical" then
		if p:hasPlayerAtPosition("Tactical") then
			if p.activate_jump_button_tac == nil then
				p.activate_jump_button_tac = "activate_jump_button_tac"
				p:addCustomButton("Tactical",p.activate_jump_button_tac,_("upgrade-buttonTactical", "Jump Range"),function()
					string.format("")	--global context for serious proton
					if p.jump_count > 0 then
						p.jump_active = true
						if p.max_jump_range == nil then
							p.max_jump_range = 50000
							p.min_jump_range = 5000
						end
						p:setJumpDriveRange(p.min_jump_range,p.max_jump_range*1.1)
						p.max_jump_range = p.max_jump_range*1.1
						p.jump_timer = 300
						p.jump_count = p.jump_count - 1
						p.jump_activated_message_tac = "jump_activated_message_tac"
						p:addCustomMessage("Tactical",p.jump_activated_message_tac,_("upgrade-msgTactical", "The maximum jump range has been increased"))
					end
					p:removeCustom(p.activate_jump_button_tac)
					p.activate_jump_button_tac = nil
					if p.activate_jump_button ~= nil then
						p:removeCustom(p.activate_jump_button)
						p.activate_jump_button = nil
					end
				end)
			end
		end
	end
end
function wmShieldButton(p,console)
	if console == "Weapons" then
		if p:hasPlayerAtPosition("Weapons") then
			if p.activate_shield_button == nil then
				p.activate_shield_button = "activate_shield_button"
				p:addCustomButton("Weapons",p.activate_shield_button,_("upgrade-buttonWeapons", "Shield Capacity"),function()
					string.format("")	--global context for serious proton
					if p.shield_count > 0 then
						p.shield_active = true
						if p:getShieldCount() > 1 then
							p:setShieldsMax(p:getShieldMax(0)*1.1,p:getShieldMax(1)*1.1)
						else
							p:setShieldsMax(p:getShieldMax(0)*1.1)
						end
						p.shield_timer = 300
						p.shield_count = p.shield_count - 1
						p.shield_activated_message = "shield_activated_message"
						p:addCustomMessage("Weapons",p.shield_activated_message,_("upgrade-msgWeapons", "The maximum shield strength has been increased"))
					end
					p:removeCustom(p.activate_shield_button)
					p.activate_shield_button = nil
					if p.activate_shield_button_tac ~= nil then
						p:removeCustom(p.activate_shield_button_tac)
						p.activate_shield_button_tac = nil
					end
				end)
			end
		end
	elseif console == "Tactical" then
		if p:hasPlayerAtPosition("Tactical") then
			if p.activate_shield_button_tac == nil then
				p.activate_shield_button_tac = "activate_shield_button_tac"
				p:addCustomButton("Tactical",p.activate_shield_button_tac,_("upgrade-buttonTactical", "Shield Capacity"),function()
					string.format("")	--global context for serious proton
					if p.shield_count > 0 then
						p.shield_active = true
						if p:getShieldCount() > 1 then
							p:setShieldsMax(p:getShieldMax(0)*1.1,p:getShieldMax(1)*1.1)
						else
							p:setShieldsMax(p:getShieldMax(0)*1.1)
						end
						p.shield_timer = 300
						p.shield_count = p.shield_count - 1
						p.shield_activated_message_tac = "shield_activated_message_tac"
						p:addCustomMessage("Tactical",p.shield_activated_message_tac,_("upgrade-msgTactical", "The maximum shield strength has been increased"))
					end
					p:removeCustom(p.activate_shield_button_tac)
					p.activate_shield_button_tac = nil
					if p.activate_shield_button ~= nil then
						p:removeCustom(p.activate_shield_button)
						p.activate_shield_button = nil
					end
				end)
			end
		end
	end
end
function wmManeuverButton(p,console)
	if console == "Helms" then
		if p:hasPlayerAtPosition("Helms") then
			if p.activate_maneuver_button == nil then
				p.activate_maneuver_button = "activate_maneuver_button"
				p:addCustomButton("Helms",p.activate_maneuver_button,_("upgrade-buttonHelms", "Spin Speed"),function()
					string.format("")	--global context for serious proton
					if p.maneuver_count > 0 then
						p.maneuver_active = true
						p:setRotationMaxSpeed(p:getRotationMaxSpeed()*1.1)
						p.maneuver_timer = 300
						p.maneuver_count = p.maneuver_count - 1
						p.maneuver_activated_message = "maneuver_activated_message"
						p:addCustomMessage("Helms",p.maneuver_activated_message,_("upgrade-msgHelms", "The maximum spin speed has been increased"))
					end
					p:removeCustom(p.activate_maneuver_button)
					p.activate_maneuver_button = nil
					if p.activate_maneuver_button_tac ~= nil then
						p:removeCustom(p.activate_maneuver_button_tac)
						p.activate_maneuver_button_tac = nil
					end
				end)
			end
		end
	elseif console == "Tactical" then
		if p:hasPlayerAtPosition("Tactical") then
			if p.activate_maneuver_button_tac == nil then
				p.activate_maneuver_button_tac = "activate_maneuver_button_tac"
				p:addCustomButton("Tactical",p.activate_maneuver_button_tac,_("upgrade-buttonTactical", "Spin Speed"),function()
					string.format("")	--global context for serious proton
					if p.maneuver_count > 0 then
						p.maneuver_active = true
						p:setRotationMaxSpeed(p:getRotationMaxSpeed()*1.1)
						p.maneuver_timer = 300
						p.maneuver_count = p.maneuver_count - 1
						p.maneuver_activated_message_tac = "maneuver_activated_message_tac"
						p:addCustomMessage("Tactical",p.maneuver_activated_message_tac,_("upgrade-msgTactical", "The maximum spin speed has been increased"))
					end
					p:removeCustom(p.activate_maneuver_button_tac)
					p.activate_maneuver_button_tac = nil
					if p.activate_maneuver_button ~= nil then
						p:removeCustom(p.activate_maneuver_button)
						p.activate_maneuver_button = nil
					end
				end)
			end
		end
	end
end
function wmBatteryButton(p,console)
	if console == "Engineering" then
		if p:hasPlayerAtPosition("Engineering") then
			if p.activate_battery_button == nil then
				p.activate_battery_button = "activate_battery_button"
				p:addCustomButton("Engineering",p.activate_battery_button,_("upgrade-buttonEngineer", "Battery Capacity"),function()
					string.format("")	--global context for serious proton
					if p.battery_count > 0 then
						p.battery_active = true
						p:setMaxEnergy(p:getMaxEnergy()*1.1)
						p.battery_timer = 300
						p.battery_count = p.battery_count - 1
						p.battery_activated_message = "battery_activated_message"
						p:addCustomMessage("Engineering",p.battery_activated_message,_("upgrade-msgEngineer", "The maximum battery capacity has been increased"))
					end
					p:removeCustom(p.activate_battery_button)
					p.activate_battery_button = nil
					if p.activate_battery_button_plus ~= nil then
						p:removeCustom(p.activate_battery_button_plus)
						p.activate_battery_button_plus = nil
					end
				end)
			end
		end
	elseif console == "Engineering+" then
		if p:hasPlayerAtPosition("Engineering+") then
			if p.activate_battery_button_plus == nil then
				p.activate_battery_button_plus = "activate_battery_button_plus"
				p:addCustomButton("Engineering+",p.activate_battery_button_plus,_("upgrade-buttonEngineer+", "Battery Capacity"),function()
					string.format("")	--global context for serious proton
					if p.battery_count > 0 then
						p.battery_active = true
						p:setMaxEnergy(p:getMaxEnergy()*1.1)
						p.battery_timer = 300
						p.battery_count = p.battery_count - 1
						p.battery_activated_message_plus = "battery_activated_message_plus"
						p:addCustomMessage("Engineering+",p.battery_activated_message_plus,_("upgrade-msgEngineer+", "The maximum battery capacity has been increased"))
					end
					p:removeCustom(p.activate_battery_button_plus)
					p.activate_battery_button_plus = nil
					if p.activate_battery_button_plus ~= nil then
						p:removeCustom(p.activate_battery_button_plus)
						p.activate_battery_button_plus = nil
					end
				end)
			end
		end
	elseif console == "DamageControl" then
		if p:hasPlayerAtPosition("DamageControl") then
			if p.activate_battery_button_dmg == nil then
				p.activate_battery_button_dmg = "activate_battery_button_dmg"
				p:addCustomButton("DamageControl",p.activate_battery_button_dmg,_("upgrade-buttonDamageControl", "Battery Capacity"),function()
					string.format("")	--global context for serious proton
					if p.battery_count > 0 then
						p.battery_active = true
						p:setMaxEnergy(p:getMaxEnergy()*1.1)
						p.battery_timer = 300
						p.battery_count = p.battery_count - 1
						p.battery_activated_message_dmg = "battery_activated_message_dmg"
						p:addCustomMessage("DamageControl",p.battery_activated_message_dmg,_("upgrade-msgDamageControl", "The maximum battery capacity has been increased"))
					end
					p:removeCustom(p.activate_battery_button_dmg)
					p.activate_battery_button_dmg = nil
					if p.activate_battery_button ~= nil then
						p:removeCustom(p.activate_battery_button)
						p.activate_battery_button = nil
					end
				end)
			end
		end
	end
end
function resetCoolantPumpButtons(p)
	local system_types = {"reactor","beamweapons","missilesystem","maneuver","impulse","warp","jumpdrive","frontshield","rearshield"}
	for i, system in ipairs(system_types) do
		if p.coolant_pump_fix_buttons ~= nil then
			if p.coolant_pump_fix_buttons[system] ~= nil then
				p:removeCustom(p.coolant_pump_fix_buttons[system])
			end
		end
		if p.coolant_pump_fix_buttons_plus ~= nil then
			if p.coolant_pump_fix_buttons_plus[system] ~= nil then
				p:removeCustom(p.coolant_pump_fix_buttons_plus[system])
			end
		end
		if p.coolant_pump_fix_buttons_dmg ~= nil then
			if p.coolant_pump_fix_buttons_dmg[system] ~= nil then
				p:removeCustom(p.coolant_pump_fix_buttons_dmg[system])
			end
		end
		if p.normal_coolant_rate ~= nil then
			if p.normal_coolant_rate[system] < p:getSystemCoolantRate(system) then
				if p:hasPlayerAtPosition("Engineering") then
					p.coolant_pump_fix_buttons[system] = string.format("coolant_pump_fix_buttons%s",system)
					p:addCustomButton("Engineering",p.coolant_pump_fix_buttons[system],string.format(_("coolant-buttonEngineer", "%s C. Pump"),system),function()
						string.format("")	--global context for serious proton
						if p.coolant_pump_part_count > 0 then
							p:setSystemCoolantRate(system,p.normal_coolant_rate[system])
							p.coolant_pump_part_count = p.coolant_pump_part_count - 1
							p.coolant_pump_fixed_message = "coolant_pump_fixed_message"
							p:addCustomMessage("Engineering",p.coolant_pump_fixed_message,string.format(_("coolant-msgEngineer", "The %s coolant pump has been repaired"),system))
						end
						resetCoolantPumpButtons(p)
					end)
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.coolant_pump_fix_buttons_plus[system] = string.format("coolant_pump_fix_buttons_plus%s",system)
					p:addCustomButton("Engineering+",p.coolant_pump_fix_buttons_plus[system],string.format(_("coolant-buttonEngineer+", "%s C. Pump"),system),function()
						string.format("")	--global context for serious proton
						if p.coolant_pump_part_count > 0 then
							p:setSystemCoolantRate(system,p.normal_coolant_rate[system])
							p.coolant_pump_part_count = p.coolant_pump_part_count - 1
							p.coolant_pump_fixed_message_plus = "coolant_pump_fixed_message_plus"
							p:addCustomMessage("Engineering+",p.coolant_pump_fixed_message_plus,string.format(_("coolant-msgEngineer+", "The %s coolant pump has been repaired"),system))
						end
						resetCoolantPumpButtons(p)
					end)
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.coolant_pump_fix_buttons_dmg[system] = string.format("coolant_pump_fix_buttons_dmg%s",system)
					p:addCustomButton("DamageControl",p.coolant_pump_fix_buttons_dmg[system],string.format(_("coolant-buttonDamageControl", "%s C. Pump"),system),function()
						string.format("")	--global context for serious proton
						if p.coolant_pump_part_count > 0 then
							p:setSystemCoolantRate(system,p.normal_coolant_rate[system])
							p.coolant_pump_part_count = p.coolant_pump_part_count - 1
							p.coolant_pump_fixed_message_dmg = "coolant_pump_fixed_message_dmg"
							p:addCustomMessage("DamageControl",p.coolant_pump_fixed_message_dmg,string.format(_("coolant-msgDamageControl", "The %s coolant pump has been repaired"),system))
						end
						resetCoolantPumpButtons(p)
					end)
				end
			end
		end
	end
end
function wmCoolantPump(p,console,system)
	if console == "Engineering" then
		if p:hasPlayerAtPosition("Engineering") then
			if p.coolant_pump_fix_buttons[system] == nil then
				p.coolant_pump_fix_buttons[system] = string.format("coolant_pump_fix_buttons%s",system)
				p:addCustomButton("Engineering",p.coolant_pump_fix_buttons[system],string.format(_("coolant-buttonEngineer", "%s C. Pump"),system),function()
					string.format("")	--global context for serious proton
					if p.coolant_pump_part_count > 0 then
						p:setSystemCoolantRate(system,p.normal_coolant_rate[system])
						p.coolant_pump_part_count = p.coolant_pump_part_count - 1
						p.coolant_pump_fixed_message = "coolant_pump_fixed_message"
						p:addCustomMessage("Engineering",p.coolant_pump_fixed_message,string.format(_("coolant-msgEngineer", "The %s coolant pump has been repaired"),system))
					end
					resetCoolantPumpButtons(p)
				end)
			end
		end
	elseif console == "Engineering+" then
		if p:hasPlayerAtPosition("Engineering+") then
			if p.coolant_pump_fix_buttons_plus[system] == nil then
				p.coolant_pump_fix_buttons_plus[system] = string.format("coolant_pump_fix_buttons_plus%s",system)
				p:addCustomButton("Engineering+",p.coolant_pump_fix_buttons_plus[system],string.format(_("coolant-buttonEngineer+", "%s C. Pump"),system),function()
					string.format("")	--global context for serious proton
					if p.coolant_pump_part_count > 0 then
						p:setSystemCoolantRate(system,p.normal_coolant_rate[system])
						p.coolant_pump_part_count = p.coolant_pump_part_count - 1
						p.coolant_pump_fixed_message_plus = "coolant_pump_fixed_message_plus"
						p:addCustomMessage("Engineering+",p.coolant_pump_fixed_message_plus,string.format(_("coolant-msgEngineer+", "The %s coolant pump has been repaired"),system))
					end
					resetCoolantPumpButtons(p)
				end)
			end
		end
	elseif console == "DamageControl" then
		if p:hasPlayerAtPosition("DamageControl") then
			if p.coolant_pump_fix_buttons_dmg[system] == nil then
				p.coolant_pump_fix_buttons_dmg[system] = string.format("coolant_pump_fix_buttons_dmg%s",system)
				p:addCustomButton("DamageControl",p.coolant_pump_fix_buttons_dmg[system],string.format(_("coolant-buttonDamageControl", "%s C. Pump"),system),function()
					string.format("")	--global context for serious proton
					if p.coolant_pump_part_count > 0 then
						p:setSystemCoolantRate(system,p.normal_coolant_rate[system])
						p.coolant_pump_part_count = p.coolant_pump_part_count - 1
						p.coolant_pump_fixed_message_dmg = "coolant_pump_fixed_message_dmg"
						p:addCustomMessage("DamageControl",p.coolant_pump_fixed_message_dmg,string.format(_("coolant-msgDamageControl", "The %s coolant pump has been repaired"),system))
					end
					resetCoolantPumpButtons(p)
				end)
			end
		end
	end
end
function wreckModCombatBoost(x,y)
	local full_desc = wreck_mod_type[19].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[19].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		local current_boost = playerShipStats[p:getTypeName()].cm_boost
		if current_boost ~= nil then
			if p.cm_boost_count == nil then
				p.cm_boost_count = 0
			end
			local scan_bonus = 0
			if self:isScannedByFaction(p:getFaction()) then
				scan_bonus = difficulty * 5
			end
			if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
				p.cm_boost_count = p.cm_boost_count + 1
				if p.cm_boost_active == nil then
					p.cm_boost_active = false
				end
				if not p.cm_boost_active then
					wmCombatBoostButton(p,"Helms")
					wmCombatBoostButton(p,"Tactical")
				end
			else
				if p.cm_boost_count > 0 then
					p.cm_boost_count = p.cm_boost_count - 1
					if p.cm_boost_count < 1 then
						if p.activate_cm_boost_button ~= nil then
							p:removeCustom(p.activate_cm_boost_button)
							p.activate_cm_boost_button = nil
						end
						if p.activate_cm_boost_button_tac ~= nil then
							p:removeCustom(p.activate_cm_boost_button_tac)
							p.activate_cm_boost_button_tac = nil
						end
					end
					if p:hasPlayerAtPosition("Helms") then
						p.lost_cm_boost_message = "lost_cm_boost_message"
						p:addCustomMessage("Helms",p.lost_cm_boost_message,string.format(_("artifactEffect-msgHelms", "The %s retrieved disabled a %s previously retrieved"),full_desc,full_desc))
					end
					if p:hasPlayerAtPosition("Tactical") then
						p.lost_cm_boost_message_tac = "lost_cm_boost_message_tac"
						p:addCustomMessage("Tactical",p.lost_cm_boost_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved disabled a %s previously retrieved"),full_desc,full_desc))
					end
				else
					p:setCombatManeuver(playerShipStats[p:getTypeName()].cm_boost - 100,playerShipStats[p:getTypeName()].cm_strafe)
					if p:hasPlayerAtPosition("Helms") then
						p.reduced_cm_boost_message = "reduced_cm_boost_message"
						p:addCustomMessage("Helms",p.reduced_cm_boost_message,string.format(_("artifactEffect-msgHelms", "The %s retrieved reduced the combat maneuver boost (forward direction) ability"),full_desc))
					end
					if p:hasPlayerAtPosition("Tactical") then
						p.reduced_cm_boost_message_tac = "reduced_cm_boost_message_tac"
						p:addCustomMessage("Tactical",p.reduced_cm_boost_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved reduced the combat maneuver boost (forward direction) ability"),full_desc))
					end
				end
			end
		else	--cannot determine current combat maneuver values since player template type not in player ship stats table
			if p:hasPlayerAtPosition("Helms") then
				p.cm_boost_message = "cm_boost_message"
				p:addCustomMessage("Helms",p.cm_boost_message,string.format(_("artifactEffect-msgHelms", "The %s retrieved has had no effect on combat maneuver"),full_desc))
			end
			if p:hasPlayerAtPosition("Tactical") then
				p.cm_boost_message_tac = "cm_boost_message_tac"
				p:addCustomMessage("Tactical",p.cm_boost_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved has had no effect on combat maneuver"),full_desc))
			end
		end
	end)
	return wma
end
function wreckModCombatStrafe(x,y)
	local full_desc = wreck_mod_type[20].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[20].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		local current_strafe = playerShipStats[p:getTypeName()].cm_strafe
		if current_strafe ~= nil then
			if p.cm_strafe_count == nil then
				p.cm_strafe_count = 0
			end
			local scan_bonus = 0
			if self:isScannedByFaction(p:getFaction()) then
				scan_bonus = difficulty * 5
			end
			if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
				p.cm_strafe_count = p.cm_strafe_count + 1
				if p.cm_strafe_active == nil then
					p.cm_strafe_active = false
				end
				if not p.cm_strafe_active then
					wmCombatStrafeButton(p,"Helms")
					wmCombatStrafeButton(p,"Tactical")
				end
			else
				if p.cm_strafe_count > 0 then
					p.cm_strafe_count = p.cm_strafe_count - 1
					if p.cm_strafe_count < 1 then
						if p.activate_cm_strafe_button ~= nil then
							p:removeCustom(p.activate_cm_strafe_button)
							p.activate_cm_strafe_button = nil
						end
						if p.activate_cm_strafe_button_tac ~= nil then
							p:removeCustom(p.activate_cm_strafe_button_tac)
							p.activate_cm_strafe_button_tac = nil
						end
					end
					if p:hasPlayerAtPosition("Helms") then
						p.lost_cm_strafe_message = "lost_cm_strafe_message"
						p:addCustomMessage("Helms",p.lost_cm_strafe_message,string.format(_("artifactEffect-msgHelms", "The %s retrieved disabled a %s previously retrieved"),full_desc,full_desc))
					end
					if p:hasPlayerAtPosition("Tactical") then
						p.lost_cm_strafe_message_tac = "lost_cm_strafe_message_tac"
						p:addCustomMessage("Tactical",p.lost_cm_strafe_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved disabled a %s previously retrieved"),full_desc,full_desc))
					end
				else
					p:setCombatManeuver(playerShipStats[p:getTypeName()].cm_boost,playerShipStats[p:getTypeName()].cm_strafe - 100)
					if p:hasPlayerAtPosition("Helms") then
						p.reduced_cm_strafe_message = "reduced_cm_strafe_message"
						p:addCustomMessage("Helms",p.reduced_cm_strafe_message,string.format(_("artifactEffect-msgHelms", "The %s retrieved reduced the combat maneuver strafe (sideways direction) ability"),full_desc))
					end
					if p:hasPlayerAtPosition("Tactical") then
						p.reduced_cm_strafe_message_tac = "reduced_cm_strafe_message_tac"
						p:addCustomMessage("Tactical",p.reduced_cm_strafe_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved reduced the combat maneuver strafe (sideways direction) ability"),full_desc))
					end
				end
			end
		else	--cannot determine current combat maneuver values since player template type not in player ship stats table
			if p:hasPlayerAtPosition("Helms") then
				p.cm_strafe_message = "cm_strafe_message"
				p:addCustomMessage("Helms",p.cm_strafe_message,string.format(_("artifactEffect-msgHelms", "The %s retrieved has had no effect on combat maneuver"),full_desc))
			end
			if p:hasPlayerAtPosition("Tactical") then
				p.cm_strafe_message_tac = "cm_strafe_message_tac"
				p:addCustomMessage("Tactical",p.cm_strafe_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved has had no effect on combat maneuver"),full_desc))
			end
		end
	end)
	return wma
end
function wreckModProbeStock(x,y)
	local full_desc = wreck_mod_type[21].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[21].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		local current_stock = p:getScanProbeCount()
		local scan_bonus = 0
		if self:isScannedByFaction(p:getFaction()) then
			scan_bonus = difficulty * 5
		end
		if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
			if current_stock < p:getMaxScanProbeCount() then
				p:setScanProbeCount(p:getMaxScanProbeCount())
				if p:hasPlayerAtPosition("Relay") then
					p.artifact_restocked_probes_message = "artifact_restocked_probes_message"
					p:addCustomMessage("Relay",p.artifact_restocked_probes_message,string.format(_("artifactEffect-msgRelay", "The %s retrieved has restocked your probes"),full_desc))
				end
				if p:hasPlayerAtPosition("Operations") then
					p.artifact_restocked_probes_message_ops = "artifact_restocked_probes_message_ops"
					p:addCustomMessage("Operations",p.artifact_restocked_probes_message_ops,string.format(_("artifactEffect-msgOperations", "The %s retrieved has restocked your probes"),full_desc))
				end
			else
				if p:hasPlayerAtPosition("Relay") then
					p.artifact_probes_message = "artifact_probes_message"
					p:addCustomMessage("Relay",p.artifact_probes_message,string.format(_("artifactEffect-msgRelay", "The %s retrieved does not effect probe stock"),full_desc))
				end
				if p:hasPlayerAtPosition("Operations") then
					p.artifact_probes_message_ops = "artifact_probes_message_ops"
					p:addCustomMessage("Operations",p.artifact_probes_message_ops,string.format(_("artifactEffect-msgOperations", "The %s retrieved does not effect probe stock"),full_desc))
				end
			end
		else
			if current_stock > 0 then
				p:setScanProbeCount(math.floor(current_stock/2))
				if p:hasPlayerAtPosition("Relay") then
					p.artifact_depleted_probes_message = "artifact_depleted_probes_message"
					p:addCustomMessage("Relay",p.artifact_depleted_probes_message,string.format(_("artifactEffect-msgRelay", "The %s retrieved has depleted probe stock"),full_desc))
				end
				if p:hasPlayerAtPosition("Operations") then
					p.artifact_depleted_probes_message_ops = "artifact_depleted_probes_message_ops"
					p:addCustomMessage("Operations",p.artifact_depleted_probes_message_ops,string.format(_("artifactEffect-msgOperations", "The %s retrieved has depleted probe stock"),full_desc))
				end
			else
				if p:hasPlayerAtPosition("Relay") then
					p.artifact_probes_message = "artifact_probes_message"
					p:addCustomMessage("Relay",p.artifact_probes_message,string.format(_("artifactEffect-msgRelay", "The %s retrieved does not effect probe stock"),full_desc))
				end
				if p:hasPlayerAtPosition("Operations") then
					p.artifact_probes_message_ops = "artifact_probes_message_ops"
					p:addCustomMessage("Operations",p.artifact_probes_message_ops,string.format(_("artifactEffect-msgOperations", "The %s retrieved does not effect probe stock"),full_desc))
				end
			end
		end
	end)
	return wma
end
function wreckModBeamDamage(x,y)
	local full_desc = wreck_mod_type[22].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[22].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		if p:hasSystem("beamweapons") then
			if p.beam_damage_count == nil then
				p.beam_damage_count = 0
			end
			local scan_bonus = 0
			if self:isScannedByFaction(p:getFaction()) then
				scan_bonus = difficulty * 5
			end
			if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
				p.beam_damage_count = p.beam_damage_count + 1
				if p.beam_damage_active == nil then
					p.beam_damage_active = false
				end
				if not p.beam_damage_active then
					wmBeamDamageButton(p,"Weapons")
					wmBeamDamageButton(p,"Tactical")
				end
			else
				if p.beam_damage_count > 0 then
					p.beam_damage_count = p.beam_damage_count - 1
					if p.beam_damage_count < 1 then
						if p.activate_beam_damage_button ~= nil then
							p:removeCustom(p.activate_beam_damage_button)
							p.activate_beam_damage_button = nil
						end
						if p.activate_beam_damage_button_tac ~= nil then
							p:removeCustom(p.activate_beam_damage_button_tac)
							p.activate_beam_damage_button_tac = nil
						end
					end
					if p:hasPlayerAtPosition("Weapons") then
						p.lost_beam_damage_message = "lost_beam_damage_message"
						p:addCustomMessage("Weapons",p.lost_beam_damage_message,string.format(_("artifactEffect-msgWeapons", "The %s retrieved disabled a %s previously retrieved"),full_desc,full_desc))
					end
					if p:hasPlayerAtPosition("Tactical") then
						p.lost_beam_damage_message_tac = "lost_beam_damage_message_tac"
						p:addCustomMessage("Tactical",p.lost_beam_damage_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved disabled a %s previously retrieved"),full_desc,full_desc))
					end
				else
					local bi = 0
					repeat
						p:setBeamWeapon(bi,p:getBeamWeaponArc(bi),p:getBeamWeaponDirection(bi),p:getBeamWeaponRange(bi),p:getBeamWeaponCycleTime(bi),p:getBeamWeaponDamage(bi)*.9)
						bi = bi + 1
					until(p:getBeamWeaponRange(bi) < 1)
					if p:hasPlayerAtPosition("Weapons") then
						p.reduced_beam_damage_message = "reduced_beam_damage_message"
						p:addCustomMessage("Weapons",p.reduced_beam_damage_message,string.format(_("artifactEffect-msgWeapons", "The %s retrieved reduced beam damage"),full_desc))
					end
					if p:hasPlayerAtPosition("Tactical") then
						p.reduced_beam_damage_message_tac = "reduced_beam_damage_message_tac"
						p:addCustomMessage("Tactical",p.reduced_beam_damage_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved reduced beam damage"),full_desc))
					end
				end
			end
		else
			if p:hasPlayerAtPosition("Weapons") then
				p.beam_message = "beam_message"
				p:addCustomMessage("Weapons",p.beam_message,string.format(_("artifactEffect-msgWeapons", "The %s retrieved has had no effect on your non-existent beam weapon system"),full_desc))
			end
			if p:hasPlayerAtPosition("Tactical") then
				p.beam_message_tac = "beam_message_tac"
				p:addCustomMessage("Tactical",p.beam_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved has had no effect on your non-existent beam weapon system"),full_desc))
			end
		end
	end)
	return wma
end
function wreckModBeamCycle(x,y)
	local full_desc = wreck_mod_type[23].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[23].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		if p:hasSystem("beamweapons") then
			if p.beam_cycle_count == nil then
				p.beam_cycle_count = 0
			end
			local scan_bonus = 0
			if self:isScannedByFaction(p:getFaction()) then
				scan_bonus = difficulty * 5
			end
			if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
				p.beam_cycle_count = p.beam_cycle_count + 1
				if p.beam_cycle_active == nil then
					p.beam_cycle_active = false
				end
				if not p.beam_cycle_active then
					wmBeamCycleButton(p,"Weapons")
					wmBeamCycleButton(p,"Tactical")
				end
			else
				if p.beam_cycle_count > 0 then
					p.beam_cycle_count = p.beam_cycle_count - 1
					if p.beam_cycle_count < 1 then
						if p.activate_beam_cycle_button ~= nil then
							p:removeCustom(p.activate_beam_cycle_button)
							p.activate_beam_cycle_button = nil
						end
						if p.activate_beam_cycle_button_tac ~= nil then
							p:removeCustom(p.activate_beam_cycle_button_tac)
							p.activate_beam_cycle_button_tac = nil
						end
					end
					if p:hasPlayerAtPosition("Weapons") then
						p.lost_beam_cycle_message = "lost_beam_cycle_message"
						p:addCustomMessage("Weapons",p.lost_beam_cycle_message,string.format(_("artifactEffect-msgWeapons", "The %s retrieved disabled a %s previously retrieved"),full_desc,full_desc))
					end
					if p:hasPlayerAtPosition("Tactical") then
						p.lost_beam_cycle_message_tac = "lost_beam_cycle_message_tac"
						p:addCustomMessage("Tactical",p.lost_beam_cycle_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved disabled a %s previously retrieved"),full_desc,full_desc))
					end
				else
					local bi = 0
					repeat
						p:setBeamWeapon(bi,p:getBeamWeaponArc(bi),p:getBeamWeaponDirection(bi),p:getBeamWeaponRange(bi),p:getBeamWeaponCycleTime(bi)*1.1,p:getBeamWeaponDamage(bi))
						bi = bi + 1
					until(p:getBeamWeaponRange(bi) < 1)
					if p:hasPlayerAtPosition("Weapons") then
						p.reduced_beam_cycle_message = "reduced_beam_cycle_message"
						p:addCustomMessage("Weapons",p.reduced_beam_cycle_message,string.format(_("artifactEffect-msgWeapons", "The %s retrieved slowed beam cycle time"),full_desc))
					end
					if p:hasPlayerAtPosition("Tactical") then
						p.reduced_beam_cycle_message_tac = "reduced_beam_cycle_message_tac"
						p:addCustomMessage("Tactical",p.reduced_beam_cycle_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved slowed beam cycle time"),full_desc))
					end
				end
			end
		else
			if p:hasPlayerAtPosition("Weapons") then
				p.beam_message = "beam_message"
				p:addCustomMessage("Weapons",p.beam_message,string.format(_("artifactEffect-msgWeapons", "The %s retrieved has had no effect on your non-existent beam weapon system"),full_desc))
			end
			if p:hasPlayerAtPosition("Tactical") then
				p.beam_message_tac = "beam_message_tac"
				p:addCustomMessage("Tactical",p.beam_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved has had no effect on your non-existent beam weapon system"),full_desc))
			end
		end
	end)
	return wma
end
function wreckModMissileStock(x,y)
	local full_desc = wreck_mod_type[24].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[24].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		if p:hasSystem("missilesystem") then
			local current_shortage = -1
			local missle_type = {"Nuke","EMP","Mine","Homing","HVLI"}
			for i, m_type in ipairs(missle_type) do
				if p:getWeaponStorageMax(m_type) > 0 then
					if p:getWeaponStorage(m_type) < p:getWeaponStorageMax(m_type) then
						if p:getWeaponStorageMax(m_type) - p:getWeaponStorage(m_type) > current_shortage then
							current_shortage = p:getWeaponStorageMax(m_type) - p:getWeaponStorage(m_type)
							shortage_type = m_type
						end
					end
				end
			end
			local scan_bonus = 0
			if self:isScannedByFaction(p:getFaction()) then
				scan_bonus = difficulty * 5
			end
			if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
				if current_shortage > 0 then
					p:setWeaponStorage(shortage_type,p:getWeaponStorageMax(shortage_type))
					if p:hasPlayerAtPosition("Weapons") then
						p.artifact_restocked_missiles_message = "artifact_restocked_missiles_message"
						p:addCustomMessage("Weapons",p.artifact_restocked_missiles_message,string.format(_("artifactEffect-msgWeapons", "The %s retrieved has restocked your %ss"),full_desc,shortage_type))
					end
					if p:hasPlayerAtPosition("Tactical") then
						p.artifact_restocked_missiles_message_tac = "artifact_restocked_missiles_message_tac"
						p:addCustomMessage("Tactical",p.artifact_restocked_missiles_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved has restocked your %ss"),full_desc,shortage_type))
					end
				else
					if p:hasPlayerAtPosition("Weapons") then
						p.artifact_missiles_message = "artifact_missiles_message"
						p:addCustomMessage("Weapons",p.artifact_missiles_message,string.format(_("artifactEffect-msgWeapons", "The %s retrieved does not effect missile stocks"),full_desc))
					end
					if p:hasPlayerAtPosition("Tactical") then
						p.artifact_missiles_message_tac = "artifact_missiles_message_tac"
						p:addCustomMessage("Tactical",p.artifact_missiles_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved does not effect missile stocks"),full_desc))
					end
				end
			else
				local plentiful_amount = 0
				local plentiful_type = ""
				for i, m_type in ipairs(missle_type) do
					if p:getWeaponStorage(m_type) > plentiful_amount then
						plentiful_amount = p:getWeaponStorage(m_type)
						plentiful_type = m_type
					end
				end
				if current_shortage > 0 then
					if plentiful_amount > 0 then
						p:setWeaponStorage(plentiful_type,math.floor(p:getWeaponStorage(plentiful_type)/2))
						if p:hasPlayerAtPosition("Weapons") then
							p.artifact_depleted_missiles_message = "artifact_depleted_missiles_message"
							p:addCustomMessage("Weapons",p.artifact_depleted_missiles_message,string.format(_("artifactEffect-msgWeapons", "The %s retrieved has depleted your stock of %ss"),full_desc,plentiful_type))
						end
						if p:hasPlayerAtPosition("Tactical") then
							p.artifact_depleted_missiles_message_tac = "artifact_depleted_missiles_message_tac"
							p:addCustomMessage("Tactical",p.artifact_depleted_missiles_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved has depleted your stock of %ss"),full_desc,plentiful_type))
						end
					else
						if p:hasPlayerAtPosition("Weapons") then
							p.artifact_missiles_message = "artifact_missiles_message"
							p:addCustomMessage("Weapons",p.artifact_missiles_message,string.format(_("artifactEffect-msgWeapons", "The %s retrieved does not effect missile stocks"),full_desc))
						end
						if p:hasPlayerAtPosition("Tactical") then
							p.artifact_missiles_message_tac = "artifact_missiles_message_tac"
							p:addCustomMessage("Tactical",p.artifact_missiles_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved does not effect missile stocks"),full_desc))
						end
					end
				else
					p:setWeaponStorage(plentiful_type,math.floor(p:getWeaponStorage(plentiful_type)/2))
					if p:hasPlayerAtPosition("Weapons") then
						p.artifact_depleted_missiles_message = "artifact_depleted_missiles_message"
						p:addCustomMessage("Weapons",p.artifact_depleted_missiles_message,string.format(_("artifactEffect-msgWeapons", "The %s retrieved has depleted your stock of %ss"),full_desc,plentiful_type))
					end
					if p:hasPlayerAtPosition("Tactical") then
						p.artifact_depleted_missiles_message_tac = "artifact_depleted_missiles_message_tac"
						p:addCustomMessage("Tactical",p.artifact_depleted_missiles_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved has depleted your stock of %ss"),full_desc,plentiful_type))
					end
				end
			end
		else
			if p:hasPlayerAtPosition("Weapons") then
				p.artifact_missiles_message = "artifact_missiles_message"
				p:addCustomMessage("Weapons",p.artifact_missiles_message,string.format(_("artifactEffect-msgWeapons", "The %s retrieved does not effect your non-existent missile system"),full_desc))
			end
			if p:hasPlayerAtPosition("Tactical") then
				p.artifact_missiles_message_tac = "artifact_missiles_message_tac"
				p:addCustomMessage("Tactical",p.artifact_missiles_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved does not effect your non-existent missile system"),full_desc))
			end
		end
	end)
	return wma
end
function wreckModImpulseSpeed(x,y)
	local full_desc = wreck_mod_type[25].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[25].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		if p.impulse_count == nil then
			p.impulse_count = 0
		end
		local scan_bonus = 0
		if self:isScannedByFaction(p:getFaction()) then
			scan_bonus = difficulty * 5
		end
		if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
			p.impulse_count = p.impulse_count + 1
			if p.impulse_active == nil then
				p.impulse_active = false
			end
			if not p.impulse_active then
				wmImpulseButton(p,"Helms")
				wmImpulseButton(p,"Tactical")
			end
		else
			if p.impulse_count > 0 then
				p.impulse_count = p.impulse_count - 1
				if p.impulse_count < 1 then
					if p.activate_impulse_button ~= nil then
						p:removeCustom(p.activate_impulse_button)
						p.activate_impulse_button = nil
					end
					if p.activate_impulse_button_tac ~= nil then
						p:removeCustom(p.activate_impulse_button_tac)
						p.activate_impulse_button_tac = nil
					end
				end
				if p:hasPlayerAtPosition("Helms") then
					p.lost_impulse_message = "lost_impulse_message"
					p:addCustomMessage("Helms",p.lost_impulse_message,string.format(_("artifactEffect-msgHelms", "The %s retrieved disabled a %s previously retrieved"),full_desc,full_desc))
				end
				if p:hasPlayerAtPosition("Tactical") then
					p.lost_impulse_message_tac = "lost_impulse_message_tac"
					p:addCustomMessage("Tactical",p.lost_impulse_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved disabled a %s previously retrieved"),full_desc,full_desc))
				end
			else
				p:setImpulseMaxSpeed(p:getImpulseMaxSpeed()*.9)
				if p:hasPlayerAtPosition("Helms") then
					p.reduced_impulse_message = "reduced_impulse_message"
					p:addCustomMessage("Helms",p.reduced_impulse_message,string.format(_("artifactEffect-msgHelms", "The %s retrieved slowed maximum impulse speed"),full_desc))
				end
				if p:hasPlayerAtPosition("Tactical") then
					p.reduced_impulse_message_tac = "reduced_impulse_message_tac"
					p:addCustomMessage("Tactical",p.reduced_impulse_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved slowed maximum impulse speed"),full_desc))
				end
			end
		end
	end)
	return wma
end
function wreckModWarpSpeed(x,y)
	local full_desc = wreck_mod_type[26].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[26].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		if p:hasSystem("warp") then
			if p.warp_count == nil then
				p.warp_count = 0
			end
			local scan_bonus = 0
			if self:isScannedByFaction(p:getFaction()) then
				scan_bonus = difficulty * 5
			end
			if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
				p.warp_count = p.warp_count + 1
				if p.warp_active == nil then
					p.warp_active = false
				end
				if not p.warp_active then
					wmWarpButton(p,"Helms")
					wmWarpButton(p,"Tactical")
				end
			else
				if p.warp_count > 0 then
					p.warp_count = p.warp_count - 1
					if p.warp_count < 1 then
						if p.activate_warp_button ~= nil then
							p:removeCustom(p.activate_warp_button)
							p.activate_warp_button = nil
						end
						if p.activate_warp_button_tac ~= nil then
							p:removeCustom(p.activate_warp_button_tac)
							p.activate_warp_button_tac = nil
						end
					end
					if p:hasPlayerAtPosition("Helms") then
						p.lost_warp_message = "lost_warp_message"
						p:addCustomMessage("Helms",p.lost_warp_message,string.format(_("artifactEffect-msgHelms", "The %s retrieved disabled a %s previously retrieved"),full_desc,full_desc))
					end
					if p:hasPlayerAtPosition("Tactical") then
						p.lost_warp_message_tac = "lost_warp_message_tac"
						p:addCustomMessage("Tactical",p.lost_warp_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved disabled a %s previously retrieved"),full_desc,full_desc))
					end
				else
					p:setWarpSpeed(p:getWarpSpeed()*.9)
					if p:hasPlayerAtPosition("Helms") then
						p.reduced_warp_message = "reduced_warp_message"
						p:addCustomMessage("Helms",p.reduced_warp_message,string.format(_("artifactEffect-msgHelms", "The %s retrieved slowed maximum warp speed"),full_desc))
					end
					if p:hasPlayerAtPosition("Tactical") then
						p.reduced_warp_message_tac = "reduced_warp_message_tac"
						p:addCustomMessage("Tactical",p.reduced_warp_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved slowed maximum warp speed"),full_desc))
					end
				end
			end
		else
			if p:hasPlayerAtPosition("Helms") then
				p.warp_message = "warp_message"
				p:addCustomMessage("Helms",p.warp_message,string.format(_("artifactEffect-msgHelms", "The %s retrieved had no effect on your non-existent warp system"),full_desc))
			end
			if p:hasPlayerAtPosition("Tactical") then
				p.warp_message_tac = "warp_message_tac"
				p:addCustomMessage("Tactical",p.warp_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved had no effect on your non-existent warp system"),full_desc))
			end
		end
	end)
	return wma
end
function wreckModJumpRange(x,y)
	local full_desc = wreck_mod_type[27].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[27].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		if p:hasSystem("jumpdrive") then
			if p.jump_count == nil then
				p.jump_count = 0
			end
			local scan_bonus = 0
			if self:isScannedByFaction(p:getFaction()) then
				scan_bonus = difficulty * 5
			end
			if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
				p.jump_count = p.jump_count + 1
				if p.jump_active == nil then
					p.jump_active = false
				end
				if not p.jump_active then
					wmJumpButton(p,"Helms")
					wmJumpButton(p,"Tactical")
				end
			else
				if p.jump_count > 0 then
					p.jump_count = p.jump_count - 1
					if p.jump_count < 1 then
						if p.activate_jump_button ~= nil then
							p:removeCustom(p.activate_jump_button)
							p.activate_jump_button = nil
						end
						if p.activate_jump_button_tac ~= nil then
							p:removeCustom(p.activate_jump_button_tac)
							p.activate_jump_button_tac = nil
						end
					end
					if p:hasPlayerAtPosition("Helms") then
						p.lost_jump_message = "lost_jump_message"
						p:addCustomMessage("Helms",p.lost_jump_message,string.format(_("artifactEffect-msgHelms", "The %s retrieved disabled a %s previously retrieved"),full_desc,full_desc))
					end
					if p:hasPlayerAtPosition("Tactical") then
						p.lost_jump_message_tac = "lost_jump_message_tac"
						p:addCustomMessage("Tactical",p.lost_jump_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved disabled a %s previously retrieved"),full_desc,full_desc))
					end
				else
					if p.max_jump_range == nil then
						p.max_jump_range = 50000
						p.min_jump_range = 5000
					end
					p:setJumpDriveRange(p.max_jump_range*.9)
					p.max_jump_range = p.max_jump_range*.9
					if p:hasPlayerAtPosition("Helms") then
						p.reduced_jump_message = "reduced_jump_message"
						p:addCustomMessage("Helms",p.reduced_jump_message,string.format(_("artifactEffect-msgHelms", "The %s retrieved reduced maximum jump range"),full_desc))
					end
					if p:hasPlayerAtPosition("Tactical") then
						p.reduced_jump_message_tac = "reduced_jump_message_tac"
						p:addCustomMessage("Tactical",p.reduced_jump_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved reduced maximum jump range"),full_desc))
					end
				end
			end
		else
			if p:hasPlayerAtPosition("Helms") then
				p.jump_message = "jump_message"
				p:addCustomMessage("Helms",p.jump_message,string.format(_("artifactEffect-msgHelms", "The %s retrieved had no effect on your non-existent jump system"),full_desc))
			end
			if p:hasPlayerAtPosition("Tactical") then
				p.jump_message_tac = "jump_message_tac"
				p:addCustomMessage("Tactical",p.jump_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved had no effect on your non-existent jump system"),full_desc))
			end
		end
	end)
	return wma
end
function wreckModShieldMax(x,y)
	local full_desc = wreck_mod_type[28].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[28].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		if p:hasSystem("frontshield") then
			if p.shield_count == nil then
				p.shield_count = 0
			end
			local scan_bonus = 0
			if self:isScannedByFaction(p:getFaction()) then
				scan_bonus = difficulty * 5
			end
			if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
				p.shield_count = p.shield_count + 1
				if p.shield_active == nil then
					p.shield_active = false
				end
				if not p.shield_active then
					wmShieldButton(p,"Weapons")
					wmShieldButton(p,"Tactical")
				end
			else
				if p.shield_count > 0 then
					p.shield_count = p.shield_count - 1
					if p.shield_count < 1 then
						if p.activate_shield_button ~= nil then
							p:removeCustom(p.activate_shield_button)
							p.activate_shield_button = nil
						end
						if p.activate_shield_button_tac ~= nil then
							p:removeCustom(p.activate_shield_button_tac)
							p.activate_shield_button_tac = nil
						end
					end
					if p:hasPlayerAtPosition("Weapons") then
						p.lost_shield_message = "lost_shield_message"
						p:addCustomMessage("Weapons",p.lost_shield_message,string.format(_("artifactEffect-msgWeapons", "The %s retrieved disabled a %s previously retrieved"),full_desc,full_desc))
					end
					if p:hasPlayerAtPosition("Tactical") then
						p.lost_shield_message_tac = "lost_shield_message_tac"
						p:addCustomMessage("Tactical",p.lost_shield_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved disabled a %s previously retrieved"),full_desc,full_desc))
					end
				else
					if p:getShieldCount() > 1 then
						p:setShieldsMax(p:getShieldMax(0)*.9,p:getShieldMax(1)*.9)
					else
						p:setShieldsMax(p:getShieldMax(0)*.9)
					end
					if p:hasPlayerAtPosition("Weapons") then
						p.reduced_shield_message = "reduced_shield_message"
						p:addCustomMessage("Weapons",p.reduced_shield_message,string.format(_("artifactEffect-msgWeapons", "The %s retrieved reduced maximum shield strength"),full_desc))
					end
					if p:hasPlayerAtPosition("Tactical") then
						p.reduced_shield_message_tac = "reduced_shield_message_tac"
						p:addCustomMessage("Tactical",p.reduced_shield_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved reduced maximum shield strength"),full_desc))
					end
				end
			end
		else
			if p:hasPlayerAtPosition("Weapons") then
				p.shield_message = "shield_message"
				p:addCustomMessage("Weapons",p.shield_message,string.format(_("artifactEffect-msgWeapons", "The %s retrieved had no effect on your non-existent shield system"),full_desc))
			end
			if p:hasPlayerAtPosition("Tactical") then
				p.shield_message_tac = "shield_message_tac"
				p:addCustomMessage("Tactical",p.shield_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved had no effect on your non-existent shield system"),full_desc))
			end
		end
	end)
	return wma
end
function wreckModSpinSpeed(x,y)
	local full_desc = wreck_mod_type[29].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[29].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		if p.maneuver_count == nil then
			p.maneuver_count = 0
		end
		local scan_bonus = 0
		if self:isScannedByFaction(p:getFaction()) then
			scan_bonus = difficulty * 5
		end
		if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
			p.maneuver_count = p.maneuver_count + 1
			if p.maneuver_active == nil then
				p.maneuver_active = false
			end
			if not p.maneuver_active then
				wmManeuverButton(p,"Helms")
				wmManeuverButton(p,"Tactical")
			end
		else
			if p.maneuver_count > 0 then
				p.maneuver_count = p.maneuver_count - 1
				if p.maneuver_count < 1 then
					if p.activate_maneuver_button ~= nil then
						p:removeCustom(p.activate_maneuver_button)
						p.activate_maneuver_button = nil
					end
					if p.activate_maneuver_button_tac ~= nil then
						p:removeCustom(p.activate_maneuver_button_tac)
						p.activate_maneuver_button_tac = nil
					end
				end
				if p:hasPlayerAtPosition("Helms") then
					p.lost_maneuver_message = "lost_maneuver_message"
					p:addCustomMessage("Helms",p.lost_maneuver_message,string.format(_("artifactEffect-msgHelms", "The %s retrieved disabled a %s previously retrieved"),full_desc,full_desc))
				end
				if p:hasPlayerAtPosition("Tactical") then
					p.lost_maneuver_message_tac = "lost_maneuver_message_tac"
					p:addCustomMessage("Tactical",p.lost_maneuver_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved disabled a %s previously retrieved"),full_desc,full_desc))
				end
			else
				p:setRotationMaxSpeed(p:getRotationMaxSpeed()*.9)
				if p:hasPlayerAtPosition("Helms") then
					p.reduced_maneuver_message = "reduced_maneuver_message"
					p:addCustomMessage("Helms",p.reduced_maneuver_message,string.format(_("artifactEffect-msgHelms", "The %s retrieved reduced maximum spin speed"),full_desc))
				end
				if p:hasPlayerAtPosition("Tactical") then
					p.reduced_maneuver_message_tac = "reduced_maneuver_message_tac"
					p:addCustomMessage("Tactical",p.reduced_maneuver_message_tac,string.format(_("artifactEffect-msgTactical", "The %s retrieved reduced maximum spin speed"),full_desc))
				end
			end
		end
	end)
	return wma
end
function wreckModBatteryMax(x,y)
	local full_desc = wreck_mod_type[30].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[30].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		if p.battery_count == nil then
			p.battery_count = 0
		end
		local scan_bonus = 0
		if self:isScannedByFaction(p:getFaction()) then
			scan_bonus = difficulty * 5
		end
		if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
			p.battery_count = p.battery_count + 1
			if p.battery_active == nil then
				p.battery_active = false
			end
			if not p.battery_active then
				wmBatteryButton(p,"Engineering")
				wmBatteryButton(p,"Engineering+")
			end
		else
			if p.battery_count > 0 then
				p.battery_count = p.battery_count - 1
				if p.battery_count < 1 then
					if p.activate_battery_button ~= nil then
						p:removeCustom(p.activate_battery_button)
						p.activate_battery_button = nil
					end
					if p.activate_battery_button_plus ~= nil then
						p:removeCustom(p.activate_battery_button_plus)
						p.activate_battery_button_plus = nil
					end
				end
				if p:hasPlayerAtPosition("Engineering") then
					p.lost_battery_message = "lost_battery_message"
					p:addCustomMessage("Engineering",p.lost_battery_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved disabled a %s previously retrieved"),full_desc,full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.lost_battery_message_plus = "lost_battery_message_plus"
					p:addCustomMessage("Engineering+",p.lost_battery_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved disabled a %s previously retrieved"),full_desc,full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.lost_battery_message_dmg = "lost_battery_message_dmg"
					p:addCustomMessage("DamageControl",p.lost_battery_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved disabled a %s previously retrieved"),full_desc,full_desc))
				end
			else
				p:setMaxEnergy(p:getMaxEnergy()*.9)
				if p:hasPlayerAtPosition("Engineering") then
					p.reduced_battery_message = "reduced_battery_message"
					p:addCustomMessage("Engineering",p.reduced_battery_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved reduced maximum battery capacity"),full_desc))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.reduced_battery_message_plus = "reduced_battery_message_plus"
					p:addCustomMessage("Engineering+",p.reduced_battery_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved reduced maximum battery capacity"),full_desc))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.reduced_battery_message_dmg = "reduced_battery_message_dmg"
					p:addCustomMessage("DamageControl",p.reduced_battery_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved reduced maximum battery capacity"),full_desc))
				end
			end
		end
	end)
	return wma
end
function wreckCargo(x,y)
	local wreck_good = commonGoods[math.random(1,#commonGoods)]
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[31].desc,string.format(_("scienceDescription-artifact", "Cargo (type: %s)"),wreck_good))
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--serious proton needs global context
		local scan_bonus = 0
		if self:isScannedByFaction(p:getFaction()) then
			scan_bonus = difficulty * 5
		end
		if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
			if p.cargo > 0 then
				p.cargo = p.cargo - 1
				if p.goods == nil then
					p.goods = {}
				end
				if p.goods[wreck_good] == nil then
					p.goods[wreck_good] = 0
				end
				p.goods[wreck_good] = p.goods[wreck_good] + 1
				if p:hasPlayerAtPosition("Relay") then
					p.good_added = "good_added"
					p:addCustomMessage("Relay",p.good_added,string.format(_("inventory-msgRelay", "One %s added to ship inventory"),wreck_good))
				end
				if p:hasPlayerAtPosition("Operations") then
					p.good_added_ops = "good_added_ops"
					p:addCustomMessage("Operations",p.good_added_ops,string.format(_("inventory-msgOperations", "One %s added to ship inventory"),wreck_good))
				end
			else
				if p:hasPlayerAtPosition("Relay") then
					p.no_cargo_space = "no_cargo_space"
					p:addCustomMessage("Relay",p.no_cargo_space,_("inventory-msgRelay", "No cargo space available. Cargo wasted"))
				end
				if p:hasPlayerAtPosition("Operations") then
					p.no_cargo_space_ops = "no_cargo_space_ops"
					p:addCustomMessage("Operations",p.no_cargo_space_ops,_("inventory-msgOperations", "No cargo space available. Cargo wasted"))
				end
			end
		else
			self:explode()
			p:setHull(p:getHull()-random(1,3))
			if p:hasPlayerAtPosition("Relay") then
				p.cargo_sabotage = "cargo_sabotage"
				p:addCustomMessage("Relay",p.cargo_sabotage,_("sabotage-msgRelay", "Booby trapped cargo container. Fortunately automated safety protocols transported the cargo container off the ship before too much damage was taken"))
			end
			if p:hasPlayerAtPosition("Operations") then
				p.cargo_sabotage_ops = "cargo_sabotage_ops"
				p:addCustomMessage("Operations",p.cargo_sabotage_ops,_("sabotage-msgOperations", "Booby trapped cargo container. Fortunately automated safety protocols transported the cargo container off the ship before too much damage was taken"))
			end
		end
	end)
	return wma
end
function wreckModCoolantPump(x,y)
	local full_desc = wreck_mod_type[32].scan_desc
	local wma = Artifact():setPosition(x,y):setDescriptions(wreck_mod_type[32].desc,full_desc)
	wreckModCommonArtifact(wma)
	wma:onPickup(function(self,p)
		string.format("")	--global context for serious proton
		local scan_bonus = 0
		if self:isScannedByFaction(p:getFaction()) then
			scan_bonus = difficulty * 5
		end
		if random(1,100) < base_wreck_mod_positive - (difficulty * wreck_mod_interval) + scan_bonus then
			if p.coolant_pump_part_count == nil then
				p.coolant_pump_part_count = 0
			end
			p.coolant_pump_part_count = p.coolant_pump_part_count + 1
			if p:hasPlayerAtPosition("Engineering") then
				p.artifact_provided_coolant_pump_parts_message = "artifact_provided_coolant_pump_parts_message"
				p:addCustomMessage("Engineering",p.artifact_provided_coolant_pump_parts_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved provided spare coolant pump parts that may be used to repair a damaged coolant pump"),full_desc))
			end
			if p:hasPlayerAtPosition("Engineering+") then
				p.artifact_provided_coolant_pump_parts_message_plus = "artifact_provided_coolant_pump_parts_message_plus"
				p:addCustomMessage("Engineering+",p.artifact_provided_coolant_pump_parts_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved provided spare coolant pump parts that may be used to repair a damaged coolant pump"),full_desc))
			end
			if p:hasPlayerAtPosition("DamageControl") then
				p.artifact_provided_coolant_pump_parts_message_dmg = "artifact_provided_coolant_pump_parts_message_dmg"
				p:addCustomMessage("DamageControl",p.artifact_provided_coolant_pump_parts_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved provided spare coolant pump parts that may be used to repair a damaged coolant pump"),full_desc))
			end
			local system_types = {"reactor","beamweapons","missilesystem","maneuver","impulse","warp","jumpdrive","frontshield","rearshield"}
			if p.coolant_pump_fix_buttons == nil then
				p.coolant_pump_fix_buttons = {}
			end
			if p.coolant_pump_fix_buttons_plus == nil then
				p.coolant_pump_fix_buttons_plus = {}
			end
			if p.coolant_pump_fix_buttons_dmg == nil then
				p.coolant_pump_fix_buttons_dmg = {}
			end
			for i, system in ipairs(system_types) do
				if p.normal_coolant_rate[system] < p:getSystemCoolantRate(system) then
					wmCoolantPump(p,"Engineering",system)
					wmCoolantPump(p,"Engineering+",system)
					wmCoolantPump(p,"DamageControl",system)
				end
			end
		else
			if p:hasPlayerAtPosition("Engineering") then
				p.artifact_incompatible_message = "artifact_incompatible_message"
				p:addCustomMessage("Engineering",p.artifact_incompatible_message,string.format(_("artifactEffect-msgEngineer", "The %s retrieved contains no compatible or salvageable parts for your coolant pump system"),full_desc))
			end
			if p:hasPlayerAtPosition("Engineering+") then
				p.artifact_incompatible_message_plus = "artifact_incompatible_message_plus"
				p:addCustomMessage("Engineering+",p.artifact_incompatible_message_plus,string.format(_("artifactEffect-msgEngineer+", "The %s retrieved contains no compatible or salvageable parts for your coolant pump system"),full_desc))
			end
			if p:hasPlayerAtPosition("DamageControl") then
				p.artifact_incompatible_message_dmg = "artifact_incompatible_message_dmg"
				p:addCustomMessage("DamageControl",p.artifact_incompatible_message_dmg,string.format(_("artifactEffect-msgDamageControl", "The %s retrieved contains no compatible or salvageable parts for your coolant pump system"),full_desc))
			end
		end
	end)
	return wma
end
---------------------------
-- Game Master functions --
---------------------------
function debugButtons()
	clearGMFunctions()
	addGMFunction(_("buttonGM", "-From Debug"),mainGMButtons)
	addGMFunction(_("buttonGM", "always popup debug"),function()
		popupGMDebug = "always"
	end)
	addGMFunction(_("buttonGM", "once popup debug"),function()
		popupGMDebug = "once"
	end)
	addGMFunction(_("buttonGM", "never popup debug"),function()
		popupGMDebug = "never"
	end)
end
function mainGMButtons()
	clearGMFunctions()
	local playerShipCount = 0
	local highestPlayerIndex = 0
	for pidx=1,32 do
		local p = getPlayerShip(pidx)
		if p ~= nil then
			if p:isValid() then
				playerShipCount = playerShipCount + 1
			end
			highestPlayerIndex = pidx
		end
	end
	addGMFunction(string.format(_("buttonGM", "+Player ships %i/%i"),playerShipCount,highestPlayerIndex),playerShip)
	addGMFunction(_("buttonGM", "+Set Time Limit"),setGameTimeLimit)
	addGMFunction(_("buttonGM", "+Show Player Info"),setShowPlayerInfo)
	addGMFunction(_("buttonGM", "+debug"),debugButtons)
	if predefined_player_ships ~= nil then
		addGMFunction(_("buttonGM", "Fixed->Random Names"),function()
			if #predefined_player_ships > 0 then
				stored_fixed_names = {}
				for i=1,#predefined_player_ships do
					table.insert(stored_fixed_names,predefined_player_ships[i])
				end
			else
				stored_fixed_names = nil
			end
			predefined_player_ships = nil
			mainGMButtons()
		end)
	else
		addGMFunction(_("buttonGM", "Random->Fixed Names"),function()
			if stored_fixed_names ~= nil and #stored_fixed_names > 0 then
				predefined_player_ships = {}
				for i=1,#stored_fixed_names do
					table.insert(predefined_player_ships,stored_fixed_names[i])
				end
			else
				addGMMessage(_("msgGM", "No fixed names available. Either there never were any defined or they have all been used"))
				predefined_player_ships = nil
			end
			stored_fixed_names = nil
			mainGMButtons()
		end)
	end
	GMBelligerentKraylors = nil
	GMLimitedWar = nil
	GMFullWar = nil
end
function setShowPlayerInfo()
	clearGMFunctions()
	addGMFunction(_("buttonGM", "-From Player Info"),mainGMButtons)
	local button_label = _("buttonGM", "Show Info")
	if show_player_info then
		button_label = string.format(_("buttonGM", "%s*"),button_label)
	end
	addGMFunction(button_label,function()
		show_player_info = true
		setShowPlayerInfo()
	end)
	button_label = _("buttonGM", "Omit Info")
	if not show_player_info then
		button_label = string.format(_("buttonGM", "%s*"),button_label)
	end
	addGMFunction(button_label,function()
		show_player_info = false
		setShowPlayerInfo()
	end)
	button_label = _("buttonGM", "Only Name")
	if show_only_player_name then
		button_label = string.format(_("buttonGM", "%s*"),button_label)
	end
	addGMFunction(button_label,function()
		show_only_player_name = true
		setShowPlayerInfo()
	end)
	button_label = _("buttonGM", "More than Name")
	if not show_only_player_name then
		button_label = string.format(_("buttonGM", "%s*"),button_label)
	end
	addGMFunction(button_label,function()
		show_only_player_name = false
		setShowPlayerInfo()
	end)
	if show_player_info then
		for pidx=1,32 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				local player_name = p:getCallSign()
				if p.show_name_helm == nil then
					p.show_name_helm = true
				end
				if p.show_name_helm then
					button_label = string.format(_("buttonGM", "%s Helm*"),player_name)
				else
					button_label = string.format(_("buttonGM", "%s Helm"),player_name)
				end
				addGMFunction(button_label,function()
					if p.show_name_helm then
						p.show_name_helm = false
					else
						p.show_name_helm = true
					end
					setShowPlayerInfo()
				end)
				if p.show_name_weapons then
					button_label = string.format(_("buttonGM", "%s Weapons*"),player_name)
				else
					button_label = string.format(_("buttonGM", "%s Weapons"),player_name)
				end
				addGMFunction(button_label,function()
					if p.show_name_weapons then
						p.show_name_weapons = false
					else
						p.show_name_weapons = true
					end
					setShowPlayerInfo()
				end)
				if p.show_name_engineer then
					button_label = string.format(_("buttonGM", "%s Engineer*"),player_name)
				else
					button_label = string.format(_("buttonGM", "%s Engineer"),player_name)
				end
				addGMFunction(button_label,function()
					if p.show_name_engineer then
						p.show_name_engineer = false
					else
						p.show_name_engineer = true
					end
					setShowPlayerInfo()
				end)
			end
		end
	end
end
function showPlayerInfoOnConsole(delta, p)
	if show_player_info then
		local player_name = p:getCallSign()
		if p.player_info_timer == nil then
			p.player_info_timer = delta + 5
		end
		p.player_info_timer = p.player_info_timer - delta
		if p.player_info_timer < 0 then
			if show_only_player_name then
				if p.show_name_helm then
					if p:hasPlayerAtPosition("Helms") then
						p.name_helm = "name_helm"
						p:addCustomInfo("Helms",p.name_helm,player_name)
					end
				else
					if p.name_helm ~= nil then
						p:removeCustom(p.name_helm)
						p.name_helm = nil
					end
				end
				if p.show_name_weapons then
					if p:hasPlayerAtPosition("Weapons") then
						p.name_weapons = "name_weapons"
						p:addCustomInfo("Weapons",p.name_weapons,player_name)
					end
				else
					if p.name_weapons ~= nil then
						p:removeCustom(p.name_weapons)
						p.name_weapons = nil
					end
				end
				if p.show_name_engineer then
					if p:hasPlayerAtPosition("Engineering") then
						p.name_engineer = "name_engineer"
						p:addCustomInfo("Engineering",p.name_engineer,player_name)
					end
				else
					if p.name_engineer ~= nil then
						p:removeCustom(p.name_engineer)
						p.name_engineer = nil
					end
				end
				p.player_info_timer = delta + 5
			else	--show player name and other info
				if p.name_toggle == nil then
					p.name_toggle = true
				end
				if p.name_toggle then	--show player name
					if p.show_name_helm then
						if p:hasPlayerAtPosition("Helms") then
							p.name_helm = "name_helm"
							p:addCustomInfo("Helms",p.name_helm,player_name)
						end
					else
						if p.name_helm ~= nil then
							p:removeCustom(p.name_helm)
							p.name_helm = nil
						end
					end
					if p.show_name_weapons then
						if p:hasPlayerAtPosition("Weapons") then
							p.name_weapons = "name_weapons"
							p:addCustomInfo("Weapons",p.name_weapons,player_name)
						end
					else
						if p.name_weapons ~= nil then
							p:removeCustom(p.name_weapons)
							p.name_weapons = nil
						end
					end
					if p.show_name_engineer then
						if p:hasPlayerAtPosition("Engineering") then
							p.name_engineer = "name_engineer"
							p:addCustomInfo("Engineering",p.name_engineer,player_name)
						end
					else
						if p.name_engineer ~= nil then
							p:removeCustom(p.name_engineer)
							p.name_engineer = nil
						end
					end
					p.name_toggle = false
					p.player_info_timer = delta + 5
				else	--show other info
					local ship_info = ""
					info_choice = info_choice + 1
					if info_choice > info_choice_max then
						info_choice = 1
					end
					if info_choice == 1 then
						ship_info = string.format("Repair Crew: %i",p:getRepairCrewCount())
						if p.maxRepairCrew ~= nil then
							ship_info = string.format("%s/%i",ship_info,p.maxRepairCrew)
						end
					elseif info_choice == 2 then
						ship_info = string.format("Hull: %i/%i",math.floor(p:getHull()),math.floor(p:getHullMax()))
					elseif info_choice == 3 then
						ship_info = "Shield: "
						if p:getShieldCount() == 1 then
							ship_info = string.format("%s%i/%i",ship_info,math.floor(p:getShieldLevel(0)),math.floor(p:getShieldMax(0)))
						else
							ship_info = string.format("%sF:%i/%i R:%i/%i",ship_info,math.floor(p:getShieldLevel(0)),math.floor(p:getShieldMax(0)),math.floor(p:getShieldLevel(1)),math.floor(p:getShieldMax(1)))
						end
					elseif info_choice == 4 then
						local beam_count = 0
						for i=0,15 do
							if p:getBeamWeaponRange(i) > 0 then
								beam_count = beam_count + 1
							end
						end
						ship_info = string.format("Beams: %i, Tubes: %i",beam_count,p:getWeaponTubeCount())
					else
						ship_info = p:getTypeName()
						print(ship_info)
						if ship_info == nil then
							ship_info = string.format("Repair Crew: %i",p:getRepairCrewCount())
						else
							ship_info = string.format("Type: %s",ship_info)
						end
					end
					if p.show_name_helm then
						if p:hasPlayerAtPosition("Helms") then
							p.name_helm = "name_helm"
							p:addCustomInfo("Helms",p.name_helm,ship_info)
						end
					else
						if p.name_helm ~= nil then
							p:removeCustom(p.name_helm)
							p.name_helm = nil
						end
					end
					if p.show_name_weapons then
						if p:hasPlayerAtPosition("Weapons") then
							p.name_weapons = "name_weapons"
							p:addCustomInfo("Weapons",p.name_weapons,ship_info)
						end
					else
						if p.name_weapons ~= nil then
							p:removeCustom(p.name_weapons)
							p.name_weapons = nil
						end
					end
					if p.show_name_engineer then
						if p:hasPlayerAtPosition("Engineering") then
							p.name_engineer = "name_engineer"
							p:addCustomInfo("Engineering",p.name_engineer,ship_info)
						end
					else
						if p.name_engineer ~= nil then
							p:removeCustom(p.name_engineer)
							p.name_engineer = nil
						end
					end
					p.name_toggle = true
					p.player_info_timer = delta + 3
				end
			end
		end
	else	--not show player info
		if p.name_helm ~= nil then
			p:removeCustom(p.name_helm)
			p.name_helm = nil
		end
		if p.name_weapons ~= nil then
			p:removeCustom(p.name_weapons)
			p.name_weapons = nil
		end
		if p.name_engineer ~= nil then
			p:removeCustom(p.name_engineer)
			p.name_engineer = nil
		end
	end
end
function playerShip()
	clearGMFunctions()
	addGMFunction(_("buttonGM", "-From Player ships"),mainGMButtons)
	addGMFunction(_("buttonGM", "+Describe stock"),describeStockPlayerShips)
	addGMFunction(_("buttonGM", "+Describe special"),describeSpecialPlayerShips)
	if playerNarsil == nil then
		addGMFunction(_("buttonGM", "Narsil"),function()
			createPlayerShipNarsil()
			playerShip()
		end)
	end
	if playerHeadhunter == nil then
		addGMFunction(_("buttonGM", "Headhunter"),function()
			createPlayerShipHeadhunter()
			playerShip()
		end)
	end
	if playerBlazon == nil then
		addGMFunction(_("buttonGM", "Blazon"),function()
			createPlayerShipBlazon()
			playerShip()
		end)
	end
	if playerSting == nil then
		addGMFunction(_("buttonGM", "Sting"),function()
			createPlayerShipSting()
			playerShip()
		end)
	end
	if playerSpyder == nil then
		addGMFunction(_("buttonGM", "Spyder"),function()
			createPlayerShipSpyder()
			playerShip()
		end)
	end
	if playerSpinstar == nil then
		addGMFunction(_("buttonGM", "Spinstar"),function()
			createPlayerShipSpinstar()
			playerShip()
		end)
	end
	if playerSimian == nil then
		addGMFunction(_("buttonGM", "Simian"),function()
			createPlayerShipSimian()
			playerShip()
		end)
	end
end
function describeSpecialPlayerShips()
	clearGMFunctions()
	addGMFunction(_("buttonGM", "-Back"),playerShip)
	addGMFunction(_("buttonGM", "Simian"),function()
		addGMMessage(_("msgGM", "Destroyer III(Simian):   Hull:100   Shield:110,70   Size:200   Repair Crew:3   Cargo:7   R.Strength:25\nDefault advanced engine:Jump (2U - 20U)   Speeds: Impulse:60   Spin:8   Accelerate:15   C.Maneuver: Boost:450 Strafe:150\nBeam:1 Turreted Speed:0.2\n   Arc:270   Direction:0   Range:0.8   Cycle:5   Damage:6\nTubes:5   Load Speed:8   Front:2   Side:2   Back:1\n   Direction:  0   Type:Exclude Mine\n   Direction:  0   Type:Exclude Mine\n   Direction:-90   Type:Homing Only\n   Direction: 90   Type:Homing Only\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      10 Homing\n      04 Nuke\n      06 Mine\n      05 EMP\n      10 HVLI\nBased on player missile cruiser: short jump drive (no warp), weaker hull, added one turreted beam, fewer tubes on side, fewer homing, nuke, EMP, mine and added HVLI"))
	end)	
	--[[	ships not present yet
	addGMFunction(_("buttonGM"), "Cobra",function()
		addGMMessage(_("msgGM", "Striker LX(Cobra): Starfighter, Patrol   Hull:120   Shield:100,100   Size:200   Repair Crew:2   Cargo:4   R.Strength:15\nDefault advanced engine:Jump (2U - 20U)   Speeds: Impulse:65   Spin:15   Accelerate:30   C.Maneuver: Boost:250 Strafe:150   Energy:800\nBeams:2 Turreted Speed:0.1\n   Arc:100   Direction:-15   Range:1   Cycle:6   Damage:6\n   Arc:100   Direction: 15   Range:1   Cycle:6   Damage:6\nTubes:2 Rear:2\n   Direction:180   Type:Any\n   Direction:180   Type:Any\n   Ordnance stock and type:\n      4 Homing\n      2 Nuke\n      3 Mine\n      3 EMP\n      6 HVLI\nBased on Striker: stronger shields, more energy, jump drive (vs none), faster impulse, slower turret, two rear tubes (vs none)"))
	end)
	addGMFunction(_("buttonGM"), "Holmes",function()
		addGMMessage(_("msgGM", "Holmes: Corvette, Popper   Hull:160   Shield:160,160   Size:200   Repair Crew:4   Cargo Space:6   R.Strength:35\nDefault advanced engine:Warp (750)   Speeds: Impulse:70   Spin:15   Accelerate:40   C.Maneuver: Boost:400 Strafe:250\nBeams:4 Broadside\n   Arc:60   Direction:-85   Range:1   Cycle:6   Damage:5\n   Arc:60   Direction:-95   Range:1   Cycle:6   Damage:5\n   Arc:60   Direction: 85   Range:1   Cycle:6   Damage:5\n   Arc:60   Direction: 95   Range:1   Cycle:6   Damage:5\nTubes:4   Load Speed:8   Front:3   Back:1\n   Direction:   0   Type:Homing Only - Small\n   Direction:   0   Type:Homing Only\n   Direction:   0   Type:Homing Only - Large\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      12 Homing\n      06 Mine\nBased on Crucible: Slower impulse, broadside beams, no side tubes, front tubes homing only"))
	end)
	addGMFunction(_("buttonGM"), "Rattler",function()
		addGMMessage(_("msgGM", "MX-Lindworm (Rattler): Starfighter, Bomber   Hull:75   Shield:40   Size:100   Repair Crew:2   Cargo:3   R.Strength:10\nDefault advanced engine:Jump (3U - 20U)   Speeds: Impulse:85   Spin:15   Accelerate:25   C.Maneuver: Boost:250 Strafe:150   Energy:400\nBeam:1 Turreted Speed:1\n   Arc:270   Direction:180   Range:0.7   Cycle:6   Damage:2\nTubes:3   Load Speed:10   Front:3 (small)\n   Direction: 0   Type:Any - small\n   Direction: 1   Type:HVLI Only - small\n   Direction:-1   Type:HVLI Only - small\n   Ordnance stock and type:\n      03 Homing\n      12 HVLI\nBased on ZX-Lindworm: More repair crew, faster impulse, jump drive, slower turret"))
	end)
	addGMFunction(_("buttonGM"), "Rogue",function()
		addGMMessage(_("msgGM", "Maverick XP(Rogue): Corvette, Gunner   Hull:160   Shield:160,160   Size:200   Repair Crew:4   Cargo:5   R.Strength:23\nDefault advanced engine:Jump (2U - 20U)   Speeds: Impulse:65   Spin:15   Accelerate:40   C.Maneuver: Boost:400 Strafe:250\nBeams:1 Turreted Speed:0.1   5X heat   5X energy\n   Arc:270   Direction:  0   Range:1.8   Cycle:18   Damage:18\nTubes:3   Load Speed:8   Side:2   Back:1\n   Direction:-90   Type:Exclude Mine\n   Direction: 90   Type:Exclude Mine\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      06 Homing\n      02 Nuke\n      02 Mine\n      04 EMP\n      10 HVLI\nBased on Maverick: slower impulse, jump (no warp), one heavy slow turreted beam (not 6 beams)"))
	end)
	--]]	
end
function describeStockPlayerShips()
	clearGMFunctions()
	addGMFunction(_("buttonGM", "-Back"),playerShip)
	addGMFunction(_("buttonGM", "Atlantis"),function()
		addGMMessage(_("msgGM", "Atlantis: Corvette, Destroyer   Hull:250   Shield:200,200   Size:400   Repair Crew:3   Cargo:6   R.Strength:52\nDefault advanced engine:Jump   Speeds: Impulse:90   Spin:10   Accelerate:20   C.Maneuver: Boost:400 Strafe:250\nBeams:2\n   Arc:100   Direction:-20   Range:1.5   Cycle:6   Damage:8\n   Arc:100   Direction: 20   Range:1.5   Cycle:6   Damage:8\nTubes:5   Load Speed:10   Side:4   Back:1\n   Direction:-90   Type:Exclude Mine\n   Direction:-90   Type:Exclude Mine\n   Direction: 90   Type:Exclude Mine\n   Direction: 90   Type:Exclude Mine\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      12 Homing\n      04 Nuke\n      08 Mine\n      06 EMP\n      20 HVLI\nA refitted Atlantis X23 for more general tasks. The large shield system has been replaced with an advanced combat maneuvering systems and improved impulse engines. Its missile loadout is also more diverse. Mistaking the modified Atlantis for an Atlantis X23 would be a deadly mistake."))
	end)
	addGMFunction(_("buttonGM", "Benedict"),function()
		addGMMessage(_("msgGM", "Benedict: Corvette, Freighter/Carrier   Hull:200   Shield:70,70   Size:400   Repair Crew:3   Cargo Space:9   R.Strength:10\nShip classes that may dock with Benedict:Starfighter, Frigate, Corvette\nDefault advanced engine:Jump (5U - 90U)   Speeds: Impulse:60   Spin:6   Accelerate:8   C.Maneuver: Boost:400 Strafe:250\nBeams:2 Turreted Speed:6\n   Arc:90   Direction:  0   Range:1.5   Cycle:6   Damage:4\n   Arc:90   Direction:180   Range:1.5   Cycle:6   Damage:4\nBenedict is an improved version of the Jump Carrier"))
	end)
	addGMFunction(_("buttonGM", "Crucible"),function()
		addGMMessage(_("msgGM", "Crucible: Corvette, Popper   Hull:160   Shield:160,160   Size:200   Repair Crew:4   Cargo Space:5   R.Strength:45\nDefault advanced engine:Warp (750)   Speeds: Impulse:80   Spin:15   Accelerate:40   C.Maneuver: Boost:400 Strafe:250\nBeams:2\n   Arc:70   Direction:-30   Range:1   Cycle:6   Damage:5\n   Arc:70   Direction: 30   Range:1   Cycle:6   Damage:5\nTubes:6   Load Speed:8   Front:3   Side:2   Back:1\n   Direction:   0   Type:HVLI Only - Small\n   Direction:   0   Type:HVLI Only\n   Direction:   0   Type:HVLI Only - Large\n   Direction:-90   Type:Exclude Mine\n   Direction: 90   Type:Exclude Mine\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      08 Homing\n      04 Nuke\n      06 Mine\n      06 EMP\n      24 HVLI\nA number of missile tubes range around this ship. Beams were deemed lower priority, though they are still present. Stronger defenses than a frigate, but not as strong as the Atlantis"))
	end)
	addGMFunction(_("buttonGM", "Ender"),function()
		addGMMessage(_("msgGM", "Ender: Dreadnaught, Battlecruiser   Hull:100   Shield:1200,1200   Size:2000   Repair Crew:8   Cargo Space:20   R.Strength:100\nShip classes that may dock with Benedict:Starfighter, Frigate, Corvette   Energy:1200\nDefault advanced engine:Jump   Speeds: Impulse:30   Spin:2   Accelerate:6   C.Maneuver: Boost:800 Strafe:500\nBeams:12 6 left, 6 right turreted Speed:6\n   Arc:120   Direction:-90   Range:2.5   Cycle:6.1   Damage:4\n   Arc:120   Direction:-90   Range:2.5   Cycle:6.0   Damage:4\n   Arc:120   Direction: 90   Range:2.5   Cycle:5.8   Damage:4\n   Arc:120   Direction: 90   Range:2.5   Cycle:6.3   Damage:4\n   Arc:120   Direction:-90   Range:2.5   Cycle:5.9   Damage:4\n   Arc:120   Direction:-90   Range:2.5   Cycle:6.4   Damage:4\n   Arc:120   Direction: 90   Range:2.5   Cycle:5.7   Damage:4\n   Arc:120   Direction: 90   Range:2.5   Cycle:5.6   Damage:4\n   Arc:120   Direction:-90   Range:2.5   Cycle:6.6   Damage:4\n   Arc:120   Direction:-90   Range:2.5   Cycle:5.5   Damage:4\n   Arc:120   Direction: 90   Range:2.5   Cycle:6.5   Damage:4\n   Arc:120   Direction: 90   Range:2.5   Cycle:6.2   Damage:4\nTubes:2   Load Speed:8   Front:1   Back:1\n   Direction:   0   Type:Homing Only\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      6 Homing\n      6 Mine"))
	end)
	addGMFunction(_("buttonGM", "Flavia P.Falcon"),function()
		addGMMessage(_("msgGM", "Flavia P.Falcon: Frigate, Light Transport   Hull:100   Shield:70,70   Size:200   Repair Crew:8   Cargo Space:15   R.Strength:13\nDefault advanced engine:Warp (500)   Speeds: Impulse:60   Spin:10   Accelerate:10   C.Maneuver: Boost:250 Strafe:150\nBeams:2 rear facing\n   Arc:40   Direction:170   Range:1.2   Cycle:6   Damage:6\n   Arc:40   Direction:190   Range:1.2   Cycle:6   Damage:6\nTubes:1   Load Speed:20   Back:1\n   Direction:180   Type:Any\n   Ordnance stock and type:\n      3 Homing\n      1 Nuke\n      1 Mine\n      5 HVLI\nThe Flavia P.Falcon has a nuclear-capable rear-facing weapon tube and a warp drive."))
	end)
	addGMFunction(_("buttonGM", "Hathcock"),function()
		addGMMessage(_("msgGM", "Hathcock: Frigate, Cruiser: Sniper   Hull:120   Shield:70,70   Size:200   Repair Crew:2   Cargo Space:6   R.Strength:30\nDefault advanced engine:Jump   Speeds: Impulse:50   Spin:15   Accelerate:8   C.Maneuver: Boost:200 Strafe:150\nBeams:4 front facing\n   Arc:04   Direction:0   Range:1.4   Cycle:6   Damage:4\n   Arc:20   Direction:0   Range:1.2   Cycle:6   Damage:4\n   Arc:60   Direction:0   Range:1.0   Cycle:6   Damage:4\n   Arc:90   Direction:0   Range:0.8   Cycle:6   Damage:4\nTubes:2   Load Speed:15   Side:2\n   Direction:-90   Type:Any\n   Direction: 90   Type:Any\n   Ordnance stock and type:\n      4 Homing\n      1 Nuke\n      2 EMP\n      8 HVLI\nLong range narrow beam and some point defense beams, broadside missiles. Agile for a frigate"))
	end)
	addGMFunction(_("buttonGM", "Kiriya"),function()
		addGMMessage(_("msgGM", "Kiriya: Corvette, Freighter/Carrier   Hull:200   Shield:70,70   Size:400   Repair Crew:3   Cargo Space:9   R.Strength:10\nShip classes that may dock with Benedict:Starfighter, Frigate, Corvette\nDefault advanced engine:Warp (750)   Speeds: Impulse:60   Spin:6   Accelerate:8   C.Maneuver: Boost:400 Strafe:250\nBeams:2 Turreted Speed:6\n   Arc:90   Direction:  0   Range:1.5   Cycle:6   Damage:4\n   Arc:90   Direction:180   Range:1.5   Cycle:6   Damage:4\nKiriya is an improved warp drive version of the Jump Carrier"))
	end)
	addGMFunction(_("buttonGM", "MP52 Hornet"),function()
		addGMMessage(_("msgGM", "MP52 Hornet: Starfighter, Interceptor   Hull:70   Shield:60   Size:100   Repair Crew:1   Cargo:3   R.Strength:7\nDefault advanced engine:None   Speeds: Impulse:125   Spin:32   Accelerate:40   C.Maneuver: Boost:600   Energy:400\nBeams:2\n   Arc:30   Direction: 5   Range:.9   Cycle:4   Damage:2.5\n   Arc:30   Direction:-5   Range:.9   Cycle:4   Damage:2.5\nThe MP52 Hornet is a significantly upgraded version of MU52 Hornet, with nearly twice the hull strength, nearly three times the shielding, better acceleration, impulse boosters, and a second laser cannon."))
	end)
	addGMFunction(_("buttonGM", "Maverick"),function()
		addGMMessage(_("msgGM", "Maverick: Corvette, Gunner   Hull:160   Shield:160,160   Size:200   Repair Crew:4   Cargo:5   R.Strength:45\nDefault advanced engine:Warp (800)   Speeds: Impulse:80   Spin:15   Accelerate:40   C.Maneuver: Boost:400 Strafe:250\nBeams:6   3 forward, 2 side, 1 back (turreted speed .5)\n   Arc:10   Direction:  0   Range:2.0   Cycle:6   Damage:6\n   Arc: 90   Direction:-20   Range:1.5   Cycle:6   Damage:8\n   Arc: 90   Direction: 20   Range:1.5   Cycle:6   Damage:8\n   Arc: 40   Direction:-70   Range:1.0   Cycle:4   Damage:6\n   Arc: 40   Direction: 70   Range:1.0   Cycle:4   Damage:6\n   Arc:180   Direction:180   Range:0.8   Cycle:6   Damage:4   (turreted speed: .5)\nTubes:3   Load Speed:8   Side:2   Back:1\n   Direction:-90   Type:Exclude Mine\n   Direction: 90   Type:Exclude Mine\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      06 Homing\n      02 Nuke\n      02 Mine\n      04 EMP\n      10 HVLI\nA number of beams bristle from various points on this gunner. Missiles were deemed lower priority, though they are still present. Stronger defenses than a frigate, but not as strong as the Atlantis"))
	end)
	addGMFunction(_("buttonGM", "Nautilus"),function()
		addGMMessage(_("msgGM", "Nautilus: Frigate, Mine Layer   Hull:100   Shield:60,60   Size:200   Repair Crew:4   Cargo:7   R.Strength:12\nDefault advanced engine:Jump   Speeds: Impulse:100   Spin:10   Accelerate:15   C.Maneuver: Boost:250 Strafe:150\nBeams:2 Turreted Speed:6\n   Arc:90   Direction: 35   Range:1   Cycle:6   Damage:6\n   Arc:90   Direction:-35   Range:1   Cycle:6   Damage:6\nTubes:3   Load Speed:10   Back:3\n   Direction:180   Type:Mine Only\n   Direction:180   Type:Mine Only\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      12 Mine\nSmall mine laying vessel with minimal armament, shields and hull"))
	end)
	addGMFunction(_("buttonGM", "Phobos MP3"),function()
		addGMMessage(_("msgGM", "Phobos MP3: Frigate, Cruiser   Hull:200   Shield:100,100   Size:200   Repair Crew:3   Cargo:10   R.Strength:19\nDefault advanced engine:None   Speeds: Impulse:80   Spin:10   Accelerate:20   C.Maneuver: Boost:400 Strafe:250\nBeams:2\n   Arc:90   Direction:-15   Range:1.2   Cycle:8   Damage:6\n   Arc:90   Direction: 15   Range:1.2   Cycle:8   Damage:6\nTubes:3   Load Speed:10   Front:2   Back:1\n   Direction: -1   Type:Exclude Mine\n   Direction:  1   Type:Exclude Mine\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      10 Homing\n      02 Nuke\n      04 Mine\n      03 EMP\n      20 HVLI\nPlayer variant of the Phobos M3, not as strong as the atlantis, but has front firing tubes, making it an easier to use ship in some scenarios."))
	end)
	addGMFunction(_("buttonGM", "Piranha"),function()
		addGMMessage(_("msgGM", "Piranha: Frigate, Cruiser: Light Artillery   Hull:120   Shield:70,70   Size:200   Repair Crew:2   Cargo:8   R.Strength:16\nDefault advanced engine:None   Speeds: Impulse:60   Spin:10   Accelerate:8   C.Maneuver: Boost:200 Strafe:150\nTubes:8   Load Speed:8   Side:6   Back:2\n   Direction:-90   Type:HVLI and Homing Only\n   Direction:-90   Type:Any\n   Direction:-90   Type:HVLI and Homing Only\n   Direction: 90   Type:HVLI and Homing Only\n   Direction: 90   Type:Any\n   Direction: 90   Type:HVLI and Homing Only\n   Direction:170   Type:Mine Only\n   Direction:190   Type:Mine Only\n   Ordnance stock and type:\n      12 Homing\n      06 Nuke\n      08 Mine\n      20 HVLI\nThis combat-specialized Piranha F12 adds mine-laying tubes, combat maneuvering systems, and a jump drive."))
	end)	
	addGMFunction(_("buttonGM", "Player Cruiser"),function()
		addGMMessage(_("msgGM", "Player Cruiser:   Hull:200   Shield:80,80   Size:400   Repair Crew:3   Cargo:6   R.Strength:40\nDefault advanced engine:Jump   Speeds: Impulse:90   Spin:10   Accelerate:20   C.Maneuver: Boost:400 Strafe:250\nBeams:2\n   Arc:90   Direction:-15   Range:1   Cycle:6   Damage:10\n   Arc:90   Direction: 15   Range:1   Cycle:6   Damage:10\nTubes:3   Load Speed:8   Front:2   Back:1\n   Direction: -5   Type:Exclude Mine\n   Direction:  5   Type:Exclude Mine\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      12 Homing\n      04 Nuke\n      08 Mine\n      06 EMP"))
	end)
	addGMFunction(_("buttonGM", "Player Fighter"),function()
		addGMMessage(_("msgGM", "Player Fighter:   Hull:60   Shield:40   Size:100   Repair Crew:3   Cargo:3   R.Strength:7\nDefault advanced engine:None   Speeds: Impulse:110   Spin:20   Accelerate:40   C.Maneuver: Boost:600   Energy:400\nBeams:2\n   Arc:40   Direction:-10   Range:1   Cycle:6   Damage:8\n   Arc:40   Direction: 10   Range:1   Cycle:6   Damage:8\nTube:1   Load Speed:10   Front:1\n   Direction:0   Type:HVLI Only\n   Ordnance stock and type:\n      4 HVLI"))
	end)
	addGMFunction(_("buttonGM", "Player Missile Cr."),function()
		addGMMessage(_("msgGM", "Player Missile Cr.:   Hull:200   Shield:110,70   Size:200   Repair Crew:3   Cargo:8   R.Strength:45\nDefault advanced engine:Warp (800)   Speeds: Impulse:60   Spin:8   Accelerate:15   C.Maneuver: Boost:450 Strafe:150\nTubes:7   Load Speed:8   Front:2   Side:4   Back:1\n   Direction:  0   Type:Exclude Mine\n   Direction:  0   Type:Exclude Mine\n   Direction: 90   Type:Homing Only\n   Direction: 90   Type:Homing Only\n   Direction:-90   Type:Homing Only\n   Direction:-90   Type:Homing Only\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      30 Homing\n      08 Nuke\n      12 Mine\n      10 EMP"))
	end)	
	addGMFunction(_("buttonGM", "Repulse"),function()
		addGMMessage(_("msgGM", "Repulse: Frigate, Armored Transport   Hull:120   Shield:80,80   Size:200   Repair Crew:8   Cargo:12   R.Strength:14\nDefault advanced engine:Jump   Speeds: Impulse:55   Spin:9   Accelerate:10   C.Maneuver: Boost:250 Strafe:150\nBeams:2 Turreted Speed:5\n   Arc:200   Direction: 90   Range:1.2   Cycle:6   Damage:5\n   Arc:200   Direction:-90   Range:1.2   Cycle:6   Damage:5\nTubes:2   Load Speed:20   Front:1   Back:1\n   Direction:  0   Type:Any\n   Direction:180   Type:Any\n   Ordnance stock and type:\n      4 Homing\n      6 HVLI\nJump/Turret version of Flavia Falcon"))
	end)
	addGMFunction(_("buttonGM", "Striker"),function()
		addGMMessage(_("msgGM", "Striker: Starfighter, Patrol   Hull:120   Shield:50,30   Size:200   Repair Crew:2   Cargo:4   R.Strength:8\nDefault advanced engine:None   Speeds: Impulse:45   Spin:15   Accelerate:30   C.Maneuver: Boost:250 Strafe:150   Energy:500\nBeams:2 Turreted Speed:6\n   Arc:100   Direction:-15   Range:1   Cycle:6   Damage:6\n   Arc:100   Direction: 15   Range:1   Cycle:6   Damage:6\nThe Striker is the predecessor to the advanced striker, slow but agile, but does not do an extreme amount of damage, and lacks in shields"))
	end)
	addGMFunction(_("buttonGM", "ZX-Lindworm"),function()
		addGMMessage(_("msgGM", "ZX-Lindworm: Starfighter, Bomber   Hull:75   Shield:40   Size:100   Repair Crew:1   Cargo:3   R.Strength:8\nDefault advanced engine:None   Speeds: Impulse:70   Spin:15   Accelerate:25   C.Maneuver: Boost:250 Strafe:150   Energy:400\nBeam:1 Turreted Speed:4\n   Arc:270   Direction:180   Range:0.7   Cycle:6   Damage:2\nTubes:3   Load Speed:10   Front:3 (small)\n   Direction: 0   Type:Any - small\n   Direction: 1   Type:HVLI Only - small\n   Direction:-1   Type:HVLI Only - small\n   Ordnance stock and type:\n      03 Homing\n      12 HVLI"))
	end)
end
function setGameTimeLimit()
	clearGMFunctions()
	addGMFunction(_("buttonGM", "-From time limit"),mainGMButtons)
	for gt=30,90,5 do
		if gt ~= 35 and gt ~= 65 and gt ~= 75 and gt ~= 85 then
			addGMFunction(string.format(_("buttonGM", "%i minutes"),gt),function()
				defaultGameTimeLimitInMinutes = gt
				gameTimeLimit = defaultGameTimeLimitInMinutes*60
				plot2 = timedGame
				playWithTimeLimit = true
				addGMMessage(string.format(_("msgGM", "Game time limit set to %i minutes"),defaultGameTimeLimitInMinutes))
			end)
		end
	end
end
-- Dynamic game master buttons --
function dynamicGameMasterButtons(delta)
	if treaty then
		if treatyTimer ~= nil and treatyTimer > 0 then
			if GMBelligerentKraylors == nil then
				GMBelligerentKraylors = "belligerent"
				addGMFunction(GMBelligerentKraylors,belligerentKraylors)
			end
		else
			if treatyStressTimer ~= nil and treatyStressTimer > 0 then
				if GMLimitedWar == nil then
					GMLimitedWar = _("buttonGM", "Limited War")
					addGMFunction(GMLimitedWar,limitedWarByGM)
				end
			end
		end
	else
		if GMBelligerentKraylors ~= nil then
			removeGMFunction(GMBelligerentKraylors)
		end
		GMBelligerentKraylors = nil
		if GMLimitedWar ~= nil then
			removeGMFunction(GMLimitedWar)
		end
		GMLimitedWar = nil
		if limitedWarTimer ~= nil and limitedWarTimer > 0 then
			if GMFullWar == nil then
				GMFullWar = _("buttonGM", "Full War")
				addGMFunction(GMFullWar,fullWarByGM)
			end
		end
	end
end
function belligerentKraylors()
	treatyTimer = 0
	if GMBelligerentKraylors ~= nil then
		removeGMFunction(GMBelligerentKraylors)
	end
	GMBelligerentKraylors = nil
end
function limitedWarByGM()
	treatyStressTimer = 0
	if GMLimitedWar ~= nil then
		removeGMFunction(GMLimitedWar)
	end
	GMLimitedWar = nil
end
function fullWarByGM()
	limitedWarTimer = 0
	if GMFullWar ~= nil then
		removeGMFunction(GMFullWar)
	end
	GMFullWar = nil
end
-- New player ship types via GM button
function createPlayerShipNarsil()
	playerNarsil = PlayerSpaceship():setTemplate("Atlantis"):setFaction("Human Navy"):setCallSign("Narsil")
	playerNarsil:setTypeName("Proto-Atlantis")
	playerNarsil:setRepairCrewCount(4)					--more repair crew (vs 3)
	playerNarsil:setImpulseMaxSpeed(70)					--slower impulse max (vs 90)
	playerNarsil:setRotationMaxSpeed(14)				--faster spin (vs 10)
	playerNarsil:setJumpDrive(false)					--no Jump
	playerNarsil:setWarpDrive(true)						--add warp
	playerNarsil:setHullMax(200)						--weaker hull (vs 250)
	playerNarsil:setHull(200)							
	playerNarsil:setShieldsMax(150,150)					--weaker shields (vs 200)
	playerNarsil:setShields(150,150)
--                  				Arc, Dir, Range, CycleTime, Dmg
	playerNarsil:setBeamWeapon(2,    10, -90,  1000, 	     6, 4)
	playerNarsil:setBeamWeapon(3,    10,  90,  1000, 	     6, 4)
--									     Arc, Dir, Rotate speed
	playerNarsil:setBeamWeaponTurret(2,   60, -90, .5)
	playerNarsil:setBeamWeaponTurret(3,   60,  90, .5)
	playerNarsil:setWeaponTubeCount(6)					--one more forward tube, less flexible ordnance
	playerNarsil:setWeaponTubeDirection(1, 90)			--right (vs left)
	playerNarsil:setWeaponTubeDirection(2,  0)			--front (vs right)
	playerNarsil:setWeaponTubeDirection(3,-90)			--left (vs right)
	playerNarsil:setWeaponTubeDirection(4, 90)			--right (vs rear)
	playerNarsil:setWeaponTubeDirection(5,180)			--rear facing
	playerNarsil:setWeaponTubeExclusiveFor(0,"HVLI")	--HVLI only (vs any)
	playerNarsil:setWeaponTubeExclusiveFor(1,"HVLI")	--HVLI only (vs any)
	playerNarsil:setWeaponTubeExclusiveFor(2,"HVLI")	--HVLI only (vs any)
	playerNarsil:setWeaponTubeExclusiveFor(4,"HVLI")	--HVLI, homing, nuke, emp
	playerNarsil:weaponTubeAllowMissle(4,"Homing")
	playerNarsil:weaponTubeAllowMissle(4,"Nuke")
	playerNarsil:weaponTubeAllowMissle(4,"EMP")
	playerNarsil:setWeaponTubeExclusiveFor(5,"Mine")
end
function createPlayerShipHeadhunter()
	playerHeadhunter = PlayerSpaceship():setTemplate("Piranha"):setFaction("Human Navy"):setCallSign("Headhunter")
	playerHeadhunter:setTypeName("Redhook")
	playerHeadhunter:setRepairCrewCount(4)						--more repair crew (vs 2)
	playerHeadhunter:setJumpDriveRange(2000,25000)				--shorter jump drive range (vs 5-50)
	playerHeadhunter:setHullMax(140)							--stronger hull (vs 120)
	playerHeadhunter:setHull(140)
	playerHeadhunter:setShieldsMax(100, 100)					--stronger shields (vs 70, 70)
	playerHeadhunter:setShields(100, 100)
	playerHeadhunter:setBeamWeapon(0, 10, 0, 1200.0, 4.0, 4)	--one beam (vs 0)
	playerHeadhunter:setBeamWeaponTurret(0, 80, 0, 1)			--slow turret 
	playerHeadhunter:setWeaponTubeCount(7)						--one fewer mine tube, but EMPs added
	playerHeadhunter:setWeaponTubeDirection(6, 180)				--mine tube points straight back
	playerHeadhunter:setWeaponTubeExclusiveFor(0,"HVLI")
	playerHeadhunter:setWeaponTubeExclusiveFor(1,"HVLI")
	playerHeadhunter:setWeaponTubeExclusiveFor(2,"HVLI")
	playerHeadhunter:setWeaponTubeExclusiveFor(3,"HVLI")
	playerHeadhunter:setWeaponTubeExclusiveFor(4,"HVLI")
	playerHeadhunter:setWeaponTubeExclusiveFor(5,"HVLI")
	playerHeadhunter:setWeaponTubeExclusiveFor(6,"Mine")
	playerHeadhunter:weaponTubeAllowMissle(1,"Homing")
	playerHeadhunter:weaponTubeAllowMissle(1,"EMP")
	playerHeadhunter:weaponTubeAllowMissle(1,"Nuke")
	playerHeadhunter:weaponTubeAllowMissle(4,"Homing")
	playerHeadhunter:weaponTubeAllowMissle(4,"EMP")
	playerHeadhunter:weaponTubeAllowMissle(4,"Nuke")
	playerHeadhunter:setWeaponStorageMax("Mine",4)				--fewer mines (vs 8)
	playerHeadhunter:setWeaponStorage("Mine", 4)				
	playerHeadhunter:setWeaponStorageMax("EMP",4)				--more EMPs (vs 0)
	playerHeadhunter:setWeaponStorage("EMP", 4)					
	playerHeadhunter:setWeaponStorageMax("Nuke",4)				--fewer Nukes (vs 6)
	playerHeadhunter:setWeaponStorage("Nuke", 4)		
end
function createPlayerShipBlazon()
	playerBlazon = PlayerSpaceship():setTemplate("Striker"):setFaction("Human Navy"):setCallSign("Blazon")
	playerBlazon:setTypeName("Stricken")
	playerBlazon:setRepairCrewCount(2)				
	playerBlazon:setImpulseMaxSpeed(105)			--vs 45		
	playerBlazon:setRotationMaxSpeed(35)			--vs 15
	playerBlazon:setShieldsMax(80,50)				--vs 50,30
	playerBlazon:setShields(80,50)
	playerBlazon:setBeamWeaponTurret(0,60,-15,2)	--vs arc width of 100 & turret speed of 6
	playerBlazon:setBeamWeaponTurret(1,60, 15,2)
	playerBlazon:setBeamWeapon(2,20,0,1200,6,5)		--vs only 2 turret beams (this is a 3rd beam)
	playerBlazon:setWeaponTubeCount(3)				--vs no tubes
	playerBlazon:setWeaponTubeDirection(0,-60)
	playerBlazon:setWeaponTubeDirection(1,60)
	playerBlazon:setWeaponTubeDirection(2,180)
	playerBlazon:weaponTubeDisallowMissle(0,"Mine")
	playerBlazon:weaponTubeDisallowMissle(1,"Mine")
	playerBlazon:setWeaponTubeExclusiveFor(2,"Mine")
	playerBlazon:setWeaponStorageMax("Homing",6)
	playerBlazon:setWeaponStorage("Homing",6)
	playerBlazon:setWeaponStorageMax("EMP",2)
	playerBlazon:setWeaponStorage("EMP",2)
	playerBlazon:setWeaponStorageMax("Nuke",2)
	playerBlazon:setWeaponStorage("Nuke",2)
	playerBlazon:setWeaponStorageMax("Mine",4)
	playerBlazon:setWeaponStorage("Mine",4)
end
function createPlayerShipSimian()
	playerSimian = PlayerSpaceship():setTemplate("Player Missile Cr."):setFaction("Human Navy"):setCallSign("Simian")
	playerSimian:setTypeName("Destroyer III")
	playerSimian:setWarpDrive(false)
	playerSimian:setJumpDrive(true)
	playerSimian:setJumpDriveRange(2000,20000)						--shorter than typical jump drive range (vs 5-50)
	playerSimian:setHullMax(100)									--weaker hull (vs 200)
	playerSimian:setHull(100)
--                 				 Arc, Dir, Range, CycleTime, Damage
	playerSimian:setBeamWeapon(0,  8,   0, 800.0,         5, 6)		--turreted beam (vs none)
--									    Arc, Dir, Rotate speed
	playerSimian:setBeamWeaponTurret(0, 270,   0, .2)				--slow turret
	playerSimian:setWeaponTubeCount(5)								--fewer (vs 7)
	playerSimian:setWeaponTubeDirection(2, -90)						--left (vs right)
	playerSimian:setWeaponTubeDirection(4, 180)						--rear (vs left)
	playerSimian:setWeaponTubeExclusiveFor(4,"Mine")
	playerSimian:setWeaponStorageMax("Homing",10)					--less (vs 30)
	playerSimian:setWeaponStorage("Homing", 10)				
	playerSimian:setWeaponStorageMax("Nuke",4)						--less (vs 8)
	playerSimian:setWeaponStorage("Nuke", 4)				
	playerSimian:setWeaponStorageMax("EMP",5)						--less (vs 10)
	playerSimian:setWeaponStorage("EMP", 5)				
	playerSimian:setWeaponStorageMax("Mine",6)						--less (vs 12)
	playerSimian:setWeaponStorage("Mine", 6)				
	playerSimian:setWeaponStorageMax("HVLI",10)						--more (vs 0)
	playerSimian:setWeaponStorage("HVLI", 10)			
end
function createPlayerShipSting()
	playerSting = PlayerSpaceship():setTemplate("Hathcock"):setFaction("Human Navy"):setCallSign("Sting")
	playerSting:setTypeName("Surkov")
	playerSting:setRepairCrewCount(3)	--more repair crew (vs 2)
	playerSting:setImpulseMaxSpeed(60)	--faster impulse max (vs 50)
	playerSting:setJumpDrive(false)		--no jump
	playerSting:setWarpDrive(true)		--add warp
	playerSting:setWeaponTubeCount(3)	--one more tube for mines, no heavy ordnance
	playerSting:setWeaponTubeDirection(0, -90)
	playerSting:weaponTubeDisallowMissle(0,"Mine")
	playerSting:weaponTubeDisallowMissle(0,"Nuke")
	playerSting:weaponTubeDisallowMissle(0,"EMP")
	playerSting:setWeaponStorageMax("Mine",3)
	playerSting:setWeaponStorage("Mine",3)
	playerSting:setWeaponStorageMax("Nuke",0)
	playerSting:setWeaponStorage("Nuke",0)
	playerSting:setWeaponStorageMax("EMP",0)
	playerSting:setWeaponStorage("EMP",0)
	playerSting:setWeaponTubeDirection(1, 90)
	playerSting:weaponTubeDisallowMissle(1,"Mine")
	playerSting:weaponTubeDisallowMissle(1,"Nuke")
	playerSting:weaponTubeDisallowMissle(1,"EMP")
	playerSting:setWeaponTubeDirection(2,180)
	playerSting:setWeaponTubeExclusiveFor(2,"Mine")
end
function createPlayerShipSpyder()
	playerSpyder = PlayerSpaceship():setTemplate("Atlantis"):setFaction("Human Navy"):setCallSign("Spyder")
	playerSpyder:setTypeName("Atlantis II")
	playerSpyder:setRepairCrewCount(4)					--more repair crew (vs 3)
	playerSpyder:setImpulseMaxSpeed(80)					--slower impulse max (vs 90)
	playerSpyder:setWeaponTubeCount(6)					--one more tube
	playerSpyder:setWeaponTubeDirection(0,300)			--front left (vs left)
	playerSpyder:setWeaponTubeDirection(1, 60)			--front right (vs left)
	playerSpyder:setWeaponTubeDirection(2,  0)			--front (vs right)
	playerSpyder:setWeaponTubeDirection(3,240)			--rear left (vs right)
	playerSpyder:setWeaponTubeDirection(4,120)			--rear right (vs rear)
	playerSpyder:setWeaponTubeDirection(5,180)			--rear (vs none)
	playerSpyder:setWeaponTubeExclusiveFor(2,"Homing")
	playerSpyder:weaponTubeAllowMissle(2,"HVLI")
	playerSpyder:setWeaponTubeExclusiveFor(4,"Homing")
	playerSpyder:weaponTubeAllowMissle(4,"HVLI")
	playerSpyder:weaponTubeAllowMissle(4,"EMP")
	playerSpyder:weaponTubeAllowMissle(4,"Nuke")
	playerSpyder:setWeaponTubeExclusiveFor(5,"Mine")
end
function createPlayerShipSpinstar()
	playerSpinStar = PlayerSpaceship():setTemplate("Atlantis"):setFaction("Human Navy"):setCallSign("Spinstar")
	playerSpinStar:setTypeName("Proto-Atlantis")
	playerSpinStar.spine_request = false
	playerSpinStar.spine_charge = true
	playerSpinStar:setRepairCrewCount(4)				--more repair crew (vs 3)
	playerSpinStar:setImpulseMaxSpeed(70)				--slower impulse max (vs 90)
	playerSpinStar:setRotationMaxSpeed(14)				--faster spin (vs 10)
	playerSpinStar:setJumpDrive(false)					--no Jump
	playerSpinStar:setWarpDrive(true)					--add warp
	playerSpinStar:setHullMax(200)						--weaker hull (vs 250)
	playerSpinStar:setHull(200)							
	playerSpinStar:setShieldsMax(150,150)				--weaker shields (vs 200)
	playerSpinStar:setShields(150,150)
	playerSpinStar:setWeaponTubeCount(3)				--fewer tubes
	playerSpinStar:setWeaponTubeDirection(0,-90)		--one left
	playerSpinStar:weaponTubeDisallowMissle(0,"Mine")	--no broadside mine
	playerSpinStar:setWeaponTubeDirection(1,90)			--one right
	playerSpinStar:weaponTubeDisallowMissle(1,"Mine")	--no broadside mine
	playerSpinStar:setWeaponTubeDirection(2,180)		--one back
	playerSpinStar:setWeaponTubeExclusiveFor(2,"Mine")	--Mine only
end
function spinalAddBeamNow()
	playerSpinStar.spine_request = true
	playerSpinStar:setBeamWeapon(4, 5, 0, 2500.0, 0.1, 8)
end
function spinalShip(delta)
	local spine_status_info = "Spine"
	if playerSpinStar ~= nil and playerSpinStar:isValid() then
		if playerSpinStar.spine_request then	--the button has been clicked
			if playerSpinStar.spinal_countdown == nil then	
				playerSpinStar.spinal_countdown = delta + 5	--set firing time limit
			end
			if playerSpinStar.spine_button ~= nil then	--remove button while firing
				playerSpinStar:removeCustom(playerSpinStar.spine_button)
				playerSpinStar.spine_button = nil
			end
			if playerSpinStar.spine_button_tactical ~= nil then
				playerSpinStar:removeCustom(playerSpinStar.spine_button_tactical)
				playerSpinStar.spine_button_tactical = nil
			end
			playerSpinStar.spinal_countdown = playerSpinStar.spinal_countdown - delta
			if playerSpinStar.spinal_countdown < 0 then	--firing time limit expired
				playerSpinStar:setBeamWeapon(4, 5, 0, 0.0, 0.1, 8)
				playerSpinStar.spine_request = false
				playerSpinStar.spine_charge = false
				playerSpinStar.spinal_countdown = nil
			else	--show firing time limit on weapons or tactical consoles
				spine_status_info = string.format(_("-tabWeapons&Tactical", "%s: %i"),spine_status_info,math.ceil(playerSpinStar.spinal_countdown))
				if playerSpinStar:hasPlayerAtPosition("Weapons") then
					playerSpinStar.spine_status_info = "spine_status_info"
					playerSpinStar:addCustomInfo("Weapons",playerSpinStar.spine_status_info,spine_status_info)
				end
				if playerSpinStar:hasPlayerAtPosition("Tactical") then
					playerSpinStar.spine_status_info_tactical = "spine_status_info_tactical"
					playerSpinStar:addCustomInfo("Weapons",playerSpinStar.spine_status_info_tactical,spine_status_info)
				end
			end
		else	--the button has not been clicked
			if playerSpinStar.spine_charge then	--weapon is charged up
				if playerSpinStar.spine_status_info ~= nil then	--remove charge status
					playerSpinStar:removeCustom(playerSpinStar.spine_status_info)
					playerSpinStar.spine_status_info = nil
				end
				if playerSpinStar.spine_status_info_tactical ~= nil then
					playerSpinStar:removeCustom(playerSpinStar.spine_status_info_tactical)
					playerSpinStar.spine_status_info_tactical = nil
				end
				if playerSpinStar.spine_button == nil then	--add fire button to weapons and/or tactical consoles
					if playerSpinStar:hasPlayerAtPosition("Weapons") then
						playerSpinStar.spine_button = "spine_button"
						playerSpinStar:addCustomButton("Weapons",playerSpinStar.spine_button,_("-buttonWeapons", "Spinal Beam"), spinalAddBeamNow)
					end
				end
				if playerSpinStar.spine_button_tactical == nil then
					if playerSpinStar:hasPlayerAtPosition("Tactical") then
						playerSpinStar.spine_button_tactical = "spine_button_tactical"
						playerSpinStar:addCustomButton("Tactical",playerSpinStar.spine_button_tactical,_("-buttonTactical", "Spinal Beam"), spinalAddBeamNow)
					end
				end
			else	--weapon is not charged
				if playerSpinStar.charge_countdown == nil then	
					playerSpinStar.charge_countdown = delta + 30	--set charge time
				end
				playerSpinStar.charge_countdown = playerSpinStar.charge_countdown - delta
				if playerSpinStar.charge_countdown < 0 then	--charge time completed
					playerSpinStar.spine_charge = true
					playerSpinStar.charge_countdown = nil
				else	--show charge time on weapons or tactical consoles
					spine_status_info = string.format(_("-tabWeapons", "%s Charging: %i"),spine_status_info,math.ceil(playerSpinStar.charge_countdown))
					if playerSpinStar:hasPlayerAtPosition("Weapons") then
						playerSpinStar.spine_status_info = "spine_status_info"
						playerSpinStar:addCustomInfo("Weapons",playerSpinStar.spine_status_info,spine_status_info)
					end
					if playerSpinStar:hasPlayerAtPosition("Tactical") then
						playerSpinStar.spine_status_info_tactical = "spine_status_info_tactical"
						playerSpinStar:addCustomInfo("Weapons",playerSpinStar.spine_status_info_tactical,spine_status_info)
					end
				end	--countdown handling
			end	--spine weapon charge handling
		end	--spine button handling
	end	--valid player ship handling
end
--------------------------------
-- Station creation functions --
--------------------------------
function placeBFStation(x,y,name,faction,size)
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
--------------------------------------
-- Set up enemy and friendly fleets --
--------------------------------------
function setFleets()
	--enemy defensive fleets
	local enemyResource = 300 + enemy_power*200
	enemyFleetList = {}
	enemyDefensiveFleetList = {}
	enemyFleet1base = kraylorStationList[math.random(1,#kraylorStationList)]
	local f1bx, f1by = enemyFleet1base:getPosition()
	local enemyFleet1, enemyFleet1Power = spawnEnemyFleet(f1bx, f1by, random(90,130))
	for i, enemy in ipairs(enemyFleet1) do
		enemy:orderDefendTarget(enemyFleet1base)
	end
	table.insert(enemyFleetList,enemyFleet1)
	table.insert(enemyDefensiveFleetList,enemyFleet1)
	intelGatherArtifacts[1]:setDescriptions(_("scienceDescription-artifact", "Scan to gather intelligence"),string.format(_("scienceDescription-artifact", "Enemy fleet detected in sector %s"),enemyFleet1base:getSectorName()))
	intelGatherArtifacts[1].startSector = enemyFleet1base:getSectorName()
	enemyResource = enemyResource - enemyFleet1Power
	if enemyResource > 120 then
		enemyFleet2Power = random(80,120)
	else
		enemyFleet2Power = 120
	end
	repeat
		candidate = kraylorStationList[math.random(1,#kraylorStationList)]
		if candidate ~= enemyFleet1base then
			enemyFleet2base = candidate
		end
	until(enemyFleet2base ~= nil)
	local f2bx, f2by = enemyFleet2base:getPosition()
	enemyFleet2, enemyFleet2Power = spawnEnemyFleet(f2bx, f2by, enemyFleet2Power)
	for i, enemy in ipairs(enemyFleet2) do
		enemy:orderDefendTarget(enemyFleet2base)
	end
	table.insert(enemyFleetList,enemyFleet2)
	table.insert(enemyDefensiveFleetList,enemyFleet2)
	intelGatherArtifacts[2]:setDescriptions(_("scienceDescription-artifact", "Scan to gather intelligence"),string.format(_("scienceDescription-artifact", "Enemy fleet detected in sector %s"),enemyFleet2base:getSectorName()))
	intelGatherArtifacts[2].startSector = enemyFleet2base:getSectorName()
	enemyResource = enemyResource - enemyFleet2Power
	if enemyResource > 120 then
		enemyFleet3Power = random(80,120)
	else
		enemyFleet3Power = 120
	end
	repeat
		candidate = kraylorStationList[math.random(1,#kraylorStationList)]
		if candidate ~= enemyFleet1base and candidate ~= enemyFleet2base then
			enemyFleet3base = candidate
		end
	until(enemyFleet3base ~= nil)
	local f3bx, f3by = enemyFleet3base:getPosition()
	enemyFleet3, enemyFleet3Power = spawnEnemyFleet(f3bx, f3by, enemyFleet3Power)
	for i, enemy in ipairs(enemyFleet3) do
		enemy:orderDefendTarget(enemyFleet3base)
	end
	table.insert(enemyFleetList,enemyFleet3)
	table.insert(enemyDefensiveFleetList,enemyFleet3)
	intelGatherArtifacts[3]:setDescriptions(_("scienceDescription-artifact", "Scan to gather intelligence"),string.format(_("scienceDescription-artifact", "Enemy fleet detected in sector %s"),enemyFleet3base:getSectorName()))
	intelGatherArtifacts[3].startSector = enemyFleet3base:getSectorName()
	enemyResource = enemyResource - enemyFleet3Power
	repeat
		candidate = kraylorStationList[math.random(1,#kraylorStationList)]
		if candidate ~= enemyFleet1base and candidate ~= enemyFleet2base and candidate ~= enemyFleet3base then
			enemyFleet4base = candidate
		end
	until(enemyFleet4base ~= nil)
	local f4bx, f4by = enemyFleet4base:getPosition()
	enemyFleet4, enemyFleet4Power = spawnEnemyFleet(f4bx, f4by, enemyResource/2)
	for i, enemy in ipairs(enemyFleet4) do
		enemy:orderDefendTarget(enemyFleet4base)
	end
	table.insert(enemyFleetList,enemyFleet4)
	table.insert(enemyDefensiveFleetList,enemyFleet4)
	intelGatherArtifacts[4]:setDescriptions(_("scienceDescription-artifact", "Scan to gather intelligence"),string.format(_("scienceDescription-artifact", "Enemy fleet detected in sector %s"),enemyFleet4base:getSectorName()))
	intelGatherArtifacts[4].startSector = enemyFleet4base:getSectorName()
	enemyResource = enemyResource - enemyFleet4Power
	repeat
		candidate = kraylorStationList[math.random(1,#kraylorStationList)]
		if candidate ~= enemyFleet1base and candidate ~= enemyFleet2base and candidate ~= enemyFleet3base and candidate ~= enemyFleet4base then
			enemyFleet5base = candidate
		end
	until(enemyFleet5base ~= nil)
	local f5bx, f5by = enemyFleet5base:getPosition()
	enemyFleet5, enemyFleet5Power = spawnEnemyFleet(f5bx, f5by, enemyResource)
	for i, enemy in ipairs(enemyFleet5) do
		enemy:orderDefendTarget(enemyFleet5base)
	end
	table.insert(enemyFleetList,enemyFleet5)
	table.insert(enemyDefensiveFleetList,enemyFleet5)
	intelGatherArtifacts[5]:setDescriptions(_("scienceDescription-artifact", "Scan to gather intelligence"),string.format(_("scienceDescription-artifact", "Enemy fleet detected in sector %s"),enemyFleet5base:getSectorName()))
	intelGatherArtifacts[5].startSector = enemyFleet5base:getSectorName()
	
	--friendly defensive fleets
	
	local friendlyResource = 500
	friendlyFleetList = {}
	friendlyHelperFleet = {}
	friendlyDefensiveFleetList = {}
	table.insert(friendlyFleetList,friendlyHelperFleet)
	friendlyFleet1base = humanStationList[math.random(1,#humanStationList)]
	f1bx, f1by = friendlyFleet1base:getPosition()
	local fleetName = friendlyFleet1base:getCallSign() .. " defensive fleet"
	local friendlyFleet1, friendlyFleet1Power = spawnEnemyFleet(f1bx, f1by, random(90,130), 1, "Human Navy", fleetName)
	for i, enemy in ipairs(friendlyFleet1) do
		enemy:orderDefendTarget(friendlyFleet1base):setScanned(true)
	end
	table.insert(friendlyFleetList,friendlyFleet1)
	friendlyDefensiveFleetList[fleetName] = friendlyFleet1
	friendlyResource = friendlyResource - friendlyFleet1Power
	if friendlyResource > 120 then
		friendlyFleet2Power = random(80,120)
	else
		friendlyFleet2Power = 120
	end
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		if candidate ~= friendlyFleet1base then
			friendlyFleet2base = candidate
		end
	until(friendlyFleet2base ~= nil)
	f2bx, f2by = friendlyFleet2base:getPosition()
	fleetName = friendlyFleet2base:getCallSign() .. " defensive fleet"
	friendlyFleet2, friendlyFleet2Power = spawnEnemyFleet(f2bx, f2by, friendlyFleet2Power, 1, "Human Navy", fleetName)
	for i, enemy in ipairs(friendlyFleet2) do
		enemy:orderDefendTarget(friendlyFleet2base):setScanned(true)
	end
	table.insert(friendlyFleetList,friendlyFleet2)
	friendlyDefensiveFleetList[fleetName] = friendlyFleet2
	friendlyResource = friendlyResource - friendlyFleet2Power
	if friendlyResource > 120 then
		friendlyFleet3Power = random(80,120)
	else
		friendlyFleet3Power = 120
	end
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		if candidate ~= friendlyFleet1base and candidate ~= friendlyFleet2base then
			friendlyFleet3base = candidate
		end
	until(friendlyFleet3base ~= nil)
	f3bx, f3by = friendlyFleet3base:getPosition()
	fleetName = friendlyFleet3base:getCallSign() .. " defensive fleet"
	friendlyFleet3, friendlyFleet3Power = spawnEnemyFleet(f3bx, f3by, friendlyFleet3Power, 1, "Human Navy", fleetName)
	for i, enemy in ipairs(friendlyFleet3) do
		enemy:orderDefendTarget(friendlyFleet3base):setScanned(true)
	end
	table.insert(friendlyFleetList,friendlyFleet3)
	friendlyDefensiveFleetList[fleetName] = friendlyFleet3
	friendlyResource = friendlyResource - friendlyFleet3Power
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		if candidate ~= friendlyFleet1base and candidate ~= friendlyFleet2base and candidate ~= friendlyFleet3base then
			friendlyFleet4base = candidate
		end
	until(friendlyFleet4base ~= nil)
	f4bx, f4by = friendlyFleet4base:getPosition()
	fleetName = friendlyFleet4base:getCallSign() .. " defensive fleet"
	friendlyFleet4, friendlyFleet4Power = spawnEnemyFleet(f4bx, f4by, friendlyResource/2, 1, "Human Navy", fleetName)
	for i, enemy in ipairs(friendlyFleet4) do
		enemy:orderDefendTarget(friendlyFleet4base):setScanned(true)
	end
	table.insert(friendlyFleetList,friendlyFleet4)
	friendlyDefensiveFleetList[fleetName] = friendlyFleet4
	friendlyResource = friendlyResource - friendlyFleet4Power
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		if candidate ~= friendlyFleet1base and candidate ~= friendlyFleet2base and candidate ~= friendlyFleet3base and candidate ~= friendlyFleet4base then
			friendlyFleet5base = candidate
		end
	until(friendlyFleet5base ~= nil)
	f5bx, f5by = friendlyFleet5base:getPosition()
	fleetName = friendlyFleet5base:getCallSign() .. " defensive fleet"
	friendlyFleet5, friendlyFleet5Power = spawnEnemyFleet(f5bx, f5by, friendlyResource, 1, "Human Navy", fleetName)
	for i, enemy in ipairs(friendlyFleet5) do
		enemy:orderDefendTarget(friendlyFleet5base):setScanned(true)
	end
	table.insert(friendlyFleetList,friendlyFleet5)
	friendlyDefensiveFleetList[fleetName] = friendlyFleet5
	for i, station in ipairs(humanStationList) do
		local station_name = station:getCallSign()
		if friendlyFleetList[station_name] == nil then
			if random(1,100) < (70 - (20*enemy_power)) then
				station.comms_data.idle_defense_fleet = {
					DF1 = "MT52 Hornet",
					DF2 = "MT52 Hornet",
					DF3 = "Adder MK5",
					DF4 = "Adder MK5",
					DF5 = "Phobos T3",
				}
			end
		end
	end
end
function spawnEnemyFleet(xOrigin, yOrigin, power, danger, enemyFaction, fleetName, shape)
	if enemyFaction == nil then
		enemyFaction = "Kraylor"
	end
	if danger == nil then 
		danger = 1
	end
	local enemyStrength = math.max(power * danger * enemy_power, 5)
	local enemy_position = 0
	local sp = irandom(400,900)			--random spacing of spawned group
	if shape == nil then
		shape = "square"
		if random(1,100) < 50 then
			shape = "hexagonal"
		end
	end
	local enemyList = {}
	template_pool_size = 10
	local template_pool = getTemplatePool(enemyStrength)
	if #template_pool < 1 then
		addGMMessage(_("msgGM", "Empty Template pool: fix excludes or other criteria"))
		return enemyList
	end
	template_pool_size = 5
	local fleetPower = 0
	local prefix = generateCallSignPrefix(1)
	while enemyStrength > 0 do
		local selected_template = template_pool[math.random(1,#template_pool)]
		fleetPower = fleetPower + ship_template[selected_template].strength
		local ship = ship_template[selected_template].create(enemyFaction,selected_template)
		ship:setCallSign(generateCallSign(nil,enemyFaction))
		if enemyFaction == "Kraylor" then
			rawKraylorShipStrength = rawKraylorShipStrength + ship_template[selected_template].strength
			ship:onDestroyed(enemyVesselDestroyed)
		elseif enemyFaction == "Human Navy" then
			rawHumanShipStrength = rawHumanShipStrength + ship_template[selected_template].strength
			ship:onDestroyed(friendlyVesselDestroyed)
		end
		enemy_position = enemy_position + 1
		if shape == "none" or shape == "pyramid" or shape == "ambush" then
			ship:setPosition(xOrigin,yOrigin)
		else
			ship:setPosition(xOrigin + formation_delta[shape].x[enemy_position] * sp, yOrigin + formation_delta[shape].y[enemy_position] * sp)
		end
		ship:setCommsScript(""):setCommsFunction(commsShip)
		if fleetName ~= nil then
			ship.fleet = fleetName
		end
		table.insert(enemyList, ship)
		ship:setCallSign(generateCallSign(nil,enemyFaction))
		enemyStrength = enemyStrength - ship_template[selected_template].strength
	end
	local increment = 360/#enemyList
	local angle = random(0,360)
	for i, enemy in ipairs(enemyList) do
		setCirclePos(enemy,xOrigin,yOrigin,angle,1500)
		enemy:setRotation(angle)
		angle = angle + increment
	end
	fleetPower = math.max(fleetPower/danger/enemy_power, 5)
	return enemyList, fleetPower
end
--------------------------------------------------
-- Optional mission initialization and routines --
--------------------------------------------------
function chooseUpgradeBase()
	local upgradeBase = nil
	local candidate = humanStationList[math.random(1,#humanStationList)]
	local ctd = candidate.comms_data
	local goodCount = 0
	local missionAttemptCount = 0
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		ctd = candidate.comms_data
		if candidate ~= nil and candidate:isValid() and not inUpgradeList(candidate) then
			for good, goodData in pairs(ctd.goods) do
				goodCount = goodCount + 1
			end
			if goodCount > 0 then
				for good, goodData in pairs(ctd.goods) do
					if good ~= "food" and good ~= "medicine" then
						upgradeBase = candidate
					end
				end
			end
		end
		missionAttemptCount = missionAttemptCount + 1
	until(upgradeBase ~= nil or missionAttemptCount > repeatExitBoundary)
	if upgradeBase ~= nil then
		table.insert(upgradeBaseList,upgradeBase)
	end
	return upgradeBase
end
function inUpgradeList(station)
	if #upgradeBaseList < 1 then
		return false
	else
		for i=1,#upgradeBaseList do
			if station == upgradeBaseList[i] then
				return true
			end
		end
		return false
	end
end
function chooseUpgradeGoodBase(upgradeBase)
	if optionalMissionDiagnostic then print("in upgrade good base") end
	if optionalMissionDiagnostic then print("upgrade base: " .. upgradeBase:getCallSign()) end
	local upgradeGoodBase = nil
	local upgradeGood = nil
	local matchAway = nil
	local candidate = humanStationList[math.random(1,#humanStationList)]
	local ctd = candidate.comms_data
	local goodCount = 0
	local missionAttemptCount = 0
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		if optionalMissionDiagnostic then print("candidate: " .. candidate:getCallSign()) end
		ctd = candidate.comms_data
		if candidate ~= nil and candidate:isValid() and candidate ~= upgradeBase then
			if optionalMissionDiagnostic then print("valid candidate") end
			goodCount = 0
			for good, goodData in pairs(ctd.goods) do
				goodCount = goodCount + 1
			end
			if goodCount > 0 then
				if optionalMissionDiagnostic then print("candidate has goods") end
				upgradeGoodBase = candidate
				for good, goodData in pairs(ctd.goods) do
					upgradeGood = good
					matchAway = false
					if good == "food" or good == "medicine" then
						if optionalMissionDiagnostic then print("skip food or medicine") end
						matchAway = true
					else
						for upgradeBaseGood, upgradeBaseGoodData in pairs(upgradeBase.comms_data.goods) do
--							print(string.format("upgrade base good: %s",upgradeBaseGood))
							if good == upgradeBaseGood then
								if optionalMissionDiagnostic then print("matched upgrade base good, exit loop") end
								matchAway = true
								break
							end
						end
					end
					if not matchAway then 
						if optionalMissionDiagnostic then print("base and good qualifies: is not food or medicine and does not match upgrade base") end
						break 
					end
				end
			end
		end
		missionAttemptCount = missionAttemptCount + 1
	until(not matchAway or missionAttemptCount > repeatExitBoundary)
	if matchAway then
		if optionalMissionDiagnostic then print("did not find qualifying good and base") end
		return nil
	else
		if optionalMissionDiagnostic then print("found qualifying good and base") end
		return upgradeGood, upgradeGoodBase
	end
end
function setOptionalMissions()
	--	faster beams
	local missionAttemptCount = 0
	local goodCount = 0
	local matchAway = false
	local candidate = humanStationList[math.random(1,#humanStationList)]
	local ctd = candidate.comms_data
	upgradeBaseList = {}
	beamTimeBase = chooseUpgradeBase()
	if beamTimeBase ~= nil then
		beamTimeGood, beamTimeGoodBase = chooseUpgradeGoodBase(beamTimeBase)
		beamTimeBase.comms_data.character = "Horace Grayson"
		beamTimeBase.comms_data.characterDescription = _("characterInfo-comms", "He dabbles in ship system innovations. He's been working on improving beam weapons by reducing the amount of time between firing. I hear he's already installed some improvements on ships that have docked here previously")
		beamTimeBase.comms_data.characterFunction = "shrinkBeamCycle"
		beamTimeBase.comms_data.characterShort = _("scienceDB","May reduce beam cycle time")
		if beamTimeGood == nil then
			beamTimeBase.comms_data.characterGood = vapor_goods[math.random(1,#vapor_goods)]			
		else
			beamTimeBase.comms_data.characterGood = beamTimeGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= beamTimeBase and candidate.comms_data.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.comms_data.gossip = string.format(_("gossip-comms", "I heard there's a guy named %s that can fix ship beam systems up so that they shoot faster. He lives out on %s in %s. He won't charge you much, but it won't be free."),beamTimeBase.comms_data.character,beamTimeBase:getCallSign(),beamTimeBase:getSectorName())
			end
		end
	end
	if optionalMissionDiagnostic then
		if beamTimeBase ~= nil then
			print(string.format("beam time: Base: %s, Sector: %s",beamTimeBase:getCallSign(),beamTimeBase:getSectorName()))
		else
			print("beam time: no base")
		end
		if beamTimeGoodBase ~= nil and beamTimeGood ~= nil then
			print(string.format("  Good: %s, Good Base: %s in %s",beamTimeGood,beamTimeGoodBase:getCallSign(),beamTimeGoodBase:getSectorName()))
		else
			print("  no good defined")
		end
		if clueStation ~= nil then
			print(string.format("  Clue Base: %s in %s",clueStation:getCallSign(),clueStation:getSectorName()))
		else
			print("  no clue base defined")
		end
	end
	--	spin faster
	spinBase = chooseUpgradeBase()
	if spinBase ~= nil then
		spinGood, spinGoodBase = chooseUpgradeGoodBase(spinBase)
		spinBase.comms_data.character = "Emily Patel"
		spinBase.comms_data.characterDescription = _("characterInfo-comms", "She tinkers with ship systems like engines and thrusters. She's consulted with the military on tuning spin time by increasing thruster power. She's got prototypes that are awaiting formal military approval before installation")
		spinBase.comms_data.characterFunction = "increaseSpin"
		spinBase.comms_data.characterShort = _("scienceDB","May improve maneuverability")
		if spinGood == nil then
			spinBase.comms_data.characterGood = vapor_goods[math.random(1,#vapor_goods)]			
		else
			spinBase.comms_data.characterGood = spinGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= spinBase and candidate.comms_data.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.comms_data.gossip = string.format(_("gossip-comms", "My friend, %s recently quit her job as a ship maintenance technician to set up this side gig. She's been improving ship systems and she's pretty good at it. She set up shop on %s in %s. I hear she's even lining up a contract with the navy for her improvements."),spinBase.comms_data.character,spinBase:getCallSign(),spinBase:getSectorName())
			end
		end
	end
	if optionalMissionDiagnostic then
		if spinBase ~= nil then
			print(string.format("spin: Base: %s, Sector: %s",spinBase:getCallSign(),spinBase:getSectorName()))
		else
			print("spin: no base")
		end
		if spinGoodBase ~= nil and spinGood ~= nil then
			print(string.format("  Good: %s, Good Base: %s in %s",spinGood,spinGoodBase:getCallSign(),spinGoodBase:getSectorName()))
		else
			print("  no good defined")
		end
		if clueStation ~= nil then
			print(string.format("  Clue Base: %s in %s",clueStation:getCallSign(),clueStation:getSectorName()))
		else
			print("  no clue base defined")
		end
	end
	--	extra missile tube
	auxTubeBase = chooseUpgradeBase()
	if auxTubeBase ~= nil then
		auxTubeGood, auxTubeGoodBase = chooseUpgradeGoodBase(auxTubeBase)
		auxTubeBase.comms_data.character = "Fred McLassiter"
		auxTubeBase.comms_data.characterDescription = _("characterInfo-comms", "He specializes in miniaturization of weapons systems. He's come up with a way to add a missile tube and some missiles to any ship regardless of size or configuration")
		auxTubeBase.comms_data.characterFunction = "addAuxTube"
		auxTubeBase.comms_data.characterShort = _("scienceDB","May add a missile tube")
		if auxTubeGood == nil then
			auxTubeBase.comms_data.characterGood = vapor_goods[math.random(1,#vapor_goods)]			
		else
			auxTubeBase.comms_data.characterGood = auxTubeGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= auxTubeBase and candidate.comms_data.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.comms_data.gossip = string.format(_("gossip-comms", "There's this guy, %s out on %s in %s that can add a missile tube to your ship. He even added one to my cousin's souped up freighter. You should see the new paint job: amusingly phallic"),auxTubeBase.comms_data.character,auxTubeBase:getCallSign(),auxTubeBase:getSectorName())
			end
		end
	end
	if optionalMissionDiagnostic then
		if auxTubeBase ~= nil then
			print(string.format("aux tube: Base: %s, Sector: %s",auxTubeBase:getCallSign(),auxTubeBase:getSectorName()))
		else
			print("aux tube: no base")
		end
		if auxTubeGoodBase ~= nil and auxTubeGood ~= nil then
			print(string.format("  Good: %s, Good Base: %s in %s",auxTubeGood,auxTubeGoodBase:getCallSign(),auxTubeGoodBase:getSectorName()))
		else
			print("  no good defined")
		end
		if clueStation ~= nil then
			print(string.format("  Clue Base: %s in %s",clueStation:getCallSign(),clueStation:getSectorName()))
		else
			print("  no clue base defined")
		end
	end
	--	cooler beam weapon firing
	coolBeamBase = chooseUpgradeBase()
	if coolBeamBase ~= nil then
		coolBeamGood, coolBeamGoodBase = chooseUpgradeGoodBase(coolBeamBase)
		coolBeamBase.comms_data.character = "Dorothy Ly"
		coolBeamBase.comms_data.characterDescription = _("characterInfo-comms", "She developed this technique for cooling beam systems so that they can be fired more often without burning out")
		coolBeamBase.comms_data.characterFunction = "coolBeam"
		coolBeamBase.comms_data.characterShort = _("scienceDB","May provide beam cooling upgrade")
		if coolBeamGood == nil then
			coolBeamBase.comms_data.characterGood = vapor_goods[math.random(1,#vapor_goods)]			
		else
			coolBeamBase.comms_data.characterGood = coolBeamGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= coolBeamBase and candidate.comms_data.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.comms_data.gossip = string.format(_("gossip-comms", "There's this girl on %s in %s. She is hot. Her name is %s. When I say she is hot, I mean she has a way of keeping your beam weapons from excessive heat."),coolBeamBase:getCallSign(),coolBeamBase:getSectorName(),coolBeamBase.comms_data.character)
			end
		end
	end
	if optionalMissionDiagnostic then
		if coolBeamBase ~= nil then
			print(string.format("cool beam: Base: %s, Sector: %s",coolBeamBase:getCallSign(),coolBeamBase:getSectorName()))
		else
			print("cool beam: no base")
		end
		if coolBeamGoodBase ~= nil and coolBeamGood ~= nil then
			print(string.format("  Good: %s, Good Base: %s in %s",coolBeamGood,coolBeamGoodBase:getCallSign(),coolBeamGoodBase:getSectorName()))
		else
			print("  no good defined")
		end
		if clueStation ~= nil then
			print(string.format("  Clue Base: %s in %s",clueStation:getCallSign(),clueStation:getSectorName()))
		else
			print("  no clue base defined")
		end
	end
	--	longer beam range
	longerBeamBase = chooseUpgradeBase()
	if longerBeamBase ~= nil then
		longerBeamGood, longerBeamGoodBase = chooseUpgradeGoodBase(longerBeamBase)
		longerBeamBase.comms_data.character = "Gerald Cook"
		longerBeamBase.comms_data.characterDescription = _("characterInfo-comms", "He knows how to modify beam systems to extend their range")
		longerBeamBase.comms_data.characterFunction = "longerBeam"
		longerBeamBase.comms_data.characterShort = _("scienceDB","May increase beam range")
		if longerBeamGood == nil then
			longerBeamBase.comms_data.characterGood = vapor_goods[math.random(1,#vapor_goods)]			
		else
			longerBeamBase.comms_data.characterGood = longerBeamGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= longerBeamBase and candidate.comms_data.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.comms_data.gossip = string.format(_("gossip-comms", "Do you know about %s? He can extend the range of your beam weapons. He's on %s in %s"),longerBeamBase.comms_data.character,longerBeamBase:getCallSign(),longerBeamBase:getSectorName())
			end
		end
	end
	if optionalMissionDiagnostic then
		if longerBeamBase ~= nil then
			print(string.format("longer beam: Base: %s, Sector: %s",longerBeamBase:getCallSign(),longerBeamBase:getSectorName()))
		else
			print("longer beam: no base")
		end
		if longerBeamGoodBase ~= nil and longerBeamGood ~= nil then
			print(string.format("  Good: %s, Good Base: %s in %s",longerBeamGood,longerBeamGoodBase:getCallSign(),longerBeamGoodBase:getSectorName()))
		else
			print("  no good defined")
		end
		if clueStation ~= nil then
			print(string.format("  Clue Base: %s in %s",clueStation:getCallSign(),clueStation:getSectorName()))
		else
			print("  no clue base defined")
		end
	end
	--	increased beam damage
	damageBeamBase = chooseUpgradeBase()
	if damageBeamBase ~= nil then
		damageBeamGood, damageBeamGoodBase = chooseUpgradeGoodBase(damageBeamBase)
		damageBeamBase.comms_data.character = "Sally Jenkins"
		damageBeamBase.comms_data.characterDescription = _("characterInfo-comms", "She can make your beams hit harder")
		damageBeamBase.comms_data.characterFunction = "damageBeam"
		damageBeamBase.comms_data.characterShort = _("scienceDB","May increase damage by beams")
		if damageBeamGood == nil then
			damageBeamBase.comms_data.characterGood = vapor_goods[math.random(1,#vapor_goods)]			
		else
			damageBeamBase.comms_data.characterGood = damageBeamGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= damageBeamBase and candidate.comms_data.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.comms_data.gossip = string.format(_("gossip-comms", "You should visit %s in %s. There's a specialist in beam technology that can increase the damage done by your beams. Her name is %s"),damageBeamBase:getCallSign(),damageBeamBase:getSectorName(),damageBeamBase.comms_data.character)
			end
		end
	end
	if optionalMissionDiagnostic then
		if damageBeamBase ~= nil then
			print(string.format("more damaging beam: Base: %s, Sector: %s",damageBeamBase:getCallSign(),damageBeamBase:getSectorName()))
		else
			print("more damaging beam: no base")
		end
		if damageBeamGoodBase ~= nil and damageBeamGood ~= nil then
			print(string.format("  Good: %s, Good Base: %s in %s",damageBeamGood,damageBeamGoodBase:getCallSign(),damageBeamGoodBase:getSectorName()))
		else
			print("  no good defined")
		end
		if clueStation ~= nil then
			print(string.format("  Clue Base: %s in %s",clueStation:getCallSign(),clueStation:getSectorName()))
		else
			print("  no clue base defined")
		end
	end
	--	increased maximum missile storage capacity
	moreMissilesBase = chooseUpgradeBase()
	if moreMissilesBase ~= nil then
		moreMissilesGood, moreMissilesGoodBase = chooseUpgradeGoodBase(moreMissilesBase)
		moreMissilesBase.comms_data.character = "Anh Dung Ly"
		moreMissilesBase.comms_data.characterDescription = _("characterInfo-comms", "He can fit more missiles aboard your ship")
		moreMissilesBase.comms_data.characterFunction = "moreMissiles"
		moreMissilesBase.comms_data.characterShort = _("scienceDB","May increase missile capacity")
		if moreMissilesGood == nil then
			moreMissilesBase.comms_data.characterGood = vapor_goods[math.random(1,#vapor_goods)]			
		else
			moreMissilesBase.comms_data.characterGood = moreMissilesGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= moreMissilesBase and candidate.comms_data.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.comms_data.gossip = string.format(_("gossip-comms", "Want to store more missiles on your ship? Talk to %s on station %s in %s. He can retrain your missile loaders and missile storage automation such that you will be able to store more missiles"),moreMissilesBase.comms_data.character,moreMissilesBase:getCallSign(),moreMissilesBase:getSectorName())
			end
		end
	end
	if optionalMissionDiagnostic then
		if moreMissilesBase ~= nil then
			print(string.format("more missiles: Base: %s, Sector: %s",moreMissilesBase:getCallSign(),moreMissilesBase:getSectorName()))
		else
			print("more missiles: no base")
		end
		if moreMissilesGoodBase ~= nil and moreMissilesGood ~= nil then
			print(string.format("  Good: %s, Good Base: %s in %s",moreMissilesGood,moreMissilesGoodBase:getCallSign(),moreMissilesGoodBase:getSectorName()))
		else
			print("  no good defined")
		end
		if clueStation ~= nil then
			print(string.format("  Clue Base: %s in %s",clueStation:getCallSign(),clueStation:getSectorName()))
		else
			print("  no clue base defined")
		end
	end
	--	faster impulse
	fasterImpulseBase = chooseUpgradeBase()
	if fasterImpulseBase ~= nil then
		fasterImpulseGood, fasterImpulseGoodBase = chooseUpgradeGoodBase(fasterImpulseBase)
		fasterImpulseBase.comms_data.character = "Doralla Ognats"
		fasterImpulseBase.comms_data.characterDescription = _("characterInfo-comms", "She can soup up your impulse engines")
		fasterImpulseBase.comms_data.characterFunction = "fasterImpulse"
		fasterImpulseBase.comms_data.characterShort = _("scienceDB","May increase impulse speed")
		if fasterImpulseGood == nil then
			fasterImpulseBase.comms_data.characterGood = vapor_goods[math.random(1,#vapor_goods)]			
		else
			fasterImpulseBase.comms_data.characterGood = fasterImpulseGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= fasterImpulseBase and candidate.comms_data.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.comms_data.gossip = string.format(_("gossip-comms", "%s, an engineer/mechanic who knows propulsion systems backwards and forwards has a bay at the shipyard on %s in %s. She can give your impulse engines a significant boost to their top speed"),fasterImpulseBase.comms_data.character,fasterImpulseBase:getCallSign(),fasterImpulseBase:getSectorName())
			end
		end
	end
	if optionalMissionDiagnostic then
		if fasterImpulseBase ~= nil then
			print(string.format("faster impulse: Base: %s, Sector: %s",fasterImpulseBase:getCallSign(),fasterImpulseBase:getSectorName()))
		else
			print("faster impulse: no base")
		end
		if fasterImpulseGoodBase ~= nil and fasterImpulseGood ~= nil then
			print(string.format("  Good: %s, Good Base: %s in %s",fasterImpulseGood,fasterImpulseGoodBase:getCallSign(),fasterImpulseGoodBase:getSectorName()))
		else
			print("  no good defined")
		end
		if clueStation ~= nil then
			print(string.format("  Clue Base: %s in %s",clueStation:getCallSign(),clueStation:getSectorName()))
		else
			print("  no clue base defined")
		end
	end
	--	stronger hull
	strongerHullBase = chooseUpgradeBase()
	if strongerHullBase ~= nil then
		strongerHullGood, strongerHullGoodBase = chooseUpgradeGoodBase(strongerHullBase)
		strongerHullBase.comms_data.character = "Maduka Lawal"
		strongerHullBase.comms_data.characterDescription = _("characterInfo-comms", "He can strengthen your hull")
		strongerHullBase.comms_data.characterFunction = "strongerHull"
		strongerHullBase.comms_data.characterShort = _("scienceDB","May strengthen hull")
		if strongerHullGood ~= nil then
			strongerHullBase.comms_data.characterGood = vapor_goods[math.random(1,#vapor_goods)]			
		else
			strongerHullBase.comms_data.characterGood = strongerHullGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= strongerHullBase and candidate.comms_data.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.comms_data.gossip = string.format(_("gossip-comms", "I know of a materials specialist on %s in %s named %s. He can strengthen the hull on your ship"),strongerHullBase:getCallSign(),strongerHullBase:getSectorName(),strongerHullBase.comms_data.character)
			end
		end
	end
	if optionalMissionDiagnostic then
		if strongerHullBase ~= nil then
			print(string.format("stronger hull: Base: %s, Sector: %s",strongerHullBase:getCallSign(),strongerHullBase:getSectorName()))
		else
			print("stronger hull: no base")
		end
		if strongerHullGoodBase ~= nil and strongerHullGood ~= nil then
			print(string.format("  Good: %s, Good Base: %s in %s",strongerHullGood,strongerHullGoodBase:getCallSign(),strongerHullGoodBase:getSectorName()))
		else
			print("  no good defined")
		end
		if clueStation ~= nil then
			print(string.format("  Clue Base: %s in %s",clueStation:getCallSign(),clueStation:getSectorName()))
		else
			print("  no clue base defined")
		end
	end
	--	efficient batteries
	efficientBatteriesBase = chooseUpgradeBase()
	if efficientBatteriesBase ~= nil then
		efficientBatteriesGood, efficientBatteriesGoodBase = chooseUpgradeGoodBase(efficientBatteriesBase)
		efficientBatteriesBase.comms_data.character = "Susil Tarigan"
		efficientBatteriesBase.comms_data.characterDescription = _("characterInfo-comms", "She knows how to increase your maximum energy capacity by improving battery efficiency")
		efficientBatteriesBase.comms_data.characterFunction = "efficientBatteries"
		efficientBatteriesBase.comms_data.characterShort = _("scienceDB","May increase battery capacity")
		if efficientBatteriesGood == nil then
			efficientBatteriesBase.comms_data.characterGood = vapor_goods[math.random(1,#vapor_goods)]			
		else
			efficientBatteriesBase.comms_data.characterGood = efficientBatteriesGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= efficientBatteriesBase and candidate.comms_data.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.comms_data.gossip = string.format(_("gossip-comms", "Have you heard about %s? She's on %s in %s and she can give your ship greater energy capacity by improving your battery efficiency"),efficientBatteriesBase.comms_data.character,efficientBatteriesBase:getCallSign(),efficientBatteriesBase:getSectorName())
			end
		end
	end
	if optionalMissionDiagnostic then
		if efficientBatteriesBase ~= nil then
			print(string.format("efficient batteries: Base: %s, Sector: %s",efficientBatteriesBase:getCallSign(),efficientBatteriesBase:getSectorName()))
		else
			print("efficient batteries: no base")
		end
		if efficientBatteriesGoodBase ~= nil and efficientBatteriesGood ~= nil then
			print(string.format("  Good: %s, Good Base: %s in %s",efficientBatteriesGood,efficientBatteriesGoodBase:getCallSign(),efficientBatteriesGoodBase:getSectorName()))
		else
			print("  no good defined")
		end
		if clueStation ~= nil then
			print(string.format("  Clue Base: %s in %s",clueStation:getCallSign(),clueStation:getSectorName()))
		else
			print("  no clue base defined")
		end
	end
	--	stronger shields
	strongerShieldsBase = chooseUpgradeBase()
	if strongerShieldsBase ~= nil then
		strongerShieldsGood, strongerShieldsGoodBase = chooseUpgradeGoodBase(strongerShieldsBase)
		strongerShieldsBase.comms_data.character = "Paulo Silva"
		strongerShieldsBase.comms_data.characterDescription = _("characterInfo-comms", "He can strengthen your shields")
		strongerShieldsBase.comms_data.characterFunction = "strongerShields"
		strongerShieldsBase.comms_data.characterShort = _("scienceDB","May strengthen shields")
		if strongerShieldsGood == nil then
			strongerShieldsBase.comms_data.characterGood = vapor_goods[math.random(1,#vapor_goods)]			
		else
			strongerShieldsBase.comms_data.characterGood = strongerShieldsGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= strongerShieldsBase and candidate.comms_data.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.comms_data.gossip = string.format(_("gossip-comms", "If you stop at %s in %s, you should talk to %s. He can strengthen your shields. Trust me, it's always good to have stronger shields"),strongerShieldsBase:getCallSign(),strongerShieldsBase:getSectorName(),strongerShieldsBase.comms_data.character)
			end
		end
	end
	if optionalMissionDiagnostic then
		if strongerShieldsBase ~= nil then
			print(string.format("stronger shields: Base: %s, Sector: %s",strongerShieldsBase:getCallSign(),strongerShieldsBase:getSectorName()))
		else
			print("stronger shields: no base")
		end
		if strongerShieldsGoodBase ~= nil and strongerShieldsGood ~= nil then
			print(string.format("  Good: %s, Good Base: %s in %s",strongerShieldsGood,strongerShieldsGoodBase:getCallSign(),strongerShieldsGoodBase:getSectorName()))
		else
			print("  no good defined")
		end
		if clueStation ~= nil then
			print(string.format("  Clue Base: %s in %s",clueStation:getCallSign(),clueStation:getSectorName()))
		else
			print("  no clue base defined")
		end
	end
end
function payForUpgrade()
	if	(difficulty == 1 and treaty) or 
		(difficulty < 1 and treaty and treatyTimer > 0) or
		(difficulty > 1 and treaty) or
		(difficulty > 1 and not treaty and not targetKraylorStations) then
		return true
	else
		return false
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
						local upgrade_value = .75
						if partQuantity > 1 then
							upgrade_value = .6
							comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 2
							comms_source.cargo = comms_source.cargo + 2
						else
							comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
							comms_source.cargo = comms_source.cargo + 1
						end
						local bi = 0
						repeat
							local tempArc = comms_source:getBeamWeaponArc(bi)
							local tempDir = comms_source:getBeamWeaponDirection(bi)
							local tempRng = comms_source:getBeamWeaponRange(bi)
							local tempCyc = comms_source:getBeamWeaponCycleTime(bi)
							local tempDmg = comms_source:getBeamWeaponDamage(bi)
							comms_source:setBeamWeapon(bi,tempArc,tempDir,tempRng,tempCyc * upgrade_value,tempDmg)
							bi = bi + 1
						until(comms_source:getBeamWeaponRange(bi) < 1)
						setCommsMessage(string.format(_("upgrade-comms", "After accepting your gift, he reduced your Beam cycle time by %i%%"),math.floor((1-upgrade_value)*100)))
					else
						setCommsMessage(string.format(_("upgrade-comms", "%s requires %s for the upgrade"),ctd.character,ctd.characterGood))
					end
				else
					comms_source.shrinkBeamCycleUpgrade = "done"
					bi = 0
					repeat
						tempArc = comms_source:getBeamWeaponArc(bi)
						tempDir = comms_source:getBeamWeaponDirection(bi)
						tempRng = comms_source:getBeamWeaponRange(bi)
						tempCyc = comms_source:getBeamWeaponCycleTime(bi)
						tempDmg = comms_source:getBeamWeaponDamage(bi)
						comms_source:setBeamWeapon(bi,tempArc,tempDir,tempRng,tempCyc * .75,tempDmg)
						bi = bi + 1
					until(comms_source:getBeamWeaponRange(bi) < 1)
					setCommsMessage(string.format(_("upgrade-comms", "%s reduced your Beam cycle time by 25%% at no cost in trade with the message, 'Go get those Kraylors.'"),ctd.character))
				end
			else
				setCommsMessage(_("upgrade-comms", "Your ship type does not support a beam weapon upgrade."))				
			end
			addCommsReply(_("Back"),commsStation)
		end)
	end
end
function increaseSpin()
	if comms_source.increaseSpinUpgrade == nil then
		addCommsReply(_("upgrade-comms", "Increase spin speed"), function()
			local ctd = comms_target.comms_data
			if payForUpgrade() then
				local partQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
					partQuantity = comms_source.goods[ctd.characterGood]
				end
				if partQuantity > 0 then
					comms_source.increaseSpinUpgrade = "done"
					local upgrade_value = 1.5
					if partQuantity > 1 then
						upgrade_value = 1.8
						comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 2
						comms_source.cargo = comms_source.cargo + 2
					else
						comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
						comms_source.cargo = comms_source.cargo + 1
					end
					comms_source:setRotationMaxSpeed(comms_source:getRotationMaxSpeed()*upgrade_value)
					setCommsMessage(string.format(_("upgrade-comms", "Ship spin speed increased by %i%% after you gave %s to %s"),math.floor((upgrade_value-1)*100),ctd.characterGood,ctd.character))
				else
					setCommsMessage(string.format(_("upgrade-comms", "%s requires %s for the spin upgrade"),ctd.character,ctd.characterGood))
				end
			else
				comms_source.increaseSpinUpgrade = "done"
				comms_source:setRotationMaxSpeed(comms_source:getRotationMaxSpeed()*1.5)
				setCommsMessage(string.format(_("upgrade-comms", "%s: I increased the speed your ship spins by 50%%. Normally, I'd require %s, but seeing as you're going out to take on the Kraylors, we worked it out"),ctd.character,ctd.characterGood))
			end
			addCommsReply(_("Back"),commsStation)
		end)
	end
end
function addAuxTube()
	if comms_source.auxTubeUpgrade == nil then
		addCommsReply(_("upgrade-comms", "Add missle tube"), function()
			local ctd = comms_target.comms_data
			if payForUpgrade() then
				local luxQuantity = 0
				local partQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
					partQuantity = comms_source.goods[ctd.characterGood]
				end
				if comms_source.goods ~= nil and comms_source.goods["luxury"] ~= nil and comms_source.goods["luxury"] > 0 then
					luxQuantity = comms_source.goods[ctd.characterGood]
				end
				if partQuantity > 0 and luxQuantity > 0 then
					comms_source.auxTubeUpgrade = "done"
					local upgrade_value = 2
					if luxQuantity > 1 then
						upgrade_value = 4
						comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
						comms_source.goods["luxury"] = comms_source.goods["luxury"] - 2
						comms_source.cargo = comms_source.cargo + 3
					else
						comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
						comms_source.goods["luxury"] = comms_source.goods["luxury"] - 1
						comms_source.cargo = comms_source.cargo + 2
					end
					local originalTubes = comms_source:getWeaponTubeCount()
					local newTubes = originalTubes + 1
					comms_source:setWeaponTubeCount(newTubes)
					comms_source:setWeaponTubeExclusiveFor(originalTubes, "Homing")
					comms_source:setWeaponStorageMax("Homing", comms_source:getWeaponStorageMax("Homing") + upgrade_value)
					comms_source:setWeaponStorage("Homing", comms_source:getWeaponStorage("Homing") + upgrade_value)
					setCommsMessage(string.format(_("upgrade-comms", "%s thanks you for the %s and the luxury and installs a homing missile tube for you"),ctd.character,ctd.characterGood))
				else
					setCommsMessage(string.format(_("upgrade-comms", "%s requires %s and luxury for the missile tube"),ctd.character,ctd.characterGood))
				end
			else
				comms_source.auxTubeUpgrade = "done"
				originalTubes = comms_source:getWeaponTubeCount()
				newTubes = originalTubes + 1
				comms_source:setWeaponTubeCount(newTubes)
				comms_source:setWeaponTubeExclusiveFor(originalTubes, "Homing")
				comms_source:setWeaponStorageMax("Homing", comms_source:getWeaponStorageMax("Homing") + 2)
				comms_source:setWeaponStorage("Homing", comms_source:getWeaponStorage("Homing") + 2)
				setCommsMessage(string.format(_("upgrade-comms", "%s installs a homing missile tube for you. The %s required was requisitioned from wartime contingency supplies"),ctd.character,ctd.characterGood))
			end
			addCommsReply(_("Back"),commsStation)
		end)
	end
end
function coolBeam()
	if comms_source.coolBeamUpgrade == nil then
		addCommsReply(_("upgrade-comms", "Reduce beam heat"), function()
			local ctd = comms_target.comms_data
			if comms_source:getBeamWeaponRange(0) > 0 then
				if payForUpgrade() then
					local partQuantity = 0
					if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
						partQuantity = comms_source.goods[ctd.characterGood]
					end
					if partQuantity > 0 then
						comms_source.coolBeamUpgrade = "done"
						local upgrade_value = .5
						if partQuantity > 1 then
							upgrade_value = .4
							comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 2
							comms_source.cargo = comms_source.cargo + 2
						else
							comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
							comms_source.cargo = comms_source.cargo + 1
						end
						local bi = 0
						repeat
							comms_source:setBeamWeaponHeatPerFire(bi,comms_source:getBeamWeaponHeatPerFire(bi) * upgrade_value)
							bi = bi + 1
						until(comms_source:getBeamWeaponRange(bi) < 1)
						setCommsMessage(string.format(_("upgrade-comms", "Beam heat generation reduced by %i%%"),math.floor((1-upgrade_value)*100)))
					else
						setCommsMessage(string.format(_("upgrade-comms", "%s says she needs %s before she can cool your beams"),ctd.character,ctd.characterGood))
					end
				else
					comms_source.coolBeamUpgrade = "done"
					bi = 0
					repeat
						comms_source:setBeamWeaponHeatPerFire(bi,comms_source:getBeamWeaponHeatPerFire(bi) * 0.5)
						bi = bi + 1
					until(comms_source:getBeamWeaponRange(bi) < 1)
					setCommsMessage(string.format(_("upgrade-comms", "%s: Beam heat generation reduced by 50%%, no %s necessary. Go shoot some Kraylors for me"),ctd.character,ctd.characterGood))
				end
			else
				setCommsMessage(_("upgrade-comms", "Your ship type does not support a beam weapon upgrade."))				
			end
			addCommsReply(_("Back"),commsStation)
		end)
	end
end
function longerBeam()
	if comms_source.longerBeamUpgrade == nil then
		addCommsReply(_("upgrade-comms", "Extend beam range"), function()
			if optionalMissionDiagnostic then print("extending beam range") end
			local ctd = comms_target.comms_data
			if comms_source:getBeamWeaponRange(0) > 0 then
				if optionalMissionDiagnostic then print("ship qualifies") end
				if payForUpgrade() then
					if optionalMissionDiagnostic then print("treaty still in force") end
					local partQuantity = 0
					if comms_source.goods ~= nil then
						if comms_source.goods[ctd.characterGood] ~= nil then
							if comms_source.goods[ctd.characterGood] > 0 then
								partQuantity = comms_source.goods[ctd.characterGood]
							end
						end
					end
					if partQuantity > 0 then
						if optionalMissionDiagnostic then print("player has enough of the right goods") end
						comms_source.longerBeamUpgrade = "done"
						local upgrade_value = 1.25
						if partQuantity > 1 then
							upgrade_value = 1.4
							comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 2
							comms_source.cargo = comms_source.cargo + 2
						else
							comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
							comms_source.cargo = comms_source.cargo + 1
						end
						local bi = 0
						repeat
							local tempArc = comms_source:getBeamWeaponArc(bi)
							local tempDir = comms_source:getBeamWeaponDirection(bi)
							local tempRng = comms_source:getBeamWeaponRange(bi)
							local tempCyc = comms_source:getBeamWeaponCycleTime(bi)
							local tempDmg = comms_source:getBeamWeaponDamage(bi)
							comms_source:setBeamWeapon(bi,tempArc,tempDir,tempRng * upgrade_value,tempCyc,tempDmg)
							bi = bi + 1
						until(comms_source:getBeamWeaponRange(bi) < 1)
						if optionalMissionDiagnostic then print("beam range extended") end
						setCommsMessage(string.format(_("upgrade-comms", "%s extended your beam range by %i%% and says thanks for the %s"),ctd.character,math.floor((upgrade_value-1)*100),ctd.characterGood))
					else
						setCommsMessage(string.format(_("upgrade-comms", "%s requires %s for the upgrade"),ctd.character,ctd.characterGood))
					end
				else
					if optionalMissionDiagnostic then print("war declared") end
					comms_source.longerBeamUpgrade = "done"
					bi = 0
					repeat
						tempArc = comms_source:getBeamWeaponArc(bi)
						tempDir = comms_source:getBeamWeaponDirection(bi)
						tempRng = comms_source:getBeamWeaponRange(bi)
						tempCyc = comms_source:getBeamWeaponCycleTime(bi)
						tempDmg = comms_source:getBeamWeaponDamage(bi)
						comms_source:setBeamWeapon(bi,tempArc,tempDir,tempRng * 1.25,tempCyc,tempDmg)
						bi = bi + 1
					until(comms_source:getBeamWeaponRange(bi) < 1)
					if optionalMissionDiagnostic then print("beam range extended for free") end
					setCommsMessage(string.format(_("upgrade-comms", "%s increased your beam range by 25%% without the usual %s from your ship"),ctd.character,ctd.characterGood))
				end
			else
				setCommsMessage(_("upgrade-comms", "Your ship type does not support a beam weapon upgrade."))				
			end
			addCommsReply(_("Back"),commsStation)
		end)
	end
end
function damageBeam()
	if comms_source.damageBeamUpgrade == nil then
		addCommsReply(_("upgrade-comms", "Increase beam damage"), function()
			local ctd = comms_target.comms_data
			if comms_source:getBeamWeaponRange(0) > 0 then
				if payForUpgrade() then
					local partQuantity = 0
					if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
						partQuantity = comms_source.goods[ctd.characterGood]
					end
					if partQuantity > 0 then
						comms_source.damageBeamUpgrade = "done"
						local upgrade_value = 1.2
						if partQuantity > 1 then
							upgrade_value = 1.3
							comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 2
							comms_source.cargo = comms_source.cargo + 2
						else
							comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
							comms_source.cargo = comms_source.cargo + 1
						end
						local bi = 0
						repeat
							local tempArc = comms_source:getBeamWeaponArc(bi)
							local tempDir = comms_source:getBeamWeaponDirection(bi)
							local tempRng = comms_source:getBeamWeaponRange(bi)
							local tempCyc = comms_source:getBeamWeaponCycleTime(bi)
							local tempDmg = comms_source:getBeamWeaponDamage(bi)
							comms_source:setBeamWeapon(bi,tempArc,tempDir,tempRng,tempCyc,tempDmg*upgrade_value)
							bi = bi + 1
						until(comms_source:getBeamWeaponRange(bi) < 1)
						setCommsMessage(string.format(_("upgrade-comms", "%s increased your beam damage by %i%% and stores away the %s"),ctd.character,math.floor((upgrade_value-1)*100),ctd.characterGood))
					else
						setCommsMessage(string.format(_("upgrade-comms", "%s requires %s for the upgrade"),ctd.character,ctd.characterGood))
					end
				else
					comms_source.damageBeamUpgrade = "done"
					bi = 0
					repeat
						tempArc = comms_source:getBeamWeaponArc(bi)
						tempDir = comms_source:getBeamWeaponDirection(bi)
						tempRng = comms_source:getBeamWeaponRange(bi)
						tempCyc = comms_source:getBeamWeaponCycleTime(bi)
						tempDmg = comms_source:getBeamWeaponDamage(bi)
						comms_source:setBeamWeapon(bi,tempArc,tempDir,tempRng,tempCyc,tempDmg*1.2)
						bi = bi + 1
					until(comms_source:getBeamWeaponRange(bi) < 1)
					setCommsMessage(string.format(_("upgrade-comms", "%s increased your beam damage by 20%%, waiving the usual %s requirement"),ctd.character,ctd.characterGood))
				end
			else
				setCommsMessage(_("upgrade-comms", "Your ship type does not support a beam weapon upgrade."))				
			end
			addCommsReply(_("Back"),commsStation)
		end)
	end
end
function moreMissiles()
	if comms_source.moreMissilesUpgrade == nil then
		addCommsReply(_("upgrade-comms", "Increase missile storage capacity"), function()
			local ctd = comms_target.comms_data
			if comms_source:getWeaponTubeCount() > 0 then
				if payForUpgrade() then
					local partQuantity = 0
					if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
						partQuantity = comms_source.goods[ctd.characterGood]
					end
					if partQuantity > 0 then
						comms_source.moreMissilesUpgrade = "done"
						local upgrade_value = 1.25
						if partQuantity > 1 then
							upgrade_value = 1.4
							comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 2
							comms_source.cargo = comms_source.cargo + 2
						else
							comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
							comms_source.cargo = comms_source.cargo + 1
						end
						local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
						for i, missile_type in ipairs(missile_types) do
							comms_source:setWeaponStorageMax(missile_type, math.ceil(comms_source:getWeaponStorageMax(missile_type)*upgrade_value))
						end
						setCommsMessage(string.format(_("upgrade-comms", "%s: You can now store at least %i%% more missiles. I appreciate the %s"),ctd.character,math.floor((upgrade_value-1)*100),ctd.characterGood))
					else
						setCommsMessage(string.format(_("upgrade-comms", "%s needs %s for the upgrade"),ctd.character,ctd.characterGood))
					end
				else
					comms_source.moreMissilesUpgrade = "done"
					missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
					for i, missile_type in ipairs(missile_types) do
						comms_source:setWeaponStorageMax(missile_type, math.ceil(comms_source:getWeaponStorageMax(missile_type)*1.25))
					end
					setCommsMessage(string.format(_("upgrade-comms", "%s: You can now store at least 25%% more missiles. I found some spare %s on the station. Go launch those missiles at those perfidious treaty-breaking Kraylors"),ctd.character,ctd.characterGood))
				end
			else
				setCommsMessage(_("upgrade-comms", "Your ship type does not support a missile storage capacity upgrade."))				
			end
			addCommsReply(_("Back"),commsStation)
		end)
	end
end
function fasterImpulse()
	if comms_source.fasterImpulseUpgrade == nil then
		addCommsReply(_("upgrade-comms", "Speed up impulse engines"), function()
			local ctd = comms_target.comms_data
			if payForUpgrade() then
				local partQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
					partQuantity = comms_source.goods[ctd.characterGood]
				end
				if partQuantity > 0 then
					comms_source.fasterImpulseUpgrade = "done"
					local upgrade_value = 1.25
					if partQuantity > 1 then
						upgrade_value = 1.4
						comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 2
						comms_source.cargo = comms_source.cargo + 2
					else
						comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
						comms_source.cargo = comms_source.cargo + 1
					end
					comms_source:setImpulseMaxSpeed(comms_source:getImpulseMaxSpeed()*upgrade_value)
					setCommsMessage(string.format(_("upgrade-comms", "%s: Your impulse engines now push you up to %i%% faster. Thanks for the %s"),ctd.character,math.floor((upgrade_value-1)*100),ctd.characterGood))
				else
					setCommsMessage(string.format(_("upgrade-comms", "You need to bring %s to %s for the upgrade"),ctd.characterGood,ctd.character))
				end
			else
				comms_source.fasterImpulseUpgrade = "done"
				comms_source:setImpulseMaxSpeed(comms_source:getImpulseMaxSpeed()*1.25)
				setCommsMessage(string.format(_("upgrade-comms", "%s: Your impulse engines now push you up to 25%% faster. I didn't need %s after all. Go run circles around those blinking Kraylors"),ctd.character,ctd.characterGood))
			end
			addCommsReply(_("Back"),commsStation)
		end)
	end
end
function strongerHull()
	if comms_source.strongerHullUpgrade == nil then
		addCommsReply(_("upgrade-comms", "Strengthen hull"), function()
			local ctd = comms_target.comms_data
			if payForUpgrade() then
				local partQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
					partQuantity = comms_source.goods[ctd.characterGood]
				end
				if partQuantity > 0 then
					comms_source.strongerHullUpgrade = "done"
					local upgrade_value = 1.5
					if partQuantity > 1 then
						upgrade_value = 1.8
						comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 2
						comms_source.cargo = comms_source.cargo + 2
					else
						comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
						comms_source.cargo = comms_source.cargo + 1
					end
					comms_source:setHullMax(comms_source:getHullMax()*upgrade_value)
					comms_source:setHull(comms_source:getHullMax())
					setCommsMessage(string.format(_("upgrade-comms", "%s: Thank you for the %s. Your hull is %i%% stronger"),ctd.character,math.floor((upgrade_value-1)*100),ctd.characterGood))
				else
					setCommsMessage(string.format(_("upgrade-comms", "%s: I need %s before I can increase your hull strength"),ctd.character,ctd.characterGood))
				end
			else
				comms_source.strongerHullUpgrade = "done"
				comms_source:setHullMax(comms_source:getHullMax()*1.5)
				comms_source:setHull(comms_source:getHullMax())
				setCommsMessage(string.format(_("upgrade-comms", "%s: I made your hull 50%% stronger. I scrounged some %s from around here since you are on the Kraylor offense team"),ctd.character,ctd.characterGood))
			end
			addCommsReply(_("Back"),commsStation)
		end)
	end
end
function efficientBatteries()
	if comms_source.efficientBatteriesUpgrade == nil then
		addCommsReply(_("upgrade-comms", "Increase battery efficiency"), function()
			local ctd = comms_target.comms_data
			if payForUpgrade() then
				local partQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
					partQuantity = comms_source.goods[ctd.characterGood]
				end
				if partQuantity > 0 then
					comms_source.efficientBatteriesUpgrade = "done"
					local upgrade_value = 1.25
					if partQuantity > 1 then
						upgrade_value = 1.4
						comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 2
						comms_source.cargo = comms_source.cargo + 2
					else
						comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
						comms_source.cargo = comms_source.cargo + 1
					end
					comms_source:setMaxEnergy(comms_source:getMaxEnergy()*upgrade_value)
					comms_source:setEnergy(comms_source:getMaxEnergy())
					setCommsMessage(string.format(_("upgrade-comms", "%s: I appreciate the %s. You have a %i%% greater energy capacity due to increased battery efficiency"),ctd.character,ctd.characterGood,math.floor((upgrade_value-1)*100)))
				else
					setCommsMessage(string.format(_("upgrade-comms", "%s: You need to bring me some %s before I can increase your battery efficiency"),ctd.character,ctd.characterGood))
				end
			else
				comms_source.efficientBatteriesUpgrade = "done"
				comms_source:setMaxEnergy(comms_source:getMaxEnergy()*1.25)
				comms_source:setEnergy(comms_source:getMaxEnergy())
				setCommsMessage(string.format(_("upgrade-comms", "%s increased your battery efficiency by 25%% without the need for %s due to the pressing military demands on your ship"),ctd.character,ctd.characterGood))
			end
			addCommsReply(_("Back"),commsStation)
		end)
	end
end
function strongerShields()
	if comms_source.strongerShieldsUpgrade == nil then
		addCommsReply(_("upgrade-comms", "Strengthen shields"), function()
			local ctd = comms_target.comms_data
			if payForUpgrade() then
				local partQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
					partQuantity = comms_source.goods[ctd.characterGood]
				end
				if partQuantity > 0 then
					comms_source.strongerShieldsUpgrade = "done"
					local upgrade_value = 1.2
					if partQuantity > 1 then
						upgrade_value = 1.4
						comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 2
						comms_source.cargo = comms_source.cargo + 2
					else
						comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
						comms_source.cargo = comms_source.cargo + 1
					end
					if comms_source:getShieldCount() == 1 then
						comms_source:setShieldsMax(comms_source:getShieldMax(0)*upgrade_value)
					else
						comms_source:setShieldsMax(comms_source:getShieldMax(0)*upgrade_value,comms_source:getShieldMax(1)*upgrade_value)
					end
					setCommsMessage(string.format(_("upgrade-comms", "%s: I've raised your shield maximum by %i%%, %s. Thanks for bringing the %s"),ctd.character,math.floor((upgrade_value-1)*100),comms_source:getCallSign(),ctd.characterGood))
				else
					setCommsMessage(string.format(_("upgrade-comms", "%s: You need to provide %s before I can raise your shield strength"),ctd.character,ctd.characterGood))
				end
			else
				comms_source.strongerShieldsUpgrade = "done"
				if comms_source:getShieldCount() == 1 then
					comms_source:setShieldsMax(comms_source:getShieldMax(0)*1.2)
				else
					comms_source:setShieldsMax(comms_source:getShieldMax(0)*1.2,comms_source:getShieldMax(1)*1.2)
				end
				setCommsMessage(string.format(_("upgrade-comms", "%s: Congratulations, %s, your shields are 20%% stronger. Don't worry about the %s. Go kick those Kraylors outta here"),ctd.character,comms_source:getCallSign(),ctd.characterGood))
			end
			addCommsReply(_("Back"),commsStation)
		end)
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
	local ctd = comms_target.comms_data
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
		oMsg = oMsg .. _("station-comms", "\nForgive us if we seem a little distracted. We are carefully monitoring the enemies nearby.")
	end
	oMsg = string.format(_("station-comms", "%s\n\nReputation: %i"),oMsg,math.floor(comms_source:getReputationPoints()))
	setCommsMessage(oMsg)
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
				setCommsMessage(string.format(_("ammo-comms", "What type of ordnance?\n\nReputation: %i"),math.floor(comms_source:getReputationPoints())))
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
		service_status = string.format(_("stationServices-comms", "%s\nMay repair the following primary systems:"),service_status)		
		local line_item_count = 0
		for i, system in ipairs(system_list) do
			if comms_target.comms_data.system_repair[system] then
				if line_item_count == 0 or line_item_count >= 3 then
					service_status = service_status .. _("stationServices-comms", "\n    ")
					line_item_count = 0
				end
				service_status = service_status .. system .. "  "
				line_item_count = line_item_count + 1
			end
		end
		service_status = string.format(_("stationServices-comms", "%s\nMay repair the coolant pump on the following primary systems:"),service_status)
		line_item_count = 0
		for i, system in ipairs(system_list) do
			if comms_target.comms_data.coolant_pump_repair[system] then
				if line_item_count == 0 or line_item_count >= 3 then
					service_status = service_status .. _("stationServices-comms", "\n    ")
					line_item_count = 0
				end
				service_status = service_status .. system .. "  "
				line_item_count = line_item_count + 1
			end
		end
		service_status = string.format(_("stationServices-comms", "%s\nMay repair the following secondary systems:"),service_status)
		line_item_count = 0	
		if comms_target.comms_data.probe_launch_repair then
			if line_item_count == 0 or line_item_count >= 3 then
				service_status = service_status .. _("stationServices-comms", "\n    ")
				line_item_count = 0
			end
			service_status = string.format(_("stationServices-comms", "%sprobe launch system   "),service_status)
			line_item_count = line_item_count + 1
		end
		if comms_target.comms_data.hack_repair then
			if line_item_count == 0 or line_item_count >= 3 then
				service_status = service_status .. _("stationServices-comms", "\n    ")
				line_item_count = 0
			end
			service_status = string.format(_("stationServices-comms", "%shacking system   "),service_status)
			line_item_count = line_item_count + 1
		end
		if comms_target.comms_data.scan_repair then
			if line_item_count == 0 or line_item_count >= 3 then
				service_status = service_status .. _("stationServices-comms", "\n    ")
				line_item_count = 0
			end
			service_status = string.format(_("stationServices-comms", "%sscanners   "),service_status)
			line_item_count = line_item_count + 1
		end
		if comms_target.comms_data.combat_maneuver_repair then
			if line_item_count == 0 or line_item_count >= 3 then
				service_status = service_status .. _("stationServices-comms", "\n    ")
				line_item_count = 0
			end
			service_status = string.format(_("stationServices-comms", "%scombat maneuver   "),service_status)
			line_item_count = line_item_count + 1
		end
		if comms_target.comms_data.self_destruct_repair then
			if line_item_count == 0 or line_item_count >= 3 then
				service_status = service_status .. _("stationServices-comms", "\n    ")
				line_item_count = 0
			end
			service_status = string.format(_("stationServices-comms", "%sself destruct system   "),service_status)
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
	local system_list = {"reactor","beamweapons","missilesystem","maneuver","impulse","warp","jumpdrive","frontshield","rearshield"}
	for i, system in ipairs(system_list) do
		if not offer_repair 
			and	((comms_source:getSystemHealthMax(system) < 1 and comms_target.comms_data.system_repair[system])
			or	(comms_source:getSystemCoolantRate(system) < comms_source.normal_coolant_rate[system] and comms_target.comms_data.coolant_pump_repair[system])) then
			offer_repair = true
			break
		end
	end
	if offer_repair then
		addCommsReply(_("stationServices-comms", "Repair ship system"),function()
			setCommsMessage(string.format(_("stationServices-comms", "What system would you like repaired?\n\nReputation: %i"),math.floor(comms_source:getReputationPoints())))
			local system_list = {"reactor","beamweapons","missilesystem","maneuver","impulse","warp","jumpdrive","frontshield","rearshield"}
			for i, system in ipairs(system_list) do
				if repair_system_diagnostic then
					print("offer repair system:",system)
				end
				if comms_target.comms_data.system_repair[system] then
					if repair_system_diagnostic then
						print(comms_target:getCallSign(),"can repair:",system)
					end
					if comms_source:getSystemHealthMax(system) < 1 then
						if repair_system_diagnostic then
							print(comms_source:getCallSign(),"needs repairs on:",system,"current health max:",comms_source:getSystemHealthMax(system))
						end
						addCommsReply(string.format(_("stationServices-comms", "Repair %s (current max is %i%%) (5 Rep)"),system,math.floor(comms_source:getSystemHealthMax(system)*100)),function()
							if comms_source:takeReputationPoints(5) then
								comms_source:setSystemHealthMax(system,1)
								comms_source:setSystemHealth(system,1)
								setCommsMessage(string.format(_("stationServices-comms", "%s has been repaired"),system))
							else
								setCommsMessage(_("needRep-comms", "Insufficient reputation"))
							end
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
				if comms_target.comms_data.coolant_pump_repair[system] then
					if repair_system_diagnostic then
						print(comms_target:getCallSign(),"can repair the coolant pump for:",system)
					end
					if comms_source:getSystemCoolantRate(system) < comms_source.normal_coolant_rate[system] then
						if repair_system_diagnostic then
							print(comms_source:getCallSign(),"needs the coolant pump repaired for:",system)
						end
						addCommsReply(string.format(_("stationServices-comms", "Repair %s coolant pump (5 Rep)"),system),function()
							if comms_source:takeReputationPoints(5) then
								comms_source:setSystemCoolantRate(system,comms_source.normal_coolant_rate[system])
								setCommsMessage(string.format(_("stationServices-comms", "%s coolant pump has been repaired"),system))
							else
								setCommsMessage(_("needRep-comms", "Insufficient reputation"))
							end
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
			end
			if comms_target.comms_data.probe_launch_repair then
				if repair_system_diagnostic then
					print(comms_target:getCallSign(),"can repair probe launcher")
				end
				if not comms_source:getCanLaunchProbe() then
					if repair_system_diagnostic then
						print(comms_source:getCallSign(),"needs probe launch system repaired")
					end
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
				if repair_system_diagnostic then
					print(comms_target:getCallSign(),"can repair hacking")
				end
				if not comms_source:getCanHack() then
					if repair_system_diagnostic then
						print(comms_source:getCallSign(),"needs hacking repaired")
					end
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
				if repair_system_diagnostic then
					print(comms_target:getCallSign(),"can repair scanners")
				end
				if not comms_source:getCanScan() then
					if repair_system_diagnostic then
						print(comms_source:getCallSign(),"needs scanners repaired")
					end
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
				if repair_system_diagnostic then
					print(comms_target:getCallSign(),"can repair combat maneuver")
				end
				if not comms_source:getCanCombatManeuver() then
					if repair_system_diagnostic then
						print(comms_source:getCallSign(),"needs combat maneuver repaired")
					end
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
				if repair_system_diagnostic then
					print(comms_target:getCallSign(),"can repair self destruct")
				end
				if not comms_source:getCanSelfDestruct() then
					if repair_system_diagnostic then
						print(comms_source:getCallSign(),"needs self destruct system repaired")
					end
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
    if isAllowedTo(comms_target.comms_data.services.activatedefensefleet) and 
    	comms_target.comms_data.idle_defense_fleet ~= nil then
    	local defense_fleet_count = 0
    	for name, template in pairs(comms_target.comms_data.idle_defense_fleet) do
    		defense_fleet_count = defense_fleet_count + 1
    	end
    	if defense_fleet_count > 0 then
    		addCommsReply("Activate station defense fleet (" .. getServiceCost("activatedefensefleet") .. " rep)",function()
    			if comms_source:takeReputationPoints(getServiceCost("activatedefensefleet")) then
    				local out = string.format("%s defense fleet\n",comms_target:getCallSign())
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
    					out = out .. " " .. name
    					comms_target.comms_data.idle_defense_fleet[name] = nil
    				end
    				out = out .. "\nactivated"
    				setCommsMessage(out)
    			else
    				setCommsMessage(_("needRep-comms", "Insufficient reputation"))
    			end
				addCommsReply(_("Back"), commsStation)
    		end)
		end
    end
	local has_gossip = random(1,100) < (100 - (30 * (difficulty - .5)))
	if (comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "") or
		(comms_target.comms_data.history ~= nil and comms_target.comms_data.history ~= "") or
		(comms_source:isFriendly(comms_target) and comms_target.comms_data.gossip ~= nil and comms_target.comms_data.gossip ~= "" and has_gossip) then
		addCommsReply(_("station-comms", "Tell me more about your station"), function()
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
			if comms_source:isFriendly(comms_target) then
				if ctd.gossip ~= nil and ctd.gossip ~= "" then
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
	end
	if enemyEverDetected then
		addCommsReply(_("station-comms", "Why the yellow neutral border zones?"), function()
			setCommsMessage(_("station-comms", "Each neutral border zone is equipped with sensors and an auto-transmitter. If the sensors detect enemy forces in the zone, the auto-transmitter sends encoded zone identifying details through subspace. Human navy ships are equipped to recognize this data and color code the appropriate zone on the science and relay consoles."))
			addCommsReply(_("Back"),commsStation)
		end)
	end
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
	if comms_source:isFriendly(comms_target) then
		addCommsReply(_("orders-comms", "What are my current orders?"), function()
			setOptionalOrders()
			setSecondaryOrders()
			ordMsg = primaryOrders .. "\n" .. secondaryOrders .. optionalOrders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format(_("orders-comms", "\n   %i Minutes remain in game"),math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
			addCommsReply(_("Back"), commsStation)
		end)
		if math.random(1,5) <= (3 - difficulty) then
			local hireCost = math.random(45,90)
			if comms_source:getRepairCrewCount() < comms_source.maxRepairCrew then
				hireCost = math.random(30,60)
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
			local hireCost = math.random(60,120)
			if comms_source:getRepairCrewCount() < comms_source.maxRepairCrew then
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
		if comms_source.initialCoolant ~= nil then
			if math.random(1,5) <= (3 - difficulty) then
				local coolantCost = math.random(60,120)
				if comms_source:getMaxCoolant() < comms_source.initialCoolant then
					coolantCost = math.random(45,90)
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
	end
	addCommsReply(_("cartographyOffice-comms", "Visit cartography office"), function()
		if comms_target.cartographer_description == nil then
			local clerk_choice = math.random(1,3)
			if clerk_choice == 1 then
				comms_target.cartographer_description = _("cartographyOffice-comms", "The clerk behind the desk looks up briefly at you then goes back to filing her nails.")
			elseif clerk_choice == 2 then
				comms_target.cartographer_description = _("cartographyOffice-comms", "The clerk behind the desk examines you then returns to grooming her tentacles.")
			else
				comms_target.cartographer_description = _("cartographyOffice-comms", "The clerk behind the desk glances at you then returns to preening her feathers.")
			end
		end
		setCommsMessage(string.format(_("cartographyOffice-comms", "%s\n\nYou can examine the brochure on the coffee table, talk to the apprentice cartographer or talk to the master cartographer.\n\nReputation: %i"),comms_target.cartographer_description,math.floor(comms_source:getReputationPoints())))
		addCommsReply(_("cartographyOffice-comms", "What's the difference between the apprentice and the master?"), function()
			setCommsMessage(_("cartographyOffice-comms", "The clerk responds in a bored voice, 'The apprentice knows the local area and is learning the broader area. The master knows the local and the broader area but can't be bothered with the local area'"))
			addCommsReply(_("Back"),commsStation)
		end)
		addCommsReply(string.format(_("cartographyOffice-comms", "Examine brochure (%i rep)"),getCartographerCost()),function()
			if comms_source:takeReputationPoints(getCartographerCost()) then
				setCommsMessage(string.format(_("cartographyOffice-comms", "The brochure has a list of nearby stations and has a list of goods nearby.\n\nReputation: %i"),math.floor(comms_source:getReputationPoints())))
				addCommsReply(string.format(_("cartographyOffice-comms", "Examine station list (%i rep)"),getCartographerCost()), function()
					if comms_source:takeReputationPoints(getCartographerCost()) then
						local brochure_stations = ""
						local sx, sy = comms_target:getPosition()
						local nearby_objects = getObjectsInRadius(sx,sy,30000)
						for i, obj in ipairs(nearby_objects) do
							if isObjectType(obj,"SpaceStation") then
								if not obj:isEnemy(comms_target) then
									if brochure_stations == "" then
										brochure_stations = string.format(_("cartographyOffice-comms", "%s %s %s"),obj:getSectorName(),obj:getFaction(),obj:getCallSign())
									else
										brochure_stations = string.format(_("cartographyOffice-comms", "%s\n%s %s %s"),brochure_stations,obj:getSectorName(),obj:getFaction(),obj:getCallSign())
									end
								end
							end
						end
						setCommsMessage(brochure_stations)
					else
						setCommsMessage(_("needRep-comms", "Insufficient reputation"))
					end
					addCommsReply(_("Back"),commsStation)
				end)
				addCommsReply(string.format(_("cartographyOffice-comms", "Examine goods list (%i rep)"),getCartographerCost()), function()
					if comms_source:takeReputationPoints(getCartographerCost()) then
						local brochure_goods = ""
						local sx, sy = comms_target:getPosition()
						local nearby_objects = getObjectsInRadius(sx,sy,30000)
						for i, obj in ipairs(nearby_objects) do
							if isObjectType(obj,"SpaceStation") then
								if not obj:isEnemy(comms_target) then
									if obj.comms_data.goods ~= nil then
										for good, good_data in pairs(obj.comms_data.goods) do
											if brochure_goods == "" then
												brochure_goods = string.format(_("cartographyOffice-comms", "Good, quantity, cost, station:\n%s, %i, %i, %s"),good,good_data["quantity"],good_data["cost"],obj:getCallSign())
											else
												brochure_goods = string.format(_("cartographyOffice-comms", "%s\n%s, %i, %i, %s"),brochure_goods,good,good_data["quantity"],good_data["cost"],obj:getCallSign())
											end
										end
									end
								end
							end
						end
						setCommsMessage(brochure_goods)
					else
						setCommsMessage(_("needRep-comms", "Insufficient reputation"))
					end
					addCommsReply(_("Back"),commsStation)
				end)
				if ctd.character_brochure == nil then
					local upgrade_stations = {}
					local sx, sy = comms_target:getPosition()
					local nearby_objects = getObjectsInRadius(sx,sy,30000)
					for i, obj in ipairs(nearby_objects) do
						if isObjectType(obj,"SpaceStation") then
							if not obj:isEnemy(comms_target) then
								if obj.comms_data.characterDescription ~= nil then
									if distance_diagnostic then print("distance_diagnostic 1",obj,sx,sy) end
									local sd = distance(obj,sx, sy)
									if random(0,1) < (1 - (sd/30000)) then
										table.insert(upgrade_stations,obj)
									end
								end
							end
						end
					end
					ctd.character_brochure = upgrade_stations
				end
				if #ctd.character_brochure > 0 then
					addCommsReply(string.format(_("cartographyOffice-comms", "Examine upgrades list (%i rep)"),getCartographerCost()), function()
						if comms_source:takeReputationPoints(getCartographerCost()) then
							local brochure_upgrades = ""
							for i=1,#ctd.character_brochure do
								local upgrade_station = ctd.character_brochure[i]
								if brochure_upgrades == "" then
									brochure_upgrades = string.format(_("cartographyOffice-comms", "%s: %s: %s"),upgrade_station:getCallSign(),upgrade_station.comms_data.character,upgrade_station.comms_data.characterDescription)
								else
									brochure_upgrades = string.format(_("cartographyOffice-comms", "%s\n%s: %s: %s"),brochure_upgrades,upgrade_station:getCallSign(),upgrade_station.comms_data.character,upgrade_station.comms_data.characterDescription)
								end
							end
							setCommsMessage(brochure_upgrades)
						else
							setCommsMessage(_("needRep-comms", "Insufficient reputation"))
						end
						addCommsReply(_("Back"),commsStation)
					end)
				end
			else
				setCommsMessage(_("needRep-comms", "Insufficient reputation"))
			end
			addCommsReply(_("Back"),commsStation)
		end)
		addCommsReply(string.format(_("cartographyOffice-comms", "Talk to apprentice cartographer (%i rep)"),getCartographerCost("apprentice")), function()
			if comms_source:takeReputationPoints(1) then
				if ctd.character_apprentice == nil then
					local upgrade_stations = {}
					local sx, sy = comms_target:getPosition()
					local nearby_objects = getObjectsInRadius(sx,sy,30000)
					for i, obj in ipairs(nearby_objects) do
						if isObjectType(obj,"SpaceStation") then
							if not obj:isEnemy(comms_target) then
								if obj.comms_data.characterDescription ~= nil then
									table.insert(upgrade_stations,obj)
								end
							end
						end
					end
					ctd.character_apprentice = upgrade_stations
				end
				if #ctd.character_apprentice > 0 then
					setCommsMessage(_("cartographyOffice-comms", "Hi, would you like for me to locate a station, some goods or some upgrades for you?"))
				else
					setCommsMessage(_("cartographyOffice-comms", "Hi, would you like for me to locate a station or some goods for you?"))
				end
				addCommsReply(_("cartographyOffice-comms", "Locate station"), function()
					setCommsMessage(_("cartographyOffice-comms", "These are stations I have learned"))
					local sx, sy = comms_target:getPosition()
					local nearby_objects = getObjectsInRadius(sx,sy,50000)
					local stations_known = 0
					for i, obj in ipairs(nearby_objects) do
						if isObjectType(obj,"SpaceStation") then
							if not obj:isEnemy(comms_target) then
								stations_known = stations_known + 1
								addCommsReply(obj:getCallSign(),function()
									local station_details = string.format(_("cartographyOffice-comms", "%s %s %s"),obj:getSectorName(),obj:getFaction(),obj:getCallSign())
									if obj.comms_data.goods ~= nil then
										station_details = string.format(_("cartographyOffice-comms", "%s\nGood, quantity, cost"),station_details)
										for good, good_data in pairs(obj.comms_data.goods) do
											station_details = string.format(_("cartographyOffice-comms", "%s\n   %s, %i, %i"),station_details,good,good_data["quantity"],good_data["cost"])
										end
									end
									if obj.comms_data.general ~= nil then
										station_details = string.format(_("stationGeneralInfo-comms", "%s\nGeneral Information:\n   %s"),station_details,obj.comms_data.general)
									end
									if obj.comms_data.history ~= nil then
										station_details = string.format(_("stationStory-comms", "%s\nHistory:\n   %s"),station_details,obj.comms_data.history)
									end
									if obj.comms_data.gossip ~= nil then
										station_details = string.format(_("gossip-comms", "%s\nGossip:\n   %s"),station_details,obj.comms_data.gossip)
									end
									if obj.comms_data.characterDescription ~= nil then
										station_details = string.format(_("cartographyOffice-comms", "%s\n%s:\n   %s"),station_details,obj.comms_data.character,obj.comms_data.characterDescription)
									end
									setCommsMessage(station_details)
									addCommsReply(_("Back"),commsStation)
								end)
							end
						end
					end
					if stations_known == 0 then
						setCommsMessage(_("cartographyOffice-comms", "I have learned of no stations yet"))
					end
					addCommsReply(_("Back"),commsStation)
				end)
				addCommsReply(_("cartographyOffice-comms", "Locate goods"), function()
					setCommsMessage(_("cartographyOffice-comms", "These are the goods I know about"))
					local sx, sy = comms_target:getPosition()
					local nearby_objects = getObjectsInRadius(sx,sy,50000)
					local button_count = 0
					local by_goods = {}
					for i, obj in ipairs(nearby_objects) do
						if isObjectType(obj,"SpaceStation") then
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
						addCommsReply(good, function()
							local station_details = string.format(_("cartographyOffice-comms", "%s %s %s"),obj:getSectorName(),obj:getFaction(),obj:getCallSign())
							if obj.comms_data.goods ~= nil then
								station_details = string.format(_("cartographyOffice-comms", "%s\nGood, quantity, cost"),station_details)
								for good, good_data in pairs(obj.comms_data.goods) do
									station_details = string.format(_("cartographyOffice-comms", "%s\n   %s, %i, %i"),station_details,good,good_data["quantity"],good_data["cost"])
								end
							end
							if obj.comms_data.general ~= nil then
								station_details = string.format(_("stationGeneralInfo-comms", "%s\nGeneral Information:\n   %s"),station_details,obj.comms_data.general)
							end
							if obj.comms_data.history ~= nil then
								station_details = string.format(_("stationStory-comms", "%s\nHistory:\n   %s"),station_details,obj.comms_data.history)
							end
							if obj.comms_data.gossip ~= nil then
								station_details = string.format(_("gossip-comms", "%s\nGossip:\n   %s"),station_details,obj.comms_data.gossip)
							end
							if obj.comms_data.characterDescription ~= nil then
								station_details = string.format(_("cartographyOffice-comms", "%s\n%s:\n   %s"),station_details,obj.comms_data.character,obj.comms_data.characterDescription)
							end
							setCommsMessage(station_details)
							addCommsReply(_("Back"),commsStation)
						end)
						button_count = button_count + 1
						if button_count >= 20 then
							break
						end
					end
					addCommsReply(_("Back"),commsStation)
				end)
				if #ctd.character_apprentice > 0 then
					addCommsReply(_("cartographyOffice-comms", "Locate upgrade station"), function()
						setCommsMessage(_("cartographyOffice-comms", "These are stations I have learned that have upgrades"))
						local sx, sy = comms_target:getPosition()
						local nearby_objects = getObjectsInRadius(sx,sy,50000)
						local stations_known = 0
						for i, obj in ipairs(nearby_objects) do
							if isObjectType(obj,"SpaceStation") then
								if not obj:isEnemy(comms_target) then
									if obj.comms_data.characterDescription ~= nil then
										stations_known = stations_known + 1
										addCommsReply(obj:getCallSign(), function()
											local station_details = string.format(_("cartographyOffice-comms", "%s %s %s"),obj:getSectorName(),obj:getFaction(),obj:getCallSign())
											if obj.comms_data.goods ~= nil then
												station_details = string.format(_("cartographyOffice-comms", "%s\nGood, quantity, cost"),station_details)
												for good, good_data in pairs(obj.comms_data.goods) do
													station_details = string.format(_("cartographyOffice-comms", "%s\n   %s, %i, %i"),station_details,good,good_data["quantity"],good_data["cost"])
												end
											end
											if obj.comms_data.general ~= nil then
												station_details = string.format(_("stationGeneralInfo-comms", "%s\nGeneral Information:\n   %s"),station_details,obj.comms_data.general)
											end
											if obj.comms_data.history ~= nil then
												station_details = string.format(_("stationStory-comms", "%s\nHistory:\n   %s"),station_details,obj.comms_data.history)
											end
											if obj.comms_data.gossip ~= nil then
												station_details = string.format(_("gossip-comms", "%s\nGossip:\n   %s"),station_details,obj.comms_data.gossip)
											end
											if obj.comms_data.characterDescription ~= nil then
												station_details = string.format(_("cartographyOffice-comms", "%s\n%s:\n   %s"),station_details,obj.comms_data.character,obj.comms_data.characterDescription)
											end
											setCommsMessage(station_details)
											addCommsReply(_("Back"),commsStation)
										end)
									end
								end
							end
						end
						if stations_known == 0 then
							setCommsMessage(_("cartographyOffice-comms", "I have learned of no upgrade stations yet"))
						end
					end)
				end
			else
				setCommsMessage(_("needRep-comms", "Insufficient reputation"))
			end
			addCommsReply(_("Back"),commsStation)
		end)
		addCommsReply(string.format(_("cartographyOffice-comms", "Talk to master cartographer (%i rep)"),getCartographerCost("master")), function()
			if comms_source:getWaypointCount() >= 9 then
				setCommsMessage(_("cartographyOffice-comms", "The clerk clears her throat:\n\nMy indicators show you have zero available waypoints. To get the most from the master cartographer, you should delete one or more so that he can update your systems appropriately.\n\nI just want you to get the maximum benefit for the time you spend with him"))
				addCommsReply(_("cartographyOffice-comms", "Continue to Master Cartographer"), masterCartographer)
			else
				masterCartographer()
			end
			addCommsReply(_("Back"),commsStation)
		end)
		addCommsReply(_("Back"),commsStation)
	end)
	if comms_source:isFriendly(comms_target) then
		addCommsReply("Visit the office of wartime statistics",function()
			wartimeStatistics()
			addCommsReply(_("Back"),commsStation)
		end)
	end
	local goodCount = 0
	for good, goodData in pairs(ctd.goods) do
		goodCount = goodCount + 1
	end
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
			if ctd.trade.food then
				if comms_source.goods ~= nil then
					if comms_source.goods.food ~= nil then
						if comms_source.goods.food > 0 then
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
					end
				end
			end
			if ctd.trade.medicine then
				if comms_source.goods ~= nil then
					if comms_source.goods.medicine ~= nil then
						if comms_source.goods.medicine > 0 then
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
					end
				end
			end
			if ctd.trade.luxury then
				if comms_source.goods ~= nil then
					if comms_source.goods.luxury ~= nil then
						if comms_source.goods.luxury > 0 then
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
function masterCartographer()
	local ctd = comms_target.comms_data
	if comms_source:takeReputationPoints(getCartographerCost("master")) then
		if ctd.character_master == nil then
			local upgrade_stations = {}
			local nearby_objects = getAllObjects()
			local station_distance = 0
			for i, obj in ipairs(nearby_objects) do
				if isObjectType(obj,"SpaceStation") then
					if not obj:isEnemy(comms_target) then
						if distance_diagnostic then print("distance_diagnostic 2",comms_target,obj) end
						station_distance = distance(comms_target,obj)
						if station_distance > 50000 then
							if obj.comms_data.characterDescription ~= nil then
								table.insert(upgrade_stations,obj)
							end
						end
					end
				end
			end
			ctd.character_master = upgrade_stations
		end
		if #ctd.character_master > 0 then
			setCommsMessage(_("cartographyOffice-comms", "Greetings,\nMay I help you find a station, goods or an upgrade?"))
		else
			setCommsMessage(_("cartographyOffice-comms", "Greetings,\nMay I help you find a station or goods?"))
		end
		addCommsReply(_("cartographyOffice-comms", "Find station"),function()
			setCommsMessage(_("cartographyOffice-comms", "What station?"))
			local nearby_objects = getAllObjects()
			local stations_known = 0
			local station_distance = 0
			for i, obj in ipairs(nearby_objects) do
				if isObjectType(obj,"SpaceStation") then
					if not obj:isEnemy(comms_target) then
						if distance_diagnostic then print("distance_diagnostic 3",comms_target,obj) end
						station_distance = distance(comms_target,obj)
						if station_distance > 50000 then
							stations_known = stations_known + 1
							addCommsReply(obj:getCallSign(),function()
								local station_details = string.format(_("cartographyOffice-comms", "%s %s %s Distance:%.1fU"),obj:getSectorName(),obj:getFaction(),obj:getCallSign(),station_distance/1000)
								if obj.comms_data.goods ~= nil then
									station_details = string.format(_("cartographyOffice-comms", "%s\nGood, quantity, cost"),station_details)
									for good, good_data in pairs(obj.comms_data.goods) do
										station_details = string.format(_("cartographyOffice-comms", "%s\n   %s, %i, %i"),station_details,good,good_data["quantity"],good_data["cost"])
									end
								end
								if obj.comms_data.general ~= nil then
									station_details = string.format(_("stationGeneralInfo-comms", "%s\nGeneral Information:\n   %s"),station_details,obj.comms_data.general)
								end
								if obj.comms_data.history ~= nil then
									station_details = string.format(_("stationStory-comms", "%s\nHistory:\n   %s"),station_details,obj.comms_data.history)
								end
								if obj.comms_data.gossip ~= nil then
									station_details = string.format(_("gossip-comms", "%s\nGossip:\n   %s"),station_details,obj.comms_data.gossip)
								end
								if obj.comms_data.characterDescription ~= nil then
									station_details = string.format(_("cartographyOffice-comms", "%s\n%s:\n   %s"),station_details,obj.comms_data.character,obj.comms_data.characterDescription)
								end
								local dsx, dsy = obj:getPosition()
								comms_source:commandAddWaypoint(dsx,dsy)								
								station_details = string.format(_("cartographyOffice-comms", "%s\nAdded waypoint %i to your navigation system for %s"),station_details,comms_source:getWaypointCount(),obj:getCallSign())
								setCommsMessage(station_details)
								addCommsReply(_("Back"),commsStation)
							end)
						end
					end
				end
			end
			if stations_known == 0 then
				setCommsMessage(_("cartographyOffice-comms", "Try the apprentice, I'm tired"))
			end
			addCommsReply(_("Back"),commsStation)
		end)
		addCommsReply(_("cartographyOffice-comms", "Find Goods"), function()
			setCommsMessage(_("cartographyOffice-comms", "What goods are you looking for?"))
			local nearby_objects = getAllObjects()
			local by_goods = {}
			for i, obj in ipairs(nearby_objects) do
				if isObjectType(obj,"SpaceStation") then
					if not obj:isEnemy(comms_target) then
						if distance_diagnostic then print("distance_diagnostic 4",comms_target,obj) end
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
			for good, obj in pairs(by_goods) do
				addCommsReply(good, function()
					if distance_diagnostic then print("distance_diagnostic 5",comms_target,obj) end
					local station_distance = distance(comms_target,obj)
					local station_details = string.format(_("cartographyOffice-comms", "%s %s %s Distance:%.1fU"),obj:getSectorName(),obj:getFaction(),obj:getCallSign(),station_distance/1000)
					if obj.comms_data.goods ~= nil then
						station_details = string.format(_("cartographyOffice-comms", "%s\nGood, quantity, cost"),station_details)
						for good, good_data in pairs(obj.comms_data.goods) do
							station_details = string.format(_("cartographyOffice-comms", "%s\n   %s, %i, %i"),station_details,good,good_data["quantity"],good_data["cost"])
						end
					end
					if obj.comms_data.general ~= nil then
						station_details = string.format(_("stationGeneralInfo-comms", "%s\nGeneral Information:\n   %s"),station_details,obj.comms_data.general)
					end
					if obj.comms_data.history ~= nil then
						station_details = string.format(_("stationStory-comms", "%s\nHistory:\n   %s"),station_details,obj.comms_data.history)
					end
					if obj.comms_data.gossip ~= nil then
						station_details = string.format(_("gossip-comms", "%s\nGossip:\n   %s"),station_details,obj.comms_data.gossip)
					end
					if obj.comms_data.characterDescription ~= nil then
						station_details = string.format(_("cartographyOffice-comms", "%s\n%s:\n   %s"),station_details,obj.comms_data.character,obj.comms_data.characterDescription)
					end
					local dsx, dsy = obj:getPosition()
					comms_source:commandAddWaypoint(dsx,dsy)
					station_details = string.format(_("cartographyOffice-comms", "%s\nAdded waypoint %i to your navigation system for %s"),station_details,comms_source:getWaypointCount(),obj:getCallSign())
					setCommsMessage(station_details)
					addCommsReply(_("Back"),commsStation)
				end)
			end
			addCommsReply(_("Back"),commsStation)
		end)
		if #ctd.character_master > 0 then
			addCommsReply(_("cartographyOffice-comms", "Find Upgrade Station"), function()
				setCommsMessage(_("cartographyOffice-comms", "What station?"))
				for i=1,#ctd.character_master do
					local obj = ctd.character_master[i]
					if distance_diagnostic then print("distance_diagnostic 6",comms_target,obj) end
					station_distance = distance(comms_target,obj)
					addCommsReply(obj:getCallSign(), function()
						local station_details = string.format(_("cartographyOffice-comms", "%s %s %s Distance:%.1fU"),obj:getSectorName(),obj:getFaction(),obj:getCallSign(),station_distance/1000)
						if obj.comms_data.goods ~= nil then
							station_details = string.format(_("cartographyOffice-comms", "%s\nGood, quantity, cost"),station_details)
							for good, good_data in pairs(obj.comms_data.goods) do
								station_details = string.format(_("cartographyOffice-comms", "%s\n   %s, %i, %i"),station_details,good,good_data["quantity"],good_data["cost"])
							end
						end
						if obj.comms_data.general ~= nil then
							station_details = string.format(_("stationGeneralInfo-comms", "%s\nGeneral Information:\n   %s"),station_details,obj.comms_data.general)
						end
						if obj.comms_data.history ~= nil then
							station_details = string.format(_("stationStory-comms", "%s\nHistory:\n   %s"),station_details,obj.comms_data.history)
						end
						if obj.comms_data.gossip ~= nil then
							station_details = string.format(_("gossip-comms", "%s\nGossip:\n   %s"),station_details,obj.comms_data.gossip)
						end
						if obj.comms_data.characterDescription ~= nil then
							station_details = string.format(_("cartographyOffice-comms", "%s\n%s:\n   %s"),station_details,obj.comms_data.character,obj.comms_data.characterDescription)
						end
						local dsx, dsy = obj:getPosition()
						comms_source:commandAddWaypoint(dsx,dsy)
						station_details = string.format(_("cartographyOffice-comms", "%s\nAdded waypoint %i to your navigation system for %s"),station_details,comms_source:getWaypointCount(),obj:getCallSign())
						setCommsMessage(station_details)
						addCommsReply(_("Back"),commsStation)
					end)
				end
			end)
		end
	else
		setCommsMessage(_("needRep-comms", "Insufficient Reputation"))
	end
end
function getCartographerCost(service)
	local base_cost = 1
	if service == "apprentice" then
		base_cost = 5
	elseif service == "master" then
		base_cost = 10
	end
	return math.ceil(base_cost * comms_target.comms_data.reputation_cost_multipliers[getFriendStatus()])
end
function setOptionalOrders()
	optionalOrders = ""
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
	--[[	Disabling until I find the bug
	if isAllowedTo(ctd.services.preorder) then
		addCommsReply("Expedite Dock",function()
			if comms_source.expedite_dock == nil then
				comms_source.expedite_dock = false
			end
			if comms_source.expedite_dock then
				--handle expedite request already present
				local existing_expedite = "Docking crew is standing by"
				if comms_target == comms_source.expedite_dock_station then
					existing_expedite = existing_expedite .. ". Current preorders:"
					local preorders_identified = false
					if comms_source.preorder_hvli ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. string.format("\n   HVLIs: %i",comms_source.preorder_hvli)
					end
					if comms_source.preorder_homing ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. string.format("\n   Homings: %i",comms_source.preorder_homing)						
					end
					if comms_source.preorder_mine ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. string.format("\n   Mines: %i",comms_source.preorder_mine)						
					end
					if comms_source.preorder_emp ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. string.format("\n   EMPs: %i",comms_source.preorder_emp)						
					end
					if comms_source.preorder_nuke ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. string.format("\n   Nukes: %i",comms_source.preorder_nuke)						
					end
					if comms_source.preorder_repair_crew ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. "\n   One repair crew"						
					end
					if comms_source.preorder_coolant ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. "\n   Coolant"						
					end
					if preorders_identified then
						existing_expedite = existing_expedite .. "\nWould you like to preorder anything else?"
					else
						existing_expedite = existing_expedite .. " none.\nWould you like to preorder anything?"						
					end
					preorder_message = existing_expedite
					preOrderOrdnance()
				else
					existing_expedite = existing_expedite .. string.format(" on station %s (not this station, %s).",comms_source.expedite_dock_station:getCallSign(),comms_target:getCallSign())
					setCommsMessage(existing_expedite)
				end
				addCommsReply(_("Back"),commsStation)
			else
				setCommsMessage("If you would like to speed up the addition of resources such as energy, ordnance, etc., please provide a time frame for your arrival. A docking crew will stand by until that time, after which they will return to their normal duties")
				preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
				addCommsReply("One minute (5 rep)", function()
					if comms_source:takeReputationPoints(5) then
						comms_source.expedite_dock = true
						comms_source.expedite_dock_station = comms_target
						comms_source.expedite_dock_timer_max = 60
						preOrderOrdnance()
					else
						setCommsMessage(_("needRep-comms", "Insufficient reputation"))
					end
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply("Two minutes (10 Rep)", function()
					if comms_source:takeReputationPoints(10) then
						comms_source.expedite_dock = true
						comms_source.expedite_dock_station = comms_target
						comms_source.expedite_dock_timer_max = 120
						preOrderOrdnance()
					else
						setCommsMessage(_("needRep-comms", "Insufficient reputation"))
					end
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply("Three minutes (15 Rep)", function()
					if comms_source:takeReputationPoints(15) then
						comms_source.expedite_dock = true
						comms_source.expedite_dock_station = comms_target
						comms_source.expedite_dock_timer_max = 180
						preOrderOrdnance()
					else
						setCommsMessage(_("needRep-comms", "Insufficient reputation"))
					end
					addCommsReply(_("Back"), commsStation)
				end)
			end
			addCommsReply(_("Back"), commsStation)
		end)
	end	
	--]]
 	addCommsReply(_("station-comms", "I need information"), function()
		setCommsMessage(_("station-comms", "What kind of information do you need?"))
		addCommsReply(_("orders-comms", "What are my current orders?"), function()
			setOptionalOrders()
			setSecondaryOrders()
			ordMsg = primaryOrders .. "\n" .. secondaryOrders .. optionalOrders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format(_("orders-comms", "\n   %i Minutes remain in game"),math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
			addCommsReply(_("Back"), commsStation)
		end)
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
			service_status = string.format(_("stationServices-comms", "%s\nMay repair the following primary systems:"),service_status)		
			local line_item_count = 0
			for i, system in ipairs(system_list) do
				if comms_target.comms_data.system_repair[system] then
					if line_item_count == 0 or line_item_count >= 3 then
						service_status = service_status .. _("stationServices-comms", "\n    ")
						line_item_count = 0
					end
					service_status = service_status .. system .. "  "
					line_item_count = line_item_count + 1
				end
			end
			service_status = string.format(_("stationServices-comms", "%s\nMay repair the cooling pump for the following primary systems:"),service_status)
			line_item_count = 0
			for i, system in ipairs(system_list) do
				if comms_target.comms_data.coolant_pump_repair[system] then
					if line_item_count == 0 or line_item_count >= 3 then
						service_status = service_status .. _("stationServices-comms", "\n    ")
						line_item_count = 0
					end
					service_status = service_status .. system .. "  "
					line_item_count = line_item_count + 1
				end
			end
			service_status = string.format(_("stationServices-comms", "%s\nMay repair the following secondary systems:"),service_status)
			line_item_count = 0	
			if comms_target.comms_data.probe_launch_repair then
				if line_item_count == 0 or line_item_count >= 3 then
					service_status = service_status .. _("stationServices-comms", "\n    ")
					line_item_count = 0
				end
				service_status = string.format(_("stationServices-comms", "%sprobe launch system   "),service_status)
				line_item_count = line_item_count + 1
			end
			if comms_target.comms_data.hack_repair then
				if line_item_count == 0 or line_item_count >= 3 then
					service_status = service_status .. _("stationServices-comms", "\n    ")
					line_item_count = 0
				end
				service_status = string.format(_("stationServices-comms", "%shacking system   "),service_status)
				line_item_count = line_item_count + 1
			end
			if comms_target.comms_data.scan_repair then
				if line_item_count == 0 or line_item_count >= 3 then
					service_status = service_status .. _("stationServices-comms", "\n    ")
					line_item_count = 0
				end
				service_status = string.format(_("stationServices-comms", "%sscanners   "),service_status)
				line_item_count = line_item_count + 1
			end
			if comms_target.comms_data.combat_maneuver_repair then
				if line_item_count == 0 or line_item_count >= 3 then
					service_status = service_status .. _("stationServices-comms", "\n    ")
					line_item_count = 0
				end
				service_status = string.format(_("stationServices-comms", "%scombat maneuver   "),service_status)
				line_item_count = line_item_count + 1
			end
			if comms_target.comms_data.self_destruct_repair then
				if line_item_count == 0 or line_item_count >= 3 then
					service_status = service_status .. _("stationServices-comms", "\n    ")
					line_item_count = 0
				end
				service_status = string.format(_("stationServices-comms", "%sself destruct system   "),service_status)
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
		if comms_source:isFriendly(comms_target) then
			addCommsReply("Contact the office of wartime statistics",function()
				wartimeStatistics()
				addCommsReply(_("Back"),commsStation)
			end)
		end
		addCommsReply(_("trade-comms", "Where can I find particular goods?"), function()
			local ctd = comms_target.comms_data
			gkMsg = _("trade-comms", "Friendly stations often have food or medicine or both. Neutral stations may trade their goods for food, medicine or luxury.")
			if ctd.goodsKnowledge == nil then
				ctd.goodsKnowledge = {}
				local knowledgeCount = 0
				local knowledgeMax = 10
				for i=1,#humanStationList do
					local station = humanStationList[i]
					if station ~= nil and station:isValid() then
						local brainCheckChance = 60
						if distance_diagnostic then print("distance_diagnostic 7",comms_target,station) end
						if distance(comms_target,station) > 75000 then
							brainCheckChance = 20
						end
						for good, goodData in pairs(station.comms_data.goods) do
							if random(1,100) <= brainCheckChance then
								local stationCallSign = station:getCallSign()
								local stationSector = station:getSectorName()
								ctd.goodsKnowledge[good] =	{	station = stationCallSign,
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
			for good, goodKnowledge in pairs(ctd.goodsKnowledge) do
				goodsKnowledgeCount = goodsKnowledgeCount + 1
				addCommsReply(good, function()
					local ctd = comms_target.comms_data
					local stationName = ctd.goodsKnowledge[good]["station"]
					local sectorName = ctd.goodsKnowledge[good]["sector"]
					local goodName = good
					local goodCost = ctd.goodsKnowledge[good]["cost"]
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
		local has_gossip = random(1,100) < (100 - (30 * (difficulty - .5)))
		if (comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "") or
			(comms_target.comms_data.history ~= nil and comms_target.comms_data.history ~= "") or
			(comms_source:isFriendly(comms_target) and comms_target.comms_data.gossip ~= nil and comms_target.comms_data.gossip ~= "" and has_gossip) then
			addCommsReply(_("station-comms", "Tell me more about your station"), function()
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
				if comms_source:isFriendly(comms_target) then
					if ctd.gossip ~= nil and ctd.gossip ~= "" then
						if random(1,100) < 50 then
							addCommsReply(_("gossip-comms", "Gossip"), function()
								setCommsMessage(ctd.gossip)
								addCommsReply(_("Back"), commsStation)
							end)
						end
					end
				end
			end)	--end station info comms reply branch
		end	--end public relations if branch
		if ctd.character ~= nil then
			if random(1,100) < (70 - (20 * difficulty)) then
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
				end)
			end
		end
		if enemyEverDetected then
			addCommsReply(_("station-comms", "Why the yellow neutral border zones?"), function()
				setCommsMessage(_("station-comms", "Each neutral border zone is equipped with sensors and an auto-transmitter. If the sensors detect enemy forces in the zone, the auto-transmitter sends encoded zone identifying details through subspace. Human navy ships are equipped to recognize this data and color code the appropriate zone on the science and relay consoles."))
			end)
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
						if treaty then
							local tempAsteroid = VisualAsteroid():setPosition(comms_source:getWaypoint(n))
							local waypointInBorderZone = false
							for i=1,#borderZone do
								if borderZone[i]:isInside(tempAsteroid) then
									waypointInBorderZone = true
									break
								end
							end
							if waypointInBorderZone then
								setCommsMessage("We cannot break the treaty by sending reinforcements to WP" .. n .. " in the neutral border zone")
							elseif outerZone:isInside(tempAsteroid) then
								setCommsMessage("We cannot break the treaty by sending reinforcements to WP" .. n .. " across the neutral border zones")							
							else
								if comms_source:takeReputationPoints(getServiceCost("reinforcements")) then
									local ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
									ship:setCallSign(generateCallSign(nil,"Human Navy"))
									ship:setCommsScript(""):setCommsFunction(commsShip):onDestroyed(friendlyVesselDestroyed)
									table.insert(friendlyHelperFleet,ship)
									setCommsMessage(string.format(_("stationAssist-comms", "We have dispatched %s to assist at WP %d"),ship:getCallSign(),n))
								else
									setCommsMessage(_("needRep-comms", "Not enough reputation!"));
								end
							end
							tempAsteroid:destroy()
						else
							if comms_source:takeReputationPoints(getServiceCost("reinforcements")) then
								ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
								ship:setCommsScript(""):setCommsFunction(commsShip):onDestroyed(friendlyVesselDestroyed)
								ship:setCallSign(generateCallSign(nil,"Human Navy"))
								table.insert(friendlyHelperFleet,ship)
								setCommsMessage(string.format(_("stationAssist-comms", "We have dispatched %s to assist at WP %d"),ship:getCallSign(),n))
							else
								setCommsMessage(_("needRep-comms", "Not enough reputation!"));
							end
						end
                        addCommsReply(_("Back"), commsStation)
                    end)
                end
            end
            addCommsReply(_("Back"), commsStation)
        end)
    end
    if isAllowedTo(comms_target.comms_data.services.activatedefensefleet) and 
    	comms_target.comms_data.idle_defense_fleet ~= nil then
    	local defense_fleet_count = 0
    	for name, template in pairs(comms_target.comms_data.idle_defense_fleet) do
    		defense_fleet_count = defense_fleet_count + 1
    	end
    	if defense_fleet_count > 0 then
    		addCommsReply("Activate station defense fleet (" .. getServiceCost("activatedefensefleet") .. " rep)",function()
    			if comms_source:takeReputationPoints(getServiceCost("activatedefensefleet")) then
    				local out = string.format("%s defense fleet\n",comms_target:getCallSign())
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
    					out = out .. " " .. name
    					comms_target.comms_data.idle_defense_fleet[name] = nil
    				end
    				out = out .. "\nactivated"
    				setCommsMessage(out)
    			else
    				setCommsMessage(_("needRep-comms", "Insufficient reputation"))
    			end
				addCommsReply(_("Back"), commsStation)
    		end)
		end
    end
end
function preOrderOrdnance()
	setCommsMessage(preorder_message)
	local ctd = comms_target.comms_data
	local hvli_count = math.floor(comms_source:getWeaponStorageMax("HVLI") * ctd.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage("HVLI")
	if ctd.weapon_available.HVLI and isAllowedTo(ctd.weapons["HVLI"]) and hvli_count > 0 then
		local hvli_prompt = ""
		local hvli_cost = getWeaponCost("HVLI")
		if hvli_count > 1 then
			hvli_prompt = string.format("%i HVLIs * %i Rep = %i Rep",hvli_count,hvli_cost,hvli_count*hvli_cost)
		else
			hvli_prompt = string.format("%i HVLI * %i Rep = %i Rep",hvli_count,hvli_cost,hvli_count*hvli_cost)
		end
		addCommsReply(hvli_prompt,function()
			if comms_source:takeReputationPoints(hvli_count*hvli_cost) then
				comms_source.preorder_hvli = hvli_count
				if hvli_count > 1 then
					setCommsMessage(string.format("%i HVLIs preordered",hvli_count))
				else
					setCommsMessage(string.format("%i HVLI preordered",hvli_count))
				end
			else
				setCommsMessage(_("needRep-comms", "Insufficient reputation"))
			end
			preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
			addCommsReply(_("Back"),preOrderOrdnance)
		end)
	end
	local homing_count = math.floor(comms_source:getWeaponStorageMax("Homing") * ctd.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage("Homing")
	if ctd.weapon_available.Homing and isAllowedTo(ctd.weapons["Homing"]) and homing_count > 0 then
		local homing_prompt = ""
		local homing_cost = getWeaponCost("Homing")
		if homing_count > 1 then
			homing_prompt = string.format("%i Homings * %i Rep = %i Rep",homing_count,homing_cost,homing_count*homing_cost)
		else
			homing_prompt = string.format("%i Homing * %i Rep = %i Rep",homing_count,homing_cost,homing_count*homing_cost)
		end
		addCommsReply(homing_prompt,function()
			if comms_source:takeReputationPoints(homing_count*homing_cost) then
				comms_source.preorder_homing = homing_count
				if homing_count > 1 then
					setCommsMessage(string.format("%i Homings preordered",homing_count))
				else
					setCommsMessage(string.format("%i Homing preordered",homing_count))
				end
			else
				setCommsMessage(_("needRep-comms", "Insufficient reputation"))
			end
			preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
			addCommsReply(_("Back"),preOrderOrdnance)
		end)
	end
	local mine_count = math.floor(comms_source:getWeaponStorageMax("Mine") * ctd.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage("Mine")
	if ctd.weapon_available.Mine and isAllowedTo(ctd.weapons["Mine"]) and mine_count > 0 then
		local mine_prompt = ""
		local mine_cost = getWeaponCost("Mine")
		if mine_count > 1 then
			mine_prompt = string.format("%i Mines * %i Rep = %i Rep",mine_count,mine_cost,mine_count*mine_cost)
		else
			mine_prompt = string.format("%i Mine * %i Rep = %i Rep",mine_count,mine_cost,mine_count*mine_cost)
		end
		addCommsReply(mine_prompt,function()
			if comms_source:takeReputationPoints(mine_count*mine_cost) then
				comms_source.preorder_mine = mine_count
				if mine_count > 1 then
					setCommsMessage(string.format("%i Mines preordered",mine_count))
				else
					setCommsMessage(string.format("%i Mine preordered",mine_count))
				end
			else
				setCommsMessage(_("needRep-comms", "Insufficient reputation"))
			end
			preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
			addCommsReply(_("Back"),preOrderOrdnance)
		end)
	end
	local emp_count = math.floor(comms_source:getWeaponStorageMax("EMP") * ctd.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage("EMP")
	if ctd.weapon_available.EMP and isAllowedTo(ctd.weapons["EMP"]) and emp_count > 0 then
		local emp_prompt = ""
		local emp_cost = getWeaponCost("EMP")
		if emp_count > 1 then
			emp_prompt = string.format("%i EMPs * %i Rep = %i Rep",emp_count,emp_cost,emp_count*emp_cost)
		else
			emp_prompt = string.format("%i EMP * %i Rep = %i Rep",emp_count,emp_cost,emp_count*emp_cost)
		end
		addCommsReply(emp_prompt,function()
			if comms_source:takeReputationPoints(emp_count*emp_cost) then
				comms_source.preorder_emp = emp_count
				if emp_count > 1 then
					setCommsMessage(string.format("%i EMPs preordered",emp_count))
				else
					setCommsMessage(string.format("%i EMP preordered",emp_count))
				end
			else
				setCommsMessage(_("needRep-comms", "Insufficient reputation"))
			end
			preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
			addCommsReply(_("Back"),preOrderOrdnance)
		end)
	end
	local nuke_count = math.floor(comms_source:getWeaponStorageMax("Nuke") * ctd.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage("Nuke")
	if ctd.weapon_available.Nuke and isAllowedTo(ctd.weapons["Nuke"]) and nuke_count > 0 then
		local nuke_prompt = ""
		local nuke_cost = getWeaponCost("Nuke")
		if nuke_count > 1 then
			nuke_prompt = string.format("%i Nukes * %i Rep = %i Rep",nuke_count,nuke_cost,nuke_count*nuke_cost)
		else
			nuke_prompt = string.format("%i Nuke * %i Rep = %i Rep",nuke_count,nuke_cost,nuke_count*nuke_cost)
		end
		addCommsReply(nuke_prompt,function()
			if comms_source:takeReputationPoints(nuke_count*nuke_cost) then
				comms_source.preorder_nuke = nuke_count
				if nuke_count > 1 then
					setCommsMessage(string.format("%i Nukes preordered",nuke_count))
				else
					setCommsMessage(string.format("%i Nuke preordered",nuke_count))
				end
			else
				setCommsMessage(_("needRep-comms", "Insufficient reputation"))
			end
			preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
			addCommsReply(_("Back"),preOrderOrdnance)
		end)
	end
	if comms_source.preorder_repair_crew == nil then
		if random(1,100) <= 20 then
			if comms_source:isFriendly(comms_target) then
				if comms_source:getRepairCrewCount() < comms_source.maxRepairCrew then
					hireCost = math.random(30,60)
				else
					hireCost = math.random(45,90)
				end
				addCommsReply(string.format(_("trade-comms", "Recruit repair crew member for %i reputation"),hireCost), function()
					if not comms_source:takeReputationPoints(hireCost) then
						setCommsMessage(_("needRep-comms", "Insufficient reputation"))
					else
						comms_source.preorder_repair_crew = 1
						setCommsMessage("Repair crew hired on your behalf. They will board when you dock")
					end				
					preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
					addCommsReply(_("Back"),preOrderOrdnance)
				end)
			end
		end
	end
	if comms_source.preorder_coolant == nil then
		if random(1,100) <= 20 then
			if comms_source:isFriendly(comms_target) then
				if comms_source.initialCoolant ~= nil then
					local coolant_cost = math.random(45,90)
					if comms_source:getMaxCoolant() < comms_source.initialCoolant then
						coolant_cost = math.random(30,60)
					end
					addCommsReply(string.format("Set aside coolant for %i reputation",coolant_cost), function()
						if comms_source:takeReputationPoints(coolant_cost) then
							comms_source.preorder_coolant = 2
							setCommsMessage("Coolant set aside for you. It will be loaded when you dock")
						else
							setCommsMessage(_("needRep-comms", "Insufficient reputation"))
						end
						preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
						addCommsReply(_("Back"),preOrderOrdnance)
					end)
				end
			end
		end
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
function wartimeStatistics()
	setCommsMessage("So, what category of wartime statistics are you interested in?")
	addCommsReply("Destroyed assets",function()
		setCommsMessage("What kind of destroyed assets may I show you?")
		addCommsReply("Destroyed Human stations",function()
			if friendlyStationDestroyedNameList ~= nil and #friendlyStationDestroyedNameList > 0 then
				local out = "Destroyed Human Stations (value, name):"
				local friendlyDestructionValue = 0
				for i=1,#friendlyStationDestroyedNameList do
					out = string.format("%s\n    %2d %s",out,friendlyStationDestroyedValue[i],friendlyStationDestroyedNameList[i])
					friendlyDestructionValue = friendlyDestructionValue + friendlyStationDestroyedValue[i]
				end
				local stat_list = gatherStats()
				out = string.format("%s\nTotal: %s (station evaluation weight: %i%%)",out,friendlyDestructionValue,stat_list.human.weight.station*100)
				setCommsMessage(out)
			else
				setCommsMessage("No Human stations have been destroyed (yet)")
			end
			addCommsReply(_("Back"),commsStation)		
		end)
		addCommsReply("Destroyed Kraylor stations",function()
			if enemyStationDestroyedNameList ~= nil and #enemyStationDestroyedNameList > 0 then
				local out = "Destroyed Kraylor Stations (value, name):"
				local enemyDestroyedValue = 0
				for i=1,#enemyStationDestroyedNameList do
					out = string.format("%s\n    %2d %s",out,enemyStationDestroyedValue[i],enemyStationDestroyedNameList[i])
					enemyDestroyedValue = enemyDestroyedValue + enemyStationDestroyedValue[i]
				end
				local stat_list = gatherStats()
				out = string.format("%s\nTotal: %s (station evaluation weight: %i%%)",out,enemyDestroyedValue,stat_list.kraylor.weight.station*100)
				setCommsMessage(out)
			else
				setCommsMessage("No Kraylor stations have been destroyed (yet)")
			end
			addCommsReply(_("Back"),commsStation)		
		end)
		addCommsReply("Destroyed Independent stations",function()
			if neutralStationDestroyedNameList ~= nil and #neutralStationDestroyedNameList > 0 then
				local out = "Destroyed Independent Stations (value, name):"
				local neutralDestroyedValue = 0
				for i=1,#neutralStationDestroyedNameList do
					out = string.format("%s\n    %2d %s",out,neutralStationDestroyedValue[i],neutralStationDestroyedNameList[i])
					neutralDestroyedValue = neutralDestroyedValue + neutralStationDestroyedValue[i]
				end
				local stat_list = gatherStats()
				out = string.format("%s\nTotal: %s (station evaluation weight: %i%%)",out,neutralDestroyedValue,stat_list.human.weight.neutral*100)
				setCommsMessage(out)
			else
				setCommsMessage("No Independent stations have been destroyed (yet)")
			end
			addCommsReply(_("Back"),commsStation)		
		end)
		addCommsReply("Destroyed Human ships",function()
			if friendlyVesselDestroyedNameList ~= nil and #friendlyVesselDestroyedNameList > 0 then
				local out = "Destroyed Human Naval Vessels (value, name, type):"
				local friendlyShipDestroyedValue = 0
				for i=1,#friendlyVesselDestroyedNameList do
					out = string.format("%s\n    %2d %s %s",out,friendlyVesselDestroyedValue[i],friendlyVesselDestroyedNameList[i],friendlyVesselDestroyedType[i])
					friendlyShipDestroyedValue = friendlyShipDestroyedValue + friendlyVesselDestroyedValue[i]
				end
				local stat_list = gatherStats()
				out = string.format("%s\nTotal: %s (ship evaluation weight: %i%%)",out,friendlyShipDestroyedValue,stat_list.human.weight.ship*100)
				setCommsMessage(out)
			else
				setCommsMessage("No Human naval vessels have been destroyed (yet)")
			end
			addCommsReply(_("Back"),commsStation)		
		end)
		addCommsReply("Destroyed Kraylor ships",function()
			if enemyVesselDestroyedNameList ~= nil and #enemyVesselDestroyedNameList > 0 then
				local out = "Destroyed Kraylor Vessels (value, name, type):"
				local enemyShipDestroyedValue = 0
				for i=1,#enemyVesselDestroyedNameList do
					out = string.format("%s\n    %2d %s %s",out,enemyVesselDestroyedValue[i],enemyVesselDestroyedNameList[i],enemyVesselDestroyedType[i])
					enemyShipDestroyedValue = enemyShipDestroyedValue + enemyVesselDestroyedValue[i]
				end
				local stat_list = gatherStats()
				out = string.format("%s\nTotal: %s (ship evaluation weight: %i%%)",out,enemyShipDestroyedValue,stat_list.kraylor.weight.ship*100)
				setCommsMessage(out)
			else
				setCommsMessage("No Kraylor vessels have been destroyed yet. You'd better get busy")
			end
			addCommsReply(_("Back"),commsStation)		
		end)
		addCommsReply(_("Back"),commsStation)
	end)
	addCommsReply("Surviving assets",function()
		setCommsMessage("What kind of surviving assets may I show you?")
		addCommsReply("Surviving Human stations",function()
			local out = "Surviving Human stations (value, name):"
			local friendlySurvivalValue = 0
			for i, station in ipairs(stationList) do
				if station:isValid() then
					if station:isFriendly(comms_source) then
						out = string.format("%s\n    %2d %s",out,station.strength,station:getCallSign())
						friendlySurvivalValue = friendlySurvivalValue + station.strength
					end
				end
			end
			local stat_list = gatherStats()
			out = string.format("%s\nTotal: %s (station evaluation weight: %i%%)",out,friendlySurvivalValue,stat_list.human.weight.station*100)
			setCommsMessage(out)
			addCommsReply(_("Back"),commsStation)
		end)
		addCommsReply("Surviving Kraylor stations",function()
			local out = "Surviving Kraylor stations (value, name):"
			local enemySurvivalValue = 0
			for i, station in ipairs(stationList) do
				if station:isValid() then
					if station:isEnemy(comms_source) then
						out = string.format("%s\n    %2d %s",out,station.strength,station:getCallSign())
						enemySurvivalValue = enemySurvivalValue + station.strength
					end
				end
			end
			local stat_list = gatherStats()
			out = string.format("%s\nTotal: %s (station evaluation weight: %i%%)",out,enemySurvivalValue,stat_list.kraylor.weight.station*100)
			if game_state == "full war" then
				out = string.format("%s\n\nNow that we've been given authorization to destroy Kraylor stations, can you provide the location of one of these staions, please?",out)
				setCommsMessage(out)
				addCommsReply("Get location of one enemy station (5 Rep)",function()
					if comms_source:takeReputationPoints(5) then
						setCommsMessage("Which enemy station are you interested in?")
						local choice_count = 0
						for i, station in ipairs(stationList) do
							if station:isValid() then
								if station:isEnemy(comms_source) then
									choice_count = choice_count + 1
									addCommsReply(station:getCallSign(),function()
										setCommsMessage(string.format("Station %s is in %s",station:getCallSign(),station:getSectorName()))
										addCommsReply(_("Back"),commsStation)
									end)
								end
							end
							if choice_count >= 20 then
								break
							end
						end
					else
						setCommsMessage(_("needRep-comms", "Insufficient reputation"))
					end
				end)
			else
				setCommsMessage(out)
			end
			addCommsReply(_("Back"),commsStation)
		end)
		addCommsReply("Surviving Independent Stations",function()
			local out = "Surviving Independent stations (value, name):"
			local neutralSurvivalValue = 0
			for i, station in ipairs(stationList) do
				if station:isValid() then
					if not station:isFriendly(comms_source) and not station:isEnemy(comms_source)then
						out = string.format("%s\n    %2d %s",out,station.strength,station:getCallSign())
						neutralSurvivalValue = neutralSurvivalValue + station.strength
					end
				end
			end
			local stat_list = gatherStats()
			out = string.format("%s\nTotal: %s (station evaluation weight: %i%%)",out,neutralSurvivalValue,stat_list.human.weight.neutral*100)
			setCommsMessage(out)
			addCommsReply(_("Back"),commsStation)
		end)
		addCommsReply("Surviving Human ships",function()
			local out = "Surviving Human naval vessels (value, name, type):"
			local friendlyShipSurvivedValue = 0
			for j=1,#friendlyFleetList do
				local tempFleet = friendlyFleetList[j]
				for i, tempFriend in ipairs(tempFleet) do
					if tempFriend ~= nil and tempFriend:isValid() then
						local friend_type = tempFriend:getTypeName()
						out = string.format("%s\n    %2d %s %s",out,ship_template[friend_type].strength,tempFriend:getCallSign(),friend_type)
						friendlyShipSurvivedValue = friendlyShipSurvivedValue + ship_template[friend_type].strength
					end
				end
			end
			local stat_list = gatherStats()
			out = string.format("%s\nTotal: %s (ship evaluation weight: %i%%)",out,friendlyShipSurvivedValue,stat_list.human.weight.ship*100)
			setCommsMessage(out)
			addCommsReply(_("Back"),commsStation)
		end)
		addCommsReply("Surviving Kraylor ships",function()
			local out = "Surviving Kraylor vessels (intelligence estimate):"
			local enemyShipSurvivedValue = 0
			local enemyShipCount = 0
			local ship_type_list = {}
			for j=1,#enemyFleetList do
				tempFleet = enemyFleetList[j]
				for i, tempEnemy in ipairs(tempFleet) do
					local enemy_type = tempEnemy:getTypeName()
					enemyShipSurvivedValue = enemyShipSurvivedValue + ship_template[enemy_type].strength
					enemyShipCount = enemyShipCount + 1
					table.insert(ship_type_list,enemy_type)
				end
			end
			local stat_list = gatherStats()
			out = string.format("%s\nApproximately %i ships valued between %i and %i",out,enemyShipCount,math.floor(enemyShipSurvivedValue - random(0,enemyShipSurvivedValue*.3)),math.floor(enemyShipSurvivedValue + random(0,enemyShipSurvivedValue*.3)))
			out = string.format("%s\nAt least one ship is of type %s",out,ship_type_list[math.random(1,#ship_type_list)])
			out = string.format("%s\nShip evaluation weight: %i%%",out,stat_list.kraylor.weight.ship*100)
			setCommsMessage(out)
			addCommsReply(_("Back"),commsStation)
		end)
		addCommsReply(_("Back"),commsStation)
	end)
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
		local secondary_system_repair = {
			{name = "scan_repair",				key = _("scienceDB","Repair scanners")},
			{name = "combat_maneuver_repair",	key = _("scienceDB","Repair combat maneuver")},
			{name = "hack_repair",				key = _("scienceDB","Repair hacking")},
			{name = "probe_launch_repair",		key = _("scienceDB","Repair probe launch")},
			{name = "tube_slow_down_repair",	key = _("scienceDB","Repair slow tube")},
			{name = "self_destruct_repair",		key = _("scienceDB","Repair scanners")},
		}
		for i,ssr in ipairs(secondary_system_repair) do
			if station.comms_data[ssr.name] then
				if station.comms_data.service_cost[ssr.name] ~= nil then
					local val = string.format(_("scienceDB","%s reputation"),station.comms_data.service_cost[ssr.name])
					station_db:setKeyValue(ssr.key,val)
				end
			end
		end
		if station.comms_data.system_repair ~= nil then
			local primary_system_repair = {
				{name = "reactor",			key = _("scienceDB","Repair reactor")},
				{name = "beamweapons",		key = _("scienceDB","Repair beam weapons")},
				{name = "missilesystem",	key = _("scienceDB","Repair missile weapons")},
				{name = "maneuver",			key = _("scienceDB","Repair maneuvering")},
				{name = "impulse",			key = _("scienceDB","Repair impulse")},
				{name = "warp",				key = _("scienceDB","Repair warp drive")},
				{name = "jumpdrive",		key = _("scienceDB","Repair jump drive")},
				{name = "frontshield",		key = _("scienceDB","Repair front shield")},
				{name = "rearshield",		key = _("scienceDB","Repair rear shield")},
			}
			for i,psr in ipairs(primary_system_repair) do
				if station.comms_data.system_repair[psr.name] ~= nil then
					if station.comms_data.system_repair[psr.name].avail then
						local val = string.format(_("scienceDB","%s reputation, up to %.1f%% max"),station.comms_data.system_repair[psr.name].cost,station.comms_data.system_repair[psr.name].max*100)
						station_db:setKeyValue(psr.key,val)
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
		if station.comms_data.characterFunction ~= nil then
			station_db:setKeyValue(station.comms_data.character,station.comms_data.characterShort)
		end
		if station.comms_data.goods ~= nil then
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
-------------------------------
-- Defend ship communication --
-------------------------------
function commsDefendShip()
	if comms_target.comms_data == nil then
		comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
	end
	comms_data = comms_target.comms_data
	setPlayers()
	if comms_source:isFriendly(comms_target) then
		return friendlyDefendComms(comms_data)
	end
	if comms_source:isEnemy(comms_target) and comms_target:isFriendOrFoeIdentifiedBy(comms_source) then
		return enemyDefendComms(comms_data)
	end
	return neutralDefendComms(comms_data)
end
function friendlyDefendComms(comms_data)
	if comms_data.friendlyness < 20 then
		setCommsMessage(_("shipAssist-comms", "What do you want?"));
	else
		setCommsMessage(_("shipAssist-comms", "Sir, how can we assist?"));
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
		addCommsReply(_("Back"), commsDefendShip)
	end)
	return true
end
function enemyDefendComms(comms_data)
    if comms_data.friendlyness > 50 then
        local faction = comms_target:getFaction()
        local taunt_option = _("shipEnemy-comms", "We will see to your destruction!")
        local taunt_success_reply = _("shipEnemy-comms", "Your bloodline will end here!")
        local taunt_failed_reply = _("shipEnemy-comms", "Your feeble threats are meaningless.")
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
        comms_data.friendlyness = comms_data.friendlyness - random(0, 10)
        addCommsReply(taunt_option, function()
            if random(0, 100) < 30 then
                comms_target:orderAttack(player)
                setCommsMessage(taunt_success_reply);
            else
                setCommsMessage(taunt_failed_reply);
            end
        end)
        return true
    end
    return false
end
function neutralDefendComms(comms_data)
    if comms_data.friendlyness > 50 then
        setCommsMessage(_("ship-comms", "Sorry, we have no time to chat with you.\nWe are on an important mission."));
    else
        setCommsMessage(_("ship-comms", "We have nothing for you.\nGood day."));
    end
    return true
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
	setPlayers()
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
	addCommsReply(_("shipAssist-comms", "Defend a waypoint"), function()
		if comms_source:getWaypointCount() == 0 then
			setCommsMessage(_("shipAssist-comms", "No waypoints set. Please set a waypoint first."));
			addCommsReply(_("Back"), commsShip)
		else
			setCommsMessage(_("shipAssist-comms", "Which waypoint should we defend?"));
			for n=1,comms_source:getWaypointCount() do
				addCommsReply(string.format(_("shipAssist-comms", "Defend WP %d"), n), function()
					if treaty then
						local tempAsteroid = VisualAsteroid():setPosition(comms_source:getWaypoint(n))
						local waypointInBorderZone = false
						for i=1,#borderZone do
							if borderZone[i]:isInside(tempAsteroid) then
								waypointInBorderZone = true
								break
							end
						end
						if waypointInBorderZone then
							setCommsMessage("We cannot break the treaty by defending WP" .. n .. " in the neutral border zone")
						elseif outerZone:isInside(tempAsteroid) then
							setCommsMessage("We cannot break the treaty by defending WP" .. n .. " across the neutral border zones")							
						else
							comms_target:orderDefendLocation(comms_source:getWaypoint(n))
							setCommsMessage(string.format(_("shipAssist-comms", "We are heading to assist at WP %d."), n));
						end
						tempAsteroid:destroy()
					else
						comms_target:orderDefendLocation(comms_source:getWaypoint(n))
						setCommsMessage(string.format(_("shipAssist-comms", "We are heading to assist at WP %d."), n));
					end
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
		if isObjectType(obj,"SpaceStation") and not comms_target:isEnemy(obj) then
			addCommsReply(string.format(_("shipAssist-comms", "Dock at %s"), obj:getCallSign()), function()
				setCommsMessage(string.format(_("shipAssist-comms", "Docking at %s."), obj:getCallSign()));
				comms_target:orderDock(obj)
				addCommsReply(_("Back"), commsShip)
			end)
		end
	end
--	print("comms target dot fleet:",comms_target.fleet,"initial assets evaluated:",initialAssetsEvaluated,"game time limit:",gameTimeLimit)
	if comms_target.fleet ~= nil and initialAssetsEvaluated then
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
			addCommsReply("Report missile status", function()
				msg = "Fleet missile status:"
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
						addCommsReply(string.format(_("shipAssist-comms", "Defend waypoint %d"), n), function()
							if treaty then
								local tempAsteroid = VisualAsteroid():setPosition(comms_source:getWaypoint(n))
								local waypointInBorderZone = false
								for i=1,#borderZone do
									if borderZone[i]:isInside(tempAsteroid) then
										waypointInBorderZone = true
										break
									end
								end
								if waypointInBorderZone then
									setCommsMessage(string.format(_("shipAssist-comms", "We cannot break the treaty by defending WP %d in the neutral border zone"), n))
								elseif outerZone:isInside(tempAsteroid) then
									setCommsMessage(string.format(_("shipAssist-comms", "We cannot break the treaty by defending WP %d across the neutral border zones"), n))							
								else
									for i, fleetShip in ipairs(friendlyDefensiveFleetList[comms_target.fleet]) do
										if fleetShip ~= nil and fleetShip:isValid() then
											fleetShip:orderDefendLocation(comms_source:getWaypoint(n))
										end
									end
									setCommsMessage(string.format(_("shipAssist-comms", "We are heading to assist at WP %d."), n));
								end
								tempAsteroid:destroy()
							else
								for i, fleetShip in ipairs(friendlyDefensiveFleetList[comms_target.fleet]) do
									if fleetShip ~= nil and fleetShip:isValid() then
										fleetShip:orderDefendLocation(comms_source:getWaypoint(n))
									end
								end
								setCommsMessage(string.format(_("shipAssist-comms", "We are heading to assist at WP %d."), n));
							end
							addCommsReply(_("Back"), commsShip)
						end)
					end
				end
			end)
			if not treaty and limitedWarTimer <= 0 then
				addCommsReply(_("shipAssist-comms", "Go offensive, attack all enemy targets"), function()
					for i, fleetShip in ipairs(friendlyDefensiveFleetList[comms_target.fleet]) do
						if fleetShip ~= nil and fleetShip:isValid() then
							fleetShip:orderRoaming()
						end
					end
					setCommsMessage(string.format(_("shipAssist-comms", "%s is on an offensive rampage"),comms_target.fleet))
					addCommsReply(_("Back"), commsShip)
				end)
			end
		end)
	end
	if shipCommsDiagnostic then print("done with fleet buttons") end
	local shipType = comms_target:getTypeName()
	if shipCommsDiagnostic then print("got ship type") end
	if shipType:find("Freighter") ~= nil then
		if shipCommsDiagnostic then print("it's a freighter") end
		if distance_diagnostic then print("distance_diagnostic 8",comms_source,comms_target) end
		if distance(comms_source, comms_target) < 5000 then
			if shipCommsDiagnostic then print("close enough to trade or sell") end
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
			taunt_threshold = 25
			immolation_threshold = 4
			setCommsMessage(_("shipEnemy-comms", "We wish you no harm, but will harm you if we must.\nEnd of transmission."));
		elseif faction == "Exuari" then
			taunt_threshold = 40
			immolation_threshold = 7
			setCommsMessage(_("shipEnemy-comms", "Stay out of our way, or your death will amuse us extremely!"));
		elseif faction == "Ghosts" then
			taunt_threshold = 20
			immolation_threshold = 3
			setCommsMessage(_("shipEnemy-comms", "One zero one.\nNo binary communication detected.\nSwitching to universal speech.\nGenerating appropriate response for target from human language archives.\n:Do not cross us:\nCommunication halted."));
			taunt_option = _("shipEnemy-comms", "EXECUTE: SELFDESTRUCT")
			taunt_success_reply = _("shipEnemy-comms", "Rogue command received. Targeting source.")
			taunt_failed_reply = _("shipEnemy-comms", "External command ignored.")
		elseif faction == "Ktlitans" then
			setCommsMessage(_("shipEnemy-comms", "The hive suffers no threats. Opposition to any of us is opposition to us all.\nStand down or prepare to donate your corpses toward our nutrition."));
			taunt_option = _("shipEnemy-comms", "<Transmit 'The Itsy-Bitsy Spider' on all wavelengths>")
			taunt_success_reply = _("shipEnemy-comms", "We do not need permission to pluck apart such an insignificant threat.")
			taunt_failed_reply = _("shipEnemy-comms", "The hive has greater priorities than exterminating pests.")
		elseif faction == "TSN" then
			taunt_threshold = 15
			immolation_threshold = 2
			setCommsMessage(_("shipEnemy-comms", "State your business"))
		elseif faction == "USN" then
			taunt_threshold = 15
			immolation_threshold = 2
			setCommsMessage(_("shipEnemy-comms", "What do you want? (not that we care)"))
		elseif faction == "CUF" then
			taunt_threshold = 15
			immolation_threshold = 2
			setCommsMessage(_("shipEnemy-comms", "Don't waste our time"))
		else
			setCommsMessage(_("shipEnemy-comms", "Mind your own business!"));
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
					setCommsMessage("Subspace and time continuum disruption authorized")
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
		addCommsReply("Stop your actions",function()
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
				setCommsMessage("Just this once, we'll take your advice")
			else
				setCommsMessage("No")
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
		for i, enemy in ipairs(enemy_reverts) do
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
						p:addCustomInfo("Relay",p.continuum_timer_display,timer_display)
					end
					if p:hasPlayerAtPosition("Operations") then
						p.continuum_timer_display_ops = "continuum_timer_display_ops"
						p:addCustomInfo("Operations",p.continuum_timer_display_ops,timer_display)
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
    array[selected_item], array[array_item_count] = array[array_item_count], array[selected_item]
    return table.remove(array)
end
function placeRandomAsteroidsAroundPoint(amount, dist_min, dist_max, x0, y0)
-- create amount of asteroid, at a distance between dist_min and dist_max around the point (x0, y0)
    for n=1,amount do
    	for i=1,3 do
			local r = random(0, 360)
			local distance = random(dist_min, dist_max)
			x = x0 + math.cos(r / 180 * math.pi) * distance
			y = y0 + math.sin(r / 180 * math.pi) * distance
			local asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
			if i == 1 then
				Asteroid():setPosition(x, y):setSize(asteroid_size)
			else
				VisualAsteroid():setPosition(x,y):setSize(asteroid_size)
			end
		end
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
	local radialPoint = 0
	if amount > arcLen then
		for ndex=1,arcLen do
			radialPoint = startArc+ndex
			for i=1,3 do
				local pointDist = distance + random(-randomize,randomize)
				asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
				if i == 1 then
					Asteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist):setSize(asteroid_size)
				else
					VisualAsteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist):setSize(asteroid_size)
				end
			end
		end
		for ndex=1,amount-arcLen do
			radialPoint = random(startArc,endArcClockwise)
			for i=1,3 do
				pointDist = distance + random(-randomize,randomize)
				asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
				if i == 1 then
					Asteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist):setSize(asteroid_size)
				else
					VisualAsteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist):setSize(asteroid_size)
				end
			end
		end
	else
		for ndex=1,amount do
			radialPoint = random(startArc,endArcClockwise)
			for i=1,3 do
				pointDist = distance + random(-randomize,randomize)
				asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
				if i == 1 then
					Asteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist):setSize(asteroid_size)
				else
					VisualAsteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist):setSize(asteroid_size)
				end
			end
		end
	end
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
function closestPlayerTo(obj)
-- Return the player ship closest to passed object parameter
-- Return nil if no valid result
-- Assumes a maximum of 8 player ships
	if obj ~= nil and obj:isValid() then
		local closestDistance = 9999999
		local closestPlayer = nil
		for pidx=1,32 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if distance_diagnostic then print("distance_diagnostic 10",p,obj) end
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
function nearStations(nobj, compareStationList)
--nobj = named object for comparison purposes (stations, players, etc)
--compareStationList = list of stations to compare against
	local remainingStations = {}
	local closestDistance = 9999999
	for ri, obj in ipairs(compareStationList) do
		if obj ~= nil and obj:isValid() and obj:getCallSign() ~= nobj:getCallSign() then
			table.insert(remainingStations,obj)
			if distance_diagnostic then print("distance_diagnostic 11",nobj,obj) end
			local currentDistance = distance(nobj, obj)
			if currentDistance < closestDistance then
				closestObj = obj
				closestDistance = currentDistance
			end
		end
	end
	for i=1,#remainingStations do
		if remainingStations[i]:getCallSign() == closestObj:getCallSign() then
			table.remove(remainingStations,i)
			break
		end
	end
	return closestObj, remainingStations
end
function spawnEnemies(xOrigin, yOrigin, danger, enemyFaction, enemyStrength, shape, spawn_distance, spawn_angle, px, py)
	if enemyFaction == nil then
		enemyFaction = "Kraylor"
	end
	if danger == nil then 
		danger = 1
	end
	if enemyStrength == nil then
		enemyStrength = math.max(danger * enemy_power * playerPower(),5)
	end
	local enemy_position = 0
	local sp = irandom(400,900)			--random spacing of spawned group
	if shape == nil then
		shape = "square"
		if random(1,100) < 50 then
			shape = "hexagonal"
		end
	end
	local deployConfig = random(1,100)	--randomly choose between squarish formation and hexagonish formation
	local enemyList = {}
	template_pool_size = 10
	local template_pool = getTemplatePool(enemyStrength)
	if #template_pool < 1 then
		addGMMessage(_("msgGM", "Empty Template pool: fix excludes or other criteria"))
		return enemyList
	end
	local prefix = generateCallSignPrefix(1)
	while enemyStrength > 0 do
		local selected_template = template_pool[math.random(1,#template_pool)]
		local ship = ship_template[selected_template].create(enemyFaction,selected_template)
		if enemyFaction == "Kraylor" then
			rawKraylorShipStrength = rawKraylorShipStrength + ship_template[selected_template].strength
			ship:onDestroyed(enemyVesselDestroyed)
		elseif enemyFaction == "Human Navy" then
			rawHumanShipStrength = rawHumanShipStrength + ship_template[selected_template].strength
			ship:onDestroyed(friendlyVesselDestroyed)
		end
		enemy_position = enemy_position + 1
		if shape == "none" or shape == "pyramid" or shape == "ambush" then
			ship:setPosition(xOrigin,yOrigin)
		else
			ship:setPosition(xOrigin + formation_delta[shape].x[enemy_position] * sp, yOrigin + formation_delta[shape].y[enemy_position] * sp)
		end
		ship:setCommsScript(""):setCommsFunction(commsShip)
		table.insert(enemyList, ship)
		ship:setCallSign(generateCallSign(nil,enemyFaction))
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
		for i, enemy in ipairs(enemyList) do
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
		for i, current_ship_template in ipairs(ship_template_by_strength) do
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
function nameShip(p,p_type)
	if predefined_player_ships ~= nil and #predefined_player_ships > 0 then
		p:setCallSign(predefined_player_ships[1].name)
		if predefined_player_ships[1].control_code ~= nil then
			p.control_code = predefined_player_ships[1].control_code
			p:setControlCode(predefined_player_ships[1].control_code)
		end
		table.remove(predefined_player_ships,1)
	else
		if playerShipNamesFor[p_type] ~= nil and #playerShipNamesFor[p_type] > 0 then
			p:setCallSign(tableRemoveRandom(playerShipNamesFor[p_type]))
		else
			if #playerShipNamesFor["Leftovers"] > 0 then
				p:setCallSign(tableRemoveRandom(playerShipNamesFor["Leftovers"]))
			end
		end
	end
end
--	Player functions
function setPlayer(pobj)
	if pobj.goods == nil then
		pobj.goods = {}
	end
	if pobj.initialRep == nil then
		pobj:addReputationPoints(starting_reputation)
		pobj.initialRep = true
	end
	if not pobj.nameAssigned then
		pobj.nameAssigned = true
		local tempPlayerType = pobj:getTypeName()
		pobj.shipScore = playerShipStats[tempPlayerType].strength
		pobj.maxCargo = playerShipStats[tempPlayerType].cargo
		pobj:setLongRangeRadarRange(playerShipStats[tempPlayerType].long_range_radar)
		pobj:setShortRangeRadarRange(playerShipStats[tempPlayerType].short_range_radar)
		pobj.tractor = playerShipStats[tempPlayerType].tractor
		pobj.mining = playerShipStats[tempPlayerType].mining
		pobj.mining_target_lock = false
		pobj.mining_in_progress = false
		nameShip(pobj,tempPlayerType)
		if tempPlayerType == "MP52 Hornet" then
			pobj.autoCoolant = false
			pobj:setWarpDrive(true)
		elseif tempPlayerType == "Phobos M3P" then
			pobj:setWarpDrive(true)
			pobj:setWarpSpeed(500)
		elseif tempPlayerType == "Player Fighter" then
			pobj.autoCoolant = false
			pobj:setJumpDrive(true)
			pobj.max_jump_range = 40000
			pobj.min_jump_range = 3000
			pobj:setJumpDriveRange(pobj.min_jump_range,pobj.max_jump_range)
			pobj:setJumpDriveCharge(pobj.max_jump_range)
		elseif tempPlayerType == "Striker" then
			if pobj:getImpulseMaxSpeed() == 45 then
				pobj:setImpulseMaxSpeed(90)
			end
			if pobj:getBeamWeaponCycleTime(0) == 6 then
				local bi = 0
				repeat
					local tempArc = pobj:getBeamWeaponArc(bi)
					local tempDir = pobj:getBeamWeaponDirection(bi)
					local tempRng = pobj:getBeamWeaponRange(bi)
					local tempDmg = pobj:getBeamWeaponDamage(bi)
					pobj:setBeamWeapon(bi,tempArc,tempDir,tempRng,5,tempDmg)
					bi = bi + 1
				until(pobj:getBeamWeaponRange(bi) < 1)
			end
			pobj:setJumpDrive(true)
			pobj.max_jump_range = 40000
			pobj.min_jump_range = 3000
			pobj:setJumpDriveRange(pobj.min_jump_range,pobj.max_jump_range)
			pobj:setJumpDriveCharge(pobj.max_jump_range)
		elseif tempPlayerType == "ZX-Lindworm" then
			pobj.autoCoolant = false
			pobj:setWarpDrive(true)
		else	--leftovers
			if playerShipStats[tempPlayerType] == nil then
				pobj.shipScore = 24
				pobj.maxCargo = 5
				pobj:setWarpDrive(true)
				pobj:setWarpSpeed(500)
				pobj:setLongRangeRadarRange(30000)
				pobj:setShortRangeRadarRange(5000)
				pobj.tractor = false
				pobj.mining = false
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
			local system_types = {"reactor","beamweapons","missilesystem","maneuver","impulse","warp","jumpdrive","frontshield","rearshield"}
			pobj.normal_coolant_rate = {}
			pobj.normal_power_rate = {}
			for i, system in ipairs(system_types) do
				pobj.normal_coolant_rate[system] = pobj:getSystemCoolantRate(system)
				pobj.normal_power_rate[system] = pobj:getSystemPowerRate(system)
			end
		end
		if pobj:hasJumpDrive() then
			if pobj.max_jump_range == nil then
				pobj.max_jump_range = 50000
				pobj.min_jump_range = 5000
			end
		end
	end
	pobj.initialCoolant = pobj:getMaxCoolant()
end
function setPlayers()
--set up players with name, goods, cargo space, reputation and either a warp drive or a jump drive if applicable
	local active_player_count = 0
	for p1idx=1,32 do
		pobj = getPlayerShip(p1idx)
		if pobj ~= nil and pobj:isValid() then
			active_player_count = active_player_count + 1
			setPlayer(pobj)
		end
	end
	if active_player_count ~= banner["number_of_players"] then
		resetBanner()
	end
end
function resetBanner(evalFriendly,evalEnemy)
	local active_player_count = 0
	local players_relative_strength = 0
	banner["player"] = {}
	for pidx=1,32 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			active_player_count = active_player_count + 1
			players_relative_strength = players_relative_strength + p.shipScore
			table.insert(banner["player"],{index = pidx, name = p:getCallSign(), type_name = p:getTypeName(), strength = p.shipScore })
		end
	end
	banner["player_strength"] = players_relative_strength
	banner["number_of_players"] = active_player_count
	local banner_string = string.format("Number of player ships: %i.  Relative strength of all player ships: %i.  Player ships:",banner["number_of_players"],banner["player_strength"])
	for i, player in pairs(banner["player"]) do
		banner_string = string.format("%s  Index: %i, Name: %s, Type: %s, Relative Strength: %i",banner_string,player.index,player.name,player.type_name,player.strength)
	end
	local war_state = "War State:"
	if treaty then
		if treatyTimer == nil then
			war_state = string.format("%s undefined",war_state)
		elseif treatyTimer < 0 then
			war_state = string.format("%s Treaty holds. Kraylors belligerent",war_state)
		else
			war_state = string.format("%s Treaty holds",war_state)
		end
	else
		if limitedWarTimer < 0 then
			war_state = string.format("%s War, destroy all Kraylor assets",war_state)
		else
			war_state = string.format("%s War, preserve Kraylor stations",war_state)
		end
	end
	banner_string = string.format("%s  %s",banner_string,war_state)
	if evalFriendly ~= nil then
		banner_string = string.format("%s  Friendly: %.1f  Enemy: %.1f  Difference: %.1f",banner_string,evalFriendly,evalEnemy,evalFriendly-evalEnemy)
	end
	setBanner(banner_string)
end
function expediteDockCheck(delta, p)
	if p.expedite_dock then
		if p.expedite_dock_timer == nil then
			p.expedite_dock_timer = p.expedite_dock_timer_max + delta
		end
		p.expedite_dock_timer = p.expedite_dock_timer - delta
		if p.expedite_dock_timer < 0 then
			if p.expedite_dock_timer < -1 then
				if p.expedite_dock_timer_info ~= nil then
					p:removeCustom(p.expedite_dock_timer_info)
					p.expedite_dock_timer_info = nil
				end
				if p.expedite_dock_timer_info_ops ~= nil then
					p:removeCustom(p.expedite_dock_timer_info_ops)
					p.expedite_dock_timer_info_ops = nil
				end
				p.expedite_dock = nil
				p:addToShipLog(string.format("Docking crew of station %s returned to their normal duties",p.expedite_doc_station:getCallSign()),"Yellow")
				p.expedite_timer = nil
				p.expedite_dock_station = nil
				p.preorder_hvli = nil
				p.preorder_homing = nil
				p.preorder_emp = nil
				p.preorder_nuke = nil
				p.preorder_repair_crew = nil
				p.preorder_coolant = nil
			else
				if p:hasPlayerAtPosition("Relay") then
					p.expedite_dock_timer_info = "expedite_dock_timer_info"
					p:addCustomInfo("Relay",p.expedite_dock_timer_info,_("-tabRelay", "Fast Dock Expired"))						
				end
				if p:hasPlayerAtPosition("Operations") then
					p.expedite_dock_timer_info_ops = "expedite_dock_timer_info_ops"
					p:addCustomInfo("Operations",p.expedite_dock_timer_info_ops,_("-tabOperations", "Fast Dock Expired"))						
				end
			end
		else	--timer not expired
			local expedite_dock_timer_status = _("-tabRelay&Operations", "Fast Dock")
			local expedite_dock_timer_minutes = math.floor(p.expedite_dock_timer / 60)
			local expedite_dock_timer_seconds = math.floor(p.expedite_dock_timer % 60)
			if expedite_dock_timer_minutes <= 0 then
				expedite_dock_timer_status = string.format(_("-tabRelay&Operations", "%s %i"),expedite_dock_timer_status,expedite_dock_timer_seconds)
			else
				expedite_dock_timer_status = string.format(_("-tabRelay&Operations", "%s %i:%.2i"),expedite_dock_timer_status,expedite_dock_timer_minutes,expedite_dock_timer_seconds)
			end
			if p:hasPlayerAtPosition("Relay") then
				p.expedite_dock_timer_info = "expedite_dock_timer_info"
				p:addCustomInfo("Relay",p.expedite_dock_timer_info,expedite_dock_timer_status)
			end
			if p:hasPlayerAtPosition("Operations") then
				p.expedite_dock_timer_info_ops = "expedite_dock_timer_info_ops"
				p:addCustomInfo("Operations",p.expedite_dock_timer_info_ops,expedite_dock_timer_status)
			end					
		end
		if p.expedite_dock_station ~= nil and p.expedite_dock_station:isValid() then
			if p:isDocked(p.expedite_dock_station) then
				p:setEnergy(p:getMaxEnergy())
				p:setScanProbeCount(p:getMaxScanProbeCount())
				if p.preorder_hvli ~= nil then
					local new_amount = math.min(p:getWeaponStorage("HVLI") + p.preorder_hvli,p:getWeaponStorageMax("HVLI"))
					p:setWeaponStorage("HVLI",new_amount)
				end
				if p.preorder_homing ~= nil then
					new_amount = math.min(p:getWeaponStorage("Homing") + p.preorder_homing,p:getWeaponStorageMax("Homing"))
					p:setWeaponStorage("Homing",new_amount)
				end
				if p.preorder_mine ~= nil then
					new_amount = math.min(p:getWeaponStorage("Mine") + p.preorder_mine,p:getWeaponStorageMax("Mine"))
					p:setWeaponStorage("Mine",new_amount)
				end
				if p.preorder_emp ~= nil then
					new_amount = math.min(p:getWeaponStorage("EMP") + p.preorder_emp,p:getWeaponStorageMax("EMP"))
					p:setWeaponStorage("EMP",new_amount)
				end
				if p.preorder_nuke ~= nil then
					new_amount = math.min(p:getWeaponStorage("Nuke") + p.preorder_nuke,p:getWeaponStorageMax("Nuke"))
					p:setWeaponStorage("Nuke",new_amount)
				end
				if p.preorder_repair_crew ~= nil then
					p:setRepairCrewCount(p:getRepairCrewCount() + 1)
					resetPreviousSystemHealth(p)
				end
				if p.preorder_coolant ~= nil then
					p:setMaxCoolant(p:getMaxCoolant() + 2)
				end
				if p.expedite_dock_timer_info ~= nil then
					p:removeCustom(p.expedite_dock_timer_info)
					p.expedite_dock_timer_info = nil
				end
				if p.expedite_dock_timer_info_ops ~= nil then
					p:removeCustom(p.expedite_dock_timer_info_ops)
					p.expedite_dock_timer_info_ops = nil
				end
				p:addToShipLog(string.format("Docking crew at station %s completed replenishment as requested",p.expedite_dock_station:getCallSign()),"Yellow")
				p.expedite_dock = nil
				p.expedite_timer = nil
				p.expedite_dock_station = nil
				p.preorder_hvli = nil
				p.preorder_homing = nil
				p.preorder_emp = nil
				p.preorder_nuke = nil
				p.preorder_repair_crew = nil
				p.preorder_coolant = nil
			end
		end
	end
end
--		Mortal repair crew functions. Includes coolant loss as option to losing repair crew
function healthCheck(delta, p)
	healthCheckTimer = healthCheckTimer - delta
	if healthCheckTimer < 0 then
		if healthDiagnostic then print("health check timer expired") end
		if p:getRepairCrewCount() > 0 then
			p.system_choice_list = {}
			if healthDiagnostic then print("crew on valid ship") end
			local fatalityChance = 0
			if healthDiagnostic then print("shields") end
			sc = p:getShieldCount()
			if healthDiagnostic then print("sc: " .. sc) end
			if p:getShieldCount() > 1 then
				cShield = (p:getSystemHealth("frontshield") + p:getSystemHealth("rearshield"))/2
				if p.prevShield - cShield > 0 then
					table.insert(p.system_choice_list,"frontShield")
					table.insert(p.system_choice_list,"rearshield")
				end
			else
				cShield = p:getSystemHealth("frontshield")
				if p.prevShield - cShield > 0 then
					table.insert(p.system_choice_list,"frontShield")
				end
			end
			fatalityChance = fatalityChance + (p.prevShield - cShield)
			p.prevShield = cShield
			if healthDiagnostic then print("reactor") end
			if p.prevReactor - p:getSystemHealth("reactor") > 0 then
				table.insert(p.system_choice_list,"reactor")
			end
			fatalityChance = fatalityChance + (p.prevReactor - p:getSystemHealth("reactor"))
			p.prevReactor = p:getSystemHealth("reactor")
			if healthDiagnostic then print("maneuver") end
			if p.prevManeuver - p:getSystemHealth("maneuver") > 0 then
				table.insert(p.system_choice_list,"maneuver")
			end
			fatalityChance = fatalityChance + (p.prevManeuver - p:getSystemHealth("maneuver"))
			p.prevManeuver = p:getSystemHealth("maneuver")
			if healthDiagnostic then print("impulse") end
			if p.prevImpulse - p:getSystemHealth("impulse") > 0 then
				table.insert(p.system_choice_list,"impulse")
			end
			fatalityChance = fatalityChance + (p.prevImpulse - p:getSystemHealth("impulse"))
			p.prevImpulse = p:getSystemHealth("impulse")
			if healthDiagnostic then print("beamweapons") end
			if p:getBeamWeaponRange(0) > 0 then
				if p.healthyBeam == nil then
					p.healthyBeam = 1.0
					p.prevBeam = 1.0
				end
				if p.prevBeam - p:getSystemHealth("beamweapons") > 0 then
					table.insert(p.system_choice_list,"beamweapons")
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
				if p.prevMissile - p:getSystemHealth("missilesystem") > 0 then
					table.insert(p.system_choice_list,"missilesystem")
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
				if p.prevWarp - p:getSystemHealth("warp") > 0 then
					table.insert(p.system_choice_list,"warp")
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
				if p.prevJump - p:getSystemHealth("jumpdrive") > 0 then
					table.insert(p.system_choice_list,"jumpdrive")
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
				if p:hasPlayerAtPosition("DamageControl") then
					local repairCrewRecoveryDmg = "repairCrewRecoveryDmg"
					p:addCustomMessage("DamageControl",repairCrewRecoveryDmg,_("repairCrew-msgDamageControl", "Medical team has revived one of your repair crew"))
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
						if p:hasPlayerAtPosition("DamageControl") then
							p:addCustomMessage("DamageControl","coolant_recovery_dmg",_("coolant-msgDamageControl", "Automated systems have recovered some coolant"))
						end
					end
					resetPreviousSystemHealth(p)
				end
			end
		end
		healthCheckTimer = delta + healthCheckTimerInterval
		local stat_list = gatherStats()
		resetBanner(stat_list.human.evaluation,stat_list.kraylor.evaluation)
		local eval_status = string.format(_("-tabRelay&Operations", "F:%.1f%% E:%.1f%% D:%.1f%%"),stat_list.human.evaluation,stat_list.kraylor.evaluation,stat_list.human.evaluation-stat_list.kraylor.evaluation)
		for pidx=1,32 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if p:hasPlayerAtPosition("Relay") then
					p.eval_status = "eval_status"
					p:addCustomInfo("Relay",p.eval_status,eval_status)
				end
				if p:hasPlayerAtPosition("Operations") then
					p.eval_status_operations = "eval_status_operations"
					p:addCustomInfo("Operations",p.eval_status_operations,eval_status)
				end
			end
		end
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
			if p:hasPlayerAtPosition("DamageControl") then
				local repairCrewFatalityDmg = "repairCrewFatalityDmg"
				p:addCustomMessage("DamageControl",repairCrewFatalityDmg,_("repairCrew-msgDamageControl", "One of your repair crew has perished"))
			end
		else
			local damaged_system = p.system_choice_list[math.random(1,#p.system_choice_list)]
			local damage = p:getSystemHealth(damaged_system)
			damage = (1 - damage)*.3
			p:setSystemHealthMax(damaged_system,p:getSystemHealthMax(damaged_system) - damage)
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
			if p:getSystemCoolantRate("reactor") >= p.normal_coolant_rate["reactor"] then
				upper_consequence = upper_consequence + 1
				table.insert(consequence_list,"reactor_coolant_pump")
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
				if p:hasPlayerAtPosition("DamageControl") then
					local repairCrewFatalityDmg = "repairCrewFatalityDmg"
					p:addCustomMessage("DamageControl",repairCrewFatalityDmg,_("repairCrew-msgDamageControl", "One of your repair crew has perished"))
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
					p:addCustomMessage("Engineering",coolantLoss,_("damage-msgEngineer", "Damage has caused a loss of coolant"))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					local coolantLossPlus = "coolantLossPlus"
					p:addCustomMessage("Engineering+",coolantLossPlus,_("damage-msgEngineer+", "Damage has caused a loss of coolant"))
				end
				if p:hasPlayerAtPosition("DamageControl") then
					local coolantLossDmg = "coolantLossDmg"
					p:addCustomMessage("DamageControl",coolantLossDmg,_("damage-msgDamageControl", "Damage has caused a loss of coolant"))
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
					if p:hasPlayerAtPosition("DamageControl") then
						p:addCustomMessage("DamageControl","probe_launch_damage_message_dmg",_("damage-msgDamageControl", "The probe launch system has been damaged"))
					end
				elseif named_consequence == "hack" then
					p:setCanHack(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","hack_damage_message",_("damage-msgEngineer", "The hacking system has been damaged"))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","hack_damage_message_plus",_("damage-msgEngineer+", "The hacking system has been damaged"))
					end
					if p:hasPlayerAtPosition("DamageControl") then
						p:addCustomMessage("DamageControl","hack_damage_message_dmg",_("damage-msgDamageControl", "The hacking system has been damaged"))
					end
				elseif named_consequence == "scan" then
					p:setCanScan(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","scan_damage_message",_("damage-msgEngineer", "The scanners have been damaged"))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","scan_damage_message_plus",_("damage-msgEngineer+", "The scanners have been damaged"))
					end
					if p:hasPlayerAtPosition("DamageControl") then
						p:addCustomMessage("DamageControl","scan_damage_message_dmg",_("damage-msgDamageControl", "The scanners have been damaged"))
					end
				elseif named_consequence == "combat_maneuver" then
					p:setCanCombatManeuver(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","combat_maneuver_damage_message",_("damage-msgEngineer", "Combat maneuver has been damaged"))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","combat_maneuver_damage_message_plus",_("damage-msgEngineer+", "Combat maneuver has been damaged"))
					end
					if p:hasPlayerAtPosition("DamageControl") then
						p:addCustomMessage("DamageControl","combat_maneuver_damage_message_dmg",_("damage-msgDamageControl", "Combat maneuver has been damaged"))
					end
				elseif named_consequence == "self_destruct" then
					p:setCanSelfDestruct(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","self_destruct_damage_message",_("damage-msgEngineer", "Self destruct system has been damaged"))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","self_destruct_damage_message_plus",_("damage-msgEngineer+", "Self destruct system has been damaged"))
					end
					if p:hasPlayerAtPosition("DamageControl") then
						p:addCustomMessage("DamageControl","self_destruct_damage_message_dmg",_("damage-msgDamageControl", "Self destruct system has been damaged"))
					end
				elseif named_consequence == "reactor_coolant_pump" then
					p:setSystemCoolantRate("reactor",p:getSystemCoolantRate("reactor")/2)
					resetCoolantPumpButtons(p)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","reactor_coolant_pump_damage_message",_("damage-msgEngineer", "Reactor coolant pump has been damaged"))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","reactor_coolant_pump_damage_message_plus",_("damage-msgEngineer+", "Reactor coolant pump has been damaged"))
					end
					if p:hasPlayerAtPosition("DamageControl") then
						p:addCustomMessage("DamageControl","reactor_coolant_pump_damage_message_dmg",_("damage-msgDamageControl", "Reactor coolant pump has been damaged"))
					end
				end
			end	--coolant loss branch
		end
	end
end
--      Inventory button and functions for relay/operations 
function cargoInventory(p)
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
				p:addCustomButton("Relay",tbi,_("inventory-buttonRelay", "Inventory"),function() playerShipCargoInventory(p) end)
				p.inventoryButton = true
			end
		end
		if p:hasPlayerAtPosition("Operations") then
			if p.inventoryButton == nil then
				local tbi = "inventoryOp" .. p:getCallSign()
				p:addCustomButton("Operations",tbi,_("inventory-buttonOperations", "Inventory"),function() playerShipCargoInventory(p) end)
				p.inventoryButton = true
			end
		end
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
--      Enable and disable auto-cooling on a ship functions
function autoCoolant(p)
	if p.autoCoolant ~= nil then
		if p:hasPlayerAtPosition("Engineering") then
			if p.autoCoolButton == nil then
				local tbi = "enableAutoCool" .. p:getCallSign()
				p:addCustomButton("Engineering",tbi,_("coolant-buttonEngineer", "Auto cool"),function() 
					string.format("")	--global context for serious proton
					p:commandSetAutoRepair(true)
					p:setAutoCoolant(true)
					p.autoCoolant = true
				end)
				tbi = "disableAutoCool" .. p:getCallSign()
				p:addCustomButton("Engineering",tbi,_("coolant-buttonEngineer", "Manual cool"),function()
					string.format("")	--global context for serious proton
					p:commandSetAutoRepair(false)
					p:setAutoCoolant(false)
					p.autoCoolant = false
				end)
				p.autoCoolButton = true
			end
		end
		if p:hasPlayerAtPosition("Engineering+") then
			if p.autoCoolButton == nil then
				tbi = "enableAutoCoolPlus" .. p:getCallSign()
				p:addCustomButton("Engineering+",tbi,_("coolant-buttonEngineer+", "Auto cool"),function()
					string.format("")	--global context for serious proton
					p:commandSetAutoRepair(true)
					p:setAutoCoolant(true)
					p.autoCoolant = true
				end)
				tbi = "disableAutoCoolPlus" .. p:getCallSign()
				p:addCustomButton("Engineering+",tbi,_("coolant-buttonEngineer+", "Manual cool"),function()
					string.format("")	--global context for serious proton
					p:commandSetAutoRepair(false)
					p:setAutoCoolant(false)
					p.autoCoolant = false
				end)
				p.autoCoolButton = true
			end
		end
		if p:hasPlayerAtPosition("DamageControl") then
			if p.autoCoolButton == nil then
				tbi = "enableAutoCoolDmg" .. p:getCallSign()
				p:addCustomButton("DamageControl",tbi,_("coolant-buttonDamageControl", "Auto cool"),function()
					string.format("")	--global context for serious proton
					p:commandSetAutoRepair(true)
					p:setAutoCoolant(true)
					p.autoCoolant = true
				end)
				tbi = "disableAutoCoolDmg" .. p:getCallSign()
				p:addCustomButton("DamageControl",tbi,_("coolant-buttonDamageControl", "Manual cool"),function()
					string.format("")	--global context for serious proton
					p:commandSetAutoRepair(false)
					p:setAutoCoolant(false)
					p.autoCoolant = false
				end)
				p.autoCoolButton = true
			end
		end
	end
end
--		Gain or lose coolant from nebula functions
function coolantNebulae(delta, p)
	local inside_gain_coolant_nebula = false
	for i=1,#coolant_nebula do
--		if distance_diagnostic then print("distance_diagnostic 12",p,coolant_nebula[i]) end
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
	if inside_gain_coolant_nebula then
		if p.get_coolant then
			if p.coolant_trigger then
				updateCoolantGivenPlayer(p, delta)
			end
		else
			if p:hasPlayerAtPosition("Engineering") then
				p.get_coolant_button = "get_coolant_button"
				p:addCustomButton("Engineering",p.get_coolant_button,_("coolant-buttonEngineer", "Get Coolant"),function() getCoolantGivenPlayer(p) end)
				p.get_coolant = true
			end
			if p:hasPlayerAtPosition("Engineering+") then
				p.get_coolant_button_plus = "get_coolant_button_plus"
				p:addCustomButton("Engineering+",p.get_coolant_button_plus,_("coolant-buttonEngineer+", "Get Coolant"),function() getCoolantGivenPlayer(p) end)
				p.get_coolant = true
			end
			if p:hasPlayerAtPosition("DamageControl") then
				p.get_coolant_button_dmg = "get_coolant_button_dmg"
				p:addCustomButton("DamageControl",p.get_coolant_button_dmg,_("coolant-buttonDamageControl", "Get Coolant"),function() getCoolantGivenPlayer(p) end)
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
		if p:hasPlayerAtPosition("DamageControl") then
			if p.get_coolant_button_dmg ~= nil then
				p:removeCustom(p.get_coolant_button_dmg)
				p.get_coolant_button_dmg = nil
			end
			if p.gather_coolant_dmg ~= nil then
				p:removeCustom(p.gather_coolant_dmg)
				p.gather_coolant_dmg = nil
			end
		end
	end
end
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
			gather_coolant_status = string.format(_("coolant-tabEngineer&Engineer+", "Deploying Collectors %i"),math.ceil(p.deploy_coolant_timer - delta))
		end
	else
		gather_coolant_status = string.format(_("coolant-tabEngineer&Engineer+", "Configuring Collectors %i"),math.ceil(p.configure_coolant_timer - delta))
	end
	if p:hasPlayerAtPosition("Engineering") then
		p.gather_coolant = "gather_coolant"
		p:addCustomInfo("Engineering",p.gather_coolant,gather_coolant_status)
	end
	if p:hasPlayerAtPosition("Engineering+") then
		p.gather_coolant_plus = "gather_coolant_plus"
		p:addCustomInfo("Engineering+",p.gather_coolant_plus,gather_coolant_status)
	end
	if p:hasPlayerAtPosition("DamageControl") then
		p.gather_coolant_dmg = "gather_coolant_dmg"
		p:addCustomInfo("DamageControl",p.gather_coolant_dmg,gather_coolant_status)
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

--------------------
-- Plot functions --
--------------------
-- Transport plot 
function randomStation(randomStations)
	local randomlySelectedStation = nil
	local stationAttemptCount = 0
	repeat
		stationAttemptCount = stationAttemptCount + 1
		local candidate = randomStations[math.random(1,#randomStations)]
		if candidate ~= nil and candidate:isValid() then
			randomlySelectedStation = candidate
		end
	until(randomlySelectedStation ~= nil or stationAttemptCount > 100)
	return randomlySelectedStation
end
function randomNearStation(pool,nobj,partialStationList)
--pool = number of nearest stations to randomly choose from
--nobj = named object for comparison purposes
--partialStationList = list of station to compare against
	local distanceStations = {}
	local rs = {}
	local ni
	local cs
	cs, rs[1] = nearStations(nobj,partialStationList)
	table.insert(distanceStations,cs)
	for ni=2,pool do
		cs, rs[ni] = nearStations(nobj,rs[ni-1])
		table.insert(distanceStations,cs)
	end
	randomlySelectedStation = distanceStations[math.random(1,pool)]
	return randomlySelectedStation
end
function kraylorTransportPlot(delta)
	if kraylor_transport_spawn_time == nil then
		kraylor_transport_spawn_time = getScenarioTime() + random(8,20)
	end
	if getScenarioTime() > kraylor_transport_spawn_time then
		kraylor_transport_spawn_time = nil
		kraylorTransportCount = 0
		invalidKraylorTransportCount = 0
		for kidx, kobj in ipairs(kraylorTransportList) do
			if kobj:isValid() then
				kraylorTransportCount = kraylorTransportCount + 1
				if kobj.target ~= nil and kobj.target:isValid() then
					if kobj:isDocked(kobj.target) then
						if kobj.undock_delay > 0 then
							kobj.undock_delay = kobj.undock_delay - 1
						else
							kobj.target = randomNearStation(math.random(math.min(3,#kraylorStationList),math.min(7,#kraylorStationList)),kobj,kraylorStationList)
							kobj.undock_delay = math.random(1,4)
							kobj:orderDock(kobj.target)
						end
					end
				else
					kobj.target = randomNearStation(math.random(math.min(3,#kraylorStationList),math.min(7,#kraylorStationList)),kobj,kraylorStationList)
					kobj.undock_delay = math.random(1,4)
					kobj:orderDock(kobj.target)
				end
			else
				invalidKraylorTransportCount = invalidKraylorTransportCount + 1
			end
		end
		if invalidKraylorTransportCount > 0 then
			kraylorTransportCount = 0
			tempTransportList = {}
			for i, kobj in ipairs(kraylorTransportList) do
				if kobj ~= nil and kobj:isValid() then
					table.insert(tempTransportList,kobj)
					kraylorTransportCount = kraylorTransportCount + 1
				end
			end
			kraylorTransportList = tempTransportList
		end
		if kraylorTransportCount < math.max(#kraylorStationList/2,5) then
			target = nil
			transportAttemptCount = 0
			repeat
				transportAttemptCount = transportAttemptCount + 1
				target = randomStation(kraylorStationList)
			until((target ~= nil and target:isValid()) or transportAttemptCount > 100)
			if target ~= nil and target:isValid() then
				rnd = math.random(1,5)
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
				if random(1,100) < 40 then
					name = name .. " Jump Freighter " .. irandom(3, 5)
				else
					name = name .. " Freighter " .. irandom(1, 5)
				end
				kobj = CpuShip():setTemplate(name):setFaction('Kraylor'):setCommsScript(""):setCommsFunction(commsShip)
				kobj:setCallSign(generateCallSign(nil,"Kraylor"))
				kobj.target = target
				kobj.undock_delay = math.random(1,4)
				kobj:orderDock(kobj.target)
				kx, ky = kobj.target:getPosition()
				xd, yd = vectorFromAngle(random(0, 360), random(25000, 40000))
				kobj:setPosition(kx + xd, ky + yd)
				table.insert(kraylorTransportList,kobj)
			end
		end
	end
	plotVT = independentTransportPlot
end
function independentTransportPlot(delta)
	if independent_transport_spawn_time == nil then
		independent_transport_spawn_time = getScenarioTime() + random(10,30)
	end
	if getScenarioTime() > independent_transport_spawn_time then
		independent_transport_spawn_time = nil
		independentTransportCount = 0
		invalidIndependentTransportCount = 0
		for tidx, obj in ipairs(independentTransportList) do
			if obj:isValid() then
				independentTransportCount = independentTransportCount + 1
				if obj.target ~= nil and obj.target:isValid() then
					if obj:isDocked(obj.target) then
						if obj.undock_delay > 0 then
							obj.undock_delay = obj.undock_delay - 1
						else
							obj.target = randomNearStation(math.random(math.min(4,#neutralStationList),math.min(8,#neutralStationList)),obj,neutralStationList)
							obj.undock_delay = math.random(1,4)
							obj:orderDock(obj.target)
						end
					end
				else
					obj.target = randomNearStation(math.random(math.min(4,#neutralStationList),math.min(8,#neutralStationList)),obj,neutralStationList)
					obj.undock_delay = math.random(1,4)
					obj:orderDock(obj.target)
				end
			else
				invalidIndependentTransportCount = invalidIndependentTransportCount + 1
			end
		end
		if invalidIndependentTransportCount > 0 then
			independentTransportCount = 0
			tempTransportList = {}
			for i, obj in ipairs(independentTransportList) do
				if obj ~= nil and obj:isValid() then
					table.insert(independentTransportList,obj)
					independentTransportCount = independentTransportCount + 1
				end
			end
			independentTransportList = tempTransportList
		end
		if independentTransportCount < #neutralStationList then
			target = nil
			transportAttemptCount = 0
			repeat
				transportAttemptCount = transportAttemptCount + 1
				target = randomStation(neutralStationList)				
			until((target ~= nil and target:isValid()) or transportAttemptCount > 100)
			if target ~= nil and target:isValid() then
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
					name = name .. " Jump Freighter " .. irandom(3, 5)
				else
					name = name .. " Freighter " .. irandom(1, 5)
				end
				obj = CpuShip():setTemplate(name):setFaction('Independent'):setCommsScript(""):setCommsFunction(commsShip)
				obj:setCallSign(generateCallSign(nil,"Independent"))
				obj.target = target
				obj.undock_delay = irandom(1,4)
				obj:orderDock(obj.target)
				x, y = obj.target:getPosition()
				xd, yd = vectorFromAngle(random(0, 360), random(25000, 40000))
				obj:setPosition(x + xd, y + yd)
				table.insert(independentTransportList, obj)
			end
		end
	end
	plotVT = friendlyTransportPlot
end
function friendlyTransportPlot(delta)
	if friendly_transport_spawn_time == nil then
		friendly_transport_spawn_time = getScenarioTime() + random(10,30)
	end
	if getScenarioTime() > friendly_transport_spawn_time then
		friendly_transport_spawn_time = nil
		local friendlyTransportCount = 0
		for tidx, obj in ipairs(friendlyTransportList) do
			if obj ~= nil and obj:isValid() then
				friendlyTransportCount = friendlyTransportCount + 1
				if obj.target ~= nil and obj.target:isValid() then
					if obj:isDocked(obj.target) then
						if obj.undock_delay > 0 then
							obj.undock_delay = obj.undock_delay - 1
						else
							obj.target = randomNearStation(math.random(math.min(4,#humanStationList),math.min(8,#humanStationList)),obj,humanStationList)
							obj.undock_delay = math.random(1,4)
							obj:orderDock(obj.target)
						end
					end
				else
					local transportAttemptCount = 0
					local lowerNear = math.min(4,#humanStationList)
					local upperNear = math.min(8,#humanStationList)
					local randomPool = math.random(lowerNear,upperNear)
					repeat
						transportAttemptCount = transportAttemptCount + 1
						local candidate = randomNearStation(randomPool,obj,humanStationList)
					until((candidate ~= nil and candidate:isValid()) or transportAttemptCount > repeatExitBoundary)
					if candidate ~= nil and candidate:isValid() then
						obj.target = candidate
						obj.undock_delay = math.random(1,4)
						obj:orderDock(obj.target)
					end
				end
			end
		end
		if friendlyTransportCount < math.max(#humanStationList/2,5) then
			target = nil
			local transportAttemptCount = 0
			repeat
				transportAttemptCount = transportAttemptCount + 1
				target = randomStation(humanStationList)				
			until((target ~= nil and target:isValid()) or transportAttemptCount > repeatExitBoundary)
			if target ~= nil and target:isValid() then
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
					fSize = irandom(3, 5)
					name = name .. " Jump Freighter " .. fSize
				else
					fSize = irandom(1, 5)
					name = name .. " Freighter " .. fSize
				end
				obj = CpuShip():setTemplate(name):setFaction('Human Navy'):setCommsScript(""):setCommsFunction(commsShip)
				obj:setCallSign(generateCallSign(nil,"Human Navy"))
				obj.target = target
				obj.undock_delay = irandom(1,4)
				obj:orderDock(obj.target)
				x, y = obj.target:getPosition()
				xd, yd = vectorFromAngle(random(0, 360), random(25000, 40000))
				obj:setPosition(x + xd, y + yd)
				table.insert(friendlyTransportList, obj)
			end
		end
	end
	plotVT = kraylorTransportPlot	
end
-- Plot 1 peace/treaty/war states
function playerPlotMessages(p)
	if plot1 == treatyHolds then
		--plot1 treaty holds message 1
		if p.order1 == nil then
			if p.nameAssigned then
				p:addToShipLog(string.format("Greetings captain and crew of %s. The Human/Kraylor treaty has held for a number of years now, but tensions are rising. Your mission: patrol the border area for Kraylor ships. Do not enter the blue neutral border zone. Good luck",p:getCallSign()),"Magenta")
				p.order1 = "sent"
				p.prewar_improvement = getScenarioTime() + 120
			else
				setPlayer(p)
			end
		else
			if p.order1_prewar_improvement == nil and p.prewar_improvement < getScenarioTime() then
				p:addToShipLog("Feel free to check with friendly stations while you patrol. Some of them may have people living there that can improve your ship, but they may want you to bring them something in exchange.","Magenta")
				p.order1_prewar_improvement = "sent"
			end
		end
	end
	if plot1 == treatyStressed then
		if p.order2 == nil then
			if not p.nameAssigned then
				setPlayer(p)
			end
			p:addToShipLog(string.format("%s, The Kraylors threaten to break the treaty. We characterize this behavior as mere sabre rattling. Nevertheless, keep a close watch on the neutral border zone. Until war is actually declared, you are not, I repeat, *not* authorized to enter the neutral border zone",p:getCallSign()),"Magenta")
			p.order2 = "sent"
		end
	end
	if plot1 == limitedWar then
		if p.order3 == nil then
			if not p.nameAssigned then
				setPlayer(p)
			end
			p:addToShipLog(string.format("To: Commanding Officer of %s",p:getCallSign()),"Magenta")
			p:addToShipLog("From: Human Navy Headquarters","Magenta")
			p:addToShipLog("    War declared on Kraylors.","Magenta")
			p:addToShipLog("    Target any Kraylor vessel.","Magenta")
			p:addToShipLog("    Avoid targeting Kraylor stations.","Magenta")
			p:addToShipLog("End official dispatch","Magenta")
			p.order3 = "sent"
		end
	end
	if plot1 == nil and targetKraylorStations then
		if p.order4 == nil then
			if not p.nameAssigned then
				setPlayer(p)
			end
			p:addToShipLog(string.format("To: Commanding Officer of %s",p:getCallSign()),"Magenta")
			p:addToShipLog("From: Human Navy Headquarters","Magenta")
			p:addToShipLog("    War continues on Kraylors.","Magenta")
			p:addToShipLog("    Intelligence reports Kraylors targeting civilian assets.","Magenta")
			p:addToShipLog("    All Kraylor targets may be destroyed.","Magenta")
			p:addToShipLog("End official dispatch","Magenta")
			p.order4 = "sent"
		end
	end
end
function treatyHolds(delta)
	game_state = "treaty holds"
	primaryOrders = "Treaty holds. Patrol border. Stay out of blue neutral border zone"
	if treatyTimer == nil then
		if playWithTimeLimit then
			treatyTimer = random(lrr4,urr4)
		else
			treatyTimer = random(lrr5,urr5)
		end
	end
	if playWithTimeLimit then
		if getScenarioTime() > 120 and not initialAssetsEvaluated then
			evaluateInitialAssets()
		end
	else
		if treatyTimer < 40 and not initialAssetsEvaluated then
			evaluateInitialAssets()
		end
	end
	treatyTimer = treatyTimer - delta
	if treatyTimer < 0 then
		if playWithTimeLimit then
			treatyStressTimer = random(lrr4,urr4)
		else
			treatyStressTimer = random(lrr5,urr5)
		end
		primaryOrders = "Treaty holds, Kraylors belligerent. Patrol border. Stay out of blue neutral border zone"
		if GMBelligerentKraylors ~= nil then
			removeGMFunction(GMBelligerentKraylors)
		end
		GMBelligerentKraylors = nil
		globalMessage("Kraylors Belligerent")
		plot1 = treatyStressed
	end
end
function treatyStressed(delta)
	game_state = "kraylors belligerent"
	treatyStressTimer = treatyStressTimer - delta
	if not initialAssetsEvaluated then
		if playWithTimeLimit then
			if getScenarioTime() > 120 then
				evaluateInitialAssets()
			end
		else
			evaluateInitialAssets()
		end
	end
	if treatyStressTimer < 0 then
		if playWithTimeLimit then
			limitedWarTimer = gameTimeLimit/2
		else
			limitedWarTimer = random(300,600)
		end
		for i=1,#borderZone do
			borderZone[i]:setColor(255,0,0)
		end
		primaryOrders = "War declared. Destroy any Kraylor vessels. Avoid destruction of Kraylor stations"
		if GMLimitedWar ~= nil then
			removeGMFunction(GMLimitedWar)
		end
		GMLimitedWar = nil
		treaty = false
		targetKraylorStations = false
		plot1 = limitedWar
		globalMessage("War With Kraylors Declared")
	end
end
function limitedWar(delta)
	game_state = "limited war"
	if not initialAssetsEvaluated then
		if playWithTimeLimit then
			if getScenarioTime() > 120 then
				evaluateInitialAssets()
			end
		else
			evaluateInitialAssets()
		end
	end
	limitedWarTimer = limitedWarTimer - delta
	if limitedWarTimer < 0 then
		game_state = "full war"
		primaryOrders = "War continues. Atrocities suspected. Destroy any Kraylor vessels or stations"
		if GMFullWar ~= nil then
			removeGMFunction(GMFullWar)
		end
		GMFullWar = nil
		targetKraylorStations = true
		plot1 = nil
		globalMessage("Kraylors Target Civilians. Destroy All Kraylors")
	end
end
function evaluateInitialAssets()
	--delay on evaluation due to avoid penalizing players for black hole destruction due to random placement
	initialAssetsEvaluated = true
	originalHumanStationCount = 0
	originalHumanStationValue = 0
	humanCentroidX = 0
	humanCentroidY = 0
	for i=1,#humanStationList do
		if humanStationList[i] ~= nil and humanStationList[i]:isValid() then
			csx, csy = humanStationList[i]:getPosition()
			humanCentroidX = humanCentroidX + csx
			humanCentroidY = humanCentroidY + csy
			originalHumanStationCount = originalHumanStationCount + 1
			originalHumanStationValue = originalHumanStationValue + humanStationList[i].strength
		end
	end
	humanCentroidX = humanCentroidX/originalHumanStationCount
	humanCentroidY = humanCentroidY/originalHumanStationCount
	originalKraylorStationCount = 0
	originalKraylorStationValue = 0
	kraylorCentroidX = 0
	kraylorCentroidY = 0
	for i=1,#kraylorStationList do
		if kraylorStationList[i] ~= nil and kraylorStationList[i]:isValid() then
			csx, csy = kraylorStationList[i]:getPosition()
			kraylorCentroidX = kraylorCentroidX + csx
			kraylorCentroidY = kraylorCentroidY + csy
			originalKraylorStationCount = originalKraylorStationCount + 1
			originalKraylorStationValue = originalKraylorStationValue + kraylorStationList[i].strength
		end
	end
	kraylorCentroidX = kraylorCentroidX/originalKraylorStationCount
	kraylorCentroidY = kraylorCentroidY/originalKraylorStationCount
	originalNeutralStationCount = 0
	originalNeutralStationValue = 0
	attackAngle = angleFromVector(kraylorCentroidX, kraylorCentroidY, humanCentroidX, humanCentroidY)
	referenceStartX = (kraylorCentroidX + humanCentroidX)/2
	referenceStartY = (kraylorCentroidY + humanCentroidY)/2
	for i=1,#neutralStationList do
		if neutralStationList[i] ~= nil and neutralStationList[i]:isValid() then
			originalNeutralStationCount = originalNeutralStationCount + 1
			originalNeutralStationValue = originalNeutralStationValue + neutralStationList[i].strength
		end
	end
	local playerShipNames = {}
	for pidx=1,32 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			table.insert(playerShipNames,p:getCallSign())
			p:addToShipLog(string.format("To: Commanding officer of %s",p:getCallSign()),"Magenta")
			p:addToShipLog("From: Human Navy Headquarters","Magenta")
			p:addToShipLog("    Fleet admiral relieved of fleet command duties.","Magenta")
			p:addToShipLog("    You are granted fleet disposition authority.","Magenta")
			p:addToShipLog("    Fleet assets know to respond to your Relay officer's directives.","Magenta")
			p:addToShipLog("    Prepare for imminent Kraylor intrusion.","Magenta")
		end
	end
	globalMessage("Fleet Disposition Authority Granted")
	if plot1Diagnostic then
		for i=1,#playerShipNames do
			print(i .. ": " .. playerShipNames[i])
		end
	end
	for pidx=1,32 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if #playerShipNames > 1 then
				coordinateList = ""
				for i=1,#playerShipNames do
					if plot1Diagnostic then print(playerShipNames[i]) end
					if playerShipNames[i] ~= p:getCallSign() then
						if plot1Diagnostic then print("    added") end
						coordinateList = coordinateList .. playerShipNames[i] .. ", "
					else
						if plot1Diagnostic then print("    skipped") end
					end
				end
				coordinateList = string.sub(coordinateList,1,string.len(coordinateList)-2)
				if #playerShipNames > 2 then
					p:addToShipLog("    Coordinate with commanders of " .. coordinateList .. ".","Magenta")
				else
					p:addToShipLog("    Coordinate with commander of " .. coordinateList .. ".","Magenta")
				end
			end
			p:addToShipLog("End official dispatch","Magenta")
		end
	end
	plot3 = initialAttack
end
-- Plot 2 timed game
function timedGame(delta)
	gameTimeLimit = gameTimeLimit - delta
	if gameTimeLimit < 0 then
		if plot2diagnostic then print("game time limit expired") end
		missionVictory = true
		if plot2diagnostic then print("boolean set") end
		missionCompleteReason = string.format("Player survived for %i minutes",defaultGameTimeLimitInMinutes)
		if plot2diagnostic then print("reason set") end
		endStatistics()
		if plot2diagnostic then print("finished end stats page") end
		game_state = "victory-human"
		victory("Human Navy")
	end
end
-- Plot 3 kraylor attack scheme
function initialAttack(delta)
	if plot3diagnostic then print("initial attack") end
	local enemyInitialFleet = spawnEnemies(kraylorCentroidX, kraylorCentroidY, 1.3, "Kraylor")
	for i, enemy in ipairs(enemyInitialFleet) do
		enemy:orderFlyTowards(humanCentroidX, humanCentroidY)
		enemy.initialFleetMember = true
	end
	if plot3diagnostic then print("initial fleet created") end
	table.insert(enemyFleetList,enemyInitialFleet)
	if playWithTimeLimit then
		pincerTimer = random(lrr1,urr1)
	else
		pincerTimer = random(lrr2,urr2)
	end
	if plot3diagnostic then print("pincer timer: " .. pincerTimer) end
	plot3 = pincerAttack
end
function pincerAttack(delta)
	pincerTimer = pincerTimer - delta
	if pincerTimer < 0 then
		if plot3diagnostic then print("pincer timer expired") end
		if distance_diagnostic then print("distance_diagnostic 13",kraylorCentroidX,kraylorCentroidY,referenceStartX,referenceStartY) end
		local pincerSize = distance(kraylorCentroidX,kraylorCentroidY,referenceStartX,referenceStartY)*random(.4,.7)
		foundInitialFleetMember = false
		for i=1,#enemyFleetList do
			for j=1,#enemyFleetList[i] do
				exampleEnemy = enemyFleetList[i][j]
				if exampleEnemy.initialFleetMember then
					foundInitialFleetMember = true
					break
				end
			end
			if foundInitialFleetMember then
				break
			end
		end
		if foundInitialFleetMember then
			pincerAngle = exampleEnemy:getHeading()
		else
			if attackAngle ~= nil then
				pincerAngle = attackAngle
			else
				pincerAngle = angleFromVector(kraylorCentroidX, kraylorCentroidY, humanCentroidX, humanCentroidY)
			end
		end
		if pincerAngle == nil then
			pincerAngle = random(0,360)
			print(string.format("-----     Nil angle observed. Choosing random angle: %.1f",pincerAngle))
			if foundInitialFleetMember then
				print("pincer angle should have come from example enemy")
			else
				if attackAngle ~= nil then
					print("pincer angle should have come from attack angle")
				else
					print("pincer angle should have come from centroids")
				end
			end
		end
		leftPincerAngle = pincerAngle
		if leftPincerAngle > 360 then
			leftPincerAngle = leftPincerAngle - 360
		end
		leftPincerX, leftPincerY = vectorFromAngle(leftPincerAngle,pincerSize)
		rightPincerAngle = pincerAngle + 180
		if rightPincerAngle > 360 then
			rightPincerAngle = rightPincerAngle - 360
		end
		rightPincerX, rightPincerY = vectorFromAngle(rightPincerAngle,pincerSize)
		if plot3diagnostic then print(string.format("Angles: Pincer: %.1f, Left: %.1f, Right: %.1f",pincerAngle,leftPincerAngle,rightPincerAngle)) end
		local enemyLeftPincerFleet = spawnEnemies(referenceStartX+leftPincerX,referenceStartY+leftPincerY,1.5,"Kraylor")
		for i, enemy in ipairs(enemyLeftPincerFleet) do
			enemy:orderRoaming()
		end
		table.insert(enemyFleetList,enemyLeftPincerFleet)
		local enemyRightPincerFleet = spawnEnemies(referenceStartX+rightPincerX,referenceStartY+rightPincerY,1.5,"Kraylor")
		for i, enemy in ipairs(enemyRightPincerFleet) do
			enemy:orderRoaming()
		end
		table.insert(enemyFleetList,enemyRightPincerFleet)
		if playWithTimeLimit then
			vengenceTimer = random(lrr1,urr1)
		else
			vengenceTimer = random(lrr2,urr2)
		end
		if plot3diagnostic then print("pincer fleets established") end
		plot3 = vengence
	end
end
function vengence(delta)
	vengenceTimer = vengenceTimer - delta
	if vengenceTimer < 0 then
		local availableVengenceCount = 0
		if plot3diagnostic then print("vengence prep") end
		for i=1,#enemyDefensiveFleetList do
			local tempFleet = enemyDefensiveFleetList[i]
			local viableCount = 0
			local onVengence = false
			for i, enemy in ipairs(tempFleet) do
				if enemy ~= nil and enemy:isValid() then
					viableCount = viableCount + 1
					if enemy.vengence then
						onVengence = true
						break
					end
				end
			end
			if viableCount > 0 and not onVengence then
				availableVengenceCount = availableVengenceCount + 1
			end
		end
		if plot3diagnostic then print("vengence prep complete") end
		if availableVengenceCount > 0 then
			if plot3diagnostic then print("fleets available") end
			local vengenceFleet = nil
			local edfi = 0
			repeat
				edfi = math.random(1,#enemyDefensiveFleetList)
				local candidate = enemyDefensiveFleetList[edfi]
				local availableVengence = true
				for i, enemy in ipairs(candidate) do
					if enemy ~= nil and enemy:isValid() and enemy.vengence then
						availableVengence = false
						break
					end
				end
				if availableVengence then
					vengenceFleet = candidate
				end
			until(vengenceFleet ~= nil)
			intelGatherArtifacts[edfi]:setDescriptions(_("scienceDescription-artifact", "Scan to gather intelligence"),string.format(_("scienceDescription-artifact", "Enemy fleet in sector %s is on the move"),intelGatherArtifacts[edfi].startSector))
			for i, enemy in ipairs(vengenceFleet) do
				if enemy ~= nil and enemy:isValid() then
					enemy:orderRoaming()
					enemy.vengence = true
				end
			end
			if playWithTimeLimit then
				vengenceTimer = delta + random(lrr3,urr3)
			else
				vengenceTimer = delta + random(lrr2,urr2)
			end
		else
			if plot3diagnostic then print("fleet unavailable, end of vengence plot") end
			plot3 = nil
		end
	end
end
function angleFromVector(p1x, p1y, p2x, p2y)
	TWOPI = 6.2831853071795865
	RAD2DEG = 57.2957795130823209
	atan2parm1 = p2x - p1x
	atan2parm2 = p2y - p1y
	theta = math.atan2(atan2parm1, atan2parm2)
	if theta < 0 then
		theta = theta + TWOPI
	end
	return RAD2DEG * theta
end
-- Plot enemy defenses check
function setEnemyStationDefenses()
	for i=1,#kraylorStationList do
		local curEStation = kraylorStationList[i]
		if curEStation ~= enemyFleet1base and curEStation ~= enemyFleet2base and curEStation ~= enemyFleet3base and curEStation ~= enemyFleet4base and curEStation ~= enemyFleet5base then
			curEStation.defenseDeployed = false
			local defensiveChoice = random(1,100)
			--local defensiveChoice = 85	--test ambush
			if defensiveChoice < 10 then		--	fighter fleet
				curEStation.defenseType = "fighterFleet"
				curEStation.defenseTriggerDistance = random(2000,5000)
			elseif defensiveChoice < 20 then	--	zone of ship damage (and temporary counter)
				curEStation.defenseType = "zoneDamage"
				curEStation.defenseTriggerDistance = random(2000,5000)
			elseif defensiveChoice < 30 then	--	call for help from nearby station
				curEStation.defenseType = "callInHelp"
				curEStation.defenseTriggerDistance = random(2000,5000)
			elseif defensiveChoice < 40 then	--	mine or minefield
				curEStation.defenseType = "minefield"
				curEStation.defenseTriggerDistance = random(2000,5000)
			elseif defensiveChoice < 50 then	--	deploy wormhole
				curEStation.defenseType = "wormhole"
				curEStation.defenseTriggerDistance = random(2000,5000)
			elseif defensiveChoice < 60 then	--	decoy transport (explosive)
				curEStation.defenseType = "transport"
				curEStation.defenseTriggerDistance = random(2000,5000)
			elseif defensiveChoice < 70 then	--	deploy weapons platform
				curEStation.defenseType = "weaponPlatform"
				curEStation.defenseTriggerDistance = random(2000,5000)
			elseif defensiveChoice < 80 then	--	jammer fleet
				curEStation.defenseType = "jammerFleet"
				curEStation.defenseTriggerDistance = random(2000,5000)
			elseif defensiveChoice < 90 then
				curEStation.defenseType = "ambush"
				curEStation.defenseTriggerDistance = random(2000,5000)
			else								--	drone fleet
				curEStation.defenseType = "droneFleet"
				curEStation.defenseTriggerDistance = random(2000,5000)
			end
		else
			curEStation.defenseDeployed = true
		end
	end
end
function enemyDefenseCheck(delta)
	for pidx=1,32 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			for i, enemyStation in ipairs(kraylorStationList) do
				if enemyStation ~= nil and enemyStation:isValid() and not enemyStation.defenseDeployed then
--					if distance_diagnostic then print("distance_diagnostic 14",p,enemyStation) end
					local distToEnemyStation = distance(p,enemyStation)
					if distToEnemyStation < enemyStation.defenseTriggerDistance then
						if enemyStation.defenseType == "fighterFleet" then
							esx, esy = enemyStation:getPosition()
							local ef, efp = spawnFighterFleet(esx, esy, difficulty*4, "Kraylor")
							for j, enemy in ipairs(ef) do
								enemy:orderDefendTarget(enemyStation)
							end
							table.insert(enemyFleetList,ef)
							enemyStation.defenseDeployed = true
						elseif enemyStation.defenseType == "jammerFleet" then
							if jammerList == nil then
								jammerList = {}
							end
							esx, esy = enemyStation:getPosition()
							tpx, tpy = p:getPosition()
							attackAngle = p:getRotation() + 180
							tj = WarpJammer():setPosition(esx,esy):setRange(5000):setFaction("Kraylor")
							tj.travelAngle = attackAngle
							tj.triggerDistance = distToEnemyStation
							tj.originX = esx
							tj.originY = esy
							tj.orbit = false
							table.insert(jammerList,tj)
							tj = WarpJammer():setPosition(esx,esy):setRange(5000):setFaction("Kraylor")
							tj.travelAngle = attackAngle + 120
							tj.triggerDistance = distToEnemyStation
							tj.originX = esx
							tj.originY = esy
							tj.orbit = false
							table.insert(jammerList,tj)
							tj = WarpJammer():setPosition(esx,esy):setRange(5000):setFaction("Kraylor")
							tj.travelAngle = attackAngle + 240
							tj.triggerDistance = distToEnemyStation
							tj.originX = esx
							tj.originY = esy
							tj.orbit = false
							table.insert(jammerList,tj)
							enemyStation.defenseDeployed = true
							plotWJ = warpJammerOrbit
						elseif enemyStation.defenseType == "zoneDamage" then
							if defensiveZoneList == nil then
								defensiveZoneList = {}
								p:addToShipLog(string.format("[Sensor technician]: Station %s is putting out some kind of energy field. It could damage our systems",enemyStation:getCallSign()),"Magenta")
							end
							esx, esy = enemyStation:getPosition()
							dh2x, dh2y = vectorFromAngle(60,distToEnemyStation)
							dh4x, dh4y = vectorFromAngle(120,distToEnemyStation)
							dh6x, dh6y = vectorFromAngle(180,distToEnemyStation)
							dh8x, dh8y = vectorFromAngle(240,distToEnemyStation)
							dh10x, dh10y = vectorFromAngle(300,distToEnemyStation)
							dh12x,dh12y = vectorFromAngle(0,distToEnemyStation)
							sz = Zone():setPoints(esx+dh2x,esy+dh2y,
												  esx+dh4x,esy+dh4y,
												  esx+dh6x,esy+dh6y,
												  esx+dh8x,esy+dh8y,
												  esx+dh10x,esy+dh10y,
												  esx+dh12x,esy+dh12y)
							table.insert(defensiveZoneList,sz)
							enemyStation.defenseDeployed = true
							sz.revealDelay = 15
							sz.system = hitZonePermutations[math.random(1,51)]
							plotDZ = enemyDefenseZoneCheck
						elseif enemyStation.defenseType == "callInHelp" then
							local nearestStation, rest = nearStations(enemyStation, kraylorStationList)
							esx, esy = nearestStation:getPosition()
							local ef, efp = spawnEnemies(esx, esy, 1, "Kraylor")
							for j, enemy in ipairs(ef) do
								enemy:orderAttack(p)
							end
							table.insert(enemyFleetList,ef)
							enemyStation.defenseDeployed = true
						elseif enemyStation.defenseType == "ambush" then
							local apx, apy = p:getPosition()
							local ef = spawnEnemies(apx, apy, 1, "Kraylor", nil, "ambush", (enemyStation.defenseTriggerDistance - 500)/1000)
							table.insert(enemyFleetList,ef)
							enemyStation.defenseDeployed = true
						elseif enemyStation.defenseType == "minefield" then
							esx, esy = enemyStation:getPosition()
							tpx, tpy = p:getPosition()
							attackAngle = p:getRotation() + 180
							if artMineList == nil then
								artMineList = {}
							end
							tam = Artifact():setPosition(esx,esy):setModel("artifact4"):allowPickup(false)
							tam.travelAngle = attackAngle
							tam.triggerDistance = distToEnemyStation
							tam.originX = esx
							tam.originY = esy
							table.insert(artMineList,tam)
							enemyStation.defenseDeployed = true
							plotAM = artifactToMinefield
						elseif enemyStation.defenseType == "wormhole" then
							esx, esy = enemyStation:getPosition()
							tpx,tpy = p:getPosition()
							attackAngle = p:getRotation() + 180
							if artWormList == nil then
								artWormList = {}
							end
							taw = Artifact():setPosition(esx,esy):setModel("artifact4"):allowPickup(false)
							taw.travelAngle = attackAngle
							taw.triggerDistance = distToEnemyStation
							taw.originX = esx
							taw.originY = esy
							table.insert(artWormList,taw)
							enemyStation.defenseDeployed = true
							plotAW = artifactToWorm
						elseif enemyStation.defenseType == "transport" then
							esx, esy = enemyStation:getPosition()
							local rnd = irandom(1,5)
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
							if irandom(1,100) < 50 then
								name = name .. " Jump Freighter " .. irandom(3, 5)
							else
								name = name .. " Freighter " .. irandom(1, 5)
							end
							if deadlyTransportList == nil then
								deadlyTransportList = {}
							end
							vx, vy = vectorFromAngle(random(0,360),random(25000,30000))
							tdt = CpuShip():setTemplate(name):setFaction('Kraylor'):setCommsScript(""):setCommsFunction(commsShip):orderDock(enemyStation):setPosition(esx+vx,esy+vy)
							tdt:setCallSign(generateCallSign(nil,"Kraylor"))
							table.insert(deadlyTransportList,tdt)
							plotExpTrans = explosiveTransportCheck
							enemyStation.defenseDeployed = true
						elseif enemyStation.defenseType == "weaponPlatform" then
							esx, esy = enemyStation:getPosition()
							tpx, tpy = p:getPosition()
							attackAngle = p:getRotation() + 180
							if artPlatformList == nil then
								artPlatformList = {}
							end
							tap = Artifact():setPosition(esx,esy):setModel("artifact4"):allowPickup(false)
							tap.travelAngle = attackAngle
							tap.triggerDistance = distToEnemyStation/2
							tap.originX = esx
							tap.originY = esy
							table.insert(artPlatformList,tap)
							enemyStation.defenseDeployed = true
							plotWP = artifactToPlatform
						elseif enemyStation.defenseType == "droneFleet" then
							esx, esy = enemyStation:getPosition()
							local ef, efp = spawnDroneFleet(esx, esy, difficulty*6, "Kraylor")
							for j, enemy in ipairs(ef) do
								enemy:orderDefendLocation(esx, esy)
							end
							table.insert(enemyFleetList,ef)
							enemyStation.defenseDeployed = true
						end
					end
				end
			end
		end
	end
end
function artifactToPlatform(delta)
	for i=1,#artPlatformList do
		local tap = artPlatformList[i]
		local apx, apy = tap:getPosition()
		if distance_diagnostic then print("distance_diagnostic 15",apx, apy, tap.originX, tap.originY) end
		if distance(apx, apy, tap.originX, tap.originY) > tap.triggerDistance then
			if enemyDefensePlatformList == nil then
				enemyDefensePlatformList = {}
			end
			twp = CpuShip():setTemplate("Defense platform"):setFaction("Kraylor"):setPosition(apx,apy):orderRoaming()
			twp:setCallSign(generateCallSign(nil,"Kraylor"))
			twp.distance = tap.triggerDistance
			twp.originX = tap.originX
			twp.originY = tap.originY
			twp.travelAngle = tap.travelAngle
			table.insert(enemyDefensePlatformList,twp)
			plotWPO = weaponPlatformOrbit
			table.remove(artPlatformList,i)
			tap:destroy()
			break
		else
			local tDeltax, tDeltay = vectorFromAngle(tap.travelAngle,4*difficulty)
			tap:setPosition(apx+tDeltax,apy+tDeltay)
		end
	end
end
function weaponPlatformOrbit(delta)
	for i=1,#enemyDefensePlatformList do
		twp = enemyDefensePlatformList[i]
		if twp ~= nil and twp:isValid() then
			twp.travelAngle = twp.travelAngle + .05*difficulty
			if twp.travelAngle >= 360 then 
				twp.travelAngle = 0
			end
			local newx, newy = vectorFromAngle(twp.travelAngle,twp.distance)
			twp:setPosition(twp.originX+newx, twp.originY+newy)
		end
	end
end
function warpJammerOrbit(delta)
	for i=1,#jammerList do
		tj = jammerList[i]
		if tj ~= nil and tj:isValid() then
			if tj.orbit then
				tj.travelAngle = tj.travelAngle + .05*difficulty
--				if tj.travelAngle >= 360 then
--					tj.travelAngle = 0
--				end
				newx, newy = vectorFromAngle(tj.travelAngle,tj.triggerDistance)
				tj:setPosition(tj.originX+newx,tj.originY+newy)
			else
				local wjx, wjy = tj:getPosition()
				if distance_diagnostic then print("distance_diagnostic 16",wjx, wjy, tj.originX, tj.originY) end
				if distance(wjx, wjy, tj.originX, tj.originY) > tj.triggerDistance then
					ef, efp = spawnJammerFleet(esx, esy)
					for i, enemy in ipairs(ef) do
						enemy:orderDefendLocation(tj.originX,tj.originY)
					end
					table.insert(enemyFleetList,ef)
					tj.orbit = true
				else
					local tDeltax, tDeltay = vectorFromAngle(tj.travelAngle,4*difficulty)
					tj:setPosition(wjx+tDeltax,wjy+tDeltay)
				end
			end
		end
	end
end
function artifactToMinefield(delta)
	for i=1,#artMineList do
		local tam = artMineList[i]
		local amx, amy = tam:getPosition()
		if distance_diagnostic then print("distance_diagnostic 17",amx, amy, tam.originX, tam.originY) end
		if distance(amx, amy, tam.originX, tam.originY) > tam.triggerDistance then
			if tam.mineCount == nil then
				tam.mineCount = 0
			end
			if tam.mineCount < 150 then
				wang = tam.travelAngle + 360
				if tam.mineCount == 0 then
					mdx, mdy = vectorFromAngle(wang,tam.triggerDistance)
					Mine():setPosition(tam.originX+mdx,tam.originY+mdy)
				else
					mdx, mdy = vectorFromAngle(wang+tam.mineCount,tam.triggerDistance)
					Mine():setPosition(tam.originX+mdx,tam.originY+mdy)
					mdx, mdy = vectorFromAngle(wang-tam.mineCount,tam.triggerDistance)
					Mine():setPosition(tam.originX+mdx,tam.originY+mdy)
				end
				tam.mineCount = tam.mineCount + 1
			else
				tam.deleteMe = true
			end
		else
			local tDeltax, tDeltay = vectorFromAngle(tam.travelAngle,4*difficulty)
			tam:setPosition(amx+tDeltax,amy+tDeltay)
		end
	end
	for i=1,#artMineList do
		tam = artMineList[i]
		if tam.deleteMe then
			table.remove(artMineList,i)
			tam:destroy()
		end
	end
end
function explosiveTransportCheck(delta,p)
	for i=1,#deadlyTransportList do
		local tdt = deadlyTransportList[i]
		local tpx, tpy = p:getPosition()
		local dtx, dty = tdt:getPosition()
		if distance_diagnostic then print("distance_diagnostic 18",tpx, tpy, dtx, dty) end
		if distance(tpx, tpy, dtx, dty) < 750 then
			local tafx = Artifact():setPosition(dtx,dty)
			tafx:explode()
			p:setSystemHealth("beamweapons",-.5)
			p:setSystemHealth("missilesystem",-.5)
			tdt.deleteMe = true
			break
		end
	end
	for i=1,#deadlyTransportList do
		tdt = deadlyTransportList[i]
		if tdt.deleteMe then
			table.remove(deadlyTransportList,i)
			tdt:destroy()
			break
		end
	end
end
function artifactToWorm(delta)
	for i=1,#artWormList do
		local taw = artWormList[i]
		local awx, awy = taw:getPosition()
		if distance_diagnostic then print("distance_diagnostic 19",taw,taw.originX,taw.originY) end
		if distance(taw,taw.originX,taw.originY) > taw.triggerDistance then
			taw.deleteMe = true
			local wdx, wdy = vectorFromAngle(random(0,360),100000)
			WormHole():setPosition(awx,awy):setTargetPosition(awx+wdx,awy+wdy)
		else
			local tDeltax, tDeltay = vectorFromAngle(taw.travelAngle,4*difficulty)
			taw:setPosition(awx+tDeltax,awy+tDeltay)
		end	
	end
	for i=1,#artWormList do
		taw = artWormList[i]
		if taw.deleteMe then
			table.remove(artWormList,i)
			taw:explode()
			break
		end
	end
end
function enemyDefenseZoneCheck(delta,p)
	for i=1,#defensiveZoneList do
		tz = defensiveZoneList[i]
		if tz:isInside(p) then
			local systemHit = math.random(1,3)
			p:setSystemHealth(tz.system[systemHit], p:getSystemHealth(tz.system[systemHit])*adverseEffect)
		end
		if tz.revealDelay < 0 then
			if tz.color == nil then
				tz:setColor(0,255,0)
				tz.color = true
			end
		else
			tz.revealDelay = tz.revealDelay - delta
		end
	end
end
function spawnDroneFleet(originX, originY, droneCount, faction)
	if faction == nil then
		faction = "Kraylor"
	end
	local fleetList = {}
	local deploySpacing = random(300,800)
	local shape = "hexagonal"
	if random(1,100) < 50 then
		shape = "square"
	end
	for i=1,droneCount do
		ship = CpuShip():setFaction(faction):setTemplate("Ktlitan Drone"):orderRoaming():setCommsScript(""):setCommsFunction(commsShip)
		ship:setCallSign(generateCallSign(nil,faction))
		if faction == "Kraylor" then
			rawKraylorShipStrength = rawKraylorShipStrength + 4
			ship:onDestroyed(enemyVesselDestroyed)
		elseif faction == "Human Navy" then
			rawHumanShipStrength = rawHumanShipStrength + 4
			ship:onDestroyed(friendlyVesselDestroyed)
		end
		ship:setPosition(originX + formation_delta[shape].x[i] * deploySpacing, originY + formation_delta[shape].y[i] * deploySpacing)
		table.insert(fleetList,ship)
	end
	return fleetList, droneCount*4
end
function spawnFighterFleet(originX, originY, fighterCount, faction)
	if faction == nil then
		faction = "Kraylor"
	end
	--Ship Template Name List
	local fighterNames  = {"MT52 Hornet","MU52 Hornet","WX-Lindworm","Fighter","Ktlitan Fighter"}
	--Ship Template Score List
	local fighterScores = {5            ,5            ,7            ,6        ,6}
	local fleetList = {}
	local fleetPower = 0
	local deploySpacing = random(300,800)
	local shape = "hexagonal"
	if random(1,100) < 50 then
		shape = "square"
	end
	for i=1,fighterCount do
		local shipTemplateType = math.random(1,#fighterNames)
		fleetPower = fleetPower + fighterScores[shipTemplateType]
		ship = CpuShip():setFaction(faction):setTemplate(fighterNames[shipTemplateType]):orderRoaming():setCommsScript(""):setCommsFunction(commsShip)
		ship:setCallSign(generateCallSign(nil,faction))
		if faction == "Kraylor" then
			rawKraylorShipStrength = rawKraylorShipStrength + fighterScores[shipTemplateType]
			ship:onDestroyed(enemyVesselDestroyed)
		elseif faction == "Human Navy" then
			rawHumanShipStrength = rawHumanShipStrength + fighterScores[shipTemplateType]
			ship:onDestroyed(friendlyVesselDestroyed)
		end
		ship:setPosition(originX + formation_delta[shape].x[i] * deploySpacing, originY + formation_delta[shape].y[i] * deploySpacing)
		table.insert(fleetList,ship)
	end
	return fleetList, fleetPower
end
function spawnJammerFleet(originX, originY)
	faction = "Kraylor"
	local shipSpawnCount = 3
	if difficulty < 1 then
		shipSpawnCount = 2
	elseif difficulty > 1 then
		shipSpawnCount = 4
	end
	--Ship Template Name List
	local jammerNames  = {"MT52 Hornet","MU52 Hornet","Adder MK5","Adder MK4","WX-Lindworm","Adder MK6","Phobos T3","Phobos M3","Piranha F8","Piranha F12","Fighter","Ktlitan Fighter","Ktlitan Drone","Ktlitan Scout"}
	--Ship Template Score List
	local jammerScores = {5            ,5            ,7          ,6          ,7            ,8          ,15         ,16         ,15          ,15           ,6        ,6                ,4              ,8              }
	local fleetList = {}
	local fleetPower = 0
	local deploySpacing = random(300,800)
	local shape = "hexagonal"
	if random(1,100) < 50 then
		shape = "square"
	end
	for i=1,shipSpawnCount do
		local shipTemplateType = math.random(1,#jammerNames)
		fleetPower = fleetPower + jammerScores[shipTemplateType]
		ship = CpuShip():setFaction(faction):setTemplate(jammerNames[shipTemplateType]):orderRoaming():setCommsScript(""):setCommsFunction(commsShip)
		ship:setCallSign(generateCallSign(nil,faction))
		rawKraylorShipStrength = rawKraylorShipStrength + jammerScores[shipTemplateType]
		ship:onDestroyed(enemyVesselDestroyed)
		ship:setPosition(originX + formation_delta[shape].x[i] * deploySpacing, originY + formation_delta[shape].y[i] * deploySpacing)
		table.insert(fleetList,ship)
	end
	return fleetList, fleetPower
end
function personalAmbush(delta)
	if playWithTimeLimit then
		if paDiagnostic then
			paTriggerTime = 120
		else
			paTriggerTime = random(700,1000)
		end
		paTriggerTime = gameTimeLimit - paTriggerTime
		if paDiagnostic then print("using timer as initial trigger: " .. paTriggerTime) end
		plotPA = personalAmbushTimeCheck
	else
		if paDiagnostic then
			paTriggerEval = 98
		else
			midDestruct = (enemyDestructionVictoryCondition + 100)/2
			paTriggerEval = random(midDestruct-4,midDestruct+4)
		end
		if paDiagnostic then print("using eval as initial trigger: " .. paTriggerEval) end
		paDestructInterval = 15
		paDestructTimer = paDestructInterval
		plotPA = personalAmbushDestructCheck
	end
end
function personalAmbushDestructCheck(delta)
	paDestructTimer = paDestructTimer - delta
	if paDestructTimer < 0 then
		if initialAssetsEvaluated then
			if paDiagnostic then print("paDestruct check") end
			local stat_list = gatherStats()
			if stat_list.kraylor.evaluation < paTriggerEval then
				if paDiagnostic then print("met paDestruct criteria") end
				paTriggerTime = gameTimeLimit - random(30,90)
				plotPA = personalAmbushTimeCheck
			end
		end
		paDestructTimer = delta + paDestructInterval		
	end
end
function personalAmbushPlayerCheck(p)
	if plotPA ~= nil and p.sprung == nil and plotPA == personalAmbushTimeCheck then
		p.nebula_candidate = nil
		local nebulaHuntList = p:getObjectsInRange(20000)
		for i, obj in ipairs(nebulaHuntList) do
			if isObjectType(obj,"Nebula") then
				if distance_diagnostic then print("distance_diagnostic 20",p,obj) end
				if distance(p,obj) > 6000 then
					p.nebula_candidate = obj
					break
				end
			end					
		end
		if p.nebula_candidate ~= nil and gameTimeLimit < paTriggerTime then
			local efx, efy = p.nebula_candidate:getPosition()
			local enemyAmbushFleet = spawnEnemies(efx,efy,1,"Kraylor")
			for i, enemy in ipairs(enemyAmbushFleet) do
				enemy:orderAttack(p)
			end
			table.insert(enemyFleetList,enemyAmbushFleet)
			p.sprung = true
		end
	end
end
function personalAmbushTimeCheck(delta)
	if gameTimeLimit < paTriggerTime then
		if paDiagnostic then print("paGame Time check passed") end
		if random(1,100) < 3 then
			paTriggerTime = gameTimeLimit - random(30,90)
		end
		local all_sprung = true
		for pidx=1,32 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if not p.sprung then
					all_sprung = false
					break
				end
			end
		end
		if all_sprung then
			plotPA = nil
		end
	end
end
-- Plot PB player border zone checks
function playerBorderCheck(delta)
	if treaty then
		tbz = nil
		for pidx=1,32 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				playerOutOfBounds = false
				tbz = outerZone
				if tbz:isInside(p) then
					playerOutOfBounds = true
					break
				end
				for i=1,#borderZone do
					tbz = borderZone[i]
					if tbz:isInside(p) then
						playerOutOfBounds = true
						break
					end
				end
				if playerOutOfBounds then
					break
				end
			end
		end
		if tbz ~= nil then
			if playerOutOfBounds then
				if tbz.playerDetected == nil then
					tbz.playerDetected = 1
				else
					if tbz.playerDetected >= 10 then
						missionVictory = false
						finalTimer = 2
						plotPB = displayDefeatResults
					else
						tbz.playerDetected = tbz.playerDetected + 1
					end
				end
			else
				if tbz.playerDetected == nil then
					tbz.playerDetected = 0
				else
					if tbz.playerDetected <= 0 then
						tbz.playerDetected = 0
					else
						tbz.playerDetected = tbz.playerDetected - 1
					end
				end
			end
		end
	end
end
function displayDefeatResults(delta)
	finalTimer = finalTimer - delta
	if finalTimer < 0 then
		missionCompleteReason = "Player violated treaty terms by crossing neutral border zone"
		endStatistics()
		game_state = "victory-kraylor"
		victory("Kraylor")
	end
end
function playerWarCrimeCheck(delta)
	if not treaty and not targetKraylorStations and initialAssetsEvaluated then
		local stat_list = gatherStats()
		if stat_list.kraylor.station.percentage < 100 then
			missionVictory = false
			missionCompleteReason = "Player committed war crimes by destroying civilians aboard Kraylor station"
			endStatistics()
			game_state = "victory_kraylor"
			victory("Kraylor")
		end
	end
end
-- Plot EB enemy border zone checks
function enemyBorderCheck(delta)
	local tempEnemy
	enemyBorderCheckTimer = enemyBorderCheckTimer - delta
	if enemyBorderCheckTimer < 0 then
		enemyBorderCheckTimer = delta + enemyBorderCheckInterval
		for i=1,13 do
			local tbz = borderZone[i]
			local enemyDetected = false
			for j=1,#enemyFleetList do
				local tempFleet = enemyFleetList[j]
				for i, tempEnemy in ipairs(tempFleet) do
					if tempEnemy ~= nil and tempEnemy:isValid() then
						if tbz:isInside(tempEnemy) then
							enemyDetected = true
							enemyEverDetected = true
							break
						end
					end
				end
				if enemyDetected then
					break
				end
			end
			if enemyDetected then
				if tbz.detect >= 2 then
					tbz:setColor(255,255,0)
				else
					tbz.detect = tbz.detect + 1
				end
			else
				if tbz.detect <= 0 then
					if treaty then
						tbz:setColor(0,0,255)
					else
						tbz:setColor(255,0,0)
					end
				else
					tbz.detect = tbz.detect - 1
				end
			end
		end
	end
end
-- Plot ER enemy reinforcements
function tableSelectRandom(array)
	local array_item_count = #array
    if array_item_count == 0 then
        return nil
    end
	return array[math.random(1,#array)]	
end
function enemyReinforcements(delta)
	if #enemyReinforcementSchedule > 0 then
		if enemyReinforcementTimer == nil then
			enemyReinforcementTimer = delta + enemyReinforcementSchedule[1][1]*60 + ersAdj*60 + random(1,100)
		else
			enemyReinforcementTimer = enemyReinforcementTimer - delta
			if enemyReinforcementTimer < 0 then
				if kraylorCentroidX ~= nil then
					local ta = VisualAsteroid():setPosition(kraylorCentroidX,kraylorCentroidY)
					local p = closestPlayerTo(ta)
					ta:destroy()
				end
				if p == nil then
					p = tableSelectRandom(getActivePlayerShips())
				end
				if p ~= nil then
					local dirx, diry = vectorFromAngle(random(0,360),random(15000,25000))
					local fpx, fpy = p:getPosition()
					local tempFleet = spawnEnemies(fpx+dirx,fpy+diry,enemyReinforcementSchedule[1][2],"Kraylor")
					for i, enemy in ipairs(tempFleet) do
						enemy:orderAttack(p)
					end
					table.insert(enemyFleetList,tempFleet)
					table.remove(enemyReinforcementSchedule,1)
				end
				enemyReinforcementTimer = nil
			end
		end
	end
end
-- Plot MF muck and flies
function muckAndFlies(delta)
	if muckFlyCounter == nil then
		local upper_counter = difficulty*2 + 2
		muckFlyCounter = math.random(1,upper_counter)
	end
	if muckFlyTimer == nil then
--		muckFlyTimer = 10
		muckFlyTimer = delta + 400 - difficulty * 90 + random(1,200)	--final: 400, 90 and 200
	end
	muckFlyTimer = muckFlyTimer - delta
	if mf_diagnostic then print("In muck and flies. Counter:",muckFlyCounter,"Timer:",muckFlyTimer) end
	if muckFlyTimer < 0 then
		if mf_diagnostic then print("muck fly timer < 0") end
		if treaty and treatyTimer > 0 then
			muckFlyTimer = delta + 800 - difficulty * 90 + random(1,200)	--final: 800, 90 and 200
			return
		end
		local victimList = {}
		for pidx=1,32 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				table.insert(victimList,p)
			end
		end
		if #victimList > 0 then
			if mf_diagnostic then print("victim list populated") end
			local p = victimList[math.random(1,#victimList)]
			local px, py = p:getPosition()
			local jamAngle = random(0,360)
			local jamDistance = random(6000,9000)
			local jx, jy = vectorFromAngle(jamAngle,jamDistance)
			muck = WarpJammer():setRange(jamDistance*1.7):setPosition(px+jx,py+jy):setFaction("Kraylor"):onDestroyed(armoredWarpJammer)
			muck.jamRange = jamDistance*1.7
			if difficulty < 1 then
				muck.lifeCount = 0
			elseif difficulty > 1 then
				muck.lifeCount = 2
			else
				muck.lifeCount = 1
			end
			local flies = {}
			local flyCount = 2 * difficulty + math.random(1,3)
			for i=1,flyCount do
				local ship = CpuShip():setFaction("Kraylor"):setTemplate("Ktlitan Drone"):setPosition(px+jx,py+jy):orderDefendLocation(px+jx,py+jy):onDestroyed(enemyVesselDestroyed):setCommsScript(""):setCommsFunction(commsShip)
				ship:setCallSign(string.format("F%s%i%i",string.char(math.random(65,90)),muckFlyCounter,i))
				table.insert(flies,ship)
				rawKraylorShipStrength = rawKraylorShipStrength + 4
			end
			table.insert(enemyFleetList,flies)
			local stx, sty = vectorFromAngle(jamAngle,jamDistance * .8)
			local playerShipScore = 24
			if p.shipScore ~= nil then
				playerShipScore = p.ShipScore
			end
			local stench = spawnEnemies(px+stx,py+sty,1,"Kraylor",playerShipScore)
			for i, enemy in ipairs(stench) do
				enemy:orderAttack(p):setCallSign(string.format("MS%s%i%i",string.char(math.random(65,90)),i,muckFlyCounter))
			end
			table.insert(enemyFleetList,stench)
			if difficulty >= 1 then
				local attemptCount = 0
				local validCandidate = false
				local candidate = nil
				repeat 
					candidate = humanStationList[math.random(1,#humanStationList)]
					attemptCount = attemptCount + 1
					if candidate ~= nil then
						if candidate:isValid() then
							if distance_diagnostic then print("distance_diagnostic 22",candidate,px+jx,py+jy) end
							if distance(candidate,px+jx,py+jy) > (jamDistance*3 + 10000) then
								validCandidate = true
							end
						end
					end
				until(validCandidate or attemptCount > repeatExitBoundary)
				if validCandidate then
					local dix, diy = candidate:getPosition()
					if dix ~= nil then
						local tempFleet = spawnEnemies(dix+500,diy+500,1,"Kraylor")
						for i, enemy in ipairs(tempFleet) do
							enemy:setCallSign(string.format("D%s%i%i",string.char(math.random(65,90)),muckFlyCounter,i))
						end
						table.insert(enemyFleetList,tempFleet)
					end
				end
			end
			if difficulty > 1 then
				attemptCount = 0
				validCandidate = false
				repeat 
					candidate = humanStationList[math.random(1,#humanStationList)]
					attemptCount = attemptCount + 1
					if candidate ~= nil then
						if candidate:isValid() then
							if distance_diagnostic then print("distance_diagnostic 23",candidate,px+jx,py+jy) end
							if distance(candidate,px+jx,py+jy) > (jamDistance*3 + 10000) then
								validCandidate = true
							end
						end
					end
				until(validCandidate or attemptCount > repeatExitBoundary)
				if validCandidate then
					local dix, diy = candidate:getPosition()
					if dix ~= nil then
						local tempFleet = spawnEnemies(dix+500,diy+500,1,"Kraylor")
						for i, enemy in ipairs(tempFleet) do
							enemy:setCallSign(string.format("D%s%i%i",string.char(math.random(65,90)),muckFlyCounter,i))
						end
						table.insert(enemyFleetList,tempFleet)
					end
				end
			end
		end
		muckFlyCounter = muckFlyCounter - 1
		if mf_diagnostic then print("muck fly counter:",muckFlyCounter) end
		if muckFlyCounter <= 0 then
			plotMF = sleeperAgent
			muckFlyTimer = 500 - difficulty * 90 + random(1,60)
		else
			muckFlyTimer = nil
		end
	end
end
function sleeperAgent(delta)
	if mf_diagnostic then print("in sleeper agent function") end
	muckFlyTimer = muckFlyTimer - delta
	if muckFlyTimer < 0 then
		local victim_list = {}
		for pidx=1,32 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				table.insert(victim_list,p)
			end
		end
		if #victim_list > 0 then
			local victim = victim_list[math.random(1,#victim_list)]
			local victim_x, victim_y = victim:getPosition()
			local nearby_objects = getObjectsInRadius(victim_x,victim_y,5000)
			local friendly_station = nil
			local sleeper_freighter = {}
			local object_type = nil
			for i, obj in pairs(nearby_objects) do
				if victim ~= obj then
					if isObjectType(obj,"SpaceStation") then
						if victim:isDocked(obj) then
							if obj:getFaction() == "Human Navy" then
								friendly_station = obj
							end
						end
					end
					if isObjectType(obj,"CpuShip") then
						local ship_type = obj:getTypeName()
						if ship_type:find("Freighter") ~= nil then
							if obj:getFaction() == "Independent" or obj:getFaction() == "Human Navy" then
								table.insert(sleeper_freighter,obj)
							end
						end
					end
				end
			end
			if friendly_station ~= nil and #sleeper_freighter > 0 then
				sleeper_agent = {}
				if difficulty < 1 then
					table.insert(sleeper_agent,sleeper_freighter[math.random(1,#sleeper_freighter)])
				elseif difficulty > 1 then
					sleeper_agent = sleeper_freighter
				else
					repeat
						local freighter_choice = math.random(1,#sleeper_freighter)
						table.insert(sleeper_agent,sleeper_freighter[freighter_choice])
						table.remove(sleeper_freighter,freighter_choice)
					until(#sleeper_agent == 3 or #sleeper_freighter < 1)
				end
				for i=1,#sleeper_agent do
					local ship = sleeper_agent[i]
					ship:orderAttack(victim)
					ship:setBeamWeapon(0,270,0,1000,5.0,2.0)
					ship:setWeaponTubeCount(1)
					if difficulty > 1 then
						if random(1,100) < 50 then
							ship:setWeaponStorageMax("Nuke",1)
							ship:setWeaponStorage("Nuke",1)
						else
							ship:setWeaponStorageMax("EMP",1)
							ship:setWeaponStorage("EMP",1)
						end
						ship:setWeaponTubeCount(2)
					end
					if difficulty == 1 then
						ship:setWeaponStorageMax("Homing",2)
						ship:setWeaponStorage("Homing",2)
					end
					ship:setWeaponStorageMax("HVLI",4)
					ship:setWeaponStorage("HVLI",4)
				end
				muckFlyTimer = 15
				plotMF = sleeperAwakes
			end
		end
	end
end
function sleeperAwakes(delta)
	if mf_diagnostic then print("in sleeper awakes function") end
	muckFlyTimer = muckFlyTimer - delta
	if muckFlyTimer < 0 then
		for i=1,#sleeper_agent do
			local ship = sleeper_agent[i]
			if ship ~= nil then
				ship:setFaction("Kraylor")
			end
		end
		plotMF = bedtime
	end
end
function bedtime(delta)
	local sleeper_count = 0
	for i=1,#sleeper_agent do
		if sleeper_agent[i] ~= nil and sleeper_agent[i]:isValid() then
			sleeper_count = sleeper_count + 1
		end
	end
	if sleeper_count == 0 then
		muckFlyTimer = 500 - difficulty * 90 + random(1,60)
		plotMF = sleeperAgent
	end
end
function armoredWarpJammer(self, instigator)
	if self.lifeCount < 1 then
		return
	end
	local tempx, tempy = self:getPosition()
	local redoMuck = WarpJammer():setRange(self.jamRange):setPosition(tempx,tempy):setFaction("Kraylor"):onDestroyed(armoredWarpJammer)
	redoMuck.jamRange = self.jamRange
	redoMuck.lifeCount = self.lifeCount - 1
	if instigator ~= nil then
		if difficulty < 1 then
			instigator:setHull(instigator:getHull()*.9)
		elseif difficulty > 1 then
			instigator:setHull(instigator:getHull()*.7)
		else
			instigator:setHull(instigator:getHull()*.8)
		end
	end
end
-- Plot mining
function checkForMining(delta, p)
	if p.mining and p.cargo > 0 then
		local vx, vy = p:getVelocity()
		local player_velocity = math.abs(vx) + math.abs(vy)
		local cpx, cpy = p:getPosition()
		local nearby_objects = p:getObjectsInRange(1000)
		if player_velocity < 10 then
			if p.mining_target_lock then
				if p.mining_target ~= nil and p.mining_target:isValid() then
					if p.mining_in_progress then
						p.mining_timer = p.mining_timer - delta
						if p.mining_timer < 0 then
							p.mining_in_progress = false
							if p.mining_timer_info ~= nil then
								p:removeCustom(p.mining_timer_info)
								p.mining_timer_info = nil
							end
							p.mining_target_lock = false
							p.mining_timer = nil
							if #p.mining_target.trace_minerals > 0 then
								local good = p.mining_target.trace_minerals[math.random(1,#p.mining_target.trace_minerals)]
								if p.goods == nil then
									p.goods = {}
								end
								if p.goods[good] == nil then
									p.goods[good] = 0
								end
								p.goods[good] = p.goods[good] + 1
								p.cargo = p.cargo - 1
								if p:hasPlayerAtPosition("Science") then
									local mined_mineral_message = "mined_mineral_message"
									p:addCustomMessage("Science",mined_mineral_message,string.format(_("mining-msgScience", "Mining obtained %s which has been stored in the cargo hold"),good))
								end
							else	--no minerals in asteroid
								if p:hasPlayerAtPosition("Science") then
									local mined_mineral_message = "mined_mineral_message"
									p:addCustomMessage("Science",mined_mineral_message,_("mining-msgScience", "mining failed to extract any minerals"))
								end										
							end
						else	--still mining, update timer display, energy and heat
							p:setEnergy(p:getEnergy() - p:getMaxEnergy()*mining_drain)
							p:setSystemHeat("beamweapons",p:getSystemHeat("beamweapons") + (.0025 * difficulty))
							local mining_seconds = math.floor(p.mining_timer % 60)
							if random(1,100) < 22 then
								BeamEffect():setSource(p,0,0,0):setTarget(p.mining_target,0,0):setRing(false):setDuration(1):setTexture(mining_beam_string[math.random(1,#mining_beam_string)])
							end
							if p:hasPlayerAtPosition("Weapons") then
								p.mining_timer_info = "mining_timer_info"
								p:addCustomInfo("Weapons",p.mining_timer_info,string.format(_("mining-tabWeapons", "Mining %i"),mining_seconds))
							end
						end
					else	--mining not in progress
						if p.trigger_mine_beam_button == nil then
							if p:hasPlayerAtPosition("Weapons") then
								p.trigger_mine_beam_button = "trigger_mine_beam_button"
								p:addCustomButton("Weapons",p.trigger_mine_beam_button,_("mining-buttonWeapons", "Start Mining"),function()
									p.mining_in_progress = true
									p.mining_timer = delta + 5
									p:removeCustom(p.trigger_mine_beam_button)
									p.trigger_mine_beam_button = nil
								end)
							end
						end
					end
				else	--no mining target or mining target invalid
					p.mining_target_lock = false
					if p.mining_timer_info ~= nil then
						p:removeCustom(p.mining_timer_info)
						p.mining_timer_info = nil
					end
				end
			else	--not locked
				local mining_objects = {}
				if nearby_objects ~= nil and #nearby_objects > 1 then
					for i, obj in ipairs(nearby_objects) do
						if p ~= obj then
							if isObjectType(obj,"Asteroid") then
								table.insert(mining_objects,obj)
							end
						end
					end		--end of nearby object list loop
					if #mining_objects > 0 then
						if p.mining_target ~= nil and p.mining_target:isValid() then
							local target_in_list = false
							for i=1,#mining_objects do
								if mining_objects[i] == p.mining_target then
									target_in_list = true
									break
								end
							end		--end of check for the current target in list loop
							if not target_in_list then
								p.mining_target = mining_objects[1]
								removeMiningButtons(p)
							end
						else
							p.mining_target = mining_objects[1]
						end
						addMiningButtons(p,mining_objects)
					else	--no mining objects
						if p.mining_target ~= nil then
							removeMiningButtons(p)
							p.mining_target = nil
						end
					end
				else	--no nearby objects
					if p.mining_target ~= nil then
						removeMiningButtons(p)
						p.mining_target = nil
					end
				end
			end
		else	--not moving slowly enough to mine
			removeMiningButtons(p)
			if p.mining_timer_info ~= nil then
				p:removeCustom(p.mining_timer_info)
				p.mining_timer_info = nil
			end
			if p.trigger_mine_beam_button then
				p:removeCustom(p.trigger_mine_beam_button)
				p.trigger_mine_beam_button = nil
			end
			p.mining_target_lock = false
			p.mining_in_progress = false
			p.mining_timer = nil
		end
	end			
end
function removeMiningButtons(p)
	if p.mining_next_target_button ~= nil then
		p:removeCustom(p.mining_next_target_button)
		p.mining_next_target_button = nil
	end
	if p.mining_target_button ~= nil then
		p:removeCustom(p.mining_target_button)
		p.mining_target_button = nil
	end
	if p.mining_lock_button ~= nil then
		p:removeCustom(p.mining_lock_button)
		p.mining_lock_button = nil
	end
end
function addMiningButtons(p,mining_objects)
	local cpx, cpy = p:getPosition()
	local tpx, tpy = p.mining_target:getPosition()
	if p.mining_lock_button == nil then
		if p:hasPlayerAtPosition("Science") then
			p.mining_lock_button = "mining_lock_button"
			p:addCustomButton("Science",p.mining_lock_button,_("mining-buttonScience", "Lock for Mining"),function()
				local cpx, cpy = p:getPosition()
				local tpx, tpy = p.mining_target:getPosition()
				if distance_diagnostic then print("distance_diagnostic 24",cpx,cpy,tpx,tpy) end
				local asteroid_distance = distance(cpx,cpy,tpx,tpy)
				if asteroid_distance < 1000 then
					p.mining_target_lock = true
					local mining_locked_message = "mining_locked_message"
					p:addCustomMessage("Science",mining_locked_message,_("mining-msgScience", "Mining target locked\nWeapons may trigger the mining beam"))
				else
					local mining_lock_fail_message = "mining_lock_fail_message"
					p:addCustomMessage("Engineering",mining_lock_fail_message,string.format(_("mining-msgEngineer", "Mining target lock failed\nAsteroid distance is %.4fU\nMaximum range for mining is 1U"),asteroid_distance/1000))
					p:addCustomMessage("Engineering+",mining_lock_fail_message,string.format(_("mining-msgEngineer+", "Mining target lock failed\nAsteroid distance is %.4fU\nMaximum range for mining is 1U"),asteroid_distance/1000))
					p:addCustomMessage("DamageControl",mining_lock_fail_message,string.format(_("mining-msgDamageControl", "Mining target lock failed\nAsteroid distance is %.4fU\nMaximum range for mining is 1U"),asteroid_distance/1000))
					p.mining_target = nil
				end
				removeMiningButtons(p)
			end)
		end
	end
	if p.mining_target_button == nil then
		if p:hasPlayerAtPosition("Science") then
			p.mining_target_button = "mining_target_button"
			p:addCustomButton("Science",p.mining_target_button,_("mining-buttonScience", "Target Asteroid"),function()
				string.format("")	--necessary to have global reference for Serious Proton engine
				tpx, tpy = p.mining_target:getPosition()
				if distance_diagnostic then print("distance_diagnostic 25",cpx, cpy, tpx, tpy) end
				local target_distance = distance(cpx, cpy, tpx, tpy)/1000
				local theta = math.atan(tpy - cpy,tpx - cpx)
				if theta < 0 then
					theta = theta + 6.2831853071795865
				end
				local angle = theta * 57.2957795130823209
				angle = angle + 90
				if angle > 360 then
					angle = angle - 360
				end
				if p.mining_target.trace_minerals == nil then
					p.mining_target.trace_minerals = {}
					for i=1,#mineralGoods do
						if random(1,100) < (26 - (difficulty * 5)) then
							table.insert(p.mining_target.trace_minerals,mineralGoods[i])
						end
					end
				end
				local minerals = ""
				for i=1,#p.mining_target.trace_minerals do
					if minerals == "" then
						minerals = minerals .. p.mining_target.trace_minerals[i]
					else
						minerals = minerals .. ", " .. p.mining_target.trace_minerals[i]
					end
				end
				if minerals == "" then
					minerals = "none"
				end
				local target_description = "target_description"
				p:addCustomMessage("Science",target_description,string.format(_("mining-msgScience", "Distance: %.1fU\nBearing: %.1f\nMineral traces detected: %s"),target_distance,angle,minerals))
			end)
		end
	end
	if #mining_objects > 1 then
		if p.mining_next_target_button == nil then
			if p:hasPlayerAtPosition("Science") then
				p.mining_next_target_button = "mining_next_target_button"
				p:addCustomButton("Science",p.mining_next_target_button,_("mining-buttonScience", "Other mining target"),function()
					local nearby_objects = p:getObjectsInRange(1000)
					local mining_objects = {}
					if nearby_objects ~= nil and #nearby_objects > 1 then
						for i, obj in ipairs(nearby_objects) do
							if p ~= obj then
								if isObjectType(obj,"Asteroid") then
									table.insert(mining_objects,obj)
								end
							end
						end		--end of nearby object list loop
						if #mining_objects > 0 then
							--print(string.format("%i tractorable objects under 1 unit away",#tractor_objects))
							if p.mining_target ~= nil and p.mining_target:isValid() then
								local target_in_list = false
								local matching_index = 0
								for i=1,#mining_objects do
									if mining_objects[i] == p.mining_target then
										target_in_list = true
										matching_index = i
										break
									end
								end		--end of check for the current target in list loop
								if target_in_list then
									if #mining_objects > 1 then
										if #mining_objects > 2 then
											local new_index = matching_index
											repeat
												new_index = math.random(1,#mining_objects)
											until(new_index ~= matching_index)
											p.mining_target = mining_objects[new_index]
										else
											if matching_index == 1 then
												p.mining_target = mining_objects[2]
											else
												p.mining_target = mining_objects[1]
											end
										end
										removeMiningButtons(p)
										addMiningButtons(p,mining_objects)
									end
								else
									p.mining_target = mining_objects[1]
									removeMiningButtons(p)
									addMiningButtons(p,mining_objects)
								end
							else
								p.mining_target = mining_objects[1]
								addMiningButtons(p,mining_objects)
							end
						else	--no nearby tractorable objects
							if p.mining_target ~= nil then
								removeMiningButtons(p)
								p.mining_target = nil
							end
						end
					else	--no nearby objects
						if p.mining_target ~= nil then
							removeMiningButtons(p)
							p.mining_target = nil
						end
					end
				end)
			end
		end
	else
		if p.mining_next_target_button ~= nil then
			p:removeCustom(p.mining_next_target_button)
			p.mining_next_target_button = nil
		end
	end
end
-- Plot end of war checks and functions
function endWar(delta)
	endWarTimer = endWarTimer - delta
	if endWarTimer < 0 then
		endWarTimer = delta + endWarTimerInterval
		local stat_list = gatherStats()
		if stat_list.kraylor.evaluation < enemyDestructionVictoryCondition then
			missionVictory = true
			missionCompleteReason = string.format("Enemy reduced to less than %i%% strength",math.floor(enemyDestructionVictoryCondition))
			endStatistics()
			game_state = "victory-human"
			victory("Human Navy")
		end
		if stat_list.human.evaluation < friendlyDestructionDefeatCondition then
			missionVictory = false
			missionCompleteReason = string.format("Human Navy reduced to less than %i%% strength",math.floor(friendlyDestructionDefeatCondition))
			endStatistics()
			game_state = "victory-kraylor"
			victory("Kraylor")
		end
		if stat_list.kraylor.evaluation - stat_list.human.evaluation > stat_list.times.threshold then
			missionVictory = false
			missionCompleteReason = string.format("Enemy strength exceeded ours by %i percentage points",math.floor(stat_list.times.threshold))
			endStatistics()
			game_state = "victory-kraylor"
			victory("Kraylor")
		end
		if stat_list.human.evaluation - stat_list.kraylor.evaluation > stat_list.times.threshold then
			missionVictory = true
			missionCompleteReason = string.format("Our strength exceeded enemy strength by %i percentage points",math.floor(stat_list.times.threshold))
			endStatistics()
			game_state = "victory-human"
			victory("Human Navy")
		end
	end
end
function setSecondaryOrders()
	secondaryOrders = ""
	local stat_list = gatherStats()
	secondaryOrders = secondaryOrders .. string.format("\n\nFriendly evaluation: %.1f%%. Below %.1f%% = defeat",stat_list.human.evaluation,friendlyDestructionDefeatCondition)
	secondaryOrders = secondaryOrders .. string.format("\nEnemy evaluation: %.1f%%. Below %.1f%% = victory",stat_list.kraylor.evaluation,enemyDestructionVictoryCondition)
	secondaryOrders = secondaryOrders .. string.format("\n\nGet behind by %.1f%% = defeat. Get ahead by %.1f%% = victory",stat_list.times.threshold,stat_list.times.threshold)
end
function stationWarning(delta)
	if station_warning_diagnostic then print("In station warning function") end
	local function warningCheckPriority1(warn_station)
		local warning_message = ""
		for i, obj in ipairs(warn_station:getObjectsInRange(20000)) do
			if obj ~= nil and obj:isValid() and obj:isEnemy(warn_station) and isObjectType(obj,"CpuShip") then
				warning_message = string.format(_("helpfullWarning-shipLog", "[%s in %s] We detect one or more enemies nearby"),warn_station:getCallSign(),warn_station:getSectorName())
				if difficulty < 2 then
					warning_message = string.format(_("helpfullWarning-shipLog", "%s. At least one is of type %s"),warning_message,obj:getTypeName())
				end
				return warning_message
			end
		end
		return nil
	end
	local function warningCheckPriority2(warn_station)
		for i=1,warn_station:getShieldCount() do
			if warn_station:getShieldLevel(i-1) < warn_station:getShieldMax(i-1) then
				return string.format("[%s in %s] Our shields have taken damage",warn_station:getCallSign(),warn_station:getSectorName())
			end
		end
		return nil
	end
	local function warningCheckPriority3(warn_station)
		local warning_message = ""
		for i=1,warn_station:getShieldCount() do
			if warn_station:getShieldLevel(i-1) < warn_station:getShieldMax(i-1)*.1 then
				if warn_station:getShieldCount() == 1 then
					warning_message = string.format("[%s in %s] Our shields are nearly gone",warn_station:getCallSign(),warn_station:getSectorName())
				else
					warning_message = string.format("[%s in %s] One or more of our shield arcs are nearly gone",warn_station:getCallSign(),warn_station:getSectorName())
				end
				return warning_message
			end
		end
		return nil
	end
	local function warningCheckPriority4(warn_station)
		if warn_station:getHull() < warn_station:getHullMax() then
			return string.format("[%s in %s] Our hull has been damaged",warn_station:getCallSign(),warn_station:getSectorName())
		end
		return nil
	end
	local function warningCheckPriority5(warn_station)
		if warn_station:getHull() < warn_station:getHullMax()*.1 then
			return string.format("[%s in %s] We are on the brink of destruction",warn_station:getCallSign(),warn_station:getSectorName())
		end
		return nil
	end
	warning_priority = 0
	warning_message = ""
	warning_station = nil
	local check_warning_message = ""
	for i, warn_station in ipairs(humanStationList) do
		if warn_station ~= nil and warn_station:isValid() then
			if station_warning_diagnostic then print("valid station:",warn_station:getCallSign(),"warning priority:",warning_priority,"station warning priority:",warn_station.warn_priority) end
			if warn_station.warning_timer ~= nil then
				warn_station.warning_timer = warn_station.warning_timer - delta
				if warn_station.warning_timer < 0 then
					warn_station.warning_timer = nil
					warn_station.warn_priority = 0
				end
			end
			if warn_station.warn_priority == nil then
				warn_station.warn_priority = 0
			end
			if warning_priority < 1 and warn_station.warn_priority < 1 then
				if station_warning_diagnostic then print("Check 1 (nearby enemies)") end
				check_warning_message = warningCheckPriority1(warn_station)
				if check_warning_message ~= nil then
					warning_message = check_warning_message
					warning_priority = 1
					warning_station = warn_station
				end
			end
			if warning_priority < 2 and warn_station.warn_priority < 2 then
				if station_warning_diagnostic then print("Check 2 (shield damage)") end
				check_warning_message = warningCheckPriority2(warn_station)
				if check_warning_message ~= nil then
					warning_message = check_warning_message
					warning_priority = 2
					warning_station = warn_station
				end
			end
			if warning_priority < 3 and warn_station.warn_priority < 3 then
				if station_warning_diagnostic then print("Check 3 (significant shield damage)") end
				check_warning_message = warningCheckPriority3(warn_station)
				if check_warning_message ~= nil then
					warning_message = check_warning_message
					warning_priority = 3
					warning_station = warn_station
				end
			end
			if warning_priority < 4 and warn_station.warn_priority < 4 then
				if station_warning_diagnostic then print("Check 4 (hull damage)") end
				check_warning_message = warningCheckPriority4(warn_station)
				if check_warning_message ~= nil then
					warning_message = check_warning_message
					warning_priority = 4
					warning_station = warn_station
				end
			end
			if warning_priority < 5 and warn_station.warn_priority < 5 then
				if station_warning_diagnostic then print("Check 5 (significant hull damage)") end
				check_warning_message = warningCheckPriority5(warn_station)
				if check_warning_message ~= nil then
					warning_message = check_warning_message
					warning_priority = 5
					warning_station = warn_station
				end
			end
		end		
	end
	if warning_station ~= nil then
		if station_warning_diagnostic then print("determined that some warning is needed") end
		warning_station.warn_priority = warning_priority
		warning_station.warning_timer = delta + 150 + difficulty*100
	end
end
---------------------------
-- Statistical functions --
---------------------------
function detailedStats()
	print("Friendly")
	print("  Stations")
	print("    Survived")
	local friendlySurvivalValue = 0
	for i, station in ipairs(stationList) do
		if station:isValid() then
			if station:isFriendly(getPlayerShip(-1)) then
				print(string.format("      %2d %s",station.strength,station:getCallSign()))
				friendlySurvivalValue = friendlySurvivalValue + station.strength
			end
		end
	end
	print(string.format("     %3d = Total value of friendly stations that survived",friendlySurvivalValue))
	print("    Destroyed")
	local friendlyDestructionValue = 0
	for i=1,#friendlyStationDestroyedNameList do
		print(string.format("      %2d %s",friendlyStationDestroyedValue[i],friendlyStationDestroyedNameList[i]))
		friendlyDestructionValue = friendlyDestructionValue + friendlyStationDestroyedValue[i]
	end
	print(string.format("     %3d = Total value of friendly stations that were destroyed",friendlyDestructionValue))
	print("  Military vessels")
	print("    Survived")
	local friendlyShipSurvivedValue = 0
	for j=1,#friendlyFleetList do
		tempFleet = friendlyFleetList[j]
		for i, tempFriend in ipairs(tempFleet) do
			if tempFriend ~= nil and tempFriend:isValid() then
				local friend_type = tempFriend:getTypeName()
				print(string.format("      %3d %s %s",ship_template[friend_type].strength,tempFriend:getCallSign(),friend_type))
				friendlyShipSurvivedValue = friendlyShipSurvivedValue + ship_template[friend_type].strength
			end
		end
	end
	print(string.format("     %3d = total value of friendly military vessels that survived",friendlyShipSurvivedValue))
	print("    Destroyed")
	local friendlyShipDestroyedValue = 0
	for i=1,#friendlyVesselDestroyedNameList do
		print(string.format("     %3d %s %s",friendlyVesselDestroyedValue[i],friendlyVesselDestroyedNameList[i],friendlyVesselDestroyedType[i]))
		friendlyShipDestroyedValue = friendlyShipDestroyedValue + friendlyVesselDestroyedValue[i]
	end
	print(string.format("     %3d = total value of friendly military vessels that were destoyed",friendlyShipDestroyedValue))
	print("Independent")
	print("  Stations")
	print("    Survived")
	local neutralSurvivalValue = 0
	for i, station in ipairs(stationList) do
		if not station:isFriendly(getPlayerShip(-1)) and not station:isEnemy(getPlayerShip(-1))then
			if station:isValid() then
				print(string.format("      %2d %s",station.strength,station:getCallSign()))
				neutralSurvivalValue = neutralSurvivalValue + station.strength
			end
		end
	end
	print(string.format("     %3d = Total value of neutral stations that survived",neutralSurvivalValue))
	print("    Destroyed")
	local neutralDestroyedValue = 0
	for i=1,#neutralStationDestroyedNameList do
		print(string.format("      %2d %s",neutralStationDestroyedValue[i],neutralStationDestroyedNameList[i]))
		neutralDestroyedValue = neutralDestroyedValue + neutralStationDestroyedValue[i]
	end
	print(string.format("     %3d = Total value of neutral stations that were destoyed",neutralDestroyedValue))
	print("Enemy")
	print("  Stations")
	print("    Survived")
	local enemySurvivalValue = 0
	for i, station in ipairs(stationList) do
		if station:isEnemy(getPlayerShip(-1))then
			if station:isValid() then
				print(string.format("      %2d %s",station.strength,station:getCallSign()))
				enemySurvivalValue = enemySurvivalValue + station.strength
			end
		end
	end
	print(string.format("     %3d = Total value of enemy stations that survived",enemySurvivalValue))
	print("    Destroyed")
	local enemyDestroyedValue = 0
	for i=1,#enemyStationDestroyedNameList do
		print(string.format("      %2d %s",enemyStationDestroyedValue[i],enemyStationDestroyedNameList[i]))
		enemyDestroyedValue = enemyDestroyedValue + enemyStationDestroyedValue[i]
	end
	print(string.format("     %3d = Total value of enemy stations that were destroyed",enemyDestroyedValue))
	print("  Military vessels")
	print("    Survived")
	local enemyShipSurvivedValue = 0
	for j=1,#enemyFleetList do
		tempFleet = enemyFleetList[j]
		for i, tempEnemy in ipairs(tempFleet) do
			if tempEnemy ~= nil and tempEnemy:isValid() then
				local enemy_type = tempEnemy:getTypeName()
				print(string.format("      %3d %s %s",ship_template[enemy_type].strength,tempEnemy:getCallSign(),enemy_type))
				enemyShipSurvivedValue = enemyShipSurvivedValue + ship_template[enemy_type].strength
			end
		end
	end
	print(string.format("     %3d = total value of enemy military vessels that survived",enemyShipSurvivedValue))
	print("    Destroyed")
	local enemyShipDestroyedValue = 0
	for i=1,#enemyVesselDestroyedNameList do
		print(string.format("     %3d %s %s",enemyVesselDestroyedValue[i],enemyVesselDestroyedNameList[i],enemyVesselDestroyedType[i]))
		enemyShipDestroyedValue = enemyShipDestroyedValue + enemyVesselDestroyedValue[i]
	end
	print(string.format("     %3d = total value of enemy military vessels that were destroyed",enemyShipDestroyedValue))
end
function enemyVesselDestroyed(self, instigator)
	tempShipType = self:getTypeName()
	table.insert(enemyVesselDestroyedNameList,self:getCallSign())
	table.insert(enemyVesselDestroyedType,tempShipType)
	table.insert(enemyVesselDestroyedValue,ship_template[tempShipType].strength)
	local exclude_mod_list = {}
	if not self:hasSystem("warp") then
		table.insert(exclude_mod_list,4)
		table.insert(exclude_mod_list,25)
	end
	if not self:hasSystem("jumpdrive") then
		table.insert(exclude_mod_list,5)
		table.insert(exclude_mod_list,26)
	end
	if self:getShieldCount() < 1 then
		table.insert(exclude_mod_list,6)
		table.insert(exclude_mod_list,17)
		table.insert(exclude_mod_list,27)
	end
	if not self:hasSystem("beamweapons") then
		table.insert(exclude_mod_list,1)
		table.insert(exclude_mod_list,21)
		table.insert(exclude_mod_list,22)
	end
	if not self:hasSystem("missilesystem") then
		table.insert(exclude_mod_list,2)
		table.insert(exclude_mod_list,23)
	end
	local wreck_mod_type_index_list = {}
	if #exclude_mod_list > 0 then
		for i=1,#wreck_mod_type do
			local include = true
			for j=1,#exclude_mod_list do
				if i == exclude_mod_list[j] then
					include = false
				end
			end
			if include then
				table.insert(wreck_mod_type_index_list,i)
			end
		end
	else
		for i=1,#wreck_mod_type do
			table.insert(wreck_mod_type_index_list,i)
		end
	end
	local debris_count = math.floor(random(0,ship_template[tempShipType].strength)/6)
	if debris_count > 0 then
		local self_x, self_y = self:getPosition()
		for i=1,debris_count do
			local debris_x, debris_y = vectorFromAngle(random(0,360),random(300,500))
			if instigator ~= nil then
				local instigator_x, instigator_y = instigator:getPosition()
				while(distance(instigator_x, instigator_y, (self_x + debris_x), (self_y + debris_y)) < 400) do
					debris_x, debris_y = vectorFromAngle(random(0,360),random(300,500))
				end
			end
			if random(1,100) > 25 then
				local excluded_mod = false
				local wmt = wreck_mod_type_index_list[math.random(1,#wreck_mod_type_index_list)]
--				local wmt = 32	--for testing
				local wma = wreck_mod_type[wmt].func(self_x, self_y)
				wma.debris_end_x = self_x + debris_x
				wma.debris_end_y = self_y + debris_y
				table.insert(wreck_mod_debris,wma)
			else
				local ra = Asteroid():setPosition(self_x, self_y):setSize(80)
				ra.debris_end_x = self_x + debris_x
				ra.debris_end_y = self_y + debris_y
				table.insert(wreck_mod_debris,ra)
			end
		end
	end
end
function flotsamAction()
	for index, flotsam in ipairs(wreck_mod_debris) do
		if flotsam ~= nil and flotsam:isValid() then
			local cur_x, cur_y = flotsam:getPosition()
			if distance(cur_x, cur_y, flotsam.debris_end_x, flotsam.debris_end_y) < 10 then
				if flotsam:isScannedByFaction("Human Navy") then
					flotsam:setCallSign(string.format("WD%i",wreck_debris_label_count))
					wreck_debris_label_count = wreck_debris_label_count + 1
					if wreck_debris_label_count > 999 then
						wreck_debris_label_count = 1
					end
					table.remove(wreck_mod_debris,index)
					break
				end
			else
				local mid_x = (cur_x + flotsam.debris_end_x)/2
				local mid_y = (cur_y + flotsam.debris_end_y)/2
				local quarter_x = (cur_x + mid_x)/2
				local quarter_y = (cur_y + mid_y)/2
				flotsam:setPosition((cur_x + quarter_x)/2,(cur_y + quarter_y)/2)
			end
		else
			table.remove(wreck_mod_debris,index)
			break
		end
	end
end
function friendlyVesselDestroyed(self, instigator)
	tempShipType = self:getTypeName()
	table.insert(friendlyVesselDestroyedNameList,self:getCallSign())
	table.insert(friendlyVesselDestroyedType,tempShipType)
	table.insert(friendlyVesselDestroyedValue,ship_template[tempShipType].strength)
end
function friendlyStationDestroyed(self, instigator)
	string.format("")
	if self ~= nil then
		table.insert(friendlyStationDestroyedNameList,self:getCallSign())
		table.insert(friendlyStationDestroyedValue,self.strength)
	end
end
function enemyStationDestroyed(self, instigator)
	table.insert(enemyStationDestroyedNameList,self:getCallSign())
	table.insert(enemyStationDestroyedValue,self.strength)
end
function neutralStationDestroyed(self, instigator)
	table.insert(neutralStationDestroyedNameList,self:getCallSign())
	table.insert(neutralStationDestroyedValue,self.strength)
end
function gatherStats()
	local stat_list = {}
	stat_list.scenario = {name = "Borderline Fever", version = scenario_version}
	stat_list.times = {}
	stat_list.times.stage = game_state
	stat_list.times.threshold = destructionDifferenceEndCondition
	if playWithTimeLimit then
		stat_list.times.game = {}
		stat_list.times.game.max = defaultGameTimeLimitInMinutes*60
		stat_list.times.game.total_seconds_left = gameTimeLimit
		stat_list.times.game.minutes_left = math.floor(gameTimeLimit / 60)
		stat_list.times.game.seconds_left = math.floor(gameTimeLimit % 60)
	end
	stat_list.human = {}
	stat_list.human.station = {}
	stat_list.human.station.count = 0
	stat_list.human.station.value = 0
	stat_list.human.station.original_count = 0
	stat_list.human.station.original_value = 0
	stat_list.human.ship = {}
	stat_list.human.ship.value = 0
	stat_list.human.ship.original_value = rawHumanShipStrength
	stat_list.human.weight = {}
	stat_list.human.weight.station = friendlyStationComponentWeight
	stat_list.human.weight.ship = friendlyShipComponentWeight
	stat_list.human.weight.neutral = neutralStationComponentWeight
	stat_list.kraylor = {}
	stat_list.kraylor.station = {}
	stat_list.kraylor.station.count = 0
	stat_list.kraylor.station.value = 0
	stat_list.kraylor.station.original_count = 0
	stat_list.kraylor.station.original_value = 0
	stat_list.kraylor.ship = {}
	stat_list.kraylor.ship.value = 0
	stat_list.kraylor.ship.original_value = rawKraylorShipStrength
	stat_list.kraylor.weight = {}
	stat_list.kraylor.weight.station = enemyStationComponentWeight
	stat_list.kraylor.weight.ship = enemyShipComponentWeight
	stat_list.independent = {}
	stat_list.independent.station = {}
	stat_list.independent.station.count = 0
	stat_list.independent.station.value = 0
	stat_list.independent.station.original_count = 0
	stat_list.independent.station.original_value = 0
	if stationList ~= nil and #stationList > 0 then
		for i, station in ipairs(stationList) do
			if station:isValid() then
				if station:getFaction() == "Human Navy" then
					stat_list.human.station.count = stat_list.human.station.count + 1
					stat_list.human.station.value = stat_list.human.station.value + station.strength
				end
				if station:getFaction() == "Kraylor" then
					stat_list.kraylor.station.count = stat_list.kraylor.station.count + 1
					stat_list.kraylor.station.value = stat_list.kraylor.station.value + station.strength
				end
				if station:getFaction() == "Independent" then
					stat_list.independent.station.count = stat_list.independent.station.count + 1
					stat_list.independent.station.value = stat_list.independent.station.value + station.strength
				end
			end
		end
		if original_human_station_count == nil then
			original_human_station_count = stat_list.human.station.count
		end
		stat_list.human.station.original_count = original_human_station_count
		if original_human_station_value == nil then
			original_human_station_value = stat_list.human.station.value
		end
		stat_list.human.station.original_value = original_human_station_value
		if original_kraylor_station_count == nil then
			original_kraylor_station_count = stat_list.kraylor.station.count
		end
		stat_list.kraylor.station.original_count = original_kraylor_station_count
		if original_kraylor_station_value == nil then
			original_kraylor_station_value = stat_list.kraylor.station.value
		end
		stat_list.kraylor.station.original_value = original_kraylor_station_value
		if original_independent_station_count == nil then
			original_independent_station_count = stat_list.independent.station.count
		end
		stat_list.independent.station.original_count = original_independent_station_count
		if original_independent_station_value == nil then
			original_independent_station_value = stat_list.independent.station.value
		end
		stat_list.independent.station.original_value = original_independent_station_value
	end
	if stat_list.human.station.original_value > 0 then
		stat_list.human.station.percentage = stat_list.human.station.value/stat_list.human.station.original_value*100
	else
		stat_list.human.station.percentage = 100
	end
	if stat_list.kraylor.station.original_value > 0 then
		stat_list.kraylor.station.percentage = stat_list.kraylor.station.value/stat_list.kraylor.station.original_value*100
	else
		stat_list.kraylor.station.percentage = 100
	end
	if stat_list.independent.station.original_value > 0 then
		stat_list.independent.station.percentage = stat_list.independent.station.value/stat_list.independent.station.original_value*100
	else
		stat_list.independent.station.percentage = 100
	end
	if friendlyFleetList ~= nil and #friendlyFleetList > 0 then
		for i, temp_fleet in ipairs(friendlyFleetList) do
			for j, temp_friend in ipairs(temp_fleet) do
				if temp_friend ~= nil and temp_friend:isValid() then
					stat_list.human.ship.value = stat_list.human.ship.value + ship_template[temp_friend:getTypeName()].strength
				end
			end
		end
	end
	if enemyFleetList ~= nil and #enemyFleetList > 0 then
		for i, temp_fleet in ipairs(enemyFleetList) do
			for j, temp_enemy in ipairs(temp_fleet) do
				if temp_enemy ~= nil and temp_enemy:isValid() then
					stat_list.kraylor.ship.value = stat_list.kraylor.ship.value + ship_template[temp_enemy:getTypeName()].strength
				end
			end
		end
	end
	if stat_list.human.ship.original_value > 0 then
		stat_list.human.ship.percentage = stat_list.human.ship.value/stat_list.human.ship.original_value*100
	else
		stat_list.human.ship.percentage = 100
	end
	if stat_list.kraylor.ship.original_value > 0 then
		stat_list.kraylor.ship.percentage = stat_list.kraylor.ship.value/stat_list.kraylor.ship.original_value*100
	else
		stat_list.kraylor.ship.percentage = 100
	end
	stat_list.kraylor.evaluation = stat_list.kraylor.station.percentage * stat_list.kraylor.weight.station + stat_list.kraylor.ship.percentage * stat_list.kraylor.weight.ship
	stat_list.human.evaluation = stat_list.human.station.percentage * stat_list.human.weight.station + stat_list.independent.station.percentage * stat_list.human.weight.neutral + stat_list.human.ship.percentage * stat_list.human.weight.ship
	return stat_list
end
function endStatistics()
--final page for victory or defeat on main streen
	if endStatDiagnostic then print("starting end statistics") end
	local stat_list = gatherStats()
	if endStatDiagnostic then print("got statuses")	end
	local gMsg = ""
	if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
	gMsg = gMsg .. string.format(_("msgMainscreen", "Friendly stations: %i out of %i survived (%.1f%%), strength: %i out of %i (%.1f%%)\n"),stat_list.human.station.count,stat_list.human.station.original_count,stat_list.human.station.count/stat_list.human.station.original_count*100,stat_list.human.station.value,stat_list.human.station.original_value,stat_list.human.station.percentage)
	if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
	gMsg = gMsg .. string.format(_("msgMainscreen", "Enemy stations: %i out of %i survived (%.1f%%), strength: %i out of %i (%.1f%%)\n"),stat_list.kraylor.station.count,stat_list.kraylor.station.original_count,stat_list.kraylor.station.count/stat_list.kraylor.station.original_count*100,stat_list.kraylor.station.value,stat_list.kraylor.station.original_value,stat_list.kraylor.station.percentage)
	if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
	gMsg = gMsg .. string.format(_("msgMainscreen", "Neutral stations: %i out of %i survived (%.1f%%), strength: %i out of %i (%.1f%%)\n"),stat_list.independent.station.count,stat_list.independent.station.original_count,stat_list.independent.station.count/stat_list.independent.station.original_count*100,stat_list.independent.station.value,stat_list.independent.station.original_value,stat_list.independent.station.percentage)
	if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
	--ship information
	gMsg = gMsg .. string.format(_("msgMainscreen", "Friendly ships: strength: %i out of %i (%.1f%%)\n"),stat_list.human.ship.value,stat_list.human.ship.original_value,stat_list.human.ship.percentage)
	if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
	gMsg = gMsg .. string.format(_("msgMainscreen", "Enemy ships: strength: %i out of %i (%.1f%%)\n"),stat_list.kraylor.ship.value,stat_list.kraylor.ship.original_value,stat_list.kraylor.ship.percentage)
	if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
	if endStatDiagnostic then print("set raw stats") end
	local friendlyStationComponent = stat_list.human.station.value/stat_list.human.station.original_value
	local enemyStationComponent = 1-stat_list.kraylor.station.value/stat_list.kraylor.station.original_value
	local neutralStationComponent = stat_list.independent.station.value/stat_list.independent.station.original_value
	local friendlyShipComponent = stat_list.human.ship.value/stat_list.human.ship.original_value
	local enemyShipComponent = 1-stat_list.kraylor.ship.value/stat_list.kraylor.ship.original_value
	gMsg = gMsg .. string.format(_("msgMainscreen", "Friendly evaluation strength: %.1f%%\n"),stat_list.human.evaluation)
	gMsg = gMsg .. string.format(_("msgMainscreen", "   Weights: friendly station: %.2f, neutral station: %.2f, friendly ship: %.2f\n"), stat_list.human.weight.station, stat_list.human.weight.neutral, stat_list.human.weight.ship)
	gMsg = gMsg .. string.format(_("msgMainscreen", "Enemy evaluation strength: %.1f%%\n"),stat_list.kraylor.evaluation)
	gMsg = gMsg .. string.format(_("msgMainscreen", "   Weights: enemy station: %.2f, enemy ship: %.2f\n"), stat_list.kraylor.weight.station, stat_list.kraylor.weight.ship)
	local rankVal = friendlyStationComponent*.4 + friendlyShipComponent*.2 + enemyStationComponent*.2 + enemyShipComponent*.1 + neutralStationComponent*.1 
	if endStatDiagnostic then print("calculated ranking stats") end
	if endStatDiagnostic then print("rank value: " .. rankVal) end
	if missionCompleteReason ~= nil then
		gMsg = gMsg .. _("msgMainscreen", "Mission ended because ") .. missionCompleteReason .. "\n"
		if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
	end
	if endStatDiagnostic then print("built reason for end") end
	if missionVictory then
		if endStatDiagnostic then print("mission victory true") end
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
		gMsg = gMsg .. _("msgMainscreen", "Earned rank: ") .. rank
		if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
	else
		if endStatDiagnostic then print("mission victory false") end
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
		if missionCompleteReason == _("msgMainscreen", "Player violated treaty terms by crossing neutral border zone") then
			gMsg = gMsg .. _("msgMainscreen", "Rank after court martial and imprisonment: ") .. rank
			if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
		elseif missionCompleteReason == _("msgMainscreen", "Player committed war crimes by destroying civilians aboard Kraylor station") then
			gMsg = gMsg .. _("msgMainscreen", "Rank after being stripped of ship responsibilities: ") .. rank
			if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
		else
			gMsg = gMsg .. _("msgMainscreen", "Rank after military reductions due to ignominious defeat: ") .. rank
			if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
		end
	end
	if endStatDiagnostic then print(gMsg) end
	globalMessage(gMsg)
	if endStatDiagnostic then print("seng to the global message function") end
	if printDetailedStats then
		detailedStats()
		if endStatDiagnostic then print("executed detalied stats function") end
	end
end
function updateInner(delta)
	if delta == 0 then
		--game paused
		--set up players with name, goods, cargo space, reputation and either a warp drive or a jump drive if applicable
		local active_player_count = 0
		for pidx=1,32 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				active_player_count = active_player_count + 1
				setPlayer(p)
			end
		end
		if active_player_count ~= banner["number_of_players"] then
			resetBanner()
		end
		return
	end
	local active_player_count = 0
	if updateDiagnostic then print("entering player loop") end
	for pidx=1,32 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if updateDiagnostic then print("Player loop. Valid player. pidx:",pidx,"call sign:",p:getCallSign()) end
			active_player_count = active_player_count + 1
			setPlayer(p)
			playerPlotMessages(p)
			if plotDZ ~= nil then			--defensive zone check
				plotDZ(delta,p)
			end
			if plotExpTrans ~= nil then		--exploding transport
				plotExpTrans(delta,p)
			end
			healthCheck(delta,p)
			if updateDiagnostic then print("completed plotDZ, plotExpTrans & health check") end
			personalAmbushPlayerCheck(p)
			cargoInventory(p)
			autoCoolant(p)
			coolantNebulae(delta,p)
			checkForMining(delta, p)
			expediteDockCheck(delta, p)
			showPlayerInfoOnConsole(delta, p)
			if updateDiagnostic then print("completed cargo inventory, auto coolant, coolant nebulae, check for mining, expedite dock check & show player info on console") end
			local timer_status = ""
			local timer_minutes = 0
			local timer_seconds = 0
			if p.cm_boost_timer ~= nil then
				p.cm_boost_timer = p.cm_boost_timer - delta
				timer_status = _("-tabHelms&Tactical", "C.M. Boost")
				timer_minutes = math.floor(p.cm_boost_timer / 60)
				timer_seconds = math.floor(p.cm_boost_timer % 60)
				if timer_minutes <= 0 then
					timer_status = string.format(_("-tabHelms&Tactical", "%s %i"),timer_status,timer_seconds)
				else
					timer_status = string.format(_("-tabHelms&Tactical", "%s %i:%.2i"),timer_status,timer_minutes,timer_seconds)
				end
				if p:hasPlayerAtPosition("Helms") then
					p.cm_boost_timer_info = "cm_boost_timer_info"
					p:addCustomInfo("Helms",p.cm_boost_timer_info,timer_status)
				end
				if p:hasPlayerAtPosition("Tactical") then
					p.cm_boost_timer_info_tac = "cm_boost_timer_info_tac"
					p:addCustomInfo("Tactical",p.cm_boost_timer_info_tac,timer_status)
				end
				if p.cm_boost_timer < 0 then
					p.cm_boost_active = false
					p:setCombatManeuver(playerShipStats[p:getTypeName()].cm_boost - 200,playerShipStats[p:getTypeName()].cm_strafe)
					p.cm_boost_timer = nil
					if p.activate_cm_boost_button ~= nil then
						p:removeCustom(p.activate_cm_boost_button)
						p.activate_cm_boost_button = nil
					end
					if p.activate_cm_boost_button_tac ~= nil then
						p:removeCustom(p.activate_cm_boost_button_tac)
						p.activate_cm_boost_button_tac = nil
					end
					if p.cm_boost_timer_info ~= nil then
						p:removeCustom(p.cm_boost_timer_info)
						p.cm_boost_timer_info = nil
					end
					if p.cm_boost_timer_info_tac ~= nil then
						p:removeCustom(p.cm_boost_timer_info_tac)
						p.cm_boost_timer_info_tac = nil
					end
					if p.cm_boost_count > 0 then
						wmCombatBoostButton(p,"Helms")
						wmCombatBoostButton(p,"Tactical")
					end
				end
			end
			if p.cm_strafe_timer ~= nil then
				p.cm_strafe_timer = p.cm_strafe_timer - delta
				timer_status = _("-tabHelms&Tactical", "C.M. Boost")
				timer_minutes = math.floor(p.cm_strafe_timer / 60)
				timer_seconds = math.floor(p.cm_strafe_timer % 60)
				if timer_minutes <= 0 then
					timer_status = string.format(_("-tabHelms&Tactical", "%s %i"),timer_status,timer_seconds)
				else
					timer_status = string.format(_("-tabHelms&Tactical", "%s %i:%.2i"),timer_status,timer_minutes,timer_seconds)
				end
				if p:hasPlayerAtPosition("Helms") then
					p.cm_strafe_timer_info = "cm_strafe_timer_info"
					p:addCustomInfo("Helms",p.cm_strafe_timer_info,timer_status)
				end
				if p:hasPlayerAtPosition("Tactical") then
					p.cm_strafe_timer_info_tac = "cm_strafe_timer_info_tac"
					p:addCustomInfo("Tactical",p.cm_strafe_timer_info_tac,timer_status)
				end
				if p.cm_strafe_timer < 0 then
					p.cm_strafe_active = false
					p:setCombatManeuver(playerShipStats[p:getTypeName()].cm_boost,playerShipStats[p:getTypeName()].cm_strafe - 200)
					p.cm_strafe_timer = nil
					if p.activate_cm_strafe_button ~= nil then
						p:removeCustom(p.activate_cm_strafe_button)
						p.activate_cm_strafe_button = nil
					end
					if p.activate_cm_strafe_button_tac ~= nil then
						p:removeCustom(p.activate_cm_strafe_button_tac)
						p.activate_cm_strafe_button_tac = nil
					end
					if p.cm_strafe_timer_info ~= nil then
						p:removeCustom(p.cm_strafe_timer_info)
						p.cm_strafe_timer_info = nil
					end
					if p.cm_strafe_timer_info_tac ~= nil then
						p:removeCustom(p.cm_strafe_timer_info_tac)
						p.cm_strafe_timer_info_tac = nil
					end
					if p.cm_strafe_count > 0 then
						wmCombatStrafeButton(p,"Helms")
						wmCombatStrafeButton(p,"Tactical")
					end
				end
			end
			if p.beam_damage_timer ~= nil then
				p.beam_damage_timer = p.beam_damage_timer - delta
				timer_status = _("-tabWeapons&Tactical", "Beam Damage")
				timer_minutes = math.floor(p.beam_damage_timer / 60)
				timer_seconds = math.floor(p.beam_damage_timer % 60)
				if timer_minutes <= 0 then
					timer_status = string.format(_("-tabWeapons&Tactical", "%s %i"),timer_status,timer_seconds)
				else
					timer_status = string.format(_("-tabWeapons&Tactical", "%s %i:%.2i"),timer_status,timer_minutes,timer_seconds)
				end
				if p:hasPlayerAtPosition("Weapons") then
					p.beam_damage_timer_info = "beam_damage_timer_info"
					p:addCustomInfo("Weapons",p.beam_damage_timer_info,timer_status)
				end
				if p:hasPlayerAtPosition("Tactical") then
					p.beam_damage_timer_info_tac = "beam_damage_timer_info_tac"
					p:addCustomInfo("Tactical",p.beam_damage_timer_info_tac,timer_status)
				end
				if p.beam_damage_timer < 0 then
					p.beam_damage_active = false
					local bi = 0
					repeat
						p:setBeamWeapon(bi,p:getBeamWeaponArc(bi),p:getBeamWeaponDirection(bi),p:getBeamWeaponRange(bi),p:getBeamWeaponCycleTime(bi),p:getBeamWeaponDamage(bi)*random(.9,.95))
						bi = bi + 1
					until(p:getBeamWeaponRange(bi) < 1)
					p.beam_damage_timer = nil
					if p.activate_beam_damage_button ~= nil then
						p:removeCustom(p.activate_beam_damage_button)
						p.activate_beam_damage_button = nil
					end
					if p.activate_beam_damage_button_tac ~= nil then
						p:removeCustom(p.activate_beam_damage_button_tac)
						p.activate_beam_damage_button_tac = nil
					end
					if p.beam_damage_timer_info ~= nil then
						p:removeCustom(p.beam_damage_timer_info)
						p.beam_damage_timer_info = nil
					end
					if p.beam_damage_timer_info_tac ~= nil then
						p:removeCustom(p.beam_damage_timer_info_tac)
						p.beam_damage_timer_info_tac = nil
					end
					if p.beam_damage_count > 0 then
						wmBeamDamageButton(p,"Weapons")
						wmBeamDamageButton(p,"Tactical")
					end
				end
			end
			if p.beam_cycle_timer ~= nil then
				p.beam_cycle_timer = p.beam_cycle_timer - delta
				timer_status = _("-tabWeapons&Tactical", "Beam Cycle")
				timer_minutes = math.floor(p.beam_cycle_timer / 60)
				timer_seconds = math.floor(p.beam_cycle_timer % 60)
				if timer_minutes <= 0 then
					timer_status = string.format(_("-tabWeapons&Tactical", "%s %i"),timer_status,timer_seconds)
				else
					timer_status = string.format(_("-tabWeapons&Tactical", "%s %i:%.2i"),timer_status,timer_minutes,timer_seconds)
				end
				if p:hasPlayerAtPosition("Weapons") then
					p.beam_cycle_timer_info = "beam_cycle_timer_info"
					p:addCustomInfo("Weapons",p.beam_cycle_timer_info,timer_status)
				end
				if p:hasPlayerAtPosition("Tactical") then
					p.beam_cycle_timer_info_tac = "beam_cycle_timer_info_tac"
					p:addCustomInfo("Tactical",p.beam_cycle_timer_info_tac,timer_status)
				end
				if p.beam_cycle_timer < 0 then
					p.beam_cycle_active = false
					local bi = 0
					repeat
						p:setBeamWeapon(bi,p:getBeamWeaponArc(bi),p:getBeamWeaponDirection(bi),p:getBeamWeaponRange(bi),p:getBeamWeaponCycleTime(bi)*random(1.05,1.15),p:getBeamWeaponDamage(bi))
						bi = bi + 1
					until(p:getBeamWeaponRange(bi) < 1)
					p.beam_cycle_timer = nil
					if p.activate_beam_cycle_button ~= nil then
						p:removeCustom(p.activate_beam_cycle_button)
						p.activate_beam_cycle_button = nil
					end
					if p.activate_beam_cycle_button_tac ~= nil then
						p:removeCustom(p.activate_beam_cycle_button_tac)
						p.activate_beam_cycle_button_tac = nil
					end
					if p.beam_cycle_timer_info ~= nil then
						p:removeCustom(p.beam_cycle_timer_info)
						p.beam_cycle_timer_info = nil
					end
					if p.beam_cycle_timer_info_tac ~= nil then
						p:removeCustom(p.beam_cycle_timer_info_tac)
						p.beam_cycle_timer_info_tac = nil
					end
					if p.beam_damage_count > 0 then
						wmBeamCycleButton(p,"Weapons")
						wmBeamCycleButton(p,"Tactical")
					end
				end
			end
			if p.impulse_timer ~= nil then
				p.impulse_timer = p.impulse_timer - delta
				timer_status = _("-tabHelms&Tactical", "Impulse Speed")
				timer_minutes = math.floor(p.impulse_timer / 60)
				timer_seconds = math.floor(p.impulse_timer % 60)
				if timer_minutes <= 0 then
					timer_status = string.format(_("-tabHelms&Tactical", "%s %i"),timer_status,timer_seconds)
				else
					timer_status = string.format(_("-tabHelms&Tactical", "%s %i:%.2i"),timer_status,timer_minutes,timer_seconds)
				end
				if p:hasPlayerAtPosition("Helms") then
					p.impulse_timer_info = "impulse_timer_info"
					p:addCustomInfo("Helms",p.impulse_timer_info,timer_status)
				end
				if p:hasPlayerAtPosition("Tactical") then
					p.impulse_timer_info_tac = "impulse_timer_info_tac"
					p:addCustomInfo("Tactical",p.impulse_timer_info_tac,timer_status)
				end
				if p.impulse_timer < 0 then
					p.impulse_active = false
					p:setImpulseMaxSpeed(p:getImpulseMaxSpeed()*random(.9,.95))
					p.impulse_timer = nil
					if p.activate_impulse_button ~= nil then
						p:removeCustom(p.activate_impulse_button)
						p.activate_impulse_button = nil
					end
					if p.activate_impulse_button_tac ~= nil then
						p:removeCustom(p.activate_impulse_button_tac)
						p.activate_impulse_button_tac = nil
					end
					if p.impulse_timer_info ~= nil then
						p:removeCustom(p.impulse_timer_info)
						p.impulse_timer_info = nil
					end
					if p.impulse_timer_info_tac ~= nil then
						p:removeCustom(p.impulse_timer_info_tac)
						p.impulse_timer_info_tac = nil
					end
					if p.impulse_count > 0 then
						wmImpulseButton(p,"Helms")
						wmImpulseButton(p,"Tactical")
					end
				end
			end
			if p.warp_timer ~= nil then
				p.warp_timer = p.warp_timer - delta
				timer_status = _("-tabHelms&Tactical", "Warp Speed")
				timer_minutes = math.floor(p.warp_timer / 60)
				timer_seconds = math.floor(p.warp_timer % 60)
				if timer_minutes <= 0 then
					timer_status = string.format(_("-tabHelms&Tactical", "%s %i"),timer_status,timer_seconds)
				else
					timer_status = string.format(_("-tabHelms&Tactical", "%s %i:%.2i"),timer_status,timer_minutes,timer_seconds)
				end
				if p:hasPlayerAtPosition("Helms") then
					p.warp_timer_info = "warp_timer_info"
					p:addCustomInfo("Helms",p.warp_timer_info,timer_status)
				end
				if p:hasPlayerAtPosition("Tactical") then
					p.warp_timer_info_tac = "warp_timer_info_tac"
					p:addCustomInfo("Tactical",p.warp_timer_info_tac,timer_status)
				end
				if p.warp_timer < 0 then
					p.warp_active = false
					p:setWarpSpeed(p:getWarpSpeed()*random(.9,.95))
					p.warp_timer = nil
					if p.activate_warp_button ~= nil then
						p:removeCustom(p.activate_warp_button)
						p.activate_warp_button = nil
					end
					if p.activate_warp_button_tac ~= nil then
						p:removeCustom(p.activate_warp_button_tac)
						p.activate_warp_button_tac = nil
					end
					if p.warp_timer_info ~= nil then
						p:removeCustom(p.warp_timer_info)
						p.warp_timer_info = nil
					end
					if p.warp_timer_info_tac ~= nil then
						p:removeCustom(p.warp_timer_info_tac)
						p.warp_timer_info_tac = nil
					end
					if p.impulse_count > 0 then
						wmWarpButton(p,"Helms")
						wmWarpButton(p,"Tactical")
					end
				end
			end
			if p.jump_timer ~= nil then
				p.jump_timer = p.jump_timer - delta
				timer_status = _("-tabHelms&Tactical", "Jump Range")
				timer_minutes = math.floor(p.jump_timer / 60)
				timer_seconds = math.floor(p.jump_timer % 60)
				if timer_minutes <= 0 then
					timer_status = string.format(_("-tabHelms&Tactical", "%s %i"),timer_status,timer_seconds)
				else
					timer_status = string.format(_("-tabHelms&Tactical", "%s %i:%.2i"),timer_status,timer_minutes,timer_seconds)
				end
				if p:hasPlayerAtPosition("Helms") then
					p.jump_timer_info = "jump_timer_info"
					p:addCustomInfo("Helms",p.jump_timer_info,timer_status)
				end
				if p:hasPlayerAtPosition("Tactical") then
					p.jump_timer_info_tac = "jump_timer_info_tac"
					p:addCustomInfo("Tactical",p.jump_timer_info_tac,timer_status)
				end
				if p.jump_timer < 0 then
					p.jump_active = false
					p.max_jump_range = p.max_jump_range*random(.9,.95)
					p:setJumpDriveRange(p.min_jump_range,p.max_jump_range)
					p.jump_timer = nil
					if p.activate_jump_button ~= nil then
						p:removeCustom(p.activate_jump_button)
						p.activate_jump_button = nil
					end
					if p.activate_jump_button_tac ~= nil then
						p:removeCustom(p.activate_jump_button_tac)
						p.activate_jump_button_tac = nil
					end
					if p.jump_timer_info ~= nil then
						p:removeCustom(p.jump_timer_info)
						p.jump_timer_info = nil
					end
					if p.jump_timer_info_tac ~= nil then
						p:removeCustom(p.jump_timer_info_tac)
						p.jump_timer_info_tac = nil
					end
					if p.jump_count > 0 then
						wmJumpButton(p,"Helms")
						wmJumpButton(p,"Tactical")
					end
				end
			end
			if p.shield_timer ~= nil then
				p.shield_timer = p.shield_timer - delta
				timer_status = _("-tabWeapons&Tactical", "Shield Capacity")
				timer_minutes = math.floor(p.shield_timer / 60)
				timer_seconds = math.floor(p.shield_timer % 60)
				if timer_minutes <= 0 then
					timer_status = string.format(_("-tabWeapons&Tactical", "%s %i"),timer_status,timer_seconds)
				else
					timer_status = string.format(_("-tabWeapons&Tactical", "%s %i:%.2i"),timer_status,timer_minutes,timer_seconds)
				end
				if p:hasPlayerAtPosition("Weapons") then
					p.shield_timer_info = "shield_timer_info"
					p:addCustomInfo("Weapons",p.shield_timer_info,timer_status)
				end
				if p:hasPlayerAtPosition("Tactical") then
					p.shield_timer_info_tac = "shield_timer_info_tac"
					p:addCustomInfo("Tactical",p.shield_timer_info_tac,timer_status)
				end
				if p.shield_timer < 0 then
					p.shield_active = false
					local off_rate = random(.9,.95)
					if p:getShieldCount() > 1 then
						p:setShieldsMax(p:getShieldMax(0)*off_rate,p:getShieldMax(1)*off_rate)
					else
						p:setShieldsMax(p:getShieldMax(0)*off_rate)
					end
					p.shield_timer = nil
					if p.activate_shield_button ~= nil then
						p:removeCustom(p.activate_shield_button)
						p.activate_shield_button = nil
					end
					if p.activate_shield_button_tac ~= nil then
						p:removeCustom(p.activate_shield_button_tac)
						p.activate_shield_button_tac = nil
					end
					if p.shield_timer_info ~= nil then
						p:removeCustom(p.shield_timer_info)
						p.shield_timer_info = nil
					end
					if p.shield_timer_info_tac ~= nil then
						p:removeCustom(p.shield_timer_info_tac)
						p.shield_timer_info_tac = nil
					end
					if p.shield_count > 0 then
						wmShieldButton(p,"Weapons")
						wmShieldButton(p,"Tactical")
					end
				end
			end	
			if p.maneuver_timer ~= nil then
				p.maneuver_timer = p.maneuver_timer - delta
				timer_status = _("-tabHelms&Tactical", "Spin Speed")
				timer_minutes = math.floor(p.maneuver_timer / 60)
				timer_seconds = math.floor(p.maneuver_timer % 60)
				if timer_minutes <= 0 then
					timer_status = string.format(_("-tabHelms&Tactical", "%s %i"),timer_status,timer_seconds)
				else
					timer_status = string.format(_("-tabHelms&Tactical", "%s %i:%.2i"),timer_status,timer_minutes,timer_seconds)
				end
				if p:hasPlayerAtPosition("Helms") then
					p.maneuver_timer_info = "maneuver_timer_info"
					p:addCustomInfo("Helms",p.maneuver_timer_info,timer_status)
				end
				if p:hasPlayerAtPosition("Tactical") then
					p.maneuver_timer_info_tac = "maneuver_timer_info_tac"
					p:addCustomInfo("Tactical",p.maneuver_timer_info_tac,timer_status)
				end
				if p.maneuver_timer < 0 then
					p.maneuver_active = false
					p:setRotationMaxSpeed(p:getRotationMaxSpeed()*random(.9,.95))
					p.maneuver_timer = nil
					if p.activate_maneuver_button ~= nil then
						p:removeCustom(p.activate_maneuver_button)
						p.activate_maneuver_button = nil
					end
					if p.activate_maneuver_button_tac ~= nil then
						p:removeCustom(p.activate_maneuver_button_tac)
						p.activate_maneuver_button_tac = nil
					end
					if p.maneuver_timer_info ~= nil then
						p:removeCustom(p.maneuver_timer_info)
						p.maneuver_timer_info = nil
					end
					if p.maneuver_timer_info_tac ~= nil then
						p:removeCustom(p.maneuver_timer_info_tac)
						p.maneuver_timer_info_tac = nil
					end
					if p.maneuver_count > 0 then
						wmManeuverButton(p,"Helms")
						wmManeuverButton(p,"Tactical")
					end
				end
			end
			if p.battery_timer ~= nil then
				p.battery_timer = p.battery_timer - delta
				timer_status = _("-tabEngineer&Engineer+", "Battery Capacity")
				timer_minutes = math.floor(p.battery_timer / 60)
				timer_seconds = math.floor(p.battery_timer % 60)
				if timer_minutes <= 0 then
					timer_status = string.format(_("-tabEngineer&Engineer+", "%s %i"),timer_status,timer_seconds)
				else
					timer_status = string.format(_("-tabEngineer&Engineer+", "%s %i:%.2i"),timer_status,timer_minutes,timer_seconds)
				end
				if p:hasPlayerAtPosition("Engineering") then
					p.battery_timer_info = "battery_timer_info"
					p:addCustomInfo("Engineering",p.battery_timer_info,timer_status)
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p.battery_timer_info_plus = "battery_timer_info_plus"
					p:addCustomInfo("Engineering+",p.battery_timer_info_plus,timer_status)
				end
				if p:hasPlayerAtPosition("DamageControl") then
					p.battery_timer_info_dmg = "battery_timer_info_dmg"
					p:addCustomInfo("DamageControl",p.battery_timer_info_dmg,timer_status)
				end
				if p.battery_timer < 0 then
					p.battery_active = false
					p:setMaxEnergy(p:getMaxEnergy()*random(.9,.95))
					p.battery_timer = nil
					if p.activate_battery_button ~= nil then
						p:removeCustom(p.activate_battery_button)
						p.activate_battery_button = nil
					end
					if p.activate_battery_button_plus ~= nil then
						p:removeCustom(p.activate_battery_button_plus)
						p.activate_battery_button_plus = nil
					end
					if p.battery_timer_info ~= nil then
						p:removeCustom(p.battery_timer_info)
						p.battery_timer_info = nil
					end
					if p.battery_timer_info_plus ~= nil then
						p:removeCustom(p.battery_timer_info_plus)
						p.battery_timer_info_plus = nil
					end
					if p.battery_timer_info_dmg ~= nil then
						p:removeCustom(p.battery_timer_info_dmg)
						p.battery_timer_info_dmg = nil
					end
					if p.battery_count > 0 then
						wmBatteryButton(p,"Engineering")
						wmBatteryButton(p,"Engineering+")
					end
				end
			end			
			if warning_station ~= nil then				
				p:addToShipLog(warning_message,"Red")
			end
			if updateDiagnostic then print("completed timers & warnings") end
		end
	end
	if updateDiagnostic then print("done with player loop") end	
	if #wreck_mod_debris > 0 then
		flotsamAction()
	end
	if active_player_count ~= banner["number_of_players"] then
		resetBanner()
	end
	if updateDiagnostic then print("plot1") end
	if plot1 ~= nil then	--war/peace
		plot1(delta)
	end
	if updateDiagnostic then print("plot2") end
	if plot2 ~= nil then	--timed game
		plot2(delta)
	end
	if updateDiagnostic then print("end war") end
	endWar(delta)
	if updateDiagnostic then print("plotPB") end
	if plotPB ~= nil then	--player border
		plotPB(delta)
	end
	if updateDiagnostic then print("player war crime check") end
	playerWarCrimeCheck(delta)
	if updateDiagnostic then print("enemy defense check") end
	enemyDefenseCheck(delta)
	if updateDiagnostic then print("plotAW") end
	if plotAW ~= nil then	--artifact to worm
		plotAW(delta)
	end
	if updateDiagnostic then print("plotWJ") end
	if plotWJ ~= nil then	--warp jammer
		plotWJ(delta)
	end
	if updateDiagnostic then print("plotAM") end
	if plotAM ~= nil then	--artifact to mine
		plotAM(delta)
	end
	if updateDiagnostic then print("plotWP") end
	if plotWP ~= nil then	--weapons platform
		plotWP(delta)
	end
	if updateDiagnostic then print("plotWPO") end
	if plotWPO ~= nil then	--weapons platform orbit
		plotWPO(delta)
	end
	if updateDiagnostic then print("plot3") end
	if plot3 ~= nil then	--kraylor attacks
		plot3(delta)
	end
	if plotVT ~= nil then
		plotVT(delta)
	end
	if updateDiagnostic then print("friendly transport plot") end
	friendlyTransportPlot(delta)
	if updateDiagnostic then print("independent transport plot") end
	independentTransportPlot(delta)
	if updateDiagnostic then print("Kraylor transport plot") end
	kraylorTransportPlot(delta)
	if updateDiagnostic then print("enemy border check") end
	enemyBorderCheck(delta)
	if updateDiagnostic then print("plotPA") end
	if plotPA ~= nil then	--personal ambush
		plotPA(delta)
	end
	if updateDiagnostic then print("dynamic game master buttons") end
	dynamicGameMasterButtons(delta)
	if updateDiagnostic then print("enemy reinforcements") end
	enemyReinforcements(delta)
	if updateDiagnostic then print("plotMF") end
	if plotMF ~= nil then	--muck and flies
		plotMF(delta)
	end
	if updateDiagnostic then print("spinal ship") end
	spinalShip(delta)
	if updateDiagnostic then print("plotRevert") end
	if plotRevert ~= nil then
		plotRevert(delta)
	end
	if updateDiagnostic then print("plotContinuum") end
	if plotContinuum ~= nil then
		plotContinuum(delta)
	end
	if updateDiagnostic then print("station warning") end
	stationWarning(delta)
	if updateDiagnostic then print("end of update loop") end	
end
function onError(error)
	err = "script error : - \n" .. error .. "\n\ntraceback :-\n" .. traceback()
	print(err)
	if popupGMDebug == "once" or popupGMDebug == "always" then
		if popupGMDebug == "once" then
			popupGMDebug = "never"
		end
		addGMMessage(err)
	end
end
function update(delta)
    xpcall(updateInner,onError,delta)
end
