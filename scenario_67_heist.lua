-- Name: Construction Heist
-- Description: Protect your base and the construction ship as it builds new bases
---
-- Type: Mission
-- Variation[Easy]: Easy goals and/or enemies
-- Variation[Hard]: Hard goals and/or enemies

require("utils.lua")

function init()
	setVariations()
	player_spawn_x = 350000
	player_spawn_y = 350000
	spawnPlayerShip()
	prefix_length = 0
	suffix_index = 0
	--Ship Template Name List
	stnl = {"MT52 Hornet","MU52 Hornet","Adder MK5","Adder MK4","WX-Lindworm","Adder MK6","Phobos T3","Phobos M3","Piranha F8","Piranha F12","Ranus U","Nirvana R5A","Stalker Q7","Stalker R7","Atlantis X23","Starhammer II","Odin","Fighter","Cruiser","Missile Cruiser","Strikeship","Adv. Striker","Dreadnought","Battlestation","Blockade Runner","Ktlitan Fighter","Ktlitan Breaker","Ktlitan Worker","Ktlitan Drone","Ktlitan Feeder","Ktlitan Scout","Ktlitan Destroyer","Storm"}
	--Ship Template Score List
	stsl = {5            ,5            ,7          ,6          ,7            ,8          ,15         ,16         ,15          ,15           ,25       ,20           ,25          ,25          ,50            ,70             ,250   ,6        ,18       ,14               ,30          ,27            ,80           ,100            ,65               ,6                ,45               ,40              ,4              ,48              ,8              ,50                 ,22}
	-- square grid deployment
	fleetPosDelta1x = {0,1,0,-1, 0,1,-1, 1,-1,2,0,-2, 0,2,-2, 2,-2,2, 2,-2,-2,1,-1, 1,-1,0, 0,3,-3,1, 1,3,-3,-1,-1, 3,-3,2, 2,3,-3,-2,-2, 3,-3,3, 3,-3,-3,4,0,-4, 0,4,-4, 4,-4,-4,-4,-4,-4,-4,-4,4, 4,4, 4,4, 4, 1,-1, 2,-2, 3,-3,1,-1,2,-2,3,-3,5,-5,0, 0,5, 5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,5, 5,5, 5,5, 5,5, 5, 1,-1, 2,-2, 3,-3, 4,-4,1,-1,2,-2,3,-3,4,-4}
	fleetPosDelta1y = {0,0,1, 0,-1,1,-1,-1, 1,0,2, 0,-2,2,-2,-2, 2,1,-1, 1,-1,2, 2,-2,-2,3,-3,0, 0,3,-3,1, 1, 3,-3,-1,-1,3,-3,2, 2, 3,-3,-2,-2,3,-3, 3,-3,0,4, 0,-4,4,-4,-4, 4, 1,-1, 2,-2, 3,-3,1,-1,2,-2,3,-3,-4,-4,-4,-4,-4,-4,4, 4,4, 4,4, 4,0, 0,5,-5,5,-5, 5,-5, 1,-1, 2,-2, 3,-3, 4,-4,1,-1,2,-2,3,-3,4,-4,-5,-5,-5,-5,-5,-5,-5,-5,5, 5,5, 5,5, 5,5, 5}
	-- rough hexagonal deployment
	fleetPosDelta2x = {0,2,-2,1,-1, 1,-1,4,-4,0, 0,2,-2,-2, 2,3,-3, 3,-3,6,-6,1,-1, 1,-1,3,-3, 3,-3,4,-4, 4,-4,5,-5, 5,-5,8,-8,4,-4, 4,-4,5,5 ,-5,-5,2, 2,-2,-2,0, 0,6, 6,-6,-6,7, 7,-7,-7,10,-10,5, 5,-5,-5,6, 6,-6,-6,7, 7,-7,-7,8, 8,-8,-8,9, 9,-9,-9,3, 3,-3,-3,1, 1,-1,-1,12,-12,6,-6, 6,-6,7,-7, 7,-7,8,-8, 8,-8,9,-9, 9,-9,10,-10,10,-10,11,-11,11,-11,4,-4, 4,-4,2,-2, 2,-2,0, 0}
	fleetPosDelta2y = {0,0, 0,1, 1,-1,-1,0, 0,2,-2,2,-2, 2,-2,1,-1,-1, 1,0, 0,3, 3,-3,-3,3,-3,-3, 3,2,-2,-2, 2,1,-1,-1, 1,0, 0,4,-4,-4, 4,3,-3, 3,-3,4,-4, 4,-4,4,-4,2,-2, 2,-2,1,-1, 1,-1, 0,  0,5,-5, 5,-5,4,-4, 4,-4,3,-3, 3,-7,2,-2, 2,-2,1,-1, 1,-1,5,-5, 5,-5,5,-5, 5,-5, 0,  0,6, 6,-6,-6,5, 5,-5,-5,4, 4,-4,-4,3, 3,-3,-3, 2,  2,-2, -2, 1,  1,-1, -1,6, 6,-6,-6,6, 6,-6,-6,6,-6}
	asteroid_angle = random(0,360)
	asteroid_distance = random(28000,33000)
	createRandomAlongArc(Asteroid, 100, player_spawn_x, player_spawn_y, asteroid_distance, asteroid_angle, asteroid_angle+90, 3000)
	local sbx, sby = vectorFromAngle(asteroid_angle+270, random(3000,5000))
	home_station = SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setPosition(player_spawn_x+sbx,player_spawn_y+sby):setCallSign("Kryptain")
	sbx, sby = vectorFromAngle(asteroid_angle+10,asteroid_distance)
	mining_station = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setPosition(player_spawn_x+sbx,player_spawn_y+sby):setCallSign("Exhain")
	sbx, sby = vectorFromAngle(asteroid_angle+random(75,80), asteroid_distance+2000)
	Nebula():setPosition(player_spawn_x+sbx,player_spawn_y+sby)
	placeRandomAroundPoint(Nebula,5,5000,60000,player_spawn_x+sbx,player_spawn_y+sby)
	pirate_station = SpaceStation():setTemplate("Large Station"):setFaction("Exuari"):setPosition(player_spawn_x+sbx,player_spawn_y+sby):setCallSign("Agutrot")
	pirate_station_x, pirate_station_y = pirate_station:getPosition()
	pirate_station:setShieldsMax(500,500,500)					
	pirate_station:setHullMax(300)						
	construct_angle_1 = random(asteroid_angle+270+45,asteroid_angle+270+45+270)
	sbx, sby = vectorFromAngle(construct_angle_1,random(6000,8000))
	construct_site_1_x = player_spawn_x+sbx
	construct_site_1_y = player_spawn_y+sby
	construction_zone = Zone():setColor(254,242,10)
	construction_zone:setPoints(construct_site_1_x+250,construct_site_1_y+250,
								construct_site_1_x-250,construct_site_1_y+250,
								construct_site_1_x-250,construct_site_1_y-250,
								construct_site_1_x+250,construct_site_1_y-250)
	local mid_angle = (asteroid_angle+270+45 + asteroid_angle+270+45+270)/2
	if construct_angle_1 > mid_angle then
		construct_angle_2 = construct_angle_1 - random(60,90)
	else
		construct_angle_2 = construct_angle_1 + random(60,90)
	end
	sbx, sby = vectorFromAngle(construct_angle_2,random(12000,18000))
	construct_site_2_x = player_spawn_x+sbx
	construct_site_2_y = player_spawn_y+sby
	--temp_station1 = SpaceStation():setTemplate("Huge Station"):setFaction("Kraylor"):setPosition(construct_site_1_x,construct_site_1_y)
	--temp_station2 = SpaceStation():setTemplate("Huge Station"):setFaction("Exuari"):setPosition(construct_site_2_x,construct_site_2_y)
	sbx, sby = mining_station:getPosition()
	freighterOne = CpuShip():setFaction("Independent"):setTemplate("Equipment Freighter 3"):setPosition((sbx+construct_site_1_x)/2,(sby+construct_site_1_y)/2):setCallSign("Exhain Dispatch")
	freighterOne:setImpulseMaxSpeed(freighterOne:getImpulseMaxSpeed()*1.5)
	freighterOne:orderDock(mining_station)
	freighterOne.materials = 0
	freighterOne.construction_site = 0
	plotConstructionFreighter = freighterTrackDock1
	plotMessage = constructionOrders
	construction_order_timer = 10
	plotPirateHaven = checkPirateHaven
