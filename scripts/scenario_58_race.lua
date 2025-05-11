-- Name: Fermi 500
-- Description: Race three laps of four waypoints (1 to 2 to 3 to 4 to 1 = 1 lap) in the shortest time. Play for time by yourself, but have more fun with multiple player ships.
---
--- Placement points depend on the number of racers present at the starting point when the race starts. Precise values are given to Relay at that time. Each target drone of yours shot earns one point. Shoot an opponent's drone and they get the point.
---
--- Before the race starts, scope out the course, visit some stations, maybe improve your ship for the race. But, watch your time carefully. If you are not at waypoint 1 at the start of the race, your ship will be destroyed. Your competitors may also try to destroy you despite being your nominal allies, so beware
---
--- Version 2.2
-- Type: Race
-- Setting[Shoot Back]: Configures whether the targets along the race course shoot back or not
-- Shoot Back[No|Default]: Targets along the course do not shoot back
-- Shoot Back[Yes]: Targets along the course shoot back
-- Setting[Chase]: Configures whether or not random enemies will chase the racers
-- Chase[No|Default]: Random enemies will not appear to chase the racers
-- Chase[Yes]: Random enemies will appear to chase the racers
-- Setting[Hazards]: Configures whether or not hazards will appear at the race point markers to impede the race
-- Hazards[No|Default]: No hazards will appear at the race point markers to impede the race
-- Hazards[Yes]: Hazards will appear at the race point markers to impeded the race
-- Setting[Ship Name]: Configures whether player ship names and control codes will be predefined or random. See Game master screen to get control codes
-- Ship Name[Predefined|Default]: Player ship names and control codes will be predefined as scripted. See Game master screen to get control codes
-- Ship Name[Random]: Player ship names will be selected at random from a list of names and player ship control codes will be randomly generated. See Game master screen to get control codes
-- Setting[Sound]: Configure the start sound to beep or roar
-- Sound[Colossus|Default]: Start sound will be Colossus roar
-- Sound[Fermi]: Start sound will be Pole Position beep

require("utils.lua")
require("place_station_scenario_utility.lua")

