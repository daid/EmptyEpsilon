-- Max fighter count for NPC ships. Resets at every jump.

function setSpawnFleetButton(buttonName, fleetSpawn, sx, sy, offSetModifier, spawnModifier, revealCallSigns)
    
	-- A, B cordinates from Odysseus position to spawn Aurora
	-- DistanceMin and distanceMax are values which are ued to calculate distance from Aurora
	-- distanceModifier defines multiplier to fleet ship from each other when flying in form. Default value 2
	-- Spawn modifier defines how much misplaced the ships are when spawn on the map
	-- 1 = just a little bit off and disoriented, 2 = bit more chaotic situation, 3 = way too quick jump, totally lost
	-- If X coordinated of Aurora spawning point is positive, it will take longer for ships to get back to gether
	--setSpawnFleetButton("Button text", "friendlyOne", A, B, distanceModifier, spawnModifier, revealCallSignsAtSpawn)		

    addGMFunction(
        _("Fleet", buttonName), 
        function()
            spawnFleet(buttonName, fleetSpawn, sx, sy, offSetModifier, spawnModifier, revealCallSigns)
        end)
end
    
function spawnFleet(buttonName, fleetSpawn, sx, sy, offSetModifier, spawnModifier, revealCallSigns)
     ox, oy = odysseus:getPosition()

    --set Aurora spawnpoint
     ax = sx + ox
     ay = sy + oy			

    local heading = tostring(math.floor(angleHeading(ox, oy, sx, sy)))
       
    distanceModifier = offSetModifier
    positionModifier = math.floor(spawnModifier*1.5)

    odysseus:addToShipLog(string.format(_("shipLog", "EVA sector scanner alarm. Multiple incoming jumps detected from heading %d."), heading), "Red")

    auroraHeading = math.floor(90-(irandom(-45, 45)))

    if fleet_list == nil then
        setFleetTable()
    end

    for key, value in ipairs(fleet_list) do
        local callsign = value.name
        local faction = "Unidentified"
        local shipTemplate = value.template
        local xoff = value.xoff
        local yoff = value.yoff
        local fleetform = value.fleetForm
        if fleetSpawn  <= fleetform then
            xset, yset, x1, y1 = calculateSpawnLocations(xoff, yoff)
            
            ship = CpuShip():setCallSign(callsign):setFaction(faction):setAI(value.aiset):setTemplate(shipTemplate):setPosition(x1, y1):setRotation(irandom(0,380)):setScannedByFaction("Unidentified", true):setScannedByFaction("Corporate owned"):setCanBeDestroyed(false)
           ship:setRotation(irandom(0,380))
           if value.name == "UNREC-253" then --Polaris
            aurora = ship
            ship:setRotation(auroraHeading):setHeading(auroraHeading):setPosition(ax,ay)
            end
           if value.name == "UNREC-291" then --Polaris
                polaris = ship
            end
            if value.name == "UNREC-387" then -- vulture
                vulture = ship
            end
            if value.name == "UNREC-296" then --prophet
                prophet = ship
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
        end

    end
    setFlagship()

    -- Set up buttons
    showEOC()
    removeGMFunction(buttonName)

    -- If reveal call sign is true, reveal automatically. If not, add button
    if(revealCallSigns == false) then
        addGMFunction(
        _("Fleet", "Reveal fleet callsigns"), 
         function()
            revealFriendlySignsList()
            removeGMFunction("Reveal fleet callsigns")					
        end)
    else 
        revealFriendlySignsList()
    end

    setFlagship()
end

function setFlagship()
    local ax, ay = valor:getPosition()
    flagship = aurora
    
    local objects = getObjectsInRadius(ax, ay, 75000)	--position_[x|y] set by calling script
    for idx, object in ipairs(objects) do
        if object.typeName == "CpuShip" then
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


end

function revealFriendlySignsList()
    local ax, ay = _fourArgumentsIntoCoordinates(aurora, halo)
    
    local objects = getObjectsInRadius(ax, ay, 75000)	--position_[x|y] set by calling script
    for idx, object in ipairs(objects) do
        if object.typeName == "CpuShip" then
            local callsign = object:getCallSign()
            for key, value in ipairs(fleet_list) do    
                if object:getCallSign() == value.name then	
                    object:setCallSign(value.callsign):setFaction(value.faction):setScannedByFaction("EOC Starfleet", true):setScannedByFaction("EOC_Starfleet", true)
                end
            end
        end
    end