end
function setVariations()
	if string.find(getScenarioVariation(),"Easy") then
		difficulty = .5
	elseif string.find(getScenarioVariation(),"Hard") then
		difficulty = 2
	else
		difficulty = 1		--default (normal)
	end
	if string.find(getScenarioVariation(),"Timed") then
		playWithTimeLimit = true
		gameTimeLimit = defaultGameTimeLimitInMinutes*60		
		plot2 = timedGame
	else
		gameTimeLimit = 0
		playWithTimeLimit = false
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
	local arcLen = endArcClockwise - startArc
	if startArc > endArcClockwise then
		endArcClockwise = endArcClockwise + 360
		arcLen = arcLen + 360
	end
	if amount > arcLen then
		for ndex=1,arcLen do
			local radialPoint = startArc+ndex
			local pointDist = distance + random(-randomize,randomize)
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
function spawnPlayerShip()
	excelsior = PlayerSpaceship():setTemplate("MP52 Hornet")
	excelsior:setPosition(player_spawn_x,player_spawn_y)
	excelsior:setTypeName("M77 Hornet"):setCallSign("Excelsior")
	excelsior:setRepairCrewCount(2)							--more repair crew (vs 1)
	excelsior:setHullMax(100)								--stronger hull (vs 70)
	excelsior:setHull(100)							
	excelsior:setShieldsMax(70)								--stronger shield (vs 60)
	excelsior:setShields(70)
	excelsior:setMaxEnergy(500)								--more energy (vs 400)
	excelsior:setEnergy(500)
	excelsior:setBeamWeapon(0, 60, 15,  900.0, 4.0, 2.5)	--beams no longer overlap
	excelsior:setBeamWeapon(1, 60,-15,  900.0, 4.0, 2.5)
	excelsior:setBeamWeapon(2, 18,  0, 1100.0, 3.0, 3.0)	--3rd beam added with longer range and stronger damage
	excelsior:setWeaponTubeCount(2)							--more tubes (vs 0)
	excelsior:setWeaponTubeDirection(0,-110)
	excelsior:setWeaponTubeDirection(1,110)
	excelsior:weaponTubeDisallowMissle(0,"Nuke")
	excelsior:weaponTubeDisallowMissle(0,"EMP")
	excelsior:weaponTubeDisallowMissle(1,"Nuke")
	excelsior:weaponTubeDisallowMissle(1,"EMP")
	excelsior:setWeaponStorageMax("HVLI",8)
	excelsior:setWeaponStorage("HVLI",8)
	excelsior:setWeaponStorageMax("Homing",4)
	excelsior:setWeaponStorage("Homing",4)
