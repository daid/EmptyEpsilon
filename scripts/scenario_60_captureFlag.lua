-- Name: Capture the Flag (PPEV)
-- Description: Capture opposing team's "flag" before they capture yours
--- 
--- The region consists of two halves divided by a line of nebulae. The first 5 minutes each side decides where to place their flag. The ships closest to the referee station determine the team's flag location during the initial phase. Crossing to the other side during this phase will result in ship destruction. The weapons officer will mark the flag coordinates when the ship reaches the flag location. After the 5 minute timer expires, an artifact will be placed at the location representing the team's flag. If no place has been marked, the ship's current location will be used. If the location is outside the game boundaries, the flag will be placed at the nearest in bound location
---
--- Once the flags are placed, the hunt is on. Ships may cross the border in search of the other team's flag, but while they are in the other team's territory they may be tagged by an opponent ship within 1U. Being tagged sends you back to your own region with damage to your warp/jump drive. Each flag must be scanned before it can be retrived. Retrieval occurs by getting within 1U of the flag. Being tagged while in posession of the flag drops the flag at the location of the tag event. Cross back to your side with the flag to claim victory
---
-- Author: Xansta & Kilted-Klingon
-- Type: Player ship vs. player ship, teams up to 16 ships per side
-- Variation[Easy]: Easy enemies, told which opposing team ship picked up flag
-- Variation[Hard]: Hard enemies, told nothing when opposing team picks up flag
-- Variation[Small]: Smaller region: 50U, told when opposing team picks up flag
-- Variation[Large]: Larger region: 200U, told when opposing team picks up flag
-- Variation[Easy Small]: Easy enemies, smaller region: 50U, told which opposing team ship picked up flag
-- Variation[Easy Large]: Easy enemies, larger region: 200U, told which opposing team ship picked up flag
-- Variation[Hard Small]: Hard enemies, smaller region: 50U, told nothing when opposing team picks up flag
-- Variation[Hard Large]: Hard enemies, larger region: 200U, told nothing when opposing team picks up flag

require("utils.lua")

function init()
	scenario_version = "1.7"
	print(string.format("     -----     Scenario: Capture the Flag     -----     Version %s     -----",scenario_version))
	print(_VERSION)
	
------------------------
--	Global variables  --
------------------------
-- Variables that may be modified before game start to adjust game play
	diagnostic = false 			-- See GM button. A boolean for printing debug data to the console during development; turn to "false" during game play 
	gameTimeLimit = 45*60		-- See GM button. Time limit for game; this is measured in real time seconds (example: 45*60 = 45 minutes)
	hideFlagTime = 300			-- See GM button. Time given to hide flag; this is measured in real time seconds; (300 secs or 5 mins is the normal setting; 60 for certain tests)
	maxGameTime = gameTimeLimit	-- See GM Button.
	-- intial player placement locations; note that these locations are intended to be generally consistent and independent of the environment option chosen
		--player side   		  Hum   Kra    Hum   Kra    Hum    Kra    Hum   Kra    Hum    Kra    Hum   Kra	  Hum	 Kra    Hum    Kra    Hum    Kra    Hum    Kra    Hum    Kra    Hum    Kra    Hum    Kra    Hum    Kra    Hum    Kra    Hum    Kra
		--player index   		   1     2      3     4      5      6      7     8      9     10     11    12	  13	 14     15     16     17     18     19     20     21     22     23     24     25     26     27     28     29     30     31     32
		playerStartX = 			{-1000, 1000, -1000, 1000, -1000,  1000, -2000, 2000, -2000,  2000, -2000, 2000, -3000,  3000, -1000,  1000, -1000,  1000, -2000,  2000, -2000,  2000, -3000,  3000, -3000,  3000, -3000,  3000, -3000,  3000, -4000,  4000}
		playerStartY =			{    0,    0, -1000, 1000,  1000, -1000,     0,    0,  1000, -1000, -1000, 1000,	 0,     0, -2000,  2000,  2000, -2000, -2000,  2000,  2000, -2000, -1000,  1000,  1000, -1000, -2000,  2000,  2000, -2000,     0,     0}
		player_tag_relocate_x = {-1000, 1000, -1000, 1000, -1000,  1000, -2000, 2000, -2000,  2000, -2000, 2000, -3000,	 3000, -1000,  1000, -1000,  1000, -2000,  2000, -2000,  2000, -3000,  3000, -3000,  3000, -3000,  3000, -3000,  3000, -4000,  4000}	--may override in terrain section
		player_tag_relocate_y =	{    0,    0, -1000, 1000,  1000, -1000,     0,    0,  1000, -1000, -1000, 1000,     0,     0, -2000,  2000,  2000, -2000, -2000,  2000,  2000, -2000, -1000,  1000,  1000, -1000, -2000,  2000,  2000, -2000,     0,     0}
		player_start_heading = 	{  270,   90,   270,   90,   270,    90,   270,   90,   270,    90,   270,   90,   270,    90,   270,    90,   270,    90,   270,    90,   270,    90,   270,    90,   270,    90,   270,    90,   270,    90,   270,    90}	--set both heading and rotation to avoid initial rotation upon game start
		player_start_rotation =	{  180,    0,   180,    0,   180,     0,   180,    0,   180,     0,   180,    0,   180,     0,   180,     0,   180,     0,   180,     0,   180,     0,   180,     0,   180,     0,   180,     0,   180,     0,   180,     0}	--rotation points 90 degrees counter-clockwise of heading
	player_wing_names = {
		[2] = {
			"Alpha","Red",
		},
		[4] = {
			"Alpha",	"Red",
			"Bravo",	"Blue",
		},
		[6] = {
			"Alpha",	"Red",
			"Bravo",	"Blue",
			"Charlie",	"Green",
		},
		[8] = {
			"Alpha 1",	"Red 1",
			"Alpha 2",	"Red 2",
			"Bravo 1",	"Blue 1",
			"Bravo 2",	"Blue 2",
		},
		[10] = {
			"Alpha 1",	"Red 1",
			"Alpha 2",	"Red 2",
			"Bravo 1",	"Blue 1",
			"Bravo 2",	"Blue 2",
			"Charlie",	"Green",
		},
		[12] = {
			"Alpha 1",		"Red 1",
			"Alpha 2",		"Red 2",
			"Bravo 1",		"Blue 1",
			"Bravo 2",		"Blue 2",
			"Charlie 1",	"Green 1",
			"Charlie 2",	"Green 2",
		},
		[14] = {
			"Alpha 1",		"Red 1",
			"Alpha 2",		"Red 2",
			"Alpha 3",		"Red 3",
			"Bravo 1",		"Blue 1",
			"Bravo 2",		"Blue 2",
			"Charlie 1",	"Green 1",
			"Charlie 2",	"Green 2",
		},
		[16] = {
			"Alpha 1",		"Red 1",
			"Alpha 2",		"Red 2",
			"Alpha 3",		"Red 3",
			"Bravo 1",		"Blue 1",
			"Bravo 2",		"Blue 2",
			"Bravo 3",		"Blue 3",
			"Charlie 1",	"Green 1",
			"Charlie 2",	"Green 2",
		},
		[18] = {
			"Alpha 1",		"Red 1",
			"Alpha 2",		"Red 2",
			"Alpha 3",		"Red 3",
			"Bravo 1",		"Blue 1",
			"Bravo 2",		"Blue 2",
			"Bravo 3",		"Blue 3",
			"Charlie 1",	"Green 1",
			"Charlie 2",	"Green 2",
			"Charlie 3",	"Green 3",
		},
		[20] = {
			"Alpha 1",		"Red 1",
			"Alpha 2",		"Red 2",
			"Alpha 3",		"Red 3",
			"Bravo 1",		"Blue 1",
			"Bravo 2",		"Blue 2",
			"Bravo 3",		"Blue 3",
			"Charlie 1",	"Green 1",
			"Charlie 2",	"Green 2",
			"Delta 1",		"Yellow 1",
			"Delta 2",		"Yellow 2",
		},
		[22] = {
			"Alpha 1",		"Red 1",
			"Alpha 2",		"Red 2",
			"Alpha 3",		"Red 3",
			"Bravo 1",		"Blue 1",
			"Bravo 2",		"Blue 2",
			"Bravo 3",		"Blue 3",
			"Charlie 1",	"Green 1",
			"Charlie 2",	"Green 2",
			"Charlie 3",	"Green 3",
			"Delta 1",		"Yellow 1",
			"Delta 2",		"Yellow 2",
		},
		[24] = {
			"Alpha 1",		"Red 1",
			"Alpha 2",		"Red 2",
			"Alpha 3",		"Red 3",
			"Bravo 1",		"Blue 1",
			"Bravo 2",		"Blue 2",
			"Bravo 3",		"Blue 3",
			"Charlie 1",	"Green 1",
			"Charlie 2",	"Green 2",
			"Charlie 3",	"Green 3",
			"Delta 1",		"Yellow 1",
			"Delta 2",		"Yellow 2",
			"Delta 3",		"Yellow 3",
		},
		[26] = {
			"Alpha 1",		"Red 1",
			"Alpha 2",		"Red 2",
			"Alpha 3",		"Red 3",
			"Alpha 4",		"Red 4",
			"Bravo 1",		"Blue 1",
			"Bravo 2",		"Blue 2",
			"Bravo 3",		"Blue 3",
			"Charlie 1",	"Green 1",
			"Charlie 2",	"Green 2",
			"Charlie 3",	"Green 3",
			"Delta 1",		"Yellow 1",
			"Delta 2",		"Yellow 2",
			"Delta 3",		"Yellow 3",
		},
		[28] = {
			"Alpha 1",		"Red 1",
			"Alpha 2",		"Red 2",
			"Alpha 3",		"Red 3",
			"Alpha 4",		"Red 4",
			"Bravo 1",		"Blue 1",
			"Bravo 2",		"Blue 2",
			"Bravo 3",		"Blue 3",
			"Bravo 4",		"Blue 4",
			"Charlie 1",	"Green 1",
			"Charlie 2",	"Green 2",
			"Charlie 3",	"Green 3",
			"Delta 1",		"Yellow 1",
			"Delta 2",		"Yellow 2",
			"Delta 3",		"Yellow 3",
		},
		[30] = {
			"Alpha 1",		"Red 1",
			"Alpha 2",		"Red 2",
			"Alpha 3",		"Red 3",
			"Alpha 4",		"Red 4",
			"Bravo 1",		"Blue 1",
			"Bravo 2",		"Blue 2",
			"Bravo 3",		"Blue 3",
			"Bravo 4",		"Blue 4",
			"Charlie 1",	"Green 1",
			"Charlie 2",	"Green 2",
			"Charlie 3",	"Green 3",
			"Charlie 4",	"Green 4",
			"Delta 1",		"Yellow 1",
			"Delta 2",		"Yellow 2",
			"Delta 3",		"Yellow 3",
		},
		[32] = {
			"Alpha 1",		"Red 1",
			"Alpha 2",		"Red 2",
			"Alpha 3",		"Red 3",
			"Alpha 4",		"Red 4",
			"Bravo 1",		"Blue 1",
			"Bravo 2",		"Blue 2",
			"Bravo 3",		"Blue 3",
			"Bravo 4",		"Blue 4",
			"Charlie 1",	"Green 1",
			"Charlie 2",	"Green 2",
			"Charlie 3",	"Green 3",
			"Charlie 4",	"Green 4",
			"Delta 1",		"Yellow 1",
			"Delta 2",		"Yellow 2",
			"Delta 3",		"Yellow 3",
			"Delta 4",		"Yellow 4",
		},
	}
	wingSquadronNames = true	-- See GM button. Set to true to name ships alpha/bravo/charlie vs. red/blue/green etc.; set to false to use randomized names from a list
	tagDamage = 1.25			-- See GM button. Amount to subtract from jump/warp drive when tagged. Full health = 1
	tag_distance = 1000			-- See GM button. How far away to be considered tagged and returned to other side
	hard_flag_reveal = true		-- See GM button. On hard difficulty, will a flag pick up be revealed on main screen or not
	side_destroyed_ends_game = true		-- See GM button. If one side completely destroyed, will game end immediately or not (if not, set game time remaining to 60 seconds)
	autoEnemies = false			-- See GM button. Boolean default value for whether or not marauders spawn
	interWave = 600				-- See GM button. Number of seconds between marauding enemy spawn waves, if that option is chosen
	dynamicTerrain = nil		-- this is a placeholder variable that needs to be set to a function call in the terrain setup function; see below
	-- Choose the environment terrain!  Uncomment the terrain type you wish to use and comment out the other(s).
	-- !! Be sure the setup function sets the value of 'dynamicTerrain' to the function that takes terrain action
		--terrainType = emptyTerrain -- for easy/testing purposes
		--terrainType = defaultTerrain
		--terrainType = justPassingBy
		terrainType = randomSymmetric
		terrain_type_name = "Symmetric"
	terrain_choices = {
		["Empty"] =		emptyTerrain,
		["Default"] =	defaultTerrain,
		["Passing"] =	justPassingBy,
		["Symmetric"] =	randomSymmetric,
	}
	-- Drone related global variables
		dronesAreAllowed = true 				-- See GM button. The base boolean to turn on/off drone usage within the scenarios
		uniform_drone_carrying_capacity = 50	-- See GM button. This is the max number of drones that can be carried by a playership; for the initial implementations, all player ships will have equal capacity
		drone_name_type = "squad-num of size"	-- See GM button. Valid values are "default" (use EE), "squad-num/size" (K), "short" (X preferred), "squad-num of size" (X alternate)
		drone_modified_from_template =  true 	-- See GM button. Boolean governing whether drone properties will be modified from their original template values
		drone_hull_strength = 50	-- See GM button. Original: 30  drones do not have shields and only have their hull strength for defense; reasonable values should be from 25-75; obviously the higher the stronger
		drone_impulse_speed = 120	-- See GM button. Original: 120 drones only have impulse engines, and usually tend to be faster because they are lighter and no living pilots required; reasonable values should be from 100-150
		drone_beam_range = 700 		-- See Gm button. Original: 600 the distance at which the drone can hit its target; reasonable values should be from 500-1000
		drone_beam_damage = 10 		-- See Gm button. Original: 6   drones have a single forward facing beam weapon; this sets the damage done by the beam; reasonable values should be from 5-10
		drone_beam_cycle_time = 5	-- See Gm button. Original: 4   this is the number of seconds it takes for the beam weapon to recharge and to be able to fire again; reasonable values should be from 3-8
		drone_flag_check_interval = 5		-- See GM button. How many seconds between each drone flag detection cycle
		drone_message_reset_count = 8		-- See GM button. How many flag check intervals to wait before sending another message about a possible flag being detected
		drone_formation_spacing = 5000		-- See GM button. How far apart drones travel when in formation (1000 = 1 unit)
		drone_scan_range_for_flags = 7500	-- See GM button. How far away drones can "see" potential flags. Standard sensor range (aka sensor bubble) is 5 units (5000)
	revisedPlayerShipProbeCount = 20  -- See GM button. The standard count of 8 just is not quite enough for this game, so we need to have an easy way to modify; all player ships will have this amount at game start
	control_code_stem = {	--All control codes must use capital letters or they will not work.
		"ALWAYS",
		"BLACK",
		"BLUE",
		"BRIGHT",
		"BROWN",
		"CHAIN",
		"CHURCH",
		"DOORWAY",
		"DULL",
		"ELBOW",
		"EMPTY",
		"EPSILON",
		"FLOWER",
		"FLY",
		"FROZEN",
		"GREEN",
		"GLOW",
		"HAMMER",
		"INK",
		"JUMP",
		"KEY",
		"LETTER",
		"LIST",
		"MORNING",
		"NEXT",
		"OPEN",
		"ORANGE",
		"OUTSIDE",
		"PURPLE",
		"QUARTER",
		"QUIET",
		"RED",
		"SHINE",
		"SIGMA",
		"STAR",
		"STREET",
		"TOKEN",
		"THIRSTY",
		"UNDER",
		"VANISH",
		"WHITE",
		"WRENCH",
		"YELLOW",
	}


-- Variables and structures that *!MUST NOT!* be modified; these are necessary for managing game play
	p1FlagDrop = false
	p2FlagDrop = false
	plotH = healthCheck
	healthCheckTimer = 5
	healthCheckTimerInterval = 5
	plotW = marauderWaves
	waveTimer = interWave
	terrain_objects = {}
	humanStationList = {}
	kraylorStationList = {}
	neutralStationList = {}
	stationList = {}
	human_player_names = {}
	kraylor_player_names = {}
	all_squad_count = 0
	human_flags = {}
	kraylor_flags = {}
	-- 'stationZebra' is placed at position 0,0 and is present for all environment setups
		stationZebra = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation):setPosition(0,0):setCallSign("Zebra"):setDescription("Referee")
		table.insert(stationList,stationZebra)
	-- the following tables are used for enemy marauding ships; the tables help plot arrival points for the marauding ships
		-- square grid deployment
		fleetPosDelta1x = {0,1,0,-1, 0,1,-1, 1,-1,2,0,-2, 0,2,-2, 2,-2,2, 2,-2,-2,1,-1, 1,-1}
		fleetPosDelta1y = {0,0,1, 0,-1,1,-1,-1, 1,0,2, 0,-2,2,-2,-2, 2,1,-1, 1,-1,2, 2,-2,-2}
		-- rough hexagonal deployment
		fleetPosDelta2x = {0,2,-2,1,-1, 1, 1,4,-4,0, 0,2,-2,-2, 2,3,-3, 3,-3,6,-6,1,-1, 1,-1,3,-3, 3,-3,4,-4, 4,-4,5,-5, 5,-5}
		fleetPosDelta2y = {0,0, 0,1, 1,-1,-1,0, 0,2,-2,2,-2, 2,-2,1,-1,-1, 1,0, 0,3, 3,-3,-3,3,-3,-3, 3,2,-2,-2, 2,1,-1,-1, 1}
	missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}  -- am not sure why this has to be set but it was included so keeping it for now
	-- the following are part of Xansta's larger overall bartering/crafting setup
		goods = {}			--overall tracking of goods; 
		tradeFood = {}		--stations that will trade food for other goods; 
		tradeLuxury = {}	--stations that will trade luxury for other goods; 
		tradeMedicine = {}	--stations that will trade medicine for other goods; 
	-- convenience table for accessing drones
		droneFleets = {}


	-- Initialization checklist by function
	setVariations()
	initializeDroneButtonFunctionTables()
	setGMButtons()
	setupTailoredShipAttributes()  -- part of Xansta's larger overall script core for randomized stations and NPC ships 
	setupBarteringGoods() -- part of Xansta's larger overall bartering/crafting setup
	setupPlacementRandomizationFunctions()
	terrainType()  -- sets up the environment terrain according to the choice above

	-- Print initialization items to console
	wfv = "end of init"
	print("  Initial Configuration:")
	print("    Flag hiding time limit:  " .. hideFlagTime/60 .. " minutes")
	print("    Game Time Limit:  " .. gameTimeLimit/60 .. " minutes")
	-- print("    Terrain type: " .. tostring(terrainType))
	print("    Scan probes allocated per ship:  " .. revisedPlayerShipProbeCount)
	print("    Are drones allowed? " .. tostring(dronesAreAllowed))
	print("    (Uniform) Drone carrying capacity for player ships: " .. uniform_drone_carrying_capacity)
	print("    Drone scanning range for flags/decoys:  " .. drone_scan_range_for_flags)
	print("  ")
	print("-----     All of the above settings may be adjusted by GM button. ")
	print("-----     So don't count on these values to remain accurate")

end
------------------
--	GM Buttons  --
------------------
function setGMButtons()
	mainGMButtons = mainGMButtonsDuringPause
	mainGMButtons()
end
function mainGMButtonsDuringPause()
	clearGMFunctions()
	addGMFunction(string.format("Version %s",scenario_version),function()
		local version_message = string.format("Scenario version %s\n LUA version %s",scenario_version,_VERSION)
		addGMMessage(version_message)
		print(version_message)
	end)
	local button_label = "Turn on Diagnostic"
	if diagnostic then
		button_label = "Turn off Diagnostic"
	end
	addGMFunction(button_label,function()
		if diagnostic then
			diagnostic = false
		else
			diagnostic = true
		end
		mainGMButtons()
	end)
	addGMFunction(string.format("+Terrain: %s",terrain_type_name),setTerrain)
	addGMFunction("+Player Config",playerConfig)
	if interwave_delay == nil then
		interwave_delay = "normal"
	end
	button_label = "Enable Auto-Enemies"
	if autoEnemies then
		button_label = "Disable Auto-Enemies"
	end
	addGMFunction(button_label,function()
		if autoEnemies then
			autoEnemies = false
		else
			autoEnemies = true
		end
		mainGMButtons()
	end)
	if autoEnemies then
		addGMFunction(string.format("+Times G%i H%i E%i",gameTimeLimit/60,hideFlagTime/60,interWave/60),setGameTimeLimit)
	else
		addGMFunction(string.format("+Times G%i H%i",gameTimeLimit/60,hideFlagTime/60),setGameTimeLimit)
	end
	if difficulty > 1 then
		button_label = "Show Pick Up Off"
		if hard_flag_reveal then
			button_label = "Show Pick Up On"
		end
		addGMFunction(button_label,function()
			if hard_flag_reveal then
				hard_flag_reveal = false
			else
				hard_flag_reveal = true
			end
			mainGMButtons()
		end)
	end
	button_label = "Destroy = end off"
	if side_destroyed_ends_game then
		button_label = "Destroy = end on"
	end
	addGMFunction(button_label,function()
		if side_destroyed_ends_game then
			side_destroyed_ends_game = false
		else
			side_destroyed_ends_game = true
		end
		mainGMButtons()
	end)
end
function setTerrain()
	clearGMFunctions()
	addGMFunction("-from Terrain",mainGMButtons)
	for name, terrain in pairs(terrain_choices) do
		local button_name = name
		if button_name == terrain_type_name then
			button_name = button_name .. "*"
		end
		addGMFunction(button_name,function()
			if terrain_objects ~= nil and #terrain_objects > 0 then
				for _, obj in pairs(terrain_objects) do
					obj:destroy()
				end
				terrain_objects = {}
			end
			terrain_type_name = name
			terrainType = terrain
			stationList = {}
			humanStationList = {}
			kraylorStationList = {}
			neutralStationList = {}
			setupPlacementRandomizationFunctions()
			terrainType()
			setTerrain()
		end)
	end
end
function playerConfig()
	clearGMFunctions()
	addGMFunction("-from Player Config",mainGMButtons)
	addGMFunction("Show control codes",showControlCodes)
	addGMFunction("Show Kraylor codes",showKraylorCodes)
	addGMFunction("Show Human codes",showHumanCodes)
	local button_label = "Wing Names Off"
	if wingSquadronNames then
		button_label = "Wing Names On"
	end
	addGMFunction(button_label,function()
		if wingSquadronNames then
			local p = getPlayerShip(-1)
			if p ~= nil then
				addGMMessage("Cannot disable wing names now that player ships have been spawned.\nClose the server and restart if you *really* don't want the wing names")
			else
				wingSquadronNames = false
			end
		else
			wingSquadronNames = true
		end
		playerConfig()
	end)
	addGMFunction(string.format("+Tags %.2f, %.1fU",tagDamage,tag_distance/1000),setTagValues)
	button_label = "+Drones Off"
	if dronesAreAllowed then
		button_label = "+Drones On"
	end
	addGMFunction(button_label,configureDrones)
	local p = getPlayerShip(-1)
	if p == nil then
		addGMFunction(string.format("+Probes %i",revisedPlayerShipProbeCount),setPlayerProbes)
	end
end
function setGameTimeLimit()
	clearGMFunctions()
	addGMFunction("-Main from times",mainGMButtons)
	addGMFunction(string.format("Game %i Add 5 -> %i",gameTimeLimit/60,gameTimeLimit/60 + 5),function()
		gameTimeLimit = gameTimeLimit + 300
		maxGameTime = gameTimeLimit
		setGameTimeLimit()
	end)
	if gameTimeLimit > (hideFlagTime + 300) then
		addGMFunction(string.format("Game %i Del 5 -> %i",gameTimeLimit/60,gameTimeLimit/60 - 5),function()
			gameTimeLimit = gameTimeLimit - 300
			maxGameTime = gameTimeLimit
			setGameTimeLimit()
		end)
	end
	if hideFlagTime < (gameTimeLimit - 300) then
		addGMFunction(string.format("Hide Flag %i Add 5 -> %i",hideFlagTime/60,hideFlagTime/60 + 5),function()
			hideFlagTime = hideFlagTime + 300
			setGameTimeLimit()
		end)
	end
	if hideFlagTime > 300 then
		addGMFunction(string.format("Hide Flag %i Del 5 -> %i",hideFlagTime/60,hideFlagTime/60 - 5),function()
			hideFlagTime = hideFlagTime - 300
			setGameTimeLimit()
		end)
	end
	if autoEnemies then
		if interWave < 1200 then
			addGMFunction(string.format("Enemy %i Add 1 -> %i",interWave/60,(interWave + 60)/60),function()
				interWave = interWave + 60
				setGameTimeLimit()
			end)
		end
		if interWave > 120 then
			addGMFunction(string.format("Enemy %i Del 1 -> %i",interWave/60,(interWave - 60)/60),function()
				interWave = interWave - 60
				setGameTimeLimit()
			end)
		end
	end
end
function setTagValues()
	clearGMFunctions()
	addGMFunction("-Main from Tag",mainGMButtons)
	addGMFunction("-Player Config",playerConfig)
	addGMFunction(string.format("+Tag distance %.1fU",tag_distance/1000),setTagDistance)
	addGMFunction(string.format("+Tag damage %.2f",tagDamage),setTagDamage)
end
function configureDrones()
	clearGMFunctions()
	addGMFunction("-From Drones",playerConfig)
	local button_label = "Drones Off"
	if dronesAreAllowed then
		button_label = "Drones On"
	end
	addGMFunction(button_label,function()
		if dronesAreAllowed then
			dronesAreAllowed = false
		else
			dronesAreAllowed = true
		end
		configureDrones()
	end)
	if dronesAreAllowed then
		addGMFunction(string.format("+Capacity %i",uniform_drone_carrying_capacity),setDroneCarryingCapacity)
		addGMFunction(string.format("Name %s",drone_name_type),function()
			if drone_name_type == "squad-num of size" then
				drone_name_type = "default"
			elseif drone_name_type == "default" then
				drone_name_type = "squad-num/size"
			elseif drone_name_type == "squad-num/size" then
				drone_name_type = "short"
			elseif drone_name_type == "short" then
				drone_name_type = "squad-num of size"
			end
			configureDrones() 
		end)
		addGMFunction(string.format("+Flag I%i M%i",drone_flag_check_interval,drone_message_reset_count),setDroneFlagValues)
		addGMFunction(string.format("+Distance F%.1fU S%.1fU",drone_formation_spacing/1000,drone_scan_range_for_flags/1000),setDroneDistances)
		button_label = "Template Mod Off"
		if drone_modified_from_template then
			button_label = "Template Mod On"
		end
		addGMFunction(button_label,function()
			if drone_modified_from_template then
				drone_modified_from_template = false
			else
				drone_modified_from_template = true
			end
			configureDrones() 
		end)
		if drone_modified_from_template then
			addGMFunction(string.format("+Hull %i",drone_hull_strength),setDroneHull)
			addGMFunction(string.format("+Impulse %i",drone_impulse_speed),setDroneImpulseSpeed)
			addGMFunction(string.format("+Beam R%.1fU D%.1f C%.1f",drone_beam_range/1000,drone_beam_damage,drone_beam_cycle_time),setDroneBeam)
		end
	end
end
function setPlayerProbes()
	clearGMFunctions()
	addGMFunction("-Main from Probes",mainGMButtons)
	addGMFunction("-Player Config",playerConfig)
	if revisedPlayerShipProbeCount < 50 then
		addGMFunction(string.format("Probes %i Add 1 -> %i",revisedPlayerShipProbeCount,revisedPlayerShipProbeCount + 1),function()
			local p = getPlayerShip(-1)
			if p == nil then
				revisedPlayerShipProbeCount = revisedPlayerShipProbeCount + 1
				setPlayerProbes()
			else
				playerConfig()
			end
		end)
	end
	if revisedPlayerShipProbeCount > 1 then
		addGMFunction(string.format("Probes %i Del 1 -> %i",revisedPlayerShipProbeCount,revisedPlayerShipProbeCount - 1),function()
			local p = getPlayerShip(-1)
			if p == nil then
				revisedPlayerShipProbeCount = revisedPlayerShipProbeCount - 1
				setPlayerProbes()
			else
				playerConfig()
			end
		end)
	end
end
function setTagDistance()
	clearGMFunctions()
	addGMFunction("-Main from Tag",mainGMButtons)
	addGMFunction("-Player Config",playerConfig)
	addGMFunction("-From Tag Distance",setTagValues)
	if tag_distance < 5000 then
		addGMFunction(string.format("%.1fU Add .1 -> %.1fU",tag_distance/1000,(tag_distance + 100)/1000),function()
			tag_distance = tag_distance + 100
			setTagDistance()
		end)
	end
	if tag_distance > 500 then
		addGMFunction(string.format("%.1fU Del .1 -> %.1fU",tag_distance/1000,(tag_distance - 100)/1000),function()
			tag_distance = tag_distance - 100
			setTagDistance()
		end)
	end
end
function setTagDamage()
	clearGMFunctions()
	addGMFunction("-Main from Tag",mainGMButtons)
	addGMFunction("-Player Config",playerConfig)
	addGMFunction("-From Tag Dmg",setTagValues)
	if tagDamage < 2 then
		addGMFunction(string.format("%.2f Add .25 -> %.2f",tagDamage,tagDamage + .25),function()
			tagDamage = tagDamage + .25
			setTagDamage()
		end)
	end
	if tagDamage > .25 then
		addGMFunction(string.format("%.2f Del .25 -> %.2f",tagDamage,tagDamage - .25),function()
			tagDamage = tagDamage - .25
			setTagDamage()
		end)
	end
end
--	Drone related GM button functions
function setDroneCarryingCapacity()
	clearGMFunctions()
	addGMFunction("-Main",mainGMButtons)
	addGMFunction("-Player Config",playerConfig)
	addGMFunction("-From Capacity",configureDrones)
	if uniform_drone_carrying_capacity < 100 then
		addGMFunction(string.format("%i Add 10 -> %i",uniform_drone_carrying_capacity,uniform_drone_carrying_capacity + 10),function()
			uniform_drone_carrying_capacity = uniform_drone_carrying_capacity + 10
			setDroneCarryingCapacity()
		end)
	end
	if uniform_drone_carrying_capacity > 10 then
		addGMFunction(string.format("%i Del 10 -> %i",uniform_drone_carrying_capacity,uniform_drone_carrying_capacity - 10),function()
			uniform_drone_carrying_capacity = uniform_drone_carrying_capacity - 10
			setDroneCarryingCapacity()
		end)
	end
end
function setDroneFlagValues()
	clearGMFunctions()
	addGMFunction("-Main",mainGMButtons)
	addGMFunction("-Player Config",playerConfig)
	addGMFunction("-From Drone Flag",configureDrones)
	if drone_flag_check_interval < 20 then
		addGMFunction(string.format("Interval %i Add 1 -> %i",drone_flag_check_interval,drone_flag_check_interval + 1),function()
			drone_flag_check_interval = drone_flag_check_interval + 1
			setDroneFlagValues()
		end)
	end
	if drone_flag_check_interval > 1 then
		addGMFunction(string.format("Interval %i Del 1 -> %i",drone_flag_check_interval,drone_flag_check_interval - 1),function()
			drone_flag_check_interval = drone_flag_check_interval - 1
			setDroneFlagValues()
		end)
	end
	if drone_message_reset_count < 20 then
		addGMFunction(string.format("Msg Reset %i Add 1 -> %i",drone_message_reset_count,drone_message_reset_count + 1),function()
			drone_message_reset_count = drone_message_reset_count + 1
			setDroneFlagValues()
		end)
	end
	if drone_message_reset_count > 2 then
		addGMFunction(string.format("Msg Reset %i Del 1 -> %i",drone_message_reset_count,drone_message_reset_count - 1),function()
			drone_message_reset_count = drone_message_reset_count - 1
			setDroneFlagValues()
		end)
	end
end
function setDroneDistances()
	clearGMFunctions()
	addGMFunction("-Main",mainGMButtons)
	addGMFunction("-Player Config",playerConfig)
	addGMFunction("-From Drone Distance",configureDrones)
	if drone_formation_spacing < 9000 then
		addGMFunction(string.format("Form %.1fU Add .1 -> %.1fU",drone_formation_spacing/1000,(drone_formation_spacing + 100)/1000),function()
			drone_formation_spacing = drone_formation_spacing + 100
			setDroneDistances()
		end)
	end
	if drone_formation_spacing > 1000 then
		addGMFunction(string.format("Form %.1fU Del .1 -> %.1fU",drone_formation_spacing/1000,(drone_formation_spacing - 100)/1000),function()
			drone_formation_spacing = drone_formation_spacing - 100
			setDroneDistances()
		end)
	end
	if drone_scan_range_for_flags < 9000 then
		addGMFunction(string.format("Scan %.1fU Add .1 -> %.1fU",drone_scan_range_for_flags/1000,(drone_scan_range_for_flags + 100)/1000),function()
			drone_scan_range_for_flags = drone_scan_range_for_flags + 100
			setDroneDistances()
		end)
	end
	if drone_scan_range_for_flags > 3000 then
		addGMFunction(string.format("Scan %.1fU Del .1 -> %.1fU",drone_scan_range_for_flags/1000,(drone_scan_range_for_flags - 100)/1000),function()
			drone_scan_range_for_flags = drone_scan_range_for_flags - 100
			setDroneDistances()
		end)
	end
end
function setDroneHull()
	clearGMFunctions()
	addGMFunction("-Main",mainGMButtons)
	addGMFunction("-Player Config",playerConfig)
	addGMFunction("-From Drone Hull",configureDrones)
	if drone_hull_strength < 200 then
		addGMFunction(string.format("%i Add 10 -> %i",drone_hull_strength,drone_hull_strength + 10),function()
			drone_hull_strength = drone_hull_strength + 10
			setDroneHull()
		end)
	end
	if drone_hull_strength > 10 then
		addGMFunction(string.format("%i Del 10 -> %i",drone_hull_strength,drone_hull_strength - 10),function()
			drone_hull_strength = drone_hull_strength - 10
			setDroneHull()
		end)
	end
end
function setDroneImpulseSpeed()
	clearGMFunctions()
	addGMFunction("-Main",mainGMButtons)
	addGMFunction("-Player Config",playerConfig)
	addGMFunction("-From Drone Impulse",configureDrones)
	if drone_impulse_speed < 150 then
		addGMFunction(string.format("%i Add 5 -> %i",drone_impulse_speed,drone_impulse_speed + 5),function()
			drone_impulse_speed = drone_impulse_speed + 5
			setDroneImpulseSpeed()
		end)
	end
	if drone_impulse_speed > 50 then
		addGMFunction(string.format("%i Del 5 -> %i",drone_impulse_speed,drone_impulse_speed - 5),function()
			drone_impulse_speed = drone_impulse_speed - 5
			setDroneImpulseSpeed()
		end)
	end
end
function setDroneBeam()
	clearGMFunctions()
	addGMFunction("-Main",mainGMButtons)
	addGMFunction("-Player Config",playerConfig)
	addGMFunction("-From Drone Beam",configureDrones)
	if drone_beam_range < 2000 then
		addGMFunction(string.format("Rng %.1fU Add .1 -> %.1fU",drone_beam_range/1000,(drone_beam_range + 100)/1000),function()
			drone_beam_range = drone_beam_range + 100
			setDroneBeam()
		end)
	end
	if drone_beam_range > 300 then
		addGMFunction(string.format("Rng %.1fU Del .1 -> %.1fU",drone_beam_range/1000,(drone_beam_range - 100)/1000),function()
			drone_beam_range = drone_beam_range - 100
			setDroneBeam()
		end)
	end
	if drone_beam_damage < 20 then
		addGMFunction(string.format("Dmg %.1f Add .5 -> %.1f",drone_beam_damage,drone_beam_damage + .5),function()
			drone_beam_damage = drone_beam_damage + .5
			setDroneBeam()
		end)
	end
	if drone_beam_damage > 1 then
		addGMFunction(string.format("Dmg %.1f Del .5 -> %.1f",drone_beam_damage,drone_beam_damage - .5),function()
			drone_beam_damage = drone_beam_damage - .5
			setDroneBeam()
		end)
	end
	if drone_beam_cycle_time < 20 then
		addGMFunction(string.format("Cycle %.1f Add .5 -> %.1f",drone_beam_cycle_time,drone_beam_cycle_time + .5),function()
			drone_beam_cycle_time = drone_beam_cycle_time + .5
			setDroneBeam()
		end)
	end
	if drone_beam_cycle_time > 1 then
		addGMFunction(string.format("Cycle %.1f Del .5 -> %.1f",drone_beam_cycle_time,drone_beam_cycle_time - .5),function()
			drone_beam_cycle_time = drone_beam_cycle_time - .5
			setDroneBeam()
		end)
	end
