-- Odysseus fleet orders utils
function showEOC()
    addGMFunction(_("buttonGM", 'Show EOC orders'), function() showEOCOrders() end)
end

function showEOCOrders()
--    removeGMFunction('Show EOC orders')   
    addGMFunction(_("buttonGM", 'Hide EOC orders'), function() hideEOCorders() end)
    addGMFunction(_("buttonGM", 'OC - Civilians'), function() civiliansRetreatOnClick() end)
    addGMFunction(_("buttonGM", 'OC - Military'), function() moveToFightOnClick() end)
    addGMFunction(_("buttonGM", 'OC - Move fleet'), function() moveFleetOnClick() end)
    addGMFunction(_("buttonGM", "Order Formation"), function() fleetFlyFormation() end)
    addGMFunction(_("buttonGM", "Order Idle"), function() orderFleetIdle() end)

    --Muokkaa fighterit OC:ksi
    addGMFunction(
        _("buttonGM", 'OC - Aurora fighters'), 
        function()
            spawnFriendlyFighter(aurora, 4, 8)
        end)

    addGMFunction(
        _("buttonGM", 'OC - Valor fighters'), 
        function()
            spawnFriendlyFighter(valor, 2, 4)
        end)

    addGMFunction(
        _("buttonGM", 'OC - Inferno fighters'), 
        function()
            spawnFriendlyFighter(inferno, 2, 4)
        end)

    addGMFunction(
        _("buttonGM", 'OC - Halo fighters'), 
        function()
            spawnFriendlyFighter(halo, 4, 8)
        end)
end

function hideEOCorders()
    removeGMFunction('OC - Civilians')   
    removeGMFunction('OC - Military')
    removeGMFunction('OC - Move fleet')
    removeGMFunction('Order Idle')
    removeGMFunction('Order Formation')
    removeGMFunction('OC - Aurora fighters')
    removeGMFunction('OC - Valor fighters')
    removeGMFunction('OC - Inferno fighters')
    removeGMFunction('OC - Halo fighters')
    removeGMFunction('Hide EOC orders')   
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

    onGMClick(function(x, y)
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
            fighter = CpuShip():setCallSign(callSign):setFaction(faction):setTemplate("Comet Class Starfighter"):setPosition(x1, y1):setRotation(irandom(0,380)):setAI("fighter"):setScannedByFaction("Unidentified", true):setScannedByFaction("Corporate owned"):setCanBeDestroyed(true):orderDefendLocation(x,y)
            if ship == valor then 
                table.insert(friendlyFightersOut_valor, fighter)
            end
            if ship == aurora then 
                table.insert(friendlyFightersOut_aurora, fighter)
            end
            if ship == halo then 
                table.insert(friendlyFightersOut_halo, fighter)
            end
            if ship == inferno then 
                table.insert(friendlyFightersOut_inferno, fighter)
            end

        end
        if scanned == true then
            odysseus:addToShipLog(string.format(_("shipLog", "%s launched fighers: %s. Heading %i."), shipName, table.concat(callSigns, ", "), spawnHeading), "White")
        else
            odysseus:addToShipLog(string.format(_("shipLog", "Unidentified ship launched fighers. Heading %i"), spawnHeading), "Red")
        end
        onGMClick(nil)
    end)

removeGMFunction("Dock fleet fighters")
addGMFunction("Dock fleet fighters", friendlyFighterDock)


end

function friendlyFighterDock()
    removeGMFunction("Dock fleet fighters")
    for idv, object in ipairs(friendlyFightersOut_valor) do
        object:orderDock(valor)
    end

    for idi, object in ipairs(friendlyFightersOut_inferno) do
        object:orderDock(inferno)
    end
    for ida, object in ipairs(friendlyFightersOut_aurora) do
        object:orderDock(aurora)
    end
    for idh, object in ipairs(friendlyFightersOut_halo) do
        object:orderDock(halo)
    end

end