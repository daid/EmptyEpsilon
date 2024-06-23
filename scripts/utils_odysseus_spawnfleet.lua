
-- Max fighter count for NPC ships. Resets at every jump.
function setSpawnFleetButton(fleetSpawn, fleetVariation, sx, sy, offSetModifier, spawnModifier, revealCallSigns, orders, delayInMin, delayInMax, delayOutMin, delayOutMax)
     
    spawnDebugLog = false
    randomizeSpawnLoc = true

    fleetCountIn = 0
    fleetCountOut = 0

    friendlyFightersOut_valor = {}
    friendlyFightersOut_inferno = {}
    friendlyFightersOut_halo = {}
    friendlyFightersOut_aurora = {}

    fleetbuttonName = "Friendly " .. fleetSpawn 

    if fleetVariation ~= nil then
        fleetbuttonName = fleetbuttonName .. fleetVariation
    end


    fleetRevealCallSigns = revealCallSigns 
    fleetOrders = orders
    fleetSpawnSet = fleetSpawn
    fleetVariationSet = fleetVariation
    fsx = sx
    fsy = sy

    jumpDelayInMin = delayInMin
    jumpDelayInMax = delayInMax
    jumpDelayOutMin = delayOutMin
    jumpDelayOutMax = delayOutMax	
    distanceModifier = offSetModifier
    spawnModifierSet = spawnModifier
    positionModifier = math.floor(spawnModifier*1.5)

    if fleet_list == nil then
        setFleetTable()
    end

    addGMFunction(_("Fleet", fleetbuttonName), function() jumpInPrep() end)

end

