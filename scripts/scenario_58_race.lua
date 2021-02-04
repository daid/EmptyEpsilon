-- Name: Fermi 500
-- Description: Race three laps of four waypoints (1 to 2 to 3 to 4 to 1 = 1 lap) in the shortest time. Play for time by yourself, but have more fun with multiple player ships.
---
--- Placement points depend on the number of racers present at the starting point when the race starts. Precise values are given to Relay at that time. Each target drone of yours shot earns one point. Shoot an opponent's drone and they get the point.
---
--- Before the race starts, scope out the course, visit some stations, maybe improve your ship for the race. But, watch your time carefully. If you are not at waypoint 1 at the start of the race, your ship will be destroyed. Your competitors may also try to destroy you despite being your nominal allies, so beware
---
--- Current version updated for online event on 23Jan2021
-- Type: Race
-- Variation[Feisty]: Target drones shoot if you get close enough
-- Variation[Raiders]: Feisty target drones *plus* enemies chase you while you race
-- Variation[Hazardous]: Feisty drones and raiders *plus* dangers along the course

require("utils.lua")

----------------------
--	Initialization  --
----------------------
function init()
	scenario_version = "2.0.0"
	print(string.format("     -----     Scenario: Fermi 500     -----     Version %s     -----",scenario_version))
	print(_VERSION)
	-- 27 types of goods so far
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
					{"battery",0}	}
	diagnostic = true
	player_count = 0
	player_start_list = {}
	player_ship_stats = {	
		["MP52 Hornet"] 		= { strength = 7, 	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 4000, probes = 10,	},
		["Piranha"]				= { strength = 16,	cargo = 8,	distance = 200,	long_range_radar = 25000, short_range_radar = 6000, probes = 15,	},
		["Flavia P.Falcon"]		= { strength = 13,	cargo = 15,	distance = 200,	long_range_radar = 40000, short_range_radar = 5000, probes = 27	,	},
		["Phobos M3P"]			= { strength = 19,	cargo = 10,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, probes = 15,	},
		["Atlantis"]			= { strength = 52,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, probes = 25,	},
		["Player Cruiser"]		= { strength = 40,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, probes = 22,	},
		["Player Missile Cr."]	= { strength = 45,	cargo = 8,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, probes = 26,	},
		["Player Fighter"]		= { strength = 7,	cargo = 3,	distance = 100,	long_range_radar = 15000, short_range_radar = 4500, probes = 11,	},
		["Benedict"]			= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, probes = 20,	},
		["Kiriya"]				= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 35000, short_range_radar = 5000, probes = 20,	},
		["Striker"]				= { strength = 8,	cargo = 4,	distance = 200,	long_range_radar = 35000, short_range_radar = 5000, probes = 17,	},
		["ZX-Lindworm"]			= { strength = 8,	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 5500, probes = 12,	},
		["Repulse"]				= { strength = 14,	cargo = 12,	distance = 200,	long_range_radar = 38000, short_range_radar = 5000, probes = 35,	},
		["Ender"]				= { strength = 100,	cargo = 20,	distance = 2000,long_range_radar = 45000, short_range_radar = 7000, probes = 24,	},
		["Nautilus"]			= { strength = 12,	cargo = 7,	distance = 200,	long_range_radar = 22000, short_range_radar = 4000, probes = 23,	},
		["Hathcock"]			= { strength = 30,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, probes = 20,	},
		["Maverick"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000, probes = 18,	},
		["Crucible"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, probes = 20,	},
	}		
	--Player ship name lists to supplant standard randomized call sign generation
	playerShipNamesFor = {}
	playerShipNamesFor["MP52 Hornet"] = {"Dragonfly","Scarab","Mantis","Yellow Jacket","Jimminy","Flik","Thorny","Buzz"}
	playerShipNamesFor["Piranha"] = {"Razor","Biter","Ripper","Voracious","Carnivorous","Characid","Vulture","Predator"}
	playerShipNamesFor["Flavia P.Falcon"] = {"Ladyhawke","Hunter","Seeker","Gyrefalcon","Kestrel","Magpie","Bandit","Buccaneer"}
	playerShipNamesFor["Phobos M3P"] = {"Blinder","Shadow","Distortion","Diemos","Ganymede","Castillo","Thebe","Retrograde"}
	playerShipNamesFor["Atlantis"] = {"Excalibur","Thrasher","Punisher","Vorpal","Protang","Drummond","Parchim","Coronado"}
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
	playerShipNamesFor["Hathcock"] = {"Hayha", "Waldron", "Plunkett", "Mawhinney", "Furlong", "Zaytsev", "Pavlichenko", "Fett", "Hawkeye", "Hanzo"}
	playerShipNamesFor["Maverick"] = {"Angel", "Thunderbird", "Roaster", "Magnifier", "Hedge"}
	playerShipNamesFor["Crucible"] = {"Sling", "Stark", "Torrid", "Kicker", "Flummox"}
	playerShipNamesFor["Leftovers"] = {
		"Adelphi",
		"Ahwahnee",
		"Akagi",
		"Akira",
		"Al-Batani",
		"Ambassador",
		"Andromeda",
		"Antares",
		"Apollo",
		"Appalachia",
		"Arcos",
		"Aries",
		"Athena",
		"Beethoven",
		"Bellerophon",
		"Biko",
		"Bonchune",
		"Bozeman",
		"Bradbury",
		"Brattain",
		"Budapest",
		"Buran",
		"Cairo",
		"Calypso",
		"Capricorn",
		"Carolina",
		"Centaur",
		"Challenger",
		"Charleston",
		"Chekov",
		"Cheyenne",
		"Clement",
		"Cochraine",
		"Columbia",
		"Concorde",
		"Constantinople",
		"Constellation",
		"Constitution",
		"Copernicus",
		"Cousteau",
		"Crazy Horse",
		"Crockett",
		"Daedalus",
		"Danube",
		"Defiant",
		"Deneva",
		"Denver",
		"Discovery",
		"Drake",
		"Endeavor",
		"Endurance",
		"Equinox",
		"Essex",
		"Exeter",
		"Farragut",
		"Fearless",
		"Fleming",
		"Foregone",
		"Fredrickson",
		"Freedom",
		"Gage",
		"Galaxy",
		"Galileo",
		"Gander",
		"Ganges",
		"Gettysburg",
		"Ghandi",
		"Goddard",
		"Grissom",
		"Hathaway",
		"Helin",
		"Hera",
		"Heracles",
		"Hokule'a",
		"Honshu",
		"Hood",
		"Hope",
		"Horatio",
		"Horizon",
		"Interceptor",
		"Intrepid",
		"Istanbul",
		"Jenolen",
		"Kearsarge",
		"Kongo",
		"Korolev",
		"Kyushu",
		"Lakota",
		"Lalo",
		"Lancer",
		"Lantree",
		"LaSalle",
		"Leeds",
		"Lexington",
		"Luna",
		"Magellan",
		"Majestic",
		"Malinche",
		"Maryland",
		"Masher",
		"Mediterranean",
		"Mekong",
		"Melbourne",
		"Merced",
		"Merrimack",
		"Miranda",
		"Nash",
		"New Orleans",
		"Newton",
		"Niagra",
		"Nobel",
		"Norway",
		"Nova",
		"Oberth",
		"Odyssey",
		"Orinoco",
		"Osiris",
		"Pasteur",
		"Pegasus",
		"Peregrine",
		"Poseidon",
		"Potempkin",
		"Princeton",
		"Prokofiev",
		"Prometheus",
		"Proxima",
		"Rabin",
		"Raman",
		"Relativity",
		"Reliant",
		"Renaissance",
		"Renegade",
		"Republic",
		"Rhode Island",
		"Rigel",
		"Righteous",
		"Rubicon",
		"Rutledge",
		"Sarajevo",
		"Saratoga",
		"Scimitar",
		"Sequoia",
		"Shenandoah",
		"ShirKahr",
		"Sitak",
		"Socrates",
		"Sovereign",
		"Spector",
		"Springfield",
		"Stargazer",
		"Steamrunner",
		"Surak",
		"Sutherland",
		"Sydney",
		"T'Kumbra",
		"Thomas Paine",
		"Thunderchild",
		"Tian An Men",
		"Titan",
		"Tolstoy",
		"Trial",
		"Trieste",
		"Trinculo",
		"Tripoli",
		"Ulysses",
		"Valdemar",
		"Valiant",
		"Volga",
		"Voyager",
		"Wambundu",
		"Waverider",
		"Wellington",
		"Wells",
		"Wyoming",
		"Yamaguchi",
		"Yamato",
		"Yangtzee Kiang",
		"Yeager",
		"Yorkshire",
		"Yorktown",
		"Yosemite",
		"Yukon",
		"Zapata",
		"Zhukov",
		"Zodiac",
	}
	control_code_stem = {	--All control codes must use capital letters or they will not work.
		"ALWAYS",
		"ASTRO",
		"BLACK",
		"BLANK",
		"BLUE",
		"BRIGHT",
		"BROWN",
		"CHAIN",
		"CHURCH",
		"CORNER",
		"DARK",
		"DOORWAY",
		"DOUBLE",
		"DULL",
		"ELBOW",
		"EMPTY",
		"EPSILON",
		"FAST",
		"FLOWER",
		"FLY",
		"FROZEN",
		"GIG",
		"GREEN",
		"GLOW",
		"HAND",
		"HAMMER",
		"INK",
		"INTEL",
		"JOUST",
		"JUMP",
		"KEY",
		"KINDLE",
		"LAP",
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
	reward_grid = {
		{10},	--1
		{10,5},	--2
		{10,5,1},	--3
		{10,5,1,0},	--4
		{10,5,1,0,0},	--5
		{10,5,3,1,0,0},	--6
		{10,5,3,1,0,0,0},	--7
		{10,7,4,2,1,0,0,0},	--8
		{10,7,4,2,1,0,0,0,0},	--9
		{10,7,4,2,1,0,0,0,0,0},	--10
		{10,7,5,3,2,1,0,0,0,0,0},	--11
		{10,7,5,3,2,1,0,0,0,0,0,0},	--12
		{10,7,5,3,2,1,0,0,0,0,0,0,0},	--13
		{10,8,6,4,3,2,1,0,0,0,0,0,0,0},	--14
		{10,8,6,4,3,2,1,0,0,0,0,0,0,0,0},	--15
		{10,8,6,5,4,3,2,1,0,0,0,0,0,0,0,0},	--16
		{10,8,6,5,4,3,2,1,0,0,0,0,0,0,0,0,0},	--17
		{10,8,6,5,4,3,2,1,0,0,0,0,0,0,0,0,0,0},	--18
		{10,8,7,6,5,4,3,2,1,0,0,0,0,0,0,0,0,0,0},	--19
		{10,8,7,6,5,4,3,2,1,0,0,0,0,0,0,0,0,0,0,0},	--20
		{10,8,7,6,5,4,3,2,1,0,0,0,0,0,0,0,0,0,0,0,0},	--21
		{10,8,7,6,5,4,3,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0},	--22
		{10,9,8,7,6,5,4,3,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0},	--23
		{10,9,8,7,6,5,4,3,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0},	--24
		{10,9,8,7,6,5,4,3,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},	--25
		{10,9,8,7,6,5,4,3,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},	--26
		{10,9,8,7,6,5,4,3,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},	--27
		{10,9,8,7,6,5,4,3,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},	--28
		{10,9,8,7,6,5,4,3,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},	--29
		{10,9,8,7,6,5,4,3,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},	--30
		{10,9,8,7,6,5,4,3,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},	--31
		{10,9,8,7,6,5,4,3,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},	--32
	}
	goods = {}
	raceStartDelay = 600		-- should be 600 for a 10 minute prep period
	racePoint1x = -4000
	racePoint1y = -4000
	raceAxis = random(0,360)+360
	leg1length = random(40000,60000)
	racePoint2x, racePoint2y = vectorFromAngle(raceAxis,leg1length)
	racePoint2x = racePoint2x + racePoint1x
	racePoint2y = racePoint2y + racePoint1y
	leg4length = random(20000,40000)
	lastAngle = raceAxis + random(30,90)
	racePoint4x, racePoint4y = vectorFromAngle(lastAngle,leg4length)
	racePoint4x = racePoint4x + racePoint1x
	racePoint4y = racePoint4y + racePoint1y
	firstAngle = raceAxis - 180 + random(30,90)
	leg2length = 1000
	repeat
		leg2length = leg2length + 10
		racePoint3x, racePoint3y = vectorFromAngle(firstAngle,leg2length)
		racePoint3x = racePoint3x + racePoint2x
		racePoint3y = racePoint3y + racePoint2y
		leg3length = distance(racePoint3x,racePoint3y,racePoint4x,racePoint4y)
		raceLength = (leg1length + leg2length + leg3length + leg4length)/1000 * 3
	until(raceLength >= 500)
	Zone():setPoints(
		racePoint1x + 500, racePoint1y + 500,
		racePoint1x - 500, racePoint1y + 500,
		racePoint1x - 500, racePoint1y - 500,
		racePoint1x + 500, racePoint1y - 500
	):setLabel("WP1"):setColor(0,64,0)
	Zone():setPoints(
		racePoint2x + 500, racePoint2y + 500,
		racePoint2x - 500, racePoint2y + 500,
		racePoint2x - 500, racePoint2y - 500,
		racePoint2x + 500, racePoint2y - 500
	):setLabel("WP2"):setColor(0,64,0)
	Zone():setPoints(
		racePoint3x + 500, racePoint3y + 500,
		racePoint3x - 500, racePoint3y + 500,
		racePoint3x - 500, racePoint3y - 500,
		racePoint3x + 500, racePoint3y - 500
	):setLabel("WP3"):setColor(0,64,0)
	Zone():setPoints(
		racePoint4x + 500, racePoint4y + 500,
		racePoint4x - 500, racePoint4y + 500,
		racePoint4x - 500, racePoint4y - 500,
		racePoint4x + 500, racePoint4y - 500
	):setLabel("WP4"):setColor(0,64,0)
	setVariations()
	patienceTimeLimit = 1800
	original_patience_time_limit = patienceTimeLimit
	raceTimer = 0
	unfinishedRacers = 0
	impulseBump = random(10,50)
	setGMButtons()
	storage = getScriptStorage()
	storage.gatherStats = gatherStats
end
function setVariations()
	if getScenarioVariation() == "Feisty" or getScenarioVariation() == "Raiders" or getScenarioVariation() == "Hazardous" then
		shootBack = true
	else
		shootBack = false
	end
	if getScenarioVariation() == "Raiders" or getScenarioVariation() == "Hazardous" then
		chasers = true
	else
		chasers = false
	end
	if getScenarioVariation() == "Hazardous" then
		hazards = true
	else
		hazards = false
	end
end
--	GM Buttons
function setGMButtons()
	mainGMButtons = mainGMButtonsDuringPause
	mainGMButtons()
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
			elseif faction_filter == "Ktlitans" then
				if p:getFaction() == "Ktlitans" then
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
		elseif code_list[name].faction == "Ktlitans" then
			faction = " (Ktlitan)"
		end
		output = output .. string.format("%s: %s %s\n",name,code_list[name].code,faction)
	end
	addGMMessage(output)
end
--	GM buttons while paused
function mainGMButtonsDuringPause()
	clearGMFunctions()
	addGMFunction(string.format("Version %s",scenario_version),function()
		local version_message = string.format("Scenario version %s\n LUA version %s",scenario_version,_VERSION)
		addGMMessage(version_message)
		print(version_message)
	end)
	addGMFunction("Show control codes",showControlCodes)
	addGMFunction(string.format("+Start Delay: %i",raceStartDelay/60),setStartDelay)
	addGMFunction(string.format("+Patience: %i",patienceTimeLimit/60),setPatienceTimeLimit)
end
function setPatienceTimeLimit()
	clearGMFunctions()
	addGMFunction("-Main",mainGMButtons)
	if patienceTimeLimit < 3000 then
		addGMFunction(string.format("%i Patience + -> %i",patienceTimeLimit/60,(patienceTimeLimit + 300)/60),function()
			patienceTimeLimit = patienceTimeLimit + 300
			original_patience_time_limit = patienceTimeLimit
			setPatienceTimeLimit()
		end)
	end
	if patienceTimeLimit > 600 then
		addGMFunction(string.format("%i Patience - -> %i",patienceTimeLimit/60,(patienceTimeLimit - 300)/60),function()
			patienceTimeLimit = patienceTimeLimit - 300
			original_patience_time_limit = patienceTimeLimit
			setPatienceTimeLimit()
		end)
	end
end
function setStartDelay()
	clearGMFunctions()
	addGMFunction("-Main",mainGMButtons)
	if raceStartDelay < 1200 then
		addGMFunction(string.format("%i Delay + -> %i",raceStartDelay/60,(raceStartDelay + 60)/60),function()
			raceStartDelay = raceStartDelay + 60
			setStartDelay()
		end)
	end
	if raceStartDelay > 60 then
		addGMFunction(string.format("%i Delay - -> %i",raceStartDelay/60,(raceStartDelay - 60)/60),function()
			raceStartDelay = raceStartDelay - 60
			setStartDelay()
		end)
	end
end
--	GM buttons after pause
function mainGMButtonsAfterPause()
	clearGMFunctions()
	addGMFunction(string.format("Version %s",scenario_version),function()
		local version_message = string.format("Scenario version %s\n LUA version %s",scenario_version,_VERSION)
		addGMMessage(version_message)
		print(version_message)
	end)
	addGMFunction("Show control codes",showControlCodes)
	addGMFunction("Show statistics",function()
		local stats = gatherStats()
		local out = "Current Statistics:\nShip: state, laps, waypoint goal, drone pts"
		for name, details in pairs(stats.ship) do
			out = out .. "\n" .. name .. ": " 
			if details.is_alive then 
				out = out .. "alive, "
			else
				out = out .. "dead, "
			end
			if details.participant ~= nil then
				out = out .. details.participant .. ", "
			end
--			if details.participant == "participant" then
--				out = out .. "participant, "
--			else
--				out = out .. "forfeit, "
--			end
			out = string.format("%s%i, %i, %i",out,details.lap_count,details.waypoint_goal,details.drone_points)
		end
		addGMMessage(out)
	end)
end

function setStations()
	afd = 30	-- asteroid field density
	stationList = {}
	totalStations = 0
	friendlyStations = 0
	neutralStations = 0
	--Timer
	stationTimer = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCommsScript(""):setCommsFunction(commsStation)
	stationTimer:setPosition(-5000,-5000):setDescription("Race Timing Facility"):setCallSign("Timer")
	table.insert(stationList,stationTimer)
	friendlyStations = friendlyStations + 1
	--Vaiken
	stationVaiken = SpaceStation():setTemplate("Huge Station"):setFaction("Human Navy"):setCommsScript(""):setCommsFunction(commsStation)
	stationVaiken:setPosition(random(-10000,5000),random(5000,9000)):setCallSign("Vaiken"):setDescription("Ship building and maintenance facility")
	table.insert(stationList,stationVaiken)
	friendlyStations = friendlyStations + 1
	goods[stationVaiken] = {{"food",10,1},{"medicine",5,5}}
	--Zefram
	stationZefram = SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCommsScript(""):setCommsFunction(commsStation)
	stationZefram:setPosition(random(5000,8000),random(-8000,9000)):setCallSign("Zefram"):setDescription("Warp Engine Components")
	table.insert(stationList,stationZefram)
	friendlyStations = friendlyStations + 1
	goods[stationZefram] = {{"warp",5,140},{"food",5,1}}
	--Marconi
	marconiAngle = random(0,360)
	xMarconi, yMarconi = vectorFromAngle(marconiAngle,random(12500,15000))
	stationMarconi = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationMarconi:setPosition(xMarconi,yMarconi):setCallSign("Marconi"):setDescription("Energy Beam Components")
	table.insert(stationList,stationMarconi)
	neutralStations = neutralStations + 1
	goods[stationMarconi] = {{"beam",5,80}}
	--Muddville
	muddAngle = marconiAngle + random(60,180)
	xMudd, yMudd = vectorFromAngle(muddAngle,random(12500,15000))
	stationMudd = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationMudd:setPosition(xMudd,yMudd):setCallSign("Muddville"):setDescription("Trading station")
	table.insert(stationList,stationMudd)
	neutralStations = neutralStations + 1
	goods[stationMudd] = {{"luxury",10,60}}
	--Alcaleica
	alcaleicaAngle = muddAngle + random(60,120)
	xAlcaleica, yAlcaleica = vectorFromAngle(alcaleicaAngle,random(12500,15000))
	stationAlcaleica = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationAlcaleica:setPosition(xAlcaleica,yAlcaleica):setCallSign("Alcaleica"):setDescription("Optical Components")
	table.insert(stationList,stationAlcaleica)
	neutralStations = neutralStations + 1
	goods[stationAlcaleica] = {{"optic",5,66}}
	--California
	stationCalifornia = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCommsScript(""):setCommsFunction(commsStation)
	stationCalifornia:setPosition(random(-90000,-70000),random(-15000,25000)):setCallSign("California"):setDescription("Mining station")
	table.insert(stationList,stationCalifornia)
	friendlyStations = friendlyStations + 1
	goods[stationCalifornia] = {{"food",2,1},{"gold",5,25},{"dilithium",2,25}}
	--Outpost-15
	stationOutpost15 = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost15:setPosition(random(35000,50000),random(52000,79000)):setCallSign("Outpost-15"):setDescription("Mining and trade")
	table.insert(stationList,stationOutpost15)
	neutralStations = neutralStations + 1
	placeRandomAroundPoint(Asteroid,25,1,15000,60000,75000)
	--Outpost-21
	stationOutpost21 = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost21:setPosition(random(50000,75000),random(52000,61250)):setCallSign("Outpost-21"):setDescription("Mining and gambling")
	table.insert(stationList,stationOutpost21)
	neutralStations = neutralStations + 1
	if random(1,100) < 50 then
		goods[stationOutpost15] = {{"luxury",5,70},{"gold",5,25}}
		goods[stationOutpost21] = {{"cobalt",4,50}}
	else
		goods[stationOutpost21] = {{"luxury",5,70},{"gold",5,25}}
		goods[stationOutpost15] = {{"cobalt",4,50}}
	end
	--Valero
	stationValero = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationValero:setPosition(random(-88000,-65000),random(36250,40000)):setCallSign("Valero"):setDescription("Resupply")
	table.insert(stationList,stationValero)
	neutralStations = neutralStations + 1
	goods[stationValero] = {{"luxury",5,77}}
	--Vactel
	vactelAngle = random(0,360)
	xVactel, yVactel = vectorFromAngle(vactelAngle,random(50000,61250))
	stationVactel = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationVactel:setPosition(xVactel,yVactel):setCallSign("Vactel"):setDescription("Shielded Circuitry Fabrication")
	table.insert(stationList,stationVactel)
	neutralStations = neutralStations + 1
	goods[stationVactel] = {{"circuit",5,50}}
	--Archer
	archerAngle = vactelAngle + random(60,120)
	xArcher, yArcher = vectorFromAngle(archerAngle,random(50000,61250))
	stationArcher = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationArcher:setPosition(xArcher,yArcher):setCallSign("Archer"):setDescription("Shield and Armor Research")
	table.insert(stationList,stationArcher)
	neutralStations = neutralStations + 1
	goods[stationArcher] = {{"shield",5,90}}
	--Deer
	deerAngle = archerAngle + random(60,120)
	xDeer, yDeer = vectorFromAngle(deerAngle,random(50000,61250))
	stationDeer = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationDeer:setPosition(xDeer,yDeer):setCallSign("Deer"):setDescription("Repulsor and Tractor Beam Components")
	table.insert(stationList,stationDeer)
	neutralStations = neutralStations + 1
	goods[stationDeer] = {{"tractor",5,90},{"repulsor",5,95}}
	--Cavor
	cavorAngle = deerAngle + random(60,90)
	xCavor, yCavor = vectorFromAngle(cavorAngle,random(50000,61250))
	stationCavor = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationCavor:setPosition(xCavor,yCavor):setCallSign("Cavor"):setDescription("Advanced Material components")
	table.insert(stationList,stationCavor)
	neutralStations = neutralStations + 1
	goods[stationCavor] = {{"filament",5,42}}
	--Emory
	stationEmory = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCommsScript(""):setCommsFunction(commsStation)
	stationEmory:setPosition(random(72000,85000),random(-50000,-26000)):setCallSign("Emory"):setDescription("Transporter Components")
	table.insert(stationList,stationEmory)
	friendlyStations = friendlyStations + 1
	goods[stationEmory] = {{"transporter",5,63},{"food",2,1}}
	--Veloquan
	stationVeloquan = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationVeloquan:setPosition(random(-25000,15000),random(27000,40000)):setCallSign("Veloquan"):setDescription("Sensor components")
	table.insert(stationList,stationVeloquan)
	neutralStations = neutralStations + 1
	goods[stationVeloquan] = {{"sensor",5,68}}
	--Barclay
	stationBarclay = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationBarclay:setPosition(random(-20000,0),random(-45000,-25000)):setCallSign("Barclay"):setDescription("Communications components")
	table.insert(stationList,stationBarclay)
	neutralStations = neutralStations + 1
	goods[stationBarclay] = {{"communication",5,58}}
	--Lipkin
	stationLipkin = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationLipkin:setPosition(random(20000,45000),random(-25000,-15000)):setCallSign("Lipkin"):setDescription("Autodoc components")
	table.insert(stationList,stationLipkin)
	neutralStations = neutralStations + 1
	goods[stationLipkin] = {{"autodoc",5,76}}
	--Ripley
	stationRipley = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationRipley:setPosition(random(-75000,-30000),random(55000,62150)):setCallSign("Ripley"):setDescription("Load Lifters and components")
	table.insert(stationList,stationRipley)
	neutralStations = neutralStations + 1
	goods[stationRipley] = {{"lifter",5,61}}
	--Deckard
	stationDeckard = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationDeckard:setPosition(random(-45000,-25000),random(-25000,-14000)):setCallSign("Deckard"):setDescription("Android components")
	table.insert(stationList,stationDeckard)
	neutralStations = neutralStations + 1
	goods[stationDeckard] = {{"android",5,73}}
	--Conner
	stationConnor = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationConnor:setPosition(random(-10000,15000),random(15000,27000)):setCallSign("Connor"):setDescription("Weapons Automation components")
	table.insert(stationList,stationConnor)
	neutralStations = neutralStations + 1
	--Anderson
	stationAnderson = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationAnderson:setPosition(random(15000,20000),random(-25000,48000)):setCallSign("Anderson"):setDescription("Battery and Software Engineering")
	table.insert(stationList,stationAnderson)
	neutralStations = neutralStations + 1
	goods[stationAnderson] = {{"battery",5,65},{"software",5,115}}
	--Feynman
	stationFeynman = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCommsScript(""):setCommsFunction(commsStation)
	stationFeynman:setPosition(random(-90000,-55000),random(25000,36250)):setCallSign("Feynman"):setDescription("Nanotechnology Research")
	table.insert(stationList,stationFeynman)
	friendlyStations = friendlyStations + 1
	goods[stationFeynman] = {{"nanites",5,79},{"software",5,115},{"food",2,1}}
	--Mayo
	stationMayo = SpaceStation():setTemplate("Large Station"):setFaction("Human Navy"):setCommsScript(""):setCommsFunction(commsStation)
	stationMayo:setPosition(random(-45000,-30000),random(-14000,12500)):setCallSign("Mayo"):setDescription("Medical Research")
	table.insert(stationList,stationMayo)
	friendlyStations = friendlyStations + 1
	goods[stationMayo] = {{"food",5,1},{"medicine",5,5}}
	--Nefatha
	stationNefatha = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationNefatha:setPosition(random(-10000,12500),random(-96000,-80000)):setCallSign("Nefatha"):setDescription("Commerce and recreation")
	table.insert(stationList,stationNefatha)
	neutralStations = neutralStations + 1
	goods[stationNefatha] = {{"luxury",5,70}}
	--Science-4
	stationScience4 = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationScience4:setPosition(random(-60000,-40000),random(47000,55000)):setCallSign("Science-4"):setDescription("Biotech research")
	table.insert(stationList,stationScience4)
	neutralStations = neutralStations + 1
	--Speculation-4
	stationSpeculation4 = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationSpeculation4:setPosition(random(-26000,-15000),random(-10000,27000)):setCallSign("Speculation-4"):setDescription("Trading post")
	table.insert(stationList,stationSpeculation4)
	neutralStations = neutralStations + 1
	goods[stationSpeculation4] = {{"luxury",5,65}}
	--Tiberius
	stationTiberius = SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCommsScript(""):setCommsFunction(commsStation)
	stationTiberius:setPosition(random(-30000,-26000),random(-14000,35000)):setCallSign("Tiberius"):setDescription("Logistics coordination")
	table.insert(stationList,stationTiberius)
	friendlyStations = friendlyStations + 1
	goods[stationTiberius] = {{"food",5,1}}
	--Research-1
	stationResearch11 = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationResearch11:setPosition(random(-75000,-55000),random(-50000,-25000)):setCallSign("Research-11"):setDescription("Low Gravity Research")
	table.insert(stationList,stationResearch11)
	neutralStations = neutralStations + 1
	--Freena
	stationFreena = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationFreena:setPosition(random(0,15000),irandom(-37500,-15000)):setCallSign("Freena"):setDescription("Zero gravity sports")
	table.insert(stationList,stationFreena)
	neutralStations = neutralStations + 1
	--Outpost-33
	stationOutpost33 = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost33:setPosition(random(15000,65000),random(-65000,-25000)):setCallSign("Outpost-33"):setDescription("Resupply")
	table.insert(stationList,stationOutpost33)
	neutralStations = neutralStations + 1
	goods[stationOutpost33] = {{"luxury",5,75}}
	--Lando
	stationLando = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationLando:setPosition(random(-60000,-30000),random(612500,70000)):setCallSign("Lando"):setDescription("Casino and Gambling")
	table.insert(stationList,stationLando)
	neutralStations = neutralStations + 1
	--Komov
	stationKomov = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationKomov:setPosition(random(-55000,-30000),random(70000,80000)):setCallSign("Komov"):setDescription("Xenopsychology research")
	table.insert(stationList,stationKomov)
	neutralStations = neutralStations + 1
	--Science-2
	stationScience2 = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationScience2:setPosition(random(20000,35000),random(55000,70000)):setCallSign("Science-2"):setDescription("Research Lab and Observatory")
	table.insert(stationList,stationScience2)
	neutralStations = neutralStations + 1
	--Prefect
	stationPrefect = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationPrefect:setPosition(random(-65000,-60000),random(36250,55000)):setCallSign("Prefect"):setDescription("Textile and Fashion Creation")
	table.insert(stationList,stationPrefect)
	neutralStations = neutralStations + 1
	goods[stationPrefect] = {{"luxury",5,45}}
	--Outpost-7
	stationOutpost7 = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost7:setPosition(random(35000,45000),random(-15000,25000)):setCallSign("Outpost-7"):setDescription("Resupply")
	table.insert(stationList,stationOutpost7)
	neutralStations = neutralStations + 1
	goods[stationOutpost7] = {{"luxury",5,80}}
	--Organa
	stationOrgana = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationOrgana:setPosition(irandom(55000,62000),random(20000,45000)):setCallSign("Organa"):setDescription("Diplomatic training")
	table.insert(stationList,stationOrgana)
	neutralStations = neutralStations + 1
	--Grap
	stationGrap = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	xGrap = random(-20000,0)
	yGrap = random(-25000,-20000)
	stationGrap:setPosition(xGrap,yGrap):setCallSign("Grap"):setDescription("Mining station")
	posAxisGrap = random(0,360)
	posGrap = random(10000,60000)
	negGrap = random(10000,60000)
	spreadGrap = random(4000,8000)
	negAxisGrap = posAxisGrap + 180
	xPosAngleGrap, yPosAngleGrap = vectorFromAngle(posAxisGrap, posGrap)
	posEnd = random(40,90)
	createRandomAlongArc(Asteroid, afd+posEnd, xGrap+xPosAngleGrap, yGrap+yPosAngleGrap, posGrap, negAxisGrap, negAxisGrap+posEnd, spreadGrap)
	xNegAngleGrap, yNegAngleGrap = vectorFromAngle(negAxisGrap, negGrap)
	negEnd = random(20,60)
	createRandomAlongArc(Asteroid, afd+negEnd, xGrap+xNegAngleGrap, yGrap+yNegAngleGrap, negGrap, posAxisGrap, posAxisGrap+negEnd, spreadGrap)
	table.insert(stationList,stationGrap)
	neutralStations = neutralStations + 1
	--Grup
	stationGrup = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	xGrup = random(-20000,-10000)
	yGrup = random(15000,30000)
	stationGrup:setPosition(xGrup,yGrup):setCallSign("Grup"):setDescription("Mining station")
	axisGrup = random(0,360)
	longGrup = random(30000,60000)
	shortGrup = random(10000,30000)
	spreadGrup = random(5000,8000)
	negAxisGrup = axisGrup + 180
	xLongAngleGrup, yLongAngleGrup = vectorFromAngle(axisGrup, longGrup)
	longGrupEnd = random(30,70)
	createRandomAlongArc(Asteroid, afd+longGrupEnd, xGrup+xLongAngleGrup, yGrup+yLongAngleGrup, longGrup, negAxisGrup, negAxisGrup+longGrupEnd, spreadGrup)
	xShortAngleGrup, yShortAngleGrup = vectorFromAngle(axisGrup, shortGrup)
	shortGrupEnd = random(40,90)
	shortGrupEndQ = shortGrupEnd
	shortGrupEnd = negAxisGrup - shortGrupEnd
	if shortGrupEnd < 0 then 
		shortGrupEnd = shortGrupEnd + 360
	end
	createRandomAlongArc(Asteroid, afd+shortGrupEndQ, xGrup+xShortAngleGrup, yGrup+yShortAngleGrup, shortGrup, shortGrupEnd, negAxisGrup, spreadGrup)
	if random(1,100) < 50 then
		goods[stationGrap] = {{"nickel",5,20},{"tritanium",5,50}}
		goods[stationGrup] = {{"nickel",3,22},{"dilithium",5,50},{"platinum",5,70}}
	else
		goods[stationGrup] = {{"nickel",5,20},{"tritanium",5,50}}
		goods[stationGrap] = {{"nickel",3,22},{"dilithium",5,50},{"platinum",5,70}}
	end
	table.insert(stationList,stationGrup)
	neutralStations = neutralStations + 1
	--Outpost-8
	stationOutpost8 = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost8:setPosition(random(-65000,-40000),random(-61250,-50000)):setCallSign("Outpost-8")
	table.insert(stationList,stationOutpost8)
	neutralStations = neutralStations + 1
	--Science-7
	stationScience7 = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCommsScript(""):setCommsFunction(commsStation)
	stationScience7:setPosition(random(-25000,-20000),random(-40000,-10000)):setCallSign("Science-7"):setDescription("Observatory")
	table.insert(stationList,stationScience7)
	friendlyStations = friendlyStations + 1
	goods[stationScience7] = {{"food",2,1}}
	--Carradine
	stationCarradine = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationCarradine:setPosition(random(20000,35000),random(-15000,40000)):setCallSign("Carradine"):setDescription("Impulse Engine Components")
	table.insert(stationList,stationCarradine)
	neutralStations = neutralStations + 1
	goods[stationCarradine] = {{"impulse",5,100}}
	--Calvin
	stationCalvin = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationCalvin:setPosition(random(40000,86250),random(45000,51000)):setCallSign("Calvin"):setDescription("Robotic components")
	table.insert(stationList,stationCalvin)
	neutralStations = neutralStations + 1
	totalStations = neutralStations + friendlyStations
	goods[stationCalvin] = {{"robotic",5,87}}
	originalStationList = stationList	--save for statistics
	--Artifacts
	art1 = Artifact():setModel("artifact4"):allowPickup(false):setScanningParameters(2,2):setRadarSignatureInfo(random(4,20),random(2,12), random(7,13))
	art2 = Artifact():setModel("artifact5"):allowPickup(false):setScanningParameters(2,3):setRadarSignatureInfo(random(2,12),random(7,13), random(4,20))
	art3 = Artifact():setModel("artifact6"):allowPickup(false):setScanningParameters(3,2):setRadarSignatureInfo(random(7,13),random(4,20), random(2,12))
	art1:setPosition(random(-50000,50000),random(-80000,-70000))
	art2:setPosition(random(-90000,-75000),random(-40000,-20000))
	art3:setPosition(random(50000,75000),random(625000,80000))
	artChoice = math.random(6)
	if artChoice == 1 then
		art1:setDescriptions("Unusual object","Artifact with quantum biometric characteristics")
		art2:setDescriptions("Unusual object","Artifact with embedded chroniton particles")
		art3:setDescriptions("Unusual object","Artifact bridging two parallel universes")
		art1.quantum = true
		art2.chroniton = true
		art3.parallel = true
	elseif artChoice == 2 then
		art1:setDescriptions("Unusual object","Artifact with quantum biometric characteristics")
		art3:setDescriptions("Unusual object","Artifact with embedded chroniton particles")
		art2:setDescriptions("Unusual object","Artifact bridging two parallel universes")
		art1.quantum = true
		art3.chroniton = true
		art2.parallel = true
	elseif artChoice == 3 then
		art2:setDescriptions("Unusual object","Artifact with quantum biometric characteristics")
		art1:setDescriptions("Unusual object","Artifact with embedded chroniton particles")
		art3:setDescriptions("Unusual object","Artifact bridging two parallel universes")
		art2.quantum = true
		art1.chroniton = true
		art3.parallel = true
	elseif artChoice == 4 then
		art2:setDescriptions("Unusual object","Artifact with quantum biometric characteristics")
		art3:setDescriptions("Unusual object","Artifact with embedded chroniton particles")
		art1:setDescriptions("Unusual object","Artifact bridging two parallel universes")
		art2.quantum = true
		art3.chroniton = true
		art1.parallel = true
	elseif artChoice == 5 then
		art3:setDescriptions("Unusual object","Artifact with quantum biometric characteristics")
		art1:setDescriptions("Unusual object","Artifact with embedded chroniton particles")
		art2:setDescriptions("Unusual object","Artifact bridging two parallel universes")
		art3.quantum = true
		art1.chroniton = true
		art2.parallel = true
	else
		art3:setDescriptions("Unusual object","Artifact with quantum biometric characteristics")
		art2:setDescriptions("Unusual object","Artifact with embedded chroniton particles")
		art1:setDescriptions("Unusual object","Artifact bridging two parallel universes")
		art3.quantum = true
		art2.chroniton = true
		art1.parallel = true
	end
	--Ganalda
	ganaldaAngle = random(0,360)
	xGanalda, yGanalda = vectorFromAngle(ganaldaAngle,random(120000,150000))
	stationGanalda = SpaceStation():setTemplate("Medium Station"):setFaction("Kraylor")
	stationGanalda:setPosition(xGanalda,yGanalda):setCallSign("Ganalda")
	--Empok Nor
	empokAngle = ganaldaAngle + random(60,180)
	xEmpok, yEmpok = vectorFromAngle(empokAngle,random(120000,150000))
	stationEmpok = SpaceStation():setTemplate("Large Station"):setFaction("Exuari")
	stationEmpok:setPosition(xEmpok,yEmpok):setCallSign("Empok Nor")
	--Ticonderoga
	ticAngle = empokAngle + random(60,120)
	xTic, yTic = vectorFromAngle(ticAngle,random(120000,150000))
	stationTic = SpaceStation():setTemplate("Medium Station"):setFaction("Kraylor")
	stationTic:setPosition(xTic,yTic):setCallSign("Ticonderoga")
	--Nebulae
	createRandomAlongArc(Nebula, 15, 100000, -100000, 140000, 100, 170, 25000)
	Nebula():setPosition(xGanalda,yGanalda)
	gDist = distance(stationGanalda,0,0)
	createRandomAlongArc(Nebula, 5, 0, 0, gDist,ganaldaAngle-20, ganaldaAngle+20, 9000)
	--Alderaan
	alderaan= Planet():setPosition(random(-27000,32000),random(65500,87500)):setPlanetRadius(3000):setDistanceFromMovementPlane(-2000):setCallSign("Alderaan")
	alderaan:setPlanetSurfaceTexture("planets/planet-1.png"):setPlanetCloudTexture("planets/clouds-1.png")
	alderaan:setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.2,0.2,1.0)
	alderaan:setAxialRotationTime(400.0):setDescription("Lush planet with only mild seasonal variations")
	grawp = BlackHole():setPosition(random(67000,90000),random(-21000,40000))
	grawp.angle = random(0,360)
	grawp.travel = random(1,5)
	-- determine which stations will trade food, luxury items and/or medicine for their goods
	tradeFood = {}
	tradeLuxury = {}
	tradeMedicine = {}
	tradeFood[stationGrap] = true
	if random(1,100) < 50 then tradeLuxury[stationGrap] = true end
	tradeMedicine[stationGrap] = true
	tradeFood[stationGrup] = true
	tradeLuxury[stationGrup] = true
	tradeMedicine[stationGrup] = true
	tradeFood[stationOutpost15] = true
	tradeFood[stationOutpost21] = true
	tradeLuxury[stationOutpost21] = true
	if random(1,100) < 50 then tradeMedicine[stationOutpost21] = true end
	tradeLuxury[stationCarradine] = true
	tradeMedicine[stationCarradine] = true
	tradeFood[stationZefram] = true
	tradeLuxury[stationZefram] = true
	tradeLuxury[stationArcher] = true
	tradeMedicine[stationArcher] = true
	tradeFood[stationDeer] = true
	tradeLuxury[stationDeer] = true
	tradeMedicine[stationDeer] = true
	tradeFood[stationMarconi] = true
	tradeLuxury[stationMarconi] = true
	tradeFood[stationAlcaleica] = true
	tradeMedicine[stationAlcaleica] = true
	tradeLuxury[stationCalvin] = true
	whatTrade = random(1,100)
	if whatTrade < 33 then
		tradeMedicine[stationCavor] = true
	elseif whatTrade > 66 then
		tradeFood[stationCavor] = true
	else
		tradeLuxury[stationCavor] = true
	end
	tradeFood[stationEmory] = true
	tradeLuxury[stationEmory] = true
	tradeMedicine[stationEmory] = true
	tradeFood[stationVeloquan] = true
	tradeMedicine[stationVeloquan] = true
	tradeMedicine[stationBarclay] = true
	tradeFood[stationLipkin] = true
	tradeLuxury[stationLipkin] = true
	tradeMedicine[stationLipkin] = true
	tradeFood[stationRipley] = true
	tradeLuxury[stationRipley] = true
	tradeFood[stationDeckard] = true
	tradeLuxury[stationDeckard] = true
	tradeLuxury[stationAnderson] = true
	tradeFood[stationAnderson] = true
	tradeFood[stationFeynman] = true
	tradeMedicine[stationOutpost33] = true
	spinRandom = math.random(1,3)
	if spinRandom == 1 then
		spinStation = stationAlcaleica
	elseif spinRandom == 2 then
		spinStation = stationVactel
	else
		spinStation = stationDeer
	end
	spinRandom = math.random(1,3)
	if spinRandom == 1 then
		spinComponent = "lifter"
	elseif spinRandom == 2 then
		spinComponent = "software"
	else
		spinComponent = "android"
	end
	spinBump = random(20,80)
	tubeRandom = math.random(1,3)
	if tubeRandom == 1 then
		tubeStation = stationVeloquan
	elseif tubeRandom == 2 then
		tubeStation = stationOutpost33
	else
		tubeStation = stationPrefect
	end
	tubeRandom = math.random(1,3)
	if tubeRandom == 1 then
		tubeComponent = "tractor"
	elseif tubeRandom == 2 then
		tubeComponent = "nickel"
	else
		tubeComponent = "communication"
	end
	beamRangeBump = random(15,60)
	beamRandom = math.random(1,3)
	if beamRandom == 1 then
		beamComponent = "filament"
	elseif beamRandom == 2 then
		beamComponent = "battery"
	else
		beamComponent = "optic"
	end
