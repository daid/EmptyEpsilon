-- Name: Unwanted Visitors
-- Description: Get rid of the unwanted visitors. Other missions follow. Check friendly stations for mission orders. Dispatch office provides new missions. Continue or stand down after each mission. 
---
--- Each mission takes 15 - 50 minutes. That can add up. Four missions in the first area, three in the second area and in the third area, one open ended mission, chosen from three possibilities.
---
--- When returning to this scenario, choose "selectable" to perform missions you have not yet completed. Choose "Random" to be surprised at the missions selected.
---
--- GM buttons slow or speed celestial body orbits, turn on or off server voices, insert unique player ships or end the mission.
---
--- USN Discord: https://discord.gg/PntGG3a where you can join a game online.
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
--- Version 2
-- Type: Replayable Mission
-- Setting[Enemies]: Configures the strength of the enemies
-- Enemies[Easy]: Enemies are weaker or fewer than normal
-- Enemies[Normal|Default]: Enemies are normal strength
-- Enemies[Hard]: Enemies are stronger or more numerous than normal
-- Enemies[Extreme]: Much stronger, many more enemies
-- Enemies[Quixotic]: Insanely strong and/or inordinately large numbers of enemies
-- Setting[Murphy]: Configures the perversity of the universe according to Murphy's law
-- Murphy[Easy]: Random factors are more in your favor
-- Murphy[Normal|Default]: Random factors are normal
-- Murphy[Hard]: Random factors are more against you
-- Setting[Mission]: Configures the scenario missions. There are different regions with missions. The default setting lets the players choose to move to the next region. The players must always complete the first mission.
-- Mission[Random]: The next mission is randomly selected
-- Mission[Region|Default]: Players may skip to the next region of missions
-- Mission[Selectable]: Players may choose each individual mission in each region

--	Custom Info Indexes
--		Virus Fatality Timer	4
--		Gather Coolant			8
--		Sensor scan time		10

--	Custom Button Indexes
--		Virus Status	9
--		Inventory		6
--		Get Coolant		7
--		Polly scan time	11

require("utils.lua")
require("generate_call_sign_scenario_utility.lua")
require("place_station_scenario_utility.lua")
require("cpu_ship_diversification_scenario_utility.lua")

function init()
	scenario_version = "2.0.7"
	ee_version = "2023.06.17"
	print(string.format("    ----    Scenario: Unwanted Visitors    ----    Version %s    ----    Tested with EE version %s    ----",scenario_version,ee_version))
	print(_VERSION)
	--stationCommunication could be nil (default), commsStation (embedded function) or comms_station_enhanced (external script)
	stationCommunication = "commsStation"
	setVariations()
	setGlobals()
	setConstants()	--missle type names, template names and scores, deployment directions, player ship names, etc.
	buildLocalSolarSystem()
	setOptionalMissions()
	setPlots()
	plotManager = plotDelay
	--Damage to ship can kill repair crew members
	healthCheckTimer = 5
	healthCheckTimerInterval = 5
	mission_complete_count = 0
	mission_region = 0
	mainGMButtons()
end
function setGlobals()
	updateDiagnostic = false
	stationCommsDiagnostic = false
	planetologistDiagnostic = false
	moveDiagnostic = false
	fixSatelliteDiagnostic = false
	shipCommsDiagnostic = false
	goods = {}					--overall tracking of goods
	tradeFood = {}				--stations that will trade food for other goods
	tradeLuxury = {}			--stations that will trade luxury for other goods
	tradeMedicine = {}			--stations that will trade medicine for other goods
	server_voices = true
	voice_queue = {}
	voice_played = {}
end
---------------------------
-- Game Master functions --
---------------------------
function mainGMButtons()
	clearGMFunctions()
	addGMFunction(_("buttonGM","+Player ships"),playerShipGMButtons)
	addGMFunction(_("buttonGM","+Adjust speed"),adjustSpeedGMButtons)
	addGMFunction(_("buttonGM","+End Mission"),endMissionGMButtons)
	addGMFunction(_("buttonGM","+Voices"),adjustServerVoices)
end
-- GM player ship functions
function playerShipGMButtons()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main"),mainGMButtons)
	if playerNarsil == nil then
		addGMFunction(_("buttonGM","Narsil"),createPlayerShipNarsil)
	end
	if playerHeadhunter == nil then
		addGMFunction(_("buttonGM","Headhunter"),createPlayerShipHeadhunter)
	end
	if playerBlazon == nil then
		addGMFunction(_("buttonGM","Blazon"),createPlayerShipBlazon)
	end
	if playerSting == nil then
		addGMFunction(_("buttonGM","Sting"),createPlayerShipSting)
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
	playerShipGMButtons()
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
	playerShipGMButtons()
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
	playerShipGMButtons()
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
	playerShipGMButtons()
end
-- GM adjust speed functions
function adjustSpeedGMButtons()
	if speed_button_explanation == nil then
		speed_button_explanation = "sent"
		addGMMessage(string.format(_("msgGM","Primus is the planet closest to the sun. Secondus is the next planet out from the sun. Tertius is the third planet out from the sun. Sol Belt 1 is the belt of asteroids and stations closest to the sun. Sol Belt 2 is the next one out. Tertius moon belt is the asteroid, moon and station belt orbiting Tertius. Tertius belt 2 is the next one out from Tertius.\n--- Celestial Body Names ---\nSun: %s\nPrimus: %s\nSecondus: %s\nTertius: %s"),planetSol:getCallSign(),planetPrimus:getCallSign(),planetSecondus:getCallSign(),planetTertius:getCallSign()))
	end
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main"),mainGMButtons)
	addGMFunction(_("buttonGM","Primus"),adjustPrimusSpeed)
	addGMFunction(_("buttonGM","Primus Moon"),adjustPrimusMoonSpeed)
	addGMFunction(_("buttonGM","Secondus"),adjustSecondusSpeed)
	addGMFunction(_("buttonGM","Secondus Station"),adjustSecondusStationSpeed)
	addGMFunction(_("buttonGM","Sol Belt 1"),adjustSolBelt1Speed)
	addGMFunction(_("buttonGM","Sol Belt 2"),adjustSolBelt2Speed)
	addGMFunction(_("buttonGM","Tertius"),adjustTertiusSpeed)
	addGMFunction(_("buttonGM","Tertius Moon Belt"),adjustTertiusMoonBeltSpeed)
	addGMFunction(_("buttonGM","Tertius Belt 2"),adjustTertiusBelt2Speed)
end
function adjustPrimusSpeed()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main"),mainGMButtons)
	addGMFunction(_("buttonGM","-From Primus"),adjustSpeedGMButtons)
	addGMFunction(_("buttonGM","Slower"),function()
		local msg = string.format(_("msgGM","Current Primus speed: %.1f"),planetPrimus.orbit_speed)
		planetPrimus.orbit_speed = planetPrimus.orbit_speed * 1.1
		planetPrimus:setOrbit(planetSol,planetPrimus.orbit_speed)
		msg = string.format(_("msgGM","%s\nNew slower Primus speed: %.1f"),msg,planetPrimus.orbit_speed)
		addGMMessage(msg)
	end)
	addGMFunction(_("buttonGM","Faster"),function()
		local msg = string.format(_("msgGM","Current Primus speed: %.1f"),planetPrimus.orbit_speed)
		planetPrimus.orbit_speed = planetPrimus.orbit_speed * .9
		planetPrimus:setOrbit(planetSol,planetPrimus.orbit_speed)
		msg = string.format(_("msgGM","%s\nNew faster Primus speed: %.1f"),msg,planetPrimus.orbit_speed)
		addGMMessage(msg)
	end)
end
function adjustPrimusMoonSpeed()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main"),mainGMButtons)
	addGMFunction(_("buttonGM","-From Primus Moon"),adjustSpeedGMButtons)
	addGMFunction(_("buttonGM","Slower"),function()
		local msg = string.format(_("msgGM","Current Primus moon speed: %.1f"),planetPrimusMoonOrbitTime)
		planetPrimusMoonOrbitTime = planetPrimusMoonOrbitTime * 1.1
		planetPrimusMoon:setOrbit(planetPrimus,planetPrimusMoonOrbitTime)
		msg = string.format(_("msgGM","%s\nNew slower Primus moon speed: %.1f"),msg,planetPrimusMoonOrbitTime)
		addGMMessage(msg)
	end)
	addGMFunction(_("buttonGM","Faster"),function()
		local msg = string.format(_("msgGM","Current Primus moon speed: %.1f"),planetPrimusMoonOrbitTime)
		planetPrimusMoonOrbitTime = planetPrimusMoonOrbitTime * .9
		planetPrimusMoon:setOrbit(planetPrimus,planetPrimusMoonOrbitTime)
		msg = string.format(_("msgGM","%s\nNew faster Primus moon speed: %.1f"),msg,planetPrimusMoonOrbitTime)
		addGMMessage(msg)
	end)
end
function adjustSecondusSpeed()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main"),mainGMButtons)
	addGMFunction(_("buttonGM","-From Secondus"),adjustSpeedGMButtons)
	addGMFunction(_("buttonGM","Slower"),function()
		local msg = string.format(_("msgGM","Current Secondus speed: %.1f"),planetSecondus.orbit_speed)
		planetSecondus.orbit_speed = planetSecondus.orbit_speed * 1.1
		planetSecondus:setOrbit(planetSol,planetSecondus.orbit_speed)
		msg = string.format(_("msgGM","%s\nNew slower Secondus speed: %.1f"),msg,planetSecondus.orbit_speed)
		addGMMessage(msg)
	end)
	addGMFunction(_("buttonGM","Faster"),function()
		local msg = string.format(_("msgGM","Current Secondus speed: %.1f"),planetSecondus.orbit_speed)
		planetSecondus.orbit_speed = planetSecondus.orbit_speed * .9
		planetSecondus:setOrbit(planetSol,planetSecondus.orbit_speed)
		msg = string.format(_("msgGM","%s\nNew faster Secondus speed: %.1f"),msg,planetSecondus.orbit_speed)
		addGMMessage(msg)
	end)
end
function adjustSecondusStationSpeed()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main"),mainGMButtons)
	addGMFunction(_("buttonGM","-From Secondus Stn"),adjustSpeedGMButtons)
	addGMFunction(_("buttonGM","Slower"),function()
		local msg = string.format(_("msgGM","Current Secondus station speed: %.3f"),secondusStationOrbitIncrement)
		secondusStationOrbitIncrement = secondusStationOrbitIncrement * .9
		msg = string.format(_("msgGM","%s\nNew slower Secondus station speed: %.3f"),msg,secondusStationOrbitIncrement)
		addGMMessage(msg)
	end)
	addGMFunction(_("buttonGM","Faster"),function()
		local msg = string.format(_("msgGM","Current Secondus station speed: %.3f"),secondusStationOrbitIncrement)
		secondusStationOrbitIncrement = secondusStationOrbitIncrement * 1.1
		msg = string.format(_("msgGM","%s\nNew faster Secondus station speed: %.3f"),msg,secondusStationOrbitIncrement)
		addGMMessage(msg)
	end)
end
function adjustSolBelt1Speed()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main"),mainGMButtons)
	addGMFunction(_("buttonGM","-From Sol Belt 1"),adjustSpeedGMButtons)
	addGMFunction(_("buttonGM","Slower"),function()
		local msg = string.format(_("msgGM","Current Sol Belt 1 speed: %.3f"),belt1OrbitalSpeed)
		belt1OrbitalSpeed = belt1OrbitalSpeed * .9
		for i=1,#beltAsteroidList do
			local ta = beltAsteroidList[i]
			if ta ~= nil and ta:isValid() and ta.belt_id == "belt1" then
				ta.speed = belt1OrbitalSpeed
			end
		end
		msg = string.format(_("msgGM","%s\nNew slower Sol Belt 1 speed: %.3f"),msg,belt1OrbitalSpeed)
		addGMMessage(msg)
	end)
	addGMFunction(_("buttonGM","Faster"),function()
		local msg = string.format(_("msgGM","Current Sol Belt 1 speed: %.3f"),belt1OrbitalSpeed)
		belt1OrbitalSpeed = belt1OrbitalSpeed * 1.1
		for i=1,#beltAsteroidList do
			local ta = beltAsteroidList[i]
			if ta ~= nil and ta:isValid() and ta.belt_id == "belt1" then
				ta.speed = belt1OrbitalSpeed
			end
		end
		msg = string.format(_("msgGM","%s\nNew faster Sol Belt 1 speed: %.3f"),msg,belt1OrbitalSpeed)
		addGMMessage(msg)
	end)
end
function adjustSolBelt2Speed()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main"),mainGMButtons)
	addGMFunction(_("buttonGM","-From Sol Belt 2"),adjustSpeedGMButtons)
	addGMFunction(_("buttonGM","Slower"),function()
		local msg = string.format(_("msgGM","Current Sol Belt 2 speed: %.3f"),belt2OrbitalSpeed)
		belt2OrbitalSpeed = belt2OrbitalSpeed * .9
		for i=1,#beltAsteroidList do
			local ta = beltAsteroidList[i]
			if ta ~= nil and ta:isValid() and ta.belt_id == "belt2" then
				ta.speed = belt2OrbitalSpeed
			end
		end
		msg = string.format(_("msgGM","%s\nNew slower Sol Belt 2 speed: %.3f"),msg,belt2OrbitalSpeed)
		addGMMessage(msg)
	end)
	addGMFunction(_("buttonGM","Faster"),function()
		local msg = string.format(_("msgGM","Current Sol Belt 2 speed: %.3f"),belt2OrbitalSpeed)
		belt2OrbitalSpeed = belt2OrbitalSpeed * 1.1
		for i=1,#beltAsteroidList do
			local ta = beltAsteroidList[i]
			if ta ~= nil and ta:isValid() and ta.belt_id == "belt2" then
				ta.speed = belt2OrbitalSpeed
			end
		end
		msg = string.format(_("msgGM","%s\nNew faster Sol Belt 2 speed: %.3f"),msg,belt2OrbitalSpeed)
		addGMMessage(msg)
	end)
end
function adjustTertiusSpeed()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main"),mainGMButtons)
	addGMFunction(_("buttonGM","-From Tertius"),adjustSpeedGMButtons)
	addGMFunction(_("buttonGM","Slower"),function()
		local msg = string.format(_("msgGM","Current Tertius speed: %.1f"),planetTertius.orbit_speed)
		planetTertius.orbit_speed = planetTertius.orbit_speed * 1.1
		planetTertius:setOrbit(planetSol,planetTertius.orbit_speed)
		msg = string.format(_("msgGM","%s\nNew slower Tertius speed: %.1f"),msg,planetTertius.orbit_speed)
		addGMMessage(msg)
	end)
	addGMFunction(_("buttonGM","Faster"),function()
		local msg = string.format(_("msgGM","Current Tertius speed: %.1f"),planetTertius.orbit_speed)
		planetTertius.orbit_speed = planetTertius.orbit_speed * .9
		planetTertius:setOrbit(planetSol,planetTertius.orbit_speed)
		msg = string.format(_("msgGM","%s\nNew faster Tertius speed: %.1f"),msg,planetTertius.orbit_speed)
		addGMMessage(msg)
	end)
end
function adjustTertiusMoonBeltSpeed()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main"),mainGMButtons)
	addGMFunction(_("buttonGM","-From Tertius Moon"),adjustSpeedGMButtons)
	addGMFunction(_("buttonGM","Slower"),function()
		local msg = string.format(_("msgGM","Current Tertius Moon Belt speed: %.3f"),tertiusOrbitalBodyIncrement)
		tertiusOrbitalBodyIncrement = tertiusOrbitalBodyIncrement * .9
		for i=1,#tertiusAsteroids do
			local ta = tertiusAsteroids[i]
			if ta ~= nil and ta:isValid() and ta.belt_id == "tMoonBelt" then
				ta.speed = tertiusOrbitalBodyIncrement
			end
		end
		msg = string.format(_("msgGM","%s\nNew slower Tertius Moon Belt speed: %.3f"),msg,tertiusOrbitalBodyIncrement)
		addGMMessage(msg)
	end)
	addGMFunction(_("buttonGM","Faster"),function()
		local msg = string.format(_("msgGM","Current Tertius Moon Belt speed: %.3f"),tertiusOrbitalBodyIncrement)
		tertiusOrbitalBodyIncrement = tertiusOrbitalBodyIncrement * 1.1
		for i=1,#tertiusAsteroids do
			local ta = tertiusAsteroids[i]
			if ta ~= nil and ta:isValid() and ta.belt_id == "tMoonBelt" then
				ta.speed = tertiusOrbitalBodyIncrement
			end
		end
		msg = string.format(_("msgGM","%s\nNew faster Tertius Moon Belt speed: %.3f"),msg,tertiusOrbitalBodyIncrement)
		addGMMessage(msg)
	end)
end
function adjustTertiusBelt2Speed()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main"),mainGMButtons)
	addGMFunction(_("buttonGM","-From Tertius Belt 2"),adjustSpeedGMButtons)
	addGMFunction(_("buttonGM","Slower"),function()
		local msg = string.format(_("msgGM","Current Tertius Belt 2 speed: %.3f"),tertiusAsteroidBeltIncrement)
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
		msg = string.format(_("msgGM","%s\nNew slower Tertius Belt 2 speed: %.3f"),msg,tertiusAsteroidBeltIncrement)
		addGMMessage(msg)
	end)
	addGMFunction(_("buttonGM","Faster"),function()
		local msg = string.format(_("msgGM","Current Tertius Belt 2 speed: %.3f"),tertiusAsteroidBeltIncrement)
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
		msg = string.format(_("msgGM","%s\nNew faster Tertius Belt 2 speed: %.3f"),msg,tertiusAsteroidBeltIncrement)
		addGMMessage(msg)
	end)
end
-- GM end mission functions
function endMissionGMButtons()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main"),mainGMButtons)
	addGMFunction(_("buttonGM","Human victory"),function()
		showEndStats()
		victory("Human Navy")
	end)
	addGMFunction(_("buttonGM","Exuari victory"),function()
		showEndStats()
		victory("Exuari")
	end)
end
-- GM adjust voices
function adjustServerVoices()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main"),mainGMButtons)
	local button_label = _("buttonGM","Voices On")
	if server_voices then
		button_label = button_label .. "*"
	end
	addGMFunction(button_label,function()
		server_voices = true
		adjustServerVoices()
	end)
	button_label = _("buttonGM","Voices Off")
	if not server_voices then
		button_label = button_label .. "*"
	end
	addGMFunction(button_label,function()
		server_voices = false
		adjustServerVoices()
	end)
end
------------------------------------------
-- Initialization and utility functions --
------------------------------------------
function setVariations()
	local enemy_config = {
		["Easy"] =		{number = .5},
		["Normal"] =	{number = 1},
		["Hard"] =		{number = 2},
		["Extreme"] =	{number = 3},
		["Quixotic"] =	{number = 5},
	}
	enemy_power =	enemy_config[getScenarioSetting("Enemies")].number
	local murphy_config = {
		["Easy"] =		{number = .5,	adverse = .999,	lose_coolant = .99999,	gain_coolant = .005,	rep = 40,	start_danger =  .4},
		["Normal"] =	{number = 1,	adverse = .995,	lose_coolant = .99995,	gain_coolant = .001,	rep = 20,	start_danger =  .8},
		["Hard"] =		{number = 2,	adverse = .99,	lose_coolant = .9999,	gain_coolant = .0001,	rep = 0,	start_danger = 1.2},
	}
	difficulty =			murphy_config[getScenarioSetting("Murphy")].number
	adverseEffect =			murphy_config[getScenarioSetting("Murphy")].adverse
	coolant_loss =			murphy_config[getScenarioSetting("Murphy")].lose_coolant
	coolant_gain =			murphy_config[getScenarioSetting("Murphy")].gain_coolant
	reputation_start_amount=murphy_config[getScenarioSetting("Murphy")].rep
	current_danger =		murphy_config[getScenarioSetting("Murphy")].start_danger
	mission_choices = {
		["Region"] = "Region Selectable",
		["Random"] = "Random",
		["Selectable"] = "Selectable",
	}
	mission_choice = mission_choices[getScenarioSetting("Mission")]
	gameTimeLimit = 0
	playWithTimeLimit = false