end

function calculateSpawnLocations(xloc, yloc)

    local xset = xloc+irandom(-600,600)
    local yset = yloc+irandom(-600,600)

    xset = math.floor(xloc * distanceModifier)
    yset = math.floor(yloc * distanceModifier)
    local r = irandom(0, 360)
    local distance = irandom(2000, 5000)    
    local x1 = math.floor(ax + (math.cos(r / 180 * math.pi) * distance* positionModifier) -5000)
    local y1 = math.floor(ay + (math.sin(r / 180 * math.pi) * distance* positionModifier))

    local x1 = x1 + xset
    local y1 = y1 + yset


    return xset, yset, x1, y1
end

function confirm_polaris()
	removeGMFunction("Destroy ESS polaris")
	addGMFunction("Cancel destruction", cancel_polaris)
	addGMFunction("Confirm destruction", destroy_polaris)

end

function cancel_polaris()
	addGMFunction("Destroy ESS polaris", confirm_polaris)
	removeGMFunction("Cancel destruction")
	removeGMFunction("Confirm destruction")
end


function destroy_polaris()
	removeGMFunction("Cancel destruction")
	removeGMFunction("Confirm destruction")
	polaris:destroy()
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
	valkyrie:takeDamage(999999999)
	odysseus:addToShipLog("EVA long range scanning results. ESS Valkyrie left from scanner range. No jump detected.", "Red")
end

function confirm_prophet()
	removeGMFunction("Destroy ESS Prophet")
	addGMFunction("Cancel destruction", cancel_prophet)
	addGMFunction("Confirm destruction", destroy_prophet)

end

function cancel_prophet()
	addGMFunction("Destroy ESS Valkyrie", confirm_prophet)
	removeGMFunction("Cancel destruction")
	removeGMFunction("Confirm destruction")
end

function destroy_prophete()
	removeGMFunction("Cancel destruction")
	removeGMFunction("Confirm destruction")
	prophet:takeDamage(999999999)
	odysseus:addToShipLog("EVA long range scanning results. Prophet left from scanner range. No jump detected.", "Red")
end