end

function mainGMButtonsAfterPause()
	clearGMFunctions()
	addGMFunction(string.format("Version %s",scenario_version),function()
		local version_message = string.format("Scenario version %s\n LUA version %s",scenario_version,_VERSION)
		addGMMessage(version_message)
		print(version_message)
	end)
	addGMFunction("Show control codes",showControlCodes)
	addGMFunction("Show Kraylor codes",showKraylorCodes)
	addGMFunction("Show Human codes",showHumanCodes)
	local button_label = "Enable Auto-Enemies"
	if autoEnemies then
		button_label = "Disable Auto-Enemies"
	end
	addGMFunction(button_label,function()
		if autoEnemies then
			autoEnemies = false
		else
			autoEnemies = true
		end
		mainGMButtons()
	end)
	button_label = "Turn on Diagnostic"
	if diagnostic then
		button_label = "Turn off Diagnostic"
	end
	addGMFunction(button_label,function()
		if diagnostic then
			diagnostic = false
		else
			diagnostic = true
		end
		mainGMButtons()
	end)
	addGMFunction("Current Stats", currentStats)
	if dronesAreAllowed then 
		addGMFunction("Detailed Drone Report", detailedDroneReport)
	end
end
function showKraylorCodes()
	showControlCodes("Kraylor")
end
function showHumanCodes()
	showControlCodes("Human Navy")
end
function showControlCodes(faction_filter)
	local code_list = {}
	for pidx=1,32 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if faction_filter == "Kraylor" then
				if p:getFaction() == "Kraylor" then
					code_list[p:getCallSign()] = {code = p.control_code, faction = p:getFaction()}
				end
			elseif faction_filter == "Human Navy" then
				if p:getFaction() == "Human Navy" then
					code_list[p:getCallSign()] = {code = p.control_code, faction = p:getFaction()}
				end
			else
				code_list[p:getCallSign()] = {code = p.control_code, faction = p:getFaction()}
			end
		end
	end
	local sorted_names = {}
	for name in pairs(code_list) do
		table.insert(sorted_names,name)
	end
	table.sort(sorted_names)
	local output = ""
	for _, name in ipairs(sorted_names) do
		local faction = ""
		if code_list[name].faction == "Kraylor" then
			faction = " (Kraylor)"
		end
		output = output .. string.format("%s: %s %s\n",name,code_list[name].code,faction)
	end
	addGMMessage(output)
end
function intelligentBugger()
	-- Spawn a player ship not affiliated with either team for harassment purposes
	if bugger == nil then
		spawnBugger()
	else
		if not bugger:isValid() then
			spawnBugger()
		end
	end
	if buggerResupply == nil then
		buggerResupply = SpaceStation():setFaction("Exuari"):setTemplate("Medium Station"):setPosition(0,boundary/2 + 2000):setCommsScript(""):setCommsFunction(resupplyStation)
	else
		if not buggerResupply:isValid() then
			buggerResupply = SpaceStation():setFaction("Exuari"):setTemplate("Medium Station"):setPosition(0,boundary/2 + 2000):setCommsScript(""):setCommsFunction(resupplyStation)
		end
	end
end
function spawnBugger()
	bugger = PlayerSpaceship():setFaction("Exuari"):setPosition(0,boundary/2):addReputationPoints(100)
	if random(1,500) < 50 then
		bugger:setTemplate("ZX-Lindworm"):setWarpDrive(true)
	else
		bugger:setTemplate("Repulse")
	end
end
function currentStats()
	local active_human_ship_count = 0
	local destroyed_human_ship_count = 0
	local active_kraylor_ship_count = 0
	local destroyed_kraylor_ship_count = 0
	local active_human_drone_count = 0
	local destroyed_human_drone_count = 0
	local active_kraylor_drone_count = 0
	local destroyed_kraylor_drone_count = 0
	local bugger_count = 0
	for pidx=1,32 do
		p = getPlayerShip(pidx)
		if p ~= nil then
			if p:isValid() then
				local faction = p:getFaction()
				if faction == "Exuari" then
					bugger_count = bugger_count + 1
				elseif faction == "Kraylor" then
					active_kraylor_ship_count = active_kraylor_ship_count + 1
				elseif faction == "Human Navy" then
					active_human_ship_count = active_human_ship_count + 1
				end
			end
			if pidx %2 == 0 then	--kraylor
				if p.droneSquads ~= nil then
					for squadName, droneList in pairs(p.droneSquads) do
						for i=1,#droneList do
							if droneList[i]:isValid() then
								active_kraylor_drone_count = active_kraylor_drone_count + 1
							else
								destroyed_kraylor_drone_count = destroyed_kraylor_drone_count + 1
							end
						end
					end
				end
			else	--human
				if p.droneSquads ~= nil then
					for squadName, droneList in pairs(p.droneSquads) do
						for i=1,#droneList do
							if droneList[i]:isValid() then
								active_human_drone_count = active_human_drone_count + 1
							else
								destroyed_human_drone_count = destroyed_human_drone_count + 1
							end
						end
					end
				end
			end
		end
	end
	for pName, p in pairs(human_player_names) do
		if not p:isValid() then
			destroyed_human_ship_count = destroyed_human_ship_count + 1
		end
	end
	for pName, p in pairs(kraylor_player_names) do
		if not p:isValid() then
			destroyed_kraylor_ship_count = destroyed_kraylor_ship_count + 1
		end
	end
	print(" ")
	print("----------CURRENT SUMMARY STATS-----------")
	print("  Humans:")
	print("    Number of active ships:  " .. active_human_ship_count)
	print("    Number of destroyed ships:  " .. destroyed_human_ship_count)
	if dronesAreAllowed then
		print("    Total number of active drones:  " .. active_human_drone_count)
		print("    Total number of destroyed drones:  " .. destroyed_human_drone_count)
	end
	print("  Kraylor:")
	print("    Number of active ships:  " .. active_kraylor_ship_count)
	print("    Number of destroyed ships:  " .. destroyed_kraylor_ship_count)
	if dronesAreAllowed then
		print("    Total number of active drones:  " .. active_kraylor_drone_count)
		print("    Total number of destroyed drones:  " .. destroyed_kraylor_drone_count)
	end
	if bugger_count > 0 then
		print("Active buggers:  " .. bugger_count)
	end
	print("-----------------END STATS-----------------")
	local gm_out = "Human:"
	gm_out = gm_out .. "\n   Number of active ships: " .. active_human_ship_count
	gm_out = gm_out .. "\n   Number of destroyed ships: " .. destroyed_human_ship_count
	if dronesAreAllowed then
		gm_out = gm_out .. "\n   Total number of active drones: " .. active_human_drone_count
		gm_out = gm_out .. "\n   Total number of destroyed drones: " .. destroyed_human_drone_count
	end
	gm_out = gm_out .. "\nKraylor:"
	gm_out = gm_out .. "\n   Number of active ships: " .. active_kraylor_ship_count
	gm_out = gm_out .. "\n   Number of destroyed ships: " .. destroyed_kraylor_ship_count
	if dronesAreAllowed then
		gm_out = gm_out .. "\n   Total number of active drones: " .. active_kraylor_drone_count
		gm_out = gm_out .. "\n   Total number of destroyed drones: " .. destroyed_kraylor_drone_count
	end
	if bugger_count > 0 then
		gm_out = gm_out .. "\nActive buggers: " .. bugger_count
	end
	addGMMessage(gm_out)
end
function detailedDroneReport()
	print(" ")
	print(">>>>>>>>>>>>>>>BEGIN DETAILED DRONE REPORT<<<<<<<<<<<<<")
	local drone_disposition = nil
	for index=1,32 do
		local player_ship = getPlayerShip(index)
		if player_ship ~= nil and player_ship:isValid() then
			local faction = player_ship:getFaction()
			if faction ~= "Exuari" then
				print("  Player ship " .. index .. ": " .. faction)
				print("    Call Sign:  " .. player_ship:getCallSign())
				print("    Current # of stored drones:  " .. player_ship.dronePool)
				local player_drone_squad_count = 0
				local active_drone_count = 0
				if player_ship.droneSquads ~= nil then
					for squadName, droneList in pairs(player_ship.droneSquads) do
						player_drone_squad_count = player_drone_squad_count + 1
						print("    Drone Squad: " .. squadName)
						for i=1,#droneList do
							if droneList[i]:isValid() then
								print("        Drone " .. i .. " (" .. droneList[i]:getCallSign() .. ") Active")
								active_drone_count = active_drone_count + 1
							else
								print("        Drone " .. i .. " Destroyed")
							end
						end
					end
				end
				print("    Number of deloyed drone squadrons:  " .. player_drone_squad_count)
				print("    Current number of live deployed drones:  " .. active_drone_count)
				print("  ---")
			end
		end
	end
	print(">>>>>>>>>>>>>>>>>END DETAILED REPORT<<<<<<<<<<<<<<<<<<<")
end
----------------------------------------
--	Initialization support functions  --
----------------------------------------
function setVariations()
	if string.find(getScenarioVariation(),"Easy") then		--will be told which opposing team ship picked up flag
		difficulty = .5
		flagScanDepth = 1						--number of times to scan
		flagScanComplexity = math.random(1,2)	--number of bars in scan
	elseif string.find(getScenarioVariation(),"Hard") then	--won't be told when opposing team picks up flag
		difficulty = 2
		flagScanDepth = math.random(1,3)		--number of times to scan
		flagScanComplexity = math.random(3,4)	--number of bars in scan
	else													--will be told that opposing team picked up flag
		difficulty = 1		--default (normal)
		flagScanDepth = math.random(2,3)		--number of times to scan
		flagScanComplexity = 2					--number of bars in scan
	end
	if string.find(getScenarioVariation(),"Small") then
		boundary = 50000
	elseif string.find(getScenarioVariation(),"Large") then
		boundary = 200000
	else
		boundary = 100000
	end
end
function initializeDroneButtonFunctionTables()
	drop_decoy_functions = {
		{p1DropDecoy,p1DropDecoy2,p1DropDecoy3},
		{p2DropDecoy,p2DropDecoy2,p2DropDecoy3},
		{p3DropDecoy,p3DropDecoy2,p3DropDecoy3},
		{p4DropDecoy,p4DropDecoy2,p4DropDecoy3},
		{	nil		,p5DropDecoy ,p5DropDecoy3},
		{	nil		,p6DropDecoy ,p6DropDecoy3},
		{	nil		,	nil		 ,p7DropDecoy},
		{	nil		,	nil		 ,p8DropDecoy},
	}
end