--	hullRandom = math.random(1,3)
--	if hullRandom == 1 then
--		hullComponent = "nickel"
--	elseif hullRandom == 2 then
--		hullComponent = "tritanium"
--	else
--		hullComponent = "cobalt"
--	end
--	hullBump = random(40,80)
	shieldRandom = math.random(1,3)
	if shieldRandom == 1 then
		shieldStation = stationKomov
	elseif shieldRandom == 2 then
		shieldStation = stationOutpost8
	else
		shieldStation = stationOrgana
	end
	shieldRandom = math.random(1,3)
	if shieldRandom == 1 then
		shieldComponent = "repulsor"
	elseif shieldRandom == 2 then
		shieldComponent = "gold"
	else
		shieldComponent = "robotic"
	end
	shieldBump = random(40,80)
	energyRandom = math.random(1,3)
	if energyRandom == 1 then
		energyComponent = "beam"
	elseif energyRandom == 2 then
		energyComponent = "autodoc"
	else
		energyComponent = "warp"
	end
	if hazards then
		hazardDelayReset = 20
		hazardDelay = hazardDelayReset
		asteroid150 = {}
		ax, ay = vectorFromAngle(0,150)
		ta = Asteroid():setPosition(racePoint2x+ax,racePoint2y+ay)
		ta.angle = 0
		table.insert(asteroid150,ta)
		ax, ay = vectorFromAngle(90,150)
		ta = Asteroid():setPosition(racePoint2x+ax,racePoint2y+ay)
		ta.angle = 90
		table.insert(asteroid150,ta)
		ax, ay = vectorFromAngle(180,150)
		ta = Asteroid():setPosition(racePoint2x+ax,racePoint2y+ay)
		ta.angle = 180
		table.insert(asteroid150,ta)	
		ax, ay = vectorFromAngle(270,150)	
		ta = Asteroid():setPosition(racePoint2x+ax,racePoint2y+ay)
		ta.angle = 270
		table.insert(asteroid150,ta)	
		asteroid300 = {}
		ax, ay = vectorFromAngle(0,300)
		ta = Asteroid():setPosition(racePoint2x+ax,racePoint2y+ay)
		ta.angle = 0
		table.insert(asteroid300,ta)
		ax, ay = vectorFromAngle(90,300)
		ta = Asteroid():setPosition(racePoint2x+ax,racePoint2y+ay)
		ta.angle = 90
		table.insert(asteroid300,ta)
		ax, ay = vectorFromAngle(180,300)
		ta = Asteroid():setPosition(racePoint2x+ax,racePoint2y+ay)
		ta.angle = 180
		table.insert(asteroid300,ta)	
		ax, ay = vectorFromAngle(270,300)	
		ta = Asteroid():setPosition(racePoint2x+ax,racePoint2y+ay)
		ta.angle = 270
		table.insert(asteroid300,ta)	
		asteroid450 = {}
		ax, ay = vectorFromAngle(0,450)
		ta = Asteroid():setPosition(racePoint2x+ax,racePoint2y+ay)
		ta.angle = 0
		table.insert(asteroid450,ta)
		ax, ay = vectorFromAngle(90,450)
		ta = Asteroid():setPosition(racePoint2x+ax,racePoint2y+ay)
		ta.angle = 90
		table.insert(asteroid450,ta)
		ax, ay = vectorFromAngle(180,450)
		ta = Asteroid():setPosition(racePoint2x+ax,racePoint2y+ay)
		ta.angle = 180
		table.insert(asteroid450,ta)	
		ax, ay = vectorFromAngle(270,450)	
		ta = Asteroid():setPosition(racePoint2x+ax,racePoint2y+ay)
		ta.angle = 270
		table.insert(asteroid450,ta)	
		asteroid600 = {}
		ax, ay = vectorFromAngle(0,600)
		ta = Asteroid():setPosition(racePoint2x+ax,racePoint2y+ay)
		ta.angle = 0
		table.insert(asteroid600,ta)
		ax, ay = vectorFromAngle(90,600)
		ta = Asteroid():setPosition(racePoint2x+ax,racePoint2y+ay)
		ta.angle = 90
		table.insert(asteroid600,ta)
		ax, ay = vectorFromAngle(180,600)
		ta = Asteroid():setPosition(racePoint2x+ax,racePoint2y+ay)
		ta.angle = 180
		table.insert(asteroid600,ta)	
		ax, ay = vectorFromAngle(270,600)	
		ta = Asteroid():setPosition(racePoint2x+ax,racePoint2y+ay)
		ta.angle = 270
		table.insert(asteroid600,ta)	
		asteroid750 = {}
		ax, ay = vectorFromAngle(0,750)
		ta = Asteroid():setPosition(racePoint2x+ax,racePoint2y+ay)
		ta.angle = 0
		table.insert(asteroid750,ta)
		ax, ay = vectorFromAngle(90,750)
		ta = Asteroid():setPosition(racePoint2x+ax,racePoint2y+ay)
		ta.angle = 90
		table.insert(asteroid750,ta)
		ax, ay = vectorFromAngle(180,750)
		ta = Asteroid():setPosition(racePoint2x+ax,racePoint2y+ay)
		ta.angle = 180
		table.insert(asteroid750,ta)	
		ax, ay = vectorFromAngle(270,750)	
		ta = Asteroid():setPosition(racePoint2x+ax,racePoint2y+ay)
		ta.angle = 270
		table.insert(asteroid750,ta)	
		asteroid900 = {}
		ax, ay = vectorFromAngle(0,900)
		ta = Asteroid():setPosition(racePoint2x+ax,racePoint2y+ay)
		ta.angle = 0
		table.insert(asteroid900,ta)
		ax, ay = vectorFromAngle(90,900)
		ta = Asteroid():setPosition(racePoint2x+ax,racePoint2y+ay)
		ta.angle = 90
		table.insert(asteroid900,ta)
		ax, ay = vectorFromAngle(180,900)
		ta = Asteroid():setPosition(racePoint2x+ax,racePoint2y+ay)
		ta.angle = 180
		table.insert(asteroid900,ta)	
		ax, ay = vectorFromAngle(270,900)	
		ta = Asteroid():setPosition(racePoint2x+ax,racePoint2y+ay)
		ta.angle = 270
		table.insert(asteroid900,ta)	
		mine150 = {}
		mx, my = vectorFromAngle(0,150)
		tm = Mine():setPosition(racePoint3x+mx,racePoint3y+my)
		tm.angle = 0
		table.insert(mine150,tm)
		mx, my = vectorFromAngle(90,150)
		tm = Mine():setPosition(racePoint3x+mx,racePoint3y+my)
		tm.angle = 90
		table.insert(mine150,tm)
		mx, my = vectorFromAngle(180,150)
		tm = Mine():setPosition(racePoint3x+mx,racePoint3y+my)
		tm.angle = 180
		table.insert(mine150,tm)
		mx, my = vectorFromAngle(270,150)
		tm = Mine():setPosition(racePoint3x+mx,racePoint3y+my)
		tm.angle = 270
		table.insert(mine150,tm)
		mine300 = {}
		mx, my = vectorFromAngle(0,300)
		tm = Mine():setPosition(racePoint3x+mx,racePoint3y+my)
		tm.angle = 0
		table.insert(mine300,tm)
		mx, my = vectorFromAngle(90,300)
		tm = Mine():setPosition(racePoint3x+mx,racePoint3y+my)
		tm.angle = 90
		table.insert(mine300,tm)
		mx, my = vectorFromAngle(180,300)
		tm = Mine():setPosition(racePoint3x+mx,racePoint3y+my)
		tm.angle = 180
		table.insert(mine300,tm)
		mx, my = vectorFromAngle(270,300)
		tm = Mine():setPosition(racePoint3x+mx,racePoint3y+my)
		tm.angle = 270
		table.insert(mine300,tm)
		mine450 = {}
		mx, my = vectorFromAngle(0,450)
		tm = Mine():setPosition(racePoint3x+mx,racePoint3y+my)
		tm.angle = 0
		table.insert(mine450,tm)
		mx, my = vectorFromAngle(90,450)
		tm = Mine():setPosition(racePoint3x+mx,racePoint3y+my)
		tm.angle = 90
		table.insert(mine450,tm)
		mx, my = vectorFromAngle(180,450)
		tm = Mine():setPosition(racePoint3x+mx,racePoint3y+my)
		tm.angle = 180
		table.insert(mine450,tm)
		mx, my = vectorFromAngle(270,450)
		tm = Mine():setPosition(racePoint3x+mx,racePoint3y+my)
		tm.angle = 270
		table.insert(mine450,tm)
		mine600 = {}
		mx, my = vectorFromAngle(0,600)
		tm = Mine():setPosition(racePoint3x+mx,racePoint3y+my)
		tm.angle = 0
		table.insert(mine600,tm)
		mx, my = vectorFromAngle(90,600)
		tm = Mine():setPosition(racePoint3x+mx,racePoint3y+my)
		tm.angle = 90
		table.insert(mine600,tm)
		mx, my = vectorFromAngle(180,600)
		tm = Mine():setPosition(racePoint3x+mx,racePoint3y+my)
		tm.angle = 180
		table.insert(mine600,tm)
		mx, my = vectorFromAngle(270,600)
		tm = Mine():setPosition(racePoint3x+mx,racePoint3y+my)
		tm.angle = 270
		table.insert(mine600,tm)
		mine750 = {}
		mx, my = vectorFromAngle(0,750)
		tm = Mine():setPosition(racePoint3x+mx,racePoint3y+my)
		tm.angle = 0
		table.insert(mine750,tm)
		mx, my = vectorFromAngle(90,750)
		tm = Mine():setPosition(racePoint3x+mx,racePoint3y+my)
		tm.angle = 90
		table.insert(mine750,tm)
		mx, my = vectorFromAngle(180,750)
		tm = Mine():setPosition(racePoint3x+mx,racePoint3y+my)
		tm.angle = 180
		table.insert(mine750,tm)
		mx, my = vectorFromAngle(270,750)
		tm = Mine():setPosition(racePoint3x+mx,racePoint3y+my)
		tm.angle = 270
		table.insert(mine750,tm)
		mine900 = {}
		mx, my = vectorFromAngle(0,900)
		tm = Mine():setPosition(racePoint3x+mx,racePoint3y+my)
		tm.angle = 0
		table.insert(mine900,tm)
		mx, my = vectorFromAngle(90,900)
		tm = Mine():setPosition(racePoint3x+mx,racePoint3y+my)
		tm.angle = 90
		table.insert(mine900,tm)
		mx, my = vectorFromAngle(180,900)
		tm = Mine():setPosition(racePoint3x+mx,racePoint3y+my)
		tm.angle = 180
		table.insert(mine900,tm)
		mx, my = vectorFromAngle(270,900)
		tm = Mine():setPosition(racePoint3x+mx,racePoint3y+my)
		tm.angle = 270
		table.insert(mine900,tm)
		pacMine1000 = {}
		pmx, pmy = vectorFromAngle(0,1000)
		tpm = Mine():setPosition(racePoint4x+pmx,racePoint4y+pmy)
		tpm.angle = 0
		table.insert(pacMine1000,tpm)
		pmx, pmy = vectorFromAngle(30,1000)
		tpm = Mine():setPosition(racePoint4x+pmx,racePoint4y+pmy)
		tpm.angle = 30
		table.insert(pacMine1000,tpm)
		pmx, pmy = vectorFromAngle(60,1000)
		tpm = Mine():setPosition(racePoint4x+pmx,racePoint4y+pmy)
		tpm.angle = 60
		table.insert(pacMine1000,tpm)
		pmx, pmy = vectorFromAngle(90,1000)
		tpm = Mine():setPosition(racePoint4x+pmx,racePoint4y+pmy)
		tpm.angle = 90
		table.insert(pacMine1000,tpm)
		pmx, pmy = vectorFromAngle(120,1000)
		tpm = Mine():setPosition(racePoint4x+pmx,racePoint4y+pmy)
		tpm.angle = 120
		table.insert(pacMine1000,tpm)
		pmx, pmy = vectorFromAngle(150,1000)
		tpm = Mine():setPosition(racePoint4x+pmx,racePoint4y+pmy)
		tpm.angle = 150
		table.insert(pacMine1000,tpm)
		pmx, pmy = vectorFromAngle(180,1000)
		tpm = Mine():setPosition(racePoint4x+pmx,racePoint4y+pmy)
		tpm.angle = 180
		table.insert(pacMine1000,tpm)
		pmx, pmy = vectorFromAngle(210,1000)
		tpm = Mine():setPosition(racePoint4x+pmx,racePoint4y+pmy)
		tpm.angle = 210
		table.insert(pacMine1000,tpm)
		pmx, pmy = vectorFromAngle(240,1000)
		tpm = Mine():setPosition(racePoint4x+pmx,racePoint4y+pmy)
		tpm.angle = 240
		table.insert(pacMine1000,tpm)
		pmx, pmy = vectorFromAngle(270,1000)
		tpm = Mine():setPosition(racePoint4x+pmx,racePoint4y+pmy)
		tpm.angle = 270
		table.insert(pacMine1000,tpm)
		pacMine850 = {}
		pmx, pmy = vectorFromAngle(15,850)
		tpm = Mine():setPosition(racePoint4x+pmx,racePoint4y+pmy)
		tpm.angle = 15
		table.insert(pacMine850,tpm)
		pmx, pmy = vectorFromAngle(45,850)
		tpm = Mine():setPosition(racePoint4x+pmx,racePoint4y+pmy)
		tpm.angle = 45
		table.insert(pacMine850,tpm)
		pmx, pmy = vectorFromAngle(75,850)
		tpm = Mine():setPosition(racePoint4x+pmx,racePoint4y+pmy)
		tpm.angle = 75
		table.insert(pacMine850,tpm)
		pmx, pmy = vectorFromAngle(105,850)
		tpm = Mine():setPosition(racePoint4x+pmx,racePoint4y+pmy)
		tpm.angle = 105
		table.insert(pacMine850,tpm)
		pmx, pmy = vectorFromAngle(135,850)
		tpm = Mine():setPosition(racePoint4x+pmx,racePoint4y+pmy)
		tpm.angle = 135
		table.insert(pacMine850,tpm)
		pmx, pmy = vectorFromAngle(165,850)
		tpm = Mine():setPosition(racePoint4x+pmx,racePoint4y+pmy)
		tpm.angle = 165
		table.insert(pacMine850,tpm)
		pmx, pmy = vectorFromAngle(195,850)
		tpm = Mine():setPosition(racePoint4x+pmx,racePoint4y+pmy)
		tpm.angle = 195
		table.insert(pacMine850,tpm)
		pmx, pmy = vectorFromAngle(225,850)
		tpm = Mine():setPosition(racePoint4x+pmx,racePoint4y+pmy)
		tpm.angle = 225
		table.insert(pacMine850,tpm)
		pmx, pmy = vectorFromAngle(255,850)
		tpm = Mine():setPosition(racePoint4x+pmx,racePoint4y+pmy)
		tpm.angle = 255
		table.insert(pacMine850,tpm)
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
	arcLen = endArcClockwise - startArc
	if startArc > endArcClockwise then
		endArcClockwise = endArcClockwise + 360
		arcLen = arcLen + 360
	end
	if amount > arcLen then
		for ndex=1,arcLen do
			radialPoint = startArc+ndex
			pointDist = distance + random(-randomize,randomize)
			object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist)			
		end
		for ndex=1,amount-arcLen do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
			object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist)			
		end
	else
		for ndex=1,amount do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
			object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist)
		end
	end