function setFleetTable()

    fleet_list = {}
    table.insert(fleet_list,1,{spawnorder=1,name='UNREC-253',military=true,callsign="ESS Aurora",faction="EOC Starfleet",xoff=1,yoff=1,aiset="missilevolley",template="Stellar Class Battlecruiser",fleetForm=5,fleetVariation={"A", "B", "C"}})
    table.insert(fleet_list,2,{spawnorder=2,name='UNREC-364',military=true,callsign="ESS Warrior",faction="EOC Starfleet",xoff=-12000,yoff=-1500,aiset="missilevolley",template="Eclipse Class Frigate",fleetForm=5,fleetVariation={"A", "B"}})
    table.insert(fleet_list,3,{spawnorder=3,name='UNREC-281',military=true,callsign="ESS Inferno",faction="EOC Starfleet",xoff=-8000,yoff=-4500,aiset="missilevolley",template="Eclipse Class Frigate",fleetForm=5,fleetVariation={"A", "B"}})
    table.insert(fleet_list,4,{spawnorder=4,name='UNREC-307',military=true,callsign="CSS Taurus",faction="EOC Starfleet",xoff=-4000,yoff=-3000,aiset="missilevolley",template="Helios Class Corvette",fleetForm=5,fleetVariation={"A", "B"}})
    table.insert(fleet_list,5,{spawnorder=5,name='UNREC-310',military=true,callsign="ESS Valkyrie",faction="EOC Starfleet",xoff=-2000,yoff=1500,aiset="missilevolley",template="Helios Class Corvette",fleetForm=4,fleetVariation={"A", "B"}})
    table.insert(fleet_list,6,{spawnorder=6,name='UNREC-208',military=true,callsign="ESS Aries",faction="EOC Starfleet",xoff=-10000,yoff=-3000,aiset="missilevolley",template="Aurora Class Explorer",fleetForm=5,fleetVariation={"A", "B"}})
    table.insert(fleet_list,7,{spawnorder=7,name='UNREC-248',military=true,callsign="OSS Burro",faction="EOC Starfleet",xoff=-6000,yoff=-4500,aiset="missilevolley",template="Luna Class Cargo Carrier",fleetForm=5,fleetVariation={"A", "B"}})
    table.insert(fleet_list,8,{spawnorder=8,name='UNREC-279',military=false,callsign="OSS Immortal",faction="Corporate owned",xoff=-10000,yoff=-1500,aiset="evasive",template="Eclipse Class Frigate",fleetForm=5,fleetVariation={"A", "B"}})
    table.insert(fleet_list,9,{spawnorder=9,name='UNREC-298',military=false,callsign="ESS Spectrum",faction="Corporate owned",xoff=-6000,yoff=0,aiset="evasive",template="Eclipse Class Frigate",fleetForm=5,fleetVariation={"A", "B"}})
    table.insert(fleet_list,10,{spawnorder=10,name='UNREC-301',military=false,callsign="OSS Starfall",faction="Corporate owned",xoff=-10000,yoff=1500,aiset="evasive",template="Eclipse Class Frigate",fleetForm=5,fleetVariation={"A", "B"}})
    table.insert(fleet_list,11,{spawnorder=11,name='UNREC-296',military=false,callsign="OSS Ravager",faction="Corporate owned",xoff=-5000,yoff=1500,aiset="evasive",template="Helios Class Corvette",fleetForm=5,fleetVariation={"A", "B"}})
    table.insert(fleet_list,12,{spawnorder=12,name='UNREC-387',military=false,callsign="OSS Vulture",faction="Corporate owned",xoff=-8000,yoff=3000,aiset="evasive",template="Helios Class Corvette",fleetForm=1,fleetVariation={"A", "B"}})
    table.insert(fleet_list,13,{spawnorder=13,name='UNREC-289',military=false,callsign="ESS Memory",faction="Government owned",xoff=-5000,yoff=-1500,aiset="evasive",template="Helios Class Corvette",fleetForm=5,fleetVariation={"A", "B"}})
    table.insert(fleet_list,14,{spawnorder=14,name='UNREC-294',military=false,callsign="CSS Prophet",faction="Faith of the High Science",xoff=-7000,yoff=1500,aiset="evasive",template="Aurora Class Explorer",fleetForm=3,fleetVariation={"A", "B"}})
    table.insert(fleet_list,15,{spawnorder=15,name='UNREC-285',military=false,callsign="OSS Karma",faction="Unregistered",xoff=-7000,yoff=-1500,aiset="evasive",template="Aurora Class Explorer",fleetForm=5,fleetVariation={"A"}})
    table.insert(fleet_list,16,{spawnorder=16,name='UNREC-286',military=false,callsign="OSS Marauder",faction="Corporate owned",xoff=-12000,yoff=0,aiset="evasive",template="Aurora Class Explorer",fleetForm=5,fleetVariation={"A", "B"}})
    table.insert(fleet_list,17,{spawnorder=17,name='UNREC-261',military=false,callsign="ESS Discovery",faction="Government owned",xoff=-9000,yoff=0,aiset="evasive",template="Helios Class Corvette",fleetForm=5,fleetVariation={"A", "B"}})
    table.insert(fleet_list,18,{spawnorder=18,name='UNREC-355',military=false,callsign="CSS Whirlwind",faction="Corporate owned",xoff=-8000,yoff=-3000,aiset="evasive",template="Helios Class Corvette",fleetForm=5,fleetVariation={"A", "B"}})
    table.insert(fleet_list,19,{spawnorder=19,name='UNREC-291',military=false,callsign="ESS Polaris",faction="Corporate owned",xoff=-6000,yoff=3000,aiset="evasive",template="Eclipse Class Frigate",fleetForm=2,fleetVariation={"A", "B"}})
    table.insert(fleet_list,20,{spawnorder=20,name='UNREC-257',military=false,callsign="CSS Cyclone",faction="Corporate owned",xoff=-3000,yoff=0,aiset="evasive",template="Eclipse Class Frigate",fleetForm=5,fleetVariation={"A", "B"}})
    table.insert(fleet_list,21,{spawnorder=21,name='UNREC-249',military=false,callsign="CSS Centurion",faction="Corporate owned",xoff=-6000,yoff=-3000,aiset="evasive",template="Eclipse Class Frigate",fleetForm=5,fleetVariation={"A", "B"}})
    table.insert(fleet_list,22,{spawnorder=22,name='UNREC-232',military=true,callsign="ESS Arthas",faction="EOC Starfleet",xoff=-10000,yoff=3000,aiset="missilevolley",template="Aurora Class Explorer",fleetForm=5,fleetVariation={"A", "B"}})
    table.insert(fleet_list,23,{spawnorder=23,name='UNREC-237',military=true,callsign="ESS Bluecoat",faction="EOC Starfleet",xoff=-2000,yoff=-1500,aiset="missilevolley",template="Helios Class Corvette",fleetForm=5,fleetVariation={"A", "B"}})
    table.insert(fleet_list,24,{spawnorder=24,name='UNREC-264',military=true,callsign="ESS Envoy",faction="EOC Starfleet",xoff=-4000,yoff=3000,aiset="missilevolley",template="Helios Class Corvette",fleetForm=5,fleetVariation={"A", "B", }})
    table.insert(fleet_list,25,{spawnorder=25,name='UNREC-327',military=true,callsign="ESS Valor",faction="EOC Starfleet",xoff=-8000,yoff=4500,aiset="missilevolley",template="Eclipse Class Frigate",fleetForm=5,fleetVariation={"A", "B"}})
    table.insert(fleet_list,26,{spawnorder=26,name='UNREC-278',military=true,callsign="ESS Harbinger",faction="EOC Starfleet",xoff=-12000,yoff=1500,aiset="missilevolley",template="Eclipse Class Frigate",fleetForm=5,fleetVariation={"A", "B"}})
    table.insert(fleet_list,27,{spawnorder=27,name='UNREC-275',military=true,callsign="ESS Halo",faction="EOC Starfleet",xoff=-14000,yoff=0,aiset="missilevolley",template="Stellar Class Battlecruiser",fleetForm=5,fleetVariation={"A", "B", "C"}})

    fleetSize = 27

