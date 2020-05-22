-- Name: Unwanted Visitors
-- Description: Get rid of the unwanted visitors. Various other missions follow (check the dispatch office). Missions may challenge the helm officer regardless of the difficulty level chosen. You may choose to continue or stand down after each mission. 
---
--- Running all missions can take several hours. Consider real life limits when given the option to stand down at the end of each mission. Some missions are easier to complete in a warp ship than in a jump ship. Only one of the last set of missions may be selected.
---
--- If you have already played one or more missions and want to choose to replay or avoid a particular mission, choose a 'Selectable' variation. Choosing a 'Random' variation gives you no mission choice. The default is partial selection control allowing you to select a mission group.
---
--- Buttons on the Game Master screen can change the speed of objects in various orbits by 10 percent per click
---
--- If you are playing on a LAN and would like to hear voices from the server running a main screen, change file scenario_48_visitors.lua in the scripts folder such that 'server_voices = true' rather than 'server_voices = false' on line 37. Note: case is important, so match the case in the lua file, not what you see here (which is always upper case). After editing, you will need to restart the server.
---
--- Voice Actors:
--- Admiral U. E.
--- David Priddy
--- Jordy Kruijer
--- Kilted Klingon
--- Kristen Priddy
--- Nick Mercier
--- Peter Priddy
--- Slate https://www.amazon.com/T.-L.-Ford/e/B0034Q6Q2S
--- Stephen Priddy
--- 
--- Version 1
-- Type: Replayable Mission
-- Variation[Easy]: Easy goals and/or enemies
-- Variation[Hard]: Hard goals and/or enemies
-- Variation[Random]: Next mission is chosen at random
-- Variation[Selectable]: Next mission may be selected
-- Variation[Easy Random]: Easy goals and/or enemies, Next mission is chosen at random
-- Variation[Easy Selectable]: Easy goals and/or enemies, Next mission may be selected
-- Variation[Hard Random]: Hard goals and/or enemies, Next mission is chosen at random
-- Variation[Hard Selectable]: Hard goals and/or enemies, Next mission may be selected

require("utils.lua")

function init()
	server_voices = false
	if server_voices then
		voice_queue = {}
		voice_delay = 0
		voice_played = {}
		plotV = handleVoiceQueue
	end
	print(_VERSION)
	updateDiagnostic = false
	stationCommsDiagnostic = false
	planetologistDiagnostic = false
	moveDiagnostic = false
	pollyDiagnostic = false
	fixSatelliteDiagnostic = false
	shipCommsDiagnostic = false
	prefix_length = 0
	suffix_index = 0
	--stationCommunication could be nil (default), commsStation (embedded function) or comms_station_enhanced (external script)
	stationCommunication = "commsStation"
	setVariations()
	setConstants()	--missle type names, template names and scores, deployment directions, player ship names, etc.
	setGoodsList()
	setListOfStations()
	buildLocalSolarSystem()
	setOptionalMissions()
	setPlots()
	plotManager = plotDelay
	plotM = movingObjects
	plotT = workingTransports
	plotCN = coolantNebulae
	plotH = healthCheck				--Damage to ship can kill repair crew members
	healthCheckTimer = 5
	healthCheckTimerInterval = 5
	mission_complete_count = 0
	mission_region = 0
	mainGMButtons()
end
---------------------------
-- Game Master functions --
---------------------------
function mainGMButtons()
	clearGMFunctions()
	addGMFunction("Player ships",playerShipGMButtons)
	addGMFunction("Adjust speed",adjustSpeedGMButtons)
	addGMFunction("End Mission",endMissionGMButtons)
end
-- GM player ship functions
function playerShipGMButtons()
	clearGMFunctions()
	addGMFunction("Back to main",mainGMButtons)
	if playerNarsil == nil then
		addGMFunction("Narsil",createPlayerShipNarsil)
	end
	if playerHeadhunter == nil then
		addGMFunction("Headhunter",createPlayerShipHeadhunter)
	end
	if playerBlazon == nil then
		addGMFunction("Blazon",createPlayerShipBlazon)
	end
	if playerSting == nil then
		addGMFunction("Sting",createPlayerShipSting)
	end
end
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
	playerNarsil:setWeaponTubeCount(6)					--one more forward tube, less flexible ordnance
	playerNarsil:setWeaponTubeDirection(0,0)			--front facing
	playerNarsil:setWeaponTubeExclusiveFor(0,"HVLI")	--HVLI only
	playerNarsil:setWeaponTubeDirection(1,-90)			--left facing
	playerNarsil:weaponTubeDisallowMissle(1,"Mine")		--all but mine
	playerNarsil:setWeaponTubeDirection(2,-90)			--left facing
	playerNarsil:setWeaponTubeExclusiveFor(2,"HVLI")	--HVLI only
	playerNarsil:setWeaponTubeDirection(3,90)			--right facing
	playerNarsil:weaponTubeDisallowMissle(3,"Mine")		--all but mine
	playerNarsil:setWeaponTubeDirection(4,90)			--right facing
	playerNarsil:setWeaponTubeExclusiveFor(4,"HVLI")	--HVLI only
	playerNarsil:setWeaponTubeDirection(5,180)			--rear facing
	playerNarsil:setWeaponTubeExclusiveFor(5,"Mine")	--Mine only
	playerNarsil:addReputationPoints(50)
	removeGMFunction("Narsil")
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
	playerHeadhunter:addReputationPoints(50)
	removeGMFunction("Headhunter")
end
function createPlayerShipBlazon()
	playerBlazon = PlayerSpaceship():setTemplate("Striker"):setFaction("Human Navy"):setCallSign("Blazon")
	playerBlazon:setTypeName("Stricken")
	playerBlazon:setRepairCrewCount(2)
	playerBlazon:setImpulseMaxSpeed(105)					
	playerBlazon:setRotationMaxSpeed(35)				
	playerBlazon:setShieldsMax(80,50)
	playerBlazon:setShields(80,50)
	playerBlazon:setBeamWeaponTurret(0,60,-15,2)
	playerBlazon:setBeamWeaponTurret(1,60, 15,2)
	playerBlazon:setBeamWeapon(2,20,0,1200,6,5)
	playerBlazon:setWeaponTubeCount(3)
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
	playerBlazon:addReputationPoints(50)
	removeGMFunction("Blazon")
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
	playerSting:addReputationPoints(50)
	removeGMFunction("Sting")
end
-- GM adjust speed functions
function adjustSpeedGMButtons()
	clearGMFunctions()
	addGMFunction("Back to main",mainGMButtons)
	addGMFunction("Primus",adjustPrimusSpeed)
	addGMFunction("Primus Moon",adjustPrimusMoonSpeed)
	addGMFunction("Secondus",adjustSecondusSpeed)
	addGMFunction("Secondus Station",adjustSecondusStationSpeed)
	addGMFunction("Sol Belt 1",adjustSolBelt1Speed)
	addGMFunction("Sol Belt 2",adjustSolBelt2Speed)
	addGMFunction("Tertius",adjustTertiusSpeed)
	addGMFunction("Tertius Moon Belt",adjustTertiusMoonBeltSpeed)
	addGMFunction("Tertius Belt 2",adjustTertiusBelt2Speed)
end
function adjustPrimusSpeed()
	clearGMFunctions()
	addGMFunction("Back to main",mainGMButtons)
	addGMFunction("Back from Primus",adjustSpeedGMButtons)
	addGMFunction("Slower",function()
		print(string.format("current Primus speed: %.1f",planetPrimus.orbit_speed))
		planetPrimus.orbit_speed = planetPrimus.orbit_speed * 1.1
		planetPrimus:setOrbit(planetSol,planetPrimus.orbit_speed)
		print(string.format("new slower Primus speed: %.1f",planetPrimus.orbit_speed))
	end)
	addGMFunction("Faster",function()
		print(string.format("current Primus speed: %.1f",planetPrimus.orbit_speed))
		planetPrimus.orbit_speed = planetPrimus.orbit_speed * .9
		planetPrimus:setOrbit(planetSol,planetPrimus.orbit_speed)
		print(string.format("new faster Primus speed: %.1f",planetPrimus.orbit_speed))
	end)
end
function adjustPrimusMoonSpeed()
	clearGMFunctions()
	addGMFunction("Back to main",mainGMButtons)
	addGMFunction("Back from Primus Moon",adjustSpeedGMButtons)
	addGMFunction("Slower",function()
		print(string.format("current Primus moon speed: %.1f",planetPrimusMoonOrbitTime))
		planetPrimusMoonOrbitTime = planetPrimusMoonOrbitTime * 1.1
		planetPrimusMoon:setOrbit(planetPrimus,planetPrimusMoonOrbitTime)
		print(string.format("new slower Primus moon speed: %.1f",planetPrimusMoonOrbitTime))
	end)
	addGMFunction("Faster",function()
		print(string.format("current Primus moon speed: %.1f",planetPrimusMoonOrbitTime))
		planetPrimusMoonOrbitTime = planetPrimusMoonOrbitTime * .9
		planetPrimusMoon:setOrbit(planetPrimus,planetPrimusMoonOrbitTime)
		print(string.format("new faster Primus moon speed: %.1f",planetPrimusMoonOrbitTime))
	end)
end
function adjustSecondusSpeed()
	clearGMFunctions()
	addGMFunction("Back to main",mainGMButtons)
	addGMFunction("Back from Secondus",adjustSpeedGMButtons)
	addGMFunction("Slower",function()
		print(string.format("current Secondus speed: %.1f",planetSecondus.orbit_speed))
		planetSecondus.orbit_speed = planetSecondus.orbit_speed * 1.1
		planetSecondus:setOrbit(planetSol,planetSecondus.orbit_speed)
		print(string.format("new slower Secondus speed: %.1f",planetSecondus.orbit_speed))
	end)
	addGMFunction("Faster",function()
		print(string.format("current Secondus speed: %.1f",planetSecondus.orbit_speed))
		planetSecondus.orbit_speed = planetSecondus.orbit_speed * .9
		planetSecondus:setOrbit(planetSol,planetSecondus.orbit_speed)
		print(string.format("new faster Secondus speed: %.1f",planetSecondus.orbit_speed))
	end)
end
function adjustSecondusStationSpeed()
	clearGMFunctions()
	addGMFunction("Back to main",mainGMButtons)
	addGMFunction("Back from Secondus Stn",adjustSpeedGMButtons)
	addGMFunction("Slower",function()
		print(string.format("current Secondus station speed: %.3f",secondusStationOrbitIncrement))
		secondusStationOrbitIncrement = secondusStationOrbitIncrement * .9
		print(string.format("new slower Secondus station speed: %.3f",secondusStationOrbitIncrement))
	end)
	addGMFunction("Faster",function()
		print(string.format("current Secondus station speed: %.3f",secondusStationOrbitIncrement))
		secondusStationOrbitIncrement = secondusStationOrbitIncrement * 1.1
		print(string.format("new faster Secondus station speed: %.3f",secondusStationOrbitIncrement))
	end)
end
function adjustSolBelt1Speed()
	clearGMFunctions()
	addGMFunction("Back to main",mainGMButtons)
	addGMFunction("Back from Sol Belt 1",adjustSpeedGMButtons)
	addGMFunction("Slower",function()
		print(string.format("current Sol Belt 1 speed: %.3f",belt1OrbitalSpeed))
		belt1OrbitalSpeed = belt1OrbitalSpeed * .9
		for i=1,#beltAsteroidList do
			local ta = beltAsteroidList[i]
			if ta ~= nil and ta:isValid() and ta.belt_id == "belt1" then
				ta.speed = belt1OrbitalSpeed
			end
		end
		print(string.format("new slower Sol Belt 1 speed: %.3f",belt1OrbitalSpeed))
	end)
	addGMFunction("Faster",function()
		print(string.format("current Sol Belt 1 speed: %.3f",belt1OrbitalSpeed))
		belt1OrbitalSpeed = belt1OrbitalSpeed * 1.1
		for i=1,#beltAsteroidList do
			local ta = beltAsteroidList[i]
			if ta ~= nil and ta:isValid() and ta.belt_id == "belt1" then
				ta.speed = belt1OrbitalSpeed
			end
		end
		print(string.format("new faster Sol Belt 1 speed: %.3f",belt1OrbitalSpeed))
	end)
end
function adjustSolBelt2Speed()
	clearGMFunctions()
	addGMFunction("Back to main",mainGMButtons)
	addGMFunction("Back from Sol Belt 2",adjustSpeedGMButtons)
	addGMFunction("Slower",function()
		print(string.format("current Sol Belt 2 speed: %.3f",belt2OrbitalSpeed))
		belt2OrbitalSpeed = belt2OrbitalSpeed * .9
		for i=1,#beltAsteroidList do
			local ta = beltAsteroidList[i]
			if ta ~= nil and ta:isValid() and ta.belt_id == "belt2" then
				ta.speed = belt2OrbitalSpeed
			end
		end
		print(string.format("new slower Sol Belt 2 speed: %.3f",belt2OrbitalSpeed))
	end)
	addGMFunction("Faster",function()
		print(string.format("current Sol Belt 2 speed: %.3f",belt2OrbitalSpeed))
		belt2OrbitalSpeed = belt2OrbitalSpeed * 1.1
		for i=1,#beltAsteroidList do
			local ta = beltAsteroidList[i]
			if ta ~= nil and ta:isValid() and ta.belt_id == "belt2" then
				ta.speed = belt2OrbitalSpeed
			end
		end
		print(string.format("new faster Sol Belt 2 speed: %.3f",belt2OrbitalSpeed))
	end)
end
function adjustTertiusSpeed()
	clearGMFunctions()
	addGMFunction("Back to main",mainGMButtons)
	addGMFunction("Back from Tertius",adjustSpeedGMButtons)
	addGMFunction("Slower",function()
		print(string.format("current Tertius speed: %.1f",planetTertius.orbit_speed))
		planetTertius.orbit_speed = planetTertius.orbit_speed * 1.1
		planetTertius:setOrbit(planetSol,planetTertius.orbit_speed)
		print(string.format("new slower Tertius speed: %.1f",planetTertius.orbit_speed))
	end)
	addGMFunction("Faster",function()
		print(string.format("current Tertius speed: %.1f",planetTertius.orbit_speed))
		planetTertius.orbit_speed = planetTertius.orbit_speed * .9
		planetTertius:setOrbit(planetSol,planetTertius.orbit_speed)
		print(string.format("new faster Tertius speed: %.1f",planetTertius.orbit_speed))
	end)
end
function adjustTertiusMoonBeltSpeed()
	clearGMFunctions()
	addGMFunction("Back to main",mainGMButtons)
	addGMFunction("Back from Tertius Moon",adjustSpeedGMButtons)
	addGMFunction("Slower",function()
		print(string.format("current Tertius Moon Belt speed: %.3f",tertiusOrbitalBodyIncrement))
		tertiusOrbitalBodyIncrement = tertiusOrbitalBodyIncrement * .9
		for i=1,#tertiusAsteroids do
			local ta = tertiusAsteroids[i]
			if ta ~= nil and ta:isValid() and ta.belt_id == "tMoonBelt" then
				ta.speed = tertiusOrbitalBodyIncrement
			end
		end
		print(string.format("new slower Tertius Moon Belt speed: %.3f",tertiusOrbitalBodyIncrement))
	end)
	addGMFunction("Faster",function()
		print(string.format("current Tertius Moon Belt speed: %.3f",tertiusOrbitalBodyIncrement))
		tertiusOrbitalBodyIncrement = tertiusOrbitalBodyIncrement * 1.1
		for i=1,#tertiusAsteroids do
			local ta = tertiusAsteroids[i]
			if ta ~= nil and ta:isValid() and ta.belt_id == "tMoonBelt" then
				ta.speed = tertiusOrbitalBodyIncrement
			end
		end
		print(string.format("new faster Tertius Moon Belt speed: %.3f",tertiusOrbitalBodyIncrement))
	end)
end
function adjustTertiusBelt2Speed()
	clearGMFunctions()
	addGMFunction("Back to main",mainGMButtons)
	addGMFunction("Back from Tertius Belt 2",adjustSpeedGMButtons)
	addGMFunction("Slower",function()
		print(string.format("current Tertius Belt 2 speed: %.3f",tertiusAsteroidBeltIncrement))
		tertiusAsteroidBeltIncrement = tertiusAsteroidBeltIncrement * .9
		for i=1,#tertiusAsteroids do
			local ta = tertiusAsteroids[i]
			if ta ~= nil and ta:isValid() and ta.belt_id == "tBelt2" then
				ta.speed = tertiusAsteroidBeltIncrement
			end
		end
		for i=1,#tertiusAsteroidStations do
			local tbs = tertiusAsteroidStations[i]
			if tbs ~= nil and tbs:isValid() then
				tbs.speed = tertiusAsteroidBeltIncrement
			end
		end
		print(string.format("new slower Tertius Belt 2 speed: %.3f",tertiusAsteroidBeltIncrement))
	end)
	addGMFunction("Faster",function()
		print(string.format("current Tertius Belt 2 speed: %.3f",tertiusAsteroidBeltIncrement))
		tertiusAsteroidBeltIncrement = tertiusAsteroidBeltIncrement * 1.1
		for i=1,#tertiusAsteroids do
			local ta = tertiusAsteroids[i]
			if ta ~= nil and ta:isValid() and ta.belt_id == "tBelt2" then
				ta.speed = tertiusAsteroidBeltIncrement
			end
		end
		for i=1,#tertiusAsteroidStations do
			local tbs = tertiusAsteroidStations[i]
			if tbs ~= nil and tbs:isValid() then
				tbs.speed = tertiusAsteroidBeltIncrement
			end
		end
		print(string.format("new faster Tertius Belt 2 speed: %.3f",tertiusAsteroidBeltIncrement))
	end)
end
-- GM end mission functions
function endMissionGMButtons()
	clearGMFunctions()
	addGMFunction("Back to main",mainGMButtons)
	addGMFunction("Human victory",function()
		showEndStats()
		victory("Human Navy")
	end)
	addGMFunction("Exuari victory",function()
		showEndStats()
		victory("Exuari")
	end)
end
------------------------------------------
-- Initialization and utility functions --
------------------------------------------
function setVariations()
	local svs = getScenarioVariation()	--scenario variation string
	if string.find(svs,"Easy") then
		difficulty = .5
		coolant_loss = .99999
		coolant_gain = .01
	elseif string.find(svs,"Hard") then
		difficulty = 2
		coolant_loss = .9999
		coolant_gain = .0001
	else
		difficulty = 1		--default (normal)
		coolant_loss = .99995
		coolant_gain = .001
	end
	mission_choice = "Region Selectable"	--valid choices are "Random", "Region Selectable" (default) and "Selectable"
	if string.find(svs,"Selectable") then
		mission_choice = "Selectable"
	elseif string.find(svs,"Random") then
		mission_choice = "Random"
	end
	gameTimeLimit = 0
	playWithTimeLimit = false
end
function setConstants()
	repeatExitBoundary = 100
	scarceResources = false
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
	playerShipNamesForStriker = {"Sparrow","Sizzle","Squawk","Crow","Phoenix","Snowbird","Hawk"}
	playerShipNamesForLindworm = {"Seagull","Catapult","Blowhard","Flapper","Nixie","Pixie","Tinkerbell"}
	playerShipNamesForRepulse = {"Fiddler","Brinks","Loomis","Mowag","Patria","Pandur","Terrex","Komatsu","Eitan"}
	playerShipNamesForEnder = {"Mongo","Godzilla","Leviathan","Kraken","Jupiter","Saturn"}
	playerShipNamesForNautilus = {"October","Abdiel","Manxman","Newcon","Nusret","Pluton","Amiral","Amur","Heinkel","Dornier"}
	playerShipNamesForHathcock = {"Hayha","Waldron","Plunkett","Mawhinney","Furlong","Zaytsev","Pavlichenko","Pegahmagabow","Fett","Hawkeye","Hanzo"}
	playerShipNamesForAtlantisII = {"Spyder", "Shelob", "Tarantula", "Aragog", "Charlotte"}
	playerShipNamesForProtoAtlantis = {"Narsil", "Blade", "Decapitator", "Trisect", "Sabre"}
	playerShipNamesForMaverick = {"Angel", "Thunderbird", "Roaster", "Magnifier", "Hedge"}
	playerShipNamesForCrucible = {"Sling", "Stark", "Torrid", "Kicker", "Flummox"}
	playerShipNamesForSurkov = {"Sting", "Sneak", "Bingo", "Thrill", "Vivisect"}
	playerShipNamesForStricken = {"Blazon", "Streaker", "Pinto", "Spear", "Javelin"}
	playerShipNamesForAtlantisII = {"Spyder", "Shelob", "Tarantula", "Aragog", "Charlotte"}
	playerShipNamesForRedhook = {"Headhunter", "Thud", "Troll", "Scalper", "Shark"}
	playerShipNamesForLeftovers = {"Foregone","Righteous","Masher"}
	if server_voices then
		primusNames = {"Minos","Talos","Primus"}
		secondusNames = {"Secondus","Aurora","Covenant"}
		tertiusNames = {"Tertius","Megas","Tadmore"}
		solNames = {"Sun","Tau Ceti","Barnard"}
	else
		primusNames = {"Minos","Talos","Thor","Minotaur","Thanatos","Hades","Tartarus","Erebus","Primus"}
		secondusNames = {"New Terra","Gaia","Home","Secondus","Thulcandra","Territa","Garth","Aurora","Covenant"}
		tertiusNames = {"Cat's Eye","Tertius","Dagoba","Pitcairn","Tl'ho","Megas","Amateru","Tadmore","Brahe"}
		solNames = {"Sol","Sun","Groombridge 34","Tau Ceti","Wolf 1061","Gliese 876","Barnard"}
	end
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
	virus_status_functions = {virusStatusP1,virusStatusP2,virusStatusP3,virusStatusP4,virusStatusP5,virusStatusP6,virusStatusP7,virusStatusP8}
	--				short clip name		length in seconds
	voice_clips = {	
					["Avery01"] = 					0.971,
					["Avery02"] = 					7.187,
					["Ellis01"] =					14.433,
					["Ellis02"] =					2.810,
					["Enrique01"] =					2.995,
					["Enrique02"] =					1.741,
					["Enrique03"] =					2.241,
					["Enrique04"] =					4.040,
					["Enrique05"] =					0.720,
					["Enrique06"] =					2.345,
					["Enrique07"] =					3.170,
					["Enrique08"] =					2.322,
					["Enrique09"] =					1.358,
					["Enrique10"] =					0.441,
					["Enrique11"] =					2.682,
					["Enrique12"] =					1.858,
					["Enrique13"] =					2.055,
					["Enrique14"] =					1.544,
					["Enrique15"] =					1.486,
					["Enrique16"] =					2.229,
					["Enrique17"] =					2.159,
					["Enrique18"] =					3.413,
					["Enrique19"] =					2.728,
					["Enrique20"] =					3.239,
					["Enrique21"] =					0.467,
					["Enrique22"] =					1.405,
					["Enrique23"] =					2.125,
					["Hayden01"] =					5.468,
					["Hayden02"] =					11.378,
					["Hayden03"] =					5.027,
					["Hayden04"] =					11.459,
					["Hayden05"] =					0.569,
					["Hayden06"] =					8.731,
					["Hayden07"] =					1.463,
					["Hayden08"] =					2.264,
					["Jamie01"] =					7.883,
					["Jamie02"] =					8.406,
					["Karsyn01"] =					1.231,
					["Karsyn02"] =					4.841,
					["Ozzie01"] =					0.360,
					["Ozzie02"] =					0.557,
					["Ozzie03"] =					0.360,
					["Ozzie04"] =					1.707,
					["Ozzie05"] =					1.335,
					["Ozzie06"] =					1.161,
					["Ozzie07"] =					0.418,
					["Ozzie08"] =					0.615,
					["Ozzie09"] =					0.929,
					["Parker01"] =					1.753,
					["Parker02"] =					1.614,
					["Pat01Aurora"] =				7.327,
					["Pat01Covenant"] =				7.248,
					["Pat01Secondus"] =				7.587,
					["Pat02Minos"] =				15.140,
					["Pat02Primus"] =				15.681,
					["Pat02Talos"] =				15.681,
					["Pat03"] =						18.429,
					["Pat04"] =						5.354,
					["Pat05"] =						3.179,
					["Pat06"] =						6.672,
					["Peyton01"] =					12.327,
					["Peyton02"] =					1.792,
					["Phoenix01"] =					1.815,
					["Polly0110"] =					6.966,
					["Polly0120"] =					7.094,
					["Polly0140"] =					7.523,
					["Polly02"] =					8.893,
					["Polly03"] =					14.710,
					["Polly04"] =					2.844,
					["Polly05"] =					9.021,
					["Polly06"] =					8.440,
					["Polly07"] =					9.880,
					["Quinn01"] =					1.033,
					["Quinn02"] =					1.858,
					["Reese01"] =					4.836,
					["Reese02"] =					8.681,
					["Rory01"] =					1.521,
					["Rory02"] =					1.939,
					["Rory03"] =					2.717,
					["Rory04"] =					3.251,
					["Skyler01"] = 					2.798,
					["Skyler02"] =					4.203,
					["Skyler03"] =					4.923,
					["Taylor01"] =					1.022,
					["Taylor02"] =					8.742,
					["Tracy01Megas"] =				4.098,
					["Tracy01Tadmore"] =			3.796,
					["Tracy01Tertius"] =			3.924,
					["Tracy02"] =					2.984,
					["Tracy03"] =					2.659,
					["Tracy04"] =					1.591,
					["Tracy05"] =					10.913,
					["Tracy06InsideAurora"] =		4.934,
					["Tracy06InsideCovenant"] =		4.888,
					["Tracy06InsideSecondus"] =		5.457,
					["Tracy06OutsideAurora"] =		4.992,
					["Tracy06OutsideCovenant"] =	4.841,
					["Tracy06OutsideSecondus"] =	5.039,
					["Tracy07"] =					2.245,
					["Tracy08"] =					2.090,
					["Tracy09"] =					2.020,
					["Tracy10"] =					2.229,
					["Tracy11"] =					1.057,
					["Tracy12"] =					1.231,
					["Tracy13"] =					3.344,
					["Tracy14"] =					0.775,
				}
	cargoInventoryList = {}
	table.insert(cargoInventoryList,cargoInventory1)
	table.insert(cargoInventoryList,cargoInventory2)
	table.insert(cargoInventoryList,cargoInventory3)
	table.insert(cargoInventoryList,cargoInventory4)
	table.insert(cargoInventoryList,cargoInventory5)
	table.insert(cargoInventoryList,cargoInventory6)
	table.insert(cargoInventoryList,cargoInventory7)
	table.insert(cargoInventoryList,cargoInventory8)
	get_coolant_function = {}
	table.insert(get_coolant_function,getCoolant1)
	table.insert(get_coolant_function,getCoolant2)
	table.insert(get_coolant_function,getCoolant3)
	table.insert(get_coolant_function,getCoolant4)
	table.insert(get_coolant_function,getCoolant5)
	table.insert(get_coolant_function,getCoolant6)
	table.insert(get_coolant_function,getCoolant7)
	table.insert(get_coolant_function,getCoolant8)
end
function buildLocalSolarSystem()
	stationList = {}
	humanStationList = {}
	humanStationStrength = 0
	humanStationsRemain = true
	humanStationDestroyedNameList = {}
	humanStationDestroyedValue = {}
	neutralStationList = {}
	neutralStationStrength = 0
	neutralStationsRemain = true
	neutralStationDestroyedNameList = {}
	neutralStationDestroyedValue = {}
	clueStations = {}
	exuariStationList = {}
	exuariStationStrength = 0
	orbitChoice = "random"	--could be lo, hi or random
	-- central star (Sol)
	solX, solY = vectorFromAngle(random(20,70),random(100000,200000))
	planetSol = Planet():setPosition(solX,solY):setPlanetRadius(1000):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0,1.0,1.0)
	planetSol:setCallSign(solNames[math.random(1,#solNames)])
	-------------------------------
	-- innermost planet (Primus) --
	-------------------------------
	primusOrbit = random(8000,20000)
	pla = random(0,360)
	plx, ply = vectorFromAngle(pla,primusOrbit)
	primusRadius = random(800,1200)
	planetPrimus = Planet():setPosition(solX+plx,solY+ply):setPlanetRadius(primusRadius):setAxialRotationTime(random(200,250)):setDistanceFromMovementPlane(-primusRadius/2)
	planetPrimus:setPlanetSurfaceTexture("planets/planet-2.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.2,0.2,0.1)
	planetPrimus:setCallSign(primusNames[math.random(1,#primusNames)])
	lo = 400
	hi = 500
	if orbitChoice == "lo" then
		planetPrimus.orbit_speed = lo/difficulty
	elseif orbitChoice == "hi" then
		planetPrimus.orbit_speed = hi/difficulty
	else
		planetPrimus.orbit_speed = random(lo,hi)/difficulty
	end
	planetPrimus:setOrbit(planetSol,planetPrimus.orbit_speed)
	-- moon orbiting Primus
	primusMoonOrbit = random(3000,5000)
	pla = random(0,360)
	plx, ply = vectorFromAngle(pla,primusMoonOrbit)
	primusX, primusY = planetPrimus:getPosition()
	primusMoonRadius = random(200,400)
	planetPrimusMoon = Planet():setPosition(primusX+plx,primusY+ply):setPlanetRadius(primusMoonRadius):setAxialRotationTime(random(60,100)):setDistanceFromMovementPlane(-primusMoonRadius/2)
	lo = 200
	hi = 300
	if orbitChoice == "lo" then
		planetPrimusMoonOrbitTime = lo/difficulty
	elseif orbitChoice == "hi" then
		planetPrimusMoonOrbitTime = hi/difficulty
	else
		planetPrimusMoonOrbitTime = random(lo,hi)/difficulty
	end
	planetPrimusMoon:setPlanetSurfaceTexture("planets/moon-1.png")
	planetPrimusMoon:setOrbit(planetPrimus,planetPrimusMoonOrbitTime)
	-- station orbiting Primus
	plx, ply = vectorFromAngle(pla+180,primusMoonOrbit)
	psx = primusX+plx
	psy = primusY+ply
	stationStaticAsteroids = false
	stationFaction = "Human Navy"				--set station faction
	si = math.random(1,#placeStation)			--station index
	pStation = placeStation[si]()				--place selected station
	table.remove(placeStation,si)				--remove station from placement list
	humanStationStrength = humanStationStrength + setStationStrength(pStation)
	pStation:onDestruction(humanStationDestroyed)
	pStation.comms_data.orbit = string.format("orbiting %s at a distance of %.1fU",planetPrimus:getCallSign(),primusMoonOrbit/1000)
	table.insert(stationList,pStation)			--save station in general station list
	table.insert(humanStationList,pStation)		--save station in friendly station list
	table.insert(clueStations,pStation)			--1
	primusStation = pStation
	-- player spawn band (5 units wide: 5000)
	primusOuter = primusOrbit + primusMoonOrbit + primusMoonRadius + 500
	playerSpawnBand = random(primusOuter, primusOuter + 50000)
	--------------------------------------
	-- second closest planet (Secondus) --
	--------------------------------------
	secondusRadius = random(2500,3500)
	secondusMoonOrbit = random(6000,10000)
	secondusMoonRadius = random(400,600)
	if (playerSpawnBand - primusOuter) > ((secondusMoonOrbit*2) + (secondusMoonRadius*2) + 5000) then
		secondusOrbit = (playerSpawnBand + primusOuter)/2								--players spawn outside Secondus
	else
		secondusOrbit = playerSpawnBand + secondusMoonOrbit + secondusMoonRadius + 5000	--players spawn inside Secondus
	end
	pla = random(0,360)
	plx, ply = vectorFromAngle(pla,secondusOrbit)
	planetSecondus = Planet():setPosition(solX+plx,solY+ply):setPlanetRadius(secondusRadius):setAxialRotationTime(random(250,300)):setDistanceFromMovementPlane(-secondusRadius/2)
	planetSecondus:setPlanetSurfaceTexture("planets/planet-1.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.2,0.2,1.0):setPlanetCloudTexture("planets/clouds-1.png")
	planetSecondus:setCallSign(secondusNames[math.random(1,#secondusNames)])
	lo = 1000
	hi = 2000
	if orbitChoice == "lo" then
		planetSecondus.orbit_speed = lo/difficulty
	elseif orbitChoice == "hi" then
		planetSecondus.orbit_speed = hi/difficulty
	else
		planetSecondus.orbit_speed = random(lo,hi)/difficulty
	end
	planetSecondus:setOrbit(planetSol,planetSecondus.orbit_speed)
	-- moon orbiting Secondus
	pla = random(0,360)
	plx, ply = vectorFromAngle(pla,secondusMoonOrbit)
	secondusX, secondusY = planetSecondus:getPosition()
	planetSecondusMoon = Planet():setPosition(secondusX+plx,secondusY+ply):setPlanetRadius(secondusMoonRadius):setAxialRotationTime(random(120,160)):setDistanceFromMovementPlane(-secondusMoonRadius/2)
	lo = 80
	hi = 100
	if orbitChoice == "lo" then
		planetSecondusMoonOrbitTime = lo/difficulty
	elseif orbitChoice == "hi" then
		planetSecondusMoonOrbitTime = hi/difficulty
	else
		planetSecondusMoonOrbitTime = random(lo,hi)/difficulty
	end
	planetSecondusMoon:setPlanetSurfaceTexture("planets/moon-1.png"):setOrbit(planetSecondus,planetSecondusMoonOrbitTime)
	-- stations orbiting Secondus
	secondusStationOrbitIncrement = .05*difficulty
	secondusStations = {}
	secondusStationOrbit = (secondusRadius + secondusMoonOrbit - secondusMoonRadius)/2
	stationSize = "Small Station"
	--secondus station 1
	plx, ply = vectorFromAngle(0,secondusStationOrbit)
	psx = secondusX + plx
	psy = secondusY + ply
	si = math.random(1,#placeStation)			--station index
	pStation = placeStation[si]()				--place selected station
	table.remove(placeStation,si)				--remove station from placement list
	humanStationStrength = humanStationStrength + setStationStrength(pStation)
	pStation:onDestruction(humanStationDestroyed)
	pStation.comms_data.orbit = string.format("orbiting %s at a distance of %.1fU",planetSecondus:getCallSign(),secondusStationOrbit/1000)
	table.insert(stationList,pStation)			--save station in general station list
	table.insert(humanStationList,pStation)		--save station in friendly station list
	table.insert(secondusStations,pStation)
	table.insert(clueStations,pStation)			--2
	pStation.angle = 0
	--secondus station 2
	plx, ply = vectorFromAngle(120,secondusStationOrbit)
	psx = secondusX + plx
	psy = secondusY + ply
	si = math.random(1,#placeStation)			--station index
	pStation = placeStation[si]()				--place selected station
	table.remove(placeStation,si)				--remove station from placement list
	humanStationStrength = humanStationStrength + setStationStrength(pStation)
	pStation:onDestruction(humanStationDestroyed)
	pStation.comms_data.orbit = string.format("orbiting %s at a distance of %.1fU",planetSecondus:getCallSign(),secondusStationOrbit/1000)
	table.insert(stationList,pStation)			--save station in general station list
	table.insert(humanStationList,pStation)		--save station in friendly station list
	table.insert(secondusStations,pStation)
	table.insert(clueStations,pStation)			--3
	pStation.angle = 120
	--secondus station 3
	plx, ply = vectorFromAngle(240,secondusStationOrbit)
	psx = secondusX + plx
	psy = secondusY + ply
	si = math.random(1,#placeStation)			--station index
	pStation = placeStation[si]()				--place selected station
	table.remove(placeStation,si)				--remove station from placement list
	humanStationStrength = humanStationStrength + setStationStrength(pStation)
	pStation:onDestruction(humanStationDestroyed)
	pStation.comms_data.orbit = string.format("orbiting %s at a distance of %.1fU",planetSecondus:getCallSign(),secondusStationOrbit/1000)
	table.insert(stationList,pStation)			--save station in general station list
	table.insert(humanStationList,pStation)		--save station in friendly station list
	table.insert(secondusStations,pStation)
	table.insert(clueStations,pStation)			--4
	pStation.angle = 240
	stationSize = nil
	---------------------------------------
	-- determine asteroid belt locations --
	---------------------------------------
	secondusOuter = secondusOrbit + secondusMoonOrbit + secondusMoonRadius
	if secondusOrbit > playerSpawnBand then		--players spawn inside Secondus
		beltOrbit1 = playerSpawnBand + 3000
		beltOrbit1Width = 1000
		beltOrbit2 = secondusOuter + random(1000,10000)
		beltOrbit2Width = beltOrbit2 - secondusOuter
	else										--players spawn outside Secondus
		beltOrbit1Width = (playerSpawnBand - 2500) - secondusOuter - 500
		beltOrbit1 = (secondusOuter + (playerSpawnBand - 2500))/2
		beltOrbit2 = playerSpawnBand + random(3500,10000)
		beltOrbit2Width = beltOrbit2 - (playerSpawnBand + 2500)
	end
	--------------------------------
	-- populate player spawn band --
	--------------------------------
	--pick player spawn points within player spawn band
	playerSpawnAngle = random(0,360)
	plx, ply = vectorFromAngle(playerSpawnAngle,playerSpawnBand)
	playerSpawn1X = solX+plx
	playerSpawn1Y = solY+ply
	playerSpawn2X = solX-plx
	playerSpawn2Y = solY-ply
	--stations in player spawn band
	playerSpawnBandStations = {}
	sa1 = playerSpawnAngle
	sa2 = sa1 + 180
	for i=1,4 do
		sa1 = sa1 + random(18,36)
		plx, ply = vectorFromAngle(sa1,playerSpawnBand)
		psx = solX+plx
		psy = solY+ply
		if random(1,100) < 15 then
			stationFaction = "Human Navy"				--set station faction
		else
			stationFaction = "Independent"				--set station faction
		end
		si = math.random(1,#placeStation)			--station index
		pStation = placeStation[si]()				--place selected station
		table.remove(placeStation,si)				--remove station from placement list
		if stationFaction == "Human Navy" then
			humanStationStrength = humanStationStrength + setStationStrength(pStation)
			pStation:onDestruction(humanStationDestroyed)
			table.insert(humanStationList,pStation)		--save station in friendly station list
		else
			neutralStationStrength = neutralStationStrength + setStationStrength(pStation)
			pStation:onDestruction(neutralStationDestroyed)
			table.insert(neutralStationList,pStation)		--save station in friendly station list
		end
		table.insert(stationList,pStation)			--save station in general station list
		table.insert(playerSpawnBandStations,pStation)
		sa2 = sa2 + random(18,36)
		plx, ply = vectorFromAngle(sa2,playerSpawnBand)
		psx = solX+plx
		psy = solY+ply
		if random(1,100) < 15 then
			stationFaction = "Human Navy"				--set station faction
		else
			stationFaction = "Independent"				--set station faction
		end
		si = math.random(1,#placeStation)			--station index
		pStation = placeStation[si]()				--place selected station
		table.remove(placeStation,si)				--remove station from placement list
		if stationFaction == "Human Navy" then
			humanStationStrength = humanStationStrength + setStationStrength(pStation)
			pStation:onDestruction(humanStationDestroyed)
			table.insert(humanStationList,pStation)		--save station in friendly station list
		else
			neutralStationStrength = neutralStationStrength + setStationStrength(pStation)
			pStation:onDestruction(neutralStationDestroyed)
			table.insert(neutralStationList,pStation)		--save station in friendly station list
		end
		table.insert(stationList,pStation)			--save station in general station list
		table.insert(playerSpawnBandStations,pStation)
	end
	--transports in player spawn band
	transportsInPlayerSpawnBandList = {}
	transportCheckDelayInterval = 4
	transportCheckDelayTimer = transportCheckDelayInterval
	local transportType = {"Personnel","Goods","Garbage","Equipment","Fuel"}
	local name = transportType[math.random(1,#transportType)]
	if random(1,100) < 30 then
		name = name .. " Jump Freighter " .. math.random(3, 5)
	else
		name = name .. " Freighter " .. math.random(1, 5)
	end
	psx, psy = playerSpawnBandStations[1]:getPosition()
	local tempTransport = CpuShip():setTemplate(name):setPosition(psx,psy):setFaction(playerSpawnBandStations[1]:getFaction()):setCommsScript(""):setCommsFunction(commsShip)
	tempTransport:setCallSign(generateCallSign(nil,playerSpawnBandStations[1]:getFaction()))
	tempTransport.targetStart = playerSpawnBandStations[1]
	tempTransport.targetEnd = playerSpawnBandStations[3]
	if random(1,100) < 50 then
		tempTransport:orderDock(tempTransport.targetStart)
	else
		tempTransport:orderDock(tempTransport.targetEnd)
	end
	table.insert(transportsInPlayerSpawnBandList,tempTransport)
	name = transportType[math.random(1,#transportType)]
	if random(1,100) < 30 then
		name = name .. " Jump Freighter " .. math.random(3, 5)
	else
		name = name .. " Freighter " .. math.random(1, 5)
	end
	psx, psy = playerSpawnBandStations[3]:getPosition()
	tempTransport = CpuShip():setTemplate(name):setPosition(psx,psy):setFaction(playerSpawnBandStations[3]:getFaction()):setCommsScript(""):setCommsFunction(commsShip)
	tempTransport:setCallSign(generateCallSign(nil,playerSpawnBandStations[3]:getFaction()))
	tempTransport.targetStart = playerSpawnBandStations[3]
	tempTransport.targetEnd = playerSpawnBandStations[5]
	if random(1,100) < 50 then
		tempTransport:orderDock(tempTransport.targetStart)
	else
		tempTransport:orderDock(tempTransport.targetEnd)
	end
	table.insert(transportsInPlayerSpawnBandList,tempTransport)
	name = transportType[math.random(1,#transportType)]
	if random(1,100) < 30 then
		name = name .. " Jump Freighter " .. math.random(3, 5)
	else
		name = name .. " Freighter " .. math.random(1, 5)
	end
	psx, psy = playerSpawnBandStations[5]:getPosition()
	tempTransport = CpuShip():setTemplate(name):setPosition(psx,psy):setFaction(playerSpawnBandStations[5]:getFaction()):setCommsScript(""):setCommsFunction(commsShip)
	tempTransport:setCallSign(generateCallSign(nil,playerSpawnBandStations[5]:getFaction()))
	tempTransport.targetStart = playerSpawnBandStations[5]
	tempTransport.targetEnd = playerSpawnBandStations[7]
	if random(1,100) < 50 then
		tempTransport:orderDock(tempTransport.targetStart)
	else
		tempTransport:orderDock(tempTransport.targetEnd)
	end
	table.insert(transportsInPlayerSpawnBandList,tempTransport)
	name = transportType[math.random(1,#transportType)]
	if random(1,100) < 30 then
		name = name .. " Jump Freighter " .. math.random(3, 5)
	else
		name = name .. " Freighter " .. math.random(1, 5)
	end
	psx, psy = playerSpawnBandStations[2]:getPosition()
	tempTransport = CpuShip():setTemplate(name):setPosition(psx,psy):setFaction(playerSpawnBandStations[2]:getFaction()):setCommsScript(""):setCommsFunction(commsShip)
	tempTransport:setCallSign(generateCallSign(nil,playerSpawnBandStations[2]:getFaction()))
	tempTransport.targetStart = playerSpawnBandStations[2]
	tempTransport.targetEnd = playerSpawnBandStations[4]
	if random(1,100) < 50 then
		tempTransport:orderDock(tempTransport.targetStart)
	else
		tempTransport:orderDock(tempTransport.targetEnd)
	end
	table.insert(transportsInPlayerSpawnBandList,tempTransport)
	name = transportType[math.random(1,#transportType)]
	if random(1,100) < 30 then
		name = name .. " Jump Freighter " .. math.random(3, 5)
	else
		name = name .. " Freighter " .. math.random(1, 5)
	end
	psx, psy = playerSpawnBandStations[4]:getPosition()
	tempTransport = CpuShip():setTemplate(name):setPosition(psx,psy):setFaction(playerSpawnBandStations[4]:getFaction()):setCommsScript(""):setCommsFunction(commsShip)
	tempTransport:setCallSign(generateCallSign(nil,playerSpawnBandStations[4]:getFaction()))
	tempTransport.targetStart = playerSpawnBandStations[4]
	tempTransport.targetEnd = playerSpawnBandStations[6]
	if random(1,100) < 50 then
		tempTransport:orderDock(tempTransport.targetStart)
	else
		tempTransport:orderDock(tempTransport.targetEnd)
	end
	table.insert(transportsInPlayerSpawnBandList,tempTransport)
	name = transportType[math.random(1,#transportType)]
	if random(1,100) < 30 then
		name = name .. " Jump Freighter " .. math.random(3, 5)
	else
		name = name .. " Freighter " .. math.random(1, 5)
	end
	psx, psy = playerSpawnBandStations[6]:getPosition()
	tempTransport = CpuShip():setTemplate(name):setPosition(psx,psy):setFaction(playerSpawnBandStations[6]:getFaction()):setCommsScript(""):setCommsFunction(commsShip)
	tempTransport:setCallSign(generateCallSign(nil,playerSpawnBandStations[6]:getFaction()))
	tempTransport.targetStart = playerSpawnBandStations[6]
	tempTransport.targetEnd = playerSpawnBandStations[8]
	if random(1,100) < 50 then
		tempTransport:orderDock(tempTransport.targetStart)
	else
		tempTransport:orderDock(tempTransport.targetEnd)
	end
	table.insert(transportsInPlayerSpawnBandList,tempTransport)
	------------------------------
	-- populate asteroid belt 1 --
	------------------------------
	--belt 1 station 1
	belt1Stations = {}
	beltStationAngle = random(0,360)
	lo = 2
	hi = 8
	gradient = 450
	if orbitChoice == "lo" then
		belt1OrbitalSpeed = lo/gradient*difficulty
	elseif orbitChoice == "hi" then
		belt1OrbitalSpeed = hi/gradient*difficulty
	else
		belt1OrbitalSpeed = math.random(lo,hi)/gradient*difficulty
	end
	beltOrbitalSpeed = belt1OrbitalSpeed
	plx, ply = vectorFromAngle(beltStationAngle,beltOrbit1)
	psx = solX+plx
	psy = solY+ply
	stationFaction = "Human Navy"				--set station faction
	si = math.random(1,#placeStation)			--station index
	pStation = placeStation[si]()				--place selected station
	table.remove(placeStation,si)				--remove station from placement list
	humanStationStrength = humanStationStrength + setStationStrength(pStation)
	pStation:onDestruction(humanStationDestroyed)
	pStation.comms_data.orbit = string.format("orbiting %s with the inner asteroids at a distance of %.1fU",planetSol:getCallSign(),beltOrbit1/1000)
	table.insert(stationList,pStation)			--save station in general station list
	table.insert(humanStationList,pStation)		--save station in friendly station list
	table.insert(belt1Stations,pStation)
	table.insert(clueStations,pStation)			--5
	pStation.angle = beltStationAngle
	beltAsteroidList = {}
	--asteroids between station 1 and station 2 (clockwise)
	beltStationAngle = beltStationAngle + random(15,30)
	local asteroidPopulation = math.random(8,20)
	createOrbitalAsteroids(asteroidPopulation,beltOrbit1,belt1Stations[1].angle,beltStationAngle-1,"belt1",math.floor(beltOrbit1Width/2))
	--belt 1 station 2
	beltStationAngle = beltStationAngle + 1
	plx, ply = vectorFromAngle(beltStationAngle,beltOrbit1)
	psx = solX+plx
	psy = solY+ply
	stationFaction = "Independent"
	si = math.random(1,#placeStation)			--station index
	pStation = placeStation[si]()				--place selected station
	table.remove(placeStation,si)				--remove station from placement list
	neutralStationStrength = neutralStationStrength + setStationStrength(pStation)
	pStation:onDestruction(neutralStationDestroyed)
	pStation.comms_data.orbit = string.format("orbiting %s with the inner asteroids at a distance of %.1fU",planetSol:getCallSign(),beltOrbit1/1000)
	table.insert(stationList,pStation)			--save station in general station list
	table.insert(neutralStationList,pStation)	--save station in neutral station list
	table.insert(belt1Stations,pStation)
	table.insert(clueStations,pStation)			--6
	pStation.angle = beltStationAngle
	--asteroids between station 1 and station 3 (counter-clockwise)
	local asteroidPopulation = math.random(8,20)
	beltStationAngle = belt1Stations[1].angle - random(15,30)
	if beltStationAngle < 0 then 
		beltStationAngle = beltStationAngle + 360
	end
	createOrbitalAsteroids(asteroidPopulation,beltOrbit1,beltStationAngle,belt1Stations[1].angle-1,"belt1",math.floor(beltOrbit1Width/2))
	--belt 1 station 3
	beltStationAngle = beltStationAngle - 1
	if beltStationAngle < 0 then
		beltStationAngle = beltStationAngle + 360
	end
	plx, ply = vectorFromAngle(beltStationAngle,beltOrbit1)
	psx = solX+plx
	psy = solY+ply
	stationFaction = "Independent"
	si = math.random(1,#placeStation)			--station index
	pStation = placeStation[si]()				--place selected station
	table.remove(placeStation,si)				--remove station from placement list
	neutralStationStrength = neutralStationStrength + setStationStrength(pStation)
	pStation:onDestruction(neutralStationDestroyed)
	pStation.comms_data.orbit = string.format("orbiting %s with the inner asteroids at a distance of %.1fU",planetSol:getCallSign(),beltOrbit1/1000)
	table.insert(stationList,pStation)			--save station in general station list
	table.insert(neutralStationList,pStation)	--save station in neutral station list
	table.insert(belt1Stations,pStation)
	table.insert(clueStations,pStation)			--7
	pStation.angle = beltStationAngle
	--asteroids between station 2 and 4 (clockwise)
	local asteroidPopulation = math.random(8,20)
	beltStationAngle = belt1Stations[2].angle + random(20,60)
	createOrbitalAsteroids(asteroidPopulation,beltOrbit1,belt1Stations[2].angle,beltStationAngle-1,"belt1",math.floor(beltOrbit1Width/2))
	--belt 1 station 4
	beltStationAngle = beltStationAngle + 1
	plx, ply = vectorFromAngle(beltStationAngle,beltOrbit1)
	psx = solX+plx
	psy = solY+ply
	stationFaction = "Independent"
	si = math.random(1,#placeStation)			--station index
	pStation = placeStation[si]()				--place selected station
	table.remove(placeStation,si)				--remove station from placement list
	neutralStationStrength = neutralStationStrength + setStationStrength(pStation)
	pStation:onDestruction(neutralStationDestroyed)
	pStation.comms_data.orbit = string.format("orbiting %s with the inner asteroids at a distance of %.1fU",planetSol:getCallSign(),beltOrbit1/1000)
	table.insert(stationList,pStation)			--save station in general station list
	table.insert(neutralStationList,pStation)	--save station in neutral station list
	table.insert(belt1Stations,pStation)
	table.insert(clueStations,pStation)			--8
	pStation.angle = beltStationAngle
	--asteroids between station 3 and 5 (counter clockwise)
	local asteroidPopulation = math.random(8,20)
	beltStationAngle = belt1Stations[3].angle - random(20,60)
	if beltStationAngle < 0 then 
		beltStationAngle = beltStationAngle + 360
	end
	createOrbitalAsteroids(asteroidPopulation,beltOrbit1,beltStationAngle,belt1Stations[3].angle-1,"belt1",math.floor(beltOrbit1Width/2))
	--belt 1 station 5
	beltStationAngle = beltStationAngle - 1
	if beltStationAngle < 0 then
		beltStationAngle = beltStationAngle + 360
	end
	plx, ply = vectorFromAngle(beltStationAngle,beltOrbit1)
	psx = solX+plx
	psy = solY+ply
	stationFaction = "Independent"
	si = math.random(1,#placeStation)			--station index
	pStation = placeStation[si]()				--place selected station
	table.remove(placeStation,si)				--remove station from placement list
	neutralStationStrength = neutralStationStrength + setStationStrength(pStation)
	pStation:onDestruction(neutralStationDestroyed)
	pStation.comms_data.orbit = string.format("orbiting %s with the inner asteroids at a distance of %.1fU",planetSol:getCallSign(),beltOrbit1/1000)
	table.insert(stationList,pStation)			--save station in general station list
	table.insert(neutralStationList,pStation)	--save station in neutral station list
	table.insert(belt1Stations,pStation)
	table.insert(clueStations,pStation)			--9
	pStation.angle = beltStationAngle
	--asteroids trailing station 4 (clockwise)
	local asteroidPopulation = math.random(8,20)
	beltStationAngle = belt1Stations[4].angle + random(30,90)
	createOrbitalAsteroids(asteroidPopulation,beltOrbit1,belt1Stations[4].angle,beltStationAngle-1,"belt1",math.floor(beltOrbit1Width/2))
	--asteroids trailing station 5 (counter clockwise)
	local asteroidPopulation = math.random(8,20)
	beltStationAngle = belt1Stations[5].angle - random(30,90)
	if beltStationAngle < 0 then 
		beltStationAngle = beltStationAngle + 360
	end
	createOrbitalAsteroids(asteroidPopulation,beltOrbit1,beltStationAngle,belt1Stations[5].angle-1,"belt1",math.floor(beltOrbit1Width/2))
	plx, ply = vectorFromAngle(beltStationAngle + 10,beltOrbit1)
	belt1Artifact = Artifact():setPosition(solX+plx,solY+ply):setScanningParameters(3,2):setRadarSignatureInfo(1,1,0)
	belt1Artifact:setModel("artifact6"):allowPickup(false):setDescriptions("Sensor readings change as the object orbits with the asteroid belt","Object exhibits periodic spikes of chroniton particles")
	belt1Artifact.angle = beltStationAngle + 10
	------------------------------
	-- populate asteroid belt 2 --
	------------------------------
	--belt 2 station 1
	belt2Stations = {}
	beltStationAngle = random(0,360)
	lo = 2
	hi = 9
	gradient = 900
	if orbitChoice == "lo" then
		belt2OrbitalSpeed = lo/gradient*difficulty
	elseif orbitChoice == "hi" then
		belt2OrbitalSpeed = hi/gradient*difficulty
	else
		belt2OrbitalSpeed = math.random(lo,hi)/gradient*difficulty
	end
	beltOrbitalSpeed = belt2OrbitalSpeed
	plx, ply = vectorFromAngle(beltStationAngle,beltOrbit2)
	psx = solX+plx
	psy = solY+ply
	stationFaction = "Human Navy"
	si = math.random(1,#placeStation)			--station index
	pStation = placeStation[si]()				--place selected station
	table.remove(placeStation,si)				--remove station from placement list
	humanStationStrength = humanStationStrength + setStationStrength(pStation)
	pStation:onDestruction(humanStationDestroyed)
	pStation.comms_data.orbit = string.format("orbiting %s with the outer asteroids at a distance of %.1fU",planetSol:getCallSign(),beltOrbit2/1000)
	table.insert(stationList,pStation)			--save station in general station list
	table.insert(humanStationList,pStation)		--save station in friendly station list
	table.insert(belt2Stations,pStation)
	table.insert(clueStations,pStation)			--10
	pStation.angle = beltStationAngle
	--asteroids between station 1 and station 2 (clockwise)
	beltStationAngle = beltStationAngle + random(20,60)
	local asteroidPopulation = math.random(8,20)
	createOrbitalAsteroids(asteroidPopulation,beltOrbit2,belt2Stations[1].angle,beltStationAngle-1,"belt2",math.floor(beltOrbit2Width/2))
	--belt 2 station 2
	beltStationAngle = beltStationAngle + 1
	plx, ply = vectorFromAngle(beltStationAngle,beltOrbit2)
	psx = solX+plx
	psy = solY+ply
	stationFaction = "Independent"
	si = math.random(1,#placeStation)			--station index
	pStation = placeStation[si]()				--place selected station
	table.remove(placeStation,si)				--remove station from placement list
	neutralStationStrength = neutralStationStrength + setStationStrength(pStation)
	pStation:onDestruction(neutralStationDestroyed)
	pStation.comms_data.orbit = string.format("orbiting %s with the outer asteroids at a distance of %.1fU",planetSol:getCallSign(),beltOrbit2/1000)
	table.insert(stationList,pStation)			--save station in general station list
	table.insert(neutralStationList,pStation)	--save station in neutral station list
	table.insert(belt2Stations,pStation)
	table.insert(clueStations,pStation)			--11
	pStation.angle = beltStationAngle
	--asteroids between station 1 and station 3 (counter-clockwise)
	local asteroidPopulation = math.random(8,20)
	beltStationAngle = belt2Stations[1].angle - random(20,60)
	if beltStationAngle < 0 then 
		beltStationAngle = beltStationAngle + 360
	end
	createOrbitalAsteroids(asteroidPopulation,beltOrbit2,beltStationAngle,belt2Stations[1].angle-1,"belt2",math.floor(beltOrbit2Width/2))
	--belt 2 station 3
	beltStationAngle = beltStationAngle - 1
	if beltStationAngle < 0 then
		beltStationAngle = beltStationAngle + 360
	end
	plx, ply = vectorFromAngle(beltStationAngle,beltOrbit2)
	psx = solX+plx
	psy = solY+ply
	stationFaction = "Independent"
	si = math.random(1,#placeStation)			--station index
	pStation = placeStation[si]()				--place selected station
	table.remove(placeStation,si)				--remove station from placement list
	neutralStationStrength = neutralStationStrength + setStationStrength(pStation)
	pStation:onDestruction(neutralStationDestroyed)
	pStation.comms_data.orbit = string.format("orbiting %s with the outer asteroids at a distance of %.1fU",planetSol:getCallSign(),beltOrbit2/1000)
	table.insert(stationList,pStation)			--save station in general station list
	table.insert(neutralStationList,pStation)	--save station in neutral station list
	table.insert(belt2Stations,pStation)
	table.insert(clueStations,pStation)			--12
	pStation.angle = beltStationAngle
	--asteroids between station 2 and 4 (clockwise)
	local asteroidPopulation = math.random(8,20)
	beltStationAngle = belt2Stations[2].angle + random(25,60)
	createOrbitalAsteroids(asteroidPopulation,beltOrbit2,belt2Stations[2].angle,beltStationAngle-1,"belt2",math.floor(beltOrbit2Width/2))
	--belt 2 station 4
	beltStationAngle = beltStationAngle + 1
	plx, ply = vectorFromAngle(beltStationAngle,beltOrbit2)
	psx = solX+plx
	psy = solY+ply
	stationFaction = "Independent"
	si = math.random(1,#placeStation)			--station index
	pStation = placeStation[si]()				--place selected station
	table.remove(placeStation,si)				--remove station from placement list
	neutralStationStrength = neutralStationStrength + setStationStrength(pStation)
	pStation:onDestruction(neutralStationDestroyed)
	pStation.comms_data.orbit = string.format("orbiting %s with the outer asteroids at a distance of %.1fU",planetSol:getCallSign(),beltOrbit2/1000)
	table.insert(stationList,pStation)			--save station in general station list
	table.insert(neutralStationList,pStation)	--save station in neutral station list
	table.insert(belt2Stations,pStation)
	table.insert(clueStations,pStation)			--13
	pStation.angle = beltStationAngle
	--asteroids between station 3 and 5 (counter clockwise)
	local asteroidPopulation = math.random(8,20)
	beltStationAngle = belt2Stations[3].angle - random(25,60)
	if beltStationAngle < 0 then 
		beltStationAngle = beltStationAngle + 360
	end
	createOrbitalAsteroids(asteroidPopulation,beltOrbit2,beltStationAngle,belt2Stations[3].angle-1,"belt2",math.floor(beltOrbit2Width/2))
	--belt 2 station 5
	beltStationAngle = beltStationAngle - 1
	if beltStationAngle < 0 then
		beltStationAngle = beltStationAngle + 360
	end
	plx, ply = vectorFromAngle(beltStationAngle,beltOrbit2)
	psx = solX+plx
	psy = solY+ply
	stationFaction = "Independent"
	si = math.random(1,#placeStation)			--station index
	pStation = placeStation[si]()				--place selected station
	table.remove(placeStation,si)				--remove station from placement list
	neutralStationStrength = neutralStationStrength + setStationStrength(pStation)
	pStation:onDestruction(neutralStationDestroyed)
	pStation.comms_data.orbit = string.format("orbiting %s with the outer asteroids at a distance of %.1fU",planetSol:getCallSign(),beltOrbit2/1000)
	table.insert(stationList,pStation)			--save station in general station list
	table.insert(neutralStationList,pStation)	--save station in neutral station list
	table.insert(belt2Stations,pStation)
	table.insert(clueStations,pStation)			--14
	pStation.angle = beltStationAngle
	--asteroids trailing station 4 (clockwise)
	local asteroidPopulation = math.random(8,20)
	beltStationAngle = belt2Stations[4].angle + random(30,90)
	createOrbitalAsteroids(asteroidPopulation,beltOrbit2,belt2Stations[4].angle,beltStationAngle-1,"belt2",math.floor(beltOrbit2Width/2))
	--asteroids trailing station 5 (counter clockwise)
	local asteroidPopulation = math.random(8,20)
	beltStationAngle = belt2Stations[5].angle - random(30,90)
	if beltStationAngle < 0 then 
		beltStationAngle = beltStationAngle + 360
	end
	createOrbitalAsteroids(asteroidPopulation,beltOrbit2,beltStationAngle,belt2Stations[5].angle-1,"belt2",math.floor(beltOrbit2Width/2))
	local nebula_angle = random(0,360)
	plx, ply = vectorFromAngle(nebula_angle,beltOrbit2)
	belt_2_nebula = Nebula():setPosition(solX+plx,solY+ply)
	belt_2_nebula.angle = nebula_angle
	------------------------------------
	-- Third closest planet (tertius) --
	------------------------------------
	outerBelt2 = beltOrbit2 + (beltOrbit2Width/2)
	tertiusRadius = random(10000,20000)
	tertiusMoonOrbit = random(tertiusRadius+2000,tertiusRadius+15000)
	tertiusMoon1Radius = random(200,500)
	tertiusMoon2Radius = random(200,500)
	tertiusMoon3Radius = random(200,500)
	tertiusAsteroidOrbit = tertiusMoonOrbit + random(2000,4000)
	tertiusAsteroidOrbitWidth = tertiusAsteroidOrbit - tertiusMoonOrbit - 500
	tertiusBandWidth = (tertiusAsteroidOrbit + (tertiusAsteroidOrbitWidth/2))*2
	tertiusOrbit = random(outerBelt2 + tertiusBandWidth + 8000, outerBelt2 + tertiusBandWidth + 50000)
	outerBelt2Spawn = (outerBelt2 + (tertiusOrbit - (tertiusBandWidth/2)))/2
	outerBelt2SpawnWidth = (tertiusOrbit - tertiusBandWidth/2) - outerBelt2 - 3000
	lo = 3
	hi = 8
	gradient = 400
	if orbitChoice == "lo" then
		tertiusOrbitalBodyIncrement = lo/gradient*difficulty
	elseif orbitChoice == "hi" then
		tertiusOrbitalBodyIncrement = hi/gradient*difficulty
	else
		tertiusOrbitalBodyIncrement = math.random(lo,hi)/gradient*difficulty
	end
	pla = random(0,360)
	plx, ply = vectorFromAngle(pla,tertiusOrbit)
	planetTertius = Planet():setPosition(solX+plx,solY+ply):setPlanetRadius(tertiusRadius):setAxialRotationTime(random(300,700)):setDistanceFromMovementPlane(2000)
	planetTertius:setPlanetSurfaceTexture("planets/gas-1.png")
	planetTertius.orbit_speed = random(2000,6000)
	planetTertius:setOrbit(planetSol,planetTertius.orbit_speed)
	planetTertius:setCallSign(tertiusNames[math.random(1,#tertiusNames)])
	tertiusX, tertiusY = planetTertius:getPosition()
	--tertius moons
	tertiusMoon1Angle = random(0,360)
	plx, ply = vectorFromAngle(tertiusMoon1Angle,tertiusMoonOrbit)
	planetTertiusMoon1 = Planet():setPosition(tertiusX+plx,tertiusY+ply):setPlanetRadius(tertiusMoon1Radius):setAxialRotationTime(random(40,80)):setDistanceFromMovementPlane(tertiusMoon1Radius/2)
	planetTertiusMoon1:setPlanetSurfaceTexture("planets/moon-1.png")
	planetTertiusMoon1.angle = tertiusMoon1Angle
	tertiusMoon2Angle = tertiusMoon1Angle + random(30,165)
	plx, ply = vectorFromAngle(tertiusMoon2Angle,tertiusMoonOrbit)
	planetTertiusMoon2 = Planet():setPosition(tertiusX+plx,tertiusY+ply):setPlanetRadius(tertiusMoon2Radius):setAxialRotationTime(random(40,80)):setDistanceFromMovementPlane(tertiusMoon2Radius/2)
	planetTertiusMoon2:setPlanetSurfaceTexture("planets/moon-1.png")
	planetTertiusMoon2.angle = tertiusMoon2Angle
	tertiusMoon3Angle = tertiusMoon1Angle + random(195,330)
	plx, ply = vectorFromAngle(tertiusMoon3Angle,tertiusMoonOrbit)
	planetTertiusMoon3 = Planet():setPosition(tertiusX+plx,tertiusY+ply):setPlanetRadius(tertiusMoon3Radius):setAxialRotationTime(random(40,80)):setDistanceFromMovementPlane(tertiusMoon3Radius/2)
	planetTertiusMoon3:setPlanetSurfaceTexture("planets/moon-1.png")
	planetTertiusMoon3.angle = tertiusMoon3Angle
	--tertius station orbiting with tertius moons
	local orbitalGap1 = tertiusMoon2Angle - tertiusMoon1Angle
	local orbitalGap2 = tertiusMoon3Angle - tertiusMoon2Angle
	local orbitalGap3 = tertiusMoon1Angle + 360 - tertiusMoon3Angle
	local maxGap = math.max(orbitalGap1, orbitalGap2, orbitalGap3)
	if maxGap == orbitalGap1 then
		tertiusStationAngle = (tertiusMoon2Angle + tertiusMoon1Angle)/2
	elseif maxGap == orbitalGap2 then
		tertiusStationAngle = (tertiusMoon3Angle + tertiusMoon2Angle)/2
	else
		tertiusStationAngle = (tertiusMoon1Angle + 360 + tertiusMoon3Angle)/2
		if tertiusStationAngle > 360 then
			tertiusStationAngle = tertiusStationAngle - 360
		end
	end
	plx, ply = vectorFromAngle(tertiusStationAngle,tertiusMoonOrbit)
	psx = tertiusX+plx
	psy = tertiusY+ply
	stationFaction = "Human Navy"
	si = math.random(1,#placeStation)			--station index
	pStation = placeStation[si]()				--place selected station
	table.remove(placeStation,si)				--remove station from placement list
	humanStationStrength = humanStationStrength + setStationStrength(pStation)
	pStation:onDestruction(humanStationDestroyed)
	pStation.comms_data.orbit = string.format("orbiting %s with the moons and asteroids at a distance of %.1fU",planetTertius:getCallSign(),tertiusMoonOrbit/1000)
	table.insert(stationList,pStation)			--save station in general station list
	table.insert(humanStationList,pStation)		--save station in friendly station list
	table.insert(clueStations,pStation)			--15
	tertiusStation = pStation
	tertiusStation.angle = tertiusStationAngle
	tertiusAsteroids = {}
	--tertius moon asteroids clockwise
	beltStationAngle = tertiusStationAngle + random(30,60)
	local asteroidPopulation = math.random(5,15)
	createTertiusOrbitalAsteroids(asteroidPopulation,tertiusMoonOrbit,tertiusStationAngle,beltStationAngle,250,tertiusOrbitalBodyIncrement,"tMoonBelt")
	--tertius moon asteroids counter-clockwise
	beltStationAngle = tertiusStationAngle - random(30,60)
	if beltStationAngle < 360 then
		beltStationAngle = beltStationAngle + 360
	end
	local asteroidPopulation = math.random(5,15)
	createTertiusOrbitalAsteroids(asteroidPopulation,tertiusMoonOrbit,beltStationAngle,tertiusStationAngle-1,250,tertiusOrbitalBodyIncrement,"tMoonBelt")
	-- tertius moon 1 station
	tertiusMoon1StationOrbit = tertiusMoon1Radius + 250
	stationSize = "Small Station"
	plx, ply = vectorFromAngle(0,tertiusMoon1StationOrbit)
	pmx, pmy = planetTertiusMoon1:getPosition()
	psx = pmx + plx
	psy = pmy + ply
	si = math.random(1,#placeStation)			--station index
	pStation = placeStation[si]()				--place selected station
	table.remove(placeStation,si)				--remove station from placement list
	humanStationStrength = humanStationStrength + setStationStrength(pStation)
	pStation:onDestruction(humanStationDestroyed)
	pStation.comms_data.orbit = string.format("orbiting a moon of %s at a distance of %.1fU",planetTertius:getCallSign(),tertiusMoon1StationOrbit/1000)
	table.insert(stationList,pStation)			--save station in general station list
	table.insert(humanStationList,pStation)		--save station in friendly station list
	table.insert(clueStations,pStation)			--16
	tertiusMoon1Station = pStation
	tertiusMoon1Station.angle = 0
	tertiusMoon1Station.distance = tertiusMoon1StationOrbit
	--tertius outer asteroid belt station 1
	tertiusAsteroidStations = {}
	stationSize = nil
	lo = 1
	hi = 10
	if orbitChoice == "lo" then
		differential = lo/800
	elseif orbitChoice == "hi" then
		differential = hi/800
	else
		differential = math.random(lo,hi)/200
	end
	if random(1,100) < 50 then
		tertiusAsteroidBeltIncrement = tertiusOrbitalBodyIncrement + differential
	else
		tertiusAsteroidBeltIncrement = tertiusOrbitalBodyIncrement - differential
	end
	beltStationAngle = random(0,360)
	plx, ply = vectorFromAngle(beltStationAngle,tertiusAsteroidOrbit)
	psx = tertiusX+plx
	psy = tertiusY+ply
	stationFaction = "Human Navy"
	si = math.random(1,#placeStation)			--station index
	pStation = placeStation[si]()				--place selected station
	table.remove(placeStation,si)				--remove station from placement list
	humanStationStrength = humanStationStrength + setStationStrength(pStation)
	pStation:onDestruction(humanStationDestroyed)
	pStation.comms_data.orbit = string.format("orbiting %s with the outer asteroids at a distance of %.1fU",planetTertius:getCallSign(),tertiusAsteroidOrbit/1000)
	table.insert(stationList,pStation)			--save station in general station list
	table.insert(humanStationList,pStation)		--save station in friendly station list
	table.insert(clueStations,pStation)			--16
	table.insert(tertiusAsteroidStations,pStation)
	pStation.angle = beltStationAngle
	pStation.speed = tertiusAsteroidBeltIncrement
	--tertius outer asteroids between stations 1 and 2
	beltStationAngle = tertiusAsteroidStations[1].angle + random(15,60)
	local asteroidPopulation = math.random(5,15)
	createTertiusOrbitalAsteroids(asteroidPopulation,tertiusAsteroidOrbit,tertiusAsteroidStations[1].angle,beltStationAngle,tertiusAsteroidOrbitWidth/2,tertiusAsteroidBeltIncrement,"tBelt2")
	--tertius outer asteroid belt station 2
	beltStationAngle = beltStationAngle + 1
	plx, ply = vectorFromAngle(beltStationAngle,tertiusAsteroidOrbit)
	psx = tertiusX+plx
	psy = tertiusY+ply
	stationFaction = "Independent"
	si = math.random(1,#placeStation)			--station index
	pStation = placeStation[si]()				--place selected station
	table.remove(placeStation,si)				--remove station from placement list
	neutralStationStrength = neutralStationStrength + setStationStrength(pStation)
	pStation:onDestruction(neutralStationDestroyed)
	pStation.comms_data.orbit = string.format("orbiting %s with the outer asteroids at a distance of %.1fU",planetTertius:getCallSign(),tertiusAsteroidOrbit/1000)
	table.insert(stationList,pStation)			--save station in general station list
	table.insert(neutralStationList,pStation)	--save station in neutral station list
	table.insert(tertiusAsteroidStations,pStation)
	table.insert(clueStations,pStation)			--17
	pStation.angle = beltStationAngle
	pStation.speed = tertiusAsteroidBeltIncrement
	--tertius outer asteroids between stations 2 and 3
	beltStationAngle = tertiusAsteroidStations[2].angle + random(15,60)
	local asteroidPopulation = math.random(5,15)
	createTertiusOrbitalAsteroids(asteroidPopulation,tertiusAsteroidOrbit,tertiusAsteroidStations[2].angle,beltStationAngle,tertiusAsteroidOrbitWidth/2,tertiusAsteroidBeltIncrement,"tBelt2")
	--tertius outer asteroid belt station 3
	beltStationAngle = beltStationAngle + 1
	plx, ply = vectorFromAngle(beltStationAngle,tertiusAsteroidOrbit)
	psx = tertiusX+plx
	psy = tertiusY+ply
	stationFaction = "Independent"
	si = math.random(1,#placeStation)			--station index
	pStation = placeStation[si]()				--place selected station
	table.remove(placeStation,si)				--remove station from placement list
	neutralStationStrength = neutralStationStrength + setStationStrength(pStation)
	pStation:onDestruction(neutralStationDestroyed)
	pStation.comms_data.orbit = string.format("orbiting %s with the outer asteroids at a distance of %.1fU",planetTertius:getCallSign(),tertiusAsteroidOrbit/1000)
	table.insert(stationList,pStation)			--save station in general station list
	table.insert(neutralStationList,pStation)	--save station in neutral station list
	table.insert(tertiusAsteroidStations,pStation)
	table.insert(clueStations,pStation)			--18
	pStation.angle = beltStationAngle
	pStation.speed = tertiusAsteroidBeltIncrement
	--tertius outer asteroids between stations 3 and 4
	beltStationAngle = tertiusAsteroidStations[3].angle + random(15,60)
	local asteroidPopulation = math.random(5,15)
	createTertiusOrbitalAsteroids(asteroidPopulation,tertiusAsteroidOrbit,tertiusAsteroidStations[3].angle,beltStationAngle,tertiusAsteroidOrbitWidth/2,tertiusAsteroidBeltIncrement,"tBelt2")
	--tertius outer asteroid belt station 4
	beltStationAngle = beltStationAngle + 1
	plx, ply = vectorFromAngle(beltStationAngle,tertiusAsteroidOrbit)
	psx = tertiusX+plx
	psy = tertiusY+ply
	stationFaction = "Independent"
	si = math.random(1,#placeStation)			--station index
	pStation = placeStation[si]()				--place selected station
	table.remove(placeStation,si)				--remove station from placement list
	neutralStationStrength = neutralStationStrength + setStationStrength(pStation)
	pStation:onDestruction(neutralStationDestroyed)
	pStation.comms_data.orbit = string.format("orbiting %s with the outer asteroids at a distance of %.1fU",planetTertius:getCallSign(),tertiusAsteroidOrbit/1000)
	table.insert(stationList,pStation)			--save station in general station list
	table.insert(neutralStationList,pStation)	--save station in neutral station list
	table.insert(tertiusAsteroidStations,pStation)
	table.insert(clueStations,pStation)			--19
	pStation.angle = beltStationAngle
	pStation.speed = tertiusAsteroidBeltIncrement
	--tertius outer asteroids between stations 3 and 4
	beltStationAngle = tertiusAsteroidStations[4].angle + random(15,60)
	local asteroidPopulation = math.random(5,15)
	createTertiusOrbitalAsteroids(asteroidPopulation,tertiusAsteroidOrbit,tertiusAsteroidStations[4].angle,beltStationAngle,tertiusAsteroidOrbitWidth/2,tertiusAsteroidBeltIncrement,"tBelt2")
	--tertius outer asteroid belt station 5
	beltStationAngle = beltStationAngle + 1
	plx, ply = vectorFromAngle(beltStationAngle,tertiusAsteroidOrbit)
	psx = tertiusX+plx
	psy = tertiusY+ply
	stationFaction = "Independent"
	si = math.random(1,#placeStation)			--station index
	pStation = placeStation[si]()				--place selected station
	table.remove(placeStation,si)				--remove station from placement list
	neutralStationStrength = neutralStationStrength + setStationStrength(pStation)
	pStation:onDestruction(neutralStationDestroyed)
	pStation.comms_data.orbit = string.format("orbiting %s with the outer asteroids at a distance of %.1fU",planetTertius:getCallSign(),tertiusAsteroidOrbit/1000)
	table.insert(stationList,pStation)			--save station in general station list
	table.insert(neutralStationList,pStation)	--save station in neutral station list
	table.insert(tertiusAsteroidStations,pStation)
	table.insert(clueStations,pStation)			--20
	pStation.angle = beltStationAngle
	pStation.speed = tertiusAsteroidBeltIncrement
	--tertius outer asteroids between stations 5 and 6
	beltStationAngle = tertiusAsteroidStations[5].angle + random(15,60)
	local asteroidPopulation = math.random(5,15)
	createTertiusOrbitalAsteroids(asteroidPopulation,tertiusAsteroidOrbit,tertiusAsteroidStations[5].angle,beltStationAngle,tertiusAsteroidOrbitWidth/2,tertiusAsteroidBeltIncrement,"tBelt2")
	--tertius outer asteroid belt station 6
	beltStationAngle = beltStationAngle + 1
	plx, ply = vectorFromAngle(beltStationAngle,tertiusAsteroidOrbit)
	psx = tertiusX+plx
	psy = tertiusY+ply
	stationFaction = "Independent"
	si = math.random(1,#placeStation)			--station index
	pStation = placeStation[si]()				--place selected station
	table.remove(placeStation,si)				--remove station from placement list
	neutralStationStrength = neutralStationStrength + setStationStrength(pStation)
	pStation:onDestruction(neutralStationDestroyed)
	pStation.comms_data.orbit = string.format("orbiting %s with the outer asteroids at a distance of %.1fU",planetTertius:getCallSign(),tertiusAsteroidOrbit/1000)
	table.insert(stationList,pStation)			--save station in general station list
	table.insert(neutralStationList,pStation)	--save station in neutral station list
	table.insert(tertiusAsteroidStations,pStation)
	table.insert(clueStations,pStation)			--21
	pStation.angle = beltStationAngle
	pStation.speed = tertiusAsteroidBeltIncrement
	
	--outer belt 2 stations (beyond asteroid belt, before Tertius)
	outerBelt2Stations = {}
	sa1 = random(0,360)
	sa2 = sa1 + 120
	sa3 = sa2 + 120
	for i=1,4 do
		plx, ply = vectorFromAngle(sa1,outerBelt2Spawn - (outerBelt2SpawnWidth/2) + random(1,outerBelt2SpawnWidth))
		psx = solX+plx
		psy = solY+ply
		if random(1,100) < 12 then
			stationFaction = "Human Navy"				--set station faction
		else
			stationFaction = "Independent"				--set station faction
		end
		si = math.random(1,#placeStation)			--station index
		pStation = placeStation[si]()				--place selected station
		table.remove(placeStation,si)				--remove station from placement list
		if stationFaction == "Human Navy" then
			humanStationStrength = humanStationStrength + setStationStrength(pStation)
			pStation:onDestruction(humanStationDestroyed)
			table.insert(humanStationList,pStation)		--save station in friendly station list
		else
			neutralStationStrength = neutralStationStrength + setStationStrength(pStation)
			pStation:onDestruction(neutralStationDestroyed)
			table.insert(neutralStationList,pStation)		--save station in friendly station list
		end
		table.insert(stationList,pStation)			--save station in general station list
		table.insert(outerBelt2Stations,pStation)
		table.insert(clueStations,pStation)			--22-25
		if random(1,100) < 8 then
			local abx, aby = vectorFromAngle(sa1,outerBelt2Spawn)
			placeRandomAroundPoint(Asteroid,math.random(6,20),1,7800,solX+abx,solY+aby)
		end
		sa1 = sa1 + random(12,30)
		plx, ply = vectorFromAngle(sa2,outerBelt2Spawn - (outerBelt2SpawnWidth/2) + random(1,outerBelt2SpawnWidth))
		psx = solX+plx
		psy = solY+ply
		if random(1,100) < 12 then
			stationFaction = "Human Navy"				--set station faction
		else
			stationFaction = "Independent"				--set station faction
		end
		si = math.random(1,#placeStation)			--station index
		pStation = placeStation[si]()				--place selected station
		table.remove(placeStation,si)				--remove station from placement list
		if stationFaction == "Human Navy" then
			humanStationStrength = humanStationStrength + setStationStrength(pStation)
			pStation:onDestruction(humanStationDestroyed)
			table.insert(humanStationList,pStation)		--save station in friendly station list
		else
			neutralStationStrength = neutralStationStrength + setStationStrength(pStation)
			pStation:onDestruction(neutralStationDestroyed)
			table.insert(neutralStationList,pStation)		--save station in friendly station list
		end
		table.insert(stationList,pStation)			--save station in general station list
		table.insert(outerBelt2Stations,pStation)
		table.insert(clueStations,pStation)			--26-29
		if random(1,100) < 8 then
			local abx, aby = vectorFromAngle(sa2,outerBelt2Spawn)
			placeRandomAroundPoint(Asteroid,math.random(6,20),1,7800,solX+abx,solY+aby)
		end
		sa2 = sa2 + random(12,30)
		plx, ply = vectorFromAngle(sa3,outerBelt2Spawn - (outerBelt2SpawnWidth/2) + random(1,outerBelt2SpawnWidth))
		psx = solX+plx
		psy = solY+ply
		if random(1,100) < 12 then
			stationFaction = "Human Navy"				--set station faction
		else
			stationFaction = "Independent"				--set station faction
		end
		si = math.random(1,#placeStation)			--station index
		pStation = placeStation[si]()				--place selected station
		table.remove(placeStation,si)				--remove station from placement list
		if stationFaction == "Human Navy" then
			humanStationStrength = humanStationStrength + setStationStrength(pStation)
			pStation:onDestruction(humanStationDestroyed)
			table.insert(humanStationList,pStation)		--save station in friendly station list
		else
			neutralStationStrength = neutralStationStrength + setStationStrength(pStation)
			pStation:onDestruction(neutralStationDestroyed)
			table.insert(neutralStationList,pStation)		--save station in friendly station list
		end
		table.insert(stationList,pStation)			--save station in general station list
		table.insert(outerBelt2Stations,pStation)
		table.insert(clueStations,pStation)			--30-33
		if random(1,100) < 8 then
			local abx, aby = vectorFromAngle(sa3,outerBelt2Spawn)
			placeRandomAroundPoint(Asteroid,math.random(6,20),1,7800,solX+abx,solY+aby)
		end
		sa3 = sa3 + random(12,30)
	end
	local si = {1,4,7,10,2,5,8,11,3,6,9,12}	--start indices
	local ei = {4,7,10,2,5,8,11,3,6,9,12,1}	--end indices
	transportsOutsideBelt2List = {}
	for i=1,12 do
		name = transportType[math.random(1,#transportType)]
		if random(1,100) < 30 then
			name = name .. " Jump Freighter " .. math.random(3, 5)
		else
			name = name .. " Freighter " .. math.random(1, 5)
		end
		psx, psy = outerBelt2Stations[si[i]]:getPosition()
		tempTransport = CpuShip():setTemplate(name):setPosition(psx,psy):setFaction(outerBelt2Stations[si[i]]:getFaction()):setCommsScript(""):setCommsFunction(commsShip)
		tempTransport.targetStart = outerBelt2Stations[si[i]]
		tempTransport.targetEnd = outerBelt2Stations[ei[i]]
		if random(1,100) < 50 then
			tempTransport:orderDock(tempTransport.targetStart)
		else
			tempTransport:orderDock(tempTransport.targetEnd)
		end
		table.insert(transportsOutsideBelt2List,tempTransport)
	end
	nebulaRiver()
end
function nebulaRiver()
	local nebula_list = {}
	local out_angle = random(0,360)
	local nmpx, nmpy = vectorFromAngle(out_angle,random(10000,30000))
	nmpx = solX + nmpx
	nmpy = solY + nmpy
	river_names = {"Ankh","Lancre","Styx","Indus","Chenab","Turbio","Mithil","Sirion"}
	river_nebula = Nebula():setPosition(nmpx,nmpy):setCallSign(river_names[math.random(1,#river_names)])
	table.insert(nebula_list,river_nebula)
	local left_angle = out_angle + 90
	left_angle = left_angle + random(-10,10)
	if left_angle < 0 then
		left_angle = left_angle + 360
	end
	if left_angle > 360 then
		left_angle = left_angle - 360
	end
	local dlbx, dlby = vectorFromAngle(left_angle,random(2500,10000))
	local lbx = nmpx + dlbx
	local lby = nmpy + dlby
	table.insert(nebula_list,Nebula():setPosition(lbx,lby))
	local right_angle = out_angle + 270
	right_angle = right_angle + random(-10,10)
	if right_angle < 0 then
		right_angle = right_angle + 360
	end
	if right_angle > 0 then
		right_angle = right_angle - 360
	end
	local drbx, drby = vectorFromAngle(right_angle,random(2500,10000))
	local rbx = nmpx + drbx
	local rby = nmpy + drby
	table.insert(nebula_list,Nebula():setPosition(rbx,rby))
	for i=1,10 do
		left_angle = left_angle + random(-25,25)
		if left_angle < 0 then
			left_angle = left_angle + 360
		end
		if left_angle > 360 then
			left_angle = left_angle - 360
		end
		dlbx, dlby = vectorFromAngle(left_angle,random(2500,15000)+i*1500)
		lbx = lbx + dlbx
		lby = lby + dlby
		table.insert(nebula_list,Nebula():setPosition(lbx,lby))
		for j=1,math.random(0,3) do
			dlbx, dlby = vectorFromAngle(random(0,360),random(4000,20000))
			table.insert(nebula_list,Nebula():setPosition(lbx+dlbx,lby+dlby))
		end
		right_angle = right_angle + random(-25,25)
		if right_angle < 0 then
			right_angle = right_angle + 360
		end
		if right_angle > 0 then
			right_angle = right_angle - 360
		end
		drbx, drby = vectorFromAngle(right_angle,random(2500,15000)+i*1500)
		rbx = rbx + drbx
		rby = rby + drby
		table.insert(nebula_list,Nebula():setPosition(rbx,rby))
		for j=1,math.random(0,3) do
			drbx, drby = vectorFromAngle(random(0,360),random(4000,20000))
			table.insert(nebula_list,Nebula():setPosition(rbx+drbx,rby+drby))
		end
	end
	coolant_nebula = {}
	local nebula_index = 0
	for i=1,#nebula_list do
		nebula_list[i].lose = false
		nebula_list[i].gain = false
	end
	local nebula_count = #nebula_list
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
function createTertiusOrbitalAsteroids(amount,distance,startArc,clockwiseEndArc,randomize,speedIncrement,belt_id)
	if randomize == nil then randomize = 0 end
	if amount == nil then amount = 1 end
	local arcLen = clockwiseEndArc - startArc
	if startArc > clockwiseEndArc then
		clockwiseEndArc = clockwiseEndArc + 360
		arcLen = arcLen + 360
	end
	if amount > arcLen then
		for ndex=1,math.floor(arcLen) do
			local radialPoint = startArc+ndex
			local pointDist = distance + random(-randomize,randomize)
			ta = Asteroid():setPosition(tertiusX + math.cos(radialPoint / 180 * math.pi) * pointDist, tertiusY + math.sin(radialPoint / 180 * math.pi) * pointDist)
			if radialPoint > 360 then
				radialPoint = radialPoint - 360
			end
			ta.angle = radialPoint
			ta.distance = pointDist
			ta.speed = speedIncrement
			ta.belt_id = belt_id
			table.insert(tertiusAsteroids,ta)		
		end
		for ndex=1,math.floor(amount-arcLen) do
			radialPoint = random(startArc,clockwiseEndArc)
			pointDist = distance + random(-randomize,randomize)
			ta = Asteroid():setPosition(tertiusX + math.cos(radialPoint / 180 * math.pi) * pointDist, tertiusY + math.sin(radialPoint / 180 * math.pi) * pointDist)			
			if radialPoint > 360 then
				radialPoint = radialPoint - 360
			end
			ta.angle = radialPoint
			ta.distance = pointDist
			ta.speed = speedIncrement
			ta.belt_id = belt_id
			table.insert(tertiusAsteroids,ta)		
		end
	else
		for ndex=1,amount do
			radialPoint = random(startArc,clockwiseEndArc)
			pointDist = distance + random(-randomize,randomize)
			ta = Asteroid():setPosition(tertiusX + math.cos(radialPoint / 180 * math.pi) * pointDist, tertiusY + math.sin(radialPoint / 180 * math.pi) * pointDist)
			if radialPoint > 360 then
				radialPoint = radialPoint - 360
			end
			ta.angle = radialPoint
			ta.distance = pointDist
			ta.speed = speedIncrement
			ta.belt_id = belt_id
			table.insert(tertiusAsteroids,ta)		
		end
	end
end
function createOrbitalAsteroids(amount,distance,startArc,clockwiseEndArc,belt_id,randomize)
	if randomize == nil then randomize = 0 end
	if amount == nil then amount = 1 end
	local arcLen = clockwiseEndArc - startArc
	if startArc > clockwiseEndArc then
		clockwiseEndArc = clockwiseEndArc + 360
		arcLen = arcLen + 360
	end
	if amount > arcLen then
		for ndex=1,math.floor(arcLen) do
			local radialPoint = startArc+ndex
			local pointDist = distance + random(-randomize,randomize)
			ta = Asteroid():setPosition(solX + math.cos(radialPoint / 180 * math.pi) * pointDist, solY + math.sin(radialPoint / 180 * math.pi) * pointDist)
			if radialPoint > 360 then
				radialPoint = radialPoint - 360
			end
			ta.angle = radialPoint
			ta.distance = pointDist
			ta.speed = beltOrbitalSpeed
			ta.belt_id = belt_id
			table.insert(beltAsteroidList,ta)		
		end
		for ndex=1,math.floor(amount-arcLen) do
			radialPoint = random(startArc,clockwiseEndArc)
			pointDist = distance + random(-randomize,randomize)
			ta = Asteroid():setPosition(solX + math.cos(radialPoint / 180 * math.pi) * pointDist, solY + math.sin(radialPoint / 180 * math.pi) * pointDist)			
			if radialPoint > 360 then
				radialPoint = radialPoint - 360
			end
			ta.angle = radialPoint
			ta.distance = pointDist
			ta.speed = beltOrbitalSpeed
			ta.belt_id = belt_id
			table.insert(beltAsteroidList,ta)		
		end
	else
		for ndex=1,amount do
			radialPoint = random(startArc,clockwiseEndArc)
			pointDist = distance + random(-randomize,randomize)
			ta = Asteroid():setPosition(solX + math.cos(radialPoint / 180 * math.pi) * pointDist, solY + math.sin(radialPoint / 180 * math.pi) * pointDist)
			if radialPoint > 360 then
				radialPoint = radialPoint - 360
			end
			ta.angle = radialPoint
			ta.distance = pointDist
			ta.speed = beltOrbitalSpeed
			ta.belt_id = belt_id
			table.insert(beltAsteroidList,ta)		
		end
	end
end
function movingObjects(delta)
	prx, pry = planetPrimus:getPosition()
	pmx, pmy = planetPrimusMoon:getPosition()
	if primusStation ~= nil and primusStation:isValid() then
		primusStation:setPosition(prx + (prx-pmx), pry + (pry-pmy))
	end
	prx, pry = planetSecondus:getPosition()
	for i=1,#secondusStations do
		local tms = secondusStations[i]
		if tms ~= nil and tms:isValid() then
			tms.angle = tms.angle - secondusStationOrbitIncrement
			if tms.angle <= 0 then
				tms.angle = tms.angle + 360
			end
			local tpmx, tpmy = vectorFromAngle(tms.angle,secondusStationOrbit)
			tms:setPosition(prx+tpmx,pry+tpmy)
		end
	end
	if moveDiagnostic then print("end of secondus stations moving objects") end
	--tertius (default orbit function only works for one moon - additional moons don't orbit)
	prx, pry = planetTertius:getPosition()
	--tertius moon 1
	planetTertiusMoon1.angle = planetTertiusMoon1.angle + tertiusOrbitalBodyIncrement
	if planetTertiusMoon1.angle >= 360 then
		planetTertiusMoon1.angle = planetTertiusMoon1.angle - 360
	end
	pmx, pmy = vectorFromAngle(planetTertiusMoon1.angle,tertiusMoonOrbit)
	pmx = prx+pmx
	pmy = pry+pmy
	planetTertiusMoon1:setPosition(pmx,pmy)
	--tertius moon 1 station
	if tertiusMoon1Station ~= nil and tertiusMoon1Station:isValid() then
		tertiusMoon1Station.angle = tertiusMoon1Station.angle - .05*difficulty
		if tertiusMoon1Station.angle < 0 then
			tertiusMoon1Station.angle = tertiusMoon1Station.angle + 360
		end
		psx, psy = vectorFromAngle(tertiusMoon1Station.angle,tertiusMoon1Station.distance)
		tertiusMoon1Station:setPosition(pmx+psx,pmy+psy)
	end
	--tertius moon 2
	planetTertiusMoon2.angle = planetTertiusMoon2.angle + tertiusOrbitalBodyIncrement
	if planetTertiusMoon2.angle >= 360 then
		planetTertiusMoon2.angle = planetTertiusMoon2.angle - 360
	end
	pmx, pmy = vectorFromAngle(planetTertiusMoon2.angle,tertiusMoonOrbit)
	planetTertiusMoon2:setPosition(prx+pmx,pry+pmy)
	--tertius moon 3
	planetTertiusMoon3.angle = planetTertiusMoon3.angle + tertiusOrbitalBodyIncrement
	if planetTertiusMoon3.angle >= 360 then
		planetTertiusMoon3.angle = planetTertiusMoon3.angle - 360
	end
	pmx, pmy = vectorFromAngle(planetTertiusMoon3.angle,tertiusMoonOrbit)
	planetTertiusMoon3:setPosition(prx+pmx,pry+pmy)
	if moveDiagnostic then print("end of tertius moon moving objects") end
	--tertius orbital body station 
	if tertiusStation ~= nil and tertiusStation:isValid() then
		tertiusStation.angle = tertiusStation.angle + tertiusOrbitalBodyIncrement
		if tertiusStation.angle >= 360 then
			tertiusStation.angle = tertiusStation.angle - 360
		end
		pmx, pmy = vectorFromAngle(tertiusStation.angle,tertiusMoonOrbit)
		tertiusStation:setPosition(prx+pmx,pry+pmy)
	end
	--tertius asteroid belt stations
	for i=1,#tertiusAsteroidStations do
		local tbs = tertiusAsteroidStations[i]
		if tbs ~= nil and tbs:isValid() then
			tbs.angle = tbs.angle + tbs.speed
			if tbs.angle >= 360 then
				tbs.angle = tbs.angle - 360
			end
			local tpmx, tpmy = vectorFromAngle(tbs.angle,tertiusAsteroidOrbit)
			tbs:setPosition(prx+tpmx,pry+tpmy)
		end
	end
	--tertius asteroids
	for i=1,#tertiusAsteroids do
		local ta = tertiusAsteroids[i]
		if ta ~= nil and ta:isValid() then
			ta.angle = ta.angle + ta.speed
			if ta.angle >= 360 then 
				ta.angle = 0
			end
			pmx, pmy = vectorFromAngle(ta.angle, ta.distance)
			ta:setPosition(prx+pmx,pry+pmy)
		end
	end
	if moveDiagnostic then print("end of tertius moving objects") end
	--belt 1 stations
	for i=1,#belt1Stations do
		local tbs = belt1Stations[i]
		if tbs ~= nil and tbs:isValid() then
			tbs.angle = tbs.angle + belt1OrbitalSpeed
			if tbs.angle >= 360 then
				tbs.angle = tbs.angle - 360
			end
			local tpmx, tpmy = vectorFromAngle(tbs.angle,beltOrbit1)
			tbs:setPosition(solX+tpmx,solY+tpmy)
		end
	end
	if belt1Artifact ~= nil and belt1Artifact:isValid() then
		belt1Artifact.angle = belt1Artifact.angle + belt1OrbitalSpeed
		if belt1Artifact.angle >= 360 then
			belt1Artifact.angle = belt1Artifact.angle - 360
		end
		tpmx, tpmy = vectorFromAngle(belt1Artifact.angle,beltOrbit1)
		belt1Artifact:setPosition(solX+tpmx,solY+tpmy)
		belt1Artifact:setRadarSignatureInfo(distance(belt1Artifact,planetPrimus),distance(belt1Artifact,planetSecondus),distance(belt1Artifact,planetTertius))
	end
	--belt 2 stations
	for i=1,#belt2Stations do
		local tbs = belt2Stations[i]
		if tbs ~= nil and tbs:isValid() then
			tbs.angle = tbs.angle + belt2OrbitalSpeed
			if tbs.angle >= 360 then
				tbs.angle = tbs.angle - 360
			end
			local tpmx, tpmy = vectorFromAngle(tbs.angle,beltOrbit2)
			tbs:setPosition(solX+tpmx,solY+tpmy)
		end
	end
	belt_2_nebula.angle = belt_2_nebula.angle + (belt2OrbitalSpeed*.7)
	if belt_2_nebula.angle >= 360 then
		belt_2_nebula.angle = belt_2_nebula.angle - 360
	end
	local tpmx, tpmy = vectorFromAngle(belt_2_nebula.angle,beltOrbit2)
	belt_2_nebula:setPosition(solX+tpmx,solY+tpmy)
	--belt asteroids
	for i=1,#beltAsteroidList do
		local ta = beltAsteroidList[i]
		if ta ~= nil and ta:isValid() then
			ta.angle = ta.angle + ta.speed
			if ta.angle >= 360 then 
				ta.angle = 0
			end
			pmx, pmy = vectorFromAngle(ta.angle, ta.distance)
			ta:setPosition(solX+pmx,solY+pmy)
		end
	end
	if moveDiagnostic then print("end of moving objects") end
end
-------------------------------------------
-- Object destruction callback functions --
-------------------------------------------
function humanStationDestroyed(self, instigator)
	table.insert(humanStationDestroyedNameList,self:getCallSign())
	table.insert(humanStationDestroyedValue,self.strength)
end
function neutralStationDestroyed(self, instigator)
	table.insert(neutralStationDestroyedNameList,self:getCallSign())
	table.insert(neutralStationDestroyedValue,self.strength)
end
function kraylorVesselDestroyed(self, instigator)
	local tempShipType = self:getTypeName()
	table.insert(kraylorVesselDestroyedNameList,self:getCallSign())
	table.insert(kraylorVesselDestroyedType,tempShipType)
	for k=1,#stnl do
		if tempShipType == stnl[k] then
			table.insert(kraylorVesselDestroyedValue,stsl[k])
		end
	end
end
function exuariVesselDestroyed(self, instigator)
	local tempShipType = self:getTypeName()
	table.insert(exuariVesselDestroyedNameList,self:getCallSign())
	table.insert(exuariVesselDestroyedType,tempShipType)
	for k=1,#stnl do
		if tempShipType == stnl[k] then
			table.insert(exuariVesselDestroyedValue,stsl[k])
		end
	end
end
function humanVesselDestroyed(self, instigator)
	local tempShipType = self:getTypeName()
	table.insert(humanVesselDestroyedNameList,self:getCallSign())
	table.insert(humanVesselDestroyedType,tempShipType)
	for k=1,#stnl do
		if tempShipType == stnl[k] then
			table.insert(humanVesselDestroyedValue,stsl[k])
		end
	end
end
function arlenianVesselDestroyed(self, instigator)
	local tempShipType = self:getTypeName()
	table.insert(arlenianVesselDestroyedNameList,self:getCallSign())
	table.insert(arlenianVesselDestroyedType,tempShipType)
	for k=1,#stnl do
		if tempShipType == stnl[k] then
			table.insert(arlenianVesselDestroyedValue,stsl[k])
		end
	end
end
-------------------------------------------------------
-- Optional mission functions to upgrade player ship --
-------------------------------------------------------
function setOptionalMissions()
	--	faster beams
	local required_good = chooseUpgradeGood("beam",playerSpawnBandStations[1])
	playerSpawnBandStations[1].comms_data.character = "Horace Grayson"
	playerSpawnBandStations[1].comms_data.characterDescription = "He dabbles in ship system innovations. He's been working on improving beam weapons by reducing the amount of time between firing. I hear he's already installed some improvements on ships that have docked here previously"
	playerSpawnBandStations[1].comms_data.characterFunction = "shrinkBeamCycle"
	playerSpawnBandStations[1].comms_data.characterGood = required_good
	local clue_station = clueStations[math.random(1,#clueStations)]
	repeat
		clue_station = clueStations[math.random(1,#clueStations)]
	until(clue_station.comms_data.gossip == nil)
	clue_station.comms_data.gossip = string.format("I heard there's a guy named %s that can fix ship beam systems up so that they shoot faster. He lives out on %s in %s. He won't charge you much, but it won't be free.",playerSpawnBandStations[1].comms_data.character,playerSpawnBandStations[1]:getCallSign(),playerSpawnBandStations[1]:getSectorName())
	--	spin faster
	required_good = chooseUpgradeGood("circuit",playerSpawnBandStations[2])
	playerSpawnBandStations[2].comms_data.character = "Emily Patel"
	playerSpawnBandStations[2].comms_data.characterDescription = "She tinkers with ship systems like engines and thrusters. She's consulted with the military on tuning spin time by increasing thruster power. She's got prototypes that are awaiting formal military approval before installation"
	playerSpawnBandStations[2].comms_data.characterFunction = "increaseSpin"
	playerSpawnBandStations[2].comms_data.characterGood = required_good
	clue_station = clueStations[math.random(1,#clueStations)]
	repeat
		clue_station = clueStations[math.random(1,#clueStations)]
	until(clue_station.comms_data.gossip == nil)
	clue_station.comms_data.gossip = string.format("My friend, %s recently quit her job as a ship maintenance technician to set up this side gig. She's been improving ship systems and she's pretty good at it. She set up shop on %s in %s. I hear she's even lining up a contract with the navy for her improvements.",playerSpawnBandStations[2].comms_data.character,playerSpawnBandStations[2]:getCallSign(),playerSpawnBandStations[2]:getSectorName())
	--	extra missile tube
	required_good = chooseUpgradeGood("nanites",playerSpawnBandStations[3])
	playerSpawnBandStations[3].comms_data.character = "Fred McLassiter"
	playerSpawnBandStations[3].comms_data.characterDescription = "He specializes in miniaturization of weapons systems. He's come up with a way to add a missile tube and some missiles to any ship regardless of size or configuration"
	playerSpawnBandStations[3].comms_data.characterFunction = "addAuxTube"
	playerSpawnBandStations[3].comms_data.characterGood = required_good
	clue_station = clueStations[math.random(1,#clueStations)]
	repeat
		clue_station = clueStations[math.random(1,#clueStations)]
	until(clue_station.comms_data.gossip == nil)
	clue_station.comms_data.gossip = string.format("There's this guy, %s out on %s in %s that can add a missile tube to your ship. He even added one to my cousin's souped up freighter. You should see the new paint job: amusingly phallic",playerSpawnBandStations[3].comms_data.character,playerSpawnBandStations[3]:getCallSign(),playerSpawnBandStations[3]:getSectorName())
	--	cooler beam weapon firing
	required_good = chooseUpgradeGood("software",playerSpawnBandStations[4])
	playerSpawnBandStations[4].comms_data.character = "Dorothy Ly"
	playerSpawnBandStations[4].comms_data.characterDescription = "She developed this technique for cooling beam systems so that they can be fired more often without burning out"
	playerSpawnBandStations[4].comms_data.characterFunction = "coolBeam"
	playerSpawnBandStations[4].comms_data.characterGood = required_good
	clue_station = clueStations[math.random(1,#clueStations)]
	repeat
		clue_station = clueStations[math.random(1,#clueStations)]
	until(clue_station.comms_data.gossip == nil)
	clue_station.comms_data.gossip = string.format("There's this girl on %s in %s. She is hot. Her name is %s. When I say she is hot, I mean she has a way of keeping your beam weapons from excessive heat.",playerSpawnBandStations[4]:getCallSign(),playerSpawnBandStations[4]:getSectorName(),playerSpawnBandStations[4].comms_data.character)
	--	longer beam range
	required_good = chooseUpgradeGood("optic",playerSpawnBandStations[5])
	playerSpawnBandStations[5].comms_data.character = "Gerald Cook"
	playerSpawnBandStations[5].comms_data.characterDescription = "He knows how to modify beam systems to extend their range"
	playerSpawnBandStations[5].comms_data.characterFunction = "longerBeam"
	playerSpawnBandStations[5].comms_data.characterGood = required_good
	clue_station = clueStations[math.random(1,#clueStations)]
	repeat
		clue_station = clueStations[math.random(1,#clueStations)]
	until(clue_station.comms_data.gossip == nil)
	clue_station.comms_data.gossip = string.format("Do you know about %s? He can extend the range of your beam weapons. He's on %s in %s",playerSpawnBandStations[5].comms_data.character,playerSpawnBandStations[5]:getCallSign(),playerSpawnBandStations[5]:getSectorName())
	--	increased beam damage
	required_good = chooseUpgradeGood("filament",playerSpawnBandStations[6])
	playerSpawnBandStations[6].comms_data.character = "Sally Jenkins"
	playerSpawnBandStations[6].comms_data.characterDescription = "She can make your beams hit harder"
	playerSpawnBandStations[6].comms_data.characterFunction = "damageBeam"
	playerSpawnBandStations[6].comms_data.characterGood = required_good
	clue_station = clueStations[math.random(1,#clueStations)]
	repeat
		clue_station = clueStations[math.random(1,#clueStations)]
	until(clue_station.comms_data.gossip == nil)
	clue_station.comms_data.gossip = string.format("You should visit %s in %s. There's a specialist in beam technology that can increase the damage done by your beams. Her name is %s",playerSpawnBandStations[6]:getCallSign(),playerSpawnBandStations[6]:getSectorName(),playerSpawnBandStations[6].comms_data.character)
	--	increased maximum missile storage capacity
	required_good = chooseUpgradeGood("transporter",playerSpawnBandStations[7])
	playerSpawnBandStations[7].comms_data.character = "Anh Dung Ly"
	playerSpawnBandStations[7].comms_data.characterDescription = "He can fit more missiles aboard your ship"
	playerSpawnBandStations[7].comms_data.characterFunction = "moreMissiles"
	playerSpawnBandStations[7].comms_data.characterGood = required_good
	clue_station = clueStations[math.random(1,#clueStations)]
	repeat
		clue_station = clueStations[math.random(1,#clueStations)]
	until(clue_station.comms_data.gossip == nil)
	clue_station.comms_data.gossip = string.format("Want to store more missiles on your ship? Talk to %s on station %s in %s. He can retrain your missile loaders and missile storage automation such that you will be able to store more missiles",playerSpawnBandStations[7].comms_data.character,playerSpawnBandStations[7]:getCallSign(),playerSpawnBandStations[7]:getSectorName())
	--	faster impulse
	required_good = chooseUpgradeGood("impulse",playerSpawnBandStations[8])
	playerSpawnBandStations[8].comms_data.character = "Doralla Ognats"
	playerSpawnBandStations[8].comms_data.characterDescription = "She can soup up your impulse engines"
	playerSpawnBandStations[8].comms_data.characterFunction = "fasterImpulse"
	playerSpawnBandStations[8].comms_data.characterGood = required_good
	clue_station = clueStations[math.random(1,#clueStations)]
	repeat
		clue_station = clueStations[math.random(1,#clueStations)]
	until(clue_station.comms_data.gossip == nil)
	clue_station.comms_data.gossip = string.format("%s, an engineer/mechanic who knows propulsion systems backwards and forwards has a bay at the shipyard on %s in %s. She can give your impulse engines a significant boost to their top speed",playerSpawnBandStations[8].comms_data.character,playerSpawnBandStations[8]:getCallSign(),playerSpawnBandStations[8]:getSectorName())
	--	stronger hull
	required_good = chooseUpgradeGood("repulsor",tertiusStation)
	tertiusStation.comms_data.character = "Maduka Lawal"
	tertiusStation.comms_data.characterDescription = "He can strengthen your hull"
	tertiusStation.comms_data.characterFunction = "strongerHull"
	tertiusStation.comms_data.characterGood = required_good
	clue_station = clueStations[math.random(1,#clueStations)]
	repeat
		clue_station = clueStations[math.random(1,#clueStations)]
	until(clue_station.comms_data.gossip == nil and clue_station ~= tertiusStation)
	clue_station.comms_data.gossip = string.format("I know of a materials specialist on %s in %s named %s. He can strengthen the hull on your ship",tertiusStation:getCallSign(),tertiusStation:getSectorName(),tertiusStation.comms_data.character)
	--	efficient batteries
	required_good = chooseUpgradeGood("battery",tertiusMoon1Station)
	tertiusMoon1Station.comms_data.character = "Susil Tarigan"
	tertiusMoon1Station.comms_data.characterDescription = "She knows how to increase your maximum energy capacity by improving battery efficiency"
	tertiusMoon1Station.comms_data.characterFunction = "efficientBatteries"
	tertiusMoon1Station.comms_data.characterGood = required_good
	clue_station = clueStations[math.random(1,#clueStations)]
	repeat
		clue_station = clueStations[math.random(1,#clueStations)]
	until(clue_station.comms_data.gossip == nil and clue_station ~= tertiusMoon1Station)
	clue_station.comms_data.gossip = string.format("Have you heard about %s? She's on %s in %s and she can give your ship greater energy capacity by improving your battery efficiency",tertiusMoon1Station.comms_data.character,tertiusMoon1Station:getCallSign(),tertiusMoon1Station:getSectorName())
	--	stronger shields
	required_good = chooseUpgradeGood("shield",tertiusAsteroidStations[1])
	tertiusAsteroidStations[1].comms_data.character = "Paulo Silva"
	tertiusAsteroidStations[1].comms_data.characterDescription = "He can strengthen your shields"
	tertiusAsteroidStations[1].comms_data.characterFunction = "strongerShields"
	tertiusAsteroidStations[1].comms_data.characterGood = required_good
	clue_station = clueStations[math.random(1,#clueStations)]
	repeat
		clue_station = clueStations[math.random(1,#clueStations)]
	until(clue_station.comms_data.gossip == nil and clue_station ~= tertiusAsteroidStations[1])
	clue_station.comms_data.gossip = string.format("If you stop at %s in %s, you should talk to %s. He can strengthen your shields. Trust me, it's always good to have stronger shields",tertiusAsteroidStations[1]:getCallSign(),tertiusAsteroidStations[1]:getSectorName(),tertiusAsteroidStations[1].comms_data.character)
end
function chooseUpgradeGood(ideal_good,upgrade_station)
	local required_good = ideal_good
	local match_preferred_good = false
	for good, goodData in pairs(upgrade_station.comms_data.goods) do
		if good == required_good then
			match_preferred_good = true
			break
		end
	end
	if match_preferred_good then
		required_good = randomComponent(ideal_good)
		local chosen_good = true
		repeat
			chosen_good = true
			for good, goodData in pairs(upgrade_station.comms_data.goods) do
				if good ~= "food" and good ~= "medicine" and good ~= "luxury" then
					if good == beamGood then
						required_good = randomComponent(ideal_good)
						chosen_good = false
						break
					end
				end
			end
		until(chosen_good)
	end
	return required_good
end
function payForUpgrade()
	if	(difficulty == 1 and mission_region < 2) or 
		(difficulty == 1 and mission_complete_count < 5) or
		(difficulty < 1 and mission_complete_count < 3) or
		(difficulty > 1 and mission_region < 3) or
		(difficulty > 1 and mission_complete_count < 7) then
		return true
	else
		return false
	end
end
function shrinkBeamCycle()
	if comms_source.shrinkBeamCycleUpgrade == nil then
		addCommsReply("Reduce beam cycle time", function()
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
						local bi = 0
						repeat
							local tempArc = comms_source:getBeamWeaponArc(bi)
							local tempDir = comms_source:getBeamWeaponDirection(bi)
							local tempRng = comms_source:getBeamWeaponRange(bi)
							local tempCyc = comms_source:getBeamWeaponCycleTime(bi)
							local tempDmg = comms_source:getBeamWeaponDamage(bi)
							comms_source:setBeamWeapon(bi,tempArc,tempDir,tempRng,tempCyc * .75,tempDmg)
							bi = bi + 1
						until(comms_source:getBeamWeaponRange(bi) < 1)
						setCommsMessage("After accepting your gift, he reduced your Beam cycle time by 25%%")
					else
						setCommsMessage(string.format("%s requires %s for the upgrade",ctd.character,ctd.characterGood))
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
					setCommsMessage(string.format("%s reduced your Beam cycle time by 25%% at no cost in trade with the message, 'Go get those Exuari.'",ctd.character))
				end
			else
				setCommsMessage("Your ship type does not support a beam weapon upgrade.")				
			end
		end)
	end
end
function increaseSpin()
	if comms_source.increaseSpinUpgrade == nil then
		addCommsReply("Increase spin speed", function()
			local ctd = comms_target.comms_data
			if payForUpgrade() then
				local partQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
					partQuantity = comms_source.goods[ctd.characterGood]
				end
				if partQuantity > 0 then
					comms_source.increaseSpinUpgrade = "done"
					comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
					comms_source.cargo = comms_source.cargo + 1
					comms_source:setRotationMaxSpeed(comms_source:getRotationMaxSpeed()*1.5)
					setCommsMessage(string.format("Ship spin speed increased by 50%% after you gave %s to %s",ctd.characterGood,ctd.character))
				else
					setCommsMessage(string.format("%s requires %s for the spin upgrade",ctd.character,ctd.characterGood))
				end
			else
				comms_source.increaseSpinUpgrade = "done"
				comms_source:setRotationMaxSpeed(player:getRotationMaxSpeed()*1.5)
				setCommsMessage(string.format("%s: I increased the speed your ship spins by 50%%. Normally, I'd require %s, but seeing as you're going out to take on the Exuari, we worked it out",ctd.character,ctd.characterGood))
			end
		end)
	end
end
function addAuxTube()
	if comms_source.auxTubeUpgrade == nil then
		addCommsReply("Add missle tube", function()
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
					comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
					comms_source.goods["luxury"] = comms_source.goods["luxury"] - 1
					comms_source.cargo = comms_source.cargo + 2
					local originalTubes = comms_source:getWeaponTubeCount()
					local newTubes = originalTubes + 1
					comms_source:setWeaponTubeCount(newTubes)
					comms_source:setWeaponTubeExclusiveFor(originalTubes, "Homing")
					comms_source:setWeaponStorageMax("Homing", comms_source:getWeaponStorageMax("Homing") + 2)
					comms_source:setWeaponStorage("Homing", comms_source:getWeaponStorage("Homing") + 2)
					setCommsMessage(string.format("%s thanks you for the %s and the luxury and installs a homing missile tube for you",ctd.character,ctd.characterGood))
				else
					setCommsMessage(string.format("%s requires %s and luxury for the missile tube",ctd.character,ctd.characterGood))
				end
			else
				comms_source.auxTubeUpgrade = "done"
				originalTubes = comms_source:getWeaponTubeCount()
				newTubes = originalTubes + 1
				comms_source:setWeaponTubeCount(newTubes)
				comms_source:setWeaponTubeExclusiveFor(originalTubes, "Homing")
				comms_source:setWeaponStorageMax("Homing", comms_source:getWeaponStorageMax("Homing") + 2)
				comms_source:setWeaponStorage("Homing", comms_source:getWeaponStorage("Homing") + 2)
				setCommsMessage(string.format("%s installs a homing missile tube for you. The %s required was requisitioned from emergency contingency supplies",ctd.character,ctd.characterGood))
			end
		end)
	end
end
function coolBeam()
	if comms_source.coolBeamUpgrade == nil then
		addCommsReply("Reduce beam heat", function()
			local ctd = comms_target.comms_data
			if comms_source:getBeamWeaponRange(0) > 0 then
				if payForUpgrade() then
					local partQuantity = 0
					if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
						partQuantity = comms_source.goods[ctd.characterGood]
					end
					if partQuantity > 0 then
						comms_source.coolBeamUpgrade = "done"
						comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
						comms_source.cargo = comms_source.cargo + 1
						local bi = 0
						repeat
							comms_source:setBeamWeaponHeatPerFire(bi,comms_source:getBeamWeaponHeatPerFire(bi) * 0.5)
							bi = bi + 1
						until(comms_source:getBeamWeaponRange(bi) < 1)
						setCommsMessage("Beam heat generation reduced by 50%%")
					else
						setCommsMessage(string.format("%s says she needs %s before she can cool your beams",ctd.character,ctd.characterGood))
					end
				else
					comms_source.coolBeamUpgrade = "done"
					bi = 0
					repeat
						comms_source:setBeamWeaponHeatPerFire(bi,comms_source:getBeamWeaponHeatPerFire(bi) * 0.5)
						bi = bi + 1
					until(comms_source:getBeamWeaponRange(bi) < 1)
					setCommsMessage(string.format("%s: Beam heat generation reduced by 50%%, no %s necessary. Go shoot some Exuari for me",ctd.character,ctd.characterGood))
				end
			else
				setCommsMessage("Your ship type does not support a beam weapon upgrade.")				
			end
		end)
	end
end
function longerBeam()
	if comms_source.longerBeamUpgrade == nil then
		addCommsReply("Extend beam range", function()
			if optionalMissionDiagnostic then print("extending beam range") end
			local ctd = comms_target.comms_data
			if comms_source:getBeamWeaponRange(0) > 0 then
				if payForUpgrade() then
					local partQuantity = 0
					if comms_source.goods ~= nil then
						if comms_source.goods[ctd.characterGood] ~= nil then
							if comms_source.goods[ctd.characterGood] > 0 then
								partQuantity = comms_source.goods[ctd.characterGood]
							end
						end
					end
					if partQuantity > 0 then
						comms_source.longerBeamUpgrade = "done"
						comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
						comms_source.cargo = comms_source.cargo + 1
						local bi = 0
						repeat
							local tempArc = comms_source:getBeamWeaponArc(bi)
							local tempDir = comms_source:getBeamWeaponDirection(bi)
							local tempRng = comms_source:getBeamWeaponRange(bi)
							local tempCyc = comms_source:getBeamWeaponCycleTime(bi)
							local tempDmg = comms_source:getBeamWeaponDamage(bi)
							comms_source:setBeamWeapon(bi,tempArc,tempDir,tempRng * 1.25,tempCyc,tempDmg)
							bi = bi + 1
						until(comms_source:getBeamWeaponRange(bi) < 1)
						setCommsMessage(string.format("%s extended your beam range by 25%% and says thanks for the %s",ctd.character,ctd.characterGood))
					else
						setCommsMessage(string.format("%s requires %s for the upgrade",ctd.character,ctd.characterGood))
					end
				else
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
					setCommsMessage(string.format("%s increased your beam range by 25%% without the usual %s from your ship",ctd.character,ctd.characterGood))
				end
			else
				setCommsMessage("Your ship type does not support a beam weapon upgrade.")				
			end
		end)
	end
end
function damageBeam()
	if comms_source.damageBeamUpgrade == nil then
		addCommsReply("Increase beam damage", function()
			local ctd = comms_target.comms_data
			if comms_source:getBeamWeaponRange(0) > 0 then
				if payForUpgrade() then
					local partQuantity = 0
					if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
						partQuantity = comms_source.goods[ctd.characterGood]
					end
					if partQuantity > 0 then
						comms_source.damageBeamUpgrade = "done"
						comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
						comms_source.cargo = comms_source.cargo + 1
						local bi = 0
						repeat
							local tempArc = comms_source:getBeamWeaponArc(bi)
							local tempDir = comms_source:getBeamWeaponDirection(bi)
							local tempRng = comms_source:getBeamWeaponRange(bi)
							local tempCyc = comms_source:getBeamWeaponCycleTime(bi)
							local tempDmg = comms_source:getBeamWeaponDamage(bi)
							comms_source:setBeamWeapon(bi,tempArc,tempDir,tempRng,tempCyc,tempDmg*1.2)
							bi = bi + 1
						until(comms_source:getBeamWeaponRange(bi) < 1)
						setCommsMessage(string.format("%s increased your beam damage by 20%% and stores away the %s",ctd.character,ctd.characterGood))
					else
						setCommsMessage(string.format("%s requires %s for the upgrade",ctd.character,ctd.characterGood))
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
					setCommsMessage(string.format("%s increased your beam damage by 20%%, waiving the usual %s requirement",ctd.character,ctd.characterGood))
				end
			else
				setCommsMessage("Your ship type does not support a beam weapon upgrade.")				
			end
		end)
	end
end
function moreMissiles()
	if comms_source.moreMissilesUpgrade == nil then
		addCommsReply("Increase missile storage capacity", function()
			local ctd = comms_target.comms_data
			if comms_source:getWeaponTubeCount() > 0 then
				if payForUpgrade() then
					local partQuantity = 0
					if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
						partQuantity = comms_source.goods[ctd.characterGood]
					end
					if partQuantity > 0 then
						comms_source.moreMissilesUpgrade = "done"
						comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
						comms_source.cargo = comms_source.cargo + 1
						local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
						for _, missile_type in ipairs(missile_types) do
							comms_source:setWeaponStorageMax(missile_type, math.ceil(comms_source:getWeaponStorageMax(missile_type)*1.25))
						end
						setCommsMessage(string.format("%s: You can now store at least 25%% more missiles. I appreciate the %s",ctd.character,ctd.characterGood))
					else
						setCommsMessage(string.format("%s needs %s for the upgrade",ctd.character,ctd.characterGood))
					end
				else
					comms_source.moreMissilesUpgrade = "done"
					missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
					for _, missile_type in ipairs(missile_types) do
						comms_source:setWeaponStorageMax(missile_type, math.ceil(comms_source:getWeaponStorageMax(missile_type)*1.25))
					end
					setCommsMessage(string.format("%s: You can now store at least 25%% more missiles. I found some spare %s on the station. Go launch those missiles at those perfidious Exuari",ctd.character,ctd.characterGood))
				end
			else
				setCommsMessage("Your ship type does not support a missile storage capacity upgrade.")				
			end
		end)
	end
end
function fasterImpulse()
	if comms_source.fasterImpulseUpgrade == nil then
		addCommsReply("Speed up impulse engines", function()
			local ctd = comms_target.comms_data
			if payForUpgrade() then
				local partQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
					partQuantity = comms_source.goods[ctd.characterGood]
				end
				if partQuantity > 0 then
					comms_source.fasterImpulseUpgrade = "done"
					comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
					comms_source.cargo = comms_source.cargo + 1
					comms_source:setImpulseMaxSpeed(comms_source:getImpulseMaxSpeed()*1.25)
					setCommsMessage(string.format("%s: Your impulse engines now push you up to 25%% faster. Thanks for the %s",ctd.character,ctd.characterGood))
				else
					setCommsMessage(string.format("You need to bring %s to %s for the upgrade",ctd.characterGood,ctd.character))
				end
			else
				comms_source.fasterImpulseUpgrade = "done"
				comms_source:setImpulseMaxSpeed(comms_source:getImpulseMaxSpeed()*1.25)
				setCommsMessage(string.format("%s: Your impulse engines now push you up to 25%% faster. I didn't need %s after all. Go run circles around those blinking Exuari",ctd.character,ctd.characterGood))
			end
		end)
	end
end
function strongerHull()
	if comms_source.strongerHullUpgrade == nil then
		addCommsReply("Strengthen hull", function()
			local ctd = comms_target.comms_data
			if payForUpgrade() then
				local partQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
					partQuantity = comms_source.goods[ctd.characterGood]
				end
				if partQuantity > 0 then
					comms_source.strongerHullUpgrade = "done"
					comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
					comms_source.cargo = comms_source.cargo + 1
					comms_source:setHullMax(comms_source:getHullMax()*1.5)
					comms_source:setHull(comms_source:getHullMax())
					setCommsMessage(string.format("%s: Thank you for the %s. Your hull is 50%% stronger",ctd.character,ctd.characterGood))
				else
					setCommsMessage(string.format("%s: I need %s before I can increase your hull strength",ctd.character,ctd.characterGood))
				end
			else
				comms_source.strongerHullUpgrade = "done"
				comms_source:setHullMax(comms_source:getHullMax()*1.5)
				comms_source:setHull(comms_source:getHullMax())
				setCommsMessage(string.format("%s: I made your hull 50%% stronger. I scrounged some %s from around here since you are on the Exuari offense team",ctd.character,ctd.characterGood))
			end
		end)
	end
end
function efficientBatteries()
	if comms_source.efficientBatteriesUpgrade == nil then
		addCommsReply("Increase battery efficiency", function()
			local ctd = comms_target.comms_data
			if payForUpgrade() then
				local partQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
					partQuantity = comms_source.goods[ctd.characterGood]
				end
				if partQuantity > 0 then
					comms_source.efficientBatteriesUpgrade = "done"
					comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
					comms_source.cargo = comms_source.cargo + 1
					comms_source:setMaxEnergy(comms_source:getMaxEnergy()*1.25)
					comms_source:setEnergy(comms_source:getMaxEnergy())
					setCommsMessage(string.format("%s: I appreciate the %s. You have a 25%% greater energy capacity due to increased battery efficiency",ctd.character,ctd.characterGood))
				else
					setCommsMessage(string.format("%s: You need to bring me some %s before I can increase your battery efficiency",ctd.character,ctd.characterGood))
				end
			else
				comms_source.efficientBatteriesUpgrade = "done"
				comms_source:setMaxEnergy(comms_source:getMaxEnergy()*1.25)
				comms_source:setEnergy(comms_source:getMaxEnergy())
				setCommsMessage(string.format("%s increased your battery efficiency by 25%% without the need for %s due to the pressing military demands on your ship",ctd.character,ctd.characterGood))
			end
		end)
	end
end
function strongerShields()
	if comms_source.strongerShieldsUpgrade == nil then
		addCommsReply("Strengthen shields", function()
			local ctd = comms_target.comms_data
			if payForUpgrade() then
				local partQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
					partQuantity = comms_source.goods[ctd.characterGood]
				end
				if partQuantity > 0 then
					comms_source.strongerShieldsUpgrade = "done"
					comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
					comms_source.cargo = comms_source.cargo + 1
					if comms_source:getShieldCount() == 1 then
						comms_source:setShieldsMax(comms_source:getShieldMax(0)*1.2)
					else
						comms_source:setShieldsMax(comms_source:getShieldMax(0)*1.2,comms_source:getShieldMax(1)*1.2)
					end
					setCommsMessage(string.format("%s: I've raised your shield maximum by 20%%, %s. Thanks for bringing the %s",ctd.character,comms_source:getCallSign(),ctd.characterGood))
				else
					setCommsMessage(string.format("%s: You need to provide %s before I can raise your shield strength",ctd.character,ctd.characterGood))
				end
			else
				comms_source.strongerShieldsUpgrade = "done"
				if comms_source:getShieldCount() == 1 then
					comms_source:setShieldsMax(comms_source:getShieldMax(0)*1.2)
				else
					comms_source:setShieldsMax(comms_source:getShieldMax(0)*1.2,comms_source:getShieldMax(1)*1.2)
				end
				setCommsMessage(string.format("%s: Congratulations, %s, your shields are 20%% stronger. Don't worry about the %s. Go kick those Exuari outta here",ctd.character,comms_source:getCallSign(),ctd.characterGood))
			end
		end)
	end
end
function setGoodsList()
	--list of goods available to buy, sell or trade (sell still under development)
	--[[
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
	--]]
	goodsList = {	{"food",0}, {"medicine",0},	{"nickel",0}, {"platinum",0}, {"gold",0}, {"dilithium",0}, {"tritanium",0}, {"luxury",0}, {"cobalt",0}, {"impulse",0}, {"warp",0}, {"shield",0}, {"tractor",0}, {"repulsor",0}, {"beam",0}, {"optic",0}, {"robotic",0}, {"filament",0}, {"transporter",0}, {"sensor",0}, {"communication",0}, {"autodoc",0}, {"lifter",0}, {"android",0}, {"nanites",0}, {"software",0}, {"circuit",0}, {"battery",0}	}
	goods = {}					--overall tracking of goods
	tradeFood = {}				--stations that will trade food for other goods
	tradeLuxury = {}			--stations that will trade luxury for other goods
	tradeMedicine = {}			--stations that will trade medicine for other goods
end
--------------------------------
--	Station related functions --
--------------------------------
function setListOfStations()
	--array of functions to facilitate randomized station placement (friendly and neutral)
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
	--array of functions to facilitate randomized station placement (enemy)
	placeEnemyStation = {placeAramanth,		-- 1
					placeEmpok,				-- 2
					placeGandala,			-- 3
					placeHassenstadt,		-- 4
					placeKaldor,			-- 5
					placeMagMesra,			-- 6
					placeMosEisley,			-- 7
					placeQuestaVerde,		-- 8
					placeRlyeh,				-- 9
					placeScarletCit,		--10
					placeStahlstadt,		--11
					placeTic}				--12
end
function szt()
--Randomly choose station size template
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
function setStationComms(cStation)
	if stationCommunication ~= nil then
		if stationCommunication == "commsStation" then
			cStation:setCommsScript(""):setCommsFunction(commsStation)
		else
			cStation:setCommsScript(stationCommunication)
		end
	end
end
function setStationStrength(sStation)
	if sizeTemplate == "Huge Station" then
		sStation.strength = 10
	elseif sizeTemplate == "Large Station" then
		sStation.strength = 5
	elseif sizeTemplate == "Medium Station" then
		sStation.strength = 3
	else
		sStation.strength = 1
	end
	return sStation.strength
end
--	Human and neutral stations to be placed (all need some kind of goods) --
function placeAlcaleica()
	--Alcaleica
	stationAlcaleica = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationAlcaleica)
	stationAlcaleica:setPosition(psx,psy):setCallSign("Alcaleica"):setDescription("Optical Components")
    stationAlcaleica.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	optic = {quantity = 5,	cost = 66} },
        trade = {	food = false, medicine = false, luxury = false },
		buy =	{	[randomMineral()] = math.random(40,200)	},
        public_relations = true,
        general_information = "We make and supply optic components for various station and ship systems",
    	history = "This station continues the businesses from Earth based on the merging of several companies including Leica from Switzerland, the lens manufacturer and the Japanese advanced low carbon (ALCA) electronic and optic research and development company"
	}
	if stationFaction == "Human Navy" then
		stationAlcaleica.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationAlcaleica.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationAlcaleica.comms_data.trade.medicine = true
		end
	else
		stationAlcaleica.comms_data.trade.medicine = true
		stationAlcaleica.comms_data.trade.food = true
	end
	return stationAlcaleica
end
function placeAnderson()
	--Anderson 
	stationAnderson = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationAnderson)
	stationAnderson:setPosition(psx,psy):setCallSign("Anderson"):setDescription("Battery and software engineering")
    stationAnderson.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	battery =	{quantity = 5,	cost = 66},
        			software =	{quantity = 5,	cost = 115} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We provide high quality high capacity batteries and specialized software for all shipboard systems",
    	history = "The station is named after a fictional software engineer in a late 20th century movie depicting humanity unknowingly conquered by aliens and kept docile by software generated illusion"
	}
	if stationFaction == "Human Navy" then
		stationAnderson.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationAnderson.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	end
	return stationAnderson
end
function placeArcher()
	--Archer 
	stationArcher = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationArcher)
	stationArcher:setPosition(psx,psy):setCallSign("Archer"):setDescription("Shield and Armor Research")
    stationArcher.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 1.0 },
        goods = {	shield =	{quantity = 5,	cost = 90} },
        trade = {	food = false, medicine = false, luxury = true },
		buy =	{	[randomMineral()] = math.random(40,200)	},
        public_relations = true,
        general_information = "The finest shield and armor manufacturer in the quadrant",
    	history = "We named this station for the pioneering spirit of the 22nd century Starfleet explorer, Captain Jonathan Archer"
	}
	if stationFaction == "Human Navy" then
		stationArcher.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationArcher.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationArcher.comms_data.trade.medicine = true
		end
	else
		stationArcher.comms_data.trade.medicine = true
	end
	return stationArcher
end
function placeArchimedes()
	--Archimedes
	stationArchimedes = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationArchimedes)
	stationArchimedes:setPosition(psx,psy):setCallSign("Archimedes"):setDescription("Energy and particle beam components")
    stationArchimedes.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	beam =	{quantity = 5,	cost = 80} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We fabricate general and specialized components for ship beam systems",
    	history = "This station was named after Archimedes who, according to legend, used a series of adjustable focal length mirrors to focus sunlight on a Roman naval fleet invading Syracuse, setting fire to it"
	}
	if stationFaction == "Human Navy" then
		stationArchimedes.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationArchimedes.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationArchimedes.comms_data.trade.medicine = true
		end
	else
		stationArchimedes.comms_data.trade.food = true
	end
	return stationArchimedes
end
function placeArmstrong()
	--Armstrong
	stationArmstrong = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationArmstrong)
	stationArmstrong:setPosition(psx,psy):setCallSign("Armstrong"):setDescription("Warp and Impulse engine manufacturing")
    stationArmstrong.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "friend",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 1.0 },
        goods = {	warp =		{quantity = 5,	cost = 77},
        			repulsor =	{quantity = 5,	cost = 62} },
        trade = {	food = false, medicine = false, luxury = false },
		buy =	{	[randomMineral()] = math.random(40,200)	},
        public_relations = true,
        general_information = "We manufacture warp, impulse and jump engines for the human navy fleet as well as other independent clients on a contract basis",
    	history = "The station is named after the late 19th century astronaut as well as the fictionlized stations that followed. The station initially constructed entire space worthy vessels. In time, it transitioned into specializeing in propulsion systems."
	}
	if stationFaction == "Human Navy" then
		stationArmstrong.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationArmstrong.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	end
	return stationArmstrong
end
function placeAsimov()
	--Asimov
	stationAsimov = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationAsimov)
	stationAsimov:setCallSign("Asimov"):setDescription("Training and Coordination"):setPosition(psx,psy)
    stationAsimov.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	tractor =	{quantity = 5,	cost = 48} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We train naval cadets in routine and specialized functions aboard space vessels and coordinate naval activity throughout the sector",
    	history = "The original station builders were fans of the late 20th century scientist and author Isaac Asimov. The station was initially named Foundation, but was later changed simply to Asimov. It started off as a stellar observatory, then became a supply stop and as it has grown has become an educational and coordination hub for the region"
	}
	if stationFaction == "Human Navy" then
		stationAsimov.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationAsimov.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	end
	return stationAsimov
end
function placeBarclay()
	--Barclay
	stationBarclay = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationBarclay)
	stationBarclay:setPosition(psx,psy):setCallSign("Barclay"):setDescription("Communication components")
    stationBarclay.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	communication =	{quantity = 5,	cost = 58} },
        trade = {	food = false, medicine = false, luxury = false },
		buy =	{	[randomMineral()] = math.random(40,200)	},
        public_relations = true,
        general_information = "We provide a range of communication equipment and software for use aboard ships",
    	history = "The station is named after Reginald Barclay who established the first transgalactic com link through the creative application of a quantum singularity. Station personnel often refer to the station as the Broccoli station"
	}
	if stationFaction == "Human Navy" then
		stationBarclay.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationBarclay.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationBarclay.comms_data.trade.medicine = true
		end
	else
		stationBarclay.comms_data.trade.medicine = true
	end
	return stationBarclay
end
function placeBethesda()
	--Bethesda 
	stationBethesda = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationBethesda)
	stationBethesda:setPosition(psx,psy):setCallSign("Bethesda"):setDescription("Medical research")
    stationBethesda.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "friend",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 4.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	autodoc =	{quantity = 5,					cost = 36},
        			medicine =	{quantity = 5,					cost = 5},
        			food =		{quantity = math.random(5,10),	cost = 1} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We research and treat exotic medical conditions",
    	history = "The station is named after the United States national medical research center based in Bethesda, Maryland on earth which was established in the mid 20th century"
	}
	return stationBethesda
end
function placeBroeck()
	--Broeck
	stationBroeck = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationBroeck)
	stationBroeck:setPosition(psx,psy):setCallSign("Broeck"):setDescription("Warp drive components")
    stationBroeck.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	warp =	{quantity = 5,	cost = 36} },
        trade = {	food = false, medicine = false, luxury = random(1,100) < 62 },
		buy =	{	[randomMineral()] = math.random(40,200)	},
        public_relations = true,
        general_information = "We provide warp drive engines and components",
    	history = "This station is named after Chris Van Den Broeck who did some initial research into the possibility of warp drive in the late 20th century on Earth"
	}
	if stationFaction == "Human Navy" then
		stationBroeck.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationBroeck.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationBroeck.comms_data.trade.medicine = random(1,100) < 53
		end
	else
		stationBroeck.comms_data.trade.medicine = random(1,100) < 53
		stationBroeck.comms_data.trade.food = random(1,100) < 14
	end
	return stationBroeck
end
function placeCalifornia()
	--California
	stationCalifornia = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationCalifornia)
	stationCalifornia:setPosition(psx,psy):setCallSign("California"):setDescription("Mining station")
    stationCalifornia.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 2.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	gold =		{quantity = 5,	cost = 90},
        			dilithium =	{quantity = 2,	cost = 25} },
        trade = {	food = false, medicine = false, luxury = false },
		buy =	{	[randomComponent()] = math.random(40,200)	}
	}
	if stationFaction == "Human Navy" then
		stationCalifornia.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationCalifornia.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	end
	return stationCalifornia
end
function placeCalvin()
	--Calvin 
	stationCalvin = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationCalvin)
	stationCalvin:setPosition(psx,psy):setCallSign("Calvin"):setDescription("Robotic research")
    stationCalvin.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	robotic =	{quantity = 5,	cost = 90} },
        trade = {	food = false, medicine = false, luxury = true },
		buy =	{	[randomComponent("robotic")] = math.random(40,200)	},
        public_relations = true,
        general_information = "We research and provide robotic systems and components",
    	history = "This station is named after Dr. Susan Calvin who pioneered robotic behavioral research and programming"
	}
	if stationFaction == "Human Navy" then
		stationCalvin.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationCalvin.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	else
		stationCalvin.comms_data.trade.food = random(1,100) < 8
	end
	return stationCalvin
end
function placeCavor()
	--Cavor 
	stationCavor = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationCavor)
	stationCavor:setPosition(psx,psy):setCallSign("Cavor"):setDescription("Advanced Material components")
    stationCavor.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	filament =	{quantity = 5,	cost = 42} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We fabricate several different kinds of materials critical to various space industries like ship building, station construction and mineral extraction",
    	history = "We named our station after Dr. Cavor, the physicist that invented a barrier material for gravity waves - Cavorite"
	}
	if stationFaction == "Human Navy" then
		stationCavor.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationCavor.comms_data.goods.medicine = {quantity = 5, cost = 5}
			stationCavor.comms_data.trade.luxury = random(1,100) < 33
		else
			if random(1,100) < 50 then
				stationCavor.comms_data.trade.medicine = true
			else
				stationCavor.comms_data.trade.luxury = true
			end
		end
	else
		local whatTrade = random(1,100)
		if whatTrade < 33 then
			stationCavor.comms_data.trade.medicine = true
		elseif whatTrade > 66 then
			stationCavor.comms_data.trade.food = true
		else
			stationCavor.comms_data.trade.luxury = true
		end
	end
	return stationCavor
end
function placeChatuchak()
	--Chatuchak
	stationChatuchak = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationChatuchak)
	stationChatuchak:setPosition(psx,psy):setCallSign("Chatuchak"):setDescription("Trading station")
    stationChatuchak.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 60} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "Only the largest market and trading location in twenty sectors. You can find your heart's desire here",
    	history = "Modeled after the early 21st century bazaar on Earth in Bangkok, Thailand. Designed and built with trade and commerce in mind"
	}
	if stationFaction == "Human Navy" then
		stationChatuchak.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationChatuchak.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	end
	return stationChatuchak
end
function placeCoulomb()
	--Coulomb
	stationCoulomb = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationCoulomb)
	stationCoulomb:setPosition(psx,psy):setCallSign("Coulomb"):setDescription("Shielded circuitry fabrication")
    stationCoulomb.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	circuit =	{quantity = 5,	cost = 50} },
        trade = {	food = false, medicine = false, luxury = random(1,100) < 82 },
		buy =	{	[randomMineral()] = math.random(40,200)	},
        public_relations = true,
        general_information = "We make a large variety of circuits for numerous ship systems shielded from sensor detection and external control interference",
    	history = "Our station is named after the law which quantifies the amount of force with which stationary electrically charged particals repel or attact each other - a fundamental principle in the design of our circuits"
	}
	if stationFaction == "Human Navy" then
		stationCoulomb.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationCoulomb.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationCoulomb.comms_data.trade.medicine = random(1,100) < 27
		end
	else
		stationCoulomb.comms_data.trade.medicine = random(1,100) < 27
		stationCoulomb.comms_data.trade.food = random(1,100) < 16
	end
	return stationCoulomb
end
function placeCyrus()
	--Cyrus
	stationCyrus = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationCyrus)
	stationCyrus:setPosition(psx,psy):setCallSign("Cyrus"):setDescription("Impulse engine components")
    stationCyrus.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	impulse =	{quantity = 5,	cost = 124} },
        trade = {	food = false, medicine = false, luxury = random(1,100) < 78 },
        public_relations = true,
        general_information = "We supply high quality impulse engines and parts for use aboard ships",
    	history = "This station was named after the fictional engineer, Cyrus Smith created by 19th century author Jules Verne"
	}
	if stationFaction == "Human Navy" then
		stationCyrus.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationCyrus.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationCyrus.comms_data.trade.medicine = random(1,100) < 34
		end
	else
		stationCyrus.comms_data.trade.medicine = random(1,100) < 34
		stationCyrus.comms_data.trade.food = random(1,100) < 13
	end
	return stationCyrus
end
function placeDeckard()
	--Deckard
	stationDeckard = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationDeckard)
	stationDeckard:setPosition(psx,psy):setCallSign("Deckard"):setDescription("Android components")
    stationDeckard.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	android =	{quantity = 5,	cost = 73} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "Supplier of android components, programming and service",
    	history = "Named for Richard Deckard who inspired many of the sophisticated safety security algorithms now required for all androids"
	}
	if stationFaction == "Human Navy" then
		stationDeckard.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationDeckard.comms_data.goods.medicine = {quantity = 5, cost = 5}
			stationDeckard.comms_data.goods.medicine.cost = 5
		end
	else
		stationDeckard.comms_data.trade.food = true
	end
	return stationDeckard
end
function placeDeer()
	--Deer
	stationDeer = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationDeer)
	stationDeer:setPosition(psx,psy):setCallSign("Deer"):setDescription("Repulsor and Tractor Beam Components")
    stationDeer.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	tractor =	{quantity = 5,	cost = 90},
        			repulsor =	{quantity = 5,	cost = 95} },
        trade = {	food = false, medicine = false, luxury = true },
		buy =	{	[randomMineral()] = math.random(40,200)	},
        public_relations = true,
        general_information = "We can meet all your pushing and pulling needs with specialized equipment custom made",
    	history = "The station name comes from a short story by the 20th century author Clifford D. Simak as well as from the 19th century developer John Deere who inspired a company that makes the Earth bound equivalents of our products"
	}
	if stationFaction == "Human Navy" then
		stationDeer.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		stationDeer.comms_data.goods.food.cost = 1
		if random(1,5) <= 1 then
			stationDeer.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationDeer.comms_data.trade.medicine = true
		end
	else
		stationDeer.comms_data.trade.medicine = true
		stationDeer.comms_data.trade.food = true
	end
	return stationDeer
end
function placeErickson()
	--Erickson
	stationErickson = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationErickson)
	stationErickson:setPosition(psx,psy):setCallSign("Erickson"):setDescription("Transporter components")
    stationErickson.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	transporter =	{quantity = 5,	cost = 90} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We provide transporters used aboard ships as well as the components for repair and maintenance",
    	history = "The station is named after the early 22nd century inventor of the transporter, Dr. Emory Erickson. This station is proud to have received the endorsement of Admiral Leonard McCoy"
	}
	if stationFaction == "Human Navy" then
		stationErickson.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationErickson.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationErickson.comms_data.trade.medicine = true
		end
	else
		stationErickson.comms_data.trade.medicine = true
		stationErickson.comms_data.trade.food = true
	end
	return stationErickson
end
function placeEvondos()
	--Evondos
	stationEvondos = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationEvondos)
	stationEvondos:setPosition(psx,psy):setCallSign("Evondos"):setDescription("Autodoc components")
    stationEvondos.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	autodoc =	{quantity = 5,	cost = 56} },
        trade = {	food = false, medicine = false, luxury = random(1,100) < 41 },
        public_relations = true,
        general_information = "We provide components for automated medical machinery",
    	history = "The station is the evolution of the company that started automated pharmaceutical dispensing in the early 21st century on Earth in Finland"
	}
	if stationFaction == "Human Navy" then
		stationEvondos.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationEvondos.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationEvondos.comms_data.trade.medicine = true
		end
	else
		stationEvondos.comms_data.trade.medicine = true
	end
	return stationEvondos
end
function placeFeynman()
	--Feynman 
	stationFeynman = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationFeynman)
	stationFeynman:setPosition(psx,psy):setCallSign("Feynman"):setDescription("Nanotechnology research")
    stationFeynman.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	software =	{quantity = 5,	cost = 115},
        			nanites =	{quantity = 5,	cost = 79} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We provide nanites and software for a variety of ship-board systems",
    	history = "This station's name recognizes one of the first scientific researchers into nanotechnology, physicist Richard Feynman"
	}
	if stationFaction == "Human Navy" then
		stationFeynman.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationFeynman.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	else
		stationFeynman.comms_data.trade.medicine = true
		stationFeynman.comms_data.trade.food = random(1,100) < 26
	end
	return stationFeynman
end
function placeGrasberg()
	--Grasberg
	if stationStaticAsteroids then
		placeRandomAroundPoint(Asteroid,15,1,15000,psx,psy)
	end
	stationGrasberg = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationGrasberg)
	stationGrasberg:setPosition(psx,psy):setCallSign("Grasberg"):setDescription("Mining")
    stationGrasberg.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 70} },
        trade = {	food = false, medicine = false, luxury = false },
		buy =	{	[randomComponent()] = math.random(40,200)	},
        public_relations = true,
        general_information = "We mine nearby asteroids for precious minerals and process them for sale",
    	history = "This station's name is inspired by a large gold mine on Earth in Indonesia. The station builders hoped to have a similar amount of minerals found amongst these asteroids"
	}
	if stationFaction == "Human Navy" then
		stationGrasberg.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationGrasberg.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	else
		stationGrasberg.comms_data.trade.food = true
	end
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
	return stationGrasberg
end
function placeHayden()
	--Hayden
	stationHayden = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationHayden)
	stationHayden:setPosition(psx,psy):setCallSign("Hayden"):setDescription("Observatory and stellar mapping")
    stationHayden.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	nanites =	{quantity = 5,	cost = 65} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We study the cosmos and map stellar phenomena. We also track moving asteroids. Look out! Just kidding",
    	history = "Statin named in honor of Charles Hayden whose philanthropy continued astrophysical research and education on Earth in the early 20th century"
	}
	if stationFaction == "Human Navy" then
		stationHayden.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationHayden.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	end
	return stationHayden
end
function placeHeyes()
	--Heyes
	stationHeyes = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationHeyes)
	stationHeyes:setPosition(psx,psy):setCallSign("Heyes"):setDescription("Sensor components")
    stationHeyes.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	sensor =	{quantity = 5,	cost = 72} },
        trade = {	food = false, medicine = false, luxury = true },
		buy =	{	[randomMineral()] = math.random(40,200)	},
        public_relations = true,
        general_information = "We research and manufacture sensor components and systems",
    	history = "The station is named after Tony Heyes the inventor of some of the earliest electromagnetic sensors in the mid 20th century on Earth in the United Kingdom to assist blind human mobility"
	}
	if stationFaction == "Human Navy" then
		stationHeyes.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationHeyes.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	end
	return stationHeyes
end
function placeHossam()
	--Hossam
	stationHossam = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationHossam)
	stationHossam:setPosition(psx,psy):setCallSign("Hossam"):setDescription("Nanite supplier")
    stationHossam.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	nanites =	{quantity = 5,	cost = 90} },
        trade = {	food = false, medicine = false, luxury = random(1,100) < 63 },
        public_relations = true,
        general_information = "We provide nanites for various organic and non-organic systems",
    	history = "This station is named after the nanotechnologist Hossam Haick from the early 21st century on Earth in Israel"
	}
	if stationFaction == "Human Navy" then
		stationHossam.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationHossam.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationHossam.comms_data.trade.medicine = random(1,100) < 44
		end
	else
		stationHossam.comms_data.trade.medicine = random(1,100) < 44
		stationHossam.comms_data.trade.food = random(1,100) < 24
	end
	return stationHossam
end
function placeImpala()
	--Impala
	if stationStaticAsteroids then
		placeRandomAroundPoint(Asteroid,15,1,15000,psx,psy)
	end
	stationImpala = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationImpala)
	stationImpala:setPosition(psx,psy):setCallSign("Impala"):setDescription("Mining")
    stationImpala.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 70} },
        trade = {	food = false, medicine = false, luxury = true },
		buy =	{	[randomComponent()] = math.random(40,200)	},
        public_relations = true,
        general_information = "We mine nearby asteroids for precious minerals"
	}
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
	if stationFaction == "Human Navy" then
		stationImpala.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationImpala.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationImpala.comms_data.trade.medicine = random(1,100) < 28
		end
	else
		stationImpala.comms_data.trade.food = true
	end
	return stationImpala
end
function placeKomov()
	--Komov
	stationKomov = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationKomov)
	stationKomov:setPosition(psx,psy):setCallSign("Komov"):setDescription("Xenopsychology training")
    stationKomov.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	filament =	{quantity = 5,	cost = 46} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We provide classes and simulation to help train diverse species in how to relate to each other",
    	history = "A continuation of the research initially conducted by Dr. Gennady Komov in the early 22nd century on Venus, supported by the application of these principles"
	}
	if stationFaction == "Human Navy" then
		stationKomov.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationKomov.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationKomov.comms_data.trade.medicine = random(1,100) < 44
		end
	else
		stationKomov.comms_data.trade.medicine = random(1,100) < 44
		stationKomov.comms_data.trade.food = random(1,100) < 24
	end
	return stationKomov
end
function placeKrak()
	--Krak
	stationKrak = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationKrak)
	stationKrak:setPosition(psx,psy):setCallSign("Krak"):setDescription("Mining station")
	if stationStaticAsteroids then
		posAxisKrak = random(0,360)
		posKrak = random(10000,60000)
		negKrak = random(10000,60000)
		spreadKrak = random(4000,7000)
		negAxisKrak = posAxisKrak + 180
		xPosAngleKrak, yPosAngleKrak = vectorFromAngle(posAxisKrak, posKrak)
		posKrakEnd = random(30,70)
		createRandomAlongArc(Asteroid, 30+posKrakEnd, psx+xPosAngleKrak, psy+yPosAngleKrak, posKrak, negAxisKrak, negAxisKrak+posKrakEnd, spreadKrak)
		xNegAngleKrak, yNegAngleKrak = vectorFromAngle(negAxisKrak, negKrak)
		negKrakEnd = random(40,80)
		createRandomAlongArc(Asteroid, 30+negKrakEnd, psx+xNegAngleKrak, psy+yNegAngleKrak, negKrak, posAxisKrak, posAxisKrak+negKrakEnd, spreadKrak)
	end
    stationKrak.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	nickel =	{quantity = 5,	cost = 20} },
        trade = {	food = random(1,100) < 50, medicine = true, luxury = random(1,100) < 50 },
		buy =	{	[randomComponent()] = math.random(40,200)	}
	}
	local krakGoods = random(1,100)
	if krakGoods < 10 then
		stationKrak.comms_data.goods.platinum = {quantity = 5, cost = 70}
		stationKrak.comms_data.goods.tritanium = {quantity = 5, cost = 50}
		stationKrak.comms_data.goods.dilithium = {quantity = 5, cost = 52}
	elseif krakGoods < 20 then
		stationKrak.comms_data.goods.platinum = {quantity = 5, cost = 70}
		stationKrak.comms_data.goods.tritanium = {quantity = 5, cost = 50}
	elseif krakGoods < 30 then
		stationKrak.comms_data.goods.platinum = {quantity = 5, cost = 70}
		stationKrak.comms_data.goods.dilithium = {quantity = 5, cost = 52}
	elseif krakGoods < 40 then
		stationKrak.comms_data.goods.tritanium = {quantity = 5, cost = 50}
		stationKrak.comms_data.goods.dilithium = {quantity = 5, cost = 52}
	elseif krakGoods < 50 then
		stationKrak.comms_data.goods.dilithium = {quantity = 5, cost = 52}
	elseif krakGoods < 60 then
		stationKrak.comms_data.goods.platinum = {quantity = 5, cost = 70}
	elseif krakGoods < 70 then
		stationKrak.comms_data.goods.tritanium = {quantity = 5, cost = 50}
	elseif krakGoods < 80 then
		stationKrak.comms_data.goods.gold = {quantity = 5, cost = 50}
		stationKrak.comms_data.goods.tritanium = {quantity = 5, cost = 50}
	elseif krakGoods < 90 then
		stationKrak.comms_data.goods.gold = {quantity = 5, cost = 50}
		stationKrak.comms_data.goods.dilithium = {quantity = 5, cost = 52}
	else
		stationKrak.comms_data.goods.gold = {quantity = 5, cost = 50}
	end
	return stationKrak
end
function placeKruk()
	--Kruk
	stationKruk = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationKruk)
	stationKruk:setPosition(psx,psy):setCallSign("Kruk"):setDescription("Mining station")
	if stationStaticAsteroids then
		posAxisKruk = random(0,360)
		posKruk = random(10000,60000)
		negKruk = random(10000,60000)
		spreadKruk = random(4000,7000)
		negAxisKruk = posAxisKruk + 180
		xPosAngleKruk, yPosAngleKruk = vectorFromAngle(posAxisKruk, posKruk)
		posKrukEnd = random(30,70)
		createRandomAlongArc(Asteroid, 30+posKrukEnd, psx+xPosAngleKruk, psy+yPosAngleKruk, posKruk, negAxisKruk, negAxisKruk+posKrukEnd, spreadKruk)
		xNegAngleKruk, yNegAngleKruk = vectorFromAngle(negAxisKruk, negKruk)
		negKrukEnd = random(40,80)
		createRandomAlongArc(Asteroid, 30+negKrukEnd, psx+xNegAngleKruk, psy+yNegAngleKruk, negKruk, posAxisKruk, posAxisKruk+negKrukEnd, spreadKruk)
	end
    stationKruk.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	nickel =	{quantity = 5,	cost = math.random(25,35)} },
        trade = {	food = random(1,100) < 50, medicine = random(1,100) < 50, luxury = true },
		buy =	{	[randomComponent()] = math.random(40,200)	}
	}
	local krukGoods = random(1,100)
	if krukGoods < 10 then
		stationKruk.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		stationKruk.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
		stationKruk.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	elseif krukGoods < 20 then
		stationKruk.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		stationKruk.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
	elseif krukGoods < 30 then
		stationKruk.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		stationKruk.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	elseif krukGoods < 40 then
		stationKruk.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
		stationKruk.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	elseif krukGoods < 50 then
		stationKruk.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	elseif krukGoods < 60 then
		stationKruk.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
	elseif krukGoods < 70 then
		stationKruk.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
	elseif krukGoods < 80 then
		stationKruk.comms_data.goods.gold = {quantity = 5, cost = math.random(45,55)}
		stationKruk.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
	elseif krukGoods < 90 then
		stationKruk.comms_data.goods.gold = {quantity = 5, cost = math.random(45,55)}
		stationKruk.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	else
		stationKruk.comms_data.goods.gold = {quantity = 5, cost = math.random(45,55)}
	end
	return stationKruk
end
function placeLipkin()
	--Lipkin
	stationLipkin = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationLipkin)
	stationLipkin:setPosition(psx,psy):setCallSign("Lipkin"):setDescription("Autodoc components")
    stationLipkin.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	autodoc =	{quantity = 5,	cost = 76} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We build and repair and provide components and upgrades for automated facilities designed for ships where a doctor cannot be a crew member (commonly called autodocs)",
    	history = "The station is named after Dr. Lipkin who pioneered some of the research and application around robot assisted surgery in the area of partial nephrectomy for renal tumors in the early 21st century on Earth"
	}
	if stationFaction == "Human Navy" then
		stationLipkin.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationLipkin.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	else
		stationLipkin.comms_data.trade.food = true
	end
	return stationLipkin
end
function placeMadison()
	--Madison
	stationMadison = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationMadison)
	stationMadison:setPosition(psx,psy):setCallSign("Madison"):setDescription("Zero gravity sports and entertainment")
    stationMadison.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 70} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "Come take in a game or two or perhaps see a show",
    	history = "Named after Madison Square Gardens from 21st century Earth, this station was designed to serve similar purposes in space - a venue for sports and entertainment"
	}
	if stationFaction == "Human Navy" then
		stationMadison.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationMadison.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationMadison.comms_data.trade.medicine = true
		end
	else
		stationMadison.comms_data.trade.medicine = true
	end
	return stationMadison
end
function placeMaiman()
	--Maiman
	stationMaiman = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationMaiman)
	stationMaiman:setPosition(psx,psy):setCallSign("Maiman"):setDescription("Energy beam components")
    stationMaiman.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	beam =	{quantity = 5,	cost = 70} },
        trade = {	food = false, medicine = false, luxury = false },
		buy =	{	[randomMineral()] = math.random(40,200)	},
        public_relations = true,
        general_information = "We research and manufacture energy beam components and systems",
    	history = "The station is named after Theodore Maiman who researched and built the first laser in the mid 20th centuryon Earth"
	}
	if stationFaction == "Human Navy" then
		stationMaiman.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationMaiman.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationMaiman.comms_data.trade.medicine = true
		end
	else
		stationMaiman.comms_data.trade.medicine = true
	end
	return stationMaiman
end
function placeMarconi()
	--Marconi 
	stationMarconi = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationMarconi)
	stationMarconi:setPosition(psx,psy):setCallSign("Marconi"):setDescription("Energy Beam Components")
    stationMarconi.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	beam =	{quantity = 5,	cost = 80} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We manufacture energy beam components",
    	history = "Station named after Guglielmo Marconi an Italian inventor from early 20th century Earth who, along with Nicolo Tesla, claimed to have invented a death ray or particle beam weapon"
	}
	if stationFaction == "Human Navy" then
		stationMarconi.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationMarconi.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationMarconi.comms_data.trade.medicine = true
		end
	else
		stationMarconi.comms_data.trade.medicine = true
		stationMarconi.comms_data.trade.food = true
	end
	return stationMarconi
end
function placeMayo()
	--Mayo
	stationMayo = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationMayo)
	stationMayo:setPosition(psx,psy):setCallSign("Mayo"):setDescription("Medical Research")
    stationMayo.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 4.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	autodoc =	{quantity = 5,	cost = 128},
        			food =		{quantity = 5,	cost = 1},
        			medicine = 	{quantity = 5,	cost = 5} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We research exotic diseases and other human medical conditions",
    	history = "We continue the medical work started by William Worrall Mayo in the late 19th century on Earth"
	}
	return stationMayo
end
function placeMiller()
	--Miller
	stationMiller = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationMiller)
	stationMiller:setPosition(psx,psy):setCallSign("Miller"):setDescription("Exobiology research")
    stationMiller.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	optic =	{quantity = 5,	cost = 60} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We study recently discovered life forms not native to Earth",
    	history = "This station was named after one of the early exobiologists from mid 20th century Earth, Dr. Stanley Miller"
	}
	if stationFaction == "Human Navy" then
		stationMiller.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationMiller.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	end
	return stationMiller
end
function placeMuddville()
	--Muddville 
	stationMudd = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationMudd)
	stationMudd:setPosition(psx,psy):setCallSign("Muddville"):setDescription("Trading station")
    stationMudd.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 60} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "Come to Muddvile for all your trade and commerce needs and desires",
    	history = "Upon retirement, Harry Mudd started this commercial venture using his leftover inventory and extensive connections obtained while he traveled the stars as a salesman"
	}
	if stationFaction == "Human Navy" then
		stationMudd.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationMudd.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	end
	return stationMudd
end
function placeNexus6()
	--Nexus-6
	stationNexus6 = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationNexus6)
	stationNexus6:setPosition(psx,psy):setCallSign("Nexus-6"):setDescription("Android components")
    stationNexus6.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 1.5 },
        goods = {	android =	{quantity = 5,	cost = 93} },
        trade = {	food = false, medicine = false, luxury = false },
		buy =	{	[randomMineral()] = math.random(40,200),
					[randomComponent("android")] = math.random(40,200)	},
        public_relations = true,
        general_information = "We research and manufacture android components and systems. Our design our androids to maximize their likeness to humans",
    	history = "We named the station after the ground breaking android model produced by the Tyrell corporation"
	}
	if stationFaction == "Human Navy" then
		stationNexus6.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationNexus6.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationNexus6.comms_data.trade.medicine = true
		end
	else
		stationNexus6.comms_data.trade.medicine = true
	end
	return stationNexus6
end
function placeOBrien()
	--O'Brien
	stationOBrien = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationOBrien)
	stationOBrien:setPosition(psx,psy):setCallSign("O'Brien"):setDescription("Transporter components")
    stationOBrien.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	transporter =	{quantity = 5,	cost = 76} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We research and fabricate high quality transporters and transporter components for use aboard ships",
    	history = "Miles O'Brien started this business after his experience as a transporter chief"
	}
	if stationFaction == "Human Navy" then
		stationOBrien.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationOBrien.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationOBrien.comms_data.trade.medicine = random(1,100) < 34
		end
	else
		stationOBrien.comms_data.trade.medicine = true
		stationOBrien.comms_data.trade.food = random(1,100) < 13
	end
	stationOBrien.comms_data.trade.luxury = random(1,100) < 43
	return stationOBrien
end
function placeOlympus()
	--Olympus
	stationOlympus = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationOlympus)
	stationOlympus:setPosition(psx,psy):setCallSign("Olympus"):setDescription("Optical components")
    stationOlympus.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	optic =	{quantity = 5,	cost = 66} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We fabricate optical lenses and related equipment as well as fiber optic cabling and components",
    	history = "This station grew out of the Olympus company based on earth in the early 21st century. It merged with Infinera, then bought several software comapnies before branching out into space based industry"
	}
	if stationFaction == "Human Navy" then
		stationOlympus.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationOlympus.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationOlympus.comms_data.trade.medicine = true
		end
	else
		stationOlympus.comms_data.trade.medicine = true
		stationOlympus.comms_data.trade.food = true
	end
	return stationOlympus
end
function placeOrgana()
	--Organa
	stationOrgana = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationOrgana)
	stationOrgana:setPosition(psx,psy):setCallSign("Organa"):setDescription("Diplomatic training")
    stationOrgana.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 1.0 },
        goods = {	luxury =	{quantity = 5,	cost = 96} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "The premeire academy for leadership and diplomacy training in the region",
    	history = "Established by the royal family so critical during the political upheaval era"
	}
	return stationOrgana
end
function placeOutpost15()
	--Outpost 15
	stationOutpost15 = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationOutpost15)
	stationOutpost15:setPosition(psx,psy):setCallSign("Outpost-15"):setDescription("Mining and trade")
    stationOutpost15.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 70} },
        trade = {	food = true, medicine = false, luxury = false }
	}
	local outpost15Goods = random(1,100)
	if outpost15Goods < 20 then
		stationOutpost15.comms_data.goods.gold = {quantity = 5, cost = math.random(22,30)}
		stationOutpost15.comms_data.goods.cobalt = {quantity = 4, cost = math.random(45,55)}
	elseif outpost15Goods < 40 then
		stationOutpost15.comms_data.goods.gold = {quantity = 5, cost = math.random(22,30)}
	elseif outpost15Goods < 60 then
		stationOutpost15.comms_data.goods.cobalt = {quantity = 4, cost = math.random(45,55)}
	else
		stationOutpost15.comms_data.goods.platinum = {quantity = 4, cost = math.random(55,65)}
	end
	if stationFaction == "Human Navy" then
		stationOutpost15.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationOutpost15.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationOutpost15.comms_data.trade.medicine = true		
		end
	else
		stationOutpost15.comms_data.trade.food = true
	end
	if stationStaticAsteroids then
		placeRandomAroundPoint(Asteroid,15,1,15000,psx,psy)
	end
	return stationOutpost15
end
function placeOutpost21()
	--Outpost 21
	stationOutpost21 = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationOutpost21)
	stationOutpost21:setPosition(psx,psy):setCallSign("Outpost-21"):setDescription("Mining and gambling")
	if stationStaticAsteroids then
		placeRandomAroundPoint(Asteroid,15,1,15000,psx,psy)
	end
    stationOutpost21.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 70} },
        trade = {	food = false, medicine = false, luxury = true }
	}
	local outpost21Goods = random(1,100)
	if outpost21Goods < 20 then
		stationOutpost21.comms_data.goods.gold = {quantity = 5, cost = math.random(22,30)}
		stationOutpost21.comms_data.goods.cobalt = {quantity = 4, cost = math.random(45,55)}
	elseif outpost21Goods < 40 then
		stationOutpost21.comms_data.goods.gold = {quantity = 5, cost = math.random(22,30)}
	elseif outpost21Goods < 60 then
		stationOutpost21.comms_data.goods.cobalt = {quantity = 4, cost = math.random(45,55)}
	else
		stationOutpost21.comms_data.goods.dilithium = {quantity = 4, cost = math.random(45,55)}
	end
	if stationFaction == "Human Navy" then
		stationOutpost21.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationOutpost21.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationOutpost21.comms_data.trade.medicine = random(1,100) < 50
		end
	else
		stationOutpost21.comms_data.trade.food = true
		stationOutpost21.comms_data.trade.medicine = random(1,100) < 50
	end
	return stationOutpost21
end
function placeOwen()
	--Owen
	stationOwen = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationOwen)
	stationOwen:setPosition(psx,psy):setCallSign("Owen"):setDescription("Load lifters and components")
    stationOwen.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	lifter =	{quantity = 5,	cost = 61} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We provide load lifters and components for various ship systems",
    	history = "The station is named after Lars Owen. After his extensive eperience with tempermental machinery on Tatooine, he used his subject matter expertise to expand into building and manufacturing the equipment adding innovations based on his years of experience using load lifters and their relative cousins, moisture vaporators"
	}
	if stationFaction == "Human Navy" then
		stationOwen.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationOwen.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	else
		stationOwen.comms_data.trade.food = true
	end
	return stationOwen
end
function placePanduit()
	--Panduit
	stationPanduit = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationPanduit)
	stationPanduit:setPosition(psx,psy):setCallSign("Panduit"):setDescription("Optic components")
    stationPanduit.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	optic =	{quantity = 5,	cost = 79} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We provide optic components for various ship systems",
    	history = "This station is an outgrowth of the Panduit corporation started in the mid 20th century on Earth in the United States"
	}
	if stationFaction == "Human Navy" then
		stationPanduit.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationPanduit.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationPanduit.comms_data.trade.medicine = random(1,100) < 33
		end
	else
		stationPanduit.comms_data.trade.medicine = random(1,100) < 33
		stationPanduit.comms_data.trade.food = random(1,100) < 27
	end
	return stationPanduit
end
function placeRipley()
	--Ripley
	stationRipley = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationRipley)
	stationRipley:setPosition(psx,psy):setCallSign("Ripley"):setDescription("Load lifters and components")
    stationRipley.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	lifter =	{quantity = 5,	cost = 82} },
        trade = {	food = false, medicine = false, luxury = random(1,100) < 47 },
        public_relations = true,
        general_information = "We provide load lifters and components",
    	history = "The station is named after Ellen Ripley who made creative and effective use of one of our load lifters when defending her ship"
	}
	if stationFaction == "Human Navy" then
		stationRipley.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationRipley.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationRipley.comms_data.trade.medicine = true
		end
	else
		stationRipley.comms_data.trade.food = random(1,100) < 17
		stationRipley.comms_data.trade.medicine = true
	end
	return stationRipley
end
function placeRutherford()
	--Rutherford
	stationRutherford = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationRutherford)
	stationRutherford:setPosition(psx,psy):setCallSign("Rutherford"):setDescription("Shield components and research")
    stationRutherford.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	shield =	{quantity = 5,	cost = 90} },
        trade = {	food = false, medicine = false, luxury = random(1,100) < 43 },
        public_relations = true,
        general_information = "We research and fabricate components for ship shield systems",
    	history = "This station was named after the national research institution Rutherford Appleton Laboratory in the United Kingdom which conducted some preliminary research into the feasability of generating an energy shield in the late 20th century"
	}
	if stationFaction == "Human Navy" then
		stationRutherford.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationRutherford.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationRutherford.comms_data.trade.medicine = true
		end
	else
		stationRutherford.comms_data.trade.food = true
		stationRutherford.comms_data.trade.medicine = true
	end
	return stationRutherford
end
function placeScience7()
	--Science 7
	stationScience7 = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationScience7)
	stationScience7:setPosition(psx,psy):setCallSign("Science-7"):setDescription("Observatory")
    stationScience7.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	food =	{quantity = 2,	cost = 1} },
        trade = {	food = false, medicine = false, luxury = false }
	}
	return stationScience7
end
function placeShawyer()
	--Shawyer
	stationShawyer = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationShawyer)
	stationShawyer:setPosition(psx,psy):setCallSign("Shawyer"):setDescription("Impulse engine components")
    stationShawyer.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	impulse =	{quantity = 5,	cost = 100} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We research and manufacture impulse engine components and systems",
    	history = "The station is named after Roger Shawyer who built the first prototype impulse engine in the early 21st century"
	}
	if stationFaction == "Human Navy" then
		stationShawyer.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationShawyer.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationShawyer.comms_data.trade.medicine = true
		end
	else
		stationShawyer.comms_data.trade.medicine = true
	end
	return stationShawyer
end
function placeShree()
	--Shree
	stationShree = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationShree)
	stationShree:setPosition(psx,psy):setCallSign("Shree"):setDescription("Repulsor and tractor beam components")
    stationShree.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	tractor =	{quantity = 5,	cost = 90},
        			repulsor =	{quantity = 5,	cost = math.random(85,95)} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We make ship systems designed to push or pull other objects around in space",
    	history = "Our station is named Shree after one of many tugboat manufacturers in the early 21st century on Earth in India. Tugboats serve a similar purpose for ocean-going vessels on earth as tractor and repulsor beams serve for space-going vessels today"
	}
	if stationFaction == "Human Navy" then
		stationShree.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationShree.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationShree.comms_data.trade.medicine = true
		end
	else
		stationShree.comms_data.trade.medicine = true
		stationShree.comms_data.trade.food = true
	end
	return stationShree
end
function placeSoong()
	--Soong 
	stationSoong = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationSoong)
	stationSoong:setPosition(psx,psy):setCallSign("Soong"):setDescription("Android components")
    stationSoong.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	android =	{quantity = 5,	cost = 73} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We create androids and android components",
    	history = "The station is named after Dr. Noonian Soong, the famous android researcher and builder"
	}
	if stationFaction == "Human Navy" then
		stationSoong.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationSoong.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	else
		stationSoong.comms_data.trade.food = true
	end
	return stationSoong
end
function placeTiberius()
	--Tiberius
	stationTiberius = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationTiberius)
	stationTiberius:setPosition(psx,psy):setCallSign("Tiberius"):setDescription("Logistics coordination")
    stationTiberius.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 1.0 },
        goods = {	food =	{quantity = 5,	cost = 1} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We support the stations and ships in the area with planning and communication services",
    	history = "We recognize the influence of Starfleet Captain James Tiberius Kirk in the 23rd century in our station name"
	}
	return stationTiberius
end
function placeTokra()
	--Tokra
	stationTokra = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationTokra)
	stationTokra:setPosition(psx,psy):setCallSign("Tokra"):setDescription("Advanced material components")
	whatTrade = random(1,100)
    stationTokra.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	filament =	{quantity = 5,	cost = 42} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We create multiple types of advanced material components. Our most popular products are our filaments",
    	history = "We learned several of our critical industrial processes from the Tokra race, so we honor our fortune by naming the station after them"
	}
	local whatTrade = random(1,100)
	if stationFaction == "Human Navy" then
		stationTokra.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationTokra.comms_data.goods.medicine = {quantity = 5, cost = 5}
			stationTokra.comms_data.trade.luxury = true
		else
			if whatTrade < 50 then
				stationTokra.comms_data.trade.medicine = true
			else
				stationTokra.comms_data.trade.luxury = true
			end
		end
	else
		if whatTrade < 33 then
			stationTokra.comms_data.trade.food = true
		elseif whatTrade > 66 then
			stationTokra.comms_data.trade.medicine = true
		else
			stationTokra.comms_data.trade.luxury = true
		end
	end
	return stationTokra
end
function placeToohie()
	--Toohie
	stationToohie = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationToohie)
	stationToohie:setPosition(psx,psy):setCallSign("Toohie"):setDescription("Shield and armor components and research")
    stationToohie.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	shield =	{quantity = 5,	cost = 90} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We research and make general and specialized components for ship shield and ship armor systems",
    	history = "This station was named after one of the earliest researchers in shield technology, Alexander Toohie back when it was considered impractical to construct shields due to the physics involved."
	}
	if stationFaction == "Human Navy" then
		stationToohie.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationToohie.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationToohie.comms_data.trade.medicine = random(1,100) < 25
		end
	else
		stationToohie.comms_data.trade.medicine = random(1,100) < 25
	end
	return stationToohie
end
function placeUtopiaPlanitia()
	--Utopia Planitia
	stationUtopiaPlanitia = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationUtopiaPlanitia)
	stationUtopiaPlanitia:setPosition(psx,psy):setCallSign("Utopia Planitia"):setDescription("Ship building and maintenance facility")
    stationUtopiaPlanitia.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 1.0 },
        goods = {	warp =	{quantity = 5,	cost = 167} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We work on all aspects of naval ship building and maintenance. Many of the naval models are researched, designed and built right here on this station. Our design goals seek to make the space faring experience as simple as possible given the tremendous capabilities of the modern naval vessel"
	}
	if stationFaction == "Human Navy" then
		stationUtopiaPlanitia.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationUtopiaPlanitia.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	end
	return stationUtopiaPlanitia
end
function placeVactel()
	--Vactel
	stationVactel = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationVactel)
	stationVactel:setPosition(psx,psy):setCallSign("Vactel"):setDescription("Shielded Circuitry Fabrication")
    stationVactel.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	circuit =	{quantity = 5,	cost = 50} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We specialize in circuitry shielded from external hacking suitable for ship systems",
    	history = "We started as an expansion from the lunar based chip manufacturer of Earth legacy Intel electronic chips"
	}
	if stationFaction == "Human Navy" then
		stationVactel.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationVactel.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	end
	return stationVactel
end
function placeVeloquan()
	--Veloquan
	stationVeloquan = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationVeloquan)
	stationVeloquan:setPosition(psx,psy):setCallSign("Veloquan"):setDescription("Sensor components")
    stationVeloquan.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	sensor =	{quantity = 5,	cost = 68} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We research and construct components for the most powerful and accurate sensors used aboard ships along with the software to make them easy to use",
    	history = "The Veloquan company has its roots in the manufacturing of LIDAR sensors in the early 21st century on Earth in the United States for autonomous ground-based vehicles. They expanded research and manufacturing operations to include various sensors for space vehicles. Veloquan was the result of numerous mergers and acquisitions of several companies including Velodyne and Quanergy"
	}
	if stationFaction == "Human Navy" then
		stationVeloquan.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationVeloquan.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationVeloquan.comms_data.trade.medicine = true
		end
	else
		stationVeloquan.comms_data.trade.medicine = true
		stationVeloquan.comms_data.trade.food = true
	end
	return stationVeloquan
end
function placeZefram()
	--Zefram
	stationZefram = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationZefram)
	stationZefram:setPosition(psx,psy):setCallSign("Zefram"):setDescription("Warp engine components")
    stationZefram.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 1.0 },
        goods = {	warp =	{quantity = 5,	cost = 140} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We specialize in the esoteric components necessary to make warp drives function properly",
    	history = "Zefram Cochrane constructed the first warp drive in human history. We named our station after him because of the specialized warp systems work we do"
	}
	if stationFaction == "Human Navy" then
		stationZefram.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationZefram.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationZefram.comms_data.trade.medicine = random(1,100) < 27
		end
	else
		stationZefram.comms_data.trade.medicine = random(1,100) < 27
		stationZefram.comms_data.trade.food = random(1,100) < 16
	end
	return stationZefram
end
--	Generic stations to be placed --
function placeJabba()
	--Jabba
	stationJabba = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationJabba)
	stationJabba:setPosition(psx,psy):setCallSign("Jabba"):setDescription("Commerce and gambling")
    stationJabba.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "Come play some games and shop. House take does not exceed 4 percent"
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationJabba.comms_data.goods.luxury = {quantity = 5, cost = math.random(68,81)}
	elseif stationGoodChoice == 2 then
		stationJabba.comms_data.goods.gold = {quantity = 5, cost = math.random(61,77)}
	else
		stationJabba.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,79)}
	end
	return stationJabba
end
function placeKrik()
	--Krik
	stationKrik = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationKrik)
	stationKrik:setPosition(psx,psy):setCallSign("Krik"):setDescription("Mining station")
	if stationStaticAsteroids then
		posAxisKrik = random(0,360)
		posKrik = random(30000,80000)
		negKrik = random(20000,60000)
		spreadKrik = random(5000,8000)
		negAxisKrik = posAxisKrik + 180
		xPosAngleKrik, yPosAngleKrik = vectorFromAngle(posAxisKrik, posKrik)
		posKrikEnd = random(40,90)
		createRandomAlongArc(Asteroid, 30+posKrikEnd, psx+xPosAngleKrik, psy+yPosAngleKrik, posKrik, negAxisKrik, negAxisKrik+posKrikEnd, spreadKrik)
		xNegAngleKrik, yNegAngleKrik = vectorFromAngle(negAxisKrik, negKrik)
		negKrikEnd = random(30,60)
		createRandomAlongArc(Asteroid, 30+negKrikEnd, psx+xNegAngleKrik, psy+yNegAngleKrik, negKrik, posAxisKrik, posAxisKrik+negKrikEnd, spreadKrik)
	end
    stationKrik.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	nickel =	{quantity = 5,	cost = 20} },
        trade = {	food = true, medicine = true, luxury = random(1,100) < 50 },
        public_relations = true,
        general_information = "The finest shield and armor manufacturer in the quadrant",
    	history = "We named this station for the pioneering spirit of the 22nd century Starfleet explorer, Captain Jonathan Archer"
	}
	local krikGoods = random(1,100)
	if krikGoods < 10 then
		stationKrik.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		stationKrik.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
		stationKrik.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	elseif krikGoods < 20 then
		stationKrik.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		stationKrik.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
	elseif krikGoods < 30 then
		stationKrik.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		stationKrik.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	elseif krikGoods < 40 then
		stationKrik.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
		stationKrik.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	elseif krikGoods < 50 then
		stationKrik.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	elseif krikGoods < 60 then
		stationKrik.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
	elseif krikGoods < 70 then
		stationKrik.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
	elseif krikGoods < 80 then
		stationKrik.comms_data.goods.cobalt = {quantity = 5, cost = math.random(55,65)}
	else
		stationKrik.comms_data.goods.cobalt = {quantity = 5, cost = math.random(55,65)}
		stationKrik.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	end
	return stationKrik
end
function placeLando()
	--Lando
	stationLando = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationLando)
	stationLando:setPosition(psx,psy):setCallSign("Lando"):setDescription("Casino and Gambling")
    stationLando.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	shield =	{quantity = 5,	cost = 90} },
        trade = {	food = false, medicine = false, luxury = false }
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationLando.comms_data.goods.luxury = {quantity = 5, cost = math.random(68,81)}
	elseif stationGoodChoice == 2 then
		stationLando.comms_data.goods.gold = {quantity = 5, cost = math.random(61,77)}
	else
		stationLando.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,79)}
	end
	return stationLando
end
function placeMaverick()
	--Maverick
	stationMaverick = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationMaverick)
	stationMaverick:setPosition(psx,psy):setCallSign("Maverick"):setDescription("Gambling and resupply")
    stationMaverick.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "Relax and meet some interesting players"
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationMaverick.comms_data.goods.luxury = {quantity = 5, cost = math.random(68,81)}
	elseif stationGoodChoice == 2 then
		stationMaverick.comms_data.goods.gold = {quantity = 5, cost = math.random(61,77)}
	else
		stationMaverick.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,79)}
	end
	return stationMaverick
end
function placeNefatha()
	--Nefatha
	stationNefatha = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationNefatha)
	stationNefatha:setPosition(psx,psy):setCallSign("Nefatha"):setDescription("Commerce and recreation")
    stationNefatha.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 70} },
        trade = {	food = false, medicine = false, luxury = false }
	}
	return stationNefatha
end
function placeOkun()
	--Okun
	stationOkun = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationOkun)
	stationOkun:setPosition(psx,psy):setCallSign("Okun"):setDescription("Xenopsychology research")
    stationOkun.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = false
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationOkun.comms_data.goods.optic = {quantity = 5, cost = math.random(52,65)}
	elseif stationGoodChoice == 2 then
		stationOkun.comms_data.goods.filament = {quantity = 5, cost = math.random(55,67)}
	else
		stationOkun.comms_data.goods.lifter = {quantity = 5, cost = math.random(48,69)}
	end
	return stationOkun
end
function placeOutpost7()
	--Outpost 7
	stationOutpost7 = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationOutpost7)
	stationOutpost7:setPosition(psx,psy):setCallSign("Outpost-7"):setDescription("Resupply")
    stationOutpost7.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 80} },
        trade = {	food = false, medicine = false, luxury = false }
	}
	return stationOutpost7
end
function placeOutpost8()
	--Outpost 8
	stationOutpost8 = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationOutpost8)
	stationOutpost8:setPosition(psx,psy):setCallSign("Outpost-8")
    stationOutpost8.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false }
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationOutpost8.comms_data.goods.impulse = {quantity = 5, cost = math.random(69,75)}
	elseif stationGoodChoice == 2 then
		stationOutpost8.comms_data.goods.tractor = {quantity = 5, cost = math.random(55,67)}
	else
		stationOutpost8.comms_data.goods.beam = {quantity = 5, cost = math.random(61,69)}
	end
	return stationOutpost8
end
function placeOutpost33()
	--Outpost 33
	stationOutpost33 = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationOutpost33)
	stationOutpost33:setPosition(psx,psy):setCallSign("Outpost-33"):setDescription("Resupply")
    stationOutpost33.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 75} },
        trade = {	food = false, medicine = false, luxury = false }
	}
	return stationOutpost33
end
function placePrada()
	--Prada
	stationPrada = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationPrada)
	stationPrada:setPosition(psx,psy):setCallSign("Prada"):setDescription("Textiles and fashion")
    stationPrada.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false }
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationPrada.comms_data.goods.luxury = {quantity = 5, cost = math.random(69,75)}
	elseif stationGoodChoice == 2 then
		stationPrada.comms_data.goods.cobalt = {quantity = 5, cost = math.random(55,67)}
	else
		stationPrada.comms_data.goods.dilithium = {quantity = 5, cost = math.random(61,69)}
	end
	return stationPrada
end
function placeResearch11()
	--Research-11
	stationResearch11 = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationResearch11)
	stationResearch11:setPosition(psx,psy):setCallSign("Research-11"):setDescription("Stress Psychology Research")
    stationResearch11.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false }
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationResearch11.comms_data.goods.warp = {quantity = 5, cost = math.random(85,120)}
	elseif stationGoodChoice == 2 then
		stationResearch11.comms_data.goods.repulsor = {quantity = 5, cost = math.random(62,75)}
	else
		stationResearch11.comms_data.goods.robotic = {quantity = 5, cost = math.random(75,89)}
	end
	return stationResearch11
end
function placeResearch19()
	--Research-19
	stationResearch19 = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationResearch19)
	stationResearch19:setPosition(psx,psy):setCallSign("Research-19"):setDescription("Low gravity research")
    stationResearch19.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false }
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationResearch19.comms_data.goods.transporter = {quantity = 5, cost = math.random(85,94)}
	elseif stationGoodChoice == 2 then
		stationResearch19.comms_data.goods.sensor = {quantity = 5, cost = math.random(62,75)}
	else
		stationResearch19.comms_data.goods.communication = {quantity = 5, cost = math.random(55,89)}
	end
	return stationResearch19
end
function placeRubis()
	--Rubis
	stationRubis = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationRubis)
	stationRubis:setPosition(psx,psy):setCallSign("Rubis"):setDescription("Resupply")
    stationRubis.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 76} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "Get your energy here! Grab a drink before you go!"
	}
	return stationRubis
end
function placeScience2()
	--Science 2
	stationScience2 = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationScience2)
	stationScience2:setPosition(psx,psy):setCallSign("Science-2"):setDescription("Research Lab and Observatory")
    stationScience2.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false }
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationScience2.comms_data.goods.autodoc = {quantity = 5, cost = math.random(85,94)}
	elseif stationGoodChoice == 2 then
		stationScience2.comms_data.goods.android = {quantity = 5, cost = math.random(62,75)}
	else
		stationScience2.comms_data.goods.nanites = {quantity = 5, cost = math.random(55,89)}
	end
	return stationScience2
end
function placeScience4()
	--Science 4
	stationScience4 = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationScience4)
	stationScience4:setPosition(psx,psy):setCallSign("Science-4"):setDescription("Biotech research")
    stationScience4.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "The finest shield and armor manufacturer in the quadrant",
    	history = "We named this station for the pioneering spirit of the 22nd century Starfleet explorer, Captain Jonathan Archer"
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationScience4.comms_data.goods.software = {quantity = 5, cost = math.random(85,94)}
	elseif stationGoodChoice == 2 then
		stationScience4.comms_data.goods.circuit = {quantity = 5, cost = math.random(62,75)}
	else
		stationScience4.comms_data.goods.battery = {quantity = 5, cost = math.random(55,89)}
	end
	return stationScience4
end
function placeSkandar()
	--Skandar
	stationSkandar = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationSkandar)
	stationSkandar:setPosition(psx,psy):setCallSign("Skandar"):setDescription("Routine maintenance and entertainment")
    stationSkandar.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 87} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "Stop by for repairs. Take in one of our juggling shows featuring the four-armed Skandars",
    	history = "The nomadic Skandars have set up at this station to practice their entertainment and maintenance skills as well as build a community where Skandars can relax"
	}
	return stationSkandar
end
function placeSpot()
	--Spot
	stationSpot = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationSpot)
	stationSpot:setPosition(psx,psy):setCallSign("Spot"):setDescription("Observatory")
    stationSpot.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false }
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationSpot.comms_data.goods.optic = {quantity = 5, cost = math.random(85,94)}
	elseif stationGoodChoice == 2 then
		stationSpot.comms_data.goods.software = {quantity = 5, cost = math.random(62,75)}
	else
		stationSpot.comms_data.goods.sensor = {quantity = 5, cost = math.random(55,89)}
	end
	return stationSpot
end
function placeStarnet()
	--Starnet 
	stationStarnet = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationStarnet)
	stationStarnet:setPosition(psx,psy):setCallSign("Starnet"):setDescription("Automated weapons systems")
    stationStarnet.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We research and create automated weapons systems to improve ship combat capability"
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationStarnet.comms_data.goods.shield = {quantity = 5, cost = math.random(85,94)}
	elseif stationGoodChoice == 2 then
		stationStarnet.comms_data.goods.beam = {quantity = 5, cost = math.random(62,75)}
	else
		stationStarnet.comms_data.goods.lifter = {quantity = 5, cost = math.random(55,89)}
	end
	return stationStarnet
end
function placeTandon()
	--Tandon
	stationTandon = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationTandon)
	stationTandon:setPosition(psx,psy):setCallSign("Tandon"):setDescription("Biotechnology research")
    stationTandon.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "The finest shield and armor manufacturer in the quadrant",
    	history = "We named this station for the pioneering spirit of the 22nd century Starfleet explorer, Captain Jonathan Archer"
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationTandon.comms_data.goods.autodoc = {quantity = 5, cost = math.random(85,94)}
	elseif stationGoodChoice == 2 then
		stationTandon.comms_data.goods.robotic = {quantity = 5, cost = math.random(62,75)}
	else
		stationTandon.comms_data.goods.android = {quantity = 5, cost = math.random(55,89)}
	end
	return stationTandon
end
function placeVaiken()
	--Vaiken
	stationVaiken = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationVaiken)
	stationVaiken:setPosition(psx,psy):setCallSign("Vaiken"):setDescription("Ship building and maintenance facility")
    stationVaiken.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	food =		{quantity = 10,	cost = 1},
        			medicine =	{quantity = 5,	cost = 5} },
        trade = {	food = false, medicine = false, luxury = false }
	}
	return stationVaiken
end
function placeValero()
	--Valero
	stationValero = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	setStationComms(stationValero)
	stationValero:setPosition(psx,psy):setCallSign("Valero"):setDescription("Resupply")
    stationValero.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "neutral", 						EMP = "neutral"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        weapon_cost = 		{Homing = math.random(3,4),				HVLI = math.random(3,4),				Mine = math.random(3,5),				Nuke = math.random(15,18),				EMP = math.random(5,12)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 4.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 1.0 },
        goods = {	luxury =	{quantity = 5,	cost = 90} },
        trade = {	food = false, medicine = false, luxury = false }
	}
	return stationValero
end
--	Enemy stations to be placed --
function placeAramanth()
	--Aramanth
	stationAramanth = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCallSign("Aramanth"):setPosition(psx,psy)
	return stationAramanth
end
function placeEmpok()
	--Empok Nor
	stationEmpok = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	stationEmpok:setPosition(psx,psy):setCallSign("Empok Nor")
	return stationEmpok
end
function placeGandala()
	--Gandala
	stationGanalda = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	stationGanalda:setPosition(psx,psy):setCallSign("Ganalda")
	return stationGanalda
end
function placeHassenstadt()
	--Hassenstadt
	stationHassenstadt = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCallSign("Hassenstadt"):setPosition(psx,psy)
	return stationHassenstadt
end
function placeKaldor()
	--Kaldor
	stationKaldor = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCallSign("Kaldor"):setPosition(psx,psy)
	return stationKaldor
end
function placeMagMesra()
	--Magenta Mesra
	stationMagMesra = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCallSign("Magenta Mesra"):setPosition(psx,psy)
	return stationMagMesra
end
function placeMosEisley()
	--Mos Eisley
	stationMosEisley = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCallSign("Mos Eisley"):setPosition(psx,psy)
	return stationMosEisley
end
function placeQuestaVerde()
	--Questa Verde
	stationQuestaVerde = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCallSign("Questa Verde"):setPosition(psx,psy)
	return stationQuestaVerde
end
function placeRlyeh()
	--R'lyeh
	stationRlyeh = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCallSign("R'lyeh"):setPosition(psx,psy)
	return stationRlyeh
end
function placeScarletCit()
	--Scarlet Citadel
	stationScarletCitadel = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	stationScarletCitadel:setPosition(psx,psy):setCallSign("Scarlet Citadel")
	return stationScarletCitadel
end
function placeStahlstadt()
	--Stahlstadt
	stationStahlstadt = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCallSign("Stahlstadt"):setPosition(psx,psy)
	return stationStahlstadt
end
function placeTic()
	--Ticonderoga
	stationTic = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	stationTic:setPosition(psx,psy):setCallSign("Ticonderoga")
	return stationTic
end
-------------------------------------------
-- Inventory button for relay/operations --
-------------------------------------------
function cargoInventory(delta)
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
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
						p:addCustomButton("Relay",tbi,"Inventory",cargoInventoryList[pidx])
						p.inventoryButton = true
					end
				end
				if p:hasPlayerAtPosition("Operations") then
					if p.inventoryButton == nil then
						local tbi = "inventoryOp" .. p:getCallSign()
						p:addCustomButton("Operations",tbi,"Inventory",cargoInventoryList[pidx])
						p.inventoryButton = true
					end
				end
			end
		end
	end
end
function cargoInventoryGivenShip(p)
	p:addToShipLog(string.format("%s Current cargo:",p:getCallSign()),"Yellow")
	local cargoHoldEmpty = true
	if p.goods ~= nil then
		for good, quantity in pairs(p.goods) do
			if quantity ~= nil and quantity > 0 then
				p:addToShipLog(string.format("     %s: %i",good,math.floor(quantity)),"Yellow")
				cargoHoldEmpty = false
			end
		end
	end
	if cargoHoldEmpty then
		p:addToShipLog("     Empty\n","Yellow")
	end
	p:addToShipLog(string.format("Available space: %i",p.cargo),"Yellow")
end
function cargoInventory1()
	local p = getPlayerShip(1)
	cargoInventoryGivenShip(p)
end
function cargoInventory2()
	local p = getPlayerShip(2)
	cargoInventoryGivenShip(p)
end
function cargoInventory3()
	local p = getPlayerShip(3)
	cargoInventoryGivenShip(p)
end
function cargoInventory4()
	local p = getPlayerShip(4)
	cargoInventoryGivenShip(p)
end
function cargoInventory5()
	local p = getPlayerShip(5)
	cargoInventoryGivenShip(p)
end
function cargoInventory6()
	local p = getPlayerShip(6)
	cargoInventoryGivenShip(p)
end
function cargoInventory7()
	local p = getPlayerShip(7)
	cargoInventoryGivenShip(p)
end
function cargoInventory8()
	local p = getPlayerShip(8)
	cargoInventoryGivenShip(p)
end
----------------------------
-- Station communications --
----------------------------
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
    if stationCommsDiagnostic then print("set players") end
	setPlayers()
	if stationCommsDiagnostic then print("set local variable player from comms source") end
	local playerCallSign = comms_source:getCallSign()
	if stationCommsDiagnostic then print(string.format("commsStation derived name: %s",playerCallSign)) end
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
	local playerCallSign = comms_source:getCallSign()
	local ctd = comms_target.comms_data
	if stationCommsDiagnostic then print(string.format("handleDockedState derived name: %s",playerCallSign)) end
    if comms_source:isFriendly(comms_target) then
    	if ctd.friendlyness > 66 then
    		oMsg = string.format("Greetings %s!\nHow may we help you today?",comms_source:getCallSign())
    	elseif ctd.friendlyness > 33 then
			oMsg = "Good day, officer!\nWhat can we do for you today?"
		else
			oMsg = "Hello, may I help you?"
		end
    else
		oMsg = "Welcome to our lovely station."
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. "Forgive us if we seem a little distracted. We are carefully monitoring the enemies nearby."
	end
	setCommsMessage(oMsg)
	local missilePresence = 0
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
				if stationCommsDiagnostic then print("in restock function") end
				setCommsMessage("What type of ordnance?")
				if stationCommsDiagnostic then print(string.format("player nuke weapon storage max: %.1f",comms_source:getWeaponStorageMax("Nuke"))) end
				if comms_source:getWeaponStorageMax("Nuke") > 0 then
					if stationCommsDiagnostic then print("player can fire nukes") end
					if ctd.weapon_available.Nuke then
						if stationCommsDiagnostic then print("station has nukes available") end
						if math.random(1,10) <= 5 then
							nukePrompt = "Can you supply us with some nukes? ("
						else
							nukePrompt = "We really need some nukes ("
						end
						if stationCommsDiagnostic then print("nuke prompt: " .. nukePrompt) end
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
		end	--end secondary ordnance available from station if branch
	end	--end missles used on player ship if branch
	if comms_target == primusStation and plotChoiceStation == primusStation and plot1 == nil then
		addCommsReply("Visit dispatch office", function()
			setCommsMessage(string.format("Excellent work on your last assignment, %s. You may stand down or take another assignment",playerCallSign))
			playVoice("Skyler03")
			addCommsReply("Stand down", function()
				setCommsMessage("Congratulations and thank you")
				playVoice("Pat05")
				showEndStats()
				victory("Human Navy")
			end)
			if string.find(mission_choice,"Selectable") then
				addCommsReply("Move to next region of available missions", function()
					setCommsMessage(string.format("Dock with station %s for the details of your next assignment. Beware the asteroids",belt1Stations[1]:getCallSign()))
					playVoice("Pat06")
					plotChoiceStation = belt1Stations[1]
					mission_region = 2
					primaryOrders = string.format("Dock with station %s",belt1Stations[1]:getCallSign())
				end)
				if string.find(mission_choice,"Region") then
					if #plotList >= 1 then
						addCommsReply("Request next assignment", function()
							plotChoice = math.random(1,#plotList)
							plot1 = plotList[plotChoice]
							setCommsMessage(plotListMessage[plotChoice])
							if server_voices then
								if plotChoice == 1 then
									playVoice(string.format("Pat01%s",planetSecondus:getCallSign()))
								end
								if plotChoice == 2 then
									playVoice(string.format("Pat02%s",planetPrimus:getCallSign()))
								end
								if plotChoice == 3 then
									playVoice("Pat03")
								end
								if plotChoice == 4 then
									playVoice("Pat04")
								end
							end
							primaryOrders = plotListOrders[plotChoice]
							table.remove(plotList,plotChoice)
							table.remove(plotListMessage,plotChoice)
							table.remove(plotListOrders,plotChoice)
						end)
					end
				else
					for plot_index=1,#plotList do
						addCommsReply(plotListOrders[plot_index], function()
							plotChoice = plot_index
							plot1 = plotList[plot_index]
							setCommsMessage(plotListMessage[plot_index])
							if server_voices then
								if plotChoice == 1 then
									playVoice(string.format("Pat01%s",planetSecondus:getCallSign()))
								end
								if plotChoice == 2 then
									playVoice(string.format("Pat02%s",planetPrimus:getCallSign()))
								end
								if plotChoice == 3 then
									playVoice("Pat03")
								end
								if plotChoice == 4 then
									playVoice("Pat04")
								end
							end
							primaryOrders = plotListOrders[plot_index]
							table.remove(plotList,plot_index)
							table.remove(plotListMessage,plot_index)
							table.remove(plotListOrders,plot_index)
						end)
					end				
				end
			else
				addCommsReply("Request next assignment", function()
					if #plotList < 1 then
						setCommsMessage(string.format("Dock with station %s for the details of your next assignment. Beware the asteroids",belt1Stations[1]:getCallSign()))
						playVoice("Pat06")
						plotChoiceStation = belt1Stations[1]
						mission_region = 2
						primaryOrders = string.format("Dock with station %s",belt1Stations[1]:getCallSign())
					else
						--plotChoice = 4	--force to Exuari marauders
						plotChoice = math.random(1,#plotList)
						plot1 = plotList[plotChoice]
						setCommsMessage(plotListMessage[plotChoice])
						if server_voices then
							if plotChoice == 1 then
								playVoice(string.format("Pat01%s",planetSecondus:getCallSign()))
							end
							if plotChoice == 2 then
								playVoice(string.format("Pat02%s",planetPrimus:getCallSign()))
							end
							if plotChoice == 3 then
								playVoice("Pat03")
							end
							if plotChoice == 4 then
								playVoice("Pat04")
							end
						end
						primaryOrders = plotListOrders[plotChoice]
						table.remove(plotList,plotChoice)
						table.remove(plotListMessage,plotChoice)
						table.remove(plotListOrders,plotChoice)
					end
					addCommsReply("Back", commsStation)
				end)
			end
			addCommsReply("Back", commsStation)
		end)
	end	--choose mission from dispatch office on primus station
	if comms_target == belt1Stations[1] and plotChoiceStation == belt1Stations[1] and plot1 == nil then
		addCommsReply("Visit dispatch office", function()
			setCommsMessage(string.format("Welcome to %s station, %s. We're glad you're here. These are your choices for assignments",belt1Stations[1]:getCallSign(),comms_source:getCallSign()))
			playVoice("Tracy02")
			if string.find(mission_choice,"Selectable") then
				addCommsReply(string.format("Move on to missions in %s area",planetTertius:getCallSign()), function()
					setCommsMessage(string.format("Dock with station %s for your next assignment",tertiusStation:getCallSign()))
					playVoice(string.format("Tracy01%s",planetTertius:getCallSign()))
					plotChoiceStation = tertiusStation
					mission_region = 3
					primaryOrders = string.format("Dock with station %s",tertiusStation:getCallSign())
				end)
				if string.find(mission_choice,"Region") then
					if #plotList2 >= 1 then
						addCommsReply("Request next assignment", function()
							plotChoice = math.random(1,#plotList2)
							plot1 = plotList2[plotChoice]
							setCommsMessage(plotListMessage2[plotChoice])
							if server_voices then
								if plotChoice == 1 then
									playVoice("Tracy03")
								end
								if plotChoice == 2 then
									playVoice("Tracy05")
								end
								if plotChoice == 3 then
									local orbit_label = "Outside"
									if secondusOrbit > playerSpawnBand then		--players spawn inside Secondus
										orbit_label = "Inside"
									end
									playVoice(string.format("Tracy06%s%s",orbit_label,planetSecondus:getCallSign()))
								end
							end
							primaryOrders = plotListOrders2[plotChoice]
							table.remove(plotList2,plotChoice)
							table.remove(plotListMessage2,plotChoice)
							table.remove(plotListOrders2,plotChoice)
						end)
					end
				else
					for plot_index=1,#plotList2 do
						addCommsReply(plotListOrders2[plot_index], function()
							plotChoice = plot_index
							plot1 = plotList2[plot_index]
							setCommsMessage(plotListMessage2[plot_index])
							if server_voices then
								if plotChoice == 1 then
									playVoice("Tracy03")
								end
								if plotChoice == 2 then
									playVoice("Tracy05")
								end
								if plotChoice == 3 then
									local orbit_label = "Outside"
									if secondusOrbit > playerSpawnBand then		--players spawn inside Secondus
										orbit_label = "Inside"
									end
									playVoice(string.format("Tracy06%s%s",orbit_label,planetSecondus:getCallSign()))
								end
							end
							primaryOrders = plotListOrders2[plot_index]
							table.remove(plotList2,plot_index)
							table.remove(plotListMessage2,plot_index)
							table.remove(plotListOrders2,plot_index)
						end)
					end				
				end
			else
				addCommsReply("Request next assignment", function()
					if #plotList2 < 1 then
						setCommsMessage(string.format("Dock with station %s for your next assignment",tertiusStation:getCallSign()))
						playVoice(string.format("Tracy01%s",planetTertius:getCallSign()))
						plotChoiceStation = tertiusStation
						mission_region = 3
						primaryOrders = string.format("Dock with station %s",tertiusStation:getCallSign())
					else
						plotChoice = math.random(1,#plotList2)
						plot1 = plotList2[plotChoice]
						setCommsMessage(plotListMessage2[plotChoice])
						if server_voices then
							if plotChoice == 1 then
								playVoice("Tracy03")
							end
							if plotChoice == 2 then
								playVoice("Tracy05")
							end
							if plotChoice == 3 then
								local orbit_label = "Outside"
								if secondusOrbit > playerSpawnBand then		--players spawn inside Secondus
									orbit_label = "Inside"
								end
								playVoice(string.format("Tracy06%s%s",orbit_label,planetSecondus:getCallSign()))
							end
						end
						primaryOrders = plotListOrders2[plotChoice]
						table.remove(plotList2,plotChoice)
						table.remove(plotListMessage2,plotChoice)
						table.remove(plotListOrders2,plotChoice)
					end
					addCommsReply("Back", commsStation)
				end)
			end
			addCommsReply("Stand down", function()
				setCommsMessage("Congratulations and thank you")
				playVoice("Tracy04")
				showEndStats()
				victory("Human Navy")
			end)
			addCommsReply("Back", commsStation)
		end)
	end
	if comms_target == tertiusStation and plotChoiceStation == tertiusStation and plot1 == nil then
		addCommsReply("Visit dispatch office", function()
			setCommsMessage(string.format("Welcome, %s. Everything is bigger at %s station. We could use your help with one of these mission options",comms_source:getCallSign(),tertiusStation:getCallSign()))
			playVoice("Hayden01")
			addCommsReply("Exuari Exterminates Extraterrestrials", function()
				setCommsMessage("The Exuari have unlimited resources and continually send more ships of greater and greater power and nastier surprises. No victory condition exists")
				playVoice("Hayden02")
				addCommsReply("Confirm", function()
					plot1 = exterminate
					setCommsMessage(string.format("The Exuari are on their way. They will target you and the assets in and around %s",planetTertius:getCallSign()))
					playVoice("Hayden03")
				end)
				addCommsReply("Back", commsStation)
			end)
			addCommsReply("Eliminate Exuari stronghold", function()
				setCommsMessage("The Exuari have unlimited resources, but they are constrained to funnel them through their stronghold. Obtain victory by finding and destroying the Exuari stronghold.")
				playVoice("Hayden04")
				addCommsReply("Confirm", function()
					plot1 = stronghold
					setCommsMessage("Good luck")
					playVoice("Hayden05")
				end)
				addCommsReply("Back", commsStation)
			end)
			addCommsReply("Survive Exuari offensive", function()
				setCommsMessage("The Exuari launch their invasion offensive. You must survive their attack. You will have a limited amount of time during which you must survive")
				playVoice("Hayden06")
				addCommsReply("15 minutes", function()
					plot1 = survive
					playWithTimeLimit = true
					gameTimeLimit = 15*60
					setCommsMessage("The countdown has begun")
					playVoice("Hayden07")
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("30 minutes", function()
					plot1 = survive
					playWithTimeLimit = true
					gameTimeLimit = 30*60
					setCommsMessage("The countdown has begun")
					playVoice("Hayden07")
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("45 minutes", function()
					plot1 = survive
					playWithTimeLimit = true
					gameTimeLimit = 45*60
					setCommsMessage("The countdown has begun")
					playVoice("Hayden07")
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("Back",commsStation)
			end)
			addCommsReply("Stand down", function()
				setCommsMessage("Congratulations and thank you")
				playVoice("Hayden08")
				showEndStats()
				victory("Human Navy")
			end)
			addCommsReply("Back", commsStation)
		end)
	end
	if comms_target == belt1Stations[5] and plot1 == checkOrbitingArtifactEvents and not astronomerBoardedShip then
		addCommsReply("Pick up astronomer Polly Hobbs", function()
			setCommsMessage("[Polly Hobbs] Thank you for picking me up. I found the source of the anomalous readings near the end of the inner solar asteroid belt. I've brought specialized scanning instruments, but they must be closer than 1 unit to be effective. Also, we will need baseline scan data from your ship's instruments")
			playVoice("Polly03")
			primaryOrders = "Bring astronomer Polly Hobbs close to artifact for additional sensor readings"
			astronomerBoardedShip = true
			comms_source.astronomer = true
			addCommsReply("Back", commsStation)
		end)
	end
	if comms_target == belt1Stations[2] and plot1 == checkTransportPrimusResearcherEvents and not researcherBoardedShip then
		addCommsReply("Pick up planetologist", function()
			setCommsMessage("I'm not sure he's ready. He's not at the dock ready to board or in the transporter room. Our station is undergoing repairs, so several systems are offline")
			addCommsReply("Look for planetologist", function()
				setCommsMessage("The likeliest places to find him are his quarters, the lab or the observation lounge")
				addCommsReply("Try his quarters", function()
					if lastLocationPlanetologist == "his quarters" then
						planetologistChase = planetologistChase + 1
					else
						planetologistChase = 0
					end
					if random(1,5) + planetologistChase > 4 then
						setCommsMessage("[Enrique Flogistan] Yes? What can I do for you? Please be quick about it, I'm in a bit of a hurry")
						playVoice("Enrique01")
						addCommsReply(string.format("Ready to begin your observations of %s?",planetPrimus:getCallSign()), function()
							if random(1,100) < 50 then
								lastLocationPlanetologist = "the lab"
								playVoice("Enrique02")
							else
								lastLocationPlanetologist = "the observation lounge"
								playVoice("Enrique03")
							end
							setCommsMessage("[Enrique Flogistan] Almost. Let me grab something from " .. lastLocationPlanetologist)
							addCommsReply("Back", commsStation)
						end)
						addCommsReply(string.format("We are here to transport you to %s",primusStation:getCallSign()), function()
							if random(1,100) < 50 then
								lastLocationPlanetologist = "the lab"
							else
								lastLocationPlanetologist = "the observation lounge"
							end
							setCommsMessage("[Enrique Flogistan] You're not my normal transport representative. Besides, I still need to pack a few things.\n\nHe heads off down the corridor towards " .. lastLocationPlanetologist)
							playVoice("Enrique04")
							addCommsReply("Back", commsStation)
						end)
						addCommsReply(string.format("My ship, %s, is here to transport you",comms_source:getCallSign()), function()
							setCommsMessage("Is your ship armed?")
							playVoice("Enrique05")
							addCommsReply("Yes, we can handle any Exuari in the area", function()
								local scurry_choice = random(1,100)
								if scurry_choice < 50 then
									lastLocationPlanetologist = "the lab"
								else
									lastLocationPlanetologist = "the observation lounge"
								end
								if random(1,5) + planetologistChase > 4 then
									setCommsMessage("Good. Let's go\n\nHe joins you as you go back to the ship")
									researcherBoardedShip = true
									comms_source.planetologistAboard = true
								else
									setCommsMessage("Good. I still need a couple of items from " .. lastLocationPlanetologist)
									if scurry_choice < 50 then
										playVoice("Enrique06")
									else
										playVoice("Enrique07")
									end
								end
								addCommsReply("Back", commsStation)
							end)
							addCommsReply("Back", commsStation)
						end)
					else
						if random(1,100) < 50 then
							lastLocationPlanetologist = "the lab"
						else
							lastLocationPlanetologist = "the observation lounge"
						end
						setCommsMessage("He's not in his quarters. His digital room assistant predicts he went to " .. lastLocationPlanetologist)
					end
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("Try the lab", function()
					if lastLocationPlanetologist == "the lab" then
						planetologistChase = planetologistChase + 1
					else
						planetologistChase = 0
					end
					if random(1,5) + planetologistChase > 4 then
						setCommsMessage("[Enrique Flogistan] Hello, welcome to the planetology lab. Can I help you?")
						playVoice("Enrique08")
						addCommsReply(string.format("Ready to go observe %s?",planetPrimus:getCallSign()), function()
							if random(1,100) < 50 then
								lastLocationPlanetologist = "his quarters"
							else
								lastLocationPlanetologist = "the observation lounge"
							end
							setCommsMessage("[Enrique Flogistan] Almost. Let me get one more thing.\n\nHe leaves the lab for " .. lastLocationPlanetologist)
							playVoice("Enrique09")
							addCommsReply("Back", commsStation)
						end)
						addCommsReply(string.format("We're ready to transport you to %s",primusStation:getCallSign()), function()
							local tech_choice = random(1,100)
							if tech_choice < 50 then
								lastLocationPlanetologist = "his quarters"
							else
								lastLocationPlanetologist = "the observation lounge"
							end
							setCommsMessage("[Enrique Flogistan] Already?!\n\nHe quickly leaves the lab. The lab technician looks over as he leaves\n\n[Lab technician] I think he's going to " .. lastLocationPlanetologist)
							playVoice("Enrique10")
							if tech_choice < 50 then
								playVoice("Rory01")
							else
								playVoice("Rory02")
							end
							addCommsReply("Back", commsStation)
						end)
						addCommsReply(string.format("%s has docked and is waiting on you",comms_source:getCallSign()), function()
							setCommsMessage("Are you aware of the Exuari that have been spotted in the area?")
							playVoice("Enrique11")
							addCommsReply("Yes, don't worry about them", function()
								if random(1,100) < 50 then
									setCommsMessage("[Enrique Flogistan] Good to know. I need to finishing packing in my quarters")
									playVoice("Enrique12")
									lastLocationPlanetologist = "his quarters"
								else
									setCommsMessage("[Enrique Flogistan] Good to know. I left some notes in the observation lounge")
									playVoice("Enrique13")
									lastLocationPlanetologist = "the observation lounge"
								end
								addCommsReply("Back", commsStation)
							end)
							addCommsReply("Back", commsStation)
						end)
					else
						if random(1,100) < 50 then
							lastLocationPlanetologist = "his quarters"
							playVoice("Rory03")
						else
							lastLocationPlanetologist = "the observation lounge"
							playVoice("Rory04")
						end
						setCommsMessage("[Lab technician] You just missed him. I think he said he was going to " .. lastLocationPlanetologist)
					end
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("Try observation lounge", function()
					if planetologistDiagnostic then print("looking in observation lounge") end
					if lastLocationPlanetologist == "the observation lounge" then
						planetologistChase = planetologistChase + 1
					else
						planetologistChase = 0
					end
					if planetologistDiagnostic then print("check previous location") end
					if random(1,5) + planetologistChase > 4 then
						if planetologistDiagnostic then print("found planetologist") end
						setCommsMessage(string.format("[Enrique Flogistan] Just take in the gorgeous view of %s from here",planetPrimus:getCallSign()))
						playVoice("Enrique14")
						addCommsReply(string.format("Ready for a closer view of %s?",planetPrimus:getCallSign()), function()
							if planetologistDiagnostic then print("closer view") end
							if random(1,100) < 50 then
								lastLocationPlanetologist = "his quarters"
							else
								lastLocationPlanetologist = "the lab"
							end
							setCommsMessage("[Enrique Flogistan] Just about. I forgot to pack something.\n\nHe leaves the observation lounge to go to " .. lastLocationPlanetologist)
							playVoice("Enrique15")
							addCommsReply("Back", commsStation)
						end)
						addCommsReply(string.format("We're ready to take you to %s",primusStation:getCallSign()), function()
							if planetologistDiagnostic then print("ready to take you") end
							if random(1,100) < 50 then
								setCommsMessage("[Enrique Flogistan] Well I'm not. I just need a few more items from my quarters")
								playVoice("Enrique16")
								lastLocationPlanetologist = "his quarters"
							else
								setCommsMessage("[Enrique Flogistan] Well I'm not. I just need a few more items from the lab")
								playVoice("Enrique17")
								lastLocationPlanetologist = "the lab"
							end
							addCommsReply("Back", commsStation)
						end)
						addCommsReply(string.format("%s has been ordered to get you to %s",comms_source:getCallSign(), primusStation:getCallSign()), function()
							if planetologistDiagnostic then print("ordered to get you") end
							setCommsMessage("I heard about your encounter with the Exuari. You know they could come back, right?")
							playVoice("Enrique18")
							addCommsReply("Certainly. We'll be ready, don't worry", function()
								if random(1,100) < 50 then
									setCommsMessage("[Enrique Flogistan] I admire your confidence. I'll get my things from my quarters")
									playVoice("Enrique19")
									lastLocationPlanetologist = "his quarters"
								else
									setCommsMessage("[Enrique Flogistan] I admire your confidence. I'll get my research material from the lab")
									playVoice("Enrique20")
									lastLocationPlanetologist = "the lab"
								end
								addCommsReply("Back", commsStation)
							end)
							addCommsReply("Back", commsStation)
						end)
					else
						if planetologistDiagnostic then print("didn't find planetologist") end
						if random(1,100) < 50 then
							lastLocationPlanetologist = "his quarters"
							playVoice("Parker01")
						else
							lastLocationPlanetologist = "the lab"
							playVoice("Parker02")
						end
						setCommsMessage("[Station repair crewman] He just left for " .. lastLocationPlanetologist)
					end
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("Back", commsStation)
			end)
			addCommsReply("Contact planetologist directly", function()
				setCommsMessage("Repair work prevents contact with individual")
				addCommsReply("Contact Enrique Flogistan's quarters", function()
					if random(1,100) < 50 then
						setCommsMessage("[Enrique Flogistan] Who is it?")
						playVoice("Enrique21")
						planetologistChase = planetologistChase + 1
						addCommsReply(string.format("This is %s. We are your transportation to %s",comms_source:getCallSign(),primusStation:getCallSign()), function()
							if random(1,100) < 50 then
								lastLocationPlanetologist = "the lab"
								playVoice("Enrique22")
							else
								lastLocationPlanetologist = "the observation lounge"
								playVoice("Enrique23")
							end
							setCommsMessage("I'm going to " .. lastLocationPlanetologist .. " before we leave")
							addCommsReply("Back", commsStation)
						end)
					else
						if lastLocationPlanetologist == "his quarters" then
							planetologistChase = planetologistChase + 1
						else
							planetologistChase = 0
						end
						setCommsMessage("No reply from Enrique Flogistan's quarters")
					end
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("Contact planetology lab", function()
					if lastLocationPlanetologist == "the lab" then
						planetologistChase = planetologistChase + 1
					else
						planetologistChase = 0
					end
					if random(1,100) < 50 then
						lastLocationPlanetologist = "his quarters"
					else
						lastLocationPlanetologist = "the observation lounge"
					end
					setCommsMessage("A lab technician answers and tells you Enrique Flogistan is probably going to " .. lastLocationPlanetologist)
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("Contact observation lounge", function()
					if lastLocationPlanetologist == "the observation lounge" then
						planetologistChase = planetologistChase + 1
					else
						planetologistChase = 0
					end
					if random(1,100) < 50 then
						lastLocationPlanetologist = "his quarters"
					else
						lastLocationPlanetologist = "the lab"
					end
					setCommsMessage("A repair crewman answers and tells you Enrique Flogistan is probably going to " .. lastLocationPlanetologist)
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("Contact station galley", function()
					planetologistChase = 0
					setCommsMessage("[Cook] Hello, who's there?")
					playVoice("Karsyn01")
					addCommsReply(string.format("I'm from %s. I'm looking for Enrique Flogistan",comms_source:getCallSign()), function()
						setCommsMessage("He was here about an hour ago. You might try his quarters, the observation lounge or the lab")
						playVoice("Karsyn02")
						addCommsReply("Back", commsStation)
					end)
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("Contact station security office", function()
					planetologistChase = 0
					setCommsMessage("[Security officer] May I help you?")
					playVoice("Taylor01")
					addCommsReply("I'm looking for Enrique Flogistan", function()
						playVoice("Taylor02")
						setCommsMessage("He's not here in the security office. Our records show he often frequents his quarters, the observation lounge and the planetology lab")
						addCommsReply("Back", commsStation)
					end)
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("Contact station maintenance office", function()
					planetologistChase = 0
					setCommsMessage("[Maintenance technician] Hi, what's broken?")
					playVoice("Quinn01")
					addCommsReply("Nothing. I'm looking for Enrique Flogistan", function()
						playVoice("Quinn02")
						setCommsMessage("He's not here. Good luck finding him")
						addCommsReply("Back", commsStation)
					end)
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("Contact station operations office", function()
					planetologistChase = 0
					setCommsMessage("[Operations manager] Yes?")
					playVoice("Avery01")
					addCommsReply("Can you help me find Enrique Flogistan?", function()
						playVoice("Avery02")
						setCommsMessage("He's not here in operations. We are short handed right now with all the repairs going on. I'm afraid you'll have to find him yourself")
						addCommsReply("Back", commsStation)
					end)
					addCommsReply("Back", commsStation)
				end)
			end)
			addCommsReply("Scan for planetologist", function()
				local scanResultChoice = math.random(1,3)
				if scanResultChoice == 1 then
					lastLocationPlanetologist = "his quarters"
				elseif scanResultChoice == 2 then
					lastLocationPlanetologist = "the lab"
				else
					lastLocationPlanetologist = "the observation lounge"
				end
				setCommsMessage(string.format("Sensors show him in %s",lastLocationPlanetologist))
				addCommsReply(string.format("Beam him over from %s",lastLocationPlanetologist), function()
					if random(1,100) < 5 then
						setCommsMessage("He has been beamed aboard")
						researcherBoardedShip = true
						comms_source.planetologistAboard = true
					else
						setCommsMessage("Interference from station repairs prevents a transporter lock")
						planetologistChase = 0
					end
					addCommsReply("Back", commsStation)
				end)
			end)
			addCommsReply("Back", commsStation)
		end)
	end
	if comms_target == secondusStations[1] and plot1 == checkFixSatelliteEvents and not comms_target.satelliteFixed then
		addCommsReply("Satellite problems?", function()
			setCommsMessage(string.format("Yes. Our technicians have tracked back the problem to a faulty relay module. However, They are unable to fix it with available parts. They need %s. They've requested delivery, but hear it will take weeks before the next delivery cycle. I don't suppose you could bring us what we need?",comms_target.satelliteFixGood))
			playVoice("Ellis01")
			local playerCallSign = comms_source:getCallSign()
			local ctd = comms_target.comms_data
			if fixSatelliteDiagnostic then print("satellite fix good 1: " .. comms_target.satelliteFixGood) end
			if fixSatelliteDiagnostic then 
				if comms_source.goods[ctd.satelliteFixGood] == nil then
					print("related player good: nil")
				else
					print("related player good: " .. comms_source.goods[ctd.satelliteFixGood])
				end
			end 
			if comms_source.goods[comms_target.satelliteFixGood] ~= nil and comms_source.goods[comms_target.satelliteFixGood] > 0 then
				addCommsReply(string.format("Provide %s",comms_target.satelliteFixGood), function()
					comms_source.goods[comms_target.satelliteFixGood] = comms_source.goods[comms_target.satelliteFixGood] - 1
					comms_source.cargo = comms_source.cargo + 1
					comms_target.satelliteFixed = true
					setCommsMessage("Thanks. With your help, we fixed the faulty relay module")
					playVoice("Ellis02")
					comms_source:addReputationPoints(75 - (30*difficulty))
					addCommsReply("Back", commsStation)
				end)
			end
			addCommsReply("Back", commsStation)
		end)
	end
	if comms_target == secondusStations[2] and plot1 == checkFixSatelliteEvents and not comms_target.satelliteFixed then
		addCommsReply("Having satellite trouble?", function()
			playVoice("Peyton01")
			setCommsMessage(string.format("It seems we've got an outdated servo motor. Replacement will take time. Our repairman says he can fix it with %s, so we don't have to wait. Do you have any?",comms_target.satelliteFixGood))
			local playerCallSign = comms_source:getCallSign()
			local ctd = comms_target.comms_data
			if fixSatelliteDiagnostic then print("satellite fix good 2: " .. comms_target.satelliteFixGood) end
			if fixSatelliteDiagnostic then 
				if comms_source.goods[comms_target.satelliteFixGood] == nil then
					print("related player good: nil")
				else
					print("related player good: " .. comms_source.goods[comms_target.satelliteFixGood])
				end
			end 
			if comms_source.goods[comms_target.satelliteFixGood] ~= nil and comms_source.goods[comms_target.satelliteFixGood] > 0 then
				addCommsReply(string.format("Give %s to %s",comms_target.satelliteFixGood, comms_target:getCallSign()), function()
					comms_source.goods[comms_target.satelliteFixGood] = comms_source.goods[comms_target.satelliteFixGood] - 1
					comms_source.cargo = comms_source.cargo + 1
					comms_target.satelliteFixed = true
					playVoice("Peyton02")
					setCommsMessage("That worked. Thanks")
					comms_source:addReputationPoints(75 - (30*difficulty))
					addCommsReply("Back", commsStation)
				end)
			end
			addCommsReply("Back", commsStation)
		end)
	end
	if comms_target == secondusStations[3] and plot1 == checkFixSatelliteEvents and not comms_target.satelliteFixed then
		addCommsReply("Can we help with your satellite?", function()
			playVoice("Reese01")
			setCommsMessage(string.format("Only if you've got %s aboard your ship. Otherwise, we're stuck",comms_target.satelliteFixGood))
			local playerCallSign = comms_source:getCallSign()
			local ctd = comms_target.comms_data
			if fixSatelliteDiagnostic then print("satellite fix good 3: " .. comms_target.satelliteFixGood) end
			if fixSatelliteDiagnostic then 
				if comms_source.goods[comms_target.satelliteFixGood] == nil then
					print("related player good: nil")
				else
					print("related player good: " .. comms_source.goods[comms_target.satelliteFixGood])
				end
			end 
			if comms_source.goods[comms_target.satelliteFixGood] ~= nil and comms_source.goods[comms_target.satelliteFixGood] > 0 then
				addCommsReply(string.format("Provide %s",comms_target.satelliteFixGood), function()
					comms_source.goods[comms_target.satelliteFixGood] = comms_source.goods[comms_target.satelliteFixGood] - 1
					comms_source.cargo = comms_source.cargo + 1
					comms_target.satelliteFixed = true
					playVoice("Reese02")
					setCommsMessage("You have saved us a tremendous headache. We thought we'd have to wait two months before we could fix the problem. Thanks")
					comms_source:addReputationPoints(75 - (30*difficulty))
					addCommsReply("Back", commsStation)
				end)
			end
			addCommsReply("Back", commsStation)
		end)
	end
	if stationCommsDiagnostic then print(ctd.public_relations) end
	if ctd.public_relations then
		addCommsReply("Tell me more about your station", function()
			setCommsMessage("What would you like to know?")
			addCommsReply("General information", function()
				setCommsMessage(ctd.general_information)
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
					if random(1,100) < (100 - (30 * (difficulty - .5))) then
						addCommsReply("Gossip", function()
							setCommsMessage(ctd.gossip)
							addCommsReply("Back", commsStation)
						end)
					end
				end
			end
		end)	--end station info comms reply branch
	end	--end public relations if branch
	if stationCommsDiagnostic then print(ctd.character) end
	if ctd.character ~= nil then
		addCommsReply(string.format("Tell me about %s",ctd.character), function()
			if ctd.characterDescription ~= nil then
				setCommsMessage(ctd.characterDescription)
			else
				if ctd.characterDeadEnd == nil then
					local deadEndChoice = math.random(1,5)
					if deadEndChoice == 1 then
						ctd.characterDeadEnd = "Never heard of " .. ctd.character
					elseif deadEndChoice == 2 then
						ctd.characterDeadEnd = ctd.character .. " died last week. The funeral was yesterday"
					elseif deadEndChoice == 3 then
						ctd.characterDeadEnd = string.format("%s? Who's %s? There's nobody here named %s",ctd.character,ctd.character,ctd.character)
					elseif deadEndChoice == 4 then
						ctd.characterDeadEnd = string.format("We don't talk about %s. They are gone and good riddance",ctd.character)
					else
						ctd.characterDeadEnd = string.format("I think %s moved away",ctd.character)
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
			addCommsReply("Back", commsStation)
		end)
	end
	if speed_adjust_count == nil then
		speed_adjust_count = 0
	end
	if random(1,100) < (80 - (speed_adjust_count * 10)) then
		addCommsReply("Request access to isolated transporter pad", function()
			setCommsMessage("That will damage your reputation. Do you wish to proceed?")
			addCommsReply("Proceed regardless of the reputation cost",function()
				local p = getPlayerShip(-1)
				p:takeReputationPoints(math.floor(p:getReputationPoints()/2))
				setCommsMessage("You are transported to an unknown location. A small man in front of a vast array of virtual monitors showing constantly changing pictures of different planetary systems asks you what you want")
				addCommsReply(string.format("Slow orbital speed of %s",planetPrimus:getCallSign()),function()
					planetPrimus.orbit_speed = planetPrimus.orbit_speed * 1.1
					planetPrimus:setOrbit(planetSol,planetPrimus.orbit_speed)
					speed_adjust_count = speed_adjust_count + 1
					setCommsMessage("He twists a small dial and says, 'Done.'")
					playVoice("Ozzie01")
				end)
				addCommsReply(string.format("Slow orbital speed of the moon orbiting %s",planetPrimus:getCallSign()),function()
					planetPrimusMoonOrbitTime = planetPrimusMoonOrbitTime * 1.1
					planetPrimusMoon:setOrbit(planetPrimus,planetPrimusMoonOrbitTime)
					speed_adjust_count = speed_adjust_count + 1
					setCommsMessage("He moves a slider and says, 'Ok.'")
					playVoice("Ozzie02")
				end)
				addCommsReply(string.format("Slow orbital speed of %s",planetSecondus:getCallSign()),function()
					planetSecondus.orbit_speed = planetSecondus.orbit_speed * 1.1
					planetSecondus:setOrbit(planetSol,planetSecondus.orbit_speed)
					speed_adjust_count = speed_adjust_count + 1
					setCommsMessage("He types in a couple of numbers and says, 'Happy?'")
					playVoice("Ozzie03")
				end)
				addCommsReply(string.format("Slow orbital speed of stations orbiting %s",planetSecondus:getCallSign()),function()
					secondusStationOrbitIncrement = secondusStationOrbitIncrement * .9
					speed_adjust_count = speed_adjust_count + 1
					setCommsMessage("He flips a couple of switches and says, 'I love programmable stations'")
					playVoice("Ozzie04")
				end)
				addCommsReply(string.format("Slow orbital speed of the inner belt around %s",planetSol:getCallSign()),function()
					belt1OrbitalSpeed = belt1OrbitalSpeed * .9
					for i=1,#beltAsteroidList do
						local ta = beltAsteroidList[i]
						if ta ~= nil and ta:isValid() and ta.belt_id == "belt1" then
							ta.speed = belt1OrbitalSpeed
						end
					end
					speed_adjust_count = speed_adjust_count + 1
					setCommsMessage("He rubs one of the monitors a bit and says 'that should do it.'")
					playVoice("Ozzie05")
				end)
				addCommsReply(string.format("Slow orbital speed of the outer belt around %s",planetSol:getCallSign()),function()
					belt2OrbitalSpeed = belt2OrbitalSpeed * .9
					for i=1,#beltAsteroidList do
						local ta = beltAsteroidList[i]
						if ta ~= nil and ta:isValid() and ta.belt_id == "belt2" then
							ta.speed = belt2OrbitalSpeed
						end
					end
					speed_adjust_count = speed_adjust_count + 1
					setCommsMessage("He says, 'if you insist' and opens a small panel in the wall and enters a code on a keypad.")
					playVoice("Ozzie06")
				end)
				addCommsReply(string.format("Slow orbital speed of %s",planetTertius:getCallSign()),function()
					planetTertius.orbit_speed = planetTertius.orbit_speed * 1.1
					planetTertius:setOrbit(planetSol,planetTertius.orbit_speed)
					speed_adjust_count = speed_adjust_count + 1
					setCommsMessage("He sighs, stands up, grabs a large lever and pulls it about two inches towards him then says, 'there.'")
					playVoice("Ozzie07")
				end)
				addCommsReply(string.format("Slow orbital speed of the inner belt around %s",planetTertius:getCallSign()),function()
					tertiusOrbitalBodyIncrement = tertiusOrbitalBodyIncrement * .9
					for i=1,#tertiusAsteroids do
						local ta = tertiusAsteroids[i]
						if ta ~= nil and ta:isValid() and ta.belt_id == "tMoonBelt" then
							ta.speed = tertiusOrbitalBodyIncrement
						end
					end
					speed_adjust_count = speed_adjust_count + 1
					setCommsMessage("He pulls a keyboard out from under his desk, types a couple of things and says, 'Alright.'")
					playVoice("Ozzie08")
				end)
				addCommsReply(string.format("Slow orbital speed of the outer belt around %s",planetTertius:getCallSign()),function()
					tertiusAsteroidBeltIncrement = tertiusAsteroidBeltIncrement * .9
					for i=1,#tertiusAsteroids do
						local ta = tertiusAsteroids[i]
						if ta ~= nil and ta:isValid() and ta.belt_id == "tBelt2" then
							ta.speed = tertiusAsteroidBeltIncrement
						end
					end
					for i=1,#tertiusAsteroidStations do
						local tbs = tertiusAsteroidStations[i]
						if tbs ~= nil and tbs:isValid() then
							tbs.speed = tertiusAsteroidBeltIncrement
						end
					end
					speed_adjust_count = speed_adjust_count + 1
					setCommsMessage("He dons a couple of purple haptic gloves, makes a couple of arcane gestures and says, 'You asked for it.'")
					playVoice("Ozzie09")
				end)
			end)
		end)
	end
	if comms_source:isFriendly(comms_target) then
		if plot1 == checkTransportPrimusResearcherEvents and not researcherBoardedShip then
			addCommsReply(string.format("Where is %s? (cost 10 reputation)",belt1Stations[2]:getCallSign()), function()
				if comms_source:takeReputationPoints(10) then
					if difficulty <= 1 then
						setCommsMessage(string.format("%s is near %s",belt1Stations[2]:getCallSign(),belt1Stations[1]:getCallSign()))
					else
						setCommsMessage(string.format("%s is along the inner solar asteroid belt",belt1Stations[2]))
					end
				else
					setCommsMessage("Not enough reputation")
				end
				addCommsReply("Back", commsStation)
			end)
		end
		addCommsReply("What are my current orders?", function()
			setOptionalOrders()
			setSecondaryOrders()
			ordMsg = primaryOrders .. "\n" .. secondaryOrders .. optionalOrders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format("\n   %i Minutes remain in game",math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
			addCommsReply("Back", commsStation)
		end)
		if math.random(1,5) <= (3 - difficulty) then
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
		if comms_source.initialCoolant ~= nil then
			if math.random(1,5) <= (3 - difficulty) then
				local coolantCost = math.random(45,90)
				if comms_source:getMaxCoolant() < comms_source.initialCoolant then
					coolantCost = math.random(30,60)
				end
				addCommsReply(string.format("Purchase coolant for %i reputation",coolantCost), function()
					if not comms_source:takeReputationPoints(coolantCost) then
						setCommsMessage("Insufficient reputation")
					else
						comms_source:setMaxCoolant(comms_source:getMaxCoolant() + 2)
						setCommsMessage("Additional coolant purchased")
					end
					addCommsReply("Back", commsStation)
				end)
			end
		end
		showCurrentStats()
	else	--neutral 
		if math.random(1,5) <= (3 - difficulty) then
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
				addCommsReply("Back", commsStation)
			end)
		end
		if comms_source.initialCoolant ~= nil then
			if math.random(1,5) <= (3 - difficulty) then
				local coolantCost = math.random(60,120)
				if comms_source:getMaxCoolant() < comms_source.initialCoolant then
					coolantCost = math.random(45,90)
				end
				addCommsReply(string.format("Purchase coolant for %i reputation",coolantCost), function()
					if not comms_source:takeReputationPoints(coolantCost) then
						setCommsMessage("Insufficient reputation")
					else
						comms_source:setMaxCoolant(comms_source:getMaxCoolant() + 1)
						setCommsMessage("Additional coolant purchased")
					end
					addCommsReply("Back", commsStation)
				end)
			end
		end
	end	--end friendly/neutral 
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
									if obj.comms_data.orbit ~= nil then
										brochure_stations = string.format("%s %s",brochure_stations,obj.comms_data.orbit)
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
									if obj.comms_data.orbit ~= nil then
										station_details = string.format("%s %s",station_details,obj.comms_data.orbit)
									end
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
							if obj.comms_data.orbit ~= nil then
								station_details = string.format("%s %s",station_details,obj.comms_data.orbit)
							end
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
			local goodCount = 0
			if comms_source.goods ~= nil then
				for good, goodQuantity in pairs(comms_source.goods) do
					goodCount = goodCount + 1
					goodsReport = goodsReport .. string.format("     %s: %i\n",good,goodQuantity)
				end
			end
			if goodCount < 1 then
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
					if comms_source.goods[good] ~= nil and comms_source.goods[good] > 0 then
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
			if ctd.trade.food and comms_source.goods ~= nil and comms_source.goods.food ~= nil and comms_source.goods.food.quantity > 0 then
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
			if ctd.trade.medicine and comms_source.goods ~= nil and comms_source.goods.medicine ~= nil and comms_source.goods.medicine.quantity > 0 then
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
			if ctd.trade.luxury and comms_source.goods ~= nil and comms_source.goods.luxury ~= nil and comms_source.goods.luxury.quantity > 0 then
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
		addCommsReply("No tutorial covered goods or cargo. Explain", function()
			setCommsMessage("Different types of cargo or goods may be obtained from stations, freighters or other sources. They go by one word descriptions such as dilithium, optic, warp, etc. Certain mission goals may require a particular type or types of cargo. Each player ship differs in cargo carrying capacity. Goods may be obtained by spending reputation points or by trading other types of cargo (typically food, medicine or luxury)")
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
								if obj.comms_data.orbit ~= nil then
									station_details = string.format("%s %s",station_details,obj.comms_data.orbit)
								end
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
								if obj.comms_data.orbit ~= nil then
									station_details = string.format("%s\nNote: this waypoint will be out of date shortly since %s is in motion",station_details,obj:getCallSign())
								end
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
					if obj.comms_data.orbit ~= nil then
						station_details = string.format("%s %s",station_details,obj.comms_data.orbit)
					end
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
					if obj.comms_data.orbit ~= nil then
						station_details = string.format("%s\nNote: this waypoint will be out of date shortly since %s is in motion",station_details,obj:getCallSign())
					end
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
function getCartographerCost(service)
	local base_cost = 1
	if service == "apprentice" then
		base_cost = 5
	elseif service == "master" then
		base_cost = 10
	end
	return math.ceil(base_cost * comms_data.reputation_cost_multipliers[getFriendStatus()])
end
function showCurrentStats()
	local stats_exist = false
	if #humanStationDestroyedNameList ~= nil and #humanStationDestroyedNameList > 0 then
		stats_exist = true
	end
	if #neutralStationDestroyedNameList ~= nil and #neutralStationDestroyedNameList > 0 then
		stats_exist = true
	end
	if #kraylorVesselDestroyedNameList ~= nil and #kraylorVesselDestroyedNameList > 0 then
		stats_exist = true
	end
	if #exuariVesselDestroyedNameList ~= nil and #exuariVesselDestroyedNameList > 0 then
		stats_exist = true
	end
	if #arlenianVesselDestroyedNameList ~= nil and #arlenianVesselDestroyedNameList > 0 then
		stats_exist = true
	end
	if stats_exist then
		addCommsReply("Show me the current statistics, please", function()
			setCommsMessage("What would you like statistics on?")
			if #humanStationDestroyedNameList ~= nil and #humanStationDestroyedNameList > 0 then
				addCommsReply("Human Stations Destroyed",function()
					local human_station_stats = ""
					local station_strength = 0
					for i=1,#humanStationDestroyedNameList do
						human_station_stats = human_station_stats .. string.format("\n%s, %i",humanStationDestroyedNameList[i],humanStationDestroyedValue[i])
						station_strength = station_strength + humanStationDestroyedValue[i]
					end
					human_station_stats = string.format("Count: %i, Total strength: %i\n   Station Name, Strength",#humanStationDestroyedNameList,station_strength) .. human_station_stats
					setCommsMessage(human_station_stats)
					addCommsReply("Back", commsStation)
				end)
			end
			if #neutralStationDestroyedNameList ~= nil and #neutralStationDestroyedNameList > 0 then
				addCommsReply("Neutral Stations Destroyed",function()
					local neutral_station_stats = ""
					local station_strength = 0
					for i=1,#neutralStationDestroyedNameList do
						neutral_station_stats = neutral_station_stats .. string.format("\n%s, %i",neutralStationDestroyedNameList[i],neutralStationDestroyedValue[i])
						station_strength = station_strength + neutralStationDestroyedValue[i]
					end
					neutral_station_stats = string.format("Count: %i, Total strength: %i\n   Station Name, Strength",#neutralStationDestroyedNameList,station_strength) .. neutral_station_stats
					setCommsMessage(neutral_station_stats)
					addCommsReply("Back", commsStation)
				end)
			end
			if #kraylorVesselDestroyedNameList ~= nil and #kraylorVesselDestroyedNameList > 0 then
				addCommsReply("Kraylor Vessels Destroyed",function()
					local vessel_stats = ""
					local vessel_strength = 0
					for i=1,#kraylorVesselDestroyedNameList do
						vessel_stats = vessel_stats .. string.format("\n%s, %s, %i",kraylorVesselDestroyedNameList[i],kraylorVesselDestroyedType[i],kraylorVesselDestroyedValue[i])
						vessel_strength = vessel_strength + kraylorVesselDestroyedValue[i]
					end
					vessel_stats = string.format("Count: %i, Total strength: %i\n   Vessel Name, Type, Strength",#kraylorVesselDestroyedNameList,vessel_strength) .. vessel_stats
					setCommsMessage(vessel_stats)
					addCommsReply("Back", commsStation)
				end)
			end
			if #exuariVesselDestroyedNameList ~= nil and #exuariVesselDestroyedNameList > 0 then
				addCommsReply("Exuari Vessels Destroyed",function()
					local vessel_stats = ""
					local vessel_strength = 0
					for i=1,#exuariVesselDestroyedNameList do
						vessel_stats = vessel_stats .. string.format("\n%s, %s, %i",exuariVesselDestroyedNameList[i],exuariVesselDestroyedType[i],exuariVesselDestroyedValue[i])
						vessel_strength = vessel_strength + exuariVesselDestroyedValue[i]
					end
					vessel_stats = string.format("Count: %i, Total strength: %i\n   Vessel Name, Type, Strength",#exuariVesselDestroyedNameList,vessel_strength) .. vessel_stats
					setCommsMessage(vessel_stats)
					addCommsReply("Back", commsStation)
				end)
			end
			if #arlenianVesselDestroyedNameList ~= nil and #arlenianVesselDestroyedNameList > 0 then
				addCommsReply("Arlenian Vessels Destroyed",function()
					local vessel_stats = ""
					local vessel_strength = 0
					for i=1,#arlenianVesselDestroyedNameList do
						vessel_stats = vessel_stats .. string.format("\n%s, %s, %i",arlenianVesselDestroyedNameList[i],arlenianVesselDestroyedType[i],arlenianVesselDestroyedValue[i])
						vessel_strength = vessel_strength + arlenianVesselDestroyedValue[i]
					end
					vessel_stats = string.format("Count: %i, Total strength: %i\n   Vessel Name, Type, Strength",#arlenianVesselDestroyedNameList,vessel_strength) .. vessel_stats
					setCommsMessage(vessel_stats)
					addCommsReply("Back", commsStation)
				end)
			end
			addCommsReply("Missions completed",function()
				if mission_complete_count > 0 then
					setCommsMessage(string.format("Missions completed so far: %i",mission_complete_count))
				else
					setCommsMessage("No missions completed yet")
				end
				addCommsReply("Back", commsStation)
			end)
			addCommsReply("Back", commsStation)
		end)
	end
end
function setOptionalOrders()
	optionalOrders = ""
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
		if comms_source:getReputationPoints() > points_per_item * item_amount then
			if comms_source:takeReputationPoints(points_per_item * item_amount) then
				comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + item_amount)
				if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
					setCommsMessage("You are fully loaded and ready to explode things.")
				else
					setCommsMessage("We generously resupplied you with some weapon charges.\nPut them to good use.")
				end
			else
				setCommsMessage("Not enough reputation.")
				return
			end
		else
			if comms_source:getReputationPoints() > points_per_item then
				setCommsMessage("You can't afford as much as I'd like to give you")
				addCommsReply("Get just one", function()
					if comms_source:takeReputationPoints(points_per_item) then
						comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + 1)
						if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
							setCommsMessage("You are fully loaded and ready to explode things.")
						else
							setCommsMessage("We generously resupplied you with one weapon charge.\nPut it to good use.")
						end
					else
						setCommsMessage("Not enough reputation.")
					end
					return
				end)
			else
				setCommsMessage("Not enough reputation.")
				return				
			end
		end
        addCommsReply("Back", commsStation)
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
        oMsg = "Good day, officer.\nIf you need supplies, please dock with us first."
    else
        oMsg = "Greetings.\nIf you want to do business, please dock with us first."
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. "\nBe aware that if enemies in the area get much closer, we will be too busy to conduct business with you."
	end
	setCommsMessage(oMsg)
	if comms_target == belt1Stations[5] and plot1 == checkOrbitingArtifactEvents and not astronomerBoardedShip then
		addCommsReply("Contact astronomer Polly Hobbs", function()
			setCommsMessage("[Polly Hobbs] I've constructed a sensitive scanning device to gather additional data. However, the device needs to be much closer. Can you transport me closer to the location of the readings?")
			playVoice("Polly02")
			addCommsReply("Back", commsStation)
		end)
	end
 	addCommsReply("I need information", function()
		setCommsMessage("What kind of information do you need?")
		if stationCommsDiagnostic then print("requesting information") end
		local ctd = comms_target.comms_data
		if stationCommsDiagnostic then print(ctd.character) end
		if ctd.character ~= nil then
			addCommsReply(string.format("Tell me about %s",ctd.character), function()
				if ctd.characterDescription ~= nil then
					setCommsMessage(ctd.characterDescription)
				else
					if ctd.characterDeadEnd == nil then
						local deadEndChoice = math.random(1,5)
						if deadEndChoice == 1 then
							ctd.characterDeadEnd = "Never heard of " .. ctd.character
						elseif deadEndChoice == 2 then
							ctd.characterDeadEnd = ctd.character .. " died last week. The funeral was yesterday"
						elseif deadEndChoice == 3 then
							ctd.characterDeadEnd = string.format("%s? Who's %s? There's nobody here named %s",ctd.character,ctd.character,ctd.character)
						elseif deadEndChoice == 4 then
							ctd.characterDeadEnd = string.format("We don't talk about %s. They are gone and good riddance",ctd.character)
						else
							ctd.characterDeadEnd = string.format("I think %s moved away",ctd.character)
						end
					end
					setCommsMessage(ctd.characterDeadEnd)
				end
				addCommsReply("Back", commsStation)
			end)
		end
	    if comms_source:isFriendly(comms_target) then
			addCommsReply("What are my current orders?", function()
				setOptionalOrders()
				setSecondaryOrders()
				ordMsg = primaryOrders .. "\n" .. secondaryOrders .. optionalOrders
				if playWithTimeLimit then
					ordMsg = ordMsg .. string.format("\n   %i Minutes remain in game",math.floor(gameTimeLimit/60))
				end
				setCommsMessage(ordMsg)
				addCommsReply("Back", commsStation)
			end)
			showCurrentStats()
		end
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
		if ctd.goods ~= nil then
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
		addCommsReply("Where can I find particular goods?", function()
			local ctd = comms_target.comms_data
			gkMsg = "Friendly stations often have food or medicine or both. Neutral stations may trade their goods for food, medicine or luxury."
			if ctd.goodsKnowledge == nil then
				ctd.goodsKnowledge = {}
				local knowledgeCount = 0
				local knowledgeMax = 10
				for i=1,#humanStationList do
					local station = humanStationList[i]
					if station ~= nil and station:isValid() then
						local brainCheckChance = 60
						if distance(comms_target,station) > 75000 then
							brainCheckChance = 20
						end
						for good, goodData in pairs(ctd.goods) do
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
		if ctd.public_relations then
			addCommsReply("Tell me more about your station", function()
				local ctd = comms_target.comms_data
				setCommsMessage("What would you like to know?")
				addCommsReply("General information", function()
					setCommsMessage(ctd.general_information)
					addCommsReply("Back", commsStation)
				end)
				if ctd.history ~= nil then
					addCommsReply("Station history", function()
						setCommsMessage(ctd.history)
						addCommsReply("Back", commsStation)
					end)
				end
				if ctd.gossip ~= nil then
					if random(1,100) < 80 then
						addCommsReply("Gossip", function()
							setCommsMessage(ctd.gossip)
							addCommsReply("Back", commsStation)
						end)
					end
				end
			end)	--end station info comms reply branch
		end	--end public relations if branch
		addCommsReply("Report status", function()
			msg = "Hull: " .. math.floor(comms_target:getHull() / comms_target:getHullMax() * 100) .. "%\n"
			local shields = comms_target:getShieldCount()
			if shields == 1 then
				msg = msg .. "Shield: " .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
			else
				for n=0,shields-1 do
					msg = msg .. "Shield " .. n .. ": " .. math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100) .. "%\n"
				end
			end			
			setCommsMessage(msg);
			addCommsReply("Back", commsStation)
		end)
	end)
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
        addCommsReply("Please send Adder MK5 reinforcements! ("..getServiceCost("reinforcements").."rep)", function()
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage("You need to set a waypoint before you can request reinforcements.");
            else
                setCommsMessage("To which waypoint should we dispatch the reinforcements?");
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
						if comms_source:takeReputationPoints(getServiceCost("reinforcements")) then
							ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
							ship:setCommsScript(""):setCommsFunction(commsShip):onDestruction(humanVesselDestroyed)
							table.insert(friendlyHelperFleet,ship)
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
        addCommsReply("Please send Phobos T3 reinforcements! ("..getServiceCost("phobosReinforcements").."rep)", function()
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage("You need to set a waypoint before you can request reinforcements.");
            else
                setCommsMessage("To which waypoint should we dispatch the reinforcements?");
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
						if comms_source:takeReputationPoints(getServiceCost("phobosReinforcements")) then
							ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Phobos T3"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
							ship:setCommsScript(""):setCommsFunction(commsShip):onDestruction(humanVesselDestroyed)
							table.insert(friendlyHelperFleet,ship)
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
        addCommsReply("Please send Stalker Q7 reinforcements! ("..getServiceCost("stalkerReinforcements").."rep)", function()
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage("You need to set a waypoint before you can request reinforcements.");
            else
                setCommsMessage("To which waypoint should we dispatch the reinforcements?");
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
						if comms_source:takeReputationPoints(getServiceCost("stalkerReinforcements")) then
							ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Stalker Q7"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
							ship:setCommsScript(""):setCommsFunction(commsShip):onDestruction(humanVesselDestroyed)
							table.insert(friendlyHelperFleet,ship)
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
	local knowledgeCount = 0
	local knowledgeMax = 10
	for sti=1,#humanStationList do
		if humanStationList[sti] ~= nil and humanStationList[sti]:isValid() then
			if distance(comms_target,humanStationList[sti]) < 75000 then
				brainCheck = 3
			else
				brainCheck = 1
			end
			for gi=1,#goods[humanStationList[sti]] do
				if random(1,10) <= brainCheck then
					table.insert(comms_target.goodsKnowledge,humanStationList[sti]:getCallSign())
					table.insert(comms_target.goodsKnowledgeSector,humanStationList[sti]:getSectorName())
					table.insert(comms_target.goodsKnowledgeType,goods[humanStationList[sti]][gi][1])
					tradeString = ""
					stationTrades = false
					if tradeMedicine[humanStationList[sti]] ~= nil then
						tradeString = " and will trade it for medicine"
						stationTrades = true
					end
					if tradeFood[humanStationList[sti]] ~= nil then
						if stationTrades then
							tradeString = tradeString .. " or food"
						else
							tradeString = tradeString .. " and will trade it for food"
							stationTrades = true
						end
					end
					if tradeLuxury[humanStationList[sti]] ~= nil then
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
    if comms_source:isFriendly(comms_target) then
        return "friend"
    else
        return "neutral"
    end
end
-------------------------
-- Ship communication  --
-------------------------
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
		local shields = comms_target:getShieldCount()
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
	if comms_target.fleet ~= nil then
		addCommsReply(string.format("Direct %s",comms_target.fleet), function()
			setCommsMessage(string.format("What command should be given to %s?",comms_target.fleet))
			addCommsReply("Report hull and shield status", function()
				msg = "Fleet status:"
				for _, fleetShip in ipairs(friendlyDefensiveFleetList[comms_target.fleet]) do
					if fleetShip ~= nil and fleetShip:isValid() then
						msg = msg .. "\n  " .. fleetShip:getCallSign() .. ":"
						msg = msg .. "\n    Hull: " .. math.floor(fleetShip:getHull() / fleetShip:getHullMax() * 100) .. "%"
						local shields = fleetShip:getShieldCount()
						if shields == 1 then
							msg = msg .. "\n    Shield: " .. math.floor(fleetShip:getShieldLevel(0) / fleetShip:getShieldMax(0) * 100) .. "%"
						else
							msg = msg .. "\n    Shields: "
							if shields == 2 then
								msg = msg .. "Front:" .. math.floor(fleetShip:getShieldLevel(0) / fleetShip:getShieldMax(0) * 100) .. "% Rear:" .. math.floor(fleetShip:getShieldLevel(1) / fleetShip:getShieldMax(1) * 100) .. "%"
							else
								for n=0,shields-1 do
									msg = msg .. " " .. n .. ":" .. math.floor(fleetShip:getShieldLevel(n) / fleetShip:getShieldMax(n) * 100) .. "%"
								end
							end
						end
					end
				end
				setCommsMessage(msg)
				addCommsReply("Back", commsShip)
			end)
			addCommsReply("Report missile status", function()
				msg = "Fleet missile status:"
				for _, fleetShip in ipairs(friendlyDefensiveFleetList[comms_target.fleet]) do
					if fleetShip ~= nil and fleetShip:isValid() then
						msg = msg .. "\n  " .. fleetShip:getCallSign() .. ":"
						local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
						missileMsg = ""
						for _, missile_type in ipairs(missile_types) do
							if fleetShip:getWeaponStorageMax(missile_type) > 0 then
								missileMsg = missileMsg .. "\n      " .. missile_type .. ": " .. math.floor(fleetShip:getWeaponStorage(missile_type)) .. "/" .. math.floor(fleetShip:getWeaponStorageMax(missile_type))
							end
						end
						if missileMsg ~= "" then
							msg = msg .. "\n    Missiles: " .. missileMsg
						end
					end
				end
				setCommsMessage(msg)
				addCommsReply("Back", commsShip)
			end)
			addCommsReply("Assist me", function()
				for _, fleetShip in ipairs(friendlyDefensiveFleetList[comms_target.fleet]) do
					if fleetShip ~= nil and fleetShip:isValid() then
						fleetShip:orderDefendTarget(comms_source)
					end
				end
				setCommsMessage(string.format("%s heading toward you to assist",comms_target.fleet))
				addCommsReply("Back", commsShip)
			end)
			addCommsReply("Defend a waypoint", function()
				if comms_source:getWaypointCount() == 0 then
					setCommsMessage("No waypoints set. Please set a waypoint first.");
					addCommsReply("Back", commsShip)
				else
					setCommsMessage("Which waypoint should we defend?");
					for n=1,comms_source:getWaypointCount() do
						addCommsReply("Defend WP" .. n, function()
							for _, fleetShip in ipairs(friendlyDefensiveFleetList[comms_target.fleet]) do
								if fleetShip ~= nil and fleetShip:isValid() then
									fleetShip:orderDefendLocation(comms_source:getWaypoint(n))
								end
							end
							setCommsMessage("We are heading to assist at WP" .. n ..".");
							addCommsReply("Back", commsShip)
						end)
					end
				end
			end)
		end)
	end
	local shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
		if distance(comms_source, comms_target) < 5000 then
			if comms_data.friendlyness > 66 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					if comms_source.goods ~= nil and comms_source.goods.luxury ~= nil and comms_source.goods.luxury > 0 then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 and good ~= "luxury" then
								addCommsReply(string.format("Trade luxury for %s",good), function()
									goodData.quantity = goodData.quantity - 1
									if comms_source.goods == nil then
										comms_source.goods = {}
									end
									if comms_source.goods[good] == nil then
										comms_source.goods[good] = 0
									end
									comms_source.goods[good] = comms_source.goods[good] + 1
									comms_source.goods.luxury = comms_source.goods.luxury - 1
									setCommsMessage(string.format("Traded your luxury for %s from %s",good,comms_target:getCallSign()))
									addCommsReply("Back", commsShip)
								end)
							end
						end	--freighter goods loop
					end	--player has luxury branch
				end	--goods or equipment freighter
				if comms_source.cargo > 0 then
					for good, goodData in pairs(comms_data.goods) do
						if goodData.quantity > 0 then
							addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost)), function()
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
									setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
								else
									setCommsMessage("Insufficient reputation for purchase")
								end
								addCommsReply("Back", commsShip)
							end)
						end
					end	--freighter goods loop
				end	--player has cargo space branch
			elseif comms_data.friendlyness > 33 then
				if comms_source.cargo > 0 then
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost)), function()
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
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end	--freighter has something to sell branch
						end	--freighter goods loop
					else	--not goods or equipment freighter
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*2)), function()
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
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end	--freighter has something to sell branch
						end	--freighter goods loop
					end
				end	--player has room for cargo branch
			else	--least friendly
				if comms_source.cargo > 0 then
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*2)), function()
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
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end	--freighter has something to sell branch
						end	--freighter goods loop
					end	--goods or equipment freighter
				end	--player has room to get goods
			end	--various friendliness choices
		else	--not close enough to sell
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
				addCommsReply("Back", commsShip)
			end)
		end
	end
	return true
end
function enemyComms(comms_data)
	if comms_data.friendlyness > 50 then
		local faction = comms_target:getFaction()
		local taunt_option = "We will see to your destruction!"
		local taunt_success_reply = "Your bloodline will end here!"
		local taunt_failed_reply = "Your feeble threats are meaningless."
		if faction == "Kraylor" then
			setCommsMessage("Ktzzzsss.\nYou will DIEEee weaklingsss!");
			local kraylorTauntChoice = math.random(1,3)
			if kraylorTauntChoice == 1 then
				taunt_option = "We will destroy you"
				taunt_success_reply = "We think not. It is you who will experience destruction!"
			elseif kraylorTauntChoice == 2 then
				taunt_option = "You have no honor"
				taunt_success_reply = "Your insult has brought our wrath upon you. Prepare to die."
				taunt_failed_reply = "Your comments about honor have no meaning to us"
			else
				taunt_option = "We pity your pathetic race"
				taunt_success_reply = "Pathetic? You will regret your disparagement!"
				taunt_failed_reply = "We don't care what you think of us"
			end
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
	local shipType = comms_target:getTypeName()
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
		if distance(comms_source,comms_target) < 5000 then
			if comms_source.cargo > 0 then
				if comms_data.friendlyness > 66 then
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost)), function()
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
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end
						end	--freighter goods loop
					else
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*2)), function()
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
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*2)), function()
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
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end
						end	--freighter goods loop
					else
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*3)), function()
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
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*3)), function()
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
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end
						end	--freighter goods loop
					end
				end	--end friendly branches
			end	--player has room for cargo
		end	--close enough to sell
	else	--not a freighter
		if comms_data.friendlyness > 50 then
			setCommsMessage("Sorry, we have no time to chat with you.\nWe are on an important mission.");
		else
			setCommsMessage("We have nothing for you.\nGood day.");
		end
	end	--end non-freighter communications else branch
	return true
end	--end neutral communications function
-----------------------
-- Utility functions --
-----------------------
function playVoice(clip)
	if server_voices then
		if not voice_played[clip] then
			table.insert(voice_queue,clip)
			voice_played[clip] = true
		end
	end
end
function handleVoiceQueue(delta)
	if #voice_queue > 0 then
		voice_delay = voice_delay - delta
		if voice_delay < 0 then
			playSoundFile(string.format("sa_48_%s.ogg",voice_queue[1]))
			voice_delay = voice_delay + delta + 1 + voice_clips[voice_queue[1]]
			table.remove(voice_queue,1)
		end
	else
		voice_delay = delta
	end
end
function createRandomAlongArc(object_type, amount, x, y, distance, startArc, clockwiseEndArc, randomize)
-- Create amount of objects of type object_type along arc
-- Center defined by x and y
-- Radius defined by distance
-- Start of arc between 0 and 360 (startArc), end arc: clockwiseEndArc
-- Use randomize to vary the distance from the center point. Omit to keep distance constant
-- Example:
--   createRandomAlongArc(Asteroid, 100, 500, 3000, 65, 120, 450)
	if randomize == nil then randomize = 0 end
	if amount == nil then amount = 1 end
	local arcLen = clockwiseEndArc - startArc
	if startArc > clockwiseEndArc then
		clockwiseEndArc = clockwiseEndArc + 360
		arcLen = arcLen + 360
	end
	if amount > arcLen then
		for ndex=1,arcLen do
			local radialPoint = startArc+ndex
			local pointDist = distance + random(-randomize,randomize)
			object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist)			
		end
		for ndex=1,amount-arcLen do
			radialPoint = random(startArc,clockwiseEndArc)
			pointDist = distance + random(-randomize,randomize)
			object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist)			
		end
	else
		for ndex=1,amount do
			radialPoint = random(startArc,clockwiseEndArc)
			pointDist = distance + random(-randomize,randomize)
			object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist)
		end
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
function closestPlayerTo(obj)
-- Return the player ship closest to passed object parameter
-- Return nil if no valid result
-- Assumes a maximum of 8 player ships
	if obj ~= nil and obj:isValid() then
		local closestDistance = 9999999
		local closestPlayer = nil
		for pidx=1,8 do
			local p = getPlayerShip(pidx)
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
function spawnEnemies(xOrigin, yOrigin, danger, enemyFaction, perimeter_min, perimeter_max)
	if enemyFaction == nil then
		enemyFaction = "Kraylor"
	end
	if danger == nil then 
		danger = 1
	end
	local enemyStrength = math.max(danger * difficulty * playerPower(),5)
	local enemyPosition = 0
	local sp = irandom(400,900)			--random spacing of spawned group
	local deployConfig = random(1,100)	--randomly choose between squarish formation and hexagonish formation
	local enemyList = {}
	-- Reminder: stsl and stnl are ship template score and name list
	while enemyStrength > 0 do
		local shipTemplateType = irandom(1,#stsl)
		while stsl[shipTemplateType] > enemyStrength * 1.1 + 5 do
			shipTemplateType = irandom(1,#stsl)
		end		
		local ship = CpuShip():setFaction(enemyFaction):setTemplate(stnl[shipTemplateType]):orderRoaming()
		if enemyFaction == "Kraylor" then
			rawKraylorShipStrength = rawKraylorShipStrength + stsl[shipTemplateType]
			ship:onDestruction(kraylorVesselDestroyed)
		elseif enemyFaction == "Human Navy" then
			rawHumanShipStrength = rawHumanShipStrength + stsl[shipTemplateType]
			ship:onDestruction(humanVesselDestroyed)
		elseif enemyFaction == "Exuari" then
			rawExuariShipStrength = rawExuariShipStrength + stsl[shipTemplateType]
			ship:onDestruction(exuariVesselDestroyed)
		elseif enemyFaction == "Arlenians" then
			rawArlenianShipStrength = rawArlenianShipStrength + stsl[shipTemplateType]
			ship:onDestruction(arlenianVesselDestroyed)
		end
		enemyPosition = enemyPosition + 1
		if deployConfig < 50 then
			ship:setPosition(xOrigin+fleetPosDelta1x[enemyPosition]*sp,yOrigin+fleetPosDelta1y[enemyPosition]*sp)
		else
			ship:setPosition(xOrigin+fleetPosDelta2x[enemyPosition]*sp,yOrigin+fleetPosDelta2y[enemyPosition]*sp)
		end
		ship:setCommsScript(""):setCommsFunction(commsShip)
		ship:setCallSign(generateCallSign(nil,enemyFaction))
		table.insert(enemyList, ship)
		enemyStrength = enemyStrength - stsl[shipTemplateType]
	end
	if perimeter_min ~= nil then
		local enemy_angle = random(0,360)
		local circle_increment = 360/#enemyList
		local perimeter_deploy = perimeter_min
		if perimeter_max ~= nil then
			perimeter_deploy = random(perimeter_min,perimeter_max)
		end
		for _, enemy in pairs(enemyList) do
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
-- Mortal repair crew functions. Includes coolant loss as option to losing repair crew
function healthCheck(delta)
	healthCheckTimer = healthCheckTimer - delta
	if healthCheckTimer < 0 then
		if healthDiagnostic then print("health check timer expired") end
		for pidx=1,8 do
			if healthDiagnostic then print("in player loop") end
			local p = getPlayerShip(pidx)
			if healthDiagnostic then print("got player ship") end
			if p ~= nil and p:isValid() then
				if healthDiagnostic then print("valid ship") end
				if p:getRepairCrewCount() > 0 then
					if healthDiagnostic then print("crew on valid ship") end
					local fatalityChance = 0
					if healthDiagnostic then print("shields") end
					sc = p:getShieldCount()
					if healthDiagnostic then print("sc: " .. sc) end
					if p:getShieldCount() > 1 then
						cShield = (p:getSystemHealth("frontshield") + p:getSystemHealth("rearshield"))/2
					else
						cShield = p:getSystemHealth("frontshield")
					end
					fatalityChance = fatalityChance + (p.prevShield - cShield)
					p.prevShield = cShield
					if healthDiagnostic then print("reactor") end
					fatalityChance = fatalityChance + (p.prevReactor - p:getSystemHealth("reactor"))
					p.prevReactor = p:getSystemHealth("reactor")
					if healthDiagnostic then print("maneuver") end
					fatalityChance = fatalityChance + (p.prevManeuver - p:getSystemHealth("maneuver"))
					p.prevManeuver = p:getSystemHealth("maneuver")
					if healthDiagnostic then print("impulse") end
					fatalityChance = fatalityChance + (p.prevImpulse - p:getSystemHealth("impulse"))
					p.prevImpulse = p:getSystemHealth("impulse")
					if healthDiagnostic then print("beamweapons") end
					if p:getBeamWeaponRange(0) > 0 then
						if p.healthyBeam == nil then
							p.healthyBeam = 1.0
							p.prevBeam = 1.0
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
						fatalityChance = fatalityChance + (p.prevMissile - p:getSystemHealth("missilesystem"))
						p.prevMissile = p:getSystemHealth("missilesystem")
					end
					if healthDiagnostic then print("warp") end
					if p:hasWarpDrive() then
						if p.healthyWarp == nil then
							p.healthyWarp = 1.0
							p.prevWarp = 1.0
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
					if random(1,100) <= (4 - dificulty) then
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
		if p.initialCoolant == nil then
			p:setRepairCrewCount(p:getRepairCrewCount() - 1)
			if p:hasPlayerAtPosition("Engineering") then
				local repairCrewFatality = "repairCrewFatality"
				p:addCustomMessage("Engineering",repairCrewFatality,"One of your repair crew has perished")
			end
			if p:hasPlayerAtPosition("Engineering+") then
				local repairCrewFatalityPlus = "repairCrewFatalityPlus"
				p:addCustomMessage("Engineering+",repairCrewFatalityPlus,"One of your repair crew has perished")
			end
		else
			if random(1,100) < 50 then
				p:setRepairCrewCount(p:getRepairCrewCount() - 1)
				if p:hasPlayerAtPosition("Engineering") then
					local repairCrewFatality = "repairCrewFatality"
					p:addCustomMessage("Engineering",repairCrewFatality,"One of your repair crew has perished")
				end
				if p:hasPlayerAtPosition("Engineering+") then
					local repairCrewFatalityPlus = "repairCrewFatalityPlus"
					p:addCustomMessage("Engineering+",repairCrewFatalityPlus,"One of your repair crew has perished")
				end
			else
				local current_coolant = p:getMaxCoolant()
				if current_coolant >= 10 then
					p:setMaxCoolant(p:getMaxCoolant()*.5)
				else
					p:setMaxCoolant(p:getMaxCoolant()*.8)
				end
				if p:hasPlayerAtPosition("Engineering") then
					local coolantLoss = "coolantLoss"
					p:addCustomMessage("Engineering",coolantLoss,"Damage has caused a loss of coolant")
				end
				if p:hasPlayerAtPosition("Engineering+") then
					local coolantLossPlus = "coolantLossPlus"
					p:addCustomMessage("Engineering+",coolantLossPlus,"Damage has caused a loss of coolant")
				end
			end
		end
	end
end
-- Gain or lose coolant from nebula functions
function coolantNebulae(delta)
	for pidx=1,8 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			local inside_gain_coolant_nebula = false
			for i=1,#coolant_nebula do
				if distance(p,coolant_nebula[i]) < 5000 then
					if coolant_nebula[i].lose then
						p:setMaxCoolant(p:getMaxCoolant()*coolant_loss)
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
						p:addCustomButton("Engineering",p.get_coolant_button,"Get Coolant",get_coolant_function[pidx])
						p.get_coolant = true
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p.get_coolant_button_plus = "get_coolant_button_plus"
						p:addCustomButton("Engineering+",p.get_coolant_button_plus,"Get Coolant",get_coolant_function[pidx])
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
			gather_coolant_status = "Gathering Coolant"
			p:setMaxCoolant(p:getMaxCoolant() + coolant_gain)
		else
			gather_coolant_status = string.format("Deploying Collectors %i",math.ceil(p.deploy_coolant_timer - delta))
		end
	else
		gather_coolant_status = string.format("Configuring Collectors %i",math.ceil(p.configure_coolant_timer - delta))
	end
	if p:hasPlayerAtPosition("Engineering") then
		p.gather_coolant = "gather_coolant"
		p:addCustomInfo("Engineering",p.gather_coolant,gather_coolant_status)
	end
	if p:hasPlayerAtPosition("Engineering+") then
		p.gather_coolant_plus = "gather_coolant_plus"
		p:addCustomInfo("Engineering",p.gather_coolant_plus,gather_coolant_status)
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
function getCoolant1()
	local p = getPlayerShip(1)
	getCoolantGivenPlayer(p)
end
function getCoolant2()
	local p = getPlayerShip(2)
	getCoolantGivenPlayer(p)
end
function getCoolant3()
	local p = getPlayerShip(3)
	getCoolantGivenPlayer(p)
end
function getCoolant4()
	local p = getPlayerShip(4)
	getCoolantGivenPlayer(p)
end
function getCoolant5()
	local p = getPlayerShip(5)
	getCoolantGivenPlayer(p)
end
function getCoolant6()
	local p = getPlayerShip(6)
	getCoolantGivenPlayer(p)
end
function getCoolant7()
	local p = getPlayerShip(7)
	getCoolantGivenPlayer(p)
end
function getCoolant8()
	local p = getPlayerShip(8)
	getCoolantGivenPlayer(p)
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
	if faction == "Human Navy" then
		if human_names == nil then
			setHumanNames()
		else
			if #human_names < 1 then
				setHumanNames()
			end
		end
		local human_name_choice = math.random(1,#human_names)
		faction_prefix = human_names[human_name_choice]
		table.remove(human_names,human_name_choice)
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
function setHumanNames()
	human_names = {}
	table.insert(human_names,"Achilles")
	table.insert(human_names,"Agamemnon")
	table.insert(human_names,"Aloof")
	table.insert(human_names,"Atlas")
	table.insert(human_names,"Bent Lament")
	table.insert(human_names,"Blue Suede Shoes")
	table.insert(human_names,"Blade")
	table.insert(human_names,"Blue Sky")
	table.insert(human_names,"Bright Light")
	table.insert(human_names,"Charon")
	table.insert(human_names,"Cloudy Sky")
	table.insert(human_names,"Contingency")
	table.insert(human_names,"Corner Office")
	table.insert(human_names,"Cutter")
	table.insert(human_names,"d'Artagnan")
	table.insert(human_names,"Dante")
	table.insert(human_names,"Dark Star")
	table.insert(human_names,"Dreamer")
	table.insert(human_names,"Eager Beaver")
	table.insert(human_names,"Earnest Plea")
	table.insert(human_names,"Exodous")
	table.insert(human_names,"Expedition")
	table.insert(human_names,"Faint Praise")
	table.insert(human_names,"Far Cry")
	table.insert(human_names,"Fashion Sense")
	table.insert(human_names,"Final Frontier")
	table.insert(human_names,"Finn")
	table.insert(human_names,"First Try")
	table.insert(human_names,"Free Lunch")
	table.insert(human_names,"Formidable")
	table.insert(human_names,"Gargantuan")
	table.insert(human_names,"Glide Path")
	table.insert(human_names,"Grand Plan")
	table.insert(human_names,"Gremlin")
	table.insert(human_names,"Guiding Light")
	table.insert(human_names,"Hades")
	table.insert(human_names,"Haughty")
	table.insert(human_names,"Heavenly Body")
	table.insert(human_names,"Hermes")
	table.insert(human_names,"Highlander")
	table.insert(human_names,"Holy Cow")
	table.insert(human_names,"Hunter")
	table.insert(human_names,"Hypertension")
	table.insert(human_names,"Indifferent")
	table.insert(human_names,"Insatiable")
	table.insert(human_names,"Insidious")
	table.insert(human_names,"Instigator")
	table.insert(human_names,"Invincible")
	table.insert(human_names,"J. B. Sloop")
	table.insert(human_names,"Kipling")
	table.insert(human_names,"Knowledge Fount")
	table.insert(human_names,"Kremlin")
	table.insert(human_names,"Lady Luck")
	table.insert(human_names,"Last Chance")
	table.insert(human_names,"Lurker")
	table.insert(human_names,"Malady")
	table.insert(human_names,"Manticore")
	table.insert(human_names,"Mars")
	table.insert(human_names,"Medusa")
	table.insert(human_names,"Mercury")
	table.insert(human_names,"Minnow")
	table.insert(human_names,"Morpheus")
	table.insert(human_names,"Murphy's Law")
	table.insert(human_names,"Murphy's Corollary")
	table.insert(human_names,"Mystery")
	table.insert(human_names,"Near Horizon")
	table.insert(human_names,"Near Term")
	table.insert(human_names,"Neo")
	table.insert(human_names,"Nightshade")
	table.insert(human_names,"Nineva")
	table.insert(human_names,"North Star")
	table.insert(human_names,"Occam's Razor")
	table.insert(human_names,"Opulent")
	table.insert(human_names,"Ostentatious")
	table.insert(human_names,"Outlander")
	table.insert(human_names,"Pentagon")
	table.insert(human_names,"Persistent")
	table.insert(human_names,"Persnickety")
	table.insert(human_names,"Phoebus")
	table.insert(human_names,"Plumbline")
	table.insert(human_names,"Portent")
	table.insert(human_names,"Purple People Eater")
	table.insert(human_names,"Quatrain")
	table.insert(human_names,"Raider")
	table.insert(human_names,"Reflection")
	table.insert(human_names,"Red Baron")
	table.insert(human_names,"Red Dawn")
	table.insert(human_names,"Safari")
	table.insert(human_names,"Sawyer")
	table.insert(human_names,"Schoolgirl")
	table.insert(human_names,"Scupper")
	table.insert(human_names,"Seeker")
	table.insert(human_names,"Shadow")
	table.insert(human_names,"Silvery Moon")
	table.insert(human_names,"Snake Eyes")
	table.insert(human_names,"Solaris")
	table.insert(human_names,"Stream of Consciousness")
	table.insert(human_names,"Teluride")
	table.insert(human_names,"Throckwaddle")
	table.insert(human_names,"Tramp")
	table.insert(human_names,"Tracker")
	table.insert(human_names,"Tried and True")
	table.insert(human_names,"Tripe")
	table.insert(human_names,"Tripper")
	table.insert(human_names,"Trixie")
	table.insert(human_names,"Underbelly")
	table.insert(human_names,"Urgent")
	table.insert(human_names,"Vacuous")
	table.insert(human_names,"Venial")
	table.insert(human_names,"Veritas")
	table.insert(human_names,"Ways and Means")
	table.insert(human_names,"Weeping Widow")
	table.insert(human_names,"Wolfman")
end
----------------------------
-- Plot related functions --
----------------------------
-- INITIAL PLOT Defend primus station
function startDefendPrimusStation()
	setUpDefendPrimusStation = "done"
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			p:addToShipLog(string.format("[%s orbiting %s currently in %s] We could use help taking care of nearby Exuari",primusStation:getCallSign(),planetPrimus:getCallSign(),primusStation:getSectorName()),"Magenta")
		end
	end
	playVoice("Skyler01")
	primaryOrders = string.format("Remove Exuari near %s",primusStation:getCallSign())
	rawExuariShipStrength = 0
	rawKraylorShipStrength = 0
	rawHumanShipStrength = 0
	rawArlenianShipStrength = 0
	kraylorVesselDestroyedNameList = {}
	exuariVesselDestroyedNameList = {}
	humanVesselDestroyedNameList = {}
	arlenianVesselDestroyedNameList = {}
	kraylorVesselDestroyedType = {}
	exuariVesselDestroyedType = {}
	humanVesselDestroyedType = {}
	arlenianVesselDestroyedType = {}
	kraylorVesselDestroyedValue = {}
	exuariVesselDestroyedValue = {}
	humanVesselDestroyedValue = {}
	arlenianVesselDestroyedValue = {}
	prx, pry = primusStation:getPosition()
	pla = random(0,360)
	pmx, pmy = vectorFromAngle(pla,random(8000,12000))
	enemyFleet = spawnEnemies(prx+pmx,pry+pmy,1,"Exuari")
	for _, enemy in ipairs(enemyFleet) do
		enemy:orderAttack(primusStation)
	end
	reinforcementInterval = 60
	reinforcementTimer = reinforcementInterval
	reinforcementCount = 3
end
function defendPrimusStation(delta)
	if setUpDefendPrimusStation == nil then
		startDefendPrimusStation()
	end
	plot1 = checkDefendPrimusStationEvents
end
function checkDefendPrimusStationEvents(delta)
	local perceivePlayer = false
	local remainingEnemyCount = 0
	for _, enemy in ipairs(enemyFleet) do
		if enemy ~= nil and enemy:isValid() then
			remainingEnemyCount = remainingEnemyCount + 1
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					if distance(p,enemy) < 8000 then
						perceivePlayer = true
						break
					end
				end
			end
		end
		if perceivePlayer and remainingEnemyCount > 0 then
			break
		end
	end
	if remainingEnemyCount > 0 then
		if perceivePlayer then
			reinforcementTimer = reinforcementTimer - delta
			if reinforcementTimer < 0 then
				if reinforcementCount > 0 then
					if reinforcementCount == 3 then
						for _, enemy in ipairs(enemyFleet) do
							enemy:orderAttack(p)
						end
					else
						prx, pry = p:getPosition()
						pmx, pmy = vectorFromAngle(random(0,360),random(6000,8000))
						local tempFleet = spawnEnemies(prx+pmx,pry+pmy,1,"Exuari")
						for _, enemy in ipairs(tempFleet) do
							enemy:orderAttack(p)
							table.insert(enemyFleet,enemy)
						end
					end
					reinforcementCount = reinforcementCount - 1
				end
				reinforcementTimer = delta + reinforcementInterval
			end
		else
			reinforcementTimer = delta + reinforcementInterval
		end
	else
		--no enemies remain
		if missionCloseMessage == nil then
			missionCloseMessage = "sent"
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					p:addToShipLog(string.format("[%s] All station personnel thank you for your assistance. Dock with us for further orders",primusStation:getCallSign()),"Magenta")
				end
			end
			playVoice("Skyler02")
			primaryOrders = string.format("Dock with %s",primusStation:getCallSign())
		end
		initialMission = false
		plot1 = nil
		mission_complete_count = mission_complete_count + 1
		mission_region = 1
		plotChoiceStation = primusStation
	end
end
-- PRIMUS STATION PLOT Orbiting artifact
function startOrbitingArtifact()
	setUpOrbitingArtifact = "done"
	astronomerBoardedShip = false
	artifactInvestigateRange = false
	artifactSensorDataGathered = false
	artifact_sensor_data_timer_button = false
	readingTimerMax = 20*difficulty
	artifactSensorReadingTimer = readingTimerMax
	accumulatedReadings = 0
end
function orbitingArtifact(delta)
	if setUpOrbitingArtifact == nil then
		startOrbitingArtifact()
	end
	plot1 = checkOrbitingArtifactEvents
end
function checkOrbitingArtifactEvents(delta)
	if astronomerBoardedShip and belt1Artifact:isScannedByFaction("Human Navy") then
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if p.astronomer then
					if not artifact_sensor_data_timer_button and not artifactSensorDataGathered then
						artifact_sensor_data_timer_button = true
						sensor_data_timer_button = "sensor_data_timer_button"
						p:addCustomButton("Relay",sensor_data_timer_button,"Polly Scan Time",function()
							for pidx=1,8 do
								p = getPlayerShip(pidx)
								if p.astronomer then
									p:addToShipLog(string.format("%.1f seconds remain to be scanned",artifactSensorReadingTimer),"Yellow")
								end
							end
						end)
					end
					local sensor_status = "Range"
					if distance(p,belt1Artifact) < 1000 then
						sensor_status = "In " .. sensor_status
						local batchMsg = false
						if not artifactInvestigateRange then
							artifactInvestigateRange = true
							p:addToShipLog(string.format("[Polly Hobbs] We are in range for additional sensor readings. Gathering data now. We will need to stay in range for %s seconds to complete the sensor readings",readingTimerMax),"Magenta")
							playVoice(string.format("Polly01%i",readingTimerMax))
						end
						artifactSensorReadingTimer = artifactSensorReadingTimer - delta
						if pollyDiagnostic then print("In range.  Timer: " .. artifactSensorReadingTimer) end
						if artifactSensorReadingTimer < 0 then
							artifactSensorDataGathered = true
							if analyzeGatheredDataMsg == nil then
								analyzeGatheredDataMsg = "sent"
								p:addToShipLog("[Polly Hobbs] The data gathering phase is complete. Analyzing data","Magenta")
								playVoice("Polly04")
								artifactDataAnalysisTimer = delta + random(10,20)
							end
						end
					else
						sensor_status = "Out of " .. sensor_status
						--artifactSensorReadingTimer = delta + readingTimerMax
						artifactSensorReadingTimer = delta + artifactSensorReadingTimer
						if artifactSensorReadingTimer > readingTimerMax then
							artifactSensorReadingTimer = readingTimerMax
						end
						if not batchMsg then
							batchMsg = true
							p:addToShipLog(string.format("[Polly Hobbs] %.1f seconds remain to be scanned",artifactSensorReadingTimer),"Magenta")
						end
						if pollyDiagnostic then print("Out of range.  Timer: " .. artifactSensorReadingTimer) end
					end
					sensor_status = string.format("%s: %i",sensor_status,math.ceil(artifactSensorReadingTimer))
					if p:hasPlayerAtPosition("Helms") then
						p.sensor_status = "sensor_status"
						p:addCustomInfo("Helms",p.sensor_status,sensor_status)
					end
					if p:hasPlayerAtPosition("Tactical") then
						p.sensor_status_tactical = "sensor_status_tactical"
						p:addCustomInfo("Tactical",p.sensor_status_tactical,sensor_status)
					end
					if artifact_sensor_data_timer_button and artifactSensorDataGathered then
						p:removeCustom(sensor_data_timer_button)
						artifact_sensor_data_timer_button = false
					end
					if artifactSensorDataGathered then
						if p.sensor_status ~= nil then
							p:removeCustom(p.sensor_status)
							p.sensor_status = nil
						end
						if p.sensor_status_tactical then
							p:removeCustom(p.sensor_status_tactical)
							p.sensor_status_tactical = nil
						end
					end
					break
				end
			end
		end
		if artifactSensorDataGathered then
			artifactDataAnalysisTimer = artifactDataAnalysisTimer - delta
			if artifactDataAnalysisTimer < 0 then
				if p ~= nil and p:isValid() then
					if artifactAnalysisMessage == nil then
						artifactAnalysisMessage = "sent"
						p:addToShipLog("[Polly Hobbs] Readings indicate that not only does this object not belong here physically, it seems to not belong here temporally either. Portions of it are phasing in and out of our time continuum","Magenta")
						playVoice("Polly05")
						independentReleaseTimer = delta + random(20,40)
					end
				end
			end
			if artifactAnalysisMessage == "sent" then
				independentReleaseTimer = independentReleaseTimer - delta
				if independentReleaseTimer < 0 and lostIndependentFleet == nil then
					lostIndependentFleet = {}
					local tempBase = nearStations(belt1Artifact,playerSpawnBandStations)
					local transportType = {"Personnel","Goods","Garbage","Equipment","Fuel"}
					local tpmx, tpmy = belt1Artifact:getPosition()
					for i=1,4 do
						local name = transportType[math.random(1,#transportType)]
						if random(1,100) < 30 then
							name = name .. " Jump Freighter " .. math.random(3, 5)
						else
							name = name .. " Freighter " .. math.random(1, 5)
						end
						local tempShip = CpuShip():setTemplate(name):setFaction('Independent'):setCommsScript(""):setCommsFunction(commsShip)
						tempShip:setPosition(tpmx,tpmy):orderDock(tempBase)
						tempShip.targetDock = tempBase
						table.insert(lostIndependentFleet,tempShip)
					end
					tempShip = CpuShip():setTemplate("Adder MK4"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsShip):setPosition(tpmx,tpmy):orderDock(tempBase)
					tempShip.targetDock = tempBase
					table.insert(lostIndependentFleet,tempShip)
					releaseMessageTimer = delta + 5
				end
			end
			if lostIndependentFleet ~= nil then
				releaseMessageTimer = releaseMessageTimer - delta
				if releaseMessageTimer < 0 then
					if releaseMsg == nil then
						releaseMsg = "sent"
						if p ~= nil and p:isValid() then
							p:addToShipLog("[Polly Hobbs] There was a surge of chroniton particles from the artifact just before those Independent ships appeared. I think they were somehow released or transported by the artifact","Magenta")
							playVoice("Polly06")
							timeSignatureMessageTimer = delta + 10
						end
					end
				end
			end
			if releaseMsg == "sent" then
				timeSignatureMessageTimer = timeSignatureMessageTimer - delta
				if timeSignatureMessageTimer < 0 then
					if timeSignatureMsg == nil then
						timeSignatureMsg = "sent"
						if p ~= nil and p:isValid() then
							p:addToShipLog("[Polly Hobbs] Those ships show time signatures from history. I'm not sure why such old ships have suddenly appeared. I have gathered as much data as I can on this phenomenon. Thank you for your assistance","Magenta")
							playVoice("Polly07")
						end
						exuariInterestTimer = 30
						plot2 = exuariInterest
						plot3 = transportCleanup
						plot1 = nil
						mission_complete_count = mission_complete_count + 1
						plotChoiceStation = primusStation
						primaryOrders = string.format("Dock with %s",primusStation:getCallSign())
					end
				end
			end
		end
	end
end
-- PRIMUS STATION PLOT Plot 3 clean up time travelers (branch of orbiting artifact plot)
function transportCleanup(delta)
	local lostIndependentFleetCount = 0
	if lostIndependentFleet ~= nil then
		for _, tempShip in pairs(lostIndependentFleet) do
			if tempShip ~= nil and tempShip:isValid() then
				lostIndependentFleetCount = lostIndependentFleetCount + 1
				if tempShip:isDocked(tempShip.targetDock) then
					if delta > 500 then
						tempShip:destroy()
					end
				end
			end
		end
	end
	local secondLostFleetCount = 0
	if secondLostFleet ~= nil then
		for _, tempShip in pairs(secondLostFleet) do
			if tempShip ~= nil and tempShip:isValid() then
				secondLostFleetCount = secondLostFleetCount + 1
				if tempShip.targetDock ~= nil then
					if tempShip:isDocked(tempShip.targetDock) then
						if delta > 1100 then
							tempShip:destroy()
						end
					end
				end
			end
		end
	end
	if lostIndependentFleetCount == 0 and secondLostFleetCount == 0 then
		plot3 = nil
	end
end
-- PRIMUS STATION PLOT Plot 2 time travel and related conflict (branch of orbiting artifact plot)
function exuariInterest(delta)
	exuariInterestTimer = exuariInterestTimer - delta
	if exuariInterestTimer < 0 then
		plot2 = secondRelease
		secondReleaseTimer = 600
		for i=1,#lostIndependentFleet do
			local tempShip = lostIndependentFleet[i]
			if tempShip ~= nil and tempShip:isValid() then
				pmx, pmy = tempShip:getPosition()
				break
			end
		end
		local tempFleet = spawnEnemies(pmx, pmy, 2, "Exuari")
		for _, enemy in ipairs(tempFleet) do
			enemy:orderRoaming()
		end
	end
end
function secondRelease(delta)
	secondReleaseTimer = secondReleaseTimer - delta
	if secondReleaseTimer < 0 then
		secondLostFleet = {}
		local tempBase = nearStations(belt1Artifact,playerSpawnBandStations)
		local transportType = {"Personnel","Goods","Garbage","Equipment","Fuel"}
		local tpmx, tpmy = belt1Artifact:getPosition()
		for i=1,4 do
			local name = transportType[math.random(1,#transportType)]
			if random(1,100) < 30 then
				name = name .. " Jump Freighter " .. math.random(3, 5)
			else
				name = name .. " Freighter " .. math.random(1, 5)
			end
			local tempShip = CpuShip():setTemplate(name):setFaction('Independent'):setCommsScript(""):setCommsFunction(commsShip)
			tempShip:setPosition(tpmx,tpmy):orderDock(tempBase)
			tempShip.targetDock = tempBase
			table.insert(secondLostFleet,tempShip)
		end
		tempShip = CpuShip():setTemplate("Adder MK4"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsShip):setPosition(tpmx,tpmy):orderDock(tempBase)
		tempShip.targetDock = tempBase
		table.insert(secondLostFleet,tempShip)
		for i=1,4 do
			local name = transportType[math.random(1,#transportType)]
			if random(1,100) < 30 then
				name = name .. " Jump Freighter " .. math.random(3, 5)
			else
				name = name .. " Freighter " .. math.random(1, 5)
			end
			local tempShip = CpuShip():setTemplate(name):setFaction('Human Navy'):setCommsScript(""):setCommsFunction(commsShip)
			tempShip:setPosition(tpmx,tpmy):orderDock(tempBase)
			tempShip.targetDock = tempBase
			table.insert(secondLostFleet,tempShip)
		end
		tempShip = CpuShip():setTemplate("Adder MK4"):setFaction("Human Navy"):setCommsScript(""):setCommsFunction(commsShip):setPosition(tpmx,tpmy):orderDefendTarget(secondLostFleet[#secondLostFleet])
		table.insert(secondLostFleet,tempShip)
		for i=1,4 do
			local name = transportType[math.random(1,#transportType)]
			if random(1,100) < 30 then
				name = name .. " Jump Freighter " .. math.random(3, 5)
			else
				name = name .. " Freighter " .. math.random(1, 5)
			end
			local tempShip = CpuShip():setTemplate(name):setFaction('Exuari'):setCommsScript(""):setCommsFunction(commsShip)
			ship:setCallSign(generateCallSign(nil,"Exuari"))
			tempShip:setPosition(tpmx,tpmy):orderDock(tempBase)
			tempShip.targetDock = tempBase
			table.insert(secondLostFleet,tempShip)
		end
		plot2 = secondExuariInterest
		secondInterestTimer = 30
	end
end
function secondExuariInterest(delta)
	secondInterestTimer = secondInterestTimer - delta
	if secondInterestTimer < 0 then
		plot2 = nil
		for i=1,#secondLostFleet do
			local tempShip = secondLostFleet[i]
			if tempShip ~= nil and tempShip:isValid() then
				local tpmx, tpmy = tempShip:getPosition()
				break
			end
		end
		local tempFleet = spawnEnemies(tpmx, tpmy, 5, "Exuari")
		for _, enemy in ipairs(tempFleet) do
			enemy:orderRoaming()
		end
	end
end
-- PRIMUS STATION PLOT Transport Primus researcher
function startTransportPrimusResearcher()
	setUpTransportPrimusResearcher = "done"
	researcherBoardedShip = false
	lastLocationPlanetologist = "unknown"
	planetologistChase = 0
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			p.planetologistAboard = false
		end
	end
	enemyFleet = {}
end
function transportPrimusResearcher(delta)
	if setUpTransportPrimusResearcher == nil then
		startTransportPrimusResearcher()
	end
	plot1 = checkTransportPrimusResearcherEvents
end
function checkTransportPrimusResearcherEvents(delta)
	if researcherBoardedShip then
		primaryOrders = string.format("Transport planetologist by docking with %s",primusStation:getCallSign())
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil then
				if p:isValid() then
					if p.planetologistAboard then
						if p:isDocked(primusStation) then
							primaryOrders = string.format("Dock with %s",primusStation:getCallSign())
							plot1 = nil
							mission_complete_count = mission_complete_count + 1
							plotChoiceStation = primusStation
							p:addToShipLog("Enrique Flogistan profusely thanked you as he dashed to his observation laboratory. He discussed his research on some unique properties of dilithium with your engineer before he left. Consequently, engineering has improved battery efficiency by ten percent","Magenta")
							p:setMaxEnergy(p:getMaxEnergy()*1.1)
							p:addReputationPoints(50)
						end
						break
					end
				else
					if p.planetologistAboard then
						--player ship with planetologist aboard was destroyed
						showEndStats("Planetologist perished")
						victory("Exuari")
					end
				end
			end
		end
		planetologistAssassinTimer = planetologistAssassinTimer - delta
		if planetologistAssassinTimer < 0 then
			if planetologistAssassin == nil then
				planetologistAssassin = "spawned"
				prx, pry = p:getPosition()
				pmx, pmy = primusStation:getPosition()
				enemyFleet = spawnEnemies((prx+pmx)/2,(pry+pmy)/2,1,"Exuari")
				for _, enemy in ipairs(enemyFleet) do
					enemy:orderAttack(p)
					if difficulty >= 1 then
						enemy:setWarpDrive(true)
					end
				end
			end
		end
	else
		planetologistAssassinTimer = delta + random(10,30)
	end
end
-- PRIMUS STATION PLOT Fix satellites
function startFixSatellites()
	if fixSatelliteDiagnostic then print("top of start fix satellite") end
	setUpFixSatellites = "done"
	secondusStations[1].satelliteFixed = false
	secondusStations[2].satelliteFixed = false
	secondusStations[3].satelliteFixed = false
	--station 1 has what station 2 needs
	local satelliteGood = nil
	local ctd = secondusStations[1].comms_data
	local ctd2 = secondusStations[2].comms_data
	local matchGood = false
	for good, goodData in pairs(ctd.goods) do
		if good ~= "food" and good ~= "medicine" and good ~= "luxury" then
			matchGood = false
			for good2, goodData2 in pairs(ctd2.goods) do
				if good2 == good then
					matchGood = true
					break
				end
			end
			if not matchGood then
				satelliteGood = good
				break
			end
		end
	end
	if satelliteGood == nil then
		secondusStations[1].comms_data.goods.optic = {quantity = 10, cost = math.random(50,70)}
		satelliteGood = "optic"
	end
	if fixSatelliteDiagnostic then print("satellite good 1: " .. satelliteGood) end
	secondusStations[2].satelliteFixGood = satelliteGood
	--station 2 has what station 3 needs
	satelliteGood = nil
	ctd = secondusStations[2].comms_data
	ctd2 = secondusStations[3].comms_data
	for good, goodData in pairs(ctd.goods) do
		if good ~= "food" and good ~= "medicine" and good ~= "luxury" and good ~= secondusStations[2].satelliteFixGood then
			matchGood = false
			for good2, goodData2 in pairs(ctd2.goods) do
				if good2 == good then
					matchGood = true
					break
				end
			end
			if not matchGood then
				satelliteGood = good
				break
			end
		end
	end
	if satelliteGood == nil then
		if secondusStations[2].satelliteFixGood ~= "filament" then
			secondusStations[2].comms_data.goods.filament = {quantity = 10, cost = math.random(60,90)}
			satelliteGood = "filament"
		else
			secondusStations[2].comms_data.goods.robotic = {quantity = 10, cost = math.random(60,90)}
			satelliteGood = "robotic"
		end
	end
	if fixSatelliteDiagnostic then print("satellite good 2: " .. satelliteGood) end
	secondusStations[3].satelliteFixGood = satelliteGood
	--station 3 has what station 1 needs
	satelliteGood = nil
	ctd = secondusStations[3].comms_data
	ctd2 = secondusStations[1].comms_data
	for good, goodData in pairs(ctd.goods) do
		if good ~= "food" and good ~= "medicine" and good ~= "luxury" and good ~= secondusStations[2].satelliteFixGood and good ~= secondusStations[3].satelliteFixGood then
			matchGood = false
			for good2, goodData2 in pairs(ctd2.goods) do
				if good2 == good then
					matchGood = true
					break
				end
			end
			if not matchGood then
				satelliteGood = good
				break
			end
		end
	end
	if satelliteGood == nil then
		if secondusStations[3].satelliteFixGood ~= "tractor" then
			secondusStations[3].comms_data.goods.tractor = {quantity = 10, cost = math.random(45,105)}
			satelliteGood = "tractor"
		else
			secondusStations[3].comms_data.goods.software = {quantity = 10, cost = math.random(45,105)}
			satelliteGood = "software"
		end
	end
	if fixSatelliteDiagnostic then print("satellite good 3: " .. satelliteGood) end
	secondusStations[1].satelliteFixGood = satelliteGood
	fixHarassInterval = 300
	fixHarassTimer = fixHarassInterval
	fixHarassCount = 0
	enemyFleet = {}
	if fixSatelliteDiagnostic then print("end of start fix satellite") end
end
function fixSatellites(delta)
	if setUpFixSatellites == nil then
		startFixSatellites()
	end
	plot1 = checkFixSatelliteEvents
end
function checkFixSatelliteEvents(delta)
	local remainingEnemyCount = 0
	for _, enemy in ipairs(enemyFleet) do
		if enemy ~= nil and enemy:isValid() then
			remainingEnemyCount = remainingEnemyCount + 1
		end
	end
	if secondusStations[1].satelliteFixed and secondusStations[2].satelliteFixed and secondusStations[3].satelliteFixed then
		--when completion criteria met, set plot1 to nil and set the plot choice station
		plot1 = nil
		mission_complete_count = mission_complete_count + 1
		plotChoiceStation = primusStation
		local reputationPending = true
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog("[Engineering Technician] For helping to fix their satellites, the satellite station technicians have doubled our impulse engine's top speed","Magenta")
				p:addToShipLog(string.format("Dock with %s",primusStation:getCallSign()),"Magenta")
				p:setImpulseMaxSpeed(p:getImpulseMaxSpeed()*2)
				if reputationPending then
					p:addReputationPoints(50)
					reputationPending = false
				end
			end
		end
		playVoice("Jamie01")
		primaryOrders = string.format("Dock with %s",primusStation:getCallSign())
	end
	if remainingEnemyCount > 0 then
		fixHarassTimer = delta + fixHarassInterval
	else
		fixHarassTimer = fixHarassTimer - delta
		if fixHarassTimer < 0 then
			fixHarassTimer = delta + fixHarassInterval
			p = closestPlayerTo(planetSecondus)
			if p == nil then
				for pidx=1,8 do
					p = getPlayerShip(pidx)
					if p ~= nil and p:isValid() then
						break
					end
				end
			end
			local hps = nearStations(p, secondusStations)
			prx, pry = p:getPosition()
			pmx, pmy = vectorFromAngle(hps.angle,random(5100,6000))
			enemyFleet = spawnEnemies(prx+pmx,pry+pmy,1+(difficulty*fixHarassCount),"Exuari")
			for _, enemy in ipairs(enemyFleet) do
				enemy:orderAttack(p)
			end
			fixHarassCount = fixHarassCount + 1
		end
	end
end
-- PRIMUS STATION PLOT Defend station from attack
function startDefendSpawnBandStation()
	set_up_defend_spawn_band_station = "done"
	repeat
		protect_station = playerSpawnBandStations[math.random(1,#playerSpawnBandStations)]
	until(protect_station ~= nil and protect_station:isValid())
	primaryOrders = string.format("Protect %s from marauding Exuari",protect_station:getCallSign())
end
function defendSpawnBandStation(delta)
	if set_up_defend_spawn_band_station == nil then
		startDefendSpawnBandStation()
	end
	plot1 = marauderHorizon
end
function marauderHorizon(delta)
	if marauder_horizon_timer == nil then
		marauder_horizon_timer = delta + 100
	end
	marauder_horizon_timer = marauder_horizon_timer - delta
	if marauder_horizon_timer < 0 then
		if protect_station ~= nil and protect_station:isValid() then
			plot1 = marauderSpawn
		else
			victory("Exuari")
		end
	end
end
function marauderSpawn(delta)
	if protect_station ~= nil and protect_station:isValid() then
		local cp = nil
		for pidx=1,8 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if cp == nil then
					cp = p
				else
					if distance(p,protect_station) < distance(cp,protect_station) then
						cp = p
					end
				end
			end
		end
		if cp ~= nil then
			protect_station.marauder_choice = cp
			local px, py = cp:getPosition()
			local sx, sy = protect_station:getPosition()
			protect_station.initial_marauder_fleet = spawnEnemies((px+sx)/2,(py+sy)/2,1,"Exuari")
			for _, enemy in ipairs(protect_station.initial_marauder_fleet) do
				enemy:orderAttack(protect_station)
			end
			plot1 = marauderApproach
		end
	else
		showEndStats(string.format("Station %s destroyed",protect_station:getCallSign()))
		victory("Exuari")
	end
end
function marauderApproach(delta)
	if protect_station ~= nil and protect_station:isValid() then
		if protect_station.marauder_warning == nil then
			for _, enemy in pairs(protect_station.initial_marauder_fleet) do
				if enemy ~= nil and enemy:isValid() then
					if distance(enemy,protect_station) < 30000 then
						if protect_station.marauder_choice ~= nil and protect_station.marauder_choice:isValid() then
							protect_station.marauder_choice:addToShipLog(string.format("[%s in %s] The Exuari are coming",protect_station:getCallSign(),protect_station:getSectorName()),"Magenta")
						else
							local cp = nil
							for pidx=1,8 do
								local p = getPlayerShip(pidx)
								if p ~= nil and p:isValid() then
									if cp == nil then
										cp = p
									else
										if distance(p,protect_station) < distance(cp,protect_station) then
											cp = p
										end
									end
								end
							end
							if cp ~= nil then
								protect_station.marauder_choice = cp
								protect_station.marauder_choice:addToShipLog(string.format("[%s in %s] The Exuari are coming",protect_station:getCallSign(),protect_station:getSectorName()),"Magenta")
							end
						end
						protect_station.marauder_warning = "done"
						break
					end
				end
			end
		end
		for pidx=1,8 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() and distance(p,protect_station) < 25000 then
				if protect_station.marauder_station_fleet == nil then
					local px, py = p:getPosition()
					local sx, sy = protect_station:getPosition()
					protect_station.marauder_station_fleet = spawnEnemies((px+sx)/2,(py+sy)/2,1,"Exuari")
					for _, enemy in ipairs(protect_station.marauder_station_fleet) do
						enemy:orderAttack(protect_station)
					end
					protect_station.marauder_player_fleet = spawnEnemies((px+sx)/2,(py+sy)/2,1,"Exuari")
					for _, enemy in ipairs(protect_station.marauder_player_fleet) do
						enemy:orderAttack(p)
					end
				end
				plot1 = marauderVanguard
				break
			end
		end
	else
		showEndStats(string.format("Station %s destroyed",protect_station:getCallSign()))
		victory("Exuari")
	end
end
function marauderVanguard(delta)
	if protect_station ~= nil and protect_station:isValid() then
		if protect_station.vanguard_timer == nil then
			protect_station.vanguard_timer = delta + 300
		end
		protect_station.vanguard_timer = protect_station.vanguard_timer - delta
		if protect_station.vanguard_timer < 0 then
			local vx, vy = vectorFromAngle(random(0,360),random(9000,14000))
			local sx, sy = protect_station:getPosition()
			protect_station.vanguard_fleet = spawnEnemies(vx+sx,vy+sy,2*difficulty,"Exuari")
			for _, enemy in ipairs(protect_station.vanguard_fleet) do
				enemy:orderFlyTowards(sx,sy)
			end
			plot1 = marauderFleetDestroyed
		end
	else
		showEndStats(string.format("Station %s destroyed",protect_station:getCallSign()))
		victory("Exuari")
	end
end
function marauderFleetDestroyed(delta)
	if protect_station ~= nil and protect_station:isValid() then
		local marauder_count = 0
		for _, enemy in pairs(protect_station.initial_marauder_fleet) do
			if enemy ~= nil and enemy:isValid() then
				marauder_count = marauder_count + 1
				break
			end
		end
		for _, enemy in pairs(protect_station.marauder_station_fleet) do
			if enemy ~= nil and enemy:isValid() then
				marauder_count = marauder_count + 1
				break
			end
		end
		for _, enemy in pairs(protect_station.marauder_player_fleet) do
			if enemy ~= nil and enemy:isValid() then
				marauder_count = marauder_count + 1
				break
			end
		end
		for _, enemy in pairs(protect_station.vanguard_fleet) do
			if enemy ~= nil and enemy:isValid() then
				marauder_count = marauder_count + 1
				break
			end
		end
		if marauder_count < 1 then
			plot1 = nil
			mission_complete_count = mission_complete_count + 1
			plotChoiceStation = primusStation
			local reputationPending = true
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					p:addToShipLog(string.format("[Engineering Technician] For helping against the Exuari marauders, %s has provided us details on improving our maneuvering speed.",protect_station:getCallSign()),"Magenta")
					p:addToShipLog(string.format("Dock with %s",primusStation:getCallSign()),"Magenta")
					p:setRotationMaxSpeed(p:getRotationMaxSpeed()*2)
					if reputationPending then
						p:addReputationPoints(50)
						reputationPending = false
					end
				end
			end
			playVoice("Jamie02")
			primaryOrders = string.format("Dock with %s",primusStation:getCallSign())
		end
	else
		showEndStats(string.format("Station %s destroyed",protect_station:getCallSign()))
		victory("Exuari")
	end
end
-- BELT STATION PLOT Piracy
function startPiracy()
	setUpPiracy = "done"
	protectTransport = nearStations(belt1Stations[1],transportsOutsideBelt2List)
	local tpmx, tpmy = protectTransport:getPosition()
	local pirx, piry = vectorFromAngle(random(0,360),random(10000,20000)-(3000*difficulty))
	piracyFleet = spawnEnemies(tpmx+pirx, tpmy+piry, 1, "Exuari")
	for _, enemy in ipairs(piracyFleet) do
		enemy:orderFlyTowards(tpmx, tpmy)
	end
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			p:addToShipLog(string.format("%s in %s reports Exuari pirates threatening them",protectTransport:getCallSign(),protectTransport:getSectorName()),"Magenta")
		end
	end
	primaryOrders = string.format("Protect %s from Exuari pirates. Last reported in %s",protectTransport:getCallSign(),protectTransport:getSectorName())
end
function piracyPlot(delta)
	if setUpPiracy == nil then
		startPiracy()
	end
	plot1 = checkPiracyEvents
end
function checkPiracyEvents(delta)
	if protectTransport == nil or not protectTransport:isValid() then
		showEndStats("Transport destroyed")
		victory("Exuari")
	end
	local piracyFleetCount = 0
	if piracyFleet ~= nil then
		for _, enemy in pairs(piracyFleet) do
			if enemy ~= nil and enemy:isValid() then
				piracyFleetCount = piracyFleetCount + 1
				break
			end
		end
		if piracyFleetCount < 1 then
			plot1 = nil
			mission_complete_count = mission_complete_count + 1
			plotChoiceStation = belt1Stations[1]
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					p:addToShipLog(string.format("[%s] Thanks for dealing with those Exuari pirates",protectTransport:getCallSign()),"Magenta")
				end
			end
			primaryOrders = string.format("Dock with %s",belt1Stations[1]:getCallSign())
			piracy = "done"
		end
	end
end
-- BELT STATION PLOT Virus Outbreak
function startVirus()
	set_up_virus = "done"
	local virus_player_count = 0
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			p.virus_cure = false
			p.virus_cure_button = "empty"
			virus_player_count = virus_player_count + 1
		end
	end
	for i=1,#belt1Stations do
		belt1Stations[i].virus_cure = false
	end
	virus_timer = (720 - difficulty*120)/virus_player_count
	max_virus_timer = virus_timer
	virus_harass = false
end
function virusOutbreak(delta)
	if set_up_virus == nil then
		startVirus()
	end
	plot1 = checkVirusEvents
end
function checkVirusEvents(delta)
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if p:isDocked(belt1Stations[4]) and not p.virus_cure then
				p.virus_cure = true
				p:addToShipLog(string.format("[%s medical quartermaster] Anti-virus loaded aboard your ship",belt1Stations[4]:getCallSign()),"Magenta")
				playVoice("Phoenix01")
				belt1Stations[4].virus_cure = true
			end
			if p.virus_cure then
				if p.virus_cure_button == "empty" then
					p.virus_cure_button = "virus_cure_button" .. p:getCallSign()
					p:addCustomButton("Relay",p.virus_cure_button,"Virus status",virus_status_functions[pidx])
				end
				for i=1,#belt1Stations do
					local current_belt1_station = belt1Stations[i]
					if p:isDocked(current_belt1_station) and not current_belt1_station.virus_cure then
						current_belt1_station.virus_cure = true
						p:addToShipLog(string.format("[%s Medical Team] Received Anti-virus. Administering to station personnel. Thanks %s",current_belt1_station:getCallSign(),p:getCallSign()),"Magenta")
					end
				end
			end
		end
	end
	local station_cure_count = 0
	for i=1,#belt1Stations do
		if belt1Stations[i].virus_cure then
			station_cure_count = station_cure_count + 1
		end
	end
	if station_cure_count < #belt1Stations then
		virus_timer = virus_timer - delta
		if virus_timer < 0 then
			playVoice("Tracy13")
			showEndStats("Pandemic")
			victory("Exuari")
		else
			if station_cure_count >= 3 and not virus_harass then
				--add harassing Exuari here
				virus_harass = true
				local per_station = max_virus_timer/5
				if virus_timer < (max_virus_timer - (3 * per_station)) then
					playVoice("Tracy12")
				end
				for pidx=1,8 do
					local p = getPlayerShip(pidx)
					if p ~= nil and p:isValid() and p.virus_cure then
						local phx, phy = p:getPosition()
						local virus_fleet = spawnEnemies(phx, phy, 1, "Exuari", 2000 - difficulty*100, 4000)
						for enemy in pairs(virus_fleet) do
							enemy:orderAttack(p)
						end
					end
				end
			end
			local virus_minutes = math.floor(virus_timer / 60)
			local virus_seconds = math.floor(virus_timer % 60)
			local virus_status = "Virus Fatality"
			if virus_minutes <= 0 then
				virus_status = string.format("%s: %i",virus_status,virus_seconds)
			else
				virus_status = string.format("%s: %i:%.2i",virus_status,virus_minutes,virus_seconds)
			end
			for pidx=1,8 do
				local p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					if p:hasPlayerAtPosition("Science") then
						p.virus_status = "virus_status"
						p:addCustomInfo("Science",p.virus_status,virus_status)
					end
					if p:hasPlayerAtPosition("Operations") then
						p.virus_status_operations = "virus_status_operations"
						p:addCustomInfo("Operations",p.virus_status_operations,virus_status)
					end
				end
			end
		end
	else
		plot1 = nil
		mission_complete_count = mission_complete_count + 1
		plotChoiceStation = belt1Stations[1]
		primaryOrders = string.format("Dock with %s",belt1Stations[1]:getCallSign())
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(string.format("Stations have been saved from the virus outbreak. Dock with %s for further orders",belt1Stations[1]:getCallSign()),"Magenta")
				if p.virus_cure_button ~= nil and p.virus_cure_button ~= "empty" then
					p:removeCustom(p.virus_cure_button)
					p.virus_cure_button = "empty"
				end
				if p.virus_status ~= nil then
					p:removeCustom(p.virus_status)
					p.virus_status = nil
				end
				if p.virus_status_operations ~= nil then
					p:removeCustom(p.virus_status_operations)
					p.virus_status_operations = nil
				end
			end
		end
		playVoice("Tracy07")
	end
end
function virusStatusP1()
	local p = getPlayerShip(1)
	virusStatus(p)
end
function virusStatusP2()
	local p = getPlayerShip(2)
	virusStatus(p)
end
function virusStatusP3()
	local p = getPlayerShip(3)
	virusStatus(p)
end
function virusStatusP4()
	local p = getPlayerShip(4)
	virusStatus(p)
end
function virusStatusP5()
	local p = getPlayerShip(5)
	virusStatus(p)
end
function virusStatusP6()
	local p = getPlayerShip(6)
	virusStatus(p)
end
function virusStatusP7()
	local p = getPlayerShip(7)
	virusStatus(p)
end
function virusStatusP8()
	local p = getPlayerShip(8)
	virusStatus(p)
end
function virusStatus(p)
	local virus_minutes = math.floor(virus_timer / 60)
	local status_message = "First virus fatality in"
	if virus_minutes < 1 then
		status_message = string.format("%s %.f seconds.",status_message,virus_timer)
	else
		status_message = string.format("%s %i minutes.",status_message,virus_minutes)
	end
	local stations_needing_antivirus = ". Stations needing anti-virus: "
	for i=1,#belt1Stations do
		local current_belt1_station = belt1Stations[i]
		if not current_belt1_station.virus_cure then
			stations_needing_antivirus = stations_needing_antivirus .. current_belt1_station:getCallSign() .. "  "
		end
	end
	status_message = status_message .. stations_needing_antivirus
	p:addToShipLog(status_message,"Yellow")
end
-- BELT STATION PLOT Exuari Target Intelligence
function startTargetIntel()
	set_up_target_intel = "done"
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			p.target_intel = false
		end
	end
	intel_station = playerSpawnBandStations[1]
	local intel_station_index = 1
	intel_station = playerSpawnBandStations[intel_station_index]
	while (intel_station_index <= 6 and intel_station == nil) do
		intel_station_index = intel_station_index + 1
		intel_station = playerSpawnBandStations[intel_station_index]
	end
	if intel_station_index > 6 then
		playVoice("Tracy11")
		showEndStats("Exuari destroyed target station")
		victory("Exuari")
		return
	end
	target_station = playerSpawnBandStations[intel_station_index + 2]
	primaryOrders = string.format("Dock with %s in %s for Exuari intelligence",intel_station:getCallSign(),intel_station:getSectorName())
	intel_attack = false
end
function targetIntel(delta)
	if set_up_target_intel == nil then
		startTargetIntel()
	end
	plot1 = checkTargetIntelEvents
end
function checkTargetIntelEvents(delta)
	if intel_station == nil or not intel_station:isValid() or target_station == nil or not target_station:isValid() then
		playVoice("Tracy10")
		showEndStats("Exuari destroyed station")
		victory("Exuari")
	end
	local iwpx, iwpy = target_station:getPosition()
	for pidx=1,8 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if p:isDocked(intel_station) and p.intel_message == nil then
				p.target_intel = true
				p:addToShipLog(string.format("Intelligence report: the Exuari have chosen %s in %s as their next target for attack. Make sure they do not succeed",target_station:getCallSign(),target_station:getSectorName()),"Magenta")
				p.intel_message = "sent"
				if p:getWaypointCount() < 9 and p.intel_waypoint == nil then
					p:commandAddWaypoint(iwpx,iwpy)
					p:addToShipLog(string.format("Added waypoint %i to your navigation system for %s",p:getWaypointCount(),target_station:getCallSign()),"Magenta")
					playVoice("Tracy08")
					p.intel_waypoint = "added"
				end
			else
				if p.target_intel and not intel_attack then
					local plx, ply = p:getPosition()
					intel_fleet_player = spawnEnemies((plx+iwpx)/2, (ply+iwpy)/2, 1, "Exuari")
					for _, enemy in ipairs(intel_fleet_player) do
						enemy:orderFlyTowards(plx,ply)
					end
					intel_fleet_station = spawnEnemies((plx+iwpx)/2 + 1000, (ply+iwpy)/2 + 1000, 1, "Exuari")
					for _, enemy in ipairs(intel_fleet_station) do
						enemy:orderFlyTowards(iwpx,iwpy)
					end
					intel_attack = true
				end
			end
		end
	end
	if intel_attack then
		local intel_fleet_count = 0
		for _, enemy in pairs(intel_fleet_player) do
			if enemy ~= nil and enemy:isValid() then
				intel_fleet_count = intel_fleet_count + 1
				break
			end
		end
		for _, enemy in pairs(intel_fleet_station) do
			if enemy ~= nil and enemy:isValid() then
				intel_fleet_count = intel_fleet_count + 1
				break
			end
		end
		if intel_fleet_count < 1 then
			plot1 = nil
			mission_complete_count = mission_complete_count + 1
			plotChoiceStation = belt1Stations[1]
			for pidx=1,8 do
				local p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					p:addToShipLog("Looks like you thwarted that Exuari attack","Magenta")
				end
			end
			playVoice("Tracy09")
			primaryOrders = string.format("Dock with %s",belt1Stations[1]:getCallSign())
		end
	end
end
-- TERTIUS PLOT Exuari Exterminate Extraterrestrials
function startExterminate()
	set_up_exterminate = "done"
	primaryOrders = "Make a good showing for the Human Navy against the Exuari invasion"
	exterminate_interval = 300 - 50*difficulty
	exterminate_timer = exterminate_interval
	docked_with_tertius = true
	exterminate_fleet_list = {}
	exuari_danger = 1
	for pidx=1,8 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			local plx, ply = p:getPosition()
			local eFleet = spawnEnemies(plx,ply,exuari_danger,"Exuari",4000,6000)
			for _, enemy in ipairs(eFleet) do
				enemy:orderAttack(p)
			end
			table.insert(exterminate_fleet_list,eFleet)
		end
	end
end
function exterminate(delta)
	if set_up_exterminate == nil then
		startExterminate()
	end
	plot1 = checkExterminateEvents
end
function checkExterminateEvents(delta)
	if docked_with_tertius then
		if tertiusStation:isValid() then
			docked_with_tertius = false
			for pidx=1,8 do
				local p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					if p:isDocked(tertiusStation) then
						docked_with_tertius = true
						break
					end
				end
			end
		else
			docked_with_tertius = false
		end
	else
		exterminate_timer = exterminate_timer - delta
	end
	if exterminate_timer < 0 then
		exuari_danger = exuari_danger + 1
		for pidx=1,8 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				local plx, ply = p:getPosition()
				local eFleet = spawnEnemies(plx,ply,exuari_danger,"Exuari",2000,6000)
				for _, enemy in ipairs(eFleet) do
					enemy:orderAttack(p)
				end
				table.insert(exterminate_fleet_list,eFleet)
			end
		end
		plx, ply = vectorFromAngle(random(0,360),tertiusMoonOrbit+1000)
		local tx, ty = planetTertius:getPosition()
		eFleet = spawnEnemies(tx+plx,ty+ply,exuari_danger*2,"Exuari")
		for _, enemy in ipairs(eFleet) do
			enemy:orderRoaming()
		end
		table.insert(exterminate_fleet_list,eFleet)
		exterminate_timer = delta + exterminate_interval
	end
	local exuari_enemy_count = 0
	for _, fleet in pairs(exterminate_fleet_list) do
		for _, enemy in pairs(fleet) do
			if enemy ~= nil and enemy:isValid() then
				exuari_enemy_count = exuari_enemy_count + 1
			end
		end
	end
	if exuari_enemy_count < exuari_danger then
		exuari_danger = exuari_danger + 1
		for pidx=1,8 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				plx, ply = p:getPosition()
				eFleet = spawnEnemies(plx,ply,exuari_danger,"Exuari",2000,6000)
				for _, enemy in ipairs(eFleet) do
					enemy:orderAttack(p)
				end
				table.insert(exterminate_fleet_list,eFleet)
			end
		end
	end
end
-- TERTIUS PLOT Eliminate Exuari stronghold
function startStronghold()
	set_up_stronghold = "done"
	primaryOrders = "Find and eliminate the Exuari station that is sending all these ships after us"
	local esx, esy = vectorFromAngle(random(10,80),random(tertiusOrbit + tertiusMoonOrbit + 50000,tertiusOrbit + tertiusMoonOrbit + 100000))
	psx = solX+esx
	psy = solY+esy
	stationFaction = "Exuari"
	stationStaticAsteroids = true
	si = math.random(1,#placeEnemyStation)		--station index
	pStation = placeEnemyStation[si]()			--place selected station
	table.remove(placeEnemyStation,si)			--remove station from placement list
	table.insert(stationList,pStation)			--save station in general station list
	table.insert(exuariStationList,pStation)	--save station in exuari station list
	exuari_stronghold = pStation
	stronghold_interval = 300 - 50*difficulty
	stronghold_timer = stronghold_interval
	exuari_danger = 1
	for pidx=1,8 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			local plx, ply = p:getPosition()
			local eFleet = spawnEnemies(plx,ply,exuari_danger,"Exuari",4000,6000)
			for _, enemy in ipairs(eFleet) do
				enemy:orderAttack(p)
			end
		end
	end
end
function stronghold(delta)
	if set_up_stronghold == nil then
		startStronghold()
	end
	plot1 = checkStrongholdEvents
end
function checkStrongholdEvents(delta)
	if exuari_stronghold == nil or not exuari_stronghold:isValid() then
		mission_complete_count = mission_complete_count + 1
		showEndStats("Exuari stronghold destroyed")
		victory("Human Navy")
	end
	stronghold_timer = stronghold_timer - delta
	if stronghold_timer < 0 then
		local p = closestPlayerTo(exuari_stronghold)
		if p ~= nil then
			local plx, ply = p:getPosition()
			if random(1,100) < 50 then
				local eFleet = spawnEnemies(plx,ply,exuari_danger,"Exuari",4000,6000)
				for _, enemy in ipairs(eFleet) do
					enemy:orderAttack(p)
				end
				if random(1,100) < 50 then
					WarpJammer():setRange(8000):setPosition(plx+3000,ply+3000):setFaction("Exuari")
				end
			else
				local esx, esy = exuari_stronghold:getPosition()
				eFleet = spawnEnemies((plx+esx)/2,(ply+esy)/2,exuari_danger,"Exuari")
				for _, enemy in ipairs(eFleet) do
					enemy:orderRoaming()
				end
			end
		else
			local plx, ply = exuari_stronghold:getPosition()
			local eFleet = spawnEnemies(plx,ply,exuari_danger,"Exuari",4000,6000)
			for _, enemy in ipairs(eFleet) do
				enemy:orderStandGround()
			end
		end
		exuari_danger = exuari_danger + 1
		stronghold_timer = delta + stronghold_interval
	end
end
-- TERTIUS PLOT Eliminate Exuari stronghold
function startSurvive()
	set_up_survive = "done"
	primaryOrders = "Survive until the game time runs out"
	survive_interval = 300 - 50*difficulty
	survive_timer = survive_interval
	exuari_danger = 1
	for pidx=1,8 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			local plx, ply = p:getPosition()
			local eFleet = spawnEnemies(plx,ply,exuari_danger,"Exuari",4000,6000)
			for _, enemy in ipairs(eFleet) do
				enemy:orderAttack(p)
			end
		end
	end
end
function survive(delta)
	if set_up_survive == nil then
		startSurvive()
	end
	plot1 = checkSurviveEvents
end
function checkSurviveEvents(delta)
	gameTimeLimit = gameTimeLimit - delta
	if gameTimeLimit < 0 then
		mission_complete_count = mission_complete_count + 1
		showEndStats("Survived Exuari Attacks")
		victory("Human Navy")
	else
		survive_timer = survive_timer - delta
		if survive_timer < 0 then
			exuari_danger = exuari_danger + 1
			for pidx=1,8 do
				local p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					local plx, ply = p:getPosition()
					local eFleet = spawnEnemies(plx,ply,exuari_danger,"Exuari",4000,6000)
					for _, enemy in ipairs(eFleet) do
						enemy:orderAttack(p)
					end
					if random(1,100) < 50 then
						WarpJammer():setRange(8000):setLocation(plx+3000,ply-3000):setFaction("Exuari")
					end
				end
			end
			survive_timer = delta + survive_interval
		end
	end
end
-- Working transports plot
function workingTransports(delta)
	transportCheckDelayTimer = transportCheckDelayTimer - delta
	if transportCheckDelayTimer < 0 then
		for _, wt in pairs(transportsInPlayerSpawnBandList) do
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
		for _, wt in pairs(transportsOutsideBelt2List) do
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
-- Manage plots
function setPlots()
	plotList = {fixSatellites,
				transportPrimusResearcher,
				orbitingArtifact,
				defendSpawnBandStation}
	plotListMessage = {string.format("Satellite stations %s, %s and %s orbiting %s have been reporting periodic problems. See what you can do to help them out",secondusStations[1]:getCallSign(),secondusStations[2]:getCallSign(),secondusStations[3]:getCallSign(),planetSecondus:getCallSign()),
					   string.format("Planetologist Enrique Flogistan plans to study %s. However, his transport refuses to travel in the area due to increased Exuari activity. Dock with %s and transport the planetologist to %s",planetPrimus:getCallSign(),belt1Stations[2]:getCallSign(),primusStation:getCallSign()),
					   string.format("Analysis of sightings and readings taken by civilian astronmer Polly Hobbs shows anomalous readings in this area. She lives on station %s according to her published research. Find her, get the source data and investigate. Solicit her assistance if she's willing",belt1Stations[5]:getCallSign()),
					   "Intelligence indicates an imminent attack by the Exuari on a station in the area. Your mission is to protect the station"}
	plotListOrders = {string.format("Fix satellites orbiting %s",planetSecondus:getCallSign()),
					  string.format("Transport planetologist from %s to %s",belt1Stations[2]:getCallSign(),primusStation:getCallSign()),
					  string.format("Dock with %s to investigate astronomer's unusual data",belt1Stations[5]:getCallSign()),
					  "Defend station from Exuari attack"}
	maxPlotCount = #plotList
	initialMission = true
	plotList2 = {piracyPlot,
				 virusOutbreak,
				 targetIntel}
	plotListMessage2 = {"A transport reports Exuari pirates threatening them",
						string.format("Stations %s, %s, %s, %s and %s all report outbreaks of a variant of Rathgar's space virus. %s has developed an effective anti-virus, but it needs to be delivered to all the stations quickly",belt1Stations[1]:getCallSign(),belt1Stations[2]:getCallSign(),belt1Stations[3]:getCallSign(),belt1Stations[4]:getCallSign(),belt1Stations[5]:getCallSign(),belt1Stations[4]:getCallSign()),
						string.format("Station %s in %s has intelligence on where the Exuari are attacking next",playerSpawnBandStations[1]:getCallSign(),playerSpawnBandStations[1]:getSectorName())}
	plotListOrders2 = {"Protect transport from Exuari pirates",
						string.format("Dock with %s to pick up anti-virus",belt1Stations[4]:getCallSign()),
						string.format("Dock with %s in %s for Exuari intelligence",playerSpawnBandStations[1]:getCallSign(),playerSpawnBandStations[1]:getSectorName())}
	piracy = "available"
	plotCI = cargoInventory			--manage button on relay/operations to show cargo inventory
end
function plotDelay(delta)
	if plotDelayTimer == nil then
		plotDelayTimer = delta + random(10,30)
	end
	plotDelayTimer = plotDelayTimer - delta
	if plotDelayTimer < 0 then
		plotDelayTimer = nil
		plotManager = plotChoose
	end
end
function plotChoose(delta)
	if initialMission then
		plotManager = plotRun
		plot1 = defendPrimusStation
	else
		if plotChoiceStation == nil then
			--no mission choices via station dock. Select more here or end scenario
			showEndStats()
			victory("Human Navy")
		else
			if not plotChoiceStation:isValid() then
				--migratory headquarters destroyed
				showEndStats("Critical station destroyed")
				victory("Exuari")
			end
		end
	end
end
function plotRun(delta)
	if plot1 == nil then
		plotManager = plotDelay
	end
end
-- End of plot related functions
function showEndStats(reason)
	local stat_message = "Human stations destroyed: "
	if #humanStationDestroyedNameList ~= nil and #humanStationDestroyedNameList > 0 then
		stat_message = stat_message .. #humanStationDestroyedNameList
		local station_strength = 0
		for i=1,#humanStationDestroyedNameList do
			station_strength = station_strength + humanStationDestroyedValue[i]
		end
		stat_message = stat_message .. string.format(" (total strength: %i)",station_strength)
	else
		stat_message = stat_message .. "none"
	end
	stat_message = stat_message .. "\nNeutral stations destroyed: "
	if #neutralStationDestroyedNameList ~= nil and #neutralStationDestroyedNameList > 0 then
		stat_message = stat_message .. #neutralStationDestroyedNameList
		station_strength = 0
		for i=1,#neutralStationDestroyedNameList do
			station_strength = station_strength + neutralStationDestroyedValue[i]
		end
		stat_message = stat_message .. string.format(" (total strength: %i)",station_strength)
	else
		stat_message = stat_message .. "none"
	end
	stat_message = stat_message .. "\nKraylor vessels destroyed: "
	if #kraylorVesselDestroyedNameList ~= nil and #kraylorVesselDestroyedNameList > 0 then
		stat_message = stat_message .. #kraylorVesselDestroyedNameList
		station_strength = 0
		for i=1,#kraylorVesselDestroyedNameList do
			station_strength = station_strength + kraylorVesselDestroyedValue[i]
		end
		stat_message = stat_message .. string.format(" (total strength: %i)",station_strength)
	else
		stat_message = stat_message .. "none"
	end
	stat_message = stat_message .. "\n\n\n\nExuari vessels destroyed: "
	if #exuariVesselDestroyedNameList ~= nil and #exuariVesselDestroyedNameList > 0 then
		stat_message = stat_message .. #exuariVesselDestroyedNameList
		station_strength = 0
		for i=1,#exuariVesselDestroyedNameList do
			station_strength = station_strength + exuariVesselDestroyedValue[i]
		end
		stat_message = stat_message .. string.format(" (total strength: %i)",station_strength)
	else
		stat_message = stat_message .. "none"
	end
	stat_message = stat_message .. "\nArlenian vessels destroyed: "
	if #arlenianVesselDestroyedNameList ~= nil and #arlenianVesselDestroyedNameList > 0 then
		stat_message = stat_message .. #arlenianVesselDestroyedNameList
		station_strength = 0
		for i=1,#arlenianVesselDestroyedNameList do
			station_strength = station_strength + arlenianVesselDestroyedValue[i]
		end
		stat_message = stat_message .. string.format(" (total strength: %i)",station_strength)
	else
		stat_message = stat_message .. "none"
	end
	stat_message = stat_message .. string.format("\nMissions completed: %i",mission_complete_count)
	if reason ~= nil then
		stat_message = stat_message .. "\n" .. reason
	end
	globalMessage(stat_message)
end
function setPlayers()
	local concurrentPlayerCount = 0
	for p1idx=1,8 do
		pobj = getPlayerShip(p1idx)
		if pobj ~= nil and pobj:isValid() then
			concurrentPlayerCount = concurrentPlayerCount + 1
			if pobj.initialRep == nil then
				pobj:addReputationPoints(200-(difficulty*40))
				pobj.initialRep = true
			end
			if not pobj.nameAssigned then
				pobj.nameAssigned = true
				local tempPlayerType = pobj:getTypeName()
				if p1idx % 2 == 0 then
					pobj:setPosition(playerSpawn1X,playerSpawn1Y)
				else
					pobj:setPosition(playerSpawn2X,playerSpawn2Y)
				end
				if tempPlayerType == "MP52 Hornet" then
					if #playerShipNamesForMP52Hornet > 0 then
						local ni = math.random(1,#playerShipNamesForMP52Hornet)
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
				elseif tempPlayerType == "Atlantis II" then
					if #playerShipNamesForAtlantisII > 0 then
						ni = math.random(1,#playerShipNamesForAtlantisII)
						pobj:setCallSign(playerShipNamesForAtlantisII[ni])
						table.remove(playerShipNamesForAtlantisII,ni)
					end
					pobj.shipScore = 60
					pobj.maxCargo = 5
				elseif tempPlayerType == "Proto-Atlantis" then
					if #playerShipNamesForProtoAtlantis > 0 then
						ni = math.random(1,#playerShipNamesForProtoAtlantis)
						pobj:setCallSign(playerShipNamesForProtoAtlantis[ni])
						table.remove(playerShipNamesForProtoAtlantis,ni)
					end
					pobj.shipScore = 40
					pobj.maxCargo = 4
				elseif tempPlayerType == "Surkov" then
					if #playerShipNamesForSurkov > 0 then
						ni = math.random(1,#playerShipNamesForSurkov)
						pobj:setCallSign(playerShipNamesForSurkov[ni])
						table.remove(playerShipNamesForSurkov,ni)
					end
					pobj.shipScore = 35
					pobj.maxCargo = 6
				elseif tempPlayerType == "Redhook" then
					if #playerShipNamesForRedhook > 0 then
						ni = math.random(1,#playerShipNamesForRedhook)
						pobj:setCallSign(playerShipNamesForRedhook[ni])
						table.remove(playerShipNamesForRedhook,ni)
					end
					pobj.shipScore = 18
					pobj.maxCargo = 8
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
				local playerCallSign = pobj:getCallSign()
				goods[playerCallSign] = {}
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
	return concurrentPlayerCount
end
function update(delta)
	if delta == 0 then	--game paused
		setPlayers()
		return
	end
	if updateDiagnostic then print("set players") end
	local concurrentPlayerCount = setPlayers()
	if updateDiagnostic then print("concurrent player count: " .. concurrentPlayerCount) end
	if concurrentPlayerCount < 1 then	--do nothing until player ship is spawned
		return
	end
	if updateDiagnostic then print("plotManager") end
	if plotManager ~= nil then
		plotManager(delta)
	end
	if updateDiagnostic then print("plot1") end
	if plot1 ~= nil then	--various primary plot lines
		plot1(delta)
	end
	if updateDiagnostic then print("plot2") end
	if plot2 ~= nil then	--continued time travel
		plot2(delta)
	end
	if updateDiagnostic then print("plot3") end
	if plot3 ~= nil then	--transport cleanup
		plot3(delta)
	end
	if updateDiagnostic then print("plotT") end
	if plotT ~= nil then	--working transports 
		plotT(delta)
	end
	if updateDiagnostic then print("plotM") end
	if plotM ~= nil then	--moving objects
		plotM(delta)
	end
	if plotCI ~= nil then	--cargo inventory
		plotCI(delta)
	end
	if plotH ~= nil then	--health
		plotH(delta)
	end
	if plotCN ~= nil then	--coolant via nebula
		plotCN(delta)
	end
	if plotV ~= nil then	--voice handling
		plotV(delta)
	end
end