end
-----------------------------
--	Station communication  --
-----------------------------
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
            Homing = 2,
            HVLI = 2,
            Mine = 2,
            Nuke = 15,
            EMP = 10
        },
        services = {
            supplydrop = "friend",
            reinforcements = "friend",
        },
        service_cost = {
            supplydrop = 100,
            reinforcements = 150,
        },
        reputation_cost_multipliers = {
            friend = 1.0,
            neutral = 2.5
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
        setCommsMessage("We are under attack! No time for chatting!");
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
		oMsg = "Good day, officer!\nWhat can we do for you today?\n"
    else
		oMsg = "Welcome to our lovely station.\n"
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. "Forgive us if we seem a little distracted. We are carefully monitoring the enemies nearby."
	end
	setCommsMessage(oMsg)
	missilePresence = 0
	local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	for _, missile_type in ipairs(missile_types) do
		missilePresence = missilePresence + comms_source:getWeaponStorageMax(missile_type)
	end
	if missilePresence > 0 then
		addCommsReply("I need ordnance restocked", function()
			setCommsMessage("What type of ordnance?")
			for _, missile_type in ipairs(missile_types) do
				if comms_source:getWeaponStorageMax(missile_type) > 0 then
					addCommsReply(missile_type .. " (" .. getWeaponCost(missile_type) .. "rep each)", function()
						handleWeaponRestock(missile_type)
					end)
				end
			end
		end)
	end
	if comms_source:isFriendly(comms_target) then
		addCommsReply("What are my current orders?", function()
			ordMsg = primaryOrders
			if raceStartDelay > 0 then
				ordMsg = ordMsg .. string.format("\n%i Seconds remain until start of race",raceStartDelay)
			else
				if comms_source.goal ~= nil then
					ordMsg = ordMsg .. string.format("\nImmediate goal: race waypoint %i",comms_source.goal)
				end
			end
			setCommsMessage(ordMsg)
			addCommsReply("Back", commsStation)
		end)
	end
	addCommsReply("Do you upgrade spaceships?", function()
		if comms_target == stationZefram then
			setCommsMessage("We can upgrade your jump drive maximum range for nanites or robotic goods")
		elseif comms_target == stationCarradine then
			setCommsMessage(string.format("We can increase the speed of your impulse engines by %.2f percent for tritanium or dilithium",impulseBump))
		elseif comms_target == spinStation then
			setCommsMessage(string.format("We can increase the speed your rotate speed by %.2f percent for %s",spinBump,spinComponent))
		elseif comms_target == stationMarconi then
			setCommsMessage(string.format("We can increase the range of your beam weapons by %.2f percent for %s",beamRangeBump,beamComponent))
		elseif comms_target == tubeStation then
			setCommsMessage(string.format("We can add a homing missile tube to your ship for %s",tubeComponent))
--			elseif comms_target == stationArcher then
--				setCommsMessage(string.format("We can upgrade the durability of your hull by %.2f percent for %s",hullBump,hullComponent))
		elseif comms_target == shieldStation then
			setCommsMessage(string.format("We can upgrade your shields by %.2f percent for %s",shieldBump,shieldComponent))
		elseif comms_target == stationNefatha then
			setCommsMessage(string.format("We can upgrade your energy capacity by 25 percent for %s",energyComponent))
		else
			setCommsMessage("We don't upgrade spaceships")
		end
	end)
	addCommsReply("Visit cartography office", function()
		if comms_target.cartographer_description == nil then
			local clerk_choice = math.random(1,3)
			if clerk_choice == 1 then
				comms_target.cartographer_description = "The clerk behind the desk looks up briefly at you then goes back to filing her nails."
			elseif clerk_choice == 2 then
				comms_target.cartographer_description = "The clerk behind the desk examines you then returns to grooming her tentacles."
			else
				comms_target.cartographer_description = "The clerk behind the desk glances at you then returns to preening her feathers."
			end
		end
		setCommsMessage(string.format("%s\n\nYou can examine the brochure on the coffee table or talk to the cartographer",comms_target.cartographer_description))
		addCommsReply("Examine brochure",function()
			setCommsMessage("The brochure has a list of nearby stations and has a list of goods nearby")
			addCommsReply("Examine station list", function()
				local brochure_stations = ""
				local sx, sy = comms_target:getPosition()
				local nearby_objects = getObjectsInRadius(sx,sy,30000)
				for _, obj in ipairs(nearby_objects) do
					if obj.typeName == "SpaceStation" then
						if not obj:isEnemy(comms_target) then
							if brochure_stations == "" then
								brochure_stations = string.format("%s %s %s",obj:getSectorName(),obj:getFaction(),obj:getCallSign())
							else
								brochure_stations = string.format("%s\n%s %s %s",brochure_stations,obj:getSectorName(),obj:getFaction(),obj:getCallSign())
							end
						end
					end
				end
				setCommsMessage(brochure_stations)
				addCommsReply("Back",commsStation)
			end)
			addCommsReply("Examine goods list", function()
				local brochure_goods = ""
				local sx, sy = comms_target:getPosition()
				local nearby_objects = getObjectsInRadius(sx,sy,30000)
				for _, obj in ipairs(nearby_objects) do
					if obj.typeName == "SpaceStation" then
						if not obj:isEnemy(comms_target) then
							if goods[obj] ~= nil then
								local gi = 1
								repeat
									if brochure_goods == "" then
										brochure_goods = string.format("Good, quantity, cost, station:\n%s, %i, %i, %s",goods[obj][gi][1],goods[obj][gi][2],goods[obj][gi][3],obj:getCallSign())
									else
										brochure_goods = string.format("%s\n%s, %i, %i, %s",brochure_goods,goods[obj][gi][1],goods[obj][gi][2],goods[obj][gi][3],obj:getCallSign())
									end
									gi = gi + 1
								until(gi > #goods[obj])
							end
						end
					end
				end
				setCommsMessage(brochure_goods)
				addCommsReply("Back",commsStation)
			end)
			addCommsReply("Back",commsStation)
		end)
		addCommsReply("Talk to apprentice cartographer", function()
			setCommsMessage("Hi, would you like for me to locate a station or some goods for you?")
			addCommsReply("Locate station", function()
				setCommsMessage("These are stations I have learned")
				local sx, sy = comms_target:getPosition()
				local nearby_objects = getObjectsInRadius(sx,sy,50000)
				local stations_known = 0
				for _, obj in ipairs(nearby_objects) do
					if obj.typeName == "SpaceStation" then
						if not obj:isEnemy(comms_target) then
							stations_known = stations_known + 1
							addCommsReply(obj:getCallSign(),function()
								local station_details = string.format("%s %s %s",obj:getSectorName(),obj:getFaction(),obj:getCallSign())
								if goods[obj] ~= nil then
									station_details = string.format("%s\nGood, quantity, cost",station_details)
									local gi = 1
									repeat
										station_details = string.format("%s\n   %s, %i, %i",station_details,goods[obj][gi][1],goods[obj][gi][2],goods[obj][gi][3])
										gi = gi + 1
									until(gi > #goods[obj])
								end
								setCommsMessage(station_details)
								addCommsReply("Back",commsStation)
							end)
						end
					end
				end
				if stations_known == 0 then
					setCommsMessage("I have learned of no stations yet")
				end
				addCommsReply("Back",commsStation)
			end)
			addCommsReply("Locate goods", function()
				setCommsMessage("These are the goods I know about")
				local sx, sy = comms_target:getPosition()
				local nearby_objects = getObjectsInRadius(sx,sy,50000)
				local button_count = 0
				local by_goods = {}
				for _, obj in ipairs(nearby_objects) do
					if obj.typeName == "SpaceStation" then
						if not obj:isEnemy(comms_target) then
							if goods[obj] ~= nil then
								station_details = string.format("%s\nGood, quantity, cost",station_details)
								local gi = 1
								repeat
									by_goods[goods[obj][gi][1]] = obj
									gi = gi + 1
								until(gi > #goods[obj])
							end
						end
					end
				end
				for good, obj in pairs(by_goods) do
					addCommsReply(good, function()
						local station_details = string.format("%s %s %s",obj:getSectorName(),obj:getFaction(),obj:getCallSign())
						if goods[obj] ~= nil then					
--						if obj.comms_data.goods ~= nil then
							station_details = string.format("%s\nGood, quantity, cost",station_details)
							local gi = 1
							repeat
								station_details = string.format("%s\n   %s, %i, %i",station_details,goods[obj][gi][1],goods[obj][gi][2],goods[obj][gi][3])
								gi = gi + 1
							until(gi > #goods[obj])
						end
						setCommsMessage(station_details)
						addCommsReply("Back",commsStation)
					end)
					button_count = button_count + 1
					if button_count >= 20 then
						break
					end
				end
				addCommsReply("Back",commsStation)
			end)
			addCommsReply("Back",commsStation)
		end)
		addCommsReply("Back",commsStation)
	end)	
	if goods[comms_target] ~= nil then
		addCommsReply("Buy, sell, trade", function()
			oMsg = "Goods or components available here: quantity, cost in reputation\n"
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
				playerGoodsType = goods[comms_source][gi][1]
				playerGoodsQuantity = goods[comms_source][gi][2]
				if playerGoodsQuantity > 0 then
					oMsg = oMsg .. string.format("     %s: %i\n",playerGoodsType,playerGoodsQuantity)
					cargoHoldEmpty = false
				end
				gi = gi + 1
			until(gi > #goods[comms_source])
			if cargoHoldEmpty then
				oMsg = oMsg .. "     Empty\n"
			end
			playerRep = math.floor(comms_source:getReputationPoints())
			oMsg = oMsg .. string.format("Available Space: %i, Available Reputation: %i\n",comms_source.cargo,playerRep)
			setCommsMessage(oMsg)
			-- Buttons for reputation purchases
			gi = 1
			repeat
				local goodsType = goods[comms_target][gi][1]
				local goodsQuantity = goods[comms_target][gi][2]
				local goodsRep = goods[comms_target][gi][3]
				addCommsReply(string.format("Buy one %s for %i reputation",goods[comms_target][gi][1],goods[comms_target][gi][3]), function()
					oMsg = string.format("Type: %s, Quantity: %i, Rep: %i",goodsType,goodsQuantity,goodsRep)
					if comms_source.cargo < 1 then
						oMsg = oMsg .. "\nInsufficient cargo space for purchase"
					elseif goodsRep > playerRep then
						oMsg = oMsg .. "\nInsufficient reputation for purchase"
					elseif goodsQuantity < 1 then
						oMsg = oMsg .. "\nInsufficient station inventory"
					else
						if not comms_source:takeReputationPoints(goodsRep) then
							oMsg = oMsg .. "\nInsufficient reputation for purchase"
						else
							comms_source.cargo = comms_source.cargo - 1
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
					if goods[comms_source][gi][1] == "food" then
						foodQuantity = goods[comms_source][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[comms_source])
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
					if goods[comms_source][gi][1] == "luxury" then
						luxuryQuantity = goods[comms_source][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[comms_source])
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
					if goods[comms_source][gi][1] == "medicine" then
						medicineQuantity = goods[comms_source][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[comms_source])
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
	end
	if comms_target == stationZefram then
		gi = 1
		naniteQuantity = 0
		roboticQuantity = 0
		repeat
			if goods[comms_source][gi][1] == "nanites" then
				naniteQuantity = goods[comms_source][gi][2]
			end
			if goods[comms_source][gi][1] == "robotic" then
				roboticQuantity = goods[comms_source][gi][2]
			end
			gi = gi + 1
		until(gi > #goods[comms_source])
		if naniteQuantity > 0 then
			if comms_source:hasJumpDrive() then
				addCommsReply("Provide nanites for jump drive upgrade", function()
					if comms_source.jumpUpgrade then
						setCommsMessage("You already have the upgrade")
					else
						decrementPlayerGoods("nanites")
						comms_source.cargo = comms_source.cargo + 1
						comms_source.jumpUpgrade = true
						if comms_source:getTypeName() == "Player Fighter" then
							comms_source:setJumpDriveRange(3000,45000)
						else
							comms_source:setJumpDriveRange(5000,55000)
						end
						setCommsMessage("Your jump drive has been upgraded")
					end
				end)
			end
		end
		if roboticQuantity > 0 then
			if comms_source:hasJumpDrive() then
				addCommsReply("Provide robotic goods for jump drive upgrade", function()
					if comms_source.jumpUpgrade then
						setCommsMessage("You already have the upgrade")
					else
						decrementPlayerGoods("robotic")
						comms_source.cargo = comms_source.cargo + 1
						comms_source.jumpUpgrade = true
						if comms_source:getTypeName() == "Player Fighter" then
							comms_source:setJumpDriveRange(3000,45000)
						else
							comms_source:setJumpDriveRange(5000,55000)
						end
						setCommsMessage("Your jump drive has been upgraded")
					end
				end)
			end
		end
	end
	if comms_target == stationCarradine then
		gi = 1
		tritaniumQuantity = 0
		dilithiumQuantity = 0
		repeat
			if goods[comms_source][gi][1] == "tritanium" then
				tritaniumQuantity = goods[comms_source][gi][2]
			end
			if goods[comms_source][gi][1] == "dilithium" then
				dilithiumQuantity = goods[comms_source][gi][2]
			end
			gi = gi + 1
		until(gi > #goods[comms_source])		
		if tritaniumQuantity > 0 then
			addCommsReply(string.format("Provide tritanium for %.2f percent impulse engine speed upgrade",impulseBump), function()
				if comms_source.impulseUpgrade then
					setCommsMessage("You already have the upgrade")
				else
					decrementPlayerGoods("tritanium")
					comms_source.cargo = comms_source.cargo + 1
					comms_source.impulseUpgrade = true
					comms_source:setImpulseMaxSpeed(comms_source:getImpulseMaxSpeed()*(1+impulseBump/100))
					setCommsMessage("Your impulse engine speed has been upgraded")
				end
			end)
		end
		if dilithiumQuantity > 0 then
			addCommsReply(string.format("Provide dilithium for %f percent impulse engine speed upgrade",impulseBump), function()
				if comms_source.impulseUpgrade then
					setCommsMessage("You already have the upgrade")
				else
					decrementPlayerGoods("dilithium")
					comms_source.cargo = comms_source.cargo + 1
					comms_source.impulseUpgrade = true
					comms_source:setImpulseMaxSpeed(comms_source:getImpulseMaxSpeed()*(1+impulseBump/100))
					setCommsMessage("Your impulse engine speed has been upgraded")
				end
			end)
		end
	end
	if comms_target == spinStation then
		gi = 1
		spinQuantity = 0
		repeat
			if goods[comms_source][gi][1] == spinComponent then
				spinQuantity = goods[comms_source][gi][2]
			end
			gi = gi + 1
		until(gi > #goods[comms_source])
		if spinQuantity > 0 then
			addCommsReply(string.format("Provide %s for %.2f percent maneuver speed upgrade",spinComponent,spinBump), function()
				if comms_source.spinUpgrade then
					setCommsMessage("You already have the upgrade")
				else
					decrementPlayerGoods(spinComponent)
					comms_source.cargo = comms_source.cargo + 1
					comms_source.spinUpgrade = true
					comms_source:setRotationMaxSpeed(comms_source:getRotationMaxSpeed()*(1+spinBump/100))
					setCommsMessage("Your spin speed has been upgraded")
				end
			end)
		end
	end
	if comms_target == stationMarconi then
		gi = 1
		beamQuantity = 0
		repeat
			if goods[comms_source][gi][1] == beamComponent then
				beamQuantity = goods[comms_source][gi][2]
			end
			gi = gi + 1
		until(gi > #goods[comms_source])
		if beamQuantity > 0 then
			addCommsReply(string.format("Provide %s for %.2f percent beam range upgrade",beamComponent,beamRangeBump), function()
				if comms_source.beamRangeUpgrade then
					setCommsMessage("You already have the upgrade")
				else
					if comms_source:getBeamWeaponRange(0) > 0 then
						decrementPlayerGoods(beamComponent)
						comms_source.cargo = comms_source.cargo + 1
						comms_source.beamRangeUpgrade = true
						for b=0,tempBeam-1 do
							newRange = comms_source:getBeamWeaponRange(b) * (1+beamRangeBump/100)
							tempCycle = comms_source:getBeamWeaponCycleTime(b)
							tempDamage = comms_source:getBeamWeaponDamage(b)
							tempArc = comms_source:getBeamWeaponArc(b)
							tempDirection = comms_source:getBeamWeaponDirection(b)
							comms_source:setBeamWeapon(b,tempArc,tempDirection,newRange,tempCycle,tempDamage)
						end	
						setCommsMessage("Your beam range has been upgraded")					
					else
						setCommsMessage("Your ship does not support a beam weapon upgrade")
					end
				end
			end)
		end
	end
	if comms_target == tubeStation then
		gi = 1
		tubeQuantity = 0
		repeat
			if goods[comms_source][gi][1] == tubeComponent then
				tubeQuantity = goods[comms_source][gi][2]
			end
			gi = gi + 1
		until(gi > #goods[comms_source])
		if tubeQuantity > 0 then
			addCommsReply(string.format("Provide %s for additional homing missile tube",tubeComponent), function()
				if comms_source.tubeUpgrade then
					setCommsMessage("You already have the upgrade")
				else
					decrementPlayerGoods(tubeComponent)
					comms_source.cargo = comms_source.cargo + 1
					comms_source.tubeUpgrade = true
					originalTubes = comms_source:getWeaponTubeCount()
					newTubes = originalTubes + 1
					comms_source:setWeaponTubeCount(newTubes)
					comms_source:setWeaponTubeExclusiveFor(originalTubes, "Homing")
					comms_source:setWeaponStorageMax("Homing", comms_source:getWeaponStorageMax("Homing") + 2)
					comms_source:setWeaponStorage("Homing", comms_source:getWeaponStorage("Homing") + 2)
					setCommsMessage("You now have an additional homing missle tube")
				end
			end)
		end
	end
--	if comms_target == stationArcher then
--		gi = 1
--		hullQuantity = 0
--		repeat
--			if goods[comms_source][gi][1] == hullComponent then
--				hullQuantity = goods[comms_source][gi][2]
--			end
--			gi = gi + 1
--		until(gi > #goods[comms_source])
--		if hullQuantity > 0 then
--			addCommsReply(string.format("Provide %s for %.2f percent hull upgrade",hullComponent,hullBump), function()
--				if comms_source.hullUpgrade then
--					setCommsMessage("You already have the upgrade")
--				else
--					decrementPlayerGoods(hullComponent)
--					comms_source.cargo = comms_source.cargo + 1
--					comms_source.hullUpgrade = true
--					comms_source:setHullMax(comms_source:getHullMax()*(1+hullBump/100))
--					setCommsMessage("You now have an upgraded hull")
--				end
--			end)
--		end
--	end
	if comms_target == stationNefatha then
		gi = 1
		energyQuantity = 0
		repeat
			if goods[comms_source][gi][1] == energyComponent then
				energyQuantity = goods[comms_source][gi][2]
			end
			gi = gi + 1
		until(gi > #goods[comms_source])
		if energyQuantity > 0 then
			addCommsReply(string.format("Provide %s for 25 percent energy capacity upgrade",energyComponent), function()
				if comms_source.energyUpgrade then
					setCommsMessage("You already have the upgrade")
				else
					decrementPlayerGoods(energyComponent)
					comms_source.cargo = comms_source.cargo + 1
					comms_source.energyUpgrade = true
					comms_source:setMaxEnergy(comms_source:getMaxEnergy()*1.25)
					setCommsMessage("You now have upgraded energy capacity")
				end
			end)
		end
	end
	if comms_target == shieldStation then
		gi = 1
		shieldQuantity = 0
		repeat
			if goods[comms_source][gi][1] == shieldComponent then
				shieldQuantity = goods[comms_source][gi][2]
			end
			gi = gi + 1
		until(gi > #goods[comms_source])
		if shieldQuantity > 0 then
			addCommsReply(string.format("Provide %s for %.2f percent front shield upgrade",shieldComponent,shieldBump), function()
				if comms_source.frontShieldUpgrade then
					setCommsMessage("You already have the upgrade")
				else
					decrementPlayerGoods(shieldComponent)
					comms_source.cargo = comms_source.cargo + 1
					comms_source.frontShieldUpgrade = true
					si = comms_source:getShieldCount()
					if comms_source:getShieldCount() == 1 then
						comms_source:setShieldsMax(comms_source:getShieldMax(0)*(1+shieldBump/100))
					else
						comms_source:setShieldsMax(comms_source:getShieldMax(0)*(1+shieldBump/100), comms_source:getShieldMax(1))
					end
					setCommsMessage("You now have an upgraded front shield")
				end
			end)
			if comms_source:getShieldCount() > 1 then
				addCommsReply(string.format("Provide %s for %.2f percent rear shield upgrade",shieldComponent,shieldBump), function()
					if comms_source.rearShieldUpgrade then
						setCommsMessage("You already have the upgrade")
					else
						decrementPlayerGoods(shieldComponent)
						comms_source.cargo = comms_source.cargo + 1
						comms_source.rearShieldUpgrade = true
						si = comms_source:getShieldCount()
						comms_source:setShieldsMax(comms_source:getShieldMax(0), comms_source:getShieldMax(1)*(1+shieldBump/100))
						setCommsMessage("You now have an upgraded rear shield")
					end				
				end)
			end
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
    local item_amount = math.floor(comms_source:getWeaponStorageMax(weapon) * comms_data.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage(weapon)
    if item_amount <= 0 then
        if weapon == "Nuke" then
            setCommsMessage("All nukes are charged and primed for destruction.");
        else
            setCommsMessage("Sorry, sir, but you are as fully stocked as I can allow.");
        end
        addCommsReply("Back", commsStation)
    else
        if not comms_source:takeReputationPoints(points_per_item * item_amount) then
            setCommsMessage("Not enough reputation.")
            return
        end
        comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + item_amount)
        if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
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
    if comms_source:isFriendly(comms_target) then
        oMsg = "Good day, officer.\nIf you need supplies, please dock with us first."
    else
        oMsg = "Greetings.\nIf you want to do business, please dock with us first."
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. "\nBe aware that if enemies in the area get much closer, we will be too busy to conduct business with you."
	end
	setCommsMessage(oMsg)
 	addCommsReply("I need information", function()
		setCommsMessage("What kind of information do you need?")
		addCommsReply("Do you upgrade spaceships?", function()
			if comms_target == stationZefram then
				setCommsMessage("We can upgrade your jump drive maximum range for nanites or robotic goods")
			elseif comms_target == stationCarradine then
				setCommsMessage(string.format("We can increase the speed of your impulse engines by %.2f percent for tritanium or dilithium",impulseBump))
			elseif comms_target == spinStation then
				setCommsMessage(string.format("We can increase the speed your rotate speed by %.2f percent for %s",spinBump,spinComponent))
			elseif comms_target == stationMarconi then
				setCommsMessage(string.format("We can increase the range of your beam weapons by %.2f percent for %s",beamRangeBump,beamComponent))
			elseif comms_target == tubeStation then
				setCommsMessage(string.format("We can add a homing missile tube to your ship for %s",tubeComponent))
--			elseif comms_target == stationArcher then
--				setCommsMessage(string.format("We can upgrade the durability of your hull by %.2f percent for %s",hullBump,hullComponent))
			elseif comms_target == shieldStation then
				setCommsMessage(string.format("We can upgrade your shields by %.2f percent for %s",shieldBump,shieldComponent))
			elseif comms_target == stationNefatha then
				setCommsMessage(string.format("We can upgrade your energy capacity by 25 percent for %s",energyComponent))
			else
				setCommsMessage("We don't upgrade spaceships")
			end
		end)
	end)
	if comms_source:isFriendly(comms_target) then
		addCommsReply("What are my current orders?", function()
			ordMsg = primaryOrders
			if raceStartDelay > 0 then
				ordMsg = ordMsg .. string.format("\n%i Seconds remain until start of race",raceStartDelay)
			else
				if comms_source.goal ~= nil then
					ordMsg = ordMsg .. string.format("\nImmediate goal: race waypoint %i",comms_source.goal)
				end
			end
			setCommsMessage(ordMsg)
			addCommsReply("Back", commsStation)
		end)
	end
	if diagnostic then
		addCommsReply("Diagnostic data", function()
			if raceStartDelay > 0 then
				dMsg = string.format("Seconds to race start: %f",raceStartDelay)
			else
				dMsg = string.format("Race has been running for %f seconds",raceTimer)
			end
			dMsg = dMsg .. string.format("RacePoint 1 (x, y): %i, %i",racePoint1x,racePoint1y)
			dMsg = dMsg .. string.format("\nRacePoint 2 (x,y): %f, %f",racePoint2x,racePoint2y)
			dMsg = dMsg .. string.format("\nRacePoint 3 (x,y): %f, %f",racePoint3x,racePoint3y)
			dMsg = dMsg .. string.format("\nRacePoint 4 (x,y): %f, %f",racePoint4x,racePoint4y)
			if raceStartDelay <= 0 then
				addCommsReply("Show player goals in race", function()
					dMsg = "Player goals in race:"
					for p12idx=1,32 do
						p12 = getPlayerShip(p12idx)
						if p12 ~= nil and p12:isValid() then
							dMsg = dMsg .. string.format("\nPlayer %i: %s goal: %i",p12idx,p12:getCallSign(),p12.goal)
						end
					end
					setCommsMessage(dMsg)
					addCommsReply("Back", commsStation)
				end)
			end
			addCommsReply("Show patience time limit", function()
				dMsg = string.format("\nPatience time limit: %i",patienceTimeLimit)
				setCommsMessage(dMsg)
				addCommsReply("Back", commsStation)
			end)
			if raceStartDelay <= 0 then
				addCommsReply("Show unfinished racers", function()
					dMsg = string.format("Unfinished racers: %i",unfinishedRacers)
					setCommsMessage(dMsg)
					addCommsReply("Back", commsStation)
				end)
			end
			if gMsg ~= nil then
				dMsg = dMsg .. "\n\nFinal built message so far:\n\n" .. gMsg
			end
			setCommsMessage(dMsg)
			addCommsReply("Back", commsStation)
		end)
	end
	if isAllowedTo(comms_target.comms_data.services.supplydrop) then
        addCommsReply("Can you send a supply drop? ("..getServiceCost("supplydrop").."rep)", function()
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage("You need to set a waypoint before you can request backup.");
            else
                setCommsMessage("To which waypoint should we deliver your supplies?");
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
                        if comms_source:takeReputationPoints(getServiceCost("supplydrop")) then
                            local position_x, position_y = comms_target:getPosition()
                            local target_x, target_y = comms_source:getWaypoint(n)
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
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage("You need to set a waypoint before you can request reinforcements.");
            else
                setCommsMessage("To which waypoint should we dispatch the reinforcements?");
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
                        if comms_source:takeReputationPoints(getServiceCost("reinforcements")) then
                            ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
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
	if goods[comms_target] == nil then
		goods[comms_target] = {goodsList[irandom(1,#goodsList)][1], 1, random(20,80)}
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
		local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
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
	return true
end
function enemyComms(comms_data)
	if comms_target.owner == nil then
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
	else
		setCommsMessage("I belong to " .. comms_target.owner)
		addCommsReply("Back", commsShip)
	end
	return false
end
function neutralComms(comms_data)
	shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
		if comms_data.friendlyness > 66 then
			setCommsMessage("Yes?")
			-- Offer destination information
			addCommsReply("Where are you headed?", function()
				setCommsMessage(comms_target.target:getCallSign())
				addCommsReply("Back", commsShip)
			end)
			-- Offer to trade goods if goods or equipment freighter
			if distance(comms_source,comms_target) < 5000 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					gi = 1
					luxuryQuantity = 0
					repeat
						if goods[comms_source][gi][1] == "luxury" then
							luxuryQuantity = goods[comms_source][gi][2]
						end
						gi = gi + 1
					until(gi > #goods[comms_source])
					if luxuryQuantity > 0 then
						gi = 1
						repeat
							local goodsType = goods[comms_target][gi][1]
							local goodsQuantity = goods[comms_target][gi][2]
							addCommsReply(string.format("Trade luxury for %s",goods[comms_target][gi][1]), function()
								if goodsQuantity < 1 then
									setCommsMessage("Insufficient inventory on freighter for trade")
								else
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									decrementPlayerGoods("luxury")
									setCommsMessage("Traded")
								end
								addCommsReply("Back", commsShip)
							end)
							gi = gi + 1
						until(gi > #goods[comms_target])
					else
						setCommsMessage("Insufficient luxury to trade")
					end
					addCommsReply("Back", commsShip)
				else
					-- Offer to sell goods
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]
						addCommsReply(string.format("Buy one %s for %i reputation",goods[comms_target][gi][1],goods[comms_target][gi][3]), function()
							if comms_source.cargo < 1 then
								setCommsMessage("Insufficient cargo space for purchase")
							elseif goodsQuantity < 1 then
								setCommsMessage("Insufficient inventory on freighter")
							else
								if not comms_source:takeReputationPoints(goodsRep) then
									setCommsMessage("Insufficient reputation for purchase")
								else
									comms_source.cargo = comms_source.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage("Purchased")
								end
							end
							addCommsReply("Back", commsShip)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
		elseif comms_data.friendlyness > 33 then
			setCommsMessage("What do you want?")
			-- Offer to sell destination information
			destRep = random(1,5)
			addCommsReply(string.format("Where are you headed? (cost: %f reputation)",destRep), function()
				if not comms_source:takeReputationPoints(destRep) then
					setCommsMessage("Insufficient reputation")
				else
					setCommsMessage(comms_target.target:getCallSign())
				end
				addCommsReply("Back", commsShip)
			end)
			-- Offer to sell goods if goods or equipment freighter
			if distance(comms_source,comms_target) < 5000 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]
						addCommsReply(string.format("Buy one %s for %i reputation",goods[comms_target][gi][1],goods[comms_target][gi][3]), function()
							if comms_source.cargo < 1 then
								setCommsMessage("Insufficient cargo space for purchase")
							elseif goodsQuantity < 1 then
								setCommsMessage("Insufficient inventory on freighter")
							else
								if not comms_source:takeReputationPoints(goodsRep) then
									setCommsMessage("Insufficient reputation for purchase")
								else
									comms_source.cargo = comms_source.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage("Purchased")
								end
							end
							addCommsReply("Back", commsShip)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				else
					-- Offer to sell goods double price
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]*2
						addCommsReply(string.format("Buy one %s for %i reputation",goods[comms_target][gi][1],goods[comms_target][gi][3]*2), function()
							if comms_source.cargo < 1 then
								setCommsMessage("Insufficient cargo space for purchase")
							elseif goodsQuantity < 1 then
								setCommsMessage("Insufficient inventory on freighter")
							else
								if not comms_source:takeReputationPoints(goodsRep) then
									setCommsMessage("Insufficient reputation for purchase")
								else
									comms_source.cargo = comms_source.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage("Purchased")
								end
							end
							addCommsReply("Back", commsShip)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
		else
			setCommsMessage("Why are you bothering me?")
			-- Offer to sell goods if goods or equipment freighter double price
			if distance(comms_source,comms_target) < 5000 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]*2
						addCommsReply(string.format("Buy one %s for %i reputation",goods[comms_target][gi][1],goods[comms_target][gi][3]*2), function()
							if comms_source.cargo < 1 then
								setCommsMessage("Insufficient cargo space for purchase")
							elseif goodsQuantity < 1 then
								setCommsMessage("Insufficient inventory on freighter")
							else
								if not comms_source:takeReputationPoints(goodsRep) then
									setCommsMessage("Insufficient reputation for purchase")
								else
									comms_source.cargo = comms_source.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage("Purchased")
								end
							end
							addCommsReply("Back", commsShip)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
		end
	else
		if comms_data.friendlyness > 50 then
			setCommsMessage("Sorry, we have no time to chat with you.\nWe are on an important mission.");
		else
			setCommsMessage("We have nothing for you.\nGood day.");
		end
	end
	return true
end
------------------------
--	Cargo management  --
------------------------
function incrementPlayerGoods(goodsType)
	local gi = 1
	repeat
		if goods[comms_source][gi][1] == goodsType then
			goods[comms_source][gi][2] = goods[comms_source][gi][2] + 1
		end
		gi = gi + 1
	until(gi > #goods[comms_source])
end
function decrementPlayerGoods(goodsType)
	local gi = 1
	repeat
		if goods[comms_source][gi][1] == goodsType then
			goods[comms_source][gi][2] = goods[comms_source][gi][2] - 1
		end
		gi = gi + 1
	until(gi > #goods[comms_source])
end
function decrementStationGoods(goodsType)
	local gi = 1
	repeat
		if goods[comms_target][gi][1] == goodsType then
			goods[comms_target][gi][2] = goods[comms_target][gi][2] - 1
		end
		gi = gi + 1
	until(gi > #goods[comms_target])
end
function decrementShipGoods(goodsType)
	local gi = 1
	repeat
		if goods[comms_target][gi][1] == goodsType then
			goods[comms_target][gi][2] = goods[comms_target][gi][2] - 1
		end
		gi = gi + 1
	until(gi > #goods[comms_target])
end
--	Target drones
function spawnTargetDrone(originx,originy,targetDroneID,area,sequenceNumber)
	if shootBack then
		enemyTemplate = "Atlantis X23"
	else
		enemyTemplate = "Fighter"
	end
	tdx, tdy = vectorFromAngle(random(0,360),random(2500,4800))
	td = CpuShip():setTemplate(enemyTemplate):setPosition(originx+tdx,originy+tdy):setFaction("Kraylor")
	td:setHullMax(0):setShieldsMax(0):setHull(0)
	td:setCallSign(string.format("%s %s",td:getCallSign(),targetDroneID))
	td.owner = targetDroneID
	td.area = area
	td.sequence = sequenceNumber
	if shootBack then
		td:orderStandGround()
	else
		td:orderIdle()
	end
	table.insert(droneList,td)
end
--	Moving terrain
function moveHazardAsteroids(aList,aDiameter)
	for hai=1,4 do
		if aList[hai]:isValid() then
			aList[hai].angle = aList[hai].angle + 1
			if aList[hai].angle == 360 then
				aList[hai].angle = 0
			end
			hax, hay = vectorFromAngle(aList[hai].angle,aDiameter)
			aList[hai]:setPosition(racePoint2x+hax,racePoint2y+hay)
		end
	end
end
function moveHazardMines(mList,mDiameter)
	for hmi=1,4 do
		if mList[hmi]:isValid() then
			mList[hmi].angle = mList[hmi].angle + 1
			if mList[hmi].angle == 360 then
				mList[hmi].angle = 0
			end
			hmx, hmy = vectorFromAngle(mList[hmi].angle,mDiameter)
			mList[hmi]:setPosition(racePoint3x+hmx,racePoint3y+hmy)
		end
	end
end
function moveHazardPacMines(pmList,pmDiameter)
	for hpmi=1,#pmList do
		if pmList[hpmi]:isValid() then
			pmList[hpmi].angle = pmList[hpmi].angle + 1
			if pmList[hpmi].angle == 360 then
				pmList[hpmi].angle = 0
			end
			hpmx, hpmy = vectorFromAngle(pmList[hpmi].angle,pmDiameter)
			pmList[hpmi]:setPosition(racePoint4x+hpmx,racePoint4y+hpmy)
		end
	end
end
--	Naming player ships
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
function namePlayerShip(p,template_type)
	if playerShipNamesFor[template_type] ~= nil and #playerShipNamesFor[template_type] > 0 then
		p:setCallSign(tableRemoveRandom(playerShipNamesFor[template_type]))
	else
		p:setCallSign(tableRemoveRandom(playerShipNamesFor["Leftovers"]))
	end
end
--	End of game handling
function allRacersFinished()
	print("in all racers finished function")
	calculateTimeRank()
	if playerCount == 1 then
		soloComplete()
	else
		competeComplete()
	end
	globalMessage(gMsg)
end
function raceTimerExpired()
	print("in race timer expired function")
	calculateTimeRank()
	if playerCount == 1 then
		soloExpire()
	else
		competeExpire()
	end
	globalMessage(gMsg)
end
function calculateTimeRank()
	print("in calculate time rank function")
	playerList = {}
	for p6idx=1,32 do
		p6 = getPlayerShip(p6idx)
		if p6 ~= nil and p6:isValid() and p6.participant == "participant" then
			table.insert(playerList,p6)
			if p6.raceTime == nil then
				p6.raceTime = raceTimer
			end
			if p6.raceTime < 600 then
				p6.timeRank = "Admiral"
			elseif p6.raceTime < 720 then
				p6.timeRank = "Captain"
			elseif p6.raceTime < 900 then
				p6.timeRank = "Commander"
			elseif p6.raceTime < 1200 then
				p6.timeRank = "Lieutenant"
			elseif p6.raceTime < 1500 then
				p6.timeRank = "Ensign"
			else
				if p6.raceTime == nil then
					p6.timeRank = "Undefined"
				else
					p6.timeRank = "Cadet"
				end
			end
		end
	end
end
function soloComplete()
	print("in solo complete function")
	gMsg = string.format("Race completed in %.2f seconds. Time rank: %s",playerList[1].raceTime,playerList[1].timeRank)
	eliminatedDrones = countEliminatedDrones(playerList[1])
	gMsg = gMsg .. string.format("\nTarget drones eliminated: %i",eliminatedDrones)
end
function soloExpire()
	print("in solo expire function")
	gMsg = "Race administrators got tired of waiting. Race stopped after 2000 seconds. Time Rank: Cadet"
	eliminatedDrones = countEliminatedDrones(playerList[1])
	gMsg = gMsg .. string.format("\nTarget drones eliminated: %i",eliminatedDrones)
end
function competeComplete()
	print("in compete complete function")
	gMsg = "Race Results"
	competeResults()
end
function competeExpire()
	print("in compete expire function")
	gMsg = string.format("Race administrators got tired of waiting. Race stopped after %.2f seconds.",raceTimer)
	competeResults()
end
function competeResults()
	print("in compete results function")
	local stat_list, sorted_stat_list = gatherStats(true)
	gMsg = gMsg .. "\nOrdered by score. Place, ship name, score, time in seconds, place points, drone points"
	print("Final Statistics:")
	print("Rank","Score","Place","Drones","Time","Name")
	for index, item in ipairs(sorted_stat_list) do
		local time = 0
		if item.time ~= nil then
			time = item.time
		end
		print(index,item.score,item.rank_points,item.drone_points,time,item.name)
		gMsg = gMsg .. string.format("\n%i, %s, %i, %.2f, %i, %i",index,item.name,item.score,time,item.rank_points,item.drone_points)
		if index == 1 then
			gMsg = gMsg .. "\n\n\n"
		end
	end
--	previous method (deprecated)
--[[
	fastestPlayer(10)
	victoryAccount = false
	fastestPlayer(5)
	if playerCount > 2 then
		gMsg = gMsg .. "\n\n\n"
		fastestPlayer(3)
		victoryAccount = true
	end
	if playerCount > 3 then
		fastestPlayer(1)
	end
	if playerCount > 4 then
		for pl=1,#playerList do
			if playerList[pl].timePoints == nil then
				playerList[pl].timePoints = 0
				gMsg = gMsg .. string.format("\n%s time: %.2f seconds. Time rank: %s. Placement points: 0",playerList[pl]:getCallSign(),playerList[pl].raceTime,playerList[pl].timeRank)
			end
		end
	end
	if not victoryAccount then
		gMsg = gMsg .. "\n\n\n"
	end
	droneTally()
	gMsg = gMsg .. "\n"
	unorderedFinalTally()
--]]
end
function fastestPlayer(reward)
	shortestTime = 999999
	for pl=1,#playerList do
		if playerList[pl].timePoints == nil then
			if playerList[pl].raceTime < shortestTime then
				pi = pl
				shortestTime = playerList[pl].raceTime
			end
		end
	end
	if pi ~= nil then
		playerList[pi].timePoints = reward
		gMsg = gMsg .. string.format("\n%s time: %.2f seconds. Time rank: %s. Placement points: %i",playerList[pi]:getCallSign(),playerList[pi].raceTime,playerList[pi].timeRank,playerList[pi].timePoints)
	else
		gMsg = gMsg .. "\nResults indeterminate"
	end
	return
end
function droneTally()
	for pl=1,#playerList do
		eliminatedDrones = countEliminatedDrones(playerList[pl])
		playerList[pl].score = playerList[pl].timePoints + eliminatedDrones
		playerList[pl].dronePoints = eliminatedDrones
	end	
end
function countEliminatedDrones(ePlayer)
	local remainingDrones = 0
	local tdid = ePlayer:getCallSign()
	if droneList ~= nil and #droneList > 0 then
		for didx=1,#droneList do
			if droneList[didx]:isValid() then
				if droneList[didx].owner == tdid then
					remainingDrones = remainingDrones + 1
				end
			end
		end
	else
		remainingDrones = 12
	end
	return 12 - remainingDrones	
end
function countEliminatedDronesByName(name)
	local remainingDrones = 0
	if droneList ~= nil and #droneList > 0 then
		for didx=1,#droneList do
			if droneList[didx]:isValid() then
				if droneList[didx].owner == name then
					remainingDrones = remainingDrones + 1
				end
			end
		end
	else
		remainingDrones = 12
	end
	return 12 - remainingDrones	
end
function unorderedFinalTally()
	for pl=1,#playerList do
		gMsg = gMsg .. string.format("%s Drones shot: %i, Total score: %i. ",playerList[pl]:getCallSign(),playerList[pl].dronePoints,playerList[pl].score)
	end
end
function finalTally()
	outerIndex = #playerList
	for plo=1,outerIndex do
		bestScore = 0
		for pl=1,#playerList do
			if playerList[pl].score >= bestScore then
				bestPlayer = playerList[pl]
				bestScore = playerList[pl].score
			end
		end
		gMsg = gMsg .. string.format("%s Drones shot: %i, Total score: %i. ",bestPlayer:getCallSign(),bestPlayer.dronePoints,bestPlayer.score)
		table.remove(playerList,bestPlayer)
	end
end
function gatherStats(final_score)
	local stat_list = {}
	stat_list.scenario = {name = "Fermi 500", version = scenario_version}
	stat_list.ship = {}
	stat_list.times = {}
	stat_list.times.stage = game_state
	stat_list.times.raceStartDelay = raceStartDelay
	stat_list.times.raceTimer = raceTimer
	stat_list.times.patienceTimeLimit = patienceTimeLimit
	local score_list = {}
	for pidx=1,32 do
		local p = getPlayerShip(pidx)
		if p ~= nil then
			score_list[p:getCallSign()] = {laps = p.laps, goal = p.goal, drone_points = 0, rank = 0, score = 0, time = 0}
			local participant = false
			if p.participant == "participant" then
				participant = "participant"
			else
				if raceStartDelay > 0 then
					participant = "unknown"
				else
					participant = "forfeit"
				end
			end
			local laps = 0
			if p.laps ~= nil then
				laps = p.laps
			end
			local goal = 0
			if p.goal ~= nil then
				goal = p.goal
			end
			local rank_goal = goal - 1
			if rank_goal == 0 then
				rank_goal = 4
			elseif rank_goal < 0 then
				rank_goal = 0
			end
			local drone_points = 0
			if p:isValid() then
				drone_points = countEliminatedDrones(p)
				score_list[p:getCallSign()].drone_points = drone_points
				score_list[p:getCallSign()].rank = laps*10000 + rank_goal*1000
				if p.raceTime ~= nil then
					score_list[p:getCallSign()].rank = score_list[p:getCallSign()].rank + (original_patience_time_limit - p.raceTime)
					score_list[p:getCallSign()].time = p.raceTime
				end
				stat_list.ship[p:getCallSign()] = {is_alive = true, participant = participant, lap_count = laps, waypoint_goal = goal, drone_points = drone_points, rank_points = 0, score = 0, time = 0}
			else
				drone_points = countEliminatedDronesByName(p.name)
				score_list[p.name].drone_points = drone_points
				score_list[p.name].rank = laps*10000 + rank_goal*1000
				if p.raceTime ~= nil then
					score_list[p.name].rank = score_list[p:getCallSign()].rank + (original_patience_time_limit - p.raceTime)
					score_list[p.name].time = p.raceTime
				end
				stat_list.ship[p.name] = {is_alive = false, participant = participant, lap_count = laps, waypoint_goal = goal, drone_points = drone_points, rank_points = 0, score = 0, time = 0}
			end
		end
	end
	for name, p in pairs(player_start_list) do
		if name ~= nil then
			if stat_list.ship[name] == nil then
				if p ~= nil then
					local participant = p.participant
					if participant == nil then
						participant = "unknown"
					end
					local laps = 0
					if p.laps ~= nil then
						laps = p.laps
					end
					local goal = 1
					if p.goal ~= nil then
						goal = p.goal
					end
					local rank_goal = goal - 1
					if rank_goal == 0 then
						rank_goal = 4
					elseif rank_goal < 0 then
						rank_goal = 0
					end
					local drone_points = countEliminatedDronesByName(name)
					if drone_points == nil then
						drone_points = 0
					end
					if score_list[name] ~= nil then
						score_list[name].drone_points = drone_points
						score_list[name].rank = laps*10000 + rank_goal*1000
						if p.raceTime ~= nil then
							score_list[name].rank = score_list[p:getCallSign()].rank + (original_patience_time_limit - p.raceTime)
							score_list[name].time = p.raceTime
						end
					end
					stat_list.ship[name] = {is_alive = false, participant = participant, lap_count = laps, waypoint_goal = goal, drone_points = drone_points, rank_points = 0, score = 0, time = 0} 
				end
			end
		end
	end
	local sorted_score_list = {}
	for name, details in pairs(score_list) do
		table.insert(sorted_score_list,{name=name,drone_points=details.drone_points,rank=details.rank,time=details.time})
	end
	table.sort(sorted_score_list,function(a,b)
		return a.rank > b.rank
	end)
--	for _,item in ipairs(sorted_score_list) do
--		print(item.name, item.drone_points, item.rank)
--	end
	if sorted_score_list ~= nil and #sorted_score_list > 0 and player_count > 0 then
		local prev_value = sorted_score_list[1].rank
		local place_index = 1
		local reward_index = 1
		for _, item in ipairs(sorted_score_list) do
			if item.rank ~= prev_value then
				reward_index = place_index
			end
			local reward = reward_grid[player_count][reward_index]
			stat_list.ship[item.name].rank_points = reward
--			stat_list.ship[item.name].score = reward + item.drone_points
			stat_list.ship[item.name].time = item.time	
			place_index = place_index + 1
			prev_value = item.rank
		end
	end
	for name, details in pairs(stat_list.ship) do
		local reward = details.rank_points
		local drones = details.drone_points
		if reward ~= nil and drones ~= nil then
			details.score = reward + drones
		end
	end
	if final_score then
		print("in gather stats function when the final score is being calculated")
		local sorted_stat_list = {}
		for name, details in pairs(stat_list.ship) do
			table.insert(sorted_stat_list,{name=name,lap_count=details.lap_count,waypoint_goal=details.waypoint_goal,score=details.score,rank_points=details.rank_points,drone_points=details.drone_points,time=details.time})
		end
		table.sort(sorted_stat_list,function(a,b)
			return a.score > b.score
		end)
		print("Score","Place","Drones","Name","Laps","WP Goal")
		for _, item in ipairs(sorted_stat_list) do
			print(item.score,item.rank_points,item.drone_points,item.name,item.lap_count,item.waypoint_goal)
		end
		return stat_list, sorted_stat_list
	end
	return stat_list
end
function setRaceWaypoints(p)
	string.format("")	--global context for serious proton
	p:commandAddWaypoint(racePoint1x,racePoint1y)
	p:commandAddWaypoint(racePoint2x,racePoint2y)
	p:commandAddWaypoint(racePoint3x,racePoint3y)
	p:commandAddWaypoint(racePoint4x,racePoint4y)
end
function resetRaceWaypoints(p)
	string.format("")	--global context for serious proton
	for i=p:getWaypointCount(),1,-1 do
		p:commandRemoveWaypoint(i)
	end
	setRaceWaypoints(p)
end
function update(delta)
	if delta == 0 then
		game_state = "paused"
		--game paused
		for pidx=1,32 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if p.nameAssigned == nil then
					p.nameAssigned = true
					local control_code_index = math.random(1,#control_code_stem)
					local stem = control_code_stem[control_code_index]
					table.remove(control_code_stem,control_code_index)
					local branch = math.random(100,999)
					p.control_code = stem .. branch
					p:setControlCode(stem .. branch)
					tempPlayerType = p:getTypeName()
					p.shipScore = player_ship_stats[tempPlayerType].strength
					p.maxCargo = player_ship_stats[tempPlayerType].cargo
					p:addReputationPoints(5)
					goods[p] = goodsList
					namePlayerShip(p,tempPlayerType)
					p.name = p:getCallSign()
					local gi = 1
					repeat
						if goods[p][gi][1] == "food" then
							goods[p][gi][2] = 1
						end
						if goods[p][gi][1] == "medicine" then
							goods[p][gi][2] = 1
						end
						gi = gi + 1
					until(gi > #goods[p])
					p.cargo = p.maxCargo - 2
					if tempPlayerType == "MP52 Hornet" then
						p:setWarpDrive(true)
					elseif tempPlayerType == "Phobos M3P" then
						p:setWarpDrive(true)
					elseif tempPlayerType == "Player Fighter" then
						p:setJumpDrive(true)
						p:setJumpDriveRange(3000,40000)
					end
					print("Control Code for " .. p:getCallSign(), p.control_code)
					if player_ship_stats[tempPlayerType] == nil then
						p.shipScore = 24
						p.maxCargo = 5
						p.cargo = p.maxCargo
						if not p:hasSystem("warp") and not p:hasSystem("jumpdrive") then
							pobj:setWarpDrive(true)
						end
					end
				end
			end
		end
		return
	end
	-- game not paused
	if stationsBuilt ~= "done" then
		game_state = "creating"
		stationsBuilt = "done"
		setStations()
	end
	if mainGMButtons == mainGMButtonsDuringPause then
		mainGMButtons = mainGMButtonsAfterPause
		mainGMButtons()
	end
	if players_placed == nil then
		game_state = "placing"
		player_count = 0
		for pidx=1,32 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				player_count = player_count + 1
			end
		end
		local angle_increment = 360/player_count
		local angle = random(0,360)
		for pidx=1,player_count do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				local start_x, start_y = vectorFromAngle(angle,10000)
				p:setPosition(start_x, start_y)
				p:setHeading((angle + 180)%360)
				p:commandTargetRotation((angle + 90)%360)
				angle = angle + angle_increment
			else
				print("Player ship problem. Restart")
				return
			end
		end
		players_placed = true
	end
	if raceInstructionMessage ~= "sent" then
		game_state = "introducing"
		raceInstructionMessage = "sent"
		primaryOrders = string.format("Start race on time at waypoint 1\nRace Length: %f units",raceLength)
		for p1idx=1,32 do
			local p1 = getPlayerShip(p1idx)
			if p1 ~= nil and p1:isValid() then
				p1:addToShipLog("Race starts in 10 minutes. Be at waypoint 1 on time or forfeit","Magenta")
				p1:addToShipLog(string.format("Today's race length: %.1f units",raceLength),"Magenta")
			end
		end
	end
	if raceStartDelay > 0 then
		game_state = "countdown"
		--before race start
		raceStartDelay = raceStartDelay - delta
		stationTimer:setCallSign(string.format("Race Start Countdown: %.2f",raceStartDelay))
		if stationsBuilt == "done" then
			for p2idx=1,32 do
				p2 = getPlayerShip(p2idx)
				if p2 ~= nil and p2:isValid() then
					if p2:getWaypointCount() < 1 then
						p2:commandAddWaypoint(racePoint1x,racePoint1y)
						p2:commandAddWaypoint(racePoint2x,racePoint2y)
						p2:commandAddWaypoint(racePoint3x,racePoint3y)
						p2:commandAddWaypoint(racePoint4x,racePoint4y)
					end
					if p2.readyMessage ~= "done" and raceStartDelay > 1 and raceStartDelay < 2 then
						p2:addToShipLog("Ready...","Blue")
						p2.readyMessage = "done"
					end
					if p2.setMessage ~= "done" and raceStartDelay < 1 then
						p2:addToShipLog("Set...","Magenta")
						p2.setMessage = "done"
					end
				end
			end
		end
	else
		game_state = "race"
		--race has started
		if startLineCheck ~= "done" then
			startLineCheck = "done"
			raceTimer = 0
			primaryOrders = "Complete race. Win if possible."
			player_start_list = {}
			original_player_count = player_count
			player_count = 0
			for p4idx=1,32 do
				p4 = getPlayerShip(p4idx)
				if p4 ~= nil and p4:isValid() then
					if distance(p4,racePoint1x,racePoint1y) < 5000 then
						p4.participant = "participant"
						p4.goal = 2
						p4.laps = 0
						p4.laptimer = 0
						p4.legtimer = 0
						p4:addToShipLog("Go!","Red")
						player_start_list[p4:getCallSign()] = p4
						player_count = player_count + 1
					else
						p4:destroy()
					end
				end
			end
			droneList = {}
			for p4idx=1,32 do	--make some target drones
				p4 = getPlayerShip(p4idx)
				if p4 ~= nil and p4:isValid() and p4.participant == "participant" then
					tdid = p4:getCallSign()	--target drone ID
					for etd=1,4 do
						spawnTargetDrone(racePoint2x,racePoint2y,tdid,"wp2",etd)
						spawnTargetDrone(racePoint3x,racePoint3y,tdid,"wp3",etd)
						spawnTargetDrone(racePoint4x,racePoint4y,tdid,"wp4",etd)
					end
				end
			end
		else
			stationTimer:setCallSign(string.format("Race Run Time %.2f",raceTimer))
			raceTimer = raceTimer + delta
			if hazards then
				hazardDelay = hazardDelay - 1
				if hazardDelay < 0 then
					hazardDelay = hazardDelayReset
					moveHazardAsteroids(asteroid150,150)
					moveHazardAsteroids(asteroid300,300)
					moveHazardAsteroids(asteroid450,450)
					moveHazardAsteroids(asteroid600,600)
					moveHazardAsteroids(asteroid750,750)
					moveHazardAsteroids(asteroid900,900)
					moveHazardMines(mine150,150)
					moveHazardMines(mine300,300)
					moveHazardMines(mine450,450)
					moveHazardMines(mine600,600)
					moveHazardMines(mine750,750)
					moveHazardMines(mine900,900)
					moveHazardPacMines(pacMine1000,1000)
					moveHazardPacMines(pacMine850,850)
				end
			end
			if follow_up_message == nil then
				follow_up_message = "sent"
				local msg = "The race has begun!"
				for name, p in pairs(player_start_list) do
					p:addToShipLog(msg,"Magenta")
				end
				if player_count == original_player_count then
					msg = string.format("With %i racers, we have the following points awarded for final race place:",player_count)
				else
					msg = string.format("With %i racers remaining from the original %i registrants, we have the following points awarded for final race place:",player_count,original_player_count)
				end
				for name, p in pairs(player_start_list) do
					p:addToShipLog(msg,"Magenta")
				end
				msg = ""
				local place_name = {
					"First",
					"Second",
					"Third",
					"Fourth",
					"Fifth",
					"Sixth",
					"Seventh",
					"Eighth",
					"Ninth",
					"Tenth",
				}
				for i=1,#reward_grid[player_count] do
					if reward_grid[player_count][i] > 0 then
						if i > 1 then
							msg = msg .. ", " .. place_name[i] .. ":" .. reward_grid[player_count][i]
						else
							msg = place_name[i] .. ":" .. reward_grid[player_count][i]
						end
					else
						break
					end
				end
				for name, p in pairs(player_start_list) do
					p:addToShipLog(msg,"Magenta")
				end
			end
			for p5idx=1,32 do
				p5 = getPlayerShip(p5idx)
				if p5 ~= nil and p5:isValid() and p5.participant == "participant" and p5.laps < 3 then
					p5.laptimer = p5.laptimer + delta
					p5.legtimer = p5.legtimer + delta
					if chasers then
						if not p5.chaser then
							if p5.laps == 1 then
								p5.chaser = true
								cx, cy = vectorFromAngle(raceAxis,random(5000,8000))
								p5.c1 = CpuShip():setTemplate("Stalker Q7"):setPosition(racePoint1x+cx,racePoint1y+cy)
								p5.c1:setFaction("Kraylor"):orderAttack(p5)
								cx, cy = vectorFromAngle(raceAxis,random(5000,8000))
								p5.c2 = CpuShip():setTemplate("Stalker R7"):setPosition(racePoint1x+cx,racePoint1y+cy)
								p5.c2:setFaction("Kraylor"):orderAttack(p5)
								cx, cy = vectorFromAngle(raceAxis,random(1000,3000))
								p5.c3 = CpuShip():setTemplate("Piranha F12"):setPosition(racePoint1x+cx,racePoint1y+cy)
								p5.c3:setFaction("Kraylor"):orderDefendLocation(racePoint1x,racePoint1y)						
							end
						end
					end
					local name_tag_text = string.format("%s in %s",p5:getCallSign(),p5:getSectorName())
					if p5:hasPlayerAtPosition("Helms") then
						p5.name_tag_helm = "name_tag_helm"
						p5:addCustomInfo("Helms",p5.name_tag_helm,name_tag_text)
					end
					if p5:hasPlayerAtPosition("Tactical") then
						p5.name_tag_helm_tac = "name_tag_helm_tac"
						p5:addCustomInfo("Tactical",p5.name_tag_helm_tac,name_tag_text)
					end
					if p5:hasPlayerAtPosition("SinglePilot") then
						p5.name_tag_helm_single = "name_tag_helm_single"
						p5:addCustomInfo("SinglePilot",p5.name_tag_helm_single,name_tag_text)
					end
					if p5.goal == 2 then
						if distance(p5,racePoint2x,racePoint2y) < 1000 then
							p5.goal = 3
							if p5.laps == 1 then
								lapString = "lap"
							else
								lapString = "laps"
							end
							p5:addToShipLog(string.format("Waypoint 2 met. Go to waypoint 3. Leg took %f seconds. You have completed %i %s.",p5.legtimer,p5.laps,lapString),"Magenta")
							p5.legtimer = 0
						end
					elseif p5.goal == 3 then
						if distance(p5,racePoint3x,racePoint3y) < 1000 then
							p5.goal = 4
							if p5.laps == 1 then
								lapString = "lap"
							else
								lapString = "laps"
							end
							p5:addToShipLog(string.format("Waypoint 3 met. Go to waypoint 4. Leg took %f seconds. You have completed %i %s.",p5.legtimer,p5.laps,lapString),"Magenta")
							p5.legtimer = 0
						end
					elseif p5.goal == 4 then
						if distance(p5,racePoint4x,racePoint4y) < 1000 then
							p5.goal = 1
							if p5.laps == 1 then
								lapString = "lap"
							else
								lapString = "laps"
							end
							p5:addToShipLog(string.format("Waypoint 4 met. Go to waypoint 1. Leg took %f seconds. You have completed %i %s.",p5.legtimer,p5.laps,lapString),"Magenta")
							p5.legtimer = 0
						end
					elseif p5.goal == 1 then
						if distance(p5,racePoint1x,racePoint1y) < 1000 then
							p5.laps = p5.laps + 1
							if p5.laps >= 3 then
								p5.raceTime = raceTimer
								p5:addToShipLog(string.format("Completed race. Race time in seconds: %f",p5.raceTime),"Magenta")
							else
								p5.goal = 2
								if p5.laps == 1 then
									lapString = "lap"
								else
									lapString = "laps"
								end
								p5:addToShipLog(string.format("Waypoint 1 met. Go to waypoint 2. Leg took %f seconds. You have completed %i %s. Lap took %f seconds.",p5.legtimer,p5.laps,lapString,p5.laptimer),"Magenta")
								p5.laptimer = 0
								p5.legtimer = 0
							end
						end
					end
					if p5:getWaypointCount() < 1 then
						p5:commandAddWaypoint(racePoint1x,racePoint1y)
						p5:commandAddWaypoint(racePoint2x,racePoint2y)
						p5:commandAddWaypoint(racePoint3x,racePoint3y)
						p5:commandAddWaypoint(racePoint4x,racePoint4y)
					end
				end
			end
			local finished_racers = 0
			local viable_racers = 0
			for pidx=1,32 do
				local p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() and p.participant == "participant" then
					viable_racers = viable_racers + 1
					if p.laps >= 3 then
						finished_racers = finished_racers + 1
					end
				end
			end
			if finished_racers < #reward_grid[player_count] and reward_grid[player_count][finished_racers + 1] == 0 then
				if patienceTimeLimit == original_patience_time_limit then
					patienceTimeLimit = raceTimer + 10		--wait 10 seconds for last place player ship to finish
				end
			end
			if finished_racers >= viable_racers then
				allRacersFinished()
				game_state = "complete"
				victory("Human Navy")
			end
			if raceTimer > patienceTimeLimit then
				raceTimerExpired()
				game_state = "expired"
				victory("Human Navy")
			end
		end
	end
end