end
--pirate haven destruction
function checkPirateHaven(delta)
	if not pirate_station:isValid() then
		crown_artifact = Artifact():setPosition(pirate_station_x,pirate_station_y):setDescriptions("Shiny object","Kaspar's Crown"):setScanningParameters(2,2):allowPickup(true):onPickUp(artifactGrab)
		crown_artifact:setModel("artifact5")
		excelsior:addToShipLog(string.format("[Kryptain] Get Kaspar's crown that was left behind, then return and dock with %s",home_station:getCallSign()),"Magenta")
		plotPirateHaven = checkDockWithArtifact
	end
end
function checkDockWithArtifact(delta)
	if excelsior:isDocked(home_station) then
		if constructed_station_1 ~= nil then
			if constructed_station_2 ~= nil then
				if not pirate_station:isValid() then
					if crown_artifact ~= nil then
						if not crown_artifact:isValid() then
							globalMessage("Stations built and crown recovered")
							victory("Human Navy")
						end
					end
				end
			end
		end
	end
end
function artifactGrab(art, p)
	string.format("")
	p:addToShipLog("[Kryptain] Artifact retrieved. Come back and dock with us","Magenta")
end
--station construction freighter functions
function constructionProgress(p,delivery,site)
	string.format("")
	p:addToShipLog(string.format("[Exhain Dispatch] I have completed delivery number %i for construction site %i. Retrieving materials for the next run now", delivery, site),"Magenta")
