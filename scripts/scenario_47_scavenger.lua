-- Name: Scurvy Scavenger
-- Description: Stay alive while scavenging treasures. Length: > 2 hours
---
--- Version 0
-- Type: Single player ship mission, moderately replayable
-- Variation[Easy]: Easy goals and/or enemies
-- Variation[Hard]: Hard goals and/or enemies

require("utils.lua")
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
function init()
--	print("start of init")
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
	populateStationPool()
	--stationCommunication could be nil (default), commsStation (embedded function) or comms_station_enhanced (external script)
	stationCommunication = "commsStation"
	stationStaticAsteroids = true
	primaryOrders = "No primary orders"
	plot1 = exuariHarassment
	plot1_mission_count = 0
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
	local pStation = placeStation(psx,psy,nil,"Independent")
	table.insert(independent_station,pStation)
	table.insert(station_list,pStation)
	first_station = pStation
	first_station.comms_data.weapon_available.Homing = true
	first_station.comms_data.weapon_available.EMP = true
	first_station.comms_data.weapon_available.Nuke = true
	first_station.comms_data.weapon_cost = {Homing = 2, HV, HVLI = math.random(1,3), Mine = math.random(2,5), Nuke = 12, EMP = 9}
	local fsx = psx
	local fsy = psy
--	print("init: place first enemy station")
	--place first enemy station for first mission 
	exuari_station = {}
	local exuari_station_angle = first_station_angle + random(-20,20)
	local enemy_station_distance = random(11000,15000)
	cnx, cny = vectorFromAngle(exuari_station_angle,enemy_station_distance-2500)
	concealing_nebula = Nebula():setPosition(fsx+cnx,fsy+cny)
	nebula_list = {}
	table.insert(nebula_list,concealing_nebula)
	for i=1,math.random(2,2+difficulty*2) do
		local ref_x, ref_y = nebula_list[#nebula_list]:getPosition()
		local far_enough = true
		local expand_distance = 0
		local new_x, new_y = vectorFromAngle(random(0,360),random(4000,20000+expand_distance))
		repeat
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
	psx = psx + fsx
	psy = psy + fsy
	pStation = placeStation(psx,psy,"Sinister","Exuari","Large Station")
	table.insert(exuari_station,pStation)
	table.insert(station_list,pStation)
	exuari_harassing_station = pStation
	evx, evy = vectorFromAngle(exuari_station_angle,20000)
	evx = evx + psx
	evy = evy + psy
	ev_angle = (exuari_station_angle + 180) % 360	--exuari vengeance attack angle
--	print("init: place research asteroids")
	local arx, ary, brx, bry, asteroids = curvaceousAsteroids1(fsx, fsy, player_to_station_distance)
	research_asteroids = asteroids
	--place artifact near asteroids
	local avx, avy = vectorFromAngle(random(0,360),350-(difficulty*100))
	beam_damage_artifact = Artifact():setPosition(arx+avx,ary+avy):setModel("artifact4"):setScanningParameters(difficulty*2,difficulty*2):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1))
	beam_damage_artifact:setDescriptions("Object of unknown origin","Object of unknown origin, advanced technology detected"):allowPickup(true):onPickUp(beamDamageArtifactPickup)
	avx, avy = vectorFromAngle(random(0,360),350-(difficulty*100))
	burn_out_artifact = Artifact():setPosition(brx+avx,bry+avy):setModel("artifact4"):setScanningParameters(difficulty*2,difficulty*2):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1))
	burn_out_artifact:setDescriptions("Object of unknown origin","Object of unknown origin, advanced technology detected"):allowPickup(true):onPickUp(burnOutArtifactPickup)
	if difficulty >= 1 then
		avx, avy = vectorFromAngle(random(0,360),350-(difficulty*100))
		burn_out_artifact_2 = Artifact():setPosition(crx+avx,cry+avy):setModel("artifact4"):setScanningParameters(difficulty*2,difficulty*2):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1))
		burn_out_artifact_2:setDescriptions("Object of unknown origin","Object of unknown origin, advanced technology detected"):allowPickup(true):onPickUp(burnOutArtifactPickup)
	end
	if difficulty > 1 then
		avx, avy = vectorFromAngle(random(0,360),350-(difficulty*100))
		burn_out_artifact_3 = Artifact():setPosition(drx+avx,dry+avy):setModel("artifact4"):setScanningParameters(difficulty*2,difficulty*2):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1))
		burn_out_artifact_3:setDescriptions("Object of unknown origin","Object of unknown origin, advanced technology detected"):allowPickup(true):onPickUp(burnOutArtifactPickup)
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
	initialGMButtons()
--	print("end of init")
	allowNewPlayerShips(false)
end
function setInitialContractDetails()
	--contract details: first to second station
	first_station.comms_data.contract = {}
	first_station.comms_data.contract["one_to_two"] = {
		type = "start",
		prompt = string.format("Deliver three %s to %s. Upon delivery, they will increase your hull strength",independent_station[2].comms_data.characterGood,independent_station[2]:getCallSign()), 
		short_prompt = string.format("Three %s to %s",independent_station[2].comms_data.characterGood,independent_station[2]:getCallSign()),
		accepted = false,
		func = start1to2delivery,
	}
	independent_station[2].comms_data.contract = {}
	independent_station[2].comms_data.contract["one_to_two"] = {
		type = "fulfill",
		prompt = string.format("Fulfill %s 3 %s %s contract",first_station:getCallSign(),independent_station[2].comms_data.characterGood,independent_station[2]:getCallSign()),
		short_prompt = string.format("Three %s from %s",independent_station[2].comms_data.characterGood,first_station:getCallSign()),
		fulfilled = false,
		func = complete1to2delivery,
	}
	--contract details: second to third station
	independent_station[2].comms_data.contract["two_to_three"] = {
		type = "start",
		prompt = string.format("Deliver two %s to %s. Upon delivery, they will increase your shield strength",independent_station[3].comms_data.characterGood,independent_station[3]:getCallSign()),
		short_prompt = string.format("Two %s to %s",independent_station[3].comms_data.characterGood,independent_station[3]:getCallSign()),
		accepted = false,
		func = start2to3delivery,
	}
	independent_station[3].comms_data.contract = {}
	independent_station[3].comms_data.contract["two_to_three"] = {
		type = "fulfill",
		prompt = string.format("Fulfill %s 2 %s %s contract",independent_station[2]:getCallSign(),independent_station[3].comms_data.characterGood,independent_station[3]:getCallSign()),
		short_prompt = string.format("Two %s from %s",independent_station[3].comms_data.characterGood,independent_station[2]:getCallSign()),
		fulfilled = false,
		func = complete2to3delivery,
	}
end
function initialGMButtons()
	clearGMFunctions()
	addGMFunction("+Missions",missionSelection)
	addGMFunction("Show delta sum",function()
		local gm_message = "Accumulated delta:\n" .. accumulated_delta
		local seconds = math.floor(accumulated_delta % 60)
		if accumulated_delta > 60 then
			local minutes = math.floor(accumulated_delta / 60)
			if minutes > 60 then
				local hours = math.floor(minutes / 60)
				gm_message = gm_message .. string.format("\n%i:%.2i:%.2i",hours,minutes,seconds)
			else
				gm_message = gm_message .. string.format("\n%i:%.2i",minutes,seconds)
			end
		end
		addGMMessage(gm_message)
	end)
end
function missionSelection()
	clearGMFunctions()
	addGMFunction("-Main from missions",initialGMButtons)
	if plot1 ~= nil and plot1 ~= kraylorDiversionarySabotage then
		addGMFunction("Skip Harassment",function()
			player = getPlayerShip(-1)
			impulseUpgrade(player)
			missileTubeUpgrade(player)
			doubleBeamDamageUpgrade(player)
			jumpDriveUpgrade(player)
			player:addReputationPoints(200)
			plot1 = nil
			plot1_type = nil
			plot1_mission_count = plot1_mission_count + 1
			plot1_timer = nil
			plot1_defensive_timer = nil
			plot1_danger = nil
			plot1_fleet_spawned = nil
			plot1_defensive_fleet_spawned = nil
			exuari_harassment_upgrade = true
			plot2 = contractTarget
			addGMMessage("Harassment skipped")
			missionSelection()
		end)
	end
	if plot2 == contractTarget then
		addGMFunction("Skip Local Contracts",function()
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
			player:addToShipLog(string.format("A rare long range contract has been posted at station %s",first_station:getCallSign()),"Magenta")
			transition_contract_message = true
			plot2 = nil
			addGMMessage("Local contracts skipped")
			missionSelection()
		end)
	end
	addGMFunction("Mark asteroids",function()
		for _,asteroid in pairs(research_asteroids) do
			if asteroid.osmium ~= nil and asteroid.iridium ~= nil then
				local ax, ay = asteroid:getPosition()
				local d = 250
				Zone():setPoints(ax-d,ay-d,ax+d,ay-d,ax+d,ay+d,ax-d,ay+d):setColor(128,0,0)
			end
		end
	end)
end
------------------------------------------------------
--	Contract for increased hull strength functions  --
------------------------------------------------------
function start1to2delivery()
	if independent_station[2] ~= nil and independent_station[2]:isValid() then
		if comms_source.cargo < 3 then
			setCommsMessage(string.format("Your available cargo space, %i, is insufficient for this contract. You need at least 3",comms_source.cargo))
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
			setCommsMessage(string.format("Cargo of three %s has been loaded onto your ship. Deliver to %s in %s",good,independent_station[2]:getCallSign(),independent_station[2]:getSectorName()))
			first_station.comms_data.contract["one_to_two"].accepted = true
			table.insert(contract_station,independent_station[2])
		end
	else
		setCommsMessage(string.format("This contract is no longer valid since the destination, %s, no longer exists. Sorry for the clerical error. Have a nice day",independent_station[2]:getCallSign()))
		first_station.comms_data.contract["one_to_two"].accepted = true
	end
	addCommsReply("Back",commsStation)
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
		setCommsMessage(string.format("Thanks for the %s, %s. We increased your hull strength by 50%%",good,comms_source:getCallSign()))
	else
		setCommsMessage(string.format("The terms of the contract require the delivery of three %s. This has not been met",good))
	end
	addCommsReply("Back",commsStation)