end

-- Calculates values based on ship locations and sets jumpFleetStatus to "jumpIn"
-- update(delta) at utils_odysseus.lua calls spawnfleetDelta
function jumpInPrep()
    if spawnDebugLog then
        print("Func: jumpInPrep - Global In:", fleetSpawnSet, fleetVariationSet,  fsx, fsy, distanceModifier, positionModifier, fleetRevealCallSigns, fleetOrders, jumpDelayInMin, jumpDelayInMax, jumpDelayOutMin, jumpDelayOutMax)
    end    

    nextJumpInAt = getScenarioTime()

    ox, oy = odysseus:getPosition()

    --set Aurora spawnpoint
     ax = fsx + ox
     ay = fsy + oy			

    local heading = tostring(math.floor(angleHeading(ox, oy, fsx, fsy)))

    auroraHeading = math.floor(90-(irandom(-45, 45)))
    if randomizeSpawnLoc == false then
        auroraHeading = 90
    end

    fleetObjectsIn = {}

    fleetJumpStatus = "jumpIn"

    if fleetVariationSet ~= nil then
        local fleetButtonNameA = "Friendly " .. fleetSpawnSet .. "A"
        local fleetButtonNameB = "Friendly " .. fleetSpawnSet .. "B"
        removeGMFunction(fleetButtonNameA) 
        removeGMFunction(fleetButtonNameB) 
    else
        removeGMFunction(fleetbuttonName) 
    end
    if fleetRevealCallSigns == false then 
        odysseus:addToShipLog(string.format(_("shipLog", "EVA sector scanner alarm. Multiple incoming jumps detected from heading %d. Unidentified vessels."), heading), "Red")
    else
        odysseus:addToShipLog(string.format(_("shipLog", "EVA sector scanner alarm. Multiple incoming jumps detected from heading %d. Identified vessels."), heading), "White")
    end
end
    