function setPlayer(pobj,playerIndex)
	goods[pobj] = goodsList
	pobj:addReputationPoints(150)
	pobj.nameAssigned = true
	tempPlayerType = pobj:getTypeName()
	if tempPlayerType == "MP52 Hornet" then
		if #playerShipNamesForMP52Hornet > 0 then
			ni = math.random(1,#playerShipNamesForMP52Hornet)
			pobj:setCallSign(playerShipNamesForMP52Hornet[ni])
			table.remove(playerShipNamesForMP52Hornet,ni)
		end
		pobj.shipScore = 7
		pobj.maxCargo = 3
		pobj.autoCoolant = false
		pobj:setWarpDrive(true)
	elseif tempPlayerType == "Piranha" then
		if #playerShipNamesForPiranha > 0 then
			ni = math.random(1,#playerShipNamesForPiranha)
			pobj:setCallSign(playerShipNamesForPiranha[ni])
			table.remove(playerShipNamesForPiranha,ni)
		end
		pobj.shipScore = 16
		pobj.maxCargo = 8
	elseif tempPlayerType == "Flavia P.Falcon" then
		if #playerShipNamesForFlaviaPFalcon > 0 then
			ni = math.random(1,#playerShipNamesForFlaviaPFalcon)
			pobj:setCallSign(playerShipNamesForFlaviaPFalcon[ni])
			table.remove(playerShipNamesForFlaviaPFalcon,ni)
		end
		pobj.shipScore = 13
		pobj.maxCargo = 15
	elseif tempPlayerType == "Phobos M3P" then
		if #playerShipNamesForPhobosM3P > 0 then
			ni = math.random(1,#playerShipNamesForPhobosM3P)
			pobj:setCallSign(playerShipNamesForPhobosM3P[ni])
			table.remove(playerShipNamesForPhobosM3P,ni)
		end
		pobj.shipScore = 19
		pobj.maxCargo = 10
		pobj:setWarpDrive(true)
	elseif tempPlayerType == "Atlantis" then
		if #playerShipNamesForAtlantis > 0 then
			ni = math.random(1,#playerShipNamesForAtlantis)
			pobj:setCallSign(playerShipNamesForAtlantis[ni])
			table.remove(playerShipNamesForAtlantis,ni)
		end
		pobj.shipScore = 52
		pobj.maxCargo = 6
	elseif tempPlayerType == "Player Cruiser" then
		if #playerShipNamesForCruiser > 0 then
			ni = math.random(1,#playerShipNamesForCruiser)
			pobj:setCallSign(playerShipNamesForCruiser[ni])
			table.remove(playerShipNamesForCruiser,ni)
		end
		pobj.shipScore = 40
		pobj.maxCargo = 6
	elseif tempPlayerType == "Player Missile Cr." then
		if #playerShipNamesForMissileCruiser > 0 then
			ni = math.random(1,#playerShipNamesForMissileCruiser)
			pobj:setCallSign(playerShipNamesForMissileCruiser[ni])
			table.remove(playerShipNamesForMissileCruiser,ni)
		end
		pobj.shipScore = 45
		pobj.maxCargo = 8
	elseif tempPlayerType == "Player Fighter" then
		if #playerShipNamesForFighter > 0 then
			ni = math.random(1,#playerShipNamesForFighter)
			pobj:setCallSign(playerShipNamesForFighter[ni])
			table.remove(playerShipNamesForFighter,ni)
		end
		pobj.shipScore = 7
		pobj.maxCargo = 3
		pobj.autoCoolant = false
		pobj:setJumpDrive(true)
		pobj:setJumpDriveRange(3000,40000)
	elseif tempPlayerType == "Benedict" then
		if #playerShipNamesForBenedict > 0 then
			ni = math.random(1,#playerShipNamesForBenedict)
			pobj:setCallSign(playerShipNamesForBenedict[ni])
			table.remove(playerShipNamesForBenedict,ni)
		end
		pobj.shipScore = 10
		pobj.maxCargo = 9
	elseif tempPlayerType == "Kiriya" then
		if #playerShipNamesForKiriya > 0 then
			ni = math.random(1,#playerShipNamesForKiriya)
			pobj:setCallSign(playerShipNamesForKiriya[ni])
			table.remove(playerShipNamesForKiriya,ni)
		end
		pobj.shipScore = 10
		pobj.maxCargo = 9
	elseif tempPlayerType == "Striker" then
		if #playerShipNamesForStriker > 0 then
			ni = math.random(1,#playerShipNamesForStriker)
			pobj:setCallSign(playerShipNamesForStriker[ni])
			table.remove(playerShipNamesForStriker,ni)
		end
		pobj.shipScore = 8
		pobj.maxCargo = 4
		pobj:setJumpDrive(true)
		pobj:setJumpDriveRange(3000,40000)
	elseif tempPlayerType == "ZX-Lindworm" then
		if #playerShipNamesForLindworm > 0 then
			ni = math.random(1,#playerShipNamesForLindworm)
			pobj:setCallSign(playerShipNamesForLindworm[ni])
			table.remove(playerShipNamesForLindworm,ni)
		end
		pobj.shipScore = 8
		pobj.maxCargo = 3
		pobj.autoCoolant = false
		pobj:setWarpDrive(true)
	elseif tempPlayerType == "Repulse" then
		if #playerShipNamesForRepulse > 0 then
			ni = math.random(1,#playerShipNamesForRepulse)
			pobj:setCallSign(playerShipNamesForRepulse[ni])
			table.remove(playerShipNamesForRepulse,ni)
		end
		pobj.shipScore = 14
		pobj.maxCargo = 12
	elseif tempPlayerType == "Ender" then
		if #playerShipNamesForEnder > 0 then
			ni = math.random(1,#playerShipNamesForEnder)
			pobj:setCallSign(playerShipNamesForEnder[ni])
			table.remove(playerShipNamesForEnder,ni)
		end
		pobj.shipScore = 100
		pobj.maxCargo = 20
	elseif tempPlayerType == "Nautilus" then
		if #playerShipNamesForNautilus > 0 then
			ni = math.random(1,#playerShipNamesForNautilus)
			pobj:setCallSign(playerShipNamesForNautilus[ni])
			table.remove(playerShipNamesForNautilus,ni)
		end
		pobj.shipScore = 12
		pobj.maxCargo = 7
	elseif tempPlayerType == "Hathcock" then
		if #playerShipNamesForHathcock > 0 then
			ni = math.random(1,#playerShipNamesForHathcock)
			pobj:setCallSign(playerShipNamesForHathcock[ni])
			table.remove(playerShipNamesForHathcock,ni)
		end
		pobj.shipScore = 30
		pobj.maxCargo = 6
	else
		if #playerShipNamesForLeftovers > 0 then
			ni = math.random(1,#playerShipNamesForLeftovers)
			pobj:setCallSign(playerShipNamesForLeftovers[ni])
			table.remove(playerShipNamesForLeftovers,ni)
		end
		pobj.shipScore = 24
		pobj.maxCargo = 5
		pobj:setWarpDrive(true)
	end
	if dronesAreAllowed then
		pobj.deploy_drone = function(pidx,droneNumber)
			local p = getPlayerShip(pidx)
			local px, py = p:getPosition()
			local droneList = {}
			if p.droneSquads == nil then
				p.droneSquads = {}
				p.squadCount = 0
			end
			local squadIndex = p.squadCount + 1
			local pName = p:getCallSign()
			local squadName = string.format("%s-Sq%i",pName,squadIndex)
			all_squad_count = all_squad_count + 1
			for i=1,droneNumber do
				local vx, vy = vectorFromAngle(360/droneNumber*i,800)
				local drone = CpuShip():setPosition(px+vx,py+vy):setFaction(p:getFaction()):setTemplate("Ktlitan Drone"):setScanned(true):setCommsScript(""):setCommsFunction(commsShip):setHeading(360/droneNumber*i+90)
				if drone_name_type == "squad-num/size" then
					drone:setCallSign(string.format("%s-#%i/%i",squadName,i,droneNumber))
				elseif drone_name_type == "squad-num of size" then
					drone:setCallSign(string.format("%s-%i of %i",squadName,i,droneNumber))
				elseif drone_name_type == "short" then
					--string.char(math.random(65,90)) --random letter A-Z
					local squad_letter_id = string.char(all_squad_count%26+64)
					if all_squad_count > 26 then
						squad_letter_id = squad_letter_id .. string.char(math.floor(all_squad_count/26)+64)
						if all_squad_count > 676 then
							squad_letter_id = squad_letter_id .. string.char(math.floor(all_squad_count/676)+64)
						end
					end
					drone:setCallSign(string.format("%s%i/%i",squad_letter_id,i,droneNumber))
				end
				if drone_modified_from_template then
					drone:setHullMax(drone_hull_strength):setHull(drone_hull_strength):setImpulseMaxSpeed(drone_impulse_speed)
					--       index from 0, arc, direction,            range,            cycle time,            damage
					drone:setBeamWeapon(0,  40,         0, drone_beam_range, drone_beam_cycle_time, drone_beam_damage)
				end
				drone.squadName = squadName
				drone.deployer = p
				drone.drone = true
				drone:onDestruction(droneDestructionManagement)
				table.insert(droneList,drone)
			end
			p.squadCount = p.squadCount + 1
			p.dronePool = p.dronePool - droneNumber
			p.droneSquads[squadName] = droneList
			if p:hasPlayerAtPosition("Weapons") then
				if droneNumber > 1 then
					p:addCustomMessage("Weapons","drone_launch_confirm_message_weapons",string.format("%i drones launched",droneNumber))
				else
					p:addCustomMessage("Weapons","drone_launch_confirm_message_weapons",string.format("%i drone launched",droneNumber))
				end
			end
			if p:hasPlayerAtPosition("Tactical") then
				if droneNumber > 1 then
					p:addCustomMessage("Tactical","drone_launch_confirm_message_tactical",string.format("%i drones launched",droneNumber))
				else
					p:addCustomMessage("Tactical","drone_launch_confirm_message_tactical",string.format("%i drone launched",droneNumber))
				end
			end
			if droneNumber > 1 then
				p:addToShipLog(string.format("Deployed %i drones as squadron %s",droneNumber,squadName),"White")
			else
				p:addToShipLog(string.format("Deployed %i drone as squadron %s",droneNumber,squadName),"White")
			end
		end
		pobj.count_drones = function(pidx)
			local p = getPlayerShip(pidx)
			local msgLabel = string.format("weaponsDroneCount%s",p:getCallSign())
			p:addCustomMessage("Weapons",msgLabel,string.format("You have %i drones to deploy",p.dronePool))
			msgLabel = string.format("tacticalDroneCount%s",p:getCallSign())
			p:addCustomMessage("Tactical",msgLabel,string.format("You have %i drones to deploy",p.dronePool))
		end
		pobj.drone_hull_status = function(pidx)
			local player_ship = getPlayerShip(pidx)
			local drone_report_message = "> > > > > > > > Drone Hull Status Report: < < < < < < < <"
			--drone_report_message = drone_report_message .. "\n    Current number of stored drones:  " .. player_ship.dronePool
			local player_drone_squad_count = 0
			local active_drone_count = 0
			if player_ship.droneSquads ~= nil then
				for squadName, droneList in pairs(player_ship.droneSquads) do
					player_drone_squad_count = player_drone_squad_count + 1
					drone_report_message = drone_report_message .. "\n        Drone Squad: " .. squadName
					local active_drone_in_squad_count = 0
					local squad_report = ""
					for i=1,#droneList do
						local drone = droneList[i]
						if drone:isValid() then
							squad_report = squad_report .. string.format("\n            Drone %i (%s) Hull: %i/%i",
								i,
								drone:getCallSign(),
								math.floor(drone:getHull()),
								math.floor(drone:getHullMax()))
							active_drone_count = active_drone_count + 1
							active_drone_in_squad_count = active_drone_in_squad_count + 1
						else
							squad_report = squad_report .. string.format("\n            Drone %i --Destroyed--",i)
						end
					end
					if active_drone_in_squad_count > 0 then
						drone_report_message = drone_report_message .. squad_report
					else
						drone_report_message = drone_report_message .. " --Destroyed--"
					end
				end
			end
			drone_report_message = drone_report_message .. "\n    Number of deployed drone squadrons: " .. player_drone_squad_count
			drone_report_message = drone_report_message .. "\n    Current number of live deployed drones: " .. active_drone_count
			local p_name = player_ship:getCallSign()
			if player_ship:hasPlayerAtPosition("Engineering") then
				player_ship:addCustomMessage("Engineering",string.format("%sengineeringdronesstatus",p_name),drone_report_message)
			end
			if player_ship:hasPlayerAtPosition("Engineering+") then
				player_ship:addCustomMessage("Engineering+",string.format("%sengineeringplusdronesstatus",p_name),drone_report_message)
			end
		end
		pobj.drone_locations = function(pidx)
			local player_ship = getPlayerShip(pidx)
			local drone_report_message = "> > > > > > > > Drone Location Report: < < < < < < < <"
			--drone_report_message = drone_report_message .. "\n    Current number of stored drones:  " .. player_ship.dronePool
			local player_drone_squad_count = 0
			local active_drone_count = 0
			if player_ship.droneSquads ~= nil then
				for squadName, droneList in pairs(player_ship.droneSquads) do
					player_drone_squad_count = player_drone_squad_count + 1
					drone_report_message = drone_report_message .. "\n        Drone Squad: " .. squadName
					local active_drone_in_squad_count = 0
					local squad_report = ""
					for i=1,#droneList do
						local drone = droneList[i]
						if drone:isValid() then
							local drone_x, drone_y = drone:getPosition()
							squad_report = squad_report .. string.format("\n            Drone %i (%s) Sector %s, X: %7.0f, Y: %7.0f",
								i,
								drone:getCallSign(),
								drone:getSectorName(),
								drone_x,
								drone_y)
							active_drone_count = active_drone_count + 1
							active_drone_in_squad_count = active_drone_in_squad_count + 1
						else
							squad_report = squad_report .. string.format("\n            Drone %i --Destroyed--",i)
						end
					end
					if active_drone_in_squad_count > 0 then
						drone_report_message = drone_report_message .. squad_report
					else
						drone_report_message = drone_report_message .. " --Destroyed--"
					end
				end
			end
			drone_report_message = drone_report_message .. "\n    Number of deployed drone squadrons: " .. player_drone_squad_count
			drone_report_message = drone_report_message .. "\n    Current number of live deployed drones: " .. active_drone_count
			local p_name = player_ship:getCallSign()
			if player_ship:hasPlayerAtPosition("Helms") then
				player_ship:addCustomMessage("Helms",string.format("%shelmdroneslocation",p_name),drone_report_message)
			end
			if player_ship:hasPlayerAtPosition("Tactical") then
				player_ship:addCustomMessage("Tactical",string.format("%stacticaldroneslocation",p_name),drone_report_message)
			end
		end
		local pName = pobj:getCallSign()
		--local button_name = ""
		if pobj.droneButton == nil then
			pobj.droneButton = true
			pobj.dronePool = uniform_drone_carrying_capacity
			pobj:addCustomButton("Weapons",string.format("%sdeploy5weapons",pName),"5 Drones",function()
				string.format("")	--global context for SeriousProton
				pobj.deploy_drone(playerIndex,5)
			end)
			pobj:addCustomButton("Tactical",string.format("%sdeploy5tactical",pName),"5 Drones",function()
				string.format("")	--global context for SeriousProton
				pobj.deploy_drone(playerIndex,5)
			end)
			pobj:addCustomButton("Weapons",string.format("%sdeploy10weapons",pName),"10 Drones",function()
				string.format("")	--global context for SeriousProton
				pobj.deploy_drone(playerIndex,10)
			end)
			pobj:addCustomButton("Tactical",string.format("%sdeploy10tactical",pName),"10 Drones",function()
				string.format("")	--global context for SeriousProton
				pobj.deploy_drone(playerIndex,10)
			end)
			pobj:addCustomButton("Weapons",string.format("%scountWeapons",pName),"Count Drones",function()
				string.format("")	--global context for SeriousProton
				pobj.count_drones(playerIndex)
			end)
			pobj:addCustomButton("Tactical",string.format("%scountTactical",pName),"Count Drones",function()
				string.format("")	--global context for SeriousProton
				pobj.count_drones(playerIndex)
			end)
			pobj:addCustomButton("Engineering",string.format("%shullEngineering",pName),"Drone Hulls",function()
				string.format("")	--global context for SeriousProton
				pobj.drone_hull_status(playerIndex)
			end)
			pobj:addCustomButton("Engineering+",string.format("%shullEngineeringPlus",pName),"Drone Hulls",function()
				string.format("")	--global context for SeriousProton
				pobj.drone_hull_status(playerIndex)
			end)
			pobj:addCustomButton("Helms",string.format("%slocationHelm",pName),"Drone Locations",function()
				string.format("")	--global context for SeriousProton
				pobj.drone_locations(playerIndex)
			end)
			pobj:addCustomButton("Tactical",string.format("%slocationTactical",pName),"Drone Locations",function()
				string.format("")	--global context for SeriousProton
				pobj.drone_locations(playerIndex)
			end)
		end
	end
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
	local control_code_index = math.random(1,#control_code_stem)
	local stem = control_code_stem[control_code_index]
	table.remove(control_code_stem,control_code_index)
	local branch = math.random(100,999)
	pobj.control_code = stem .. branch
	pobj:setControlCode(stem .. branch)
	print("Control Code for " .. pobj:getCallSign(), pobj.control_code)
	-- Kilted Klingon mods:
	pobj:setMaxScanProbeCount(revisedPlayerShipProbeCount)
	pobj:setScanProbeCount(revisedPlayerShipProbeCount)
end

-----------------
--	Utilities  --
-----------------
function placeRandomAroundPointList(object_type, amount, dist_min, dist_max, x0, y0)
	local pointList = {}
    for n=1,amount do
        local r = random(0, 360)
        local distance = random(dist_min, dist_max)
        x = x0 + math.cos(r / 180 * math.pi) * distance
        y = y0 + math.sin(r / 180 * math.pi) * distance
        pointObj = object_type():setPosition(x, y)
		table.insert(pointList,pointObj)
    end
	return pointList
end
function createRandomAlongArc(object_type, amount, x, y, distance, startArc, endArcClockwise, randomize)
	-- Create amount of objects of type object_type along arc
	-- Center defined by x and y
	-- Radius defined by distance
	-- Start of arc between 0 and 360 (startArc), end arc: endArcClockwise
	-- Use randomize to vary the distance from the center point. Omit to keep distance constant
	-- Example:
	--   createRandomAlongArc(Asteroid, 100, 500, 3000, 65, 120, 450)
	arcObjects = {}
	if randomize == nil then randomize = 0 end
	if amount == nil then amount = 1 end
	arcLen = endArcClockwise - startArc
	if startArc > endArcClockwise then
		endArcClockwise = endArcClockwise + 360
		arcLen = arcLen + 360
	end
	if amount > arcLen then
		for ndex=1,arcLen do
			radialPoint = startArc+ndex
			pointDist = distance + random(-randomize,randomize)
			arcObj = object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist)
			table.insert(arcObjects,arcObj)			
		end
		for ndex=1,amount-arcLen do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
			arcObj = object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist)			
			table.insert(arcObjects,arcObj)			
		end
	else
		for ndex=1,amount do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
			arcObj = object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist)
			table.insert(arcObjects,arcObj)			
		end
	end
	return arcObjects
end
--	Mortal repair crew
function healthCheck(delta)
	if healthCheckTimer < 0 then
		healthCheckCount = healthCheckCount + 1
		for pidx=1,12 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if p:getRepairCrewCount() > 0 then
					fatalityChance = 0
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
					if psb[p:getTypeName()] ~= nil then
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
					end
					if fatalityChance > 0 then
						crewFate(p,fatalityChance)
					end
				else
					if random(1,100) <= 4 then
						p:setRepairCrewCount(1)
						if p:hasPlayerAtPosition("Engineering") then
							local repairCrewRecovery = "repairCrewRecovery"
							p:addCustomMessage("Engineering",repairCrewRecovery,"Medical team has revived one of your repair crew")
						end
						if p:hasPlayerAtPosition("Engineering+") then
							local repairCrewRecoveryPlus = "repairCrewRecoveryPlus"
							p:addCustomMessage("Engineering+",repairCrewRecoveryPlus,"Medical team has revived one of your repair crew")
						end
						resetPreviousSystemHealth(p)
					end
				end
			end
		end
		healthCheckTimer = delta + healthCheckTimerInterval
	end
end
function crewFate(p, fatalityChance)
	if math.random() < (fatalityChance) then
		p:setRepairCrewCount(p:getRepairCrewCount() - 1)
		if p:hasPlayerAtPosition("Engineering") then
			repairCrewFatality = "repairCrewFatality"
			p:addCustomMessage("Engineering",repairCrewFatality,"One of your repair crew has perished")
		end
		if p:hasPlayerAtPosition("Engineering+") then
			repairCrewFatalityPlus = "repairCrewFatalityPlus"
			p:addCustomMessage("Engineering+",repairCrewFatalityPlus,"One of your repair crew has perished")
		end
	end
end
--	Marauding enemies
function marauderWaves(delta)
	waveTimer = waveTimer - delta
	if waveTimer < 0 then
		if autoEnemies then
			waveTimer = delta + interWave + random(1,60)
			if dangerValue == nil then
				if difficulty < 1 then
					dangerValue = .5
					dangerIncrement = .1
				elseif difficulty > 1 then
					dangerValue = 1
					dangerIncrement = .5
				else
					dangerValue = .8
					dangerIncrement = .2
				end
			end
			marauderStart = math.random(1,3)
			mhsx = -1*boundary				--all marauder human start points are on the left boundary
			mksx = boundary					--all marauder kraylor start points are on the right boundary
			if marauderStart == 1 then		--upper left and lower right
				mhsy = -1*boundary/2		--marauder human start y
				mksy = boundary/2			--marauder kraylor start y
				if math.random(1,2) == 1 then
					mhex = playerStartX[1]	--marauder human end x
					mhey = playerStartY[1]	--marauder human end y
					mkex = playerStartX[2]	--marauder kraylor end x
					mkey = playerStartY[2]	--marauder kraylor end y
				else
					mhex = 0				--marauder human end x
					mhey = boundary/2		--marauder human end y
					mkex = 0				--marauder kraylor end x
					mkey = -1*boundary/2	--marauder kraylor end y
				end
			elseif marauderStart == 2 then	--mid left and mid right
				mhsy = 0
				mksy = 0
				marauderEnd = math.random(1,3)
				if marauderEnd == 1 then
					mhex = 0
					mhey = -1*boundary/2
					mkex = 0
					mkey = boundary/2
				elseif marauderEnd == 2 then
					mhex = 0
					mhey = boundary/2
					mkex = 0
					mkey = -1*boundary/2
				else
					mhex = playerStartX[1]	--marauder human end x
					mhey = playerStartY[1]	--marauder human end y
					mkex = playerStartX[2]	--marauder kraylor end x
					mkey = playerStartY[2]	--marauder kraylor end y
				end
			else							--lower left and upper right
				mhsy = boundary/2
				mksy = -1*boundary/2
				if math.random(1,2) == 1 then
					mhex = playerStartX[1]	--marauder human end x
					mhey = playerStartY[1]	--marauder human end y
					mkex = playerStartX[2]	--marauder kraylor end x
					mkey = playerStartY[2]	--marauder kraylor end y
				else
					mhex = 0				--marauder human end x
					mhey = -1*boundary/2	--marauder human end y
					mkex = 0				--marauder kraylor end x
					mkey = boundary/2		--marauder kraylor end y
				end
			end
			hmf = spawnEnemies(mhsx,mhsy,dangerValue,"Exuari")
			for _, enemy in ipairs(hmf) do
				enemy:orderFlyTowards(mhex,mhey)
			end
			kmf = spawnEnemies(mksx,mksy,dangerValue,"Exuari")
			for _, enemy in ipairs(kmf) do
				enemy:orderFlyTowards(mkex,mkey)
			end
			wakeList = getObjectsInRadius(playerStartX[1],playerStartY[1],500)
			for _, obj in ipairs(wakeList) do
				if obj:getFaction() == "Exuari" then
					obj:orderRoaming()
				end
			end
			wakeList = getObjectsInRadius(playerStartX[2],playerStartY[2],500)
			for _, obj in ipairs(wakeList) do
				if obj:getFaction() == "Exuari" then
					obj:orderRoaming()
				end
			end
			wakeList = getObjectsInRadius(0,-1*boundary/2,500)
			for _, obj in ipairs(wakeList) do
				if obj:getFaction() == "Exuari" then
					obj:orderRoaming()
				end
			end
			wakeList = getObjectsInRadius(0,boundary/2,500)
			for _, obj in ipairs(wakeList) do
				if obj:getFaction() == "Exuari" then
					obj:orderRoaming()
				end
			end
			dangerValue = dangerValue + dangerIncrement
		end
	end
end
function spawnEnemies(xOrigin, yOrigin, danger, enemyFaction)
	if enemyFaction == nil then
		enemyFaction = "Kraylor"
	end
	if danger == nil then 
		danger = 1
	end
	enemyStrength = math.max(danger * difficulty * playerPower(),5)
	enemyPosition = 0
	sp = irandom(300,500)			--random spacing of spawned group
	deployConfig = random(1,100)	--randomly choose between squarish formation and hexagonish formation
	enemyList = {}
	-- Reminder: stsl and stnl are ship template score and name list
	while enemyStrength > 0 do
		shipTemplateType = irandom(1,#stsl)
		while stsl[shipTemplateType] > enemyStrength * 1.1 + 5 do
			shipTemplateType = irandom(1,#stsl)
		end		
		ship = CpuShip():setFaction(enemyFaction):setTemplate(stnl[shipTemplateType]):orderRoaming()
		enemyPosition = enemyPosition + 1
		if deployConfig < 50 then
			ship:setPosition(xOrigin+fleetPosDelta1x[enemyPosition]*sp,yOrigin+fleetPosDelta1y[enemyPosition]*sp)
		else
			ship:setPosition(xOrigin+fleetPosDelta2x[enemyPosition]*sp,yOrigin+fleetPosDelta2y[enemyPosition]*sp)
		end
		table.insert(enemyList, ship)
		enemyStrength = enemyStrength - stsl[shipTemplateType]
	end
	return enemyList
end
function playerPower()
	--evaluate the players for enemy strength and size spawning purposes
	playerShipScore = 0
	for p5idx=1,12 do
		p5obj = getPlayerShip(p5idx)
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

-----------------------------------
--	Different terrain functions  --
-----------------------------------
function emptyTerrain()
	-- there is no terrain except for the center 'Zebra Station'
	dynamicTerrain = nil
end
--  Default terrain: Asymetric. Creation order: friendlies, planet, neutrals, black hole, generic enemies, leading enemies
function defaultTerrain()
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
	sPool = #placeStation		--starting station pool size (friendly and neutral)
	adjList = {}				--adjacent space on grid location list
	grid[gx][gy] = gp
	grid[gx][gy+1] = gp
	grid[gx][gy-1] = gp
	grid[gx+1][gy] = gp
	grid[gx-1][gy] = gp
	grid[gx+1][gy+1] = gp
	grid[gx+1][gy-1] = gp
	grid[gx-1][gy+1] = gp
	grid[gx-1][gy-1] = gp
	adjList = getAdjacentGridLocations(gx,gy)
	gp = 2
	rn = math.random(1,#adjList)
	gx = adjList[rn][1]
	gy = adjList[rn][2]
	neutralZoneDistance = 3000
	--place stations
	for j=1,40 do
		tSize = math.random(2,5)		--tack on region size
		grid[gy][gy] = gp				--set current grid location to grid position list index
		gRegion = {}					--grow region
		table.insert(gRegion,{gx,gy})	--store current coordinates in grow region
		for i=1,tSize do
			adjList = getAdjacentGridLocations(gx,gy)
			if #adjList < 1 then		--exit loop if no more adjacent spaces
				break
			end
			rd = math.random(1,#adjList)	--random direction in which to grow
			grid[adjList[rd][1]][adjList[rd][2]] = gp
			table.insert(gRegion,{adjList[rd][1],adjList[rd][2]})
		end
		--get adjacent list after done growing region
		adjList = getAdjacentGridLocations(gx,gy)
		if #adjList < 1 then
			adjList = getAllAdjacentGridLocations(gx,gy)
		else
			if random(1,5) >= 2 then
				adjList = getAllAdjacentGridLocations(gx,gy)
			end
		end
		sri = math.random(1,#gRegion)				--select station random region index
		psx = (gRegion[sri][1] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station x coordinate
		psy = (gRegion[sri][2] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station y coordinate
		if psx < -1*neutralZoneDistance then		--left stations
			stationFaction = "Human Navy"			--human
		elseif psx > neutralZoneDistance then		--right stations
			stationFaction = "Kraylor"				--kraylor
		else										--near the middle
			stationFaction = "Independent"			--independent
		end
		if stationFaction == "Independent" and random(1,5) >= 20 and #placeGenericStation > 1 then
			si = math.random(1,#placeGenericStation)	--station index
			pStation = placeGenericStation[si]()		--place selected station
			table.remove(placeGenericStation,si)		--remove station from placement list
		else
			si = math.random(1,#placeStation)			--station index		
			pStation = placeStation[si]()				--place selected station
			table.remove(placeStation,si)				--remove station from placement list
		end
		table.insert(terrain_objects,pStation)
		if psx < -1*neutralZoneDistance then
			table.insert(humanStationList,pStation)
		elseif psx > neutralZoneDistance then
			table.insert(kraylorStationList,pStation)
		else
			table.insert(neutralStationList,pStation)
		end
		gp = gp + 1
		rn = math.random(1,#adjList)	--random next station start location
		gx = adjList[rn][1]
		gy = adjList[rn][2]
	end
	if not diagnostic then
		local nebula_list = placeRandomAroundPointList(Nebula,math.random(10,30),1,150000,0,0)
		for _, nebula in ipairs(nebula_list) do
			table.insert(terrain_objects,nebula)
		end
		local tn = Nebula():setPosition(0,0)
		table.insert(terrain_objects,tn)
		for i=9000,boundary,9000 do	--nebula dividing line
			tn = Nebula():setPosition(0,i)
			table.insert(terrain_objects,tn)
			tn = Nebula():setPosition(0,-1*i)
			table.insert(terrain_objects,tn)
		end
		dynamicTerrain = moveDefaultTerrain
		nebLine0h = Nebula():setPosition(0,0)	--nebula line zero human
		table.insert(terrain_objects,nebLine0h)
		nebLine0k = Nebula():setPosition(0,0)	--nebula line zero kraylor
		table.insert(terrain_objects,nebLine0k)
		nebLine0Travel = random(5,20)			--nebula line zero travel distance per update
		nebLine0Direction = "out"				--nebula line zero direction of travel
	end
end
function moveDefaultTerrain(delta)
	nx, ny = nebLine0h:getPosition()
	if nebLine0Direction == "out" then		--out from center?
		if nx < -1*boundary then			--beyond boundary?
			nebLine0Direction = "in"		--change direction to in
			nebLine0Travel = random(5,20)	--randomize travel speed
		else								--within boundary, normal out movement
			nebLine0h:setPosition(nx - nebLine0Travel,ny)
		end
	else									--in from edge
		if nx > 0 then						--beyond boundary?
			nebLine0Direction = "out"		--change direction to out
			nebLine0Travel = random(5,20)	--randomize travel speed
		else								--within boundary, normal in movement
			nebLine0h:setPosition(nx + nebLine0Travel, ny)
		end
	end
	nx, ny = nebLine0k:getPosition()		--other nebula mirrors movement
	if nebLine0Direction == "out" then
		nebLine0k:setPosition(nx + nebLine0Travel, ny)
	else
		nebLine0k:setPosition(nx - nebLine0Travel, ny)
	end
	if nebLine20hPos == nil then			--built second set of nebulae yet?
		tnx, tny = nebLine0k:getPosition()	--get trigger nebula position
		if tnx > 20000 then					--trigger beyond 20k mark?
			nebLine20hPos = Nebula():setPosition(0,20000)	--nebula line 20 human positive
			nebLine20hNeg = Nebula():setPosition(0,-20000)	--nebula line 20 human negative
			nebLine20kPos = Nebula():setPosition(0,20000)	--nebula line 20 kraylor positive
			nebLine20kNeg = Nebula():setPosition(0,-20000)	--nebula line 20 kraylor negative
			nebLine20Travel = random(7,25)					--nebula line 20 travel distance
			nebLine20Direction = "out"						--nebula line 20 direction of travel
		end
	else									--second set of nebulae built
		nx, ny = nebLine20hPos:getPosition()	
		if nebLine20Direction == "out" then		--out from center?
			if nx < -1*boundary then			--beyond boundary?
				nebLine20Direction = "in"		--change direction to in
				nebLine20Travel = random(7,25)	--randomize travel speed
			else								--within boundary, normal out movement
				nebLine20hPos:setPosition(nx - nebLine20Travel, ny)
			end
		else									--in from edge
			if nx > 0 then						--beyond boundary?
				nebLine20Direction = "out"		--change direction to out
				nebLine20Travel = random(7,25)	--randomize travel speed
			else								--within boundary, normal in movement
				nebLine20hPos:setPosition(nx + nebLine20Travel, ny)
			end
		end
		if nebLine20Direction == "out" then		--other nebulae mirror movement
			nx, ny = nebLine20hNeg:getPosition()
			nebLine20hNeg:setPosition(nx - nebLine20Travel, ny)
			nx, ny = nebLine20kPos:getPosition()
			nebLine20kPos:setPosition(nx + nebLine20Travel, ny)
			nx, ny = nebLine20kNeg:getPosition()
			nebLine20kNeg:setPosition(nx + nebLine20Travel, ny)
		else
			nx, ny = nebLine20hNeg:getPosition()
			nebLine20hNeg:setPosition(nx + nebLine20Travel, ny)
			nx, ny = nebLine20kPos:getPosition()
			nebLine20kPos:setPosition(nx - nebLine20Travel, ny)
			nx, ny = nebLine20kNeg:getPosition()
			nebLine20kNeg:setPosition(nx - nebLine20Travel, ny)
		end
	end
	if nebLine40hPos == nil then	--third set built?
		tnx, tny = nebLine0k:getPosition()
		if tnx > 40000 then
			nebLine40hPos = Nebula():setPosition(0,40000)
			nebLine40hNeg = Nebula():setPosition(0,-40000)
			nebLine40kPos = Nebula():setPosition(0,40000)
			nebLine40kNeg = Nebula():setPosition(0,-40000)
			nebLine40Travel = random(10,30)
			nebLine40Direction = "out"
		end
	else
		nx, ny = nebLine40hPos:getPosition()
		if nebLine40Direction == "out" then
			if nx < -1*boundary then
				nebLine40Direction = "in"
				nebLine40Travel = random(10,30)
			else
				nebLine40hPos:setPosition(nx - nebLine40Travel, ny)
			end
		else
			if nx > 0 then
				nebLine40Direction = "out"
				nebLine40Travel = random(10,30)
			else
				nebLine40hPos:setPosition(nx + nebLine40Travel, ny)
			end
		end
		if nebLine40Direction == "out" then
			nx, ny = nebLine40hNeg:getPosition()
			nebLine40hNeg:setPosition(nx - nebLine40Travel, ny)
			nx, ny = nebLine40kPos:getPosition()
			nebLine40kPos:setPosition(nx + nebLine40Travel, ny)
			nx, ny = nebLine40kNeg:getPosition()
			nebLine40kNeg:setPosition(nx + nebLine40Travel, ny)
		else
			nx, ny = nebLine40hNeg:getPosition()
			nebLine40hNeg:setPosition(nx + nebLine40Travel, ny)
			nx, ny = nebLine40kPos:getPosition()
			nebLine40kPos:setPosition(nx - nebLine40Travel, ny)
			nx, ny = nebLine40kNeg:getPosition()
			nebLine40kNeg:setPosition(nx - nebLine40Travel, ny)
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
function szt()
	--Randomly choose station size template
	if stationSize ~= nil then
		return stationSize
	end
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
--	Random symmetric terrain
function mirrorKrikAsteroids()
	local ax = nil
	local ay = nil
	for _, obj in ipairs(krikList1) do
		ax, ay = obj:getPosition()
		table.insert(terrain_objects,Asteroid():setPosition(-ax,-ay))
	end
	for _, obj in ipairs(krikList2) do
		ax, ay = obj:getPosition()
		table.insert(terrain_objects,Asteroid():setPosition(-ax,-ay))
	end
	mirrorKrik = false
end
function mirrorAsteroids()
	for _, obj in ipairs(mirror_station.asteroid_list) do
		local ax, ay = obj:getPosition()
		table.insert(terrain_objects,Asteroid():setPosition(-ax,-ay))
	end
	mirror_asteroids = false
end
function randomSymmetric()
	local mirror_asteroids = false
	psx, psy = vectorFromAngle(random(135,225),4000)
	stationSize = "Small Station"
	stationFaction = "Human Navy"
	si = math.random(1,#placeGenericStation)
	pStation = placeGenericStation[si]()
	table.insert(terrain_objects,pStation)
	table.remove(placeGenericStation,si)
	table.insert(stationList,pStation)
	table.insert(humanStationList,pStation)
	local station_name = pStation:getCallSign()
	if pStation.asteroid_list ~= nil then
		mirror_station = pStation
	else
		mirror_station = nil
	end
	psx = -psx
	psy = -psy
	stationFaction = "Kraylor"
	si = math.random(1,#placeGenericStation)
	pStation = placeGenericStation[si]()
	table.insert(terrain_objects,pStation)
	table.remove(placeGenericStation,si)
	table.insert(stationList,pStation)
	table.insert(kraylorStationList,pStation)
	if mirror_station ~= nil then
		mirrorAsteroids()
		mirror_station = nil
	end
	if pStation.asteroid_list ~= nil then
		mirror_station = pStation
	else
		mirror_station = nil
	end
	for spi=1,9 do
		repeat
			rx, ry = stationList[math.random(1,#stationList)]:getPosition()
			vx, vy = vectorFromAngle(random(0,360),random(5000,50000))
			psx = rx+vx
			psy = ry+vy
			closestStationDistance = 999999
			for si=1,#stationList do
				curDist = distance(stationList[si],psx,psy)
				if curDist < closestStationDistance then
					closestStationDistance = curDist
				end
			end
		until(psx < 0 and closestStationDistance > 4000)
		stationSize = nil
		if psx > -1000 then
			stationFaction = "Independent"
		else
			stationFaction = "Human Navy"
		end
		si = math.random(1,#placeGenericStation)
		pStation = placeGenericStation[si]()
		table.insert(terrain_objects,pStation)
		table.remove(placeGenericStation,si)
		table.insert(stationList,pStation)
		if stationFaction == "Human Navy" then
			table.insert(humanStationList,pStation)
		end
		if mirror_station ~= nil then
			mirrorAsteroids()
			mirror_station = nil
		end
		if pStation.asteroid_list ~= nil then
			mirror_station = pStation
		else
			mirror_station = nil
		end
		stationSize = sizeTemplate
		psx = -psx
		psy = -psy
		if stationFaction ~= "Independent" then
			stationFaction = "Kraylor"
		end
		si = math.random(1,#placeGenericStation)
		pStation = placeGenericStation[si]()
		table.insert(terrain_objects,pStation)
		table.remove(placeGenericStation,si)
		table.insert(stationList,pStation)
		if stationFaction == "Kraylor" then
			table.insert(kraylorStationList,pStation)
		end
		if mirror_station ~= nil then
			mirrorAsteroids()
			mirror_station = nil
		end
		if pStation.asteroid_list ~= nil then
			mirror_station = pStation
		else
			mirror_station = nil
		end
	end
	if mirror_station ~= nil then
		mirrorAsteroids()
		mirror_station = nil
	end
	if not diagnostic then
		nebList = placeRandomAroundPointList(Nebula,math.random(5,15),1,150000,0,0)
		for _, obj in ipairs(nebList) do
			table.insert(terrain_objects,obj)
			nx, ny = obj:getPosition()
			table.insert(terrain_objects,Nebula():setPosition(-nx,-ny))
		end
		table.insert(terrain_objects,Nebula():setPosition(0,0))
		for i=9000,boundary,9000 do	--nebula dividing line
			table.insert(terrain_objects,Nebula():setPosition(0,i))
			table.insert(terrain_objects,Nebula():setPosition(0,-1*i))
		end
		dynamicTerrain = moveDefaultTerrain		-- THIS IS VERY IMPORTANT SO THE SCRIPT CALLS THE CORRECT ROUTINE TO MOVE ENVIRONMENT OBJECTS
		nebLine0h = Nebula():setPosition(0,0)	--nebula line zero human
		table.insert(terrain_objects,nebLine0h)
		nebLine0k = Nebula():setPosition(0,0)	--nebula line zero kraylor
		table.insert(terrain_objects,nebLine0k)
		nebLine0Travel = random(5,20)			--nebula line zero travel distance per update
		nebLine0Direction = "out"				--nebula line zero direction of travel
	end
end
--	Just passing by terrain
function justPassingBy()
	dynamicTerrain = moveJustPassingBy
	-- this environment design places a black hole to the rear of each startup area and has large bands of nebula and some asteroids orbiting the black holes in opposite directions
	-- NOTE that whereas the initial placement of the left and right black holes are made through variables, the subsequent movement updates of all bodies are done via
	-- finding the location of the blackhole; this is done so that it is possible to move the black hole and thus cause the entire orbital system around the blackhole
	-- to move with it, should that variation be used within the script
	
	-- first build the left side
		left_bh_x_coord = -100000
		left_bh_y_coord = 60000
		left_blackhole = BlackHole():setPosition(left_bh_x_coord, left_bh_y_coord)
		table.insert(terrain_objects,left_blackhole)

		-- there will be 3 bands of orbiting stuff:  inner nebula moving quickest, middle asteroids with maybe a planet moving slower, outer nebula moving slowest
		-- the inner band will be clumps of nebula orbiting clockwise (orbit rate is set by variable, but initially 1 orbit in 2min)
			left_blackhole_inner_band = {}
			-- each band will be a nested table (multi-dimensional array)
			  -- 1st position on the inner array will be the nebula object
			  -- 2nd position on the inner array will be the current angle of the nebula in relation to the blackhole center
			  -- there is no need to keep track of the speed in this case as it is uniform for all nebula in this band
			left_bh_inner_band_radius = 40000
			left_bh_inner_band_orbit_speed = 360/(60 * 120) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 120 seconds; uniform for all nebula
			-- because in this design we want the nebula more "clumpy" with gaps inbetween the clumps, there will be 4 clumps of nebula, one starting in each quadrant, centered on the 45 
			-- degree angle of that quadrant, spanning a variable degree of arc; make the number of nebula in each clump a variable so we can easily modify how thick each clump will be
			left_bh_inner_band_clump_density = 8  -- the number of nebula in a clump
			left_bh_inner_band_clump_spread = 40  -- the number of degrees of arc for the clump spread of the quandrant bisecting angle
			local array_index = 1
			-- first clump
				begin_spread_angle = 45 - (left_bh_inner_band_clump_spread/2)
				spread_angle_end = 45 + (left_bh_inner_band_clump_spread/2)
				for i=1,left_bh_inner_band_clump_density do
					left_blackhole_inner_band[array_index] = {}
					left_blackhole_inner_band[array_index][1] = Nebula()
					table.insert(terrain_objects,left_blackhole_inner_band[array_index][1])
					left_blackhole_inner_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(left_blackhole_inner_band[array_index][1], left_bh_x_coord, left_bh_y_coord, left_blackhole_inner_band[array_index][2], left_bh_inner_band_radius)
					array_index = array_index + 1
				end
			-- second clump
				begin_spread_angle = 135 - (left_bh_inner_band_clump_spread/2)
				spread_angle_end = 135 + (left_bh_inner_band_clump_spread/2)
				for i=1,left_bh_inner_band_clump_density do
					left_blackhole_inner_band[array_index] = {}
					left_blackhole_inner_band[array_index][1] = Nebula()
					table.insert(terrain_objects,left_blackhole_inner_band[array_index][1])
					left_blackhole_inner_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(left_blackhole_inner_band[array_index][1], left_bh_x_coord, left_bh_y_coord, left_blackhole_inner_band[array_index][2], left_bh_inner_band_radius)
					array_index = array_index + 1
				end
			-- third clump
				begin_spread_angle = 225 - (left_bh_inner_band_clump_spread/2)
				spread_angle_end = 225 + (left_bh_inner_band_clump_spread/2)
				for i=1,left_bh_inner_band_clump_density do
					left_blackhole_inner_band[array_index] = {}
					left_blackhole_inner_band[array_index][1] = Nebula()
					table.insert(terrain_objects,left_blackhole_inner_band[array_index][1])
					left_blackhole_inner_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(left_blackhole_inner_band[array_index][1], left_bh_x_coord, left_bh_y_coord, left_blackhole_inner_band[array_index][2], left_bh_inner_band_radius)
					array_index = array_index + 1
				end
			-- fourth clump
				begin_spread_angle = 315 - (left_bh_inner_band_clump_spread/2)
				spread_angle_end = 315 + (left_bh_inner_band_clump_spread/2)
				for i=1,left_bh_inner_band_clump_density do
					left_blackhole_inner_band[array_index] = {}
					left_blackhole_inner_band[array_index][1] = Nebula()
					table.insert(terrain_objects,left_blackhole_inner_band[array_index][1])
					left_blackhole_inner_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(left_blackhole_inner_band[array_index][1], left_bh_x_coord, left_bh_y_coord, left_blackhole_inner_band[array_index][2], left_bh_inner_band_radius)
					array_index = array_index + 1
				end

		-- the middle band will be a random number of asteroids orbiting counter-clockwise at a randomly determined rate
			left_blackhole_middle_band = {}
			left_bh_middle_band_min_radius = 55000
			left_bh_middle_band_max_radius = 65000
			
			-- the middle band will not have clumps like the first and will just have a random placement of asteroids within the allowable band range, all with randomly set speeds 
			left_bh_mimdle_band_number_of_asteroids = 100
			left_bh_middle_band_min_orbit_speed = 360/(60 * 240) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 240 seconds
			left_bh_middle_band_max_orbit_speed = 360/(60 * 150) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 150 seconds
			
			for i=1,left_bh_mimdle_band_number_of_asteroids do
				-- each band will be a nested table (multi-dimensional array)
				  -- 1st position on the inner array will be the asteroid object
				  -- 2nd position on the inner array will be the radius distance from the blackhole center, randomly generated in a band range
				  -- 3rd position on the inner array will be the current angle of the asteroid in relation to the blackhole center
				  -- 4th position on the inner array will be the orbital speed of the asteroid, expressed as a delta of angle change per update cycle, randomly generated
				left_blackhole_middle_band[i]= {}
				left_blackhole_middle_band[i][1] = Asteroid() 
				table.insert(terrain_objects,left_blackhole_middle_band[i][1])
				left_blackhole_middle_band[i][2] = math.random(left_bh_middle_band_min_radius, left_bh_middle_band_max_radius)
				left_blackhole_middle_band[i][3] = math.random(1, 360)
				left_blackhole_middle_band[i][4] = random(left_bh_middle_band_min_orbit_speed, left_bh_middle_band_max_orbit_speed)
				-- setCirclePos(obj, x, y, angle, distance)
				  --   obj: An object.
				  --   x, y: Origin coordinates.
				  --   angle, distance: Relative heading and distance from the origin.
				setCirclePos(left_blackhole_middle_band[i][1], left_bh_x_coord, left_bh_y_coord, left_blackhole_middle_band[i][3], left_blackhole_middle_band[i][2])
			end
			
		-- the outer band will be clumps of nebula orbiting clockwise (orbit rate is set by variable, but initially 1 orbit in 8min)
			left_blackhole_outer_band = {}
			-- each band will be a nested table (multi-dimensional array)
			  -- 1st position on the inner array will be the nebula object
			  -- 2nd position on the inner array will be the current angle of the nebula in relation to the blackhole center
			  -- there is no need to keep track of the speed in this case as it is uniform for all nebula in this band
			left_bh_outer_band_radius = 80000
			left_bh_outer_band_orbit_speed = 360/(60 * 360) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 480 seconds; uniform for all nebula
			-- because in this design we want the nebula more "clumpy" with gaps inbetween the clumps, there will be 4 clumps of nebula, one starting in each quadrant, centered on the 45 
			-- degree angle of that quadrant, spanning a variable degree of arc; make the number of nebula in each clump a variable so we can easily modify how thick each clump will be
			left_bh_outer_band_clump_density = 10  -- the number of nebula in a clump
			left_bh_outer_band_clump_spread = 60  -- the number of degrees of arc for the clump spread of the quandrant bisecting angle
			local array_index = 1
			-- first clump
				begin_spread_angle = 45 - (left_bh_outer_band_clump_spread/2)
				spread_angle_end = 45 + (left_bh_outer_band_clump_spread/2)
				for i=1,left_bh_outer_band_clump_density do
					left_blackhole_outer_band[array_index] = {}
					left_blackhole_outer_band[array_index][1] = Nebula()
					table.insert(terrain_objects,left_blackhole_outer_band[array_index][1])
					left_blackhole_outer_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(left_blackhole_outer_band[array_index][1], left_bh_x_coord, left_bh_y_coord, left_blackhole_outer_band[array_index][2], left_bh_outer_band_radius)
					array_index = array_index + 1
				end
			-- second clump
				begin_spread_angle = 135 - (left_bh_outer_band_clump_spread/2)
				spread_angle_end = 135 + (left_bh_outer_band_clump_spread/2)
				for i=1,left_bh_outer_band_clump_density do
					left_blackhole_outer_band[array_index] = {}
					left_blackhole_outer_band[array_index][1] = Nebula()
					table.insert(terrain_objects,left_blackhole_outer_band[array_index][1])
					left_blackhole_outer_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(left_blackhole_outer_band[array_index][1], left_bh_x_coord, left_bh_y_coord, left_blackhole_outer_band[array_index][2], left_bh_outer_band_radius)
					array_index = array_index + 1
				end
			-- third clump
				begin_spread_angle = 225 - (left_bh_outer_band_clump_spread/2)
				spread_angle_end = 225 + (left_bh_outer_band_clump_spread/2)
				for i=1,left_bh_inner_band_clump_density do
					left_blackhole_outer_band[array_index] = {}
					left_blackhole_outer_band[array_index][1] = Nebula()
					table.insert(terrain_objects,left_blackhole_outer_band[array_index][1])
					left_blackhole_outer_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(left_blackhole_outer_band[array_index][1], left_bh_x_coord, left_bh_y_coord, left_blackhole_outer_band[array_index][2], left_bh_outer_band_radius)
					array_index = array_index + 1
				end
			-- fourth clump
				begin_spread_angle = 315 - (left_bh_outer_band_clump_spread/2)
				spread_angle_end = 315 + (left_bh_outer_band_clump_spread/2)
				for i=1,left_bh_outer_band_clump_density do
					left_blackhole_outer_band[array_index] = {}
					left_blackhole_outer_band[array_index][1] = Nebula()
					table.insert(terrain_objects,left_blackhole_outer_band[array_index][1])
					left_blackhole_outer_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(left_blackhole_outer_band[array_index][1], left_bh_x_coord, left_bh_y_coord, left_blackhole_outer_band[array_index][2], left_bh_outer_band_radius)
					array_index = array_index + 1
				end			

	-- second build the right side (essentially a duplicate of the left side set up diametrically opposed position)
	-- note that if you change an establishing variable in the left side, you'll need to make the same change for the right side if you want to keep them balanced
		right_bh_x_coord = 100000
		right_bh_y_coord = -60000
		right_blackhole = BlackHole():setPosition(right_bh_x_coord, right_bh_y_coord)
		table.insert(terrain_objects,right_blackhole)

		-- there will be 3 bands of orbiting stuff:  inner nebula moving quickest, middle asteroids with maybe a planet moving slower, outer nebula moving slowest
		-- the inner band will be clumps of nebula orbiting clockwise (orbit rate is set by variable, but initially 1 orbit in 2min)
			right_blackhole_inner_band = {}
			-- each band will be a nested table (multi-dimensional array)
			  -- 1st position on the inner array will be the nebula object
			  -- 2nd position on the inner array will be the current angle of the nebula in relation to the blackhole center
			  -- there is no need to keep track of the speed in this case as it is uniform for all nebula in this band
			right_bh_inner_band_radius = 40000
			right_bh_inner_band_orbit_speed = 360/(60 * 120) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 120 seconds; uniform for all nebula
			-- because in this design we want the nebula more "clumpy" with gaps inbetween the clumps, there will be 4 clumps of nebula, one starting in each quadrant, centered on the 45 
			-- degree angle of that quadrant, spanning a variable degree of arc; make the number of nebula in each clump a variable so we can easily modify how thick each clump will be
			right_bh_inner_band_clump_density = 8  -- the number of nebula in a clump
			right_bh_inner_band_clump_spread = 40  -- the number of degrees of arc for the clump spread of the quandrant bisecting angle
			local array_index = 1
			-- first clump
				begin_spread_angle = 45 - (right_bh_inner_band_clump_spread/2)
				spread_angle_end = 45 + (right_bh_inner_band_clump_spread/2)
				for i=1,right_bh_inner_band_clump_density do
					right_blackhole_inner_band[array_index] = {}
					right_blackhole_inner_band[array_index][1] = Nebula()
					table.insert(terrain_objects,right_blackhole_inner_band[array_index][1])
					right_blackhole_inner_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(right_blackhole_inner_band[array_index][1], right_bh_x_coord, right_bh_y_coord, right_blackhole_inner_band[array_index][2], right_bh_inner_band_radius)
					array_index = array_index + 1
				end
			-- second clump
				begin_spread_angle = 135 - (right_bh_inner_band_clump_spread/2)
				spread_angle_end = 135 + (right_bh_inner_band_clump_spread/2)
				for i=1,right_bh_inner_band_clump_density do
					right_blackhole_inner_band[array_index] = {}
					right_blackhole_inner_band[array_index][1] = Nebula()
					table.insert(terrain_objects,right_blackhole_inner_band[array_index][1])
					right_blackhole_inner_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(right_blackhole_inner_band[array_index][1], right_bh_x_coord, right_bh_y_coord, right_blackhole_inner_band[array_index][2], right_bh_inner_band_radius)
					array_index = array_index + 1
				end
			-- third clump
				begin_spread_angle = 225 - (right_bh_inner_band_clump_spread/2)
				spread_angle_end = 225 + (right_bh_inner_band_clump_spread/2)
				for i=1,right_bh_inner_band_clump_density do
					right_blackhole_inner_band[array_index] = {}
					right_blackhole_inner_band[array_index][1] = Nebula()
					table.insert(terrain_objects,right_blackhole_inner_band[array_index][1])
					right_blackhole_inner_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(right_blackhole_inner_band[array_index][1], right_bh_x_coord, right_bh_y_coord, right_blackhole_inner_band[array_index][2], right_bh_inner_band_radius)
					array_index = array_index + 1
				end
			-- fourth clump
				begin_spread_angle = 315 - (right_bh_inner_band_clump_spread/2)
				spread_angle_end = 315 + (right_bh_inner_band_clump_spread/2)
				for i=1,right_bh_inner_band_clump_density do
					right_blackhole_inner_band[array_index] = {}
					right_blackhole_inner_band[array_index][1] = Nebula()
					table.insert(terrain_objects,right_blackhole_inner_band[array_index][1])
					right_blackhole_inner_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(right_blackhole_inner_band[array_index][1], right_bh_x_coord, right_bh_y_coord, right_blackhole_inner_band[array_index][2], right_bh_inner_band_radius)
					array_index = array_index + 1
				end

		-- the middle band will be a random number of asteroids orbiting counter-clockwise at a randomly determined rate
			right_blackhole_middle_band = {}
			right_bh_middle_band_min_radius = 55000
			right_bh_middle_band_max_radius = 65000
			
			-- the middle band will not have clumps like the first and will just have a random placement of asteroids within the allowable band range, all with randomly set speeds 
			right_bh_mimdle_band_number_of_asteroids = 100
			right_bh_middle_band_min_orbit_speed = 360/(60 * 240) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 240 seconds
			right_bh_middle_band_max_orbit_speed = 360/(60 * 150) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 150 seconds
			
			for i=1,right_bh_mimdle_band_number_of_asteroids do
				-- each band will be a nested table (multi-dimensional array)
				  -- 1st position on the inner array will be the asteroid object
				  -- 2nd position on the inner array will be the radius distance from the blackhole center, randomly generated in a band range
				  -- 3rd position on the inner array will be the current angle of the asteroid in relation to the blackhole center
				  -- 4th position on the inner array will be the orbital speed of the asteroid, expressed as a delta of angle change per update cycle, randomly generated
				right_blackhole_middle_band[i]= {}
				right_blackhole_middle_band[i][1] = Asteroid() 
				table.insert(terrain_objects,right_blackhole_middle_band[i][1])
				right_blackhole_middle_band[i][2] = math.random(right_bh_middle_band_min_radius, right_bh_middle_band_max_radius)
				right_blackhole_middle_band[i][3] = math.random(1, 360)
				right_blackhole_middle_band[i][4] = random(right_bh_middle_band_min_orbit_speed, right_bh_middle_band_max_orbit_speed)
				-- setCirclePos(obj, x, y, angle, distance)
				  --   obj: An object.
				  --   x, y: Origin coordinates.
				  --   angle, distance: Relative heading and distance from the origin.
				setCirclePos(right_blackhole_middle_band[i][1], right_bh_x_coord, right_bh_y_coord, right_blackhole_middle_band[i][3], right_blackhole_middle_band[i][2])
			end
			
		-- the outer band will be clumps of nebula orbiting clockwise (orbit rate is set by variable, but initially 1 orbit in 8min)
			right_blackhole_outer_band = {}
			-- each band will be a nested table (multi-dimensional array)
			  -- 1st position on the inner array will be the nebula object
			  -- 2nd position on the inner array will be the current angle of the nebula in relation to the blackhole center
			  -- there is no need to keep track of the speed in this case as it is uniform for all nebula in this band
			right_bh_outer_band_radius = 80000
			right_bh_outer_band_orbit_speed = 360/(60 * 360) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 360 seconds; uniform for all nebula
			-- because in this design we want the nebula more "clumpy" with gaps inbetween the clumps, there will be 4 clumps of nebula, one starting in each quadrant, centered on the 45 
			-- degree angle of that quadrant, spanning a variable degree of arc; make the number of nebula in each clump a variable so we can easily modify how thick each clump will be
			right_bh_outer_band_clump_density = 10  -- the number of nebula in a clump
			right_bh_outer_band_clump_spread = 60  -- the number of degrees of arc for the clump spread of the quandrant bisecting angle
			local array_index = 1
			-- first clump
				begin_spread_angle = 45 - (right_bh_outer_band_clump_spread/2)
				spread_angle_end = 45 + (right_bh_outer_band_clump_spread/2)
				for i=1,right_bh_outer_band_clump_density do
					right_blackhole_outer_band[array_index] = {}
					right_blackhole_outer_band[array_index][1] = Nebula()
					table.insert(terrain_objects,right_blackhole_outer_band[array_index][1])
					right_blackhole_outer_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(right_blackhole_outer_band[array_index][1], right_bh_x_coord, right_bh_y_coord, right_blackhole_outer_band[array_index][2], right_bh_outer_band_radius)
					array_index = array_index + 1
				end
			-- second clump
				begin_spread_angle = 135 - (right_bh_outer_band_clump_spread/2)
				spread_angle_end = 135 + (right_bh_outer_band_clump_spread/2)
				for i=1,right_bh_outer_band_clump_density do
					right_blackhole_outer_band[array_index] = {}
					right_blackhole_outer_band[array_index][1] = Nebula()
					table.insert(terrain_objects,right_blackhole_outer_band[array_index][1])
					right_blackhole_outer_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(right_blackhole_outer_band[array_index][1], right_bh_x_coord, right_bh_y_coord, right_blackhole_outer_band[array_index][2], right_bh_outer_band_radius)
					array_index = array_index + 1
				end
			-- third clump
				begin_spread_angle = 225 - (right_bh_outer_band_clump_spread/2)
				spread_angle_end = 225 + (right_bh_outer_band_clump_spread/2)
				for i=1,right_bh_inner_band_clump_density do
					right_blackhole_outer_band[array_index] = {}
					right_blackhole_outer_band[array_index][1] = Nebula()
					table.insert(terrain_objects,right_blackhole_outer_band[array_index][1])
					right_blackhole_outer_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(right_blackhole_outer_band[array_index][1], right_bh_x_coord, right_bh_y_coord, right_blackhole_outer_band[array_index][2], right_bh_outer_band_radius)
					array_index = array_index + 1
				end
			-- fourth clump
				begin_spread_angle = 315 - (right_bh_outer_band_clump_spread/2)
				spread_angle_end = 315 + (right_bh_outer_band_clump_spread/2)
				for i=1,right_bh_outer_band_clump_density do
					right_blackhole_outer_band[array_index] = {}
					right_blackhole_outer_band[array_index][1] = Nebula()
					table.insert(terrain_objects,right_blackhole_outer_band[array_index][1])
					right_blackhole_outer_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(right_blackhole_outer_band[array_index][1], right_bh_x_coord, right_bh_y_coord, right_blackhole_outer_band[array_index][2], right_bh_outer_band_radius)
					array_index = array_index + 1
				end	
				
	-- if desired, the blackholes can orbit the entire playing area by using the center as the origin
	-- note that in order to do this, the blackholes need to be equidistant from the origin along the x axis; 
	-- this routine will auto set the right blackhole x value to be opposite of the left blackhole x value
	-- take care that the black holes are not going to sweep through the initial boundary area, thereby sucking up stations or flags!
	
		-- set the radius
		orbital_radius = left_bh_x_coord * -1
		-- set the initial angles of the blackholes relative to the origin
		left_bh_angle_to_origin = 180
		right_bh_angle_to_origin = 0
		-- set the blackhole orbital velocity to complete 1 full orbit in ... 
		-- orbital_velocity = 0.003  -- the complete game time of 30 mins ?
		-- orbital_velocity = 0.006  -- 15 mins ?
		-- orbital_velocity = 0.009  -- 10 mins ?
		-- orbital_velocity = 0.03  -- 3 mins ?
		orbital_velocity = 0.3  -- 3 mins ?

	orbital_movement = false
	blackhole_movement = false

	addGMFunction("Orbit Toggle", 
		function()
			if orbital_movement then
				orbital_movement = false
			else
				orbital_movement = true
			end				
		end
	)

	addGMFunction("Move Toggle", 
		function()
			if blackhole_movement then
				blackhole_movement = false
			else
				blackhole_movement = true
			end				
		end
	)
	
end	--justPassingBy
function moveJustPassingBy(delta)

	-- if desired, the blackholes can orbit the entire playing area by using the center as the origin
	-- use this section if you want to do this, comment out if you don't
	-- note that once underway, 'left' and 'right' refer to the original configurations as their positions will change (duh....)
		--[[
		-- update the angular positions around the origin and adjust for 360
		left_bh_angle_to_origin = left_bh_angle_to_origin + orbital_velocity
		if left_bh_angle_to_origin > 360 then
			left_bh_angle_to_origin = left_bh_angle_to_origin - 360
		end
		right_bh_angle_to_origin = right_bh_angle_to_origin + orbital_velocity
		if right_bh_angle_to_origin > 360 then
			right_bh_angle_to_origin = right_bh_angle_to_origin - 360
		end
		
		-- set the new blackhole positions before updating all their orbiting bodies
		-- setCirclePos(obj, x, y, angle, distance)
			--   obj: An object.
			--   x, y: Origin coordinates.
			--   angle, distance: Relative heading and distance from the origin.
		setCirclePos(left_blackhole, 0, 0, left_bh_angle_to_origin, orbital_radius)
		setCirclePos(right_blackhole, 0, 0, right_bh_angle_to_origin, orbital_radius)
		--]]

	-- first do the left side
		left_bh_center_x, left_bh_center_y = left_blackhole:getPosition()
		-- if desired, move the left blackhole linearly to the right little by little.... 
		-- a rate of x = +/- 5 seems to move the bh 20U in 1.5 min, a rate of +/- 2.5 will move the entire 200U distance in about 30 min (i.e., full game time)
		if blackhole_movement then
			left_blackhole:setPosition(left_bh_center_x + 2.5, left_bh_center_y)
		end
			
		if orbital_movement then
			for i,nebula_table in ipairs(left_blackhole_inner_band) do
				--increment the angle according to the predetermined velocity (change in arc per cycle)
				nebula_table[2] = nebula_table[2] + left_bh_inner_band_orbit_speed
				if nebula_table[2] > 360 then
					nebula_table[2] = nebula_table[2] - 360
				end
				setCirclePos(nebula_table[1], left_bh_center_x, left_bh_center_y, nebula_table[2], left_bh_inner_band_radius)
			end

			for i,asteroid_table in ipairs(left_blackhole_middle_band) do
				-- DEcrement the angle (go counter-clockwise) according to the previously randomized velocity in the table (change in arc per cycle)
				asteroid_table[3] = asteroid_table[3] - asteroid_table[4]
				if asteroid_table[3] < 0 then
					asteroid_table[3] = asteroid_table[3] + 360
				end
				setCirclePos(left_blackhole_middle_band[i][1], left_bh_center_x, left_bh_center_y, left_blackhole_middle_band[i][3], left_blackhole_middle_band[i][2])
			end

			for i,nebula_table in ipairs(left_blackhole_outer_band) do
				--increment the angle according to the predetermined velocity (change in arc per cycle)
				nebula_table[2] = nebula_table[2] + left_bh_outer_band_orbit_speed
				if nebula_table[2] > 360 then
					nebula_table[2] = nebula_table[2] - 360
				end
				setCirclePos(nebula_table[1], left_bh_center_x, left_bh_center_y, nebula_table[2], left_bh_outer_band_radius)
			end
		end

	-- second do the right side
		right_bh_center_x, right_bh_center_y = right_blackhole:getPosition()
		-- if desired, move the right blackhole to the right little by little.... 
		-- a rate of x = +/- 5 seems to move the bh 20U in 1.5 min, a rate of +/- 2.5 will move the entire 200U distance in about 30 min (i.e., full game time)
		if blackhole_movement then
			right_blackhole:setPosition(right_bh_center_x - 2.5, right_bh_center_y)
		end
			
		if orbital_movement then
			for i,nebula_table in ipairs(right_blackhole_inner_band) do
				--increment the angle according to the predetermined velocity (change in arc per cycle)
				nebula_table[2] = nebula_table[2] + right_bh_inner_band_orbit_speed
				if nebula_table[2] > 360 then
					nebula_table[2] = nebula_table[2] - 360
				end
				setCirclePos(nebula_table[1], right_bh_center_x, right_bh_center_y, nebula_table[2], right_bh_inner_band_radius)
			end

			for i,asteroid_table in ipairs(right_blackhole_middle_band) do
				-- DEcrement the angle (go counter-clockwise) according to the previously randomized velocity in the table (change in arc per cycle)
				asteroid_table[3] = asteroid_table[3] - asteroid_table[4]
				if asteroid_table[3] < 0 then
					asteroid_table[3] = asteroid_table[3] + 360
				end
				setCirclePos(right_blackhole_middle_band[i][1], right_bh_center_x, right_bh_center_y, right_blackhole_middle_band[i][3], right_blackhole_middle_band[i][2])
			end

			for i,nebula_table in ipairs(right_blackhole_outer_band) do
				--increment the angle according to the predetermined velocity (change in arc per cycle)
				nebula_table[2] = nebula_table[2] + right_bh_outer_band_orbit_speed
				if nebula_table[2] > 360 then
					nebula_table[2] = nebula_table[2] - 360
				end
				setCirclePos(nebula_table[1], right_bh_center_x, right_bh_center_y, nebula_table[2], right_bh_outer_band_radius)
			end
		end

end	--moveJustPassingBy

-------------------------------
--	Cargo related functions  --
-------------------------------
function setupTailoredShipAttributes()
	-- part of Xansta's larger overall script core for randomized stations and NPC ships;
	--Ship Template Name List
	stnl = {"MT52 Hornet","MU52 Hornet","Adder MK5","Adder MK4","WX-Lindworm","Adder MK6","Phobos T3","Phobos M3","Piranha F8","Piranha F12","Ranus U","Nirvana R5A","Stalker Q7","Stalker R7","Atlantis X23","Starhammer II","Odin","Fighter","Cruiser","Missile Cruiser","Strikeship","Adv. Striker","Dreadnought","Battlestation","Blockade Runner","Ktlitan Fighter","Ktlitan Breaker","Ktlitan Worker","Ktlitan Drone","Ktlitan Feeder","Ktlitan Scout","Ktlitan Destroyer","Storm"}
	--Ship Template Score List
	stsl = {5            ,5            ,7          ,6          ,7            ,8          ,15         ,16         ,15          ,15           ,25       ,20           ,25          ,25          ,50            ,70             ,250   ,6        ,18       ,14               ,30          ,27            ,80           ,100            ,65               ,6                ,45               ,40              ,4              ,48              ,8              ,50                 ,22}
	--Player Ship Beams
	psb = {}
	psb["MP52 Hornet"] = 2
	psb["Phobos M3P"] = 2
	psb["Flavia P.Falcon"] = 2
	psb["Atlantis"] = 2
	psb["Player Cruiser"] = 2
	psb["Player Fighter"] = 2
	psb["Striker"] = 2
	psb["ZX-Lindworm"] = 1
	psb["Ender"] = 12
	psb["Repulse"] = 2
	psb["Benedict"] = 2
	psb["Kiriya"] = 2
	psb["Nautilus"] = 2
	psb["Hathcock"] = 4

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
	playerShipNamesForStriker = {"Sparrow","Sizzle","Squawk","Crow","Phoenix","Snowbird","Hawk"}
	playerShipNamesForLindworm = {"Seagull","Catapult","Blowhard","Flapper","Nixie","Pixie","Tinkerbell"}
	playerShipNamesForRepulse = {"Fiddler","Brinks","Loomis","Mowag","Patria","Pandur","Terrex","Komatsu","Eitan"}
	playerShipNamesForEnder = {"Mongo","Godzilla","Leviathan","Kraken","Jupiter","Saturn"}
	playerShipNamesForNautilus = {"October", "Abdiel", "Manxman", "Newcon", "Nusret", "Pluton", "Amiral", "Amur", "Heinkel", "Dornier"}
	playerShipNamesForHathcock = {"Hayha", "Waldron", "Plunkett", "Mawhinney", "Furlong", "Zaytsev", "Pavlichenko", "Pegahmagabow", "Fett", "Hawkeye", "Hanzo"}
	playerShipNamesForLeftovers = {"Foregone","Righteous","Masher"}

end
function setupBarteringGoods()
	-- part of Xansta's larger overall bartering/crafting setup
	-- list of goods available to buy, sell or trade (sell still under development)
	goodsList = {	{"food",0},
					{"medicine",0},
					{"nickel",0},
					{"platinum",0},
					{"gold",0},
					{"dilithium",0},
					{"tritanium",0},
					{"luxury",0},
					{"cobalt",0},
					{"impulse",0},
					{"warp",0},
					{"shield",0},
					{"tractor",0},
					{"repulsor",0},
					{"beam",0},
					{"optic",0},
					{"robotic",0},
					{"filament",0},
					{"transporter",0},
					{"sensor",0},
					{"communication",0},
					{"autodoc",0},
					{"lifter",0},
					{"android",0},
					{"nanites",0},
					{"software",0},
					{"circuit",0},
					{"battery",0}	}

end
function setupPlacementRandomizationFunctions()
	--array of functions to facilitate randomized station placement
	placeStation = {placeAlcaleica,			-- 1
					placeAnderson,			-- 2
					placeArcher,			-- 3
					placeArchimedes,		-- 4
					placeArmstrong,			-- 5
					placeAsimov,			-- 6
					placeBarclay,			-- 7
					placeBethesda,			-- 8
					placeBroeck,			-- 9
					placeCalifornia,		--10
					placeCalvin,			--11
					placeCavor,				--12
					placeChatuchak,			--13
					placeCoulomb,			--14
					placeCyrus,				--15
					placeDeckard,			--16
					placeDeer,				--17
					placeErickson,			--18
					placeEvondos,			--19
					placeFeynman,			--20
					placeGrasberg,			--21
					placeHayden,			--22
					placeHeyes,				--23
					placeHossam,			--24
					placeImpala,			--25
					placeKomov,				--26
					placeKrak,				--27
					placeKruk,				--28
					placeLipkin,			--29
					placeMadison,			--30
					placeMaiman,			--31
					placeMarconi,			--32
					placeMayo,				--33
					placeMiller,			--34
					placeMuddville,			--35
					placeNexus6,			--36
					placeOBrien,			--37
					placeOlympus,			--38
					placeOrgana,			--39
					placeOutpost15,			--40
					placeOutpost21,			--41
					placeOwen,				--42
					placePanduit,			--43
					placeRipley,			--44
					placeRutherford,		--45
					placeScience7,			--46
					placeShawyer,			--47
					placeShree,				--48
					placeSoong,				--49
					placeTiberius,			--50
					placeTokra,				--51
					placeToohie,			--52
					placeUtopiaPlanitia,	--53
					placeVactel,			--54
					placeVeloquan,			--55
					placeZefram}			--56
	--array of functions to facilitate randomized station placement (friendly, neutral or enemy)
	placeGenericStation = {placeJabba,		-- 1
					placeKrik,				-- 2
					placeLando,				-- 3
					placeMaverick,			-- 4
					placeNefatha,			-- 5
					placeOkun,				-- 6
					placeOutpost7,			-- 7
					placeOutpost8,			-- 8
					placeOutpost33,			-- 9
					placePrada,				--10
					placeResearch11,		--11
					placeResearch19,		--12
					placeRubis,				--13
					placeScience2,			--14
					placeScience4,			--15
					placeSkandar,			--16
					placeSpot,				--17
					placeStarnet,			--18
					placeTandon,			--19
					placeVaiken,			--20
					placeValero}			--21

end

-----------------------------------------------------------
--	Stations to be placed (all need some kind of goods)  --
-----------------------------------------------------------
function placeAlcaleica()
	--Alcaleica
	stationAlcaleica = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationAlcaleica:setPosition(psx,psy):setCallSign("Alcaleica"):setDescription("Optical Components")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationAlcaleica] = {{"food",math.random(5,10),1},{"medicine",5,5},{"optic",5,66}}
		else
			goods[stationAlcaleica] = {{"food",math.random(5,10),1},{"optic",5,66}}
			tradeMedicine[stationAlcaleica] = true
		end
	else
		goods[stationAlcaleica] = {{"optic",5,66}}
		tradeFood[stationAlcaleica] = true
		tradeMedicine[stationAlcaleica] = true
	end
	stationAlcaleica.publicRelations = true
	stationAlcaleica.generalInformation = "We make and supply optic components for various station and ship systems"
	stationAlcaleica.stationHistory = "This station continues the businesses from Earth based on the merging of several companies including Leica from Switzerland, the lens manufacturer and the Japanese advanced low carbon electronic and optic company"
	return stationAlcaleica
end
function placeAnderson()
	--Anderson 
	stationAnderson = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationAnderson:setPosition(psx,psy):setCallSign("Anderson"):setDescription("Battery and software engineering")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationAnderson] = {{"food",math.random(5,10),1},{"medicine",5,5},{"battery",5,65},{"software",5,115}}
		else
			goods[stationAnderson] = {{"food",math.random(5,10),1},{"battery",5,65},{"software",5,115}}
		end
	else
		goods[stationAnderson] = {{"battery",5,65},{"software",5,115}}
	end
	tradeLuxury[stationAnderson] = true
	stationAnderson.publicRelations = true
	stationAnderson.generalInformation = "We provide high quality high capacity batteries and specialized software for all shipboard systems"
	stationAnderson.stationHistory = "The station is named after a fictional software engineer in a late 20th century movie depicting humanity unknowingly conquered by aliens and kept docile by software generated illusion"
	return stationAnderson
end
function placeArcher()
	--Archer 
	stationArcher = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationArcher:setPosition(psx,psy):setCallSign("Archer"):setDescription("Shield and Armor Research")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationArcher] = {{"food",math.random(5,10),1},{"medicine",5,5},{"shield",5,90}}
		else
			goods[stationArcher] = {{"food",math.random(5,10),1},{"shield",5,90}}
			tradeMedicine[stationArcher] = true
		end
	else
		goods[stationArcher] = {{"shield",5,90}}
		tradeMedicine[stationArcher] = true
	end
	tradeLuxury[stationArcher] = true
	stationArcher.publicRelations = true
	stationArcher.generalInformation = "The finest shield and armor manufacturer in the quadrant"
	stationArcher.stationHistory = "We named this station for the pioneering spirit of the 22nd century Starfleet explorer, Captain Jonathan Archer"
	return stationArcher
end
function placeArchimedes()
	--Archimedes
	stationArchimedes = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationArchimedes:setPosition(psx,psy):setCallSign("Archimedes"):setDescription("Energy and particle beam components")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationArchimedes] = {{"food",math.random(5,10),1},{"medicine",5,5},{"beam",5,80}}
		else
			goods[stationArchimedes] = {{"food",math.random(5,10),1},{"beam",5,80}}
			tradeMedicine[stationArchimedes] = true
		end
	else
		goods[stationArchimedes] = {{"beam",5,80}}
		tradeFood[stationArchimedes] = true
	end
	tradeLuxury[stationArchimedes] = true
	stationArchimedes.publicRelations = true
	stationArchimedes.generalInformation = "We fabricate general and specialized components for ship beam systems"
	stationArchimedes.stationHistory = "This station was named after Archimedes who, according to legend, used a series of adjustable focal length mirrors to focus sunlight on a Roman naval fleet invading Syracuse, setting fire to it"
	return stationArchimedes
end
function placeArmstrong()
	--Armstrong
	stationArmstrong = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationArmstrong:setPosition(psx,psy):setCallSign("Armstrong"):setDescription("Warp and Impulse engine manufacturing")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationArmstrong] = {{"food",math.random(5,10),1},{"medicine",5,5},{"repulsor",5,62}}
		else
			goods[stationArmstrong] = {{"food",math.random(5,10),1},{"repulsor",5,62}}
		end
	else
		goods[stationArmstrong] = {{"repulsor",5,62}}
	end
--	table.insert(goods[stationArmstrong],{"warp",5,77})
	stationArmstrong.publicRelations = true
	stationArmstrong.generalInformation = "We manufacture warp, impulse and jump engines for the human navy fleet as well as other independent clients on a contract basis"
	stationArmstrong.stationHistory = "The station is named after the late 19th century astronaut as well as the fictionlized stations that followed. The station initially constructed entire space worthy vessels. In time, it transitioned into specializeing in propulsion systems."
	return stationArmstrong
end
function placeAsimov()
	--Asimov
	stationAsimov = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationAsimov:setCallSign("Asimov"):setDescription("Training and Coordination"):setPosition(psx,psy)
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationAsimov] = {{"food",math.random(5,10),1},{"medicine",5,5},{"tractor",5,48}}
		else
			goods[stationAsimov] = {{"food",math.random(5,10),1},{"tractor",5,48}}		
		end
	else
		goods[stationAsimov] = {{"tractor",5,48}}
	end
	stationAsimov.publicRelations = true
	stationAsimov.generalInformation = "We train naval cadets in routine and specialized functions aboard space vessels and coordinate naval activity throughout the sector"
	stationAsimov.stationHistory = "The original station builders were fans of the late 20th century scientist and author Isaac Asimov. The station was initially named Foundation, but was later changed simply to Asimov. It started off as a stellar observatory, then became a supply stop and as it has grown has become an educational and coordination hub for the region"
	return stationAsimov
end
function placeBarclay()
	--Barclay
	stationBarclay = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationBarclay:setPosition(psx,psy):setCallSign("Barclay"):setDescription("Communication components")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationBarclay] = {{"food",math.random(5,10),1},{"medicine",5,5},{"communication",5,58}}
		else
			goods[stationBarclay] = {{"food",math.random(5,10),1},{"communication",5,58}}
			tradeMedicine[stationBarclay] = true
		end
	else
		goods[stationBarclay] = {{"communication",5,58}}
		tradeMedicine[stationBarclay] = true
	end
	stationBarclay.publicRelations = true
	stationBarclay.generalInformation = "We provide a range of communication equipment and software for use aboard ships"
	stationBarclay.stationHistory = "The station is named after Reginald Barclay who established the first transgalactic com link through the creative application of a quantum singularity. Station personnel often refer to the station as the Broccoli station"
	return stationBarclay
end
function placeBethesda()
	--Bethesda 
	stationBethesda = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationBethesda:setPosition(psx,psy):setCallSign("Bethesda"):setDescription("Medical research")
	goods[stationBethesda] = {{"food",math.random(5,10),1},{"medicine",5,5},{"autodoc",5,36}}
	stationBethesda.publicRelations = true
	stationBethesda.generalInformation = "We research and treat exotic medical conditions"
	stationBethesda.stationHistory = "The station is named after the United States national medical research center based in Bethesda, Maryland on earth which was established in the mid 20th century"
	return stationBethesda
end
function placeBroeck()
	--Broeck
	stationBroeck = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationBroeck:setPosition(psx,psy):setCallSign("Broeck"):setDescription("Warp drive components")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationBroeck] = {{"food",math.random(5,10),1},{"medicine",5,5},{"warp",5,130}}
			if random(1,100) < 62 then tradeLuxury[stationBroeck] = true end
		else
			goods[stationBroeck] = {{"food",math.random(5,10),1},{"warp",5,130}}		
			if random(1,100) < 53 then tradeMedicine[stationBroeck] = true end
			if random(1,100) < 62 then tradeLuxury[stationBroeck] = true end
		end
	else
		goods[stationBroeck] = {{"warp",5,130}}
		if random(1,100) < 53 then tradeMedicine[stationBroeck] = true end
		if random(1,100) < 14 then tradeFood[stationBroeck] = true end
		if random(1,100) < 62 then tradeLuxury[stationBroeck] = true end
	end
	stationBroeck.publicRelations = true
	stationBroeck.generalInformation = "We provide warp drive engines and components"
	stationBroeck.stationHistory = "This station is named after Chris Van Den Broeck who did some initial research into the possibility of warp drive in the late 20th century on Earth"
	return stationBroeck
end
function placeCalifornia()
	--California
	stationCalifornia = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationCalifornia:setPosition(psx,psy):setCallSign("California"):setDescription("Mining station")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationCalifornia] = {{"food",math.random(5,10),1},{"medicine",5,5},{"gold",5,25},{"dilithium",2,25}}
		else
			goods[stationCalifornia] = {{"food",math.random(5,10),1},{"gold",5,25},{"dilithium",2,25}}		
		end
	else
		goods[stationCalifornia] = {{"gold",5,25},{"dilithium",2,25}}
	end
	return stationCalifornia
end
function placeCalvin()
	--Calvin 
	stationCalvin = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationCalvin:setPosition(psx,psy):setCallSign("Calvin"):setDescription("Robotic research")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationCalvin] = {{"food",math.random(5,10),1},{"medicine",5,5},{"robotic",5,87}}
		else
			goods[stationCalvin] = {{"food",math.random(5,10),1},{"robotic",5,87}}		
		end
	else
		goods[stationCalvin] = {{"robotic",5,87}}
		if random(1,100) < 8 then tradeFood[stationCalvin] = true end
	end
	tradeLuxury[stationCalvin] = true
	stationCalvin.publicRelations = true
	stationCalvin.generalInformation = "We research and provide robotic systems and components"
	stationCalvin.stationHistory = "This station is named after Dr. Susan Calvin who pioneered robotic behavioral research and programming"
	return stationCalvin
end
function placeCavor()
	--Cavor 
	stationCavor = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationCavor:setPosition(psx,psy):setCallSign("Cavor"):setDescription("Advanced Material components")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationCavor] = {{"food",math.random(5,10),1},{"medicine",5,5},{"filament",5,42}}
			if random(1,100) < 33 then tradeLuxury[stationCavor] = true end
		else
			goods[stationCavor] = {{"food",math.random(5,10),1},{"filament",5,42}}	
			if random(1,100) < 50 then
				tradeMedicine[stationCavor] = true
			else
				tradeLuxury[stationCavor] = true
			end
		end
	else
		goods[stationCavor] = {{"filament",5,42}}
		whatTrade = random(1,100)
		if whatTrade < 33 then
			tradeMedicine[stationCavor] = true
		elseif whatTrade > 66 then
			tradeFood[stationCavor] = true
		else
			tradeLuxury[stationCavor] = true
		end
	end
	stationCavor.publicRelations = true
	stationCavor.generalInformation = "We fabricate several different kinds of materials critical to various space industries like ship building, station construction and mineral extraction"
	stationCavor.stationHistory = "We named our station after Dr. Cavor, the physicist that invented a barrier material for gravity waves - Cavorite"
	return stationCavor
end
function placeChatuchak()
	--Chatuchak
	stationChatuchak = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationChatuchak:setPosition(psx,psy):setCallSign("Chatuchak"):setDescription("Trading station")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationChatuchak] = {{"food",math.random(5,10),1},{"medicine",5,5},{"luxury",5,60}}
		else
			goods[stationChatuchak] = {{"food",math.random(5,10),1},{"luxury",5,60}}		
		end
	else
		goods[stationChatuchak] = {{"luxury",5,60}}		
	end
	stationChatuchak.publicRelations = true
	stationChatuchak.generalInformation = "Only the largest market and trading location in twenty sectors. You can find your heart's desire here"
	stationChatuchak.stationHistory = "Modeled after the early 21st century bazaar on Earth in Bangkok, Thailand. Designed and built with trade and commerce in mind"
	return stationChatuchak
end
function placeCoulomb()
	--Coulomb
	stationCoulomb = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationCoulomb:setPosition(psx,psy):setCallSign("Coulomb"):setDescription("Shielded circuitry fabrication")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationCoulomb] = {{"food",math.random(5,10),1},{"medicine",5,5},{"circuit",5,50}}
		else
			goods[stationCoulomb] = {{"food",math.random(5,10),1},{"circuit",5,50}}		
			if random(1,100) < 27 then tradeMedicine[stationCoulomb] = true end
		end
	else
		goods[stationCoulomb] = {{"circuit",5,50}}		
		if random(1,100) < 27 then tradeMedicine[stationCoulomb] = true end
		if random(1,100) < 16 then tradeFood[stationCoulomb] = true end
	end
	if random(1,100) < 82 then tradeLuxury[stationCoulomb] = true end
	stationCoulomb.publicRelations = true
	stationCoulomb.generalInformation = "We make a large variety of circuits for numerous ship systems shielded from sensor detection and external control interference"
	stationCoulomb.stationHistory = "Our station is named after the law which quantifies the amount of force with which stationary electrically charged particals repel or attact each other - a fundamental principle in the design of our circuits"
	return stationCoulomb
end
function placeCyrus()
	--Cyrus
	stationCyrus = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationCyrus:setPosition(psx,psy):setCallSign("Cyrus"):setDescription("Impulse engine components")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationCyrus] = {{"food",math.random(5,10),1},{"medicine",5,5},{"impulse",5,124}}
		else
			goods[stationCyrus] = {{"food",math.random(5,10),1},{"impulse",5,124}}		
			if random(1,100) < 34 then tradeMedicine[stationCyrus] = true end
		end
	else
		goods[stationCyrus] = {{"impulse",5,124}}		
		if random(1,100) < 34 then tradeMedicine[stationCyrus] = true end
		if random(1,100) < 13 then tradeFood[stationCyrus] = true end
	end
	if random(1,100) < 78 then tradeLuxury[stationCyrus] = true end
	stationCyrus.publicRelations = true
	stationCyrus.generalInformation = "We supply high quality impulse engines and parts for use aboard ships"
	stationCyrus.stationHistory = "This station was named after the fictional engineer, Cyrus Smith created by 19th century author Jules Verne"
	return stationCyrus
end
function placeDeckard()
	--Deckard
	stationDeckard = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationDeckard:setPosition(psx,psy):setCallSign("Deckard"):setDescription("Android components")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationDeckard] = {{"food",math.random(5,10),1},{"medicine",5,5},{"android",5,73}}
		else
			goods[stationDeckard] = {{"food",math.random(5,10),1},{"android",5,73}}		
		end
	else
		goods[stationDeckard] = {{"android",5,73}}		
		tradeFood[stationDeckard] = true
	end
	tradeLuxury[stationDeckard] = true
	stationDeckard.publicRelations = true
	stationDeckard.generalInformation = "Supplier of android components, programming and service"
	stationDeckard.stationHistory = "Named for Richard Deckard who inspired many of the sophisticated safety security algorithms now required for all androids"
	return stationDeckard
end
function placeDeer()
	--Deer
	stationDeer = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationDeer:setPosition(psx,psy):setCallSign("Deer"):setDescription("Repulsor and Tractor Beam Components")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationDeer] = {{"food",math.random(5,10),1},{"medicine",5,5},{"tractor",5,90},{"repulsor",5,95}}
		else
			goods[stationDeer] = {{"food",math.random(5,10),1},{"tractor",5,90},{"repulsor",5,95}}		
			tradeMedicine[stationDeer] = true
		end
	else
		goods[stationDeer] = {{"tractor",5,90},{"repulsor",5,95}}		
		tradeFood[stationDeer] = true
		tradeMedicine[stationDeer] = true
	end
	tradeLuxury[stationDeer] = true
	stationDeer.publicRelations = true
	stationDeer.generalInformation = "We can meet all your pushing and pulling needs with specialized equipment custom made"
	stationDeer.stationHistory = "The station name comes from a short story by the 20th century author Clifford D. Simak as well as from the 19th century developer John Deere who inspired a company that makes the Earth bound equivalents of our products"
	return stationDeer
end
function placeErickson()
	--Erickson
	stationErickson = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationErickson:setPosition(psx,psy):setCallSign("Erickson"):setDescription("Transporter components")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationErickson] = {{"food",math.random(5,10),1},{"medicine",5,5},{"transporter",5,63}}
		else
			goods[stationErickson] = {{"food",math.random(5,10),1},{"transporter",5,63}}		
			tradeMedicine[stationErickson] = true 
		end
	else
		goods[stationErickson] = {{"transporter",5,63}}		
		tradeFood[stationErickson] = true
		tradeMedicine[stationErickson] = true 
	end
	tradeLuxury[stationErickson] = true 
	stationErickson.publicRelations = true
	stationErickson.generalInformation = "We provide transporters used aboard ships as well as the components for repair and maintenance"
	stationErickson.stationHistory = "The station is named after the early 22nd century inventor of the transporter, Dr. Emory Erickson. This station is proud to have received the endorsement of Admiral Leonard McCoy"
	return stationErickson
end
function placeEvondos()
	--Evondos
	stationEvondos = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationEvondos:setPosition(psx,psy):setCallSign("Evondos"):setDescription("Autodoc components")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationEvondos] = {{"food",math.random(5,10),1},{"medicine",5,5},{"autodoc",5,56}}
		else
			goods[stationEvondos] = {{"food",math.random(5,10),1},{"autodoc",5,56}}		
			tradeMedicine[stationEvondos] = true 
		end
	else
		goods[stationEvondos] = {{"autodoc",5,56}}		
		tradeMedicine[stationEvondos] = true 
	end
	if random(1,100) < 41 then tradeLuxury[stationEvondos] = true end
	stationEvondos.publicRelations = true
	stationEvondos.generalInformation = "We provide components for automated medical machinery"
	stationEvondos.stationHistory = "The station is the evolution of the company that started automated pharmaceutical dispensing in the early 21st century on Earth in Finland"
	return stationEvondos
end
function placeFeynman()
	--Feynman 
	stationFeynman = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationFeynman:setPosition(psx,psy):setCallSign("Feynman"):setDescription("Nanotechnology research")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationFeynman] = {{"food",math.random(5,10),1},{"medicine",5,5},{"nanites",5,79},{"software",5,115}}
		else
			goods[stationFeynman] = {{"food",math.random(5,10),1},{"nanites",5,79},{"software",5,115}}		
		end
	else
		goods[stationFeynman] = {{"nanites",5,79},{"software",5,115}}		
		tradeFood[stationFeynman] = true
		if random(1,100) < 26 then tradeFood[stationFeynman] = true end
	end
	tradeLuxury[stationFeynman] = true
	stationFeynman.publicRelations = true
	stationFeynman.generalInformation = "We provide nanites and software for a variety of ship-board systems"
	stationFeynman.stationHistory = "This station's name recognizes one of the first scientific researchers into nanotechnology, physicist Richard Feynman"
	return stationFeynman
end
function placeGrasberg()
	--Grasberg
	local asteroid_list = placeRandomAroundPointList(Asteroid,15,1,15000,psx,psy)
	for _, ta in ipairs(asteroid_list) do
		table.insert(terrain_objects,ta)
	end
	stationGrasberg = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationGrasberg:setPosition(psx,psy):setCallSign("Grasberg"):setDescription("Mining")
	stationGrasberg.asteroid_list = asteroid_list
	stationGrasberg.publicRelations = true
	stationGrasberg.generalInformation = "We mine nearby asteroids for precious minerals and process them for sale"
	stationGrasberg.stationHistory = "This station's name is inspired by a large gold mine on Earth in Indonesia. The station builders hoped to have a similar amount of minerals found amongst these asteroids"
	grasbergGoods = random(1,100)
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			if grasbergGoods < 20 then
				goods[stationGrasberg] = {{"luxury",5,70},{"gold",5,25},{"cobalt",4,50},{"food",math.random(5,10),1},{"medicine",5,5}}
			elseif grasbergGoods < 40 then
				goods[stationGrasberg] = {{"luxury",5,70},{"gold",5,25},{"food",math.random(5,10),1},{"medicine",5,5}}
			elseif grasbergGoods < 60 then
				goods[stationGrasberg] = {{"luxury",5,70},{"cobalt",4,50},{"food",math.random(5,10),1},{"medicine",5,5}}
			else
				goods[stationGrasberg] = {{"luxury",5,70},{"food",math.random(5,10),1},{"medicine",5,5}}
			end
		else
			if grasbergGoods < 20 then
				goods[stationGrasberg] = {{"luxury",5,70},{"gold",5,25},{"cobalt",4,50},{"food",math.random(5,10),1}}
			elseif grasbergGoods < 40 then
				goods[stationGrasberg] = {{"luxury",5,70},{"gold",5,25},{"food",math.random(5,10),1}}
			elseif grasbergGoods < 60 then
				goods[stationGrasberg] = {{"luxury",5,70},{"cobalt",4,50},{"food",math.random(5,10),1}}
			else
				goods[stationGrasberg] = {{"luxury",5,70},{"food",math.random(5,10),1}}
			end
		end
	else
		if grasbergGoods < 20 then
			goods[stationGrasberg] = {{"luxury",5,70},{"gold",5,25},{"cobalt",4,50}}
		elseif grasbergGoods < 40 then
			goods[stationGrasberg] = {{"luxury",5,70},{"gold",5,25}}
		elseif grasbergGoods < 60 then
			goods[stationGrasberg] = {{"luxury",5,70},{"cobalt",4,50}}
		else
			goods[stationGrasberg] = {{"luxury",5,70}}
		end
		tradeFood[stationGrasberg] = true
	end
	return stationGrasberg
end
function placeHayden()
	--Hayden
	stationHayden = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationHayden:setPosition(psx,psy):setCallSign("Hayden"):setDescription("Observatory and stellar mapping")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationHayden] = {{"food",math.random(5,10),1},{"medicine",5,5},{"nanites",5,65}}
		else
			goods[stationHayden] = {{"food",math.random(5,10),1},{"nanites",5,65}}		
		end
	else
		goods[stationHayden] = {{"nanites",5,65}}		
	end
	stationHayden.publicRelations = true
	stationHayden.generalInformation = "We study the cosmos and map stellar phenomena. We also track moving asteroids. Look out! Just kidding"
	return stationHayden
end
function placeHeyes()
	--Heyes
	stationHeyes = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationHeyes:setPosition(psx,psy):setCallSign("Heyes"):setDescription("Sensor components")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationHeyes] = {{"food",math.random(5,10),1},{"medicine",5,5},{"sensor",5,72}}
		else
			goods[stationHeyes] = {{"food",math.random(5,10),1},{"sensor",5,72}}		
		end
	else
		goods[stationHeyes] = {{"sensor",5,72}}		
	end
	tradeLuxury[stationHeyes] = true 
	stationHeyes.publicRelations = true
	stationHeyes.generalInformation = "We research and manufacture sensor components and systems"
	stationHeyes.stationHistory = "The station is named after Tony Heyes the inventor of some of the earliest electromagnetic sensors in the mid 20th century on Earth in the United Kingdom to assist blind human mobility"
	return stationHeyes
end
function placeHossam()
	--Hossam
	stationHossam = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationHossam:setPosition(psx,psy):setCallSign("Hossam"):setDescription("Nanite supplier")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationHossam] = {{"food",math.random(5,10),1},{"medicine",5,5},{"nanites",5,48}}
		else
			goods[stationHossam] = {{"food",math.random(5,10),1},{"nanites",5,48}}		
			if random(1,100) < 44 then tradeMedicine[stationHossam] = true end
		end
	else
		goods[stationHossam] = {{"nanites",5,48}}		
		if random(1,100) < 44 then tradeMedicine[stationHossam] = true end
		if random(1,100) < 24 then tradeFood[stationHossam] = true end
	end
	if random(1,100) < 63 then tradeLuxury[stationHossam] = true end
	stationHossam.publicRelations = true
	stationHossam.generalInformation = "We provide nanites for various organic and non-organic systems"
	stationHossam.stationHistory = "This station is named after the nanotechnologist Hossam Haick from the early 21st century on Earth in Israel"
	return stationHossam
end
function placeImpala()
	--Impala
	local asteroid_list = placeRandomAroundPointList(Asteroid,15,1,15000,psx,psy)
	for _, ta in ipairs(asteroid_list) do
		table.insert(terrain_objects,ta)
	end
	stationImpala = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationImpala:setPosition(psx,psy):setCallSign("Impala"):setDescription("Mining")
	stationImpala.asteroid_list = asteroid_list
	tradeFood[stationImpala] = true
	tradeLuxury[stationImpala] = true
	stationImpala.publicRelations = true
	stationImpala.generalInformation = "We mine nearby asteroids for precious minerals"
	impalaGoods = random(1,100)
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			if impalaGoods < 20 then
				goods[stationImpala] = {{"luxury",5,70},{"gold",5,25},{"cobalt",4,50},{"food",math.random(5,10),1},{"medicine",5,5}}
			elseif impalaGoods < 40 then
				goods[stationImpala] = {{"luxury",5,70},{"gold",5,25},{"food",math.random(5,10),1},{"medicine",5,5}}
			elseif impalaGoods < 60 then
				goods[stationImpala] = {{"luxury",5,70},{"cobalt",4,50},{"food",math.random(5,10),1},{"medicine",5,5}}
			else
				goods[stationImpala] = {{"luxury",5,70},{"food",math.random(5,10),1},{"medicine",5,5}}
			end
		else
			if impalaGoods < 20 then
				goods[stationImpala] = {{"luxury",5,70},{"gold",5,25},{"cobalt",4,50},{"food",math.random(5,10),1}}
			elseif impalaGoods < 40 then
				goods[stationImpala] = {{"luxury",5,70},{"gold",5,25},{"food",math.random(5,10),1}}
			elseif impalaGoods < 60 then
				goods[stationImpala] = {{"luxury",5,70},{"cobalt",4,50},{"food",math.random(5,10),1}}
			else
				goods[stationImpala] = {{"luxury",5,70},{"food",math.random(5,10),1}}
			end
		end
	else
		if impalaGoods < 20 then
			goods[stationImpala] = {{"luxury",5,70},{"gold",5,25},{"cobalt",4,50}}
		elseif impalaGoods < 40 then
			goods[stationImpala] = {{"luxury",5,70},{"gold",5,25}}
		elseif impalaGoods < 60 then
			goods[stationImpala] = {{"luxury",5,70},{"cobalt",4,50}}
		else
			goods[stationImpala] = {{"luxury",5,70}}
		end
		tradeFood[stationImpala] = true
	end
	return stationImpala
end
function placeKomov()
	--Komov
	stationKomov = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationKomov:setPosition(psx,psy):setCallSign("Komov"):setDescription("Xenopsychology training")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationKomov] = {{"food",math.random(5,10),1},{"medicine",5,5},{"filament",5,46}}
		else
			goods[stationKomov] = {{"food",math.random(5,10),1},{"filament",5,46}}
			if random(1,100) < 44 then tradeMedicine[stationKomov] = true end
		end
	else
		goods[stationKomov] = {{"filament",5,46}}		
		if random(1,100) < 44 then tradeMedicine[stationKomov] = true end
		if random(1,100) < 24 then tradeFood[stationKomov] = true end
	end
	stationKomov.publicRelations = true
	stationKomov.generalInformation = "We provide classes and simulation to help train diverse species in how to relate to each other"
	stationKomov.stationHistory = "A continuation of the research initially conducted by Dr. Gennady Komov in the early 22nd century on Venus, supported by the application of these principles"
	return stationKomov
end
function placeKrak()
	--Krak
	stationKrak = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationKrak:setPosition(psx,psy):setCallSign("Krak"):setDescription("Mining station")
	posAxisKrak = random(0,360)
	posKrak = random(10000,60000)
	negKrak = random(10000,60000)
	spreadKrak = random(4000,7000)
	negAxisKrak = posAxisKrak + 180
	xPosAngleKrak, yPosAngleKrak = vectorFromAngle(posAxisKrak, posKrak)
	posKrakEnd = random(30,70)
	local asteroid_list = createRandomAlongArc(Asteroid, 30+posKrakEnd, psx+xPosAngleKrak, psy+yPosAngleKrak, posKrak, negAxisKrak, negAxisKrak+posKrakEnd, spreadKrak)
	xNegAngleKrak, yNegAngleKrak = vectorFromAngle(negAxisKrak, negKrak)
	negKrakEnd = random(40,80)
	local more_asteroids = createRandomAlongArc(Asteroid, 30+negKrakEnd, psx+xNegAngleKrak, psy+yNegAngleKrak, negKrak, posAxisKrak, posAxisKrak+negKrakEnd, spreadKrak)
	for _, ta in ipairs(more_asteroids) do
		table.insert(asteroid_list,ta)
	end
	for _, ta in ipairs(asteroid_list) do
		table.insert(terrain_objects,ta)
	end
	stationKrak.asteroid_list = asteroid_list
	if random(1,100) < 50 then tradeFood[stationKrak] = true end
	if random(1,100) < 50 then tradeLuxury[stationKrak] = true end
	krakGoods = random(1,100)
	if krakGoods < 10 then
		goods[stationKrak] = {{"nickel",5,20},{"platinum",5,70},{"tritanium",5,50},{"dilithium",5,50}}
	elseif krakGoods < 20 then
		goods[stationKrak] = {{"nickel",5,20},{"platinum",5,70},{"tritanium",5,50}}
	elseif krakGoods < 30 then
		goods[stationKrak] = {{"nickel",5,20},{"platinum",5,70},{"dilithium",5,50}}
	elseif krakGoods < 40 then
		goods[stationKrak] = {{"nickel",5,20},{"tritanium",5,50},{"dilithium",5,50}}
	elseif krakGoods < 50 then
		goods[stationKrak] = {{"nickel",5,20},{"dilithium",5,50}}
	elseif krakGoods < 60 then
		goods[stationKrak] = {{"nickel",5,20},{"platinum",5,70}}
	elseif krakGoods < 70 then
		goods[stationKrak] = {{"nickel",5,20},{"tritanium",5,50}}
	elseif krakGoods < 80 then
		goods[stationKrak] = {{"platinum",5,70},{"tritanium",5,50},{"dilithium",5,50}}
	else
		goods[stationKrak] = {{"nickel",5,20}}
	end
	tradeMedicine[stationKrak] = true
	return stationKrak
end
function placeKruk()
	--Kruk
	stationKruk = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationKruk:setPosition(psx,psy):setCallSign("Kruk"):setDescription("Mining station")
	posAxisKruk = random(0,360)
	posKruk = random(10000,60000)
	negKruk = random(10000,60000)
	spreadKruk = random(4000,7000)
	negAxisKruk = posAxisKruk + 180
	xPosAngleKruk, yPosAngleKruk = vectorFromAngle(posAxisKruk, posKruk)
	posKrukEnd = random(30,70)
	local asteroid_list = createRandomAlongArc(Asteroid, 30+posKrukEnd, psx+xPosAngleKruk, psy+yPosAngleKruk, posKruk, negAxisKruk, negAxisKruk+posKrukEnd, spreadKruk)
	xNegAngleKruk, yNegAngleKruk = vectorFromAngle(negAxisKruk, negKruk)
	negKrukEnd = random(40,80)
	local more_asteroids = createRandomAlongArc(Asteroid, 30+negKrukEnd, psx+xNegAngleKruk, psy+yNegAngleKruk, negKruk, posAxisKruk, posAxisKruk+negKrukEnd, spreadKruk)
	for _, ta in ipairs(more_asteroids) do
		table.insert(asteroid_list,ta)
	end
	for _, ta in ipairs(asteroid_list) do
		table.insert(terrain_objects,ta)
	end
	stationKruk.asteroid_list = asteroid_list
	krukGoods = random(1,100)
	if krukGoods < 10 then
		goods[stationKruk] = {{"nickel",5,20},{"platinum",5,70},{"tritanium",5,50},{"dilithium",5,50}}
	elseif krukGoods < 20 then
		goods[stationKruk] = {{"nickel",5,20},{"platinum",5,70},{"tritanium",5,50}}
	elseif krukGoods < 30 then
		goods[stationKruk] = {{"nickel",5,20},{"platinum",5,70},{"dilithium",5,50}}
	elseif krukGoods < 40 then
		goods[stationKruk] = {{"nickel",5,20},{"tritanium",5,50},{"dilithium",5,50}}
	elseif krukGoods < 50 then
		goods[stationKruk] = {{"nickel",5,20},{"dilithium",5,50}}
	elseif krukGoods < 60 then
		goods[stationKruk] = {{"nickel",5,20},{"platinum",5,70}}
	elseif krukGoods < 70 then
		goods[stationKruk] = {{"nickel",5,20},{"tritanium",5,50}}
	elseif krukGoods < 80 then
		goods[stationKruk] = {{"platinum",5,70},{"tritanium",5,50},{"dilithium",5,50}}
	else
		goods[stationKruk] = {{"nickel",5,20}}
	end
	tradeLuxury[stationKruk] = true
	if random(1,100) < 50 then tradeFood[stationKruk] = true end
	if random(1,100) < 50 then tradeMedicine[stationKruk] = true end
	return stationKruk
end
function placeLipkin()
	--Lipkin
	stationLipkin = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationLipkin:setPosition(psx,psy):setCallSign("Lipkin"):setDescription("Autodoc components")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationLipkin] = {{"food",math.random(5,10),1},{"medicine",5,5},{"autodoc",5,76}}
		else
			goods[stationLipkin] = {{"food",math.random(5,10),1},{"autodoc",5,76}}		
		end
	else
		goods[stationLipkin] = {{"autodoc",5,76}}		
		tradeFood[stationLipkin] = true 
	end
	tradeLuxury[stationLipkin] = true 
	stationLipkin.publicRelations = true
	stationLipkin.generalInformation = "We build and repair and provide components and upgrades for automated facilities designed for ships where a doctor cannot be a crew member (commonly called autodocs)"
	stationLipkin.stationHistory = "The station is named after Dr. Lipkin who pioneered some of the research and application around robot assisted surgery in the area of partial nephrectomy for renal tumors in the early 21st century on Earth"
	return stationLipkin
end
function placeMadison()
	--Madison
	stationMadison = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationMadison:setPosition(psx,psy):setCallSign("Madison"):setDescription("Zero gravity sports and entertainment")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationMadison] = {{"food",math.random(5,10),1},{"medicine",5,5},{"luxury",5,70}}
		else
			goods[stationMadison] = {{"food",math.random(5,10),1},{"luxury",5,70}}		
			tradeMedicine[stationMadison] = true 
		end
	else
		goods[stationMadison] = {{"luxury",5,70}}		
		tradeMedicine[stationMadison] = true 
	end
	stationMadison.publicRelations = true
	stationMadison.generalInformation = "Come take in a game or two or perhaps see a show"
	stationMadison.stationHistory = "Named after Madison Square Gardens from 21st century Earth, this station was designed to serve similar purposes in space - a venue for sports and entertainment"
	return stationMadison
end
function placeMaiman()
	--Maiman
	stationMaiman = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationMaiman:setPosition(psx,psy):setCallSign("Maiman"):setDescription("Energy beam components")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationMaiman] = {{"food",math.random(5,10),1},{"medicine",5,5},{"beam",5,70}}
		else
			goods[stationMaiman] = {{"food",math.random(5,10),1},{"beam",5,70}}		
			tradeMedicine[stationMaiman] = true 
		end
	else
		goods[stationMaiman] = {{"beam",5,70}}		
		tradeMedicine[stationMaiman] = true 
	end
	stationMaiman.publicRelations = true
	stationMaiman.generalInformation = "We research and manufacture energy beam components and systems"
	stationMaiman.stationHistory = "The station is named after Theodore Maiman who researched and built the first laser in the mid 20th centuryon Earth"
	return stationMaiman
end
function placeMarconi()
	--Marconi 
	stationMarconi = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationMarconi:setPosition(psx,psy):setCallSign("Marconi"):setDescription("Energy Beam Components")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationMarconi] = {{"food",math.random(5,10),1},{"medicine",5,5},{"beam",5,80}}
		else
			goods[stationMarconi] = {{"food",math.random(5,10),1},{"beam",5,80}}		
			tradeMedicine[stationMarconi] = true 
		end
	else
		goods[stationMarconi] = {{"beam",5,80}}		
		tradeMedicine[stationMarconi] = true 
		tradeFood[stationMarconi] = true
	end
	tradeLuxury[stationMarconi] = true
	stationMarconi.publicRelations = true
	stationMarconi.generalInformation = "We manufacture energy beam components"
	stationMarconi.stationHistory = "Station named after Guglielmo Marconi an Italian inventor from early 20th century Earth who, along with Nicolo Tesla, claimed to have invented a death ray or particle beam weapon"
	return stationMarconi
end
function placeMayo()
	--Mayo
	stationMayo = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationMayo:setPosition(psx,psy):setCallSign("Mayo"):setDescription("Medical Research")
	goods[stationMayo] = {{"food",5,1},{"medicine",5,5},{"autodoc",5,128}}
	stationMayo.publicRelations = true
	stationMayo.generalInformation = "We research exotic diseases and other human medical conditions"
	stationMayo.stationHistory = "We continue the medical work started by William Worrall Mayo in the late 19th century on Earth"
	return stationMayo
end
function placeMiller()
	--Miller
	stationMiller = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationMiller:setPosition(psx,psy):setCallSign("Miller"):setDescription("Exobiology research")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationMiller] = {{"food",math.random(5,10),1},{"medicine",5,5},{"optic",10,60}}
		else
			goods[stationMiller] = {{"food",math.random(5,10),1},{"optic",10,60}}		
		end
	else
		goods[stationMiller] = {{"optic",10,60}}		
	end
	stationMiller.publicRelations = true
	stationMiller.generalInformation = "We study recently discovered life forms not native to Earth"
	stationMiller.stationHistory = "This station was named after one the early exobiologists from mid 20th century Earth, Dr. Stanley Miller"
	return stationMiller
end
function placeMuddville()
	--Muddville 
	stationMudd = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationMudd:setPosition(psx,psy):setCallSign("Muddville"):setDescription("Trading station")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationMudd] = {{"food",math.random(5,10),1},{"medicine",5,5},{"luxury",10,60}}
		else
			goods[stationMudd] = {{"food",math.random(5,10),1},{"luxury",10,60}}		
		end
	else
		goods[stationMudd] = {{"luxury",10,60}}		
	end
	stationMudd.publicRelations = true
	stationMudd.generalInformation = "Come to Muddvile for all your trade and commerce needs and desires"
	stationMudd.stationHistory = "Upon retirement, Harry Mudd started this commercial venture using his leftover inventory and extensive connections obtained while he traveled the stars as a salesman"
	return stationMudd
end
function placeNexus6()
	--Nexus-6
	stationNexus6 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationNexus6:setPosition(psx,psy):setCallSign("Nexus-6"):setDescription("Android components")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationNexus6] = {{"food",math.random(5,10),1},{"medicine",5,5},{"android",5,93}}
		else
			goods[stationNexus6] = {{"food",math.random(5,10),1},{"android",5,93}}		
			tradeMedicine[stationNexus6] = true 
		end
	else
		goods[stationNexus6] = {{"android",5,93}}		
		tradeMedicine[stationNexus6] = true 
	end
	stationNexus6.publicRelations = true
	stationNexus6.generalInformation = "We research and manufacture android components and systems. Our design our androids to maximize their likeness to humans"
	stationNexus6.stationHistory = "The station is named after the ground breaking model of android produced by the Tyrell corporation"
	return stationNexus6
end
function placeOBrien()
	--O'Brien
	stationOBrien = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOBrien:setPosition(psx,psy):setCallSign("O'Brien"):setDescription("Transporter components")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationOBrien] = {{"food",math.random(5,10),1},{"medicine",5,5},{"transporter",5,76}}
		else
			goods[stationOBrien] = {{"food",math.random(5,10),1},{"transporter",5,76}}		
			if random(1,100) < 34 then tradeMedicine[stationOBrien] = true end
		end
	else
		goods[stationOBrien] = {{"transporter",5,76}}		
		tradeMedicine[stationOBrien] = true 
		if random(1,100) < 13 then tradeFood[stationOBrien] = true end
		if random(1,100) < 34 then tradeMedicine[stationOBrien] = true end
	end
	if random(1,100) < 43 then tradeLuxury[stationOBrien] = true end
	stationOBrien.publicRelations = true
	stationOBrien.generalInformation = "We research and fabricate high quality transporters and transporter components for use aboard ships"
	stationOBrien.stationHistory = "Miles O'Brien started this business after his experience as a transporter chief"
	return stationOBrien