end
function freighterTrackDock1(delta)
	checkFreighter()
	checkMiningStation()
	if freighterOne:isDocked(mining_station) then
		freighterOne.materials = freighterOne.materials + 1
		freighterOne:orderFlyTowards(construct_site_1_x,construct_site_1_y)
		plotConstructionFreighter = freighterTrackConstruction1
		freighterOne:setImpulseMaxSpeed(freighterOne:getImpulseMaxSpeed()+5)
	end
end
function freighterTrackConstruction1(delta)
	checkFreighter()
	if distance(freighterOne,construct_site_1_x,construct_site_1_y) < 500 then
		freighterOne.construction_site = freighterOne.construction_site + 1
		constructionProgress(excelsior, freighterOne.construction_site, 1)
		--print("before:",freighterOne:getImpulseMaxSpeed())
		freighterOne:setImpulseMaxSpeed(freighterOne:getImpulseMaxSpeed()+5)
		--print("after:",freighterOne:getImpulseMaxSpeed())
		if freighterOne.construction_site >= 3 then	--final value is 3
			constructed_station_1 = SpaceStation():setTemplate("Medium Station"):setFaction("TSN"):setPosition(construct_site_1_x,construct_site_1_y):setCallSign("Fluotis")
			excelsior:addToShipLog(string.format("[Exhain Dispatch] First construction mission completed. %s built",constructed_station_1:getCallSign()),"Magenta")
			excelsior:addToShipLog(string.format("[%s] Thank you for protecting the Exhain Dispatch as it carried out the construction of this station. As a reward for your efforts, dock with us and we will present you with a new impulse engine.",constructed_station_1:getCallSign()),"Magenta")
			freighterOne:orderDock(mining_station)
			freighterOne.materials = 0
			freighterOne.construction_site = 0
			plotConstructionFreighter = freighterTrackDock2
			--construction_zone = Zone():setColor(254,242,10)
			construction_zone:setPoints(construct_site_2_x+250,construct_site_2_y+250,
										construct_site_2_x-250,construct_site_2_y+250,
										construct_site_2_x-250,construct_site_2_y-250,
										construct_site_2_x+250,construct_site_2_y-250)
		else
			freighterOne:orderDock(mining_station)
			plotConstructionFreighter = freighterTrackDock1
		end
	end
end
function freighterTrackDock2(delta)
	checkFreighter()
	checkMiningStation()
	if freighterOne:isDocked(mining_station) then
		freighterOne.materials = freighterOne.materials + 1
		freighterOne:orderFlyTowards(construct_site_2_x,construct_site_2_y)
		plotConstructionFreighter = freighterTrackConstruction2
		freighterOne:setImpulseMaxSpeed(freighterOne:getImpulseMaxSpeed()+5)
	end
end
function freighterTrackConstruction2(delta)
	checkFreighter()
	if distance(freighterOne,construct_site_2_x,construct_site_2_y) < 500 then
		freighterOne.construction_site = freighterOne.construction_site + 1
		constructionProgress(excelsior, freighterOne.construction_site, 2)
		freighterOne:setImpulseMaxSpeed(freighterOne:getImpulseMaxSpeed()+5)
		if freighterOne.construction_site >= 3 then	--final value is 3
			constructed_station_2 = SpaceStation():setTemplate("Medium Station"):setFaction("USN"):setPosition(construct_site_2_x,construct_site_2_y):setCallSign("Dephgol")
			excelsior:addToShipLog(string.format("[Exhain Dispatch] Second construction mission completed. %s built",constructed_station_2:getCallSign()),"Magenta")
			excelsior:addToShipLog(string.format("[%s] Thank you for protecting the Exhain Dispatch as it carried out the construction of this station. As a reward for your efforts, dock with us and we will present you with enhanced weaponry.",constructed_station_2:getCallSign()),"Magenta")
			excelsior:addToShipLog("[Kryptain] Come dock with us. We have new orders for you.","Magenta")
			freighterOne:orderDefendTarget(constructed_station_2)
			plotConstructionFreighter = nil
			construction_zone:destroy()
		else
			freighterOne:orderDock(mining_station)
			plotConstructionFreighter = freighterTrackDock2
		end
	end
