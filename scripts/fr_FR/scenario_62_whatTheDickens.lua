-- Name: What the Dickens
-- Description: Patrol around the London area during Christmas. Bah! Humbug!
-- Type: Mission
-- Variation[Easy]: Easy goals and/or enemies. Good for solo players, short handed crews or less experienced crews.
-- Variation[Hard]: Hard goals and/or enemies. Good for experienced crews looking for a challenge.

require("utils.lua")
require("options.lua")
require(lang .. "/ships.lua")
require(lang .. "/factions.lua")


function init()
	diagnostic = true
	setVariations()
	stationFaction = humanFaction
	stationBedlam = SpaceStation():setTemplate(smallStation):setFaction(stationFaction)
	stationBedlam:setCallSign("Bedlam"):setPosition(27333, 54000)
	stationTavistock = SpaceStation():setTemplate(smallStation):setFaction(stationFaction)
	stationTavistock:setCallSign("Tavistock"):setPosition(-33111, -68222)
	stationCornhill = SpaceStation():setTemplate(smallStation):setFaction(stationFaction)
	stationCornhill:setCallSign("Cornhill"):setPosition(78667, -20444)
	stationCamden = SpaceStation():setTemplate(largeStation):setFaction(stationFaction)
	stationCamden:setCallSign("Camden"):setPosition(-65556, -82667)
	stationCity = SpaceStation():setTemplate(hugeStation):setFaction(stationFaction)
	stationCity:setCallSign("City"):setPosition(82889, -10444)
	stationSomerset = SpaceStation():setTemplate(largeStation):setFaction(stationFaction)
	stationSomerset:setCallSign("Somerset"):setPosition(500, -10000):setCommsScript(""):setCommsFunction(commsStation)
	stationMillbank = SpaceStation():setTemplate(mediumStation):setFaction(stationFaction)
	stationMillbank:setCallSign("Millbank"):setPosition(-35000, 48000)
	stationChange = SpaceStation():setTemplate(mediumStation):setFaction(stationFaction)
	stationChange:setCallSign("Change"):setPosition(85333, -21111)
	stationDevonshire = SpaceStation():setTemplate(smallStation):setFaction(stationFaction)
	stationDevonshire:setCallSign("Devonshire"):setPosition(-82000, -59000)
	stationCavendish = SpaceStation():setTemplate(smallStation):setFaction(stationFaction)
	stationCavendish:setCallSign("Cavendish"):setPosition(-77000, -36000)
	stationFoundling = SpaceStation():setTemplate(smallStation):setFaction(stationFaction)
	stationFoundling:setCallSign("Foundling"):setPosition(-5000, -63000):setDescription("Medical research and support")
	stationSoho = SpaceStation():setTemplate(smallStation):setFaction(stationFaction)
	stationSoho:setCallSign("Soho"):setPosition(-40000, -28000)
	stationGrosvenor = SpaceStation():setTemplate(smallStation):setFaction(stationFaction)
	stationGrosvenor:setCallSign("Grosvenor"):setPosition(-92000, -12000)
	stationPentonville = SpaceStation():setTemplate(smallStation):setFaction(stationFaction)
	stationPentonville:setCallSign("Pentonville"):setPosition(50, -78000)
	stationCovent = SpaceStation():setTemplate(smallStation):setFaction(stationFaction)
	stationCovent:setCallSign("Covent"):setPosition(-15000, -14000):setDescription("Hydroponics and plant life")
	stationCheshire = SpaceStation():setTemplate(smallStation):setFaction(stationFaction)
	stationCheshire:setCallSign("Cheshire"):setPosition(23000, -23000):setDescription("Cheese, food, drink")
	stationSouthwark = SpaceStation():setTemplate(mediumStation):setFaction(stationFaction)
	stationSouthwark:setCallSign("Southwark"):setPosition(52000, 19000)
	stationLambeth = SpaceStation():setTemplate(mediumStation):setFaction(stationFaction)
	stationLambeth:setCallSign("Lambeth"):setPosition(22000, 51000)
	stationBorough = SpaceStation():setTemplate(smallStation):setFaction(stationFaction)
	stationBorough:setCallSign("Borough"):setPosition(38500, 40500)
	stationChelsea = SpaceStation():setTemplate(smallStation):setFaction(stationFaction)
	stationChelsea:setCallSign("Chelsea"):setPosition(-53000, 81500)
	stationTower = SpaceStation():setTemplate(mediumStation):setFaction(stationFaction)
	stationTower:setCallSign("Tower"):setPosition(118000, 3000)
	stationCripplegate = SpaceStation():setTemplate(smallStation):setFaction(stationFaction)
	stationCripplegate:setCallSign("Cripplegate"):setPosition(60500, -50500)
	stationHolborn = SpaceStation():setTemplate(mediumStation):setFaction(stationFaction)
	stationHolborn:setCallSign("Holborn"):setPosition(25000, -46000)
	stationBloomsbury = SpaceStation():setTemplate(smallStation):setFaction(stationFaction)
	stationBloomsbury:setCallSign("Bloomsbury"):setPosition(-50, -57000)
	stationSpitalfields = SpaceStation():setTemplate(mediumStation):setFaction(stationFaction)
	stationSpitalfields:setCallSign("Spitalfields"):setPosition(117000, -39000)
	stationBishopsgate = SpaceStation():setTemplate(smallStation):setFaction(stationFaction)
	stationBishopsgate:setCallSign("Bishopsgate"):setPosition(101000, -32000)
	stationMoorgate = SpaceStation():setTemplate(smallStation):setFaction(stationFaction)
	stationMoorgate:setCallSign("Moorgate"):setPosition(82000, -40000)
	stationWestminster = SpaceStation():setTemplate(mediumStation):setFaction(stationFaction)
	stationWestminster:setCallSign("Westminster"):setPosition(-36000, 51000)
	stationBuckingham = SpaceStation():setTemplate(mediumStation):setFaction(stationFaction)
	stationBuckingham:setCallSign("Buckingham"):setPosition(-68000, 33000)
	stationKensington = SpaceStation():setTemplate(smallStation):setFaction(stationFaction)
	stationKensington:setCallSign("Kensington"):setPosition(-108000, 35000)
	stationAldgate = SpaceStation():setTemplate(smallStation):setFaction(stationFaction)
	stationAldgate:setCallSign("Aldgate"):setPosition(115000, -19000)
	riverZone = Zone():setColor(0,0,255)
	riverZone:setPoints(-60000,160000,
						-39778,108667,
						-34000,95556,
						-31778,89778,
						-28889,79111,
						-23778,65333,
						-20222,49111,
						-20000,37111,
						-19556,32444,
						-19778,21333,
						-19333,12000,
						-18000,7333,
						-16889,5556,
						-15556,4222,
						-14000,3556,
						-11333,2000,
						-8222,0,
						-4667,-1556,
						889,-5778,
						4222,-8000,
						8444,-9778,
						21111,-9556,
						30222,-8889,
						34444,-9556,
						38889,-9556,
						40889,-10222,
						43778,-10222,
						50222,-8444,
						60667,-5556,
						70000,-2000,
						74889,-1778,
						76667,-2444,
						84889,0,
						89556,222,
						100667,2000,
						110889,5333,
						120667,9778,
						135556,16444,
						220000,40000,
						220000,60000,
						135778,31333,
						119111,23778,
						108222,17333,
						98222,14444,
						88444,14000,
						85111,13111,
						79778,12000,
						71778,9778,
						68222,9111,
						62444,7333,
						59333,6000,
						47778,2889,
						39556,1778,
						35778,3111,
						32889,2444,
						18889,3556,
						11111,6222,
						5556,9556,
						667,12889,
						-3111,17333,
						-4889,23778,
						-5778,33778,
						-6000,39111,
						-3556,43556,
						-3778,46889,
						-5333,53556,
						-6444,60889,
						-9111,68667,
						-15111,83778,
						-18444,94000,
						-20889,96667,
						-22444,99333,
						-25333,113333,
						-40000,160000)
	waterLooZone = Zone():setColor(0,0,0)
	waterLooZone:setPoints(5556,9556,
						-4667,-1556,
						889,-5778,
						11111,6222)
	blackFriarZone = Zone():setColor(0,0,0)
	blackFriarZone:setPoints(35778,3111,
						34444,-9556,
						38889,-9556,
						39556,1778)
	southwarkZone = Zone():setColor(0,0,0)
	southwarkZone:setPoints(68222,9111,
						62444,7333,
						70000,-2000,
						74889,-1778)
	londonZone = Zone():setColor(0,0,0)
	londonZone:setPoints(85111,13111,
						79778,12000,
						84889,0,
						89556,222)
	westMinsterZone = Zone():setColor(0,0,0)
	westMinsterZone:setPoints(-5778,33378,
						-6000,39111,
						-20000,37111,
						-19556,32444)
	vauxHallZone = Zone():setColor(0,0,0)
	vauxHallZone:setPoints(-20889,96667,
						-22444,99333,
						-34000,95556,
						-31778,89778)
    Nebula():setPosition(-44444, 31556)
    Nebula():setPosition(-40667, 32889)
    Nebula():setPosition(-37778, 25111)
    Nebula():setPosition(-42667, 20222)
    Nebula():setPosition(-39333, 18667)
    Nebula():setPosition(-50222, 23556)
    Nebula():setPosition(-56444, 27778)
    Nebula():setPosition(-61333, 30889)
    Nebula():setPosition(-50889, 30667)
    Nebula():setPosition(-63778, 19111)
    Nebula():setPosition(-65333, 13333)
    Nebula():setPosition(-70889, 9778)
    Nebula():setPosition(-74444, 13111)
    Nebula():setPosition(-82222, 19333)
    Nebula():setPosition(-90000, 22444)
    Nebula():setPosition(-74444, 19778)
    Nebula():setPosition(-69333, 18889)
    Nebula():setPosition(-90000, 8444)
    Nebula():setPosition(-97333, 10667)
    Nebula():setPosition(-110000, 13333)
    Nebula():setPosition(-120444, 16222)
    Nebula():setPosition(-106222, 8000)
    Nebula():setPosition(-98444, 3556)
    Nebula():setPosition(-104222, -4222)
    Nebula():setPosition(-113111, -12222)
    Nebula():setPosition(-108444, -8889)
    Nebula():setPosition(-112667, -222)
    Nebula():setPosition(-119333, 8667)
    Nebula():setPosition(-124222, 4000)
    Nebula():setPosition(-118000, -6889)
    Nebula():setPosition(-122444, -16000)
    Nebula():setPosition(-126444, -10222)
    Nebula():setPosition(-126889, -3333)
    Nebula():setPosition(-126000, 11333)
    Nebula():setPosition(-127111, 20889)
    Nebula():setPosition(-100111, -80889)
    Nebula():setPosition(-90111, -80000)
	createRandomAlongArc(Asteroid, 50, 0, 0, 70000, 180, 270, 25000)
	player = PlayerSpaceship():setFaction(humanFaction):setTemplate(repulse):setCallSign("HMS Scrooge"):addReputationPoints(77)
	plotZ = zoneChecks
	plot1timer = 5
	plot1 = missionMessage
	plot1name = "missionMessage"
	primaryOrders = string.format("Protect Somerset in %s",stationSomerset:getSectorName())
	secondaryOrders = ""
	optionalOrders = ""
	graveyardDocked = false
	graveyardSpawned = false
	cemeteryDocked = false
	necropolisDocked = false
	GMChristmasPast = "Christmas Past"
	addGMFunction(GMChristmasPast,christmasPast)
	GMChristmasPresent = "Christmas Present"
	addGMFunction(GMChristmasPresent,christmasPresent)
	GMChristmasFuture = "Christmas Future"
	addGMFunction(GMChristmasFuture,christmasFuture)
	wfv = "end of init"