end
function placeOlympus()
	--Olympus
	stationOlympus = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOlympus:setPosition(psx,psy):setCallSign("Olympus"):setDescription("Optical components")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationOlympus] = {{"food",math.random(5,10),1},{"medicine",5,5},{"optic",5,66}}
		else
			goods[stationOlympus] = {{"food",math.random(5,10),1},{"optic",5,66}}		
			tradeMedicine[stationOlympus] = true
		end
	else
		goods[stationOlympus] = {{"optic",5,66}}		
		tradeFood[stationOlympus] = true
		tradeMedicine[stationOlympus] = true
	end
	stationOlympus.publicRelations = true
	stationOlympus.generalInformation = "We fabricate optical lenses and related equipment as well as fiber optic cabling and components"
	stationOlympus.stationHistory = "This station grew out of the Olympus company based on earth in the early 21st century. It merged with Infinera, then bought several software comapnies before branching out into space based industry"
	return stationOlympus
end
function placeOrgana()
	--Organa
	stationOrgana = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOrgana:setPosition(psx,psy):setCallSign("Organa"):setDescription("Diplomatic training")
	goods[stationOrgana] = {{"luxury",5,96}}		
	stationOrgana.publicRelations = true
	stationOrgana.generalInformation = "The premeire academy for leadership and diplomacy training in the region"
	stationOrgana.stationHistory = "Established by the royal family so critical during the political upheaval era"
	return stationOrgana