----------------------
--	Initialization  --
----------------------
function init()
	scenario_version = "2.2.3"
	ee_version = "2024.12.08"
	print(string.format("    ----    Scenario: Fermi 500    ----    Version %s    ----    Tested with EE version %s    ----",scenario_version,ee_version))
	if _VERSION ~= nil then
		print("Lua version:",_VERSION)
	end
	-- 27 types of goods so far
	goodsList = {	
		{"food",0},
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
		{"battery",0}	
	}
	component_goods = {"impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	mineral_goods = {"nickel","platinum","gold","dilithium","tritanium","cobalt"}
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

	diagnostic = false
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
	playerShipNamesFor["Striker"] = {"Sparrow","Sizzle","Squawk","Crow","Snowbird","Hawk"}
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
		"Merrimac",
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
	original_race_start_delay = raceStartDelay
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
	start_zone = Zone():setPoints(
		racePoint1x + 500, racePoint1y + 500,
		racePoint1x - 500, racePoint1y + 500,
		racePoint1x - 500, racePoint1y - 500,
		racePoint1x + 500, racePoint1y - 500
	):setLabel("WP1"):setColor(0,64,0)
	point_2_zone = Zone():setPoints(
		racePoint2x + 500, racePoint2y + 500,
		racePoint2x - 500, racePoint2y + 500,
		racePoint2x - 500, racePoint2y - 500,
		racePoint2x + 500, racePoint2y - 500
	):setLabel("WP2"):setColor(0,64,0)
	point_3_zone = Zone():setPoints(
		racePoint3x + 500, racePoint3y + 500,
		racePoint3x - 500, racePoint3y + 500,
		racePoint3x - 500, racePoint3y - 500,
		racePoint3x + 500, racePoint3y - 500
	):setLabel("WP3"):setColor(0,64,0)
	point_4_zone = Zone():setPoints(
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
	if getScenarioSetting == nil then
		shootBack = false
		chasers = false
		hazards = false
		predefined_player_ships = getPredefinedPlayerShipNames()
	else
		shootBack = false
		if getScenarioSetting("Shoot Back") == "Yes" then
			shootBack = true
		end
		chasers = false
		if getScenarioSetting("Chase") == "Yes" then
			chasers = true
		end
		hazards = false
		if getScenarioSetting("Hazards") == "Yes" then
			hazards = true
		end
		if getScenarioSetting("Ship Name") == "Predefined" then
			predefined_player_ships = getPredefinedPlayerShipNames()
		else
			predefined_player_ships = nil
		end
		if getScenarioSetting("Sound") == "Fermi" then
			start_sound_file = "audio/scenario/58/sa_58_goBeep.ogg"
		else
			start_sound_file = "audio/scenario/58/sa_58_start.ogg"
		end
	end
end
function getPredefinedPlayerShipNames()
	local predefined_player_ships = {
		{name = "Damocles",		control_code = "BURN265"},
		{name = "Endeavor",		control_code = "MOON558"},
		{name = "Hyperion",		control_code = "JACKPOT777"},
		{name = "Liberty",		control_code = "FERENGI432"},
		{name = "Prismatic",	control_code = "EQUILATERAL180"},
		{name = "Visionary",	control_code = "TIME909"},
	}
	return predefined_player_ships
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
	for i, name in ipairs(sorted_names) do
		local faction = ""
		if code_list[name].faction == "Kraylor" then
			faction = _("msgGM", " (Kraylor)")
		elseif code_list[name].faction == "Ktlitans" then
			faction = _("msgGM", " (Ktlitan)")
		end
		output = output .. string.format(_("msgGM", "%s: %s %s\n"),name,code_list[name].code,faction)
	end
	addGMMessage(output)
end
--	GM buttons while paused
function mainGMButtonsDuringPause()
	clearGMFunctions()
	addGMFunction(string.format(_("buttonGM", "Version %s"),scenario_version),function()
		local version_message = string.format(_("msgGM", "Scenario version %s\n LUA version %s"),scenario_version,_VERSION)
		addGMMessage(version_message)
		print(version_message)
	end)
	addGMFunction(_("buttonGM", "Show control codes"),showControlCodes)
	addGMFunction(_("buttonGM","Reset control codes"),resetControlCodes)
	addGMFunction(string.format(_("buttonGM", "+Start Delay: %i"),raceStartDelay/60),setStartDelay)
	addGMFunction(string.format(_("buttonGM", "+Patience: %i"),patienceTimeLimit/60),setPatienceTimeLimit)
	if predefined_player_ships ~= nil then
		addGMFunction(_("buttonGM", "Random PShip Names"),function()
			addGMMessage(_("msgGM", "Player ship names will be selected at random.\nControl codes will be randomly generated"))
			predefined_player_ships = nil
			mainGMButtons()
		end)
	end
	local button_label = _("buttonGM", "+Shoot Back: ")
	if shootBack then
		button_label = string.format("%s%s",button_label,_("buttonGM", "Yes"))
	else
		button_label = string.format("%s%s",button_label,_("buttonGM", "No"))
	end
	addGMFunction(button_label,setShootBack)
	button_label = _("buttonGM", "+Chase: ")
	if chasers then
		button_label = string.format("%s%s",button_label,_("buttonGM", "Yes"))
	else
		button_label = string.format("%s%s",button_label,_("buttonGM", "No"))
	end
	addGMFunction(button_label,setChasers)
	button_label = _("buttonGM", "+Hazards: ")
	if hazards then
		button_label = string.format("%s%s",button_label,_("buttonGM", "Yes"))
	else
		button_label = string.format("%s%s",button_label,_("buttonGM", "No"))
	end
	addGMFunction(button_label,setHazards)
	addGMFunction(_("buttonGM","Show Statistics"),function()
		local out = _("msgGM","Not much to show since the game is still paused")
		print(out)
		local player_list = getActivePlayerShips()
		local player_count = string.format(_("msgGM","Total player ships: %i"),#player_list)
		print(player_count)
		out = string.format("%s\n%s",out,player_count)
		for index, p in ipairs(player_list) do
			local player_line = string.format(_("msgGM","%2i Name:%s, Type:%s"),index,p:getCallSign(),p:getTypeName())
			print(player_line)
			out = string.format("%s\n%s",out,player_line)
		end
		addGMMessage(out)
	end)
end
function resetControlCodes()
	for i,p in ipairs(getActivePlayerShips()) do
		local stem = tableRemoveRandom(control_code_stem)
		local branch = math.random(100,999)
		p.control_code = stem .. branch
		p:setControlCode(stem .. branch)
	end
	showControlCodes()
end
function setShootBack()
	clearGMFunctions()
	addGMFunction(_("buttonGM", "-From Shoot Back"),mainGMButtons)
	local button_label = _("buttonGM", "Shoot Back Yes")
	if shootBack then
		button_label = button_label .. _("buttonGM", "*")
	end
	addGMFunction(button_label,function()
		shootBack = true
		setShootBack()
	end)
	button_label = _("buttonGM", "Shoot Back No")
	if not shootBack then
		button_label = button_label .. _("buttonGM", "*")
	end
	addGMFunction(button_label,function()
		shootBack = false
		setShootBack()
	end)
end
function setChasers()
	clearGMFunctions()
	addGMFunction(_("buttonGM", "-From Chase"),mainGMButtons)
	local button_label = _("buttonGM", "Chase Yes")
	if chasers then
		button_label = button_label .. _("buttonGM", "*")
	end
	addGMFunction(button_label,function()
		chasers = true
		setChasers()
	end)
	button_label = _("buttonGM", "Chase No")
	if not chasers then
		button_label = button_label .. _("buttonGM", "*")
	end
	addGMFunction(button_label,function()
		chasers = false
		setChasers()
	end)
end
function setHazards()
	clearGMFunctions()
	addGMFunction(_("buttonGM", "-From Hazards"),mainGMButtons)
	local button_label = _("buttonGM", "Hazards Yes")
	if hazards then
		button_label = button_label .. _("buttonGM", "*")
	end
	addGMFunction(button_label,function()
		hazards = true
		setHazards()
	end)
	button_label = _("buttonGM", "Hazards No")
	if not hazards then
		button_label = button_label .. _("buttonGM", "*")
	end
	addGMFunction(button_label,function()
		hazards = false
		setHazards()
	end)
end
function setPatienceTimeLimit()
	clearGMFunctions()
	addGMFunction(_("buttonGM", "-Main"),mainGMButtons)
	if patienceTimeLimit < 3000 then
		addGMFunction(string.format(_("buttonGM", "%i Patience + -> %i"),patienceTimeLimit/60,(patienceTimeLimit + 300)/60),function()
			patienceTimeLimit = patienceTimeLimit + 300
			original_patience_time_limit = patienceTimeLimit
			setPatienceTimeLimit()
		end)
	end
	if patienceTimeLimit > 600 then
		addGMFunction(string.format(_("buttonGM", "%i Patience - -> %i"),patienceTimeLimit/60,(patienceTimeLimit - 300)/60),function()
			patienceTimeLimit = patienceTimeLimit - 300
			original_patience_time_limit = patienceTimeLimit
			setPatienceTimeLimit()
		end)
	end
end
function setStartDelay()
	clearGMFunctions()
	addGMFunction(_("buttonGM", "-Main"),mainGMButtons)
	if raceStartDelay < 1200 then
		addGMFunction(string.format(_("buttonGM", "%i Delay + -> %i"),raceStartDelay/60,(raceStartDelay + 60)/60),function()
			raceStartDelay = raceStartDelay + 60
			original_race_start_delay = raceStartDelay
			setStartDelay()
		end)
	end
	if raceStartDelay > 60 then
		addGMFunction(string.format(_("buttonGM", "%i Delay - -> %i"),raceStartDelay/60,(raceStartDelay - 60)/60),function()
			raceStartDelay = raceStartDelay - 60
			original_race_start_delay = raceStartDelay
			setStartDelay()
		end)
	end
end
--	GM buttons after pause
function mainGMButtonsAfterPause()
	clearGMFunctions()
	addGMFunction(string.format(_("buttonGM", "Version %s"),scenario_version),function()
		local version_message = string.format(_("msgGM", "Scenario version %s\n LUA version %s"),scenario_version,_VERSION)
		addGMMessage(version_message)
		print(version_message)
	end)
	addGMFunction(_("buttonGM", "Show control codes"),showControlCodes)
	addGMFunction(_("buttonGM", "Show statistics"),function()
		local stats = gatherStats()
		local out = _("msgGM", "Current Statistics:\nShip: state, laps, waypoint goal, drone pts")
		for name, details in pairs(stats.ship) do
			out = out .. "\n" .. name .. ": " 
			if details.is_alive then 
				out = out .. _("msgGM", "alive, ")
			else
				out = out .. _("msgGM", "dead, ")
			end
			if details.participant ~= nil then
				out = out .. details.participant .. _("msgGM", ", ")
			end
--			if details.participant == "participant" then
--				out = out .. "participant, "
--			else
--				out = out .. "forfeit, "
--			end
			out = string.format(_("msgGM", "%s%i, %i, %i"),out,details.lap_count,details.waypoint_goal,details.drone_points)
		end
		if raceStartDelay < 0 then
			if player_count == original_player_count then
				out = string.format(_("msgGM","%s\n\nWith %i racers, we have the following points awarded for final race place:"),out,player_count)
			else
				out = string.format(_("msgGM","%s\n\nWith %i racers remaining from the original %i registrants, we have the following points awarded for final race place:"),out,player_count,original_player_count)
			end
			local place_name = {
				_("msgGM","First"),
				_("msgGM","Second"),
				_("msgGM","Third"),
				_("msgGM","Fourth"),
				_("msgGM","Fifth"),
				_("msgGM","Sixth"),
				_("msgGM","Seventh"),
				_("msgGM","Eighth"),
				_("msgGM","Ninth"),
				_("msgGM","Tenth"),
			}
			for i=1,#reward_grid[player_count] do
				if reward_grid[player_count][i] > 0 then
					out = string.format(_("msgGM", "%s\n    %s:%s"),out,place_name[i],reward_grid[player_count][i])
				else
					break
				end
			end
		end
		addGMMessage(out)
	end)
	addGMFunction(_("buttonGM","Show final results"),function()
		gMsg = _("msgGM","Final results:\nNote: this data appears on the main screen after the race is complete. If the race is not complete, what you see here may not be accurate.")
		competeResults()
		addGMMessage(gMsg)
	end)
end

function setStations()
	afd = 30	-- asteroid field density
	stationList = {}
	station_upgrade_list = {}
	totalStations = 0
	friendlyStations = 0
	neutralStations = 0
	--Timer
	stationTimer = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCommsScript(""):setCommsFunction(commsStation)
	stationTimer:setPosition(-5000,-5000):setDescription(_("scienceDescription-station", "Race Timing Facility")):setCallSign("Timer")
	table.insert(stationList,stationTimer)
	--Vaiken
	stationVaiken = placeStation(random(-10000,5000), random(5000,9000), "Vaiken", "Human Navy", "Huge Station")
	table.insert(stationList,stationVaiken)
	stationVaiken.comms_data.goods.food = {cost = 1, quantity = 10}
	stationVaiken.comms_data.goods.medicine = {cost = 5, quantity = 5}
	--Zefram
	stationZefram = placeStation(random(5000,8000),random(-8000,9000),"Zefram","Human Navy","Medium Station")
	table.insert(stationList,stationZefram)
	stationZefram.comms_data.goods.warp = {cost = 140, quantity = 5}
	stationZefram.comms_data.goods.food = {cost = 1, quantity = 5}
	--Marconi
	local marconiAngle = random(0,360)
	local xMarconi, yMarconi = vectorFromAngle(marconiAngle,random(12500,15000))
	stationMarconi = placeStation(xMarconi,yMarconi,"Marconi","Independent","Small Station")
	table.insert(stationList,stationMarconi)
	stationMarconi.comms_data.goods.beam = {cost = 80, quantity = 5}
	--Muddville
	local muddAngle = marconiAngle + random(60,180)
	local xMudd, yMudd = vectorFromAngle(muddAngle,random(12500,15000))
	stationMudd = placeStation(xMudd,yMudd,"Muddville","Independent","Medium Station")
	table.insert(stationList,stationMudd)
	stationMudd.comms_data.goods.luxury = {cost = 60, quantity = 10}
	--Alcaleica
	xAlcaleica, yAlcaleica = vectorFromAngle(muddAngle + random(60,120),random(12500,15000))
	stationAlcaleica = placeStation(xAlcaleica,yAlcaleica,"Alcaleica","Independent","Small Station")
	table.insert(stationList,stationAlcaleica)
	stationAlcaleica.comms_data.goods.optic = {cost = 66, quantity = 5}
	--California
	stationCalifornia = placeStation(random(-90000,-70000),random(-15000,25000),"California","Human Navy","Small Station")
	table.insert(stationList,stationCalifornia)
	stationCalifornia.comms_data.goods.food = {cost = 1, quantity = 2}
	stationCalifornia.comms_data.goods.gold = {cost = 25, quantity = 5}
	stationCalifornia.comms_data.goods.dilithium = {cost = 25, quantity = 2}
	--Outpost-15
	stationOutpost15 = placeStation(random(35000,50000),random(52000,79000),"Outpost-15","Independent","Small Station")
	table.insert(stationList,stationOutpost15)
	placeRandomAroundPoint(Asteroid,25,1,15000,60000,75000)
	--Outpost-21
	stationOutpost21 = placeStation(random(50000,75000),random(52000,61250),"Outpost-21","Independent","Small Station")
	table.insert(stationList,stationOutpost21)
	if random(1,100) < 50 then
		stationOutpost15.comms_data.goods.luxury = {cost = 70, quantity = 5}
		stationOutpost15.comms_data.goods.gold = {cost = 25, quantity = 5}
		stationOutpost21.comms_data.goods.cobalt = {cost = 50, quantity = 4}
	else
		stationOutpost21.comms_data.goods.luxury = {cost = 70, quantity = 5}
		stationOutpost21.comms_data.goods.gold = {cost = 25, quantity = 5}
		stationOutpost15.comms_data.goods.cobalt = {cost = 50, quantity = 4}
	end
	--Valero
	stationValero = placeStation(random(-88000,-65000),random(36250,40000),"Valero","Independent","Small Station")
	table.insert(stationList,stationValero)
	stationValero.comms_data.goods.luxury = {cost = 77, quantity = 5}
	--Vactel
	local vactelAngle = random(0,360)
	local xVactel, yVactel = vectorFromAngle(vactelAngle,random(50000,61250))
	stationVactel = placeStation(xVactel,yVactel,"Vactel","Independent","Small Station")
	table.insert(stationList,stationVactel)
	stationVactel.comms_data.goods.circuit = {cost = 50, quantity = 5}
	--Archer
	local archerAngle = vactelAngle + random(60,120)
	local xArcher, yArcher = vectorFromAngle(archerAngle,random(50000,61250))
	stationArcher = placeStation(xArcher,yArcher,"Archer","Independent","Small Station")
	table.insert(stationList,stationArcher)
	stationArcher.comms_data.goods.shield = {cost = 90, quantity = 5}
	--Deer
	local deerAngle = archerAngle + random(60,120)
	local xDeer, yDeer = vectorFromAngle(deerAngle,random(50000,61250))
	stationDeer = placeStation(xDeer,yDeer,"Deer","Independent","Small Station")
	table.insert(stationList,stationDeer)
	stationDeer.comms_data.goods.tractor = {cost = 90, quantity = 5}
	stationDeer.comms_data.goods.repulsor = {cost = 95, quantity = 5}
	--Cavor
	local cavorAngle = deerAngle + random(60,90)
	local xCavor, yCavor = vectorFromAngle(cavorAngle,random(50000,61250))
	stationCavor = placeStation(xCavor,yCavor,"Cavor","Independent","Small Station")
	table.insert(stationList,stationCavor)
	stationCavor.comms_data.goods.filament = {cost = 42, quantity = 5}
	--Emory
	stationEmory = placeStation(random(72000,85000),random(-50000,-26000),"Erickson","Human Navy","Small Station")
	table.insert(stationList,stationEmory)
	stationEmory.comms_data.goods.transporter = {cost = 63, quantity = 5}
	stationEmory.comms_data.goods.food = {cost = 1, quantity = 2}
	--Veloquan
	stationVeloquan = placeStation(random(-25000,15000),random(27000,40000),"Veloquan","Independent","Small Station")
	table.insert(stationList,stationVeloquan)
	stationVeloquan.comms_data.goods.sensor = {cost = 68, quantity = 5}
	--Barclay
	stationBarclay = placeStation(random(-20000,0),random(-45000,-25000),"Barclay","Independent","Small Station")
	table.insert(stationList,stationBarclay)
	stationBarclay.comms_data.goods.communication = {cost = 58, quantity = 5}
	--Lipkin
	stationLipkin = placeStation(random(20000,45000),random(-25000,-15000),"Lipkin","Independent","Small Station")
	table.insert(stationList,stationLipkin)
	stationLipkin.comms_data.goods.autodoc = {cost = 7, quantity = 5}
	--Ripley
	stationRipley = placeStation(random(-75000,-30000),random(55000,62150),"Ripley","Independent","Small Station")
	table.insert(stationList,stationRipley)
	stationRipley.comms_data.goods.lifter = {cost = 61, quantity = 5}
	--Deckard
	stationDeckard = placeStation(random(-45000,-25000),random(-25000,-14000),"Deckard","Independent","Small Station")
	table.insert(stationList,stationDeckard)
	stationDeckard.comms_data.goods.android = {cost = 73, quantity = 5}
	--Conner
	stationConnor = placeStation(random(-10000,15000),random(15000,27000),"Starnet","Independent","Small Station")
	table.insert(stationList,stationConnor)
	--Anderson
	stationAnderson = placeStation(random(15000,20000),random(-25000,48000),"Anderson","Independent","Small Station")
	table.insert(stationList,stationAnderson)
	stationAnderson.comms_data.goods.battery = {cost = 65, quantity = 5}
	stationAnderson.comms_data.goods.software = {cost = 115, quantity = 5}	
	--Feynman
	stationFeynman = placeStation(random(-90000,-55000),random(25000,36250),"Feynman","Human Navy","Small Station")
	table.insert(stationList,stationFeynman)
	stationFeynman.comms_data.goods.nanites = {cost = 79, quantity = 5}
	stationFeynman.comms_data.goods.software = {cost = 115, quantity = 5}
	stationFeynman.comms_data.goods.food = {cost = 1, quantity = 2}
	--Mayo
	stationMayo = placeStation(random(-45000,-30000),random(-14000,12500),"Mayo","Human Navy","Large Station")
	table.insert(stationList,stationMayo)
	stationMayo.comms_data.goods.food = {cost = 1, quantity = 5}
	stationMayo.comms_data.goods.medicine = {cost = 5, quantity = 5}
	--Nefatha
	stationNefatha = placeStation(random(-10000,12500),random(-96000,-80000),"Nefatha","Independent","Medium Station")
	table.insert(stationList,stationNefatha)
	stationNefatha.comms_data.goods.luxury = {cost = 70, quantity = 5}
	--Science-4
	stationScience4 = placeStation(random(-60000,-40000),random(47000,55000),"Science-4","Independent","Medium Station")
	table.insert(stationList,stationScience4)
	--Research-19
	stationResearch19 = placeStation(random(-26000,-15000),random(-10000,27000),"Research-19","Independent","Small Station")
	table.insert(stationList,stationResearch19)
	--Tiberius
	stationTiberius = placeStation(random(-30000,-26000),random(-14000,35000),"Tiberius","Human Navy","Medium Station")
	table.insert(stationList,stationTiberius)
	stationTiberius.comms_data.goods.food = {cost = 1, quantity = 5}
	--Research-11
	stationResearch11 = placeStation(random(-75000,-55000),random(-50000,-25000),"Research-11","Independent","Small Station")
	table.insert(stationList,stationResearch11)
	--Madison
	stationMadison = placeStation(random(0,15000),irandom(-37500,-15000),"Madison","Independent","Small Station")
	table.insert(stationList,stationMadison)
	--Outpost-33
	stationOutpost33 = placeStation(random(15000,65000),random(-65000,-25000),"Outpost-33","Independent","Small Station")
	table.insert(stationList,stationOutpost33)
	stationOutpost33.comms_data.goods.luxury = {cost = 75, quantity = 5}
	--Lando
	stationLando = placeStation(random(-60000,-30000),random(612500,70000),"Lando","Independent","Small Station")
	table.insert(stationList,stationLando)
	--Komov
	stationKomov = placeStation(random(-55000,-30000),random(70000,80000),"Komov","Independent","Small Station")
	table.insert(stationList,stationKomov)
	--Science-2
	stationScience2 = placeStation(random(20000,35000),random(55000,70000),"Science-2","Independent","Medium Station")
	table.insert(stationList,stationScience2)
	--Prada
	stationPrada = placeStation(random(-65000,-60000),random(36250,55000),"Prada","Independent","Small Station")
	table.insert(stationList,stationPrada)
	stationPrada.comms_data.goods.luxury = {cost = 45, quantity = 5}
	--Outpost-7
	stationOutpost7 = placeStation(random(35000,45000),random(-15000,25000),"Outpost-7","Independent","Small Station")
	table.insert(stationList,stationOutpost7)
	stationOutpost7.comms_data.goods.luxury = {cost = 80, quantity = 5}
	--Organa
	stationOrgana = placeStation(irandom(55000,62000),random(20000,45000),"Organa","Independent","Small Station")
	table.insert(stationList,stationOrgana)
	--Grap
	local xGrap = random(-20000,0)
	local yGrap = random(-25000,-20000)
	stationGrap = placeStation(xGrap,yGrap,"Grap","Independent","Small Station")
	local posAxisGrap = random(0,360)
	local posGrap = random(10000,60000)
	local negGrap = random(10000,60000)
	local spreadGrap = random(4000,8000)
	local negAxisGrap = posAxisGrap + 180
	local xPosAngleGrap, yPosAngleGrap = vectorFromAngle(posAxisGrap, posGrap)
	local posEnd = random(40,90)
	createRandomAlongArc(Asteroid, afd+posEnd, xGrap+xPosAngleGrap, yGrap+yPosAngleGrap, posGrap, negAxisGrap, negAxisGrap+posEnd, spreadGrap)
	local xNegAngleGrap, yNegAngleGrap = vectorFromAngle(negAxisGrap, negGrap)
	local negEnd = random(20,60)
	createRandomAlongArc(Asteroid, afd+negEnd, xGrap+xNegAngleGrap, yGrap+yNegAngleGrap, negGrap, posAxisGrap, posAxisGrap+negEnd, spreadGrap)
	table.insert(stationList,stationGrap)
	--Grup
	local xGrup = random(-20000,-10000)
	local yGrup = random(15000,30000)
	stationGrup = placeStation(xGrup,yGrup,"Grup","Independent","Small Station")
	local axisGrup = random(0,360)
	local longGrup = random(30000,60000)
	local shortGrup = random(10000,30000)
	local spreadGrup = random(5000,8000)
	local negAxisGrup = axisGrup + 180
	local xLongAngleGrup, yLongAngleGrup = vectorFromAngle(axisGrup, longGrup)
	local longGrupEnd = random(30,70)
	createRandomAlongArc(Asteroid, afd+longGrupEnd, xGrup+xLongAngleGrup, yGrup+yLongAngleGrup, longGrup, negAxisGrup, negAxisGrup+longGrupEnd, spreadGrup)
	local xShortAngleGrup, yShortAngleGrup = vectorFromAngle(axisGrup, shortGrup)
	local shortGrupEnd = random(40,90)
	local shortGrupEndQ = shortGrupEnd
	shortGrupEnd = negAxisGrup - shortGrupEnd
	if shortGrupEnd < 0 then 
		shortGrupEnd = shortGrupEnd + 360
	end
	createRandomAlongArc(Asteroid, afd+shortGrupEndQ, xGrup+xShortAngleGrup, yGrup+yShortAngleGrup, shortGrup, shortGrupEnd, negAxisGrup, spreadGrup)
	table.insert(stationList,stationGrup)
	if random(1,100) < 50 then
		stationGrap.comms_data.goods.nickel = {cost = 20, quantity = 5}
		stationGrap.comms_data.goods.tritanium = {cost = 50, quantity = 5}
		stationGrup.comms_data.goods.nickel = {cost = 22, quantity = 3}
		stationGrup.comms_data.goods.dilithium = {cost = 50, quantity = 5}
		stationGrup.comms_data.goods.platinum = {cost = 70, quantity = 5}
	else
		stationGrup.comms_data.goods.nickel = {cost = 20, quantity = 5}
		stationGrup.comms_data.goods.tritanium = {cost = 50, quantity = 5}
		stationGrap.comms_data.goods.nickel = {cost = 22, quantity = 3}
		stationGrap.comms_data.goods.dilithium = {cost = 50, quantity = 5}
		stationGrap.comms_data.goods.platinum = {cost = 70, quantity = 5}
	end
	--Outpost-8
	stationOutpost8 = placeStation(random(-65000,-40000),random(-61250,-50000),"Outpost-8","Independent","Small Station")
	table.insert(stationList,stationOutpost8)
	--Science-7
	stationScience7 = placeStation(random(-25000,-20000),random(-40000,-10000),"Science-7","Human Navy","Small Station")
	table.insert(stationList,stationScience7)
	stationScience7.comms_data.goods.food = {cost = 1, quantity = 2}
	--Carradine
	stationCarradine = placeStation(random(20000,35000),random(-15000,40000),"Carradine","Independent","Small Station")
	table.insert(stationList,stationCarradine)
	--Calvin
	stationCalvin = placeStation(random(40000,86250),random(45000,51000),"Calvin","Independent","Medium Station")
	table.insert(stationList,stationCalvin)
	--Artifacts. Just color (for now)
	art1 = Artifact():setModel("artifact4"):allowPickup(false):setScanningParameters(2,2):setRadarSignatureInfo(random(4,20),random(2,12), random(7,13))
	art2 = Artifact():setModel("artifact5"):allowPickup(false):setScanningParameters(2,3):setRadarSignatureInfo(random(2,12),random(7,13), random(4,20))
	art3 = Artifact():setModel("artifact6"):allowPickup(false):setScanningParameters(3,2):setRadarSignatureInfo(random(7,13),random(4,20), random(2,12))
	art1:setPosition(random(-50000,50000),random(-80000,-70000))
	art2:setPosition(random(-90000,-75000),random(-40000,-20000))
	art3:setPosition(random(50000,75000),random(625000,80000))
	artChoice = math.random(6)
	if artChoice == 1 then
		art1:setDescriptions(_("scienceDescription-artifact", "Unusual object"),_("scienceDescription-artifact", "Artifact with quantum biometric characteristics"))
		art2:setDescriptions(_("scienceDescription-artifact", "Unusual object"),_("scienceDescription-artifact", "Artifact with embedded chroniton particles"))
		art3:setDescriptions(_("scienceDescription-artifact", "Unusual object"),_("scienceDescription-artifact", "Artifact bridging two parallel universes"))
		art1.quantum = true
		art2.chroniton = true
		art3.parallel = true
	elseif artChoice == 2 then
		art1:setDescriptions(_("scienceDescription-artifact", "Unusual object"),_("scienceDescription-artifact", "Artifact with quantum biometric characteristics"))
		art3:setDescriptions(_("scienceDescription-artifact", "Unusual object"),_("scienceDescription-artifact", "Artifact with embedded chroniton particles"))
		art2:setDescriptions(_("scienceDescription-artifact", "Unusual object"),_("scienceDescription-artifact", "Artifact bridging two parallel universes"))
		art1.quantum = true
		art3.chroniton = true
		art2.parallel = true
	elseif artChoice == 3 then
		art2:setDescriptions(_("scienceDescription-artifact", "Unusual object"),_("scienceDescription-artifact", "Artifact with quantum biometric characteristics"))
		art1:setDescriptions(_("scienceDescription-artifact", "Unusual object"),_("scienceDescription-artifact", "Artifact with embedded chroniton particles"))
		art3:setDescriptions(_("scienceDescription-artifact", "Unusual object"),_("scienceDescription-artifact", "Artifact bridging two parallel universes"))
		art2.quantum = true
		art1.chroniton = true
		art3.parallel = true
	elseif artChoice == 4 then
		art2:setDescriptions(_("scienceDescription-artifact", "Unusual object"),_("scienceDescription-artifact", "Artifact with quantum biometric characteristics"))
		art3:setDescriptions(_("scienceDescription-artifact", "Unusual object"),_("scienceDescription-artifact", "Artifact with embedded chroniton particles"))
		art1:setDescriptions(_("scienceDescription-artifact", "Unusual object"),_("scienceDescription-artifact", "Artifact bridging two parallel universes"))
		art2.quantum = true
		art3.chroniton = true
		art1.parallel = true
	elseif artChoice == 5 then
		art3:setDescriptions(_("scienceDescription-artifact", "Unusual object"),_("scienceDescription-artifact", "Artifact with quantum biometric characteristics"))
		art1:setDescriptions(_("scienceDescription-artifact", "Unusual object"),_("scienceDescription-artifact", "Artifact with embedded chroniton particles"))
		art2:setDescriptions(_("scienceDescription-artifact", "Unusual object"),_("scienceDescription-artifact", "Artifact bridging two parallel universes"))
		art3.quantum = true
		art1.chroniton = true
		art2.parallel = true
	else
		art3:setDescriptions(_("scienceDescription-artifact", "Unusual object"),_("scienceDescription-artifact", "Artifact with quantum biometric characteristics"))
		art2:setDescriptions(_("scienceDescription-artifact", "Unusual object"),_("scienceDescription-artifact", "Artifact with embedded chroniton particles"))
		art1:setDescriptions(_("scienceDescription-artifact", "Unusual object"),_("scienceDescription-artifact", "Artifact bridging two parallel universes"))
		art3.quantum = true
		art2.chroniton = true
		art1.parallel = true
	end
	enemy_stations = {}
	--Ganalda
	local ganaldaAngle = random(0,360)
	local xGanalda, yGanalda = vectorFromAngle(ganaldaAngle,random(120000,150000))
	stationGanalda = placeStation(xGanalda,yGanalda,"Ganalda","Kraylor","Medium Station")
	table.insert(enemy_stations,stationGanalda)
	--Empok Nor
	local empokAngle = ganaldaAngle + random(60,180)
	local xEmpok, yEmpok = vectorFromAngle(empokAngle,random(120000,150000))
	stationEmpok = placeStation(xEmpok,yEmpok,"Empok Nor","Exuari","Large Station")
	table.insert(enemy_stations,stationEmpok)
	--Ticonderoga
	local ticAngle = empokAngle + random(60,120)
	local xTic, yTic = vectorFromAngle(ticAngle,random(120000,150000))
	stationTic = placeStation(xTic,yTic,"Ticonderoga","Kraylor","Medium Station")
	table.insert(enemy_stations,stationTic)
	--Nebulae
	createRandomAlongArc(Nebula, 15, 100000, -100000, 140000, 100, 170, 25000)
	Nebula():setPosition(xGanalda,yGanalda)
	local gDist = distance(stationGanalda,0,0)
	createRandomAlongArc(Nebula, 5, 0, 0, gDist,ganaldaAngle-20, ganaldaAngle+20, 9000)
	--Alderaan
	alderaan= Planet():setPosition(random(-27000,32000),random(65500,87500)):setPlanetRadius(3000):setDistanceFromMovementPlane(-2000):setCallSign("Alderaan")
	alderaan:setPlanetSurfaceTexture("planets/planet-1.png"):setPlanetCloudTexture("planets/clouds-1.png")
	alderaan:setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.2,0.2,1.0)
	alderaan:setAxialRotationTime(400.0):setDescription(_("scienceDescription-planet", "Lush planet with only mild seasonal variations"))
	--Grawp
	grawp = BlackHole():setPosition(random(67000,90000),random(-21000,40000))
	grawp.angle = random(0,360)
	grawp.travel = random(1,5)
	-- determine which stations will trade food, luxury items and/or medicine for their goods
	stationGrap.comms_data.trade.food = true
	stationGrap.comms_data.trade.medicine = true
	stationGrap.comms_data.trade.luxury = random(1,100) < 50
	stationGrup.comms_data.trade.food = true
	stationGrup.comms_data.trade.medicine = true
	stationGrup.comms_data.trade.luxury = true
	stationOutpost15.comms_data.trade.food = true
	stationOutpost21.comms_data.trade.food = true
	stationOutpost21.comms_data.trade.luxury = true
	stationOutpost21.comms_data.trade.medicine = random(1,100) < 50
	stationCarradine.comms_data.trade.luxury = true
	stationCarradine.comms_data.trade.medicine = true
	stationZefram.comms_data.trade.food = true
	stationZefram.comms_data.trade.luxury = true
	stationArcher.comms_data.trade.luxury = true
	stationArcher.comms_data.trade.medicine = true
	stationDeer.comms_data.trade.food = true
	stationDeer.comms_data.trade.medicine = true
	stationDeer.comms_data.trade.luxury = true
	stationMarconi.comms_data.trade.luxury = true
	stationMarconi.comms_data.trade.food = true
	stationAlcaleica.comms_data.trade.food = true
	stationAlcaleica.comms_data.trade.medicine = true
	stationCalvin.comms_data.trade.luxury = true
	local whatTrade = random(1,100)
	stationCavor.comms_data.trade.medicine = whatTrade < 33
	stationCavor.comms_data.trade.food = whatTrade > 66
	stationCavor.comms_data.trade.luxury = (whatTrade >= 33 and whatTrade <= 66)
	stationEmory.comms_data.trade.food = true
	stationEmory.comms_data.trade.medicine = true
	stationEmory.comms_data.trade.luxury = true
	stationVeloquan.comms_data.trade.food = true
	stationVeloquan.comms_data.trade.medicine = true
	stationBarclay.comms_data.trade.medicine = true
	stationLipkin.comms_data.trade.food = true
	stationLipkin.comms_data.trade.medicine = true
	stationLipkin.comms_data.trade.luxury = true
	stationRipley.comms_data.trade.luxury = true
	stationRipley.comms_data.trade.food = true
	stationDeckard.comms_data.trade.luxury = true
	stationDeckard.comms_data.trade.food = true
	stationAnderson.comms_data.trade.luxury = true
	stationAnderson.comms_data.trade.food = true
	stationFeynman.comms_data.trade.food = true
	stationOutpost33.comms_data.trade.medicine = true
	upgrade_goods = {}
	--set spin upgrade values
	local spinRandom = math.random(1,3)
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
	table.insert(upgrade_goods,spinComponent)
	spinBump = random(20,80)
	--set tube upgrade values
	local tubeRandom = math.random(1,3)
	if tubeRandom == 1 then
		tubeStation = stationVeloquan
	elseif tubeRandom == 2 then
		tubeStation = stationOutpost33
	else
		tubeStation = stationPrada
	end
	tubeRandom = math.random(1,3)
	if tubeRandom == 1 then
		tubeComponent = "tractor"
	elseif tubeRandom == 2 then
		tubeComponent = "nickel"
	else
		tubeComponent = "communication"
	end
	table.insert(upgrade_goods,tubeComponent)
	--set beam range upgrade values
	beamRangeBump = random(15,60)
	local beamRandom = math.random(1,3)
	if beamRandom == 1 then
		beamComponent = "filament"
	elseif beamRandom == 2 then
		beamComponent = "battery"
	else
		beamComponent = "optic"
	end
	table.insert(upgrade_goods,beamComponent)
	--set shield upgrade values
	local shieldRandom = math.random(1,3)
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
	table.insert(upgrade_goods,shieldComponent)
	shieldBump = random(40,80)
	--set energy upgrade values
	local energyRandom = math.random(1,3)
	if energyRandom == 1 then
		energyComponent = "beam"
	elseif energyRandom == 2 then
		energyComponent = "autodoc"
	else
		energyComponent = "warp"
	end
	table.insert(upgrade_goods,energyComponent)
	table.insert(upgrade_goods,"nanites")
	table.insert(upgrade_goods,"robotic")
	table.insert(upgrade_goods,"tritanium")
	table.insert(upgrade_goods,"dilithium")
	station_upgrade_list = {
		{station = stationZefram,		upgrade = _("upgrade-comms","jump drive"),			desc = _("upgrade-comms", "We can upgrade your jump drive maximum range for nanites or robotic goods")},
		{station = stationCarradine,	upgrade = _("upgrade-comms","impulse drive"),		desc = string.format(_("upgrade-comms", "We can increase the speed of your impulse engines by %.2f percent for tritanium or dilithium"),impulseBump)},
		{station = spinStation,			upgrade = _("upgrade-comms","maneuver"),			desc = string.format(_("upgrade-comms", "We can increase the your rotate speed by %.2f percent for %s"),spinBump,good_desc[spinComponent])},
		{station = stationMarconi,		upgrade = _("upgrade-comms","beam range"),			desc = string.format(_("upgrade-comms", "We can increase the range of your beam weapons by %.2f percent for %s"),beamRangeBump,good_desc[beamComponent])},
		{station = tubeStation,			upgrade = _("upgrade-comms","extra missile tube"),	desc = string.format(_("upgrade-comms", "We can add a homing missile tube to your ship for %s"),good_desc[tubeComponent])},
		{station = shieldStation,		upgrade = _("upgrade-comms","shield"),				desc = string.format(_("upgrade-comms", "We can upgrade your shields by %.2f percent for %s"),shieldBump,good_desc[shieldComponent])},
		{station = stationNefatha,		upgrade = _("upgrade-comms","energy capacity"),		desc = string.format(_("upgrade-comms", "We can upgrade your energy capacity by 25 percent for %s"),good_desc[energyComponent])},
	}
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
	local player_count = #getActivePlayerShips()
	for i=1,player_count do
		local psx, psy = vectorFromAngle(random(0,360),random(80000,120000))
		local objects = getObjectsInRadius(psx,psy,5000)
		if objects == nil or #objects < 1 then
			local placed_station = placeStation(psx,psy,"Sinister","Kraylor")
			table.insert(enemy_stations,placed_station)
			if random(1,100) < 77 then
				Nebula():setPosition(psx,psy)
			end
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
    if comms_source:isFriendly(comms_target) then
		oMsg = _("station-comms", "Good day, officer!\nWhat can we do for you today?\n")
    else
		oMsg = _("station-comms", "Welcome to our lovely station.\n")
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. _("station-comms", "Forgive us if we seem a little distracted. We are carefully monitoring the enemies nearby.")
	end
	setCommsMessage(oMsg)
	missilePresence = 0
	local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	for i, missile_type in ipairs(missile_types) do
		missilePresence = missilePresence + comms_source:getWeaponStorageMax(missile_type)
	end
	if missilePresence > 0 then
		addCommsReply(_("ammo-comms", "I need ordnance restocked"), function()
			setCommsMessage(_("ammo-comms", "What type of ordnance?"))
			for i, missile_type in ipairs(missile_types) do
				if comms_source:getWeaponStorageMax(missile_type) > 0 then
					addCommsReply(string.format(_("ammo-comms", "%s (%d rep each)"), missile_type, getWeaponCost(missile_type)), function()
						handleWeaponRestock(missile_type)
					end)
				end
			end
		end)
	end
	if comms_source:isFriendly(comms_target) then
		addCommsReply(_("orders-comms", "What are my current orders?"), function()
			ordMsg = primaryOrders
			if raceStartDelay > 0 then
				ordMsg = ordMsg .. string.format(_("orders-comms", "\n%i Seconds remain until start of race"),raceStartDelay)
			else
				if comms_source.goal ~= nil then
					ordMsg = ordMsg .. string.format(_("orders-comms", "\nImmediate goal: race waypoint %i"),comms_source.goal)
				end
			end
			setCommsMessage(ordMsg)
			addCommsReply(_("Back"), commsStation)
		end)
	end
	addCommsReply(_("upgrade-comms",  "Do you upgrade spaceships?"), function()
		for i,station_info in ipairs(station_upgrade_list) do
			if station_info.station == comms_target then
				setCommsMessage(station_info.desc)
				break
			else
				setCommsMessage(_("upgrade-comms", "We don't upgrade spaceships"))
			end
		end
		addCommsReply(_("Back"), commsStation)
	end)
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
		local out = _("cartographyOffice-comms","Without looking at you, the clerk tells you that the cartographers are out of the office for the race. They left this list of stations that provide upgrades for any racer that dropped by:")
		if comms_target:isFriendly(comms_source) then
			for i,station_info in ipairs(station_upgrade_list) do
				if station_info.station:isValid() then
					out = string.format(_("upgrade-comms","%s\nSector:%s Station:%s Upgrade:%s"),out,station_info.station:getSectorName(),station_info.station:getCallSign(),station_info.upgrade)
				end
			end
		else
			out = _("cartographyOffice-comms","Without looking at you, the clerk tells you that the cartographers are out of the office for the race. They left this list of neutral station locations in the area and what goods they might sell for any racer that dropped by:")
			for i,station in ipairs(stationList) do
				if station:isValid() and not station:isFriendly(comms_source) and not station:isEnemy(comms_source) then
					out = string.format(_("cartographyOffice-comms","%s\n%s %s"),out,station:getSectorName(),station:getCallSign())
					if station.comms_data == nil then
						out = string.format(_("cartographyOffice-comms","%s: none"),out)
					else
						if station.comms_data.goods == nil then
							out = string.format(_("cartographyOffice-comms","%s: none"),out)
						else
							local good_present = false
							for good, good_data in pairs(station.comms_data.goods) do
								if good_data.quantity > 0 then
									if good_present then
										out = string.format(_("cartographyOffice-comms","%s, %s"),out,good)
									else
										out = string.format(_("cartographyOffice-comms","%s: %s"),out,good)
									end
									good_present = true
								end
							end
							if not good_present then
								out = string.format(_("cartographyOffice-comms","%s: none"),out)
							end
						end
					end
				end
			end
		end
		setCommsMessage(string.format(_("cartographyOffice-comms", "%s %s"),comms_target.cartographer_description,out))
		addCommsReply(_("Back"),commsStation)
	end)
	local commerce_available = false
	local station_sells = false
	local goods_for_sale = ""
	local player_has_goods = false
	local goods_in_cargo_hold = ""
	if comms_target.comms_data.goods ~= nil then
		for good, good_data in pairs(comms_target.comms_data.goods) do
			if good_data.quantity ~= nil and good_data.quantity > 0 then
				commerce_available = true
				station_sells = true
				goods_for_sale = string.format(_("trade-comms","%s\n%s %s @ %s"),goods_for_sale,good_data.quantity,good_desc[good],good_data.cost)
			end
		end
	end
	if comms_source.goods ~= nil then
		for good, quantity in pairs(comms_source.goods) do
			if quantity > 0 then
				player_has_goods = true
				goods_in_cargo_hold = string.format(_("trade-comms","%s\n%s: %s"),goods_in_cargo_hold,good_desc[good],quantity)
			end
		end
	end
	if commerce_available then
		addCommsReply(_("trade-comms", "Buy, sell, trade"), function()
			local oMsg = string.format(_("trade-comms","Goods or components available for sale here:%s"),goods_for_sale)
			if player_has_goods then
				oMsg = string.format(_("trade-comms","%s\nGoods in cargo hold:%s"),oMsg,goods_in_cargo_hold)
			else
				oMsg = string.format(_("trade-comms","%s\nCargo hold is empty"),oMsg)
			end
			oMsg = string.format(_("trade-comms","%s\nAvailable space:%s"),oMsg,comms_source.cargo)
			setCommsMessage(oMsg)
			if station_sells then
				local alt_goods = {}
				for good, good_data in pairs(comms_target.comms_data.goods) do
					if good_data["quantity"] > 0 then
						addCommsReply(string.format(_("trade-comms","Buy a %s for %s reputation"),good_desc[good],good_data["cost"]),function()
							if not comms_source:isDocked(comms_target) then
								setCommsMessage(_("trade-comms","You have to be docked to complete the transaction."))
								return
							end
							if comms_source.cargo < 1 then
								setCommsMessage(string.format(_("trade-comms","Not enough room on %s to purchase %s"),comms_source:getCallSign(),good_desc[good]))
							elseif good_data.quantity < 1 then
								setCommsMessage(string.format(_("trade-comms","%s ran out of %s."),comms_target:getCallSign(),good_desc[good]))
							elseif comms_source:takeReputationPoints(good_data["cost"]) then
								comms_source.cargo = comms_source.cargo - 1
								good_data["quantity"] = good_data["quantity"] - 1
								if comms_source.goods == nil then
									comms_source.goods = {}
								end
								if comms_source.goods[good] == nil then
									comms_source.goods[good] = 0
								end
								comms_source.goods[good] = comms_source.goods[good] + 1
								setCommsMessage(string.format(_("trade-comms","One %s purchased"),good_desc[good]))
							else
								setCommsMessage(_("trade-comms","Insufficient reputation"))
							end
						end)
					end
					for i,upgrade_good in ipairs(upgrade_goods) do
						if upgrade_good == good and comms_source:getReputationPoints() < good_data.cost then
							table.insert(alt_goods,good)
						end
					end
				end
				if #alt_goods > 0 then
					if comms_source.asteroid_contract ~= nil then
						local contract_match = false
						local contract_completed = false
						local player_contract = nil
						local pac_index = nil
						for i,pac in ipairs(comms_source.asteroid_contract) do
							if pac.station == comms_target then
								contract_match = true
								player_contract = pac
								if not pac.a:isValid() then
									contract_completed = true
								end
								pac_index = i
								break
							end
						end
						if contract_completed then
							for i,alt_good in ipairs(alt_goods) do
								addCommsReply(string.format(_("trade-comms","Accept %s for removing asteroid"),alt_good),function()
									if comms_source.goods == nil then
										comms_source.goods = {}
									end
									if comms_source.goods[alt_good] == nil then
										comms_source.goods[alt_good] = 0
									end
									comms_source.goods[alt_good] = comms_source.goods[alt_good] + 1
									comms_source.cargo = comms_source.cargo - 1
									comms_target.comms_data.goods[alt_good].quantity = math.max(0,comms_target.comms_data.goods[alt_good].quantity - 1)
									setCommsMessage(string.format(_("trade-comms","One %s obtained"),good_desc[alt_good]))
									table.remove(comms_source.asteroid_contract,pac_index)
									if #comms_source.asteroid_contract < 1 then
										comms_source.asteroid_contract = nil
									end
								end)
							end
						else
							if contract_match then
								addCommsReply(_("trade-comms","Where's the asteroid you want us to remove?"),function()
									local a_bearing = angleHeading(comms_station,player_contract.a)
									local a_dist = distance(comms_target,player_contract.a)/1000
									setCommsMessage(string.format(_("trade-comms","Bearing %.1f, distance %.1fu from %s"),a_bearing,a_dist,comms_target:getCallSign()))
								end)
							end
						end
					elseif comms_source.enemy_station_contract ~= nil then
						local contract_match = false
						local contract_completed = false
						local player_contract = nil
						local pesc_index = nil
						for i,pesc in ipairs(comms_source.enemy_station_contract) do
							if pesc.contractor == comms_target then
								contract_match = true
								planer_contract = pesc
								if not pesc.station:isValid() then
									contract_completed = true
								end
								pesc_index = i
								break
							end
						end
						if contract_completed then
							for i,alt_good in ipairs(alt_goods) do
								addCommsReply(string.format("Accept %s for removing station",alt_good),function()
									if comms_source.goods == nil then
										comms_source.goods = {}
									end
									if comms_source.goods[alt_good] == nil then
										comms_source.goods[alt_good] = 0
									end
									comms_source.goods[alt_good] = comms_source.goods[alt_good] + 1
									comms_source.cargo = comms_source.cargo - 1
									comms_target.comms_data.goods[alt_good].quantity = math.max(0,comms_target.comms_data.goods[alt_good].quantity - 1)
									setCommsMessage(string.format(_("trade-comms","One %s obtained"),good_desc[alt_good]))
									table.remove(comms_source.enemy_station_contract,pesc_index)
									if #comms_source.enemy_station_contract < 1 then
										comms_source.enemy_station_contract = nil
									end
								end)
							end
						else
							if contract_match then
								addCommsReply("What station did you want us to remove?",function()
									setCommsMessage(string.format("%s in sector %s",player_contract.station:getCallSign(),player_contract.station:getSectorName()))
								end)
							end
						end
					else
						local sx, sy = comms_target:getPosition()
						local objects = getObjectsInRadius(sx,sy,10000)
						local asteroids = {}
						for i,obj in ipairs(objects) do
							if isObjectType(obj,"Asteroid") then
								local ax, ay = obj:getPosition()
								local sx, sy = comms_target:getPosition()
								table.insert(asteroids,{a = obj, dist = distance(ax, ay, sx, sy)})
							end
						end
						if #asteroids > 0 then
							addCommsReply(_("trade-comms","Can I get goods without spending reputation?"),function()
								local out = _("trade-comms","We could give you")
								if #alt_goods > 1 then
									local alt_good_list_string = ""
									for i,alt_good in ipairs(alt_goods) do
										if alt_good_list_string == "" then
											alt_good_list_string = good_desc[alt_good]
										else
											alt_good_list_string = string.format(_("trade-comms","%s, %s"),alt_good_list_string,good_desc[alt_good])
										end
									end
									out = string.format(_("trade-comms","%s one of these (%s)"),out,alt_good_list_string)
								else
									out = string.format(_("trade-comms","%s %s"),out,good_desc[alt_goods[1]])
								end
								table.sort(asteroids,function(a,b)
									return a.dist < b.dist
								end)
								local sx, sy = comms_target:getPosition()
								local ax, ay = asteroids[1].a:getPosition()
								local a_bearing = angleHeading(sx, sy, ax, ay)
								out = string.format(_("trade-comms","%s if you removed the asteroid at bearing %.1f, distance %.1fu for us. It's been mined out and has become a navigation hazard."),out,a_bearing,asteroids[1].dist/1000)
								setCommsMessage(out)
								addCommsReply(_("trade-comms","Agree to remove the asteroid"),function()
									if comms_source.asteroid_contract == nil then
										comms_source.asteroid_contract = {}
									end
									table.insert(comms_source.asteroid_contract,{a = asteroids[1].a, station = comms_target})
									setCommsMessage(_("trade-comms","Come back and ask to buy your desired resource after you have removed the asteroid."))
								end)
							end)
						else
							--no nearby asteroids
							addCommsReply(_("trade-comms","Can I get goods without spending reputation?"),function()
								local out = _("trade-comms","The Human Navy can earn more reputation by destroying enemy stations. These enemies agree to remove their ships for the race since it benefits commerce in the area, but their stations are still here. Technically, we're supposed to leave them alone, but if some were 'accidentally' destroyed, that would facilitate some future business for us. These are the known enemy stations:")
								for i,station in ipairs(enemy_stations) do
									if station:isValid() then
										out = string.format(_("destroyTrade-comms","%s\n%s %s"),out,station:getSectorName(),station:getCallSign())
									end
								end
								setCommsMessage(out)
								addCommsReply(_("trade-comms","Would you exchange goods if we destroyed a station?"),function()
									local sorted_enemy_stations = {}
									local tx, ty = comms_target:getPosition()
									for i,station in ipairs(enemy_stations) do
										if station:isValid() then
											local sx, sy = station:getPosition()
											table.insert(sorted_enemy_stations,{station = station, dist = distance(tx, ty, sx, sy)})
										end
									end
									table.sort(sorted_enemy_stations,function(a, b)
										return a.dist < b.dist
									end)
									setCommsMessage(string.format(_("trade-comms","We could make an exchange if %s were destroyed. It's the closest and thus disrupts our business the most."),sorted_enemy_stations[1].station:getCallSign()))
									addCommsReply(string.format(_("trade-comms","Agree to destroy station %s"),sorted_enemy_stations[1].station:getCallSign()),function()
										if comms_source.enemy_station_contract == nil then
											comms_source.enemy_station_contract = {}
										end
										table.insert(comms_source.enemy_station_contract,{station = sorted_enemy_stations[1].station, contractor = comms_target})
										setCommsMessage(string.format(_("trade-comms","Come back and ask to buy your desired resource after %s has been removed."),sorted_enemy_stations[1].station:getCallSign()))
									end)
								end)
							end)
						end
					end
				end
			end
		end)
	end
	if goods[comms_target] ~= nil then
		addCommsReply(_("trade-comms", "Buy, sell, trade"), function()
			oMsg = _("trade-comms", "Goods or components available here: quantity, cost in reputation\n")
			gi = 1		-- initialize goods index
			repeat
				goodsType = goods[comms_target][gi][1]
				goodsQuantity = goods[comms_target][gi][2]
				goodsRep = goods[comms_target][gi][3]
				oMsg = oMsg .. string.format(_("trade-comms", "     %s: %i, %i\n"),goodsType,goodsQuantity,goodsRep)
				gi = gi + 1
			until(gi > #goods[comms_target])
			oMsg = oMsg .. _("trade-comms", "Current Cargo:\n")
			gi = 1
			cargoHoldEmpty = true
			repeat
				playerGoodsType = goods[comms_source][gi][1]
				playerGoodsQuantity = goods[comms_source][gi][2]
				if playerGoodsQuantity > 0 then
					oMsg = oMsg .. string.format(_("trade-comms", "     %s: %i\n"),playerGoodsType,playerGoodsQuantity)
					cargoHoldEmpty = false
				end
				gi = gi + 1
			until(gi > #goods[comms_source])
			if cargoHoldEmpty then
				oMsg = oMsg .. _("trade-comms", "     Empty\n")
			end
			playerRep = math.floor(comms_source:getReputationPoints())
			oMsg = oMsg .. string.format(_("trade-comms", "Available Space: %i, Available Reputation: %i\n"),comms_source.cargo,playerRep)
			setCommsMessage(oMsg)
			-- Buttons for reputation purchases
			gi = 1
			repeat
				local goodsType = goods[comms_target][gi][1]
				local goodsQuantity = goods[comms_target][gi][2]
				local goodsRep = goods[comms_target][gi][3]
				addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),goods[comms_target][gi][1],goods[comms_target][gi][3]), function()
					oMsg = string.format(_("trade-comms", "Type: %s, Quantity: %i, Rep: %i"),goodsType,goodsQuantity,goodsRep)
					if comms_source.cargo < 1 then
						oMsg = oMsg .. _("trade-comms", "\nInsufficient cargo space for purchase")
					elseif goodsRep > playerRep then
						oMsg = oMsg .. _("needRep-comms", "\nInsufficient reputation for purchase")
					elseif goodsQuantity < 1 then
						oMsg = oMsg .. _("trade-comms", "\nInsufficient station inventory")
					else
						if not comms_source:takeReputationPoints(goodsRep) then
							oMsg = oMsg .. _("needRep-comms", "\nInsufficient reputation for purchase")
						else
							comms_source.cargo = comms_source.cargo - 1
							decrementStationGoods(goodsType)
							incrementPlayerGoods(goodsType)
							oMsg = oMsg .. _("trade-comms", "\npurchased")
						end
					end
					setCommsMessage(oMsg)
					addCommsReply(_("Back"), commsStation)
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
						addCommsReply(string.format(_("trade-comms", "Trade food for %s"),goods[comms_target][gi][1]), function()
							oMsg = string.format(_("trade-comms", "Type: %s,  Quantity: %i"),goodsType,goodsQuantity)
							if goodsQuantity < 1 then
								oMsg = oMsg .. _("trade-comms", "\nInsufficient station inventory")
							else
								decrementStationGoods(goodsType)
								incrementPlayerGoods(goodsType)
								decrementPlayerGoods("food")
								oMsg = oMsg .. _("trade-comms", "\nTraded")
							end
							setCommsMessage(oMsg)
							addCommsReply(_("Back"), commsStation)
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
						addCommsReply(string.format(_("trade-comms", "Trade luxury for %s"),goods[comms_target][gi][1]), function()
							oMsg = string.format(_("trade-comms", "Type: %s,  Quantity: %i"),goodsType,goodsQuantity)
							if goodsQuantity < 1 then
								oMsg = oMsg .. _("trade-comms", "\nInsufficient station inventory")
							else
								decrementStationGoods(goodsType)
								incrementPlayerGoods(goodsType)
								decrementPlayerGoods("luxury")
								oMsg = oMsg .. _("trade-comms", "\nTraded")
							end
							setCommsMessage(oMsg)
							addCommsReply(_("Back"), commsStation)
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
						addCommsReply(string.format(_("trade-comms", "Trade medicine for %s"),goods[comms_target][gi][1]), function()
							oMsg = string.format(_("trade-comms", "Type: %s,  Quantity: %i"),goodsType,goodsQuantity)
							if goodsQuantity < 1 then
								oMsg = oMsg .. _("trade-comms", "\nInsufficient station inventory")
							else
								decrementStationGoods(goodsType)
								incrementPlayerGoods(goodsType)
								decrementPlayerGoods("medicine")
								oMsg = oMsg .. _("trade-comms", "\nTraded")
							end
							setCommsMessage(oMsg)
							addCommsReply(_("Back"), commsStation)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
			addCommsReply(_("Back"), commsStation)
		end)
	end
	if comms_target == stationZefram then
		if comms_source:hasJumpDrive() then
			if comms_source.goods ~= nil then
				if comms_source.goods.nanites ~= nil and comms_source.goods.nanites > 0 then
					addCommsReply(_("upgrade-comms", "Provide nanites for jump drive upgrade"), function()
						if comms_source.jump_upgrade then
							setCommsMessage(_("upgrade-comms", "You already have the upgrade"))
						else
							comms_source.goods.nanites = comms_source.goods.nanites - 1
							comms_source.cargo = comms_source.cargo + 1
							if comms_source:getTypeName() == "Player Fighter" then
								comms_source:setJumpDriveRange(3000,45000)
							else
								comms_source:setJumpDriveRange(5000,55000)
							end
							setCommsMessage(_("upgrade-comms", "Your jump drive has been upgraded"))
							comms_source.jump_upgrade = true
						end
					end)
				end
				if comms_source.goods.robotic ~= nil and comms_source.goods.robotic > 0 then
					addCommsReply(_("upgrade-comms", "Provide robotic for jump drive upgrade"), function()
						if comms_source.jump_upgrade then
							setCommsMessage(_("upgrade-comms", "You already have the jump drive upgrade"))
						else
							comms_source.goods.robotic = comms_source.goods.robotic - 1
							comms_source.cargo = comms_source.cargo + 1
							if comms_source:getTypeName() == "Player Fighter" then
								comms_source:setJumpDriveRange(3000,45000)
							else
								comms_source:setJumpDriveRange(5000,55000)
							end
							setCommsMessage(_("upgrade-comms", "Your jump drive has been upgraded"))
							comms_source.jump_upgrade = true
						end
					end)
				end
			end
		end
	end
	if comms_target == stationCarradine then
		if comms_source.goods ~= nil then
			if comms_source.goods.dilithium ~= nil and comms_source.goods.dilithium > 0 then
				addCommsReply(string.format(_("upgrade-comms", "Provide dilithium for %f percent impulse engine speed upgrade"),impulseBump), function()
					if comms_source.impulse_upgrade then
						setCommsMessage(_("upgrade-comms", "You already have the impulse drive upgrade"))
					else
						comms_source.goods.dilithium = comms_source.goods.dilithium - 1
						comms_source.cargo = comms_source.cargo + 1
						comms_source:setImpulseMaxSpeed(comms_source:getImpulseMaxSpeed()*(1+impulseBump/100))
						setCommsMessage(_("upgrade-comms", "Your impulse engine speed has been upgraded"))
						comms_source.impulse_upgrade = true
					end
				end)
			end
			if comms_source.goods.tritanium ~= nil and comms_source.goods.tritanium > 0 then
				addCommsReply(string.format(_("upgrade-comms", "Provide tritanium for %f percent impulse engine speed upgrade"),impulseBump), function()
					if comms_source.impulse_upgrade then
						setCommsMessage(_("upgrade-comms", "You already have the impulse drive upgrade"))
					else
						comms_source.goods.tritanium = comms_source.goods.tritanium - 1
						comms_source.cargo = comms_source.cargo + 1
						comms_source:setImpulseMaxSpeed(comms_source:getImpulseMaxSpeed()*(1+impulseBump/100))
						setCommsMessage(_("upgrade-comms", "Your impulse engine speed has been upgraded"))
						comms_source.impulse_upgrade = true
					end
				end)
			end
		end
	end
	if comms_target == spinStation then
		if comms_source.goods ~= nil then
			if comms_source.goods[spinComponent] > 0 then
				addCommsReply(string.format(_("upgrade-comms", "Provide %s for %.2f percent maneuver speed upgrade"),spinComponent,spinBump), function()
					if comms_source.spin_upgrade then
						setCommsMessage(_("upgrade-comms", "You already have the maneuver speed upgrade"))
					else
						comms_source.goods[spinComponent] = comms_source.goods[spinComponent] - 1
						comms_source.cargo = comms_source.cargo + 1
						comms_source:setRotationMaxSpeed(comms_source:getRotationMaxSpeed()*(1+spinBump/100))
						setCommsMessage(_("upgrade-comms", "Your spin speed has been upgraded"))
						comms_source.spin_upgrade = true
					end
				end)
			end
		end
	end
	if comms_target == stationMarconi then
		if comms_source.goods ~= nil then
			if comms_source.goods[beamComponent] > 0 then
				addCommsReply(string.format(_("upgrade-comms", "Provide %s for %.2f percent beam range upgrade"),beamComponent,beamRangeBump), function()
					if comms_source.beam_range_upgrade then
						setCommsMessage(_("upgrade-comms", "You already have the beam range upgrade"))
					else
						if comms_source:getBeamWeaponRange(0) < 1 then
							setCommsMessage(_("upgrade-comms", "Your ship does not support a beam weapon upgrade"))
						else
							comms_source.goods[beamComponent] = comms_source.goods[beamComponent] - 1
							comms_source.cargo = comms_source.cargo + 1
							local bi = 0
							repeat
								local arc = comms_source:getBeamWeaponArc(bi)
								local dir = comms_source:getBeamWeaponDirection(bi)
								local rng = comms_source:getBeamWeaponRange(bi)
								local cyc = comms_source:getBeamWeaponCycleTime(bi)
								local dmg = comms_source:getBeamWeaponDamage(bi)
								comms_source:setBeamWeapon(bi,arc,dir,rng*(1+beamRangeBump/100),cyc,dmg)
								bi = bi + 1
							until(comms_source:getBeamWeaponRange(bi) < 1 or bi > 15)
							setCommsMessage(_("upgrade-comms", "Your beam range has been upgraded"))
							comms_source.beam_range_upgrade = true
						end
					end
				end)
			end
		end
	end
	if comms_target == tubeStation then
		if comms_source.goods ~= nil then
			if comms_source.goods[tubeComponent] > 0 then
				addCommsReply(string.format(_("upgrade-comms", "Provide %s for additional homing missile tube"),tubeComponent), function()
					if comms_source.tube_upgrade then
						setCommsMessage(_("upgrade-comms", "You already have the missile tube upgrade"))
					else
						comms_source.goods[tubeComponent] = comms_source.goods[tubeComponent] - 1
						comms_source.cargo = comms_source.cargo + 1
						local original_tubes = comms_source:getWeaponTubeCount()
						local new_tubes = original_tubes + 1
						comms_source:setWeaponTubeCount(new_tubes)
						comms_source:setWeaponTubeExclusiveFor(original_tubes, "Homing")
						comms_source:setWeaponStorageMax("Homing", comms_source:getWeaponStorageMax("Homing") + 2)
						comms_source:setWeaponStorage("Homing", comms_source:getWeaponStorage("Homing") + 2)
						setCommsMessage(_("upgrade-comms", "You now have an additional homing missile tube"))
						comms_source.tube_upgrade = true
					end
				end)
			end
		end
	end
	if comms_target == stationNefatha then
		if comms_source.goods ~= nil then
			if comms_source.goods[energyComponent] > 0 then
				addCommsReply(string.format(_("upgrade-comms", "Provide %s for 25 percent energy capacity upgrade"),energyComponent), function()
					if comms_source.energy_upgrade then
						setCommsMessage(_("upgrade-comms", "You already have the energy capacity upgrade"))
					else
						comms_source.goods[energyComponent] = comms_source.goods[energyComponent] - 1
						comms_source.cargo = comms_source.cargo + 1
						comms_source:setMaxEnergy(comms_source:getMaxEnergy()*1.25)
						setCommsMessage(_("upgrade-comms", "You now have upgraded energy capacity"))
						comms_source.energy_upgrade = true
					end
				end)
			end
		end
	end
	if comms_target == shieldStation then
		if comms_source.goods ~= nil then
			if comms_source.goods[shieldComponent] > 0 then
				if comms_source:getShieldCount() > 0 then
					if comms_source:getShieldCount() == 1 then
						addCommsReply(string.format(_("upgrade-comms", "Provide %s for %.2f percent shield upgrade"),shieldComponent,shieldBump), function()
							if comms_source.front_shield_upgrade then
								setCommsMessage(_("upgrade-comms", "You already have the shield upgrade"))
							else
								comms_source.goods[shieldComponent] = comms_source.goods[shieldComponent] - 1
								comms_source.cargo = comms_source.cargo + 1
								comms_source:setShieldsMax(comms_source:getShieldMax(0)*(1+shieldBump/100))
								setCommsMessage(_("upgrade-comms", "You now have upgraded shield capacity"))
								comms_source.front_shield_upgrade = true
							end
						end)
					elseif comms_source:getShieldCount() > 1 then
						addCommsReply(string.format(_("upgrade-comms", "Provide %s for %.2f percent front shield upgrade"),shieldComponent,shieldBump), function()
							if comms_source.front_shield_upgrade then
								setCommsMessage(_("upgrade-comms", "You already have the front shield upgrade"))
							else
								comms_source.goods[shieldComponent] = comms_source.goods[shieldComponent] - 1
								comms_source.cargo = comms_source.cargo + 1
								comms_source:setShieldsMax(comms_source:getShieldMax(0)*(1+shieldBump/100), comms_source:getShieldMax(1))
								setCommsMessage(_("upgrade-comms", "You now have upgraded front shield capacity"))
								comms_source.front_shield_upgrade = true
							end
						end)
						addCommsReply(string.format(_("upgrade-comms", "Provide %s for %.2f percent rear shield upgrade"),shieldComponent,shieldBump), function()
							if comms_source.rear_shield_upgrade then
								setCommsMessage(_("upgrade-comms", "You already have the rear shield upgrade"))
							else
								comms_source.goods[shieldComponent] = comms_source.goods[shieldComponent] - 1
								comms_source.cargo = comms_source.cargo + 1
								comms_source:setShieldsMax(comms_source:getShieldMax(0), comms_source:getShieldMax(1)*(1+shieldBump/100))
								setCommsMessage(_("upgrade-comms", "You now have upgraded rear shield capacity"))
								comms_source.rear_shield_upgrade = true
							end
						end)
					end
				end
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
        if not comms_source:takeReputationPoints(points_per_item * item_amount) then
            setCommsMessage(_("needRep-comms", "Not enough reputation."))
            return
        end
        comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + item_amount)
        if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
            setCommsMessage(_("ammo-comms", "You are fully loaded and ready to explode things."))
        else
            setCommsMessage(_("ammo-comms", "We generously resupplied you with some weapon charges.\nPut them to good use."))
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
 	addCommsReply(_("station-comms", "I need information"), function()
		setCommsMessage(_("station-comms", "What kind of information do you need?"))
		addCommsReply(_("upgrade-comms",  "Do you upgrade spaceships?"), function()
			for i,station_info in ipairs(station_upgrade_list) do
				if station_info.station == comms_target then
					setCommsMessage(station_info.desc)
					break
				else
					setCommsMessage(_("upgrade-comms", "We don't upgrade spaceships"))
				end
			end
			addCommsReply(_("Back"), commsStation)
		end)
		if comms_target == stationTimer then
			addCommsReply(_("station-comms","How far am I from the race start point?"),function()
				local p_x, p_y = comms_source:getPosition()
				local current_distance = distance(p_x, p_y, racePoint1x, racePoint1y)
				local qualify = _("station-comms","not close enough to qualify for the start of the race")
				if current_distance < 5000 then
					qualify = _("station-comms","close enough to qualify for the start of the race")
				end
				current_distance = current_distance/1000
				if current_distance <= 1 then
					setCommsMessage(string.format(_("station-comms","%s, my messaging terminal says you're %.1f unit away, %s."),comms_source:getCallSign(),current_distance,qualify))
				else
					setCommsMessage(string.format(_("station-comms","%s, my messaging terminal says you're %.1f units away, %s."),comms_source:getCallSign(),current_distance,qualify))
				end
				addCommsReply(_("Back"), commsStation)
			end)
		end	
		addCommsReply(_("station-comms","Station docking service status"),function()
			local out = _("station-comms","Station docking services report:")
			out = string.format(_("station-comms","%s\nRestock scan probes: %s"),out,comms_target:getRestocksScanProbes())
			out = string.format(_("station-comms","%s\nRecharge energy: %s"),out,comms_target:getSharesEnergyWithDocked())
			out = string.format(_("station-comms","%s\nRepair hull: %s"),out,comms_target:getRepairDocked())
			setCommsMessage(out)
			addCommsReply(_("Back"), commsStation)
		end)	
	end)
	if comms_source:isFriendly(comms_target) then
		addCommsReply(_("orders-comms", "What are my current orders?"), function()
			ordMsg = primaryOrders
			if raceStartDelay > 0 then
				ordMsg = ordMsg .. string.format(_("orders-comms", "\n%i Seconds remain until start of race"),math.floor(raceStartDelay))
			else
				if comms_source.goal ~= nil then
					ordMsg = ordMsg .. string.format(_("orders-comms", "\nImmediate goal: race waypoint %i"),comms_source.goal)
				end
			end
			setCommsMessage(ordMsg)
			addCommsReply(_("Back"), commsStation)
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
					addCommsReply(_("Back"), commsStation)
				end)
			end
			addCommsReply("Show patience time limit", function()
				dMsg = string.format("\nPatience time limit: %i",patienceTimeLimit)
				setCommsMessage(dMsg)
				addCommsReply(_("Back"), commsStation)
			end)
			if raceStartDelay <= 0 then
				addCommsReply("Show unfinished racers", function()
					dMsg = string.format("Unfinished racers: %i",unfinishedRacers)
					setCommsMessage(dMsg)
					addCommsReply(_("Back"), commsStation)
				end)
			end
			if gMsg ~= nil then
				dMsg = dMsg .. "\n\nFinal built message so far:\n\n" .. gMsg
			end
			setCommsMessage(dMsg)
			addCommsReply(_("Back"), commsStation)
		end)
	end
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
                            ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
                            setCommsMessage(string.format(_("stationAssist-comms", "We have dispatched %s to assist at WP %d"),ship:getCallSign(),n))
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
	-- Return the number of reputation points that a specified service costs for
	-- the current player.
    return math.ceil(comms_target.comms_data.service_cost[service])
end
function getFriendStatus()
    if comms_source:isFriendly(comms_target) then
        return "friend"
    else
        return "neutral"
    end
end
function tableSelectRandom(array)
	local array_item_count = #array
    if array_item_count == 0 then
        return nil
    end
	return array[math.random(1,#array)]	
end
--------------------------
--	Ship communication  --
--------------------------
function commsShip()
	if comms_target.comms_data == nil then
		comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
	end
	if comms_target.comms_data.goods == nil then
		comms_target.comms_data.goods = {}
		local selected_good = tableSelectRandom(component_goods)
		if random(1,100) < 40 then
			selected_good = tableSelectRandom(mineral_goods)
		end
		comms_target.comms_data.goods[selected_good] = {cost = math.random(20,80), quantity = 1}
	end
	if comms_source:isFriendly(comms_target) then
		return friendlyComms()
	end
	if comms_source:isEnemy(comms_target) and comms_target:isFriendOrFoeIdentifiedBy(comms_source) then
		return enemyComms()
	end
	return neutralComms()
end
function friendlyComms()
	if comms_target.comms_data.friendlyness < 20 then
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
					comms_target:orderDefendLocation(comms_source:getWaypoint(n))
					setCommsMessage(string.format(_("shipAssist-comms", "We are heading to assist at WP %d."), n));
					addCommsReply(_("Back"), commsShip)
				end)
			end
		end
	end)
	if comms_target.comms_data.friendlyness > 0.2 then
		addCommsReply(_("shipAssist-comms", "Assist me"), function()
			setCommsMessage(_("shipAssist-comms", "Heading toward you to assist."));
			comms_target:orderDefendTarget(comms_source)
			addCommsReply(_("Back"), commsShip)
		end)
	end
	addCommsReply(_("shipAssist-comms", "Report status"), function()
		msg = string.format(_("shipAssist-comms", "Hull: %d%%\n"), math.floor(comms_target:getHull() / comms_target:getHullMax() * 100))
		shields = comms_target:getShieldCount()
		if shields == 1 then
			msg = string.format(_("shipAssist-comms", "%sShield: %d%%\n"),msg, math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100))
		elseif shields == 2 then
			msg = string.format(_("shipAssist-comms", "%sFront Shield: %d%%\n"),msg, math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100))
			msg = string.format(_("shipAssist-comms", "%sRear Shield: %d%%\n"),msg, math.floor(comms_target:getShieldLevel(1) / comms_target:getShieldMax(1) * 100))
		else
			for n=0,shields-1 do
				msg = string.format(_("shipAssist-comms", "%sShield %s: %d%%\n"),msg, n, math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100))
			end
		end
		local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
		for i, missile_type in ipairs(missile_types) do
			if comms_target:getWeaponStorageMax(missile_type) > 0 then
					msg = string.format(_("shipAssist-comms", "%s%s Missiles: %d/%d\n"),msg, missile_type, math.floor(comms_target:getWeaponStorage(missile_type)), math.floor(comms_target:getWeaponStorageMax(missile_type)))
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
	return true