end
-- Create amount of objects of type object_type along arc
-- Center defined by x and y
-- Radius defined by distance
-- Start of arc between 0 and 360 (startArc), end arc: endArcClockwise
-- Use randomize to vary the distance from the center point. Omit to keep distance constant
-- Example:
--   createRandomAlongArc(Asteroid, 100, 500, 3000, 65, 120, 450)
function createRandomAlongArc(object_type, amount, x, y, distance, startArc, endArcClockwise, randomize)
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

function setVariations()
	if string.find(getScenarioVariation(),"Easy") then
		difficulty = .5
	elseif string.find(getScenarioVariation(),"Hard") then
		difficulty = 2
	else
		difficulty = 1		--default (normal)
	end
end

function zoneChecks(delta)
	if riverZone:isInside(player) then
		if 	not waterLooZone:isInside(player) and
			not blackFriarZone:isInside(player) and
			not westMinsterZone:isInside(player) and
			not vauxHallZone:isInside(player) and
			not londonZone:isInside(player) and
			not southwarkZone:isInside(player) then
			if riverZoneWarningMessage == nil then
				player:addToShipLog("Reminder to all newcomers to the London area: the river area damages ship systems. Jump the river or use the provided bridges","Magenta")
				riverZoneWarningMessage = "sent"
			end
			systemHit = math.random(1,8)
			if systemHit == 1 then
				player:setSystemHealth("reactor", player:getSystemHealth("reactor")*.99)
			elseif systemHit == 2 then
				player:setSystemHealth("beamweapons", player:getSystemHealth("beamweapons")*.99)
			elseif systemHit == 3 then
				player:setSystemHealth("maneuver", player:getSystemHealth("maneuver")*.99)
			elseif systemHit == 4 then
				player:setSystemHealth("missilesystem", player:getSystemHealth("missilesystem")*.99)
			elseif systemHit == 5 then
				player:setSystemHealth("warp", player:getSystemHealth("warp")*.99)
			elseif systemHit == 6 then
				player:setSystemHealth("jumpdrive", player:getSystemHealth("jumpdrive")*.99)
			elseif systemHit == 7 then
				player:setSystemHealth("frontshield", player:getSystemHealth("frontshield")*.99)
			else
				player:setSystemHealth("rearshield", player:getSystemHealth("rearshield")*.99)
			end
		end
	end
end

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

    if player:isEnemy(comms_target) then
        return false
    end

    if comms_target:areEnemiesInRange(5000) then
        setCommsMessage("We are under attack! No time for chatting!");
        return true
    end
    if not player:isDocked(comms_target) then
        handleUndockedState()
    else
        handleDockedState()
    end
    return true
end

function handleDockedState()
    -- Handle communications while docked with this station.
    if player:isFriendly(comms_target) then
        setCommsMessage("Good day, officer!\nWhat can we do for you today?")
    else
        setCommsMessage("Welcome to our lovely station.")
    end

    if player:getWeaponStorageMax(homing) > 0 then
        addCommsReply("Do you have spare homing missiles for us? ("..getWeaponCost(homing).."rep each)", function()
            handleWeaponRestock(homing)
        end)
    end
    if player:getWeaponStorageMax(hvli) > 0 then
        addCommsReply("Can you restock us with HVLI? ("..getWeaponCost(hvli).."rep each)", function()
            handleWeaponRestock(hvli)
        end)
    end
    if player:getWeaponStorageMax(mine) > 0 then
        addCommsReply("Please re-stock our mines. ("..getWeaponCost(mine).."rep each)", function()
            handleWeaponRestock(mine)
        end)
    end
    if player:getWeaponStorageMax(nuke) > 0 then
        addCommsReply("Can you supply us with some nukes? ("..getWeaponCost(nuke).."rep each)", function()
            handleWeaponRestock(nuke)
        end)
    end
    if player:getWeaponStorageMax(emp) > 0 then
        addCommsReply("Please re-stock our EMP missiles. ("..getWeaponCost(emp).."rep each)", function()
            handleWeaponRestock(emp)
        end)
    end
	if player:isFriendly(comms_target) then
		addCommsReply("What are my current orders?", function()
			ordMsg = primaryOrders .. "\n" .. secondaryOrders
			setCommsMessage(ordMsg)
			addCommsReply("Back", commsStation)
		end)
		addCommsReply("Interesting points in the area", function()
			setCommsMessage("You may be interested in one or more of these:")
			addCommsReply("City", function()
				setCommsMessage("The City station represents one of the most developed stations in the area. Correlating the station to olde Earth, this would be where the walled medieval area of London would have been located")
				addCommsReply("Back", commsStation)
			end)
			addCommsReply("Change", function()
				setCommsMessage("Much of the area's financial business is handled at the station named Change. The station name is an oblique reference to the Royal Exchange of London")
				addCommsReply("Back", commsStation)
			end)
			addCommsReply("Foundling", function()
				setCommsMessage("Foundling station specializes in medical research for children. The station name honors Foundling Hospital in London, an orphanage established in 1739 by Captain Thomas Coram, a retired seaman")
				addCommsReply("Back", commsStation)
			end)
			addCommsReply("Thames", function()
				setCommsMessage("The zone running through this area colored blue is named Thames after the river Thames in London of olde Earth. Ships should avoid entering this zoneexcept by bridges designated due to the adverse effects it has on ship systems. This is why navigation systems automatically show this region for all ships in the area.")
				addCommsReply("Back", commsStation)
			end)
			addCommsReply("Covent", function()
				setCommsMessage("Most of the area's food supply comes from station Covent. It specializes in hydroponics. THe station derives its name from Covent Garden from olde Earth London where fruits, vegetables and flowers were bought and sold")
				addCommsReply("Back", commsStation)
			end)
			addCommsReply("Cheshire", function()
				setCommsMessage("You can find fine dining and drinking at Cheshire station. The name alludes to the Ye Olde Cheshire Cheese pub from London on olde earth")
				addCommsReply("Back", commsStation)
			end)
			addCommsReply("Tower", function()
				setCommsMessage("Station Tower serves as a residence for the wealthiest members of the London area community")
				addCommsReply("Back", commsStation)
			end)
			addCommsReply("Back", commsStation)
		end)
	end