function setFleetTable()

    fleet_list = {}
    table.insert(fleet_list,{name='UNREC-253',military=true,callsign="ESS Aurora",faction="EOC Starfleet",xoff=1,yoff=1,aiset="missilevolley",template="Stellar Class Battlecruiser",fleetForm=5})
    table.insert(fleet_list,{name='UNREC-208',military=true,callsign="ESS Aries",faction="EOC Starfleet",xoff=-10000,yoff=-3000,aiset="missilevolley",template="Aurora Class Explorer",fleetForm=5,})
    table.insert(fleet_list,{name='UNREC-232',military=true,callsign="ESS Arthas",faction="EOC Starfleet",xoff=-10000,yoff=3000,aiset="missilevolley",template="Aurora Class Explorer",fleetForm=5,})
    table.insert(fleet_list,{name='UNREC-237',military=true,callsign="ESS Bluecoat",faction="EOC Starfleet",xoff=-2000,yoff=-1500,aiset="missilevolley",template="Helios Class Corvette",fleetForm=5,})
    table.insert(fleet_list,{name='UNREC-248',military=true,callsign="OSS Burro",faction="EOC Starfleet",xoff=-6000,yoff=-4500,aiset="missilevolley",template="Luna Class Cargo Carrier",fleetForm=5,})
    table.insert(fleet_list,{name='UNREC-249',military=false,callsign="CSS Centurion",faction="Corporate owned",xoff=-6000,yoff=-3000,aiset="evasive",template="Eclipse Class Frigate",fleetForm=5,})
    table.insert(fleet_list,{name='UNREC-257',military=false,callsign="CSS Cyclone",faction="Corporate owned",xoff=-3000,yoff=0,aiset="evasive",template="Eclipse Class Frigate",fleetForm=5,})
    table.insert(fleet_list,{name='UNREC-261',military=false,callsign="ESS Discovery",faction="Government owned",xoff=-9000,yoff=0,aiset="evasive",template="Helios Class Corvette",fleetForm=5,})
    table.insert(fleet_list,{name='UNREC-264',military=true,callsign="ESS Envoy",faction="EOC Starfleet",xoff=-4000,yoff=3000,aiset="missilevolley",template="Helios Class Corvette",fleetForm=5,})
    table.insert(fleet_list,{name='UNREC-275',military=true,callsign="ESS Halo",faction="EOC Starfleet",xoff=-14000,yoff=0,aiset="missilevolley",template="Stellar Class Battlecruiser",fleetForm=5,})
    table.insert(fleet_list,{name='UNREC-278',military=true,callsign="ESS Harbinger",faction="EOC Starfleet",xoff=-12000,yoff=1500,aiset="missilevolley",template="Eclipse Class Frigate",fleetForm=5,})
    table.insert(fleet_list,{name='UNREC-279',military=false,callsign="OSS Immortal",faction="Corporate owned",xoff=-10000,yoff=-1500,aiset="evasive",template="Eclipse Class Frigate",fleetForm=5,})
    table.insert(fleet_list,{name='UNREC-281',military=true,callsign="ESS Inferno",faction="EOC Starfleet",xoff=-8000,yoff=-4500,aiset="missilevolley",template="Eclipse Class Frigate",fleetForm=5,})
    table.insert(fleet_list,{name='UNREC-285',military=false,callsign="OSS Karma",faction="Unregistered",xoff=-7000,yoff=-1500,aiset="evasive",template="Aurora Class Explorer",fleetForm=5,})
    table.insert(fleet_list,{name='UNREC-286',military=false,callsign="OSS Marauder",faction="Corporate owned",xoff=-7000,yoff=1500,aiset="evasive",template="Aurora Class Explorer",fleetForm=5,})
    table.insert(fleet_list,{name='UNREC-289',military=false,callsign="ESS Memory",faction="Government owned",xoff=-5000,yoff=-1500,aiset="evasive",template="Helios Class Corvette",fleetForm=5,})
    table.insert(fleet_list,{name='UNREC-291',military=false,callsign="ESS Polaris",faction="Corporate owned",xoff=-6000,yoff=3000,aiset="evasive",template="Eclipse Class Frigate",fleetForm=2,})
    table.insert(fleet_list,{name='UNREC-294',military=false,callsign="CSS Prophet",faction="Faith of the High Science",xoff=-12000,yoff=0,aiset="evasive",template="Aurora Class Explorer",fleetForm=3,})
    table.insert(fleet_list,{name='UNREC-296',military=false,callsign="OSS Ravager",faction="Corporate owned",xoff=-5000,yoff=1500,aiset="evasive",template="Helios Class Corvette",fleetForm=5,})
   table.insert(fleet_list,{name='UNREC-298',military=false,callsign="ESS Spectrum",faction="Corporate owned",xoff=-6000,yoff=0,aiset="evasive",template="Eclipse Class Frigate",fleetForm=5,})
    table.insert(fleet_list,{name='UNREC-301',military=false,callsign="OSS Starfall",faction="Corporate owned",xoff=-10000,yoff=1500,aiset="evasive",template="Eclipse Class Frigate",fleetForm=5,})
    table.insert(fleet_list,{name='UNREC-307',military=true,callsign="CSS Taurus",faction="EOC Starfleet",xoff=-4000,yoff=-3000,aiset="missilevolley",template="Helios Class Corvette",fleetForm=5,})
    table.insert(fleet_list,{name='UNREC-310',military=true,callsign="ESS Valkyrie",faction="EOC Starfleet",xoff=-2000,yoff=1500,aiset="missilevolley",template="Helios Class Corvette",fleetForm=4,})
    table.insert(fleet_list,{name='UNREC-327',military=true,callsign="ESS Valor",faction="EOC Starfleet",xoff=-8000,yoff=4500,aiset="missilevolley",template="Eclipse Class Frigate",fleetForm=5,})
    table.insert(fleet_list,{name='UNREC-387',military=false,callsign="OSS Vulture",faction="Corporate owned",xoff=-8000,yoff=3000,aiset="evasive",template="Helios Class Corvette",fleetForm=1,})
    table.insert(fleet_list,{name='UNREC-364',military=true,callsign="ESS Warrior",faction="EOC Starfleet",xoff=-12000,yoff=-1500,aiset="missilevolley",template="Eclipse Class Frigate",fleetForm=5,})
   table.insert(fleet_list,{name='UNREC-355',military=false,callsign="CSS Whirlwind",faction="Corporate owned",xoff=-8000,yoff=-3000,aiset="evasive",template="Helios Class Corvette",fleetForm=5,})

end