-- Called by update(delta) which is located in utils_odysseus.lua
function jumpInDelta()



    if fleetCountIn > fleetSize then
        fleetJumpStatus = "jumpInAfter"
        print("Func: jumpInDelta - Error occured, didn't stop to last ship")
    end

    fleetCountIn = fleetCountIn+1
    if spawnDebugLog then
        print("Func: jumpInPrep - Global In:", nextJumpInAt, ox, oy,  ax, ay, auroraHeading, fleetJumpStatus)
        print("Func: jumpInPrep - fleetCountIn", fleetCountIn)
    end    

    local value = fleet_list[fleetCountIn]
    local callsign = value.name

        local shipfleetForm = value.fleetForm
        local shipfleetVariation = value.fleetVariation

        local spawnValue = checkFleetSpawn(fleetSpawnSet, fleetVariationSet, shipfleetForm, shipfleetVariation)

        if spawnValue == false then
            return
        end

        nextJumpInAt = getScenarioTime() + random(jumpDelayInMin, jumpDelayInMax)


    local faction = "Unidentified"
    if fleetRevealCallSigns == true then
        callsign = value.callsign
        faction = value.faction
    end

    local shipTemplate = value.template
    local xoff = value.xoff*distanceModifier
    local yoff = value.yoff*distanceModifier
    local fleetform = value.fleetForm
     xset, yset, x1, y1 = calculateSpawnLocations(xoff, yoff)
            
    local ship= CpuShip():setCallSign(callsign):setAI(value.aiset):setTemplate(shipTemplate):setPosition(x1, y1):setRotation(irandom(0,380)):setScannedByFaction("Unidentified", true):setScannedByFaction("Corporate owned"):setCanBeDestroyed(false)
    ship:setRotation(irandom(0,380)):setFaction(faction)
    table.insert(fleetObjectsIn, ship)

    if fleetRevealCallSigns == true then
        ship:setScannedByFaction("EOC Starfleet", true):setScannedByFaction("EOC_Starfleet", true)
    end
    if value.name == "UNREC-253" then --Aurora
        aurora = ship
        flagship = ship
        ship:setRotation(auroraHeading):setHeading(auroraHeading):setPosition(ax,ay)
    else
        if fleetOrders == "formation" then
            ship:orderFlyFormation(flagship, xset, yset)
        end
    end
    if value.name == "UNREC-291" then --Polaris
        polaris = ship
    end
    if value.name == "UNREC-387" then -- vulture
        vulture = ship
    end
    if value.name == "UNREC-294" then -- Proåphet
        prophet = ship
    end
    if value.name == "UNREC-285" then --Karma
        karma = ship
    end
    if value.name == "UNREC-310" then -- valkyrie
        valkyrie = ship
    end
    if value.name == "UNREC-275" then -- halo
        halo = ship
    end
    if value.name == "UNREC-281" then -- inferno
       inferno = ship
    end
    if value.name == "UNREC-327" then -- valor
       valor = ship
    end
    if value.name == "UNREC-261" then --discovery
       discovery = ship
    end
    if value.name == "UNREC-278" then --harbinger
        harbinger = ship
     end
    if fleetCountIn >= fleetSize then
        fleetJumpStatus = "jumpInAfter"
    end
end

-- Called by update(delta) which is located in utils_odysseus.lua
function jumpInAfterDelta()
    fleetJumpStatus = "jumpInReady"

    -- Set up buttons
    showEOC()
    addGMFunction(_("buttonGM", "Fleet jump"), function() jumpOutPrep() end)


    -- If reveal call sign is true, reveal automatically. If not, add button
    if(fleetRevealCallSigns == false) then
        addGMFunction(
        _("Fleet", "Reveal fleet callsigns"), 
         function()
            revealFriendlySignsList()
            removeGMFunction("Reveal fleet callsigns")					
        end)
    end
end

function revealFriendlySignsList()
    odysseus:addToShipLog(string.format(_("shipLog", "EOC fleet handshake accepted. Vessels identified.")), "White")
    --odysseus: Lisätään "EOC fleet handshake accepted."
    for idx, object in ipairs(fleetObjectsIn) do
        local callsign = object:getCallSign()
        for key, value in ipairs(fleet_list) do    
            if object:getCallSign() == value.name then	
                object:setCallSign(value.callsign):setFaction(value.faction):setScannedByFaction("EOC Starfleet", true):setScannedByFaction("EOC_Starfleet", true)
            end
        end
    end