end

function handleWeaponRestock(weapon)
    if not player:isDocked(comms_target) then setCommsMessage("You need to stay docked for that action."); return end
    if not isAllowedTo(comms_data.weapons[weapon]) then
        if weapon == nuke then setCommsMessage("We do not deal in weapons of mass destruction.")
        elseif weapon == emp then setCommsMessage("We do not deal in weapons of mass disruption.")
        else setCommsMessage("We do not deal in those weapons.") end
        return
    end
    local points_per_item = getWeaponCost(weapon)
    local item_amount = math.floor(player:getWeaponStorageMax(weapon) * comms_data.max_weapon_refill_amount[getFriendStatus()]) - player:getWeaponStorage(weapon)
    if item_amount <= 0 then
        if weapon == nuke then
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

function handleUndockedState()
    --Handle communications when we are not docked with the station.
    if player:isFriendly(comms_target) then
        setCommsMessage("Good day, officer.\nIf you need supplies, please dock with us first.")
    else
        setCommsMessage("Greetings.\nIf you want to do business, please dock with us first.")
    end
 	if player:isFriendly(comms_target) then
		addCommsReply("What are my current orders?", function()
			ordMsg = primaryOrders .. "\n" .. secondaryOrders .. optionalOrders
			setCommsMessage(ordMsg)
			addCommsReply("Back", commsStation)
		end)
	end
	if diagnostic then
		addCommsReply("Diagnostic data", function()
			oMsg = string.format("Difficulty: %.1f",difficulty)
			if plot1name == nil or plot1 == nil then
				oMsg = oMsg .. ""
			else
				oMsg = oMsg .. "\nplot1: " .. plot1name
			end
			if plot2name == nil or plot2 == nil then
				oMsg = oMsg .. ""
			else
				oMsg = oMsg .. "\nplot2: " .. plot2name
			end
			if plot3name == nil or plot3 == nil then
				oMsg = oMsg .. ""
			else
				oMsg = oMsg .. "\nplot3: " .. plot3name
			end
			if plot4name == nil or plot4 == nil then
				oMsg = oMsg .. ""
			else
				oMsg = oMsg .. "\nplot4: " .. plot4name
			end
			oMsg = oMsg .. "\nwfv: " .. wfv
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

function isAllowedTo(state)
    if state == "friend" and player:isFriendly(comms_target) then
        return true
    end
    if state == "neutral" and not player:isEnemy(comms_target) then
        return true
    end
    return false
end

-- Return the number of reputation points that a specified weapon costs for the
-- current player.
function getWeaponCost(weapon)
    return math.ceil(comms_data.weapon_cost[weapon] * comms_data.reputation_cost_multipliers[getFriendStatus()])
end

-- Return the number of reputation points that a specified service costs for
-- the current player.
function getServiceCost(service)
    return math.ceil(comms_data.service_cost[service])
end

function getFriendStatus()
    if player:isFriendly(comms_target) then
        return "friend"
    else
        return "neutral"
    end
end

function christmasPast()
	plot1 = startChristmasPast
	removeGMFunction(GMChristmasPast)
end

function christmasPresent()
	plot1 = startChristmasPresent
	removeGMFunction(GMChristmasPresent)
end

function christmasFuture()
	plot1 = startChristmasFuture
	removeGMFunction(GMChristmasFuture)
end

function missionMessage(delta)
	plot1timer = plot1timer - delta
	if plot1timer < 0 then
		player:addToShipLog(string.format("Your mission is to protect station Somerset in %s. Other missions may be added. Dock with Somerset for additional mission parameters. Welcome to the london area of human navy influence",stationSomerset:getSectorName()),"Magenta")
		primaryOrders = string.format("Protect Somerset in %s",stationSomerset:getSectorName())
		secondaryOrders = "Dock with Somerset"
		plot1 = camdenSensorReading
		plot1name = "camdenSensorReading"
	end
end

function camdenSensorReading(delta)
	if player:isDocked(stationSomerset) then
		player:addToShipLog("Investigate unusual sensor readings near station Camden in A2","Magenta")
		playSoundFile("sa_62_London1.ogg")
		secondaryOrders = "Investigate near station Camden in A2"
		plot1 = arriveA2
		plot1name = "arriveA2"
	end
end

function arriveA2(delta)
	if player:getSectorName() == "A2" then
		px, py = player:getPosition()
		vx, vy = vectorFromAngle(315,random(10000,12000))
		marleyArt = Artifact():setPosition(px+vx,py+vy):setModel("artifact2"):allowPickup(false):setDescriptions("Rusty Chain Link","Translucent but glowing rusty chain link"):setRadarSignatureInfo(0,0,.9):setScanningParameters(1,1)
		plot1 = scanMarleyArtifact
		plot1name = "scanMarleyArtifact"
	end
end

function scanMarleyArtifact(delta)
	if marleyArt:isScannedBy(player) then
		player:addToShipLog("[Jacob Marley] Do you remember your partner from previous missions? Especially the one where Marley station was destroyed? I am doomed to haunt this area of space forever. Take care or suffer the same fate.","Red")
		playSoundFile("sa_62_Marley1.ogg")
		plot1 = explosionDelay
		plot1name = "explosionDelay"
		explosionDelayTimer = 10
	end
end

function explosionDelay(delta)
	explosionDelayTimer = explosionDelayTimer - delta
	if explosionDelayTimer < 0 then
		marleyArt:explode()
		plot1 = marleyMob
		plot1name = "marleyMob"
		plot1timer = 20
	end
end

function marleyMob(delta)
	plot1timer = plot1timer - delta
	if plot1timer < 0 then
		marleyList = {}
		px, py = player:getPosition()
		startAngle = random(0,360)
		vx, vy = vectorFromAngle(startAngle,3000)
		enemyLink = CpuShip():setFaction(kraylorFaction):setCallSign("Link"):setTemplate(adderMK4):orderAttack(player):setPosition(px+vx,py+vy):setRotation(startAngle+180)
		table.insert(marleyList, enemyLink)
		plot1 = destroyMarleyMob
		plot1name = "destroyMarleyMob"
		if difficulty == 1 then
			vx, vy = vectorFromAngle(startAngle+90,3000)
			enemyChain = CpuShip():setFaction(kraylorFaction):setCallSign("Chain"):setTemplate(adderMK4):orderAttack(player):setPosition(px+vx,py+vy):setRotation(startAngle+270)
			vx, vy = vectorFromAngle(startAngle+180,3000)
			enemyLock = CpuShip():setFaction(kraylorFaction):setCallSign("Lock"):setTemplate(adderMK4):orderAttack(player):setPosition(px+vx,py+vy):setRotation(startAngle)
			vx, vy = vectorFromAngle(startAngle+270,3000)
			enemyKey = CpuShip():setFaction(kraylorFaction):setCallSign("Key"):setTemplate(adderMK4):orderAttack(player):setPosition(px+vx,py+vy):setRotation(startAngle+90)
			table.insert(marleyList, enemyChain)
			table.insert(marleyList, enemyLock)
			table.insert(marleyList, enemyKey)
		else
			vx, vy = vectorFromAngle(startAngle+120,3000)
			enemyLock = CpuShip():setFaction(kraylorFaction):setCallSign("Lock"):setTemplate(adderMK4):orderAttack(player):setPosition(px+vx,py+vy):setRotation(startAngle+300)
			vx, vy = vectorFromAngle(startAngle+240,3000)
			enemyCoil = CpuShip():setFaction(kraylorFaction):setCallSign("Coil"):setTemplate(adderMK4):orderAttack(player):setPosition(px+vx,py+vy):setRotation(startAngle+60)
			vx, vy = vectorFromAngle(startAngle+60,3000)
			table.insert(marleyList, enemyLock)
			table.insert(marleyList, enemyCoil)
			if difficulty > 1 then
				enemyChain = CpuShip():setFaction(kraylorFaction):setCallSign("Chain"):setTemplate(adderMK4):orderAttack(player):setPosition(px+vx,py+vy):setRotation(startAngle+240)
				vx, vy = vectorFromAngle(startAngle+180,3000)
				enemyKey = CpuShip():setFaction(kraylorFaction):setCallSign("Key"):setTemplate(adderMK4):orderAttack(player):setPosition(px+vx,py+vy):setRotation(startAngle)
				vx, vy = vectorFromAngle(startAngle+300,3000)
				enemyBind = CpuShip():setFaction(kraylorFaction):setCallSign("Bind"):setTemplate(adderMK4):orderAttack(player):setPosition(px+vx,py+vy):setRotation(startAngle+120)
				table.insert(marleyList, enemyChain)
				table.insert(marleyList, enemyKey)
				table.insert(marleyList, enemyBind)
			end
		end
		player:addToShipLog("[Jacob Marley] You must defeat the chains that bind you in the form of Kraylor ships","Red")
		playSoundFile("sa_62_Marley2.ogg")
		secondaryOrders = "Defeat Kraylors"
	end
end

function destroyMarleyMob(delta)
	marleyMobCount = 0
	for _, enemy in ipairs(marleyList) do
		if enemy:isValid() then
			marleyMobCount = marleyMobCount + 1
		end
	end
	if marleyMobCount == 0 then
		player:addReputationPoints(50)
		player:addToShipLog(string.format("[Jacob Marley] Defeating the Kraylors gives you an idea of what is to come. Return to Somerset in %s and prepare for three ghostly visits",stationSomerset:getSectorName()),"Red")
		playSoundFile("sa_62_Marley3.ogg")
		plot1 = startChristmasPast
		plot1name = "startChristmasPast"
		secondaryOrders = "Dock with Somerset"
		removeGMFunction(GMChristmasPast)
	end
end

function startChristmasPast(delta)
	if player:isDocked(stationSomerset) then
		player:addToShipLog(string.format("I'm guessing you handled whatever was in A2. Those unusual readings have disappeared. However, we show an unusually high level of chroniton particles near station Millbank in %s. Recommend you investigate.",stationMillbank:getSectorName()),"Magenta")
		playSoundFile("sa_62_London2.ogg")
		secondaryOrders = string.format("Investigate chroniton particles near station Millbank in %s",stationMillbank:getSectorName())
		plot1 = arriveNearMillbank
		plot1name = "arriveNearMillbank"
	end
end

function arriveNearMillbank(delta)
	if distance(player,stationMillbank) < 15000 then
		smx, smy = stationMillbank:getPosition()
		vx, vy = vectorFromAngle(random(0,360),2500)
		pastArt = Artifact():setPosition(smx+vx,smy+vy):setModel("artifact3"):allowPickup(false):setDescriptions("Tiny escape pod","Tiny escape pod from a previous generation"):setRadarSignatureInfo(0,0.9,0):setScanningParameters(2,1)
		hopTimer = 1
		plot1 = hopArt
		plot1name = "hopArt"
		plot2 = pastArtScan
		plot2name = "pastArtScan"
	end
end

function hopArt(delta)
	hopTimer = hopTimer - delta
	if hopTimer < 0 then
		vx, vy = vectorFromAngle(random(0,360),2500)
		pastArt:setPosition(smx+vx,smy+vy)
		hopTimer = delta + 1
	end
end

function pastArtScan(delta)
	if pastArt:isScannedByFaction(humanFaction) then
		px, py = player:getPosition()
		fezx = (px + smx)/2
		fezy = (py + smy)/2
		if distance(player,fezx,fezy) < 1000 then
			wfv = "alternate fez"
			fezx = fezx + 3000
			fezy = fezy + 3000
		end
		plot1 = fezEffect
		plot1name = "fezEffect"
		plot2 = podToFez
		podToFezTimer = 1
		plot2name = "podToFez"
	end
end

function podToFez(delta)
	podToFezTimer = podToFezTimer - delta
	if podToFezTimer < 0 then
		if stationFezziwig ~= nil then
			if distance(stationFezziwig,pastArt) < 100 then
				pastArt:destroy()
				plot2 = nil
				plot2name = ""
			end
		end
		pox, poy = pastArt:getPosition()
		pastArt:setPosition((pox+fezx)/2,(poy+fezy)/2)
		podToFezTimer = delta + 1
	end
end

function fezEffect(delta)
	fezNeb1 = Nebula():setPosition(fezx,fezy)
	fez2Timer = 3
	plot1 = fez2Effect
	plot1name = "fez2Effect"
end

function fez2Effect(delta)
	fez2Timer = fez2Timer - delta
	if fez2Timer < 0 then
		fez3Timer = 3
		plot1 = fez3Effect
		plot1name = "fez3Effect"
		fezNeb2 = Nebula():setPosition(fezx,fezy+5000)
		fezNeb3 = Nebula():setPosition(fezx+5000,fezy)
		fezNeb4 = Nebula():setPosition(fezx,fezy-5000)
		fezNeb5 = Nebula():setPosition(fezx-5000,fezy)
	end
end

function fez3Effect(delta)
	fez3Timer = fez3Timer - delta
	if fez3Timer < 0 then
		stationFezziwig = SpaceStation():setTemplate(smallStation):setFaction(humanFaction):setCallSign("Fezziwig"):setPosition(fezx, fezy)
		plot1 = fezWelcomeMessage
		plot1name = "fezWelcomeMessage"
		fezWelcomeTimer = 5
	end
end

function fezWelcomeMessage(delta)
	fezWelcomeTimer = fezWelcomeTimer - delta
	if fezWelcomeTimer < 0 then
		player:addToShipLog("Welcome to the Christmases of your past, Scrooge","Blue")
		playSoundFile("sa_62_Child1.ogg")
		plot1 = fezFleet
		plot1name = "fezFleet"
		fezFleetTimer = 7
	end
end

function fezFleet(delta)
	fezFleetTimer = fezFleetTimer - delta
	if fezFleetTimer < 0 then
		fezList = {}
		px, py = player:getPosition()
		startAngle = random(35,55)
		vx, vy = vectorFromAngle(startAngle-10,5000)
		enemyAliBabba = CpuShip():setFaction(exuariFaction):setCallSign("Ali Babba"):setTemplate(lindwormWX):orderAttack(player):setPosition(px+vx,py+vy):setRotation(startAngle+170)
		table.insert(fezList, enemyAliBabba)
		plot1 = destroyFezFleet
		plot1name = "destroyFezFleet"
		vx, vy = vectorFromAngle(startAngle+10,5000)
		enemyValentine = CpuShip():setFaction(exuariFaction):setCallSign("Valentine"):setTemplate(lindwormWX):orderAttack(player):setPosition(px+vx,py+vy):setRotation(startAngle+190)
		table.insert(fezList, enemyValentine)
		if difficulty >= 1 then
			vx, vy = vectorFromAngle(startAngle-30,5000)
			enemyOrson = CpuShip():setFaction(exuariFaction):setCallSign("Orson"):setTemplate(lindwormWX):orderAttack(player):setPosition(px+vx,py+vy):setRotation(startAngle+150)
			table.insert(fezList, enemyOrson)
			vx, vy = vectorFromAngle(startAngle+30,5000)
			enemyGroom = CpuShip():setFaction(exuariFaction):setCallSign("Groom"):setTemplate(lindwormWX):orderAttack(player):setPosition(px+vx,py+vy):setRotation(startAngle+210)
			table.insert(fezList, enemyGroom)
		end
		if difficulty > 1 then
			vx, vy = vectorFromAngle(startAngle,5000)
			enemyGenii = CpuShip():setFaction(exuariFaction):setCallSign("Genii"):setTemplate(lindwormWX):orderAttack(player):setPosition(px+vx,py+vy):setRotation(startAngle+180)
			table.insert(fezList, enemyGenii)
			vx, vy = vectorFromAngle(startAngle-20,5000)
			enemyParrot = CpuShip():setFaction(exuariFaction):setCallSign("Parrot"):setTemplate(lindwormWX):orderAttack(player):setPosition(px+vx,py+vy):setRotation(startAngle+160)
			table.insert(fezList, enemyParrot)
			vx, vy = vectorFromAngle(startAngle+20,5000)
			enemyFriday = CpuShip():setFaction(exuariFaction):setCallSign("Friday"):setTemplate(lindwormWX):orderAttack(player):setPosition(px+vx,py+vy):setRotation(startAngle+200)
			table.insert(fezList, enemyFriday)
		end
	end
end

function destroyFezFleet(delta)
	fezFleetCount = 0
	for _, enemy in ipairs(fezList) do
		if enemy:isValid() then
			fezFleetCount = fezFleetCount + 1
		end
	end
	if fezFleetCount == 0 then
		player:addReputationPoints(50)
		player:addToShipLog(string.format("Belle has come. Be sure she makes it to Fezziwig in %s",stationFezziwig:getSectorName()),"Blue")
		playSoundFile("sa_62_Child2.ogg")
		belleAngle = random(170,190)
		vx, vy = vectorFromAngle(belleAngle,20000)
		friendBelle = CpuShip():setFaction(humanFaction):setCallSign("Belle"):setTemplate("Goods Freighter 3"):orderDock(stationFezziwig):setPosition(fezx+vx,fezy+vy):setRotation(belleAngle+180):setScannedByFaction(humanFaction,true)
		plot1 = belleNemesis
		plot1name = "belleNemesis"
		secondaryOrders = "Protect Belle"
		belleNemesisTimer = 10
	end
end

function belleNemesis(delta)
	belleNemesisTimer = belleNemesisTimer - delta
	if belleNemesisTimer < 0 then
		belleList = {}
		vx, vy = vectorFromAngle(belleAngle-10,24000)
		enemyIdol = CpuShip():setFaction(exuariFaction):setCallSign("Idol"):setTemplate(hornetMT52):orderAttack(friendBelle):setPosition(fezx+vx,fezy+vy):setRotation(startAngle+170)
		table.insert(belleList, enemyIdol)
		plot1 = destroyBelleFleet
		plot1name = "destroyBelleFleet"
		vx, vy = vectorFromAngle(belleAngle+10,24000)
		enemyGold = CpuShip():setFaction(exuariFaction):setCallSign("Gold"):setTemplate(hornetMT52):orderRoaming():setPosition(fezx+vx,fezy+vy):setRotation(startAngle+190)
		table.insert(belleList, enemyGold)
		if difficulty >= 1 then
			vx, vy = vectorFromAngle(belleAngle,24000)
			enemyPoverty = CpuShip():setFaction(exuariFaction):setCallSign("Poverty"):setTemplate(hornetMT52):orderAttack(friendBelle):setPosition(fezx+vx,fezy+vy):setRotation(startAngle+180)
			table.insert(belleList, enemyPoverty)
		end
		if difficulty > 1 then
			vx, vy = vectorFromAngle(belleAngle-20,24000)
			enemyWealth = CpuShip():setFaction(exuariFaction):setCallSign("Wealth"):setTemplate(hornetMT52):orderAttack(friendBelle):setPosition(fezx+vx,fezy+vy):setRotation(startAngle+160)
			table.insert(belleList, enemyWealth)
			vx, vy = vectorFromAngle(belleAngle+20,24000)
			enemyContract = CpuShip():setFaction(exuariFaction):setCallSign("Contract"):setTemplate(hornetMT52):orderRoaming():setPosition(fezx+vx,fezy+vy):setRotation(startAngle+200)
			table.insert(belleList, enemyContract)
		end
	end
end

function destroyBelleFleet(delta)
	if not friendBelle:isValid() then
		victory(exuariFaction)
	end
	belleFleetCount = 0
	for _, enemy in ipairs(belleList) do
		if enemy:isValid() then
			belleFleetCount = belleFleetCount + 1
		end
	end
	if belleFleetCount == 0 or distance(friendBelle,stationFezziwig) < 1000 then
		player:addReputationPoints(50)
		player:addToShipLog("You protected Belle. Somerset awaits","Blue")
		playSoundFile("sa_62_Child3.ogg")
		plot1 = startChristmasPresent
		secondaryOrders = "Dock with Somerset"
		plot1name = "startChristmasPresent"
		removeGMFunction(GMChristmasPresent)
		stationFezziwig:destroy()
		fezNeb1:destroy()
		fezNeb2:destroy()
		fezNeb3:destroy()
		fezNeb4:destroy()
		fezNeb5:destroy()
		friendBelle:destroy()
	end
end

function startChristmasPresent(delta)
	if player:isDocked(stationSomerset) then
		player:addToShipLog(string.format("Our sensors indicated nebulas forming then disappearing. That is impossible, of course. We started level three diagnostics on our sensors to discover what's wrong. Just before starting the diagnostic, we picked up unusual readings near Bedlam in %s. Perhaps you should investigate",stationBedlam:getSectorName()),"Magenta")
		playSoundFile("sa_62_London3.ogg")
		secondaryOrders = string.format("Investigate unusual readings near Bedlam in %s",stationBedlam:getSectorName())
		plot1 = arriveNearBedlam
		plot1name = "arriveNearBedlam"
	end
end

function arriveNearBedlam(delta)
	if distance(player,stationBedlam) < 3000 then
		player:addToShipLog("[Bob Cratchit on station Bedlam] Happy Christmas, Scrooge! You are just in time to make our holiday bright. I know it is against your nature, but surely you can decorate our skies with alien enemy ship explosions. In the worst case, we will get a sky decorated with your ship exploding.","Yellow")
		playSoundFile("sa_62_BobCratchit1.ogg")
		cratchitList = {}
		px, py = player:getPosition()
		vx, vy = vectorFromAngle(random(0,300),random(6000,8000))
		enemyHolly = CpuShip():setFaction(gitmFaction):setCallSign("Holly"):setTemplate(phobosT3):orderAttack(player):setPosition(px+vx,py+vy)
		table.insert(cratchitList, enemyHolly)
		plot1 = destroyCratchitFleet
		plot1name = "destroyCratchitFleet"
		secondaryOrders = "Destroy marauding enemies"
		if difficulty >= 1 then
			vx, vy = vectorFromAngle(random(0,300),random(8000,12000))
			enemyWreath = CpuShip():setFaction(gitmFaction):setCallSign("Wreath"):setTemplate(phobosT3):orderRoaming():setPosition(px+vx,py+vy)
			table.insert(cratchitList, enemyWreath)
			vx, vy = vectorFromAngle(random(0,300),random(12000,20000))
			enemyBough = CpuShip():setFaction(gitmFaction):setCallSign("Bough"):setTemplate(phobosT3):orderRoaming():setPosition(px+vx,py+vy)
			table.insert(cratchitList, enemyBough)
		end
		if difficulty > 1 then
			vx, vy = vectorFromAngle(random(0,300),random(20000,25000))
			enemyTroll = CpuShip():setFaction(gitmFaction):setCallSign("Troll"):setTemplate(phobosT3):orderRoaming():setPosition(px+vx,py+vy)
			table.insert(cratchitList, enemyTroll)
			vx, vy = vectorFromAngle(random(0,300),random(25000,30000))
			enemyYuletide = CpuShip():setFaction(gitmFaction):setCallSign("Yuletide"):setTemplate(phobosT3):orderRoaming():setPosition(px+vx,py+vy)
			table.insert(cratchitList, enemyYuletide)
		end
	end
end

function destroyCratchitFleet(delta)
	cratchitFleetCount = 0
	for _, enemy in ipairs(cratchitList) do
		if enemy:isValid() then
			cratchitFleetCount = cratchitFleetCount + 1
		end
	end
	if cratchitFleetCount == 0 then
		if stationBedlam:isValid() then
			player:addReputationPoints(50)
			player:addToShipLog("[Bob Cratchit on station Bedlam] I hate to dampen your spirits, but my young maintenance technician, Tim, has become seriously ill. Our medical facilities cannot diagnose, much less treat him. The medical ship Turkey Surprise should be able to help. Could you dock with Bedlam and transport Tim to Turkey Surprise?","Yellow")
			playSoundFile("sa_62_BobCratchit2.ogg")
			turkeyAngle = random(90,180)
			bx, by = stationBedlam:getPosition()
			vx, vy = vectorFromAngle(turkeyAngle,random(20000,30000))
			friendTurkeySurprise = CpuShip():setFaction(humanFaction):setCallSign("Turkey Surprise"):setTemplate("Equipment Freighter 3"):orderDock(stationSomerset):setPosition(bx+vx,by+vy):setScannedByFaction(humanFaction,true)
			plot1 = timIll
			plot1name = "timIll"
			secondaryOrders = "Take Tim from Bedlam to Turkey Surprise"
			timAboard = false
			plot2 = turkeyNemesis
			plot2name = "turkeyNemesis"
			turkeyNemesisTimer = 30
			timLifeTimer = 240
			timHalfLife = timLifeTimer/2
		else
			globalMessage("[Ghost of Christmas present] While you fought off the ships near Bedlam, Tiny Tim, Bob Cratchit's maintenance technician perished along with the others aboard station Bedlam. Your engineering crew were so overcome with grief that they neglected a routie maintenance cycle causing engine failure on HMS Scrooge.","Red")
			victory(gitmFaction)
		end
	end
end

function turkeyNemesis(delta)
	turkeyNemesisTimer = turkeyNemesisTimer - delta
	if turkeyNemesisTimer < 0 then
		turkeyList = {}
		tx, ty = friendTurkeySurprise:getPosition()
		tgAngle = random(0,360)
		vx, vy = vectorFromAngle(tgAngle,random(4000,5000))
		enemyCrutch = CpuShip():setFaction(gitmFaction):setCallSign("Crutch"):setTemplate(piranhaF12):orderAttack(friendTurkeySurprise):setPosition(tx+vx,ty+vy)
		table.insert(turkeyList, enemyCrutch)
		plot2 = presentHunters
		plot2name = "presentHunters"
		presentHuntersTimer = 30
		vx, vy = vectorFromAngle(tgAngle,random(5000,6000))
		enemyConsumption = CpuShip():setFaction(gitmFaction):setCallSign("Consumption"):setTemplate("Karnack"):orderAttack(friendTurkeySurprise):setPosition(tx+vx,ty+vy)
		table.insert(turkeyList, enemyConsumption)
		if difficulty >= 1 then
			tgAngle = random(0,360)
			vx, vy = vectorFromAngle(tgAngle,random(4000,5000))
			enemyMalnutrition = CpuShip():setFaction(gitmFaction):setCallSign("Malnutrition"):setTemplate(piranhaF12):orderAttack(friendTurkeySurprise):setPosition(tx+vx,ty+vy)
			table.insert(turkeyList, enemyMalnutrition)
			vx, vy = vectorFromAngle(tgAngle,random(5000,6000))
			enemyRags = CpuShip():setFaction(gitmFaction):setCallSign("Rags"):setTemplate("Karnack"):orderAttack(friendTurkeySurprise):setPosition(tx+vx,ty+vy)
			table.insert(turkeyList, enemyRags)
		end
		if difficulty > 1 then
			tgAngle = random(0,360)
			vx, vy = vectorFromAngle(tgAngle,random(4000,5000))
			enemyPlague = CpuShip():setFaction(gitmFaction):setCallSign("Plague"):setTemplate(piranhaF12M):orderAttack(friendTurkeySurprise):setPosition(tx+vx,ty+vy)
			table.insert(turkeyList, enemyPlague)
			vx, vy = vectorFromAngle(tgAngle,random(5000,6000))
			enemyLimp = CpuShip():setFaction(gitmFaction):setCallSign("Limp"):setTemplate("Karnack"):orderAttack(friendTurkeySurprise):setPosition(tx+vx,ty+vy)
			table.insert(turkeyList, enemyLimp)
		end
	end
end

function presentHunters(delta)
	presentHuntersTimer = presentHuntersTimer - delta
	if presentHuntersTimer < 0 then
		tx, ty = friendTurkeySurprise:getPosition()
		sx, sy = stationSomerset:getPosition()
		enemyGoose = CpuShip():setFaction(gitmFaction):setCallSign("Goose"):setTemplate("Gunship"):orderAttack(stationSomerset):setPosition((tx+sx)/2,(ty+sy)/2)
		table.insert(turkeyList, enemyGoose)
		plot2 = presentOutrage
		plot2name = "presentOutrage"
		presentOutrageTimer = 30
		if difficulty >= 1 then
			enemySuckingPig = CpuShip():setFaction(gitmFaction):setCallSign("Sucking Pig"):setTemplate("Gunship"):orderAttack(stationSomerset):setPosition((tx+sx)/2 + 1000,(ty+sy)/2)
			table.insert(turkeyList, enemySuckingPig)
			enemyMincePie = CpuShip():setFaction(gitmFaction):setCallSign("Mince Pie"):setTemplate("Gunship"):orderAttack(stationSomerset):setPosition((tx+sx)/2 - 1000,(ty+sy)/2)
			table.insert(turkeyList, enemyMincePie)
		end
		if difficulty > 1 then
			enemyPlumPudding = CpuShip():setFaction(gitmFaction):setCallSign("Plum Pudding"):setTemplate("Gunship"):orderAttack(stationSomerset):setPosition((tx+sx)/2,(ty+sy)/2 + 1000)
			table.insert(turkeyList, enemyPlumPudding)
			enemyChestnut = CpuShip():setFaction(gitmFaction):setCallSign("Chestnut"):setTemplate("Gunship"):orderAttack(stationSomerset):setPosition((tx+sx)/2,(ty+sy)/2 - 1000)
			table.insert(turkeyList, enemyChestnut)
		end
	end
end

function presentOutrage(delta)
	presentOutrageTimer = presentOutrageTimer - delta
	if presentOutrageTimer < 0 then
		player:addToShipLog("How dare you bring us here!","#556b2f")
		playSoundFile("sa_62_Kralien1.ogg")
		plot2 = presentIntent
		plot2name = "presentIntent"
		presentIntentTimer = 20
	end
end

function presentIntent(delta)
	presentIntentTimer = presentIntentTimer - delta
	if presentIntentTimer < 0 then
		player:addToShipLog("Silence! Since we are here, let us destroy Somerset","#556b2f")
		playSoundFile("sa_62_Kralien2.ogg")
		plot2 = nil
		plot2name = ""
	end
end

function timIll(delta)
	timLifeTimer = timLifeTimer - delta
	if not timAboard then
		if player:isDocked(stationBedlam) then
			timAboard = true
			player:addToShipLog(string.format("[Bob Cratchit] Tim has been transported aboard %s. Hurry to Turkey Surprise. The doctors say he has about %i minutes to live",player:getCallSign(),math.floor(timLifeTimer/60)),"Yellow")
		end
		if timLifeTimer < timHalfLife then
			if halfMsg == nil then
				halfMsg = "sent"
				player:addToShipLog(string.format("[Bob Cratchit] Please hurry, the doctors say Tim has less than %i seconds to live",timHalfLife),"Yellow")
			end
		end
	else
		if timLifeTimer < timHalfLife then
			if halfMsg == nil then
				halfMsg = "sent"
				player:addToShipLog(string.format("[Sick Bay] Tim has less than %i seconds to live",timHalfLife),"Magenta")
			end
		end
		if friendTurkeySurprise:isValid() then
			if distance(player,friendTurkeySurprise) < 500 then
				if player:getShieldsActive() then
					if shieldsOnMsg == nil then
						shieldsOnMsg = "sent"
						player:addToShipLog("[Turkey Surprise] We cannot transport through your shields. Please lower them","Cyan")
						playSoundFile("sa_62_Turkey1.ogg") 
					end
				else
					player:addToShipLog("[Turkey Surprise] We have transported Tim and our doctors are examining him","Cyan")
					playSoundFile("sa_62_Turkey3.ogg")
					plot1 = timHeal
					plot1name = "timHeal"
					secondaryOrders = "Protect Turkey Surprise"
					timHealTimer = 50
				end
			end
		end
	end
	if timLifeTimer < 0 then
		globalMessage(string.format("Tim dies. %s disabled by a broken heart (engine failure)",player:getCallSign()))
		victory(gitmFaction)
	end
end

function timHeal(delta)
	timHealTimer = timHealTimer - delta
	if timHealTimer < 0 then
		player:addToShipLog("[Bob Cratchit] Turkey Surprise tells me Tim is doing fine. In fact, he's ready to return to duty. We need him here for critical repairs. Would you bring him home, please?","Yellow")
		playSoundFile("sa_62_BobCratchit3.ogg")
		timAboard = false
		plot1 = returnTim
		plot1name = "returnTim"
		secondaryOrders = "Return Tim to Bedlam"
	end
	if not friendTurkeySurprise:isValid() then
		globalMessage(string.format("Tim dies with Turkey Surprise. %s disabled by a broken heart (engine failure)",player:getCallSign()))
		victory(gitmFaction)
	end
end

function returnTim(delta)
	if timAboard then
		if player:isDocked(stationBedlam) then
			player:addToShipLog("[Bob Cratchit] We are so glad Tim is better. He serves a critical role here. Somerset is looking for you","Yellow")
			playSoundFile("sa_62_BobCratchit4.ogg")
			plot1 = endChristmasPast
			plot1name = "endChristmasPast"
			secondaryOrders = "Dock with Somerset"
		end
	else
		if distance(friendTurkeySurprise,player) < 500 then
			if player:getShieldsActive() then
				if shieldsOnMsg == nil then
					shieldsOnMsg = "sent"
					player:addToShipLog("[Turkey Surprise] We cannot transport through your shields. Please lower them","Cyan")
					playSoundFile("sa_62_Turkey2.ogg")
				end
			else
				player:addToShipLog("[Transporter Room] Tim has been transported aboard. Bedlam is wating for us to bring him back to work on repairs","Magenta")
				timAboard = true
			end
		end
		if not friendTurkeySurprise:isValid() then
			globalMessage(string.format("Tim dies with Turkey Surprise. %s disabled by a broken heart (engine failure)",player:getCallSign()))
			victory(gitmFaction)
		end
	end
end

function endChristmasPast(delta)
	for _, enemy in ipairs(turkeyList) do
		enemy:destroy()
	end
	friendTurkeySurprise:destroy()
	removeGMFunction(GMChristmasFuture)
	plot1 = startChristmasFuture
	plot1name = "startChristmasFuture"
end

function startChristmasFuture(delta)
	secondaryOrders = "Dock with Somerset"
	if player:isDocked(stationSomerset) then
		player:addToShipLog(string.format("We are glad you took care of those Ghosts in the machine. They came out of nowhere! We still saw some impossible sensor readings even after our sensor overhaul. We are now conducting a level 5 diagnostic and repair regimen. Keep an eye on the City in %s",stationCity:getSectorName()),"Magenta")
		playSoundFile("sa_62_London4.ogg")
		secondaryOrders = string.format("Watch the City in %s",stationCity:getSectorName())
		cx, cy = stationCity:getPosition()
		futx = cx + 5000
		futy = cy - 5000
		plot1 = futureEffect1
		plot1name = "futureEffect1"
		futureEffect1Timer = 15
	end
end

function futureEffect1(delta)
	futureEffect1Timer = futureEffect1Timer - delta
	if futureEffect1Timer < 0 then
		futNeb1 = Nebula():setPosition(futx, futy)
		futureEffect2Timer = 10
		plot1 = futureEffect2
		plot1name = "futureEffect2"
	end
end

function futureEffect2(delta)
	futureEffect2Timer = futureEffect2Timer - delta
	if futureEffect2Timer < 0 then
		futNeb2 = Nebula():setPosition(futx+10000,futy)
		futNeb3 = Nebula():setPosition(futx-10000,futy)
		futNeb4 = Nebula():setPosition(futx,futy+10000)
		futNeb5 = Nebula():setPosition(futx,futy-10000)
		futNeb6 = Nebula():setPosition(futx-10000,futy-10000)
		futNeb7 = Nebula():setPosition(futx+10000,futy-10000)
		futNeb8 = Nebula():setPosition(futx-10000,futy+10000)
		futNeb9 = Nebula():setPosition(futx+10000,futy+10000)
		futureEffect3Timer = 10
		plot1 = futureEffect3
		plot1name = "futureEffect3"
	end
end

function futureEffect3(delta)
	futureEffect3Timer = futureEffect3Timer - delta
	if futureEffect3Timer < 0 then
		movingNebula = {}
		nebAngle = 0
		for nidx=1,12 do
			vx, vy = vectorFromAngle(nebAngle,40000)
			mNeb = Nebula():setPosition(futx+vx,futy+vy)
			mNeb.angle = nebAngle
			table.insert(movingNebula,mNeb)
			nebAngle = nebAngle + 30
		end
		plot2 = moveNebula
		plot1 = futureEffect4
		plot1name = "futureEffect4"
		futureEffect4Timer = 10
	end
end

function moveNebula(delta)
	for nidx=1,#movingNebula do
		newAngle = movingNebula[nidx].angle + .1
		if newAngle > 360 then
			newAngle = newAngle - 360
		end
		movingNebula[nidx].angle = newAngle
		vnx, vny = vectorFromAngle(newAngle,40000)
		movingNebula[nidx]:setPosition(futx+vnx,futy+vny)
	end
end

function futureEffect4(delta)
	futureEffect4Timer = futureEffect4Timer - delta
	if futureEffect4Timer < 0 then
		vx, vy = vectorFromAngle(0,2500)
		stationGraveyard = SpaceStation():setTemplate(smallStation):setFaction(neutralFaction):setCallSign("Graveyard"):setPosition(futx+vx, futy+vy)
		stationGraveyard.angle = 0
		vx, vy = vectorFromAngle(120,2500)
		stationCemetery = SpaceStation():setTemplate(smallStation):setFaction(neutralFaction):setCallSign("Cemetery"):setPosition(futx+vx, futy+vy)
		stationCemetery.angle = 120
		vx, vy = vectorFromAngle(240,2500)
		stationNecropolis = SpaceStation():setTemplate(smallStation):setFaction(neutralFaction):setCallSign("Necropolis"):setPosition(futx+vx, futy+vy)
		stationNecropolis.angle = 240
		player:addToShipLog("Face your future","Red")
		graveyardList = {}
		cemeteryList = {}
		necropolisList = {}
		plot3 = orbitStations
		plot3name = "orbitStations"
		plot1 = futureCheck
		plot1name = "futureCheck"
	end
end

function orbitStations(delta)
	newStationAngle = stationGraveyard.angle - .1
	if newStationAngle < 0 then
		newStationAngle = newStationAngle + 360
	end
	stationGraveyard.angle = newStationAngle
	vsx, vsy = vectorFromAngle(newStationAngle,2500)
	stationGraveyard:setPosition(futx+vsx,futy+vsy)
	newStationAngle = stationCemetery.angle - .1
	if newStationAngle < 0 then
		newStationAngle = newStationAngle + 360
	end
	stationCemetery.angle = newStationAngle
	vsx, vsy = vectorFromAngle(newStationAngle,2500)
	stationCemetery:setPosition(futx+vsx,futy+vsy)
	newStationAngle = stationNecropolis.angle - .1
	if newStationAngle < 0 then
		newStationAngle = newStationAngle + 360
	end
	stationNecropolis.angle = newStationAngle
	vsx, vsy = vectorFromAngle(newStationAngle,2500)
	stationNecropolis:setPosition(futx+vsx,futy+vsy)
end

function futureCheck(delta)
	if player:isDocked(stationGraveyard) then
		graveyardDocked = true
		if graveyardSpawned then
			graveyardFleetCount = 0
			for _, enemy in ipairs(graveyardList) do
				if enemy:isValid() then
					graveyardFleetCount = graveyardFleetCount + 1
				end
			end
			if graveyardFleetCount == 0 then
				for _, enemy in ipairs(graveyardList) do
					enemy:destroy()
				end
				graveyardSpawned = false
			end
		else
			spawnGraveyard()
		end
	end
	if player:isDocked(stationCemetery) then
		cemeteryDocked = true
		if cemeterySpawned then
			cemeteryFleetCount = 0
			for _, enemy in ipairs(cemeteryList) do
				if enemy:isValid() then
					cemeteryFleetCount = cemeteryFleetCount + 1
				end
			end
			if cemeteryFleetCount == 0 then
				for _, enemy in ipairs(cemeteryList) do
					enemy:destroy()
				end
				cemeterySpawned = false
			end
		else
			spawnCemetery()
		end
	end
	if player:isDocked(stationNecropolis) then
		necropolisDocked = true
		if necropolisSpawned then
			necropolisFleetCount = 0
			for _, enemy in ipairs(necropolisList) do
				if enemy:isValid() then
					necropolisFleetCount = necropolisFleetCount + 1
				end
			end
			if necropolisFleetCount == 0 then
				for _, enemy in ipairs(necropolisList) do
					enemy:destroy()
				end
				necropolisSpawned = false
			end
		else
			spawnNecropolis()
		end
	end
	if graveyardDocked and cemeteryDocked and necropolisDocked then
		fleetCount = 0
		if graveyardSpawned then
			graveyardFleetCount = 0
			for _, enemy in ipairs(graveyardList) do
				if enemy:isValid() then
					graveyardFleetCount = graveyardFleetCount + 1
				end
			end
			fleetCount = fleetCount + graveyardFleetCount
		end
		if cemeterySpawned then
			cemeteryFleetCount = 0
			for _, enemy in ipairs(cemeteryList) do
				if enemy:isValid() then
					cemeteryFleetCount = cemeteryFleetCount + 1
				end
			end
			fleetCount = fleetCount + cemeteryFleetCount
		end
		if necropolisSpawned then
			necropolisFleetCount = 0
			for _, enemy in ipairs(necropolisList) do
				if enemy:isValid() then
					necropolisFleetCount = necropolisFleetCount + 1
				end
			end
			fleetCount = fleetCount + necropolisFleetCount
		end
		if fleetCount == 0 then
			plot1 = cleanFuture
			plot1name = "cleanFuture"
		end
	end
end

function spawnGraveyard()
	graveyardSpawned = true
	enemyButton = CpuShip():setFaction(hiveFaction):setCallSign("Button"):setTemplate("Ktlitan Drone"):orderAttack(player):setPosition(futx,futy)
	table.insert(graveyardList, enemyButton)
	if difficulty >= 1 then
		enemyBoot = CpuShip():setFaction(hiveFaction):setCallSign("Boot"):setTemplate("Ktlitan Drone"):orderAttack(player):setPosition(futx+800,futy)
		table.insert(graveyardList, enemyBoot)
		enemySheet = CpuShip():setFaction(hiveFaction):setCallSign("Sheet"):setTemplate("Ktlitan Drone"):orderAttack(player):setPosition(futx-800,futy)
		table.insert(graveyardList, enemySheet)
	end
	if difficulty > 1 then
		enemyBedCurtain = CpuShip():setFaction(hiveFaction):setCallSign("Bed Curtain"):setTemplate("Ktlitan Drone"):orderAttack(player):setPosition(futx,futy+800)
		table.insert(graveyardList, enemyBedCurtain)
	end
end

function spawnCemetery()
	cemeterySpawned = true
	enemyRelent = CpuShip():setFaction(hiveFaction):setCallSign("Relent"):setTemplate("Ktlitan Scout"):orderAttack(player):setPosition(futx,futy)
	table.insert(cemeteryList, enemyRelent)
	if difficulty >= 1 then
		enemyRuin = CpuShip():setFaction(hiveFaction):setCallSign("Ruin"):setTemplate("Ktlitan Scout"):orderAttack(player):setPosition(futx,futy+800)
		table.insert(cemeteryList, enemyRuin)
		enemyCreditor = CpuShip():setFaction(hiveFaction):setCallSign("Creditor"):setTemplate("Ktlitan Scout"):orderAttack(player):setPosition(futx,futy-800)
		table.insert(cemeteryList, enemyCreditor)
	end
	if difficulty > 1 then
		enemyDelight = CpuShip():setFaction(hiveFaction):setCallSign("Delight"):setTemplate("Ktlitan Scout"):orderAttack(player):setPosition(futx-800,futy)
		table.insert(cemeteryList, enemyDelight)
	end
end

function spawnNecropolis()
	necropolisSpawned = true
	enemyAbsent = CpuShip():setFaction(hiveFaction):setCallSign("Absent"):setTemplate("Ktlitan Breaker"):orderAttack(player):setPosition(futx,futy)
	table.insert(necropolisList, enemyAbsent)
	if difficulty >= 1 then
		enemyGrief = CpuShip():setFaction(hiveFaction):setCallSign("Grief"):setTemplate("Ktlitan Breaker"):orderAttack(player):setPosition(futx+800,futy+800)
		table.insert(necropolisList, enemyGrief)
	end
	if difficulty > 1 then
		enemyTomb = CpuShip():setFaction(hiveFaction):setCallSign("Tomb"):setTemplate("Ktlitan Breaker"):orderAttack(player):setPosition(futx-800,futy-800)
		table.insert(necropolisList, enemyTomb)
	end
end

function cleanFuture(delta)
	player:addToShipLog("You have faced your future","Red")
	plot2 = nil
	plot3 = nil
	stationGraveyard:destroy()
	stationCemetery:destroy()
	stationNecropolis:destroy()
	for nidx=1,#movingNebula do
		movingNebula[nidx]:destroy()
	end
	futNeb1:destroy()
	futNeb2:destroy()
	futNeb3:destroy()
	futNeb4:destroy()
	futNeb5:destroy()
	futNeb6:destroy()
	futNeb7:destroy()
	futNeb8:destroy()
	futNeb9:destroy()
	plot1 = returnMsg1
	plot1name = "returnMsg1"
end

function returnMsg1(delta)
	player:addToShipLog("Dock at Somerset for a well deserved Christmas break","Magenta")
	plot1 = returnMsg2
	plot1name = "returnMsg2"
	returnMsg2Timer = 4
end

function returnMsg2(delta)
	returnMsg2Timer = returnMsg2Timer - delta
	if returnMsg2Timer < 0 and distance(player,stationSomerset) < 80000 then
		player:addToShipLog("[Jacob Marley] Good to see you spreading joy and easing pain, Scrooge","Red")
		playSoundFile("sa_62_Marley4.ogg")
		plot1 = returnMsg3
		plot1name = "returnMsg3"
		returnMsg3Timer = 4
	end
end

function returnMsg3(delta)
	returnMsg3Timer = returnMsg3Timer - delta
	if returnMsg3Timer < 0 and distance(player,stationSomerset) < 70000 then
		player:addToShipLog("May the shadows of the things that have been continue to remind you of the joy of Christmas","Blue")
		playSoundFile("sa_62_Child4.ogg")
		plot1 = returnMsg4
		plot1name = "returnMsg4"
		returnMsg4Timer = 8
	end
end

function returnMsg4(delta)
	returnMsg4Timer = returnMsg4Timer - delta
	if returnMsg4Timer < 0 and distance(player,stationSomerset) < 60000 then
		player:addToShipLog("Despite Ignorance and Want, prisons and workhouses, know each day fully and celebrate it, especially Christmas","Yellow")
		plot1 = returnMsg5
		plot1name = "returnMsg5"
		returnMsg5Timer = 15
	end
end

function returnMsg5(delta)
	returnMsg5Timer = returnMsg5Timer - delta
	if returnMsg5Timer < 0 and distance(player,stationSomerset) < 50000 then
		player:addToShipLog("[Urchin Express]\nHappy Christmas, sir!\nTop o' the day to ya!\nThanks for the shillings!","Cyan")
		playSoundFile("sa_62_Urchins.ogg")
		plot1 = returnMsg6
		plot1name = "returnMsg6"
		returnMsg6Timer = 3
	end
end

function returnMsg6(delta)
	returnMsg6Timer = returnMsg6Timer - delta
	if returnMsg6Timer < 0 and distance(player,stationSomerset) < 40000 then
		player:addToShipLog("[Fred from QE17] Merry Christmas, uncle! Stop by and share Christmas dinner with us when you're off duty","Green")
		playSoundFile("sa_62_Fred.ogg")
		plot1 = returnMsg7
		plot1name = "returnMsg7"
		returnMsg7Timer = 6
	end
end

function returnMsg7(delta)
	returnMsg7Timer = returnMsg7Timer - delta
	if returnMsg7Timer < 0 and distance(player,stationSomerset) < 30000 then
		player:addToShipLog("[Bob on Cratchit Cruiser] Happy Christmas, Mr. Scrooge. Thanks for the raise and for helping Tiny Tim","Yellow")
		playSoundFile("sa_62_BobCratchit5.ogg")
		plot1 = returnMsg8
		plot1name = "returnMsg8"
		returnMsg8Timer = 10
	end
end

function returnMsg8(delta)
	returnMsg8Timer = returnMsg8Timer - delta
	if returnMsg8Timer < 0 and distance(player,stationSomerset) < 20000 then
		player:addToShipLog("[Tim on Cratchit Cruiser] God bless us every one","White")
		playSoundFile("sa_62_Tim.ogg")
		plot1 = returnMsg9
		plot1name = "returnMsg9"
		returnMsg9Timer = 6
	end
end

function returnMsg9(delta)
	returnMsg9Timer = returnMsg9Timer - delta
	if returnMsg9Timer < 0 and distance(player,stationSomerset) < 10000 then
		if difficulty > 1 then
			player:addToShipLog("[Tim on Cratchit Cruiser] Give me some freakin' eggnog","White")
			playSoundFile("sa_62_Tim2.ogg")
		end
		plot1 = finalDock
		plot1name = "finalDock"
	end
end

function finalDock(delta)
	if player:isDocked(stationSomerset) then
		globalMessage("Merry Christmas!")
		victory(humanFaction)
	end
end

function update(delta)
	if delta == 0 then
		return
		--game paused
	end
	if not stationSomerset:isValid() then
		globalMessage(string.format("Somerset destroyed. %s dishonored and meaner. Christmas is ruined",player:getCallSign()))
		victory(kraylorFaction)
	end
	if plot1 ~= nil then
		plot1(delta)
	end
	if plot2 ~= nil then
		plot2(delta)
	end
	if plot3 ~= nil then
		plot3(delta)
	end
	if plotZ ~= nil then
		plotZ(delta)
	end
end