end
function checkFreighter()
	if freighterOne == nil then
		globalMessage("Construction freighter destroyed")
		victory("Exuari")
	else
		if not freighterOne:isValid() then
			globalMessage("Construction freighter destroyed")
			victory("Exuari")
		end
	end
end
function checkMiningStation()
	if mining_station == nil then
		globalMessage("Mining station with construction resources destroyed")
		victory("Exuari")
	else
		if not mining_station:isValid() then
			globalMessage("Mining station with construction resources destroyed")
			victory("Exuari")
		end
	end
end
--messages
function constructionOrders(delta)
	construction_order_timer = construction_order_timer - delta
	if construction_order_timer < 0 then
		excelsior:addToShipLog(string.format("[Kryptain] Protect freighter %s as it conducts construction operations",freighterOne:getCallSign()),"Magenta")
		plotMessage = destructionOrders
		plotPirate = pirateWave
		pirate_wave_danger =  1.2
		pirate_wave_counter = 0
		pirate_wave_danger_direction = 1
	end
end
function destructionOrders(delta)
	if constructed_station_1 ~= nil then
		local send_destruction_message = false
		if excelsior:isDocked(home_station) then
			send_destruction_message = true
		end
		if excelsior:isDocked(constructed_station_1) then
			send_destruction_message = true
		end
		if constructed_station_2 ~= nil then
			if excelsior:isDocked(constructed_station_2) then
				send_destruction_message = true
			end
		end
		if send_destruction_message then
			excelsior:addToShipLog("[Kryptain] Find and destroy the pirate haven. They've stolen Prince Kaspar's crown, an heirloom that has been in our possession for centuries (I will spare you the details). Recover the crown from the station wreckage","Magenta")
			plotMessage = nil
		end
	end
end
--continuous pirate wave generation
function pirateWave(delta)
	if enemy_list == nil then
		local px, py = pirate_station:getPosition()
		enemy_list = spawnEnemies(px+1000,py+1000,pirate_wave_danger,"Exuari")
		--choices: fly to player, attack player, fly to player base, attack player base, fly to freighter, attack freighter
		local order_choice = math.random(1,6)
		for _, enemy in ipairs(enemy_list) do
			if order_choice == 1 then
				px, py = excelsior:getPosition()
				enemy:orderFlyTowards(px,py)
			elseif order_choice == 2 then
				enemy:orderAttack(excelsior)
			elseif order_choice == 3 then
				px, py = home_station:getPosition()
				enemy:orderFlyTowards(px,py)
			elseif order_choice == 4 then
				enemy:orderAttack(home_station)
			elseif order_choice == 5 then
				px, py = freighterOne:getPosition()
				enemy:orderFlyTowards(px,py)
			else
				enemy:orderAttack(freighterOne)
			end
		end
		plotPirate = monitorPirateWave
		--excelsior:addToShipLog(string.format("danger level: %f",pirate_wave_danger),"Magenta")	--temp for debug
	end