end
function start2to3delivery()
	if independent_station[3] ~= nil and independent_station[3]:isValid() then
		if comms_source.cargo < 2 then
			setCommsMessage(string.format("Your available cargo space, %i, is insufficient for this contract. You need at least 3",comms_source.cargo))
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
			setCommsMessage(string.format("Cargo of two %s has been loaded onto your ship. Deliver to %s in %s",good,independent_station[3]:getCallSign(),independent_station[3]:getSectorName()))
			independent_station[2].comms_data.contract["two_to_three"].accepted = true
			table.insert(contract_station,independent_station[3])
		end
	else
		setCommsMessage(string.format("This contract is no longer valid since the destination, %s, no longer exists. Sorry for the clerical error. Have a nice day",independent_station[3]:getCallSign()))
		independent_station[2].comms_data.contract["two_to_three"].accepted = true
	end
	addCommsReply("Back",commsStation)
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
		setCommsMessage(string.format("Thanks for the %s, %s. We increased your shield strength by 25%%",good,comms_source:getCallSign()))
	else
		setCommsMessage(string.format("The terms of the contract require the delivery of two %s. This has not been met",good))
	end
	addCommsReply("Back",commsStation)
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
			unscanned_description = "Structure: solid"
		elseif random(0,100) < 70 then
			unscanned_description = "Structure: rubble"
		else
			unscanned_description = "Structure: binary"
		end
		local scanned_description = ""
		selected_asteroid.composition = 0
		if i == 1 then
			selected_asteroid.osmium = math.random(1,20)/10
			scanned_description = string.format("%sosmium:%.1f%% ",scanned_description,selected_asteroid.osmium)
			selected_asteroid.iridium = math.random(1,70)/10
			scanned_description = string.format("%siridium:%.1f%% ",scanned_description,selected_asteroid.iridium)
			selected_asteroid.olivine = math.random(1,150)/10
			scanned_description = string.format("%solivine:%.1f%% ",scanned_description,selected_asteroid.olivine)
			selected_asteroid.nickel = math.random(1,190)/10
			scanned_description = string.format("%snickel:%.1f%% ",scanned_description,selected_asteroid.nickel)
			scanned_description = string.format("%s, %srock:remainder",unscanned_description, scanned_description)
			target_asteroid = selected_asteroid
			target_asteroid_x, target_asteroid_y = target_asteroid:getPosition()
			print(string.format("Target Asteroid: Sector:%s X:%i Y:%i Osmium:%.1f, Iridium:%.1f, Olivine:%.1f, Nickel:%.1f",target_asteroid:getSectorName(),math.floor(target_asteroid_x),math.floor(target_asteroid_y),target_asteroid.osmium,target_asteroid.iridium,target_asteroid.olivine,target_asteroid.nickel))
		else
			if random(0,100) < 2 and selected_asteroid.composition < 100 then
				selected_asteroid.osmium = math.random(1,20)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.osmium
				scanned_description = string.format("%sosmium:%.1f%% ",scanned_description,selected_asteroid.osmium)
			end
			if random(0,100) < 3 and selected_asteroid.composition < 100 then
				selected_asteroid.ruthenium = math.random(1,30)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.ruthenium
				scanned_description = string.format("%sruthenium:%.1f%% ",scanned_description,selected_asteroid.ruthenium)
			end
			if random(0,100) < 4 and selected_asteroid.composition < 100 then
				selected_asteroid.rhodium = math.random(1,40)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.rhodium
				scanned_description = string.format("%srhodium:%.1f%% ",scanned_description,selected_asteroid.rhodium)
			end
			if random(0,100) < 5 and selected_asteroid.composition < 100 then
				selected_asteroid.magnesium = math.random(1,50)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.magnesium
				scanned_description = string.format("%smagnesium:%.1f%% ",scanned_description,selected_asteroid.magnesium)
			end
			if random(0,100) < 6 and selected_asteroid.composition < 100 then
				selected_asteroid.platinum = math.random(1,60)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.platinum
				scanned_description = string.format("%splatinum:%.1f%% ",scanned_description,selected_asteroid.platinum)
			end
			if random(0,100) < 7 and selected_asteroid.composition < 100 then
				selected_asteroid.iridium = math.random(1,70)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.iridium
				scanned_description = string.format("%siridium:%.1f%% ",scanned_description,selected_asteroid.iridium)
			end
			if random(0,100) < 8 and selected_asteroid.composition < 100 then
				selected_asteroid.gold = math.random(1,80)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.gold
				scanned_description = string.format("%sgold:%.1f%% ",scanned_description,selected_asteroid.gold)
			end
			if random(0,100) < 9 and selected_asteroid.composition < 100 then
				selected_asteroid.palladium = math.random(1,90)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.palladium
				scanned_description = string.format("%spalladium:%.1f%% ",scanned_description,selected_asteroid.palladium)
			end
			if random(0,100) < 10 and selected_asteroid.composition < 100 then
				selected_asteroid.oxygen = math.random(1,100)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.oxygen
				scanned_description = string.format("%soxygen:%.1f%% ",scanned_description,selected_asteroid.oxygen)
			end
			if random(0,100) < 11 and selected_asteroid.composition < 100 then
				selected_asteroid.silicon = math.random(1,110)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.silicon
				scanned_description = string.format("%ssilicon:%.1f%% ",scanned_description,selected_asteroid.silicon)
			end
			if random(0,100) < 12 and selected_asteroid.composition < 100 then
				selected_asteroid.hydrogen = math.random(1,120)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.hydrogen
				scanned_description = string.format("%shydrogen:%.1f%% ",scanned_description,selected_asteroid.hydrogen)
			end
			if random(0,100) < 13 and selected_asteroid.composition < 100 then
				selected_asteroid.nitrogen = math.random(1,130)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.nitrogen
				scanned_description = string.format("%snitrogen:%.1f%% ",scanned_description,selected_asteroid.nitrogen)
			end
			if random(0,100) < 14 and selected_asteroid.composition < 100 then
				selected_asteroid.pyroxene = math.random(1,140)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.pyroxene
				if selected_asteroid.composition >= 100 then
					scanned_description = string.format("%spyroxene:remainder",scanned_description)				
				else
					scanned_description = string.format("%spyroxene:%.1f%% ",scanned_description,selected_asteroid.pyroxene)
				end
			end
			if random(0,100) < 15 and selected_asteroid.composition < 100 then
				selected_asteroid.olivine = math.random(1,150)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.olivine
				if selected_asteroid.composition >= 100 then
					scanned_description = string.format("%solivine:remainder",scanned_description)				
				else
					scanned_description = string.format("%solivine:%.1f%% ",scanned_description,selected_asteroid.olivine)
				end
			end
			if random(0,100) < 16 and selected_asteroid.composition < 100 then
				selected_asteroid.cobalt = math.random(1,160)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.cobalt
				if selected_asteroid.composition >= 100 then
					scanned_description = string.format("%scobalt:remainder",scanned_description)				
				else
					scanned_description = string.format("%scobalt:%.1f%% ",scanned_description,selected_asteroid.cobalt)
				end
			end
			if random(0,100) < 17 and selected_asteroid.composition < 100 then
				selected_asteroid.dilithium = math.random(1,170)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.dilithium
				if selected_asteroid.composition >= 100 then
					scanned_description = string.format("%sdilithium:remainder",scanned_description)				
				else
					scanned_description = string.format("%sdilithium:%.1f%% ",scanned_description,selected_asteroid.dilithium)
				end
			end
			if random(0,100) < 18 and selected_asteroid.composition < 100 then
				selected_asteroid.calcium = math.random(1,180)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.calcium
				if selected_asteroid.composition >= 100 then
					scanned_description = string.format("%scalcium:remainder",scanned_description)				
				else
					scanned_description = string.format("%scalcium:%.1f%% ",scanned_description,selected_asteroid.calcium)
				end
			end
			if random(0,100) < 19 and selected_asteroid.composition < 100 then
				selected_asteroid.nickel = math.random(1,190)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.nickel
				if selected_asteroid.composition >= 100 then
					scanned_description = string.format("%snickel:remainder",scanned_description)				
				else
					scanned_description = string.format("%snickel:%.1f%% ",scanned_description,selected_asteroid.nickel)
				end
			end
			if random(0,100) < 20 and selected_asteroid.composition < 100 then
				selected_asteroid.iron = math.random(1,200)/10
				selected_asteroid.composition = selected_asteroid.composition + selected_asteroid.iron
				if selected_asteroid.composition >= 100 then
					scanned_description = string.format("%siron:remainder",scanned_description)				
				else
					scanned_description = string.format("%siron:%.1f%% ",scanned_description,selected_asteroid.iron)
				end
			end
			if selected_asteroid.composition > 0 then
				if selected_asteroid.composition < 100 then
					scanned_description = string.format("%s, %srock:remainder",unscanned_description, scanned_description)
				end
			else
				scanned_description = string.format("%s, just rock",unscanned_description, scanned_description)			
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
function setPlayer()
	player = getPlayerShip(-1)
	if not player.name_assigned then
		if player:getTypeName() == "Striker" then
			if #playerShipNamesForStriker > 0 then
				local name_index = math.random(1,#playerShipNamesForStriker)
				player:setCallSign(playerShipNamesForStriker[name_index])
				table.remove(playerShipNamesForStriker,name_index)
			end
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
function setVariations()
	local svs = getScenarioVariation()	--scenario variation string
	if string.find(svs,"Easy") then
		difficulty = .5
	elseif string.find(svs,"Hard") then
		difficulty = 2
	else
		difficulty = 1		--default (normal)
	end
	gameTimeLimit = 0
	playWithTimeLimit = false
end
function setConstants()
	repeatExitBoundary = 100
	scarceResources = false
	missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	--Ship Template Name List
	--stnl = {"MT52 Hornet","MU52 Hornet","Adder MK5","Adder MK4","WX-Lindworm","Adder MK6","Phobos T3","Phobos M3","Piranha F8","Piranha F12","Ranus U","Nirvana R5A","Stalker Q7","Stalker R7","Atlantis X23","Starhammer II","Odin","Fighter","Cruiser","Missile Cruiser","Strikeship","Adv. Striker","Dreadnought","Battlestation","Blockade Runner","Ktlitan Fighter","Ktlitan Breaker","Ktlitan Worker","Ktlitan Drone","Ktlitan Feeder","Ktlitan Scout","Ktlitan Destroyer","Storm"}
	--Ship Template Score List
	--stsl = {5            ,5            ,7          ,6          ,7            ,8          ,15         ,16         ,15          ,15           ,25       ,20           ,25          ,25          ,50            ,70             ,250   ,6        ,18       ,14               ,30          ,27            ,80           ,100            ,65               ,6                ,45               ,40              ,4              ,48              ,8              ,50                 ,22}
	--stnl: Ship Template Name List, stsl: Ship Template Score List, stbl: Ship Template Boolean List, nsfl: Non Standard Function List
	stnl = {"Phobos R2","Adder MK8","Adder MK7","Adder MK3","MT52 Hornet","MU52 Hornet","Adder MK5","Adder MK4","WX-Lindworm","Adder MK6","Phobos T3","Phobos M3","Piranha F8","Piranha F12","Ranus U","Nirvana R5A","Stalker Q7","Stalker R7","Atlantis X23","Starhammer II","Odin","Fighter","Cruiser","Missile Cruiser","Strikeship","Adv. Striker","Dreadnought","Battlestation","Blockade Runner","Ktlitan Fighter","Ktlitan Breaker","Ktlitan Worker","Ktlitan Drone","Ktlitan Feeder","Ktlitan Scout","Ktlitan Destroyer","Storm"}
	stsl = {13         ,10         ,9          ,5          ,5            ,5            ,7          ,6          ,7            ,8          ,15         ,16         ,15          ,15           ,25       ,20           ,25          ,25          ,50            ,70             ,250   ,6        ,18       ,14               ,30          ,27            ,80           ,100            ,65               ,6                ,45               ,40              ,4              ,48              ,8              ,50                 ,22}
	stbl = {false      ,false      ,false      ,false      ,true         ,true         ,true       ,true       ,true         ,true       ,true       ,true       ,true        ,true         ,true     ,true         ,true        ,true        ,true          ,true           ,true  ,true     ,true     ,true             ,true        ,true          ,true         ,true           ,true             ,true             ,true             ,true            ,true           ,true            ,true           ,true               ,true}
	nsfl = {}
	table.insert(nsfl,phobosR2)
	table.insert(nsfl,adderMk8)
	table.insert(nsfl,adderMk7)
	table.insert(nsfl,adderMk3)
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
	cargoInventoryList = {}
	table.insert(cargoInventoryList,cargoInventory1)
	table.insert(cargoInventoryList,cargoInventory2)
	table.insert(cargoInventoryList,cargoInventory3)
	table.insert(cargoInventoryList,cargoInventory4)
	table.insert(cargoInventoryList,cargoInventory5)
	table.insert(cargoInventoryList,cargoInventory6)
	table.insert(cargoInventoryList,cargoInventory7)
	table.insert(cargoInventoryList,cargoInventory8)
	station_pool = {
		["Science"] = {
			["Asimov"] =	{goods = {"repulsor"}, description = "Training and Coordination", general = "We train naval cadets in routine and specialized functions aboard space vessels and coordinate naval activity throughout the sector", history = "The original station builders were fans of the late 20th century scientist and author Isaac Asimov. The station was initially named Foundation, but was later changed simply to Asimov. It started off as a stellar observatory, then became a supply stop and as it has grown has become an educational and coordination hub for the region"},
			["Armstrong"] =	{goods = {"warp", "impulse"}, description = "Warp and Impulse engine manufacturing", general = "We manufacture warp, impulse and jump engines for the human navy fleet as well as other independent clients on a contract basis", history = "The station is named after the late 19th century astronaut as well as the fictionlized stations that followed. The station initially constructed entire space worthy vessels. In time, it transitioned into specializeing in propulsion systems."},
			["Broeck"] =	{goods = {"warp"}, description = "Warp drive components", general = "We provide warp drive engines and components", history = "This station is named after Chris Van Den Broeck who did some initial research into the possibility of warp drive in the late 20th century on Earth"},
			["Coulomb"] =	{goods = {"circuit"}, description = "Shielded circuitry fabrication", general = "We make a large variety of circuits for numerous ship systems shielded from sensor detection and external control interference", history = "Our station is named after the law which quantifies the amount of force with which stationary electrically charged particals repel or attact each other - a fundamental principle in the design of our circuits"},
			["Heyes"] =		{goods = {"sensor"}, description = "Sensor components", general = "We research and manufacture sensor components and systems", history = "The station is named after Tony Heyes the inventor of some of the earliest electromagnetic sensors in the mid 20th century on Earth in the United Kingdom to assist blind human mobility"},
			["Hossam"] =	{goods = {"nanites"}, description = "Nanite supplier", general = "We provide nanites for various organic and non-organic systems", history = "This station is named after the nanotechnologist Hossam Haick from the early 21st century on Earth in Israel"},
			["Maiman"] =	{goods = {"beam"}, description = "Energy beam components", general = "We research and manufacture energy beam components and systems", history = "The station is named after Theodore Maiman who researched and built the first laser in the mid 20th century on Earth"},
			["Marconi"] =	{goods = {"beam"}, description = "Energy Beam Components", general = "We manufacture energy beam components", history = "Station named after Guglielmo Marconi an Italian inventor from early 20th century Earth who, along with Nicolo Tesla, claimed to have invented a death ray or particle beam weapon"},
			["Miller"] =	{goods = {"optic"}, description = "Exobiology research", general = "We study recently discovered life forms not native to Earth", history = "This station was named after one of the early exobiologists from mid 20th century Earth, Dr. Stanley Miller"},
			["Shawyer"] =	{goods = {"impulse"}, description = "Impulse engine components", general = "We research and manufacture impulse engine components and systems", history = "The station is named after Roger Shawyer who built the first prototype impulse engine in the early 21st century"},
		},
		["History"] = {
			["Archimedes"] = {goods = {"beam"}, description = "Energy and particle beam components", general = "We fabricate general and specialized components for ship beam systems", history = "This station was named after Archimedes who, according to legend, used a series of adjustable focal length mirrors to focus sunlight on a Roman naval fleet invading Syracuse, setting fire to it"},
			["Chatuchak"] =	{goods = {"luxury"}, description = "Trading station", general = "Only the largest market and trading location in twenty sectors. You can find your heart's desire here", history = "Modeled after the early 21st century bazaar on Earth in Bangkok, Thailand. Designed and built with trade and commerce in mind"},
			["Grasberg"] =	{goods = {"luxury"}, description = "Mining", general ="We mine nearby asteroids for precious minerals and process them for sale", history = "This station's name is inspired by a large gold mine on Earth in Indonesia. The station builders hoped to have a similar amount of minerals found amongst these asteroids"},
			["Hayden"] =	{goods = {"nanites"}, description = "Observatory and stellar mapping", general = "We study the cosmos and map stellar phenomena. We also track moving asteroids. Look out! Just kidding", history = "Station named in honor of Charles Hayden whose philanthropy continued astrophysical research and education on Earth in the early 20th century"},
			["Lipkin"] =	{goods = {"autodoc"}, description = "Autodoc components", general = "", history = "The station is named after Dr. Lipkin who pioneered some of the research and application around robot assisted surgery in the area of partial nephrectomy for renal tumors in the early 21st century on Earth"},
			["Madison"] =	{goods = {"luxury"}, description = "Zero gravity sports and entertainment", general = "Come take in a game or two or perhaps see a show", history = "Named after Madison Square Gardens from 21st century Earth, this station was designed to serve similar purposes in space - a venue for sports and entertainment"},
			["Rutherford"] = {goods = {"shield"}, description = "Shield components and research", general = "We research and fabricate components for ship shield systems", history = "This station was named after the national research institution Rutherford Appleton Laboratory in the United Kingdom which conducted some preliminary research into the feasability of generating an energy shield in the late 20th century"},
			["Toohie"] =	{goods = {"shield"}, description = "Shield and armor components and research", general = "We research and make general and specialized components for ship shield and ship armor systems", history = "This station was named after one of the earliest researchers in shield technology, Alexander Toohie back when it was considered impractical to construct shields due to the physics involved."},
		},
		["Pop Sci Fi"] = {
			["Anderson"] =	{goods = {"software", "battery"}, description = "Battery and software engineering", general = "We provide high quality high capacity batteries and specialized software for all shipboard systems", history = "The station is named after a fictional software engineer in a late 20th century movie depicting humanity unknowingly conquered by aliens and kept docile by software generated illusion"},
			["Archer"] =	{goods = {"shield"}, description = "Shield and Armor Research", general = "The finest shield and armor manufacturer in the quadrant", history = "We named this station for the pioneering spirit of the 22nd century Starfleet explorer, Captain Jonathan Archer"},
			["Barclay"] =	{goods = {"communication"}, description = "Communication components", general = "We provide a range of communication equipment and software for use aboard ships", history = "The station is named after Reginald Barclay who established the first transgalactic com link through the creative application of a quantum singularity. Station personnel often refer to the station as the Broccoli station"},
			["Calvin"] =	{goods = {"robotic"}, description = "Robotic research", general = "We research and provide robotic systems and components", history = "This station is named after Dr. Susan Calvin who pioneered robotic behavioral research and programming"},
			["Cavor"] =		{goods = {"filament"}, description = "Advanced Material components", general = "We fabricate several different kinds of materials critical to various space industries like ship building, station construction and mineral extraction", history = "We named our station after Dr. Cavor, the physicist that invented a barrier material for gravity waves - Cavorite"},
			["Cyrus"] =		{goods = {"impulse"}, description = "Impulse engine components", general = "We supply high quality impulse engines and parts for use aboard ships", history = "This station was named after the fictional engineer, Cyrus Smith created by 19th century author Jules Verne"},
			["Deckard"] =	{goods = {"android"}, description = "Android components", general = "Supplier of android components, programming and service", history = "Named for Richard Deckard who inspired many of the sophisticated safety security algorithms now required for all androids"},
			["Erickson"] =	{goods = {"transporter"}, description = "Transporter components", general = "We provide transporters used aboard ships as well as the components for repair and maintenance", history = "The station is named after the early 22nd century inventor of the transporter, Dr. Emory Erickson. This station is proud to have received the endorsement of Admiral Leonard McCoy"},
			["Komov"] =		{goods = {"filament"}, description = "Xenopsychology training", general = "We provide classes and simulation to help train diverse species in how to relate to each other", history = "A continuation of the research initially conducted by Dr. Gennady Komov in the early 22nd century on Venus, supported by the application of these principles"},
			["Muddville"] = {goods = {"luxury"}, description = "Trading station", general = "Come to Muddvile for all your trade and commerce needs and desires", history = "Upon retirement, Harry Mudd started this commercial venture using his leftover inventory and extensive connections obtained while he traveled the stars as a salesman"},
			["Nexus-6"] =	{goods = {"android"}, description = "Android components", general = "Androids, their parts, maintenance and recylcling", history = "We named the station after the ground breaking android model produced by the Tyrell corporation"},
			["O'Brien"] =	{goods = {"transporter"}, description = "Transporter components", general = "We research and fabricate high quality transporters and transporter components for use aboard ships", history = "Miles O'Brien started this business after his experience as a transporter chief"},
			["Organa"] =	{goods = {"luxury"}, description = "Diplomatic training", general = "The premeire academy for leadership and diplomacy training in the region", history = "Established by the royal family so critical during the political upheaval era"},
			["Owen"] =		{goods = {"lifter"}, description = "Load lifters and components", general = "We provide load lifters and components for various ship systems", history = "Owens started off in the moisture vaporator business on Tattooine then branched out into load lifters based on acquisition of proprietary software and protocols. The station name recognizes the tragic loss of our founder to Imperial violence"},
			["Ripley"] =	{goods = {"lifter"}, description = "Load lifters and components", general = "We provide load lifters and components", history = "The station is named after Ellen Ripley who made creative and effective use of one of our load lifters when defending her ship"},
			["Soong"] =		{goods = {"android"}, description = "Android components", general = "We create androids and android components", history = "The station is named after Dr. Noonian Soong, the famous android researcher and builder"},
			["Tiberius"] =	{goods = {"food"}, description = "Logistics coordination", general = "We support the stations and ships in the area with planning and communication services", history = "We recognize the influence of Starfleet Captain James Tiberius Kirk in the 23rd century in our station name"},
			["Tokra"] =		{goods = {"filament"}, description = "Advanced material components", general = "", history = "We learned several of our critical industrial processes from the Tokra race, so we honor our fortune by naming the station after them"},
			["Utopia Planitia"] = {goods = {"warp"}, description = "Ship building and maintenance facility", general = "We work on all aspects of naval ship building and maintenance. Many of the naval models are researched, designed and built right here on this station. Our design goals seek to make the space faring experience as simple as possible given the tremendous capabilities of the modern naval vessel", history = ""},
			["Zefram"] =	{goods = {"warp"}, description = "Warp engine components", general = "We specialize in the esoteric components necessary to make warp drives function properly", history = "Zefram Cochrane constructed the first warp drive in human history. We named our station after him because of the specialized warp systems work we do"},
			["Jabba"] =		{goods = {"luxury"}, description = "Commerce and gambling", general = "Come play some games and shop. House take does not exceed 4 percent", history = ""},
			["Lando"] =		{goods = {"shield"}, description = "Casino and Gambling", general = "", history = ""},
			["Skandar"] =	{goods = {"luxury"}, description = "Routine maintenance and entertainment", general = "Stop by for repairs. Take in one of our juggling shows featuring the four-armed Skandars", history = "The nomadic Skandars have set up at this station to practice their entertainment and maintenance skills as well as build a community where Skandars can relax"},
			["Starnet"] =	{goods = {"software"}, description = "Automated weapons systems", general = "We research and create automated weapons systems to improve ship combat capability", history = "Lost the history memory bank. Recovery efforts only brought back the phrase, 'I'll be back'"},
			["Vaiken"] =	{goods = {"food","impulse"}, description = "Ship building and maintenance facility", general = "", history = ""},
		},
		["Spec Sci Fi"] = {
			["Alcaleica"] =	{goods = {"optic"}, description = "Optical Components", general = "We make and supply optic components for various station and ship systems", history = "This station continues the businesses from Earth based on the merging of several companies including Leica from Switzerland, the lens manufacturer and the Japanese advanced low carbon (ALCA) electronic and optic research and development company"},
			["Bethesda"] =	{goods = {"autodoc", "medicine"}, description = "Medical research", general = "We research and treat exotic medical conditions", history = "The station is named after the United States national medical research center based in Bethesda, Maryland on earth which was established in the mid 20th century"},
			["Deer"] =		{goods = {"tractor","repulsor"}, description = "Repulsor and Tractor Beam Components", general = "We can meet all your pushing and pulling needs with specialized equipment custom made", history = "The station name comes from a short story by the 20th century author Clifford D. Simak as well as from the 19th century developer John Deere who inspired a company that makes the Earth bound equivalents of our products"},
			["Evondos"] =	{goods = {"autodoc"}, description = "Autodoc components", general = "We provide components for automated medical machinery", history = "The station is the evolution of the company that started automated pharmaceutical dispensing in the early 21st century on Earth in Finland"},
			["Feynman"] =	{goods = {"nanites","software"}, description = "Nanotechnology research", general = "We provide nanites and software for a variety of ship-board systems", history = "This station's name recognizes one of the first scientific researchers into nanotechnology, physicist Richard Feynman"},
			["Mayo"] =		{goods = {"autodoc","medicine","food"}, description = "Medical Research", general = "We research exotic diseases and other human medical conditions", history = "We continue the medical work started by William Worrall Mayo in the late 19th century on Earth"},
			["Olympus"] =	{goods = {"optic"}, description = "Optical components", general = "We fabricate optical lenses and related equipment as well as fiber optic cabling and components", history = "This station grew out of the Olympus company based on earth in the early 21st century. It merged with Infinera, then bought several software comapnies before branching out into space based industry"},
			["Panduit"] =	{goods = {"optic"}, description = "Optic components", general = "We provide optic components for various ship systems", history = "This station is an outgrowth of the Panduit corporation started in the mid 20th century on Earth in the United States"},
			["Shree"] =		{goods = {"tractor"}, description = "Repulsor and tractor beam components", general = "We make ship systems designed to push or pull other objects around in space", history = "Our station is named Shree after one of many tugboat manufacturers in the early 21st century on Earth in India. Tugboats serve a similar purpose for ocean-going vessels on earth as tractor and repulsor beams serve for space-going vessels today"},
			["Vactel"] =	{goods = {"circuit"}, description = "Shielded Circuitry Fabrication", general = "We specialize in circuitry shielded from external hacking suitable for ship systems", history = "We started as an expansion from the lunar based chip manufacturer of Earth legacy Intel electronic chips"},
			["Veloquan"] =	{goods = {"sensor"}, description = "Sensor components", general = "We research and construct components for the most powerful and accurate sensors used aboard ships along with the software to make them easy to use", history = "The Veloquan company has its roots in the manufacturing of LIDAR sensors in the early 21st century on Earth in the United States for autonomous ground-based vehicles. They expanded research and manufacturing operations to include various sensors for space vehicles. Veloquan was the result of numerous mergers and acquisitions of several companies including Velodyne and Quanergy"},
			["Tandon"] =	{goods = {"medicine","autodoc"}, description = "Biotechnology research", general = "Merging the organic and inorganic through research", history = "Continued from the Tandon school of engineering started on Earth in the early 21st century"},
		},
		["Generic"] = {
			["California"] = {goods = {"gold", "dilithium"}, description = "Mining station", general = "", history = ""},
			["Impala"] = 	{goods = {"luxury"}, description = "Mining", general = "We mine nearby asteroids for precious minerals", history = ""},
			["Krak"] =		{goods = {"nickel","platinum"}, description = "Mining station", general = "", history = ""},
			["Krik"] =		{goods = {"nickel","cobalt"}, description = "Mining station", general = "", history = ""},
			["Kruk"] =		{goods = {"nickel","tritanium"}, description = "Mining station", general = "", history = ""},
			["Outpost-15"] = {goods = {"luxury"}, description = "Mining and trade", general = "", history = ""},
			["Outpost-21"] = {goods = {"luxury"}, description = "Mining and gambling", general = "", history = ""},
			["Science-7"] = {goods = {"food"}, description = "Observatory", general = "", history = ""},
			["Maverick"] =	{goods = {"luxury"}, description = "Gambling and resupply", general = "Relax and meet some interesting players", history = ""},
			["Nefatha"] =	{goods = {"luxury"}, description = "Commerce and recreation", general = "", history = ""},
			["Okun"] =		{goods = {"medicine"}, description = "Xenopsychology research", general = "", history = ""},
			["Outpost-7"] = {goods = {"luxury"}, description = "Resupply", general = "", history = ""},
			["Outpost-8"] = {goods = {"food"}, description = "", general = "", history = ""},
			["Outpost-33"] = {goods = {"luxury"}, description = "Resupply", general = "", history = ""},
			["Prada"] =		{goods = {"luxury"}, description = "Textiles and fashion", general = "", history = ""},
			["Research-11"] = {goods = {"medicine"}, description = "Stress Psychology Research", general = "", history = ""},
			["Research-19"] = {goods = {"sensor"}, description = "Low gravity research", general = "", history = ""},
			["Rubis"] =		{goods = {"luxury"}, description = "Resupply", general = "Get your energy here! Grab a drink before you go!", history = ""},
			["Science-2"] = {goods = {"circuit"}, description = "Research Lab and Observatory", general = "", history = ""},
			["Science-4"] = {goods = {"medicine","autodoc"}, description = "Biotech research", general = "", history = ""},
			["Spot"] =		{goods = {"food"}, description = "Observatory", general = "", history = ""},
			["Valero"] =	{goods = {"luxury"}, description = "Resupply", general = "", history = ""},
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
end
function playerShipCargoInventory(p)
	p:addToShipLog(string.format("%s Current cargo:",p:getCallSign()),"Yellow")
	local goodCount = 0
	if p.goods ~= nil then
		for good, goodQuantity in pairs(p.goods) do
			goodCount = goodCount + 1
			p:addToShipLog(string.format("     %s: %i",good,goodQuantity),"Yellow")
		end
	end
	if goodCount < 1 then
		p:addToShipLog("     Empty","Yellow")
	end
	p:addToShipLog(string.format("Available space: %i",p.cargo),"Yellow")
end
----------------------------------
--	Artifact pick up functions  --
----------------------------------
function burnOutArtifactPickup(self, picker)
	if self:isScannedBy(picker) then
		picker:setSystemHealth("beamweapons",picker:getSystemHealth("beamweapons") - 1)
		if difficulty >= 1 then
			picker:setSystemHealth("frontshield",picker:getSystemHealth("frontshield") - 1)			
		end
		if difficulty >= 2 then
			picker:setSystemHealth("maneuver",picker:getSystemHealth("maneuver") - 1)			
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
	picker:addToShipLog("The artifact we picked up has damaged our ship","Magenta")
end
function beamDamageArtifactPickup(self, picker)
	local damage_factor = 0
	local increased_heat_and_energy = 0
	if self:isScannedBy(picker) then
		--damage_factor = 1.5 + (2 - difficulty)/2
		if difficulty < 1 then
			damage_factor = 8
			increased_heat_and_energy = (14/6)
		elseif difficulty > 1 then
			damage_factor = 3
			increased_heat_and_energy = (9/6)
		else
			damage_factor = 6
			increased_heat_and_energy = (12/6)
		end
	else
		--damage_factor = 1.2 + (2 - difficulty)/2
		if difficulty < 1 then
			damage_factor = 5
			increased_heat_and_energy = (11/6)
		elseif difficulty > 1 then
			damage_factor = 2
			increased_heat_and_energy = (8/6)
		else
			damage_factor = 4
			increased_heat_and_energy = (10/6)
		end
	end
	local beam_index = 0
	repeat
		local tempArc = picker:getBeamWeaponArc(beam_index)
		local tempDir = picker:getBeamWeaponDirection(beam_index)
		local tempRng = picker:getBeamWeaponRange(beam_index)
		local tempCyc = picker:getBeamWeaponCycleTime(beam_index)
		local tempDmg = picker:getBeamWeaponDamage(beam_index)
		picker:setBeamWeapon(beam_index,tempArc,tempDir,tempRng,tempCyc,tempDmg + damage_factor)
		picker:setBeamWeaponHeatPerFire(beam_index,picker:getBeamWeaponHeatPerFire(beam_index)*increased_heat_and_energy)
		picker:setBeamWeaponEnergyPerFire(beam_index,picker:getBeamWeaponEnergyPerFire(beam_index)*increased_heat_and_energy)
		beam_index = beam_index + 1
	until(picker:getBeamWeaponRange(beam_index) < 1)
	picker:addToShipLog("The technology gleaned from the artifact has allowed our technicians to increase the damage inflicted by our beam weapons","Magenta")
end
function maneuverArtifactPickup(self, picker)
	local maneuver_factor = 1
	if self:isScannedBy(picker) then
		maneuver_factor = 1.5 + (2 - difficulty)/2
	else
		maneuver_factor = 1.2 + (2 - difficulty)/2
	end
	picker:setRotationMaxSpeed(picker:getRotationMaxSpeed()*maneuver_factor)
	picker:addToShipLog(string.format("The technology gleaned from the artifact has allowed our technicians to increase our maneuver speed by %.1f%%",(maneuver_factor - 1)*100),"Magenta")
end
function setOptionalAddBeamMission(beam_station)
	if efficient_battery_diagnostic then print("top of setOptionalAddBeamMission") end
	if beam_station == nil then
		return
	end
	beam_station.comms_data.character = "Bob Fairchilde"
	beam_station.comms_data.characterDescription = "His penchant for miniaturization and tinkering allows him to add a beam weapon to any ship"
	beam_station.comms_data.characterFunction = "addForwardBeam"
	if efficient_battery_diagnostic then print(string.format("first station: %s",first_station:getCallSign())) end
	local mineral_good = stationMineralGood(first_station)
	if efficient_battery_diagnostic then print("determined mineral good: " .. mineral_good) end
	beam_station.comms_data.characterGood = mineral_good
	--add clue station here	
end
function setOptionalEfficientBatteriesMisison(battery_station)
	if efficient_battery_diagnostic then print("top of setOptionalEfficientBatteriesMisison") end
	if battery_station == nil then
		return
	end
	battery_station.comms_data.character = "Norma Tarigan"
	battery_station.comms_data.characterDescription = "She knows how to increase your maximum energy capacity by improving battery efficiency"
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
------------------------------------
--	Generate call sign functions  --
------------------------------------
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
---------------------------------
--	Station related functions  --
---------------------------------
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
function populateStationPool()
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
					repulsor = {
						quantity =	5,	
						cost =		62,
					},
				},
				trade = {	
					food = random(1,100) <= 45, 
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
					food = random(1,100) <= 14, 
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
        			food = random(1,100) <= 35, 
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
					food = random(1,100) <= 32, 
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
					food = random(1,100) <= 75, 
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
    				food = random(1,100) <= 65, 
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
					food = random(1,100) <= 53, 
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
					food = random(1,100) <= 68, 
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
					food = random(1,100) <= 42, 
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
					food = random(1,100) <= 85, 
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
					food = random(1,100) <= 21, 
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
					food = random(1,100) <= 35, 
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
	station_priority = {}
	table.insert(station_priority,"Science")
	table.insert(station_priority,"Pop Sci Fi")
	table.insert(station_priority,"Spec Sci Fi")
	table.insert(station_priority,"History")
	table.insert(station_priority,"Generic")
	for group, list in pairs(station_pool) do
		local already_inserted = false
		for _, previous_group in ipairs(station_priority) do
			if group == previous_group then
				already_inserted = true
				break
			end
		end
		if not already_inserted and group ~= "Sinister" then
			table.insert(station_priority,group)
		end
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
		if stationFaction ~= nil then
			station:setFaction(stationFaction)
		else
			station:setFaction("Independent")
		end
	end
	if size == nil then
		station:setTemplate(szt())
	else
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
	end
	local size_matters = 0
	local station_size = station:getTypeName()
	if station_size == "Medium Station" then
		size_matters = 20
	elseif station_size == "Large Station" then
		size_matters = 30
	elseif station_size == "Huge Station" then
		size_matters = 40
	end
	local faction_matters = 0
	if station:getFaction() == "Human Navy" then
		faction_matters = 20
	end
	station.comms_data.probe_launch_repair =	random(1,100) <= (20 + size_matters + faction_matters)
	station.comms_data.scan_repair =			random(1,100) <= (30 + size_matters + faction_matters)
	station.comms_data.hack_repair =			random(1,100) <= (10 + size_matters + faction_matters)
	station.comms_data.combat_maneuver_repair =	random(1,100) <= (15 + size_matters + faction_matters)
	station.comms_data.self_destruct_repair =	random(1,100) <= (25 + size_matters + faction_matters)
	station.comms_data.jump_overcharge =		random(1,100) <= (5 + size_matters + faction_matters)
	station:setSharesEnergyWithDocked(random(1,100) <= (50 + size_matters + faction_matters))
	station:setRepairDocked(random(1,100) <= (55 + size_matters + faction_matters))
	station:setRestocksScanProbes(random(1,100) <= (45 + size_matters + faction_matters))
	--specialized code for particular stations
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
function pickStation(name)
--	print("pick station name")
	if station_pool == nil then
		populateStationPool()
	end
	local selected_station_name = nil
	local station_selection_list = {}
	local selected_station = nil
	local station = nil
	if name == nil then
		--default to random in priority order
		for _, group in ipairs(station_priority) do
			if station_pool[group] ~= nil then
				for station, details in pairs(station_pool[group]) do
					table.insert(station_selection_list,station)
				end
				if #station_selection_list > 0 then
					if selected_station_name == nil then
						selected_station_name = station_selection_list[math.random(1,#station_selection_list)]
						station = SpaceStation():setCommsScript(""):setCommsFunction(commsStation):setCallSign(selected_station_name):setDescription(station_pool[group][selected_station_name].description)
						station.comms_data = station_pool[group][selected_station_name]
						station_pool[group][selected_station_name] = nil
						return group, station
					end
				end
			end
		end
	else
--		print("name parameter provided:",name)
		if name == "Random" then
			--random across all groups
			for group, list in pairs(station_pool) do
				for station_name, station_details in pairs(list) do
					table.insert(station_selection_list,{group = group, station_name = station_name, station_details = station_details})
				end
			end
			if #station_selection_list > 0 then
				selected_station = station_selection_list[math.random(1,#station_selection_list)]
				station = SpaceStation():setCommsScript(""):setCommsFunction(commsStation):setCallSign(selected_station.station_name):setDescription(selected_station.station_details.description)
				station.comms_data = selected_station.station_details
				station_pool[selected_station.group][selected_station.station_name] = nil
				return selected_station.group, station
			end
		elseif name == "RandomHumanNeutral" then
			for group, list in pairs(station_pool) do
				if group ~= "Generic" and group ~= "Sinister" then
					for station_name, station_details in pairs(list) do
						table.insert(station_selection_list,{group = group, station_name = station_name, station_details = station_details})
					end
				end
			end
			if #station_selection_list > 0 then
				selected_station = station_selection_list[math.random(1,#station_selection_list)]
				station = SpaceStation():setCommsScript(""):setCommsFunction(commsStation):setCallSign(selected_station.station_name):setDescription(selected_station.station_details.description)
				station.comms_data = selected_station.station_details
				station_pool[selected_station.group][selected_station.station_name] = nil
				return selected_station.group, station
			end
		elseif name == "RandomGenericSinister" then
			for group, list in pairs(station_pool) do
				if group == "Generic" or group == "Sinister" then
					for station_name, station_details in pairs(list) do
						table.insert(station_selection_list,{group = group, station_name = station_name, station_details = station_details})
					end
				end
			end
			if #station_selection_list > 0 then
				selected_station = station_selection_list[math.random(1,#station_selection_list)]
				station = SpaceStation():setCommsScript(""):setCommsFunction(commsStation):setCallSign(selected_station.station_name):setDescription(selected_station.station_details.description)
				station.comms_data = selected_station.station_details
				station_pool[selected_station.group][selected_station.station_name] = nil
				return selected_station.group, station
			end
		else
--			print("not one of the generic random names")
			if station_pool[name] ~= nil then
--				print("name is a group name")
				--name is a group name
				for station_name, station_details in pairs(station_pool[name]) do
					table.insert(station_selection_list,{station_name = station_name, station_details = station_details})
				end
				if #station_selection_list > 0 then
					selected_station = station_selection_list[math.random(1,#station_selection_list)]
					station = SpaceStation():setCommsScript(""):setCommsFunction(commsStation):setCallSign(selected_station.station_name):setDescription(selected_station.station_details.description)
					station.comms_data = selected_station.station_details
					station_pool[name][selected_station.station_name] = nil
					return name, station
				end
			else
--				print("name is not a group name")
				for group, list in pairs(station_pool) do
					if station_pool[group][name] ~= nil then
						station = SpaceStation():setCommsScript(""):setCommsFunction(commsStation):setCallSign(name):setDescription(station_pool[group][name].description)
						station.comms_data = station_pool[group][name]
						station_pool[group][name] = nil
						return group, station
					end
				end
				--name not found in any group
				print("Name provided not found in groups or stations, nor is it an accepted specialized name, like Random, RandomHumanNeutral or RandomGenericSinister")
				return nil
			end
		end
	end
	return nil
end
---------------------------------------------
--	Inventory button for relay/operations  --
---------------------------------------------
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
------------------------------
--	Station communications  --
------------------------------
function impulseUpgrade(ship)
	ship.impulse_upgrade = true
	ship:setImpulseMaxSpeed(ship:getImpulseMaxSpeed()*2)
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
function doubleBeamDamageUpgrade(ship)
	ship.beam_damage_upgrade = true
	local bi = 0
	local damage_factor = 0
	local increased_heat_and_energy = 0
	if difficulty < 1 then
		damage_factor = 8
		increased_heat_and_energy = (14/6)
	elseif difficulty > 1 then
		damage_factor = 3
		increased_heat_and_energy = (9/6)
	else
		damage_factor = 6
		increased_heat_and_energy = (12/6)
	end
	repeat
		local tempArc = ship:getBeamWeaponArc(bi)
		local tempDir = ship:getBeamWeaponDirection(bi)
		local tempRng = ship:getBeamWeaponRange(bi)
		local tempCyc = ship:getBeamWeaponCycleTime(bi)
		local tempDmg = ship:getBeamWeaponDamage(bi)
		ship:setBeamWeapon(bi,tempArc,tempDir,tempRng,tempCyc,tempDmg + damage_factor)
		ship:setBeamWeaponHeatPerFire(bi,ship:getBeamWeaponHeatPerFire(bi)*increased_heat_and_energy)
		ship:setBeamWeaponEnergyPerFire(bi,ship:getBeamWeaponEnergyPerFire(bi)*increased_heat_and_energy)
		bi = bi + 1
	until(ship:getBeamWeaponRange(bi) < 1)
end
function jumpDriveUpgrade(ship)
	ship.add_small_jump = true
	contract_eligible = true
	transition_contract_delay_max = 300 + (difficulty*50)
	transition_contract_delay = transition_contract_delay_max
	ship:setJumpDrive(true)
	ship.max_jump_range = 25000
	ship.min_jump_range = 2000
	ship:setJumpDriveRange(ship.min_jump_range,ship.max_jump_range)
	ship:setJumpDriveCharge(ship.max_jump_range)
	print("Accumulated delta when player gets jump drive upgrade:",accumulated_delta)
	local seconds = math.floor(accumulated_delta % 60)
	if accumulated_delta > 60 then
		local minutes = math.floor(accumulated_delta / 60)
		if minutes > 60 then
			local hours = math.floor(minutes / 60)
			print(string.format("%i:%.2i:%.2i",hours,minutes,seconds))
		else
			print(string.format("%i:%.2i",minutes,seconds))
		end
	else
		print("seconds: ",seconds)
	end
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
	local goodCount = 0
	for good, goodData in pairs(ctd.goods) do
		goodCount = goodCount + 1
	end
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
	addCommsReply("I need information",function()
		setCommsMessage("What kind of information are you looking for?")
		addCommsReply("Docking services status", function()
			local service_status = string.format("Station %s docking services status:",comms_target:getCallSign())
			if comms_target:getRestocksScanProbes() then
				service_status = string.format("%s\nReplenish scan probes.",service_status)
			else
				if comms_target.probe_fail_reason == nil then
					local reason_list = {
						"Cannot replenish scan probes due to fabrication unit failure.",
						"Parts shortage prevents scan probe replenishment.",
						"Station management has curtailed scan probe replenishment for cost cutting reasons.",
					}
					comms_target.probe_fail_reason = reason_list[math.random(1,#reason_list)]
				end
				service_status = string.format("%s\n%s",service_status,comms_target.probe_fail_reason)
			end
			if comms_target:getRepairDocked() then
				service_status = string.format("%s\nShip hull repair.",service_status)
			else
				if comms_target.repair_fail_reason == nil then
					reason_list = {
						"We're out of the necessary materials and supplies for hull repair.",
						"Hull repair automation unavailable while it is undergoing maintenance.",
						"All hull repair technicians quarantined to quarters due to illness.",
					}
					comms_target.repair_fail_reason = reason_list[math.random(1,#reason_list)]
				end
				service_status = string.format("%s\n%s",service_status,comms_target.repair_fail_reason)
			end
			if comms_target:getSharesEnergyWithDocked() then
				service_status = string.format("%s\nRecharge ship energy stores.",service_status)
			else
				if comms_target.energy_fail_reason == nil then
					reason_list = {
						"A recent reactor failure has put us on auxiliary power, so we cannot recharge ships.",
						"A damaged power coupling makes it too dangerous to recharge ships.",
						"An asteroid strike damaged our solar cells and we are short on power, so we can't recharge ships right now.",
					}
					comms_target.energy_fail_reason = reason_list[math.random(1,#reason_list)]
				end
				service_status = string.format("%s\n%s",service_status,comms_target.energy_fail_reason)
			end
			if comms_target.comms_data.jump_overcharge then
				service_status = string.format("%s\nMay overcharge jump drive",service_status)
			end
			if comms_target.comms_data.probe_launch_repair then
				service_status = string.format("%s\nMay repair probe launch system",service_status)
			end
			if comms_target.comms_data.hack_repair then
				service_status = string.format("%s\nMay repair hacking system",service_status)
			end
			if comms_target.comms_data.scan_repair then
				service_status = string.format("%s\nMay repair scanners",service_status)
			end
			if comms_target.comms_data.combat_maneuver_repair then
				service_status = string.format("%s\nMay repair combat maneuver",service_status)
			end
			if comms_target.comms_data.self_destruct_repair then
				service_status = string.format("%s\nMay repair self destruct system",service_status)
			end
			setCommsMessage(service_status)
			addCommsReply("Back", commsStation)
		end)
		local has_gossip = random(1,100) < (100 - (30 * (difficulty - .5)))
		if (comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "") or
			(comms_target.comms_data.history ~= nil and comms_target.comms_data.history ~= "") or
			(comms_source:isFriendly(comms_target) and comms_target.comms_data.gossip ~= nil and comms_target.comms_data.gossip ~= "" and has_gossip) then
			addCommsReply("Tell me more about your station", function()
				setCommsMessage("What would you like to know?")
				if comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "" then
					addCommsReply("General information", function()
						setCommsMessage(ctd.general)
						addCommsReply("Back", commsStation)
					end)
				end
				if ctd.history ~= nil and comms_target.comms_data.history ~= "" then
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
				addCommsReply("Back",commsStation)
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
				addCommsReply("Back", commsStation)
			end)
		end
		if comms_target:isFriendly(comms_source) then
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
		end
		if goodCount > 0 then
			addCommsReply("No tutorial covered goods or cargo. Explain", function()
				setCommsMessage("Different types of cargo or goods may be obtained from stations, freighters or other sources. They go by one word descriptions such as dilithium, optic, warp, etc. Certain mission goals may require a particular type or types of cargo. Each player ship differs in cargo carrying capacity. Goods may be obtained by spending reputation points or by trading other types of cargo (typically food, medicine or luxury)")
				addCommsReply("Back", commsStation)
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
				addCommsReply("Overcharge Jump Drive (10 Rep)",function()
					if comms_source:takeReputationPoints(10) then
						comms_source:setJumpDriveCharge(comms_source:getJumpDriveCharge() + max_charge)
						setCommsMessage(string.format("Your jump drive has been overcharged to %ik",math.floor(comms_source:getJumpDriveCharge()/1000)))
					else
						setCommsMessage("Insufficient reputation")
					end
					addCommsReply("Back", commsStation)
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
		addCommsReply("Repair ship system",function()
			setCommsMessage("What system would you like repaired?")
			if comms_target.comms_data.probe_launch_repair then
				if not comms_source:getCanLaunchProbe() then
					addCommsReply("Repair probe launch system (5 Rep)",function()
						if comms_source:takeReputationPoints(5) then
							comms_source:setCanLaunchProbe(true)
							setCommsMessage("Your probe launch system has been repaired")
						else
							setCommsMessage("Insufficient reputation")
						end
						addCommsReply("Back", commsStation)
					end)
				end
			end
			if comms_target.comms_data.hack_repair then
				if not comms_source:getCanHack() then
					addCommsReply("Repair hacking system (5 Rep)",function()
						if comms_source:takeReputationPoints(5) then
							comms_source:setCanHack(true)
							setCommsMessage("Your hack system has been repaired")
						else
							setCommsMessage("Insufficient reputation")
						end
						addCommsReply("Back", commsStation)
					end)
				end
			end
			if comms_target.comms_data.scan_repair then
				if not comms_source:getCanScan() then
					addCommsReply("Repair scanners (5 Rep)",function()
						if comms_source:takeReputationPoints(5) then
							comms_source:setCanScan(true)
							setCommsMessage("Your scanners have been repaired")
						else
							setCommsMessage("Insufficient reputation")
						end
						addCommsReply("Back", commsStation)
					end)
				end
			end
			if comms_target.comms_data.combat_maneuver_repair then
				if not comms_source:getCanCombatManeuver() then
					addCommsReply("Repair combat maneuver (5 Rep)",function()
						if comms_source:takeReputationPoints(5) then
							comms_source:setCanCombatManeuver(true)
							setCommsMessage("Your combat maneuver has been repaired")
						else
							setCommsMessage("Insufficient reputation")
						end
						addCommsReply("Back", commsStation)
					end)
				end
			end
			if comms_target.comms_data.self_destruct_repair then
				if not comms_source:getCanSelfDestruct() then
					addCommsReply("Repair self destruct system (5 Rep)",function()
						if comms_source:takeReputationPoints(5) then
							comms_source:setCanSelfDestruct(true)
							setCommsMessage("Your self destruct system has been repaired")
						else
							setCommsMessage("Insufficient reputation")
						end
						addCommsReply("Back", commsStation)
					end)
				end
			end
			addCommsReply("Back", commsStation)
		end)
	end
	if comms_target == transition_station then
		if plot1 == nil then
			addCommsReply("Check long distance contract",function()
				createHumanNavySystem()
				setCommsMessage(string.format("Contract Details:\nTravel to %s system to deliver cargo to supply station %s. Distance to system: %i units. Upon delivery, %s technicians will upgrade your battery efficiency and beam cycle time.",planet_star:getCallSign(),supply_depot_station:getCallSign(),math.floor(distance(comms_target,planet_star)/1000),supply_depot_station:getCallSign()))
				addCommsReply("Accept",function()
					local p = getPlayerShip(-1)
					addMineTube(p)
					local acceptance_message = string.format("The Human Navy requires all armed ships be equipped with the ability to drop mines. We have modified %s with a rear facing mining tube. Due to ship size constraints, we were only able to provide you with two mines.",comms_source:getCallSign())
					--remove/add cargo here
					if comms_source.cargo < 4 then
						local remove_list = ""
						for good, good_quantity in pairs(comms_source.goods) do
							if good_quantity > 0 then
								comms_source.goods[good] = 0
								if remove_list == "" then
									remove_list = remove_list .. "\n\nYour current cargo (" .. good
								else
									remove_list = remove_list .. ", " .. good
								end
							end
						end
						remove_list = remove_list .. ") has been removed to make room for your contract cargo and to help defray the cost of upgrading your ship to Human Navy standards."
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
					acceptance_message = acceptance_message .. string.format("\n\nCritical cargo has been loaded aboard your ship, %s. Take the cargo to the %s system centered in sector %s. Find %s, the second planet out from star %s. Dock at station %s in orbit around %s's moon, %s to deliver the cargo. They will have crew standing by to immediately offload the cargo",p:getCallSign(),planet_star:getCallSign(),planet_star:getSectorName(),planet_secondus:getCallSign(),planet_star:getCallSign(),supply_depot_station:getCallSign(),planet_secondus:getCallSign(),planet_secondus_moon:getCallSign())
					setCommsMessage(acceptance_message)
					plot1 = longDistanceCargo
					addCommsReply("Back",commsStation)
				end)
				addCommsReply("Back",commsStation)
			end)
		end
	end
	if comms_target == first_station then
		if plot1_fleets_destroyed ~= nil then
			if plot1_fleets_destroyed > 0 then
				if not comms_source.impulse_upgrade then
					addCommsReply("Upgrade impulse engines", function()
						impulseUpgrade(comms_source)
						setCommsMessage("Thanks for taking care of those Exuari. We've upgraded the topspeed of your impulse engines")
						addCommsReply("Back",commsStation)
					end)
				end
				if plot1_fleets_destroyed > 1 and not comms_source.missile_upgrade then
					addCommsReply("Add missile tubes", function()
						missileTubeUpgrade(comms_source)
						setCommsMessage("Thanks for continuing to shoot down those Exuari. We've added some missile tubes to help you destroy the Exuari station")
						plot1_message = string.format("%s has asked for help against Exuari forces and has provided your ship with missile weapons to help you destroy %s",first_station:getCallSign(),exuari_harassing_station:getCallSign())
						addCommsReply("Back",commsStation)
					end)
				end
				if plot1_fleets_destroyed > 2 and not comms_source.beam_damage_upgrade then
					addCommsReply("Upgrade beam damage", function()
						doubleBeamDamageUpgrade(comms_source)
						setCommsMessage("Looks like you're having a hard time with those Exuari. We've increased the damage your beam weapons deal out")
						addCommsReply("Back",commsStation)
					end)
				end
			end
		end
		if exuari_harassment_upgrade and not comms_source.add_small_jump then
			addCommsReply("Add jump drive", function()
				jumpDriveUpgrade(comms_source)
				setCommsMessage("That Exuari station was a pain. Thanks for getting rid of it. We have fitted your ship with a 25 unit jump drive as a token of our gratitude.\n\nWe have also formally recognized your competence. This allows you to enter into contracts with independent entities in the area. There may even be contracts available originating from this station.")
				addCommsReply("Back",commsStation)
			end)
		end
		if exuari_harassment_upgrade then
			if player.asteroid_search == nil then
				addCommsReply("Asteroid research request", function()
					setCommsMessage("Posted on the station electronic request board:\n\nRequest services of vessel in the area to scan asteroids in search of asteroid with particular characteristics. Substantial reward. No formal contract available. For further details, contact Jenny McGuire")
					addCommsReply("Contact Jenny McGuire",function()
						setCommsMessage(string.format("Hi %s, I'm so glad you contacted me. I've been researching many of the nearby asteroids. There is one in particular that I am interested in. Unfortunately, I lost access to sensors with enough detail to scan from a distance and my research ship was shot out from under me by pirates. I was lucky to escape with my life. I would like to locate my special asteroid, but I did not record location details, only sensor details. The asteroid I am interested in has traces of osmium and iridium, both of which are fairly rare, but together, they are exceptionally rare. If you run across an asteroid like that, could you let me know? If I were able to continue my research, I would be very appreciative. I know several technicians that would be more than willing to provide your ship with a valuable upgrade.",player:getCallSign()))
						addCommsReply("We will look, but can't promise anything",function()
							setCommsMessage("Thanks. I understand about priorities. Please contact me if you find anything")
							player.asteroid_search = "enabled"
							player.asteroid_identified = false
							player.jenny_aboard = false
							first_station.asteroid_upgrade = false
							plot3 = jennyAsteroid
							player.asteroid_start_time = getScenarioTime()
							addCommsReply("Back",commsStation)
						end)
						addCommsReply("Back",commsStation)
					end)
					addCommsReply("Back",commsStation)
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
					addCommsReply("Get ship upgrade promised by Jenny McGuire",function()
						setCommsMessage("Choose one of these upgrades from Jenny McGuire's friends")
						addCommsReply("Decrease beam cycle time",function()
							player.asteroid_upgrade = "done"
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
							setCommsMessage(string.format("Your beam cycle time has been reduced. Jenny McGuire thanks you again and leaves %s to resume her work on %s",player:getCallSign(),first_station:getCallSign()))
							plot3 = nil
							addCommsReply("Back",commsStation)
						end)
						addCommsReply("Decrease heat generated per beam fired",function()
							player.asteroid_upgrade = "done"
							local bi = 0
							repeat
								comms_source:setBeamWeaponHeatPerFire(bi,comms_source:getBeamWeaponHeatPerFire(bi)*.8)
								bi = bi + 1
							until(comms_source:getBeamWeaponRange(bi) < 1)
							setCommsMessage(string.format("The heat generated when firing your beams has been reduced. Jenny McGuire thanks you again and leaves %s to resume her work on %s",player:getCallSign(),first_station:getCallSign()))
							plot3 = nil
							addCommsReply("Back",commsStation)
						end)
						addCommsReply("Increase ship acceleration",function()
							player.asteroid_upgrade = "done"
							comms_source:setAcceleration(comms_source:getAcceleration() + 10)
							setCommsMessage(string.format("Your ship acceleration has been increased. Jenny McGuire thanks you again and leaves %s to resume her work on %s",player:getCallSign(),first_station:getCallSign()))
							plot3 = nil
							addCommsReply("Back",commsStation)
						end)
					end)
				end
			end
		end
		if transition_contract_message and plot1 ~= transitionContract then
			addCommsReply("Check long range contract",function()
				createTransitionSystem()
				local distance_to_start = distance(first_station,transition_station)
				setCommsMessage(string.format("The contract outline indicates that the contract starts at station %s, a Human Navy station %i units from here. It looks like a relatively straighforward delivery to another Human Navy station between 100 and 200 units away. It also mentions that only Human Navy ships may fulfill this contract. That should not be a problem since station %s will gladly fit your ship with a Human Navy squawker if you desire based on the service you've already provided in this area.",transition_station:getCallSign(),math.floor(distance_to_start/1000),first_station:getCallSign()))
				addCommsReply("Accept",function()
					local current_rep = comms_source:getReputationPoints()
					comms_source:setFaction("Human Navy"):setLongRangeRadarRange(30000):setJumpDriveRange(3000,30000)
					comms_source:setReputationPoints(current_rep)
					local accept_message = string.format("Station %s has fitted you with a Human Navy Identification Friend or Foe (IFF) and increased your jump drive and sensor ranges to 30 units.",first_station:getCallSign())
					if comms_source:getWaypointCount() < 9 then
						local dsx, dsy = transition_station:getPosition()
						comms_source:commandAddWaypoint(dsx,dsy)
						accept_message = string.format("%s\nThey also placed waypoint %i in your navigation system for station %s in sector %s.",accept_message,comms_source:getWaypointCount(),transition_station:getCallSign(),transition_station:getSectorName())
					else
						accept_message = string.format("%s\nYou can find station %s in sector %s.",accept_message,transition_station:getCallSign(),transition_station:getSectorName())
					end
					plot1 = transitionContract
					setCommsMessage(accept_message)
					addCommsReply("Back",commsStation)
				end)
				addCommsReply("Back",commsStation)
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
			local contract_report = string.format("Contract report from station %s:",comms_target:getCallSign())
			if contract_available then
				addCommsReply("Browse Contracts", function()
					for contract, details in pairs(ctd.contract) do
						if details.type == "start" then
							if details.accepted ~= nil and not details.accepted and details.prompt ~= nil then
								contract_report = contract_report .. "\nTo Accept: " .. details.prompt
								addCommsReply(string.format("Accept %s contract",details.short_prompt),details.func)
							end
						end
						if details.type == "fulfill" then
							if details.fulfilled ~= nil and not details.fulfilled and details.prompt ~= nil then
								contract_report = contract_report .. "\nTo Fulfill: " .. details.prompt
								addCommsReply(string.format("Fulfill %s contract",details.short_prompt),details.func)
							end
						end
					end
					setCommsMessage(contract_report)
					addCommsReply("Back",commsStation)
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
	end	--end friendly/neutral 
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
			if ctd.trade.food ~= nil and ctd.trade.food and comms_source.goods ~= nil and comms_source.goods.food ~= nil and comms_source.goods.food.quantity > 0 then
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
			if ctd.trade.medicine ~= nil and ctd.trade.medicine and comms_source.goods ~= nil and comms_source.goods.medicine ~= nil and comms_source.goods.medicine.quantity > 0 then
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
			if ctd.trade.luxury ~= nil and ctd.trade.luxury and comms_source.goods ~= nil and comms_source.goods.luxury ~= nil and comms_source.goods.luxury.quantity > 0 then
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
			--[[
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
			--]]
			addCommsReply("Back", commsStation)
		end)
	end
end
function createTransitionSystem()
	if transition_station == nil then
		local fsx, fsy = first_station:getPosition()
		psx = fsx + random(100000,120000)
		psy = fsy + random(-60000,80000)
--		stationFaction = "Human Navy"				--set station faction
		if difficulty < 1 then
			stationSize = "Large Station"
		elseif difficulty > 1 then
			stationSize = "Small Station"
		else
			stationSize = "Medium Station"
		end
--		local si = math.random(1,#placeStation)		--station index
--		local pStation = placeStation[si]()			--place selected station
		pStation = placeStation(psx,psy,nil,"Human Navy",stationSize)
--		table.remove(placeStation,si)				--remove station from placement list
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
		local direct_angle = angleFromVectorNorth(fsx,fsy,psx,psy) + 90
		local asteroid_list = {}
		local lax, lay, temp_list = createRandomAlongArc(Asteroid,100,fsx,fsy,60000,direct_angle-30,direct_angle+30,1800)
		asteroid_list = add_to_list(temp_list,asteroid_list)
		local la_2_x, la_2_y = createRandomAlongArc(Asteroid,1,fsx,fsy,60000,direct_angle-30,direct_angle+30,1800)
		asteroid_list = add_to_list(temp_list,asteroid_list)
		local avx, avy = vectorFromAngle(random(0,360),350-(difficulty*100))
		Artifact():setModel("artifact4"):setScanningParameters(difficulty*2,difficulty*2):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setDescriptions("Object of unknown origin","Object of unknown origin, advanced technology detected"):allowPickup(true):onPickUp(maneuverArtifactPickup):setPosition(lax+avx,lay+avy)
		Artifact():setModel("artifact4"):setScanningParameters(difficulty*2,difficulty*2):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setDescriptions("Object of unknown origin","Object of unknown origin, advanced technology detected"):allowPickup(true):onPickUp(burnOutArtifactPickup):setPosition(la_2_x+avx,la_2_y+avy)
		if difficulty >= 1 then
			repeat
				crx, cry = asteroid_list[math.random(1,#asteroid_list)]:getPosition()
			until(crx ~= lax and cry ~= lay and crx ~= la_2_x and cry ~= la_2_y)
			Artifact():setModel("artifact4"):setScanningParameters(difficulty*2,difficulty*2):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setDescriptions("Object of unknown origin","Object of unknown origin, advanced technology detected"):allowPickup(true):onPickUp(burnOutArtifactPickup):setPosition(crx+avx,cry+avy)
		end
		if difficulty > 1 then
			repeat
				drx, dry = asteroid_list[math.random(1,#asteroid_list)]:getPosition()
			until(drx ~= lax and dry ~= lay and drx ~= la_2_x and dry ~= la_2_y and drx ~= crx and dry ~= cry)
			Artifact():setModel("artifact4"):setScanningParameters(difficulty*2,difficulty*2):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setDescriptions("Object of unknown origin","Object of unknown origin, advanced technology detected"):allowPickup(true):onPickUp(burnOutArtifactPickup):setPosition(drx+avx,dry+avy)
		end
		local etx, ety = vectorFromAngle(direct_angle,57000)
		etx = etx + fsx
		ety = ety + fsy
		drop_bait = SupplyDrop():setFaction("Exuari"):setPosition(etx,ety):setDescriptions("Supply Drop","Supply Drop containing energy, missiles and various ship system repair parts"):setScanningParameters(math.ceil(difficulty + .2),math.random(1,3))
		plot4 = highwaymen
		highway_timer = 30
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
		local fsx, fsy = first_station:getPosition()
		star_x = fsx + random(250000,270000)
		star_y = fsy + random(-20000,80000)
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
	addCommsReply("Contact Jenny McGuire", function()
		setCommsMessage("Were you able to find an asteroid with osmium and iridium?")
		addCommsReply("We think so",function()
			local asteroid_note_prompt = "Excellent! I found my notes on the asteroid composition. Let's compare your readings to the ones I took. Overall, the asteroid had osmium, iridium, olivine and nickel. The rest was rock.\n\nWhat was your reading on osmium?\nEnter the 10's digit. For example, for 23.5, the 10's digit is 2"
			if getScenarioTime() - player.asteroid_start_time > 300 then
				local asteroid_structure = target_asteroid:getDescription("notscanned")
				asteroid_note_prompt = string.format("Excellent! I found my notes on the asteroid composition. Let's compare your readings to the ones I took. %s, the asteroid had osmium, iridium, olivine and nickel. The rest was rock.\n\nWhat was your reading on osmium?\nEnter the 10's digit. For example, for 23.5, the 10's digit is 2",asteroid_structure)
			end
			setCommsMessage(asteroid_note_prompt)
			for i=0,9 do
				addCommsReply(string.format("10's digit %i",i),function()
					print("input osmium 10's:",i)
					setCommsMessage("Now for the osmium 1's digit. For example, for 23.5, the 1's digit is 3")
					for j=0,9 do
						addCommsReply(string.format("1's digit %i",j),function()
							print("input osmium 1's:",j)
							setCommsMessage("And one digit after the decimal point. For example, for 23.5, the digit after the decimal point is 5")
							for k=0,9 do
								addCommsReply(string.format("after decimal digit %i",k),function()
									print("input osmium after decimal:",k)
									print(string.format("Osmium: %.1f",i*10 + j + k/10))
									--setCommsMessage(string.format("osmium: %.1f",i*10 + j + k/10))
									setCommsMessage(string.format("Osmium: %.1f\nThe Iridium 10's digit. For example, for 23.5, the 10's digit is 2",i*10 + j + k/10))
									for l=0,9 do
										addCommsReply(string.format("10's digit %i",l),function()
											print("input iridium 10's:",l)
											setCommsMessage("Now for the iridium 1's digit. For example, for 23.5, the 1's digit is 3")
											for m=0,9 do
												addCommsReply(string.format("1's digit %i",m),function()
													print("input iridium 1's:",m)
													setCommsMessage("And one digit after the decimal point. For example, for 23.5, the digit after the decimal point is 5")
													for n=0,9 do
														addCommsReply(string.format("after decimal digit %i",n),function()
															print("input iridium after decimal:",n)
															print(string.format("iridium: %.1f",l*10 + m + n/10))
															--setCommsMessage(string.format("iridium: %.1f",l*10 + m + n/10))
															setCommsMessage(string.format("Osmium: %.1f\nIridium: %.1f\nThe Olivine 10's digit. For example, for 23.5, the 10's digit is 2",i*10 + j + k/10,l*10 + m + n/10))
															for o=0,9 do
																addCommsReply(string.format("10's digit %i",o),function()
																	print("input olivine 10's:",o)
																	setCommsMessage("Now for the olivine 1's digit. For example, for 23.5, the 1's digit is 3")
																	for p=0,9 do
																		addCommsReply(string.format("1's digit %i",p),function()
																			print("input olivine 1's:",p)
																			setCommsMessage("And one digit after the decimal point. For example, for 23.5, the digit after the decimal point is 5")
																			for q=0,9 do
																				addCommsReply(string.format("after decimal digit %i",q),function()
																					print("input olivine after decimal:",q)
																					print(string.format("olivine: %.1f",o*10 + p + q/10))
																					--setCommsMessage(string.format("osmium: %.1f\niridium: %.1f\nOlivine: %.1f",i*10 + j + k/10,l*10 + m + n/10,o*10 + p + q/10))
																					setCommsMessage(string.format("Osmium: %.1f\nIridium: %.1f\nOlivine: %.1f\nThe Nickel 10's digit. For example, for 23.5, the 10's digit is 2",i*10 + j + k/10,l*10 + m + n/10,o*10 + p + q/10))
																					for r=0,9 do
																						addCommsReply(string.format("10's digit %i",r),function()
																							print("input nickel 10's:",r)
																							setCommsMessage("Now for the nickel 1's digit. For example, for 23.5, the 1's digit is 3")
																							for s=0,9 do
																								addCommsReply(string.format("1's digit %i",s),function()
																									print("input nickel 1's:",s)
																									setCommsMessage("And one digit after the decimal point. For example, for 23.5, the digit after the decimal point is 5")
																									for t=0,9 do
																										addCommsReply(string.format("after decimal digit %i",t),function()
																											print("input nickel after decimal:",t)
																											print(string.format("nickel: %.1f",r*10 + s + t/10))
																											--setCommsMessage(string.format("osmium: %.1f\niridium: %.1f\nOlivine: %.1f\nNickel: %.1f",i*10 + j + k/10,l*10 + m + n/10,o*10 + p + q/10,r*10 + s + t/10))
																											local reported_percentages = string.format("osmium: %.1f\niridium: %.1f\nOlivine: %.1f\nNickel: %.1f",i*10 + j + k/10,l*10 + m + n/10,o*10 + p + q/10,r*10 + s + t/10)
																											if target_asteroid.osmium == i*10 + j + k/10 and
																												target_asteroid.iridium == l*10 + m + n/10 and
																												target_asteroid.olivine == o*10 + p + q/10 and
																												target_asteroid.nickel == r*10 + s + t/10 then
																												setCommsMessage(string.format("That's it! Your reported compositional percentages:\n%s\n...exactly match my recorded compositional percentages! Now I need you to take me to within 5 units of the asteroid. You may want to put a waypoint on it",reported_percentages))
																												player.asteroid_identified = true
																											else
																												setCommsMessage(string.format("Unfortunately, those compositional percentages you provided:\n%s\n...do not match the asteroid I am looking for. But don't give up! Please keep looking and contact me when you find another asteroid candidate.",reported_percentages))
																											end
																											addCommsReply("Back",commsStation)
																										end)
																									end
																									addCommsReply("Back",commsStation)
																								end)
																							end
																							addCommsReply("Back",commsStation)
																						end)
																					end
																					addCommsReply("Back",commsStation)
																				end)
																			end
																			addCommsReply("Back",commsStation)
																		end)
																	end
																	addCommsReply("Back",commsStation)
																end)
															end
															addCommsReply("Back",commsStation)
														end)
													end
													addCommsReply("Back",commsStation)
												end)
											end
											addCommsReply("Back",commsStation)
										end)
									end
									addCommsReply("Back",commsStation)
								end)
							end
							addCommsReply("Back",commsStation)
						end)
					end
					addCommsReply("Back",commsStation)
				end)
			end
			addCommsReply("Back",commsStation)
		end)
		addCommsReply("Back",commsStation)
	end)
end
function contactJennyMcguireAfterAsteroidIdentified()
	if target_asteroid ~= nil then
		if player.asteroid_upgrade == nil then
			addCommsReply("Contact Jenny McGuire",function()
				if player.jenny_data_revealed == nil then
					local jenny_prompt = ""
					if player.jenny_aboard then
						jenny_prompt = string.format("Communication routed to guest quarters aboard %s\n\n",player:getCallSign())
					end
					setCommsMessage(string.format("%sYes? What can I do for you?",jenny_prompt))
					addCommsReply("What were those asteroid compositional percentages?",function()
						setCommsMessage(string.format("Osmium: %.1f\nIridium: %.1f\nOlivine: %.1f\nNickel: %.1f",target_asteroid.osmium,target_asteroid.iridium,target_asteroid.olivine,target_asteroid.nickel))
						addCommsReply("Back",commsStation)
					end)
					if target_asteroid ~= nil and target_asteroid:isValid() then
						if distance(player,target_asteroid) < 1500 then
							addCommsReply("Asteroid under 1.5 units away",function()
								local vx, vy = player:getVelocity()
								if vx ~= 0 or vy ~= 0 then
									setCommsMessage(string.format("%s must come to a complete stop before I can deactivate the cloaking mechanism",player:getCallSign()))
								else
									setCommsMessage("Cloaking mechanism deactivated, please retrieve my data store")
									local px, py = player:getPosition()
									player.jenny_data_revealed = true
									Artifact():setDescriptions("Stasis container","Stasis container with a high density data store inside"):setScanningParameters(1,2):allowPickup(true):setPosition((px+target_asteroid_x)/2,(py+target_asteroid_y)/2):setModel("SensorBuoyMKI"):onPickUp(function(self,grabber)
										grabber:addToShipLog(string.format("[Jenny McGuire] Thank you for picking up my research for me, %s. Next time you dock with %s you can get the upgrade I promised",grabber:getCallSign(),first_station:getCallSign()),"Magenta")
										first_station.asteroid_upgrade = true
									end)
								end
								addCommsReply("Back",commsStation)
							end)
						else
							addCommsReply("What is the asteroid approach procedure?",function()
								if player.jenny_aboard then
									setCommsMessage("Get within 1.5 units of the asteroid and contact me. I will deactivate the cloaking mechanism on my research data store so that you can then pick it up")
								else
									setCommsMessage(string.format("First, you have to pick me up from %s",first_station:getCallSign()))
								end
								addCommsReply("Back",commsStation)
							end)
						end
					else
						addCommsReply("The asteroid may have been destroyed",function()
							setCommsMessage("So it seems. Looks like I'll have to find another asteroid. Thanks for your help.")
							addCommsReply("Back",commsStation)
						end)
					end
				else
					if first_station.asteroid_upgrade then
						setCommsMessage(string.format("Thanks for getting my research for me. Dock with %s to get the upgrade",first_station:getCallSign()))
					else
						setCommsMessage("Please retrieve my data store")
					end
				end
				addCommsReply("Back",commsStation)
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
	if exuari_harassment_upgrade then
		if player.asteroid_search ~= nil then
			if player.asteroid_identified then
				contactJennyMcguireAfterAsteroidIdentified()
			else
				contactJennyMcguire()
			end
		end
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
		addCommsReply("Docking services status", function()
	 		local ctd = comms_target.comms_data
			local service_status = string.format("Station %s docking services status:",comms_target:getCallSign())
			if comms_target:getRestocksScanProbes() then
				service_status = string.format("%s\nReplenish scan probes.",service_status)
			else
				if comms_target.probe_fail_reason == nil then
					local reason_list = {
						"Cannot replenish scan probes due to fabrication unit failure.",
						"Parts shortage prevents scan probe replenishment.",
						"Station management has curtailed scan probe replenishment for cost cutting reasons.",
					}
					comms_target.probe_fail_reason = reason_list[math.random(1,#reason_list)]
				end
				service_status = string.format("%s\n%s",service_status,comms_target.probe_fail_reason)
			end
			if comms_target:getRepairDocked() then
				service_status = string.format("%s\nShip hull repair.",service_status)
			else
				if comms_target.repair_fail_reason == nil then
					reason_list = {
						"We're out of the necessary materials and supplies for hull repair.",
						"Hull repair automation unavailable whie it is undergoing maintenance.",
						"All hull repair technicians quarantined to quarters due to illness.",
					}
					comms_target.repair_fail_reason = reason_list[math.random(1,#reason_list)]
				end
				service_status = string.format("%s\n%s",service_status,comms_target.repair_fail_reason)
			end
			if comms_target:getSharesEnergyWithDocked() then
				service_status = string.format("%s\nRecharge ship energy stores.",service_status)
			else
				if comms_target.energy_fail_reason == nil then
					reason_list = {
						"A recent reactor failure has put us on auxiliary power, so we cannot recharge ships.",
						"A damaged power coupling makes it too dangerous to recharge ships.",
						"An asteroid strike damaged our solar cells and we are short on power, so we can't recharge ships right now.",
					}
					comms_target.energy_fail_reason = reason_list[math.random(1,#reason_list)]
				end
				service_status = string.format("%s\n%s",service_status,comms_target.energy_fail_reason)
			end
			if comms_target.comms_data.jump_overcharge then
				service_status = string.format("%s\nMay overcharge jump drive",service_status)
			end
			if comms_target.comms_data.probe_launch_repair then
				service_status = string.format("%s\nMay repair probe launch system",service_status)
			end
			if comms_target.comms_data.hack_repair then
				service_status = string.format("%s\nMay repair hacking system",service_status)
			end
			if comms_target.comms_data.scan_repair then
				service_status = string.format("%s\nMay repair scanners",service_status)
			end
			if comms_target.comms_data.combat_maneuver_repair then
				service_status = string.format("%s\nMay repair combat maneuver",service_status)
			end
			if comms_target.comms_data.self_destruct_repair then
				service_status = string.format("%s\nMay repair self destruct system",service_status)
			end
			setCommsMessage(service_status)
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
		local has_gossip = random(1,100) < (100 - (30 * (difficulty - .5)))
		if (comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "") or
			(comms_target.comms_data.history ~= nil and comms_target.comms_data.history ~= "") or
			(comms_source:isFriendly(comms_target) and comms_target.comms_data.gossip ~= nil and comms_target.comms_data.gossip ~= "" and has_gossip) then
			addCommsReply("Tell me more about your station", function()
				local ctd = comms_target.comms_data
				setCommsMessage("What would you like to know?")
				if comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "" then
					addCommsReply("General information", function()
						setCommsMessage(ctd.general)
						addCommsReply("Back", commsStation)
					end)
				end
				if ctd.history ~= nil and ctd.history ~= "" then
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
							ship:setCommsScript(""):setCommsFunction(commsShip)
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
							ship:setCommsScript(""):setCommsFunction(commsShip)
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
							ship:setCommsScript(""):setCommsFunction(commsShip)
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
-- Return the number of reputation points that a specified service costs for the current player.
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
					if shipCommsDiagnostic then print("player has room to purchase") end
					for good, goodData in pairs(comms_data.goods) do
						if shipCommsDiagnostic then print("in freighter goods loop") end
						if goodData.quantity > 0 then
							if shipCommsDiagnostic then print("found something to sell") end
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
				if shipCommsDiagnostic then print("average frienliness branch") end
				if comms_source.cargo > 0 then
					if shipCommsDiagnostic then print("player has room to purchase") end
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						if shipCommsDiagnostic then print("goods or equipment type freighter") end
						for good, goodData in pairs(comms_data.goods) do
							if shipCommsDiagnostic then print("in freighter cargo loop") end
							if goodData.quantity > 0 then
								if shipCommsDiagnostic then print("Found something to sell") end
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
						if shipCommsDiagnostic then print("not a goods or equipment freighter") end
						for good, goodData in pairs(comms_data.goods) do
							if shipCommsDiagnostic then print("in freighter cargo loop") end
							if goodData.quantity > 0 then
								if shipCommsDiagnostic then print("found something to sell") end
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
				if shipCommsDiagnostic then print("least friendly branch") end
				if comms_source.cargo > 0 then
					if shipCommsDiagnostic then print("player has room for purchase") end
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						if shipCommsDiagnostic then print("goods or equipment freighter") end
						for good, goodData in pairs(comms_data.goods) do
							if shipCommsDiagnostic then print("in freighter cargo loop") end
							if goodData.quantity > 0 then
								if shipCommsDiagnostic then print("found something to sell") end
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
--	Non-standard enemy ships
function adderMk3(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adder MK4"):orderRoaming()
	ship:setTypeName("Adder MK3")
	ship:setHullMax(35)		--weaker hull (vs 40)
	ship:setHull(35)
	ship:setShieldsMax(15)	--weaker shield (vs 20)
	ship:setShields(15)
	ship:setRotationMaxSpeed(35)	--faster maneuver (vs 20)
	if queryScienceDatabase("Ships","Starfighter","Adder MK3") == nil then
		local starfighter_db = queryScienceDatabase("Ships","Starfighter")
		starfighter_db:addEntry("Adder MK3")
		addShipToDatabase(
			queryScienceDatabase("Ships","Starfighter","Adder MK4"),	--base ship database entry
			queryScienceDatabase("Ships","Starfighter","Adder MK3"),	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Adder MK3 is one of the first of the Adder line to meet with some success. A large number of them were made before the manufacturer went through its first bankruptcy. There has been a recent surge of purchases of the Adder MK3 in the secondary market due to its low price and its similarity to subsequent models. Compared to the Adder MK4, the Adder MK3 has weaker shields and hull, but a faster turn speed",
			{
				{key = "Small tube 0", value = "20 sec"},	--torpedo tube direction and load speed
			},
			nil
		)
	end
	return ship
end
function adderMk7(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adder MK6"):orderRoaming()
	ship:setTypeName("Adder MK7")
	ship:setShieldsMax(40)	--stronger shields (vs 30)
	ship:setShields(40)
	ship:setBeamWeapon(0,30,0,900,5.0,2.0)	--narrower (30 vs 35) but longer (900 vs 800) beam
	if queryScienceDatabase("Ships","Starfighter","Adder MK7") == nil then
		local starfighter_db = queryScienceDatabase("Ships","Starfighter")
		starfighter_db:addEntry("Adder MK7")
		addShipToDatabase(
			queryScienceDatabase("Ships","Starfighter","Adder MK6"),	--base ship database entry
			queryScienceDatabase("Ships","Starfighter","Adder MK7"),	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The release of the Adder Mark 7 sent the manufacturer into a second bankruptcy. They made improvements to the Mark 7 over the Mark 6 like stronger shields and longer beams, but the popularity of their previous models, especially the Mark 5, prevented them from raising the purchase price enough to recoup the development and manufacturing costs of the Mark 7",
			{
				{key = "Small tube 0", value = "15 sec"},	--torpedo tube direction and load speed
			},
			nil
		)
	end
	return ship
end
function adderMk8(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adder MK5"):orderRoaming()
	ship:setTypeName("Adder MK8")
	ship:setShieldsMax(50)					--stronger shields (vs 30)
	ship:setShields(50)
	ship:setBeamWeapon(0,30,0,900,5.0,2.3)	--narrower (30 vs 35) but longer (900 vs 800) and stronger (2.3 vs 2.0) beam
	ship:setRotationMaxSpeed(30)			--faster maneuver (vs 25)
	if queryScienceDatabase("Ships","Starfighter","Adder MK8") == nil then
		local starfighter_db = queryScienceDatabase("Ships","Starfighter")
		starfighter_db:addEntry("Adder MK8")
		addShipToDatabase(
			queryScienceDatabase("Ships","Starfighter","Adder MK5"),	--base ship database entry
			queryScienceDatabase("Ships","Starfighter","Adder MK8"),	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"New management after bankruptcy revisited their most popular Adder Mark 5 model with improvements: stronger shields, longer and stronger beams and a faster turn speed. Thus was born the Adder Mark 8 model. Targeted to the practical but nostalgic buyer who must purchase replacements for their Adder Mark 5 fleet",
			{
				{key = "Small tube 0", value = "15 sec"},	--torpedo tube direction and load speed
			},
			nil
		)
	end
	return ship
end
function phobosR2(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3"):orderRoaming()
	ship:setTypeName("Phobos R2")
	ship:setWeaponTubeCount(1)			--one tube (vs 2)
	ship:setWeaponTubeDirection(0,0)	
	ship:setImpulseMaxSpeed(55)			--slower impulse (vs 60)
	ship:setRotationMaxSpeed(15)		--faster maneuver (vs 10)
	if queryScienceDatabase("Ships","Frigate","Phobos R2") == nil then
		local frigate_db = queryScienceDatabase("Ships","Frigate")
		frigate_db:addEntry("Phobos R2")
		addShipToDatabase(
			queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
			queryScienceDatabase("Ships","Frigate","Phobos R2"),	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Phobos R2 model is very similar to the Phobos T3. It's got a faster turn speed, but only one missile tube",
			{
				{key = "Tube 0", value = "60 sec"},	--torpedo tube direction and load speed
			},
			nil
		)
	end
	return ship
end
function addShipToDatabase(base_db,modified_db,ship,description,tube_directions,jump_range)
	modified_db:setLongDescription(description)
	modified_db:setImage(base_db:getImage())
	modified_db:setKeyValue("Class",base_db:getKeyValue("Class"))
	modified_db:setKeyValue("Sub-class",base_db:getKeyValue("Sub-class"))
	modified_db:setKeyValue("Size",base_db:getKeyValue("Size"))
	local shields = ship:getShieldCount()
	if shields > 0 then
		local shield_string = ""
		for i=1,shields do
			if shield_string == "" then
				shield_string = string.format("%i",math.floor(ship:getShieldMax(i-1)))
			else
				shield_string = string.format("%s/%i",shield_string,math.floor(ship:getShieldMax(i-1)))
			end
		end
		modified_db:setKeyValue("Shield",shield_string)
	end
	modified_db:setKeyValue("Hull",string.format("%i",math.floor(ship:getHullMax())))
	modified_db:setKeyValue("Move speed",string.format("%.1f u/min",ship:getImpulseMaxSpeed()*60/1000))
	modified_db:setKeyValue("Turn speed",string.format("%.1f deg/sec",ship:getRotationMaxSpeed()))
	if ship:hasJumpDrive() then
		if jump_range == nil then
			local base_jump_range = base_db:getKeyValue("Jump range")
			if base_jump_range ~= nil and base_jump_range ~= "" then
				modified_db:setKeyValue("Jump range",base_jump_range)
			else
				modified_db:setKeyValue("Jump range","5 - 50 u")
			end
		else
			modified_db:setKeyValue("Jump range",jump_range)
		end
	end
	if ship:hasWarpDrive() then
		modified_db:setKeyValue("Warp Speed",string.format("%.1f u/min",ship:getWarpSpeed()*60/1000))
	end
	local key = ""
	if ship:getBeamWeaponRange(0) > 0 then
		local bi = 0
		repeat
			local beam_direction = ship:getBeamWeaponDirection(bi)
			if beam_direction > 315 and beam_direction < 360 then
				beam_direction = beam_direction - 360
			end
			key = string.format("Beam weapon %i:%i",ship:getBeamWeaponDirection(bi),ship:getBeamWeaponArc(bi))
			while(modified_db:getKeyValue(key) ~= "") do
				key = " " .. key
			end
			modified_db:setKeyValue(key,string.format("%.1f Dmg / %.1f sec",ship:getBeamWeaponDamage(bi),ship:getBeamWeaponCycleTime(bi)))
			bi = bi + 1
		until(ship:getBeamWeaponRange(bi) < 1)
	end
	local tubes = ship:getWeaponTubeCount()
	if tubes > 0 then
		if tube_directions ~= nil then
			for i=1,#tube_directions do
				modified_db:setKeyValue(tube_directions[i].key,tube_directions[i].value)
			end
		end
		local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
		for _, missile_type in ipairs(missile_types) do
			local max_storage = ship:getWeaponStorageMax(missile_type)
			if max_storage > 0 then
				modified_db:setKeyValue(string.format("Storage %s",missile_type),string.format("%i",max_storage))
			end
		end
	end
end
function spawnEnemies(xOrigin, yOrigin, danger, enemyFaction, perimeter_min, perimeter_max)
	if spawn_enemy_diagnostic then print("top of spawnEnemies function") end
	if enemyFaction == nil then
		enemyFaction = "Kraylor"
	end
	if danger == nil then 
		danger = 1
	end
	if spawn_enemy_diagnostic then print(string.format("x: %.1f, y: %.1f, danger: %.1f, faction: %s",xOrigin,yOrigin,danger,enemyFaction)) end
	local enemyStrength = math.max(danger * difficulty * playerPower(),5)
	local enemyPosition = 0
	local sp = irandom(400,900)			--random spacing of spawned group
	local deployConfig = random(1,100)	--randomly choose between squarish formation and hexagonish formation
	if spawn_enemy_diagnostic then print(string.format("enemy strength: %.1f, spacing: %i, deploy config: %.1f",enemyStrength,sp,deployConfig)) end
	local enemyList = {}
	-- Reminder: stsl and stnl are ship template score and name list
	local prefix = generateCallSignPrefix(1)
	while enemyStrength > 0 do
		if spawn_enemy_diagnostic then print("top of spawn while loop") end
		local shipTemplateType = irandom(1,#stsl)
		if spawn_enemy_diagnostic then print(string.format("temporary ship template type: %s",shipTemplateType)) end
		while stsl[shipTemplateType] > enemyStrength * 1.1 + 5 do
			shipTemplateType = irandom(1,#stsl)
			if spawn_enemy_diagnostic then print(string.format("temporary ship template type: %s",shipTemplateType)) end
		end		
		if spawn_enemy_diagnostic then print(string.format("chosen ship template type: %s",shipTemplateType)) end
		local ship = nil
		if stbl[shipTemplateType] then
			ship = CpuShip():setFaction(enemyFaction):setTemplate(stnl[shipTemplateType]):orderRoaming()
		else
			ship = nsfl[shipTemplateType](enemyFaction)
		end
		enemyPosition = enemyPosition + 1
		if deployConfig < 50 then
			ship:setPosition(xOrigin+fleetPosDelta1x[enemyPosition]*sp,yOrigin+fleetPosDelta1y[enemyPosition]*sp)
		else
			ship:setPosition(xOrigin+fleetPosDelta2x[enemyPosition]*sp,yOrigin+fleetPosDelta2y[enemyPosition]*sp)
		end
		ship:setCommsScript(""):setCommsFunction(commsShip)
		table.insert(enemyList, ship)
		enemyStrength = enemyStrength - stsl[shipTemplateType]
		ship:setCallSign(generateCallSign(prefix))
		if spawn_enemy_diagnostic then print(string.format("Adjusted enemy strength (loop control): %.1f",enemyStrength)) end
		if spawn_enemy_diagnostic then print("end of spawn while loop") end
	end
	if perimeter_min ~= nil then
		if spawn_enemy_diagnostic then print("perimeter minimum is not nil") end
		local enemy_angle = random(0,360)
		local circle_increment = 360/#enemyList
		local perimeter_deploy = perimeter_min
		if spawn_enemy_diagnostic then print(string.format("enemy angle: %.1f, circle increment: %.1f, perimeter deploy: %i",enemy_angle,circle_increment,perimeter_deploy)) end
		if perimeter_max ~= nil then
			perimeter_deploy = random(perimeter_min,perimeter_max)
		end
		for _, enemy in pairs(enemyList) do
			local dex, dey = vectorFromAngle(enemy_angle,perimeter_deploy)
			enemy:setPosition(xOrigin+dex, yOrigin+dey)
			if spawn_enemy_diagnostic then print(string.format("deploy coordinates: x: %.1f, y: %.f, angle: %.1f",xOrigin+dex,yOrigin+dey,enemy_angle)) end
			enemy_angle = enemy_angle + circle_increment
		end
	end
	if spawn_enemy_diagnostic then print("end of spawn spawn enemies function") end
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
--	Player ship improvements
function addForwardBeam()
	if comms_source.add_forward_beam == nil then
		addCommsReply("Add beam weapon", function()
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
				setCommsMessage("A beam wepon has been added to your ship")
			else
				setCommsMessage(string.format("%s cannot add a beam weapon to your ship unless you provide %s",ctd.character,ctd.characterGood))
			end
			addCommsReply("Back", commsStation)
		end)
	end
end
function efficientBatteries()
	if comms_source.efficientBatteriesUpgrade == nil then
		addCommsReply("Increase battery efficiency", function()
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
				setCommsMessage(string.format("%s: I appreciate the %s and %s. You have a 50%% greater energy capacity due to increased battery efficiency",ctd.character,ctd.characterGood,ctd.characterGood2))
			else
				setCommsMessage(string.format("%s: You need to bring me some %s and %s before I can increase your battery efficiency",ctd.character,ctd.characterGood,ctd.characterGood2))
			end
			addCommsReply("Back", commsStation)
		end)
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
					setCommsMessage(string.format("%s reduced your Beam cycle time by 25%% at no cost in trade with the message, 'Go get those Kraylors.'",ctd.character))
				end
			else
				setCommsMessage("Your ship type does not support a beam weapon upgrade.")				
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
				end
				if fatalityChance > 0 then
					crewFate(p,fatalityChance)
				end
			else	--no repair crew left
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
								p:addCustomMessage("Engineering","coolant_recovery","Automated systems have recovered some coolant")
							end
							if p:hasPlayerAtPosition("Engineering+") then
								p:addCustomMessage("Engineering+","coolant_recovery_plus","Automated systems have recovered some coolant")
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
				p:addCustomMessage("Engineering",repairCrewFatality,"One of your repair crew has perished")
			end
			if p:hasPlayerAtPosition("Engineering+") then
				local repairCrewFatalityPlus = "repairCrewFatalityPlus"
				p:addCustomMessage("Engineering+",repairCrewFatalityPlus,"One of your repair crew has perished")
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
					p:addCustomMessage("Engineering",repairCrewFatality,"One of your repair crew has perished")
				end
				if p:hasPlayerAtPosition("Engineering+") then
					local repairCrewFatalityPlus = "repairCrewFatalityPlus"
					p:addCustomMessage("Engineering+",repairCrewFatalityPlus,"One of your repair crew has perished")
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
					p:addCustomMessage("Engineering",coolantLoss,"Damage has caused a loss of coolant")
				end
				if p:hasPlayerAtPosition("Engineering+") then
					local coolantLossPlus = "coolantLossPlus"
					p:addCustomMessage("Engineering+",coolantLossPlus,"Damage has caused a loss of coolant")
				end
			else
				local named_consequence = consequence_list[consequence-2]
				if named_consequence == "probe" then
					p:setCanLaunchProbe(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","probe_launch_damage_message","The probe launch system has been damaged")
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","probe_launch_damage_message_plus","The probe launch system has been damaged")
					end
				elseif named_consequence == "hack" then
					p:setCanHack(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","hack_damage_message","The hacking system has been damaged")
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","hack_damage_message_plus","The hacking system has been damaged")
					end
				elseif named_consequence == "scan" then
					p:setCanScan(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","scan_damage_message","The scanners have been damaged")
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","scan_damage_message_plus","The scanners have been damaged")
					end
				elseif named_consequence == "combat_maneuver" then
					p:setCanCombatManeuver(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","combat_maneuver_damage_message","Combat maneuver has been damaged")
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","combat_maneuver_damage_message_plus","Combat maneuver has been damaged")
					end
				elseif named_consequence == "self_destruct" then
					p:setCanSelfDestruct(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","self_destruct_damage_message","Self destruct system has been damaged")
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","self_destruct_damage_message_plus","Self destruct system has been damaged")
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
		for _, wt in pairs(transports_around_independent_trio) do
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
		local help_message = string.format("[%s in %s] Hostile Exuari approach. Help us, please. We cannot defend ourselves. Your ship is the only thing that stands between us and destruction.",first_station:getCallSign(),first_station:getSectorName())
		if difficulty < 1 then
			help_message = string.format("%s\n\nWe think there is an Exuari base hiding in a nebula in sector %s",help_message,concealing_nebula:getSectorName())
		end
		player.harass_message_sent = first_station:sendCommsMessage(player,help_message)
		if player.harass_message_sent then
			plot1_message = string.format("%s has asked for help against the Exuari",first_station:getCallSign())
			plot1_type = "optional"
			plot1_danger = .5
			plot1_fleets_destroyed = 0
			plot1_fleets_spawned = 0
			plot1_defeat_message = string.format("Station %s destroyed",first_station:getCallSign())
		end
	end
	if player.captain_log < 1 then
		if getScenarioTime() > 90 and player.harass_message_sent then
			player:addToShipLog(string.format("[Captain's Log] We have started our initial shakedown cruise of %s, a %s class ship. The crew are glad to be moving up from the class three freighter we used to run. After several years of doing cargo delivery runs and personnel transfers, it's nice to be on a ship with more self reliance. We've got beam weapons! Our previous ship was defenseless. Unfortunately, our impulse engines are not as fast as our previous ship, but we might be able to fix that. That's the kind of compromise you make when you purchase surplus military hardware. I suspect that we got such a good deal on the ship because the previous owner, the governer of station %s, has an ulterior motive. After all, we are the best qualified to run this ship in the sector and we have not seen any other friendly armed ships around here.",player:getCallSign(),player:getTypeName(),first_station:getCallSign()),"Green")
			player.captain_log = 1
		end
	end
	if player.help_with_exuari_base_message == nil then
		if getScenarioTime() > 600 and exuari_harassing_station ~= nil and exuari_harassing_station:isValid() then
			player:addToShipLog(string.format("[Station %s] Based on our observation of the Exuari base %s in %s, we think it will continue to launch harassing spacecraft in our direction. We know it's a large target for a small fighter, but we believe you can destroy it, %s. We would be very grateful if you would do just that. Our defenses are very limited.",first_station:getCallSign(),exuari_harassing_station:getCallSign(),exuari_harassing_station:getSectorName(),player:getCallSign()),"Magenta")
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
		for _, enemy in pairs(plot1_fleet) do
			if enemy ~= nil and enemy:isValid() then
				plot1_fleet_count = plot1_fleet_count + 1
				break
			end
		end
		if exuari_harass_diagnostic then print("count of ships in fleet: " .. plot1_fleet_count) end
		if plot1_fleet_count < 1 then
			if exuari_harassing_station ~= nil and exuari_harassing_station:isValid() then
				if plot1_timer == nil then
					plot1_timer = delta + 500 + random(1,30) - (difficulty * 100)
					plot1_fleets_destroyed = plot1_fleets_destroyed + 1
				end
				plot1_timer = plot1_timer - delta
				if plot1_timer < 0 then
					plot1_danger = plot1_danger + .75
					plot1_fleet_spawned = false
					plot1_timer = nil
				end
			else
				plot1 = nil
				plot1_type = nil
				plot1_mission_count = plot1_mission_count + 1
				plot1_timer = nil
				plot1_defensive_timer = nil
				plot1_danger = nil
				plot1_fleet_spawned = nil
				plot1_defensive_fleet_spawned = nil
				player:addReputationPoints(100)
				first_station:sendCommsMessage(player,"Thanks for taking care of that Exuari base and all the Exuari ships it deployed. Dock with us for a token of our appreciation")
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
		for _, enemy in pairs(plot1_fleet) do
			enemy:orderFlyTowards(spx,spy)
		end
		plot1_fleet_spawned = true
		plot1_fleets_spawned = plot1_fleets_spawned + 1
	end
	if plot1_independent_fleet_spawned then
		plot1_fleet_count = 0
		for _, enemy in pairs(plot1_independent_fleet) do
			if enemy ~= nil and enemy:isValid() then
				plot1_fleet_count = plot1_fleet_count + 1
			end
		end
		if plot1_fleet_count < 1 then
			plot1_independent_fleet_spawned = false
		end
	else
		if exuari_harassing_station ~= nil and exuari_harassing_station:isValid() then
			if (plot1_danger % 2) == 0 then
				spx, spy = first_station:getPosition()
				plot1_independent_fleet = spawnEnemies(spx,spy,plot1_danger,"Independent",2000)
				for _, enemy in pairs(plot1_independent_fleet) do
					enemy:orderDefendTarget(first_station)
					enemy:setScannedByFaction("Independent",true)
				end
				plot1_independent_fleet_spawned = true
			end
		end
	end
	if plot1_defensive_fleet_spawned then
		if exuari_harass_diagnostic then print("defensive fleet spawned") end
		plot1_fleet_count = 0
		for _, enemy in pairs(plot1_defensive_fleet) do
			if enemy ~= nil and enemy:isValid() then
				plot1_fleet_count = plot1_fleet_count + 1
				local current_order = enemy:getOrder()
				--print("start order: " .. enemy:getCallSign() .. " " .. current_order .. " " .. enemy:getOrderTarget():getCallSign())
				if current_order == "Defend Target" then
					if enemy:getWeaponTubeCount() > 0 then
						local low_on_missiles = false
						local zero_missiles = true
						for _, missile_type in ipairs(missile_types) do
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
						for _, obj in pairs(evaluate_objects) do
							if obj.typeName == "PlayerSpaceship" then
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
						for _, obj in pairs(evaluate_objects) do
							if obj.typeName == "PlayerSpaceship" then
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
					for _, obj in pairs(evaluate_objects) do
						if obj.typeName == "PlayerSpaceship" then
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
								for _, missile_type in ipairs(missile_types) do
									if enemy:getWeaponStorage(missile_type) > 0 then
										enemy:orderDefendTarget(exuari_harassing_station)
										break
									end
								end
							end
						end
					else
						local full_on_missiles = true
						for _, missile_type in ipairs(missile_types) do
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
		if exuari_harass_diagnostic then print("count of ships in fleet: " .. plot1_fleet_count) end
		if plot1_fleet_count < 1 then
			if exuari_harassing_station ~= nil and exuari_harassing_station:isValid() then
				if plot1_defensive_timer == nil then
					plot1_defensive_timer = delta + 500 + random(1,30)- (difficulty * 100)
				end
				plot1_defensive_timer = plot1_defensive_timer - delta
				if plot1_defensive_timer < 0 then
					plot1_defensive_fleet_spawned = false
					plot1_defensive_timer = nil
				end
			end
		end
	else
		if exuari_harass_diagnostic then print("defensive fleet not spawned, spawning") end
		if exuari_harassing_station ~= nil and exuari_harassing_station:isValid() then
			spx, spy = exuari_harassing_station:getPosition()
			plot1_defensive_fleet = spawnEnemies(spx,spy,1,"Exuari",2000)
			if exuari_harass_diagnostic then print("back from spawnEnemies function") end
			for _, enemy in pairs(plot1_defensive_fleet) do
				enemy:orderDefendTarget(exuari_harassing_station)
			end
			if exuari_harass_diagnostic then print("Orders given to defensive fleet") end
			plot1_defensive_fleet_spawned = true
		end
	end
	if plot1_last_defense then
		if exuari_harassing_station ~= nil and exuari_harassing_station:isValid() then
			for _, enemy in pairs(plot1_last_defense_fleet) do
				if enemy ~= nil and enemy:isValid() then
					currrent_order = enemy:getOrder()
					if current_order == "Defend Target" then
						if enemy:getWeaponTubeCount() > 0 then
							low_on_missiles = false
							zero_missiles = true
							for _, missile_type in ipairs(missile_types) do
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
							for _, obj in pairs(evaluate_objects) do
								if obj.typeName == "PlayerSpaceship" then
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
							for _, obj in pairs(evaluate_objects) do
								if obj.typeName == "PlayerSpaceship" then
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
						for _, obj in pairs(evaluate_objects) do
							if obj.typeName == "PlayerSpaceship" then
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
									for _, missile_type in ipairs(missile_types) do
										if enemy:getWeaponStorage(missile_type) > 0 then
											enemy:orderDefendTarget(exuari_harassing_station)
											break
										end
									end
								end
							end
						else
							full_on_missiles = true
							for _, missile_type in ipairs(missile_types) do
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
				for _, enemy in ipairs(plot1_last_defense_fleet) do
					enemy:orderDefendTarget(exuari_harassing_station)
					if ship_call_signs == "" then
						ship_call_signs = enemy:getCallSign()
					else
						ship_call_signs = ship_call_signs .. ", " .. enemy:getCallSign()
					end
				end
				if #plot1_last_defense_fleet > 1 then
					player:addToShipLog(string.format("%s just launched these ships: %s",exuari_harassing_station:getCallSign(),ship_call_signs),"Red")
				else
					player:addToShipLog(string.format("%s just launched %s",exuari_harassing_station:getCallSign(),ship_call_signs),"Red")
				end
				plot1_last_defense = true
			end
		end
	end
end
function transitionContract(delta)
	local p = getPlayerShip(-1)
	local sx, sy = transition_station:getPosition()
	if transition_station.in_fleet == nil then
		if distance(p,transition_station) <= 45000 then
			local px, py = p:getPosition()
			transition_station.in_fleet = spawnEnemies((sx+px)/2,(sy+py)/2,2,"Exuari")
			for _,enemy in ipairs(transition_station.in_fleet) do
				enemy:orderFlyTowards(sx,sy)
			end
			transition_station.out_fleet = spawnEnemies((sx+px)/2,(sy+py)/2,2,"Exuari")
			for _,enemy in ipairs(transition_station.out_fleet) do
				enemy:orderFlyTowards(px,py)
			end
		end
	else
		local fleet_count = 0
		for _,enemy in pairs(transition_station.out_fleet) do
			if enemy ~= nil and enemy:isValid() then
				fleet_count = fleet_count + 1
				if string.find(enemy:getOrder(),"Defend") then
					enemy:orderFlyTowards(sx,sy)
				end
			end
		end
		for _,enemy in pairs(transition_station.in_fleet) do
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
		local p = getPlayerShip(-1)
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
					p:addToShipLog(string.format("[%s] Your delivery contract calls for food, medicine, dilithium and tritanium. Return when you have all four of these and we'll consider your contract fulfilled",comms_target:getCallSign()),"Magenta")
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
					local bi = 0
					repeat
						local tempArc = p:getBeamWeaponArc(bi)
						local tempDir = p:getBeamWeaponDirection(bi)
						local tempRng = p:getBeamWeaponRange(bi)
						local tempCyc = p:getBeamWeaponCycleTime(bi)
						local tempDmg = p:getBeamWeaponDamage(bi)
						p:setBeamWeapon(bi,tempArc,tempDir,tempRng,tempCyc*(2/3),tempDmg)
						bi = bi + 1
					until(comms_source:getBeamWeaponRange(bi) < 1)
					p:addToShipLog(string.format("[%s] Thanks for the cargo, %s. We'll make good use of it. We've added 100 units to your battery capacity and reduced your beam cycle time by 1/3. Enjoy your visit to the %s system",supply_depot_station:getCallSign(),p:getCallSign(),planet_star:getCallSign()),"Magenta")
					p.long_distance_upgrade = true
					plot1 = kraylorDiversionarySabotage
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
				for _, enemy in ipairs(enemy_fleet) do
					enemy:orderAttack(supply_depot_station)
					table.insert(supply_sabotage_fleet,enemy)
				end
				spx, spy = vectorFromAngle(random(0,360),random(15000,25000) - (difficulty*3000))
				enemy_fleet = spawnEnemies(sdx+spx,sdy+spy,3,"Exuari")
				for _, enemy in ipairs(enemy_fleet) do
					enemy:orderAttack(p)
					table.insert(supply_sabotage_fleet,enemy)
				end
				spx, spy = vectorFromAngle(random(0,360),random(15000,25000) - (difficulty*3000))
				enemy_fleet = spawnEnemies(sdx+spx,sdy+spy,3,"Exuari")
				for _, enemy in ipairs(enemy_fleet) do
					enemy:orderRoaming()
					table.insert(supply_sabotage_fleet,enemy)
				end
			end
		else
			local fleet_count = 0
			for _,enemy in pairs(supply_sabotage_fleet) do
				if enemy ~= nil and enemy:isValid() then
					fleet_count = fleet_count + 1
				end
			end
			if fleet_count == 0 then
				supply_sabotage_fleet = nil
			end
		end
	else
		globalMessage("The supply depot station has been destroyed")
		victory("Exuari")
	end
end
function opportunisticPirates(delta)
	 if greedy_pirate_fleet == nil then
		if greedy_pirate_danger == nil then
			greedy_pirate_danger = 1
		else
			greedy_pirate_danger = greedy_pirate_danger + 1
		end
		local pirate_target = nil
		local target_attempts = 0
		repeat
			pirate_target = final_system_station_list[math.random(1,#final_system_station_list)]
			if pirate_target ~= nil then
				if not pirate_target:isValid() then
					pirate_target = nil
				end 
			end
			target_attempts = target_attempts + 1
		until(pirate_target ~= nil or target_attempts > 50)
		local ptx = star_x
		local pty = star_y
		if pirate_target ~= nil then
			ptx, pty = pirate_target:getPosition()
		end
		local gpx, gpy = vectorFromAngle(random(0,360),random(10000,30000))
		greedy_pirate_fleet = spawnEnemies(ptx+gpx,pty+gpy,greedy_pirate_danger,"Exuari")
		for _, enemy in ipairs(greedy_pirate_fleet) do
			enemy:orderFlyTowards(ptx,pty)
		end
	 else
		local pirate_count = 0
		for _, enemy in ipairs(greedy_pirate_fleet) do
			if enemy ~= nil and enemy:isValid() then
				pirate_count = pirate_count + 1
				break
			end
		end
		if pirate_count < 1 then
			if random(1,5000) <= 1 then
				greedy_pirate_fleet = nil
			end
		end
	 end
end
function kraylorDiversionarySabotage(delta)
	local sdx, sdy = planet_secondus_moon:getPosition()
	local rvx, rvy = vectorFromAngle(random(0,360),random(10000,20000))
	if kraylor_diversion_danger == nil then
		kraylor_diversion_danger = 3
	end
	if supply_depot_station ~= nil and supply_depot_station:isValid() then
		 sdx, sdy = supply_depot_station:getPosition()
	end
	if diversionary_sabotage_fleet == nil then
		diversionary_sabotage_fleet = spawnEnemies(sdx+rvx,sdy+rvy,kraylor_diversion_danger,"Kraylor")
		for _, enemy in ipairs(diversionary_sabotage_fleet) do
			rvx, rvy = vectorFromAngle(random(0,360),random(10000,20000))
			enemy:setPosition(sdx+rvx,sdy+rvy)
			if supply_depot_station ~= nil and supply_depot_station:isValid() then
				enemy:orderAttack(supply_depot_station)
			else
				enemy:orderFlyTowards(sdx,sdy)
			end
		end
		kraylor_sabotage_diversion_interval = 30
		kraylor_sabotage_diversion_timer = kraylor_sabotage_diversion_interval
	else
		kraylor_sabotage_diversion_timer = kraylor_sabotage_diversion_timer - delta
		if kraylor_sabotage_diversion_timer < 0 then
			kraylor_sabotage_diversion_timer = delta + kraylor_sabotage_diversion_interval
			if player.diversion_orders == nil then
				player.diversion_orders = "sent"
				player:addToShipLog("[Human Navy Regional Headquarters] All Human Navy vessels are hereby ordered to assist in the repelling of inbound Kraylor ships. We are not sure of their intent, but we are sure it is not good. Destroy them before they can destroy us","Red")
				player:addToShipLog(string.format("This includes you, %s",player:getCallSign()),"Magenta")
				primaryOrders = "Repel Kraylor"
			end
			local enemy_count = 0
			local enemy_close_to_supply = 0
			for _, enemy in pairs(diversionary_sabotage_fleet) do
				if enemy ~= nil and enemy:isValid() then
					enemy_count = enemy_count + 1
					if supply_depot_station ~= nil and supply_depot_station:isValid() then
						local distance_to_supply = distance(enemy,supply_depot_station)
						if distance_to_supply < 1500 then
							supply_depot_station.sabotaged = true
							if kraylor_planet_buster_timer == nil then
								kraylor_planet_buster_timer = 300
								plot6 = kraylorPlanetBuster
							end
						end
						if distance_to_supply < 7500 then
							enemy_close_to_supply = enemy_close_to_supply + 1
						end
					else
						if kraylor_planet_buster_timer == nil then
							kraylor_planet_buster_timer = 300
							plot6 = kraylorPlanetBuster
						end
					end
				end
			end
			if enemy_count < 1 then
				kraylor_diversion_danger = kraylor_diversion_danger + 1
				diversionary_sabotage_fleet = spawnEnemies(sdx+rvx,sdy+rvy,kraylor_diversion_danger,"Kraylor")
				for _, enemy in ipairs(diversionary_sabotage_fleet) do
					rvx, rvy = vectorFromAngle(random(0,360),random(10000,20000))
					enemy:setPosition(sdx+rvx,sdy+rvy)
					if supply_depot_station ~= nil and supply_depot_station:isValid() then
						if random(1,100) > kraylor_diversion_danger * 10 then
							enemy:orderAttack(supply_depot_station)
						else
							enemy:orderFlyTowards(sdx,sdy)
						end
					else
						enemy:orderFlyTowards(sdx,sdy)
					end
				end
			end
			if enemy_count < difficulty*10 then
				if enemy_close_to_supply < 1 then
					kraylor_diversion_danger = kraylor_diversion_danger + 1
					local kraylor_fleet = spawnEnemies(sdx+spx,sdy+spy,kraylor_diversion_danger,"Kraylor")
					for _, enemy in ipairs(kraylor_fleet) do
						rvx, rvy = vectorFromAngle(random(0,360),random(10000,20000))
						enemy:setPosition(sdx+rvx,sdy+rvy)
						local whim = math.random(1,3)
						if whim == 1 then
							if supply_depot_station ~= nil and supply_depot_station:isValid() then
								enemy:orderAttack(supply_depot_station)
							else
								enemy:orderFlyTowards(sdx,sdy)
							end
						elseif whim == 2 then
							enemy:orderRoaming()
						else
							enemy:orderAttack(player)
						end
						table.insert(diversionary_sabotage_fleet,enemy)
					end
				end
			else
				local angle = 0
				local angle_increment = 0
				if kraylor_defense_fleet == nil then
					kraylor_defense_fleet = spawnEnemies(sdx+rvx,sdy+rvy,kraylor_diversion_danger-2,"Human Navy")
					angle_increment = 360/#kraylor_defense_fleet
					angle = random(0,360)
					for _, ship in ipairs(kraylor_defense_fleet) do
						if supply_depot_station ~= nil and supply_depot_station:isValid() then
							rvx, rvy = vectorFromAngle(angle,1200)
							ship:setPosition(sdx+rvx,sdy+rvy)
							ship:orderDefendTarget(supply_depot_station)
						else
							rvx, rvy = vectorFromAngle(angle,secondus_moon_radius + 500)
							ship:setPosition(sdx+rvx,sdy+rvy)
							ship:orderDefendTarget(player)
						end
						angle = angle + angle_increment
					end
				else
					local defensive_ships = 0
					for _, ship in pairs(kraylor_defense_fleet) do
						if ship ~= nil and ship:isValid() then
							defensive_ships = defensive_ships + 1
						end
					end
					if defensive_ships < enemy_count/3 then
						local more_friendlies = spawnEnemies(sdx+rvx,sdy+rvy,kraylor_diversion_danger-2,"Human Navy")
						angle_increment = 360/#more_friendlies
						angle = random(0,360)
						for _, ship in ipairs(more_friendlies) do
							if supply_depot_station ~= nil and supply_depot_station:isValid() then
								rvx, rvy = vectorFromAngle(angle,1200)
								ship:setPosition(sdx+rvx,sdy+rvy)
								ship:orderDefendTarget(supply_depot_station)
							else
								rvx, rvy = vectorFromAngle(angle,secondus_moon_radius + 500)
								ship:setPosition(sdx+rvx,sdy+rvy)
								ship:orderDefendTarget(player)
							end
							angle = angle + angle_increment
							table.insert(kraylor_defense_fleet,ship)
						end
					end
					if kraylor_diversion_danger > 10 and enemy_close_to_supply > 0 and plot6 == nil then
						globalMessage("You successfully handled the Kraylor threat")
						victory("Human Navy")
					end
				end
			end
		end
	end
end
function kraylorPlanetBuster(delta)
	kraylor_planet_buster_timer = kraylor_planet_buster_timer - delta
	if kraylor_planet_buster_timer < 0 then
		kraylor_planet_buster_timer_interval = 60
		kraylor_planet_buster_timer = kraylor_planet_buster_timer_interval
		if kraylor_planetary_danger == nil then
			kraylor_planetary_danger = 4
		end
		local plx, ply = planet_secondus:getPosition()
		local mox = plx
		local moy = ply
		local rvx, rvy = vectorFromAngle(random(0,360),random(10000,20000))
		if planet_secondus_moon ~= nil then
			mox, moy = planet_secondus_moon:getPosition()
		end
		if planetary_attack_fleet == nil then
			planetary_attack_fleet = spawnEnemies(plx+rvx,ply+rvy,kraylor_planetary_danger,"Kraylor")
			for _, enemy in ipairs(planetary_attack_fleet) do
				rvx, rvy = vectorFromAngle(random(0,360),random(10000,20000))
				enemy:setPosition(plx+rvx,ply+rvy)
				if planet_secondus_moon ~= nil then
					enemy:orderFlyTowards(mox,moy)
				else
					enemy:orderFlyTowards(plx,ply)
				end
			end
		else
			local enemy_count = 0
			local enemy_close_to_planet_count = 0
			for _, enemy in pairs(planetary_attack_fleet) do
				if enemy ~= nil and enemy:isValid() then
					enemy_count = enemy_count + 1
					if planet_secondus_moon ~= nil then
						if distance(enemy,planet_secondus_moon) < (1500 + secondus_moon_radius) then
							local explosion_x, explosion_y = planet_secondus_moon:getPosition()
							local moon_name = planet_secondus_moon:getCallSign()
							planet_secondus_moon:destroy()
							ExplosionEffect():setPosition(explosion_x,explosion_y):setSize(secondus_moon_radius*2)
							player:addToShipLog(string.format("Looks like the Kraylor have developed some kind of planet busting weapon. They just destroyed %s with it. Keep them away from %s!",moon_name,planet_secondus:getCallSign()),"Magenta")
						end
					else
						if distance(enemy,planet_secondus) < 1500 + planet_secondus_radius then
							enemy_close_to_planet_count = enemy_close_to_planet_count + 1
						end
					end
				end
			end
			if enemy_count < 1 then
				kraylor_planetary_danger = kraylor_planetary_danger + 1
				planetary_attack_fleet = spawnEnemies(sdx+rvx,sdy+rvy,kraylor_planetary_danger,"Kraylor")
				for _, enemy in ipairs(planetary_attack_fleet) do
					rvx, rvy = vectorFromAngle(random(0,360),random(10000,20000))
					enemy:setPosition(plx+rvx,plx+rvy)
					if planet_secondus_moon ~= nil then
						enemy:orderFlyTowards(mox,moy)
					else
						enemy:orderFlyTowards(plx,ply)
					end
				end
			elseif enemy_close_to_planet_count > 5 then
				local exp_x, exp_y = planet_secondus:getPosition()
				planet_name = planet_secondus:getCallSign()
				planet_secondus:destroy()
				ExplosionEffect():setPosition(exp_x, exp_y):setSize(planet_secondus_radius*2)
				plot7 = worldEnd
				world_end_timer = 4
			end
			if kraylor_planetary_danger > 10 and enemy_close_to_planet_count > 1 then
				globalMessage(string.format("You've saved planet %s",planet_secondus:getCallSign()))
				victory("Human Navy")
			end
		end
	end
end
function worldEnd(delta)
	world_end_timer = world_end_timer - delta
	if world_end_timer < 0 then
		globalMessage(string.format("Planet %s was destroyed",planet_name))
		victory("Kraylor")
	end
end
function transitionStationDestroyed(self,instigator)
	globalMessage(string.format("station %s destroyed",self:getCallSign()))
	victory("Exuari")
end
---------------------------------
--	Plot 2 Contract targeting  --
---------------------------------
function contractTarget(delta)
	if exuari_vengance_fleet == nil then
		if exuari_vengance_danger == nil then
			exuari_vengance_danger = 2
		else
			exuari_vengance_danger = exuari_vengance_danger + 1
		end
		local ev_fleet = spawnEnemies(evx,evy,exuari_vengance_danger,"Exuari")
		local fsx, fsy = first_station:getPosition()
		for _, enemy in ipairs(ev_fleet) do
			enemy:orderFlyTowards(fsx,fsy)
		end
		local evs_x, evs_y = vectorFromAngle((ev_angle+90)%360,8000)
		ev_fleet = spawnEnemies(evx+evs_x,evy+evs_y,exuari_vengance_danger,"Exuari")
		local evd_x, evd_y = vectorFromAngle(ev_angle,40000)
		for _, enemy in ipairs(ev_fleet) do
			enemy:orderFlyTowards(evx+evs_x+evd_x,evy+evs_y+evd_y)
		end
		evs_x, evs_y = vectorFromAngle((ev_angle+270)%360,8000)
		ev_fleet = spawnEnemies(evx+evs_x,evy+evs_y,exuari_vengance_danger,"Exuari")
		for _, enemy in ipairs(ev_fleet) do
			enemy:orderFlyTowards(evx+evs_x+evd_x,evy+evs_y+evd_y)
		end
		evs_x, evs_y = vectorFromAngle((ev_angle+270)%360,16000)
		local is_x, is_y = independent_station[2]:getPosition()
		ev_fleet = spawnEnemies(evx+evs_x,evy+evs_y,exuari_vengance_danger,"Exuari")
		for _, enemy in ipairs(ev_fleet) do
			enemy:orderFlyTowards(is_x, is_y)
		end
		evs_x, evs_y = vectorFromAngle((ev_angle+90)%360,16000)
		is_x, is_y = independent_station[3]:getPosition()
		ev_fleet = spawnEnemies(evx+evs_x,evy+evs_y,exuari_vengance_danger,"Exuari")
		for _, enemy in ipairs(ev_fleet) do
			enemy:orderFlyTowards(is_x, is_y)
		end
		exuari_vengance_fleet = 600 - (difficulty*100)
	else
		exuari_vengance_fleet = exuari_vengance_fleet - delta
		if exuari_vengance_fleet < 0 then
			exuari_vengance_fleet = nil
		end
	end
	for _, target_station in pairs(contract_station) do
		if target_station ~= nil and target_station:isValid() then
			if target_station.delay_timer == nil then
				target_station.delay_timer = delta + random(5,30)
			end
			target_station.delay_timer = target_station.delay_timer - delta
			if target_station.delay_timer < 0 then
				if target_station.harass_fleet == nil then
					if random(1,100) < 80 then
						local hfx, hfy = target_station:getPosition()
						target_station.harass_fleet = spawnEnemies(hfx, hfy, 2, "Exuari", 3000, 5000)
					else
						target_station.delay_timer = delta + random(5,30)
					end
				else
					local fleet_count = 0
					for _, enemy in pairs(target_station.harass_fleet) do
						if enemy ~= nil and enemy:isValid() then
							fleet_count = fleet_count + 1
						end
					end
					if fleet_count < 1 then
						target_station.delay_timer = delta + random(60,200)
						target_station.harass_fleet = nil
					end
				end
			end
		else
			globalMessage("Your contract destination station was destroyed")
			victory("Exuari")
		end
	end
	if not transition_contract_message then
		if transition_contract_delay ~= nil then
			transition_contract_delay = transition_contract_delay - delta
			if transition_contract_delay < 0 then
				if first_station ~= nil and first_station:isValid() then
					local p = getPlayerShip(-1)
					p:addToShipLog(string.format("A rare long range contract has been posted at station %s",first_station:getCallSign()),"Magenta")
				else
					globalMessage("Mourning over the loss of the station has halted all business\nThe mission is over")
					victory("Exuari")
				end
				transition_contract_message = true
				plot2 = nil
			else
				if player.captain_log < 2 then
					if transition_contract_delay < transition_contract_delay_max*.8 then
						if independent_station[1]:isValid() and independent_station[2]:isValid() and independent_station[3]:isValid() then
							player:addToShipLog(string.format("[Captain's Log] Why can't the Exuari just leave us alone? I don't understand what it is about them that makes them want to prey on everyone.\nThe upgrades for %s are very nice. They certainly came in handy. With the confidence of stations %s, %s and %s, I feel we will succeed as the space entrepeneurs we want to be.",player:getCallSign(),first_station:getCallSign(),independent_station[2]:getCallSign(),independent_station[3]:getCallSign()),"Green")
						end
						player.captain_log = 2
					end
				end
				local contract_remains = false
				for _, station in pairs(independent_station) do
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
						local p = getPlayerShip(-1)
						p:addToShipLog(string.format("A rare long range contract has been posted at station %s",first_station:getCallSign()),"Magenta")
					else
						globalMessage("Mourning over the loss of the station has halted all business\nThe mission is over")
						victory("Exuari")
					end
					transition_contract_message = true
					plot2 = nil
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
				player:addToShipLog(string.format("Jenny McGuire is now aboard. She's a bit paranoid and has sealed the door to her quarters. You'll have to contact %s to talk to her",first_station:getCallSign()),"Magenta")
			end
		end
	end
end
-------------------------
--	Plot 4 Highwaymen  --
-------------------------
function highwaymen(delta)
	if distance(player,drop_bait) < 30000 then
		highway_timer = highway_timer - delta
		if highway_timer < 0 then
			highway_timer = delta + 150
			plot4 = highwaymenAlerted
		end
	end
end
function highwaymenAlerted(delta)
	if distance(player,drop_bait) < 10000 then
		highway_timer = 5
		plot4 = highwaymenPounce
	end
	highway_timer = highway_timer - delta
	if highway_timer < 0 then
		highway_timer = delta + 10
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
			highway_timer = delta + 10
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
				player:addCustomMessage("Science",player.highwaymen_warning_message,"Energy surge from supply drop")
			end
			if player:hasPlayerAtPosition("Operations") then
				player.highwaymen_warning_message_ops = "highwaymen_warning_message_ops"
				player:addCustomMessage("Operations",player.highwaymen_warning_message_ops,"Energy surge from supply drop")
			end
		else
			local etx, ety = drop_bait:getPosition()
			highwaymen_warning_zone = Zone():setPoints(etx-1000,ety-1000,etx+1000,ety-1000,etx+1000,ety+1000,etx-1000,ety+1000):setColor(255,255,0)
			zone_timer = 30
			plot5 = removeZone
			if player:hasPlayerAtPosition("Science") then
				player.highwaymen_warning_message = "highwaymen_warning_message"
				player:addCustomMessage("Science",player.highwaymen_warning_message,"Energy surge from area highlighted in yellow")
			end
			if player:hasPlayerAtPosition("Operations") then
				player.highwaymen_warning_message_ops = "highwaymen_warning_message_ops"
				player:addCustomMessage("Operations",player.highwaymen_warning_message_ops,"Energy surge from area highlighted in yellow")
			end
		end
	end
	highway_timer = highway_timer - delta
	if highway_timer < 0 then
		local etx, ety = drop_bait:getPosition()
		highwaymen_fleet = spawnEnemies(etx, ety,4,"Exuari")
		local px, py = player:getPosition()
		local angle_increment = 360/#highwaymen_fleet
		local angle = random(0,360)
		for _,enemy in ipairs(highwaymen_fleet) do
			local eax, eay = vectorFromAngle(angle,random(7200,7900) - (difficulty * 500))
			enemy:setPosition(px+eax,py+eay):orderAttack(player)
			angle = (angle + angle_increment) % 360
		end
		local jam_range = distance(drop_bait,player) + 5000
		local jx, jy = drop_bait:getPosition()
		drop_bait:destroy()
		highwaymen_jammer = WarpJammer():setRange(jam_range):setPosition(jx,jy):setFaction("Exuari")
		highway_timer = 8
		plot4 = highwaymenAftermath
	end
end
function highwaymenAftermath(delta)
	local enemy_count = 0
	for _,enemy in pairs(highwaymen_fleet) do
		if enemy ~= nil and enemy:isValid() then
			enemy_count = enemy_count + 1
			break
		end
	end
	if enemy_count < 1 then
		highway_timer = highway_timer - delta
		if highway_timer < 0 then
			highwaymen_jammer:setRange(5000):setDescriptions("Jump and Warp Jammer","Jump and Warp Jammer with external dynamic range control and sensor decoy mechanism"):setScanningParameters(1,2)
			plot4 = highwaymenReset
			highway_timer = delta + 200
			local etx, ety = highwaymen_jammer:getPosition()
			highwaymen_fleet = spawnEnemies(etx, ety,4,"Exuari")
			for _,enemy in ipairs(highwaymen_fleet) do
				enemy:orderAttack(player)
			end
			local temp_fleet = spawnEnemies(etx, ety,4,"Exuari")
			for _,enemy in ipairs(temp_fleet) do
				table.insert(highwaymen_fleet,enemy)
				enemy:orderRoaming()
			end
		end
	end
end
function highwaymenReset(delta)
	highway_timer = highway_timer - delta
	if highway_timer < 0 then
		if highwaymen_jammer ~= nil then
			local enemy_count = 0
			for _,enemy in pairs(highwaymen_fleet) do
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
	zone_timer = zone_timer - delta
	if zone_timer < 0 then
		highwaymen_warning_zone:destroy()
		plot5 = nil
	end
end
function update(delta)
	if delta == 0 then	--game paused
		setPlayer()
		accumulated_delta = 0
		return
	end
	if planet_secondus_moon ~= nil then
		if supply_depot_station ~= nil and supply_depot_station:isValid() then
			if supply_depot_station.sabotaged == nil then
				local mx, my = planet_secondus_moon:getPosition()
				supply_depot_station:setPosition(mx, my + secondus_moon_radius + 1500)
				local sdx, sdy = supply_depot_station:getPosition()
				supply_worm_hole:setTargetPosition(sdx,sdy)
			else
				if player.supply_sabotage_message == nil then
					player.supply_sabotage_message = "sent"
					player:addToShipLog(string.format("Kraylor have sabotaged station %s. It can no longer maintain orbit around %s. Fortunately, it looks to be in no danger from %s or %s, but the Kraylor pose a more significant threat",supply_depot_station:getCallSign(),planet_secondus_moon:getCallSign(),planet_secondus:getCallSign(),planet_secondus_moon:getCallSign()),"Magenta")
				end
			end
		end
	end
	for pidx=1,32 do
		local p = getPlayerShip(pidx)
		if p ~= nil then
			if p:isValid() then
				if pidx > 1 then
					p:destroy()	--only one player allowed
				end
			end
		end
	end
	if plot1 ~= nil then	--various primary plot lines (harassment, transition contract, long discance cargo)
		plot1(delta)
	end
	accumulated_delta = accumulated_delta + delta
	if player.inventoryButton == nil then
		local goodCount = 0
		if player.goods ~= nil then
			for good, goodQuantity in pairs(player.goods) do
				goodCount = goodCount + 1
			end
		end
		if goodCount > 0 then		--add inventory button when cargo acquired
			if player:hasPlayerAtPosition("Relay") then
				if player.inventoryButton == nil then
					player.tbi = "inventory" .. player:getCallSign()
					player:addCustomButton("Relay",player.tbi,"Inventory",function () playerShipCargoInventory(player) end)
					player.inventoryButton = true
				end
			end
			if player:hasPlayerAtPosition("Operations") then
				if player.inventoryButton == nil then
					player.tbi_op = "inventoryOp" .. player:getCallSign()
					player:addCustomButton("Operations",player.tbi_op,"Inventory", function () playerShipCargoInventory(player) end)
					player.inventoryButton = true
				end
			end
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
	if plot7 ~= nil then	--end of the world
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