end

function calculateSpawnLocations(xloc, yloc)

    local xset = xloc+irandom(-1000,1000)
    local yset = yloc+irandom(-1000,1000)

    if randomizeSpawnLoc == false then
        xset = xloc
        yset = yloc
    end

    local r = irandom(0, 360)
    local xdistance = irandom(-2000, 2000)    
    local ydistance = irandom(-2000, 2000)    

    if randomizeSpawnLoc == false then
        xdistance = 0
        ydistance = 0
    end  

    local x1 = math.floor(ax + (math.cos(r / 180 * math.pi) * xdistance* positionModifier))
    local y1 = math.floor(ay + (math.sin(r / 180 * math.pi) * ydistance* positionModifier))

    local x1 = x1 + xset
    local y1 = y1 + yset


    return xset, yset, x1, y1
end



function confirm_polaris()
	removeGMFunction("Destroy ESS Polaris")
	addGMFunction("Cancel destruction", cancel_polaris)
	addGMFunction("Confirm destruction", destroy_polaris)

end

function cancel_polaris()
	addGMFunction("Destroy ESS Polaris", confirm_polaris)
	removeGMFunction("Cancel destruction")
	removeGMFunction("Confirm destruction")
end


function destroy_polaris()
	removeGMFunction("Cancel destruction")
	removeGMFunction("Confirm destruction")
    removeGMFunction("OC - Polaris")
    local tx, ty = polaris:getPosition()
    polaris:destroy()
    ExplosionEffect():setPosition(tx,ty):setSize(500):setOnRadar(true)
	odysseus:addToShipLog("EVA long range scanning results. ESS Polaris left from scanner range. No jump detected.", "Red")
end

function confirm_valkyrie()
	removeGMFunction("Destroy ESS Valkyrie")
	addGMFunction("Cancel destruction", cancel_valkyrie)
	addGMFunction("Confirm destruction", destroy_valkyrie)

end

function cancel_valkyrie()
	addGMFunction("Destroy ESS Valkyrie", confirm_valkyrie)
	removeGMFunction("Cancel destruction")
	removeGMFunction("Confirm destruction")
end

function destroy_valkyrie()
	removeGMFunction("Cancel destruction")
	removeGMFunction("Confirm destruction")
    local tx, ty = valkyrie:getPosition()
    valkyrie:destroy()
    ExplosionEffect():setPosition(tx,ty):setSize(500):setOnRadar(true)
	odysseus:addToShipLog("EVA long range scanning results. ESS Valkyrie left from scanner range. No jump detected.", "Red")
end

function confirm_prophet()
	removeGMFunction("Destroy CSS Prophet")
	addGMFunction("Cancel destruction", cancel_prophet)
	addGMFunction("Confirm destruction", destroy_prophet)

end

function cancel_prophet()
	addGMFunction("Destroy ESS Valkyrie", confirm_prophet)
	removeGMFunction("Cancel destruction")
	removeGMFunction("Confirm destruction")
end

function destroy_prophet()
	removeGMFunction("Cancel destruction")
	removeGMFunction("Confirm destruction")
    local tx, ty = prophet:getPosition()
	prophet:destroy()
    ExplosionEffect():setPosition(tx,ty):setSize(500):setOnRadar(true)
	odysseus:addToShipLog("EVA long range scanning results. CSS Prophet left from scanner range. No jump detected.", "Red")
end


function confirm_vulture()
	removeGMFunction("Destroy ESS Vulture")
	addGMFunction("Cancel destruction", cancel_vulture)
	addGMFunction("Confirm destruction", destroy_vulture)

end

function cancel_vulture()
	addGMFunction("Destroy ESS Vulture", confirm_vulture)
	removeGMFunction("Cancel destruction")
	removeGMFunction("Confirm destruction")
end

