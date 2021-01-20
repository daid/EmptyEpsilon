-- Name: Delta quadrant patrol duty
-- Description: Patrol between three stations in the Delta quadrant to protect from enemies
---
--- Version 8
-- Type: Mission
-- Variation[Easy]: Easy goals and/or enemies
-- Variation[Hard]: Hard goals and/or enemies
-- Variation[Self-destructive]: Extremely difficult goals and/or enemies
-- Variation[Short]: Fewer mission goals or shorter mission goals, shorter time taken
-- Variation[Timed 15]: End in 15 minutes
-- Variation[Timed 30]: End in 30 minutes
-- Variation[Short Easy]: Shorter time taken, easy goals and/or enemies
-- Variation[Timed 15 Easy]: End in 15 minutes, easy goals and/or enemies
-- Variation[Timed 30 Easy]: End in 30 minutes, easy goals and/or enemies
-- Variation[Short Hard]: Shorter time taken, hard goals and/or enemies
-- Variation[Timed 15 Hard]: End in 15 minutes, hard goals and/or enemies
-- Variation[Timed 30 Hard]: End in 30 minutes, hard goals and/or enemies
-- Variation[Short Self-destructive]: Shorter time taken, extremely difficult goals and/or enemies
-- Variation[Timed 15 Self-destructive]: End in 15 minutes, extremely difficult goals and/or enemies
-- Variation[Timed 30 Self-destructive]: End in 30 minutes, extremely difficult goals and/or enemies
-- Variation[Long]: More mission goals, longer time taken
-- Variation[Long Easy]: Longer time taken, easy goals and/or enemies
-- Variation[Long Hard]: Longer time taken, hard goals and/or enemies
-- Variation[Long Self-destructive]: Longer time taken, extremely difficult goals and/or enemies
-- Variation[Extended]: Longer missions than the long variation, longest time taken
-- Variation[Extended Easy]: Longest time taken, easy goals and/or enemies
-- Variation[Extended Hard]: Longest time taken, hard goals and/or enemies
-- Variation[Extended Self-destructive]: Longest time taken, extremely difficult goals and/or enemies

require("utils.lua")

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
	local arcLen = endArcClockwise - startArc
	local radialPoint = nil
	local pointDist = nil
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
function createRandomAsteroidAlongArc(amount, x, y, distance, startArc, endArcClockwise, randomize)
-- Create amount of asteroids along arc
-- Center defined by x and y
-- Radius defined by distance
-- Start of arc between 0 and 360 (startArc), end arc: endArcClockwise
-- Use randomize to vary the distance from the center point. Omit to keep distance constant
-- Example:
--   createRandomAsteroidAlongArc(100, 500, 3000, 65, 120, 450)
	local function asteroidSize()
		return random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
	end
	if randomize == nil then randomize = 0 end
	if amount == nil then amount = 1 end
	local arcLen = endArcClockwise - startArc
	if startArc > endArcClockwise then
		endArcClockwise = endArcClockwise + 360
		arcLen = arcLen + 360
	end
	if amount > arcLen then
		for ndex=1,arcLen do
			local radialPoint = startArc+ndex
			local pointDist = distance + random(-randomize,randomize)
			Asteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist):setSize(asteroidSize())
		end
		for ndex=1,amount-arcLen do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
			Asteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist):setSize(asteroidSize())
		end
	else
		for ndex=1,amount do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
			Asteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist):setSize(asteroidSize())
		end
	end
end
function placeRandomAsteroidsAroundPoint(amount, dist_min, dist_max, x0, y0)
-- create amount of asteroid, at a distance between dist_min and dist_max around the point (x0, y0)
    for n=1,amount do
        local r = random(0, 360)
        local distance = random(dist_min, dist_max)
        x = x0 + math.cos(r / 180 * math.pi) * distance
        y = y0 + math.sin(r / 180 * math.pi) * distance
        local asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
        Asteroid():setPosition(x, y):setSize(asteroid_size)
    end
end
function closestPlayerTo(obj)
-- Return the player ship closest to passed object parameter
-- Return nil if no valid result
-- Assumes a maximum of 8 player ships
	if obj ~= nil and obj:isValid() then
		local closestDistance = 9999999
		local closestPlayer = nil
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
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
----------------------
--	Initialization  --
----------------------
function init()
	setVariations()
	setConstants()
	diagnostic = false
	wfv = "nowhere"		--wolf fence value - used for debugging
	setPlayers()
	generateStaticWorld()
	--these are to facilitate testing
	addGMFunction("Start plot 2 sick Kojak",initiatePlot2)
	addGMFunction("Start p 3 McNabbit ride",initiatePlot3)
	addGMFunction("St p4 Lisbon's stowaway",initiatePlot4)
	addGMFunction("Start plot 5",initiatePlot5)
	addGMFunction("Strt plot 8 Sheila dies",initiatePlot8)
	addGMFunction("Start plot 9 ambush",initiatePlot9)
	addGMFunction("Start plot 10 ambush",initiatePlot10)
	addGMFunction("Skip to defend U.P.",skipToDefendUP)
	addGMFunction("Skip to destroy S.C.",skipToDestroySC)
end
function setVariations()
	-- Difficulty setting: 1 = normal, .5 is easy, 2 is hard, 5 is ridiculously hard
	difficultyList = {.5, 1, 2, 5}
	difficultySettingList = {"Easy", "Normal", "Hard", "Self-Destructive"}
	difficultyIndex = 2		--default to normal difficulty
	difficulty = difficultyList[difficultyIndex]
	if string.find(getScenarioVariation(),"Short") or string.find(getScenarioVariation(),"Timed") then
		patrolGoal = 6			--short and timed missions get a patrol goal of 6
		missionLength = 1		--short and timed missions are categorized as mission length 1
	else
		patrolGoal = 9			--normal, long and extended get a patrol goal of 9
		if string.find(getScenarioVariation(),"Long") then
			missionLength = 3	--long missions are categorized as mission length 3
		elseif string.find(getScenarioVariation(),"Extended") then
			missionLength = 4	--extended missions are categorized as mission length 4
		else
			missionLength = 2	--normal missions are categorized as mission length 2
		end
	end
	if string.find(getScenarioVariation(),"Easy") then
		difficulty = .5			--easy missions get a .5 difficulty
	elseif string.find(getScenarioVariation(),"Hard") then
		difficulty = 2			--hard missions get a difficulty of 2
	elseif string.find(getScenarioVariation(),"Self-destructive") then
		difficulty = 5			--self destructive missions get a difficulty of 5
	else
		difficulty = 1			--default: normal mission difficulty of 1
	end
	playWithTimeLimit = false	--assume no time limit
	if string.find(getScenarioVariation(),"15") then
		gameTimeLimit = 15		--set 15 minute time limit
	elseif string.find(getScenarioVariation(),"30") then
		gameTimeLimit = 30		--set 30 minute time limit
	else
		gameTimeLimit = 0		--default: set no time limit
	end
	if gameTimeLimit > 0 then
		gameTimeLimit = gameTimeLimit*60	--convert minutes to seconds for time limit countdown
		ambushTime = gameTimeLimit/2		--set halfway point for ambush in timed scenarios
		playWithTimeLimit = true			--set time limit boolean
		plot7 = beforeAmbush				--use time limit plot
	end