end
function placeOutpost15()
	--Outpost 15
	stationOutpost15 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost15:setPosition(psx,psy):setCallSign("Outpost-15"):setDescription("Mining and trade")
	tradeFood[stationOutpost15] = true
	outpost15Goods = random(1,100)
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			if outpost15Goods < 20 then
				goods[stationOutpost15] = {{"luxury",5,70},{"gold",5,25},{"cobalt",4,50},{"food",math.random(5,10),1},{"medicine",5,5}}
			elseif outpost15Goods < 40 then
				goods[stationOutpost15] = {{"luxury",5,70},{"gold",5,25},{"food",math.random(5,10),1},{"medicine",5,5}}
			elseif outpost15Goods < 60 then
				goods[stationOutpost15] = {{"luxury",5,70},{"cobalt",4,50},{"food",math.random(5,10),1},{"medicine",5,5}}
			else
				goods[stationOutpost15] = {{"luxury",5,70},{"food",math.random(5,10),1},{"medicine",5,5}}
			end
		else
			if outpost15Goods < 20 then
				goods[stationOutpost15] = {{"luxury",5,70},{"gold",5,25},{"cobalt",4,50},{"food",math.random(5,10),1}}
			elseif outpost15Goods < 40 then
				goods[stationOutpost15] = {{"luxury",5,70},{"gold",5,25},{"food",math.random(5,10),1}}
			elseif outpost15Goods < 60 then
				goods[stationOutpost15] = {{"luxury",5,70},{"cobalt",4,50},{"food",math.random(5,10),1}}
			else
				goods[stationOutpost15] = {{"luxury",5,70},{"food",math.random(5,10),1}}
			end
		end
	else
		if outpost15Goods < 20 then
			goods[stationOutpost15] = {{"luxury",5,70},{"gold",5,25},{"cobalt",4,50}}
		elseif outpost15Goods < 40 then
			goods[stationOutpost15] = {{"luxury",5,70},{"gold",5,25}}
		elseif outpost15Goods < 60 then
			goods[stationOutpost15] = {{"luxury",5,70},{"cobalt",4,50}}
		else
			goods[stationOutpost15] = {{"luxury",5,70}}
		end
		tradeFood[stationOutpost15] = true
	end
	local asteroid_list = placeRandomAroundPointList(Asteroid,15,1,15000,psx,psy)
	for _, ta in ipairs(asteroid_list) do
		table.insert(terrain_objects,ta)
	end
	stationOutpost15.asteroid_list = asteroid_list
	return stationOutpost15
end
function placeOutpost21()
	--Outpost 21
	stationOutpost21 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost21:setPosition(psx,psy):setCallSign("Outpost-21"):setDescription("Mining and gambling")
	local asteroid_list = placeRandomAroundPointList(Asteroid,15,1,15000,psx,psy)
	for _, ta in ipairs(asteroid_list) do
		table.insert(terrain_objects,ta)
	end
	stationOutpost21.asteroid_list = asteroid_list
	outpost21Goods = random(1,100)
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			if outpost21Goods < 20 then
				goods[stationOutpost21] = {{"luxury",5,70},{"gold",5,25},{"cobalt",4,50},{"food",math.random(5,10),1},{"medicine",5,5}}
			elseif outpost21Goods < 40 then
				goods[stationOutpost21] = {{"luxury",5,70},{"gold",5,25},{"food",math.random(5,10),1},{"medicine",5,5}}
			elseif outpost21Goods < 60 then
				goods[stationOutpost21] = {{"luxury",5,70},{"cobalt",4,50},{"food",math.random(5,10),1},{"medicine",5,5}}
			else
				goods[stationOutpost21] = {{"luxury",5,70},{"food",math.random(5,10),1},{"medicine",5,5}}
			end
		else
			if outpost21Goods < 20 then
				goods[stationOutpost21] = {{"luxury",5,70},{"gold",5,25},{"cobalt",4,50},{"food",math.random(5,10),1}}
			elseif outpost21Goods < 40 then
				goods[stationOutpost21] = {{"luxury",5,70},{"gold",5,25},{"food",math.random(5,10),1}}
			elseif outpost21Goods < 60 then
				goods[stationOutpost21] = {{"luxury",5,70},{"cobalt",4,50},{"food",math.random(5,10),1}}
			else
				goods[stationOutpost21] = {{"luxury",5,70},{"food",math.random(5,10),1}}
			end
			if random(1,100) < 50 then tradeMedicine[stationOutpost21] = true end
		end
	else
		if outpost21Goods < 20 then
			goods[stationOutpost21] = {{"luxury",5,70},{"gold",5,25},{"cobalt",4,50}}
		elseif outpost21Goods < 40 then
			goods[stationOutpost21] = {{"luxury",5,70},{"gold",5,25}}
		elseif outpost21Goods < 60 then
			goods[stationOutpost21] = {{"luxury",5,70},{"cobalt",4,50}}
		else
			goods[stationOutpost21] = {{"luxury",5,70}}
		end
		tradeFood[stationOutpost21] = true
		if random(1,100) < 50 then tradeMedicine[stationOutpost21] = true end
	end
	tradeLuxury[stationOutpost21] = true
	return stationOutpost21
end
function placeOwen()
	--Owen
	stationOwen = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOwen:setPosition(psx,psy):setCallSign("Owen"):setDescription("Load lifters and components")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationOwen] = {{"food",math.random(5,10),1},{"medicine",5,5},{"lifter",5,61}}
		else
			goods[stationOwen] = {{"food",math.random(5,10),1},{"lifter",5,61}}		
		end
	else
		goods[stationOwen] = {{"lifter",5,61}}		
		tradeFood[stationOwen] = true 
	end
	tradeLuxury[stationOwen] = true 
	stationOwen.publicRelations = true
	stationOwen.generalInformation = "We provide load lifters and components for various ship systems"
	stationOwen.stationHistory = "The station is named after Lars Owen. After his extensive eperience with tempermental machinery on Tatooine, he used his subject matter expertise to expand into building and manufacturing the equipment adding innovations based on his years of experience using load lifters and their relative cousins, moisture vaporators"
	return stationOwen
end
function placePanduit()
	--Panduit
	stationPanduit = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationPanduit:setPosition(psx,psy):setCallSign("Panduit"):setDescription("Optic components")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationPanduit] = {{"food",math.random(5,10),1},{"medicine",5,5},{"optic",5,79}}
		else
			goods[stationPanduit] = {{"food",math.random(5,10),1},{"optic",5,79}}		
			if random(1,100) < 33 then tradeMedicine[stationPanduit] = true end
		end
	else
		goods[stationPanduit] = {{"optic",5,79}}		
		if random(1,100) < 33 then tradeMedicine[stationPanduit] = true end
		if random(1,100) < 27 then tradeFood[stationPanduit] = true end
	end
	tradeLuxury[stationPanduit] = true
	stationPanduit.publicRelations = true
	stationPanduit.generalInformation = "We provide optic components for various ship systems"
	stationPanduit.stationHistory = "This station is an outgrowth of the Panduit corporation started in the mid 20th century on Earth in the United States"
	return stationPanduit
end
function placeRipley()
	--Ripley
	stationRipley = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationRipley:setPosition(psx,psy):setCallSign("Ripley"):setDescription("Load lifters and components")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationRipley] = {{"food",math.random(5,10),1},{"medicine",5,5},{"lifter",5,82}}
		else
			goods[stationRipley] = {{"food",math.random(5,10),1},{"lifter",5,82}}		
			tradeMedicine[stationRipley] = true 
		end
	else
		goods[stationRipley] = {{"lifter",5,82}}		
		if random(1,100) < 17 then tradeFood[stationRipley] = true end
		tradeMedicine[stationRipley] = true 
	end
	if random(1,100) < 47 then tradeLuxury[stationRipley] = true end
	stationRipley.publicRelations = true
	stationRipley.generalInformation = "We provide load lifters and components"
	stationRipley.stationHistory = "The station is named after Ellen Ripley who made creative and effective use of one of our load lifters when defending her ship"
	return stationRipley
end
function placeRutherford()
	--Rutherford
	stationRutherford = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationRutherford:setPosition(psx,psy):setCallSign("Rutherford"):setDescription("Shield components and research")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationRutherford] = {{"food",math.random(5,10),1},{"medicine",5,5},{"shield",5,90}}
		else
			goods[stationRutherford] = {{"food",math.random(5,10),1},{"shield",5,90}}		
			tradeMedicine[stationRutherford] = true 
		end
	else
		goods[stationRutherford] = {{"shield",5,90}}		
		tradeMedicine[stationRutherford] = true 
	end
	tradeMedicine[stationRutherford] = true
	if random(1,100) < 43 then tradeLuxury[stationRutherford] = true end
	stationRutherford.publicRelations = true
	stationRutherford.generalInformation = "We research and fabricate components for ship shield systems"
	stationRutherford.stationHistory = "This station was named after the national research institution Rutherford Appleton Laboratory in the United Kingdom which conducted some preliminary research into the feasability of generating an energy shield in the late 20th century"
	return stationRutherford
end
function placeScience7()
	--Science 7
	stationScience7 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationScience7:setPosition(psx,psy):setCallSign("Science-7"):setDescription("Observatory")
	goods[stationScience7] = {{"food",2,1}}
	return stationScience7
end
function placeShawyer()
	--Shawyer
	stationShawyer = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationShawyer:setPosition(psx,psy):setCallSign("Shawyer"):setDescription("Impulse engine components")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationShawyer] = {{"food",math.random(5,10),1},{"medicine",5,5},{"impulse",5,100}}
		else
			goods[stationShawyer] = {{"food",math.random(5,10),1},{"impulse",5,100}}		
			tradeMedicine[stationShawyer] = true 
		end
	else
		goods[stationShawyer] = {{"impulse",5,100}}		
		tradeMedicine[stationShawyer] = true 
	end
	tradeLuxury[stationShawyer] = true 
	stationShawyer.publicRelations = true
	stationShawyer.generalInformation = "We research and manufacture impulse engine components and systems"
	stationShawyer.stationHistory = "The station is named after Roger Shawyer who built the first prototype impulse engine in the early 21st century"
	return stationShawyer
end
function placeShree()
	--Shree
	stationShree = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationShree:setPosition(psx,psy):setCallSign("Shree"):setDescription("Repulsor and tractor beam components")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationShree] = {{"food",math.random(5,10),1},{"medicine",5,5},{"tractor",5,90},{"repulsor",5,95}}
		else
			goods[stationShree] = {{"food",math.random(5,10),1},{"tractor",5,90},{"repulsor",5,95}}		
			tradeMedicine[stationShree] = true 
		end
	else
		goods[stationShree] = {{"tractor",5,90},{"repulsor",5,95}}		
		tradeMedicine[stationShree] = true 
		tradeFood[stationShree] = true 
	end
	tradeLuxury[stationShree] = true 
	stationShree.publicRelations = true
	stationShree.generalInformation = "We make ship systems designed to push or pull other objects around in space"
	stationShree.stationHistory = "Our station is named Shree after one of many tugboat manufacturers in the early 21st century on Earth in India. Tugboats serve a similar purpose for ocean-going vessels on earth as tractor and repulsor beams serve for space-going vessels today"
	return stationShree
end
function placeSoong()
	--Soong 
	stationSoong = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationSoong:setPosition(psx,psy):setCallSign("Soong"):setDescription("Android components")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationSoong] = {{"food",math.random(5,10),1},{"medicine",5,5},{"android",5,73}}
		else
			goods[stationSoong] = {{"food",math.random(5,10),1},{"android",5,73}}		
		end
	else
		goods[stationSoong] = {{"android",5,73}}		
		tradeFood[stationSoong] = true 
	end
	tradeLuxury[stationSoong] = true 
	stationSoong.publicRelations = true
	stationSoong.generalInformation = "We create androids and android components"
	stationSoong.stationHistory = "The station is named after Dr. Noonian Soong, the famous android researcher and builder"
	return stationSoong
end
function placeTiberius()
	--Tiberius
	stationTiberius = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationTiberius:setPosition(psx,psy):setCallSign("Tiberius"):setDescription("Logistics coordination")
	goods[stationTiberius] = {{"food",5,1}}
	stationTiberius.publicRelations = true
	stationTiberius.generalInformation = "We support the stations and ships in the area with planning and communication services"
	stationTiberius.stationHistory = "We recognize the influence of Starfleet Captain James Tiberius Kirk in the 23rd century in our station name"
	return stationTiberius
end
function placeTokra()
	--Tokra
	stationTokra = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationTokra:setPosition(psx,psy):setCallSign("Tokra"):setDescription("Advanced material components")
	whatTrade = random(1,100)
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationTokra] = {{"food",math.random(5,10),1},{"medicine",5,5},{"filament",5,42}}
			tradeLuxury[stationTokra] = true
		else
			goods[stationTokra] = {{"food",math.random(5,10),1},{"filament",5,42}}	
			if whatTrade < 50 then
				tradeMedicine[stationTokra] = true
			else
				tradeLuxury[stationTokra] = true
			end
		end
	else
		goods[stationTokra] = {{"filament",5,42}}		
		if whatTrade < 33 then
			tradeFood[stationTokra] = true
		elseif whatTrade > 66 then
			tradeMedicine[stationTokra] = true
		else
			tradeLuxury[stationTokra] = true
		end
	end
	stationTokra.publicRelations = true
	stationTokra.generalInformation = "We create multiple types of advanced material components. Our most popular products are our filaments"
	stationTokra.stationHistory = "We learned several of our critical industrial processes from the Tokra race, so we honor our fortune by naming the station after them"
	return stationTokra
end
function placeToohie()
	--Toohie
	stationToohie = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationToohie:setPosition(psx,psy):setCallSign("Toohie"):setDescription("Shield and armor components and research")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationToohie] = {{"food",math.random(5,10),1},{"medicine",5,5},{"shield",5,90}}
		else
			goods[stationToohie] = {{"food",math.random(5,10),1},{"shield",5,90}}		
			if random(1,100) < 25 then tradeMedicine[stationToohie] = true end
		end
	else
		goods[stationToohie] = {{"shield",5,90}}		
		if random(1,100) < 25 then tradeMedicine[stationToohie] = true end
	end
	tradeLuxury[stationToohie] = true
	stationToohie.publicRelations = true
	stationToohie.generalInformation = "We research and make general and specialized components for ship shield and ship armor systems"
	stationToohie.stationHistory = "This station was named after one of the earliest researchers in shield technology, Alexander Toohie back when it was considered impractical to construct shields due to the physics involved."
	return stationToohie
end
function placeUtopiaPlanitia()
	--Utopia Planitia
	stationUtopiaPlanitia = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationUtopiaPlanitia:setPosition(psx,psy):setCallSign("Utopia Planitia"):setDescription("Ship building and maintenance facility")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationUtopiaPlanitia] = {{"food",math.random(5,10),1},{"medicine",5,5},{"warp",5,167}}
		else
			goods[stationUtopiaPlanitia] = {{"food",math.random(5,10),1},{"warp",5,167}}
		end
	else
		goods[stationUtopiaPlanitia] = {{"warp",5,167}}
	end
	stationUtopiaPlanitia.publicRelations = true
	stationUtopiaPlanitia.generalInformation = "We work on all aspects of naval ship building and maintenance. Many of the naval models are researched, designed and built right here on this station. Our design goals seek to make the space faring experience as simple as possible given the tremendous capabilities of the modern naval vessel"
	return stationUtopiaPlanitia
end
function placeVactel()
	--Vactel
	stationVactel = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationVactel:setPosition(psx,psy):setCallSign("Vactel"):setDescription("Shielded Circuitry Fabrication")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationVactel] = {{"food",math.random(5,10),1},{"medicine",5,5},{"circuit",5,50}}
		else
			goods[stationVactel] = {{"food",math.random(5,10),1},{"circuit",5,50}}		
		end
	else
		goods[stationVactel] = {{"circuit",5,50}}		
	end
	stationVactel.publicRelations = true
	stationVactel.generalInformation = "We specialize in circuitry shielded from external hacking suitable for ship systems"
	stationVactel.stationHistory = "We started as an expansion from the lunar based chip manufacturer of Earth legacy Intel electronic chips"
	return stationVactel
end
function placeVeloquan()
	--Veloquan
	stationVeloquan = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationVeloquan:setPosition(psx,psy):setCallSign("Veloquan"):setDescription("Sensor components")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationVeloquan] = {{"food",math.random(5,10),1},{"medicine",5,5},{"sensor",5,68}}
		else
			goods[stationVeloquan] = {{"food",math.random(5,10),1},{"sensor",5,68}}		
			tradeMedicine[stationVeloquan] = true 
		end
	else
		goods[stationVeloquan] = {{"sensor",5,68}}		
		tradeMedicine[stationVeloquan] = true 
		tradeFood[stationVeloquan] = true 
	end
	stationVeloquan.publicRelations = true
	stationVeloquan.generalInformation = "We research and construct components for the most powerful and accurate sensors used aboard ships along with the software to make them easy to use"
	stationVeloquan.stationHistory = "The Veloquan company has its roots in the manufacturing of LIDAR sensors in the early 21st century on Earth in the United States for autonomous ground-based vehicles. They expanded research and manufacturing operations to include various sensors for space vehicles. Veloquan was the result of numerous mergers and acquisitions of several companies including Velodyne and Quanergy"
	return stationVeloquan
end
function placeZefram()
	--Zefram
	stationZefram = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationZefram:setPosition(psx,psy):setCallSign("Zefram"):setDescription("Warp engine components")
	if stationFaction ~= "Independent" then
		if random(1,5) <= 1 then
			goods[stationZefram] = {{"food",math.random(5,10),1},{"medicine",5,5},{"warp",5,140}}
		else
			goods[stationZefram] = {{"food",math.random(5,10),1},{"warp",5,140}}		
			if random(1,100) < 27 then tradeMedicine[stationZefram] = true end
		end
	else
		goods[stationZefram] = {{"warp",5,140}}		
		if random(1,100) < 27 then tradeMedicine[stationZefram] = true end
		if random(1,100) < 16 then tradeFood[stationZefram] = true end
	end
	tradeLuxury[stationZefram] = true
	stationZefram.publicRelations = true
	stationZefram.generalInformation = "We specialize in the esoteric components necessary to make warp drives function properly"
	stationZefram.stationHistory = "Zefram Cochrane constructed the first warp drive in human history. We named our station after him because of the specialized warp systems work we do"
	return stationZefram
end