function destroy_vulture()
	removeGMFunction("Cancel destruction")
	removeGMFunction("Confirm destruction")
    local tx, ty = vulture:getPosition()
    vulture:destroy()
    ExplosionEffect():setPosition(tx,ty):setSize(500):setOnRadar(true)
  odysseus:addToShipLog("EVA long range scanning results. OSS Vulture left from scanner range. No jump detected.", "Red")
end


function confirm_karma()
	removeGMFunction("Destroy OSS Karma")
	addGMFunction("Cancel destruction", cancel_karma)
	addGMFunction("Confirm destruction", destroy_karma)

end

function cancel_karma()
	addGMFunction("Destroy ESS Karma", confirm_karma)
	removeGMFunction("Cancel destruction")
	removeGMFunction("Confirm destruction")
end

function destroy_karma()
	removeGMFunction("Cancel destruction")
	removeGMFunction("Confirm destruction") 
    local tx, ty = karma:getPosition()
    karma:destroy()
    ExplosionEffect():setPosition(tx,ty):setSize(500):setOnRadar(true)
	odysseus:addToShipLog("EVA long range scanning results. OSS Karma left from scanner range. No jump detected.", "Red")
end


function checkFleetSpawn(fleetSpawnSet, fleetVariation, shipfleetForm, shipfleetVariation)

    if fleetSpawnSet <= shipfleetForm then
        if fleetVariation ~= nil then
            local shipVariation = in_array(fleetVariationSet, shipfleetVariation)
           if shipVariation == true then
                return true
            end
        else
            return true
        end
    end

    return false
end


function jumpOutPrep()
    removeGMFunction("Fleet jump")
    removeGMFunction("EOC Orders")
    outObjectCount = 0
    nextJumpOutAt = getScenarioTime()
    fleetObjectsOut = {}
    for idx, object in ipairs(fleetObjectsIn) do
        if object:isValid() then
            outObjectCount = outObjectCount +1
            local ix, iy = object:getPosition()
            object:orderIdle(ix, iy)
            table.insert(fleetObjectsOut, object)
        end
    end
    fleetJumpStatus = "jumpOut"
end

function jumpOutDelta()
    fleetCountOut = fleetCountOut + 1
    local object = fleetObjectsOut[fleetCountOut]
    if object then
       nextJumpOutAt = getScenarioTime() + random(jumpDelayOutMin, jumpDelayOutMax)
        local tx, ty = object:getPosition()
        local inScannerRange = distanceFromOdysseysCheck(tx,ty,75000)
        if inScannerRange == true then
            local callsign = object:getCallSign()
           local faction = object:getFaction()                
            if faction ~= "Unidentified" and faction ~= "Machines" then
                odysseus:addToShipLog(string.format(_("shipLog", "EVA long range scanning results. %s left from scanner range. Jump detected."), callsign), "White")
            end
        end
        object:destroy()
    end
    if fleetCountOut >= outObjectCount then
        fleetJumpStatus = "jumpOutAfter"
    end

end

function jumpOutAfter()
    fleetJumpStatus = "jumpCompleted"
    if fleetVariationSet == nil then
        setSpawnFleetButton(fleetSpawnSet, fleetVariationSet, fsx, fsy, distanceModifier, spawnModifierSet, fleetRevealCallSigns, fleetOrders, 0,0, jumpDelayOutMin, jumpDelayOutMax)
    else
        setSpawnFleetButton(fleetSpawnSet, "A", fsx, fsy, distanceModifier, spawnModifierSet, fleetRevealCallSigns, fleetOrders, 0,0, jumpDelayOutMin, jumpDelayOutMax)
        setSpawnFleetButton(fleetSpawnSet, "B", fsx, fsy, distanceModifier, spawnModifierSet, fleetRevealCallSigns, fleetOrders, 0,0, jumpDelayOutMin, jumpDelayOutMax)
    end

end

function distanceFromOdysseysCheck(tx, ty, range)

    local ox, oy = odysseus:getPosition()

    local targetDistance = distance(tx, ty, ox, oy)
    local inScannerRange = false
    if targetDistance <= range then 
        inScannerRange = true
    end

    return inScannerRange
end