end
function setConstants()
	repeatExitBoundary = 100
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
	max_pyramid_tier = 15
	--Player ship name lists to supplant standard randomized call sign generation
	playerShipNamesFor = {
		["Atlantis"] =			{"Excaliber","Thrasher","Punisher","Vorpal","Protang","Drummond","Parchim","Coronado"},
		["Atlantis II"] =		{"Spyder", "Shelob", "Tarantula", "Aragog", "Charlotte"},
		["Benedict"] =			{"Elizabeth","Ford","Vikramaditya","Liaoning","Avenger","Naruebet","Washington","Lincoln","Garibaldi","Eisenhower"},
		["Crucible"] =			{"Sling", "Stark", "Torrid", "Kicker", "Flummox"},
		["Ender"] =				{"Mongo","Godzilla","Leviathan","Kraken","Jupiter","Saturn"},
		["Flavia P.Falcon"] =	{"Ladyhawke","Hunter","Seeker","Gyrefalcon","Kestrel","Magpie","Bandit","Buccaneer"},
		["Hathcock"] =			{"Hayha","Waldron","Plunkett","Mawhinney","Furlong","Zaytsev","Pavlichenko","Pegahmagabow","Fett","Hawkeye","Hanzo"},
		["Kiriya"] =			{"Cavour","Reagan","Gaulle","Paulo","Truman","Stennis","Kuznetsov","Roosevelt","Vinson","Old Salt"},
		["Maverick"] =			{"Angel", "Thunderbird", "Roaster", "Magnifier", "Hedge"},
		["MP52 Hornet"] =		{"Dragonfly","Scarab","Mantis","Yellow Jacket","Jimminy","Flik","Thorny","Buzz"},
		["Nautilus"] =			{"October","Abdiel","Manxman","Newcon","Nusret","Pluton","Amiral","Amur","Heinkel","Dornier"},
		["Phobos M3P"] =		{"Blinder","Shadow","Distortion","Diemos","Ganymede","Castillo","Thebe","Retrograde"},
		["Piranha"] =			{"Razor","Biter","Ripper","Voracious","Carnivorous","Characid","Vulture","Predator"},
		["Player Cruiser"] =	{"Excelsior","Velociraptor","Thunder","Kona","Encounter","Perth","Aspern","Panther"},
		["Player Fighter"] =	{"Buzzer","Flitter","Zippiticus","Hopper","Molt","Stinger","Stripe"},
		["Player Missile Cr."] ={"Projectus","Hurlmeister","Flinger","Ovod","Amatola","Nakhimov","Antigone"},
		["Proto-Atlantis"] =	{"Narsil", "Blade", "Decapitator", "Trisect", "Sabre"},
		["Redhook"] =			{"Headhunter", "Thud", "Troll", "Scalper", "Shark"},
		["Repulse"] =			{"Fiddler","Brinks","Loomis","Mowag","Patria","Pandur","Terrex","Komatsu","Eitan"},
		["Stricken"] =			{"Blazon", "Streaker", "Pinto", "Spear", "Javelin"},
		["Striker"] =			{"Sparrow","Sizzle","Squawk","Crow","Phoenix","Snowbird","Hawk"},
		["Surkov"] =			{"Sting", "Sneak", "Bingo", "Thrill", "Vivisect"},
		["ZX-Lindworm"] =		{"Seagull","Catapult","Blowhard","Flapper","Nixie","Pixie","Tinkerbell"},
		["Leftovers"] =			{"Foregone","Righteous",""},
	}
	player_ship_stats = {	
		["MP52 Hornet"] 		= { strength = 7, 	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 4000, tractor = false,	mining = false,	cm_boost = 600, cm_strafe = 0,		},
		["Piranha"]				= { strength = 16,	cargo = 8,	distance = 200,	long_range_radar = 25000, short_range_radar = 6000, tractor = false,	mining = false,	cm_boost = 200, cm_strafe = 150,	},
		["Flavia P.Falcon"]		= { strength = 13,	cargo = 15,	distance = 200,	long_range_radar = 40000, short_range_radar = 5000, tractor = true,		mining = true,	cm_boost = 250, cm_strafe = 150,	},
		["Phobos M3P"]			= { strength = 19,	cargo = 10,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = true,		mining = false,	cm_boost = 400, cm_strafe = 250,	},
		["Atlantis"]			= { strength = 52,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = true,		mining = true,	cm_boost = 400, cm_strafe = 250,	},
		["Player Cruiser"]		= { strength = 40,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = false,	mining = false,	cm_boost = 400, cm_strafe = 250,	},
		["Player Missile Cr."]	= { strength = 45,	cargo = 8,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, tractor = false,	mining = false,	cm_boost = 450, cm_strafe = 150,	},
		["Player Fighter"]		= { strength = 7,	cargo = 3,	distance = 100,	long_range_radar = 15000, short_range_radar = 4500, tractor = false,	mining = false,	cm_boost = 600, cm_strafe = 0,		},
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
	station_sizes = {
		["Huge Station"] =		{strength = 10,	short_lo = 150,	short_hi = 500},
		["Large Station"] =		{strength = 5,	short_lo = 90,	short_hi = 300},
		["Medium Station"] =	{strength = 3,	short_lo = 60,	short_hi = 200},
		["Small Station"] =		{strength = 1,	short_lo = 35,	short_hi = 100},
	}
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
end
function placeUVStation(psx,psy,name)
	local pStation = nil
	if stationSize == nil then
		pStation = placeStation(psx,psy,name)
		if stationFaction == "Human Navy" then
			humanStationStrength = humanStationStrength + station_sizes[sizeTemplate].strength
			pStation:onDestruction(humanStationDestroyed)
			table.insert(humanStationList,pStation)		--save station in friendly station list
		elseif stationFaction ~= "Exuari" then
			neutralStationStrength = neutralStationStrength + station_sizes[sizeTemplate].strength
			pStation:onDestruction(neutralStationDestroyed)
			table.insert(neutralStationList,pStation)		--save station in friendly station list
		end
	else
		pStation = placeStation(psx,psy,name,stationSize)
		if stationFaction == "Human Navy" then
			humanStationStrength = humanStationStrength + station_sizes[stationSize].strength
			pStation:onDestruction(humanStationDestroyed)
		elseif stationFaction ~= "Exuari" then
			neutralStationStrength = neutralStationStrength + station_sizes[stationSize].strength
			pStation:onDestruction(neutralStationDestroyed)
			table.insert(neutralStationList,pStation)		--save station in friendly station list
		end
	end
	if stationCommunication ~= nil then
		if stationCommunication == "commsStation" then
			pStation:setCommsScript(""):setCommsFunction(commsStation)
		else
			pStation:setCommsScript(stationCommunication)
		end
	end
	if stationStaticAsteroids then
		local station_name = pStation:getCallSign()
		if station_name == "Grasberg" or station_name == "Impala" or station_name == "Outpost-15" or station_name == "Outpost-21" then
			placeRandomAsteroidAroundPoint(Asteroid,15,1,15000,psx,psy)
			placeRandomAsteroidAroundPoint(VisualAsteroid,30,1,15000,psx,psy)
		elseif station_name == "Krak" then
			local posAxisKrak = random(0,360)
			local posKrak = random(10000,60000)
			local negKrak = random(10000,60000)
			local spreadKrak = random(4000,7000)
			local negAxisKrak = posAxisKrak + 180
			local xPosAngleKrak, yPosAngleKrak = vectorFromAngle(posAxisKrak, posKrak)
			local posKrakEnd = random(30,70)
			createRandomAlongArc(Asteroid, 30+posKrakEnd, psx+xPosAngleKrak, psy+yPosAngleKrak, posKrak, negAxisKrak, negAxisKrak+posKrakEnd, spreadKrak)
			createRandomAlongArc(VisualAsteroid, (30+posKrakEnd)*2, psx+xPosAngleKrak, psy+yPosAngleKrak, posKrak, negAxisKrak, negAxisKrak+posKrakEnd, spreadKrak)
			local xNegAngleKrak, yNegAngleKrak = vectorFromAngle(negAxisKrak, negKrak)
			local negKrakEnd = random(40,80)
			createRandomAlongArc(Asteroid, 30+negKrakEnd, psx+xNegAngleKrak, psy+yNegAngleKrak, negKrak, posAxisKrak, posAxisKrak+negKrakEnd, spreadKrak)
			createRandomAlongArc(VisualAsteroid, (30+negKrakEnd)*2, psx+xNegAngleKrak, psy+yNegAngleKrak, negKrak, posAxisKrak, posAxisKrak+negKrakEnd, spreadKrak)
		elseif station_name == "Kruk" then
			local posAxisKruk = random(0,360)
			local posKruk = random(10000,60000)
			local negKruk = random(10000,60000)
			local spreadKruk = random(4000,7000)
			local negAxisKruk = posAxisKruk + 180
			local xPosAngleKruk, yPosAngleKruk = vectorFromAngle(posAxisKruk, posKruk)
			local posKrukEnd = random(30,70)
			createRandomAlongArc(Asteroid, 30+posKrukEnd, psx+xPosAngleKruk, psy+yPosAngleKruk, posKruk, negAxisKruk, negAxisKruk+posKrukEnd, spreadKruk)
			createRandomAlongArc(VisualAsteroid, (30+posKrukEnd)*2, psx+xPosAngleKruk, psy+yPosAngleKruk, posKruk, negAxisKruk, negAxisKruk+posKrukEnd, spreadKruk)
			local xNegAngleKruk, yNegAngleKruk = vectorFromAngle(negAxisKruk, negKruk)
			local negKrukEnd = random(40,80)
			createRandomAlongArc(Asteroid, 30+negKrukEnd, psx+xNegAngleKruk, psy+yNegAngleKruk, negKruk, posAxisKruk, posAxisKruk+negKrukEnd, spreadKruk)
			createRandomAlongArc(VisualAsteroid, (30+negKrukEnd)*2, psx+xNegAngleKruk, psy+yNegAngleKruk, negKruk, posAxisKruk, posAxisKruk+negKrukEnd, spreadKruk)
		elseif station_name == "Krik" then
			local posAxisKrik = random(0,360)
			local posKrik = random(30000,80000)
			local negKrik = random(20000,60000)
			local spreadKrik = random(5000,8000)
			local negAxisKrik = posAxisKrik + 180
			local xPosAngleKrik, yPosAngleKrik = vectorFromAngle(posAxisKrik, posKrik)
			local posKrikEnd = random(40,90)
			createRandomAlongArc(Asteroid, 30+posKrikEnd, psx+xPosAngleKrik, psy+yPosAngleKrik, posKrik, negAxisKrik, negAxisKrik+posKrikEnd, spreadKrik)
			createRandomAlongArc(VisualAsteroid, (30+posKrikEnd)*2, psx+xPosAngleKrik, psy+yPosAngleKrik, posKrik, negAxisKrik, negAxisKrik+posKrikEnd, spreadKrik)
			local xNegAngleKrik, yNegAngleKrik = vectorFromAngle(negAxisKrik, negKrik)
			local negKrikEnd = random(30,60)
			createRandomAlongArc(Asteroid, 30+negKrikEnd, psx+xNegAngleKrik, psy+yNegAngleKrik, negKrik, posAxisKrik, posAxisKrik+negKrikEnd, spreadKrik)
			createRandomAlongArc(VisualAsteroid, (30+negKrikEnd)*2, psx+xNegAngleKrik, psy+yNegAngleKrik, negKrik, posAxisKrik, posAxisKrik+negKrikEnd, spreadKrik)
		end
	end
	return pStation
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
	pStation = placeUVStation(psx,psy,"RandomHumanNeutral")
	pStation.comms_data.orbit = string.format("orbiting %s at a distance of %.1fU",planetPrimus:getCallSign(),primusMoonOrbit/1000)
	table.insert(stationList,pStation)			--save station in general station list
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
	pStation = placeUVStation(psx,psy,"RandomHumanNeutral")
	pStation.comms_data.orbit = string.format("orbiting %s at a distance of %.1fU",planetSecondus:getCallSign(),secondusStationOrbit/1000)
	table.insert(stationList,pStation)			--save station in general station list
	table.insert(secondusStations,pStation)
	table.insert(clueStations,pStation)			--2
	pStation.angle = 0
	--secondus station 2
	plx, ply = vectorFromAngle(120,secondusStationOrbit)
	psx = secondusX + plx
	psy = secondusY + ply
	pStation = placeUVStation(psx,psy,"RandomHumanNeutral")
	pStation.comms_data.orbit = string.format("orbiting %s at a distance of %.1fU",planetSecondus:getCallSign(),secondusStationOrbit/1000)
	table.insert(stationList,pStation)			--save station in general station list
	table.insert(secondusStations,pStation)
	table.insert(clueStations,pStation)			--3
	pStation.angle = 120
	--secondus station 3
	plx, ply = vectorFromAngle(240,secondusStationOrbit)
	psx = secondusX + plx
	psy = secondusY + ply
	pStation = placeUVStation(psx,psy,"RandomHumanNeutral")
	pStation.comms_data.orbit = string.format("orbiting %s at a distance of %.1fU",planetSecondus:getCallSign(),secondusStationOrbit/1000)
	table.insert(stationList,pStation)			--save station in general station list
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
		pStation = placeUVStation(psx,psy,"RandomHumanNeutral")
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
		pStation = placeUVStation(psx,psy,"RandomHumanNeutral")
		table.insert(stationList,pStation)			--save station in general station list
		table.insert(playerSpawnBandStations,pStation)
	end
	--transports in player spawn band
	transportsInPlayerSpawnBandList = {}
	local player_band_transports = {
		{start_station = 1, target_station = 3},
		{start_station = 3, target_station = 5},
		{start_station = 5, target_station = 7},
		{start_station = 2, target_station = 4},
		{start_station = 4, target_station = 6},
		{start_station = 6,	target_station = 8},
	}
	local transportType = {"Personnel","Goods","Garbage","Equipment","Fuel"}
	for i,band in ipairs(player_band_transports) do
		local name = transportType[math.random(1,#transportType)]
		if random(1,100) < 30 then
			name = name .. " Jump Freighter " .. math.random(3, 5)
		else
			name = name .. " Freighter " .. math.random(1, 5)
		end
		local psx, psy = playerSpawnBandStations[band.start_station]:getPosition()
		local tempTransport = CpuShip():setTemplate(name):setPosition(psx,psy):setFaction(playerSpawnBandStations[band.start_station]:getFaction()):setCommsScript(""):setCommsFunction(commsShip)
		tempTransport:setCallSign(generateCallSign(nil,playerSpawnBandStations[band.start_station]:getFaction()))
		tempTransport.targetStart = playerSpawnBandStations[band.start_station]
		tempTransport.targetEnd = playerSpawnBandStations[band.target_station]
		if random(1,100) < 50 then
			tempTransport:orderDock(tempTransport.targetStart)
		else
			tempTransport:orderDock(tempTransport.targetEnd)
		end
		table.insert(transportsInPlayerSpawnBandList,tempTransport)
	end
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
	pStation = placeUVStation(psx,psy,"RandomHumanNeutral")
	pStation.comms_data.orbit = string.format("orbiting %s with the inner asteroids at a distance of %.1fU",planetSol:getCallSign(),beltOrbit1/1000)
	table.insert(stationList,pStation)			--save station in general station list
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
	pStation = placeUVStation(psx,psy,"RandomHumanNeutral")
	pStation.comms_data.orbit = string.format("orbiting %s with the inner asteroids at a distance of %.1fU",planetSol:getCallSign(),beltOrbit1/1000)
	table.insert(stationList,pStation)			--save station in general station list
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
	pStation = placeUVStation(psx,psy,"RandomHumanNeutral")
	pStation.comms_data.orbit = string.format("orbiting %s with the inner asteroids at a distance of %.1fU",planetSol:getCallSign(),beltOrbit1/1000)
	table.insert(stationList,pStation)			--save station in general station list
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
	pStation = placeUVStation(psx,psy,"RandomHumanNeutral")
	pStation.comms_data.orbit = string.format("orbiting %s with the inner asteroids at a distance of %.1fU",planetSol:getCallSign(),beltOrbit1/1000)
	table.insert(stationList,pStation)			--save station in general station list
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
	pStation = placeUVStation(psx,psy,"RandomHumanNeutral")
	pStation.comms_data.orbit = string.format("orbiting %s with the inner asteroids at a distance of %.1fU",planetSol:getCallSign(),beltOrbit1/1000)
	table.insert(stationList,pStation)			--save station in general station list
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
	belt1Artifact:setModel("artifact6"):allowPickup(false):setDescriptions(_("scienceDescription-artifact", "Sensor readings change as the object orbits with the asteroid belt"),_("scienceDescription-artifact", "Object exhibits periodic spikes of chroniton particles"))
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
	pStation = placeUVStation(psx,psy,"RandomHumanNeutral")
	pStation.comms_data.orbit = string.format("orbiting %s with the outer asteroids at a distance of %.1fU",planetSol:getCallSign(),beltOrbit2/1000)
	table.insert(stationList,pStation)			--save station in general station list
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
	pStation = placeUVStation(psx,psy,"RandomHumanNeutral")
	pStation.comms_data.orbit = string.format("orbiting %s with the outer asteroids at a distance of %.1fU",planetSol:getCallSign(),beltOrbit2/1000)
	table.insert(stationList,pStation)			--save station in general station list
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
	pStation = placeUVStation(psx,psy,"RandomHumanNeutral")
	pStation.comms_data.orbit = string.format("orbiting %s with the outer asteroids at a distance of %.1fU",planetSol:getCallSign(),beltOrbit2/1000)
	table.insert(stationList,pStation)			--save station in general station list
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
	pStation = placeUVStation(psx,psy,"RandomHumanNeutral")
	pStation.comms_data.orbit = string.format("orbiting %s with the outer asteroids at a distance of %.1fU",planetSol:getCallSign(),beltOrbit2/1000)
	table.insert(stationList,pStation)			--save station in general station list
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
	pStation = placeUVStation(psx,psy,"RandomHumanNeutral")
	pStation.comms_data.orbit = string.format("orbiting %s with the outer asteroids at a distance of %.1fU",planetSol:getCallSign(),beltOrbit2/1000)
	table.insert(stationList,pStation)			--save station in general station list
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
	pStation = placeUVStation(psx,psy,"RandomHumanNeutral")
	pStation.comms_data.orbit = string.format("orbiting %s with the moons and asteroids at a distance of %.1fU",planetTertius:getCallSign(),tertiusMoonOrbit/1000)
	table.insert(stationList,pStation)			--save station in general station list
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
	pStation = placeUVStation(psx,psy,"RandomHumanNeutral")
	pStation.comms_data.orbit = string.format("orbiting a moon of %s at a distance of %.1fU",planetTertius:getCallSign(),tertiusMoon1StationOrbit/1000)
	table.insert(stationList,pStation)			--save station in general station list
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
	pStation = placeUVStation(psx,psy,"RandomHumanNeutral")
	pStation.comms_data.orbit = string.format("orbiting %s with the outer asteroids at a distance of %.1fU",planetTertius:getCallSign(),tertiusAsteroidOrbit/1000)
	table.insert(stationList,pStation)			--save station in general station list
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
	pStation = placeUVStation(psx,psy,"RandomHumanNeutral")
	pStation.comms_data.orbit = string.format("orbiting %s with the outer asteroids at a distance of %.1fU",planetTertius:getCallSign(),tertiusAsteroidOrbit/1000)
	table.insert(stationList,pStation)			--save station in general station list
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
	pStation = placeUVStation(psx,psy,"RandomHumanNeutral")
	pStation.comms_data.orbit = string.format("orbiting %s with the outer asteroids at a distance of %.1fU",planetTertius:getCallSign(),tertiusAsteroidOrbit/1000)
	table.insert(stationList,pStation)			--save station in general station list
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
	pStation = placeUVStation(psx,psy,"RandomHumanNeutral")
	pStation.comms_data.orbit = string.format("orbiting %s with the outer asteroids at a distance of %.1fU",planetTertius:getCallSign(),tertiusAsteroidOrbit/1000)
	table.insert(stationList,pStation)			--save station in general station list
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
	pStation = placeUVStation(psx,psy,"RandomHumanNeutral")
	pStation.comms_data.orbit = string.format("orbiting %s with the outer asteroids at a distance of %.1fU",planetTertius:getCallSign(),tertiusAsteroidOrbit/1000)
	table.insert(stationList,pStation)			--save station in general station list
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
	pStation = placeUVStation(psx,psy,"RandomHumanNeutral")
	pStation.comms_data.orbit = string.format("orbiting %s with the outer asteroids at a distance of %.1fU",planetTertius:getCallSign(),tertiusAsteroidOrbit/1000)
	table.insert(stationList,pStation)			--save station in general station list
	table.insert(tertiusAsteroidStations,pStation)
	table.insert(clueStations,pStation)			--21
	pStation.angle = beltStationAngle
	pStation.speed = tertiusAsteroidBeltIncrement
	
	--outer belt 2 stations (beyond asteroid belt, before Tertius)
	outerBelt2Stations = {}
	sa1 = random(0,360)
	sa2 = sa1 + 120
	sa3 = sa2 + 120
	local asteroid_amount = 0
	for i=1,4 do
		plx, ply = vectorFromAngle(sa1,outerBelt2Spawn - (outerBelt2SpawnWidth/2) + random(1,outerBelt2SpawnWidth))
		psx = solX+plx
		psy = solY+ply
		if random(1,100) < 12 then
			stationFaction = "Human Navy"				--set station faction
		else
			stationFaction = "Independent"				--set station faction
		end
		pStation = placeUVStation(psx,psy,"RandomHumanNeutral")
		table.insert(stationList,pStation)			--save station in general station list
		table.insert(outerBelt2Stations,pStation)
		table.insert(clueStations,pStation)			--22-25
		if random(1,100) < 8 then
			local abx, aby = vectorFromAngle(sa1,outerBelt2Spawn)
			asteroid_amount = math.random(6,20)
			placeRandomAsteroidAroundPoint(Asteroid,asteroid_amount,1,7800,solX+abx,solY+aby)
			placeRandomAsteroidAroundPoint(VisualAsteroid,asteroid_amount*2,1,7800,solX+abx,solY+aby)
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
		pStation = placeUVStation(psx,psy,"RandomHumanNeutral")
		table.insert(stationList,pStation)			--save station in general station list
		table.insert(outerBelt2Stations,pStation)
		table.insert(clueStations,pStation)			--26-29
		if random(1,100) < 8 then
			local abx, aby = vectorFromAngle(sa2,outerBelt2Spawn)
			asteroid_amount = math.random(6,20)
			placeRandomAsteroidAroundPoint(Asteroid,asteroid_amount,1,7800,solX+abx,solY+aby)
			placeRandomAsteroidAroundPoint(VisualAsteroid,asteroid_amount*2,1,7800,solX+abx,solY+aby)
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
		pStation = placeUVStation(psx,psy,"RandomHumanNeutral")
		table.insert(stationList,pStation)			--save station in general station list
		table.insert(outerBelt2Stations,pStation)
		table.insert(clueStations,pStation)			--30-33
		if random(1,100) < 8 then
			local abx, aby = vectorFromAngle(sa3,outerBelt2Spawn)
			asteroid_amount = math.random(6,20)
			placeRandomAsteroidAroundPoint(Asteroid,asteroid_amount,1,7800,solX+abx,solY+aby)
			placeRandomAsteroidAroundPoint(VisualAsteroid,asteroid_amount*2,1,7800,solX+abx,solY+aby)
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
	for i,neb in ipairs(nebula_list) do
		neb.lose = false
		neb.gain = false
	end
	local nebula_count = #nebula_list
	for i=1,math.random(math.floor(nebula_count/2)) do
		local neb = tableRemoveRandom(nebula_list)
		if neb ~= nil then
			if math.random(1,100) < 50 then
				neb.lose = true
			else
				neb.gain = true
			end
			table.insert(coolant_nebula,neb)
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
			ta:setSize(random(3,100) + random(3,100) + random(3,100) + random(3,500))
			if radialPoint > 360 then
				radialPoint = radialPoint - 360
			end
			ta.angle = radialPoint
			ta.distance = pointDist
			ta.speed = speedIncrement
			ta.belt_id = belt_id
			table.insert(tertiusAsteroids,ta)		
			pointDist = distance + random(-randomize,randomize)
			tva = VisualAsteroid():setPosition(tertiusX + math.cos(radialPoint / 180 * math.pi) * pointDist, tertiusY + math.sin(radialPoint / 180 * math.pi) * pointDist)
			tva:setSize(random(3,100) + random(3,100) + random(3,100) + random(3,500))
			tva.angle = radialPoint
			tva.distance = pointDist
			tva.speed = speedIncrement * random(.9,1.1)
			tva.belt_id = belt_id
			table.insert(tertiusAsteroids,tva)
			pointDist = distance + random(-randomize,randomize)
			tva = VisualAsteroid():setPosition(tertiusX + math.cos(radialPoint / 180 * math.pi) * pointDist, tertiusY + math.sin(radialPoint / 180 * math.pi) * pointDist)
			tva:setSize(random(3,100) + random(3,100) + random(3,100) + random(3,500))
			tva.angle = radialPoint
			tva.distance = pointDist
			tva.speed = speedIncrement * random(.9,1.1)
			tva.belt_id = belt_id
			table.insert(tertiusAsteroids,tva)
		end
		for ndex=1,math.floor(amount-arcLen) do
			radialPoint = random(startArc,clockwiseEndArc)
			pointDist = distance + random(-randomize,randomize)
			ta = Asteroid():setPosition(tertiusX + math.cos(radialPoint / 180 * math.pi) * pointDist, tertiusY + math.sin(radialPoint / 180 * math.pi) * pointDist)			
			ta:setSize(random(3,100) + random(3,100) + random(3,100) + random(3,500))
			if radialPoint > 360 then
				radialPoint = radialPoint - 360
			end
			ta.angle = radialPoint
			ta.distance = pointDist
			ta.speed = speedIncrement
			ta.belt_id = belt_id
			table.insert(tertiusAsteroids,ta)
			pointDist = distance + random(-randomize,randomize)
			tva = VisualAsteroid():setPosition(tertiusX + math.cos(radialPoint / 180 * math.pi) * pointDist, tertiusY + math.sin(radialPoint / 180 * math.pi) * pointDist)
			tva:setSize(random(3,100) + random(3,100) + random(3,100) + random(3,500))
			tva.angle = radialPoint
			tva.distance = pointDist
			tva.speed = speedIncrement * random(.9,1.1)
			tva.belt_id = belt_id
			table.insert(tertiusAsteroids,tva)
			pointDist = distance + random(-randomize,randomize)
			tva = VisualAsteroid():setPosition(tertiusX + math.cos(radialPoint / 180 * math.pi) * pointDist, tertiusY + math.sin(radialPoint / 180 * math.pi) * pointDist)
			tva:setSize(random(3,100) + random(3,100) + random(3,100) + random(3,500))
			tva.angle = radialPoint
			tva.distance = pointDist
			tva.speed = speedIncrement * random(.9,1.1)
			tva.belt_id = belt_id
			table.insert(tertiusAsteroids,tva)
		end
	else
		for ndex=1,amount do
			radialPoint = random(startArc,clockwiseEndArc)
			pointDist = distance + random(-randomize,randomize)
			ta = Asteroid():setPosition(tertiusX + math.cos(radialPoint / 180 * math.pi) * pointDist, tertiusY + math.sin(radialPoint / 180 * math.pi) * pointDist)
			ta:setSize(random(3,100) + random(3,100) + random(3,100) + random(3,500))
			if radialPoint > 360 then
				radialPoint = radialPoint - 360
			end
			ta.angle = radialPoint
			ta.distance = pointDist
			ta.speed = speedIncrement
			ta.belt_id = belt_id
			table.insert(tertiusAsteroids,ta)
			radialPoint = random(startArc,clockwiseEndArc)
			pointDist = distance + random(-randomize,randomize)
			tva = VisualAsteroid():setPosition(tertiusX + math.cos(radialPoint / 180 * math.pi) * pointDist, tertiusY + math.sin(radialPoint / 180 * math.pi) * pointDist)
			tva:setSize(random(3,100) + random(3,100) + random(3,100) + random(3,500))
			tva.angle = radialPoint
			tva.distance = pointDist
			tva.speed = speedIncrement * random(.9,1.1)
			tva.belt_id = belt_id
			table.insert(tertiusAsteroids,tva)
			radialPoint = random(startArc,clockwiseEndArc)
			pointDist = distance + random(-randomize,randomize)
			tva = VisualAsteroid():setPosition(tertiusX + math.cos(radialPoint / 180 * math.pi) * pointDist, tertiusY + math.sin(radialPoint / 180 * math.pi) * pointDist)
			tva:setSize(random(3,100) + random(3,100) + random(3,100) + random(3,500))
			tva.angle = radialPoint
			tva.distance = pointDist
			tva.speed = speedIncrement * random(.9,1.1)
			tva.belt_id = belt_id
			table.insert(tertiusAsteroids,tva)
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
	local radialPoint = 0
	local pointDist = 0
	if amount > arcLen then
		for ndex=1,math.floor(arcLen) do
			radialPoint = startArc+ndex
			pointDist = distance + random(-randomize,randomize)
			ta = Asteroid():setPosition(solX + math.cos(radialPoint / 180 * math.pi) * pointDist, solY + math.sin(radialPoint / 180 * math.pi) * pointDist)
			ta:setSize(random(3,100) + random(3,100) + random(3,100) + random(3,500))
			if radialPoint > 360 then
				radialPoint = radialPoint - 360
			end
			ta.angle = radialPoint
			ta.distance = pointDist
			ta.speed = beltOrbitalSpeed
			ta.belt_id = belt_id
			table.insert(beltAsteroidList,ta)
			pointDist = distance + random(-randomize,randomize)
			tva = VisualAsteroid():setPosition(solX + math.cos(radialPoint / 180 * math.pi) * pointDist, solY + math.sin(radialPoint / 180 * math.pi) * pointDist)
			tva:setSize(random(3,100) + random(3,100) + random(3,100) + random(3,500))
			tva.angle = radialPoint
			tva.distance = pointDist
			tva.speed = beltOrbitalSpeed * random(.9,1.1)
			tva.belt_id = belt_id
			table.insert(beltAsteroidList,tva)
			pointDist = distance + random(-randomize,randomize)
			tva = VisualAsteroid():setPosition(solX + math.cos(radialPoint / 180 * math.pi) * pointDist, solY + math.sin(radialPoint / 180 * math.pi) * pointDist)
			tva:setSize(random(3,100) + random(3,100) + random(3,100) + random(3,500))
			tva.angle = radialPoint
			tva.distance = pointDist
			tva.speed = beltOrbitalSpeed * random(.9,1.1)
			tva.belt_id = belt_id
			table.insert(beltAsteroidList,tva)
		end
		for ndex=1,math.floor(amount-arcLen) do
			radialPoint = random(startArc,clockwiseEndArc)
			pointDist = distance + random(-randomize,randomize)
			ta = Asteroid():setPosition(solX + math.cos(radialPoint / 180 * math.pi) * pointDist, solY + math.sin(radialPoint / 180 * math.pi) * pointDist)			
			ta:setSize(random(3,100) + random(3,100) + random(3,100) + random(3,500))
			if radialPoint > 360 then
				radialPoint = radialPoint - 360
			end
			ta.angle = radialPoint
			ta.distance = pointDist
			ta.speed = beltOrbitalSpeed
			ta.belt_id = belt_id
			table.insert(beltAsteroidList,ta)
			radialPoint = random(startArc,clockwiseEndArc)
			pointDist = distance + random(-randomize,randomize)
			tva = VisualAsteroid():setPosition(solX + math.cos(radialPoint / 180 * math.pi) * pointDist, solY + math.sin(radialPoint / 180 * math.pi) * pointDist)
			tva:setSize(random(3,100) + random(3,100) + random(3,100) + random(3,500))
			tva.angle = radialPoint
			tva.distance = pointDist
			tva.speed = beltOrbitalSpeed * random(.9,1.1)
			tva.belt_id = belt_id
			table.insert(beltAsteroidList,tva)
			radialPoint = random(startArc,clockwiseEndArc)
			pointDist = distance + random(-randomize,randomize)
			tva = VisualAsteroid():setPosition(solX + math.cos(radialPoint / 180 * math.pi) * pointDist, solY + math.sin(radialPoint / 180 * math.pi) * pointDist)
			tva:setSize(random(3,100) + random(3,100) + random(3,100) + random(3,500))
			tva.angle = radialPoint
			tva.distance = pointDist
			tva.speed = beltOrbitalSpeed * random(.9,1.1)
			tva.belt_id = belt_id
			table.insert(beltAsteroidList,tva)
		end
	else
		for ndex=1,amount do
			radialPoint = random(startArc,clockwiseEndArc)
			pointDist = distance + random(-randomize,randomize)
			ta = Asteroid():setPosition(solX + math.cos(radialPoint / 180 * math.pi) * pointDist, solY + math.sin(radialPoint / 180 * math.pi) * pointDist)
			ta:setSize(random(3,100) + random(3,100) + random(3,100) + random(3,500))
			if radialPoint > 360 then
				radialPoint = radialPoint - 360
			end
			ta.angle = radialPoint
			ta.distance = pointDist
			ta.speed = beltOrbitalSpeed
			ta.belt_id = belt_id
			table.insert(beltAsteroidList,ta)
			radialPoint = random(startArc,clockwiseEndArc)
			pointDist = distance + random(-randomize,randomize)
			tva = VisualAsteroid():setPosition(solX + math.cos(radialPoint / 180 * math.pi) * pointDist, solY + math.sin(radialPoint / 180 * math.pi) * pointDist)
			tva:setSize(random(3,100) + random(3,100) + random(3,100) + random(3,500))
			tva.angle = radialPoint
			tva.distance = pointDist
			tva.speed = beltOrbitalSpeed * random(.9,1.1)
			tva.belt_id = belt_id
			table.insert(beltAsteroidList,tva)
			radialPoint = random(startArc,clockwiseEndArc)
			pointDist = distance + random(-randomize,randomize)
			tva = VisualAsteroid():setPosition(solX + math.cos(radialPoint / 180 * math.pi) * pointDist, solY + math.sin(radialPoint / 180 * math.pi) * pointDist)
			tva:setSize(random(3,100) + random(3,100) + random(3,100) + random(3,500))
			tva.angle = radialPoint
			tva.distance = pointDist
			tva.speed = beltOrbitalSpeed * random(.9,1.1)
			tva.belt_id = belt_id
			table.insert(beltAsteroidList,tva)
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
function angleFromVectorNorth(p1x,p1y,p2x,p2y)
	if spew_function_diagnostic then print("top of angle from vector north") end
	TWOPI = 6.2831853071795865
	RAD2DEG = 57.2957795130823209
	atan2parm1 = p2x - p1x
	atan2parm2 = p2y - p1y
	theta = math.atan2(atan2parm1, atan2parm2)
	if theta < 0 then
		theta = theta + TWOPI
	end
	if spew_function_diagnostic then print("bottom (ish) of angle from vector north") end
	return (360 - (RAD2DEG * theta)) % 360
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
	table.insert(kraylorVesselDestroyedValue,ship_template[tempShipType].strength)
end
function exuariVesselDestroyed(self, instigator)
	local tempShipType = self:getTypeName()
	table.insert(exuariVesselDestroyedNameList,self:getCallSign())
	table.insert(exuariVesselDestroyedType,tempShipType)
	table.insert(exuariVesselDestroyedValue,ship_template[tempShipType].strength)
end
function humanVesselDestroyed(self, instigator)
	local tempShipType = self:getTypeName()
	table.insert(humanVesselDestroyedNameList,self:getCallSign())
	table.insert(humanVesselDestroyedType,tempShipType)
	table.insert(humanVesselDestroyedValue,ship_template[tempShipType].strength)
end
function arlenianVesselDestroyed(self, instigator)
	local tempShipType = self:getTypeName()
	table.insert(arlenianVesselDestroyedNameList,self:getCallSign())
	table.insert(arlenianVesselDestroyedType,tempShipType)
	table.insert(arlenianVesselDestroyedValue,ship_template[tempShipType].strength)
end
-------------------------------------------------------
-- Optional mission functions to upgrade player ship --
-------------------------------------------------------
function setOptionalMissions()
	--	faster beams
	local required_good = chooseUpgradeGood("beam",playerSpawnBandStations[1])
	playerSpawnBandStations[1].comms_data.character = "Horace Grayson"
	playerSpawnBandStations[1].comms_data.characterDescription = _("characterInfo-comms","He dabbles in ship system innovations. He's been working on improving beam weapons by reducing the amount of time between firing. I hear he's already installed some improvements on ships that have docked here previously")
	playerSpawnBandStations[1].comms_data.characterFunction = "shrinkBeamCycle"
	playerSpawnBandStations[1].comms_data.characterGood = required_good
	local clue_station = clueStations[math.random(1,#clueStations)]
	repeat
		clue_station = clueStations[math.random(1,#clueStations)]
	until(clue_station.comms_data.gossip == nil)
	clue_station.comms_data.gossip = string.format(_("characterInfo-comms","I heard there's a guy named %s that can fix ship beam systems up so that they shoot faster. He lives out on %s in %s. He won't charge you much, but it won't be free."),playerSpawnBandStations[1].comms_data.character,playerSpawnBandStations[1]:getCallSign(),playerSpawnBandStations[1]:getSectorName())
	--	spin faster
	required_good = chooseUpgradeGood("circuit",playerSpawnBandStations[2])
	playerSpawnBandStations[2].comms_data.character = "Emily Patel"
	playerSpawnBandStations[2].comms_data.characterDescription = _("characterInfo-comms","She tinkers with ship systems like engines and thrusters. She's consulted with the military on tuning spin time by increasing thruster power. She's got prototypes that are awaiting formal military approval before installation")
	playerSpawnBandStations[2].comms_data.characterFunction = "increaseSpin"
	playerSpawnBandStations[2].comms_data.characterGood = required_good
	clue_station = clueStations[math.random(1,#clueStations)]
	repeat
		clue_station = clueStations[math.random(1,#clueStations)]
	until(clue_station.comms_data.gossip == nil)
	clue_station.comms_data.gossip = string.format(_("characterInfo-comms","My friend, %s recently quit her job as a ship maintenance technician to set up this side gig. She's been improving ship systems and she's pretty good at it. She set up shop on %s in %s. I hear she's even lining up a contract with the navy for her improvements."),playerSpawnBandStations[2].comms_data.character,playerSpawnBandStations[2]:getCallSign(),playerSpawnBandStations[2]:getSectorName())
	--	extra missile tube
	required_good = chooseUpgradeGood("nanites",playerSpawnBandStations[3])
	playerSpawnBandStations[3].comms_data.character = "Fred McLassiter"
	playerSpawnBandStations[3].comms_data.characterDescription = _("characterInfo-comms","He specializes in miniaturization of weapons systems. He's come up with a way to add a missile tube and some missiles to any ship regardless of size or configuration")
	playerSpawnBandStations[3].comms_data.characterFunction = "addAuxTube"
	playerSpawnBandStations[3].comms_data.characterGood = required_good
	clue_station = clueStations[math.random(1,#clueStations)]
	repeat
		clue_station = clueStations[math.random(1,#clueStations)]
	until(clue_station.comms_data.gossip == nil)
	clue_station.comms_data.gossip = string.format(_("characterInfo-comms","There's this guy, %s out on %s in %s that can add a missile tube to your ship. He even added one to my cousin's souped up freighter. You should see the new paint job: amusingly phallic"),playerSpawnBandStations[3].comms_data.character,playerSpawnBandStations[3]:getCallSign(),playerSpawnBandStations[3]:getSectorName())
	--	cooler beam weapon firing
	required_good = chooseUpgradeGood("software",playerSpawnBandStations[4])
	playerSpawnBandStations[4].comms_data.character = "Dorothy Ly"
	playerSpawnBandStations[4].comms_data.characterDescription = _("characterInfo-comms","She developed this technique for cooling beam systems so that they can be fired more often without burning out")
	playerSpawnBandStations[4].comms_data.characterFunction = "coolBeam"
	playerSpawnBandStations[4].comms_data.characterGood = required_good
	clue_station = clueStations[math.random(1,#clueStations)]
	repeat
		clue_station = clueStations[math.random(1,#clueStations)]
	until(clue_station.comms_data.gossip == nil)
	clue_station.comms_data.gossip = string.format(_("characterInfo-comms","There's this girl on %s in %s. She is hot. Her name is %s. When I say she is hot, I mean she has a way of keeping your beam weapons from excessive heat."),playerSpawnBandStations[4]:getCallSign(),playerSpawnBandStations[4]:getSectorName(),playerSpawnBandStations[4].comms_data.character)
	--	longer beam range
	required_good = chooseUpgradeGood("optic",playerSpawnBandStations[5])
	playerSpawnBandStations[5].comms_data.character = "Gerald Cook"
	playerSpawnBandStations[5].comms_data.characterDescription = _("characterInfo-comms","He knows how to modify beam systems to extend their range")
	playerSpawnBandStations[5].comms_data.characterFunction = "longerBeam"
	playerSpawnBandStations[5].comms_data.characterGood = required_good
	clue_station = clueStations[math.random(1,#clueStations)]
	repeat
		clue_station = clueStations[math.random(1,#clueStations)]
	until(clue_station.comms_data.gossip == nil)
	clue_station.comms_data.gossip = string.format(_("characterInfo-comms","Do you know about %s? He can extend the range of your beam weapons. He's on %s in %s"),playerSpawnBandStations[5].comms_data.character,playerSpawnBandStations[5]:getCallSign(),playerSpawnBandStations[5]:getSectorName())
	--	increased beam damage
	required_good = chooseUpgradeGood("filament",playerSpawnBandStations[6])
	playerSpawnBandStations[6].comms_data.character = "Sally Jenkins"
	playerSpawnBandStations[6].comms_data.characterDescription = _("characterInfo-comms","She can make your beams hit harder")
	playerSpawnBandStations[6].comms_data.characterFunction = "damageBeam"
	playerSpawnBandStations[6].comms_data.characterGood = required_good
	clue_station = clueStations[math.random(1,#clueStations)]
	repeat
		clue_station = clueStations[math.random(1,#clueStations)]
	until(clue_station.comms_data.gossip == nil)
	clue_station.comms_data.gossip = string.format(_("characterInfo-comms","You should visit %s in %s. There's a specialist in beam technology that can increase the damage done by your beams. Her name is %s"),playerSpawnBandStations[6]:getCallSign(),playerSpawnBandStations[6]:getSectorName(),playerSpawnBandStations[6].comms_data.character)
	--	increased maximum missile storage capacity
	required_good = chooseUpgradeGood("transporter",playerSpawnBandStations[7])
	playerSpawnBandStations[7].comms_data.character = "Anh Dung Ly"
	playerSpawnBandStations[7].comms_data.characterDescription = _("characterInfo-comms","He can fit more missiles aboard your ship")
	playerSpawnBandStations[7].comms_data.characterFunction = "moreMissiles"
	playerSpawnBandStations[7].comms_data.characterGood = required_good
	clue_station = clueStations[math.random(1,#clueStations)]
	repeat
		clue_station = clueStations[math.random(1,#clueStations)]
	until(clue_station.comms_data.gossip == nil)
	clue_station.comms_data.gossip = string.format(_("characterInfo-comms","Want to store more missiles on your ship? Talk to %s on station %s in %s. He can retrain your missile loaders and missile storage automation such that you will be able to store more missiles"),playerSpawnBandStations[7].comms_data.character,playerSpawnBandStations[7]:getCallSign(),playerSpawnBandStations[7]:getSectorName())
	--	faster impulse
	required_good = chooseUpgradeGood("impulse",playerSpawnBandStations[8])
	playerSpawnBandStations[8].comms_data.character = "Doralla Ognats"
	playerSpawnBandStations[8].comms_data.characterDescription = _("characterInfo-comms","She can soup up your impulse engines")
	playerSpawnBandStations[8].comms_data.characterFunction = "fasterImpulse"
	playerSpawnBandStations[8].comms_data.characterGood = required_good
	clue_station = clueStations[math.random(1,#clueStations)]
	repeat
		clue_station = clueStations[math.random(1,#clueStations)]
	until(clue_station.comms_data.gossip == nil)
	clue_station.comms_data.gossip = string.format(_("characterInfo-comms","%s, an engineer/mechanic who knows propulsion systems backwards and forwards has a bay at the shipyard on %s in %s. She can give your impulse engines a significant boost to their top speed"),playerSpawnBandStations[8].comms_data.character,playerSpawnBandStations[8]:getCallSign(),playerSpawnBandStations[8]:getSectorName())
	--	stronger hull
	required_good = chooseUpgradeGood("repulsor",tertiusStation)
	tertiusStation.comms_data.character = "Maduka Lawal"
	tertiusStation.comms_data.characterDescription = _("characterInfo-comms","He can strengthen your hull")
	tertiusStation.comms_data.characterFunction = "strongerHull"
	tertiusStation.comms_data.characterGood = required_good
	clue_station = clueStations[math.random(1,#clueStations)]
	repeat
		clue_station = clueStations[math.random(1,#clueStations)]
	until(clue_station.comms_data.gossip == nil and clue_station ~= tertiusStation)
	clue_station.comms_data.gossip = string.format(_("characterInfo-comms","I know of a materials specialist on %s in %s named %s. He can strengthen the hull on your ship"),tertiusStation:getCallSign(),tertiusStation:getSectorName(),tertiusStation.comms_data.character)
	--	efficient batteries
	required_good = chooseUpgradeGood("battery",tertiusMoon1Station)
	tertiusMoon1Station.comms_data.character = "Susil Tarigan"
	tertiusMoon1Station.comms_data.characterDescription = _("characterInfo-comms","She knows how to increase your maximum energy capacity by improving battery efficiency")
	tertiusMoon1Station.comms_data.characterFunction = "efficientBatteries"
	tertiusMoon1Station.comms_data.characterGood = required_good
	clue_station = clueStations[math.random(1,#clueStations)]
	repeat
		clue_station = clueStations[math.random(1,#clueStations)]
	until(clue_station.comms_data.gossip == nil and clue_station ~= tertiusMoon1Station)
	clue_station.comms_data.gossip = string.format(_("characterInfo-comms","Have you heard about %s? She's on %s in %s and she can give your ship greater energy capacity by improving your battery efficiency"),tertiusMoon1Station.comms_data.character,tertiusMoon1Station:getCallSign(),tertiusMoon1Station:getSectorName())
	--	stronger shields
	required_good = chooseUpgradeGood("shield",tertiusAsteroidStations[1])
	tertiusAsteroidStations[1].comms_data.character = "Paulo Silva"
	tertiusAsteroidStations[1].comms_data.characterDescription = _("characterInfo-comms","He can strengthen your shields")
	tertiusAsteroidStations[1].comms_data.characterFunction = "strongerShields"
	tertiusAsteroidStations[1].comms_data.characterGood = required_good
	clue_station = clueStations[math.random(1,#clueStations)]
	repeat
		clue_station = clueStations[math.random(1,#clueStations)]
	until(clue_station.comms_data.gossip == nil and clue_station ~= tertiusAsteroidStations[1])
	clue_station.comms_data.gossip = string.format(_("characterInfo-comms","If you stop at %s in %s, you should talk to %s. He can strengthen your shields. Trust me, it's always good to have stronger shields"),tertiusAsteroidStations[1]:getCallSign(),tertiusAsteroidStations[1]:getSectorName(),tertiusAsteroidStations[1].comms_data.character)
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
		addCommsReply(_("upgrade-comms","Reduce beam cycle time"), function()
			local ctd = comms_target.comms_data
			if comms_source:getBeamWeaponRange(0) > 0 then
				if	payForUpgrade() then
					local partQuantity = 0
					if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
						partQuantity = comms_source.goods[ctd.characterGood]
					end
					if partQuantity > 0 then
						comms_source.shrinkBeamCycleUpgrade = "done"
						optional_missions[comms_source:getCallSign()] = optional_missions[comms_source:getCallSign()] + 1
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
						setCommsMessage(_("upgrade-comms","After accepting your gift, he reduced your Beam cycle time by 25%%"))
					else
						setCommsMessage(string.format(_("upgrade-comms","%s requires %s for the upgrade"),ctd.character,ctd.characterGood))
					end
				else
					comms_source.shrinkBeamCycleUpgrade = "done"
					optional_missions[comms_source:getCallSign()] = optional_missions[comms_source:getCallSign()] + 1
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
					setCommsMessage(string.format(_("upgrade-comms","%s reduced your Beam cycle time by 25%% at no cost in trade with the message, 'Go get those Exuari.'"),ctd.character))
				end
			else
				setCommsMessage(_("upgrade-comms","Your ship type does not support a beam weapon upgrade."))
			end
		end)
	end
end
function increaseSpin()
	if comms_source.increaseSpinUpgrade == nil then
		addCommsReply(_("upgrade-comms","Increase spin speed"), function()
			local ctd = comms_target.comms_data
			if payForUpgrade() then
				local partQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
					partQuantity = comms_source.goods[ctd.characterGood]
				end
				if partQuantity > 0 then
					comms_source.increaseSpinUpgrade = "done"
					optional_missions[comms_source:getCallSign()] = optional_missions[comms_source:getCallSign()] + 1
					comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
					comms_source.cargo = comms_source.cargo + 1
					comms_source:setRotationMaxSpeed(comms_source:getRotationMaxSpeed()*1.5)
					setCommsMessage(string.format(_("upgrade-comms","Ship spin speed increased by 50%% after you gave %s to %s"),ctd.characterGood,ctd.character))
				else
					setCommsMessage(string.format(_("upgrade-comms","%s requires %s for the spin upgrade"),ctd.character,ctd.characterGood))
				end
			else
				comms_source.increaseSpinUpgrade = "done"
				optional_missions[comms_source:getCallSign()] = optional_missions[comms_source:getCallSign()] + 1
				comms_source:setRotationMaxSpeed(player:getRotationMaxSpeed()*1.5)
				setCommsMessage(string.format(_("upgrade-comms","%s: I increased the speed your ship spins by 50%%. Normally, I'd require %s, but seeing as you're going out to take on the Exuari, we worked it out"),ctd.character,ctd.characterGood))
			end
		end)
	end
end
function addAuxTube()
	if comms_source.auxTubeUpgrade == nil then
		addCommsReply(_("upgrade-comms","Add missile tube"), function()
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
					optional_missions[comms_source:getCallSign()] = optional_missions[comms_source:getCallSign()] + 1
					comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
					comms_source.goods["luxury"] = comms_source.goods["luxury"] - 1
					comms_source.cargo = comms_source.cargo + 2
					local originalTubes = comms_source:getWeaponTubeCount()
					local newTubes = originalTubes + 1
					comms_source:setWeaponTubeCount(newTubes)
					comms_source:setWeaponTubeExclusiveFor(originalTubes, "Homing")
					comms_source:setWeaponStorageMax("Homing", comms_source:getWeaponStorageMax("Homing") + 2)
					comms_source:setWeaponStorage("Homing", comms_source:getWeaponStorage("Homing") + 2)
					setCommsMessage(string.format(_("upgrade-comms","%s thanks you for the %s and the luxury and installs a homing missile tube for you"),ctd.character,ctd.characterGood))
				else
					setCommsMessage(string.format(_("upgrade-comms","%s requires %s and luxury for the missile tube"),ctd.character,ctd.characterGood))
				end
			else
				comms_source.auxTubeUpgrade = "done"
				optional_missions[comms_source:getCallSign()] = optional_missions[comms_source:getCallSign()] + 1
				originalTubes = comms_source:getWeaponTubeCount()
				newTubes = originalTubes + 1
				comms_source:setWeaponTubeCount(newTubes)
				comms_source:setWeaponTubeExclusiveFor(originalTubes, "Homing")
				comms_source:setWeaponStorageMax("Homing", comms_source:getWeaponStorageMax("Homing") + 2)
				comms_source:setWeaponStorage("Homing", comms_source:getWeaponStorage("Homing") + 2)
				setCommsMessage(string.format(_("upgrade-comms","%s installs a homing missile tube for you. The %s required was requisitioned from emergency contingency supplies"),ctd.character,ctd.characterGood))
			end
		end)
	end
end
function coolBeam()
	if comms_source.coolBeamUpgrade == nil then
		addCommsReply(_("upgrade-comms","Reduce beam heat"), function()
			local ctd = comms_target.comms_data
			if comms_source:getBeamWeaponRange(0) > 0 then
				if payForUpgrade() then
					local partQuantity = 0
					if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
						partQuantity = comms_source.goods[ctd.characterGood]
					end
					if partQuantity > 0 then
						comms_source.coolBeamUpgrade = "done"
						optional_missions[comms_source:getCallSign()] = optional_missions[comms_source:getCallSign()] + 1
						comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
						comms_source.cargo = comms_source.cargo + 1
						local bi = 0
						repeat
							comms_source:setBeamWeaponHeatPerFire(bi,comms_source:getBeamWeaponHeatPerFire(bi) * 0.5)
							bi = bi + 1
						until(comms_source:getBeamWeaponRange(bi) < 1)
						setCommsMessage(_("upgrade-comms","Beam heat generation reduced by 50%%"))
					else
						setCommsMessage(string.format(_("upgrade-comms","%s says she needs %s before she can cool your beams"),ctd.character,ctd.characterGood))
					end
				else
					comms_source.coolBeamUpgrade = "done"
					optional_missions[comms_source:getCallSign()] = optional_missions[comms_source:getCallSign()] + 1
					bi = 0
					repeat
						comms_source:setBeamWeaponHeatPerFire(bi,comms_source:getBeamWeaponHeatPerFire(bi) * 0.5)
						bi = bi + 1
					until(comms_source:getBeamWeaponRange(bi) < 1)
					setCommsMessage(string.format(_("upgrade-comms","%s: Beam heat generation reduced by 50%%, no %s necessary. Go shoot some Exuari for me"),ctd.character,ctd.characterGood))
				end
			else
				setCommsMessage(_("upgrade-comms","Your ship type does not support a beam weapon upgrade."))
			end
		end)
	end
end
function longerBeam()
	if comms_source.longerBeamUpgrade == nil then
		addCommsReply(_("upgrade-comms","Extend beam range"), function()
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
						optional_missions[comms_source:getCallSign()] = optional_missions[comms_source:getCallSign()] + 1
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
						setCommsMessage(string.format(_("upgrade-comms","%s extended your beam range by 25%% and says thanks for the %s"),ctd.character,ctd.characterGood))
					else
						setCommsMessage(string.format(_("upgrade-comms","%s requires %s for the upgrade"),ctd.character,ctd.characterGood))
					end
				else
					comms_source.longerBeamUpgrade = "done"
					optional_missions[comms_source:getCallSign()] = optional_missions[comms_source:getCallSign()] + 1
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
					setCommsMessage(string.format(_("upgrade-comms","%s increased your beam range by 25%% without the usual %s from your ship"),ctd.character,ctd.characterGood))
				end
			else
				setCommsMessage(_("upgrade-comms","Your ship type does not support a beam weapon upgrade."))
			end
		end)
	end
end
function damageBeam()
	if comms_source.damageBeamUpgrade == nil then
		addCommsReply(_("upgrade-comms","Increase beam damage"), function()
			local ctd = comms_target.comms_data
			if comms_source:getBeamWeaponRange(0) > 0 then
				if payForUpgrade() then
					local partQuantity = 0
					if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
						partQuantity = comms_source.goods[ctd.characterGood]
					end
					if partQuantity > 0 then
						comms_source.damageBeamUpgrade = "done"
						optional_missions[comms_source:getCallSign()] = optional_missions[comms_source:getCallSign()] + 1
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
						setCommsMessage(string.format(_("upgrade-comms","%s increased your beam damage by 20%% and stores away the %s"),ctd.character,ctd.characterGood))
					else
						setCommsMessage(string.format(_("upgrade-comms","%s requires %s for the upgrade"),ctd.character,ctd.characterGood))
					end
				else
					comms_source.damageBeamUpgrade = "done"
					optional_missions[comms_source:getCallSign()] = optional_missions[comms_source:getCallSign()] + 1
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
					setCommsMessage(string.format(_("upgrade-comms","%s increased your beam damage by 20%%, waiving the usual %s requirement"),ctd.character,ctd.characterGood))
				end
			else
				setCommsMessage(_("upgrade-comms","Your ship type does not support a beam weapon upgrade."))
			end
		end)
	end
end
function moreMissiles()
	if comms_source.moreMissilesUpgrade == nil then
		addCommsReply(_("upgrade-comms","Increase missile storage capacity"), function()
			local ctd = comms_target.comms_data
			if comms_source:getWeaponTubeCount() > 0 then
				if payForUpgrade() then
					local partQuantity = 0
					if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
						partQuantity = comms_source.goods[ctd.characterGood]
					end
					if partQuantity > 0 then
						comms_source.moreMissilesUpgrade = "done"
						optional_missions[comms_source:getCallSign()] = optional_missions[comms_source:getCallSign()] + 1
						comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
						comms_source.cargo = comms_source.cargo + 1
						local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
						for i, missile_type in ipairs(missile_types) do
							comms_source:setWeaponStorageMax(missile_type, math.ceil(comms_source:getWeaponStorageMax(missile_type)*1.25))
						end
						setCommsMessage(string.format(_("upgrade-comms","%s: You can now store at least 25%% more missiles. I appreciate the %s"),ctd.character,ctd.characterGood))
					else
						setCommsMessage(string.format(_("upgrade-comms","%s needs %s for the upgrade"),ctd.character,ctd.characterGood))
					end
				else
					comms_source.moreMissilesUpgrade = "done"
					optional_missions[comms_source:getCallSign()] = optional_missions[comms_source:getCallSign()] + 1
					missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
					for i, missile_type in ipairs(missile_types) do
						comms_source:setWeaponStorageMax(missile_type, math.ceil(comms_source:getWeaponStorageMax(missile_type)*1.25))
					end
					setCommsMessage(string.format(_("upgrade-comms","%s: You can now store at least 25%% more missiles. I found some spare %s on the station. Go launch those missiles at those perfidious Exuari"),ctd.character,ctd.characterGood))
				end
			else
				setCommsMessage(_("upgrade-comms","Your ship type does not support a missile storage capacity upgrade."))
			end
		end)
	end
end
function fasterImpulse()
	if comms_source.fasterImpulseUpgrade == nil then
		addCommsReply(_("upgrade-comms","Speed up impulse engines"), function()
			local ctd = comms_target.comms_data
			if payForUpgrade() then
				local partQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
					partQuantity = comms_source.goods[ctd.characterGood]
				end
				if partQuantity > 0 then
					comms_source.fasterImpulseUpgrade = "done"
					optional_missions[comms_source:getCallSign()] = optional_missions[comms_source:getCallSign()] + 1
					comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
					comms_source.cargo = comms_source.cargo + 1
					comms_source:setImpulseMaxSpeed(comms_source:getImpulseMaxSpeed()*1.25)
					setCommsMessage(string.format(_("upgrade-comms","%s: Your impulse engines now push you up to 25%% faster. Thanks for the %s"),ctd.character,ctd.characterGood))
				else
					setCommsMessage(string.format(_("upgrade-comms","You need to bring %s to %s for the upgrade"),ctd.characterGood,ctd.character))
				end
			else
				comms_source.fasterImpulseUpgrade = "done"
				optional_missions[comms_source:getCallSign()] = optional_missions[comms_source:getCallSign()] + 1
				comms_source:setImpulseMaxSpeed(comms_source:getImpulseMaxSpeed()*1.25)
				setCommsMessage(string.format(_("upgrade-comms","%s: Your impulse engines now push you up to 25%% faster. I didn't need %s after all. Go run circles around those blinking Exuari"),ctd.character,ctd.characterGood))
			end
		end)
	end
end
function strongerHull()
	if comms_source.strongerHullUpgrade == nil then
		addCommsReply(_("upgrade-comms","Strengthen hull"), function()
			local ctd = comms_target.comms_data
			if payForUpgrade() then
				local partQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
					partQuantity = comms_source.goods[ctd.characterGood]
				end
				if partQuantity > 0 then
					comms_source.strongerHullUpgrade = "done"
					optional_missions[comms_source:getCallSign()] = optional_missions[comms_source:getCallSign()] + 1
					comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
					comms_source.cargo = comms_source.cargo + 1
					comms_source:setHullMax(comms_source:getHullMax()*1.5)
					comms_source:setHull(comms_source:getHullMax())
					setCommsMessage(string.format(_("upgrade-comms","%s: Thank you for the %s. Your hull is 50%% stronger"),ctd.character,ctd.characterGood))
				else
					setCommsMessage(string.format(_("upgrade-comms","%s: I need %s before I can increase your hull strength"),ctd.character,ctd.characterGood))
				end
			else
				comms_source.strongerHullUpgrade = "done"
				optional_missions[comms_source:getCallSign()] = optional_missions[comms_source:getCallSign()] + 1
				comms_source:setHullMax(comms_source:getHullMax()*1.5)
				comms_source:setHull(comms_source:getHullMax())
				setCommsMessage(string.format(_("upgrade-comms","%s: I made your hull 50%% stronger. I scrounged some %s from around here since you are on the Exuari offense team"),ctd.character,ctd.characterGood))
			end
		end)
	end
end
function efficientBatteries()
	if comms_source.efficientBatteriesUpgrade == nil then
		addCommsReply(_("upgrade-comms","Increase battery efficiency"), function()
			local ctd = comms_target.comms_data
			if payForUpgrade() then
				local partQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
					partQuantity = comms_source.goods[ctd.characterGood]
				end
				if partQuantity > 0 then
					comms_source.efficientBatteriesUpgrade = "done"
					optional_missions[comms_source:getCallSign()] = optional_missions[comms_source:getCallSign()] + 1
					comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
					comms_source.cargo = comms_source.cargo + 1
					comms_source:setMaxEnergy(comms_source:getMaxEnergy()*1.25)
					comms_source:setEnergy(comms_source:getMaxEnergy())
					setCommsMessage(string.format(_("upgrade-comms","%s: I appreciate the %s. You have a 25%% greater energy capacity due to increased battery efficiency"),ctd.character,ctd.characterGood))
				else
					setCommsMessage(string.format(_("upgrade-comms","%s: You need to bring me some %s before I can increase your battery efficiency"),ctd.character,ctd.characterGood))
				end
			else
				comms_source.efficientBatteriesUpgrade = "done"
				optional_missions[comms_source:getCallSign()] = optional_missions[comms_source:getCallSign()] + 1
				comms_source:setMaxEnergy(comms_source:getMaxEnergy()*1.25)
				comms_source:setEnergy(comms_source:getMaxEnergy())
				setCommsMessage(string.format(_("upgrade-comms","%s increased your battery efficiency by 25%% without the need for %s due to the pressing military demands on your ship"),ctd.character,ctd.characterGood))
			end
		end)
	end
end
function strongerShields()
	if comms_source.strongerShieldsUpgrade == nil then
		addCommsReply(_("upgrade-comms","Strengthen shields"), function()
			local ctd = comms_target.comms_data
			if payForUpgrade() then
				local partQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
					partQuantity = comms_source.goods[ctd.characterGood]
				end
				if partQuantity > 0 then
					comms_source.strongerShieldsUpgrade = "done"
					optional_missions[comms_source:getCallSign()] = optional_missions[comms_source:getCallSign()] + 1
					comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
					comms_source.cargo = comms_source.cargo + 1
					if comms_source:getShieldCount() == 1 then
						comms_source:setShieldsMax(comms_source:getShieldMax(0)*1.2)
					else
						comms_source:setShieldsMax(comms_source:getShieldMax(0)*1.2,comms_source:getShieldMax(1)*1.2)
					end
					setCommsMessage(string.format(_("upgrade-comms","%s: I've raised your shield maximum by 20%%, %s. Thanks for bringing the %s"),ctd.character,comms_source:getCallSign(),ctd.characterGood))
				else
					setCommsMessage(string.format(_("upgrade-comms","%s: You need to provide %s before I can raise your shield strength"),ctd.character,ctd.characterGood))
				end
			else
				comms_source.strongerShieldsUpgrade = "done"
				optional_missions[comms_source:getCallSign()] = optional_missions[comms_source:getCallSign()] + 1
				if comms_source:getShieldCount() == 1 then
					comms_source:setShieldsMax(comms_source:getShieldMax(0)*1.2)
				else
					comms_source:setShieldsMax(comms_source:getShieldMax(0)*1.2,comms_source:getShieldMax(1)*1.2)
				end
				setCommsMessage(string.format(_("upgrade-comms","%s: Congratulations, %s, your shields are 20%% stronger. Don't worry about the %s. Go kick those Exuari outta here"),ctd.character,comms_source:getCallSign(),ctd.characterGood))
			end
		end)
	end
end
-------------------------------------------
-- Inventory button for relay/operations --
-------------------------------------------
function cargoInventory(delta)
	for i,p in ipairs(getActivePlayerShips()) do
		local cargoHoldEmpty = true
		if p.goods ~= nil then
			for good, quantity in pairs(p.goods) do
				if quantity ~= nil and quantity > 0 then
					cargoHoldEmpty = false
					break
				end
			end
		end
		if cargoHoldEmpty then
			if p.inventory_button_rel ~= nil then
				p:removeCustom(p.inventory_button_rel)
				p.inventory_button_rel = nil
			end
			if p.inventory_button_ops ~= nil then
				p:removeCustom(p.inventory_button_ops)
				p.inventory_button_ops = nil
			end
		else
			p.inventory_button_rel = "inventory_button_rel"
			p:addCustomButton("Relay",p.inventory_button_rel,_("inventory-buttonRelay","Inventory"),function()
				string.format("")
				cargoInventoryGivenShip(p)
			end,6)
			p.inventory_button_ops = "inventory_button_ops"
			p:addCustomButton("Operations",p.inventory_button_ops,_("inventory-buttonOperations","Inventory"),function()
				string.format("")
				cargoInventoryGivenShip(p)
			end,6)
		end
	end
end
function cargoInventoryGivenShip(p)
	p:addToShipLog(string.format(_("inventory-shipLog","%s Current cargo:"),p:getCallSign()),"Yellow")
	local cargoHoldEmpty = true
	if p.goods ~= nil then
		for good, quantity in pairs(p.goods) do
			if quantity ~= nil and quantity > 0 then
				p:addToShipLog(string.format(_("inventory-shipLog","     %s: %i"),good,math.floor(quantity)),"Yellow")
				cargoHoldEmpty = false
			end
		end
	end
	if cargoHoldEmpty then
		p:addToShipLog(_("inventory-shipLog","     Empty\n"),"Yellow")
	end
	p:addToShipLog(string.format(_("inventory-shipLog","Available space: %i"),p.cargo),"Yellow")
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
	if not comms_source:isEnemy(comms_target) then
		addStationToDatabase(comms_target)
	end
    if stationCommsDiagnostic then print("set players") end
	setPlayers()
	if stationCommsDiagnostic then print("set local variable player from comms source") end
	local playerCallSign = comms_source:getCallSign()
	if stationCommsDiagnostic then print(string.format("commsStation derived name: %s",playerCallSign)) end
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
function handleDockedState()
	local playerCallSign = comms_source:getCallSign()
	local ctd = comms_target.comms_data
	if stationCommsDiagnostic then print(string.format("handleDockedState derived name: %s",playerCallSign)) end
    if comms_source:isFriendly(comms_target) then
    	if ctd.friendlyness > 66 then
    		oMsg = string.format(_("station-comms","Greetings %s!\nHow may we help you today?"),comms_source:getCallSign())
    	elseif ctd.friendlyness > 33 then
			oMsg = _("station-comms","Good day, officer!\nWhat can we do for you today?")
		else
			oMsg = _("station-comms","Hello, may I help you?")
		end
    else
		oMsg = _("station-comms","Welcome to our lovely station.")
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. _("station-comms","Forgive us if we seem a little distracted. We are carefully monitoring the enemies nearby.")
	end
	setCommsMessage(oMsg)
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
			oMsg = string.format(_("ammo-comms","%s\nWe don't have ordnance for you."),oMsg)
		end
	end
	if comms_target == primusStation and plotChoiceStation == primusStation and plot1 == nil then
		addCommsReply(_("orders-comms","Visit dispatch office"), function()
			setCommsMessage(string.format(_("orders-comms","Excellent work on your last assignment, %s. You may stand down or take another assignment"),playerCallSign))
			playVoice("Skyler03")
			addCommsReply(_("orders-comms","Stand down"), function()
				setCommsMessage(_("orders-comms","Congratulations and thank you"))
				playVoice("Pat05")
				showEndStats()
				victory("Human Navy")
			end)
			if string.find(mission_choice,"Selectable") then
				addCommsReply(_("orders-comms","Move to next region of available missions"), function()
					setCommsMessage(string.format(_("orders-comms","Dock with station %s for the details of your next assignment. Beware the asteroids"),belt1Stations[1]:getCallSign()))
					playVoice("Pat06")
					plotChoiceStation = belt1Stations[1]
					mission_region = 2
					primaryOrders = string.format(_("orders-comms","Dock with station %s"),belt1Stations[1]:getCallSign())
				end)
				if string.find(mission_choice,"Region") then
					if #first_plots >= 1 then
						addCommsReply(_("orders-comms","Request next assignment"), function()
							string.format("")
							local first_plot = tableRemoveRandom(first_plots)
							plot1 = first_plot.func
							setCommsMessage(first_plot.desc)
							if server_voices then
								playVoice(first_plot.voice)
							end
							primaryOrders = first_plot.order
						end)
					end
				else
					if #first_plots >= 1 then
						for i,first_plot in ipairs(first_plots) do
							addCommsReply(first_plot.order, function()
								string.format("")
								plot1 = first_plot.func
								setCommsMessage(first_plot.desc)
								if server_voices then
									playVoice(first_plot.voice)
								end
								primaryOrders = first_plot.order
								first_plots[i] = first_plots[#first_plots]
								first_plots[#first_plots] = nil
							end)
						end
					end
				end
			else
				addCommsReply(_("orders-comms","Request next assignment"), function()
					if #first_plots < 1 then
						setCommsMessage(string.format(_("orders-comms","Dock with station %s for the details of your next assignment. Beware the asteroids"),belt1Stations[1]:getCallSign()))
						playVoice("Pat06")
						plotChoiceStation = belt1Stations[1]
						mission_region = 2
						primaryOrders = string.format(_("orders-comms","Dock with station %s"),belt1Stations[1]:getCallSign())
					else
						string.format("")
						local first_plot = tableRemoveRandom(first_plots)
						plot1 = first_plot.func
						setCommsMessage(first_plot.desc)
						if server_voices then
							playVoice(first_plot.voice)
						end
						primaryOrders = first_plot.order
					end
					addCommsReply(_("Back"), commsStation)
				end)
			end
			addCommsReply(_("Back"), commsStation)
		end)
	end	--choose mission from dispatch office on primus station
	if comms_target == belt1Stations[1] and plotChoiceStation == belt1Stations[1] and plot1 == nil then
		addCommsReply(_("orders-comms","Visit dispatch office"), function()
			setCommsMessage(string.format(_("orders-comms","Welcome to %s station, %s. We're glad you're here. These are your choices for assignments"),belt1Stations[1]:getCallSign(),comms_source:getCallSign()))
			playVoice("Tracy02")
			if string.find(mission_choice,"Selectable") then
				addCommsReply(string.format(_("orders-comms","Move on to missions in %s area"),planetTertius:getCallSign()), function()
					setCommsMessage(string.format(_("orders-comms","Dock with station %s for your next assignment"),tertiusStation:getCallSign()))
					playVoice(string.format("Tracy01%s",planetTertius:getCallSign()))
					plotChoiceStation = tertiusStation
					mission_region = 3
					primaryOrders = string.format(_("orders-comms","Dock with station %s"),tertiusStation:getCallSign())
				end)
				if string.find(mission_choice,"Region") then
					if #second_plots >= 1 then
						addCommsReply(_("orders-comms","Request next assignment"), function()
							string.format("")
							local second_plot = tableRemoveRandom(second_plots)
							plot1 = second_plot.func
							setCommsMessage(second_plot.desc)
							if server_voices then
								playVoice(second_plot.voice)
							end
							primaryOrders = second_plot.order
						end)
					end			
				else
					if #second_plots >= 1 then
						for i,second_plot in ipairs(second_plots) do
							addCommsReply(second_plot.order, function()
								string.format("")
								plot1 = second_plot.func
								setCommsMessage(second_plot.desc)
								if server_voices then
									playVoice(second_plot)
								end
								primaryOrders = second_plot.order
								second_plots[i] = second_plots[#second_plots]
								second_plots[#second_plots] = nil
							end)
						end
					end
				end
			else
				addCommsReply(_("orders-comms","Request next assignment"), function()
					if #second_plots < 1 then
						setCommsMessage(string.format(_("orders-comms","Dock with station %s for your next assignment"),tertiusStation:getCallSign()))
						playVoice(string.format("Tracy01%s",planetTertius:getCallSign()))
						plotChoiceStation = tertiusStation
						mission_region = 3
						primaryOrders = string.format(_("orders-comms","Dock with station %s"),tertiusStation:getCallSign())
					else
						string.format("")
						local second_plot = tableRemoveRandom(second_plots)
						plot1 = second_plot.func
						setCommsMessage(second_plot.desc)
						if server_voices then
							playVoice(second_plot.voice)
						end
						primaryOrders = second_plot.order
					end
					addCommsReply(_("Back"), commsStation)
				end)
			end
			addCommsReply(_("orders-comms","Stand down"), function()
				setCommsMessage(_("orders-comms","Congratulations and thank you"))
				playVoice("Tracy04")
				showEndStats()
				victory("Human Navy")
			end)
			addCommsReply(_("Back"), commsStation)
		end)
	end
	if comms_target == tertiusStation and plotChoiceStation == tertiusStation and plot1 == nil then
		addCommsReply(_("orders-comms","Visit dispatch office"), function()
			setCommsMessage(string.format(_("orders-comms","Welcome, %s. Everything is bigger at %s station. We could use your help with one of these mission options"),comms_source:getCallSign(),tertiusStation:getCallSign()))
			playVoice("Hayden01")
			addCommsReply(_("orders-comms","Exuari Exterminates Extraterrestrials"), function()
				setCommsMessage(_("orders-comms","The Exuari have unlimited resources and continually send more ships of greater and greater power and nastier surprises. No victory condition exists"))
				playVoice("Hayden02")
				addCommsReply(_("orders-comms","Confirm"), function()
					plot1 = exterminate
					setCommsMessage(string.format(_("orders-comms","The Exuari are on their way. They will target you and the assets in and around %s"),planetTertius:getCallSign()))
					playVoice("Hayden03")
				end)
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("orders-comms","Eliminate Exuari stronghold"), function()
				setCommsMessage(_("orders-comms","The Exuari have unlimited resources, but they are constrained to funnel them through their stronghold. Obtain victory by finding and destroying the Exuari stronghold."))
				playVoice("Hayden04")
				addCommsReply(_("orders-comms","Confirm"), function()
					plot1 = stronghold
					setCommsMessage(_("orders-comms","Good luck"))
					playVoice("Hayden05")
				end)
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("orders-comms","Survive Exuari offensive"), function()
				setCommsMessage(_("orders-comms","The Exuari launch their invasion offensive. You must survive their attack. You will have a limited amount of time during which you must survive"))
				playVoice("Hayden06")
				addCommsReply(_("orders-comms","15 minutes"), function()
					plot1 = survive
					playWithTimeLimit = true
					gameTimeLimit = 15*60
					setCommsMessage(_("orders-comms","The countdown has begun"))
					playVoice("Hayden07")
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("orders-comms","30 minutes"), function()
					plot1 = survive
					playWithTimeLimit = true
					gameTimeLimit = 30*60
					setCommsMessage(_("orders-comms","The countdown has begun"))
					playVoice("Hayden07")
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("orders-comms","45 minutes"), function()
					plot1 = survive
					playWithTimeLimit = true
					gameTimeLimit = 45*60
					setCommsMessage(_("orders-comms","The countdown has begun"))
					playVoice("Hayden07")
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("orders-comms","Stand down"), function()
				setCommsMessage(_("orders-comms","Congratulations and thank you"))
				playVoice("Hayden08")
				showEndStats()
				victory("Human Navy")
			end)
			addCommsReply(_("Back"), commsStation)
		end)
	end
	if comms_target == belt1Stations[5] and plot1 == checkOrbitingArtifactEvents and not astronomerBoardedShip then
		addCommsReply(_("station-comms","Pick up astronomer Polly Hobbs"), function()
			setCommsMessage(_("station-comms","[Polly Hobbs] Thank you for picking me up. I found the source of the anomalous readings near the end of the inner solar asteroid belt. I've brought specialized scanning instruments, but they must be closer than 1 unit to be effective. Also, we will need baseline scan data from your ship's instruments"))
			playVoice("Polly03")
			primaryOrders = _("station-comms","Bring astronomer Polly Hobbs close to artifact for additional sensor readings")
			astronomerBoardedShip = true
			comms_source.astronomer = true
			addCommsReply(_("Back"), commsStation)
		end)
	end
	if comms_target == belt1Stations[2] and plot1 == checkTransportPrimusResearcherEvents and not researcherBoardedShip then
		addCommsReply(_("planetologist-comms","Pick up planetologist"), function()
			setCommsMessage(_("planetologist-comms","I'm not sure he's ready. He's not at the dock ready to board or in the transporter room. Our station is undergoing repairs, so several systems are offline"))
			addCommsReply(_("planetologist-comms","Look for planetologist"), function()
				setCommsMessage(_("planetologist-comms","The likeliest places to find him are his quarters, the lab or the observation lounge"))
				addCommsReply(_("planetologist-comms","Try his quarters"), function()
					if lastLocationPlanetologist == "his quarters" then
						planetologistChase = planetologistChase + 1
					else
						planetologistChase = 0
					end
					if random(1,5) + planetologistChase > 4 then
						setCommsMessage(_("planetologist-comms","[Enrique Flogistan] Yes? What can I do for you? Please be quick about it, I'm in a bit of a hurry"))
						playVoice("Enrique01")
						addCommsReply(string.format(_("planetologist-comms","Ready to begin your observations of %s?"),planetPrimus:getCallSign()), function()
							if random(1,100) < 50 then
								lastLocationPlanetologist = "the lab"
								playVoice("Enrique02")
							else
								lastLocationPlanetologist = "the observation lounge"
								playVoice("Enrique03")
							end
							setCommsMessage(string.format(_("planetologist-comms","[Enrique Flogistan] Almost. Let me grab something from %s"),lastLocationPlanetologist))
							addCommsReply(_("Back"), commsStation)
						end)
						addCommsReply(string.format(_("planetologist-comms","We are here to transport you to %s"),primusStation:getCallSign()), function()
							if random(1,100) < 50 then
								lastLocationPlanetologist = "the lab"
							else
								lastLocationPlanetologist = "the observation lounge"
							end
							setCommsMessage(string.format(_("planetologist-comms","[Enrique Flogistan] You're not my normal transport representative. Besides, I still need to pack a few things.\n\nHe heads off down the corridor towards %s"),lastLocationPlanetologist))
							playVoice("Enrique04")
							addCommsReply(_("Back"), commsStation)
						end)
						addCommsReply(string.format(_("planetologist-comms","My ship, %s, is here to transport you"),comms_source:getCallSign()), function()
							setCommsMessage(_("planetologist-comms","Is your ship armed?"))
							playVoice("Enrique05")
							addCommsReply(_("planetologist-comms","Yes, we can handle any Exuari in the area"), function()
								local scurry_choice = random(1,100)
								if scurry_choice < 50 then
									lastLocationPlanetologist = "the lab"
								else
									lastLocationPlanetologist = "the observation lounge"
								end
								if random(1,5) + planetologistChase > 4 then
									if researcherBoardedShip then
										setCommsMessage(_("planetologist-comms","He's already boarded a ship"))
									else
										setCommsMessage(_("planetologist-comms","Good. Let's go\n\nHe joins you as you go back to the ship"))
									end
									researcherBoardedShip = true
									comms_source.planetologistAboard = true
								else
									setCommsMessage(string.format(_("planetologist-comms","Good. I still need a couple of items from %s"),lastLocationPlanetologist))
									if scurry_choice < 50 then
										playVoice("Enrique06")
									else
										playVoice("Enrique07")
									end
								end
								addCommsReply(_("Back"), commsStation)
							end)
							addCommsReply(_("Back"), commsStation)
						end)
					else
						if random(1,100) < 50 then
							lastLocationPlanetologist = "the lab"
						else
							lastLocationPlanetologist = "the observation lounge"
						end
						setCommsMessage(string.format(_("planetologist-comms","He's not in his quarters. His digital room assistant predicts he went to %s"),lastLocationPlanetologist))
					end
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("planetologist-comms","Try the lab"), function()
					if lastLocationPlanetologist == "the lab" then
						planetologistChase = planetologistChase + 1
					else
						planetologistChase = 0
					end
					if random(1,5) + planetologistChase > 4 then
						setCommsMessage(_("planetologist-comms","[Enrique Flogistan] Hello, welcome to the planetology lab. Can I help you?"))
						playVoice("Enrique08")
						addCommsReply(string.format(_("planetologist-comms","Ready to go observe %s?"),planetPrimus:getCallSign()), function()
							if random(1,100) < 50 then
								lastLocationPlanetologist = "his quarters"
							else
								lastLocationPlanetologist = "the observation lounge"
							end
							setCommsMessage(string.format(_("planetologist-comms","[Enrique Flogistan] Almost. Let me get one more thing.\n\nHe leaves the lab for %s"),lastLocationPlanetologist))
							playVoice("Enrique09")
							addCommsReply(_("Back"), commsStation)
						end)
						addCommsReply(string.format(_("planetologist-comms","We're ready to transport you to %s"),primusStation:getCallSign()), function()
							local tech_choice = random(1,100)
							if tech_choice < 50 then
								lastLocationPlanetologist = "his quarters"
							else
								lastLocationPlanetologist = "the observation lounge"
							end
							setCommsMessage(string.format(_("planetologist-comms","[Enrique Flogistan] Already?!\n\nHe quickly leaves the lab. The lab technician looks over as he leaves\n\n[Lab technician] I think he's going to %s"),lastLocationPlanetologist))
							playVoice("Enrique10")
							if tech_choice < 50 then
								playVoice("Rory01")
							else
								playVoice("Rory02")
							end
							addCommsReply(_("Back"), commsStation)
						end)
						addCommsReply(string.format(_("planetologist-comms","%s has docked and is waiting on you"),comms_source:getCallSign()), function()
							setCommsMessage(_("planetologist-comms","Are you aware of the Exuari that have been spotted in the area?"))
							playVoice("Enrique11")
							addCommsReply(_("planetologist-comms","Yes, don't worry about them"), function()
								if random(1,100) < 50 then
									setCommsMessage(_("planetologist-comms","[Enrique Flogistan] Good to know. I need to finishing packing in my quarters"))
									playVoice("Enrique12")
									lastLocationPlanetologist = "his quarters"
								else
									setCommsMessage(_("planetologist-comms","[Enrique Flogistan] Good to know. I left some notes in the observation lounge"))
									playVoice("Enrique13")
									lastLocationPlanetologist = "the observation lounge"
								end
								addCommsReply(_("Back"), commsStation)
							end)
							addCommsReply(_("Back"), commsStation)
						end)
					else
						if random(1,100) < 50 then
							lastLocationPlanetologist = "his quarters"
							playVoice("Rory03")
						else
							lastLocationPlanetologist = "the observation lounge"
							playVoice("Rory04")
						end
						setCommsMessage(string.format(_("planetologist-comms","[Lab technician] You just missed him. I think he said he was going to %s"),lastLocationPlanetologist))
					end
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("planetologist-comms","Try observation lounge"), function()
					if planetologistDiagnostic then print("looking in observation lounge") end
					if lastLocationPlanetologist == "the observation lounge" then
						planetologistChase = planetologistChase + 1
					else
						planetologistChase = 0
					end
					if planetologistDiagnostic then print("check previous location") end
					if random(1,5) + planetologistChase > 4 then
						if planetologistDiagnostic then print("found planetologist") end
						setCommsMessage(string.format(_("planetologist-comms","[Enrique Flogistan] Just take in the gorgeous view of %s from here"),planetPrimus:getCallSign()))
						playVoice("Enrique14")
						addCommsReply(string.format(_("planetologist-comms","Ready for a closer view of %s?"),planetPrimus:getCallSign()), function()
							if planetologistDiagnostic then print("closer view") end
							if random(1,100) < 50 then
								lastLocationPlanetologist = "his quarters"
							else
								lastLocationPlanetologist = "the lab"
							end
							setCommsMessage(string.format(_("planetologist-comms","[Enrique Flogistan] Just about. I forgot to pack something.\n\nHe leaves the observation lounge to go to %s"),lastLocationPlanetologist))
							playVoice("Enrique15")
							addCommsReply(_("Back"), commsStation)
						end)
						addCommsReply(string.format(_("planetologist-comms","We're ready to take you to %s"),primusStation:getCallSign()), function()
							if planetologistDiagnostic then print("ready to take you") end
							if random(1,100) < 50 then
								setCommsMessage(_("planetologist-comms","[Enrique Flogistan] Well I'm not. I just need a few more items from my quarters"))
								playVoice("Enrique16")
								lastLocationPlanetologist = "his quarters"
							else
								setCommsMessage(_("planetologist-comms","[Enrique Flogistan] Well I'm not. I just need a few more items from the lab"))
								playVoice("Enrique17")
								lastLocationPlanetologist = "the lab"
							end
							addCommsReply(_("Back"), commsStation)
						end)
						addCommsReply(string.format(_("planetologist-comms","%s has been ordered to get you to %s"),comms_source:getCallSign(), primusStation:getCallSign()), function()
							if planetologistDiagnostic then print("ordered to get you") end
							setCommsMessage(_("planetologist-comms","I heard about your encounter with the Exuari. You know they could come back, right?"))
							playVoice("Enrique18")
							addCommsReply(_("planetologist-comms","Certainly. We'll be ready, don't worry"), function()
								if random(1,100) < 50 then
									setCommsMessage(_("planetologist-comms","[Enrique Flogistan] I admire your confidence. I'll get my things from my quarters"))
									playVoice("Enrique19")
									lastLocationPlanetologist = "his quarters"
								else
									setCommsMessage(_("planetologist-comms","[Enrique Flogistan] I admire your confidence. I'll get my research material from the lab"))
									playVoice("Enrique20")
									lastLocationPlanetologist = "the lab"
								end
								addCommsReply(_("Back"), commsStation)
							end)
							addCommsReply(_("Back"), commsStation)
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
						setCommsMessage(string.format(_("planetologist-comms","[Station repair crewman] He just left for %s"),lastLocationPlanetologist))
					end
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("planetologist-comms","Contact planetologist directly"), function()
				setCommsMessage(_("planetologist-comms","Repair work prevents contact with individual"))
				addCommsReply(_("planetologist-comms","Contact Enrique Flogistan's quarters"), function()
					if random(1,100) < 50 then
						setCommsMessage(_("planetologist-comms","[Enrique Flogistan] Who is it?"))
						playVoice("Enrique21")
						planetologistChase = planetologistChase + 1
						addCommsReply(string.format(_("planetologist-comms","This is %s. We are your transportation to %s"),comms_source:getCallSign(),primusStation:getCallSign()), function()
							if random(1,100) < 50 then
								lastLocationPlanetologist = "the lab"
								playVoice("Enrique22")
							else
								lastLocationPlanetologist = "the observation lounge"
								playVoice("Enrique23")
							end
							setCommsMessage(string.format(_("planetologist-comms","I'm going to %s before we leave"),lastLocationPlanetologist))
							addCommsReply(_("Back"), commsStation)
						end)
					else
						if lastLocationPlanetologist == "his quarters" then
							planetologistChase = planetologistChase + 1
						else
							planetologistChase = 0
						end
						setCommsMessage(_("planetologist-comms","No reply from Enrique Flogistan's quarters"))
					end
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("planetologist-comms","Contact planetology lab"), function()
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
					setCommsMessage(string.format(_("planetologist-comms","A lab technician answers and tells you Enrique Flogistan is probably going to %s"),lastLocationPlanetologist))
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("planetologist-comms","Contact observation lounge"), function()
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
					setCommsMessage(string.format(_("planetologist-comms","A repair crewman answers and tells you Enrique Flogistan is probably going to %s"),lastLocationPlanetologist))
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("planetologist-comms","Contact station galley"), function()
					planetologistChase = 0
					setCommsMessage(_("planetologist-comms","[Cook] Hello, who's there?"))
					playVoice("Karsyn01")
					addCommsReply(string.format(_("planetologist-comms","I'm from %s. I'm looking for Enrique Flogistan"),comms_source:getCallSign()), function()
						setCommsMessage(_("planetologist-comms","He was here about an hour ago. You might try his quarters, the observation lounge or the lab"))
						playVoice("Karsyn02")
						addCommsReply(_("Back"), commsStation)
					end)
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("planetologist-comms","Contact station security office"), function()
					planetologistChase = 0
					setCommsMessage(_("planetologist-comms","[Security officer] May I help you?"))
					playVoice("Taylor01")
					addCommsReply(_("planetologist-comms","I'm looking for Enrique Flogistan"), function()
						playVoice("Taylor02")
						setCommsMessage(_("planetologist-comms","He's not here in the security office. Our records show he often frequents his quarters, the observation lounge and the planetology lab"))
						addCommsReply(_("Back"), commsStation)
					end)
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("planetologist-comms","Contact station maintenance office"), function()
					planetologistChase = 0
					setCommsMessage(_("planetologist-comms","[Maintenance technician] Hi, what's broken?"))
					playVoice("Quinn01")
					addCommsReply(_("planetologist-comms","Nothing. I'm looking for Enrique Flogistan"), function()
						playVoice("Quinn02")
						setCommsMessage(_("planetologist-comms","He's not here. Good luck finding him"))
						addCommsReply(_("Back"), commsStation)
					end)
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("planetologist-comms","Contact station operations office"), function()
					planetologistChase = 0
					setCommsMessage(_("planetologist-comms","[Operations manager] Yes?"))
					playVoice("Avery01")
					addCommsReply(_("planetologist-comms","Can you help me find Enrique Flogistan?"), function()
						playVoice("Avery02")
						setCommsMessage(_("planetologist-comms","He's not here in operations. We are short handed right now with all the repairs going on. I'm afraid you'll have to find him yourself"))
						addCommsReply(_("Back"), commsStation)
					end)
					addCommsReply(_("Back"), commsStation)
				end)
			end)
			addCommsReply(_("planetologist-comms","Scan for planetologist"), function()
				local scanResultChoice = math.random(1,3)
				if scanResultChoice == 1 then
					lastLocationPlanetologist = "his quarters"
				elseif scanResultChoice == 2 then
					lastLocationPlanetologist = "the lab"
				else
					lastLocationPlanetologist = "the observation lounge"
				end
				setCommsMessage(string.format(_("planetologist-comms","Sensors show him in %s"),lastLocationPlanetologist))
				addCommsReply(string.format(_("planetologist-comms","Beam him over from %s"),lastLocationPlanetologist), function()
					if random(1,100) < 5 then
						if researcherBoardedShip then
							setCommsMessage(_("planetologist-comms","He's already boarded a ship"))
						else
							setCommsMessage(_("planetologist-comms","He has been beamed aboard"))
						end
						researcherBoardedShip = true
						comms_source.planetologistAboard = true
					else
						setCommsMessage(_("planetologist-comms","Interference from station repairs prevents a transporter lock"))
						planetologistChase = 0
					end
					addCommsReply(_("Back"), commsStation)
				end)
			end)
			addCommsReply(_("Back"), commsStation)
		end)
	end
	if comms_target == secondusStations[1] and plot1 == checkFixSatelliteEvents and not comms_target.satelliteFixed then
		addCommsReply(_("station-comms","Satellite problems?"), function()
			setCommsMessage(string.format(_("station-comms","Yes. Our technicians have tracked back the problem to a faulty relay module. However, They are unable to fix it with available parts. They need %s. They've requested delivery, but hear it will take weeks before the next delivery cycle. I don't suppose you could bring us what we need?"),comms_target.satelliteFixGood))
			playVoice("Ellis01")
			local playerCallSign = comms_source:getCallSign()
			local ctd = comms_target.comms_data
			if fixSatelliteDiagnostic then print("satellite fix good 1: " .. comms_target.satelliteFixGood) end
			if fixSatelliteDiagnostic then 
				if comms_source.goods ~= nil and comms_source.goods[ctd.satelliteFixGood] == nil then
					print("related player good: nil")
				else
					print("related player good: " .. comms_source.goods[ctd.satelliteFixGood])
				end
			end 
			if comms_source.goods ~= nil and comms_source.goods[comms_target.satelliteFixGood] ~= nil and comms_source.goods[comms_target.satelliteFixGood] > 0 then
				addCommsReply(string.format(_("station-comms","Provide %s"),comms_target.satelliteFixGood), function()
					comms_source.goods[comms_target.satelliteFixGood] = comms_source.goods[comms_target.satelliteFixGood] - 1
					comms_source.cargo = comms_source.cargo + 1
					comms_target.satelliteFixed = true
					setCommsMessage(_("station-comms","Thanks. With your help, we fixed the faulty relay module"))
					playVoice("Ellis02")
					comms_source:addReputationPoints(75 - (30*difficulty))
					addCommsReply(_("Back"), commsStation)
				end)
			end
			addCommsReply(_("Back"), commsStation)
		end)
	end
	if comms_target == secondusStations[2] and plot1 == checkFixSatelliteEvents and not comms_target.satelliteFixed then
		addCommsReply(_("station-comms","Having satellite trouble?"), function()
			playVoice("Peyton01")
			setCommsMessage(string.format(_("station-comms","It seems we've got an outdated servo motor. Replacement will take time. Our repairman says he can fix it with %s, so we don't have to wait. Do you have any?"),comms_target.satelliteFixGood))
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
			if comms_source.goods ~= nil and comms_source.goods[comms_target.satelliteFixGood] ~= nil and comms_source.goods[comms_target.satelliteFixGood] > 0 then
				addCommsReply(string.format(_("station-comms","Give %s to %s"),comms_target.satelliteFixGood, comms_target:getCallSign()), function()
					comms_source.goods[comms_target.satelliteFixGood] = comms_source.goods[comms_target.satelliteFixGood] - 1
					comms_source.cargo = comms_source.cargo + 1
					comms_target.satelliteFixed = true
					playVoice("Peyton02")
					setCommsMessage(_("station-comms","That worked. Thanks"))
					comms_source:addReputationPoints(75 - (30*difficulty))
					addCommsReply(_("Back"), commsStation)
				end)
			end
			addCommsReply(_("Back"), commsStation)
		end)
	end
	if comms_target == secondusStations[3] and plot1 == checkFixSatelliteEvents and not comms_target.satelliteFixed then
		addCommsReply(_("station-comms","Can we help with your satellite?"), function()
			playVoice("Reese01")
			setCommsMessage(string.format(_("station-comms","Only if you've got %s aboard your ship. Otherwise, we're stuck"),comms_target.satelliteFixGood))
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
				addCommsReply(string.format(_("station-comms","Provide %s"),comms_target.satelliteFixGood), function()
					comms_source.goods[comms_target.satelliteFixGood] = comms_source.goods[comms_target.satelliteFixGood] - 1
					comms_source.cargo = comms_source.cargo + 1
					comms_target.satelliteFixed = true
					playVoice("Reese02")
					setCommsMessage(_("station-comms","You have saved us a tremendous headache. We thought we'd have to wait two months before we could fix the problem. Thanks"))
					comms_source:addReputationPoints(75 - (30*difficulty))
					addCommsReply(_("Back"), commsStation)
				end)
			end
			addCommsReply(_("Back"), commsStation)
		end)
	end
	if stationCommsDiagnostic then print(ctd.public_relations) end
	if ctd.public_relations then
		addCommsReply(_("station-comms","Tell me more about your station"), function()
			setCommsMessage(_("station-comms","What would you like to know?"))
			addCommsReply(_("stationGeneralInfo-comms","General information"), function()
				setCommsMessage(ctd.general_information)
				addCommsReply(_("Back"), commsStation)
			end)
			if ctd.history ~= nil then
				addCommsReply(_("stationStory-comms","Station history"), function()
					setCommsMessage(ctd.history)
					addCommsReply(_("Back"), commsStation)
				end)
			end
			if comms_source:isFriendly(comms_target) then
				if ctd.gossip ~= nil then
					if random(1,100) < (100 - (30 * (difficulty - .5))) then
						addCommsReply(_("gossip-comms","Gossip"), function()
							setCommsMessage(ctd.gossip)
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
			end
		end)	--end station info comms reply branch
	end	--end public relations if branch
	if stationCommsDiagnostic then print(ctd.character) end
	if ctd.character ~= nil then
		addCommsReply(string.format(_("characterInfo-comms","Tell me about %s"),ctd.character), function()
			if ctd.characterDescription ~= nil then
				setCommsMessage(ctd.characterDescription)
			else
				if ctd.characterDeadEnd == nil then
					local dead_end_responses = {
						string.format(_("characterInfo-comms","Never heard of %s"),ctd.character),
						string.format(_("characterInfo-comms","%s died last week. The funeral was yesterday"),ctd.character),
						string.format(_("characterInfo-comms","%s? Who's %s? There's nobody here named %s"),ctd.character,ctd.character,ctd.character),
						string.format(_("characterInfo-comms","We don't talk about %s. They are gone and good riddance"),ctd.character),
						string.format(_("characterInfo-comms","I think %s moved away"),ctd.character),
						string.format(_("characterInfo-comms","My aunt's neighbor's second cousin is named %s. However, %s lives far away from here."),ctd.character,ctd.character),
					}
					ctd.characterDeadEnd = dead_end_responses[math.random(1,#dead_end_responses)]
				end
				setCommsMessage(ctd.characterDeadEnd)
			end
			local upgrade_function = {
				["shrinkBeamCycle"] = shrinkBeamCycle,
				["increaseSpin"] = increaseSpin,
				["addAuxTube"] = addAuxTube,
				["coolBeam"] = coolBeam,
				["longerBeam"] = longerBeam,
				["damageBeam"] = damageBeam,
				["moreMissiles"] = moreMissiles,
				["fasterImpulse"] = fasterImpulse,
				["strongerHull"] = strongerHull,
				["efficientBatteries"] = efficientBatteries,
				["strongerShields"] = strongerShields,
			}
			if upgrade_function[ctd.characterFunction] ~= nil then
				upgrade_function[ctd.characterFunction]()
			end
			addCommsReply(_("Back"), commsStation)
		end)
	end
	if speed_adjust_count == nil then
		speed_adjust_count = 0
	end
	if random(1,100) < (80 - (speed_adjust_count * 10)) then
		addCommsReply(_("station-comms","Request access to isolated transporter pad"), function()
			setCommsMessage(_("station-comms","That will damage your reputation. Do you wish to proceed?"))
			addCommsReply(_("station-comms","Proceed regardless of the reputation cost"),function()
				local p = getPlayerShip(-1)
				p:takeReputationPoints(math.floor(p:getReputationPoints()/2))
				setCommsMessage(_("station-comms","You are transported to an unknown location. A small man in front of a vast array of virtual monitors showing constantly changing pictures of different planetary systems asks you what you want"))
				addCommsReply(string.format(_("station-comms","Slow orbital speed of %s"),planetPrimus:getCallSign()),function()
					planetPrimus.orbit_speed = planetPrimus.orbit_speed * 1.1
					planetPrimus:setOrbit(planetSol,planetPrimus.orbit_speed)
					speed_adjust_count = speed_adjust_count + 1
					setCommsMessage(_("station-comms","He twists a small dial and says, 'Done.'"))
					playVoice("Ozzie01")
				end)
				addCommsReply(string.format(_("station-comms","Slow orbital speed of the moon orbiting %s"),planetPrimus:getCallSign()),function()
					planetPrimusMoonOrbitTime = planetPrimusMoonOrbitTime * 1.1
					planetPrimusMoon:setOrbit(planetPrimus,planetPrimusMoonOrbitTime)
					speed_adjust_count = speed_adjust_count + 1
					setCommsMessage(_("station-comms","He moves a slider and says, 'Ok.'"))
					playVoice("Ozzie02")
				end)
				addCommsReply(string.format(_("station-comms","Slow orbital speed of %s"),planetSecondus:getCallSign()),function()
					planetSecondus.orbit_speed = planetSecondus.orbit_speed * 1.1
					planetSecondus:setOrbit(planetSol,planetSecondus.orbit_speed)
					speed_adjust_count = speed_adjust_count + 1
					setCommsMessage(_("station-comms","He types in a couple of numbers and says, 'Happy?'"))
					playVoice("Ozzie03")
				end)
				addCommsReply(string.format(_("station-comms","Slow orbital speed of stations orbiting %s"),planetSecondus:getCallSign()),function()
					secondusStationOrbitIncrement = secondusStationOrbitIncrement * .9
					speed_adjust_count = speed_adjust_count + 1
					setCommsMessage(_("station-comms","He flips a couple of switches and says, 'I love programmable stations'"))
					playVoice("Ozzie04")
				end)
				addCommsReply(string.format(_("station-comms","Slow orbital speed of the inner belt around %s"),planetSol:getCallSign()),function()
					belt1OrbitalSpeed = belt1OrbitalSpeed * .9
					for i=1,#beltAsteroidList do
						local ta = beltAsteroidList[i]
						if ta ~= nil and ta:isValid() and ta.belt_id == "belt1" then
							ta.speed = belt1OrbitalSpeed
						end
					end
					speed_adjust_count = speed_adjust_count + 1
					setCommsMessage(_("station-comms","He rubs one of the monitors a bit and says 'that should do it.'"))
					playVoice("Ozzie05")
				end)
				addCommsReply(string.format(_("station-comms","Slow orbital speed of the outer belt around %s"),planetSol:getCallSign()),function()
					belt2OrbitalSpeed = belt2OrbitalSpeed * .9
					for i=1,#beltAsteroidList do
						local ta = beltAsteroidList[i]
						if ta ~= nil and ta:isValid() and ta.belt_id == "belt2" then
							ta.speed = belt2OrbitalSpeed
						end
					end
					speed_adjust_count = speed_adjust_count + 1
					setCommsMessage(_("station-comms","He says, 'if you insist' and opens a small panel in the wall and enters a code on a keypad."))
					playVoice("Ozzie06")
				end)
				addCommsReply(string.format(_("station-comms","Slow orbital speed of %s"),planetTertius:getCallSign()),function()
					planetTertius.orbit_speed = planetTertius.orbit_speed * 1.1
					planetTertius:setOrbit(planetSol,planetTertius.orbit_speed)
					speed_adjust_count = speed_adjust_count + 1
					setCommsMessage(_("station-comms","He sighs, stands up, grabs a large lever and pulls it about two inches towards him then says, 'there.'"))
					playVoice("Ozzie07")
				end)
				addCommsReply(string.format(_("station-comms","Slow orbital speed of the inner belt around %s"),planetTertius:getCallSign()),function()
					tertiusOrbitalBodyIncrement = tertiusOrbitalBodyIncrement * .9
					for i=1,#tertiusAsteroids do
						local ta = tertiusAsteroids[i]
						if ta ~= nil and ta:isValid() and ta.belt_id == "tMoonBelt" then
							ta.speed = tertiusOrbitalBodyIncrement
						end
					end
					speed_adjust_count = speed_adjust_count + 1
					setCommsMessage(_("station-comms","He pulls a keyboard out from under his desk, types a couple of things and says, 'Alright.'"))
					playVoice("Ozzie08")
				end)
				addCommsReply(string.format(_("station-comms","Slow orbital speed of the outer belt around %s"),planetTertius:getCallSign()),function()
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
					setCommsMessage(_("station-comms","He dons a couple of purple haptic gloves, makes a couple of arcane gestures and says, 'You asked for it.'"))
					playVoice("Ozzie09")
				end)
			end)
		end)
	end
	if comms_source:isFriendly(comms_target) then
		if plot1 == checkTransportPrimusResearcherEvents and not researcherBoardedShip then
			addCommsReply(string.format(_("station-comms","Where is %s? (cost 10 reputation)"),belt1Stations[2]:getCallSign()), function()
				if comms_source:takeReputationPoints(10) then
					if difficulty <= 1 then
						setCommsMessage(string.format(_("station-comms","%s is near %s"),belt1Stations[2]:getCallSign(),belt1Stations[1]:getCallSign()))
					else
						setCommsMessage(string.format(_("station-comms","%s is along the inner solar asteroid belt"),belt1Stations[2]))
					end
				else
					setCommsMessage(_("needRep-comms","Not enough reputation"))
				end
				addCommsReply(_("Back"), commsStation)
			end)
		end
		addCommsReply(_("orders-comms","What are my current orders?"), function()
			setOptionalOrders()
			setSecondaryOrders()
			ordMsg = primaryOrders .. "\n" .. secondaryOrders .. optionalOrders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format(_("orders-comms","\n   %i Minutes remain in game"),math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
			addCommsReply(_("Back"), commsStation)
		end)
		if math.random(1,5) <= (3 - difficulty) then
			if comms_source:getRepairCrewCount() < comms_source.maxRepairCrew then
				hireCost = math.random(30,60)
			else
				hireCost = math.random(45,90)
			end
			addCommsReply(string.format(_("trade-comms","Recruit repair crew member for %i reputation"),hireCost), function()
				if not comms_source:takeReputationPoints(hireCost) then
					setCommsMessage(_("needRep-comms","Insufficient reputation"))
				else
					comms_source:setRepairCrewCount(comms_source:getRepairCrewCount() + 1)
					setCommsMessage(_("trade-comms","Repair crew member hired"))
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
				addCommsReply(string.format(_("trade-comms","Purchase coolant for %i reputation"),coolantCost), function()
					if not comms_source:takeReputationPoints(coolantCost) then
						setCommsMessage(_("needRep-comms","Insufficient reputation"))
					else
						comms_source:setMaxCoolant(comms_source:getMaxCoolant() + 2)
						setCommsMessage(_("trade-comms","Additional coolant purchased"))
					end
					addCommsReply(_("Back"), commsStation)
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
			addCommsReply(string.format(_("trade-comms","Recruit repair crew member for %i reputation"),hireCost), function()
				if not comms_source:takeReputationPoints(hireCost) then
					setCommsMessage(_("needRep-comms","Insufficient reputation"))
				else
					comms_source:setRepairCrewCount(comms_source:getRepairCrewCount() + 1)
					setCommsMessage(_("trade-comms","Repair crew member hired"))
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
				addCommsReply(string.format(_("trade-comms","Purchase coolant for %i reputation"),coolantCost), function()
					if not comms_source:takeReputationPoints(coolantCost) then
						setCommsMessage(_("needRep-comms","Insufficient reputation"))
					else
						comms_source:setMaxCoolant(comms_source:getMaxCoolant() + 1)
						setCommsMessage(_("trade-comms","Additional coolant purchased"))
					end
					addCommsReply(_("Back"), commsStation)
				end)
			end
		end
	end	--end friendly/neutral 
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
		setCommsMessage(string.format(_("cartographyOffice-comms","%s\n\nYou can examine the brochure on the coffee table, talk to the apprentice cartographer or talk to the master cartographer"),comms_target.cartographer_description))
		addCommsReply(_("cartographyOffice-comms","What's the difference between the apprentice and the master?"), function()
			setCommsMessage(_("cartographyOffice-comms","The clerk responds in a bored voice, 'The apprentice knows the local area and is learning the broader area. The master knows the local and the broader area but can't be bothered with the local area'"))
			addCommsReply(_("Back"), commsStation)
		end)
		addCommsReply(string.format(_("cartographyOffice-comms","Examine brochure (%i reputation)"),getCartographerCost()),function()
			if comms_source:takeReputationPoints(1) then
				setCommsMessage(_("cartographyOffice-comms","The brochure has a list of nearby stations and has a list of goods nearby"))
				addCommsReply(string.format(_("cartographyOffice-comms","Examine station list (%i reputation)"),getCartographerCost()), function()
					if comms_source:takeReputationPoints(1) then
						local brochure_stations = ""
						local sx, sy = comms_target:getPosition()
						local nearby_objects = getObjectsInRadius(sx,sy,30000)
						for i, obj in ipairs(nearby_objects) do
							if obj.typeName == "SpaceStation" then
								if not obj:isEnemy(comms_target) then
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
						setCommsMessage(brochure_stations)
					else
						setCommsMessage(_("needRep-comms","Insufficient reputation"))
					end
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(string.format(_("cartographyOffice-comms","Examine goods list (%i reputation)"),getCartographerCost()), function()
					if comms_source:takeReputationPoints(1) then
						local brochure_goods = ""
						local sx, sy = comms_target:getPosition()
						local nearby_objects = getObjectsInRadius(sx,sy,30000)
						for i, obj in ipairs(nearby_objects) do
							if obj.typeName == "SpaceStation" then
								if not obj:isEnemy(comms_target) then
									if obj.comms_data.goods ~= nil then
										for good, good_data in pairs(obj.comms_data.goods) do
											if brochure_goods == "" then
												brochure_goods = string.format(_("cartographyOffice-comms","Good, quantity, cost, station:\n%s, %i, %i, %s"),good,good_data["quantity"],good_data["cost"],obj:getCallSign())
											else
												brochure_goods = string.format(_("cartographyOffice-comms","%s\n%s, %i, %i, %s"),brochure_goods,good,good_data["quantity"],good_data["cost"],obj:getCallSign())
											end
										end
									end
								end
							end
						end
						setCommsMessage(brochure_goods)
					else
						setCommsMessage(_("needRep-comms","Insufficient reputation"))
					end
					addCommsReply(_("Back"), commsStation)
				end)
			else
				setCommsMessage(_("needRep-comms","Insufficient reputation"))
			end
			addCommsReply(_("Back"), commsStation)
		end)
		addCommsReply(string.format(_("cartographyOffice-comms","Talk to apprentice cartographer (%i reputation)"),getCartographerCost("apprentice")), function()
			if comms_source:takeReputationPoints(1) then
				setCommsMessage(_("cartographyOffice-comms","Hi, would you like for me to locate a station or some goods for you?"))
				addCommsReply(_("cartographyOffice-comms","Locate station"), function()
					setCommsMessage(_("cartographyOffice-comms","These are stations I have learned about"))
					local sx, sy = comms_target:getPosition()
					local nearby_objects = getObjectsInRadius(sx,sy,50000)
					local stations_known = 0
					for i, obj in ipairs(nearby_objects) do
						if obj.typeName == "SpaceStation" then
							if not obj:isEnemy(comms_target) then
								stations_known = stations_known + 1
								addCommsReply(obj:getCallSign(),function()
									local station_details = string.format(_("cartographyOffice-comms","%s %s %s"),obj:getSectorName(),obj:getFaction(),obj:getCallSign())
									if obj.comms_data.orbit ~= nil then
										station_details = string.format(_("cartographyOffice-comms","%s %s"),station_details,obj.comms_data.orbit)
									end
									if obj.comms_data.goods ~= nil then
										station_details = string.format(_("cartographyOffice-comms","%s\nGood, quantity, cost"),station_details)
										for good, good_data in pairs(obj.comms_data.goods) do
											station_details = string.format(_("cartographyOffice-comms","%s\n   %s, %i, %i"),station_details,good,good_data["quantity"],good_data["cost"])
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
						setCommsMessage(_("cartographyOffice-comms","I have learned of no stations yet"))
					end
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("cartographyOffice-comms","Locate goods"), function()
					setCommsMessage(_("cartographyOffice-comms","These are the goods I know about"))
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
						addCommsReply(good, function()
							local station_details = string.format(_("cartographyOffice-comms","%s %s %s"),obj:getSectorName(),obj:getFaction(),obj:getCallSign())
							if obj.comms_data.orbit ~= nil then
								station_details = string.format(_("cartographyOffice-comms","%s %s"),station_details,obj.comms_data.orbit)
							end
							if obj.comms_data.goods ~= nil then
								station_details = string.format(_("cartographyOffice-comms","%s\nGood, quantity, cost"),station_details)
								for good, good_data in pairs(obj.comms_data.goods) do
									station_details = string.format(_("cartographyOffice-comms","%s\n   %s, %i, %i"),station_details,good,good_data["quantity"],good_data["cost"])
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
					addCommsReply(_("Back"), commsStation)
				end)
			else
				setCommsMessage(_("needRep-comms","Insufficient reputation"))
			end
			addCommsReply(_("Back"), commsStation)
		end)
		addCommsReply(string.format(_("cartographyOffice-comms","Talk to master cartographer (%i reputation)"),getCartographerCost("master")), function()
			if comms_source:getWaypointCount() >= 9 then
				setCommsMessage(_("cartographyOffice-comms","The clerk clears her throat:\n\nMy indicators show you have zero available waypoints. To get the most from the master cartographer, you should delete one or more so that he can update your systems appropriately.\n\nI just want you to get the maximum benefit for the time you spend with him"))
				addCommsReply(_("cartographyOffice-comms","Continue to Master Cartographer"), masterCartographer)
			else
				masterCartographer()
			end
			addCommsReply(_("Back"), commsStation)
		end)
		addCommsReply(_("Back"), commsStation)
	end)	
	local goodCount = 0
	for good, goodData in pairs(ctd.goods) do
		goodCount = goodCount + 1
	end
	if goodCount > 0 then
		addCommsReply(_("trade-comms","Buy, sell, trade"), function()
			local ctd = comms_target.comms_data
			local goodsReport = string.format(_("trade-comms","Station %s:\nGoods or components available for sale: quantity, cost in reputation\n"),comms_target:getCallSign())
			for good, goodData in pairs(ctd.goods) do
				goodsReport = goodsReport .. string.format(_("trade-comms","     %s: %i, %i\n"),good,goodData["quantity"],goodData["cost"])
			end
			if ctd.buy ~= nil then
				goodsReport = goodsReport .. _("trade-comms","Goods or components station will buy: price in reputation\n")
				for good, price in pairs(ctd.buy) do
					goodsReport = goodsReport .. string.format(_("trade-comms","     %s: %i\n"),good,price)
				end
			end
			goodsReport = goodsReport .. string.format(_("trade-comms","Current cargo aboard %s:\n"),comms_source:getCallSign())
			local cargoHoldEmpty = true
			local goodCount = 0
			if comms_source.goods ~= nil then
				for good, goodQuantity in pairs(comms_source.goods) do
					goodCount = goodCount + 1
					goodsReport = goodsReport .. string.format(_("trade-comms","     %s: %i\n"),good,goodQuantity)
				end
			end
			if goodCount < 1 then
				goodsReport = goodsReport .. _("trade-comms","     Empty\n")
			end
			goodsReport = goodsReport .. string.format(_("trade-comms","Available Space: %i, Available Reputation: %i\n"),comms_source.cargo,math.floor(comms_source:getReputationPoints()))
			setCommsMessage(goodsReport)
			for good, goodData in pairs(ctd.goods) do
				addCommsReply(string.format(_("trade-comms","Buy one %s for %i reputation"),good,goodData["cost"]), function()
					local goodTransactionMessage = string.format(_("trade-comms","Type: %s, Quantity: %i, Reputation: %i"),good,goodData["quantity"],goodData["cost"])
					if comms_source.cargo < 1 then
						goodTransactionMessage = goodTransactionMessage .. _("trade-comms","\nInsufficient cargo space for purchase")
					elseif goodData["cost"] > math.floor(comms_source:getReputationPoints()) then
						goodTransactionMessage = goodTransactionMessage .. _("needRep-comms","\nInsufficient reputation for purchase")
					elseif goodData["quantity"] < 1 then
						goodTransactionMessage = goodTransactionMessage .. _("trade-comms","\nInsufficient station inventory")
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
							goodTransactionMessage = goodTransactionMessage .. _("trade-comms","\npurchased")
						else
							goodTransactionMessage = goodTransactionMessage .. _("needRep-comms","\nInsufficient reputation for purchase")
						end
					end
					setCommsMessage(goodTransactionMessage)
					addCommsReply(_("Back"), commsStation)
				end)
			end
			if ctd.buy ~= nil then
				for good, price in pairs(ctd.buy) do
					if comms_source.goods ~= nil and comms_source.goods[good] ~= nil and comms_source.goods[good] > 0 then
						addCommsReply(string.format(_("trade-comms","Sell one %s for %i reputation"),good,price), function()
							local goodTransactionMessage = string.format(_("trade-comms","Type: %s,  Reputation price: %i"),good,price)
							comms_source.goods[good] = comms_source.goods[good] - 1
							comms_source:addReputationPoints(price)
							goodTransactionMessage = goodTransactionMessage .. _("trade-comms","\nOne sold")
							comms_source.cargo = comms_source.cargo + 1
							setCommsMessage(goodTransactionMessage)
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
			end
			if ctd.trade.food and comms_source.goods ~= nil and comms_source.goods.food ~= nil and comms_source.goods.food > 0 then
				for good, goodData in pairs(ctd.goods) do
					addCommsReply(string.format(_("trade-comms","Trade food for %s"),good), function()
						local goodTransactionMessage = string.format(_("trade-comms","Type: %s,  Quantity: %i"),good,goodData["quantity"])
						if goodData["quantity"] < 1 then
							goodTransactionMessage = goodTransactionMessage .. _("trade-comms","\nInsufficient station inventory")
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
							goodTransactionMessage = goodTransactionMessage .. _("trade-comms","\nTraded")
						end
						setCommsMessage(goodTransactionMessage)
						addCommsReply(_("Back"), commsStation)
					end)
				end
			end
			if ctd.trade.medicine  and comms_source.goods ~= nil and comms_source.goods.medicine ~= nil and comms_source.goods.medicine > 0 then
				for good, goodData in pairs(ctd.goods) do
					addCommsReply(string.format(_("trade-comms","Trade medicine for %s"),good), function()
						local goodTransactionMessage = string.format(_("trade-comms","Type: %s,  Quantity: %i"),good,goodData["quantity"])
						if goodData["quantity"] < 1 then
							goodTransactionMessage = goodTransactionMessage .. _("trade-comms","\nInsufficient station inventory")
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
							goodTransactionMessage = goodTransactionMessage .. _("trade-comms","\nTraded")
						end
						setCommsMessage(goodTransactionMessage)
						addCommsReply(_("Back"), commsStation)
					end)
				end
			end
			if ctd.trade.luxury and comms_source.goods ~= nil and comms_source.goods.luxury ~= nil and comms_source.goods.luxury > 0 then
				for good, goodData in pairs(ctd.goods) do
					addCommsReply(string.format(_("trade-comms","Trade luxury for %s"),good), function()
						local goodTransactionMessage = string.format(_("trade-comms","Type: %s,  Quantity: %i"),good,goodData["quantity"])
						if goodData[quantity] < 1 then
							goodTransactionMessage = goodTransactionMessage .. _("trade-comms","\nInsufficient station inventory")
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
							goodTransactionMessage = goodTransactionMessage .. _("trade-comms","\nTraded")
						end
						setCommsMessage(goodTransactionMessage)
						addCommsReply(_("Back"), commsStation)
					end)
				end
			end
			addCommsReply(_("Back"), commsStation)
		end)
		addCommsReply(_("explainGoods-comms","No tutorial covered goods or cargo. Explain"), function()
			setCommsMessage(_("explainGoods-comms","Different types of cargo or goods may be obtained from stations, freighters or other sources. They go by one word descriptions such as dilithium, optic, warp, etc. Certain mission goals may require a particular type or types of cargo. Each player ship differs in cargo carrying capacity. Goods may be obtained by spending reputation points or by trading other types of cargo (typically food, medicine or luxury)"))
			addCommsReply(_("Back"), commsStation)
		end)
	end
end
function masterCartographer()
	if comms_source:takeReputationPoints(getCartographerCost("master")) then
		setCommsMessage(_("cartographyOffice-comms","Greetings,\nMay I help you find a station or goods?"))
		addCommsReply(_("cartographyOffice-comms","Find station"),function()
			setCommsMessage(_("cartographyOffice-comms","What station?"))
			local nearby_objects = getAllObjects()
			local stations_known = 0
			for i, obj in ipairs(nearby_objects) do
				if obj.typeName == "SpaceStation" then
					if not obj:isEnemy(comms_target) then
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
										station_details = string.format(_("cartographyOffice-comms","%s\n   %s, %i, %i"),station_details,good,good_data["quantity"],good_data["cost"])
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
				setCommsMessage(_("cartographyOffice-comms","Try the apprentice, I'm tired"))
			end
			addCommsReply(_("Back"), commsStation)
		end)
		addCommsReply(_("cartographyOffice-comms","Find Goods"), function()
			setCommsMessage(_("cartographyOffice-comms","What goods are you looking for?"))
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
			for good, obj in pairs(by_goods) do
				addCommsReply(good, function()
					local station_distance = distance(comms_target,obj)
					local station_details = string.format(_("cartographyOffice-comms","%s %s %s Distance:%.1fU"),obj:getSectorName(),obj:getFaction(),obj:getCallSign(),station_distance/1000)
					if obj.comms_data.orbit ~= nil then
						station_details = string.format(_("cartographyOffice-comms","%s %s"),station_details,obj.comms_data.orbit)
					end
					if obj.comms_data.goods ~= nil then
						station_details = string.format(_("cartographyOffice-comms","%s\nGood, quantity, cost"),station_details)
						for good, good_data in pairs(obj.comms_data.goods) do
							station_details = string.format(_("cartographyOffice-comms","%s\n   %s, %i, %i"),station_details,good,good_data["quantity"],good_data["cost"])
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
		setCommsMessage(_("needRep-comms","Insufficient reputation"))
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
		addCommsReply(_("station-comms","Show me the current statistics, please"), function()
			setCommsMessage(_("station-comms","What would you like statistics on?"))
			if #humanStationDestroyedNameList ~= nil and #humanStationDestroyedNameList > 0 then
				addCommsReply(_("station-comms","Human Stations Destroyed"),function()
					local human_station_stats = ""
					local station_strength = 0
					for i=1,#humanStationDestroyedNameList do
						human_station_stats = human_station_stats .. string.format("\n%s, %i",humanStationDestroyedNameList[i],humanStationDestroyedValue[i])
						station_strength = station_strength + humanStationDestroyedValue[i]
					end
					human_station_stats = string.format(_("station-comms","Count: %i, Total strength: %i\n   Station Name, Strength"),#humanStationDestroyedNameList,station_strength) .. human_station_stats
					setCommsMessage(human_station_stats)
					addCommsReply(_("Back"), commsStation)
				end)
			end
			if #neutralStationDestroyedNameList ~= nil and #neutralStationDestroyedNameList > 0 then
				addCommsReply(_("station-comms","Neutral Stations Destroyed"),function()
					local neutral_station_stats = ""
					local station_strength = 0
					for i=1,#neutralStationDestroyedNameList do
						neutral_station_stats = neutral_station_stats .. string.format("\n%s, %i",neutralStationDestroyedNameList[i],neutralStationDestroyedValue[i])
						station_strength = station_strength + neutralStationDestroyedValue[i]
					end
					neutral_station_stats = string.format(_("station-comms","Count: %i, Total strength: %i\n   Station Name, Strength"),#neutralStationDestroyedNameList,station_strength) .. neutral_station_stats
					setCommsMessage(neutral_station_stats)
					addCommsReply(_("Back"), commsStation)
				end)
			end
			if #kraylorVesselDestroyedNameList ~= nil and #kraylorVesselDestroyedNameList > 0 then
				addCommsReply(_("station-comms","Kraylor Vessels Destroyed"),function()
					local vessel_stats = ""
					local vessel_strength = 0
					for i=1,#kraylorVesselDestroyedNameList do
						vessel_stats = vessel_stats .. string.format("\n%s, %s, %i",kraylorVesselDestroyedNameList[i],kraylorVesselDestroyedType[i],kraylorVesselDestroyedValue[i])
						vessel_strength = vessel_strength + kraylorVesselDestroyedValue[i]
					end
					vessel_stats = string.format(_("station-comms","Count: %i, Total strength: %i\n   Vessel Name, Type, Strength"),#kraylorVesselDestroyedNameList,vessel_strength) .. vessel_stats
					setCommsMessage(vessel_stats)
					addCommsReply(_("Back"), commsStation)
				end)
			end
			if #exuariVesselDestroyedNameList ~= nil and #exuariVesselDestroyedNameList > 0 then
				addCommsReply(_("station-comms","Exuari Vessels Destroyed"),function()
					local vessel_stats = ""
					local vessel_strength = 0
					for i=1,#exuariVesselDestroyedNameList do
						vessel_stats = vessel_stats .. string.format("\n%s, %s, %i",exuariVesselDestroyedNameList[i],exuariVesselDestroyedType[i],exuariVesselDestroyedValue[i])
						vessel_strength = vessel_strength + exuariVesselDestroyedValue[i]
					end
					vessel_stats = string.format(_("station-comms","Count: %i, Total strength: %i\n   Vessel Name, Type, Strength"),#exuariVesselDestroyedNameList,vessel_strength) .. vessel_stats
					setCommsMessage(vessel_stats)
					addCommsReply(_("Back"), commsStation)
				end)
			end
			if #arlenianVesselDestroyedNameList ~= nil and #arlenianVesselDestroyedNameList > 0 then
				addCommsReply(_("station-comms","Arlenian Vessels Destroyed"),function()
					local vessel_stats = ""
					local vessel_strength = 0
					for i=1,#arlenianVesselDestroyedNameList do
						vessel_stats = vessel_stats .. string.format("\n%s, %s, %i",arlenianVesselDestroyedNameList[i],arlenianVesselDestroyedType[i],arlenianVesselDestroyedValue[i])
						vessel_strength = vessel_strength + arlenianVesselDestroyedValue[i]
					end
					vessel_stats = string.format(_("station-comms","Count: %i, Total strength: %i\n   Vessel Name, Type, Strength"),#arlenianVesselDestroyedNameList,vessel_strength) .. vessel_stats
					setCommsMessage(vessel_stats)
					addCommsReply(_("Back"), commsStation)
				end)
			end
			addCommsReply(_("station-comms","Missions completed"),function()
				if mission_complete_count > 0 then
					setCommsMessage(string.format(_("station-comms","Missions completed so far: %i"),mission_complete_count))
				else
					setCommsMessage(_("station-comms","No missions completed yet"))
				end
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("Back"), commsStation)
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
		setCommsMessage(_("station-comms","You need to stay docked for that action."))
		return
	end
    if not isAllowedTo(comms_data.weapons[weapon]) then
        if weapon == "Nuke" then setCommsMessage(_("ammo-comms","We do not deal in weapons of mass destruction."))
        elseif weapon == "EMP" then setCommsMessage(_("ammo-comms","We do not deal in weapons of mass disruption."))
        else setCommsMessage(_("ammo-comms","We do not deal in those weapons.")) end
        return
    end
    local points_per_item = getWeaponCost(weapon)
    local item_amount = math.floor(comms_source:getWeaponStorageMax(weapon) * comms_data.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage(weapon)
    if item_amount <= 0 then
        if weapon == "Nuke" then
            setCommsMessage(_("ammo-comms","All nukes are charged and primed for destruction."))
        else
            setCommsMessage(_("ammo-comms","Sorry, sir, but you are as fully stocked as I can allow."))
        end
        addCommsReply(_("Back"), commsStation)
    else
		if comms_source:getReputationPoints() > points_per_item * item_amount then
			if comms_source:takeReputationPoints(points_per_item * item_amount) then
				comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + item_amount)
				if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
					setCommsMessage(_("ammo-comms","You are fully loaded and ready to explode things."))
				else
					setCommsMessage(_("ammo-comms","We generously resupplied you with some weapon charges.\nPut them to good use."))
				end
			else
				setCommsMessage(_("needRep-comms","Not enough reputation."))
				return
			end
		else
			if comms_source:getReputationPoints() > points_per_item then
				setCommsMessage(_("ammo-comms","You can't afford as much as I'd like to give you"))
				addCommsReply(_("ammo-comms","Get just one"), function()
					if comms_source:takeReputationPoints(points_per_item) then
						comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + 1)
						if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
							setCommsMessage(_("ammo-comms","You are fully loaded and ready to explode things."))
						else
							setCommsMessage(_("ammo-comms","We generously resupplied you with one weapon charge.\nPut it to good use."))
						end
					else
						setCommsMessage(_("needRep-comms","Not enough reputation."))
					end
					addCommsReply(_("Back"), commsStation)
				end)
			else
				setCommsMessage(_("needRep-comms","Not enough reputation."))
				addCommsReply(_("Back"), commsStation)				
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
        oMsg = _("station-comms","Good day, officer.\nIf you need supplies, please dock with us first.")
    else
        oMsg = _("station-comms","Greetings.\nIf you want to do business, please dock with us first.")
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. _("station-comms","\nBe aware that if enemies in the area get much closer, we will be too busy to conduct business with you.")
	end
	setCommsMessage(oMsg)
	if comms_target == belt1Stations[5] and plot1 == checkOrbitingArtifactEvents and not astronomerBoardedShip then
		addCommsReply(_("station-comms","Contact astronomer Polly Hobbs"), function()
			setCommsMessage(_("station-comms","[Polly Hobbs] I've constructed a sensitive scanning device to gather additional data. However, the device needs to be much closer. Can you transport me closer to the location of the readings?"))
			playVoice("Polly02")
			addCommsReply(_("Back"), commsStation)
		end)
	end
 	addCommsReply(_("station-comms","I need information"), function()
		setCommsMessage(_("station-comms","What kind of information do you need?"))
		if stationCommsDiagnostic then print("requesting information") end
		local ctd = comms_target.comms_data
		if stationCommsDiagnostic then print(ctd.character) end
		if ctd.character ~= nil then
			addCommsReply(string.format(_("characterInfo-comms","Tell me about %s"),ctd.character), function()
				if ctd.characterDescription ~= nil then
					setCommsMessage(ctd.characterDescription)
				else
					if ctd.characterDeadEnd == nil then
						local dead_end_responses = {
							string.format(_("characterInfo-comms","Never heard of %s"),ctd.character),
							string.format(_("characterInfo-comms","%s died last week. The funeral was yesterday"),ctd.character),
							string.format(_("characterInfo-comms","%s? Who's %s? There's nobody here named %s"),ctd.character,ctd.character,ctd.character),
							string.format(_("characterInfo-comms","We don't talk about %s. They are gone and good riddance"),ctd.character),
							string.format(_("characterInfo-comms","I think %s moved away"),ctd.character),
							string.format(_("characterInfo-comms","My aunt's neighbor's second cousin is named %s. However, %s lives far away from here."),ctd.character,ctd.character),
						}
						ctd.characterDeadEnd = dead_end_responses[math.random(1,#dead_end_responses)]
					end
					setCommsMessage(ctd.characterDeadEnd)
				end
				addCommsReply(_("Back"), commsStation)
			end)
		end
	    if comms_source:isFriendly(comms_target) then
			addCommsReply(_("orders-comms","What are my current orders?"), function()
				setOptionalOrders()
				setSecondaryOrders()
				ordMsg = primaryOrders .. "\n" .. secondaryOrders .. optionalOrders
				if playWithTimeLimit then
					ordMsg = ordMsg .. string.format(_("orders-comms","\n   %i Minutes remain in game"),math.floor(gameTimeLimit/60))
				end
				setCommsMessage(ordMsg)
				addCommsReply(_("Back"), commsStation)
			end)
			showCurrentStats()
		end
		addCommsReply(_("ammo-comms","What ordnance do you have available for restock?"), function()
			local ctd = comms_target.comms_data
			local missileTypeAvailableCount = 0
			local ordnanceListMsg = ""
			if ctd.weapon_available.Nuke then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. _("ammo-comms","\n   Nuke")
			end
			if ctd.weapon_available.EMP then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. _("ammo-comms","\n   EMP")
			end
			if ctd.weapon_available.Homing then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. _("ammo-comms","\n   Homing")
			end
			if ctd.weapon_available.Mine then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. _("ammo-comms","\n   Mine")
			end
			if ctd.weapon_available.HVLI then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. _("ammo-comms","\n   HVLI")
			end
			if missileTypeAvailableCount == 0 then
				ordnanceListMsg = _("ammo-comms","We have no ordnance available for restock")
			elseif missileTypeAvailableCount == 1 then
				ordnanceListMsg = string.format(_("ammo-comms", "We have the following type of ordnance available for restock:%s"), ordnanceListMsg)
			else
				ordnanceListMsg = string.format(_("ammo-comms", "We have the following types of ordnance available for restock:%s"), ordnanceListMsg)
			end
			setCommsMessage(ordnanceListMsg)
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
			addCommsReply(_("trade-comms","What goods do you have available for sale or trade?"), function()
				local ctd = comms_target.comms_data
				local goodsAvailableMsg = string.format(_("trade-comms","Station %s:\nGoods or components available: quantity, cost in reputation"),comms_target:getCallSign())
				for good, goodData in pairs(ctd.goods) do
					goodsAvailableMsg = goodsAvailableMsg .. string.format(_("trade-comms","\n   %14s: %2i, %3i"),good,goodData["quantity"],goodData["cost"])
				end
				setCommsMessage(goodsAvailableMsg)
				addCommsReply(_("Back"), commsStation)
			end)
		end
		addCommsReply(_("trade-comms","Where can I find particular goods?"), function()
			local ctd = comms_target.comms_data
			gkMsg = _("trade-comms","Friendly stations often have food or medicine or both. Neutral stations may trade their goods for food, medicine or luxury.")
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
					setCommsMessage(string.format(_("trade-comms","Station %s in sector %s has %s for %i reputation"),stationName,sectorName,goodName,goodCost))
					addCommsReply("Back", commsStation)
				end)
			end
			if goodsKnowledgeCount > 0 then
				gkMsg = gkMsg .. _("trade-comms","\n\nWhat goods are you interested in?\nI've heard about these:")
			else
				gkMsg = gkMsg .. _("trade-comms"," Beyond that, I have no knowledge of specific stations")
			end
			setCommsMessage(gkMsg)
			addCommsReply(_("Back"), commsStation)
		end)
		if ctd.public_relations then
			addCommsReply(_("station-comms","Tell me more about your station"), function()
				local ctd = comms_target.comms_data
				setCommsMessage(_("station-comms","What would you like to know?"))
				addCommsReply(_("stationGeneralInfo-comms","General information"), function()
					setCommsMessage(ctd.general_information)
					addCommsReply(_("Back"), commsStation)
				end)
				if ctd.history ~= nil then
					addCommsReply(_("stationStory-comms","Station history"), function()
						setCommsMessage(ctd.history)
						addCommsReply(_("Back"), commsStation)
					end)
				end
				if ctd.gossip ~= nil then
					if random(1,100) < 80 then
						addCommsReply(_("gossip-comms","Gossip"), function()
							setCommsMessage(ctd.gossip)
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
				addCommsReply(_("Back"), commsStation)
			end)	--end station info comms reply branch
		end	--end public relations if branch
		addCommsReply(_("stationAssist-comms","Report status"), function()
			msg = string.format(_("stationAssist-comms", "Hull: %d%%\n"), math.floor(comms_target:getHull() / comms_target:getHullMax() * 100))
			local shields = comms_target:getShieldCount()
			if shields == 1 then
				msg = msg .. string.format(_("stationpAssist-comms", "Shield: %d%%\n"), math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100))
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
        addCommsReply(string.format(_("stationAssist-comms","Can you send a supply drop? (%s reputation)"),getServiceCost("supplydrop")), function()
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage(_("stationAssist-comms","You need to set a waypoint before you can request backup."))
            else
                setCommsMessage(_("stationAssist-comms","To which waypoint should we deliver your supplies?"))
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply(string.format(_("stationAssist-comms","Waypoint %s"),n), function()
						if comms_source:takeReputationPoints(getServiceCost("supplydrop")) then
							local position_x, position_y = comms_target:getPosition()
							local target_x, target_y = comms_source:getWaypoint(n)
							local script = Script()
							script:setVariable("position_x", position_x):setVariable("position_y", position_y)
							script:setVariable("target_x", target_x):setVariable("target_y", target_y)
							script:setVariable("faction_id", comms_target:getFactionId()):run("supply_drop.lua")
							setCommsMessage(string.format(_("stationAssist-comms","We have dispatched a supply ship toward waypoint %s"),n))
						else
							setCommsMessage(_("needRep-comms","Insufficient reputation"))
						end
                        addCommsReply(_("Back"), commsStation)
                    end)
                end
            end
            addCommsReply(_("Back"), commsStation)
        end)
    end
    if isAllowedTo(comms_target.comms_data.services.reinforcements) then
        addCommsReply(string.format(_("stationAssist-comms","Please send Adder MK5 reinforcements! (%s reputation)"),getServiceCost("reinforcements")), function()
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage(_("stationAssist-comms","You need to set a waypoint before you can request reinforcements."))
            else
                setCommsMessage(_("stationAssist-comms","To which waypoint should we dispatch the reinforcements?"))
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply(string.format(_("stationAssist-comms","Waypoint %s"),n), function()
						if comms_source:takeReputationPoints(getServiceCost("reinforcements")) then
							ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
							ship:setCommsScript(""):setCommsFunction(commsShip):onDestruction(humanVesselDestroyed)
							table.insert(friendlyHelperFleet,ship)
							setCommsMessage(string.format(_("stationAssist-comms","We have dispatched %s to assist at waypoint %s"),ship:getCallSign(),n))
						else
							setCommsMessage(_("needRep-comms","Insufficient reputation"))
						end
                        addCommsReply(_("Back"), commsStation)
                    end)
                end
            end
            addCommsReply(_("Back"), commsStation)
        end)
        addCommsReply(string.format(_("stationAssist-comms","Please send Phobos T3 reinforcements! (%s reputation)"),getServiceCost("phobosReinforcements")), function()
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage(_("stationAssist-comms","You need to set a waypoint before you can request reinforcements."))
            else
                setCommsMessage(_("stationAssist-comms","To which waypoint should we dispatch the reinforcements?"))
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply(string.format(_("stationAssist-comms","Waypoint %s"),n), function()
						if comms_source:takeReputationPoints(getServiceCost("phobosReinforcements")) then
							ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Phobos T3"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
							ship:setCommsScript(""):setCommsFunction(commsShip):onDestruction(humanVesselDestroyed)
							table.insert(friendlyHelperFleet,ship)
							setCommsMessage(string.format(_("stationAssist-comms","We have dispatched %s to assist at waypoint %s"),ship:getCallSign(),n))
						else
							setCommsMessage(_("needRep-comms","Insufficient reputation"))
						end
                        addCommsReply(_("Back"), commsStation)
                    end)
                end
            end
            addCommsReply(_("Back"), commsStation)
        end)
        addCommsReply(string.format(_("stationAssist-comms","Please send Stalker Q7 reinforcements! (%s reputation)"),getServiceCost("stalkerReinforcements")), function()
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage(_("stationAssist-comms","You need to set a waypoint before you can request reinforcements."))
            else
                setCommsMessage(_("stationAssist-comms","To which waypoint should we dispatch the reinforcements?"))
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply(string.format(_("stationAssist-comms","Waypoint %s"),n), function()
						if comms_source:takeReputationPoints(getServiceCost("stalkerReinforcements")) then
							ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Stalker Q7"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
							ship:setCommsScript(""):setCommsFunction(commsShip):onDestruction(humanVesselDestroyed)
							table.insert(friendlyHelperFleet,ship)
							setCommsMessage(string.format(_("stationAssist-comms","We have dispatched %s to assist at waypoint %s"),ship:getCallSign(),n))
						else
							setCommsMessage(_("needRep-comms","Insufficient reputation"))
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
						tradeString = _("trade-comms"," and will trade it for medicine")
						stationTrades = true
					end
					if tradeFood[humanStationList[sti]] ~= nil then
						if stationTrades then
							tradeString = tradeString .. _("trade-comms"," or food")
						else
							tradeString = tradeString .. _("trade-comms"," and will trade it for food")
							stationTrades = true
						end
					end
					if tradeLuxury[humanStationList[sti]] ~= nil then
						if stationTrades then
							tradeString = tradeString .. _("trade-comms"," or luxury")
						else
							tradeString = tradeString .. _("trade-comms"," and will trade it for luxury")
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
		local belt_station = false
		local outer_belt_station = false
		local tertius_belt_station = false
		for i,belt_station in ipairs(belt1Stations) do
			if station == belt_station then
				belt_station = true
				break
			end
		end
		if not belt_station then
			for i,belt_station in ipairs(belt2Stations) do
				if station == belt_station then
					outer_belt_station = true
					break
				end
			end
			if not outer_belt_station then
				for i,belt_station in ipairs(tertiusAsteroidStations) do
					if station == belt_station then
						tertius_belt_station = true
					end
				end
			end
		end
		if belt_station then
			local faction_key = _("scienceDB","Faction")
			station_db:setKeyValue(faction_key,station:getFaction())
			local primary_orbit_key = _("scienceDB","Orbit around")
			station_db:setKeyValue(primary_orbit_key,string.format(_("scienceDB","Star %s in inner asteroid belt"),planetSol:getCallSign()))
		elseif outer_belt_station then
			local faction_key = _("scienceDB","Faction")
			station_db:setKeyValue(faction_key,station:getFaction())
			local primary_orbit_key = _("scienceDB","Orbit around")
			station_db:setKeyValue(primary_orbit_key,string.format(_("scienceDB","Star %s in outer asteroid belt"),planetSol:getCallSign()))
		elseif station == tertiusStation or tertius_belt_station then
			local faction_key = _("scienceDB","Faction")
			station_db:setKeyValue(faction_key,station:getFaction())
			local primary_orbit_key = _("scienceDB","Primary orbit")
			station_db:setKeyValue(primary_orbit_key,string.format(_("scienceDB","Around planet %s"),planetTertius:getCallSign()))
			local secondary_orbit_key = _("scienceDB","Secondary orbit")
			station_db:setKeyValue(secondary_orbit_key,string.format(_("scienceDB","Planet %s orbits star %s"),planetTertius:getCallSign(),planetSol:getCallSign()))
		elseif station == primusStation then
			local faction_key = _("scienceDB","Faction")
			station_db:setKeyValue(faction_key,station:getFaction())
			local primary_orbit_key = _("scienceDB","Primary orbit")
			station_db:setKeyValue(primary_orbit_key,string.format(_("scienceDB","Around planet %s"),planetPrimus:getCallSign()))
			local secondary_orbit_key = _("scienceDB","Secondary orbit")
			station_db:setKeyValue(secondary_orbit_key,string.format(_("scienceDB","Planet %s orbits star %s"),planetPrimus:getCallSign(),planetSol:getCallSign()))
		elseif station == secondusStations[1] or station == secondusStations[2] or station == secondusStations[3] then
			local faction_key = _("scienceDB","Faction")
			station_db:setKeyValue(faction_key,station:getFaction())
			local primary_orbit_key = _("scienceDB","Primary orbit")
			station_db:setKeyValue(primary_orbit_key,string.format(_("scienceDB","Around planet %s"),planetSecondus:getCallSign()))
			local secondary_orbit_key = _("scienceDB","Secondary orbit")
			station_db:setKeyValue(secondary_orbit_key,string.format(_("scienceDB","Planet %s orbits star %s"),planetSecondus:getCallSign(),planetSol:getCallSign()))
		else
			local location_key = _("scienceDB","Location, Faction")
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
		setCommsMessage(_("shipAssist-comms","What do you want?"))
	else
		setCommsMessage(_("shipAssist-comms","Sir, how can we assist?"))
	end
	addCommsReply(_("shipAssist-comms","Defend a waypoint"), function()
		if comms_source:getWaypointCount() == 0 then
			setCommsMessage(_("shipAssist-comms","No waypoints set. Please set a waypoint first."))
			addCommsReply(_("Back"), commsShip)
		else
			setCommsMessage(_("shipAssist-comms","Which waypoint should we defend?"))
			for n=1,comms_source:getWaypointCount() do
				addCommsReply(string.format(_("shipAssist-comms","Defend waypoint %s"),n), function()
					comms_target:orderDefendLocation(comms_source:getWaypoint(n))
					setCommsMessage(string.format(_("shipAssist-comms","We are heading to assist at waypoint %s."),n))
					addCommsReply(_("Back"), commsShip)
				end)
			end
		end
	end)
	if comms_data.friendlyness > 0.2 then
		addCommsReply(_("shipAssist-comms","Assist me"), function()
			setCommsMessage(_("shipAssist-comms","Heading toward you to assist."))
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
			addCommsReply(string.format(_("shipAssist-comms","Dock at %s"),obj:getCallSign()), function()
				setCommsMessage(string.format(_("shipAssist-comms","Docking at %s."),obj:getCallSign()))
				comms_target:orderDock(obj)
				addCommsReply(_("Back"), commsShip)
			end)
		end
	end
	if comms_target.fleet ~= nil then
		addCommsReply(string.format(_("shipAssist-comms","Direct %s"),comms_target.fleet), function()
			setCommsMessage(string.format(_("shipAssist-comms","What command should be given to %s?"),comms_target.fleet))
			addCommsReply(_("shipAssist-comms","Report hull and shield status"), function()
				msg = _("shipAssist-comms","Fleet status:")
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
			addCommsReply(_("shipAssist-comms","Report missile status"), function()
				msg = _("shipAssist-comms","Fleet missile status:")
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
			addCommsReply(_("shipAssist-comms","Assist me"), function()
				for i, fleetShip in ipairs(friendlyDefensiveFleetList[comms_target.fleet]) do
					if fleetShip ~= nil and fleetShip:isValid() then
						fleetShip:orderDefendTarget(comms_source)
					end
				end
				setCommsMessage(string.format(_("shipAssist-comms","%s heading toward you to assist"),comms_target.fleet))
				addCommsReply(_("Back"), commsShip)
			end)
			addCommsReply(_("shipAssist-comms","Defend a waypoint"), function()
				if comms_source:getWaypointCount() == 0 then
					setCommsMessage(_("shipAssist-comms","No waypoints set. Please set a waypoint first."))
					addCommsReply(_("Back"), commsShip)
				else
					setCommsMessage(_("shipAssist-comms","Which waypoint should we defend?"))
					for n=1,comms_source:getWaypointCount() do
						addCommsReply(string.format(_("shipAssist-comms","Defend waypoint %s"),n), function()
							for i, fleetShip in ipairs(friendlyDefensiveFleetList[comms_target.fleet]) do
								if fleetShip ~= nil and fleetShip:isValid() then
									fleetShip:orderDefendLocation(comms_source:getWaypoint(n))
								end
							end
							setCommsMessage(string.format(_("shipAssist-comms","We are heading to assist at waypoint %s."),n))
							addCommsReply(_("Back"), commsShip)
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
								addCommsReply(string.format(_("trade-comms","Trade luxury for %s"),good), function()
									goodData.quantity = goodData.quantity - 1
									if comms_source.goods == nil then
										comms_source.goods = {}
									end
									if comms_source.goods[good] == nil then
										comms_source.goods[good] = 0
									end
									comms_source.goods[good] = comms_source.goods[good] + 1
									comms_source.goods.luxury = comms_source.goods.luxury - 1
									setCommsMessage(string.format(_("trade-comms","Traded your luxury for %s from %s"),good,comms_target:getCallSign()))
									addCommsReply(_("Back"), commsShip)
								end)
							end
						end	--freighter goods loop
					end	--player has luxury branch
				end	--goods or equipment freighter
				if comms_source.cargo > 0 then
					for good, goodData in pairs(comms_data.goods) do
						if goodData.quantity > 0 then
							addCommsReply(string.format(_("trade-comms","Buy one %s for %i reputation"),good,math.floor(goodData.cost)), function()
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
									setCommsMessage(string.format(_("trade-comms","Purchased %s from %s"),good,comms_target:getCallSign()))
								else
									setCommsMessage(_("needRep-comms","Insufficient reputation for purchase"))
								end
								addCommsReply(_("Back"), commsShip)
							end)
						end
					end	--freighter goods loop
				end	--player has cargo space branch
			elseif comms_data.friendlyness > 33 then
				if comms_source.cargo > 0 then
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format(_("trade-comms","Buy one %s for %i reputation"),good,math.floor(goodData.cost)), function()
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
										setCommsMessage(string.format(_("trade-comms","Purchased %s from %s"),good,comms_target:getCallSign()))
									else
										setCommsMessage(_("needRep-comms","Insufficient reputation for purchase"))
									end
									addCommsReply(_("Back"), commsShip)
								end)
							end	--freighter has something to sell branch
						end	--freighter goods loop
					else	--not goods or equipment freighter
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format(_("trade-comms","Buy one %s for %i reputation"),good,math.floor(goodData.cost*2)), function()
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
										setCommsMessage(string.format(_("trade-comms","Purchased %s from %s"),good,comms_target:getCallSign()))
									else
										setCommsMessage(_("needRep-comms","Insufficient reputation for purchase"))
									end
									addCommsReply(_("Back"), commsShip)
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
								addCommsReply(string.format(_("trade-comms","Buy one %s for %i reputation"),good,math.floor(goodData.cost*2)), function()
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
										setCommsMessage(string.format(_("trade-comms","Purchased %s from %s"),good,comms_target:getCallSign()))
									else
										setCommsMessage(_("needRep-comms","Insufficient reputation for purchase"))
									end
									addCommsReply(_("Back"), commsShip)
								end)
							end	--freighter has something to sell branch
						end	--freighter goods loop
					end	--goods or equipment freighter
				end	--player has room to get goods
			end	--various friendliness choices
		else	--not close enough to sell
			addCommsReply(_("trade-comms","Do you have cargo you might sell?"), function()
				local goodCount = 0
				local cargoMsg = _("trade-comms","We've got ")
				for good, goodData in pairs(comms_data.goods) do
					if goodData.quantity > 0 then
						if goodCount > 0 then
							cargoMsg = cargoMsg .. _("trade-comms",", ") .. good
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
	return true
end
function enemyComms(comms_data)
	if comms_data.friendlyness > 50 then
		local faction = comms_target:getFaction()
		local messages = {
			["Kraylor"] = 	_("shipEnemy-comms","Ktzzzsss.\nYou will DIEEee weaklingsss!"),
			["Arlenians"] = _("shipEnemy-comms","We wish you no harm, but will harm you if we must.\nEnd of transmission."),
			["Exuari"] =	_("shipEnemy-comms","Stay out of our way, or your death will amuse us extremely!"),
			["Ghosts"] =	_("shipEnemy-comms","One zero one.\nNo binary communication detected.\nSwitching to universal speech.\nGenerating appropriate response for target from human language archives.\n:Do not cross us:\nCommunication halted."),
			["Ktlitans"] =	_("shipEnemy-comms","The hive suffers no threats. Opposition to any of us is opposition to us all.\nStand down or prepare to donate your corpses toward our nutrition."),
			["TSN"] =		_("shipEnemy-comms","State your business"),
			["USN"] =		_("shipEnemy-comms","What do you want? (not that we care)"),
			["CUF"] =		_("shipEnemy-comms","Don't waste our time"),
			["Default"] =	_("shipEnemy-comms","Mind your own business!"),
		}
		if messages[faction] ~= nil then
			setCommsMessage(messages[faction])
		else
			setCommsMessage(messages["Default"])
		end
		local taunts = {
			["Kraylor"] = {
				{option = _("shipEnemy-comms","We will destroy you"),									success = _("shipEnemy-comms","We think not. It is you who will experience destruction!"),				fail = _("shipEnemy-comms","Your feeble threats are meaningless.")},
				{option = _("shipEnemy-comms","You have no honor"),										success = _("shipEnemy-comms","Your insult has brought our wrath upon you. Prepare to die."),			fail = _("shipEnemy-comms","Your comments about honor have no meaning to us")},
				{option = _("shipEnemy-comms","We pity your pathetic race"),							success = _("shipEnemy-comms","Pathetic? You will regret your disparagement!"),							fail = _("shipEnemy-comms","We don't care what you think of us")},
			},
			["Ghosts"] = {
				{option = _("shipEnemy-comms","EXECUTE: SELFDESTRUCT"),									success = _("shipEnemy-comms","Rogue command received. Targeting source."),								fail = _("shipEnemy-comms","External command ignored.")},
				{option = _("shipEnemy-comms","EXECUTE: AUTOSHUTDOWN"),									success = _("shipEnemy-comms","Target source of rogue command."),										fail = _("shipEnemy-comms","External command failed security check.")},
			},
			["Ktlitans"] = {
				{option = _("shipEnemy-comms","<Transmit 'The Itsy-Bitsy Spider' on all wavelengths>"),	success = _("shipEnemy-comms","We do not need permission to pluck apart such an insignificant threat."),fail = _("shipEnemy-comms","The hive has greater priorities than exterminating pests.")},
				{option = _("shipEnemy-comms","Your queen tastes like elderberries"),					success = _("shipEnemy-comms","You will be destroyed for the honor of the hive."),						fail = _("shipEnemy-comms","Maggots are beneath our notice.")},
			},
			["Default"] = {
				{option = _("shipEnemy-comms","We will see to your destruction!"),						success = _("shipEnemy-comms","Your bloodline will end here!"),											fail = _("shipEnemy-comms","Your feeble threats are meaningless.")},
			},
		}
		comms_data.friendlyness = comms_data.friendlyness - random(0, 10)
		local taunt = taunts["Default"][1]
		if taunts[faction] ~= nil then
			taunt = taunts[faction][math.random(1,#taunts[faction])]
		end
		addCommsReply(taunt.option,function()
			string.format("")
			if random(1,100) < 30 then
				comms_target:orderAttack(comms_source)
				setCommsMessage(taunt.success)
			else
				setCommsMessage(taunt.fail)
			end
		end)
		return true
	end
	return false
end
function neutralComms(comms_data)
	local shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
		setCommsMessage(_("trade-comms","Yes?"))
		addCommsReply(_("trade-comms","Do you have cargo you might sell?"), function()
			local goodCount = 0
			local cargoMsg = _("trade-comms","We've got ")
			for good, goodData in pairs(comms_data.goods) do
				if goodData.quantity > 0 then
					if goodCount > 0 then
						cargoMsg = cargoMsg .. _("trade-comms",", ") .. good
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
			if comms_source.cargo > 0 then
				if comms_data.friendlyness > 66 then
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format(_("trade-comms","Buy one %s for %i reputation"),good,math.floor(goodData.cost)), function()
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
										setCommsMessage(string.format(_("trade-comms","Purchased %s from %s"),good,comms_target:getCallSign()))
									else
										setCommsMessage(_("needRep-comms","Insufficient reputation"))
									end
									addCommsReply(_("Back"), commsShip)
								end)
							end
						end	--freighter goods loop
					else
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format(_("trade-comms","Buy one %s for %i reputation"),good,math.floor(goodData.cost*2)), function()
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
										setCommsMessage(string.format(_("trade-comms","Purchased %s from %s"),good,comms_target:getCallSign()))
									else
										setCommsMessage(_("needRep-comms","Insufficient reputation"))
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
								addCommsReply(string.format(_("trade-comms","Buy one %s for %i reputation"),good,math.floor(goodData.cost*2)), function()
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
										setCommsMessage(string.format(_("trade-comms","Purchased %s from %s"),good,comms_target:getCallSign()))
									else
										setCommsMessage(_("needRep-comms","Insufficient reputation"))
									end
									addCommsReply(_("Back"), commsShip)
								end)
							end
						end	--freighter goods loop
					else
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format(_("trade-comms","Buy one %s for %i reputation"),good,math.floor(goodData.cost*3)), function()
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
										setCommsMessage(string.format(_("trade-comms","Purchased %s from %s"),good,comms_target:getCallSign()))
									else
										setCommsMessage(_("needRep-comms","Insufficient reputation"))
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
								addCommsReply(string.format(_("trade-comms","Buy one %s for %i reputation"),good,math.floor(goodData.cost*3)), function()
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
										setCommsMessage(string.format(_("trade-comms","Purchased %s from %s"),good,comms_target:getCallSign()))
									else
										setCommsMessage(_("needRep-comms","Insufficient reputation"))
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
			setCommsMessage(_("ship-comms","Sorry, we have no time to chat with you.\nWe are on an important mission."))
		else
			setCommsMessage(_("ship-comms","We have nothing for you.\nGood day."))
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
		if voice_play_time == nil then
			playSoundFile(string.format("scenario48audio/sa_48_%s.ogg",voice_queue[1]))
			if voice_clips[voice_queue[1]] == nil then
				print("In the voice clips list,",voice_queue[1],"comes up as nil. Setting play gap to 20")
				voice_play_time = getScenarioTime() + 20
			else
				voice_play_time = getScenarioTime() + voice_clips[voice_queue[1]] + 1
			end
			table.remove(voice_queue,1)
		elseif getScenarioTime() > voice_play_time then
			voice_play_time = nil
		end
	end
end
-- create amount of object_type, at a distance between dist_min and dist_max around the point (x0, y0)
function placeRandomAsteroidAroundPoint(object_type, amount, dist_min, dist_max, x0, y0)
    for n=1,amount do
        local r = random(0, 360)
        local distance = random(dist_min, dist_max)
        local x = x0 + math.cos(r / 180 * math.pi) * distance
        local y = y0 + math.sin(r / 180 * math.pi) * distance
        local obj = object_type():setPosition(x, y)
        if obj.typeName == "Asteroid" or obj.typeName == "VisualAsteroid" then
			obj:setSize(random(3,100) + random(3,100) + random(3,100) + random(3,500))
        end
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
	local obj = nil
	if amount > arcLen then
		for ndex=1,arcLen do
			local radialPoint = startArc+ndex
			local pointDist = distance + random(-randomize,randomize)
			obj = object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist)		
			if obj.typeName == "Asteroid" or obj.typeName == "VisualAsteroid" then
				obj:setSize(random(3,100) + random(3,100) + random(3,100) + random(3,500))
			end	
		end
		for ndex=1,amount-arcLen do
			radialPoint = random(startArc,clockwiseEndArc)
			pointDist = distance + random(-randomize,randomize)
			obj = object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist)			
			if obj.typeName == "Asteroid" or obj.typeName == "VisualAsteroid" then
				obj:setSize(random(3,100) + random(3,100) + random(3,100) + random(3,500))
			end	
		end
	else
		for ndex=1,amount do
			radialPoint = random(startArc,clockwiseEndArc)
			pointDist = distance + random(-randomize,randomize)
			obj = object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist)
			if obj.typeName == "Asteroid" or obj.typeName == "VisualAsteroid" then
				obj:setSize(random(3,100) + random(3,100) + random(3,100) + random(3,500))
			end	
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
	local enemyStrength = math.max(danger * enemy_power * playerPower(),5)
	local enemyPosition = 0
	local sp = irandom(400,900)			--random spacing of spawned group
	local deployConfig = random(1,100)	--randomly choose between squarish formation and hexagonish formation
	local enemyList = {}
	while enemyStrength > 0 do
		local template_pool = {}
		for template,info in pairs(ship_template) do
			if info.strength <= (enemyStrength * 1.1 + 5) then
				table.insert(template_pool,template)
			end
		end
		local selected_template = template_pool[math.random(1,#template_pool)]
		local ship = ship_template[selected_template].create(enemyFaction,selected_template)
		ship:orderRoaming()
		if enemyFaction == "Kraylor" then
			rawKraylorShipStrength = rawKraylorShipStrength + ship_template[selected_template].strength
			ship:onDestruction(kraylorVesselDestroyed)
		elseif enemyFaction == "Human Navy" then
			rawHumanShipStrength = rawHumanShipStrength + ship_template[selected_template].strength
			ship:onDestruction(humanVesselDestroyed)
		elseif enemyFaction == "Exuari" then
			rawExuariShipStrength = rawExuariShipStrength + ship_template[selected_template].strength
			ship:onDestruction(exuariVesselDestroyed)
		elseif enemyFaction == "Arlenians" then
			rawArlenianShipStrength = rawArlenianShipStrength + ship_template[selected_template].strength
			ship:onDestruction(arlenianVesselDestroyed)
		end
		enemyPosition = enemyPosition + 1
		if deployConfig < 50 then
			ship:setPosition(xOrigin + formation_delta["square"].x[enemyPosition] * sp, yOrigin + formation_delta["square"].y[enemyPosition] * sp)
		else
			ship:setPosition(xOrigin + formation_delta["hexagonal"].x[enemyPosition] * sp, yOrigin + formation_delta["hexagonal"].y[enemyPosition] * sp)
		end
		ship:setCommsScript(""):setCommsFunction(commsShip)
		ship:setCallSign(generateCallSign(nil,enemyFaction))
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
							p:addCustomMessage("Engineering",repairCrewRecovery,_("repairCrew-msgEngineer","Medical team has revived one of your repair crew"))
						end
						if p:hasPlayerAtPosition("Engineering+") then
							local repairCrewRecoveryPlus = "repairCrewRecoveryPlus"
							p:addCustomMessage("Engineering+",repairCrewRecoveryPlus,_("repairCrew-msgEngineer+","Medical team has revived one of your repair crew"))
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
				p:addCustomMessage("Engineering",repairCrewFatality,_("repairCrew-msgEngineer","One of your repair crew has perished"))
			end
			if p:hasPlayerAtPosition("Engineering+") then
				local repairCrewFatalityPlus = "repairCrewFatalityPlus"
				p:addCustomMessage("Engineering+",repairCrewFatalityPlus,_("repairCrew-msgEngineer+","One of your repair crew has perished"))
			end
		else
			if random(1,100) < 50 then
				p:setRepairCrewCount(p:getRepairCrewCount() - 1)
				if p:hasPlayerAtPosition("Engineering") then
					local repairCrewFatality = "repairCrewFatality"
					p:addCustomMessage("Engineering",repairCrewFatality,_("repairCrew-msgEngineer","One of your repair crew has perished"))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					local repairCrewFatalityPlus = "repairCrewFatalityPlus"
					p:addCustomMessage("Engineering+",repairCrewFatalityPlus,_("repairCrew-msgEngineer+","One of your repair crew has perished"))
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
					p:addCustomMessage("Engineering",coolantLoss,_("coolant-msgEngineer","Damage has caused a loss of coolant"))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					local coolantLossPlus = "coolantLossPlus"
					p:addCustomMessage("Engineering+",coolantLossPlus,_("coolant-msgEngineer+","Damage has caused a loss of coolant"))
				end
			end
		end
	end
end
-- Gain or lose coolant from nebula functions
function coolantNebulae(delta)
	for i,p in ipairs(getActivePlayerShips()) do
		local inside_gain_coolant_nebula = false
		for i,neb in ipairs(coolant_nebula) do
			if distance(p,neb) < 5000 then
				if neb.lose then
					p:setMaxCoolant(p:getMaxCoolant()*coolant_loss)
				end
				if neb.gain then
					inside_gain_coolant_nebula = true
				end
			end
		end
		if inside_gain_coolant_nebula then
			if p.coolant_trigger then
				updateCoolantGivenPlayer(p, delta)
			else
				p.get_coolant_button_eng = "get_coolant_button_eng"
				p:addCustomButton("Engineering",p.get_coolant_button_eng,_("coolant-buttonEngineer","Get Coolant"),function()
					string.format("")
					getCoolantGivenPlayer(p)
				end,7)
				p.get_coolant_button_epl = "get_coolant_button_epl"
				p:addCustomButton("Engineering+",p.get_coolant_button_epl,_("coolant-buttonEngineer+","Get Coolant"),function()
					string.format("")
					getCoolantGivenPlayer(p)
				end,7)
			end
		else
			p.coolant_trigger = false
			p.coolant_deploy_time = nil
			p.coolant_configure_time = nil
			if p.get_coolant_button_eng ~= nil then
				p:removeCustom(p.get_coolant_button_eng)
				p.get_coolant_button_eng = nil
			end
			if p.get_coolant_button_epl ~= nil then
				p:removeCustom(p.get_coolant_button_epl)
				p.get_coolant_button_epl = nil
			end
			if p.gather_coolant_banner_eng ~= nil then
				p:removeCustom(p.gather_coolant_banner_eng)
				p.gather_coolant_banner_eng = nil
			end
			if p.gather_coolant_banner_epl ~= nil then
				p:removeCustom(p.gather_coolant_banner_epl)
				p.gather_coolant_banner_epl = nil
			end
		end
	end
end
function updateCoolantGivenPlayer(p, delta)
	if p.coolant_configure_time == nil then
		p.coolant_configure_time = getScenarioTime() + 5
	end
	p.gather_coolant_status = string.format(_("coolant-tabEngineer","Configuring Collectors %i"),math.ceil(p.coolant_configure_time - getScenarioTime()))
	if getScenarioTime() > p.coolant_configure_time then
		if p.coolant_deploy_time == nil then
			p.coolant_deploy_time = getScenarioTime() + 5
		end
		p.gather_coolant_status = string.format(_("coolant-tabEngineer","Deploying Collectors %i"),math.ceil(p.coolant_deploy_time - getScenarioTime()))
		if getScenarioTime() > p.coolant_deploy_time then
			p.gather_coolant_status = _("coolant-tabEngineer","Gathering Coolant")
			p:setMaxCoolant(p:getMaxCoolant() + coolant_gain)
		end
	end
	p.gather_coolant_banner_eng = "gather_coolant_banner_eng"
	p:addCustomInfo("Engineering",p.gather_coolant_banner_eng,p.gather_coolant_status,8)
	p.gather_coolant_banner_epl = "gather_coolant_banner_epl"
	p:addCustomInfo("Engineering+",p.gather_coolant_banner_epl,p.gather_coolant_status,8)
end
function getCoolantGivenPlayer(p)
	if p.get_coolant_button_eng ~= nil then
		p:removeCustom(p.get_coolant_button_eng)
		p.get_coolant_button_eng = nil
	end
	if p.get_coolant_button_epl ~= nil then
		p:removeCustom(p.get_coolant_button_epl)
		p.get_coolant_button_epl = nil
	end
	p.coolant_trigger = true
end
----------------------------
-- Plot related functions --
----------------------------
-- INITIAL PLOT Defend primus station
function startDefendPrimusStation()
	setUpDefendPrimusStation = "done"
	for i,p in ipairs(getActivePlayerShips()) do
		p:addToShipLog(string.format(_("goal-shipLog","[%s orbiting %s currently in %s] We could use help taking care of nearby Exuari"),primusStation:getCallSign(),planetPrimus:getCallSign(),primusStation:getSectorName()),"Magenta")
	end
	playVoice("Skyler01")
	primaryOrders = string.format(_("orders-comms","Remove Exuari near %s"),primusStation:getCallSign())
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
	for i, enemy in ipairs(enemyFleet) do
		enemy:orderAttack(primusStation)
	end
	reinforcementInterval = 60
	reinforcementTimer = getScenarioTime() + reinforcementInterval
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
	local perceived_player = nil
	for i, enemy in ipairs(enemyFleet) do
		if enemy ~= nil and enemy:isValid() then
			remainingEnemyCount = remainingEnemyCount + 1
			for j,p in ipairs(getActivePlayerShips()) do
				if distance(p,enemy) < 8000 then
					perceivePlayer = true
					perceived_player = p
					break
				end
			end
		end
		if perceivePlayer and remainingEnemyCount > 0 then
			break
		end
	end
	if remainingEnemyCount > 0 then
		if perceivePlayer then
			if getScenarioTime() > reinforcementTimer then
				if reinforcementCount > 0 then
					if reinforcementCount == 3 then
						for i, enemy in ipairs(enemyFleet) do
							enemy:orderAttack(perceived_player)
						end
					else
						prx, pry = perceived_player:getPosition()
						pmx, pmy = vectorFromAngle(random(0,360),random(6000,8000))
						local tempFleet = spawnEnemies(prx+pmx,pry+pmy,1,"Exuari")
						for i, enemy in ipairs(tempFleet) do
							enemy:orderAttack(perceived_player)
							table.insert(enemyFleet,enemy)
						end
					end
					reinforcementCount = reinforcementCount - 1
				end
				reinforcementTimer = getScenarioTime() + reinforcementInterval
			end
		else
			reinforcementTimer = getScenarioTime() + reinforcementInterval
		end
	else
		--no enemies remain
		if missionCloseMessage == nil then
			missionCloseMessage = "sent"
			for i,p in ipairs(getActivePlayerShips()) do
				p:addToShipLog(string.format(_("goal-shipLog","[%s] All station personnel thank you for your assistance. Dock with us for further orders"),primusStation:getCallSign()),"Magenta")
			end
			playVoice("Skyler02")
			primaryOrders = string.format(_("orders-comms","Dock with %s"),primusStation:getCallSign())
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
	artifactSensorReadingTimer = getScenarioTime() + readingTimerMax
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
		local player_with_astronomer = nil
		for i,p in ipairs(getActivePlayerShips()) do
			if p.astronomer then
				player_with_astronomer = p
				local remaining_scan_time = artifactSensorReadingTimer - getScenarioTime()
				if not artifact_sensor_data_timer_button and not artifactSensorDataGathered then
					artifact_sensor_data_timer_button = true
					sensor_data_timer_button = "sensor_data_timer_button"
					p:addCustomButton("Relay",sensor_data_timer_button,_("buttonRelay","Polly Scan Time"),function()
						string.format("")
						if getScenarioTime() > artifactSensorReadingTimer then
							p:addToShipLog(_("goal-shipLog","Scan complete","Yellow"))
						else
							p:addToShipLog(string.format(_("goal-shipLog","%.1f seconds remain to be scanned"),remaining_scan_time),"Yellow")
						end
					end,11)
				end
				local sensor_status = _("tabHelmTactical","Range")
				if distance(p,belt1Artifact) < 1000 then
					sensor_status = string.format(_("tabHelmTactical","In %s"),sensor_status)
					if not artifactInvestigateRange then
						artifactInvestigateRange = true
						p:addToShipLog(string.format(_("goal-shipLog","[Polly Hobbs] We are in range for additional sensor readings. Gathering data now. We will need to stay in range for %s seconds to complete the sensor readings"),readingTimerMax),"Magenta")
						playVoice(string.format("Polly01%i",readingTimerMax))
					end
					if getScenarioTime() > artifactSensorReadingTimer then
						artifactSensorDataGathered = true
						if analyzeGatheredDataMsg == nil then
							analyzeGatheredDataMsg = "sent"
							p:addToShipLog(_("goal-shipLog","[Polly Hobbs] The data gathering phase is complete. Analyzing data."),"Magenta")
							playVoice("Polly04")
							artifactDataAnalysisTimer = getScenarioTime() + random(10,20)
						end
					end
				else
					sensor_status = string.format(_("tabHelms&Tactical","Out of %s"),sensor_status)
					artifactSensorReadingTimer = getScenarioTime() + readingTimerMax
					remaining_scan_time = artifactSensorReadingTimer - getScenarioTime()
					if batch_msg == nil then
						batch_msg = "sent"
						p:addToShipLog(string.format(_("-shipLog","[Polly Hobbs] %.1f seconds remain to be scanned"),remaining_scan_time),"Magenta")
					end
				end
				remaining_scan_time = artifactSensorReadingTimer - getScenarioTime()
				sensor_status = string.format(_("-tabHelms&Tactical","%s: %i"),sensor_status,math.ceil(remaining_scan_time))
				if p:hasPlayerAtPosition("Helms") then
					p.sensor_status = "sensor_status"
					p:addCustomInfo("Helms",p.sensor_status,sensor_status,10)
				end
				if p:hasPlayerAtPosition("Tactical") then
					p.sensor_status_tactical = "sensor_status_tactical"
					p:addCustomInfo("Tactical",p.sensor_status_tactical,sensor_status,10)
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
		if artifactSensorDataGathered then
			if getScenarioTime() > artifactDataAnalysisTimer then
				if player_with_astronomer ~= nil and player_with_astronomer:isValid() then
					if artifactAnalysisMessage == nil then
						artifactAnalysisMessage = "sent"
						player_with_astronomer:addToShipLog(_("goal-shipLog","[Polly Hobbs] Readings indicate that not only does this object not belong here physically, it seems to not belong here temporally either. Portions of it are phasing in and out of our time continuum"),"Magenta")
						playVoice("Polly05")
						independentReleaseTimer = getScenarioTime() + random(20,40)
					end
				end
			end
			if artifactAnalysisMessage == "sent" then
				if getScenarioTime() > independentReleaseTimer and lostIndependentFleet == nil then
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
					releaseMessageTimer = getScenarioTime() + 5
				end
			end
			if lostIndependentFleet ~= nil then
				if getScenarioTime() > releaseMessageTimer then
					if releaseMsg == nil then
						releaseMsg = "sent"
						if player_with_astronomer ~= nil and player_with_astronomer:isValid() then
							player_with_astronomer:addToShipLog(_("goal-shipLog","[Polly Hobbs] There was a surge of chroniton particles from the artifact just before those Independent ships appeared. I think they were somehow released or transported by the artifact"),"Magenta")
							playVoice("Polly06")
							timeSignatureMessageTimer = getScenarioTime() + 10
						end
					end
				end
			end
			if releaseMsg == "sent" then
				if getScenarioTime() > timeSignatureMessageTimer then
					if timeSignatureMsg == nil then
						timeSignatureMsg = "sent"
						if player_with_astronomer ~= nil and player_with_astronomer:isValid() then
							player_with_astronomer:addToShipLog(_("goal-shipLog","[Polly Hobbs] Those ships show time signatures from history. I'm not sure why such old ships have suddenly appeared. I have gathered as much data as I can on this phenomenon. Thank you for your assistance"),"Magenta")
							playVoice("Polly07")
						end
						exuariInterestTimer = getScenarioTime() + 30
						plot2 = exuariInterest
						plot3 = transportCleanup
						plot1 = nil
						mission_complete_count = mission_complete_count + 1
						plotChoiceStation = primusStation
						primaryOrders = string.format(_("orders-comms","Dock with %s"),primusStation:getCallSign())
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
		for i, tempShip in pairs(lostIndependentFleet) do
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
		for i, tempShip in pairs(secondLostFleet) do
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
	if getScenarioTime() > exuariInterestTimer then
		plot2 = secondRelease
		secondReleaseTimer = getScenarioTime() + 600
		for i=1,#lostIndependentFleet do
			local tempShip = lostIndependentFleet[i]
			if tempShip ~= nil and tempShip:isValid() then
				pmx, pmy = tempShip:getPosition()
				break
			end
		end
		local tempFleet = spawnEnemies(pmx, pmy, 2, "Exuari")
		for i, enemy in ipairs(tempFleet) do
			enemy:orderRoaming()
		end
	end
end
function secondRelease(delta)
	if getScenarioTime() > secondReleaseTimer then
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
			tempShip:setCallSign(generateCallSign(nil,"Exuari"))
			tempShip:setPosition(tpmx,tpmy):orderDock(tempBase)
			tempShip.targetDock = tempBase
			table.insert(secondLostFleet,tempShip)
		end
		plot2 = secondExuariInterest
		secondInterestTimer = getScenarioTime() + 30
	end
end
function secondExuariInterest(delta)
	if getScenarioTime() > secondInterestTimer then
		plot2 = nil
		for i=1,#secondLostFleet do
			local tempShip = secondLostFleet[i]
			if tempShip ~= nil and tempShip:isValid() then
				local tpmx, tpmy = tempShip:getPosition()
				break
			end
		end
		local tempFleet = spawnEnemies(tpmx, tpmy, 5, "Exuari")
		for i, enemy in ipairs(tempFleet) do
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
	for i,p in ipairs(getActivePlayerShips()) do
		p.planetologistAboard = false
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
		primaryOrders = string.format(_("orders-comms","Transport planetologist by docking with %s"),primusStation:getCallSign())
		if player_ship_with_planetologist == nil then
			for i,p in ipairs(getActivePlayerShips()) do
				if p.planetologistAboard then
					player_ship_with_planetologist = p
					break
				end
			end
		end
		if player_ship_with_planetologist ~= nil then
			if player_ship_with_planetologist:isValid() then
				if player_ship_with_planetologist:isDocked(primusStation) then
					primaryOrders = string.format(_("orders-comms","Dock with %s"),primusStation:getCallSign())
					plot1 = nil
					mission_complete_count = mission_complete_count + 1
					plotChoiceStation = primusStation
					p:addToShipLog(_("goal-shipLog","Enrique Flogistan profusely thanked you as he dashed to his observation laboratory. He discussed his research on some unique properties of dilithium with your engineer before he left. Consequently, engineering has improved battery efficiency by ten percent"),"Magenta")
					p:setMaxEnergy(p:getMaxEnergy()*1.1)
					p:addReputationPoints(50)
				end
			else
				--player ship with planetologist aboard was destroyed
				showEndStats(_("msgMainscreen","Planetologist perished"))
				victory("Exuari")
			end
		end
		if getScenarioTime() > planetologistAssassinTimer then
			if planetologistAssassin == nil then
				planetologistAssassin = "spawned"
				prx, pry = player_ship_with_planetologist:getPosition()
				pmx, pmy = primusStation:getPosition()
				enemyFleet = spawnEnemies((prx+pmx)/2,(pry+pmy)/2,1,"Exuari")
				for i, enemy in ipairs(enemyFleet) do
					enemy:orderAttack(player_ship_with_planetologist)
					if difficulty >= 1 then
						enemy:setWarpDrive(true)
					end
				end
			end
		end
	else
		planetologistAssassinTimer = getScenarioTime() + random(10,30)
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
	print(secondusStations[1]:getCallSign(),"has",satelliteGood,"at",secondusStations[1].comms_data.goods[satelliteGood].cost,"reputation each which",secondusStations[2]:getCallSign(),"needs")
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
	print(secondusStations[2]:getCallSign(),"has",satelliteGood,"at",secondusStations[2].comms_data.goods[satelliteGood].cost,"reputation each which",secondusStations[3]:getCallSign(),"needs")
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
	print(secondusStations[3]:getCallSign(),"has",satelliteGood,"at",secondusStations[3].comms_data.goods[satelliteGood].cost,"reputation each which",secondusStations[1]:getCallSign(),"needs")
	fixHarassInterval = 300
	fixHarassTimer = getScenarioTime() + fixHarassInterval
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
	for i, enemy in ipairs(enemyFleet) do
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
		for i,p in ipairs(getActivePlayerShips()) do
			p:addToShipLog(_("goal-shipLog","[Engineering Technician] For helping to fix their satellites, the satellite station technicians have doubled our impulse engine's top speed"),"Magenta")
			p:addToShipLog(string.format(_("goal-shipLog","Dock with %s"),primusStation:getCallSign()),"Magenta")
			p:setImpulseMaxSpeed(p:getImpulseMaxSpeed()*2)
			if reputationPending then
				p:addReputationPoints(50)
				reputationPending = false
			end
		end
		playVoice("Jamie01")
		primaryOrders = string.format(_("orders-comms","Dock with %s"),primusStation:getCallSign())
	end
	if remainingEnemyCount > 0 then
		fixHarassTimer = getScenarioTime() + fixHarassInterval
	else
		local got_rep = true
		if secondusStations[1].comms_data.goods[secondusStations[2].satelliteFixGood].cost > getPlayerShip(-1):getReputationPoints() then
			got_rep = false
		end
		if secondusStations[2].comms_data.goods[secondusStations[3].satelliteFixGood].cost > getPlayerShip(-1):getReputationPoints() then
			got_rep = false
		end
		if secondusStations[3].comms_data.goods[secondusStations[1].satelliteFixGood].cost > getPlayerShip(-1):getReputationPoints() then
			got_rep = false
		end
		if getScenarioTime() > fixHarassTimer or not got_rep then
			fixHarassTimer = getScenarioTime() + fixHarassInterval
			if fixHarassCount % 2 > 0 then
				local satellite_templates = {
					"Stalker Q7",
					"Stalker Q5",
					"Waddle 5",
					"Fiend G4",
					"Fiend G6",
				}
				enemyFleet = {} 
				for i,p in ipairs(getActivePlayerShips()) do
					local px, py = p:getPosition()
					for j=1,math.random(2,5) do
						local selected_template = satellite_templates[math.random(1,#satellite_templates)]
						local ship = ship_template[selected_template].create("Exuari",selected_template)
						local vx, vy = vectorFromAngle(random(0,360),random(10000,20000))
						ship:setPosition(px + vx, py + vy):orderAttack(p)
						table.insert(enemyFleet,ship)
					end
				end
			else
				harass_player_ship = closestPlayerTo(planetSecondus)
				if harass_player_ship == nil then
					local harass_players = getActivePlayerShips()
					harass_player_ship = harass_players[math.random(1,#harass_players)]
				end
				local hps = nearStations(harass_player_ship, secondusStations)
				prx, pry = harass_player_ship:getPosition()
				pmx, pmy = vectorFromAngle(hps.angle,random(5100,6000))
				enemyFleet = spawnEnemies(prx+pmx,pry+pmy,1+(difficulty*fixHarassCount*.4),"Exuari")
				for i, enemy in ipairs(enemyFleet) do
					enemy:orderAttack(harass_player_ship)
				end
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
	protect_station_name = protect_station:getCallSign()
	primaryOrders = string.format(_("orders-comms","Protect %s from marauding Exuari"),protect_station_name)
end
function defendSpawnBandStation(delta)
	if set_up_defend_spawn_band_station == nil then
		startDefendSpawnBandStation()
	end
	plot1 = marauderHorizon
end
function marauderHorizon(delta)
	if marauder_horizon_timer == nil then
		marauder_horizon_timer = getScenarioTime() + 100
	end
	if getScenarioTime() > marauder_horizon_timer then
		if protect_station ~= nil and protect_station:isValid() then
			plot1 = marauderSpawn
		else
			showEndStats(string.format(_("msgMainscreen","Station %s destroyed"),protect_station_name))
			victory("Exuari")
		end
	end
end
function marauderSpawn(delta)
	if protect_station ~= nil and protect_station:isValid() then
		local closest_protective_player = nil
		for i,p in ipairs(getActivePlayerShips()) do
			if closest_protective_player == nil then
				closest_protective_player = p
			else
				if distance(p,protect_station) < distance(closest_protective_player,protect_station) then
					closest_protective_player = p
				end
			end
		end
		if closest_protective_player ~= nil then
			protect_station.marauder_choice = closest_protective_player
			local px, py = closest_protective_player:getPosition()
			local sx, sy = protect_station:getPosition()
			protect_station.initial_marauder_fleet = spawnEnemies((px+sx)/2,(py+sy)/2,1,"Exuari")
			for i, enemy in ipairs(protect_station.initial_marauder_fleet) do
				enemy:orderAttack(protect_station)
			end
			plot1 = marauderApproach
		end
	else
		showEndStats(string.format(_("msgMainscreen","Station %s destroyed"),protect_station_name))
		victory("Exuari")
	end
end
function marauderApproach(delta)
	if protect_station ~= nil and protect_station:isValid() then
		local sx, sy = protect_station:getPosition()
		if protect_station.marauder_warning == nil then
			for i, enemy in pairs(protect_station.initial_marauder_fleet) do
				if enemy ~= nil and enemy:isValid() then
					if distance(enemy,protect_station) < 30000 then
						local ex, ey = enemy:getPosition()
						local marauder_bearing = angleFromVectorNorth(ex, ey, sx, sy)
						if protect_station.marauder_choice ~= nil and protect_station.marauder_choice:isValid() then
							protect_station.marauder_choice:addToShipLog(string.format(_("goal-shipLog","[%s in %s] The Exuari are coming! We detected them on bearing %.1f from us."),protect_station_name,protect_station:getSectorName(),marauder_bearing),"Magenta")
							protect_station.marauder_warning = "done"
						else
							local closest_protective_player = nil
							for j,p in ipairs(getActivePlayerShips()) do
								if closest_protective_player == nil then
									closest_protective_player = p
								else
									if distance(p,protect_station) < distance(closest_protective_player,protect_station) then
										closest_protective_player = p
									end
								end
							end
							if closest_protective_player ~= nil then
								protect_station.marauder_choice = closest_protective_player
								protect_station.marauder_choice:addToShipLog(string.format(_("goal-shipLog","[%s in %s] The Exuari are coming! We detected them on bearing %.1f from us."),protect_station_name,protect_station:getSectorName(),marauder_bearing),"Magenta")
								protect_station.marauder_warning = "done"
							end
						end
						break
					end
				end
			end
		end
		for i,p in ipairs(getActivePlayerShips()) do
			if distance(p,protect_station) < 25000 then
				if protect_station.marauder_station_fleet == nil then
					local px, py = p:getPosition()
					protect_station.marauder_station_fleet = spawnEnemies((px+sx)/2,(py+sy)/2,1,"Exuari")
					for i, enemy in ipairs(protect_station.marauder_station_fleet) do
						enemy:orderAttack(protect_station)
					end
					protect_station.marauder_player_fleet = spawnEnemies((px+sx)/2,(py+sy)/2,1,"Exuari")
					for i, enemy in ipairs(protect_station.marauder_player_fleet) do
						enemy:orderAttack(p)
					end
				end
				plot1 = marauderVanguard
				break
			end
		end
	else
		showEndStats(string.format(_("msgMainscreen","Station %s destroyed"),protect_station_name))
		victory("Exuari")
	end
end
function marauderVanguard(delta)
	if protect_station ~= nil and protect_station:isValid() then
		if protect_station.vanguard_timer == nil then
			protect_station.vanguard_timer = getScenarioTime() + 300
		end
		if getScenarioTime() < protect_station.vanguard_timer then
			local vx, vy = vectorFromAngle(random(0,360),random(9000,14000))
			local sx, sy = protect_station:getPosition()
			protect_station.vanguard_fleet = spawnEnemies(vx+sx,vy+sy,2*difficulty,"Exuari")
			for i, enemy in ipairs(protect_station.vanguard_fleet) do
				enemy:orderFlyTowards(sx,sy)
			end
			plot1 = marauderFleetDestroyed
		end
	else
		showEndStats(string.format(_("msgMainscreen","Station %s destroyed"),protect_station_name))
		victory("Exuari")
	end
end
function marauderFleetDestroyed(delta)
	if protect_station ~= nil and protect_station:isValid() then
		local marauder_count = 0
		for i, enemy in pairs(protect_station.initial_marauder_fleet) do
			if enemy ~= nil and enemy:isValid() then
				marauder_count = marauder_count + 1
				break
			end
		end
		for i, enemy in pairs(protect_station.marauder_station_fleet) do
			if enemy ~= nil and enemy:isValid() then
				marauder_count = marauder_count + 1
				break
			end
		end
		for i, enemy in pairs(protect_station.marauder_player_fleet) do
			if enemy ~= nil and enemy:isValid() then
				marauder_count = marauder_count + 1
				break
			end
		end
		for i, enemy in pairs(protect_station.vanguard_fleet) do
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
			for i,p in ipairs(getActivePlayerShips()) do
				p:addToShipLog(string.format(_("goal-shipLog","[Engineering Technician] For helping against the Exuari marauders, %s has provided us details on improving our maneuvering speed."),protect_station_name),"Magenta")
				p:addToShipLog(string.format(_("goal-shipLog","Dock with %s"),primusStation:getCallSign()),"Magenta")
				p:setRotationMaxSpeed(p:getRotationMaxSpeed()*2)
				if reputationPending then
					p:addReputationPoints(50)
					reputationPending = false
				end
			end
			playVoice("Jamie02")
			primaryOrders = string.format(_("orders-comms","Dock with %s"),primusStation:getCallSign())
		end
	else
		showEndStats(string.format(_("msgMainscreen","Station %s destroyed"),protect_station_name))
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
	for i, enemy in ipairs(piracyFleet) do
		enemy:orderFlyTowards(tpmx, tpmy)
	end
	for i,p in ipairs(getActivePlayerShips()) do
		p:addToShipLog(string.format(_("goal-shipLog","%s in %s reports Exuari pirates threatening them."),protectTransport:getCallSign(),protectTransport:getSectorName()),"Magenta")
	end
	primaryOrders = string.format(_("orders-comms","Protect %s from Exuari pirates. Last reported in %s"),protectTransport:getCallSign(),protectTransport:getSectorName())
end
function piracyPlot(delta)
	if setUpPiracy == nil then
		startPiracy()
	end
	plot1 = checkPiracyEvents
end
function checkPiracyEvents(delta)
	if protectTransport == nil or not protectTransport:isValid() then
		showEndStats(_("msgMainscreen","Transport destroyed"))
		victory("Exuari")
	end
	local piracyFleetCount = 0
	if piracyFleet ~= nil then
		for i, enemy in pairs(piracyFleet) do
			if enemy ~= nil and enemy:isValid() then
				piracyFleetCount = piracyFleetCount + 1
				break
			end
		end
		if piracyFleetCount < 1 then
			plot1 = nil
			mission_complete_count = mission_complete_count + 1
			plotChoiceStation = belt1Stations[1]
			local reputation_pending = true
			for i,p in ipairs(getActivePlayerShips()) do
				p:addToShipLog(string.format(_("goal-shipLog","[%s] Thanks for dealing with those Exuari pirates"),protectTransport:getCallSign()),"Magenta")
				if reputation_pending then
					p:addReputationPoints(50)
					reputation_pending = false
				end
			end
			primaryOrders = string.format(_("orders-comms","Dock with %s"),belt1Stations[1]:getCallSign())
			piracy = "done"
		end
	end
end
-- BELT STATION PLOT Virus Outbreak
function startVirus()
	set_up_virus = "done"
	local virus_player_count = 0
	for i,p in ipairs(getActivePlayerShips()) do
		p.virus_cure = false
		p.virus_cure_button = "empty"
		virus_player_count = virus_player_count + 1
	end
	for i,station in ipairs(belt1Stations) do
		station.virus_cure = false
	end
	max_virus_timer = (720 - difficulty*120)/virus_player_count
	virus_time = getScenarioTime() + max_virus_timer
	virus_harass = false
end
function virusOutbreak(delta)
	if set_up_virus == nil then
		startVirus()
	end
	plot1 = checkVirusEvents
end
function checkVirusEvents(delta)
	for i,p in ipairs(getActivePlayerShips()) do
		if p:isDocked(belt1Stations[4]) and not p.virus_cure then
			p.virus_cure = true
			p:addToShipLog(string.format(_("goal-shipLog","[%s medical quartermaster] Anti-virus loaded aboard your ship"),belt1Stations[4]:getCallSign()),"Magenta")
			playVoice("Phoenix01")
			belt1Stations[4].virus_cure = true
		end
		if p.virus_cure then
			p.virus_cure_button_rel = "virus_cure_button_rel"
			p:addCustomButton("Relay",p.virus_cure_button_rel,_("buttonRelay","Virus status"),function()
				string.format("")
				virusStatus(p)
			end, 9)
			p.virus_cure_button_ops = "virus_cure_button_ops"
			p:addCustomButton("Operations",p.virus_cure_button_ops,_("buttonOperations","Virus status"),function()
				string.format("")
				virusStatus(p)
			end, 9)
			for j,station in ipairs(belt1Stations) do
				if p:isDocked(station) and not station.virus_cure then
					station.virus_cure = true
					p:addToShipLog(string.format(_("goal-shipLog","[%s Medical Team] Received Anti-virus. Administering to station personnel. Thanks %s"),current_belt1_station:getCallSign(),p:getCallSign()),"Magenta")
				end
			end
		end
	end
	local station_cure_count = 0
	for i,station in ipairs(belt1Stations) do
		if station.virus_cure then
			station_cure_count = station_cure_count + 1
		end
	end
	if station_cure_count < #belt1Stations then
		if getScenarioTime() > virus_time then
			playVoice("Tracy13")
			showEndStats(_("msgMainscreen","Pandemic"))
			victory("Exuari")
		else
			local virus_timer = virus_time - getScenarioTime()
			if station_cure_count >= 3 and not virus_harass then
				virus_harass = true
				local per_station = max_virus_timer/5
				if virus_timer < (max_virus_timer - (3 * per_station)) then
					playVoice("Tracy12")
				end
				for i,p in ipairs(getActivePlayerShips()) do
					local phx, phy = p:getPosition()
					local virus_fleet = spawnEnemies(phx, phy, 1, "Exuari", 2000 - difficulty*100, 4000)
					for enemy in pairs(virus_fleet) do
						enemy:orderAttack(p)
					end
				end
			end
			local virus_minutes = math.floor(virus_timer / 60)
			local virus_seconds = math.floor(virus_timer % 60)
			local virus_status = _("tabScience&Operations","Virus Fatality")
			if virus_minutes <= 0 then
				virus_status = string.format(_("tabScience&Operations","%s: %i"),virus_status,virus_seconds)
			else
				virus_status = string.format(_("tabScience&Operations","%s: %i:%.2i"),virus_status,virus_minutes,virus_seconds)
			end
			for i,p in ipairs(getActivePlayerShips()) do
				p.virus_status_sci = "virus_status_sci"
				p:addCustomInfo("Science",p.virus_status_sci,virus_status,4)
				p.virus_status_ops = "virus_status_ops"
				p:addCustomInfo("Operations",p.virus_status_ops,virus_status,4)
			end
		end
	else
		plot1 = nil
		mission_complete_count = mission_complete_count + 1
		plotChoiceStation = belt1Stations[1]
		primaryOrders = string.format(_("orders-comms","Dock with %s"),belt1Stations[1]:getCallSign())
		local reputation_pending = true
		for i,p in ipairs(getActivePlayerShips()) do
			p:addToShipLog(string.format(_("goal-shipLog","Stations have been saved from the virus outbreak. Dock with %s for further orders"),belt1Stations[1]:getCallSign()),"Magenta")
			if reputation_pending then
				p:addReputationPoints(50)
				reputation_pending = false
			end
			if p.virus_cure_button_rel ~= nil then
				p:removeCustom(p.virus_cure_button_rel)
				p.virus_cure_button_rel = nil
			end
			if p.virus_cure_button_ops ~= nil then
				p:removeCustom(p.virus_cure_button_ops)
				p.virus_cure_button_ops = nil
			end
			if p.virus_status_sci ~= nil then
				p:removeCustom(p.virus_status_sci)
				p.virus_status_sci = nil
			end
			if p.virus_status_ops ~= nil then
				p:removeCustom(p.virus_status_ops)
				p.virus_status_ops = nil
			end
		end
		playVoice("Tracy07")
	end
end
function virusStatus(p)
	local virus_timer = virus_time - getScenarioTime()
	local virus_minutes = math.floor(virus_timer / 60)
	local status_message = _("goal-shipLog","First virus fatality in")
	if virus_minutes < 1 then
		status_message = string.format(_("goal-shipLog","%s %.f seconds."),status_message,virus_timer)
	else
		status_message = string.format(_("goal-shipLog","%s %i minutes."),status_message,virus_minutes)
	end
	local stations_needing_antivirus = _("goal-shipLog",". Stations needing anti-virus:")
	for i,station in ipairs(belt1Stations) do
		if not station.virus_cure then
			stations_needing_antivirus = string.format("%s %s",stations_needing_antivirus,station:getCallSign())
		end
	end
	status_message = status_message .. stations_needing_antivirus
	p:addToShipLog(status_message,"Yellow")
end
-- BELT STATION PLOT Exuari Target Intelligence
function startTargetIntel()
	set_up_target_intel = "done"
	for i,p in ipairs(getActivePlayerShips()) do
		p.target_intel = false
	end
	local clean_list = true
	repeat
		for i,station in ipairs(playerSpawnBandStations) do
			if station ~= nil then
				if not station:isValid() then
					playerSpawnBandStations[i] = playerSpawnBandStations[#playerSpawnBandStations]
					playerSpawnBandStations[#playerSpawnBandStations] = nil
					clean_list = false
					break
				end
			end
		end
	until(clean_list or #playerSpawnBandStations < 2)
	if #playerSpawnBandStations >= 2 then
		local station_pool = {}
		for i,station in ipairs(playerSpawnBandStations) do
			table.insert(station_pool,station)
		end
		intel_station = tableRemoveRandom(station_pool)
		target_station = tableRemoveRandom(station_pool)
		primaryOrders = string.format(_("orders-comms","Dock with %s in %s for Exuari intelligence"),intel_station:getCallSign(),intel_station:getSectorName())
		for i,p in ipairs(getActivePlayerShips()) do
			p:addToShipLog(string.format(_("orders-comms","Dock with %s in %s for Exuari intelligence"),intel_station:getCallSign(),intel_station:getSectorName()),"Magenta")
		end
		intel_attack = false
	else
		playVoice("Tracy11")
		showEndStats(_("msgMainscreen","Exuari destroyed station"))
		victory("Exuari")
	end
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
		showEndStats(_("msgMainscreen","Exuari destroyed station"))
		victory("Exuari")
	end
	local iwpx, iwpy = target_station:getPosition()
	for i,p in ipairs(getActivePlayerShips()) do
		if p:isDocked(intel_station) and p.intel_message == nil then
			p.target_intel = true
			p:addToShipLog(string.format(_("goal-shipLog","Intelligence report: the Exuari have chosen %s in %s as their next target for attack. Make sure they do not succeed"),target_station:getCallSign(),target_station:getSectorName()),"Magenta")
			p.intel_message = "sent"
			if p:getWaypointCount() < 9 and p.intel_waypoint == nil then
				p:commandAddWaypoint(iwpx,iwpy)
				p:addToShipLog(string.format(_("-shipLog","Added waypoint %i to your navigation system for %s"),p:getWaypointCount(),target_station:getCallSign()),"Magenta")
				playVoice("Tracy08")
				p.intel_waypoint = "added"
			end
		else
			if p.target_intel and not intel_attack then
				local plx, ply = p:getPosition()
				intel_fleet_player = spawnEnemies((plx+iwpx)/2, (ply+iwpy)/2, 1, "Exuari")
				for i, enemy in ipairs(intel_fleet_player) do
					enemy:orderFlyTowards(plx,ply)
				end
				intel_fleet_station = spawnEnemies((plx+iwpx)/2 + 1000, (ply+iwpy)/2 + 1000, 1, "Exuari")
				for i, enemy in ipairs(intel_fleet_station) do
					enemy:orderFlyTowards(iwpx,iwpy)
				end
				intel_attack = true
			end
		end
	end
	if intel_attack then
		local intel_fleet_count = 0
		for i, enemy in pairs(intel_fleet_player) do
			if enemy ~= nil and enemy:isValid() then
				intel_fleet_count = intel_fleet_count + 1
				local current_order = enemy:getOrder()
				if current_order ~= nil and (current_order == "Idle" or current_order == "Defend Location") then
					enemy:orderRoaming()
				end
			end
		end
		for i, enemy in pairs(intel_fleet_station) do
			if enemy ~= nil and enemy:isValid() then
				intel_fleet_count = intel_fleet_count + 1
				local current_order = enemy:getOrder()
				if current_order ~= nil and (current_order == "Idle" or current_order == "Defend Location") then
					enemy:orderRoaming()
				end
			end
		end
		if intel_fleet_count < 1 then
			plot1 = nil
			mission_complete_count = mission_complete_count + 1
			plotChoiceStation = belt1Stations[1]
			for i,p in ipairs(getActivePlayerShips()) do
				p:addToShipLog(_("-shipLog","Looks like you thwarted that Exuari attack"),"Magenta")
			end
			playVoice("Tracy09")
			primaryOrders = string.format(_("orders-comms","Dock with %s"),belt1Stations[1]:getCallSign())
		end
	end
end
-- TERTIUS PLOT Exuari Exterminate Extraterrestrials
function startExterminate()
	set_up_exterminate = "done"
	primaryOrders = _("orders-comms","Make a good showing for the Human Navy against the Exuari invasion")
	exterminate_interval = 300 - 50*difficulty
	exterminate_timer = getScenarioTime() + exterminate_interval
	docked_with_tertius = true
	exterminate_fleet_list = {}
	exuari_danger = 1
	for i,p in ipairs(getActivePlayerShips()) do
		local plx, ply = p:getPosition()
		local eFleet = spawnEnemies(plx,ply,exuari_danger,"Exuari",4000,6000)
		for i, enemy in ipairs(eFleet) do
			enemy:orderAttack(p)
		end
		table.insert(exterminate_fleet_list,eFleet)
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
			for i,p in ipairs(getActivePlayerShips()) do
				if p:isDocked(tertiusStation) then
					docked_with_tertius = true
					break
				end
			end
		else
			docked_with_tertius = false
		end
		if exterminate_timer > getScenarioTime() then
			exterminate_timer = exterminate_timer + delta
		end
	end
	if getScenarioTime() > exterminate_timer then
		exuari_danger = exuari_danger + 1
		for i,p in ipairs(getActivePlayerShips()) do
			local plx, ply = p:getPosition()
			local eFleet = spawnEnemies(plx,ply,exuari_danger,"Exuari",2000,6000)
			for i, enemy in ipairs(eFleet) do
				enemy:orderAttack(p)
			end
			table.insert(exterminate_fleet_list,eFleet)
		end
		plx, ply = vectorFromAngle(random(0,360),tertiusMoonOrbit+1000)
		local tx, ty = planetTertius:getPosition()
		eFleet = spawnEnemies(tx+plx,ty+ply,exuari_danger*2,"Exuari")
		for i, enemy in ipairs(eFleet) do
			enemy:orderRoaming()
		end
		table.insert(exterminate_fleet_list,eFleet)
		exterminate_timer = getScenarioTime() + exterminate_interval
	end
	local exuari_enemy_count = 0
	for i, fleet in pairs(exterminate_fleet_list) do
		for j, enemy in pairs(fleet) do
			if enemy ~= nil and enemy:isValid() then
				exuari_enemy_count = exuari_enemy_count + 1
			end
		end
	end
	if exuari_enemy_count < exuari_danger then
		exuari_danger = exuari_danger + 1
		for i,p in ipairs(getActivePlayerShips()) do
			plx, ply = p:getPosition()
			eFleet = spawnEnemies(plx,ply,exuari_danger,"Exuari",2000,6000)
			for i, enemy in ipairs(eFleet) do
				enemy:orderAttack(p)
			end
			table.insert(exterminate_fleet_list,eFleet)
		end
	end
end
-- TERTIUS PLOT Eliminate Exuari stronghold
function startStronghold()
	set_up_stronghold = "done"
	primaryOrders = _("orders-comms","Find and eliminate the Exuari station that is sending all these ships after us")
	local esx, esy = vectorFromAngle(random(10,80),random(tertiusOrbit + tertiusMoonOrbit + 50000,tertiusOrbit + tertiusMoonOrbit + 100000))
	psx = solX+esx
	psy = solY+esy
	stationFaction = "Exuari"
	stationStaticAsteroids = true
	pStation = placeUVStation(psx,psy,"Sinister")
	table.insert(stationList,pStation)			--save station in general station list
	table.insert(exuariStationList,pStation)	--save station in exuari station list
	exuari_stronghold = pStation
	stronghold_interval = 300 - 50*difficulty
	stronghold_timer = getScenarioTime() + stronghold_interval
	exuari_danger = 1
	for i,p in ipairs(getActivePlayerShips()) do
		local plx, ply = p:getPosition()
		local eFleet = spawnEnemies(plx,ply,exuari_danger,"Exuari",4000,6000)
		for j, enemy in ipairs(eFleet) do
			enemy:orderAttack(p)
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
		showEndStats(_("msgMainscreen","Exuari stronghold destroyed"))
		victory("Human Navy")
	end
	if getScenarioTime() > stronghold_timer then
		local p = closestPlayerTo(exuari_stronghold)
		if p ~= nil then
			local plx, ply = p:getPosition()
			if random(1,100) < 50 then
				local eFleet = spawnEnemies(plx,ply,exuari_danger,"Exuari",4000,6000)
				for i, enemy in ipairs(eFleet) do
					enemy:orderAttack(p)
				end
				if random(1,100) < 50 then
					WarpJammer():setRange(8000):setPosition(plx+3000,ply+3000):setFaction("Exuari")
				end
			else
				local esx, esy = exuari_stronghold:getPosition()
				eFleet = spawnEnemies((plx+esx)/2,(ply+esy)/2,exuari_danger,"Exuari")
				for i, enemy in ipairs(eFleet) do
					enemy:orderRoaming()
				end
			end
		else
			local plx, ply = exuari_stronghold:getPosition()
			local eFleet = spawnEnemies(plx,ply,exuari_danger,"Exuari",4000,6000)
			for i, enemy in ipairs(eFleet) do
				enemy:orderStandGround()
			end
		end
		exuari_danger = exuari_danger + 1
		stronghold_timer = getScenarioTime() + stronghold_interval
	end
end
-- TERTIUS PLOT Survive Exuari attack
function startSurvive()
	set_up_survive = "done"
	primaryOrders = _("orders-comms","Survive until the game time runs out")
	survive_interval = 300 - 50*difficulty
	survive_timer = getScenarioTime() + survive_interval
	exuari_danger = 1
	for i,p in ipairs(getActivePlayerShips()) do
		local plx, ply = p:getPosition()
		local eFleet = spawnEnemies(plx,ply,exuari_danger,"Exuari",4000,6000)
		for i, enemy in ipairs(eFleet) do
			enemy:orderAttack(p)
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
	if game_over_time == nil then
		game_over_time = getScenarioTime() + gameTimeLimit
	end
	if getScenarioTime() > game_over_time then
		mission_complete_count = mission_complete_count + 1
		showEndStats(_("msgMainscreen","Survived Exuari Attacks"))
		victory("Human Navy")
	else
		if getScenarioTime() > survive_timer then
			exuari_danger = exuari_danger + 1
			for i,p in ipairs(getActivePlayerShips()) do
				local plx, ply = p:getPosition()
				local eFleet = spawnEnemies(plx,ply,exuari_danger,"Exuari",4000,6000)
				for i, enemy in ipairs(eFleet) do
					enemy:orderAttack(p)
				end
				if random(1,100) < 50 then
					WarpJammer():setRange(8000):setLocation(plx+3000,ply-3000):setFaction("Exuari")
				end
			end
			survive_timer = getScenarioTime() + survive_interval
		end
	end
end
-- Working transports plot
function workingTransports(delta)
	if transport_delay_time == nil then
		transport_delay_time = getScenarioTime() + random(4,12)
	end
	if getScenarioTime() > transport_delay_time then
		transport_delay_time = nil
		for i, wt in pairs(transportsInPlayerSpawnBandList) do
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
		for i, wt in pairs(transportsOutsideBelt2List) do
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
	end
end
-- Manage plots
function setPlots()
	first_plots = {
		{func = fixSatellites,				desc = string.format(_("orders-comms","Satellite stations %s, %s and %s orbiting %s have been reporting periodic problems. See what you can do to help them out"),secondusStations[1]:getCallSign(),secondusStations[2]:getCallSign(),secondusStations[3]:getCallSign(),planetSecondus:getCallSign()),											order = string.format(_("orders-comms","Fix satellites orbiting %s"),planetSecondus:getCallSign()),												voice = string.format("Pat01%s",planetSecondus:getCallSign()),	},
		{func = transportPrimusResearcher,	desc = string.format(_("orders-comms","Planetologist Enrique Flogistan plans to study %s. However, his transport refuses to travel in the area due to increased Exuari activity. Dock with %s and transport the planetologist to %s"),planetPrimus:getCallSign(),belt1Stations[2]:getCallSign(),primusStation:getCallSign()),					order = string.format(_("orders-comms","Transport planetologist from %s to %s"),belt1Stations[2]:getCallSign(),primusStation:getCallSign()),	voice = string.format("Pat02%s",planetPrimus:getCallSign()),	},
		{func = orbitingArtifact,			desc = string.format(_("orders-comms","Analysis of sightings and readings taken by civilian astronmer Polly Hobbs shows anomalous readings in this area. She lives on station %s according to her published research. Find her, get the source data and investigate. Solicit her assistance if she's willing"),belt1Stations[5]:getCallSign()),	order = string.format(_("orders-comms","Dock with %s to investigate astronomer's unusual data"),belt1Stations[5]:getCallSign()),				voice = "Pat03",												},
		{func = defendSpawnBandStation,		desc = _("orders-comms","Intelligence indicates an imminent attack by the Exuari on a station in the area. Your mission is to protect the station"),																																															order = _("orders-comms","Defend station from Exuari attack"),																					voice = "Pat04",												},
	}
	initialMission = true
	local orbit_label = "Outside"
	if secondusOrbit > playerSpawnBand then
		orbit_label = "Inside"
	end
	second_plots = {
		{func = piracyPlot,		desc = _("orders-comms","A transport reports Exuari pirates threatening them"),																																																																																						order = _("orders-comms","Protect transport from Exuari pirates"),												voice = "Tracy03",																},
		{func = virusOutbreak,	desc = string.format(_("orders-comms","Stations %s, %s, %s, %s and %s all report outbreaks of a variant of Rathgar's space virus. %s has developed an effective anti-virus, but it needs to be delivered to all the stations quickly"),belt1Stations[1]:getCallSign(),belt1Stations[2]:getCallSign(),belt1Stations[3]:getCallSign(),belt1Stations[4]:getCallSign(),belt1Stations[5]:getCallSign(),belt1Stations[4]:getCallSign()),	order = string.format(_("orders-comms","Dock with %s to pick up anti-virus"),belt1Stations[4]:getCallSign()),	voice = "Tracy05",																},
		{func = targetIntel,	desc = _("orders-comms","We've picked up intelligence on the next Exuari attack. Check your ship log for details. Protect the target station."),																																																																					order = _("orders-comms","Dock with designated station for Exuari intelligence"),								voice = string.format("Tracy06%s%s",orbit_label,planetSecondus:getCallSign()),	},
	}
	piracy = "available"
end
function plotDelay(delta)
	if plotDelayTimer == nil then
		plotDelayTimer = getScenarioTime() + random(10,30)
	end
	if getScenarioTime() > plotDelayTimer then
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
				showEndStats(_("msgMainscreen","Critical station destroyed"))
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
	local stat_message = _("msgMainscreen","Human stations destroyed: ")
	if #humanStationDestroyedNameList ~= nil and #humanStationDestroyedNameList > 0 then
		stat_message = stat_message .. #humanStationDestroyedNameList
		local station_strength = 0
		for i=1,#humanStationDestroyedNameList do
			if humanStationDestroyedValue[i] ~= nil then
				station_strength = station_strength + humanStationDestroyedValue[i]
			else
				print("station",humanStationDestroyedNameList[i]," has nil value in human station destroyed value list")
			end
		end
		stat_message = stat_message .. string.format(_("msgMainscreen"," (total strength: %i)"),station_strength)
	else
		stat_message = stat_message .. _("msgMainscreen","none")
	end
	stat_message = stat_message .. _("msgMainscreen","\nNeutral stations destroyed: ")
	if #neutralStationDestroyedNameList ~= nil and #neutralStationDestroyedNameList > 0 then
		stat_message = stat_message .. #neutralStationDestroyedNameList
		station_strength = 0
		for i=1,#neutralStationDestroyedNameList do
			if neutralStationDestroyedValue[i] ~= nil then
				station_strength = station_strength + neutralStationDestroyedValue[i]
			else
				print("station:",neutralStationDestroyedNameList[i],"has a nil value in neutral station destroyed value list")
			end
		end
		stat_message = stat_message .. string.format(_("msgMainscreen"," (total strength: %i)"),station_strength)
	else
		stat_message = stat_message .. _("msgMainscreen","none")
	end
	stat_message = stat_message .. _("msgMainscreen","\nKraylor vessels destroyed: ")
	if #kraylorVesselDestroyedNameList ~= nil and #kraylorVesselDestroyedNameList > 0 then
		stat_message = stat_message .. #kraylorVesselDestroyedNameList
		station_strength = 0
		for i=1,#kraylorVesselDestroyedNameList do
			if kraylorVesselDestroyedValue[i] ~= nil then
				station_strength = station_strength + kraylorVesselDestroyedValue[i]
			else
				print("vessel:",kraylorVesselDestroyedNameList[i]," has nil value in kraylor vessel destroyed value list")
			end
		end
		stat_message = stat_message .. string.format(_("msgMainscreen"," (total strength: %i)"),station_strength)
	else
		stat_message = stat_message .. _("msgMainscreen","none")
	end
	stat_message = stat_message .. _("msgMainscreen","\nExuari vessels destroyed: ")
	if #exuariVesselDestroyedNameList ~= nil and #exuariVesselDestroyedNameList > 0 then
		stat_message = stat_message .. #exuariVesselDestroyedNameList
		station_strength = 0
		for i=1,#exuariVesselDestroyedNameList do
			if exuariVesselDestroyedValue[i] ~= nil then
				station_strength = station_strength + exuariVesselDestroyedValue[i]
			else
				print("vessel:",exuariVesselDestroyedNameList[i]," has nil value in exuari vessel destroyed value list")
			end
		end
		stat_message = stat_message .. string.format(_("msgMainscreen"," (total strength: %i)"),station_strength)
	else
		stat_message = stat_message .. _("msgMainscreen","none")
	end
	stat_message = stat_message .. _("msgMainscreen","\nArlenian vessels destroyed: ")
	if #arlenianVesselDestroyedNameList ~= nil and #arlenianVesselDestroyedNameList > 0 then
		stat_message = stat_message .. #arlenianVesselDestroyedNameList
		station_strength = 0
		for i=1,#arlenianVesselDestroyedNameList do
			if arlenianVesselDestroyedValue[i] ~= nil then
				station_strength = station_strength + arlenianVesselDestroyedValue[i]
			else
				print("vessel:",arlenianVesselDestroyedNameList[i]," has nil value in arlenian vessel destroyed value list")
			end
		end
		stat_message = stat_message .. string.format(_("msgMainscreen"," (total strength: %i)"),station_strength)
	else
		stat_message = stat_message .. _("msgMainscreen","none")
	end
	stat_message = stat_message .. string.format(_("msgMainscreen","\nMissions completed: %i"),mission_complete_count)
--	optional_missions[comms_source:getCallSign()] = optional_missions[comms_source:getCallSign()] + 1
	local opt_msg = ""
	for player,count in pairs(optional_missions) do
		if count ~= nil and count > 0 then
			if opt_msg == "" then
				opt_msg = string.format(_("msgMainscreen","Optional missions completed: %s:%i"),player,count)
			else
				opt_msg = string.format(_("msgMainscreen","%s, %s:%i"),opt_msg,player,count)
			end
		end
	end
	if opt_msg ~= "" then
		stat_message = string.format(_("msgMainscreen","%s\n%s"),stat_message,opt_msg)
	end
	if reason ~= nil then
		stat_message = stat_message .. "\n" .. reason
	end
	globalMessage(stat_message)
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
    local temp = array[selected_item]
    array[selected_item] = array[array_item_count]
    array[array_item_count] = temp
    return table.remove(array)
end
function setPlayers()
	for i,pobj in ipairs(getActivePlayerShips()) do
		if pobj.initialRep == nil then
			pobj:addReputationPoints(200-(difficulty*40))
			pobj.initialRep = true
		end
		if not pobj.nameAssigned then
			pobj.nameAssigned = true
			local tempPlayerType = pobj:getTypeName()
			if i % 2 == 0 then
				pobj:setPosition(playerSpawn1X,playerSpawn1Y)
			else
				pobj:setPosition(playerSpawn2X,playerSpawn2Y)
			end
			local ship_name = tableRemoveRandom(playerShipNamesFor[tempPlayerType])
			if ship_name == nil then
				ship_name = tableRemoveRandom(playerShipNamesFor["Leftovers"])
			end
			if ship_name ~= nil then
				pobj:setCallSign(ship_name)
			end
			if optional_missions == nil then
				optional_missions = {}
			end
			optional_missions[pobj:getCallSign()] = 0
			pobj.maxCargo = player_ship_stats[tempPlayerType].cargo
			pobj.shipScore = player_ship_stats[tempPlayerType].strength
			pobj:setLongRangeRadarRange(player_ship_stats[tempPlayerType].long_range_radar)
			pobj:setShortRangeRadarRange(player_ship_stats[tempPlayerType].short_range_radar)
			if tempPlayerType == "MP52 Hornet" then
				pobj.autoCoolant = false
				pobj:setWarpDrive(true)
			elseif tempPlayerType == "Phobos M3P" then
				pobj:setWarpDrive(true)
			elseif tempPlayerType == "Player Fighter" then
				pobj.autoCoolant = false
				pobj:setJumpDrive(true)
				pobj:setJumpDriveRange(3000,40000)
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
				pobj:setJumpDriveRange(3000,40000)
			elseif tempPlayerType == "ZX-Lindworm" then
				pobj.autoCoolant = false
				pobj:setWarpDrive(true)
			else
				pobj.shipScore = 24
				pobj.maxCargo = 5
				pobj:setWarpDrive(true)
			end
			local playerCallSign = pobj:getCallSign()
			goods[playerCallSign] = {}
			if pobj.cargo == nil then
				pobj.goods = {}
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
function update(delta)
	if delta == 0 then	--game paused
		setPlayers()
		return
	end
	if updateDiagnostic then print("set players") end
	setPlayers()
	if #getActivePlayerShips() < 1 then	--do nothing until player ship is spawned
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
	if updateDiagnostic then print("working transports") end
	workingTransports(delta)
	if updateDiagnostic then print("moving objects") end
	movingObjects(delta)
	cargoInventory()
	healthCheck(delta)
	coolantNebulae(delta)
	handleVoiceQueue(delta)
end