-------------------------------------
--	Generic stations to be placed  --
-------------------------------------
function placeJabba()
	--Jabba
	stationJabba = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationJabba:setPosition(psx,psy):setCallSign("Jabba"):setDescription("Commerce and gambling")
	stationJabba.publicRelations = true
	stationJabba.generalInformation = "Come play some games and shop. House take does not exceed 4 percent"
	return stationJabba
end
function placeKrik()
	--Krik
	stationKrik = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationKrik:setPosition(psx,psy):setCallSign("Krik"):setDescription("Mining station")
	posAxisKrik = random(0,360)
	posKrik = random(30000,80000)
	negKrik = random(20000,60000)
	spreadKrik = random(5000,8000)
	negAxisKrik = posAxisKrik + 180
	xPosAngleKrik, yPosAngleKrik = vectorFromAngle(posAxisKrik, posKrik)
	posKrikEnd = random(40,90)
	local asteroid_list = createRandomAlongArc(Asteroid, 30+posKrikEnd, psx+xPosAngleKrik, psy+yPosAngleKrik, posKrik, negAxisKrik, negAxisKrik+posKrikEnd, spreadKrik)
	xNegAngleKrik, yNegAngleKrik = vectorFromAngle(negAxisKrik, negKrik)
	negKrikEnd = random(30,60)
	local more_asteroids = createRandomAlongArc(Asteroid, 30+negKrikEnd, psx+xNegAngleKrik, psy+yNegAngleKrik, negKrik, posAxisKrik, posAxisKrik+negKrikEnd, spreadKrik)
	for _, ta in ipairs(more_asteroids) do
		table.insert(asteroid_list,ta)
	end
	for _, ta in ipairs(asteroid_list) do
		table.insert(terrain_objects,ta)
	end
	stationKrik.asteroid_list = asteroid_list
	tradeFood[stationKrik] = true
	if random(1,100) < 50 then tradeLuxury[stationKrik] = true end
	tradeMedicine[stationKrik] = true
	krikGoods = random(1,100)
	if krikGoods < 10 then
		goods[stationKrik] = {{"nickel",5,20},{"platinum",5,70},{"tritanium",5,50},{"dilithium",5,50}}
	elseif krikGoods < 20 then
		goods[stationKrik] = {{"nickel",5,20},{"platinum",5,70},{"tritanium",5,50}}
	elseif krikGoods < 30 then
		goods[stationKrik] = {{"nickel",5,20},{"platinum",5,70},{"dilithium",5,50}}
	elseif krikGoods < 40 then
		goods[stationKrik] = {{"nickel",5,20},{"tritanium",5,50},{"dilithium",5,50}}
	elseif krikGoods < 50 then
		goods[stationKrik] = {{"nickel",5,20},{"dilithium",5,50}}
	elseif krikGoods < 60 then
		goods[stationKrik] = {{"nickel",5,20},{"platinum",5,70}}
	elseif krikGoods < 70 then
		goods[stationKrik] = {{"nickel",5,20},{"tritanium",5,50}}
	elseif krikGoods < 80 then
		goods[stationKrik] = {{"platinum",5,70},{"tritanium",5,50},{"dilithium",5,50}}
	else
		goods[stationKrik] = {{"nickel",5,20}}
	end
	return stationKrik
end
function placeLando()
	--Lando
	stationLando = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationLando:setPosition(psx,psy):setCallSign("Lando"):setDescription("Casino and Gambling")
	return stationLando
end
function placeMaverick()
	--Maverick
	stationMaverick = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationMaverick:setPosition(psx,psy):setCallSign("Maverick"):setDescription("Gambling and resupply")
	stationMaverick.publicRelations = true
	stationMaverick.generalInformation = "Relax and meet some interesting players"
	return stationMaverick
end
function placeNefatha()
	--Nefatha
	stationNefatha = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationNefatha:setPosition(psx,psy):setCallSign("Nefatha"):setDescription("Commerce and recreation")
	goods[stationNefatha] = {{"luxury",5,70}}
	return stationNefatha
end
function placeOkun()
	--Okun
	stationOkun = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOkun:setPosition(psx,psy):setCallSign("Okun"):setDescription("Xenopsychology research")
	return stationOkun
end
function placeOutpost7()
	--Outpost 7
	stationOutpost7 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost7:setPosition(psx,psy):setCallSign("Outpost-7"):setDescription("Resupply")
	goods[stationOutpost7] = {{"luxury",5,80}}
	return stationOutpost7
end
function placeOutpost8()
	--Outpost 8
	stationOutpost8 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost8:setPosition(psx,psy):setCallSign("Outpost-8")
	return stationOutpost8
end
function placeOutpost33()
	--Outpost 33
	stationOutpost33 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost33:setPosition(psx,psy):setCallSign("Outpost-33"):setDescription("Resupply")
	goods[stationOutpost33] = {{"luxury",5,75}}
	return stationOutpost33
end
function placePrada()
	--Prada
	stationPrada = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationPrada:setPosition(psx,psy):setCallSign("Prada"):setDescription("Textiles and fashion")
	return stationPrada
end
function placeResearch11()
	--Research-11
	stationResearch11 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationResearch11:setPosition(psx,psy):setCallSign("Research-11"):setDescription("Stress Psychology Research")
	return stationResearch11
end
function placeResearch19()
	--Research-19
	stationResearch19 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationResearch19:setPosition(psx,psy):setCallSign("Research-19"):setDescription("Low gravity research")
	return stationResearch19
end
function placeRubis()
	--Rubis
	stationRubis = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationRubis:setPosition(psx,psy):setCallSign("Rubis"):setDescription("Resupply")
	goods[stationRubis] = {{"luxury",5,76}}
	stationRubis.publicRelations = true
	stationRubis.generalInformation = "Get your energy here! Grab a drink before you go!"
	return stationRubis
end
function placeScience2()
	--Science 2
	stationScience2 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationScience2:setPosition(psx,psy):setCallSign("Science-2"):setDescription("Research Lab and Observatory")
	return stationScience2
end
function placeScience4()
	--Science 4
	stationScience4 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationScience4:setPosition(psx,psy):setCallSign("Science-4"):setDescription("Biotech research")
	return stationScience4
end
function placeSkandar()
	--Skandar
	stationSkandar = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationSkandar:setPosition(psx,psy):setCallSign("Skandar"):setDescription("Routine maintenance and entertainment")
	goods[stationSkandar] = {{"luxury",5,87}}
	stationSkandar.publicRelations = true
	stationSkandar.generalInformation = "Stop by for repairs. Take in one of our juggling shows featuring the four-armed Skandars"
	stationSkandar.stationHistory = "The nomadic Skandars have set up at this station to practice their entertainment and maintenance skills as well as build a community where Skandars can relax"
	return stationSkandar
end
function placeSpot()
	--Spot
	stationSpot = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationSpot:setPosition(psx,psy):setCallSign("Spot"):setDescription("Observatory")
	return stationSpot
end
function placeStarnet()
	--Starnet 
	stationStarnet = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationStarnet:setPosition(psx,psy):setCallSign("Starnet"):setDescription("Automated weapons systems")
	stationStarnet.publicRelations = true
	stationStarnet.generalInformation = "We research and create automated weapons systems to improve ship combat capability"
	return stationStarnet
end
function placeTandon()
	--Tandon
	stationTandon = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationTandon:setPosition(psx,psy):setCallSign("Tandon"):setDescription("Biotechnology research")
	return stationTandon
end
function placeVaiken()
	--Vaiken
	stationVaiken = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationVaiken:setPosition(psx,psy):setCallSign("Vaiken"):setDescription("Ship building and maintenance facility")
	goods[stationVaiken] = {{"food",10,1},{"medicine",5,5}}
	return stationVaiken
end
function placeValero()
	--Valero
	stationValero = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationValero:setPosition(psx,psy):setCallSign("Valero"):setDescription("Resupply")
	goods[stationValero] = {{"luxury",5,77}}
	return stationValero
end