end
function setConstants()
	prefix_length = 0
	suffix_index = 0
	play_button_expire_time = 180
	--Ship Template Name List
	stnl = {"MT52 Hornet","MU52 Hornet","Adder MK5","Adder MK4","WX-Lindworm","Adder MK6","Phobos T3","Phobos M3","Piranha F8","Piranha F12","Ranus U","Nirvana R5A","Stalker Q7","Stalker R7","Atlantis X23","Starhammer II","Odin","Fighter","Cruiser","Missile Cruiser","Strikeship","Adv. Striker","Dreadnought","Battlestation","Blockade Runner","Ktlitan Fighter","Ktlitan Breaker","Ktlitan Worker","Ktlitan Drone","Ktlitan Feeder","Ktlitan Scout","Ktlitan Destroyer","Storm"}
	--Ship Template Score List
	stsl = {5            ,5            ,7          ,6          ,7            ,8          ,15         ,16         ,15          ,15           ,25       ,20           ,25          ,25          ,50            ,70             ,250   ,6        ,18       ,14               ,30          ,27            ,80           ,100            ,65               ,6                ,45               ,40              ,4              ,48              ,8              ,50                 ,22}
	-- square grid deployment
	fleetPosDelta1x = {0,1,0,-1, 0,1,-1, 1,-1,2,0,-2, 0,2,-2, 2,-2,2, 2,-2,-2,1,-1, 1,-1}
	fleetPosDelta1y = {0,0,1, 0,-1,1,-1,-1, 1,0,2, 0,-2,2,-2,-2, 2,1,-1, 1,-1,2, 2,-2,-2}
	-- rough hexagonal deployment
	fleetPosDelta2x = {0,2,-2,1,-1, 1, 1,4,-4,0, 0,2,-2,-2, 2,3,-3, 3,-3,6,-6,1,-1, 1,-1,3,-3, 3,-3,4,-4, 4,-4,5,-5, 5,-5}
	fleetPosDelta2y = {0,0, 0,1, 1,-1,-1,0, 0,2,-2,2,-2, 2,-2,1,-1,-1, 1,0, 0,3, 3,-3,-3,3,-3,-3, 3,2,-2,-2, 2,1,-1,-1, 1}
	transportList = {}
	transportSpawnDelay = 10	--30
	commonGoods = {"food","medicine","nickel","platinum","gold","dilithium","tritanium","luxury","cobalt","impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	componentGoods = {"impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	mineralGoods = {"nickel","platinum","gold","dilithium","tritanium","cobalt"}
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
					{"circuit",0},
					{"battery",0}	}
	goods = {}
	--Player ship name lists to supplant standard randomized call sign generation
	playerShipNamesFor = {}
	-- TODO switch to spelling with space or dash matching the type name
	playerShipNamesFor["MP52Hornet"] = {"Dragonfly","Scarab","Mantis","Yellow Jacket","Jimminy","Flik","Thorny","Buzz"}
	playerShipNamesFor["Piranha"] = {"Razor","Biter","Ripper","Voracious","Carnivorous","Characid","Vulture","Predator"}
	playerShipNamesFor["FlaviaPFalcon"] = {"Ladyhawke","Hunter","Seeker","Gyrefalcon","Kestrel","Magpie","Bandit","Buccaneer"}
	playerShipNamesFor["PhobosM3P"] = {"Blinder","Shadow","Distortion","Diemos","Ganymede","Castillo","Thebe","Retrograde"}
	playerShipNamesFor["Atlantis"] = {"Excaliber","Thrasher","Punisher","Vorpal","Protang","Drummond","Parchim","Coronado"}
	playerShipNamesFor["Cruiser"] = {"Excelsior","Velociraptor","Thunder","Kona","Encounter","Perth","Aspern","Panther"}
	playerShipNamesFor["MissileCruiser"] = {"Projectus","Hurlmeister","Flinger","Ovod","Amatola","Nakhimov","Antigone"}
	playerShipNamesFor["Fighter"] = {"Buzzer","Flitter","Zippiticus","Hopper","Molt","Stinger","Stripe"}
	playerShipNamesFor["Benedict"] = {"Elizabeth","Ford","Vikramaditya","Liaoning","Avenger","Naruebet","Washington","Lincoln","Garibaldi","Eisenhower"}
	playerShipNamesFor["Kiriya"] = {"Cavour","Reagan","Gaulle","Paulo","Truman","Stennis","Kuznetsov","Roosevelt","Vinson","Old Salt"}
	playerShipNamesFor["Striker"] = {"Sparrow","Sizzle","Squawk","Crow","Phoenix","Snowbird","Hawk"}
	playerShipNamesFor["Lindworm"] = {"Seagull","Catapult","Blowhard","Flapper","Nixie","Pixie","Tinkerbell"}
	playerShipNamesFor["Repulse"] = {"Fiddler","Brinks","Loomis","Mowag","Patria","Pandur","Terrex","Komatsu","Eitan"}
	playerShipNamesFor["Ender"] = {"Mongo","Godzilla","Leviathan","Kraken","Jupiter","Saturn"}
	playerShipNamesFor["Nautilus"] = {"October", "Abdiel", "Manxman", "Newcon", "Nusret", "Pluton", "Amiral", "Amur", "Heinkel", "Dornier"}
	playerShipNamesFor["Hathcock"] = {"Hayha", "Waldron", "Plunkett", "Mawhinney", "Furlong", "Zaytsev", "Pavlichenko", "Pegahmagabow", "Fett", "Hawkeye", "Hanzo"}
	playerShipNamesFor["Crucible"] = {"Sling", "Stark", "Torrid", "Kicker", "Flummox"}
	playerShipNamesFor["Maverick"] = {"Angel", "Thunderbird", "Roaster", "Magnifier", "Hedge"}
	playerShipNamesFor["Leftovers"] = {"Foregone","Righteous","Masher"}
	posseShipNames = {"Bubba","George","Winifred","Daniel","Darla","Stephen","Bob","Porky","Sally","Tommy","Jenny","Johnny","Lizzy","Billy"}
	station_pool = {
		["Science"] = {
			["Asimov"] = {
		        weapon_available = 	{
		        	Homing =			true,
		        	HVLI =				random(1,13)<=(9-difficulty),
		        	Mine =				true,
		        	Nuke =				random(1,13)<=(5-difficulty),
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop = "friend",
					reinforcements = "friend",
					jumpsupplydrop = "friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 			1.0, 
		        	neutral = 			3.0,
		        },
        		goods = {	
        			tractor = {
        				quantity =	5,	
        				cost =		48,
        			},
        			repulsor = {
        				quantity =	5,
        				cost =		48,
        			},
        		},
		        trade = {	
		        	food =			false, 
		        	medicine =		false, 
		        	luxury =		false,
		        },
				description = "Training and Coordination", 
				general = "We train naval cadets in routine and specialized functions aboard space vessels and coordinate naval activity throughout the sector", 
				history = "The original station builders were fans of the late 20th century scientist and author Isaac Asimov. The station was initially named Foundation, but was later changed simply to Asimov. It started off as a stellar observatory, then became a supply stop and as it has grown has become an educational and coordination hub for the region",
			},
			["Armstrong"] =	{
		        weapon_available = {
		        	Homing = 			random(1,13)<=(8-difficulty),	
		        	HVLI = 				true,		
		        	Mine = 				random(1,13)<=(7-difficulty),	
		        	Nuke = 				random(1,13)<=(5-difficulty),	
		        	EMP = 				true
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {	
					warp = {
						quantity =	5,	
						cost =		77,
					},
					impulse = {
						quantity =	5,	
						cost =		62,
					},
				},
				trade = {	
					food = false, 
					medicine = false, 
					luxury = false,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
				},
				description = "Warp and Impulse engine manufacturing", 
				general = "We manufacture warp, impulse and jump engines for the human navy fleet as well as other independent clients on a contract basis", 
				history = "The station is named after the late 19th century astronaut as well as the fictionlized stations that followed. The station initially constructed entire space worthy vessels. In time, it transitioned into specializeing in propulsion systems.",
			},
			["Broeck"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					warp = {
						quantity =	5,
						cost =		36,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = random(1,100) < 62,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
				},
				description = "Warp drive components", 
				general = "We provide warp drive engines and components", 
				history = "This station is named after Chris Van Den Broeck who did some initial research into the possibility of warp drive in the late 20th century on Earth",
			},
			["Coulomb"] = {
		        weapon_available = 	{
		        	Homing = random(1,13)<=(8-difficulty),	
		        	HVLI = random(1,13)<=(9-difficulty),	
		        	Mine = random(1,13)<=(7-difficulty),	
		        	Nuke = random(1,13)<=(5-difficulty),	
		        	EMP = random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
        		goods = {	
        			circuit =	{
        				quantity =	5,	
        				cost =		50,
        			},
        		},
        		trade = {	
        			food = false, 
        			medicine = false, 
        			luxury = random(1,100) < 82,
        		},
				buy =	{
					[randomMineral()] = math.random(40,200),
				},
				description = "Shielded circuitry fabrication", 
				general = "We make a large variety of circuits for numerous ship systems shielded from sensor detection and external control interference", 
				history = "Our station is named after the law which quantifies the amount of force with which stationary electrically charged particals repel or attact each other - a fundamental principle in the design of our circuits",
			},
			["Heyes"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				true,		
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					sensor = {
						quantity =	5,
						cost =		72,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
				},
				description = "Sensor components", 
				general = "We research and manufacture sensor components and systems", 
				history = "The station is named after Tony Heyes the inventor of some of the earliest electromagnetic sensors in the mid 20th century on Earth in the United Kingdom to assist blind human mobility",
			},
			["Hossam"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					nanites = {
						quantity =	5,	
						cost =		90,
					},
				},
				trade = {
					food = random(1,100) < 24, 
					medicine = random(1,100) < 44, 
					luxury = random(1,100) < 63,
				},
				description = "Nanite supplier", 
				general = "We provide nanites for various organic and non-organic systems", 
				history = "This station is named after the nanotechnologist Hossam Haick from the early 21st century on Earth in Israel",
			},
			["Maiman"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				false,		
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					beam = {
						quantity =	5,
						cost =		70,
					},
				},
				trade = {
					food = false, 
					medicine = true, 
					luxury = false,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
				},
				description = "Energy beam components", 
				general = "We research and manufacture energy beam components and systems", 
				history = "The station is named after Theodore Maiman who researched and built the first laser in the mid 20th century on Earth",
			},
			["Malthus"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
		        goods = {},
    			trade = {
    				food = false, 
    				medicine = false, 
    				luxury = false,
    			},
    			description = "Gambling and resupply",
		        general = "The oldest station in the quadrant",
		        history = "",
			},
			["Marconi"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					beam = {
						quantity =	5,
						cost =		80,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Energy Beam Components", 
				general = "We manufacture energy beam components", 
				history = "Station named after Guglielmo Marconi an Italian inventor from early 20th century Earth who, along with Nicolo Tesla, claimed to have invented a death ray or particle beam weapon",
			},
			["Miller"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					optic =	{
						quantity =	5,
						cost =		60,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Exobiology research", 
				general = "We study recently discovered life forms not native to Earth", 
				history = "This station was named after one of the early exobiologists from mid 20th century Earth, Dr. Stanley Miller",
			},
			["Shawyer"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					impulse = {
						quantity =	5,
						cost =		100,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Impulse engine components", 
				general = "We research and manufacture impulse engine components and systems", 
				history = "The station is named after Roger Shawyer who built the first prototype impulse engine in the early 21st century",
			},
		},
		["History"] = {
			["Archimedes"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					beam = {
						quantity =	5,
						cost =		80,
					},
				},
				trade = {
					food = true, 
					medicine = false, 
					luxury = true,
				},
				description = "Energy and particle beam components", 
				general = "We fabricate general and specialized components for ship beam systems", 
				history = "This station was named after Archimedes who, according to legend, used a series of adjustable focal length mirrors to focus sunlight on a Roman naval fleet invading Syracuse, setting fire to it",
			},
			["Chatuchak"] =	{
		        weapon_available = {
		        	Homing =				random(1,10)<=(8-difficulty),	
		        	HVLI =				random(1,10)<=(9-difficulty),	
		        	Mine =				false,		
		        	Nuke =				random(1,10)<=(5-difficulty),	
		        	EMP =				random(1,10)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		60,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Trading station", 
				general = "Only the largest market and trading location in twenty sectors. You can find your heart's desire here", 
				history = "Modeled after the early 21st century bazaar on Earth in Bangkok, Thailand. Designed and built with trade and commerce in mind",
			},
			["Grasberg"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		70,
					},
				},
				trade = {
					food = true, 
					medicine = false, 
					luxury = false,
				},
				buy = {
					[randomComponent()] = math.random(40,200),
				},
				description = "Mining", 
				general ="We mine nearby asteroids for precious minerals and process them for sale", 
				history = "This station's name is inspired by a large gold mine on Earth in Indonesia. The station builders hoped to have a similar amount of minerals found amongst these asteroids",
			},
			["Hayden"] = {
		        weapon_available = {
		        	Homing = random(1,13)<=(8-difficulty),	
		        	HVLI = random(1,13)<=(9-difficulty),	
		        	Mine = random(1,13)<=(7-difficulty),	
		        	Nuke = random(1,13)<=(5-difficulty),	
		        	EMP = random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					nanites = {
						quantity =	5,
						cost =		65,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Observatory and stellar mapping", 
				general = "We study the cosmos and map stellar phenomena. We also track moving asteroids. Look out! Just kidding", 
				history = "Station named in honor of Charles Hayden whose philanthropy continued astrophysical research and education on Earth in the early 20th century",
			},
			["Lipkin"] = {
		        weapon_available = {
		        	Homing =				random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				false,		
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					autodoc = {
						quantity =	5,
						cost =		76,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Autodoc components", 
				general = "", 
				history = "The station is named after Dr. Lipkin who pioneered some of the research and application around robot assisted surgery in the area of partial nephrectomy for renal tumors in the early 21st century on Earth",
			},
			["Madison"] = {
		        weapon_available = {
		        	Homing =			false,		
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(60,70),
					},
				},
				trade = {
					food = false, 
					medicine = true, 
					luxury = false,
				},
				description = "Zero gravity sports and entertainment", 
				general = "Come take in a game or two or perhaps see a show", 
				history = "Named after Madison Square Gardens from 21st century Earth, this station was designed to serve similar purposes in space - a venue for sports and entertainment",
			},
			["Rutherford"] = {
		        weapon_available = {
		        	Homing = random(1,13)<=(8-difficulty),	
		        	HVLI = random(1,13)<=(9-difficulty),	
		        	Mine = random(1,13)<=(7-difficulty),	
		        	Nuke = random(1,13)<=(5-difficulty),	
		        	EMP = random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					shield = {
						quantity =	5,	
						cost =		90,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = random(1,100) < 43,
				},
				description = "Shield components and research", 
				general = "We research and fabricate components for ship shield systems", 
				history = "This station was named after the national research institution Rutherford Appleton Laboratory in the United Kingdom which conducted some preliminary research into the feasability of generating an energy shield in the late 20th century",
			},
			["Toohie"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					shield = {
						quantity =	5,
						cost =		90,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Shield and armor components and research", 
				general = "We research and make general and specialized components for ship shield and ship armor systems", 
				history = "This station was named after one of the earliest researchers in shield technology, Alexander Toohie back when it was considered impractical to construct shields due to the physics involved."},
		},
		["Pop Sci Fi"] = {
			["Anderson"] = {
		        weapon_available = {
		        	Homing = false,		
		        	HVLI = random(1,13)<=(9-difficulty),	
		        	Mine = random(1,13)<=(7-difficulty),	
		        	Nuke = random(1,13)<=(5-difficulty),	
		        	EMP = random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					battery = {
						quantity =	5,
						cost =		66,
					},
        			software = {
        				quantity =	5,
        				cost =		115,
        			},
        		},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Battery and software engineering", 
				general = "We provide high quality high capacity batteries and specialized software for all shipboard systems", 
				history = "The station is named after a fictional software engineer in a late 20th century movie depicting humanity unknowingly conquered by aliens and kept docile by software generated illusion",
			},
			["Archer"] = {
		        weapon_available = {
		        	Homing = 			random(1,13)<=(8-difficulty),	
		        	HVLI = 				true,		
		        	Mine = 				random(1,13)<=(7-difficulty),	
		        	Nuke = 				random(1,13)<=(5-difficulty),	
		        	EMP = 				true
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					shield = {
						quantity =	5,
						cost =		90,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
				},
				description = "Shield and Armor Research", 
				general = "The finest shield and armor manufacturer in the quadrant", 
				history = "We named this station for the pioneering spirit of the 22nd century Starfleet explorer, Captain Jonathan Archer",
			},
			["Barclay"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				false,		
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					communication =	{
						quantity =	5,
						cost =		58,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
				},
				description = "Communication components", 
				general = "We provide a range of communication equipment and software for use aboard ships", 
				history = "The station is named after Reginald Barclay who established the first transgalactic com link through the creative application of a quantum singularity. Station personnel often refer to the station as the Broccoli station",
			},
			["Calvin"] = {
		        weapon_available = {
		        	Homing =			false,		
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {	
					robotic = {
						quantity =	5,	
						cost = 		90,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				buy =	{
					[randomComponent("robotic")] = math.random(40,200)
				},
				description = "Robotic research", 
				general = "We research and provide robotic systems and components", 
				history = "This station is named after Dr. Susan Calvin who pioneered robotic behavioral research and programming",
			},
			["Cavor"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					filament = {
						quantity =	5,
						cost =		42,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Advanced Material components", 
				general = "We fabricate several different kinds of materials critical to various space industries like ship building, station construction and mineral extraction", 
				history = "We named our station after Dr. Cavor, the physicist that invented a barrier material for gravity waves - Cavorite",
			},
			["Cyrus"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					impulse = {
						quantity =	5,
						cost =		124,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = random(1,100) < 78,
				},
				description = "Impulse engine components", 
				general = "We supply high quality impulse engines and parts for use aboard ships", 
				history = "This station was named after the fictional engineer, Cyrus Smith created by 19th century author Jules Verne",
			},
			["Deckard"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					android = {
						quantity =	5,
						cost =		73,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Android components", 
				general = "Supplier of android components, programming and service", 
				history = "Named for Richard Deckard who inspired many of the sophisticated safety security algorithms now required for all androids",
			},
			["Erickson"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					transporter = {
						quantity =	5,
						cost =		63,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Transporter components", 
				general = "We provide transporters used aboard ships as well as the components for repair and maintenance", 
				history = "The station is named after the early 22nd century inventor of the transporter, Dr. Emory Erickson. This station is proud to have received the endorsement of Admiral Leonard McCoy",
			},
			["Jabba"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Commerce and gambling", 
				general = "Come play some games and shop. House take does not exceed 4 percent", 
				history = "",
			},			
			["Komov"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				true,	
		        	Nuke =				false,	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					filament = {
						quantity =	5,
						cost =		46,
					},
				},
 				trade = {
 					food = false, 
 					medicine = false, 
 					luxury = false,
 				},
				description = "Xenopsychology training", 
				general = "We provide classes and simulation to help train diverse species in how to relate to each other", 
				history = "A continuation of the research initially conducted by Dr. Gennady Komov in the early 22nd century on Venus, supported by the application of these principles",
			},
			["Lando"] = {
		        weapon_available = {
		        	Homing =			true,	
		        	HVLI =				true,	
		        	Mine =				true,	
		        	Nuke =				false,	
		        	EMP =				false,
		        },
				weapon_cost = {
					Homing = math.random(2,5),
					HVLI = 2,
					Mine = math.random(2,5),
				},
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					shield = {
						quantity =	5,
						cost =		90,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Casino and Gambling", 
				general = "", 
				history = "",
			},			
			["Muddville"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		60,
					},
				},
				trade = {
					food = true, 
					medicine = true, 
					luxury = false,
				},
				description = "Trading station", 
				general = "Come to Muddvile for all your trade and commerce needs and desires", 
				history = "Upon retirement, Harry Mudd started this commercial venture using his leftover inventory and extensive connections obtained while he traveled the stars as a salesman",
			},
			["Nexus-6"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				false,		
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					android = {
						quantity =	5,
						cost =		93,
					},
				},
				trade = {
					food = false, 
					medicine = true, 
					luxury = false,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
					[randomComponent("android")] = math.random(40,200),
				},
				description = "Android components", 
				general = "Androids, their parts, maintenance and recylcling", 
				history = "We named the station after the ground breaking android model produced by the Tyrell corporation",
			},
			["O'Brien"] = {
		        weapon_available = {
		        	Homing = random(1,13)<=(8-difficulty),	
		        	HVLI = random(1,13)<=(9-difficulty),	
		        	Mine = random(1,13)<=(7-difficulty),	
		        	Nuke = random(1,13)<=(5-difficulty),	
		        	EMP = random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					transporter = {
						quantity =	5,
						cost =		76,
					},
				},
				trade = {
					food = random(1,100) < 13, 
					medicine = true, 
					luxury = random(1,100) < 43,
				},
				description = "Transporter components", 
				general = "We research and fabricate high quality transporters and transporter components for use aboard ships", 
				history = "Miles O'Brien started this business after his experience as a transporter chief",
			},
			["Organa"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		95,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Diplomatic training", 
				general = "The premeire academy for leadership and diplomacy training in the region", 
				history = "Established by the royal family so critical during the political upheaval era",
			},
			["Owen"] = {
		        weapon_available = {
		        	Homing =			true,			
		        	HVLI =				false,		
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					lifter = {
						quantity =	5,
						cost =		61,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Load lifters and components", 
				general = "We provide load lifters and components for various ship systems", 
				history = "Owens started off in the moisture vaporator business on Tattooine then branched out into load lifters based on acquisition of proprietary software and protocols. The station name recognizes the tragic loss of our founder to Imperial violence",
			},
			["Ripley"] = {
		        weapon_available = {
		        	Homing =			false,		
		        	HVLI =				true,		
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					lifter = {
						quantity =	5,
						cost =		82,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = random(1,100) < 47,
				},
				description = "Load lifters and components", 
				general = "We provide load lifters and components", 
				history = "The station is named after Ellen Ripley who made creative and effective use of one of our load lifters when defending her ship",
			},
			["Skandar"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Routine maintenance and entertainment", 
				general = "Stop by for repairs. Take in one of our juggling shows featuring the four-armed Skandars", 
				history = "The nomadic Skandars have set up at this station to practice their entertainment and maintenance skills as well as build a community where Skandars can relax",
			},			
			["Soong"] = {
		        weapon_available = {
		        	Homing = random(1,13)<=(8-difficulty),	
		        	HVLI = random(1,13)<=(9-difficulty),	
		        	Mine = random(1,13)<=(7-difficulty),	
		        	Nuke = random(1,13)<=(5-difficulty),	
		        	EMP = random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					android = {
						quantity =	5,
						cost = 73,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Android components", 
				general = "We create androids and android components", 
				history = "The station is named after Dr. Noonian Soong, the famous android researcher and builder",
			},
			["Starnet"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
		        goods = {	
		        	software =	{
		        		quantity =	5,	
		        		cost =		140,
		        	},
		        },
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Automated weapons systems", 
				general = "We research and create automated weapons systems to improve ship combat capability", 
				history = "Lost the history memory bank. Recovery efforts only brought back the phrase, 'I'll be back'",
			},			
			["Tiberius"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					food = {
						quantity =	5,
						cost =		1,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Logistics coordination", 
				general = "We support the stations and ships in the area with planning and communication services", 
				history = "We recognize the influence of Starfleet Captain James Tiberius Kirk in the 23rd century in our station name",
			},
			["Tokra"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					filament = {
						quantity =	5,
						cost =		42,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Advanced material components", 
				general = "We create multiple types of advanced material components. Our most popular products are our filaments", 
				history = "We learned several of our critical industrial processes from the Tokra race, so we honor our fortune by naming the station after them",
			},
			["Utopia Planitia"] = {
		        weapon_available = 	{
		        	Homing = 			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				true,		
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        goods = {	
		        	warp =	{
		        		quantity =	5,	
		        		cost =		167,
		        	},
		        },
		        trade = {	
		        	food = false, 
		        	medicine = false, 
		        	luxury = false 
		        },
				description = "Ship building and maintenance facility", 
				general = "We work on all aspects of naval ship building and maintenance. Many of the naval models are researched, designed and built right here on this station. Our design goals seek to make the space faring experience as simple as possible given the tremendous capabilities of the modern naval vessel", 
				history = ""
			},
			["Vaiken"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					food = {
						quantity =	10,
						cost = 		1,
					},
        			medicine = {
        				quantity =	5,
        				cost = 		5,
        			},
        			impulse = {
        				quantity =	5,
        				cost = 		math.random(65,97),
        			},
        		},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Ship building and maintenance facility", 
				general = "", 
				history = "",
			},			
			["Zefram"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
		        goods = {	
		        	warp =	{
		        		quantity =	5,	
		        		cost =		140,
		        	},
		        },
		        trade = {	
		        	food = false, 
		        	medicine = false, 
		        	luxury = true,
		        },
				description = "Warp engine components", 
				general = "We specialize in the esoteric components necessary to make warp drives function properly", 
				history = "Zefram Cochrane constructed the first warp drive in human history. We named our station after him because of the specialized warp systems work we do",
			},
		},
		["Spec Sci Fi"] = {
			["Alcaleica"] =	{
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					optic = {
						quantity =	5,
						cost =		66,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
				},
				description = "Optical Components", 
				general = "We make and supply optic components for various station and ship systems", 
				history = "This station continues the businesses from Earth based on the merging of several companies including Leica from Switzerland, the lens manufacturer and the Japanese advanced low carbon (ALCA) electronic and optic research and development company",
			},
			["Bethesda"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				reputation_cost_multipliers = {
					friend = 1.0, 
					neutral = 3.0,
				},
				goods = {	
					autodoc = {
						quantity =	5,
						cost =		36,
					},
					medicine = {
						quantity =	5,					
						cost = 		5,
					},
					food = {
						quantity =	math.random(5,10),	
						cost = 		1,
					},
				},
				trade = {	
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Medical research", 
				general = "We research and treat exotic medical conditions", 
				history = "The station is named after the United States national medical research center based in Bethesda, Maryland on earth which was established in the mid 20th century",
			},
			["Deer"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {	
					tractor = {
						quantity =	5,	
						cost =		90,
					},
        			repulsor = {
        				quantity =	5,
        				cost =		math.random(85,95),
        			},
        		},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Repulsor and Tractor Beam Components", 
				general = "We can meet all your pushing and pulling needs with specialized equipment custom made", 
				history = "The station name comes from a short story by the 20th century author Clifford D. Simak as well as from the 19th century developer John Deere who inspired a company that makes the Earth bound equivalents of our products",
			},
			["Evondos"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				true,		
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				reputation_cost_multipliers = {
					friend = 1.0, 
					neutral = 3.0,
				},
				goods = {
					autodoc = {
						quantity =	5,
						cost =		56,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = random(1,100) < 41,
				},
				description = "Autodoc components", 
				general = "We provide components for automated medical machinery", 
				history = "The station is the evolution of the company that started automated pharmaceutical dispensing in the early 21st century on Earth in Finland",
			},
			["Feynman"] = {
		        weapon_available = 	{
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				true,		
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
        		goods = {	
        			software = {
        				quantity = 	5,	
        				cost =		115,
        			},
        			nanites = {
        				quantity =	5,	
        				cost =		79,
        			},
        		},
		        trade = {	
		        	food = false, 
		        	medicine = false, 
		        	luxury = true,
		        },
				description = "Nanotechnology research", 
				general = "We provide nanites and software for a variety of ship-board systems", 
				history = "This station's name recognizes one of the first scientific researchers into nanotechnology, physicist Richard Feynman",
			},
			["Mayo"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					autodoc = {
						quantity =	5,
						cost =		128,
					},
        			food = {
        				quantity =	5,
        				cost =		1,
        			},
        			medicine = {
        				quantity =	5,
        				cost =		5,
        			},
        		},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Medical Research", 
				general = "We research exotic diseases and other human medical conditions", 
				history = "We continue the medical work started by William Worrall Mayo in the late 19th century on Earth",
			},
			["Olympus"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					optic =	{
						quantity =	5,
						cost =		66,
					},
				},
				trade = {	
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Optical components", 
				general = "We fabricate optical lenses and related equipment as well as fiber optic cabling and components", 
				history = "This station grew out of the Olympus company based on earth in the early 21st century. It merged with Infinera, then bought several software comapnies before branching out into space based industry",
			},
			["Panduit"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					optic =	{
						quantity =	5,
						cost =		79,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Optic components", 
				general = "We provide optic components for various ship systems", 
				history = "This station is an outgrowth of the Panduit corporation started in the mid 20th century on Earth in the United States",
			},
			["Shree"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {	
					tractor = {
						quantity =	5,	
						cost =		90,
					},
        			repulsor = {
        				quantity =	5,
        				cost =		math.random(85,95),
        			},
        		},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Repulsor and tractor beam components", 
				general = "We make ship systems designed to push or pull other objects around in space", 
				history = "Our station is named Shree after one of many tugboat manufacturers in the early 21st century on Earth in India. Tugboats serve a similar purpose for ocean-going vessels on earth as tractor and repulsor beams serve for space-going vessels today",
			},
			["Vactel"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					circuit = {
						quantity =	5,
						cost =		50,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Shielded Circuitry Fabrication", 
				general = "We specialize in circuitry shielded from external hacking suitable for ship systems", 
				history = "We started as an expansion from the lunar based chip manufacturer of Earth legacy Intel electronic chips",
			},
			["Veloquan"] = {
		        weapon_available = {
		        	Homing = random(1,13)<=(8-difficulty),	
		        	HVLI = random(1,13)<=(9-difficulty),	
		        	Mine = random(1,13)<=(7-difficulty),	
		        	Nuke = random(1,13)<=(5-difficulty),	
		        	EMP = random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					sensor = {
						quantity =	5,
						cost =		68,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Sensor components", 
				general = "We research and construct components for the most powerful and accurate sensors used aboard ships along with the software to make them easy to use", 
				history = "The Veloquan company has its roots in the manufacturing of LIDAR sensors in the early 21st century on Earth in the United States for autonomous ground-based vehicles. They expanded research and manufacturing operations to include various sensors for space vehicles. Veloquan was the result of numerous mergers and acquisitions of several companies including Velodyne and Quanergy",
			},
			["Tandon"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Biotechnology research",
				general = "Merging the organic and inorganic through research", 
				history = "Continued from the Tandon school of engineering started on Earth in the early 21st century",
			},
		},
		["Generic"] = {
			["California"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {	
					gold = {
						quantity =	5,
						cost =		90,
					},
					dilithium = {
						quantity =	2,					
						cost = 		25,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Mining station", 
				general = "", 
				history = "",
			},
			["Impala"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		70,
					},
				},
				trade = {
					food = true, 
					medicine = false, 
					luxury = true,
				},
				buy = {
					[randomComponent()] = math.random(40,200),
				},
				description = "Mining", 
				general = "We mine nearby asteroids for precious minerals", 
				history = "",
			},
			["Krak"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				true,		
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					nickel = {
						quantity =	5,
						cost =		20,
					},
				},
				trade = {
					food = random(1,100) < 50, 
					medicine = true, 
					luxury = random(1,100) < 50,
				},
				buy = {
					[randomComponent()] = math.random(40,200),
				},
				description = "Mining station", 
				general = "", 
				history = "",
			},
			["Krik"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					nickel = {
						quantity =	5,
						cost =		20,
					},
				},
				trade = {
					food = true, 
					medicine = true, 
					luxury = random(1,100) < 50,
				},
				description = "Mining station", 
				general = "", 
				history = "",
			},
			["Kruk"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					nickel = {
						quantity =	5,
						cost =		20,
					},
				},
				trade = {
					food = random(1,100) < 50, 
					medicine = random(1,100) < 50, 
					luxury = true },
				buy = {
					[randomComponent()] = math.random(40,200),
				},
				description = "Mining station", 
				general = "", 
				history = "",
			},
			["Maverick"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Gambling and resupply", 
				general = "Relax and meet some interesting players", 
				history = "",
			},
			["Nefatha"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Commerce and recreation", 
				general = "", 
				history = "",
			},
			["Okun"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				false,		
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Xenopsychology research", 
				general = "", 
				history = "",
			},
			["Outpost-15"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Mining and trade", 
				general = "", 
				history = "",
			},
			["Outpost-21"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Mining and gambling", 
				general = "", 
				history = "",
			},
			["Outpost-7"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Resupply", 
				general = "", 
				history = "",
			},
			["Outpost-8"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "", 
				general = "", 
				history = "",
			},
			["Outpost-33"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Resupply", 
				general = "", 
				history = "",
			},
			["Prada"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				false,		
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Textiles and fashion", 
				general = "", 
				history = "",
			},
			["Research-11"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					medicine = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Stress Psychology Research", 
				general = "", 
				history = "",
			},
			["Research-19"] = {
		        weapon_available ={
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
		        goods = {},
		        trade = {
		        	food = false, 
		        	medicine = false, 
		        	luxury = false,
		        },
				description = "Low gravity research", 
				general = "", 
				history = "",
			},
			["Rubis"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Resupply", 
				general = "Get your energy here! Grab a drink before you go!", 
				history = "",
			},
			["Science-2"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					circuit = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Research Lab and Observatory", 
				general = "", 
				history = "",
			},
			["Science-4"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					medicine = {
						quantity =	5,
						cost =		math.random(30,80),
					},
					autodoc = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Biotech research", 
				general = "", 
				history = "",
			},
			["Science-7"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					food = {
						quantity =	2,
						cost =		1,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Observatory", 
				general = "", 
				history = "",
			},
			["Spot"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
		        goods = {},
		        trade = {
		        	food = false, 
		        	medicine = false, 
		        	luxury = false,
		        },
				description = "Observatory", 
				general = "", 
				history = "",
			},
			["Valero"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Resupply", 
				general = "", 
				history = "",
			},
		},
		["Sinister"] = {
			["Aramanth"] =	{goods = {}, description = "", general = "", history = ""},
			["Empok Nor"] =	{goods = {}, description = "", general = "", history = ""},
			["Gandala"] =	{goods = {}, description = "", general = "", history = ""},
			["Hassenstadt"] =	{goods = {}, description = "", general = "", history = ""},
			["Kaldor"] =	{goods = {}, description = "", general = "", history = ""},
			["Magenta Mesra"] =	{goods = {}, description = "", general = "", history = ""},
			["Mos Eisley"] =	{goods = {}, description = "", general = "", history = ""},
			["Questa Verde"] =	{goods = {}, description = "", general = "", history = ""},
			["R'lyeh"] =	{goods = {}, description = "", general = "", history = ""},
			["Scarlet Citadel"] =	{goods = {}, description = "", general = "", history = ""},
			["Stahlstadt"] =	{goods = {}, description = "", general = "", history = ""},
			["Ticonderoga"] =	{goods = {}, description = "", general = "", history = ""},
		},
	}
	
	primaryOrders = "Patrol Asimov, Utopia Planitia and Armstrong stations. Defend if enemies attack. Dock with each station at the end of each patrol leg"
	secondaryOrders = ""
	optionalOrders = ""
	highestPatrolLeg = 0
	playerCount = 0
	highestConcurrentPlayerCount = 0
	setConcurrentPlayerCount = 0

	plot1 = initialOrderMessage
	plotT = transportPlot
	plotTname = "transportPlot"
	plotArt = unscannedAnchors
	plotH = healthCheck
	plotRS = relayStatus
	healthCheckTimer = 5
	healthCheckTimerInterval = 5
	jumpStartTimer = random(30,90)
	patrolComplete = false
	sporadicHarassInterval = 400
	sporadicHarassTimer = sporadicHarassInterval
end
function setPlayers()
	concurrentPlayerCount = 0
	for p1idx=1,8 do
		pobj = getPlayerShip(p1idx)
		if pobj ~= nil and pobj:isValid() then
			concurrentPlayerCount = concurrentPlayerCount + 1
			if goods[pobj] == nil then
				goods[pobj] = goodsList
			end
			if pobj.initialRep == nil then
				pobj:addReputationPoints(250-(difficulty*6))
				pobj.initialRep = true
			end
			if pobj.patrolLegAsimov == nil then pobj.patrolLegAsimov = 0 end
			if pobj.patrolLegUtopiaPlanitia == nil then pobj.patrolLegUtopiaPlanitia = 0 end
			if pobj.patrolLegArmstrong == nil then pobj.patrolLegArmstrong = 0 end
			if not pobj.nameAssigned then
				pobj.nameAssigned = true
				tempPlayerType = pobj:getTypeName()
				if tempPlayerType == "MP52 Hornet" then
					if #playerShipNamesFor["MP52Hornet"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["MP52Hornet"]))
					end
					pobj.shipScore = 7
					pobj.maxCargo = 3
					pobj:setWarpDrive(true)
				elseif tempPlayerType == "Piranha" then
					if #playerShipNamesFor["Piranha"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Piranha"]))
					end
					pobj.shipScore = 16
					pobj.maxCargo = 8
				elseif tempPlayerType == "Flavia P.Falcon" then
					if #playerShipNamesFor["FlaviaPFalcon"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["FlaviaPFalcon"]))
					end
					pobj.shipScore = 13
					pobj.maxCargo = 15
				elseif tempPlayerType == "Phobos M3P" then
					if #playerShipNamesFor["PhobosM3P"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["PhobosM3P"]))
					end
					pobj.shipScore = 19
					pobj.maxCargo = 10
					pobj:setWarpDrive(true)
				elseif tempPlayerType == "Atlantis" then
					if #playerShipNamesFor["Atlantis"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Atlantis"]))
					end
					pobj.shipScore = 52
					pobj.maxCargo = 6
				elseif tempPlayerType == "Player Cruiser" then
					if #playerShipNamesFor["Cruiser"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Cruiser"]))
					end
					pobj.shipScore = 40
					pobj.maxCargo = 6
				elseif tempPlayerType == "Player Missile Cr." then
					if #playerShipNamesFor["MissileCruiser"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["MissileCruiser"]))
					end
					pobj.shipScore = 45
					pobj.maxCargo = 8
				elseif tempPlayerType == "Player Fighter" then
					if #playerShipNamesFor["Fighter"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Fighter"]))
					end
					pobj.shipScore = 7
					pobj.maxCargo = 3
					pobj:setJumpDrive(true)
					pobj:setJumpDriveRange(3000,40000)
				elseif tempPlayerType == "Benedict" then
					if #playerShipNamesFor["Benedict"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Benedict"]))
					end
					pobj.shipScore = 10
					pobj.maxCargo = 9
				elseif tempPlayerType == "Kiriya" then
					if #playerShipNamesFor["Kiriya"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Kiriya"]))
					end
					pobj.shipScore = 10
					pobj.maxCargo = 9
				elseif tempPlayerType == "Striker" then
					if #playerShipNamesFor["Striker"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Striker"]))
					end
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
					pobj.shipScore = 8
					pobj.maxCargo = 4
					pobj:setJumpDrive(true)
					pobj:setJumpDriveRange(3000,40000)
				elseif tempPlayerType == "ZX-Lindworm" then
					if #playerShipNamesFor["Lindworm"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Lindworm"]))
					end
					pobj.shipScore = 8
					pobj.maxCargo = 3
					pobj.autoCoolant = false
					pobj:setWarpDrive(true)
				elseif tempPlayerType == "Repulse" then
					if #playerShipNamesFor["Repulse"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Repulse"]))
					end
					pobj.shipScore = 14
					pobj.maxCargo = 12
				elseif tempPlayerType == "Ender" then
					if #playerShipNamesFor["Ender"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Ender"]))
					end
					pobj.shipScore = 100
					pobj.maxCargo = 20
				elseif tempPlayerType == "Nautilus" then
					if #playerShipNamesFor["Nautilus"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Nautilus"]))
					end
					pobj.shipScore = 12
					pobj.maxCargo = 7
				elseif tempPlayerType == "Hathcock" then
					if #playerShipNamesFor["Hathcock"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Hathcock"]))
					end
					pobj.shipScore = 30
					pobj.maxCargo = 6
				elseif tempPlayerType == "Maverick" then
					if #playerShipNamesFor["Maverick"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Maverick"]))
					end
					pobj.shipScore = 45
					pobj.maxCargo = 5
				elseif tempPlayerType == "Crucible" then
					if #playerShipNamesFor["Crucible"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Crucible"]))
					end
					pobj.shipScore = 45
					pobj.maxCargo = 5
				else
					if #playerShipNamesFor["Leftovers"] > 0 then
						pobj:setCallSign(tableRemoveRandom(playerShipNamesFor["Leftovers"]))
					end
					pobj.shipScore = 24
					pobj.maxCargo = 5
					pobj:setWarpDrive(true)
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
				end
			end
			pobj.initialCoolant = pobj:getMaxCoolant()
		end
	end
end
--Randomly choose station size template unless overridden
function szt()
	if stationSize ~= nil then
		sizeTemplate = stationSize
		return sizeTemplate
	end
	stationSizeRandom = random(1,100)
	if stationSizeRandom < 8 then
		sizeTemplate = "Huge Station"		-- 8 percent huge
	elseif stationSizeRandom < 24 then
		sizeTemplate = "Large Station"		--16 percent large
	elseif stationSizeRandom < 50 then
		sizeTemplate = "Medium Station"		--26 percent medium
	else
		sizeTemplate = "Small Station"		--50 percent small
	end
	return sizeTemplate
end
function randomMineral(exclude)
	local good = mineralGoods[math.random(1,#mineralGoods)]
	if exclude == nil then
		return good
	else
		repeat
			good = mineralGoods[math.random(1,#mineralGoods)]
		until(good ~= exclude)
		return good
	end
end
function randomComponent(exclude)
	local good = componentGoods[math.random(1,#componentGoods)]
	if exclude == nil then
		return good
	else
		repeat
			good = componentGoods[math.random(1,#componentGoods)]
		until(good ~= exclude)
		return good
	end
end
function placeStation(x,y,name,faction,size)
	--x and y are the position of the station
	--name should be the name of the station or the name of the station group
	--		omit name to get random station from groups in priority order
	--faction is the faction of the station
	--		omit and stationFaction will be used
	--size is the name of the station template to use
	--		omit and station template will be chosen at random via szt function
	if x == nil then return nil end
	if y == nil then return nil end
	local group, station = pickStation(name)
	if group == nil then return nil end
	station:setPosition(x,y)
	if faction ~= nil then
		station:setFaction(faction)
	else
		station:setFaction(stationFaction)
	end
	if size == nil then
		station:setTemplate(szt())
		return station
	end
	local function Set(list)
		local set = {}
		for _, item in ipairs(list) do
			set[item] = true
		end
		return set
	end
	local station_size_templates = Set{"Small Station","Medium Station","Large Station","Huge Station"}
	if station_size_templates[size] then
		station:setTemplate(size)
	else
		station:setTemplate(szt())
	end
	return station
end
function pickStation(name)
	if name == nil then
		--default to random in priority order
		print("Select random in group priority order not yet implemented")
		return nil
	else
		if name == "Random" then
			--random across all groups
			print("Select random across all groups not yet implemented")
			return nil
		else
			if station_pool[name] ~= nil then
				--name is a group name
				print("Select random from group not yet implemented")
				return nil
			else
				for group, list in pairs(station_pool) do
					if station_pool[group][name] ~= nil then
						local station = SpaceStation():setCommsScript(""):setCommsFunction(commsStation):setCallSign(name):setDescription(station_pool[group][name].description)
						station.comms_data = station_pool[group][name]
						station_pool[group][name] = nil
						return group, station
					end
				end
				--name not found in any group
				print("Name provided not found in groups or stations")
				return nil
			end
		end
	end
end
function generateStaticWorld()
	stationList = {}
	patrolStationList = {}
	tradeFood = {}
	tradeLuxury = {}
	tradeMedicine = {}
	totalStations = 0
	friendlyStations = 0
	neutralStations = 0
	
	createRandomAsteroidAlongArc(30,70000,160000,100000,180,225,3000)
	createRandomAsteroidAlongArc(30,-70000,20000,100000,0,45,3000)
	createRandomAsteroidAlongArc(40,160000,20000,130000,180,225,3000)
	placeRandomAsteroidsAroundPoint(25,1,15000,150000,-30000)
	
	createRandomAlongArc(Nebula,30,150000,0,150000,110,220,30000)
	createRandomAlongArc(Nebula,30,50000,200000,200000,200,300,40000)
	
	artAnchor1 = Artifact():setPosition(150000,-30000):setScanningParameters(3,2):setRadarSignatureInfo(random(2,8),random(22,87),random(2,8))
	artAnchor1:setModel("artifact3"):allowPickup(false):setDescriptions("Unusual object","Potential object of scientific research")
	artAnchor2 = Artifact():setPosition(random(0,100000),random(70000,100000)):setScanningParameters(2,3):setRadarSignatureInfo(random(2,8),random(22,87),random(2,8))
	artAnchor2:setModel("artifact5"):allowPickup(false):setDescriptions("Object outside of normal parameters","Good research material")
--	artTube = Artifact():setPosition(random(-50000,-20500),random(100000,199500)):setScanningParameters(1,4):setRadarSignatureInfo(random(30,100),random(5,25),random(40,60))
--	artTube:setModeel("artifact6"):allowPickup(false):setDescriptions("Strange looking object","Object with unusual subatomic characteristics")

	--Asimov
	asimovx = random(500,9500)
	asimovy = random(-19500,19500)
	stationAsimov = placeStation(asimovx,asimovy,"Asimov","Human Navy","Medium Station")
	stationAsimov.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
	if random(1,5) <= 1 then stationAsimov.comms_data.goods.medicine = {quantity = 5, cost = 5}	end
	table.insert(stationList,stationAsimov)
	table.insert(patrolStationList,stationAsimov)
	friendlyStations = friendlyStations + 1
	
	--Utopia Planitia
	utopiaPlanitiax = random(120500,139500)
	utopiaPlanitiay = random(-4500,44500)
	stationUtopiaPlanitia = placeStation(utopiaPlanitiax,utopiaPlanitiay,"Utopia Planitia","Human Navy","Large Station")
	stationUtopiaPlanitia.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
	if random(1,5) <= 1 then stationUtopiaPlanitia.comms_data.goods.medicine = {quantity = 5, cost = 5}	end
	table.insert(stationList,stationUtopiaPlanitia)
	table.insert(patrolStationList,stationUtopiaPlanitia)
	friendlyStations = friendlyStations + 1
	--Armstrong
	armstrongx = random(10500,69500)
	armstrongy = random(140500,159500)
	stationArmstrong = placeStation(armstrongx,armstrongy,"Armstrong","Human Navy","Huge Station")
	stationArmstrong.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
	stationArmstrong.comms_data.goods.medicine = {quantity = 5, cost = 5}
	table.insert(stationList,stationArmstrong)
	table.insert(patrolStationList,stationArmstrong)
	friendlyStations = friendlyStations + 1
	--Bethesda (first of three around larger secondary circle of stations)
	local bethesdaAngle = random(0,360)
	local xBethesda, yBethesda = vectorFromAngle(bethesdaAngle, random(35000,40000))
	stationBethesda = placeStation(40000+xBethesda,150000+yBethesda,"Bethesda","Human Navy","Medium Station")
	table.insert(stationList,stationBethesda)
	friendlyStations = friendlyStations + 1
	--Feynman (second of three around larger secondary circle of stations)
	local feynmanAngle = bethesdaAngle + random(60,180)
	local xFeynman, yFeynman = vectorFromAngle(feynmanAngle, random(35000,40000))
	stationFeynman = placeStation(xFeynman,yFeynman,"Feynman","Independent","Small Station")
	stationFeynman.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
	if random(1,5) <= 1 then stationFeynman.comms_data.goods.medicine = {quantity = 5, cost = 5} end
	table.insert(stationList,stationFeynman)
	neutralStations = neutralStations + 1
	--Calvin (third of three around larger secondary circle of stations)
	local calvinAngle = feynmanAngle + random(60,120)
	local xCalvin, yCalvin = vectorFromAngle(calvinAngle, random(35000,40000))
	stationCalvin = placeStation(40000+xCalvin,150000+yCalvin,"Calvin","Independent","Medium Station")
	stationCalvin.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
	if random(1,5) <= 1 then stationCalvin.comms_data.goods.medicine = {quantity = 5, cost = 5}	end
	table.insert(stationList,stationCalvin)
	neutralStations = neutralStations + 1
	--Zefram (first of four around the zero-centered circle of stations)
	local zeframAngle = random(0,360)
	local xZefram, yZefram = vectorFromAngle(zeframAngle,random(42000,50000))
	stationZefram = placeStation(xZefram,yZefram,"Zefram","Independent","Small Station")
	stationZefram.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
	if random(1,5) <= 1 then
		stationZefram.comms_data.goods.medicine = {quantity = 5, cost = 5}
	else
		stationZefram.comms_data.trade.medicine = random(1,100) < 27
	end
	table.insert(stationList,stationZefram)
	friendlyStations = friendlyStations + 1
	--Coulomb (second of four around the zero-centered circle of stations)
	local coulombAngle = zeframAngle + random(60,120)
	local xCoulomb, yCoulomb = vectorFromAngle(coulombAngle,random(42000,50000))
	stationCoulomb = placeStation(xCoulomb,yCoulomb,"Coulomb","Independent","Small Station")
	stationCoulomb.comms_data.trade.medicine = random(1,100) < 27
	stationCoulomb.comms_data.trade.food = random(1,100) < 16
	table.insert(stationList,stationCoulomb)
	neutralStations = neutralStations + 1
	--Shree (third of four around the zero-centered circle of stations)
	local shreeAngle = coulombAngle + random(60,120)
	local xShree, yShree = vectorFromAngle(shreeAngle,random(42000,50000))
	stationShree = placeStation(xShree,yShree,"Shree","Independent","Small Station")
	stationShree.comms_data.trade.medicine = true
	stationShree.comms_data.trade.food = true
	table.insert(stationList,stationShree)
	neutralStations = neutralStations + 1
	--Veloquan (fourth of four around the zero-centered circle of stations)
	local veloquanAngle = shreeAngle + random(60,90)
	local xVeloquan, yVeloquan = vectorFromAngle(veloquanAngle,random(42000,50000))
	stationVeloquan = placeStation(xVeloquan,yVeloquan,"Veloquan","Independent","Small Station")
	stationVeloquan.comms_data.trade.medicine = true
	stationVeloquan.comms_data.trade.food = true
	table.insert(stationList,stationVeloquan)
	neutralStations = neutralStations + 1
	--Soong (first of three around smaller secondary circle of stations)
	local soongAngle = random(0,360)
	local xSoong, ySoong = vectorFromAngle(soongAngle, random(30000,35000))
	stationSoong = placeStation(130000+xSoong,20000+ySoong,"Soong","Human Navy","Small Station")
	stationSoong.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
	if random(1,5) <= 1 then stationSoong.comms_data.goods.medicine = {quantity = 5, cost = 5} end
	table.insert(stationList,stationSoong)
	friendlyStations = friendlyStations + 1
	--Starnet (second of three around smaller secondary circle of stations)
	local starnetAngle = soongAngle + random(60,180)
	local xStarnet, yStarnet = vectorFromAngle(starnetAngle, random(30000,35000))
	stationStarnet = placeStation(130000+xStarnet,20000+yStarnet,"Starnet","Independent","Small Station")
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationStarnet.comms_data.goods.shield = {quantity = 5, cost = math.random(85,94)}
	elseif stationGoodChoice == 2 then
		stationStarnet.comms_data.goods.beam = {quantity = 5, cost = math.random(62,75)}
	else
		stationStarnet.comms_data.goods.lifter = {quantity = 5, cost = math.random(55,89)}
	end
	table.insert(stationList,stationStarnet)
	neutralStations = neutralStations + 1
	--Anderson (third of three around smaller secondary circle of stations)
	local andersonAngle = starnetAngle + random(60,120)
	local xAnderson, yAnderson = vectorFromAngle(andersonAngle, random(30000,35000))
	stationAnderson = placeStation(130000+xAnderson,20000+yAnderson,"Anderson","Independent","Small Station")
	table.insert(stationList,stationAnderson)
	neutralStations = neutralStations + 1
	
	stationFaction = "Independent"
	stationSize = "Small Station"
	
	--Spot
	stationSpot = placeStation(random(-50000,9500),random(200500,210000),"Spot","Independent","Small Station")
	if stationGoodChoice == 1 then
		stationSpot.comms_data.goods.optic = {quantity = 5, cost = math.random(85,94)}
	elseif stationGoodChoice == 2 then
		stationSpot.comms_data.goods.software = {quantity = 5, cost = math.random(62,75)}
	else
		stationSpot.comms_data.goods.sensor = {quantity = 5, cost = math.random(55,89)}
	end
	table.insert(stationList,stationSpot)
	neutralStations = neutralStations + 1
	--Rutherford
	stationRutherford = placeStation(random(-9500,9500),random(175000,199500),"Rutherford","Independent","Small Station")
	stationRutherford.comms_data.trade.food = true
	stationRutherford.comms_data.trade.medicine = true
	table.insert(stationList,stationRutherford)
	neutralStations = neutralStations + 1
	--Evondos
	stationEvondos = placeStation(random(10500,29500),random(190000,210000),"Evondos","Independent","Small Station")
	stationEvondos.comms_data.trade.medicine = true
	table.insert(stationList,stationEvondos)
	neutralStations = neutralStations + 1
	--Tandon
	stationTandon = placeStation(random(30500,100000),random(200500,220000),"Tandon","Independent","Small Station")
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationTandon.comms_data.goods.autodoc = {quantity = 5, cost = math.random(85,94)}
	elseif stationGoodChoice == 2 then
		stationTandon.comms_data.goods.robotic = {quantity = 5, cost = math.random(62,75)}
	else
		stationTandon.comms_data.goods.android = {quantity = 5, cost = math.random(55,89)}
	end
	table.insert(stationList,stationTandon)
	neutralStations = neutralStations + 1
	--Ripley
	stationRipley = placeStation(random(70000,110000),random(180500,199500),"Ripley","Independent","Small Station")
	stationRipley.comms_data.trade.food = random(1,100) < 17
	stationRipley.comms_data.trade.medicine = true
	table.insert(stationList,stationRipley)
	neutralStations = neutralStations + 1
	--Okun
	stationOkun = placeStation(random(80500,100000),random(120000,179500),"Okun","Independent","Small Station")
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationOkun.comms_data.goods.optic = {quantity = 5, cost = math.random(52,65)}
	elseif stationGoodChoice == 2 then
		stationOkun.comms_data.goods.filament = {quantity = 5, cost = math.random(55,67)}
	else
		stationOkun.comms_data.goods.lifter = {quantity = 5, cost = math.random(48,69)}
	end
	table.insert(stationList,stationOkun)
	neutralStations = neutralStations + 1
	--Prada
	stationPrada = placeStation(random(110000,120000),random(60000,100000),"Prada","Independent","Small Station")
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationPrada.comms_data.goods.luxury = {quantity = 5, cost = math.random(69,75)}
	elseif stationGoodChoice == 2 then
		stationPrada.comms_data.goods.cobalt = {quantity = 5, cost = math.random(55,67)}
	else
		stationPrada.comms_data.goods.dilithium = {quantity = 5, cost = math.random(61,69)}
	end	
	table.insert(stationList,stationPrada)
	neutralStations = neutralStations + 1
	--Broeck
	stationBroeck = placeStation(random(130000,149500),random(60000,100000),"Broeck","Independent","Small Station")
	stationBroeck.comms_data.trade.medicine = random(1,100) < 53
	stationBroeck.comms_data.trade.food = random(1,100) < 14
	table.insert(stationList,stationBroeck)
	neutralStations = neutralStations + 1
	--Panduit
	stationPanduit = placeStation(random(150500,200000),random(50500,70000),"Panduit","Independent","Small Station")
	stationPanduit.comms_data.trade.medicine = random(1,100) < 33
	stationPanduit.comms_data.trade.food = random(1,100) < 27
	table.insert(stationList,stationPanduit)
	neutralStations = neutralStations + 1
	--Research-19
	stationResearch19 = placeStation(random(100000,170000),random(-9500,49500),"Research-19","Independent","Small Station")
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationResearch19.comms_data.goods.transporter = {quantity = 5, cost = math.random(85,94)}
	elseif stationGoodChoice == 2 then
		stationResearch19.comms_data.goods.sensor = {quantity = 5, cost = math.random(62,75)}
	else
		stationResearch19.comms_data.goods.communication = {quantity = 5, cost = math.random(55,89)}
	end
	table.insert(stationList,stationResearch19)
	neutralStations = neutralStations + 1
	--Grasberg
	stationGrasberg = placeStation(random(100000,149500),random(-60000,-20000),"Grasberg","Independent","Small Station")
	local grasbergGoods = random(1,100)
	if grasbergGoods < 20 then
		stationGrasberg.comms_data.goods.gold = {quantity = 5, cost = 25}
		stationGrasberg.comms_data.goods.cobalt = {quantity = 4, cost = 50}
	elseif grasbergGoods < 40 then
		stationGrasberg.comms_data.goods.gold = {quantity = 5, cost = 25}
	elseif grasbergGoods < 60 then
		stationGrasberg.comms_data.goods.cobalt = {quantity = 4, cost = 50}
	else
		stationGrasberg.comms_data.goods.nickel = {quantity = 5, cost = 47}
	end
	table.insert(stationList,stationGrasberg)
	neutralStations = neutralStations + 1
	--Impala
	stationImpala = placeStation(random(150500,190000),random(-50000,-10500),"Impala","Independent","Small Station")
	local impalaGoods = random(1,100)
	if impalaGoods < 20 then
		stationImpala.comms_data.goods.gold = {quantity = 5, cost = 25}
		stationImpala.comms_data.goods.cobalt = {quantity = 4, cost = 50}
	elseif impalaGoods < 40 then
		stationImpala.comms_data.goods.gold = {quantity = 5, cost = 25}
	elseif impalaGoods < 60 then
		stationImpala.comms_data.goods.cobalt = {quantity = 4, cost = 50}
	else
		stationImpala.comms_data.goods.tritanium = {quantity = 5, cost = 42}
	end
	table.insert(stationList,stationImpala)
	neutralStations = neutralStations + 1
	
	if random(1,100) < 50 then
		stationGrasberg.comms_data.goods.luxury = {quantity = 5, cost = 70}
		stationGrasberg.comms_data.goods.platinum = {quantity = 5, cost = 25}
		stationImpala.comms_data.goods.dilithium = {quantity = 4, cost = 50}
	else
		stationImpala.comms_data.goods.luxury = {quantity = 5, cost = 70}
		stationImpala.comms_data.goods.platinum = {quantity = 5, cost = 25}
		stationGrasberg.comms_data.goods.dilithium = {quantity = 4, cost = 50}
	end
	
	--Cyrus
	stationCyrus = placeStation(random(-20000,35000),random(-60000,-50500),"Cyrus","Independent","Small Station")
	stationCyrus.comms_data.trade.medicine = random(1,100) < 34
	stationCyrus.comms_data.trade.food = random(1,100) < 13
	table.insert(stationList,stationCyrus)
	neutralStations = neutralStations + 1
	--Hossam
	stationHossam = placeStation(random(-80000,-60000),random(-50000,19500),"Hossam","Independent","Small Station")
	table.insert(stationList,stationHossam)
	neutralStations = neutralStations + 1
	--Miller
	stationMiller = placeStation(random(-80000,-50000),random(20500,39500),"Miller","Independent","Small Station")
	table.insert(stationList,stationMiller)
	neutralStations = neutralStations + 1
	--O'Brien
	stationOBrien = placeStation(random(-90000,-50500),random(40500,70000),"O'Brien","Independent","Small Station")
	table.insert(stationList,stationOBrien)
	neutralStations = neutralStations + 1
	--Malthus
	stationMalthus = placeStation(random(-49500,-20500),random(45000,80000),"Malthus","Independent","Small Station")
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationMalthus.comms_data.goods.luxury = {quantity = 5, cost = math.random(68,81)}
	elseif stationGoodChoice == 2 then
		stationMalthus.comms_data.goods.gold = {quantity = 5, cost = math.random(61,77)}
	else
		stationMalthus.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,79)}
	end
	table.insert(stationList,stationMalthus)
	neutralStations = neutralStations + 1
	--Jabba
	stationJabba = placeStation(random(20000,29500),random(160500,180000),"Jabba","Independent","Small Station")
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationJabba.comms_data.goods.circuit = {quantity = 5, cost = math.random(68,81)}
	elseif stationGoodChoice == 2 then
		stationJabba.comms_data.goods.gold = {quantity = 5, cost = math.random(61,77)}
	else
		stationJabba.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,79)}
	end
	table.insert(stationList,stationJabba)
	neutralStations = neutralStations + 1
	--Heyes
	stationHeyes = placeStation(random(30500,70000),random(160500,170000),"Heyes","Independent","Small Station")
	table.insert(stationList,stationHeyes)
	neutralStations = neutralStations + 1
	--Nexus-6
	stationNexus6 = placeStation(random(40500,60000),random(123000,139500),"Nexus-6","Independent","Small Station")
	table.insert(stationList,stationNexus6)
	neutralStations = neutralStations + 1
	--Maiman
	stationMaiman = placeStation(random(30500,39500),random(120000,139500),"Maiman","Independent","Small Station")
	table.insert(stationList,stationMaiman)
	neutralStations = neutralStations + 1
	--Shawyer
	stationShawyer = placeStation(random(15000,29500),random(125000,139500),"Shawyer","Independent","Small Station")
	stationShawyer.comms_data.trade.medicine = true
	table.insert(stationList,stationShawyer)
	neutralStations = neutralStations + 1
	--Owen
	stationOwen = placeStation(random(140500,150000),random(30500,40000),"Owen","Independent","Small Station")
	stationOwen.comms_data.trade.food = true
	table.insert(stationList,stationOwen)
	neutralStations = neutralStations + 1
	--Lipkin
	stationLipkin = placeStation(random(140500,155000),random(20500,29500),"Lipkin","Independent","Small Station")
	stationLipkin.comms_data.trade.food = true
	table.insert(stationList,stationLipkin)
	neutralStations = neutralStations + 1
	--Barclay
	stationBarclay = placeStation(random(140500,155000),random(5000,19500),"Barclay","Independent","Small Station")
	stationBarclay.comms_data.trade.medicine = true
	table.insert(stationList,stationBarclay)
	neutralStations = neutralStations + 1
	--Erickson
	stationErickson = placeStation(random(110000,119500),random(20500,40000),"Erickson","Independent","Small Station")
	stationErickson.comms_data.trade.medicine = true
	stationErickson.comms_data.trade.food = true
	table.insert(stationList,stationErickson)
	neutralStations = neutralStations + 1
	--Hayden
	stationHayden = placeStation(random(-15000,10000),random(-40000,-29500),"Hayden","Independent","Small Station")
	table.insert(stationList,stationHayden)
	neutralStations = neutralStations + 1
	--Skandar
	stationSkandar = placeStation(random(-35000,-10500),random(500,20000),"Skandar","Independent","Small Station")
	table.insert(stationList,stationSkandar)
	neutralStations = neutralStations + 1
	--Tokra
	stationTokra = placeStation(random(-25000,-10500),random(-10000,-500),"Tokra","Independent","Small Station")
	local whatTrade = random(1,100)
	if whatTrade < 33 then
		stationTokra.comms_data.trade.food = true
	elseif whatTrade > 66 then
		stationTokra.comms_data.trade.medicine = true
	else
		stationTokra.comms_data.trade.luxury = true
	end
	table.insert(stationList,stationTokra)
	neutralStations = neutralStations + 1
	--Rubis
	stationRubis = placeStation(random(10500,35000),random(10500,25000),"Rubis","Independent","Small Station")
	table.insert(stationList,stationRubis)
	neutralStations = neutralStations + 1
	--Olympus
	stationOlympus = placeStation(random(10500,35000),random(-19500,9500),"Olympus","Independent","Small Station")
	stationOlympus.comms_data.trade.medicine = true
	stationOlympus.comms_data.trade.food = true
	table.insert(stationList,stationOlympus)
	neutralStations = neutralStations + 1
	--Archimedes
	stationArchimedes = placeStation(random(-29500,-20500),random(-29500,-20500),"Archimedes","Independent","Small Station")
	stationArchimedes.comms_data.trade.food = true
	table.insert(stationList,stationArchimedes)
	neutralStations = neutralStations + 1
	--Toohie
	stationToohie = placeStation(random(-9500,-500),random(-19500,40000),"Toohie","Independent","Small Station")
	stationToohie.comms_data.trade.medicine = random(1,100) < 25
	table.insert(stationList,stationToohie)
	neutralStations = neutralStations + 1
	--Krik
	psx = random(-19500,-10500)
	psy = random(70500,179500)
	stationKrik = placeStation(psx,psy,"Krik","Independent","Small Station")
	local posAxisKrik = random(0,360)
	local posKrik = random(30000,80000)
	local negKrik = random(20000,60000)
	local spreadKrik = random(5000,8000)
	local negAxisKrik = posAxisKrik + 180
	local xPosAngleKrik, yPosAngleKrik = vectorFromAngle(posAxisKrik, posKrik)
	local posKrikEnd = random(40,90)
	createRandomAsteroidAlongArc(30+posKrikEnd, psx+xPosAngleKrik, psy+yPosAngleKrik, posKrik, negAxisKrik, negAxisKrik+posKrikEnd, spreadKrik)
	local xNegAngleKrik, yNegAngleKrik = vectorFromAngle(negAxisKrik, negKrik)
	local negKrikEnd = random(30,60)
	createRandomAsteroidAlongArc(30+negKrikEnd, psx+xNegAngleKrik, psy+yNegAngleKrik, negKrik, posAxisKrik, posAxisKrik+negKrikEnd, spreadKrik)
	local krikGoods = random(1,100)
	if krikGoods < 10 then
		stationKrik.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		stationKrik.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
		stationKrik.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
		stationKrik.comms_data.general = "We've been able to extract platinum, tritanium and dilithium from these rocks. Come get some if you want some"
	elseif krikGoods < 20 then
		stationKrik.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		stationKrik.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
		stationKrik.comms_data.general = "We've been able to extract platinum and tritanium from these rocks. Come get some if you want some"
	elseif krikGoods < 30 then
		stationKrik.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		stationKrik.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
		stationKrik.comms_data.general = "We've been able to extract platinum and dilithium from these rocks. Come get some if you want some"
	elseif krikGoods < 40 then
		stationKrik.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
		stationKrik.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
		stationKrik.comms_data.general = "We've been able to extract tritanium and dilithium from these rocks. Come get some if you want some"
	elseif krikGoods < 50 then
		stationKrik.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
		stationKrik.comms_data.general = "We've been able to extract dilithium from these rocks. Come get some if you want some"
	elseif krikGoods < 60 then
		stationKrik.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		stationKrik.comms_data.general = "We've been able to extract platinum from these rocks. Come get some if you want some"
	elseif krikGoods < 70 then
		stationKrik.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
		stationKrik.comms_data.general = "We've been able to extract tritanium from these rocks. Come get some if you want some"
	elseif krikGoods < 80 then
		stationKrik.comms_data.goods.cobalt = {quantity = 5, cost = math.random(55,65)}
		stationKrik.comms_data.general = "We've been able to extract cobalt from these rocks. Come get some if you want some"
	else
		stationKrik.comms_data.goods.cobalt = {quantity = 5, cost = math.random(55,65)}
		stationKrik.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
		stationKrik.comms_data.general = "We've been able to extract cobalt and dilithium from these rocks. Come get some if you want some"
	end
	table.insert(stationList,stationKrik)
	neutralStations = neutralStations + 1
	--Krak
	psx = random(-19500,79500)
	psy = random(55500,69500)
	stationKrak = placeStation(psx,psy,"Krak","Independent","Small Station")
	local posAxisKrak = random(0,360)
	local posKrak = random(10000,60000)
	local negKrak = random(10000,60000)
	local spreadKrak = random(4000,7000)
	local negAxisKrak = posAxisKrak + 180
	local xPosAngleKrak, yPosAngleKrak = vectorFromAngle(posAxisKrak, posKrak)
	local posKrakEnd = random(30,70)
	createRandomAsteroidAlongArc(30+posKrakEnd, psx+xPosAngleKrak, psy+yPosAngleKrak, posKrak, negAxisKrak, negAxisKrak+posKrakEnd, spreadKrak)
	local xNegAngleKrak, yNegAngleKrak = vectorFromAngle(negAxisKrak, negKrak)
	local negKrakEnd = random(40,80)
	createRandomAsteroidAlongArc(30+negKrakEnd, psx+xNegAngleKrak, psy+yNegAngleKrak, negKrak, posAxisKrak, posAxisKrak+negKrakEnd, spreadKrak)
	local krakGoods = random(1,100)
	if krakGoods < 10 then
		stationKrak.comms_data.goods.platinum = {quantity = 5, cost = 70}
		stationKrak.comms_data.goods.tritanium = {quantity = 5, cost = 50}
		stationKrak.comms_data.goods.dilithium = {quantity = 5, cost = 52}
		stationKrak.comms_data.general = "We've been able to extract platinum, tritanium and dilithium from these rocks. Come get some if you want some"
	elseif krakGoods < 20 then
		stationKrak.comms_data.goods.platinum = {quantity = 5, cost = 70}
		stationKrak.comms_data.goods.tritanium = {quantity = 5, cost = 50}
		stationKrak.comms_data.general = "We've been able to extract platinum and tritanium from these rocks. Come get some if you want some"
	elseif krakGoods < 30 then
		stationKrak.comms_data.goods.platinum = {quantity = 5, cost = 70}
		stationKrak.comms_data.goods.dilithium = {quantity = 5, cost = 52}
		stationKrak.comms_data.general = "We've been able to extract platinum and dilithium from these rocks. Come get some if you want some"
	elseif krakGoods < 40 then
		stationKrak.comms_data.goods.tritanium = {quantity = 5, cost = 50}
		stationKrak.comms_data.goods.dilithium = {quantity = 5, cost = 52}
		stationKrak.comms_data.general = "We've been able to extract tritanium and dilithium from these rocks. Come get some if you want some"
	elseif krakGoods < 50 then
		stationKrak.comms_data.goods.dilithium = {quantity = 5, cost = 52}
		stationKrak.comms_data.general = "We've been able to extract dilithium from these rocks. Come get some if you want some"
	elseif krakGoods < 60 then
		stationKrak.comms_data.goods.platinum = {quantity = 5, cost = 70}
		stationKrak.comms_data.general = "We've been able to extract platinum from these rocks. Come get some if you want some"
	elseif krakGoods < 70 then
		stationKrak.comms_data.goods.tritanium = {quantity = 5, cost = 50}
		stationKrak.comms_data.general = "We've been able to extract tritanium from these rocks. Come get some if you want some"
	elseif krakGoods < 80 then
		stationKrak.comms_data.goods.gold = {quantity = 5, cost = 50}
		stationKrak.comms_data.goods.tritanium = {quantity = 5, cost = 50}
		stationKrak.comms_data.general = "We've been able to extract tritanium and gold from these rocks. Come get some if you want some"
	elseif krakGoods < 90 then
		stationKrak.comms_data.goods.gold = {quantity = 5, cost = 50}
		stationKrak.comms_data.goods.dilithium = {quantity = 5, cost = 52}
		stationKrak.comms_data.general = "We've been able to extract gold and dilithium from these rocks. Come get some if you want some"
	else
		stationKrak.comms_data.goods.gold = {quantity = 5, cost = 50}
		stationKrak.comms_data.general = "We've been able to extract gold from these rocks. Come get some if you want some"
	end
	table.insert(stationList,stationKrak)
	neutralStations = neutralStations + 1
	--Kruk
	psx = random(80000,90000)
	psy = random(-70000,70000)
	stationKruk = placeStation(psx,psy,"Kruk","Independent","Small Station")
	local posAxisKruk = random(0,360)
	local posKruk = random(10000,60000)
	local negKruk = random(10000,60000)
	local spreadKruk = random(4000,7000)
	local negAxisKruk = posAxisKruk + 180
	local xPosAngleKruk, yPosAngleKruk = vectorFromAngle(posAxisKruk, posKruk)
	local posKrukEnd = random(30,70)
	createRandomAsteroidAlongArc(30+posKrukEnd, psx+xPosAngleKruk, psy+yPosAngleKruk, posKruk, negAxisKruk, negAxisKruk+posKrukEnd, spreadKruk)
	local xNegAngleKruk, yNegAngleKruk = vectorFromAngle(negAxisKruk, negKruk)
	local negKrukEnd = random(40,80)
	createRandomAsteroidAlongArc(30+negKrukEnd, psx+xNegAngleKruk, psy+yNegAngleKruk, negKruk, posAxisKruk, posAxisKruk+negKrukEnd, spreadKruk)
	local krukGoods = random(1,100)
	if krukGoods < 10 then
		stationKruk.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		stationKruk.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
		stationKruk.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
		stationKruk.comms_data.general = "We've been able to extract platinum, tritanium and dilithium from these rocks. Come get some if you want some"
	elseif krukGoods < 20 then
		stationKruk.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		stationKruk.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
		stationKruk.comms_data.general = "We've been able to extract platinum and tritanium from these rocks. Come get some if you want some"
	elseif krukGoods < 30 then
		stationKruk.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		stationKruk.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
		stationKruk.comms_data.general = "We've been able to extract platinum and dilithium from these rocks. Come get some if you want some"
	elseif krukGoods < 40 then
		stationKruk.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
		stationKruk.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
		stationKruk.comms_data.general = "We've been able to extract tritanium and dilithium from these rocks. Come get some if you want some"
	elseif krukGoods < 50 then
		stationKruk.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
		stationKruk.comms_data.general = "We've been able to extract dilithium from these rocks. Come get some if you want some"
	elseif krukGoods < 60 then
		stationKruk.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		stationKruk.comms_data.general = "We've been able to extract platinum from these rocks. Come get some if you want some"
	elseif krukGoods < 70 then
		stationKruk.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
		stationKruk.comms_data.general = "We've been able to extract tritanium from these rocks. Come get some if you want some"
	elseif krukGoods < 80 then
		stationKruk.comms_data.goods.gold = {quantity = 5, cost = math.random(45,55)}
		stationKruk.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
		stationKruk.comms_data.general = "We've been able to extract tritanium and gold from these rocks. Come get some if you want some"
	elseif krukGoods < 90 then
		stationKruk.comms_data.goods.gold = {quantity = 5, cost = math.random(45,55)}
		stationKruk.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
		stationKruk.comms_data.general = "We've been able to extract gold and dilithium from these rocks. Come get some if you want some"
	else
		stationKruk.comms_data.goods.gold = {quantity = 5, cost = math.random(45,55)}
		stationKruk.comms_data.general = "We've been able to extract gold from these rocks. Come get some if you want some"
	end
	table.insert(stationList,stationKruk)
	neutralStations = neutralStations + 1
	--Chatuchak
	stationChatuchak = placeStation(random(-29500,20000),random(-29500,-20500),"Chatuchak","Independent","Medium Station")
	table.insert(stationList,stationChatuchak)
	neutralStations = neutralStations + 1
	--Madison
	stationMadison = placeStation(random(110000,119500),random(0,19500),"Madison","Independent","Medium Station")
	table.insert(stationList,stationMadison)
	neutralStations = neutralStations + 1
--	Named nebulas	
	nebAx = (asimovx + armstrongx)/2
	nebAy = (asimovy + armstrongy)/2
	nebA = Nebula():setPosition(nebAx,nebAy)
	nebMx = (asimovx + utopiaPlanitiax)/2
	nebMy = (asimovy + utopiaPlanitiay)/2
	nebM = Nebula():setPosition(nebMx,nebMy)
	if math.random(1,2) == 1 then
		neb1 = nebA
		neb1x = nebAx
		neb1y = nebAy
		neb2 = nebM
		neb2x = nebMx
		neb2y = nebMy
	else
		neb1 = nebM
		neb1x = nebMx
		neb1y = nebMy
		neb2 = nebA
		neb2x = nebAx
		neb2y = nebAy
	end	
end

----------------------------------------------
--	Transport ship generation and handling  --
----------------------------------------------
function randomNearStation(pool,nobj,partialStationList)
--pool = number of nearest stations to randomly choose from
--nobj = named object for comparison purposes
--partialStationList = list of stations to compare against
	local distanceStations = {}
	local rs = {}	--random station
	local ni		--near index
	local cs		--current station
	cs, rs[1] = nearStations(nobj,partialStationList)
	table.insert(distanceStations,cs)
	for ni=2,pool do
		cs, rs[ni] = nearStations(nobj,rs[ni-1])
		table.insert(distanceStations,cs)
	end
	randomlySelectedStation = distanceStations[math.random(1,pool)]
	return randomlySelectedStation
end
function nearStations(nobj, compareStationList)
--nobj = named object for comparison purposes (stations, players, etc)
--compareStationList = list of stations to compare against
	local remainingStations = {}
	local closestDistance = 9999999
	for ri, obj in ipairs(compareStationList) do
		if obj ~= nil then
			if obj:isValid() then
				if obj:getCallSign() ~= nobj:getCallSign() then
					table.insert(remainingStations,obj)
					local currentDistance = distance(nobj, obj)
					if currentDistance < closestDistance then
						closestObj = obj
						closestDistance = currentDistance
					end
				end
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
function transportPlot(delta)
	if transportSpawnDelay > 0 then
		transportSpawnDelay = transportSpawnDelay - delta
	end
	if transportSpawnDelay < 0 then
		transportSpawnDelay = delta + random(15,45) + missionLength*8
		transportCount = 0
		for tidx, obj in ipairs(transportList) do
			if obj:isValid() then
				if obj:isDocked(obj.target) then
					if obj.undock_delay > 0 then
						obj.undock_delay = obj.undock_delay - 1
					else
						obj.target = randomNearStation(5,obj,stationList)
						obj.undock_delay = irandom(1,4)
						obj:orderDock(obj.target)
					end
				end
				transportCount = transportCount + 1
			end
		end
		lastTransportCount = transportCount
		if transportCount < #transportList then
			tempTransportList = {}
			for _, obj in ipairs(transportList) do
				if obj:isValid() then
					table.insert(tempTransportList,obj)
				end
			end
			transportList = tempTransportList
		end
		if #transportList < #stationList then
			target = nil
			repeat
				candidate = stationList[math.random(1,#stationList)]
				if candidate:isValid() then
					target = candidate
				end
			until(target ~= nil)
			wfv = string.format("station chosen: %s",target:getCallSign())
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
			wfv = string.format("transport model: %s",name)
			obj = CpuShip():setTemplate(name):setFaction('Independent'):setCommsScript(""):setCommsFunction(commsShip)
			obj.target = target
			obj.undock_delay = irandom(1,4)
			rifl = math.floor(random(1,#goodsList))	-- random item from list
			goodsType = goodsList[rifl][1]
			if goodsType == nil then
				goodsType = "nickel"
			end
			rcoi = math.floor(random(30,90))	-- random cost of item
			goods[obj] = {{goodsType,1,rcoi}}
			obj:orderDock(obj.target)
			x, y = obj.target:getPosition()
			xd, yd = vectorFromAngle(random(0, 360), random(25000, 40000))
			obj:setPosition(x + xd, y + yd)
			obj:setCallSign(generateCallSign(nil,"Independent"))
			table.insert(transportList, obj)
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
            neutral = 2.5
        },
        max_weapon_refill_amount = {
            friend = 1.0,
            neutral = 0.5
        }
    })
    comms_data = comms_target.comms_data
	setPlayers()
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
function setOptionalOrders()
	optionalOrders = ""
	optionalOrdersPresent = false
	if plot2reminder ~= nil then
		optionalOrders = "\nOptional:\n" .. plot2reminder
		optionalOrdersPresent = true
	end
	if plot3reminder ~= nil then
		if optionalOrdersPresent then
			optionalOrders = optionalOrders .. "\n" .. plot3reminder
		else
			optionalOrders = "\nOptional:\n" .. plot3reminder
			optionalOrdersPresent = true
		end
	end
	if plot4reminder ~= nil then
		if optionalOrdersPresent then
			optionalOrders = optionalOrders .. "\n" .. plot4reminder
		else
			optionalOrders = "\nOptional:\n" .. plot4reminder
			optionalOrdersPresent = true
		end
	end
	if plot5reminder ~= nil then
		if optionalOrdersPresent then
			optionalOrders = optionalOrders .. "\n" .. plot5reminder
		else
			optionalOrders = "\nOptional:\n" .. plot5reminder
			optionalOrdersPresent = true
		end
	end
	if plot8reminder ~= nil then
		if optionalOrdersPresent then
			optionalOrders = optionalOrders .. "\n" .. plot8reminder
		else
			optionalOrders = "\nOptional:\n" .. plot8reminder
			optionalOrdersPresent = true
		end
	end
end
function handleDockedState()
	local ctd = comms_target.comms_data
    if comms_source:isFriendly(comms_target) then
    	if ctd.friendlyness > 66 then
    		oMsg = string.format("Greetings %s!\nHow may we help you today?",comms_source:getCallSign())
    	elseif ctd.friendlyness > 33 then
			oMsg = "Good day, officer!\nWhat can we do for you today?"
		else
			oMsg = "Hello, may I help you?"
		end
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
		if 	(ctd.weapon_available.Nuke   and comms_source:getWeaponStorageMax("Nuke") > 0)   or 
			(ctd.weapon_available.EMP    and comms_source:getWeaponStorageMax("EMP") > 0)    or 
			(ctd.weapon_available.Homing and comms_source:getWeaponStorageMax("Homing") > 0) or 
			(ctd.weapon_available.Mine   and comms_source:getWeaponStorageMax("Mine") > 0)   or 
			(ctd.weapon_available.HVLI   and comms_source:getWeaponStorageMax("HVLI") > 0)   then
			addCommsReply("I need ordnance restocked", function()
				local ctd = comms_target.comms_data
				setCommsMessage("What type of ordnance?")
				if comms_source:getWeaponStorageMax("Nuke") > 0 then
					if ctd.weapon_available.Nuke then
						if stationCommsDiagnostic then print("station has nukes available") end
						if math.random(1,10) <= 5 then
							nukePrompt = "Can you supply us with some nukes? ("
						else
							nukePrompt = "We really need some nukes ("
						end
						addCommsReply(nukePrompt .. getWeaponCost("Nuke") .. " rep each)", function()
							if stationCommsDiagnostic then print("going to handle weapon restock function") end
							handleWeaponRestock("Nuke")
						end)
					end	--end station has nuke available if branch
				end	--end player can accept nuke if branch
				if comms_source:getWeaponStorageMax("EMP") > 0 then
					if ctd.weapon_available.EMP then
						if math.random(1,10) <= 5 then
							empPrompt = "Please re-stock our EMP missiles. ("
						else
							empPrompt = "Got any EMPs? ("
						end
						addCommsReply(empPrompt .. getWeaponCost("EMP") .. " rep each)", function()
							handleWeaponRestock("EMP")
						end)
					end	--end station has EMP available if branch
				end	--end player can accept EMP if branch
				if comms_source:getWeaponStorageMax("Homing") > 0 then
					if ctd.weapon_available.Homing then
						if math.random(1,10) <= 5 then
							homePrompt = "Do you have spare homing missiles for us? ("
						else
							homePrompt = "Do you have extra homing missiles? ("
						end
						addCommsReply(homePrompt .. getWeaponCost("Homing") .. " rep each)", function()
							handleWeaponRestock("Homing")
						end)
					end	--end station has homing for player if branch
				end	--end player can accept homing if branch
				if comms_source:getWeaponStorageMax("Mine") > 0 then
					if ctd.weapon_available.Mine then
						if math.random(1,10) <= 5 then
							minePrompt = "We could use some mines. ("
						else
							minePrompt = "How about mines? ("
						end
						addCommsReply(minePrompt .. getWeaponCost("Mine") .. " rep each)", function()
							handleWeaponRestock("Mine")
						end)
					end	--end station has mine for player if branch
				end	--end player can accept mine if branch
				if comms_source:getWeaponStorageMax("HVLI") > 0 then
					if ctd.weapon_available.HVLI then
						if math.random(1,10) <= 5 then
							hvliPrompt = "What about HVLI? ("
						else
							hvliPrompt = "Could you provide HVLI? ("
						end
						addCommsReply(hvliPrompt .. getWeaponCost("HVLI") .. " rep each)", function()
							handleWeaponRestock("HVLI")
						end)
					end	--end station has HVLI for player if branch
				end	--end player can accept HVLI if branch
			end)	--end player requests secondary ordnance comms reply branch
		end
	end
	addCommsReply("I need information",function()
		setCommsMessage(string.format("What kind of information do you need, %s",comms_source:getCallSign()))
		if comms_source:isFriendly(comms_target) then
			addCommsReply("What are my current orders?", function()
				setOptionalOrders()
				ordMsg = primaryOrders .. secondaryOrders .. optionalOrders
				if playWithTimeLimit then
					ordMsg = ordMsg .. string.format("\n   %i Minutes remain in game",math.floor(gameTimeLimit/60))
				else
					if patrolComplete then
						ordMsg = ordMsg .. "\nPatrol mission complete"
					else
						legAverage = (comms_source.patrolLegAsimov + comms_source.patrolLegUtopiaPlanitia + comms_source.patrolLegArmstrong)/3
						ordMsg = ordMsg .. string.format("\n   patrol is %.2f percent complete",legAverage/patrolGoal*100)
						if comms_source.patrolLegArmstrong ~= comms_source.patrolLegAsimov or comms_source.patrolLegUtopiaPlanitia ~= comms_source.patrolLegArmstrong then
							if comms_source.patrolLegArmstrong == comms_source.patrolLegAsimov then
								if comms_source.patrolLegArmstrong > comms_source.patrolLegUtopiaPlanitia then
									ordMsg = ordMsg .. "\n   Least patrolled station: Utopia Panitia"
								else
									ordMsg = ordMsg .. "\n   Most patrolled station: Utopia Planitia"
								end
							elseif comms_source.patrolLegArmstrong == comms_source.patrolLegUtopiaPlanitia then
								if comms_source.patrolLegArmstrong > comms_source.patrolLegAsimov then
									ordMsg = ordMsg .. "\n   Least patrolled station: Asimov"
								else
									ordMsg = ordMsg .. "\n   Most patrolled station: Asimov"
								end
							else
								if comms_source.patrolLegAsimov > comms_source.patrolLegArmstrong then
									ordMsg = ordMsg .. "\n   Least patrolled station: Armstrong"
								else
									ordMsg = ordMsg .. "\n   Most patrolled station: Armstrong"
								end
							end
						end
					end
				end
				setCommsMessage(ordMsg)
				addCommsReply("Back", commsStation)
			end)
			if math.random(1,8) <= (6 - difficulty) then
				if comms_source:getRepairCrewCount() < comms_source.maxRepairCrew then
					hireCost = math.random(30,60)
				else
					hireCost = math.random(45,90)
				end
				addCommsReply(string.format("Recruit repair crew member for %i reputation",hireCost), function()
					if not comms_source:takeReputationPoints(hireCost) then
						setCommsMessage("Insufficient reputation")
					else
						comms_source:setRepairCrewCount(comms_source:getRepairCrewCount() + 1)
						setCommsMessage("Repair crew member hired")
					end
					addCommsReply("Back", commsStation)
				end)
			end
			if random(1,10) <= (6 - difficulty) then
				if comms_target == stationAsimov or comms_target == stationUtopiaPlanitia or comms_target == stationArmstrong then
					if comms_target.telemetry == nil then
						addCommsReply(string.format("Establish defensive telemetry link (%i rep)",10*difficulty),function()
							if comms_source:takeReputationPoints(10*difficulty) then
								comms_target.telemetry = true
								setCommsMessage("Automated telemetry for shields and hull established.\nDamage summary should appear on Relay when damage taken")
							else
								setCommsMessage("Insufficient reputation")
							end
							addCommsReply("Back", commsStation)
						end)
					end
				end
			end
		else
			if math.random(1,8) <= (6 - difficulty) then
				if comms_source:getRepairCrewCount() < comms_source.maxRepairCrew then
					hireCost = math.random(45,90)
				else
					hireCost = math.random(60,120)
				end
				addCommsReply(string.format("Recruit repair crew member for %i reputation",hireCost), function()
					if not comms_source:takeReputationPoints(hireCost) then
						setCommsMessage("Insufficient reputation")
					else
						comms_source:setRepairCrewCount(comms_source:getRepairCrewCount() + 1)
						setCommsMessage("Repair crew member hired")
					end
				end)
			end
		end
		local has_gossip = random(1,100) < (100 - (30 * (difficulty - .5)))
		if (ctd.general ~= nil and ctd.general ~= "") or 
			(ctd.history ~= nil and ctd.history ~= "") or 
			(comms_source:isFriendly(comms_target) and ctd.gossip ~= nil and has_gossip) then
			addCommsReply("Tell me more about your station", function()
				setCommsMessage("What would you like to know?")
				addCommsReply("General information", function()
					setCommsMessage(ctd.general)
					addCommsReply("Back", commsStation)
				end)
				if ctd.history ~= nil then
					addCommsReply("Station history", function()
						setCommsMessage(ctd.history)
						addCommsReply("Back", commsStation)
					end)
				end
				if comms_source:isFriendly(comms_target) then
					if ctd.gossip ~= nil then
						if has_gossip then
							addCommsReply("Gossip", function()
								setCommsMessage(ctd.gossip)
								addCommsReply("Back", commsStation)
							end)
						end
					end
				end
			end)	--end station info comms reply branch
		end
		addCommsReply("Where can I find particular goods?", function()
			local ctd = comms_target.comms_data
			gkMsg = "Friendly stations often have food or medicine or both. Neutral stations may trade their goods for food, medicine or luxury."
			if ctd.goodsKnowledge == nil then
				ctd.goodsKnowledge = {}
				local knowledgeCount = 0
				local knowledgeMax = 10
				for i=1,#stationList do
					local station = stationList[i]
					if station ~= nil and station:isValid() then
						local brainCheckChance = 60
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
					setCommsMessage(string.format("Station %s in sector %s has %s for %i reputation",stationName,sectorName,goodName,goodCost))
					addCommsReply("Back", commsStation)
				end)
			end
			if goodsKnowledgeCount > 0 then
				gkMsg = gkMsg .. "\n\nWhat goods are you interested in?\nI've heard about these:"
			else
				gkMsg = gkMsg .. " Beyond that, I have no knowledge of specific stations"
			end
			setCommsMessage(gkMsg)
			addCommsReply("Back", commsStation)
		end)
		addCommsReply("Back", commsStation)
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
		setCommsMessage(string.format("%s\n\nYou can examine the brochure on the coffee table, talk to the apprentice cartographer or talk to the master cartographer",comms_target.cartographer_description))
		addCommsReply("What's the difference between the apprentice and the master?", function()
			setCommsMessage("The clerk responds in a bored voice, 'The apprentice knows the local area and is learning the broader area. The master knows the local and the broader area but can't be bothered with the local area'")
			addCommsReply("Back",commsStation)
		end)
		addCommsReply(string.format("Examine brochure (%i rep)",getCartographerCost()),function()
			if comms_source:takeReputationPoints(1) then
				setCommsMessage("The brochure has a list of nearby stations and has a list of goods nearby")
				addCommsReply(string.format("Examine station list (%i rep)",getCartographerCost()), function()
					if comms_source:takeReputationPoints(1) then
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
					else
						setCommsMessage("Insufficient reputation")
					end
					addCommsReply("Back",commsStation)
				end)
				addCommsReply(string.format("Examine goods list (%i rep)",getCartographerCost()), function()
					if comms_source:takeReputationPoints(1) then
						local brochure_goods = ""
						local sx, sy = comms_target:getPosition()
						local nearby_objects = getObjectsInRadius(sx,sy,30000)
						for _, obj in ipairs(nearby_objects) do
							if obj.typeName == "SpaceStation" then
								if not obj:isEnemy(comms_target) then
									if obj.comms_data.goods ~= nil then
										for good, good_data in pairs(obj.comms_data.goods) do
											if brochure_goods == "" then
												brochure_goods = string.format("Good, quantity, cost, station:\n%s, %i, %i, %s",good,good_data["quantity"],good_data["cost"],obj:getCallSign())
											else
												brochure_goods = string.format("%s\n%s, %i, %i, %s",brochure_goods,good,good_data["quantity"],good_data["cost"],obj:getCallSign())
											end
										end
									end
								end
							end
						end
						setCommsMessage(brochure_goods)
					else
						setCommsMessage("Insufficient reputation")
					end
					addCommsReply("Back",commsStation)
				end)
			else
				setCommsMessage("Insufficient reputation")
			end
			addCommsReply("Back",commsStation)
		end)
		addCommsReply(string.format("Talk to apprentice cartographer (%i rep)",getCartographerCost("apprentice")), function()
			if comms_source:takeReputationPoints(1) then
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
									if obj.comms_data.goods ~= nil then
										station_details = string.format("%s\nGood, quantity, cost",station_details)
										for good, good_data in pairs(obj.comms_data.goods) do
											station_details = string.format("%s\n   %s, %i, %i",station_details,good,good_data["quantity"],good_data["cost"])
										end
									end
									if obj.comms_data.general_information ~= nil then
										station_details = string.format("%s\nGeneral Information:\n   %s",station_details,obj.comms_data.general_information)
									end
									if obj.comms_data.history ~= nil then
										station_details = string.format("%s\nHistory:\n   %s",station_details,obj.comms_data.history)
									end
									if obj.comms_data.gossip ~= nil then
										station_details = string.format("%s\nGossip:\n   %s",station_details,obj.comms_data.gossip)
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
							local station_details = string.format("%s %s %s",obj:getSectorName(),obj:getFaction(),obj:getCallSign())
							if obj.comms_data.goods ~= nil then
								station_details = string.format("%s\nGood, quantity, cost",station_details)
								for good, good_data in pairs(obj.comms_data.goods) do
									station_details = string.format("%s\n   %s, %i, %i",station_details,good,good_data["quantity"],good_data["cost"])
								end
							end
							if obj.comms_data.general_information ~= nil then
								station_details = string.format("%s\nGeneral Information:\n   %s",station_details,obj.comms_data.general_information)
							end
							if obj.comms_data.history ~= nil then
								station_details = string.format("%s\nHistory:\n   %s",station_details,obj.comms_data.history)
							end
							if obj.comms_data.gossip ~= nil then
								station_details = string.format("%s\nGossip:\n   %s",station_details,obj.comms_data.gossip)
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
			else
				setCommsMessage("Insufficient reputation")
			end
			addCommsReply("Back",commsStation)
		end)
		addCommsReply(string.format("Talk to master cartographer (%i rep)",getCartographerCost("master")), function()
			if comms_source:getWaypointCount() >= 9 then
				setCommsMessage("The clerk clears her throat:\n\nMy indicators show you have zero available waypoints. To get the most from the master cartographer, you should delete one or more so that he can update your systems appropriately.\n\nI just want you to get the maximum benefit for the time you spend with him")
				addCommsReply("Continue to Master Cartographer", masterCartographer)
			else
				masterCartographer()
			end
			addCommsReply("Back",commsStation)
		end)
		addCommsReply("Back",commsStation)
	end)
	local goodCount = 0
	for good, goodData in pairs(ctd.goods) do
		goodCount = goodCount + 1
	end
	if goodCount > 0 then
		addCommsReply("Buy, sell, trade", function()
			local ctd = comms_target.comms_data
			local goodsReport = string.format("Station %s:\nGoods or components available for sale: quantity, cost in reputation\n",comms_target:getCallSign())
			for good, goodData in pairs(ctd.goods) do
				goodsReport = goodsReport .. string.format("     %s: %i, %i\n",good,goodData["quantity"],goodData["cost"])
			end
			if ctd.buy ~= nil then
				goodsReport = goodsReport .. "Goods or components station will buy: price in reputation\n"
				for good, price in pairs(ctd.buy) do
					goodsReport = goodsReport .. string.format("     %s: %i\n",good,price)
				end
			end
			goodsReport = goodsReport .. string.format("Current cargo aboard %s:\n",comms_source:getCallSign())
			local cargoHoldEmpty = true
			local player_good_count = 0
			if comms_source.goods ~= nil then
				for good, goodQuantity in pairs(comms_source.goods) do
					player_good_count = player_good_count + 1
					goodsReport = goodsReport .. string.format("     %s: %i\n",good,goodQuantity)
				end
			end
			if player_good_count < 1 then
				goodsReport = goodsReport .. "     Empty\n"
			end
			goodsReport = goodsReport .. string.format("Available Space: %i, Available Reputation: %i\n",comms_source.cargo,math.floor(comms_source:getReputationPoints()))
			setCommsMessage(goodsReport)
			for good, goodData in pairs(ctd.goods) do
				addCommsReply(string.format("Buy one %s for %i reputation",good,goodData["cost"]), function()
					local goodTransactionMessage = string.format("Type: %s, Quantity: %i, Rep: %i",good,goodData["quantity"],goodData["cost"])
					if comms_source.cargo < 1 then
						goodTransactionMessage = goodTransactionMessage .. "\nInsufficient cargo space for purchase"
					elseif goodData["cost"] > math.floor(comms_source:getReputationPoints()) then
						goodTransactionMessage = goodTransactionMessage .. "\nInsufficient reputation for purchase"
					elseif goodData["quantity"] < 1 then
						goodTransactionMessage = goodTransactionMessage .. "\nInsufficient station inventory"
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
							goodTransactionMessage = goodTransactionMessage .. "\npurchased"
						else
							goodTransactionMessage = goodTransactionMessage .. "\nInsufficient reputation for purchase"
						end
					end
					setCommsMessage(goodTransactionMessage)
					addCommsReply("Back", commsStation)
				end)
			end
			if ctd.buy ~= nil then
				for good, price in pairs(ctd.buy) do
					if comms_source.goods ~= nil and comms_source.goods[good] ~= nil and comms_source.goods[good] > 0 then
						addCommsReply(string.format("Sell one %s for %i reputation",good,price), function()
							local goodTransactionMessage = string.format("Type: %s,  Reputation price: %i",good,price)
							comms_source.goods[good] = comms_source.goods[good] - 1
							comms_source:addReputationPoints(price)
							goodTransactionMessage = goodTransactionMessage .. "\nOne sold"
							comms_source.cargo = comms_source.cargo + 1
							setCommsMessage(goodTransactionMessage)
							addCommsReply("Back", commsStation)
						end)
					end
				end
			end
			if ctd.trade.food and comms_source.goods ~= nil and comms_source.goods["food"] ~= nil and comms_source.goods["food"] > 0 then
				for good, goodData in pairs(ctd.goods) do
					addCommsReply(string.format("Trade food for %s",good), function()
						local goodTransactionMessage = string.format("Type: %s,  Quantity: %i",good,goodData["quantity"])
						if goodData["quantity"] < 1 then
							goodTransactionMessage = goodTransactionMessage .. "\nInsufficient station inventory"
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
							goodTransactionMessage = goodTransactionMessage .. "\nTraded"
						end
						setCommsMessage(goodTransactionMessage)
						addCommsReply("Back", commsStation)
					end)
				end
			end
			if ctd.trade.medicine and comms_source.goods ~= nil and comms_source.goods["medicine"] ~= nil and comms_source.goods["medicine"] > 0 then
				for good, goodData in pairs(ctd.goods) do
					addCommsReply(string.format("Trade medicine for %s",good), function()
						local goodTransactionMessage = string.format("Type: %s,  Quantity: %i",good,goodData["quantity"])
						if goodData["quantity"] < 1 then
							goodTransactionMessage = goodTransactionMessage .. "\nInsufficient station inventory"
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
							goodTransactionMessage = goodTransactionMessage .. "\nTraded"
						end
						setCommsMessage(goodTransactionMessage)
						addCommsReply("Back", commsStation)
					end)
				end
			end
			if ctd.trade.luxury and comms_source.goods ~= nil and comms_source.goods["luxury"] ~= nil and comms_source.goods["luxury"] > 0 then
				for good, goodData in pairs(ctd.goods) do
					addCommsReply(string.format("Trade luxury for %s",good), function()
						local goodTransactionMessage = string.format("Type: %s,  Quantity: %i",good,goodData["quantity"])
						if goodData[quantity] < 1 then
							goodTransactionMessage = goodTransactionMessage .. "\nInsufficient station inventory"
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
							goodTransactionMessage = goodTransactionMessage .. "\nTraded"
						end
						setCommsMessage(goodTransactionMessage)
						addCommsReply("Back", commsStation)
					end)
				end
			end
			addCommsReply("Back", commsStation)
		end)
		local player_good_count = 0
		if comms_source.goods ~= nil then
			for good, goodQuantity in pairs(comms_source.goods) do
				player_good_count = player_good_count + 1
			end
		end
		if player_good_count > 0 then
			addCommsReply("Jettison cargo", function()
				setCommsMessage(string.format("Available space: %i\nWhat would you like to jettison?",comms_source.cargo))
				for good, good_quantity in pairs(comms_source.goods) do
					if good_quantity > 0 then
						addCommsReply(good, function()
							comms_source.goods[good] = comms_source.goods[good] - 1
							comms_source.cargo = comms_source.cargo + 1
							setCommsMessage(string.format("One %s jettisoned",good))
							addCommsReply("Back", commsStation)
						end)
					end
				end
				addCommsReply("Back", commsStation)
			end)
		end
		addCommsReply("No tutorial covered goods or cargo. Explain", function()
			setCommsMessage("Different types of cargo or goods may be obtained from stations, freighters or other sources. They go by one word descriptions such as dilithium, optic, warp, etc. Certain mission goals may require a particular type or types of cargo. Each player ship differs in cargo carrying capacity. Goods may be obtained by spending reputation points or by trading other types of cargo (typically food, medicine or luxury)")
			addCommsReply("Back", commsStation)
		end)
	end
	if comms_target:getCallSign() == "Utopia Planitia" and (minerUpgrade or nabbitUpgrade or lisbonUpgrade or artAnchorUpgrade or addTubeUpgrade) then
		addCommsReply("Check maintenance bay for ship upgrade", function()
			setCommsMessage(string.format("Greetings %s,\nWelcome to the ship maintenance bay of %s. What can we do for you?",comms_source:getCallSign(),comms_target:getCallSign()))
			if minerUpgrade then
				addCommsReply("Upgrade beam weapons with Joshua Kojak's research", function()
					if comms_source.kojakUpgrade then
						setCommsMessage("You already have the upgrade.")
					else
						if comms_source:getBeamWeaponRange(0) < 1 then
							setCommsMessage("Your ship type does not support a beam weapon upgrade.")
						else
							if missionLength >= 3 then
								if comms_source.kojakPart == nil then
									kojakChoice = math.random(1,5)
									if kojakChoice == 1 then
										comms_source.kojakPart = "dilithium"
									elseif kojakChoice == 2 then
										comms_source.kojakPart = "beam"
									elseif kojakChoice == 3 then
										comms_source.kojakPart = "circuit"
									elseif kojakChoice == 4 then
										comms_source.kojakPart = "software"
									else
										comms_source.kojakPart = "tritanium"
									end
								end
								local kojakPartQuantity = 0
								if comms_source.goods ~= nil and comms_source.goods[comms_source.kojakPart] ~= nil and comms_source.goods[comms_source.kojakPart] > 0 then
									kojakPartQuantity = comms_source.goods[comms_source.kojakPart]
								end
								if kojakPartQuantity > 0 then
									kojakBeamUpgrade()
									comms_source.goods[comms_source.kojakPart] = comms_source.goods[comms_source.kojakPart] - 1
									comms_source.cargo = comms_source.cargo + 1
									comms_source.kojakUpgrade = true
									setCommsMessage(string.format("Thanks for the %s. Your beam weapons now have improved range, cycle time and damage.",comms_source.kojakPart))
								else
									setCommsMessage(string.format("We find ourselves short of %s. Please bring us some of that kind of cargo and we can upgrade your beams",comms_source.kojakPart))
								end
							else
								kojakBeamUpgrade()
								setCommsMessage("Your beam weapons now have improved range, cycle time and damage.")
								comms_source.kojakUpgrade = true
							end
						end
					end
					addCommsReply("Back", commsStation)
				end)
			end
			if nabbitUpgrade then
				addCommsReply("Upgrade impulse engines with Dan McNabbit's tuning parameters", function()
					if comms_source.nabbitUpgrade then
						setCommsMessage("You already have the upgrade")
					else
						if missionLength >= 3 then
							if comms_source.nabbitPart == nil then
								nabbitPartChoice = math.random(1,5)
								if nabbitPartChoice == 1 then
									comms_source.nabbitPart = "nickel"
								elseif nabbitPartChoice == 2 then
									comms_source.nabbitPart = "impulse"
								elseif nabbitPartChoice == 3 then
									comms_source.nabbitPart = "lifter"
								elseif nabbitPartChoice == 4 then
									comms_source.nabbitPart = "filament"
								else
									comms_source.nabbitPart = "cobalt"
								end
							end
							local nabbitPartQuantity = 0
							if comms_source.goods ~= nil and comms_source.goods[comms_source.nabbitPart] ~= nil and comms_source.goods[comms_source.nabbitPart] > 0 then
								nabbitPartQuantity = comms_source.goods[comms_source.nabbitPart]
							end
							if nabbitPartQuantity > 0 then
								comms_source.goods[comms_source.nabbitPart] = comms_source.goods[comms_source.nabbitPart] - 1
								comms_source.cargo = comms_source.cargo + 1
								comms_source:setImpulseMaxSpeed(comms_source:getImpulseMaxSpeed()*1.2)
								if impulseDone == nil then
									playSoundFile("sa_54_UTImpulse.wav")
									impulseDone = "played"
								end
								setCommsMessage(string.format("Thanks for the %s. Your impulse engines now have improved speed",comms_source.nabbitPart))
								comms_source.nabbitUpgrade = true
							else
								setCommsMessage(string.format("We're short of %s. Please bring us some of that kind of cargo and we can upgrade your impulse engines",comms_source.nabbitPart))
							end
						else
							comms_source:setImpulseMaxSpeed(comms_source:getImpulseMaxSpeed()*1.2)
							if impulseDone == nil then
								playSoundFile("sa_54_UTImpulse.wav")
								impulseDone = "played"
							end
							setCommsMessage("Your impulse engines now have improved speed")
							comms_source.nabbitUpgrade = true
						end
					end
					addCommsReply("Back", commsStation)
				end)
			end
			if lisbonUpgrade then
				addCommsReply("Apply Commander Lisbon's beam cooling algorithm", function()
					if comms_source.lisbonUpgrade then
						setCommsMessage("You already have the upgrade.")
					else
						if comms_source:getBeamWeaponRange(0) < 1 then
							setCommsMessage("Your ship type does not support a beam weapon upgrade.")
						else
							if missionLength >= 3 then
								if comms_source.lisbonPart == nil then
									lisbonPartChoice = math.random(1,5)
									if lisbonPartChoice == 1 then
										comms_source.lisbonPart = "platinum"
									elseif lisbonPartChoice == 2 then
										comms_source.lisbonPart = "battery"
									elseif lisbonPartChoice == 3 then
										comms_source.lisbonPart = "robotic"
									elseif lisbonPartChoice == 4 then
										comms_source.lisbonPart = "nanites"
									else
										comms_source.lisbonPart = "gold"
									end
								end
								local lisbonPartQuantity = 0
								if comms_source.goods ~= nil and comms_source.goods[comms_source.lisbonPart] ~= nil and comms_source.goods[comms_source.lisbonPart] > 0 then
									lisbonPartQuantity = comms_source.goods[comms_source.lisbonPart]
								end
								if lisbonPartQuantity > 0 then
									lisbonBeamUpgrade()
									comms_source.goods[comms_source.lisbonPart] = comms_source.goods[comms_source.lisbonPart] - 1
									comms_source.cargo = comms_source.cargo + 1
									setCommsMessage(string.format("Thanks for bringing us %s. Your beam weapons now generate less heat when firing",comms_source.lisbonPart))
								else
									setCommsMessage(string.format("The algorithm requires components we don't have right now. Please bring us some %s and we can apply the upgrade",comms_source.lisbonPart))
								end
							else
								lisbonBeamUpgrade()
								setCommsMessage("Your beam weapons now generate less heat when firing.")
							end
						end
					end
					addCommsReply("Back", commsStation)
				end)
			end
			if artAnchorUpgrade then
				addCommsReply("Upgrade maneuverability", function()
					if comms_source.artAnchorUpgrade then
						setCommsMessage("You already have the upgrade")
					else
						if missionLength >= 3 then
							if comms_source.artifactUpgradePart == nil then
								artifactUpgradePartChoice = math.random(1,5)
								if artifactUpgradePartChoice == 1 then
									comms_source.artifactUpgradePart = "sensor"
								elseif artifactUpgradePartChoice == 2 then
									comms_source.artifactUpgradePart = "repulsor"
								elseif artifactUpgradePartChoice == 3 then
									comms_source.artifactUpgradePart = "tractor"
								elseif artifactUpgradePartChoice == 4 then
									comms_source.artifactUpgradePart = "dilithium"
								else
									comms_source.artifactUpgradePart = "nickel"
								end
							end
							local artifactPartQuantity = 0
							if comms_source.goods ~= nil and comms_source.goods[comms_source.artifactUpgradePart] ~= nil and comms_source.goods[comms_source.artifactUpgradePart] > 0 then
								artifactPartQuantity = comms_source.goods[comms_source.artifactUpgradePart]
							end
							if artifactPartQuantity > 0 then
								comms_source.goods[comms_source.artifactUpgradePart] = comms_source.goods[comms_source.artifactUpgradePart] - 1
								comms_source.cargo = comms_source.cargo + 1
								artifactUpgrade()
								setCommsMessage(string.format("We needed that %s, thanks. Your maneuverability has been significantly improved",comms_source.artifactUpgradePart))
							else
								setCommsMessage(string.format("To upgrade, we need you to bring us some %s",comms_source.artifactUpgradePart))
							end
						else
							artifactUpgrade()
							setCommsMessage("Your maneuverability has been significantly improved")
						end
					end
					addCommsReply("Back", commsStation)
				end)
			end
			if addTubeUpgrade then
				addCommsReply("Add homing missile tube upgrade", function()
					if comms_source.addTubeUpgrade then
						setCommsMessage("You already have the upgrade")
					else
						if comms_source.addTubeUpgradePart1 == nil then
							randomTubeAddCargo = math.random(1,5)
							if randomTubeAddCargo == 1 then
								comms_source.addTubeUpgradePart1 = "platinum"
							elseif randomTubeAddCargo == 2 then
								comms_source.addTubeUpgradePart1 = "dilithium"
							elseif randomTubeAddCargo == 3 then
								comms_source.addTubeUpgradePart1 = "tritanium"
							elseif randomTubeAddCargo == 4 then
								comms_source.addTubeUpgradePart1 = "cobalt"
							else
								comms_source.addTubeUpgradePart1 = "nickel"
							end
							randomTubeAddCargo = math.random(1,5)
							if randomTubeAddCargo == 1 then
								comms_source.addTubeUpgradePart2 = "lifter"
							elseif randomTubeAddCargo == 2 then
								comms_source.addTubeUpgradePart2 = "tractor"
							elseif randomTubeAddCargo == 3 then
								comms_source.addTubeUpgradePart2 = "circuit"
							elseif randomTubeAddCargo == 4 then
								comms_source.addTubeUpgradePart2 = "software"
							else
								comms_source.addTubeUpgradePart2 = "robotic"
							end
						end
						local addTubePart1quantity = 0
						local addTubePart2quantity = 0
						if comms_source.goods ~= nil and comms_source.goods[comms_source.addTubeUpgradePart1] ~= nil and comms_source.goods[comms_source.addTubeUpgradePart1] > 0 then
							addTubePart1quantity = comms_source.goods[comms_source.addTubeUpgradePart1]
						end
						if comms_source.goods ~= nil and comms_source.goods[comms_source.addTubeUpgradePart2] ~= nil and comms_source.goods[comms_source.addTubeUpgradePart2] > 0 then
							addTubePart2quantity = comms_source.goods[comms_source.addTubeUpgradePart2]
						end
						if addTubePart1quantity > 0 and addTubePart2quantity > 0 then
							comms_source.goods[comms_source.addTubeUpgradePart1] = comms_source.goods[comms_source.addTubeUpgradePart1] - 1
							comms_source.goods[comms_source.addTubeUpgradePart2] = comms_source.goods[comms_source.addTubeUpgradePart2] - 1
							comms_source.cargo = comms_source.cargo + 2
							comms_source.addTubeUpgrade = true
							originalTubes = comms_source:getWeaponTubeCount()
							newTubes = originalTubes + 1
							comms_source:setWeaponTubeCount(newTubes)
							comms_source:setWeaponTubeExclusiveFor(originalTubes, "Homing")
							comms_source:setWeaponStorageMax("Homing", comms_source:getWeaponStorageMax("Homing") + 2)
							comms_source:setWeaponStorage("Homing", comms_source:getWeaponStorage("Homing") + 2)
							setCommsMessage(string.format("Thanks for the %s and %s. You now have an additional homing torpedo tube",comms_source.addTubeUpgradePart1,comms_source.addTubeUpgradePart2))
							comms_source.flakyTubeCount = 0
							comms_source.tubeFixed = true
							if plot8 ~= flakyTube then
								plot8 = flakyTube
								flakyTubeTimer = 300
							end
						else
							setCommsMessage(string.format("We're running short of supplies. To add the homing torpedo tube, we need you to bring us %s and %s",comms_source.addTubeUpgradePart1,comms_source.addTubeUpgradePart2))				
						end
					end
					addCommsReply("Back", commsStation)
				end)
			end	
			addCommsReply("Back", commsStation)
		end)	
	end
end
function masterCartographer()
	if comms_source:takeReputationPoints(getCartographerCost("master")) then
		setCommsMessage("Greetings,\nMay I help you find a station or goods?")
		addCommsReply("Find station",function()
			setCommsMessage("What station?")
			local nearby_objects = getAllObjects()
			local stations_known = 0
			for _, obj in ipairs(nearby_objects) do
				if obj.typeName == "SpaceStation" then
					if not obj:isEnemy(comms_target) then
						local station_distance = distance(comms_target,obj)
						if station_distance > 50000 then
							stations_known = stations_known + 1
							addCommsReply(obj:getCallSign(),function()
								local station_details = string.format("%s %s %s Distance:%.1fU",obj:getSectorName(),obj:getFaction(),obj:getCallSign(),station_distance/1000)
								if obj.comms_data.goods ~= nil then
									station_details = string.format("%s\nGood, quantity, cost",station_details)
									for good, good_data in pairs(obj.comms_data.goods) do
										station_details = string.format("%s\n   %s, %i, %i",station_details,good,good_data["quantity"],good_data["cost"])
									end
								end
								if obj.comms_data.general_information ~= nil then
									station_details = string.format("%s\nGeneral Information:\n   %s",station_details,obj.comms_data.general_information)
								end
								if obj.comms_data.history ~= nil then
									station_details = string.format("%s\nHistory:\n   %s",station_details,obj.comms_data.history)
								end
								if obj.comms_data.gossip ~= nil then
									station_details = string.format("%s\nGossip:\n   %s",station_details,obj.comms_data.gossip)
								end
								local dsx, dsy = obj:getPosition()
								comms_source:commandAddWaypoint(dsx,dsy)
								station_details = string.format("%s\nAdded waypoint %i to your navigation system for %s",station_details,comms_source:getWaypointCount(),obj:getCallSign())
								setCommsMessage(station_details)
								addCommsReply("Back",commsStation)
							end)
						end
					end
				end
			end
			if stations_known == 0 then
				setCommsMessage("Try the apprentice, I'm tired")
			end
			addCommsReply("Back",commsStation)
		end)
		addCommsReply("Find Goods", function()
			setCommsMessage("What goods are you looking for?")
			local nearby_objects = getAllObjects()
			local by_goods = {}
			for _, obj in ipairs(nearby_objects) do
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
			for good, obj in pairs(by_goods) do
				addCommsReply(good, function()
					local station_distance = distance(comms_target,obj)
					local station_details = string.format("%s %s %s Distance:%.1fU",obj:getSectorName(),obj:getFaction(),obj:getCallSign(),station_distance/1000)
					if obj.comms_data.goods ~= nil then
						station_details = string.format("%s\nGood, quantity, cost",station_details)
						for good, good_data in pairs(obj.comms_data.goods) do
							station_details = string.format("%s\n   %s, %i, %i",station_details,good,good_data["quantity"],good_data["cost"])
						end
					end
					if obj.comms_data.general_information ~= nil then
						station_details = string.format("%s\nGeneral Information:\n   %s",station_details,obj.comms_data.general_information)
					end
					if obj.comms_data.history ~= nil then
						station_details = string.format("%s\nHistory:\n   %s",station_details,obj.comms_data.history)
					end
					if obj.comms_data.gossip ~= nil then
						station_details = string.format("%s\nGossip:\n   %s",station_details,obj.comms_data.gossip)
					end
					local dsx, dsy = obj:getPosition()
					comms_source:commandAddWaypoint(dsx,dsy)
					station_details = string.format("%s\nAdded waypoint %i to your navigation system for %s",station_details,comms_source:getWaypointCount(),obj:getCallSign())
					setCommsMessage(station_details)
					addCommsReply("Back",commsStation)
				end)
			end
			addCommsReply("Back",commsStation)
		end)
	else
		setCommsMessage("Insufficient Reputation")
	end
end
function artifactUpgrade()
	comms_source:setRotationMaxSpeed(comms_source:getRotationMaxSpeed()*2)
	comms_source.artAnchorUpgrade = true
	if maneuverDone ~= "played" then
		playSoundFile("sa_54_UTManeuver.wav")
		maneuverDone = "played"
	end	
end
function lisbonBeamUpgrade()
	local bi = 0
	repeat
		comms_source:setBeamWeaponHeatPerFire(bi,comms_source:getBeamWeaponHeatPerFire(bi) * 0.5)
		bi = bi + 1
	until(comms_source:getBeamWeaponRange(bi) < 1)
	comms_source.lisbonUpgrade = true
	if coolBeamsDone ~= "played" then
		playSoundFile("sa_54_UTCoolBeams.wav")
		coolBeamsDone = "played"
	end
end
function kojakBeamUpgrade()
	local bi = 0
	local newRange = 0
	local newCycle = 0
	local newDamage = 0
	local tempArc = 0
	local tempDirection = 0
	repeat
		newRange = comms_source:getBeamWeaponRange(bi) * 1.1
		newCycle = comms_source:getBeamWeaponCycleTime(bi) * .9
		newDamage = comms_source:getBeamWeaponDamage(bi) * 1.1
		tempArc = comms_source:getBeamWeaponArc(bi)
		tempDirection = comms_source:getBeamWeaponDirection(bi)
		comms_source:setBeamWeapon(bi,tempArc,tempDirection,newRange,newCycle,newDamage)
		bi = bi + 1
	until(comms_source:getBeamWeaponRange(bi) < 1)
	comms_source.kojakUpgrade = true
	if tripleBeam ~= "played" then
		playSoundFile("sa_54_UTTripleBeam.wav")
		tripleBeam = "played"
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
function getCartographerCost(service)
	local base_cost = 1
	if service == "apprentice" then
		base_cost = 5
	elseif service == "master" then
		base_cost = 10
	end
	return math.ceil(base_cost * comms_data.reputation_cost_multipliers[getFriendStatus()])
end
function handleUndockedState()
    --Handle communications when we are not docked with the station.
	local ctd = comms_target.comms_data
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
		addCommsReply("What ordnance do you have available for restock?", function()
			local ctd = comms_target.comms_data
			local missileTypeAvailableCount = 0
			local ordnanceListMsg = ""
			if ctd.weapon_available.Nuke then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. "\n   Nuke"
			end
			if ctd.weapon_available.EMP then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. "\n   EMP"
			end
			if ctd.weapon_available.Homing then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. "\n   Homing"
			end
			if ctd.weapon_available.Mine then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. "\n   Mine"
			end
			if ctd.weapon_available.HVLI then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. "\n   HVLI"
			end
			if missileTypeAvailableCount == 0 then
				ordnanceListMsg = "We have no ordnance available for restock"
			elseif missileTypeAvailableCount == 1 then
				ordnanceListMsg = "We have the following type of ordnance available for restock:" .. ordnanceListMsg
			else
				ordnanceListMsg = "We have the following types of ordnance available for restock:" .. ordnanceListMsg
			end
			setCommsMessage(ordnanceListMsg)
			addCommsReply("Back", commsStation)
		end)
		local goodsAvailable = false
		if ctd.goods ~= nil then	--ERROR: attempt to index a nil value (global 'ctd')
			for good, goodData in pairs(ctd.goods) do
				if goodData["quantity"] > 0 then
					goodsAvailable = true
				end
			end
		end
		if goodsAvailable then
			addCommsReply("What goods do you have available for sale or trade?", function()
				local ctd = comms_target.comms_data
				local goodsAvailableMsg = string.format("Station %s:\nGoods or components available: quantity, cost in reputation",comms_target:getCallSign())
				for good, goodData in pairs(ctd.goods) do
					goodsAvailableMsg = goodsAvailableMsg .. string.format("\n   %14s: %2i, %3i",good,goodData["quantity"],goodData["cost"])
				end
				setCommsMessage(goodsAvailableMsg)
				addCommsReply("Back", commsStation)
			end)
		end
		addCommsReply("See any enemies in your area?", function()
			if comms_source:isFriendly(comms_target) then
				enemiesInRange = 0
				for _, obj in ipairs(comms_target:getObjectsInRange(30000)) do
					if obj:isEnemy(comms_source) then
						enemiesInRange = enemiesInRange + 1
					end
				end
				if enemiesInRange > 0 then
					if enemiesInRange > 1 then
						setCommsMessage(string.format("Yes, we see %i enemies within 30U",enemiesInRange))
					else
						setCommsMessage("Yes, we see one enemy within 30U")						
					end
					comms_source:addReputationPoints(2.0)					
				else
					setCommsMessage("No enemies within 30U")
					comms_source:addReputationPoints(1.0)
				end
				addCommsReply("Back", commsStation)
			else
				setCommsMessage("Not really")
				comms_source:addReputationPoints(1.0)
				addCommsReply("Back", commsStation)
			end
		end)
		addCommsReply("Where can I find particular goods?", function()
			local ctd = comms_target.comms_data
			gkMsg = "Friendly stations often have food or medicine or both. Neutral stations may trade their goods for food, medicine or luxury."
			if ctd.goodsKnowledge == nil then
				ctd.goodsKnowledge = {}
				local knowledgeCount = 0
				local knowledgeMax = 10
				for i=1,#stationList do
					local station = stationList[i]
					if station ~= nil and station:isValid() then
						local brainCheckChance = 60
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
					setCommsMessage(string.format("Station %s in sector %s has %s for %i reputation",stationName,sectorName,goodName,goodCost))
					addCommsReply("Back", commsStation)
				end)
			end
			if goodsKnowledgeCount > 0 then
				gkMsg = gkMsg .. "\n\nWhat goods are you interested in?\nI've heard about these:"
			else
				gkMsg = gkMsg .. " Beyond that, I have no knowledge of specific stations"
			end
			setCommsMessage(gkMsg)
			addCommsReply("Back", commsStation)
		end)
		local has_gossip = random(1,100) < 50
		if (ctd.general ~= nil and ctd.general ~= "") or 
			(ctd.history ~= nil and ctd.history ~= "") or 
			(comms_source:isFriendly(comms_target) and ctd.gossip ~= nil and has_gossip) then
			addCommsReply("Tell me more about your station", function()
				setCommsMessage("What would you like to know?")
				addCommsReply("General information", function()
					setCommsMessage(ctd.general)
					addCommsReply("Back", commsStation)
				end)
				if ctd.history ~= nil then
					addCommsReply("Station history", function()
						setCommsMessage(ctd.history)
						addCommsReply("Back", commsStation)
					end)
				end
				if comms_source:isFriendly(comms_target) then
					if ctd.gossip ~= nil then
						if has_gossip then
							addCommsReply("Gossip", function()
								setCommsMessage(ctd.gossip)
								addCommsReply("Back", commsStation)
							end)
						end
					end
				end
			end)	--end station info comms reply branch
		end
	end)
	if comms_source:isFriendly(comms_target) then
		addCommsReply("What are my current orders?", function()
			setOptionalOrders()
			ordMsg = primaryOrders .. secondaryOrders .. optionalOrders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format("\n   %i Minutes remain in game",math.floor(gameTimeLimit/60))
			else
				if patrolComplete then
					ordMsg = ordMsg .. "\nPatrol mission complete"
				else
					legAverage = (comms_source.patrolLegAsimov + comms_source.patrolLegUtopiaPlanitia + comms_source.patrolLegArmstrong)/3
					ordMsg = ordMsg .. string.format("\n   patrol is %.2f percent complete",legAverage/patrolGoal*100)
					--print(string.format("Av legs: %i, UP legs: %i, Ag legs: %i, Avg: %.1f, Goal: %i",comms_source.patrolLegAsimov,comms_source.patrolLegUtopiaPlanitia,comms_source.patrolLegArmstrong,legAverage,patrolGoal))
					if comms_source.patrolLegArmstrong ~= comms_source.patrolLegAsimov or comms_source.patrolLegUtopiaPlanitia ~= comms_source.patrolLegArmstrong then
						if comms_source.patrolLegArmstrong == comms_source.patrolLegAsimov then
							if comms_source.patrolLegArmstrong > comms_source.patrolLegUtopiaPlanitia then
								ordMsg = ordMsg .. "\n   Least patrolled station: Utopia Panitia"
							else
								ordMsg = ordMsg .. "\n   Most patrolled station: Utopia Planitia"
							end
						elseif comms_source.patrolLegArmstrong == comms_source.patrolLegUtopiaPlanitia then
							if comms_source.patrolLegArmstrong > comms_source.patrolLegAsimov then
								ordMsg = ordMsg .. "\n   Least patrolled station: Asimov"
							else
								ordMsg = ordMsg .. "\n   Most patrolled station: Asimov"
							end
						else
							if comms_source.patrolLegAsimov > comms_source.patrolLegArmstrong then
								ordMsg = ordMsg .. "\n   Least patrolled station: Armstrong"
							else
								ordMsg = ordMsg .. "\n   Most patrolled station: Armstrong"
							end
						end
					end
				end
			end
			setCommsMessage(ordMsg)
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
	comms_data = comms_target.comms_data
	if comms_data.goods == nil then
		comms_data.goods = {}
		if random(1,100) < 50 then
			comms_data.goods[mineralGoods[math.random(1,#mineralGoods)]] = {quantity = 1, cost = random(20,80)}
		else
			comms_data.goods[componentGoods[math.random(1,#componentGoods)]] = {quantity = 1, cost = random(20,80)}			
		end
		local shipType = comms_target:getTypeName()
		local goodCount = 0
		if shipType:find("Freighter") ~= nil then
			if shipType:find("Goods") ~= nil then
				repeat
					goodCount = 0
					for good, goodData in pairs(comms_data.goods) do
						goodCount = goodCount + 1
					end
					if good_count == 1 then
						comms_data.goods[mineralGoods[math.random(1,#mineralGoods)]] = {quantity = 1, cost = random(20,80)}
					elseif good_count == 2 then
						comms_data.goods[componentGoods[math.random(1,#componentGoods)]] = {quantity = 1, cost = random(20,80)}
					else
						comms_data.goods[commonGoods[math.random(1,#commonGoods)]] = {quantity = 1, cost = random(20,80)}
					end
				until(goodCount >= 3)
			elseif shipType:find("Equipment") ~= nil then
				repeat
					comms_data.goods[componentGoods[math.random(1,#componentGoods)]] = {quantity = 1, cost = random(20,80)}
					goodCount = 0
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
	shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
		setCommsMessage("Yes?")
		addCommsReply("Do you have cargo you might sell?", function()
			local goodCount = 0
			local cargoMsg = "We've got "
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
				cargoMsg = cargoMsg .. "nothing"
			end
			setCommsMessage(cargoMsg)
		end)
		local freighter_multiplier = 1
		if comms_data.friendlyness > 66 then
			setCommsMessage("Yes?")
			-- Offer destination information
			addCommsReply("Where are you headed?", function()
				setCommsMessage(comms_target.target:getCallSign())
				addCommsReply("Back", commsShip)
			end)
			-- Offer to trade goods if goods or equipment freighter
			if distance(comms_source,comms_target) < 5000 then
				local goodCount = 0
				if comms_source.goods ~= nil then
					for good, goodQuantity in pairs(comms_source.goods) do
						goodCount = goodCount + 1
					end
				end
				if goodCount > 0 then
					addCommsReply("Jettison cargo", function()
						setCommsMessage(string.format("Available space: %i\nWhat would you like to jettison?",comms_source.cargo))
						for good, good_quantity in pairs(comms_source.goods) do
							if good_quantity > 0 then
								addCommsReply(good, function()
									comms_source.goods[good] = comms_source.goods[good] - 1
									comms_source.cargo = comms_source.cargo + 1
									setCommsMessage(string.format("One %s jettisoned",good))
									addCommsReply("Back", commsShip)
								end)
							end
						end
						addCommsReply("Back", commsShip)
					end)
				end
				if comms_source.cargo > 0 then
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						local luxuryQuantity = 0
						if comms_source.goods ~= nil and comms_source.goods["luxury"] ~= nil and comms_source.goods["luxury"] > 0 then
							luxuryQuantity = comms_source.goods["luxury"]
						end
						if luxuryQuantity > 0 then
							for good, goodData in pairs(comms_data.goods) do
								if goodData.quantity > 0 then
									addCommsReply(string.format("Trade luxury for %s",good), function()
										comms_source.goods["luxury"] = comms_source.goods["luxury"] - 1
										if comms_source.goods[good] == nil then comms_source.goods[good] = 0 end
										comms_source.goods[good] = comms_source.goods[good] + 1
										setCommsMessage("Traded")
										addCommsReply("Back", commsShip)
									end)
								end
							end
						end
					end
				end
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					freighter_multiplier = 1
				else
					freighter_multiplier = 2
				end
				for good, goodData in pairs(comms_data.goods) do
					if goodData.quantity > 0 then
						addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*freighter_multiplier)), function()
							if comms_source:takeReputationPoints(goodData.cost) then
								goodData.quantity = goodData.quantity - 1
								if comms_source.goods == nil then comms_source.goods = {} end
								if comms_source.goods[good] == nil then comms_source.goods[good] = 0 end
								comms_source.goods[good] = comms_source.goods[good] + 1
								comms_source.cargo = comms_source.cargo - 1
								setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
							else
								setCommsMessage("Insufficient reputation for purchase")
							end
							addCommsReply("Back", commsShip)
						end)
					end
				end	--freighter goods loop
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
				local goodCount = 0
				if comms_source.goods ~= nil then
					for good, goodQuantity in pairs(comms_source.goods) do
						goodCount = goodCount + 1
					end
				end
				if goodCount > 0 then
					addCommsReply("Jettison cargo", function()
						setCommsMessage(string.format("Available space: %i\nWhat would you like to jettison?",comms_source.cargo))
						for good, good_quantity in pairs(comms_source.goods) do
							if good_quantity > 0 then
								addCommsReply(good, function()
									comms_source.goods[good] = comms_source.goods[good] - 1
									comms_source.cargo = comms_source.cargo + 1
									setCommsMessage(string.format("One %s jettisoned",good))
									addCommsReply("Back", commsShip)
								end)
							end
						end
						addCommsReply("Back", commsShip)
					end)
				end
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					freighter_multiplier = 2
				else
					freighter_multiplier = 3
				end
				for good, goodData in pairs(comms_data.goods) do
					if goodData.quantity > 0 then
						addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*freighter_multiplier)), function()
							if comms_source:takeReputationPoints(goodData.cost*freighter_multiplier) then
								goodData.quantity = goodData.quantity - 1
								if comms_source.goods == nil then
									comms_source.goods = {}
								end
								if comms_source.goods[good] == nil then
									comms_source.goods[good] = 0
								end
								comms_source.goods[good] = comms_source.goods[good] + 1
								comms_source.cargo = comms_source.cargo - 1
								setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
							else
								setCommsMessage("Insufficient reputation for purchase")
							end
							addCommsReply("Back", commsShip)
						end)
					end
				end	--freighter goods loop
			end
		else	--least friendly
			setCommsMessage("Why are you bothering me?")
			-- Offer to sell goods if goods or equipment freighter double price
			if distance(comms_source,comms_target) < 5000 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					freighter_multiplier = 3
					for good, goodData in pairs(comms_data.goods) do
						if goodData.quantity > 0 then
							addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*freighter_multiplier)), function()
								if comms_source:takeReputationPoints(goodData.cost*freighter_multiplier) then
									goodData.quantity = goodData.quantity - 1
									if comms_source.goods == nil then
										comms_source.goods = {}
									end
									if comms_source.goods[good] == nil then
										comms_source.goods[good] = 0
									end
									comms_source.goods[good] = comms_source.goods[good] + 1
									comms_source.cargo = comms_source.cargo - 1
									setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
								else
									setCommsMessage("Insufficient reputation for purchase")
								end
								addCommsReply("Back", commsShip)
							end)
						end
					end	--freighter goods loop
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
------------------------------------
--	Generate call sign functions  --
------------------------------------
function generateCallSign(prefix,faction)
	if faction == nil then
		if prefix == nil then
			prefix = generateCallSignPrefix()
		end
	else
		if prefix == nil then
			prefix = getFactionPrefix(faction)
		else
			prefix = string.format("%s %s",getFactionPrefix(faction),prefix)
		end
	end
	suffix_index = suffix_index + math.random(1,3)
	if suffix_index > 999 then 
		suffix_index = 1
	end
	return string.format("%s%i",prefix,suffix_index)
end
function generateCallSignPrefix(length)
	if call_sign_prefix_pool == nil then
		call_sign_prefix_pool = {}
		prefix_length = prefix_length + 1
		if prefix_length > 3 then
			prefix_length = 1
		end
		fillPrefixPool()
	end
	if length == nil then
		length = prefix_length
	end
	local prefix_index = 0
	local prefix = ""
	for i=1,length do
		if #call_sign_prefix_pool < 1 then
			fillPrefixPool()
		end
		prefix_index = math.random(1,#call_sign_prefix_pool)
		prefix = prefix .. call_sign_prefix_pool[prefix_index]
		table.remove(call_sign_prefix_pool,prefix_index)
	end
	return prefix
end
function fillPrefixPool()
	for i=1,26 do
		table.insert(call_sign_prefix_pool,string.char(i+64))
	end
end
function getFactionPrefix(faction)
	local faction_prefix = nil
	if faction == "Kraylor" then
		if kraylor_names == nil then
			setKraylorNames()
		else
			if #kraylor_names < 1 then
				setKraylorNames()
			end
		end
		local kraylor_name_choice = math.random(1,#kraylor_names)
		faction_prefix = kraylor_names[kraylor_name_choice]
		table.remove(kraylor_names,kraylor_name_choice)
	end
	if faction == "Exuari" then
		if exuari_names == nil then
			setExuariNames()
		else
			if #exuari_names < 1 then
				setExuariNames()
			end
		end
		local exuari_name_choice = math.random(1,#exuari_names)
		faction_prefix = exuari_names[exuari_name_choice]
		table.remove(exuari_names,exuari_name_choice)
	end
	if faction == "Ghosts" then
		if ghosts_names == nil then
			setGhostsNames()
		else
			if #ghosts_names < 1 then
				setGhostsNames()
			end
		end
		local ghosts_name_choice = math.random(1,#ghosts_names)
		faction_prefix = ghosts_names[ghosts_name_choice]
		table.remove(ghosts_names,ghosts_name_choice)
	end
	if faction == "Independent" then
		if independent_names == nil then
			setIndependentNames()
		else
			if #independent_names < 1 then
				setIndependentNames()
			end
		end
		local independent_name_choice = math.random(1,#independent_names)
		faction_prefix = independent_names[independent_name_choice]
		table.remove(independent_names,independent_name_choice)
	end
	if faction_prefix == nil then
		faction_prefix = generateCallSignPrefix()
	end
	return faction_prefix
end
function setGhostsNames()
	ghosts_names = {}
	table.insert(ghosts_names,"Abstract")
	table.insert(ghosts_names,"Ada")
	table.insert(ghosts_names,"Assemble")
	table.insert(ghosts_names,"Assert")
	table.insert(ghosts_names,"Backup")
	table.insert(ghosts_names,"BASIC")
	table.insert(ghosts_names,"Big Iron")
	table.insert(ghosts_names,"BigEndian")
	table.insert(ghosts_names,"Binary")
	table.insert(ghosts_names,"Bit")
	table.insert(ghosts_names,"Block")
	table.insert(ghosts_names,"Boot")
	table.insert(ghosts_names,"Branch")
	table.insert(ghosts_names,"BTree")
	table.insert(ghosts_names,"Bubble")
	table.insert(ghosts_names,"Byte")
	table.insert(ghosts_names,"Capacitor")
	table.insert(ghosts_names,"Case")
	table.insert(ghosts_names,"Chad")
	table.insert(ghosts_names,"Charge")
	table.insert(ghosts_names,"COBOL")
	table.insert(ghosts_names,"Collate")
	table.insert(ghosts_names,"Compile")
	table.insert(ghosts_names,"Control")
	table.insert(ghosts_names,"Construct")
	table.insert(ghosts_names,"Cycle")
	table.insert(ghosts_names,"Data")
	table.insert(ghosts_names,"Debug")
	table.insert(ghosts_names,"Decimal")
	table.insert(ghosts_names,"Decision")
	table.insert(ghosts_names,"Default")
	table.insert(ghosts_names,"DIMM")
	table.insert(ghosts_names,"Displacement")
	table.insert(ghosts_names,"Edge")
	table.insert(ghosts_names,"Exit")
	table.insert(ghosts_names,"Factor")
	table.insert(ghosts_names,"Flag")
	table.insert(ghosts_names,"Float")
	table.insert(ghosts_names,"Flow")
	table.insert(ghosts_names,"FORTRAN")
	table.insert(ghosts_names,"Fullword")
	table.insert(ghosts_names,"GIGO")
	table.insert(ghosts_names,"Graph")
	table.insert(ghosts_names,"Hack")
	table.insert(ghosts_names,"Hash")
	table.insert(ghosts_names,"Halfword")
	table.insert(ghosts_names,"Hertz")
	table.insert(ghosts_names,"Hexadecimal")
	table.insert(ghosts_names,"Indicator")
	table.insert(ghosts_names,"Initialize")
	table.insert(ghosts_names,"Integer")
	table.insert(ghosts_names,"Integrate")
	table.insert(ghosts_names,"Interrupt")
	table.insert(ghosts_names,"Java")
	table.insert(ghosts_names,"Lisp")
	table.insert(ghosts_names,"List")
	table.insert(ghosts_names,"Logic")
	table.insert(ghosts_names,"Loop")
	table.insert(ghosts_names,"Lua")
	table.insert(ghosts_names,"Magnetic")
	table.insert(ghosts_names,"Mask")
	table.insert(ghosts_names,"Memory")
	table.insert(ghosts_names,"Mnemonic")
	table.insert(ghosts_names,"Micro")
	table.insert(ghosts_names,"Model")
	table.insert(ghosts_names,"Nibble")
	table.insert(ghosts_names,"Octal")
	table.insert(ghosts_names,"Order")
	table.insert(ghosts_names,"Operator")
	table.insert(ghosts_names,"Parameter")
	table.insert(ghosts_names,"Pascal")
	table.insert(ghosts_names,"Pattern")
	table.insert(ghosts_names,"Pixel")
	table.insert(ghosts_names,"Point")
	table.insert(ghosts_names,"Polygon")
	table.insert(ghosts_names,"Port")
	table.insert(ghosts_names,"Process")
	table.insert(ghosts_names,"RAM")
	table.insert(ghosts_names,"Raster")
	table.insert(ghosts_names,"Rate")
	table.insert(ghosts_names,"Redundant")
	table.insert(ghosts_names,"Reference")
	table.insert(ghosts_names,"Refresh")
	table.insert(ghosts_names,"Register")
	table.insert(ghosts_names,"Resistor")
	table.insert(ghosts_names,"ROM")
	table.insert(ghosts_names,"Routine")
	table.insert(ghosts_names,"Ruby")
	table.insert(ghosts_names,"SAAS")
	table.insert(ghosts_names,"Sequence")
	table.insert(ghosts_names,"Share")
	table.insert(ghosts_names,"Silicon")
	table.insert(ghosts_names,"SIMM")
	table.insert(ghosts_names,"Socket")
	table.insert(ghosts_names,"Sort")
	table.insert(ghosts_names,"Structure")
	table.insert(ghosts_names,"Switch")
	table.insert(ghosts_names,"Symbol")
	table.insert(ghosts_names,"Trace")
	table.insert(ghosts_names,"Transistor")
	table.insert(ghosts_names,"Value")
	table.insert(ghosts_names,"Vector")
	table.insert(ghosts_names,"Version")
	table.insert(ghosts_names,"View")
	table.insert(ghosts_names,"WYSIWYG")
	table.insert(ghosts_names,"XOR")
end
function setExuariNames()
	exuari_names = {}
	table.insert(exuari_names,"Astonester")
	table.insert(exuari_names,"Ametripox")
	table.insert(exuari_names,"Bakeltevex")
	table.insert(exuari_names,"Baropledax")
	table.insert(exuari_names,"Batongomox")
	table.insert(exuari_names,"Bekilvimix")
	table.insert(exuari_names,"Benoglopok")
	table.insert(exuari_names,"Bilontipur")
	table.insert(exuari_names,"Bolictimik")
	table.insert(exuari_names,"Bomagralax")
	table.insert(exuari_names,"Buteldefex")
	table.insert(exuari_names,"Catondinab")
	table.insert(exuari_names,"Chatorlonox")
	table.insert(exuari_names,"Culagromik")
	table.insert(exuari_names,"Dakimbinix")
	table.insert(exuari_names,"Degintalix")
	table.insert(exuari_names,"Dimabratax")
	table.insert(exuari_names,"Dokintifix")
	table.insert(exuari_names,"Dotandirex")
	table.insert(exuari_names,"Dupalgawax")
	table.insert(exuari_names,"Ekoftupex")
	table.insert(exuari_names,"Elidranov")
	table.insert(exuari_names,"Fakobrovox")
	table.insert(exuari_names,"Femoplabix")
	table.insert(exuari_names,"Fibatralax")
	table.insert(exuari_names,"Fomartoran")
	table.insert(exuari_names,"Gateldepex")
	table.insert(exuari_names,"Gamutrewal")
	table.insert(exuari_names,"Gesanterux")
	table.insert(exuari_names,"Gimardanax")
	table.insert(exuari_names,"Hamintinal")
	table.insert(exuari_names,"Holangavak")
	table.insert(exuari_names,"Igolpafik")
	table.insert(exuari_names,"Inoklomat")
	table.insert(exuari_names,"Jamewtibex")
	table.insert(exuari_names,"Jepospagox")
	table.insert(exuari_names,"Kajortonox")
	table.insert(exuari_names,"Kapogrinix")
	table.insert(exuari_names,"Kelitravax")
	table.insert(exuari_names,"Kipaldanax")
	table.insert(exuari_names,"Kodendevex")
	table.insert(exuari_names,"Kotelpedex")
	table.insert(exuari_names,"Kutandolak")
	table.insert(exuari_names,"Lakirtinix")
	table.insert(exuari_names,"Lapoldinek")
	table.insert(exuari_names,"Lavorbonox")
	table.insert(exuari_names,"Letirvinix")
	table.insert(exuari_names,"Lowibromax")
	table.insert(exuari_names,"Makintibix")
	table.insert(exuari_names,"Makorpohox")
	table.insert(exuari_names,"Matoprowox")
	table.insert(exuari_names,"Mefinketix")
	table.insert(exuari_names,"Motandobak")
	table.insert(exuari_names,"Nakustunux")
	table.insert(exuari_names,"Nequivonax")
	table.insert(exuari_names,"Nitaldavax")
	table.insert(exuari_names,"Nobaldorex")
	table.insert(exuari_names,"Obimpitix")
	table.insert(exuari_names,"Owaklanat")
	table.insert(exuari_names,"Pakendesik")
	table.insert(exuari_names,"Pazinderix")
	table.insert(exuari_names,"Pefoglamuk")
	table.insert(exuari_names,"Pekirdivix")
	table.insert(exuari_names,"Potarkadax")
	table.insert(exuari_names,"Pulendemex")
	table.insert(exuari_names,"Quatordunix")
	table.insert(exuari_names,"Rakurdumux")
	table.insert(exuari_names,"Ralombenik")
	table.insert(exuari_names,"Regosporak")
	table.insert(exuari_names,"Retordofox")
	table.insert(exuari_names,"Rikondogox")
	table.insert(exuari_names,"Rokengelex")
	table.insert(exuari_names,"Rutarkadax")
	table.insert(exuari_names,"Sakeldepex")
	table.insert(exuari_names,"Setiftimix")
	table.insert(exuari_names,"Siparkonal")
	table.insert(exuari_names,"Sopaldanax")
	table.insert(exuari_names,"Sudastulux")
	table.insert(exuari_names,"Takeftebex")
	table.insert(exuari_names,"Taliskawit")
	table.insert(exuari_names,"Tegundolex")
	table.insert(exuari_names,"Tekintipix")
	table.insert(exuari_names,"Tiposhomox")
	table.insert(exuari_names,"Tokaldapax")
	table.insert(exuari_names,"Tomuglupux")
	table.insert(exuari_names,"Tufeldepex")
	table.insert(exuari_names,"Unegremek")
	table.insert(exuari_names,"Uvendipax")
	table.insert(exuari_names,"Vatorgopox")
	table.insert(exuari_names,"Venitribix")
	table.insert(exuari_names,"Vobalterix")
	table.insert(exuari_names,"Wakintivix")
	table.insert(exuari_names,"Wapaltunix")
	table.insert(exuari_names,"Wekitrolax")
	table.insert(exuari_names,"Wofarbanax")
	table.insert(exuari_names,"Xeniplofek")
	table.insert(exuari_names,"Yamaglevik")
	table.insert(exuari_names,"Yakildivix")
	table.insert(exuari_names,"Yegomparik")
	table.insert(exuari_names,"Zapondehex")
	table.insert(exuari_names,"Zikandelat")
end
function setKraylorNames()		
	kraylor_names = {}
	table.insert(kraylor_names,"Abroten")
	table.insert(kraylor_names,"Ankwar")
	table.insert(kraylor_names,"Bakrik")
	table.insert(kraylor_names,"Belgor")
	table.insert(kraylor_names,"Benkop")
	table.insert(kraylor_names,"Blargvet")
	table.insert(kraylor_names,"Bloktarg")
	table.insert(kraylor_names,"Bortok")
	table.insert(kraylor_names,"Bredjat")
	table.insert(kraylor_names,"Chankret")
	table.insert(kraylor_names,"Chatork")
	table.insert(kraylor_names,"Chokarp")
	table.insert(kraylor_names,"Cloprak")
	table.insert(kraylor_names,"Coplek")
	table.insert(kraylor_names,"Cortek")
	table.insert(kraylor_names,"Daltok")
	table.insert(kraylor_names,"Darpik")
	table.insert(kraylor_names,"Dastek")
	table.insert(kraylor_names,"Dotark")
	table.insert(kraylor_names,"Drambok")
	table.insert(kraylor_names,"Duntarg")
	table.insert(kraylor_names,"Earklat")
	table.insert(kraylor_names,"Ekmit")
	table.insert(kraylor_names,"Fakret")
	table.insert(kraylor_names,"Fapork")
	table.insert(kraylor_names,"Fawtrik")
	table.insert(kraylor_names,"Fenturp")
	table.insert(kraylor_names,"Feplik")
	table.insert(kraylor_names,"Figront")
	table.insert(kraylor_names,"Floktrag")
	table.insert(kraylor_names,"Fonkack")
	table.insert(kraylor_names,"Fontreg")
	table.insert(kraylor_names,"Foondrap")
	table.insert(kraylor_names,"Frotwak")
	table.insert(kraylor_names,"Gastonk")
	table.insert(kraylor_names,"Gentouk")
	table.insert(kraylor_names,"Gonpruk")
	table.insert(kraylor_names,"Gortak")
	table.insert(kraylor_names,"Gronkud")
	table.insert(kraylor_names,"Hewtang")
	table.insert(kraylor_names,"Hongtag")
	table.insert(kraylor_names,"Hortook")
	table.insert(kraylor_names,"Indrut")
	table.insert(kraylor_names,"Iprant")
	table.insert(kraylor_names,"Jakblet")
	table.insert(kraylor_names,"Jonket")
	table.insert(kraylor_names,"Jontot")
	table.insert(kraylor_names,"Kandarp")
	table.insert(kraylor_names,"Kantrok")
	table.insert(kraylor_names,"Kiptak")
	table.insert(kraylor_names,"Kortrant")
	table.insert(kraylor_names,"Krontgat")
	table.insert(kraylor_names,"Lobreck")
	table.insert(kraylor_names,"Lokrant")
	table.insert(kraylor_names,"Lomprok")
	table.insert(kraylor_names,"Lutrank")
	table.insert(kraylor_names,"Makrast")
	table.insert(kraylor_names,"Moklahft")
	table.insert(kraylor_names,"Morpug")
	table.insert(kraylor_names,"Nagblat")
	table.insert(kraylor_names,"Nokrat")
	table.insert(kraylor_names,"Nomek")
	table.insert(kraylor_names,"Notark")
	table.insert(kraylor_names,"Ontrok")
	table.insert(kraylor_names,"Orkpent")
	table.insert(kraylor_names,"Peechak")
	table.insert(kraylor_names,"Plogrent")
	table.insert(kraylor_names,"Pokrint")
	table.insert(kraylor_names,"Potarg")
	table.insert(kraylor_names,"Prangtil")
	table.insert(kraylor_names,"Quagbrok")
	table.insert(kraylor_names,"Quimprill")
	table.insert(kraylor_names,"Reekront")
	table.insert(kraylor_names,"Ripkort")
	table.insert(kraylor_names,"Rokust")
	table.insert(kraylor_names,"Rontrait")
	table.insert(kraylor_names,"Saknep")
	table.insert(kraylor_names,"Sengot")
	table.insert(kraylor_names,"Skitkard")
	table.insert(kraylor_names,"Skopgrek")
	table.insert(kraylor_names,"Sletrok")
	table.insert(kraylor_names,"Slorknat")
	table.insert(kraylor_names,"Spogrunk")
	table.insert(kraylor_names,"Staklurt")
	table.insert(kraylor_names,"Stonkbrant")
	table.insert(kraylor_names,"Swaktrep")
	table.insert(kraylor_names,"Tandrok")
	table.insert(kraylor_names,"Takrost")
	table.insert(kraylor_names,"Tonkrut")
	table.insert(kraylor_names,"Torkrot")
	table.insert(kraylor_names,"Trablok")
	table.insert(kraylor_names,"Trokdin")
	table.insert(kraylor_names,"Unkelt")
	table.insert(kraylor_names,"Urjop")
	table.insert(kraylor_names,"Vankront")
	table.insert(kraylor_names,"Vintrep")
	table.insert(kraylor_names,"Volkerd")
	table.insert(kraylor_names,"Vortread")
	table.insert(kraylor_names,"Wickurt")
	table.insert(kraylor_names,"Xokbrek")
	table.insert(kraylor_names,"Yeskret")
	table.insert(kraylor_names,"Zacktrope")
end
function setIndependentNames()
	independent_names = {}
	table.insert(independent_names,"Akdroft")	--faux Kraylor
	table.insert(independent_names,"Bletnik")	--faux Kraylor
	table.insert(independent_names,"Brogfent")	--faux Kraylor
	table.insert(independent_names,"Cruflech")	--faux Kraylor
	table.insert(independent_names,"Dengtoct")	--faux Kraylor
	table.insert(independent_names,"Fiklerg")	--faux Kraylor
	table.insert(independent_names,"Groftep")	--faux Kraylor
	table.insert(independent_names,"Hinkflort")	--faux Kraylor
	table.insert(independent_names,"Irklesht")	--faux Kraylor
	table.insert(independent_names,"Jotrak")	--faux Kraylor
	table.insert(independent_names,"Kargleth")	--faux Kraylor
	table.insert(independent_names,"Lidroft")	--faux Kraylor
	table.insert(independent_names,"Movrect")	--faux Kraylor
	table.insert(independent_names,"Nitrang")	--faux Kraylor
	table.insert(independent_names,"Poklapt")	--faux Kraylor
	table.insert(independent_names,"Raknalg")	--faux Kraylor
	table.insert(independent_names,"Stovtuk")	--faux Kraylor
	table.insert(independent_names,"Trongluft")	--faux Kraylor
	table.insert(independent_names,"Vactremp")	--faux Kraylor
	table.insert(independent_names,"Wunklesp")	--faux Kraylor
	table.insert(independent_names,"Yentrilg")	--faux Kraylor
	table.insert(independent_names,"Zeltrag")	--faux Kraylor
	table.insert(independent_names,"Avoltojop")		--faux Exuari
	table.insert(independent_names,"Bimartarax")	--faux Exuari
	table.insert(independent_names,"Cidalkapax")	--faux Exuari
	table.insert(independent_names,"Darongovax")	--faux Exuari
	table.insert(independent_names,"Felistiyik")	--faux Exuari
	table.insert(independent_names,"Gopendewex")	--faux Exuari
	table.insert(independent_names,"Hakortodox")	--faux Exuari
	table.insert(independent_names,"Jemistibix")	--faux Exuari
	table.insert(independent_names,"Kilampafax")	--faux Exuari
	table.insert(independent_names,"Lokuftumux")	--faux Exuari
	table.insert(independent_names,"Mabildirix")	--faux Exuari
	table.insert(independent_names,"Notervelex")	--faux Exuari
	table.insert(independent_names,"Pekolgonex")	--faux Exuari
	table.insert(independent_names,"Rifaltabax")	--faux Exuari
	table.insert(independent_names,"Sobendeyex")	--faux Exuari
	table.insert(independent_names,"Tinaftadax")	--faux Exuari
	table.insert(independent_names,"Vadorgomax")	--faux Exuari
	table.insert(independent_names,"Wilerpejex")	--faux Exuari
	table.insert(independent_names,"Yukawvalak")	--faux Exuari
	table.insert(independent_names,"Zajiltibix")	--faux Exuari
	table.insert(independent_names,"Alter")		--faux Ghosts
	table.insert(independent_names,"Assign")	--faux Ghosts
	table.insert(independent_names,"Brain")		--faux Ghosts
	table.insert(independent_names,"Break")		--faux Ghosts
	table.insert(independent_names,"Boundary")	--faux Ghosts
	table.insert(independent_names,"Code")		--faux Ghosts
	table.insert(independent_names,"Compare")	--faux Ghosts
	table.insert(independent_names,"Continue")	--faux Ghosts
	table.insert(independent_names,"Core")		--faux Ghosts
	table.insert(independent_names,"CRUD")		--faux Ghosts
	table.insert(independent_names,"Decode")	--faux Ghosts
	table.insert(independent_names,"Decrypt")	--faux Ghosts
	table.insert(independent_names,"Device")	--faux Ghosts
	table.insert(independent_names,"Encode")	--faux Ghosts
	table.insert(independent_names,"Encrypt")	--faux Ghosts
	table.insert(independent_names,"Event")		--faux Ghosts
	table.insert(independent_names,"Fetch")		--faux Ghosts
	table.insert(independent_names,"Frame")		--faux Ghosts
	table.insert(independent_names,"Go")		--faux Ghosts
	table.insert(independent_names,"IO")		--faux Ghosts
	table.insert(independent_names,"Interface")	--faux Ghosts
	table.insert(independent_names,"Kilo")		--faux Ghosts
	table.insert(independent_names,"Modify")	--faux Ghosts
	table.insert(independent_names,"Pin")		--faux Ghosts
	table.insert(independent_names,"Program")	--faux Ghosts
	table.insert(independent_names,"Purge")		--faux Ghosts
	table.insert(independent_names,"Retrieve")	--faux Ghosts
	table.insert(independent_names,"Store")		--faux Ghosts
	table.insert(independent_names,"Unit")		--faux Ghosts
	table.insert(independent_names,"Wire")		--faux Ghosts
end
-------------------------------------------------------------
--	First plot line - patrol between stations then defend  --
-------------------------------------------------------------
function initialOrderMessage(delta)
	plot1name = "initialOrderMessage"
	plot1 = patrolAsimovUtopiaPlanitiaArmstrong
	if difficulty > .5 then
		plot11 = jumpStart
	end
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			p:addToShipLog(string.format("Welcome to the delta quadrant, %s. The independent stations in the area outnumber the human naval stations, but they all rely on us to protect them.",p:getCallSign()),"Magenta")
			p:addToShipLog("Your job is to patrol between the three major human naval stations: Asimov, Utopia Planitia and Armstrong. You'll need to dock with each of these stations. Automated systems will extract your routes and track your progress on patrolling between these stations. The primary objective of your patrol is to watch for enemy ships and intercept them, prevent them from destroying the three bases mentioned as your patrol endpoints. Enemies in the area may harass other stations in the area. Protecting the other stations is your secondary objective. Spread goodwill in this high growth, high value quadrant. Our enemies dearly wish to give us a black eye here and claim it for their own.","Magenta")
		end
	end
end

function patrolAsimovUtopiaPlanitiaArmstrong(delta)
	plot1name = "patrol asimov Utopia Planitia armstrong"
	if highestConcurrentPlayerCount > 0 then
		if not stationAsimov:isValid() then
			globalMessage("Asimov station destroyed")
			defeatTimer = 15
			plot1 = defeated
		end
		if not stationUtopiaPlanitia:isValid() then
			globalMessage("Utopia Planitia station destroyed")
			defeatTimer = 15
			plot1 = defeated
		end
		if not stationArmstrong:isValid() then
			globalMessage("Armstrong station destroyed")
			defeatTimer = 15
			plot1 = defeated
		end
	end
	playerCount = 0
	for p5idx=1,8 do
		p5obj = getPlayerShip(p5idx)
		if p5obj ~= nil and p5obj:isValid() then
			if p5obj:isDocked(stationAsimov) then
				if p5obj.patrolLegAsimov < p5obj.patrolLegUtopiaPlanitia or p5obj.patrolLegAsimov < p5obj.patrolLegArmstrong then
					p5obj.patrolLegAsimov = p5obj.patrolLegAsimov + 1
					p5obj:addReputationPoints(1)
				end
				if p5obj.patrolLegAsimov == p5obj.patrolLegUtopiaPlanitia and p5obj.patrolLegAsimov == p5obj.patrolLegArmstrong then
					p5obj.patrolLegAsimov = p5obj.patrolLegAsimov + 1
					p5obj:addReputationPoints(1)
				end
				if p5obj.patrolLegAsimov >= patrolGoal then
					patrolComplete = true
				end
				if p5obj.patrolLegAsimov > highestPatrolLeg then
					highestPatrolLeg = p5obj.patrolLegAsimov
				end
			end
			if p5obj:isDocked(stationUtopiaPlanitia) then
				if p5obj.patrolLegUtopiaPlanitia < p5obj.patrolLegAsimov or p5obj.patrolLegUtopiaPlanitia < p5obj.patrolLegArmstrong then
					p5obj.patrolLegUtopiaPlanitia = p5obj.patrolLegUtopiaPlanitia + 1
					p5obj:addReputationPoints(1)
				end
				if p5obj.patrolLegUtopiaPlanitia == p5obj.patrolLegAsimov and p5obj.patrolLegUtopiaPlanitia == p5obj.patrolLegArmstrong then
					p5obj.patrolLegUtopiaPlanitia = p5obj.patrolLegUtopiaPlanitia + 1
					p5obj:addReputationPoints(1)
				end
				if p5obj.patrolLegUtopiaPlanitia >= patrolGoal then
					patrolComplete = true
				end
				if p5obj.patrolLegUtopiaPlanitia > highestPatrolLeg then
					highestPatrolLeg = p5obj.patrolLegUtopiaPlanitia
				end
			end
			if p5obj:isDocked(stationArmstrong) then
				if p5obj.patrolLegArmstrong < p5obj.patrolLegUtopiaPlanitia or p5obj.patrolLegArmstrong < p5obj.patrolLegAsimov then
					p5obj.patrolLegArmstrong = p5obj.patrolLegArmstrong + 1
					p5obj:addReputationPoints(1)
				end
				if p5obj.patrolLegArmstrong == p5obj.patrolLegUtopiaPlanitia and p5obj.patrolLegArmstrong == p5obj.patrolLegAsimov then
					p5obj.patrolLegArmstrong = p5obj.patrolLegArmstrong + 1
					p5obj:addReputationPoints(1)
				end
				if p5obj.patrolLegArmstrong >= patrolGoal then
					patrolComplete = true
				end
				if p5obj.patrolLegArmstrong > highestPatrolLeg then
					highestPatrolLeg = p5obj.patrolLegArmstrong
				end
			end
			playerCount = playerCount + 1
		end
		if highestPatrolLeg == 2 then
			if nuisanceSpawned == nil then
				nuisanceSpawned = "ready"
				nuisanceTimer = random(30,90)
				plot2 = nuisance
				removeGMFunction("Start plot 2 sick Kojak")
			end
		end
		if highestPatrolLeg == 3 and missionLength > 1 then
			if attack3spawned == nil then
				attack3spawned = "ready"
				attack3Timer = random(15,40)
				plot8 = attack3
				removeGMFunction("Strt plot 8 Sheila dies")
			end
		end
		if highestPatrolLeg == 4 and missionLength > 1 then
			if attack4spawned == nil then
				attack4spawned = "ready"
				attack4Timer = random(20,50)
				plot9 = attack4
				removeGMFunction("Start plot 9 ambush")
			end
		end
		if highestPatrolLeg == 5 then
			if incursionSpawned == nil then
				incursionSpawned = "ready"
				incursionTimer = random(30,90)
				plot3 = incursion
				removeGMFunction("Start p 3 McNabbit ride")
			end
		end
		if highestPatrolLeg == 6 and missionLength > 1 then
			if attack5spawned == nil then
				attack5spawned = "ready"
				attack5Timer = random(20,50)
				plot10 = attack5
				removeGMFunction("Start plot 10 ambush")
			end
		end
		if highestPatrolLeg == 7 then
			if attack1spawned == nil then
				attack1spawned = "ready"
				attack1Timer = random(40,120)
				plot4 = attack1
				removeGMFunction("St p4 Lisbon's stowaway")
			end
		end
		if highestPatrolLeg == 8 then
			if attack2spawned == nil then
				attack2spawned = "ready"
				plot5 = attack2
				removeGMFunction("Start plot 5")
			end		
		end
		if patrolComplete then
			plot1 = afterPatrol
		end
	end
	if playerCount == 0 and highestConcurrentPlayerCount > 0 then
		victory("Kraylor")
	end
	sporadicHarassTimer = sporadicHarassTimer - delta
	if sporadicHarassTimer < 0 then
		randomPatrolStation = patrolStationList[math.random(1,#patrolStationList)]
		p = closestPlayerTo(randomPatrolStation)
		px, py = p:getPosition()
		--ox, oy = vectorFromAngle(random(0,360),getLongRangeRadarRange()+1000)
		--ox, oy = vectorFromAngle(random(0,360),31000)	--workaround
		ox, oy = vectorFromAngle(random(0,360),p:getLongRangeRadarRange()+1000)
		harassFleet = spawnEnemies(px+ox,py+oy,difficulty)
		whatToDo = math.random(1,3)
		if whatToDo == 1 then
			for _, enemy in ipairs(harassFleet) do
				enemy:orderAttack(p)
			end
		elseif whatToDo == 2 then
			for _, enemy in ipairs(harassFleet) do
				enemy:orderAttack(randomPatrolStation)
			end
		else
			for _, enemy in ipairs(harassFleet) do
				enemy:orderRoaming()
			end
		end
		sporadicHarassTimer = delta + sporadicHarassInterval - (difficulty*30) - random(1,60)
	end
end

function playDefendUtopiaMsg()
	playSoundFile("sa_54_AuthMBDefend.wav")
	closestUtopiaPlayer:removeCustom(defendUtopiaMsgButton)
	closestUtopiaPlayer:removeCustom(defendUtopiaMsgButtonOps)
	closestUtopiaPlayer = nil
end

function afterPatrol(delta)
	plot1name = "afterPatrol"
	if not stationAsimov:isValid() then
		globalMessage("Asimov station destroyed")
		defeatTimer = 15
		plot1 = defeated
	end
	if not stationUtopiaPlanitia:isValid() then
		globalMessage("Utopia Planitia station destroyed")
		defeatTimer = 15
		plot1 = defeated
	end
	if not stationArmstrong:isValid() then
		globalMessage("Armstrong station destroyed")
		defeatTimer = 15
		plot1 = defeated
	end
	nuisanceCount = 0
	for _, enemy in ipairs(nuisanceList) do
		if enemy:isValid() then
			nuisanceCount = nuisanceCount + 1
		end
	end
	incursionCount = 0
	for _, enemy in ipairs(incursionList) do
		if enemy:isValid() then
			incursionCount = incursionCount + 1
		end
	end
	attack1count = 0
	for _, enemy in ipairs(attack1list) do
		if enemy:isValid() then
			attack1count = attack1count + 1
		end
	end
	attack2count = 0
	for _, enemy in pairs(attack2list) do
		if enemy:isValid() then
			attack2count = attack2count + 1
		end
	end
	attack3count = 0
	for _, enemy in ipairs(attack3list) do
		if enemy:isValid() then
			attack3count = attack3count + 1
		end
	end
	local enemy_ships = incursionCount + nuisanceCount + attack1count + attack2count + attack3count
	primaryOrders = string.format("Rid the area of remaining enemies. Combined sensors show %i ships",enemy_ships)
	if patrol_complete_message == nil then
		for pidx=1,32 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(string.format("You completed your patrol docking duties, but enemy ships still pollute the area. Be sure to clean those up. Combined sensor readings from area stations put the current count at %i enemy ships. Feel free to continue to dock to repair and replenish if desired. Oh yes, I almost forgot, you're still responsible for protecting stations Asimov, Armstrong and Utopia Planitia",enemy_ships),"Magenta")
			end
		end
		patrol_complete_message = "sent"
	end
	if enemy_ships == 0 then
		if missionLength > 3 then
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					p:addToShipLog("Stop patrol and Defend Utopia Planitia","Magenta")
				end
			end
			closestUtopiaPlayer = closestPlayerTo(stationUtopiaPlanitia)
			if closestUtopiaPlayer ~= nil then
				closestUtopiaPlayer_timer = play_button_expire_time
				stationUtopiaPlanitia:sendCommsMessage(closestUtopiaPlayer, "Audio message received, auto-transcribed to log, stored for playback: UTPLNT441")
				closestUtopiaPlayer:addToShipLog("[UTPLNT441](Utopia Planitia) Our long range sensors show a number of enemy ships approaching. Cease patrolling other stations and defend station Utopia Planitia","Yellow")
				if defendUtopiaMsgButton == nil then
					defendUtopiaMsgButton = "defendUtopiaMsgButton"
					closestUtopiaPlayer:addCustomButton("Relay",defendUtopiaMsgButton,"|> UTPLNT441",playDefendUtopiaMsg)
					defendUtopiaMsgButtonOps = "defendUtopiaMsgButtonOps"
					closestUtopiaPlayer:addCustomButton("Operations",defendUtopiaMsgButtonOps,"|> UTPLNT441",playDefendUtopiaMsg)
				end
			end
			stationUtopiaPlanitia:sendCommsMessage(closestUtopiaPlayer, "Our long range sensors show a number of enemy ships approaching. Cease patrolling other stations and defend station Utopia Planitia")
			primaryOrders = "Defend Utopia Planitia"
			waveDelayTimer = 120
			longWave = 0
			plot1 = defendUtopia
			removeGMFunction("Skip to defend U.P.")
		else
			playSoundFile("sa_54_AuthMBVictory.wav")
			victory("Human Navy")
		end
	end
end

function playUtopiaBreakMsg()
	playSoundFile("sa_54_AuthMBBreak.wav")
	closestMidWaveUtopiaPlayer:removeCustom(utopiaBreakMsgButton)
	closestMidWaveUtopiaPlayer:removeCustom(utopiaBreakMsgButtonOps)
	closestMidWaveUtopiaPlayer = nil
end

function defendUtopia(delta)
	plot1name = "defendUtopia"
	if not stationUtopiaPlanitia:isValid() then
		globalMessage("Utopia Planitia station destroyed")
		defeatTimer = 15
		plot1 = defeated
	end
	waveDelayTimer = waveDelayTimer - delta
	if longWave == 0 then
		if waveDelayTimer < 0 then
			longWave1List = spawnEnemies(utopiaPlanitiax+irandom(30000,40000),utopiaPlanitiay+irandom(-5000,5000),.5,"Kraylor")
			for _, enemy in ipairs(longWave1List) do
				enemy:orderFlyTowards(utopiaPlanitiax, utopiaPlanitiay)
			end
			waveDelayTimer = delta + 120
			longWave = 1
		end
	end
	if longWave == 1 then
		if waveDelayTimer < 0 then
			longWave2List = spawnEnemies(utopiaPlanitiax+irandom(-40000,-30000),utopiaPlanitiay+irandom(-5000,5000),.5,"Kraylor")
			for _, enemy in ipairs(longWave2List) do
				enemy:orderFlyTowards(utopiaPlanitiax, utopiaPlanitiay)
			end
			waveDelayTimer = delta + 120
			longWave = 2
		end
	end
	if longWave == 2 then
		if waveDelayTimer < 0 then
			wave1count = 0
			for _, enemy in ipairs(longWave1List) do
				if enemy:isValid() then
					wave1count = wave1count + 1
				end
			end
			wave2count = 0
			for _, enemy in ipairs(longWave2List) do
				if enemy:isValid() then
					wave2count = wave2count + 1
				end
			end
			if wave1count + wave2count == 0 then
				closestMidWaveUtopiaPlayer = closestPlayerTo(stationUtopiaPlanitia)
				if closestMidWaveUtopiaPlayer ~= nil then
					closestMidWaveUtopiaPlayer_timer = play_button_expire_time
					stationUtopiaPlanitia:sendCommsMessage(closestMidWaveUtopiaPlayer, "Audio message received, auto-transcribed to log, stored for playback: UTPLNT477")
					closestMidWaveUtopiaPlayer:addToShipLog("[UTPLNT477](Utopia Planitia) You have taken care of the closest enemies. Our extreme range sensors show more, but they should not arrive for a couple of minutes","Yellow")
					if utopiaBreakMsgButton == nil then
						utopiaBreakMsgButton = "utopiaBreakMsgButton"
						closestMidWaveUtopiaPlayer:addCustomButton("Relay",utopiaBreakMsgButton,"|> UTPLNT477",playUtopiaBreakMsg)
						utopiaBreakMsgButtonOps = "utopiaBreakMsgButtonOps"
						closestMidWaveUtopiaPlayer:addCustomButton("Operations",utopiaBreakMsgButtonOps,"|> UTPLNT477",playUtopiaBreakMsg)
					end
				end
				for pidx=1,8 do
					p = getPlayerShip(pidx)
					if p ~= nil and p:isValid() then
						p:addToShipLog("Nearest ships cleared. More to come shortly","Magenta")
					end
				end
				longWave = 3
				waveDelayTimer = delta + 120
			end
		end
	end
	if longWave == 3 then
		if waveDelayTimer < 0 then
			longWave3List = spawnEnemies(utopiaPlanitiax+irandom(-10000,10000),utopiaPlanitiay+irandom(30000,40000),1,"Kraylor")
			for _, enemy in ipairs(longWave3List) do
				enemy:orderFlyTowards(utopiaPlanitiax, utopiaPlanitiay)
			end
			waveDelayTimer = delta + 120
			longWave = 4
		end
	end
	if longWave == 4 then
		if waveDelayTimer < 0 then
			longWave4List = spawnEnemies(utopiaPlanitiax+irandom(-10000,10000),utopiaPlanitiay+irandom(30000,40000),2,"Kraylor")
			for _, enemy in ipairs(longWave4List) do
				enemy:orderFlyTowards(utopiaPlanitiax, utopiaPlanitiay)
			end
			waveDelayTimer = delta + 300
			longWave = 5
		end
	end
	if longWave == 5 then
		if waveDelayTimer < 0 then
			longWave5List = spawnEnemies(utopiaPlanitiax+irandom(-10000,10000),utopiaPlanitiay+irandom(30000,40000),1,"Kraylor")
			for _, enemy in ipairs(longWave5List) do
				enemy:orderFlyTowards(utopiaPlanitiax, utopiaPlanitiay)
			end
			waveDelayTimer = delta + 120
			longWave = 6
		end
	end
	if longWave == 6 then
		if waveDelayTimer < 0 then
			wave3count = 0
			for _, enemy in ipairs(longWave3List) do
				if enemy:isValid() then
					wave3count = wave3count + 1
				end
			end
			wave4count = 0
			for _, enemy in ipairs(longWave4List) do
				if enemy:isValid() then
					wave4count = wave4count + 1
				end
			end
			wave5count = 0
			for _, enemy in ipairs(longWave5List) do
				if enemy:isValid() then
					wave5count = wave5count + 1
				end
			end
			if wave3count + wave4count + wave5count == 0 then
				if difficulty > 1 then
					plot1 = destroyEnemyStronghold
					removeGMFunction("Skip to destroy S.C.")
				else
					victory("Human Navy")
				end
			end
		end
	end
end

function defeated(delta)
	defeatTimer = defeatTimer - delta
	if defeatTimer < 0 then
		victory("Kraylor")
	end
end

function destroyEnemyStronghold(delta)
	if lateEnemies == nil then
		lateEnemies = "placed"
		scarletx = random(120000,200000)
		scarlety = random(120000,200000)
		stationScarletCitadel = SpaceStation():setTemplate("Medium Station"):setFaction("Kraylor"):setCommsScript(""):setCommsFunction(commsStation)
		stationScarletCitadel:setPosition(scarletx,scarlety):setCallSign("Scarlet Citadel")
		wpRadius = 3000
		x, y = vectorFromAngle(0,wpRadius)
		wp13 = CpuShip():setFaction("Kraylor"):setposition(scarletx+x,scarlety+y):setTemplate("Defense platform"):setCallSign("WP-13")
		x, y = vectorFromAngle(90,wpRadius)
		wp45 = CpuShip():setFaction("Kraylor"):setposition(scarletx+x,scarlety+y):setTemplate("Defense platform"):setCallSign("WP-45")
		x, y = vectorFromAngle(180,wpRadius)
		wp33 = CpuShip():setFaction("Kraylor"):setposition(scarletx+x,scarlety+y):setTemplate("Defense platform"):setCallSign("WP-33")
		x, y = vectorFromAngle(270,wpRadius)
		wp57 = CpuShip():setFaction("Kraylor"):setposition(scarletx+x,scarlety+y):setTemplate("Defense platform"):setCallSign("WP-57")
		if difficulty > 2 then
			x, y = vectorFromAngle(45,wpRadius)
			wp62 = CpuShip():setFaction("Kraylor"):setposition(scarletx+x,scarlety+y):setTemplate("Defense platform"):setCallSign("WP-62")			
			x, y = vectorFromAngle(135,wpRadius)
			wp78 = CpuShip():setFaction("Kraylor"):setposition(scarletx+x,scarlety+y):setTemplate("Defense platform"):setCallSign("WP-78")			
			x, y = vectorFromAngle(225,wpRadius)
			wp25 = CpuShip():setFaction("Kraylor"):setposition(scarletx+x,scarlety+y):setTemplate("Defense platform"):setCallSign("WP-25")			
			x, y = vectorFromAngle(315,wpRadius)
			wp27 = CpuShip():setFaction("Kraylor"):setposition(scarletx+x,scarlety+y):setTemplate("Defense platform"):setCallSign("WP-27")			
		end
		strongholdDefense = spawnEnemies(scarletx-5000,scarlety-5000,1,"Kraylor")
		for _, enemy in ipairs(strongholdDefense) do
			enemy:orderDefendTarget(stationScarletCitadel)
		end
		strongholdOffense = spawnEnemies(scarletx-8000,scarlety-8000,1,"Kraylor")
		targetPlayer = closestPlayerTo(stationScarletCitadel)
		if targetPlayer:isValid() then
			for _, enemy in ipairs(strongholdOffense) do
				enemy:orderAttack(targetPlayer)
			end
			targetPlayer:addToShipLog(string.format("Enemy base nearby located in secctor %s. Fleet assembled near Utopia Planitia to assist if needed. Destroy base.",stationScarletCitadel:getSectorName()),"Magenta")
		end
		posse = spawnEnemies(utopiaPlanitiaX,utopiaPlanitiaY+8000,2,"Human Navy")
		primaryOrders = string.format("Destroy enemy base in sector %s",stationScarletCitadel:getSectorName())
		for _, friend in ipairs(posse) do
			friend:orderStandGround()
			if #posseShipNames > 0 then
				ni = math.random(1,#posseShipNames)
				friend:setCallSign(posseShipNames[ni])
				table.remove(posseShipNames,ni)
			end
		end
		scarletDanger = 1
		scarletTimer = 300
	end
	if stationScarletCitadel:isValid() then
		scarletTimer = scarletTimer - delta
		if scarletTimer < 0 then
			if scarletDanger > 0 then
				scarletTimer = delta + 300
				strongholdDefense = spawnEnemies(scarletx-5000,scarlety-5000,scarletDanger,"Kraylor")
				for _, enemy in ipairs(strongholdDefense) do
					enemy:orderDefendTarget(stationScarletCitadel)
				end
				strongholdOffense = spawnEnemies(scarletx-8000,scarlety-8000,scarletDanger,"Kraylor")
				targetPlayer = closestPlayerTo(stationScarletCitadel)
				if targetPlayer:isValid() then
					for _, enemy in ipairs(strongholdOffense) do
						enemy:orderAttack(targetPlayer)
					end
				end
				scarletDanger = scarletDanger - 0.1
			end
		end
	else
		victory("Human Navy")
	end
end
------------------------------------------------------------------
--	Second plot line: small enemy fleet followed by sick miner  --
------------------------------------------------------------------
function playAsimovSensorTechMessage()
	playSoundFile("sa_54_TorrinSensorTech.wav")
	closestPlayer:removeCustom(playMsgFromAsimovButton)
	closestPlayer:removeCustom(playMsgFromAsimovButtonOps)
	closestPlayer = nil
end

function nuisance(delta)
	if minerUpgrade then
		plot2 = nil
	end
	plot2name = "nuisance"
	if nuisanceSpawned == "ready" then
		nuisanceSpawned = "done"
		asimovx, asimovy = stationAsimov:getPosition()
		nuisanceList = spawnEnemies(asimovx+irandom(20000,30000),asimovx+irandom(20000,30000),.4,"Kraylor")
		for _, enemy in ipairs(nuisanceList) do
			enemy:orderFlyTowards(asimovx, asimovy)
		end
	end
	nuisanceTimer = nuisanceTimer - delta
	if nuisanceTimer < 0 then
		if nuisanceHelp == nil then
			nuisanceHelp = "complete"
			closestPlayer = closestPlayerTo(stationAsimov)
			if closestPlayer ~= nil then
				closestPlayer_timer = play_button_expire_time
				stationAsimov:sendCommsMessage(closestPlayer, "Audio message received, auto-transcribed into log, stored for playback: ASMVSNSR003")
				closestPlayer:addToShipLog("[ASMVSNSR003](Asimov sensor technician) Our long range sensors show enemies approaching","Yellow")
				if playMsgFromAsimovButton == nil then
					playMsgFromAsimovButton = "playMsgFromAsimovButton"
					closestPlayer:addCustomButton("Relay",playMsgFromAsimovButton,"|> ASMVSNSR003",playAsimovSensorTechMessage)
					playMsgFromAsimovButtonOps = "playMsgFromAsimovButtonOps"
					closestPlayer:addCustomButton("Operations",playMsgFromAsimovButtonOps,"|> ASMVSNSR003",playAsimovSensorTechMessage)
				end		
			end
		end
	end
	enemy_count = 0
	for _, enemy in ipairs(nuisanceList) do
		if enemy:isValid() then
			enemy_count = enemy_count + 1
		end
	end
	if enemy_count == 0 then
		if nuisanceAward == nil then
			nuisanceAward = "done"
			local p = getPlayerShip(-1)
			p:addReputationPoints(25.0)
			sickMinerTimer = random(90,120)
			plot2 = sickMiner
		end
	end
end

function playSickStationMessage()
	playSoundFile("sa_54_MinerSickRequest.wav")
	closestSickMinerPlayer:removeCustom(playMsgFromSickStationButton)
	closestSickMinerPlayer:removeCustom(playMsgFromSickStationButtonOps)
	closestSickMinerPlayer = nil
end

function sickMiner(delta)
	plot2name = "sickMiner"
	sickMinerTimer = sickMinerTimer - delta
	if sickMinerTimer < 0 then
		if sickMinerHelp == nil then
			sickMinerHelp = "done"
			sickMinerStationChoice = math.random(1,5)
			if sickMinerStationChoice == 1 then
				sickMinerStation = stationKrik
			elseif sickMinerStationChoice == 2 then
				sickMinerStation = stationKrak
			elseif sickMinerStationChoice == 3 then
				sickMinerStation = stationKruk
			elseif sickMinerStationChoice == 4 then
				sickMinerStation = stationGrasberg
			else
				sickMinerStation = stationImpala
			end
			plot2reminder = string.format("Pick up Joshua Kojack from %s in sector %s and take him to Bethesda",sickMinerStation:getCallSign(),sickMinerStation:getSectorName())
			closestSickMinerPlayer = closestPlayerTo(sickMinerStation)
			if closestSickMinerPlayer ~= nil then
				closestSickMinerPlayer_timer = play_button_expire_time
				sickMinerStation:sendCommsMessage(closestSickMinerPlayer, "Audio message received, auto-transcribed into log, stored for playback: MINSTN014")
				closestSickMinerPlayer:addToShipLog(string.format("[MINSTN014](%s in sector %s) Joshua Kojak has come down with something our autodoc can't handle. He's supposed to be helping us mine these asteroids, but he can't do us any good while he's sick. Can you transport him to Bethesda station? I hear they've got some clever doctors there that might help.",sickMinerStation:getCallSign(),sickMinerStation:getSectorName()),"Yellow")
				if playMsgFromSickStationButton == nil then
					playMsgFromSickStationButton = "playMsgFromSickStationButton"
					closestSickMinerPlayer:addCustomButton("Relay",playMsgFromSickStationButton,"|> MINSTN014",playSickStationMessage)
					playMsgFromSickStationButtonOps = "playMsgFromSickStationButtonOps"
					closestSickMinerPlayer:addCustomButton("Operations",playMsgFromSickStationButtonOps,"|> MINSTN014",playSickStationMessage)
				end				
			end
			sickMinerState = "sick on station"
			plot2 = getSickMinerFromStation
		end
	end
end

function playSickStationMessage2()
	playSoundFile("sa_54_MinerSickAboard.wav")
	sickMinerShip:removeCustom(playMsg2FromSickStationButton)
	sickMinerShip:removeCustom(playMsg2FromSickStationButtonOps)
end

function getSickMinerFromStation(delta)
	plot2name = "getSickMinerFromStation"
	if sickMinerState == "sick on station" then
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() and p:isDocked(sickMinerStation) then
				p.sickMinerAboard = true
				sickMinerState = "aboard player ship"
				sickMinerStation:sendCommsMessage(p,"Audio message received, auto-transcribed into log, stored for playback: MINSTN019")
				p:addToShipLog("[MINSTN019]Thanks for getting Joshua aboard. Please take him to Bethesda","Yellow")
				sickMinerShip = p
				if playMsg2FromSickStationButton == nil then
					playMsg2FromSickStationButton = "playMsg2FromSickStationButton"
					sickMinerShip:addCustomButton("Relay",playMsg2FromSickStationButton,"|> MINSTN019",playSickStationMessage2)
					playMsg2FromSickStationButtonOps = "playMsg2FromSickStationButtonOps"
					sickMinerShip:addCustomButton("Operations",playMsg2FromSickStationButtonOps,"|> MINSTN019",playSickStationMessage2)
				end
				sickMinerShip:addReputationPoints(15)
				plot2 = takeSickMinerToBethesda
			end
		end
	end
end

function playBethesdaStationMessage()
	playSoundFile("sa_54_BethesdaDoctor.wav")
	sickMinerShip:removeCustom(playMsgFromBethesdaButton)
	sickMinerShip:removeCustom(playMsgFromBethesdaButtonOps)
end

function takeSickMinerToBethesda(delta)
	plot2name = "takeSickMinerToBethesda"
	if sickMinerState == "aboard player ship" then
		if sickMinerShip:isDocked(stationBethesda) then
			sickMinerState = "at Bethesda"
			stationBethesda:sendCommsMessage(sickMinerShip,"Audio message received, auto-transcribed into log, stored for playback: BTHSDA002")
			sickMinerShip:addToShipLog("[BTHSDA002] Joshua Kojak is being treated. He shows every sign of recovering","Yellow")
			if playMsgFromBethesdaButton == nil then
				playMsgFromBethesdaButton = "playMsgFromBethesdaButton"
				sickMinerShip:addCustomButton("Relay",playMsgFromBethesdaButton,"|> BTHSDA002",playBethesdaStationMessage)
				playMsgFromBethesdaButtonOps = "playMsgFromBethesdaButtonOps"
				sickMinerShip:addCustomButton("Operations",playMsgFromBethesdaButtonOps,"|> BTHSDA002",playBethesdaStationMessage)
			end
			sickMinerShip:addReputationPoints(30)
			minerRecoveryTimer = random(90,120)
			plot2reminder = nil
			plot2 = minerRecovering
		end
	end
end

function playKojakThanksMessage()
	playSoundFile("sa_54_KojakThanks.wav")
	closestBethesdaPlayer:removeCustom(playMsgKojakButton)
	closestBethesdaPlayer:removeCustom(playMsgKojakButtonOps)
	closestBethesdaPlayer = nil
end
function minerRecovering(delta)
	plot2name = "minerRecovering"
	minerRecoveryTimer = minerRecoveryTimer - delta
	if minerRecoveryTimer < 0 then
		if sickMinerState == "at Bethesda" then
			closestBethesdaPlayer = closestPlayerTo(stationBethesda)
			if closestBethesdaPlayer == nil then
				closestBethesdaPlayer = getPlayerShip(-1)
			end
			stationBethesda:sendCommsMessage(closestBethesdaPlayer, "Audio message received, auto-transcribed into log, stored for playback: BTHSDA034")
			closestBethesdaPlayer:addToShipLog("[BTHSDA034](Joshua Kojak) Thanks for bringing me to Bethesda. I'm feeling much better. I'm transmitting my research on power systems and exotic metals. You may find it interesting. Mining leaves me lots of time for thinking","Yellow")
			if playMsgKojakButton == nil then
				closestBethesdaPlayer_timer = play_button_expire_time
				playMsgKojakButton = "playMsgKojakButton"
				closestBethesdaPlayer:addCustomButton("Relay",playMsgKojakButton,"|> BTHSDA034",playKojakThanksMessage)
				playMsgKojakButtonOps = "playMsgKojakButtonOps"
				closestBethesdaPlayer:addCustomButton("Operations",playMsgKojakButtonOps,"|> BTHSDA034",playKojakThanksMessage)
			end
			closestBethesdaPlayer:addReputationPoints(15.00)
			closestBethesdaPlayer.receivedMinerResearch = true
			sickMinerState = "transmitted research"
			minerScienceDiscoveryTimer = random(90,120)
			plot2 = minerScienceDiscovery
		end
	end
end
function minerScienceDiscovery(delta)
	plot2name = "minerScienceDiscovery"
	minerScienceDiscoveryTimer = minerScienceDiscoveryTimer - delta
	if minerScienceDiscoveryTimer < 0 then
		if sickMinerState == "transmitted research" then
			if closestBethesdaPlayer:isValid() and closestBethesdaPlayer.receivedMinerResearch then
				sickMinerState = "sent to engineer"
				scienceSendMessage = "scienceSendMessage"
				closestBethesdaPlayer:addCustomMessage("Science",scienceSendMessage,"While reading through Joshua Kojak's research, you discover a potential application to on-board ship systems. Click the 'Send to engineer' button to submit insight to engineering. You may find the button under the 'scanning' label")
				operationsSendMessage = "operationsSendMessage"
				closestBethesdaPlayer:addCustomMessage("Operations",operationsSendMessage,"While reading through Joshua Kojak's research, you discover a potential application to on-board ship systems. Click the 'Send to engineer' button to submit insight to engineering.")
				scienceSendButton = "scienceSendButton"
				closestBethesdaPlayer:addCustomButton("Science",scienceSendButton,"Send to engineer",insightToEngineer)
				operationsSendButton = "operationsSendButton"
				closestBethesdaPlayer:addCustomButton("Operations",operationsSendButton,"Send to engineer",insightToEngineer)
				engineerEvaluateMessageTimer = 30
				plot2 = minerEngineerEvaluate
			end
		end
	end
end
function minerEngineerEvaluate(delta)
	plot2name = "minerEngineerEvaluate"
	if sickMinerState == "sent to engineer" then
		engineerEvaluateMessageTimer = engineerEvaluateMessageTimer - delta
		if engineerEvaluateMessageTimer < 0 then
			if closestBethesdaPlayer:isValid() and closestBethesdaPlayer.receivedMinerResearch then
				closestBethesdaPlayer:removeCustom(scienceSendMessage)
				closestBethesdaPlayer:removeCustom(operationsSendMessage)
			end
		end
	end
	if sickMinerState == "sent to weapons" then
		if closestBethesdaPlayer:isValid() and closestBethesdaPlayer.receivedMinerResearch then
			engineerSendMessage = "engineerSendMessage"
			closestBethesdaPlayer:addCustomMessage("Engineering",engineerSendMessage,"The science officer sent you some thoughts on Joshua Kojak's research. You think it applies to beam weapon improvement. Click the 'Send to weapons' button to suggest changes to weapons")
			engineerPlusSendMessage = "engineerPlusSendMessage"
			closestBethesdaPlayer:addCustomMessage("Engineering+",engineerPlusSendMessage,"The science officer sent you some thoughts on Joshua Kojak's research. You think it applies to beam weapon improvement. Click the 'Send to weapons' button to suggest changes to weapons")
			engineerSendToWeaponsButton = "engineerSendToWeaponsButton"
			closestBethesdaPlayer:addCustomButton("Engineering",engineerSendToWeaponsButton,"Send to weapons",insightToWeapons)
			engineerPlusSendToWeaponsButton = "engineerPlusSendToWeaponsButton"
			closestBethesdaPlayer:addCustomButton("Engineering+",engineerPlusSendToWeaponsButton,"Send to weapons",insightToWeapons)
			weaponsEvaluateMessageTimer = 30
			plot2 = minerWeaponsApply
		end
	end
end
function insightToEngineer()
	sickMinerState = "sent to weapons"
	if closestBethesdaPlayer:isValid() and closestBethesdaPlayer.receivedMinerResearch then
		closestBethesdaPlayer:removeCustom(scienceSendButton)
		closestBethesdaPlayer:removeCustom(operationsSendButton)
	end
end
function minerWeaponsApply(delta)
	plot2name = "minerWeaponsApply"
	if sickMinerState == "sent to weapons" then
		weaponsEvaluateMessageTimer = weaponsEvaluateMessageTimer - delta
		if weaponsEvaluateMessageTimer < 0 then
			if closestBethesdaPlayer:isValid() and closestBethesdaPlayer.receivedMinerResearch then
				closestBethesdaPlayer:removeCustom(engineerSendMessage)
				closestBethesdaPlayer:removeCustom(engineerPlusSendMessage)
			end
		end
	end
	if sickMinerState == "sent to base" then
		if closestBethesdaPlayer:isValid() and closestBethesdaPlayer.receivedMinerResearch then
			weaponsSendMessage = "weaponsSendMessage"
			closestBethesdaPlayer:addCustomMessage("Weapons",weaponsSendMessage,"The engineer sent you some thoughts on Joshua Kojak's research. You know how to apply it to the beam weapons, but lack the tools to do it immediately. Click the 'Send to Utopia Planitia' button to transmit upgrade instructions to Utopia Planitia station")
			tacticalSendMessage = "tacticalSendMessage"
			closestBethesdaPlayer:addCustomMessage("Tactical",tacticalSendMessage,"The engineer sent you some thoughts on Joshua Kojak's research. You know how to apply it to the beam weapons, but lack the tools to do it immediately. Click the 'Send to Utopia Planitia' button to transmit upgrade instructions to Utopia Planitia station")
			weaponsSendButton = "weaponsSendButton"
			closestBethesdaPlayer:addCustomButton("Weapons",weaponsSendButton,"Send to Utopia Planitia",insightToBase)
			tacticalSendButton = "tacticalSendButton"
			closestBethesdaPlayer:addCustomButton("Tactical",tacticalSendButton,"Send to Utopia Planitia",insightToBase)
			weaponsDecideMessageTimer = 30
			plot2 = minerWeaponsDecide
		end
	end
end
function insightToWeapons()
	sickMinerState = "sent to base"
	if closestBethesdaPlayer:isValid() and closestBethesdaPlayer.receivedMinerResearch then
		closestBethesdaPlayer:removeCustom(engineerSendToWeaponsButton)
		closestBethesdaPlayer:removeCustom(engineerPlusSendToWeaponsButton)
	end
end
function minerWeaponsDecide(delta)
	plot2name = "minerWeaponsDecide"
	if sickMinerState == "sent to base" then
		weaponsDecideMessageTimer = weaponsDecideMessageTimer - delta
		if weaponsDecideMessageTimer < 0 then
			if closestBethesdaPlayer:isValid() and closestBethesdaPlayer.receivedMinerResearch then
				closestBethesdaPlayer:removeCustom(weaponsSendMessage)
				closestBethesdaPlayer:removeCustom(tacticalSendMessage)
			end
		end
	end
	if sickMinerState == "base processed" then
		if closestBethesdaPlayer:isValid() and closestBethesdaPlayer.receivedMinerResearch then
			stationUtopiaPlanitia:sendCommsMessage(closestBethesdaPlayer,"Thanks for the information. We can upgrade you next time you dock.")
			closestBethesdaPlayer:addToShipLog("[Utopia Planitia] Thanks for the information. We can upgrade you next time you dock","Magenta")
		end
		plot2 = nil
		minerUpgrade = true
		removeGMFunction("Start plot 2 sick Kojak")
	end
end
function insightToBase()
	sickMinerState = "base processed"
	if closestBethesdaPlayer:isValid() and closestBethesdaPlayer.receivedMinerResearch then
		closestBethesdaPlayer:removeCustom(weaponsSendButton)
		closestBethesdaPlayer:removeCustom(tacticalSendButton)
	end
end
------------------------------------------------------------
--	Third plot line: comparable fleet and Nabbit upgrade  --
------------------------------------------------------------
function playUtopiaPlanitiaSensorTechMessage()
	playSoundFile("sa_54_DuncanSensorTech.wav")
	closestIncursionPlayer:removeCustom(playUtopiaPlanitiaSensorMsgButton)
	closestIncursionPlayer:removeCustom(playUtopiaPlanitiaSensorMsgButtonOps)
	closestIncursionPlayer = nil
end

function incursion(delta)
	if nabbitUpgrade then
		plot3 = nil
	end
	plot3name = "incursion"
	if incursionSpawned == "ready" then
		incursionSpawned = "done"
		incursionList = spawnEnemies(utopiaPlanitiax+irandom(-30000,-20000),utopiaPlanitiay+irandom(20000,30000),1,"Ghosts")
	end
	incursionTimer = incursionTimer - delta
	if incursionTimer < 0 then
		if incursionHelp == nil then
			incursionHelp = "complete"
			closestIncursionPlayer = closestPlayerTo(stationUtopiaPlanitia)
			if closestIncursionPlayer == nil then
				closestIncursionPlayer = getPlayerShip(-1)
			end
			stationUtopiaPlanitia:sendCommsMessage(closestIncursionPlayer, "Audio message received, auto-transcribed into log, stored for playback: UTPLNT103")
			closestIncursionPlayer:addToShipLog("[UTPLNT103](Utopia Planitia sensor technician) Our long range sensors show enemies approaching","Yellow")
			if playUtopiaPlanitiaSensorMsgButton == nil then
				closestIncursionPlayer_timer = play_button_expire_time
				playUtopiaPlanitiaSensorMsgButton = "playUtopiaPlanitiaSensorMsgButton"
				closestIncursionPlayer:addCustomButton("Relay",playUtopiaPlanitiaSensorMsgButton,"|> UTPLNT103",playUtopiaPlanitiaSensorTechMessage)
				playUtopiaPlanitiaSensorMsgButtonOps = "playUtopiaPlanitiaSensorMsgButtonOps"
				closestIncursionPlayer:addCustomButton("Operations",playUtopiaPlanitiaSensorMsgButtonOps,"|> UTPLNT103",playUtopiaPlanitiaSensorTechMessage)
			end
		end
	end
	enemy_count = 0
	for _, enemy in ipairs(incursionList) do
		if enemy:isValid() then
			enemy_count = enemy_count + 1
		end
	end
	if enemy_count == 0 then
		if incursionAward == nil then
			incursionAward = "done"
			closestIncursionPlayer:addReputationPoints(50.0)
			plot3 = nabbitRideRequest
		end
	end
end

function nabbitRideRequest()
	plot3name = "nabbitRideRequest"
	nabbitStationChoice = math.random(1,5)
	if nabbitStationChoice == 1 then
		nabbitStation = stationHossam
	elseif nabbitStationChoice == 2 then
		nabbitStation = stationMalthus
	elseif nabbitStationChoice == 3 then
		nabbitStation = stationResearch19
	elseif nabbitStationChoice == 4 then
		nabbitStation = stationMadison
	else
		nabbitStation = stationShree
	end
	if nabbitStation:isValid() then
		closestNabbitPlayer = closestPlayerTo(nabbitStation)
		if closestNabbitPlayer == nil then
			closestNabbitPlayer = getPlayerShip(-1)
		end
		closestNabbitPlayer:addToShipLog(string.format("[%s in sector %s] Engineer Dan McNabbit requests a ride to Armstrong",nabbitStation:getCallSign(),nabbitStation:getSectorName()),"Magenta")
		plot3reminder = string.format("Pick up Dan McNabbit from %s in sector %s and take him to Armstrong",nabbitStation:getCallSign(),nabbitStation:getSectorName())
		plot3 = getNabbit
	else
		plot3 = nil
		removeGMFunction("Start p 3 McNabbit ride")
	end
end

function getNabbit(delta)
	plot3name = "getNabbit"
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if nabbitStation:isValid() then
				if p:isDocked(nabbitStation) then
					nabbitShip = p
					nabbitShip.nabbitAboard = true
					nabbitShip:addToShipLog("Engineer Dan McNabbit aboard and ready to go to Armstrong","Magenta")
					nabbitShip:addReputationPoints(5)
					plot3 = dropNabbit
				end
			else
				plot3 = nil
				plot3reminder = nil
				removeGMFunction("Start p 3 McNabbit ride")
			end
		end
	end
end

function playNabbitTune()
	playSoundFile("sa_54_NabbitTune.wav")
	nabbitShip:removeCustom(playNabbitTuneMsgButton)
	nabbitShip:removeCustom(playNabbitTuneMsgButtonOps)
end

function dropNabbit(delta)
	plot3name = "dropNabbit"
	if nabbitShip:isValid() and nabbitShip.nabbitAboard and stationArmstrong:isValid() then
		if nabbitShip:isDocked(stationArmstrong) then
			stationArmstrong:sendCommsMessage(nabbitShip,"Audio message received, auto-transcribed into log, stored for playback: ASTGDN038")
			nabbitShip:addToShipLog("[ASTGDN038](Dan McNabbit) Thanks for the ride. I've tuned your impulse engines en route. I transmitted my engine tuning parameters to Utopia Planitia. Expect faster impulse speeds","Yellow")
			nabbitShip:setImpulseMaxSpeed(nabbitShip:getImpulseMaxSpeed()*1.2)
			nabbitShip.nabbitUpgrade = true
			nabbitUpgrade = true
			nabbitShip:addReputationPoints(5)
			plot3 = nil
			plot3reminder = nil
			removeGMFunction("Start p 3 McNabbit ride")
			if playNabbitTuneMsgButton == nil then
				playNabbitTuneMsgButton = "playNabbitTuneMsgButton"
				nabbitShip:addCustomButton("Relay",playNabbitTuneMsgButton,"|> ASTGDN038",playNabbitTune)
				playNabbitTuneMsgButtonOps = "playNabbitTuneMsgButtonOps"
				nabbitShip:addCustomButton("Operations",playNabbitTuneMsgButtonOps,"|> ASTGDN038",playNabbitTune)
			end
		end
	end
end
-----------------------------------------------------------------------
--	Fourth plot line: better than comparable fleet, return stowaway  --
-----------------------------------------------------------------------
function attack1(delta)
	if lisbonUpgrade then
		plot4 = nil
	end
	plot4name = "attack1"
	if attack1spawned == "ready" then
		attack1spawned = "done"
		attack1list = spawnEnemies(armstrongx+irandom(-5000,5000),armstrongy+irandom(-45000,-40000),1.3,"Exuari")
		for _, enemy in ipairs(attack1list) do
			enemy:orderFlyTowards(armstrongx, armstrongy)
		end
	end
	attack1Timer = attack1Timer - delta
	if attack1Timer < 0 then
		if longRangeWarning == nil then
			longRangeWarning = "complete"
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					p:addToShipLog("Stations Asimov, Utopia Planitia and Armstrong say that their long range sensors no longer read properly beyond 30U. This implies enemy activity is preventing accurate sensor readings. We suggest you check with these stations periodically to see if their normal sensors have picked up any enemy activity","Magenta")
				end
			end
		end
	end
	enemy_count = 0
	for _, enemy in ipairs(attack1list) do
		if enemy:isValid() then
			enemy_count = enemy_count + 1
		end
	end
	if enemy_count == 0 then
		plot4 = stowawayMessage
	end
end

function playLisbonRequestMessage()
	playSoundFile("sa_54_BethesdaAdmin.wav")
	closestLisbonPlayer:removeCustom(playLisbonMsgButton)
	closestLisbonPlayer:removeCustom(playLisbonMsgButtonOps)
	closestLisbonPlayer = nil
end

function stowawayMessage()
	plot4name = "stowawayMessage"
	if stationBethesda ~= nil and stationBethesda:isValid() then
		closestLisbonPlayer = closestPlayerTo(stationBethesda)
		if closestLisbonPlayer == nil then
			closestLisbonPlayer = getPlayerShip(-1)
		end
		farthestTransport = transportList[1]
		for _, t in ipairs(transportList) do
			if t:isValid() then
				if distance(stationBethesda, t) > distance(stationBethesda, farthestTransport) then
					farthestTransport = t
				end
			end
		end
		stowawayTransport = farthestTransport
		stowawayName = stowawayTransport:getCallSign()
		stationBethesda:sendCommsMessage(closestLisbonPlayer,"Audio message received, auto-transcribed into log, stored for playback: BTHSDA271")
		closestLisbonPlayer:addToShipLog(string.format("[BTHSDA271] Commander Lisbon reports her child stowed away on a freighter. After extensive investigation, she believes Francis is aboard %s currently in sector %s\nShe requests a rendezvous with the freighter to bring back her child",stowawayName,stowawayTransport:getSectorName()),"Yellow")
		if playLisbonMsgButton == nil then
			closestLisbonPlayer_timer = play_button_expire_time
			playLisbonMsgButton = "playLisbonMsgButton"
			closestLisbonPlayer:addCustomButton("Relay",playLisbonMsgButton,"|> BTHSDA271",playLisbonRequestMessage)
			playLisbonMsgButtonOps = "playLisbonMsgButtonOps"
			closestLisbonPlayer:addCustomButton("Operations",playLisbonMsgButtonOps,"|> BTHSDA271",playLisbonRequestMessage)
		end
		plot4 = getStowaway
		plot4reminder = string.format("Retrieve Francis from freighter %s last reported in sector %s and return child to station Bethesda",stowawayName,stowawayTransport:getSectorName())
	else
		plot4reminder = nil
		plot4 = nil
	end
end

function getStowaway(delta)
	plot4name = "getStowaway"
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if distance(stowawayTransport,p) < 500 then
				p.francisAboard = true
				francisShip = p
				francisShip:addToShipLog("The stowaway, Francis, is aboard. Commander Lisbon awaits at Bethesda","Magenta")
				plot4reminder = string.format("%s: Return Commander Lisbon's child to station Bethesda",francisShip:getCallSign())
				plot4 = returnStowaway
			end
		end
	end
	if not stowawayTransport:isValid() then
		plot4 = nil
		plot4reminder = nil
	end
end

function returnStowaway(delta)
	plot4name = "returnStowaway"
	if francisShip:isValid() then
		if stationBethesda ~= nil and stationBethesda:isValid() then
			if francisShip:isDocked(stationBethesda) and francisShip.francisAboard then
				francisShip:addToShipLog("[Commander Lisbon] Thanks for bringing Francis back. I am entrusting you with my beam system cooling algorithm research. Take it to station Utopia Planitia so that they can decrypt it and it may be applied to human navy ships","Magenta") 
				plot4 = deliverAlgorithm
				plot4reminder = string.format("%s: Deliver Commander Lisbon's encrypted beam system cooling algorithm to station Utopia Planitia",francisShip:getCallSign())
				francisShip.lisbonAlgorithm = true
			end
		else
			plot4 = nil
			plot4reminder = nil
		end
	else
		plot4 = nil
		plot4reminder = nil
	end
end

function deliverAlgorithm(delta)
	plot4name = "deliverAlgorithm"
	if francisShip:isValid() then
		if francisShip:isDocked(stationUtopiaPlanitia) then
			if francisShip.lisbonAlgorithm then
				francisShip:addToShipLog("[Utopia Planitia] Received Commander Lisbon's beam cooling research. Upgrade available to human navy ships","Magenta")
				lisbonUpgrade = true
				plot4 = nil
				plot4reminder = nil
			end
		end
	end
end
-----------------------------------------------------
--	Fifth plot line: better than comparable fleet  --
-----------------------------------------------------
function attack2(delta)
	plot5name = "atack2"
	if attack2spawned == "ready" then
		attack2list = spawnEnemies(asimovx+irandom(-45000,-40000),asimovy+irandom(-5000,5000),1.6,"Kraylor")
		attack2spawned = "done"
		for _, enemy in ipairs(attack2list) do
			enemy:orderFlyTowards(asimovx, asimovy)
		end
	end
	enemy_count = 0
	for _, enemy in ipairs(attack2list) do
		if enemy:isValid() then
			enemy_count = enemy_count + 1
		end
	end
	if enemy_count == 0 then
		plot5 = nil
	end
end
--------------------------------------
--	Eleventh plot line: Jump start  --
--------------------------------------
function jumpStart(delta)
	plot11name = "jumpStart"
	jumpStartTimer = jumpStartTimer - delta
	if jumpStartTimer < 0 then
		cp = closestPlayerTo(stationAsimov)
		x, y = cp:getPosition()
		objList = getObjectsInRadius(x, y, 30000)
		nebulaList = {}
		for _, obj in ipairs(objList) do
			if obj.typeName == "Nebula" then
				table.insert(nebulaList,obj)
			end
		end
		plot11name = "jumpStart - nebula list built"
		if #nebulaList > 0 then
			dist2cp = 999999
			for nidx=1,#nebulaList do
				n2cp = distance(cp,nebulaList[nidx])
				if n2cp < dist2cp then
					nebAmbush = nebulaList[nidx]
					dist2cp = n2cp
				end
			end
			ax, ay = nebAmbush:getPosition()
			if distance(cp, nebAmbush) < 5000 then
				ax, ay = vectorFromAngle(random(0,360),15000)
				ax = x + ax
				ay = y + ay				
			end
		else
			ax, ay = vectorFromAngle(random(0,360),15000)
			ax = x + ax
			ay = y + ay
		end
		jAsimov = spawnEnemies(ax, ay, .5)
		for _, enemy in ipairs(jAsimov) do
			enemy:orderFlyTowards(asimovx,asimovy)
		end
		jPlayer = spawnEnemies(ax, ay, .5)
		for _, enemy in ipairs(jPlayer) do
			enemy:orderAttack(cp)
		end
		plot11 = nil
		plot11name = nil
	end
end
---------------------------------------------
--	Tenth plot line: ambush from nebula 2  --
---------------------------------------------
function attack5(delta)
	plot10name = "atack5"
	if attack5Timer == nil then
		attack5Timer = random(20,50)
	end
	if attack5spawned == "ready" then
		attack5list = spawnEnemies(neb2x,neb2y,1.8,"Kraylor")
		attack5spawned = "done"
		for _, enemy in ipairs(attack5list) do
			enemy:orderStandGround()
			if difficulty > 1 then
				enemy:setWarpDrive(true)
				enemy:setWarpSpeed(750)
			end
		end
		plot10 = ambush5
	end
end

function ambush5(delta)
	plot10name = "ambush4"
	attack5Timer = attack5Timer - delta
	if attack5Timer < 0 then
		p = closestPlayerTo(neb2)
		if p ~= nil then
			pDist = distance(p,neb2)
			if math.random() > pDist/30000 then
				for _, enemy in ipairs(attack5list) do
					enemy:orderAttack(p)
				end
				plot10 = pursue5
			else
				attack5Timer = delta + 10
			end
		end		
		enemy_count = 0
		for _, enemy in ipairs(attack5list) do
			if enemy:isValid() then
				enemy_count = enemy_count + 1
			end
		end
		if enemy_count == 0 then
			plot10 = nil
		end
	end	
end

function pursue5()
	plot10name = "pursue4"
	enemy_count = 0
	for _, enemy in ipairs(attack5list) do
		if enemy:isValid() then
			enemy_count = enemy_count + 1
		end
	end
	if enemy_count == 0 then
		plot10 = nil
	end
end
---------------------------------------------
--	Ninth plot line: ambush from nebula 1  --
---------------------------------------------
function attack4(delta)
	plot9name = "atack4"
	if attack4Timer == nil then
		attack4Timer = random(20,50)
	end
	if attack4spawned == "ready" then
		attack4list = spawnEnemies(neb1x,neb1y,1.6,"Kraylor")
		attack4spawned = "done"
		for _, enemy in ipairs(attack4list) do
			enemy:orderStandGround()
			if difficulty > 1 then
				enemy:setWarpDrive(true)
				enemy:setWarpSpeed(750)
			end
		end
		--eval1dist = distance(neb1,stationAsimov)
		plot9 = ambush4
	end
end

function ambush4(delta)
	plot9name = "ambush4"
	attack4Timer = attack4Timer - delta
	if attack4Timer < 0 then
		p = closestPlayerTo(neb1)
		if p ~= nil then
			pDist = distance(p,neb1)
			if math.random() > pDist/30000 then
				for _, enemy in ipairs(attack4list) do
					enemy:orderAttack(p)
				end
				plot9 = pursue4
			else
				attack4Timer = delta + 10
			end
		end		
		enemy_count = 0
		for _, enemy in ipairs(attack4list) do
			if enemy:isValid() then
				enemy_count = enemy_count + 1
			end
		end
		if enemy_count == 0 then
			plot9 = nil
		end
	end
end

function pursue4()
	plot9name = "pursue4"
	enemy_count = 0
	for _, enemy in ipairs(attack4list) do
		if enemy:isValid() then
			enemy_count = enemy_count + 1
		end
	end
	if enemy_count == 0 then
		plot9 = nil
	end
end
----------------------------------------------------------------
--	Eighth plot line: geometric fleet pincers, strap on tube  --
----------------------------------------------------------------
function attack3(delta)
	plot8name = "atack3"
	if attack3spawned == "ready" then
		asimovx, asimovy = stationAsimov:getPosition()
		asimovDistance = random(20000,30000)
		avx, avy = vectorFromAngle(random(0,360),asimovDistance)
		attack3list = spawnEnemies(asimovx+avx,asimovy+avy,1,"Kraylor")
		attack3spawned = "done"
		for _, enemy in ipairs(attack3list) do
			enemy:orderFlyTowards(asimovx, asimovy)
		end
		if asimov8thWarning == nil then
			asimov8thWarning = "done"
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					p:addToShipLog(string.format("[Asimov] Our sensors show enemies approximately %.2f units away",asimovDistance/1000),"Magenta")
				end
			end
		end
		if difficulty >= 1 then
			armstrongDistance = random(35000,45000)
			arx, ary = vectorFromAngle(random(0,360),armstrongDistance)
			temp3list = spawnEnemies(armstrongx+arx,armstrongy+ary,.667,"Ghosts")
			for _, enemy in ipairs(temp3list) do
				enemy:orderFlyTowards(armstrongx,armstrongy)
				table.insert(attack3list,enemy)
			end
			if armstrong8thWarning == nil then
				armstrong8thWarning = "done"
				for pidx=1,8 do
					p = getPlayerShip(pidx)
					if p ~= nil and p:isValid() then
						p:addToShipLog(string.format("[Armstrong] Our long range sensors show enemies approximately %.2f units away",armstrongDistance/1000),"Magenta")
					end
				end
			end
		end
		if difficulty >= 2 then
			utopiaDistance = random(50000,60000)
			upx, upy = vectorFromAngle(random(0,360),utopiaDistance)
			temp4list = spawnEnemies(utopiaPlanitiax+upx,utopiaPlanitiay+upy,.5,"Ktlitans")
			for _, enemy in ipairs(temp4list) do
				table.insert(attack3list,enemy)
			end
			if utopia8thWarning == nil then
				utopia8thWarning = "done"
				for pidx=1,8 do
					p = getPlayerShip(pidx)
					if p ~= nil and p:isValid() then
						p:addToShipLog(string.format("[Utopia Planitia] Our long range sensors show enemies approximately %.2f units away",utopiaDistance/1000),"Magenta")
					end
				end
			end
		end
	end
	enemy_count = 0
	for _, enemy in ipairs(attack3list) do
		if enemy:isValid() then
			enemy_count = enemy_count + 1
		end
	end
	if enemy_count == 0 then
		plot8 = chooseTubeAddStation
	end
end

function chooseTubeAddStation()
	if tubeAddStationChoose == nil then
		tubeAddStationChoose = "done"
		randomTubeAddStation = math.random(1,5)
		if randomTubeAddStation == 1 then
			tubeAddStation = stationOBrien
		elseif randomTubeAddStation == 2 then
			tubeAddStation = stationCyrus
		elseif randomTubeAddStation == 3 then
			tubeAddStation = stationPanduit
		elseif randomTubeAddStation == 4 then
			tubeAddStation = stationOkun
		else
			tubeAddStation = stationSpot
		end
	end
	plot8 = inheritanceMessage
end

function inheritanceMessage()
	if messageOnInheritance == nil then
		messageOnInheritance = "done"
		if tubeAddStation:isValid() then
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					p:addToShipLog(string.format("Sheila Long, A former naval officer recenly perished. Among her personal effects she left a data store for the academy on station Asimov. Her personal effects are located on station %s in sector %s. Please dock and pick up the data store and transport it to station Asimov",tubeAddStation:getCallSign(),tubeAddStation:getSectorName()),"Magenta")
					plot8reminder = string.format("Get Sheila Long's package from %s in sector %s and take to station Asimov",tubeAddStation:getCallSign(),tubeAddStation:getSectorName())
				end
			end
			plot8 = dockWithTubeAddStation
		else
			plot8 = nil
			plot8reminder = nil
		end
	end
end

function dockWithTubeAddStation(delta)
	if tubeAddStation:isValid() then
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() and p:isDocked(tubeAddStation) then
				p:addToShipLog("Sheila Long's package for station Asimov is aboard","Magenta")
				p.sheilaLongPackage = true
				plot8 = dockWithAsimovForTubeAdd
				return
			end
		end
	else
		plot8 = nil
		plot8reminder = nil
	end
end

function dockWithAsimovForTubeAdd(delta)
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p~= nil and p:isValid() and p:isDocked(stationAsimov) then
			p:addToShipLog("Sheila Long's package received. The archive curator discovered some research on weapons systems miniaturization in the data store. Utopia Planitia received the information and stated that they believe they can add an extra homing missile weapons tube to any ship in the fleet if the ship will dock with Utopia Planitia","Magenta")
			addTubeUpgrade = true
			plot8 = nil
			plot8reminder = nil
		end
	end
end

function flakyTube(delta)
	if resetFlakyTubeTimer then
		flakyTubeTimer = delta + random(150,450)
		resetFlakyTubeTimer = false
	end
	flakyTubeTimer = flakyTubeTimer - delta
	if flakyTubeTimer < 0 then
		if flakyTubeVictim == nil then
			lowestVictim = 999
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() and p.addTubeUpgrade then
					if p.flakyTubeCount < lowestVictim then
						nextVictim = p
						lowestVictim = p.flakyTubeCount
					end
				end
			end
			flakyTubeVictim = nextVictim
			flakyTubeVictim.tubeFixed = false
			originalTubes = flakyTubeVictim:getWeaponTubeCount()
			newTubes = originalTubes - 1
			flakyTubeVictim:setWeaponTubeCount(newTubes)
			flakyTubeVictim.flakyTubeCount = flakyTubeVictim.flakyTubeCount + 1
			failedTubeMessage = "failedTubeMessage"
			flakyTubeVictim:addCustomMessage("Weapons",failedTubeMessage,"Automated systems removed our new weapons tube due to malfunction. Technicians investigating")
			failedTubeMessageTactical = "failedTubeMessageTactical"
			flakyTubeVictim:addCustomMessage("Tactical",failedTubeMessageTactical,"Automated systems removed our new weapons tube due to malfunction. Technicians investigating")
		else
			if fixedTubeButton == nil then
				fixedTubeMessage = "fixedTubeMessage"
				flakyTubeVictim:addCustomMessage("Weapons",fixedTubeMessage,"Technicians fixed the new tube. Click 'Redeploy' button to enable")
				fixedTubeMessageTactical = "fixedTubeMessageTactical"
				flakyTubeVictim:addCustomMessage("Tactical",fixedTubeMessageTactical,"Technicians fixed the new tube. Click 'Redeploy' button to enable")
				fixedTubeButton = "fixedTubeButton"
				flakyTubeVictim:addCustomButton("Weapons",fixedTubeButton,"Redeploy",redeployTube)
				fixedTubeButtonTactical = "fixedTubeButtonTactical"
				flakyTubeVictim:addCustomButton("Tactical",fixedTubeButtonTactical,"Redeploy",redeployTube)
			end
		end
		flakyTubeTimer = delta + random(150,450)
	end
end

function redeployTube()
	flakyTubeVictim.tubeFixed = true
	originalTubes = flakyTubeVictim:getWeaponTubeCount()
	newTubes = originalTubes + 1
	flakyTubeVictim:setWeaponTubeCount(newTubes)
	flakyTubeVictim:setWeaponTubeExclusiveFor(originalTubes, "Homing")
	flakyTubeVictim:removeCustom(fixedTubeButton)
	flakyTubeVictim:removeCustom(fixedTubeButtonTactical)
	resetFlakyTubeTimer = true
	fixedTubeButton = nil
	flakyTubeVictim = nil
end
------------------------------------------------------------------
--	Seventh plot line - ambush for time constrained short game  --
------------------------------------------------------------------
function beforeAmbush(delta)
	plot7name = "before ambush"
	gameTimeLimit = gameTimeLimit - delta
	if gameTimeLimit < ambushTime then
		plot7 = duringAmbush
	end
end

function duringAmbush(delta)
	plot7name = "during ambush"
	closestToAsimov = closestPlayerTo(stationAsimov)
	if closestToAsimov == nil then
		closestToAsimov = getPlayerShip(-1)
	end
	px, py = closestToAsimov:getPosition()
	ambushList = spawnEnemies(px-irandom(1000,7000),py-irandom(1000,7000),1.5,"Exuari")
	for _, enemy in ipairs(ambushList) do
		enemy:orderAttack(closestToAsimov)
	end
	plot7 = afterAmbush
end

function afterAmbush(delta)
	gameTimeLimit = gameTimeLimit - delta
	if gameTimeLimit < 0 then
		playSoundFile("sa_54_AuthMBVictory.wav")
		victory("Human Navy")	
	end
end
-------------------------------------------------------------------------
--	Anchor artifacts (plotArt): find, scan, retrieve anchor artifacts  --
-------------------------------------------------------------------------
function unscannedAnchors(delta)
	plotArtName = "unscannedAnchors"
	if artAnchor1:isScannedByFaction("Human Navy") and artAnchor2:isScannedByFaction("Human Navy") then
		artAnchor1:allowPickup(true)
		artAnchor2:allowPickup(true)		
		plotArt = scannedAnchors
	end
	trackArtAnchors()
end

function playArtSound()
	playSoundFile("sa_54_UPScienceGet.wav")
	artSoundShip:removeCustom(artSoundButton)
	artSoundShip:removeCustom(artSoundButtonOps)
end

function scannedAnchors(delta)
	plotArtName = "scannedAnchors"
	trackArtAnchors()
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if p.artAnchor1 or p.artAnchor2 then
				p:addToShipLog("[UTPLNT116](Utopia Planitia) Scanned artifacts show promise for ship systems improvement. Recommend retrieval","Yellow")
				plotArt = suggestRetrieveAnchors
				if artSoundButton == nil then
					artSoundButton = "artSoundButton"
					artSoundShip = p
					stationUtopiaPlanitia:sendCommsMessage(artSoundShip,"Audio message received, stored for playback: UTPLNT116")
					artSoundShip:addCustomButton("Relay",artSoundButton,"|> UTPLNT116",playArtSound)
					artSoundButtonOps = "artSoundButtonOps"
					artSoundShip:addCustomButton("Operations",artSoundButtonOps,"|> UTPLNT116",playArtSound)
				end
			end
		end
	end
end

function suggestRetrieveAnchors(delta)
	plotArtName = "suggestRetrieveAnchors"
	trackArtAnchors()
	if not artAnchor1:isValid() and not artAnchor2:isValid() then
		anchorsAboardTimer = 30
		plotArt = anchorsAboard
	end
end

function anchorsAboard(delta)
	plotArtName = "anchorsAboard"
	anchorsAboardTimer = anchorsAboardTimer - delta
	if anchorsAboardTimer < 0 then
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if p.artAnchor1 or p.artAnchor2 then
					p:addToShipLog("[Utopia Planitia] Bring artifacts to Utopia Planitia and we can improve ship maneuverability","Magenta")
					plotArt = bringToStation
				end
			end
		end
	end
end

function bringToStation(delta)
	plotArtName = "bringToStation"
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if p:isDocked(stationUtopiaPlanitia) and p.artAnchor1 then
				stationUtopiaPlanitia.artAnchor1 = true
			end
			if p:isDocked(stationUtopiaPlanitia) and p.artAnchor2 then
				stationUtopiaPlanitia.artAnchor2 = true
			end
		end
	end
	if stationUtopiaPlanitia.artAnchor1 and stationUtopiaPlanitia.artAnchor2 then
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p~= nil and p:isValid() then
				p:addToShipLog("[Utopia Planitia] We received the artifacts. We can improve ship maneuverability next time you dock","Magenta")
			end
		end
		artAnchorUpgrade = true
		plotArt = nil
	end
end

function trackArtAnchors()
	if artAnchor1:isValid() then
		closestArt1player = closestPlayerTo(artAnchor1)
		if closestArt1player == nil then
			closestArt1player = getPlayerShip(-1)
		end
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if p == closestArt1player then
					p.artAnchor1 = true
				else
					p.artAnchor1 = false
				end
			end
		end
	end
	if artAnchor2:isValid() then
		closestArt2player = closestPlayerTo(artAnchor2)
		if closestArt2player == nil then
			closestArt2player = getPlayerShip(-1)
		end
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if p == closestArt2player then
					p.artAnchor2 = true
				else
					p.artAnchor2 = false
				end
			end
		end
	end
end

----------------------------------
--	Game master (GM) functions  --
----------------------------------
function initiatePlot2()
	nuisanceSpawned = "ready"
	nuisanceTimer = random(30,90)
	plot2 = nuisance
	removeGMFunction("Start plot 2 sick Kojak")
end
function initiatePlot3()
	incursionSpawned = "ready"
	incursionTimer = random(30,90)
	plot3 = incursion
	removeGMFunction("Start p 3 McNabbit ride")
end
function initiatePlot4()
	attack1spawned = "ready"
	attack1Timer = random(40,120)
	plot4 = attack1
	removeGMFunction("St p4 Lisbon's stowaway")
end
function initiatePlot5()
	attack2spawned = "ready"
	plot5 = attack2
	removeGMFunction("Start plot 5")
end
function initiatePlot8()
	attack3spawned = "ready"
	plot8 = attack3
	removeGMFunction("Strt plot 8 Sheila dies")
end
function initiatePlot9()
	attack4spawned = "ready"
	plot9 = attack4
	removeGMFunction("Start plot 9 ambush")
end
function initiatePlot10()
	attack5spawned = "ready"
	plot10 = attack5
	removeGMFunction("Start plot 10 ambush")
end
function skipToDefendUP()
	artAnchorUpgrade = true
	longWave = 0
	minerUpgrade = true
	nabbitUpgrade = true
	lisbonUpgrade = true
	waveDelayTimer = 120
	plot1 = defendUtopia	
	removeGMFunction("Skip to defend U.P.")
end
function skipToDestroySC()
	artAnchorUpgrade = true
	longWave = 0
	minerUpgrade = true
	nabbitUpgrade = true
	lisbonUpgrade = true
	waveDelayTimer = 120
	plot1 = destroyEnemyStronghold	
	removeGMFunction("Skip to destroy S.C.")
end
------------------------------------
--	Generic or utility functions  --
------------------------------------
function expirePlayButtons(delta)
	if closestUtopiaPlayer ~= nil then
		closestUtopiaPlayer_timer = closestUtopiaPlayer_timer - delta
		if closestUtopiaPlayer_timer < 0 then
			closestUtopiaPlayer:removeCustom(defendUtopiaMsgButton)
			closestUtopiaPlayer:removeCustom(defendUtopiaMsgButtonOps)
			closestUtopiaPlayer = nil
		end
	end
	if closestMidWaveUtopiaPlayer ~= nil then
		closestMidWaveUtopiaPlayer_timer = closestMidWaveUtopiaPlayer_timer - delta
		if closestMidWaveUtopiaPlayer_timer < 0 then
			closestMidWaveUtopiaPlayer:removeCustom(utopiaBreakMsgButton)
			closestMidWaveUtopiaPlayer:removeCustom(utopiaBreakMsgButtonOps)
			closestMidWaveUtopiaPlayer = nil
		end
	end
	if closestPlayer ~= nil then
		closestPlayer_timer = closestPlayer_timer - delta
		if closestPlayer_timer < 0 then
			closestPlayer:removeCustom(playMsgFromAsimovButton)
			closestPlayer:removeCustom(playMsgFromAsimovButtonOps)
			closestPlayer = nil
		end
	end
	if closestSickMinerPlayer ~= nil then
		closestSickMinerPlayer_timer = closestSickMinerPlayer_timer - delta
		if closestSickMinerPlayer_timer < 0 then
			closestSickMinerPlayer:removeCustom(playMsgFromSickStationButton)
			closestSickMinerPlayer:removeCustom(playMsgFromSickStationButtonOps)
			closestSickMinerPlayer = nil
		end
	end
	if closestBethesdaPlayer ~= nil then
		closestBethesdaPlayer_timer = closestBethesdaPlayer_timer - delta
		if closestBethesdaPlayer_timer < 0 then
			closestBethesdaPlayer:removeCustom(playMsgKojakButton)
			closestBethesdaPlayer:removeCustom(playMsgKojakButtonOps)
			closestBethesdaPlayer = nil
		end
	end
	if closestIncursionPlayer ~= nil then
		closestIncursionPlayer_timer = closestIncursionPlayer_timer - delta
		if closestIncursionPlayer_timer < 0 then
			closestIncursionPlayer:removeCustom(playUtopiaPlanitiaSensorMsgButton)
			closestIncursionPlayer:removeCustom(playUtopiaPlanitiaSensorMsgButtonOps)
			closestIncursionPlayer = nil
		end
	end
	if closestLisbonPlayer ~= nil then
		closestLisbonPlayer_timer = closestLisbonPlayer_timer - delta
		if closestLisbonPlayer_timer < 0 then
			closestLisbonPlayer:removeCustom(playLisbonMsgButton)
			closestLisbonPlayer:removeCustom(playLisbonMsgButtonOps)
			closestLisbonPlayer = nil
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
		shipTemplateType = irandom(1,17)
		while stsl[shipTemplateType] > enemyStrength * 1.1 + 5 do
			shipTemplateType = irandom(1,17)
		end		
		ship = CpuShip():setFaction(enemyFaction):setTemplate(stnl[shipTemplateType]):orderRoaming()
		enemyPosition = enemyPosition + 1
		if deployConfig < 50 then
			ship:setPosition(xOrigin+fleetPosDelta1x[enemyPosition]*sp,yOrigin+fleetPosDelta1y[enemyPosition]*sp)
		else
			ship:setPosition(xOrigin+fleetPosDelta2x[enemyPosition]*sp,yOrigin+fleetPosDelta2y[enemyPosition]*sp)
		end
		table.insert(enemyList, ship)
		ship:setCallSign(generateCallSign(nil,enemyFaction))
		enemyStrength = enemyStrength - stsl[shipTemplateType]
	end
	return enemyList
end

function playerPower()
	playerShipScore = 0
	for p5idx=1,8 do
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

function healthCheck(delta)
	healthCheckTimer = healthCheckTimer - delta
	if healthCheckTimer < 0 then
		for pidx=1,8 do
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
					end
					if fatalityChance > 0 then
						crewFate(p,fatalityChance)
					end
				else
					if random(1,100) <= (4 - difficulty) then
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
function relayStatus(delta)
	local limit_minutes = nil
	local limit_seconds = nil
	local limit_status = "Game Timer"
	local leg_average = 0
	local mission_status = nil
	for pidx=1,8 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if playWithTimeLimit then
				limit_minutes = math.floor(gameTimeLimit/60)
				limit_seconds = math.floor(gameTimeLimit%60)
				limit_status = "Game Timer"
				if limit_minutes <= 0 then
					limit_status = string.format("%s %i",limit_status,limit_seconds)
				else
					limit_status = string.format("%s %i:%.2i",limit_status,limit_minutes,limit_seconds)
				end
				if p:hasPlayerAtPosition("Relay") then
					p.limit_status = "limit_status"
					p:addCustomInfo("Relay",p.limit_status,limit_status)
				end
				if p:hasPlayerAtPosition("Operations") then
					p.limit_status_ops = "limit_status_ops"
					p:addCustomInfo("Operations",p.limit_status_ops,limit_status)
				end
			else
				if patrolComplete then
					if p.mission_status ~= nil then
						p:removeCustom(p.mission_status)
						p.mission_status = nil
					end
					if p.mission_status_ops ~= nil then
						p:removeCustom(p.mission_status_ops)
						p.mission_status_ops = nil
					end
				else
					leg_average = (p.patrolLegAsimov + p.patrolLegUtopiaPlanitia + p.patrolLegArmstrong)/3
					mission_status = string.format("%i%% Complete",math.floor(leg_average/patrolGoal*100))
					if p.patrolLegArmstrong ~= p.patrolLegAsimov or p.patrolLegUtopiaPlanitia ~= p.patrolLegArmstrong then
						if p.patrolLegArmstrong == p.patrolLegAsimov then
							if p.patrolLegArmstrong > p.patrolLegUtopiaPlanitia then
								mission_status = string.format("%s -Utopia Planitia",mission_status)
							else
								mission_status = string.format("%s +Utopia Planitia",mission_status)
							end
						elseif p.patrolLegArmstrong == p.patrolLegUtopiaPlanitia then
							if p.patrolLegArmstrong > p.patrolLegAsimov then
								mission_status = string.format("%s -Asimov",mission_status)
							else
								mission_status = string.format("%s +Asimov",mission_status)
							end
						else
							if p.patrolLegAsimov > p.patrolLegArmstrong then
								mission_status = string.format("%s -Armstrong",mission_status)
							else
								mission_status = string.format("%s +Armstrong",mission_status)
							end
						end
					end
					if p:hasPlayerAtPosition("Relay") then
						p.mission_status = "mission_status"
						p:addCustomInfo("Relay",p.mission_status,mission_status)
					end
					if p:hasPlayerAtPosition("Operations") then
						p.mission_status_ops = "mission_status_ops"
						p:addCustomInfo("Operations",p.mission_status_ops,mission_status)
					end
					local shield_percentage = nil
					if stationAsimov ~= nil and stationAsimov:isValid() then
						if stationAsimov.telemetry then
							shield_percentage =  stationAsimov:getShieldLevel(0) / stationAsimov:getShieldMax(0)
							if shield_percentage < 1 then
								local asimov_health = string.format("Asimov S:%i%% H:%i%%",math.floor(shield_percentage*100),math.floor(stationAsimov:getHull()/stationAsimov:getHullMax()*100))
								if p:hasPlayerAtPosition("Relay") then
									p.asimov_status = "asimov_status"
									p:addCustomInfo("Relay",p.asimov_status,asimov_health)
								end
								if p:hasPlayerAtPosition("Operations") then
									p.asimov_status_ops = "asimov_status_ops"
									p:addCustomInfo("Operations",p.asimov_status_ops,asimov_health)
								end
							else
								if p.asimov_status ~= nil then
									p:removeCustom(p.asimov_status)
									p.asimov_status = nil
								end
								if p.asimov_status_ops ~= nil then
									p:removeCustom(p.asimov_status_ops)
									p.asimov_status_ops = nil
								end
							end
						end
					end
					local shield_index = 0
					local weakened_shield = false
					local weakest_shield = 1000
					if stationUtopiaPlanitia ~= nil and stationUtopiaPlanitia:isValid() then
						if stationUtopiaPlanitia.telemetry then
							repeat
								local current_shield_level = stationUtopiaPlanitia:getShieldLevel(shield_index)
								shield_percentage =  current_shield_level / stationUtopiaPlanitia:getShieldMax(shield_index)
								if shield_percentage < 1 then
									weakened_shield = true
									if current_shield_level < weakest_shield then
										weakest_shield = current_shield_level
									end
								end
								shield_index = shield_index + 1
							until shield_index >= 3
							if weakened_shield then
								local up_health = string.format("U.P. WS:%i%% H:%i%%",math.floor(weakest_shield/1000*100),math.floor(stationUtopiaPlanitia:getHull()/stationUtopiaPlanitia:getHullMax()*100))
								if p:hasPlayerAtPosition("Relay") then
									p.up_status = "up_status"
									p:addCustomInfo("Relay",p.up_status,up_health)
								end
								if p:hasPlayerAtPosition("Operations") then
									p.up_status_ops = "up_status_ops"
									p:addCustomInfo("Operations",p.up_status_ops,up_health)
								end
							else
								if p.up_status ~= nil then
									p:removeCustom(p.up_status)
									p.up_status = nil
								end
								if p.up_status_ops ~= nil then
									p:removeCustom(p.up_status_ops)
									p.up_status_ops = nil
								end
							end
						end
					end
					shield_index = 0
					weakened_shield = false
					weakest_shield = 1200
					if stationArmstrong ~= nil and stationArmstrong:isValid() then
						if stationArmstrong.telemetry then
							repeat
								local current_shield_level = stationArmstrong:getShieldLevel(shield_index)
								shield_percentage =  current_shield_level / stationArmstrong:getShieldMax(shield_index)
								if shield_percentage < 1 then
									weakened_shield = true
									if current_shield_level < weakest_shield then
										weakest_shield = current_shield_level
									end
								end
								shield_index = shield_index + 1
							until shield_index >= 4
							if weakened_shield then
								local armstrong_health = string.format("U.P. WS:%i%% H:%i%%",math.floor(weakest_shield/1000*100),math.floor(stationArmstrong:getHull()/stationArmstrong:getHullMax()*100))
								if p:hasPlayerAtPosition("Relay") then
									p.armstrong_status = "armstrong_status"
									p:addCustomInfo("Relay",p.armstrong_status,armstrong_health)
								end
								if p:hasPlayerAtPosition("Operations") then
									p.armstrong_status_ops = "armstrong_status_ops"
									p:addCustomInfo("Operations",p.armstrong_status_ops,armstrong_health)
								end
							else
								if p.armstrong_status ~= nil then
									p:removeCustom(p.armstrong_status)
									p.armstrong_status = nil
								end
								if p.armstrong_status_ops ~= nil then
									p:removeCustom(p.armstrong_status_ops)
									p.armstrong_status_ops = nil
								end
							end
						end
					end
				end
			end
		end
	end
end
function update(delta)
	concurrentPlayerCount = 0
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			concurrentPlayerCount = concurrentPlayerCount + 1
		end
	end
	if concurrentPlayerCount > highestConcurrentPlayerCount then
		highestConcurrentPlayerCount = concurrentPlayerCount
	end
	if setConcurrentPlayerCount ~= highestConcurrentPlayerCount then
		setPlayers()
	end
	if delta == 0 then
		--game paused
		setPlayers()
		return
	end
	if plotArt ~= nil then		--artifact plot: find, scan, retrieve anchor artifacts
		plotArt(delta)
	end
	if plot1 ~= nil then		--primary plot: patrol bases, defend Utopia then destroy Scarlet Citadel based on selected length variation
		plot1(delta)
	end
	if plot7 ~= nil then		--timed game: ambush
		plot7(delta)
	end
	if plotH ~= nil then		--health
		plotH(delta)
	end
	if plot8 ~= nil then		--patrol sub plot (not short): leg 3: attack3 enemies, Sheila death, extra flaky tube
		plot8(delta)
	end
	if plotT ~= nil then		--Transports
		plotT(delta)
	end
--	if not patrolComplete then
		if plot2 ~= nil then		--patrol sub plot: leg 2: nuisance enemies, sick miner kojak, beam upgrade
			plot2(delta)
		end
		if plot9 ~= nil then		--patrol sub plot (not short): leg 4: attack4 enemies, nebula 1 ambush
			plot9(delta)
		end
		if plot10 ~= nil then		--patrol sub plot (not short): leg 5: attack5 enemies, nebula 2 ambush
			plot10(delta)
		end
		if plot3 ~= nil then		--patrol sub plot: leg 6: incursion enemies, McNabbit ride, upgrade impulse
			plot3(delta)
		end
		if plot4 ~= nil then		--patrol sub plot: leg 7: attack1 enemies, Lisbon stowaway, beam cooling upgrade
			plot4(delta)
		end
		if plot5 ~= nil then		--patrol sub plot: leg 8: attack2 enemies
			plot5(delta)
		end
		if plot11 ~= nil then		--jump start (not easy)
			plot11(delta)
		end
--	end
	if plotRS ~= nil then			--relay status
		plotRS(delta)
	end
	expirePlayButtons(delta)
end