end
function monitorPirateWave(delta)
	local enemies_remaining = 0
	for _, enemy in ipairs(enemy_list) do
		if enemy ~= nil and enemy:isValid() then
			enemies_remaining = enemies_remaining + 1
		end
	end
	if enemies_remaining < 1 then
		plotPirate = pirateWave
		enemy_list = nil
		pirate_wave_counter = pirate_wave_counter + 1
		if pirate_wave_danger_direction > 0 then
			if pirate_wave_counter < 5 then
				pirate_wave_danger = pirate_wave_danger + .2
			else
				pirate_wave_counter = 0
				pirate_wave_danger_direction = -1
				pirate_wave_danger = pirate_wave_danger - .2
			end
		else
			if pirate_wave_counter < 4 then
				pirate_wave_danger = pirate_wave_danger - .2
			else
				pirate_wave_counter = 0
				pirate_wave_danger_direction = 1
				pirate_wave_danger = pirate_wave_danger + .2
			end
		end
	end
end
--enemy spawn functions relative to player strength
function spawnEnemies(xOrigin, yOrigin, danger, enemyFaction, enemyStrength)
	if enemyFaction == nil then
		enemyFaction = "Kraylor"
	end
	if danger == nil then 
		danger = 1
	end
	if enemyStrength == nil then
		enemyStrength = math.max(danger * difficulty * playerPower(),5)
	end
	local enemyPosition = 0
	local sp = irandom(400,900)			--random spacing of spawned group
	local deployConfig = random(1,100)	--randomly choose between squarish formation and hexagonish formation
	local enemyList = {}
	local prefix = generateCallSignPrefix(1)
	-- Reminder: stsl and stnl are ship template score and name list
	while enemyStrength > 0 do
		local shipTemplateType = irandom(1,#stsl)
		while stsl[shipTemplateType] > enemyStrength * 1.1 + 5 do
			shipTemplateType = irandom(1,#stsl)
		end		
		local ship = CpuShip():setFaction(enemyFaction):setTemplate(stnl[shipTemplateType]):orderRoaming()
		enemyPosition = enemyPosition + 1
		if deployConfig < 50 then
			ship:setPosition(xOrigin+fleetPosDelta1x[enemyPosition]*sp,yOrigin+fleetPosDelta1y[enemyPosition]*sp)
		else
			ship:setPosition(xOrigin+fleetPosDelta2x[enemyPosition]*sp,yOrigin+fleetPosDelta2y[enemyPosition]*sp)
		end
		--ship:setCommsScript(""):setCommsFunction(commsShip)
		table.insert(enemyList, ship)
		ship:setCallSign(generateCallSign(prefix))
		enemyStrength = enemyStrength - stsl[shipTemplateType]
	end
	return enemyList
end
function playerPower()
	return 11
end
--		Generate call sign functions
function generateCallSign(prefix)
	if prefix == nil then
		prefix = generateCallSignPrefix()
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
function plotImpulseUpgrade(delta)
	if constructed_station_1 ~= nil and excelsior:isDocked(constructed_station_1) and excelsior.impulse_upgrade == nil then
		excelsior:setImpulseMaxSpeed(160)
		excelsior:addToShipLog(string.format("[%s] Impulse engine upgraded.",constructed_station_1:getCallSign()),"Magenta")
		excelsior.impulse_upgrade = "done"
	end
end
function plotWeaponUpgrade(delta)
	if constructed_station_2 ~= nil and excelsior:isDocked(constructed_station_2) and excelsior.weapon_upgrade == nil then
		excelsior:setWeaponTubeCount(3)
		excelsior:setWeaponStorageMax("Homing",9)
		excelsior:setWeaponStorage("Homing",9)
		excelsior:addToShipLog(string.format("[%s] Weapon tube and homing storage added.",constructed_station_2:getCallSign()),"Magenta")
		excelsior.weapon_upgrade = "done"
	end
end
function update(delta)
	if plotConstructionFreighter ~= nil then
		plotConstructionFreighter(delta)
	end
	if plotMessage ~= nil then
		plotMessage(delta)
	end
	if plotPirate ~= nil then
		plotPirate(delta)
	end
	if plotPirateHaven ~= nil then
		plotPirateHaven(delta)
	end
	if plotImpulseUpgrade ~= nil then
		plotImpulseUpgrade(delta)
	end
	if plotWeaponUpgrade ~= nil then
		plotWeaponUpgrade(delta)
	end
end