-- Odysseus fleet orders utils
function showEOC()
    addGMFunction(_("buttonGM", 'Show EOC orders'), function() showEOCOrders() end)
end

function showEOCOrders()
    removeGMFunction('Show EOC orders')   
    addGMFunction(_("buttonGM", 'Hide EOC orders'), function() hideEOCorders() end)
    addGMFunction(_("buttonGM", 'OC - Civilians'), function() civiliansRetreatOnClick() end)
    addGMFunction(_("buttonGM", 'OC - Military'), function() moveToFightOnClick() end)
    addGMFunction(_("buttonGM", 'OC - Move fleet'), function() moveFleetOnClick() end)
    addGMFunction(_("buttonGM", "Order Formation"), function() fleetFlyFormation() end)
    addGMFunction(_("buttonGM", "Order Idle"), function() orderFleetIdle() end)

    addGMFunction(
        _("buttonGM", 'Spawn Aurora fighters'), 
        function()
            spawnFriendlyFighter(aurora, 4, 8)
        end)

    addGMFunction(
        _("buttonGM", 'Spawn Valor fighters'), 
        function()
            spawnFriendlyFighter(valor, 2, 4)
        end)

    addGMFunction(
        _("buttonGM", 'Spawn Inferno fighters'), 
        function()
            spawnFriendlyFighter(inferno, 2, 4)
        end)

    addGMFunction(
        _("buttonGM", 'Spawn Halo fighters'), 
        function()
            spawnFriendlyFighter(halo, 4, 8)
        end)
end

function hideEOCorders()
    removeGMFunction('OC - Civilians')   
    removeGMFunction('OC - Military')
    removeGMFunction('Order Idle')
    removeGMFunction('Order Formation')
    removeGMFunction('Spawn Aurora fighters')
    removeGMFunction('Spawn Valor fighters')
    removeGMFunction('Spawn Inferno fighters')
    removeGMFunction('Spawn Halo fighters')
    removeGMFunction('Hide EOC orders')   
    showEOC()
end

function civiliansRetreatOnClick()
    onGMClick(function(x, y)
        civiliansRetreat(x,y)
        onGMClick(nil)
    end)
end

function civiliansRetreat(x,y)
    for key, object in ipairs(fleetObjectsIn) do
        if object:getFaction() ~= "EOC Starfleet" then
            tx = x+math.floor(random(-5000, 5000))
            ty = y+math.floor(random(-5000, 5000))
            object:orderFlyTowardsBlind(tx, ty)
        end
    end
end


function moveToFightOnClick()
    onGMClick(function(x, y)
        moveToFight(x,y)
        onGMClick(nil)
    end)
end

function moveToFight(x,y)
    for idx, object in ipairs(fleetObjectsIn) do
        if object:getFaction() == "EOC Starfleet" then
            tx = x+math.floor(random(-5000, 5000))
             ty = y+math.floor(random(-5000, 5000))
            object:orderDefendLocation(tx, ty)
        end
    end
end

function moveFleetOnClick()
    onGMClick(function(x, y)
        moveFleet(x,y)
        onGMClick(nil)
    end)
end


function moveFleet(x,y)
    aurora:orderFlyTowards(x,y)
end



function fleetFlyFormation()
    flagship = aurora
    flagship:orderIdle()
    for idx, object in ipairs(fleetObjectsIn) do
        local callsign = object:getCallSign()
        for key, value in ipairs(fleet_list) do    
            if value.callsign ~= "ESS Aurora" then
                if object:getCallSign() == value.name or object:getCallSign() == value.callsign then
                local xoff = value.xoff
                local yoff = value.yoff            
                xset, yset, x1, y1 = calculateSpawnLocations(xoff, yoff)
                object:orderFlyFormation(flagship, xset, yset)
                end
            end
        end
    end
end

function orderFleetIdle()
    for idx, object in ipairs(fleetObjectsIn) do
        object:orderIdle()
    end
end


--Spawn friendly fighters
function spawnFriendlyFighter(ship, minFighter, maxFighter)
    local shipName = ship:getCallSign()
    local tx, ty = ship:getPosition()
    local ox, oy = odysseus:getPosition()

    local spawnHeading = tostring(math.floor(angleHeading(ox, oy, tx, ty)))
    local scanned = ship:isScannedByFaction("EOC_Starfleet")
    local callSigns = {}

    local fc = irandom(minFighter, maxFighter)

    for n=1, fc do
        local r = irandom(0, 360)
        local distance = irandom(200, 1000)
        local x1 = tx + math.cos(r / 180 * math.pi) * distance
        local y1 = ty + math.sin(r / 180 * math.pi) * distance
        local callSign = generateCallSign("UNIDEN", nil)
        local faction = "Unidentified"
        if scanned == true then
            callSign = generateCallSignFromList(nil, shipName)
            faction = "EOC Starfleet"
        end
        table.insert(callSigns, callSign)
        CpuShip():setCallSign(callSign):setFaction(faction):setTemplate("Comet Class Starfighter"):setPosition(x1, y1):setRotation(irandom(0,380)):setAI("fighter"):setScannedByFaction("Unidentified", true):setScannedByFaction("Corporate owned"):setCanBeDestroyed(yes)
      
    end
    if scanned == true then
        odysseus:addToShipLog(string.format(_("shipLog", "%s launched fighers: %s. Heading %i."), shipName, table.concat(callSigns, ", "), spawnHeading), "White")
    else
        odysseus:addToShipLog(string.format(_("shipLog", "Unidentified ship launched fighers. Heading %i"), spawnHeading), "Red")
    end
end