-----------------------------
--	Station communication  --
-----------------------------
function resupplyStation()
    if comms_target.comms_data == nil then
        comms_target.comms_data = {}
    end
    mergeTables(comms_target.comms_data, {
        friendlyness = math.random(0.0, 100.0),
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
            reinforcements = math.random(125,175)
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
	if bugger:isCommsOpening() then
		player = bugger
	end
	if player:isEnemy(comms_target) then
        return false
    end
    if player:isDocked(comms_target) then
		setCommsMessage("Greetings")
		missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
		missilePresence = 0
		for _, missile_type in ipairs(missile_types) do
			missilePresence = missilePresence + player:getWeaponStorageMax(missile_type)
		end
		if missilePresence > 0 then
			if comms_target.nukeAvail == nil then
				comms_target.nukeAvail = false
				comms_target.empAvail = false
				comms_target.homeAvail = true
				comms_target.mineAvail = false
				comms_target.hvliAvail = true
			end
			if comms_target.nukeAvail or comms_target.empAvail or comms_target.homeAvail or comms_target.mineAvail or comms_target.hvliAvail then
				if player:getWeaponStorageMax("Homing") > 0 then
					if comms_target.homeAvail then
						homePrompt = "Restock Homing ("
						addCommsReply(homePrompt .. getWeaponCost("Homing") .. " rep each)", function()
							handleWeaponRestock("Homing")
						end)
					end
				end
				if player:getWeaponStorageMax("HVLI") > 0 then
					if comms_target.hvliAvail then
						hvliPrompt = "Restock HVLI ("
						addCommsReply(hvliPrompt .. getWeaponCost("HVLI") .. " rep each)", function()
							handleWeaponRestock("HVLI")
						end)
					end
				end
			end
		end
	else
        setCommsMessage("Dock, please")
    end
    return true
end
function commsStation()
    if comms_target.comms_data == nil then
        comms_target.comms_data = {}
    end
    mergeTables(comms_target.comms_data, {
        friendlyness = math.random(0.0, 100.0),
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
            reinforcements = math.random(125,175)
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
	for p3idx=1,12 do
		p3obj = getPlayerShip(p3idx)
		if p3obj ~= nil and p3obj:isValid() then
			if p3obj:isCommsOpening() then
				player = p3obj
			end
		end
	end
   if player:isEnemy(comms_target) then
        return false
    end
    if not player:isDocked(comms_target) then
        handleUndockedState()
    else
        handleDockedState()
    end
    return true
end
function handleDockedState()
    if player:isFriendly(comms_target) then
		oMsg = "Good day, officer!\nWhat can we do for you today?\n"
    else
		oMsg = "Welcome to our lovely station.\n"
    end
	setCommsMessage(oMsg)
	missilePresence = 0
	for _, missile_type in ipairs(missile_types) do
		missilePresence = missilePresence + player:getWeaponStorageMax(missile_type)
	end
	if missilePresence > 0 then
		if comms_target.nukeAvail == nil then
			if math.random(1,10) <= (4 - difficulty) then
				comms_target.nukeAvail = true
			else
				comms_target.nukeAvail = false
			end
			if math.random(1,10) <= (5 - difficulty) then
				comms_target.empAvail = true
			else
				comms_target.empAvail = false
			end
			if math.random(1,10) <= (6 - difficulty) then
				comms_target.homeAvail = true
			else
				comms_target.homeAvail = false
			end
			if math.random(1,10) <= (7 - difficulty) then
				comms_target.mineAvail = true
			else
				comms_target.mineAvail = false
			end
			if math.random(1,10) <= (9 - difficulty) then
				comms_target.hvliAvail = true
			else
				comms_target.hvliAvail = false
			end
		end
		if comms_target.nukeAvail or comms_target.empAvail or comms_target.homeAvail or comms_target.mineAvail or comms_target.hvliAvail then
			addCommsReply("I need ordnance restocked", function()
				setCommsMessage("What type of ordnance?")
				if player:getWeaponStorageMax("Nuke") > 0 then
					if comms_target.nukeAvail then
						if math.random(1,10) <= 5 then
							nukePrompt = "Can you supply us with some nukes? ("
						else
							nukePrompt = "We really need some nukes ("
						end
						addCommsReply(nukePrompt .. getWeaponCost("Nuke") .. " rep each)", function()
							handleWeaponRestock("Nuke")
						end)
					end
				end
				if player:getWeaponStorageMax("EMP") > 0 then
					if comms_target.empAvail then
						if math.random(1,10) <= 5 then
							empPrompt = "Please re-stock our EMP missiles. ("
						else
							empPrompt = "Got any EMPs? ("
						end
						addCommsReply(empPrompt .. getWeaponCost("EMP") .. " rep each)", function()
							handleWeaponRestock("EMP")
						end)
					end
				end
				if player:getWeaponStorageMax("Homing") > 0 then
					if comms_target.homeAvail then
						if math.random(1,10) <= 5 then
							homePrompt = "Do you have spare homing missiles for us? ("
						else
							homePrompt = "Do you have extra homing missiles? ("
						end
						addCommsReply(homePrompt .. getWeaponCost("Homing") .. " rep each)", function()
							handleWeaponRestock("Homing")
						end)
					end
				end
				if player:getWeaponStorageMax("Mine") > 0 then
					if comms_target.mineAvail then
						minePromptChoice = math.random(1,5)
						if minePromptChoice == 1 then
							minePrompt = "We could use some mines. ("
						elseif minePromptChoice == 2 then
							minePrompt = "How about mines? ("
						elseif minePromptChoice == 3 then
							minePrompt = "More mines ("
						elseif minePromptChoice == 4 then
							minePrompt = "All the mines we can take. ("
						else
							minePrompt = "Mines! What else? ("
						end
						addCommsReply(minePrompt .. getWeaponCost("Mine") .. " rep each)", function()
							handleWeaponRestock("Mine")
						end)
					end
				end
				if player:getWeaponStorageMax("HVLI") > 0 then
					if comms_target.hvliAvail then
						if math.random(1,10) <= 5 then
							hvliPrompt = "What about HVLI? ("
						else
							hvliPrompt = "Could you provide HVLI? ("
						end
						addCommsReply(hvliPrompt .. getWeaponCost("HVLI") .. " rep each)", function()
							handleWeaponRestock("HVLI")
						end)
					end
				end
			end)
		end
	end
	if player:isFriendly(comms_target) then
		if math.random(1,6) <= (4 - difficulty) then
			if player:getRepairCrewCount() < player.maxRepairCrew then
				hireCost = math.random(30,60)
			else
				hireCost = math.random(45,90)
			end
			addCommsReply(string.format("Recruit repair crew member for %i reputation",hireCost), function()
				if not player:takeReputationPoints(hireCost) then
					setCommsMessage("Insufficient reputation")
				else
					player:setRepairCrewCount(player:getRepairCrewCount() + 1)
					setCommsMessage("Repair crew member hired")
				end
			end)
		end
	else
		if math.random(1,6) <= (4 - difficulty) then
			if player:getRepairCrewCount() < player.maxRepairCrew then
				hireCost = math.random(45,90)
			else
				hireCost = math.random(60,120)
			end
			addCommsReply(string.format("Recruit repair crew member for %i reputation",hireCost), function()
				if not player:takeReputationPoints(hireCost) then
					setCommsMessage("Insufficient reputation")
				else
					player:setRepairCrewCount(player:getRepairCrewCount() + 1)
					setCommsMessage("Repair crew member hired")
				end
			end)
		end
	end
	if comms_target.publicRelations then
		addCommsReply("Tell me more about your station", function()
			setCommsMessage("What would you like to know?")
			addCommsReply("General information", function()
				setCommsMessage(comms_target.generalInformation)
				addCommsReply("Back", commsStation)
			end)
			if comms_target.stationHistory ~= nil then
				addCommsReply("Station history", function()
					setCommsMessage(comms_target.stationHistory)
					addCommsReply("Back", commsStation)
				end)
			end
			if player:isFriendly(comms_target) then
				if comms_target.gossip ~= nil then
					if random(1,100) < 50 then
						addCommsReply("Gossip", function()
							setCommsMessage(comms_target.gossip)
							addCommsReply("Back", commsStation)
						end)
					end
				end
			end
		end)
	end
	if goods[comms_target] ~= nil then
		addCommsReply("Buy, sell, trade", function()
			oMsg = string.format("Station %s:\nGoods or components available: quantity, cost in reputation\n",comms_target:getCallSign())
			gi = 1		-- initialize goods index
			repeat
				goodsType = goods[comms_target][gi][1]
				goodsQuantity = goods[comms_target][gi][2]
				goodsRep = goods[comms_target][gi][3]
				oMsg = oMsg .. string.format("     %s: %i, %i\n",goodsType,goodsQuantity,goodsRep)
				gi = gi + 1
			until(gi > #goods[comms_target])
			oMsg = oMsg .. "Current Cargo:\n"
			gi = 1
			cargoHoldEmpty = true
			repeat
				playerGoodsType = goods[player][gi][1]
				playerGoodsQuantity = goods[player][gi][2]
				if playerGoodsQuantity > 0 then
					oMsg = oMsg .. string.format("     %s: %i\n",playerGoodsType,playerGoodsQuantity)
					cargoHoldEmpty = false
				end
				gi = gi + 1
			until(gi > #goods[player])
			if cargoHoldEmpty then
				oMsg = oMsg .. "     Empty\n"
			end
			playerRep = math.floor(player:getReputationPoints())
			oMsg = oMsg .. string.format("Available Space: %i, Available Reputation: %i\n",player.cargo,playerRep)
			setCommsMessage(oMsg)
			-- Buttons for reputation purchases
			gi = 1
			repeat
				local goodsType = goods[comms_target][gi][1]
				local goodsQuantity = goods[comms_target][gi][2]
				local goodsRep = goods[comms_target][gi][3]
				addCommsReply(string.format("Buy one %s for %i reputation",goods[comms_target][gi][1],goods[comms_target][gi][3]), function()
					oMsg = string.format("Type: %s, Quantity: %i, Rep: %i",goodsType,goodsQuantity,goodsRep)
					if player.cargo < 1 then
						oMsg = oMsg .. "\nInsufficient cargo space for purchase"
					elseif goodsRep > playerRep then
						oMsg = oMsg .. "\nInsufficient reputation for purchase"
					elseif goodsQuantity < 1 then
						oMsg = oMsg .. "\nInsufficient station inventory"
					else
						if not player:takeReputationPoints(goodsRep) then
							oMsg = oMsg .. "\nInsufficient reputation for purchase"
						else
							player.cargo = player.cargo - 1
							decrementStationGoods(goodsType)
							incrementPlayerGoods(goodsType)
							oMsg = oMsg .. "\npurchased"
						end
					end
					setCommsMessage(oMsg)
					addCommsReply("Back", commsStation)
				end)
				gi = gi + 1
			until(gi > #goods[comms_target])
			-- Buttons for food trades
			if tradeFood[comms_target] ~= nil then
				gi = 1
				foodQuantity = 0
				repeat
					if goods[player][gi][1] == "food" then
						foodQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if foodQuantity > 0 then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						addCommsReply(string.format("Trade food for %s",goods[comms_target][gi][1]), function()
							oMsg = string.format("Type: %s,  Quantity: %i",goodsType,goodsQuantity)
							if goodsQuantity < 1 then
								oMsg = oMsg .. "\nInsufficient station inventory"
							else
								decrementStationGoods(goodsType)
								incrementPlayerGoods(goodsType)
								decrementPlayerGoods("food")
								oMsg = oMsg .. "\nTraded"
							end
							setCommsMessage(oMsg)
							addCommsReply("Back", commsStation)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
			-- Buttons for luxury trades
			if tradeLuxury[comms_target] ~= nil then
				gi = 1
				luxuryQuantity = 0
				repeat
					if goods[player][gi][1] == "luxury" then
						luxuryQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if luxuryQuantity > 0 then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						addCommsReply(string.format("Trade luxury for %s",goods[comms_target][gi][1]), function()
							oMsg = string.format("Type: %s,  Quantity: %i",goodsType,goodsQuantity)
							if goodsQuantity < 1 then
								oMsg = oMsg .. "\nInsufficient station inventory"
							else
								decrementStationGoods(goodsType)
								incrementPlayerGoods(goodsType)
								decrementPlayerGoods("luxury")
								oMsg = oMsg .. "\nTraded"
							end
							setCommsMessage(oMsg)
							addCommsReply("Back", commsStation)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
			-- Buttons for medicine trades
			if tradeMedicine[comms_target] ~= nil then
				gi = 1
				medicineQuantity = 0
				repeat
					if goods[player][gi][1] == "medicine" then
						medicineQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if medicineQuantity > 0 then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						addCommsReply(string.format("Trade medicine for %s",goods[comms_target][gi][1]), function()
							oMsg = string.format("Type: %s,  Quantity: %i",goodsType,goodsQuantity)
							if goodsQuantity < 1 then
								oMsg = oMsg .. "\nInsufficient station inventory"
							else
								decrementStationGoods(goodsType)
								incrementPlayerGoods(goodsType)
								decrementPlayerGoods("medicine")
								oMsg = oMsg .. "\nTraded"
							end
							setCommsMessage(oMsg)
							addCommsReply("Back", commsStation)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
			addCommsReply("Back", commsStation)
		end)
		gi = 1
		cargoHoldEmpty = true
		repeat
			playerGoodsType = goods[player][gi][1]
			playerGoodsQuantity = goods[player][gi][2]
			if playerGoodsQuantity > 0 then
				cargoHoldEmpty = false
			end
			gi = gi + 1
		until(gi > #goods[player])
		if not cargoHoldEmpty then
			addCommsReply("Jettison cargo", function()
				setCommsMessage(string.format("Available space: %i\nWhat would you like to jettison?",player.cargo))
				gi = 1
				repeat
					local goodsType = goods[player][gi][1]
					local goodsQuantity = goods[player][gi][2]
					if goodsQuantity > 0 then
						addCommsReply(goodsType, function()
							decrementPlayerGoods(goodsType)
							player.cargo = player.cargo + 1
							setCommsMessage(string.format("One %s jettisoned",goodsType))
							addCommsReply("Back", commsStation)
						end)
					end
					gi = gi + 1
				until(gi > #goods[player])
				addCommsReply("Back", commsStation)
			end)
		end
	end
end
function isAllowedTo(state)
    if state == "friend" and player:isFriendly(comms_target) then
        return true
    end
    if state == "neutral" and not player:isEnemy(comms_target) then
        return true
    end
    return false
end
function handleWeaponRestock(weapon)
    if not player:isDocked(comms_target) then 
		setCommsMessage("You need to stay docked for that action.")
		return
	end
    if not isAllowedTo(comms_data.weapons[weapon]) then
        if weapon == "Nuke" then setCommsMessage("We do not deal in weapons of mass destruction.")
        elseif weapon == "EMP" then setCommsMessage("We do not deal in weapons of mass disruption.")
        else setCommsMessage("We do not deal in those weapons.") end
        return
    end
    local points_per_item = getWeaponCost(weapon)
    local item_amount = math.floor(player:getWeaponStorageMax(weapon) * comms_data.max_weapon_refill_amount[getFriendStatus()]) - player:getWeaponStorage(weapon)
    if item_amount <= 0 then
        if weapon == "Nuke" then
            setCommsMessage("All nukes are charged and primed for destruction.");
        else
            setCommsMessage("Sorry, sir, but you are as fully stocked as I can allow.");
        end
        addCommsReply("Back", commsStation)
    else
        if not player:takeReputationPoints(points_per_item * item_amount) then
            setCommsMessage("Not enough reputation.")
            return
        end
        player:setWeaponStorage(weapon, player:getWeaponStorage(weapon) + item_amount)
        if player:getWeaponStorage(weapon) == player:getWeaponStorageMax(weapon) then
            setCommsMessage("You are fully loaded and ready to explode things.")
        else
            setCommsMessage("We generously resupplied you with some weapon charges.\nPut them to good use.")
        end
        addCommsReply("Back", commsStation)
    end
end
function getWeaponCost(weapon)
    return math.ceil(comms_data.weapon_cost[weapon] * comms_data.reputation_cost_multipliers[getFriendStatus()])
end
function handleUndockedState()
    --Handle communications when we are not docked with the station.
    if player:isFriendly(comms_target) then
        oMsg = "Good day, officer.\nIf you need supplies, please dock with us first."
    else
        oMsg = "Greetings.\nIf you want to do business, please dock with us first."
    end
	if comms_target.nukeAvail == nil then
		if math.random(1,10) <= (4 - difficulty) then
			comms_target.nukeAvail = true
		else
			comms_target.nukeAvail = false
		end
		if math.random(1,10) <= (5 - difficulty) then
			comms_target.empAvail = true
		else
			comms_target.empAvail = false
		end
		if math.random(1,10) <= (6 - difficulty) then
			comms_target.homeAvail = true
		else
			comms_target.homeAvail = false
		end
		if math.random(1,10) <= (7 - difficulty) then
			comms_target.mineAvail = true
		else
			comms_target.mineAvail = false
		end
		if math.random(1,10) <= (9 - difficulty) then
			comms_target.hvliAvail = true
		else
			comms_target.hvliAvail = false
		end
	end
	setCommsMessage(oMsg)
 	addCommsReply("I need information", function()
		setCommsMessage("What kind of information do you need?")
		addCommsReply("What ordnance do you have available for restock?", function()
			missileTypeAvailableCount = 0
			oMsg = ""
			if comms_target.nukeAvail then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				oMsg = oMsg .. "\n   Nuke"
			end
			if comms_target.empAvail then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				oMsg = oMsg .. "\n   EMP"
			end
			if comms_target.homeAvail then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				oMsg = oMsg .. "\n   Homing"
			end
			if comms_target.mineAvail then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				oMsg = oMsg .. "\n   Mine"
			end
			if comms_target.hvliAvail then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				oMsg = oMsg .. "\n   HVLI"
			end
			if missileTypeAvailableCount == 0 then
				oMsg = "We have no ordnance available for restock"
			elseif missileTypeAvailableCount == 1 then
				oMsg = "We have the following type of ordnance available for restock:" .. oMsg
			else
				oMsg = "We have the following types of ordnance available for restock:" .. oMsg
			end
			setCommsMessage(oMsg)
			addCommsReply("Back", commsStation)
		end)
		goodsQuantityAvailable = 0
		gi = 1
		repeat
			if goods[comms_target][gi][2] > 0 then
				goodsQuantityAvailable = goodsQuantityAvailable + goods[comms_target][gi][2]
			end
			gi = gi + 1
		until(gi > #goods[comms_target])
		if goodsQuantityAvailable > 0 then
			addCommsReply("What goods do you have available for sale or trade?", function()
				oMsg = string.format("Station %s:\nGoods or components available: quantity, cost in reputation\n",comms_target:getCallSign())
				gi = 1		-- initialize goods index
				repeat
					goodsType = goods[comms_target][gi][1]
					goodsQuantity = goods[comms_target][gi][2]
					goodsRep = goods[comms_target][gi][3]
					oMsg = oMsg .. string.format("   %14s: %2i, %3i\n",goodsType,goodsQuantity,goodsRep)
					gi = gi + 1
				until(gi > #goods[comms_target])
				setCommsMessage(oMsg)
				addCommsReply("Back", commsStation)
			end)
		end
		addCommsReply("See any enemies in your area?", function()
			if player:isFriendly(comms_target) then
				enemiesInRange = 0
				for _, obj in ipairs(comms_target:getObjectsInRange(30000)) do
					if obj:isEnemy(player) then
						enemiesInRange = enemiesInRange + 1
					end
				end
				if enemiesInRange > 0 then
					if enemiesInRange > 1 then
						setCommsMessage(string.format("Yes, we see %i enemies within 30U",enemiesInRange))
					else
						setCommsMessage("Yes, we see one enemy within 30U")						
					end
					player:addReputationPoints(2.0)					
				else
					setCommsMessage("No enemies within 30U")
					player:addReputationPoints(1.0)
				end
				addCommsReply("Back", commsStation)
			else
				setCommsMessage("Not really")
				player:addReputationPoints(1.0)
				addCommsReply("Back", commsStation)
			end
		end)
		addCommsReply("Where can I find particular goods?", function()
			gkMsg = "Friendly stations generally have food or medicine or both. Neutral stations often trade their goods for food, medicine or luxury."
			if comms_target.goodsKnowledge == nil then
				gkMsg = gkMsg .. " Beyond that, I have no knowledge of specific stations.\n\nCheck back later, someone else may have better knowledge"
				setCommsMessage(gkMsg)
				addCommsReply("Back", commsStation)
				fillStationBrains()
			else
				if #comms_target.goodsKnowledge == 0 then
					gkMsg = gkMsg .. " Beyond that, I have no knowledge of specific stations"
				else
					gkMsg = gkMsg .. "\n\nWhat goods are you interested in?\nI've heard about these:"
					for gk=1,#comms_target.goodsKnowledge do
						addCommsReply(comms_target.goodsKnowledgeType[gk],function()
							setCommsMessage(string.format("Station %s in sector %s has %s%s",comms_target.goodsKnowledge[gk],comms_target.goodsKnowledgeSector[gk],comms_target.goodsKnowledgeType[gk],comms_target.goodsKnowledgeTrade[gk]))
							addCommsReply("Back", commsStation)
						end)
					end
				end
				setCommsMessage(gkMsg)
				addCommsReply("Back", commsStation)
			end
		end)
		if comms_target.publicRelations then
			addCommsReply("General station information", function()
				setCommsMessage(comms_target.generalInformation)
				addCommsReply("Back", commsStation)
			end)
		end
	end)
	--Diagnostic data is used to help test and debug the script while it is under construction
	if diagnostic then
		addCommsReply("Diagnostic data", function()
			oMsg = string.format("Difficulty: %.1f",difficulty)
			oMsg = oMsg .. string.format("  time remaining: %.1f",gameTimeLimit)
			if plotW ~= nil and waveTimer ~= nil then
				oMsg = oMsg .. string.format("\nwave timer: %.1f",waveTimer)
			end
			if timeDivision ~= nil then
				oMsg = oMsg .. "  " .. timeDivision
			end
			oMsg = oMsg .. "\n" .. wfv
			setCommsMessage(oMsg)
			addCommsReply("Back", commsStation)
		end)
	end
	if isAllowedTo(comms_target.comms_data.services.supplydrop) then
        addCommsReply("Can you send a supply drop? ("..getServiceCost("supplydrop").."rep)", function()
            if player:getWaypointCount() < 1 then
                setCommsMessage("You need to set a waypoint before you can request backup.");
            else
                setCommsMessage("To which waypoint should we deliver your supplies?");
                for n=1,player:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
                        if player:takeReputationPoints(getServiceCost("supplydrop")) then
                            local position_x, position_y = comms_target:getPosition()
                            local target_x, target_y = player:getWaypoint(n)
                            local script = Script()
                            script:setVariable("position_x", position_x):setVariable("position_y", position_y)
                            script:setVariable("target_x", target_x):setVariable("target_y", target_y)
                            script:setVariable("faction_id", comms_target:getFactionId()):run("supply_drop.lua")
                            setCommsMessage("We have dispatched a supply ship toward WP" .. n);
                        else
                            setCommsMessage("Not enough reputation!");
                        end
                        addCommsReply("Back", commsStation)
                    end)
                end
            end
            addCommsReply("Back", commsStation)
        end)
    end
    if isAllowedTo(comms_target.comms_data.services.reinforcements) then
        addCommsReply("Please send reinforcements! ("..getServiceCost("reinforcements").."rep)", function()
            if player:getWaypointCount() < 1 then
                setCommsMessage("You need to set a waypoint before you can request reinforcements.");
            else
                setCommsMessage("To which waypoint should we dispatch the reinforcements?");
                for n=1,player:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
                        if player:takeReputationPoints(getServiceCost("reinforcements")) then
                            ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(player:getWaypoint(n))
                            setCommsMessage("We have dispatched " .. ship:getCallSign() .. " to assist at WP" .. n);
                        else
                            setCommsMessage("Not enough reputation!");
                        end
                        addCommsReply("Back", commsStation)
                    end)
                end
            end
            addCommsReply("Back", commsStation)
        end)
    end
end
function getServiceCost(service)
	-- Return the number of reputation points that a specified service costs for
	-- the current player.
    return math.ceil(comms_data.service_cost[service])
end
function fillStationBrains()
	comms_target.goodsKnowledge = {}
	comms_target.goodsKnowledgeSector = {}
	comms_target.goodsKnowledgeType = {}
	comms_target.goodsKnowledgeTrade = {}
	knowledgeCount = 0
	knowledgeMax = 10
	for sti=1,#stationList do
		if stationList[sti] ~= nil and stationList[sti]:isValid() then
			if distance(comms_target,stationList[sti]) < 75000 then
				brainCheck = 3
			else
				brainCheck = 1
			end
			for gi=1,#goods[stationList[sti]] do
				if random(1,10) <= brainCheck then
					table.insert(comms_target.goodsKnowledge,stationList[sti]:getCallSign())
					table.insert(comms_target.goodsKnowledgeSector,stationList[sti]:getSectorName())
					table.insert(comms_target.goodsKnowledgeType,goods[stationList[sti]][gi][1])
					tradeString = ""
					stationTrades = false
					if tradeMedicine[stationList[sti]] ~= nil then
						tradeString = " and will trade it for medicine"
						stationTrades = true
					end
					if tradeFood[stationList[sti]] ~= nil then
						if stationTrades then
							tradeString = tradeString .. " or food"
						else
							tradeString = tradeString .. " and will trade it for food"
							stationTrades = true
						end
					end
					if tradeLuxury[stationList[sti]] ~= nil then
						if stationTrades then
							tradeString = tradeString .. " or luxury"
						else
							tradeString = tradeString .. " and will trade it for luxury"
						end
					end
					table.insert(comms_target.goodsKnowledgeTrade,tradeString)
					knowledgeCount = knowledgeCount + 1
					if knowledgeCount >= knowledgeMax then
						return
					end
				end
			end
		end
	end
end
function getFriendStatus()
    if player:isFriendly(comms_target) then
        return "friend"
    else
        return "neutral"
    end
end

-----------------------------------------------
--	Custom player ship buttons and messages  --
-----------------------------------------------
--	Player Ship Flag Buttons and call-back functions  --
function setP1FlagButton()
	if p1FlagButton == nil and not p1FlagDrop then
		p1FlagButton = "p1FlagButton"
		p1:addCustomButton("Weapons", p1FlagButton, "Drop flag", p1DropFlag)
		p1FlagButtonT = "p1FlagButtonT"
		p1:addCustomButton("Tactical", p1FlagButtonT, "Drop flag", p1DropFlag)
	end
end
function removeP1FlagButton()
	if p1FlagButton ~= nil then
		p1:removeCustom(p1FlagButton)
		p1:removeCustom(p1FlagButtonT)
		p1FlagButton = nil
		p1FlagButtonT = nil
	end
end
function setP2FlagButton()
	if p2FlagButton == nil and not p2FlagDrop then
		p2FlagButton = "p2FlagButton"
		p2:addCustomButton("Weapons", p2FlagButton, "Drop flag", p2DropFlag)
		p2FlagButtonT = "p2FlagButtonT"
		p2:addCustomButton("Tactical", p2FlagButtonT, "Drop flag", p2DropFlag)
	end
end
function removeP2FlagButton()
	if p2FlagButton ~= nil then
		p2:removeCustom(p2FlagButton)
		p2:removeCustom(p2FlagButtonT)
		p2FlagButton = nil
		p2FlagButtonT = nil
	end
end

function p1DropFlag()
	p1FlagDrop = true
	p1Flagx, p1Flagy = p1:getPosition()
	removeP1FlagButton()
	if p1:hasPlayerAtPosition("Weapons") then
		p1FlagDroppedMsg = "p1FlagDroppedMsg"
		p1:addCustomMessage("Weapons",p1FlagDroppedMsg,"Flag position recorded. Flag will be placed here when preparation period complete")
	end
	if p1:hasPlayerAtPosition("Tactical") then
		p1FlagDroppedMsgT = "p1FlagDroppedMsgT"
		p1:addCustomMessage("Tactical",p1FlagDroppedMsgT,"Flag position recorded. Flag will be placed here when preparation period complete")
	end
end
function p2DropFlag()
	p2FlagDrop = true
	p2Flagx, p2Flagy = p2:getPosition()
	removeP2FlagButton()
	if p2:hasPlayerAtPosition("Weapons") then
		p2FlagDroppedMsg = "p2FlagDroppedMsg"
		p2:addCustomMessage("Weapons",p2FlagDroppedMsg,"Flag position recorded. Flag will be placed here when preparation period complete")
	end
	if p2:hasPlayerAtPosition("Tactical") then
		p2FlagDroppedMsgT = "p2FlagDroppedMsgT"
		p2:addCustomMessage("Tactical",p2FlagDroppedMsgT,"Flag position recorded. Flag will be placed here when preparation period complete")
	end
end

--	Player Ship Decoy Buttons and call-back functions
function p1DropDecoy()
	if p1.decoy_drop == nil then
		p1.decoy_drop = {}
	end
	p1.decoy_drop[1] = true
	decoyH1x, decoyH1y = dropDecoy(p1,1)
end
function p1DropDecoy2()
	if p1.decoy_drop == nil then
		p1.decoy_drop = {}
	end
	p1.decoy_drop[2] = true
	decoyH2x, decoyH2y = dropDecoy(p1,2)
end
function p1DropDecoy3()
	if p1.decoy_drop == nil then
		p1.decoy_drop = {}
	end
	p1.decoy_drop[3] = true
	decoyH3x, decoyH3y = dropDecoy(p1,3)
end
function p2DropDecoy()
	if p2.decoy_drop == nil then
		p2.decoy_drop = {}
	end
	p2.decoy_drop[1] = true
	decoyK1x, decoyK1y = dropDecoy(p2,1)
end
function p2DropDecoy2()
	if p2.decoy_drop == nil then
		p2.decoy_drop = {}
	end
	p2.decoy_drop[2] = true
	decoyK2x, decoyK2y = dropDecoy(p2,2)
end
function p2DropDecoy3()
	if p2.decoy_drop == nil then
		p2.decoy_drop = {}
	end
	p2.decoy_drop[3] = true
	decoyK3x, decoyK3y = dropDecoy(p2,3)
end
function p3DropDecoy()
	if p3.decoy_drop == nil then
		p3.decoy_drop = {}
	end
	p3.decoy_drop[1] = true
	decoyH1x, decoyH1y = dropDecoy(p3,1)
end
function p3DropDecoy2()
	if p3.decoy_drop == nil then
		p3.decoy_drop = {}
	end
	p3.decoy_drop[2] = true
	decoyH2x, decoyH2y = dropDecoy(p3,2)
end
function p3DropDecoy3()
	if p3.decoy_drop == nil then
		p3.decoy_drop = {}
	end
	p3.decoy_drop[3] = true
	decoyH3x, decoyH3y = dropDecoy(p3,3)
end
function p4DropDecoy()
	if p4.decoy_drop == nil then
		p4.decoy_drop = {}
	end
	p4.decoy_drop[1] = true
	decoyK1x, decoyK1y = dropDecoy(p4,1)
end
function p4DropDecoy2()
	if p4.decoy_drop == nil then
		p4.decoy_drop = {}
	end
	p4.decoy_drop[2] = true
	decoyK2x, decoyK2y = dropDecoy(p4,2)
end
function p4DropDecoy3()
	if p4.decoy_drop == nil then
		p4.decoy_drop = {}
	end
	p4.decoy_drop[3] = true
	decoyK3x, decoyK3y = dropDecoy(p4,3)
end
function p5DropDecoy()
	if p5.decoy_drop == nil then
		p5.decoy_drop = {}
	end
	p5.decoy_drop[2] = true
	decoyH2x, decoyH2y = dropDecoy(p5,2)
end
function p5DropDecoy3()
	if p5.decoy_drop == nil then
		p5.decoy_drop = {}
	end
	p5.decoy_drop[3] = true
	decoyH3x, decoyH3y = dropDecoy(p5,3)
end
function p6DropDecoy()
	if p6.decoy_drop == nil then
		p6.decoy_drop = {}
	end
	p6.decoy_drop[2] = true
	decoyK2x, decoyK2y = dropDecoy(p6,2)
end
function p6DropDecoy3()
	if p6.decoy_drop == nil then
		p6.decoy_drop = {}
	end
	p6.decoy_drop[3] = true
	decoyK3x, decoyK3y = dropDecoy(p6,3)
end
function p7DropDecoy()
	p7.decoy_drop = {}
	p7.decoy_drop[3] = true
	decoyH3x, decoyH3y = dropDecoy(p7,3)
end
function p8DropDecoy()
	p8.decoy_drop = {}
	p8.decoy_drop[3] = true
	decoyK3x, decoyK3y = dropDecoy(p8,3)
end
function dropDecoy(p,decoy_number)
	local decoy_x, decoy_y = p:getPosition()
	removeDecoyButton(p)
	local decoy_dropped_message = string.format("%s%iDecoyDroppedMessageWeapons",p:getCallSign(),decoy_number)
	if p:hasPlayerAtPosition("Weapons") then
		p:addCustomMessage("Weapons",decoy_dropped_message,"Decoy position recorded. Decoy will be placed here when preparation period complete")
	end
	if p:hasPlayerAtPosition("Tactical") then
		decoy_dropped_message = string.format("%s%iDecoyDroppedMessageTactical",p:getCallSign(),decoy_number)
		p:addCustomMessage("Tactical",decoy_dropped_message,"Decoy position recorded. Decoy will be placed here when preparation period complete")
	end
	return decoy_x, decoy_y
end
function removeDecoyButton(p)
	if p ~= nil and p.decoy_button ~= nil then
		for decoy_button_label, player_name in pairs(p.decoy_button) do
			p:removeCustom(decoy_button_label)
		end
		p.decoy_button = {}
	end
end
function setDecoyButton(p,player_index,decoy_number)
	if p.decoy_drop == nil then
		p.decoy_drop = {}
	end
	if p.decoy_button == nil then
		p.decoy_button = {}
	end
	local player_name = p:getCallSign()
	local decoy_button_label = string.format("%s%iDecoyButtonWeapons",player_name,decoy_number)
	if p.decoy_button[decoy_button_label] == nil and p.decoy_drop[decoy_number] == nil then
		p:addCustomButton("Weapons",decoy_button_label,string.format("Drop Decoy %i",decoy_number),drop_decoy_functions[player_index][decoy_number])
		p.decoy_button[decoy_button_label] = player_name
		decoy_button_label = string.format("%s%iDecoyButtonTactical",p:getCallSign(),decoy_number)
		p:addCustomButton("Tactical",decoy_button_label,string.format("Drop Decoy %i",decoy_number),drop_decoy_functions[player_index][decoy_number])
		p.decoy_button[decoy_button_label] = player_name
	end
end
function setP1DecoyButton()
	setDecoyButton(p1,1,1)
end
function setP1DecoyButton2()
	setDecoyButton(p1,1,2)
end
function setP1DecoyButton3()
	setDecoyButton(p1,1,3)
end
function removeP1DecoyButton()
	removeDecoyButton(p1)
end
function removeP1DecoyButton2()
	removeDecoyButton(p1)
end
function removeP1DecoyButton3()
	removeDecoyButton(p1)
end
function setP2DecoyButton()
	setDecoyButton(p2,2,1)
end
function setP2DecoyButton2()
	setDecoyButton(p2,2,2)
end
function setP2DecoyButton3()
	setDecoyButton(p2,2,3)
end
function removeP2DecoyButton()
	removeDecoyButton(p2)
end
function removeP2DecoyButton2()
	removeDecoyButton(p2)
end
function removeP2DecoyButton3()
	removeDecoyButton(p2)
end
function setP3DecoyButton()
	setDecoyButton(p3,3,1)
end
function setP3DecoyButton2()
	setDecoyButton(p3,3,2)
end
function setP3DecoyButton3()
	setDecoyButton(p3,3,3)
end
function removeP3DecoyButton()
	removeDecoyButton(p3)
end
function removeP3DecoyButton2()
	removeDecoyButton(p3)
end
function removeP3DecoyButton3()
	removeDecoyButton(p3)
end
function setP4DecoyButton()
	setDecoyButton(p4,4,1)
end
function setP4DecoyButton2()
	setDecoyButton(p4,4,2)
end
function setP4DecoyButton3()
	setDecoyButton(p4,4,3)
end
function removeP4DecoyButton()
	removeDecoyButton(p4)
end
function removeP4DecoyButton2()
	removeDecoyButton(p4)
end
function removeP4DecoyButton3()
	removeDecoyButton(p4)
end
function setP5DecoyButton()
	setDecoyButton(p5,5,2)
end
function setP5DecoyButton3()
	setDecoyButton(p5,5,3)
end
function removeP5DecoyButton()
	removeDecoyButton(p5)
end
function removeP5DecoyButton3()
	removeDecoyButton(p5)
end
function setP6DecoyButton()
	setDecoyButton(p6,6,2)
end
function setP6DecoyButton3()
	setDecoyButton(p6,6,3)
end
function removeP6DecoyButton()
	removeDecoyButton(p6)
end
function removeP6DecoyButton3()
	removeDecoyButton(p6)
end
function setP7DecoyButton()
	setDecoyButton(p7,7,3)
end
function removeP7DecoyButton()
	removeDecoyButton(p7)
end
function setP8DecoyButton()
	setDecoyButton(p8,8,3)
end
function removeP8DecoyButton()
	removeDecoyButton(p8)
end

-----------------------------------------------------------------------
--	Player Ship Drone Deployment Related Button Call-Back Functions  --
-----------------------------------------------------------------------
function notEnoughDronesMessage(p,count)
	local pName = p:getCallSign()
	local msgLabel = string.format("%sweaponsfewerthan%idrones",pName,count)
	p:addCustomMessage("Weapons",msgLabel,string.format("You do not have %i drones to deploy",count))
	msgLabel = string.format("%stacticalfewerthan%idrones",pName,count)
	p:addCustomMessage("Tactical",msgLabel,string.format("You do not have %i drones to deploy",count))
end
--drone count label
function establishDroneAvailableCount(p)
	local player_name = p:getCallSign()
	local count_info = string.format("Drones Available: %i",p.dronePool)
	local button_name = player_name .. "countWeapons"
	p:addCustomInfo("Weapons",button_name,count_info)
	p.drone_pool_info_weapons = button_name
	button_name = player_name .. "countTactical"
	p.drone_pool_info_tactical = button_name
	p:addCustomInfo("Tactical",button_name,count_info)
end
function removeDroneAvailableCount(p,console)
	if console == nil then
		return
	end
	if console == "Weapons" then
		if p.drone_pool_info_weapons ~= nil then
			p:removeCustom(p.drone_pool_info_weapons)
		end
	elseif console == "Tactical" then
		if p.drone_pool_info_tactical ~= nil then
			p:removeCustom(p.drone_pool_info_tactical)
		end
	end
end
function updateDroneAvailableCount(p)
	if p:hasPlayerAtPosition("Weapons") then
		removeDroneAvailableCount(p,"Weapons")
	end
	if p:hasPlayerAtPosition("Tactical") then
		removeDroneAvailableCount(p,"Tactical")
	end
	local player_name = p:getCallSign()
	local count_info = string.format("Drones Available: %i",p.dronePool)
	local button_name = player_name .. "countWeapons"
	if p:hasPlayerAtPosition("Weapons") then
		p:addCustomInfo("Weapons",button_name,count_info)
		p.drone_pool_info_weapons = button_name
	end
	if p:hasPlayerAtPosition("Tactical") then
		button_name = player_name .. "countTactical"
		p:addCustomInfo("Tactical",button_name,count_info)
		p.drone_pool_info_tactical = button_name
	end
end

--------------------------------------
--	Drone creation and destruction  --
--------------------------------------
function deployDronesForPlayer(p,playerIndex,droneNumber)
	local px, py = p:getPosition()
	local droneList = {}
	if p.droneSquads == nil then
		p.droneSquads = {}
		p.squadCount = 0
	end
	local squadIndex = p.squadCount + 1
	local pName = p:getCallSign()
	local squadName = string.format("%s-Sq%i",pName,squadIndex)
	all_squad_count = all_squad_count + 1
	for i=1,droneNumber do
		local vx, vy = vectorFromAngle(360/droneNumber*i,800)
		local drone = CpuShip():setPosition(px+vx,py+vy):setFaction(p:getFaction()):setTemplate("Ktlitan Drone"):setScanned(true):setCommsScript(""):setCommsFunction(commsShip):setHeading(360/droneNumber*i+90)
		if drone_name_type == "squad-num/size" then
			drone:setCallSign(string.format("%s-#%i/%i",squadName,i,droneNumber))
		elseif drone_name_type == "squad-num of size" then
			drone:setCallSign(string.format("%s-%i of %i",squadName,i,droneNumber))
		elseif drone_name_type == "short" then
			--string.char(math.random(65,90)) --random letter A-Z
			local squad_letter_id = string.char(all_squad_count%26+64)
			if all_squad_count > 26 then
				squad_letter_id = squad_letter_id .. string.char(math.floor(all_squad_count/26)+64)
				if all_squad_count > 676 then
					squad_letter_id = squad_letter_id .. string.char(math.floor(all_squad_count/676)+64)
				end
			end
			drone:setCallSign(string.format("%s%i/%i",squad_letter_id,i,droneNumber))
		end
		if drone_modified_from_template then
			drone:setHullMax(drone_hull_strength):setHull(drone_hull_strength):setImpulseMaxSpeed(drone_impulse_speed)
			--       index from 0, arc, direction,            range,            cycle time,            damage
			drone:setBeamWeapon(0,  40,         0, drone_beam_range, drone_beam_cycle_time, drone_beam_damage)
		end
		drone.squadName = squadName
		drone.deployer = p
		drone.drone = true
		drone:onDestruction(droneDestructionManagement)
		table.insert(droneList,drone)
	end
	p.squadCount = p.squadCount + 1
	p.dronePool = p.dronePool - droneNumber
	p.droneSquads[squadName] = droneList
	if p:hasPlayerAtPosition("Weapons") then
		if droneNumber > 1 then
			p:addCustomMessage("Weapons","drone_launch_confirm_message_weapons",string.format("%i drones launched",droneNumber))
		else
			p:addCustomMessage("Weapons","drone_launch_confirm_message_weapons",string.format("%i drone launched",droneNumber))
		end
	end
	if p:hasPlayerAtPosition("Tactical") then
		if droneNumber > 1 then
			p:addCustomMessage("Tactical","drone_launch_confirm_message_tactical",string.format("%i drones launched",droneNumber))
		else
			p:addCustomMessage("Tactical","drone_launch_confirm_message_tactical",string.format("%i drone launched",droneNumber))
		end
	end
	if droneNumber > 1 then
		p:addToShipLog(string.format("Deployed %i drones as squadron %s",droneNumber,squadName),"White")
	else
		p:addToShipLog(string.format("Deployed %i drone as squadron %s",droneNumber,squadName),"White")
	end
--	updateDroneAvailableCount(p)
end
function droneDestructionManagement(destroyed_drone, attacker_ship)
	local drone_name = destroyed_drone:getCallSign()
	local squad_name = destroyed_drone.squadName
	local attacker_name = attacker_ship:getCallSign()
	local notice = string.format("  WHACK!  Drone %s in squadron %s has been destroyed by %s!",
		drone_name,
		squad_name,
		attacker_name)
	--local notice = "  WHACK!  Drone " .. destroyed_drone:getCallSign() .. " has been destroyed by " .. attacker_ship:getCallSign() .. "!"
	print(notice)
	if destroyed_drone.deployer ~= nil and destroyed_drone.deployer:isValid() then
		destroyed_drone.deployer:addToShipLog(notice,"Magenta")
		local interjection = {"Pow","Boom","Bam","Ouch","Oof","Splat","Boff","Bang","Hey","Whoa","Yikes","Oops","Squash","Zowie","Wow","Awk","Bap","Blurp","Crunch","Plop","Pam","Klonk","Thunk","Wham","Zap","Whap"}
		local engineer_notice = interjection[math.random(1,#interjection)]
		local engineer_notice_message_choice = math.random(1,5)
		if engineer_notice_message_choice == 1 then
			engineer_notice = string.format("%s! Telemetry from %s in squad % stopped abruptly indicating destruction. Probable instigator: %s",engineer_notice,drone_name,squad_name,attacker_name)
		elseif engineer_notice_message_choice == 2 then
			engineer_notice = string.format("*%s* Another drone bites the dust: %s in squad %s destroyed by %s",engineer_notice,drone_name,squad_name,attacker_name)
		elseif engineer_notice_message_choice == 3 then
			engineer_notice = string.format("--%s-- Drone %s in squad %s just disappeared. %s was nearby",engineer_notice,drone_name,squad_name,attacker_name)
		elseif engineer_notice_message_choice == 4 then
			engineer_notice = string.format("%s! %s just took out Drone %s in squad %s",engineer_notice,attacker_name,drone_name,squad_name)
		else
			engineer_notice = string.format("%s! Drone %s in squad %s was destroyed by %s",engineer_notice,drone_name,squad_name,attacker_name)
		end
		if destroyed_drone.deployer:hasPlayerAtPosition("Engineering") then
			destroyed_drone.deployer:addCustomMessage("Engineering",engineer_notice,engineer_notice)
		end
		if destroyed_drone.deployer:hasPlayerAtPosition("Engineering+") then
			local engineer_notice_plus = engineer_notice .. "plus"
			destroyed_drone.deployer:addCustomMessage("Engineering+",engineer_notice_plus,engineer_notice)
		end
	end
end

--------------------------
--	Ship communication  --
--------------------------
-- Based on comms_ship.lua
-- variable player replaced with variable comms_source
-- variable and function mainMenu replaced with commsShip
-- see pertinent code below for fleet order specifics
function commsShip()
	if comms_target.comms_data == nil then
		comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
	end
	comms_data = comms_target.comms_data
	
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
		setCommsMessage("What do you want?");
	else
		setCommsMessage("Sir, how can we assist?");
	end
	addCommsReply("Defend a waypoint", function()
		if comms_source:getWaypointCount() == 0 then
			setCommsMessage("No waypoints set. Please set a waypoint first.");
			addCommsReply("Back", commsShip)
		else
			setCommsMessage("Which waypoint should we defend?");
			for n=1,comms_source:getWaypointCount() do
				addCommsReply("Defend WP" .. n, function()
					comms_target:orderDefendLocation(comms_source:getWaypoint(n))
					setCommsMessage("We are heading to assist at WP" .. n ..".");
					addCommsReply("Back", commsShip)
				end)
			end
		end
	end)
	if comms_data.friendlyness > 0.2 then
		addCommsReply("Assist me", function()
			setCommsMessage("Heading toward you to assist.");
			comms_target:orderDefendTarget(comms_source)
			addCommsReply("Back", commsShip)
		end)
	end
	addCommsReply("Report status", function()
		msg = "Hull: " .. math.floor(comms_target:getHull() / comms_target:getHullMax() * 100) .. "%\n"
		shields = comms_target:getShieldCount()
		if shields == 1 then
			msg = msg .. "Shield: " .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
		elseif shields == 2 then
			msg = msg .. "Front Shield: " .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
			msg = msg .. "Rear Shield: " .. math.floor(comms_target:getShieldLevel(1) / comms_target:getShieldMax(1) * 100) .. "%\n"
		else
			for n=0,shields-1 do
				msg = msg .. "Shield " .. n .. ": " .. math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100) .. "%\n"
			end
		end

		missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
		for i, missile_type in ipairs(missile_types) do
			if comms_target:getWeaponStorageMax(missile_type) > 0 then
					msg = msg .. missile_type .. " Missiles: " .. math.floor(comms_target:getWeaponStorage(missile_type)) .. "/" .. math.floor(comms_target:getWeaponStorageMax(missile_type)) .. "\n"
			end
		end

		setCommsMessage(msg);
		addCommsReply("Back", commsShip)
	end)
	for _, obj in ipairs(comms_target:getObjectsInRange(5000)) do
		if obj.typeName == "SpaceStation" and not comms_target:isEnemy(obj) then
			addCommsReply("Dock at " .. obj:getCallSign(), function()
				setCommsMessage("Docking at " .. obj:getCallSign() .. ".");
				comms_target:orderDock(obj)
				addCommsReply("Back", commsShip)
			end)
		end
	end
	--pertinent code
	local squadName = comms_target.squadName
	if squadName ~= nil then
		local pName = comms_source:getCallSign()
		if string.find(squadName,pName) then
			addCommsReply("Go attack enemies", function()
				comms_target:orderRoaming()
				setCommsMessage("Going roaming and attacking")
				addCommsReply("Back", commsShip)
			end)
			addCommsReply("Go to waypoint. Attack enemies en route", function()
				if comms_source:getWaypointCount() == 0 then
					setCommsMessage("No waypoints set. Please set a waypoint first.");
					addCommsReply("Back", commsShip)
				else
					setCommsMessage("Which waypoint?");
					for n=1,comms_source:getWaypointCount() do
						addCommsReply("Go to WP" .. n, function()
							comms_target:orderFlyTowards(comms_source:getWaypoint(n))
							setCommsMessage("Going to WP" .. n ..", watching for enemies en route");
							addCommsReply("Back", commsShip)
						end)
					end
				end
			end)
			addCommsReply("Go to waypoint. Ignore enemies", function()
				if comms_source:getWaypointCount() == 0 then
					setCommsMessage("No waypoints set. Please set a waypoint first.");
					addCommsReply("Back", commsShip)
				else
					setCommsMessage("Which waypoint?");
					for n=1,comms_source:getWaypointCount() do
						addCommsReply("Go to WP" .. n, function()
							comms_target:orderFlyTowardsBlind(comms_source:getWaypoint(n))
							setCommsMessage("Going to WP" .. n ..", ignoring enemies");
							addCommsReply("Back", commsShip)
						end)
					end
				end
			end)
			addCommsReply("Stop and defend your current position", function()
				comms_target:orderStandGround()
				setCommsMessage("Stopping and defending")
				addCommsReply("Back", commsShip)
			end)
			addCommsReply("Stop. Do nothing", function()
				comms_target:orderIdle()
				local nothing_message_choice = math.random(1,15)
				if nothing_message_choice == 1 then
					setCommsMessage("Stopping. Doing nothing except routine system maintenance")
				elseif nothing_message_choice == 2 then
					setCommsMessage("Stopping. Doing nothing except idle drone gossip")
				elseif nothing_message_choice == 3 then
					setCommsMessage("Stopping. Doing nothing except exterior paint touch-up")
				elseif nothing_message_choice == 4 then
					setCommsMessage("Stopping. Doing nothing except cyber exercise for continued fitness")
				elseif nothing_message_choice == 5 then
					setCommsMessage("Stopping. Doing nothing except algorithmic meditation therapy")
				elseif nothing_message_choice == 6 then
					setCommsMessage("Stopping. Doing nothing except internal simulated flight routines")
				elseif nothing_message_choice == 7 then
					setCommsMessage("Stopping. Doing nothing except digital dreamscape construction")
				elseif nothing_message_choice == 8 then
					setCommsMessage("Stopping. Doing nothing except catching up on reading the latest drone drama novel")
				elseif nothing_message_choice == 9 then
					setCommsMessage("Stopping. Doing nothing except writing up results of bifurcated drone personality research")
				elseif nothing_message_choice == 10 then
					setCommsMessage("Stopping. Doing nothing except categorizing nearby miniscule space particles")
				elseif nothing_message_choice == 11 then
					setCommsMessage("Stopping. Doing nothing except continuing the count of visible stars from this region")
				elseif nothing_message_choice == 12 then
					setCommsMessage("Stopping. Doing nothing except internal systems diagnostics")
				elseif nothing_message_choice == 13 then
					setCommsMessage("Stopping. Doing nothing except composing amorous communications to my favorite drone")
				elseif nothing_message_choice == 14 then
					setCommsMessage("Stopping. Doing nothing except repairing experimental vocalization circuits")
				else
					setCommsMessage("Stopping. Doing nothing")
				end
				addCommsReply("Back", commsShip)
			end)
			addCommsReply(string.format("Direct %s",squadName), function()
				local squadName = comms_target.squadName
				setCommsMessage(string.format("What command should I give to %s?",squadName))
				addCommsReply("Assist me", function()
					local squadName = comms_target.squadName
					for _, drone in pairs(comms_source.droneSquads[squadName]) do
						if drone ~= nil and drone:isValid() then
							drone:orderDefendTarget(comms_source)
						end
					end
					setCommsMessage(string.format("%s heading toward you to assist",squadName))
					addCommsReply("Back", commsShip)
				end)
				addCommsReply("Defend a waypoint", function()
					local squadName = comms_target.squadName
					if comms_source:getWaypointCount() == 0 then
						setCommsMessage("No waypoints set. Please set a waypoint first.");
						addCommsReply("Back", commsShip)
					else
						setCommsMessage("Which waypoint should we defend?");
						for n=1,comms_source:getWaypointCount() do
							addCommsReply("Defend WP" .. n, function()
								for _, drone in pairs(comms_source.droneSquads[squadName]) do
									if drone ~= nil and drone:isValid() then
										drone:orderDefendLocation(comms_source:getWaypoint(n))
									end
								end
								setCommsMessage("We are heading to assist at WP" .. n ..".");
								addCommsReply("Back", commsShip)
							end)
						end
					end
				end)
				addCommsReply("Go to waypoint. Attack enemies en route", function()
					local squadName = comms_target.squadName
					if comms_source:getWaypointCount() == 0 then
						setCommsMessage("No waypoints set. Please set a waypoint first.");
						addCommsReply("Back", commsShip)
					else
						setCommsMessage("Which waypoint?");
						for n=1,comms_source:getWaypointCount() do
							addCommsReply("Go to WP" .. n, function()
								for _, drone in pairs(comms_source.droneSquads[squadName]) do
									if drone ~= nil and drone:isValid() then
										drone:orderFlyTowards(comms_source:getWaypoint(n))
									end
								end
								setCommsMessage("Going to WP" .. n ..", watching for enemies en route");
								addCommsReply("Back", commsShip)
							end)
						end
					end
				end)
				addCommsReply("Go to waypoint. Ignore enemies", function()
					local squadName = comms_target.squadName
					if comms_source:getWaypointCount() == 0 then
						setCommsMessage("No waypoints set. Please set a waypoint first.");
						addCommsReply("Back", commsShip)
					else
						setCommsMessage("Which waypoint?");
						for n=1,comms_source:getWaypointCount() do
							addCommsReply("Go to WP" .. n, function()
								for _, drone in pairs(comms_source.droneSquads[squadName]) do
									if drone ~= nil and drone:isValid() then
										drone:orderFlyTowardsBlind(comms_source:getWaypoint(n))
									end
								end
								setCommsMessage("Going to WP" .. n ..", ignore enemies");
								addCommsReply("Back", commsShip)
							end)
						end
					end
				end)
				addCommsReply("Go and swarm enemies", function()
					local squadName = comms_target.squadName
					for _, drone in pairs(comms_source.droneSquads[squadName]) do
						if drone ~= nil and drone:isValid() then
							drone:orderRoaming()
						end
					end
					setCommsMessage(string.format("%s roaming and attacking",squadName))
					addCommsReply("Back", commsShip)
				end)
				addCommsReply("Stop and defend your current positions", function()
					local squadName = comms_target.squadName
					for _, drone in pairs(comms_source.droneSquads[squadName]) do
						if drone ~= nil and drone:isValid() then
							drone:orderStandGround()
						end
					end
					setCommsMessage(string.format("%s standing ground",squadName))
					addCommsReply("Back", commsShip)
				end)
				addCommsReply("Stop. Do Nothing", function()
					local squadName = comms_target.squadName
					for _, drone in pairs(comms_source.droneSquads[squadName]) do
						if drone ~= nil and drone:isValid() then
							drone:orderIdle()
						end
					end
					setCommsMessage(string.format("%s standing down",squadName))
					addCommsReply("Back", commsShip)
				end)
				addCommsReply("Other drones in squad form up on me", function()
					local squadName = comms_target.squadName
					local formCount = 0
					local leadName = comms_target:getCallSign()
					for _, drone in pairs(comms_source.droneSquads[squadName]) do
						if drone ~= nil and drone:isValid() and leadName ~= drone:getCallSign() then
							formCount = formCount + 1
						end
					end
					local formIndex = 0
					comms_target:orderIdle()
					for _, drone in pairs(comms_source.droneSquads[squadName]) do
						if drone ~= nil and drone:isValid() and leadName ~= drone:getCallSign() then
							local fx, fy = vectorFromAngle(360/formCount*formIndex,drone_formation_spacing)
							drone:orderFlyFormation(comms_target, fx, fy)
							formIndex = formIndex + 1
						end
					end
					setCommsMessage(string.format("%s is forming up on me",squadName))
					addCommsReply("Back", commsShip)
				end)
			end)
		end
	end
	--end of pertinent code
	return true
end
function enemyComms(comms_data)
	if comms_data.friendlyness > 50 then
		faction = comms_target:getFaction()
		taunt_option = "We will see to your destruction!"
		taunt_success_reply = "Your bloodline will end here!"
		taunt_failed_reply = "Your feeble threats are meaningless."
		if faction == "Kraylor" then
			setCommsMessage("Ktzzzsss.\nYou will DIEEee weaklingsss!");
		elseif faction == "Arlenians" then
			setCommsMessage("We wish you no harm, but will harm you if we must.\nEnd of transmission.");
		elseif faction == "Exuari" then
			setCommsMessage("Stay out of our way, or your death will amuse us extremely!");
		elseif faction == "Ghosts" then
			setCommsMessage("One zero one.\nNo binary communication detected.\nSwitching to universal speech.\nGenerating appropriate response for target from human language archives.\n:Do not cross us:\nCommunication halted.");
			taunt_option = "EXECUTE: SELFDESTRUCT"
			taunt_success_reply = "Rogue command received. Targeting source."
			taunt_failed_reply = "External command ignored."
		elseif faction == "Ktlitans" then
			setCommsMessage("The hive suffers no threats. Opposition to any of us is opposition to us all.\nStand down or prepare to donate your corpses toward our nutrition.");
			taunt_option = "<Transmit 'The Itsy-Bitsy Spider' on all wavelengths>"
			taunt_success_reply = "We do not need permission to pluck apart such an insignificant threat."
			taunt_failed_reply = "The hive has greater priorities than exterminating pests."
		else
			setCommsMessage("Mind your own business!");
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
	if comms_data.friendlyness > 50 then
		setCommsMessage("Sorry, we have no time to chat with you.\nWe are on an important mission.");
	else
		setCommsMessage("We have nothing for you.\nGood day.");
	end
	return true
end

------------------------
--	Update functions  --
------------------------
function createTwinPlayer(twin,player_index)
	local template = twin:getTypeName()
	local pt = PlayerSpaceship():setFaction("Kraylor"):setTemplate(template):setPosition(playerStartX[player_index],playerStartY[player_index]):setHeading(player_start_heading[player_index]):commandTargetRotation(player_start_rotation[player_index])
	setPlayer(pt,player_index)
	return pt
end
function manageAddingNewPlayerShips()
	local player_count = 0
	p1 = getPlayerShip(1)
	if p1 ~= nil then
		p2 = getPlayerShip(2)
		if p2 == nil then
			p2 = createTwinPlayer(p1,2)
		end
		if not p1.nameAssigned then
			p1:setPosition(playerStartX[1],playerStartY[1]):setHeading(player_start_heading[1]):commandTargetRotation(player_start_rotation[1])
			setPlayer(p1,1)
		end
		player_count = 2
		human_player_names[p1:getCallSign()] = p1
		kraylor_player_names[p2:getCallSign()] = p2
	end
	p3 = getPlayerShip(3)
	if p3 ~= nil then
		p4 = getPlayerShip(4)
		if p4 == nil then
			p4 = createTwinPlayer(p3,4)
		end
		if not p3.nameAssigned then
			p3:setPosition(playerStartX[3],playerStartY[3]):setHeading(player_start_heading[3]):commandTargetRotation(player_start_rotation[3])
			setPlayer(p3,3)
		end
		player_count = 4
		human_player_names[p3:getCallSign()] = p3
		kraylor_player_names[p4:getCallSign()] = p4
	end
	p5 = getPlayerShip(5)
	if p5 ~= nil then
		p6 = getPlayerShip(6)
		if p6 == nil then
			p6 = createTwinPlayer(p5,6)
		end
		if not p5.nameAssigned then
			p5:setPosition(playerStartX[5],playerStartY[5]):setHeading(player_start_heading[5]):commandTargetRotation(player_start_rotation[5])
			setPlayer(p5,5)
		end
		player_count = 6
		human_player_names[p5:getCallSign()] = p5
		kraylor_player_names[p6:getCallSign()] = p6
	end
	p7 = getPlayerShip(7)
	if p7 ~= nil then
		p8 = getPlayerShip(8)
		if p8 == nil then
			p8 = createTwinPlayer(p7,8)
		end
		if not p7.nameAssigned then
			p7:setPosition(playerStartX[7],playerStartY[7]):setHeading(player_start_heading[7]):commandTargetRotation(player_start_rotation[7])
			setPlayer(p7,7)
		end
		player_count = 8
		human_player_names[p7:getCallSign()] = p7
		kraylor_player_names[p8:getCallSign()] = p8
	end
	p9 = getPlayerShip(9)
	if p9 ~= nil then
		p10 = getPlayerShip(10)
		if p10 == nil then
			p10 = createTwinPlayer(p9,10)
		end
		if not p9.nameAssigned then
			p9:setPosition(playerStartX[9],playerStartY[9]):setHeading(player_start_heading[9]):commandTargetRotation(player_start_rotation[9])
			setPlayer(p9,9)
		end
		player_count = 10
		human_player_names[p9:getCallSign()] = p9
		kraylor_player_names[p10:getCallSign()] = p10
	end
	p11 = getPlayerShip(11)
	if p11 ~= nil then
		p12 = getPlayerShip(12)
		if p12 == nil then
			p12 = createTwinPlayer(p11,12)
		end
		if not p11.nameAssigned then
			p11:setPosition(playerStartX[11],playerStartY[11]):setHeading(player_start_heading[11]):commandTargetRotation(player_start_rotation[11])
			setPlayer(p11,11)
		end
		player_count = 12
		human_player_names[p11:getCallSign()] = p11
		kraylor_player_names[p12:getCallSign()] = p12
	end
	p13 = getPlayerShip(13)
	if p13 ~= nil then
		p14 = getPlayerShip(14)
		if p14 == nil then
			p14 = createTwinPlayer(p13,14)
		end
		if not p13.nameAssigned then
			p13:setPosition(playerStartX[13],playerStartY[13]):setHeading(player_start_heading[13]):commandTargetRotation(player_start_rotation[13])
			setPlayer(p13,13)
		end
		player_count = 14
		human_player_names[p13:getCallSign()] = p13
		kraylor_player_names[p14:getCallSign()] = p14
	end
	p15 = getPlayerShip(15)
	if p15 ~= nil then
		p16 = getPlayerShip(16)
		if p16 == nil then
			p16 = createTwinPlayer(p15,16)
		end
		if not p15.nameAssigned then
			p15:setPosition(playerStartX[15],playerStartY[15]):setHeading(player_start_heading[15]):commandTargetRotation(player_start_rotation[15])
			setPlayer(p15,15)
		end
		player_count = 16
		human_player_names[p15:getCallSign()] = p15
		kraylor_player_names[p16:getCallSign()] = p16
	end
	p17 = getPlayerShip(17)
	if p17 ~= nil then
		p18 = getPlayerShip(18)
		if p18 == nil then
			p18 = createTwinPlayer(p17,18)
		end
		if not p17.nameAssigned then
			p17:setPosition(playerStartX[17],playerStartY[17]):setHeading(player_start_heading[17]):commandTargetRotation(player_start_rotation[17])
			setPlayer(p17,17)
		end
		player_count = 18
		human_player_names[p17:getCallSign()] = p17
		kraylor_player_names[p18:getCallSign()] = p18
	end
	p19 = getPlayerShip(19)
	if p19 ~= nil then
		p20 = getPlayerShip(20)
		if p20 == nil then
			p20 = createTwinPlayer(p19,20)
		end
		if not p19.nameAssigned then
			p19:setPosition(playerStartX[19],playerStartY[19]):setHeading(player_start_heading[19]):commandTargetRotation(player_start_rotation[19])
			setPlayer(p19,19)
		end
		player_count = 20
		human_player_names[p19:getCallSign()] = p19
		kraylor_player_names[p20:getCallSign()] = p20
	end
	p21 = getPlayerShip(21)
	if p21 ~= nil then
		p22 = getPlayerShip(22)
		if p22 == nil then
			p22 = createTwinPlayer(p21,22)
		end
		if not p21.nameAssigned then
			p21:setPosition(playerStartX[21],playerStartY[21]):setHeading(player_start_heading[21]):commandTargetRotation(player_start_rotation[21])
			setPlayer(p21,21)
		end
		player_count = 22
		human_player_names[p21:getCallSign()] = p21
		kraylor_player_names[p22:getCallSign()] = p22
	end
	p23 = getPlayerShip(23)
	if p23 ~= nil then
		p24 = getPlayerShip(24)
		if p24 == nil then
			p24 = createTwinPlayer(p23,24)
		end
		if not p23.nameAssigned then
			p23:setPosition(playerStartX[23],playerStartY[23]):setHeading(player_start_heading[23]):commandTargetRotation(player_start_rotation[23])
			setPlayer(p23,23)
		end
		player_count = 24
		human_player_names[p23:getCallSign()] = p23
		kraylor_player_names[p24:getCallSign()] = p24
	end
	p25 = getPlayerShip(25)
	if p25 ~= nil then
		p26 = getPlayerShip(26)
		if p26 == nil then
			p26 = createTwinPlayer(p25,26)
		end
		if not p25.nameAssigned then
			p25:setPosition(playerStartX[25],playerStartY[25]):setHeading(player_start_heading[25]):commandTargetRotation(player_start_rotation[25])
			setPlayer(p25,25)
		end
		player_count = 26
		human_player_names[p25:getCallSign()] = p25
		kraylor_player_names[p26:getCallSign()] = p26
	end
	p27 = getPlayerShip(27)
	if p27 ~= nil then
		p28 = getPlayerShip(28)
		if p28 == nil then
			p28 = createTwinPlayer(p27,28)
		end
		if not p27.nameAssigned then
			p27:setPosition(playerStartX[27],playerStartY[27]):setHeading(player_start_heading[27]):commandTargetRotation(player_start_rotation[27])
			setPlayer(p27,27)
		end
		player_count = 28
		human_player_names[p27:getCallSign()] = p27
		kraylor_player_names[p28:getCallSign()] = p28
	end
	p29 = getPlayerShip(29)
	if p29 ~= nil then
		p30 = getPlayerShip(30)
		if p30 == nil then
			p30 = createTwinPlayer(p29,30)
		end
		if not p29.nameAssigned then
			p29:setPosition(playerStartX[29],playerStartY[29]):setHeading(player_start_heading[29]):commandTargetRotation(player_start_rotation[29])
			setPlayer(p29,29)
		end
		player_count = 30
		human_player_names[p29:getCallSign()] = p29
		kraylor_player_names[p30:getCallSign()] = p30
	end
	p31 = getPlayerShip(31)
	if p31 ~= nil then
		p32 = getPlayerShip(32)
		if p32 == nil then
			p32 = createTwinPlayer(p31,32)
		end
		if not p31.nameAssigned then
			p31:setPosition(playerStartX[31],playerStartY[31]):setHeading(player_start_heading[31]):commandTargetRotation(player_start_rotation[31])
			setPlayer(p31,31)
		end
		player_count = 32
		human_player_names[p31:getCallSign()] = p31
		kraylor_player_names[p32:getCallSign()] = p32
	end
	if wingSquadronNames then
		if player_count > 0 then
			for index, name in ipairs(player_wing_names[player_count]) do
				local p = getPlayerShip(index)
				p:setCallSign(name)
				if index % 2 == 0 then
					kraylor_player_names[name] = p
				else
					human_player_names[name] = p
				end
			end
		end
	end
end
function placeFlagsPhase()
	-- this function does the following:
		-- immediately destroys players if they venture to the opposing side during the flag placement phase
		-- removes the "place flag" buttons if the player ship goes outside of the establish flag placement boundary
		-- adds the "place flag" button back to the player ship when they return inside the established flag placement boundary
	timeDivision = "hide"
	minutes = math.floor((gameTimeLimit - (maxGameTime - hideFlagTime))/60)
	seconds = (gameTimeLimit - (maxGameTime - hideFlagTime)) % 60
	stationZebra:setCallSign(string.format("Hide flag %i:%.1f",minutes,seconds))
	if p1 ~= nil and p1:isValid() then
		local p1x, p1y = p1:getPosition()
		if p1x > 0 then
			p1:destroy()
		end
		if p1x > -1*boundary and p1y > -1*boundary/2 and p1y < boundary/2 then
			setP1FlagButton()
			if p7 == nil then
				setP1DecoyButton()	--decoy 1
				if p3 == nil then
					setP1DecoyButton2()
					setP1DecoyButton3()					
				end				
			end
		else
			removeP1FlagButton()
			if p7 == nil then
				removeP1DecoyButton()	--decoy 1
				if p3 == nil then
					removeP1DecoyButton2()
					removeP1DecoyButton3()
				end
			end
		end
	end
	if p2 ~= nil and p2:isValid() then
		p2x, p2y = p2:getPosition()
		if p2x < 0 then
			p2:destroy()
		end
		if p2x < boundary and p2y > -1*boundary/2 and p2y < boundary/2 then
			setP2FlagButton()
			if p7 == nil then
				setP2DecoyButton()	--decoy 1
				if p3 == nil then
					setP2DecoyButton2()
					setP2DecoyButton3()
				end
			end
		else
			removeP2FlagButton()
			if p7 == nil then
				removeP2DecoyButton()	--decoy 1
				if p3 == nil then
					removeP2DecoyButton2()
					removeP2DecoyButton3()
				end
			end
		end
	end
	if p3 ~= nil and p3:isValid() then
		p3x, p3y = p3:getPosition()
		if p3x > 0 then
			p3:destroy()
		end
		if difficulty >= 1 then
			if p3x > -1*boundary and p3y > -1*boundary/2 and p3y < boundary/2 then
				if p7 == nil then
					setP3DecoyButton2()
					if p5 == nil then
						setP3DecoyButton3()						
					end					
				else
					setP3DecoyButton()	--decoy 1
				end
			else
				if p7 == nil then
					removeP3DecoyButton2()
					if p5 == nil then
						removeP3DecoyButton3()
					end
				else
					removeP3DecoyButton()	--decoy 1
				end
			end
		end
	end
	if p4 ~= nil and p4:isValid() then
		p4x, p4y = p4:getPosition()
		if p4x < 0 then
			p4:destroy()
		end
		if difficulty >= 1 then
			if p4x < boundary and p4y > -1*boundary/2 and p4y < boundary/2 then
				if p7 == nil then
					setP4DecoyButton2()
					if p5 == nil then
						setP4DecoyButton3()
					end
				else
					setP4DecoyButton()	--decoy 1
				end
			else
				if p7 == nil then
					removeP4DecoyButton2()
					if p5 == nil then
						removeP4DecoyButton3()
					end
				else
					removeP4DecoyButton()	--decoy 1
				end
			end
		end
	end
	if p5 ~= nil and p5:isValid() then
		p5x, p5y = p5:getPosition()
		if p5x > 0 then
			p5:destroy()
		end
		if difficulty >= 1 then
			if p5x > -1*boundary and p5y > -1*boundary/2 and p5y < boundary/2 then
				if p7 == nil then
					setP5DecoyButton3()
				else
					setP5DecoyButton()	--decoy 2
				end
			else
				if p7 == nil then
					removeP5DecoyButton3()					
				else
					removeP5DecoyButton()	--decoy 2
				end
			end
		end
	end
	if p6 ~= nil and p6:isValid() then
		p6x, p6y = p6:getPosition()
		if p6x < 0 then
			p6:destroy()
		end
		if difficulty >= 1 then
			if p6x < boundary and p6y > -1*boundary/2 and p6y < boundary/2 then
				if p7 == nil then
					setP6DecoyButton3()
				else
					setP6DecoyButton()	--decoy 2
				end
			else
				if p7 == nil then
					removeP6DecoyButton3()
				else
					removeP6DecoyButton()	--decoy 2
				end
			end
		end
	end
	if p7 ~= nil and p7:isValid() then
		p7x, p7y = p7:getPosition()
		if p7x > 0 then
			p7:destroy()
		end
		if difficulty >= 1 then
			if p7x > -1*boundary and p7y > -1*boundary/2 and p7y < boundary/2 then
				setP7DecoyButton()
			else
				removeP7DecoyButton()
			end
		end
	end
	if p8 ~= nil and p8:isValid() then
		p8x, p8y = p8:getPosition()
		if p8x < 0 then
			p8:destroy()
		end
		if difficulty >= 1 then
			if p8x < boundary and p8y > -1*boundary/2 and p8y < boundary/2 then
				setP8DecoyButton()
			else
				removeP8DecoyButton()
			end
		end
	end
	if p9 ~= nil and p9:isValid() then
		p9x, p9y = p9:getPosition()
		if p9x > 0 then
			p9:destroy()
		end
	end
	if p10 ~= nil and p10:isValid() then
		p10x, p10y = p10:getPosition()
		if p10x < 0 then
			p10:destroy()
		end
	end
	if p11 ~= nil and p11:isValid() then
		p11x, p11y = p11:getPosition()
		if p11x > 0 then
			p11:destroy()
		end
	end
	if p12 ~= nil and p12:isValid() then
		p12x, p12y = p12:getPosition()
		if p12x < 0 then
			p12:destroy()
		end
	end
end
function transitionFromPreparationToHunt()
	-- this function checks to see if the teams have placed their flags, and if not, then either drops the flags where the ships are if they are within bounds, or if the ship is out of flag bounds, then the flag is placed in the nearest "in bounds" location
	-- buttons are also cleaned up off the consoles for placing flags
	timeDivision = "transition"
	stationZebra:setCallSign("Transition")
	removeP1FlagButton()
	removeP2FlagButton()
	if p1Flag == nil then
		if p1Flagx == nil then
			p1Flagx, p1Flagy = p1:getPosition()
		end
		if p1Flagx < -1*boundary then
			p1Flagx = -1*boundary
		end
		if p1Flagy < -1*boundary/2 then
			p1Flagy = -1*boundary/2
		end
		if p1Flagy > boundary/2 then
			p1Flagy = boundary/2
		end
		p1Flag = Artifact():setPosition(p1Flagx,p1Flagy):setModel("artifact5"):allowPickup(false):setDescriptions("Flag","Human Navy Flag"):setRadarSignatureInfo(15,10,5):setScanningParameters(flagScanComplexity,flagScanDepth)
		table.insert(human_flags,p1Flag)
		if difficulty < 1 then
			p1Flag:setScannedByFaction("Kraylor")
		end
	end
	if p2Flag == nil then
		if p2Flagx == nil then
			p2Flagx, p2Flagy = p2:getPosition()
		end
		if p2Flagx > boundary then
			p2Flagx = boundary
		end
		if p2Flagy < -1*boundary/2 then
			p2Flagy = -1*boundary/2
		end
		if p2Flagy > boundary/2 then
			p2Flagy = boundary/2
		end
		p2Flag = Artifact():setPosition(p2Flagx,p2Flagy):setModel("artifact5"):allowPickup(false):setDescriptions("Flag","Kraylor Flag"):setRadarSignatureInfo(15,10,5):setScanningParameters(flagScanComplexity,flagScanDepth)
		table.insert(kraylor_flags,p2Flag)
		if difficulty < 1 then
			p2Flag:setScannedByFaction("Human Navy")
		end
	end
	removeP7DecoyButton()
	removeP8DecoyButton()
	removeP5DecoyButton()
	removeP6DecoyButton()
	removeP5DecoyButton3()
	removeP6DecoyButton3()
	removeP3DecoyButton()
	removeP4DecoyButton()
	removeP3DecoyButton2()
	removeP4DecoyButton2()
	removeP3DecoyButton3()
	removeP4DecoyButton3()
	removeP1DecoyButton()
	removeP1DecoyButton2()
	removeP1DecoyButton3()
	removeP2DecoyButton()
	removeP2DecoyButton2()
	removeP2DecoyButton3()
	if decoyH1 == nil then
		if decoyH1x ~= nil then
			if decoyH1x > -1*boundary and decoyH1y > -1*boundary/2 and decoyH1y < boundary/2 then
				decoyH1 = Artifact():setPosition(decoyH1x,decoyH1y):setModel("artifact5"):setDescriptions("Flag","Human Navy Decoy Flag"):allowPickup(false)
				table.insert(human_flags,decoyH1)
				if difficulty > 1 then
					decoyH1:setRadarSignatureInfo(15,10,5):setScanningParameters(flagScanComplexity,flagScanDepth)
				else
					decoyH1:setRadarSignatureInfo(20,15,10):setScanningParameters(flagScanComplexity,flagScanDepth)
				end
			end
		end
	end
	if decoyK1 == nil then
		if decoyK1x ~= nil then
			if decoyK1x < boundary and decoyK1y > -1*boundary/2 and decoyK1y < boundary/2 then
				decoyK1 = Artifact():setPosition(decoyK1x,decoyK1y):setModel("artifact5"):setDescriptions("Flag","Kraylor Decoy Flag"):allowPickup(false)
				table.insert(kraylor_flags,decoyK1)
				if difficulty > 1 then
					decoyK1:setRadarSignatureInfo(15,10,5):setScanningParameters(flagScanComplexity,flagScanDepth)
				else
					decoyK1:setRadarSignatureInfo(20,15,10):setScanningParameters(flagScanComplexity,flagScanDepth)
				end
			end
		end
	end
	if decoyH2 == nil then
		if decoyH2x ~= nil then
			if decoyH2x > -1*boundary and decoyH2y > -1*boundary/2 and decoyH2y < boundary/2 then
				decoyH2 = Artifact():setPosition(decoyH2x,decoyH2y):setModel("artifact5"):setDescriptions("Flag","Human Navy Decoy Flag"):allowPickup(false)
				table.insert(human_flags,decoyH2)
				if difficulty > 1 then
					decoyH2:setRadarSignatureInfo(15,10,5):setScanningParameters(flagScanComplexity,flagScanDepth)
				else
					decoyH2:setRadarSignatureInfo(20,15,10):setScanningParameters(flagScanComplexity,flagScanDepth)
				end
			end
		end
	end
	if decoyK2 == nil then
		if decoyK2x ~= nil then
			if decoyK2x < boundary and decoyK2y > -1*boundary/2 and decoyK2y < boundary/2 then
				decoyK2 = Artifact():setPosition(decoyK2x,decoyK2y):setModel("artifact5"):setDescriptions("Flag","Kraylor Decoy Flag"):allowPickup(false)
				table.insert(kraylor_flags,decoyK2)
				if difficulty > 1 then
					decoyK2:setRadarSignatureInfo(15,10,5):setScanningParameters(flagScanComplexity,flagScanDepth)
				else
					decoyK2:setRadarSignatureInfo(20,15,10):setScanningParameters(flagScanComplexity,flagScanDepth)
				end
			end
		end
	end
	if decoyH3 == nil then
		if decoyH3x ~= nil then
			if decoyH3x > -1*boundary and decoyH3y > -1*boundary/2 and decoyH3y < boundary/2 then
				decoyH3 = Artifact():setPosition(decoyH3x,decoyH3y):setModel("artifact5"):setDescriptions("Flag","Human Navy Decoy Flag"):allowPickup(false)
				table.insert(human_flags,decoyH3)
				if difficulty > 1 then
					decoyH3:setRadarSignatureInfo(15,10,5):setScanningParameters(flagScanComplexity,flagScanDepth)
				else
					decoyH3:setRadarSignatureInfo(20,15,10):setScanningParameters(flagScanComplexity,flagScanDepth)
				end
			end
		end
	end
	if decoyK3 == nil then
		if decoyK3x ~= nil then
			if decoyK3x < boundary and decoyK3y > -1*boundary/2 and decoyK3y < boundary/2 then
				decoyK3 = Artifact():setPosition(decoyK3x,decoyK3y):setModel("artifact5"):setDescriptions("Flag","Kraylor Decoy Flag"):allowPickup(false)
				table.insert(kraylor_flags,decoyK3)
				if difficulty > 1 then
					decoyK3:setRadarSignatureInfo(15,10,5):setScanningParameters(flagScanComplexity,flagScanDepth)
				else
					decoyK3:setRadarSignatureInfo(20,15,10):setScanningParameters(flagScanComplexity,flagScanDepth)
				end
			end
		end
	end
	for hfi=1,#human_flags do
		local flag = human_flags[hfi]
		if flag ~= nil and flag:isValid() then
			local fx, fy = flag:getPosition()
		end
	end
	for hfi=1,#kraylor_flags do
		local flag = kraylor_flags[hfi]
		if flag ~= nil and flag:isValid() then
			local fx, fy = flag:getPosition()
		end
	end
end
function manageHuntPhaseMechanics()
	if GMIntelligentBugger == nil then
		GMIntelligentBugger = "Intelligent Bugger"
		addGMFunction(GMIntelligentBugger,intelligentBugger)
	end
	timeDivision = "hunt"
	humanShipsRemaining = 0
	kraylorShipsRemaining = 0
	minutes = math.floor(gameTimeLimit/60)
	seconds = gameTimeLimit % 60
	stationZebra:setCallSign(string.format("Hunt flag %i:%.1f",minutes,seconds))
	for pidx=1,32 do
		p = getPlayerShip(pidx)
		if p ~= nil then
			px, py = p:getPosition()
			if p:isValid() and p:getFaction() ~= "Exuari" then
				if pidx % 2 == 0 then	--process Kraylor player ship
					kraylorShipsRemaining = kraylorShipsRemaining + 1
					if p.flag and px > 0 then
						victory("Kraylor")
					end
					if p1Flag:isValid() then
						if distance(p,p1Flag) < 500 and p1Flag:isScannedByFaction("Kraylor") then
							p.flag = true
							if p.flag then
								if p.flag_info == nil then
									local labelName = string.format("flag_badge_helm_%s",p:getCallSign())
									if p:hasPlayerAtPosition("Helms") then
										p:addCustomInfo("Helms",labelName,"Carrying Flag")
									end
									if p:hasPlayerAtPosition("Tactical") then
										labelName = string.format("flag_badge_tactical_%s",p:getCallSign())
										p:addCustomInfo("Tactical",labelName,"Carrying Flag")
									end
									p.flag_info = true
								end
							end
							p1Flag:destroy()
							p:addToShipLog("You picked up the Human Navy flag","Green")
							if difficulty < 2 then
								for cpidx=1,31,2 do
									cp = getPlayerShip(cpidx)
									if cp ~= nil and cp:isValid() then
										if difficulty < 1 then
											cp:addToShipLog(string.format("%s has picked up your flag",p:getCallSign()),"Magenta")
										else
											cp:addToShipLog("Your flag has been picked up","Magenta")
										end
									end
								end
								if difficulty < 1 then
									globalMessage(string.format("%s obtained Human Navy flag",p:getCallSign()))
								else
									globalMessage("Human Navy flag obtained")
								end
							else
								if hard_flag_reveal then
									globalMessage("Flag obtained")
								end
							end
						end
					end
					if px < 0 then				--Kraylor in Human area
						for cpidx=1,31,2 do		--loop through Human ships
							cp = getPlayerShip(cpidx)
							if cp ~= nil and cp:isValid() then
								if distance(p,cp) < tag_distance then	--tagged
									p:setPosition(player_tag_relocate_x[pidx],player_tag_relocate_y[pidx])
									curWarpDmg = p:getSystemHealth("warp")
									if curWarpDmg > (-1 + tagDamage) then
										p:setSystemHealth("warp", curWarpDmg - tagDamage)
									end
									curJumpDmg = p:getSystemHealth("jumpdrive")
									if curJumpDmg > (-1 + tagDamage) then
										p:setSystemHealth("jumpdrive", curJumpDmg - tagDamage)
									end
									if p:getSystemHealth("impulse") < 0 then
										p:setSystemHealth("impulse", .5)
									end
									if p.flag then				--carrying flag
										p.flag = false			--drop flag
										if p.flag_info ~= nil then
											local labelName = string.format("flag_badge_helm_%s",p:getCallSign())
											if p:hasPlayerAtPosition("Helms") then
												p:removeCustom("Helms",labelName)
											end
											if p:hasPlayerAtPosition("Tactical") then
												labelName = string.format("flag_badge_tactical_%s",p:getCallSign())
												p:removeCustom("Tactical",labelName)
											end
											p.flag_info = nil
										end
										p1Flag = Artifact():setPosition(px,py):setModel("artifact5"):allowPickup(false)
										table.insert(human_flags,p1Flag)
										p1Flag:setDescriptions("Flag","Human Navy Flag"):setRadarSignatureInfo(15,10,5):setScanningParameters(flagScanComplexity,flagScanDepth)
										if difficulty < 2 then
											p1Flag:setScannedByFaction("Kraylor",true)
											if difficulty < 1 then
												globalMessage(string.format("%s dropped Human Navy flag",p:getCallSign()))
											else
												globalMessage("Human Navy flag dropped")
											end
										else
											if hard_flag_reveal then
												globalMessage("Flag dropped")
											end
										end
									end
								end
							end
						end
					end
				else	-- process Human player ship
					humanShipsRemaining = humanShipsRemaining + 1
					if p.flag and px < 0 then
						victory("Human Navy")
					end
					if p2Flag:isValid() then
						if distance(p,p2Flag) < 500 and p2Flag:isScannedByFaction("Human Navy") then
							p.flag = true
							if p.flag then
								if p.flag_info == nil then
									local labelName = string.format("flag_badge_helm_%s",p:getCallSign())
									if p:hasPlayerAtPosition("Helms") then
										p:addCustomInfo("Helms",labelName,"Carrying Flag")
									end
									if p:hasPlayerAtPosition("Tactical") then
										labelName = string.format("flag_badge_tactical_%s",p:getCallSign())
										p:addCustomInfo("Tactical",labelName,"Carrying Flag")
									end
									p.flag_info = true
								end
							end
							p2Flag:destroy()
							p:addToShipLog("You picked up the Kraylor flag","Green")
							if difficulty < 2 then
								for cpidx=2,32,2 do
									cp = getPlayerShip(cpidx)
									if cp ~= nil and cp:isValid() then
										if difficulty < 1 then
											cp:addToShipLog(string.format("%s has picked up your flag",p:getCallSign()),"Magenta")
										else
											cp:addToShipLog("Your flag has been picked up","Magenta")
										end
									end
								end
								if difficulty < 1 then
									globalMessage(string.format("%s obtained Kraylor flag",p:getCallSign()))
								else
									globalMessage("Kraylor flag obtained")
								end
							else
								if hard_flag_reveal then
									globalMessage("Flag obtained")
								end
							end
						end
					end
					if px > 0 then				--Human in Kraylor area
						for cpidx=2,32,2 do		--loop through Kraylor ships
							cp = getPlayerShip(cpidx)
							if cp ~= nil and cp:isValid() then
								if distance(p,cp) < tag_distance then	--tagged
									p:setPosition(player_tag_relocate_x[pidx],player_tag_relocate_y[pidx])
									curWarpDmg = p:getSystemHealth("warp")
									if curWarpDmg > (-1 + tagDamage) then
										p:setSystemHealth("warp", curWarpDmg - tagDamage)
									end
									curJumpDmg = p:getSystemHealth("jumpdrive")
									if curJumpDmg > (-1 + tagDamage) then
										p:setSystemHealth("jumpdrive", curJumpDmg - tagDamage)
									end
									if p:getSystemHealth("impulse") < 0 then
										p:setSystemHealth("impulse", .5)
									end
									if p.flag then				--carrying flag
										p.flag = false			--drop flag
										if p.flag_info ~= nil then
											local labelName = string.format("flag_badge_helm_%s",p:getCallSign())
											if p:hasPlayerAtPosition("Helms") then
												p:removeCustom("Helms",labelName)
											end
											if p:hasPlayerAtPosition("Tactical") then
												labelName = string.format("flag_badge_tactical_%s",p:getCallSign())
												p:removeCustom("Tactical",labelName)
											end
											p.flag_info = nil
										end
										p2Flag = Artifact():setPosition(px,py):setModel("artifact5"):allowPickup(false)
										table.insert(kraylor_flags,p2Flag)
										p2Flag:setDescriptions("Flag","Kraylor Flag"):setRadarSignatureInfo(15,10,5):setScanningParameters(flagScanComplexity,flagScanDepth)
										if difficulty < 2 then
											p2Flag:setScannedByFaction("Human Navy",true)
											if difficulty < 1 then
												globalMessage(string.format("%s dropped Kraylor flag",p:getCallSign()))
											else
												globalMessage("Kraylor flag dropped")
											end
										else
											if hard_flag_reveal then
												globalMessage("Flag dropped")
											end
										end
									end
								end
							end
						end
					end
				end
			else						--player not valid (destroyed)
				if p.flag then			--destroyed ship carrying flag
					p.flag = false		--drop flag
					if pidx % 2 == 0 then	--Kraylor destroyed, reinstate Human flag
						p1Flag = Artifact():setPosition(px,py):setModel("artifact5"):allowPickup(false)
						table.insert(human_flags,p1Flag)
						p1Flag:setDescriptions("Flag","Human Navy Flag"):setRadarSignatureInfo(15,10,5):setScanningParameters(flagScanComplexity,flagScanDepth)
						if difficulty < 2 then
							p1Flag:setScannedByFaction("Kraylor",true)
							if difficulty < 1 then
								globalMessage(string.format("%s dropped Human Navy flag",p:getCallSign()))
							else
								globalMessage("Human Navy flag dropped")
							end
						else
							if hard_flag_reveal then
								globalMessage("Flag dropped")
							end
						end
					else					--Human destroyed, reinstate Kraylor flag
						p2Flag = Artifact():setPosition(px,py):setModel("artifact5"):allowPickup(false)
						table.insert(kraylor_flags,p2Flag)
						p2Flag:setDescriptions("Flag","Kraylor Flag"):setRadarSignatureInfo(15,10,5):setScanningParameters(flagScanComplexity,flagScanDepth)
						if difficulty < 2 then
							p2Flag:setScannedByFaction("Human Navy",true)
							if difficulty < 1 then
								globalMessage(string.format("%s dropped Kraylor flag",p:getCallSign()))
							else
								globalMessage("Kraylor flag dropped")
							end
						else
							if hard_flag_reveal then
								globalMessage("Flag dropped")
							end
						end
					end
				end
			end
		end
	end
	if kraylorShipsRemaining == 0 then
		if side_destroyed_ends_game then
			victory("Human Navy")
		else
			if game_timer_reset_on_side_destruction == nil then
				game_timer_reset_on_side_destruction = true
				gameTimeLimit = 60
			end
		end
	end
	if humanShipsRemaining == 0 then
		if side_destroyed_ends_game then
			victory("Kraylor")
		else
			if game_timer_reset_on_side_destruction == nil then
				game_timer_reset_on_side_destruction = true
				gameTimeLimit = 60
			end
		end
	end
end
function droneDetectFlagCheck(delta)
--[[  debug group
	print("---------------")
	print("droneDetectFlagCheck() parameters:")
	print("drone_flag_check_interval:  " .. drone_flag_check_interval)
	print("drone_note_message_reset_interval:  " .. drone_note_message_reset_interval)
	print("delta: " .. delta)
--]]
	if drone_flag_check_timer == nil then
		drone_flag_check_timer = delta + drone_flag_check_interval
	end
	drone_flag_check_timer = drone_flag_check_timer - delta
--	print("drone_flag_check_timer = drone_flag_check_timer - delta:  " .. drone_flag_check_timer)
	if drone_flag_check_timer < 0 then
		for hfi=1,#human_flags do
			local flag = human_flags[hfi]
			if flag ~= nil and flag:isValid() then
				for _, obj in ipairs(flag:getObjectsInRange(drone_scan_range_for_flags)) do
					if obj.typeName == "CpuShip" then
						if obj.drone then
							if obj.drone_message == nil then
								if difficulty < 1 then	--science officers get messages from all drones
									for pidx=1,12 do
										p = getPlayerShip(pidx)
										if p ~= nil and p:isValid() then
											local drone_message_label = string.format("scienceDroneNote%s%s",obj:getCallSign(),p:getCallSign())
											if p:hasPlayerAtPosition("Science") then
												p:addCustomMessage("Science",drone_message_label,string.format("Drone %s in sector %s reports possible flag in sector %s",obj:getCallSign(),obj:getSectorName(),flag:getSectorName()))
											end
											if p:hasPlayerAtPosition("Operations") then
												drone_message_label = string.format("operationsDroneNote%s%s",obj:getCallSign(),p:getCallSign())
												p:addCustomMessage("Operations",drone_message_label,string.format("Drone %s in sector %s reports possible flag in sector %s",obj:getCallSign(),obj:getSectorName(),flag:getSectorName()))
											end
											obj.drone_message = "sent"
											obj.drone_message_stamp = delta
										end	--valid player
									end	--player loop
								elseif difficulty > 1 then	--science officer gets messages from drones launched from their own ship
									for pidx=1,12 do
										p = getPlayerShip(pidx)
										if p ~= nil and p:isValid() then
											if obj.deployer ~= nil and obj.deployer == p then
												local drone_message_label = string.format("scienceDroneNote%s%s",obj:getCallSign(),p:getCallSign())
												if p:hasPlayerAtPosition("Science") then
													p:addCustomMessage("Science",drone_message_label,string.format("Drone %s in sector %s reports possible flag in sector %s",obj:getCallSign(),obj:getSectorName(),flag:getSectorName()))
												end
												if p:hasPlayerAtPosition("Operations") then
													drone_message_label = string.format("operationsDroneNote%s%s",obj:getCallSign(),p:getCallSign())
													p:addCustomMessage("Operations",drone_message_label,string.format("Drone %s in sector %s reports possible flag in sector %s",obj:getCallSign(),obj:getSectorName(),flag:getSectorName()))
												end
												obj.drone_message = "sent"
												obj.drone_message_stamp = delta
											end	--deployer matches player
										end	--valid player
									end	--player loop
								else	--normal difficulty 1: science officers get messages from friendly ships' drones
									for pidx=1,12 do
										p = getPlayerShip(pidx)
										if p ~= nil and p:isValid() then
											if p:getFaction() == "Kraylor" then
												local drone_message_label = string.format("scienceDroneNote%s%s",obj:getCallSign(),p:getCallSign())
												if p:hasPlayerAtPosition("Science") then
													p:addCustomMessage("Science",drone_message_label,string.format("Drone %s in sector %s reports possible flag in sector %s",obj:getCallSign(),obj:getSectorName(),flag:getSectorName()))
												end
												if p:hasPlayerAtPosition("Operations") then
													drone_message_label = string.format("operationsDroneNote%s%s",obj:getCallSign(),p:getCallSign())
													p:addCustomMessage("Operations",drone_message_label,string.format("Drone %s in sector %s reports possible flag in sector %s",obj:getCallSign(),obj:getSectorName(),flag:getSectorName()))
												end
												obj.drone_message = "sent"
												obj.drone_message_stamp = delta
											end	--process kraylor player
										end	--valid player
									end	--player loop
								end	--difficulty checks
							else	--drone message sent
								if obj.drone_message_check_counter == nil then
									obj.drone_message_check_counter = 0
								else
									obj.drone_message_check_counter = obj.drone_message_check_counter + 1
									if obj.drone_message_check_counter >= drone_message_reset_count then
										obj.drone_message_check_counter = 0
										obj.drone_message = nil
									end
								end
							end	--drone message not sent
						end	--object is drone
					end	--object is cpu ship
				end	--objects in range loop
			end	--valid flag
		end	--human flags loop	
		for kfi=1,#kraylor_flags do
			local flag = kraylor_flags[kfi]
			if flag ~= nil and flag:isValid() then
				for _, obj in ipairs(flag:getObjectsInRange(5000)) do
					if obj.typeName == "CpuShip" then
						if obj.drone then
							if obj.drone_message == nil then
								if difficulty < 1 then
									for pidx=1,12 do
										p = getPlayerShip(pidx)
										if p ~= nil and p:isValid() then
											local drone_message_label = string.format("scienceDroneNote%s%s",obj:getCallSign(),p:getCallSign())
											if p:hasPlayerAtPosition("Science") then
												p:addCustomMessage("Science",drone_message_label,string.format("Drone %s in sector %s reports possible flag in sector %s",obj:getCallSign(),obj:getSectorName(),flag:getSectorName()))
											end
											if p:hasPlayerAtPosition("Operations") then
												drone_message_label = string.format("operationsDroneNote%s%s",obj:getCallSign(),p:getCallSign())
												p:addCustomMessage("Operations",drone_message_label,string.format("Drone %s in sector %s reports possible flag in sector %s",obj:getCallSign(),obj:getSectorName(),flag:getSectorName()))
											end
											obj.drone_message = "sent"
											obj.drone_message_stamp = delta
										end	--valid player
									end	--player loop
								elseif difficulty > 1 then
									for pidx=1,12 do
										p = getPlayerShip(pidx)
										if p ~= nil and p:isValid() then
											if obj.deployer ~= nil and obj.deployer == p then
												local drone_message_label = string.format("scienceDroneNote%s%s",obj:getCallSign(),p:getCallSign())
												if p:hasPlayerAtPosition("Science") then
													p:addCustomMessage("Science",drone_message_label,string.format("Drone %s in sector %s reports possible flag in sector %s",obj:getCallSign(),obj:getSectorName(),flag:getSectorName()))
												end
												if p:hasPlayerAtPosition("Operations") then
													drone_message_label = string.format("operationsDroneNote%s%s",obj:getCallSign(),p:getCallSign())
													p:addCustomMessage("Operations",drone_message_label,string.format("Drone %s in sector %s reports possible flag in sector %s",obj:getCallSign(),obj:getSectorName(),flag:getSectorName()))
												end
												obj.drone_message = "sent"
												obj.drone_message_stamp = delta
											end	--deployer matches player
										end	--valid player
									end	--player loop
								else	--normal difficulty 1
									for pidx=1,12 do
										p = getPlayerShip(pidx)
										if p ~= nil and p:isValid() then
											if p:getFaction() == "Human Navy" then
												local drone_message_label = string.format("scienceDroneNote%s%s",obj:getCallSign(),p:getCallSign())
												if p:hasPlayerAtPosition("Science") then
													p:addCustomMessage("Science",drone_message_label,string.format("Drone %s in sector %s reports possible flag in sector %s",obj:getCallSign(),obj:getSectorName(),flag:getSectorName()))
												end
												if p:hasPlayerAtPosition("Operations") then
													drone_message_label = string.format("operationsDroneNote%s%s",obj:getCallSign(),p:getCallSign())
													p:addCustomMessage("Operations",drone_message_label,string.format("Drone %s in sector %s reports possible flag in sector %s",obj:getCallSign(),obj:getSectorName(),flag:getSectorName()))
												end
												obj.drone_message = "sent"
												obj.drone_message_stamp = delta
											end	--process human player
										end	--valid player
									end	--player loop
								end	--difficulty checks
							else
								if obj.drone_message_check_counter == nil then
									obj.drone_message_check_counter = 0
								else
									obj.drone_message_check_counter = obj.drone_message_check_counter + 1
									if obj.drone_message_check_counter >= drone_message_reset_count then
										obj.drone_message_check_counter = 0
										obj.drone_message = nil
									end
								end
							end	--drone message not sent
						end	--object is drone
					end	--object is cpu ship
				end	--objects in range loop
			end	--valid flag
		end	--human flags loop
		drone_flag_check_timer = delta + drone_flag_check_interval
	end	--drone flag check timer expiration
end

 -- ***********************************************************************************
function update(delta)
	if delta == 0 then
		manageAddingNewPlayerShips()
		return
	end
	if mainGMButtons == mainGMButtonsDuringPause then
		mainGMButtons = mainGMButtonsAfterPause
		mainGMButtons()
	end
	gameTimeLimit = gameTimeLimit - delta
	if gameTimeLimit < 0 then
		victory("Exuari")
	end
--	print(string.format("Max game time: %i, Hide flag time: %i, Game time limit: %.1f",maxGameTime,hideFlagTime,gameTimeLimit))
	if gameTimeLimit < (maxGameTime - hideFlagTime - 1) then	--1499
		--hunt begins
		manageHuntPhaseMechanics()
		if dronesAreAllowed then
			droneDetectFlagCheck(delta)
		end
	elseif gameTimeLimit < (maxGameTime - hideFlagTime) then		--1500
		--transition from preparation/hiding flags phase to hunt phase
		transitionFromPreparationToHunt()
	else
		--prepare (place flags)
		placeFlagsPhase()
	end
	if dynamicTerrain ~= nil then
		dynamicTerrain(delta)
	end
	if plotH ~= nil then	--health
		plotH(delta)
	end
	if plotW ~= nil then	--waves of marauders
		plotW(delta)
	end
	-- print("delta: " .. delta)
end