end
function enemyComms()
	if comms_target.owner == nil then
		if comms_target.comms_data.friendlyness > 50 then
			faction = comms_target:getFaction()
			taunt_option = _("shipEnemy-comms", "We will see to your destruction!")
			taunt_success_reply = _("shipEnemy-comms", "Your bloodline will end here!")
			taunt_failed_reply = _("shipEnemy-comms", "Your feeble threats are meaningless.")
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
			comms_target.comms_data.friendlyness = comms_target.comms_data.friendlyness - random(0, 10)
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
		setCommsMessage(string.format(_("shipEnemy-comms", "I belong to %s"),comms_target.owner))
		addCommsReply(_("Back"), commsShip)
	end
	return false
end
function neutralComms()
	shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
		if comms_target.comms_data.friendlyness > 66 then
			setCommsMessage(_("trade-comms", "Yes?"))
			-- Offer destination information
			addCommsReply(_("trade-comms", "Where are you headed?"), function()
				setCommsMessage(comms_target.target:getCallSign())
				addCommsReply(_("Back"), commsShip)
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
							addCommsReply(string.format(_("trade-comms", "Trade luxury for %s"),goods[comms_target][gi][1]), function()
								if goodsQuantity < 1 then
									setCommsMessage(_("trade-comms", "Insufficient inventory on freighter for trade"))
								else
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									decrementPlayerGoods("luxury")
									setCommsMessage(_("trade-comms", "Traded"))
								end
								addCommsReply(_("Back"), commsShip)
							end)
							gi = gi + 1
						until(gi > #goods[comms_target])
					else
						setCommsMessage(_("trade-comms", "Insufficient luxury to trade"))
					end
					addCommsReply(_("Back"), commsShip)
				else
					-- Offer to sell goods
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]
						addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),goods[comms_target][gi][1],goods[comms_target][gi][3]), function()
							if comms_source.cargo < 1 then
								setCommsMessage(_("trade-comms", "Insufficient cargo space for purchase"))
							elseif goodsQuantity < 1 then
								setCommsMessage(_("trade-comms", "Insufficient inventory on freighter"))
							else
								if not comms_source:takeReputationPoints(goodsRep) then
									setCommsMessage(_("needRep-comms", "Insufficient reputation for purchase"))
								else
									comms_source.cargo = comms_source.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage(_("trade-comms", "Purchased"))
								end
							end
							addCommsReply(_("Back"), commsShip)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
		elseif comms_target.comms_data.friendlyness > 33 then
			setCommsMessage(_("shipAssist-comms", "What do you want?"))
			-- Offer to sell destination information
			destRep = random(1,5)
			addCommsReply(string.format(_("trade-comms", "Where are you headed? (cost: %f reputation)"),destRep), function()
				if not comms_source:takeReputationPoints(destRep) then
					setCommsMessage(_("needRep-comms", "Insufficient reputation"))
				else
					setCommsMessage(comms_target.target:getCallSign())
				end
				addCommsReply(_("Back"), commsShip)
			end)
			-- Offer to sell goods if goods or equipment freighter
			if distance(comms_source,comms_target) < 5000 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]
						addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),goods[comms_target][gi][1],goods[comms_target][gi][3]), function()
							if comms_source.cargo < 1 then
								setCommsMessage(_("trade-comms", "Insufficient cargo space for purchase"))
							elseif goodsQuantity < 1 then
								setCommsMessage(_("trade-comms", "Insufficient inventory on freighter"))
							else
								if not comms_source:takeReputationPoints(goodsRep) then
									setCommsMessage(_("needRep-comms", "Insufficient reputation for purchase"))
								else
									comms_source.cargo = comms_source.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage(_("trade-comms", "Purchased"))
								end
							end
							addCommsReply(_("Back"), commsShip)
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
						addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),goods[comms_target][gi][1],goods[comms_target][gi][3]*2), function()
							if comms_source.cargo < 1 then
								setCommsMessage(_("trade-comms", "Insufficient cargo space for purchase"))
							elseif goodsQuantity < 1 then
								setCommsMessage(_("trade-comms", "Insufficient inventory on freighter"))
							else
								if not comms_source:takeReputationPoints(goodsRep) then
									setCommsMessage(_("needRep-comms", "Insufficient reputation for purchase"))
								else
									comms_source.cargo = comms_source.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage(_("trade-comms", "Purchased"))
								end
							end
							addCommsReply(_("Back"), commsShip)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
		else
			setCommsMessage(_("trade-comms", "Why are you bothering me?"))
			-- Offer to sell goods if goods or equipment freighter double price
			if distance(comms_source,comms_target) < 5000 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]*2
						addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),goods[comms_target][gi][1],goods[comms_target][gi][3]*2), function()
							if comms_source.cargo < 1 then
								setCommsMessage(_("trade-comms", "Insufficient cargo space for purchase"))
							elseif goodsQuantity < 1 then
								setCommsMessage(_("trade-comms", "Insufficient inventory on freighter"))
							else
								if not comms_source:takeReputationPoints(goodsRep) then
									setCommsMessage(_("needRep-comms", "Insufficient reputation for purchase"))
								else
									comms_source.cargo = comms_source.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage(_("trade-comms", "Purchased"))
								end
							end
							addCommsReply(_("Back"), commsShip)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
		end
	else
		if comms_target.comms_data.friendlyness > 50 then
			setCommsMessage(_("ship-comms", "Sorry, we have no time to chat with you.\nWe are on an important mission."));
		else
			setCommsMessage(_("ship-comms", "We have nothing for you.\nGood day."));
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
				p6.timeRank = _("msgMainscreen", "Admiral")
			elseif p6.raceTime < 720 then
				p6.timeRank = _("msgMainscreen", "Captain")
			elseif p6.raceTime < 900 then
				p6.timeRank = _("msgMainscreen", "Commander")
			elseif p6.raceTime < 1200 then
				p6.timeRank = _("msgMainscreen", "Lieutenant")
			elseif p6.raceTime < 1500 then
				p6.timeRank = _("msgMainscreen", "Ensign")
			else
				if p6.raceTime == nil then
					p6.timeRank = _("msgMainscreen", "Undefined")
				else
					p6.timeRank = _("msgMainscreen", "Cadet")
				end
			end
		end
	end
end
function soloComplete()
	print("in solo complete function")
	gMsg = string.format(_("msgMainscreen", "Race completed in %.2f seconds. Time rank: %s"),playerList[1].raceTime,playerList[1].timeRank)
	eliminatedDrones = countEliminatedDrones(playerList[1])
	gMsg = gMsg .. string.format(_("msgMainscreen", "\nTarget drones eliminated: %i"),eliminatedDrones)
end
function soloExpire()
	print("in solo expire function")
	gMsg = _("msgMainscreen", "Race administrators got tired of waiting. Race stopped after 2000 seconds. Time Rank: Cadet")
	eliminatedDrones = countEliminatedDrones(playerList[1])
	gMsg = gMsg .. string.format(_("msgMainscreen", "\nTarget drones eliminated: %i"),eliminatedDrones)
end
function competeComplete()
	print("in compete complete function")
	gMsg = _("msgMainscreen", "Race Results")
	competeResults()
end
function competeExpire()
	print("in compete expire function")
	gMsg = string.format(_("msgMainscreen", "Race administrators got tired of waiting. Race stopped after %.2f seconds."),raceTimer)
	competeResults()
end
function competeResults()
	print("in compete results function")
	local stat_list, sorted_stat_list = gatherStats(true)
	gMsg = gMsg .. _("msgMainscreen", "\nOrdered by score. Place, ship name, score, time in seconds, place points, drone points")
	print("Final Statistics:")
	print("Rank","Score","Place","Drones","Time","Name")
	if #sorted_stat_list > 0 then
		for index, item in ipairs(sorted_stat_list) do
			local time = 0
			if item.time ~= nil then
				time = item.time
			end
			print(index,item.score,item.rank_points,item.drone_points,time,item.name)
			gMsg = gMsg .. string.format(_("msgMainscreen", "\n%i, %s, %i, %.2f, %i, %i"),index,item.name,item.score,time,item.rank_points,item.drone_points)
		end
	else
		gMsg = _("msgMainscreen","Nobody finished the race.")
	end
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
		gMsg = gMsg .. string.format(_("msgMainscreen", "\n%s time: %.2f seconds. Time rank: %s. Placement points: %i"),playerList[pi]:getCallSign(),playerList[pi].raceTime,playerList[pi].timeRank,playerList[pi].timePoints)
	else
		gMsg = gMsg .. _("msgMainscreen", "\nResults indeterminate")
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
		gMsg = gMsg .. string.format(_("msgMainscreen", "%s Drones shot: %i, Total score: %i. "),playerList[pl]:getCallSign(),playerList[pl].dronePoints,playerList[pl].score)
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
		gMsg = gMsg .. string.format(_("msgMainscreen", "%s Drones shot: %i, Total score: %i. "),bestPlayer:getCallSign(),bestPlayer.dronePoints,bestPlayer.score)
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
	if sorted_score_list ~= nil and #sorted_score_list > 0 and player_count > 0 then
		local prev_value = sorted_score_list[1].rank
		local place_index = 1
		local reward_index = 1
		for i, item in ipairs(sorted_score_list) do
			if item.rank ~= prev_value then
				reward_index = place_index
			end
			local reward = reward_grid[player_count][reward_index]
			stat_list.ship[item.name].rank_points = reward
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
			return 
				a.score > b.score or
				(a.score == b.score and a.lap_count > b.lap_count) or
				(a.score == b.score and a.lap_count == b.lap_count and a.time < b.time)
		end)
		print("Score","Place","Drones","Name","Laps","WP Goal")
		for i, item in ipairs(sorted_stat_list) do
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
					tempPlayerType = p:getTypeName()
					p.shipScore = player_ship_stats[tempPlayerType].strength
					p.maxCargo = player_ship_stats[tempPlayerType].cargo
					p:addReputationPoints(5)
					goods[p] = goodsList
					local use_fixed = false
					if predefined_player_ships ~= nil then
						if pps_index == nil then
							pps_index = 0
						end
						pps_index = pps_index + 1
						if predefined_player_ships[pps_index] ~= nil then
							use_fixed = true
						else
							predefined_player_ships = nil
						end
					end
					if use_fixed then
						p:setCallSign(predefined_player_ships[pps_index].name)
						p.control_code = predefined_player_ships[pps_index].control_code
						p:setControlCode(predefined_player_ships[pps_index].control_code)
					else
						namePlayerShip(p,tempPlayerType)
						local control_code_index = math.random(1,#control_code_stem)
						local stem = control_code_stem[control_code_index]
						table.remove(control_code_stem,control_code_index)
						local branch = math.random(100,999)
						p.control_code = stem .. branch
						p:setControlCode(stem .. branch)
					end
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
		primaryOrders = string.format(_("raceOrders-comms", "Start race on time at waypoint 1\nRace Length: %f units"),raceLength)
		for p1idx=1,32 do
			local p1 = getPlayerShip(p1idx)
			if p1 ~= nil and p1:isValid() then
				local delay_minutes = math.floor(original_race_start_delay/60)
				if delay_minutes > 1 then
					p1:addToShipLog(string.format(_("raceOrders-shipLog", "Race starts in %i minutes. Be at waypoint 1 on time or forfeit"),delay_minutes),"Magenta")
				else
					p1:addToShipLog(string.format(_("raceOrders-shipLog", "Race starts in %i minute. Be at waypoint 1 on time or forfeit"),delay_minutes),"Magenta")
				end
				p1:addToShipLog(string.format(_("raceOrders-shipLog", "Today's race length: %.1f units"),raceLength),"Magenta")
			end
		end
	end
	if raceStartDelay > 0 then
		game_state = "countdown"
		--before race start
		raceStartDelay = raceStartDelay - delta
		stationTimer:setCallSign(string.format(_("race-", "Race Start Countdown: %.2f"),raceStartDelay))
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
						p2:addToShipLog(_("race-shipLog", "Ready..."),"Blue")
						p2.readyMessage = "done"
					end
					if p2.setMessage ~= "done" and raceStartDelay < 1 then
						p2:addToShipLog(_("race-shipLog", "Set..."),"Magenta")
						p2.setMessage = "done"
					end
				end
			end
			if beep_3 == nil and raceStartDelay > 2 and raceStartDelay < 3 then
				playSoundFile("audio/scenario/58/sa_58_beep.ogg")
				start_zone:setColor(255,0,0)
				beep_3 = "played"
			end
			if reset_3 == nil and raceStartDelay > 2 and raceStartDelay < 2.5 then
				start_zone:setColor(0,64,0)
				reset_3 = "reset"
			end
			if beep_2 == nil and raceStartDelay > 1 and raceStartDelay < 2 then
				playSoundFile("audio/scenario/58/sa_58_beep.ogg")
				start_zone:setColor(255,0,0)
				beep_2 = "played"
			end
			if reset_2 == nil and raceStartDelay > 1 and raceStartDelay < 1.5 then
				start_zone:setColor(0,64,0)
				reset_2 = "reset"
			end
			if beep_1 == nil and raceStartDelay < 1 then
				playSoundFile("audio/scenario/58/sa_58_beep.ogg")
				start_zone:setColor(255,0,0)
				beep_1 = "played"
			end
			if reset_1 == nil and raceStartDelay > 0 and raceStartDelay < .5 then
				start_zone:setColor(0,64,0)
				reset_1 = "reset"
			end
		end
	else
		game_state = "race"
		--race has started
		if startLineCheck ~= "done" then
			startLineCheck = "done"
			raceTimer = 0
			primaryOrders = _("raceOrders-comms", "Complete race. Win if possible.")
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
						p4:addToShipLog(_("raceOrders-shipLog", "Go!"),"Red")
						player_start_list[p4:getCallSign()] = p4
						player_count = player_count + 1
					else
						p4:destroy()
					end
				end
			end
			playSoundFile(start_sound_file)
			start_zone:setColor(0,128,0)
			point_2_zone:setColor(0,128,0)
			point_3_zone:setColor(0,128,0)
			point_4_zone:setColor(0,128,0)
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
			stationTimer:setCallSign(string.format(_("race-", "Race Run Time %.2f"),raceTimer))
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
				local msg = _("race-shipLog", "The race has begun!")
				for name, p in pairs(player_start_list) do
					p:addToShipLog(msg,"Magenta")
				end
				if player_count == original_player_count then
					msg = string.format(_("race-shipLog", "With %i racers, we have the following points awarded for final race place:"),player_count)
				else
					msg = string.format(_("race-shipLog", "With %i racers remaining from the original %i registrants, we have the following points awarded for final race place:"),player_count,original_player_count)
				end
				for name, p in pairs(player_start_list) do
					p:addToShipLog(msg,"Magenta")
				end
				msg = ""
				local place_name = {
					_("race-shipLog","First"),
					_("race-shipLog","Second"),
					_("race-shipLog","Third"),
					_("race-shipLog","Fourth"),
					_("race-shipLog","Fifth"),
					_("race-shipLog","Sixth"),
					_("race-shipLog","Seventh"),
					_("race-shipLog","Eighth"),
					_("race-shipLog","Ninth"),
					_("race-shipLog","Tenth"),
				}
				if player_count > 0 then
					for i=1,#reward_grid[player_count] do
						if reward_grid[player_count][i] > 0 then
							if i > 1 then
								msg = string.format(_("race-shipLog","%s, %s:%s"),msg,place_name[i],reward_grid[player_count][i])
--								msg = msg .. ", " .. place_name[i] .. ":" .. reward_grid[player_count][i]
							else
								msg = string.format(_("race-shipLog","%s:%s"),place_name[i],reward_grid[player_count][i])
--								msg = place_name[i] .. ":" .. reward_grid[player_count][i]
							end
						else
							break
						end
					end
				else
					game_state = "aborted"
					globalMessage(_("race-msgMainscreen","Race aborted. Nobody made it to the starting line"))
					victory("Exuari")
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
					local name_tag_text = string.format(_("race-tabHelms&Tactical&Singlepilot", "%s in %s"),p5:getCallSign(),p5:getSectorName())
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
							p5:addToShipLog(string.format(_("race-shipLog", "Waypoint 2 met. Go to waypoint 3. Leg took %f seconds. You have completed %i %s."),p5.legtimer,p5.laps,lapString),"Magenta")
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
							p5:addToShipLog(string.format(_("race-shipLog", "Waypoint 3 met. Go to waypoint 4. Leg took %f seconds. You have completed %i %s."),p5.legtimer,p5.laps,lapString),"Magenta")
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
							p5:addToShipLog(string.format(_("race-shipLog", "Waypoint 4 met. Go to waypoint 1. Leg took %f seconds. You have completed %i %s."),p5.legtimer,p5.laps,lapString),"Magenta")
							p5.legtimer = 0
						end
					elseif p5.goal == 1 then
						if distance(p5,racePoint1x,racePoint1y) < 1000 then
							p5.laps = p5.laps + 1
							if p5.laps >= 3 then
								p5.raceTime = raceTimer
								p5:addToShipLog(string.format(_("race-shipLog", "Completed race. Race time in seconds: %f"),p5.raceTime),"Magenta")
							else
								p5.goal = 2
								if p5.laps == 1 then
									lapString = "lap"
								else
									lapString = "laps"
								end
								p5:addToShipLog(string.format(_("race-shipLog", "Waypoint 1 met. Go to waypoint 2. Leg took %f seconds. You have completed %i %s. Lap took %f seconds."),p5.legtimer,p5.laps,lapString,p5.laptimer),"Magenta")
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
			if player_count > 0 then
				if finished_racers < #reward_grid[player_count] and reward_grid[player_count][finished_racers + 1] == 0 then
					if patienceTimeLimit == original_patience_time_limit then
						patienceTimeLimit = raceTimer + 10		--wait 10 seconds for last place player ship to finish
					end
				end
			else
				game_state = "aborted"
				globalMessage(_("msgMainscreen","Race aborted. Nobody made it to the starting line"))
				victory("Exuari")
			end
			if finished_racers >= viable_racers then
				allRacersFinished()
				game_state = "complete"
				if player_count == 0 then
					victory("Exuari")
				else
					victory("Human Navy")
				end
			end
			if raceTimer > patienceTimeLimit then
				raceTimerExpired()
				game_state = "expired"
				if player_count == 0 then
					victory("Exuari")
				else
					victory("Human Navy")
				end
			end
		end
	end
end
