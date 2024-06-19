-- Name: Odysseus utils
-- Created by Ria B for Odysseus 2024

-- Enemy spawner
function spawnwave(size, orders, tx, ty)
    onGMClick(function(x, y)
        onGMClick(nil)
        spawn_wave(x, y, size, orders, tx, ty)
    end)

end


function spawn_wave(x, y, size, orders, tx, ty)
    local heading = tostring(math.floor(angleHeading(odysseus, x, y)))
    odysseus:addToShipLog(string.format(_("shipLog", "EVA sector scanner alarm. Multiple incoming jumps detected from heading %d. Unidentified vessels."), heading), "Red")

    distanceMin = 1000;
    distanceMax = 10000;
    if size == 1 then
        distanceMax = 10000;
    end
    if size == 2 then
        distanceMax = 20000;
    end
    if size == 3 then
        distanceMax = 20000;
    end
    if size == 4 then
        distanceMax = 30000;
    end
    if size == 5 then
        distanceMax = 40000;
    end


    
    --Spawn predator
    if size == 1 then
        pMin = 2
        pMax = 4
    end
    if size == 2 then
        pMin = 4
        pMax = 8
    end
    if size == 3 then
        pMin = 9
        pMax = 11
    end
    if size == 4 or size == 5 then
        pMin = 10
        pMax = 15
    end
    if size == 6 then
        pMin = 20
        pMax = 30
        distanceMin = 20000;
        distanceMax = 30000;
    end

    pc = irandom(pMin, pMax)
    for n=1, pc do
        local r = irandom(0, 360)
        local distance = random(distanceMin, distanceMax)
        x1 = x + math.cos(r / 180 * math.pi) * distance
        y1 = y + math.sin(r / 180 * math.pi) * distance
        local machine = CpuShip():setCallSign(generateCallSign("UNREC-", nil)):setFaction("Machines"):setTemplate("Machine Predator"):setPosition(x1, y1)
        if orders == "target" then
            machine:orderFlyTowardsBlind(tx,ty)
        else 
            if orders == "idle" then
                machine:orderIdle()
            else 
                machine:orderRoaming(x, y)
            end
        end
    end

    --Spawn Stinger
    --Very small 
    if size == 1 then
        sMin = 0
        sMax = 1
    end
    -- Small
    if size == 2 then
        sMin = 1
        sMax = 2
    end
    -- Medium
    if size == 3 then
        sMin = 2
        sMax = 4
    end
    -- Large
    if size == 4 then
        sMin = 4
        sMax = 6
    end
    -- Massive or End
    if size == 5 then
        sMin = 10
        sMax = 15
    end
    if size == 6 then
        sMin = 30
        sMax = 40
        distanceMin = 10000;
        distanceMax = 20000;
    end

    sc = irandom(sMin, sMax)
    for n=1, sc do
        local r = irandom(0, 360)
        local distance = irandom(distanceMin, distanceMax)
        x1 = x + math.cos(r / 180 * math.pi) * distance
        y1 = y + math.sin(r / 180 * math.pi) * distance
        test = math.cos(r / 180 * math.pi) * distance

        local machine = CpuShip():setCallSign(generateCallSign("UNREC-", nil)):setFaction("Machines"):setTemplate("Machine Stinger"):setPosition(x1, y1)
        if orders == "target" then
            machine:orderFlyTowardsBlind(tx,ty)
        else 
            if orders == "idle" then
                machine:orderIdle()
            else 
                machine:orderRoaming(x, y)
            end
        end


    end

    --Spawn Reaper
    if size == 4 or size == 5 or size == 6 then
        if size == 4 then
            rMin = 1
            rMax = 2
            distanceMax = 10000;
        end
        if size == 5  then 
            rMin = 4
            rMax = 8
            distanceMax = 10000;
        end
        if size == 6 then
            rMin = 10
            rMax = 20
            distanceMin = 5000;
            distanceMax = 10000;
        end
        --randomize Reaper count
        rc = irandom(rMin, rMax)
        for n=1, rc do
            local r = irandom(0, 360)
            local distance = random(distanceMin, distanceMax)
            x1 = x + math.cos(r / 180 * math.pi) * distance
            y1 = y + math.sin(r / 180 * math.pi) * distance    
            local machine = CpuShip():setCallSign(generateCallSign("UNREC-", nil)):setFaction("Machines"):setTemplate("Machine Reaper"):setPosition(x1, y1)
            if orders == "target" then
                machine:orderFlyTowardsBlind(tx,ty)
            else 
                if orders == "idle" then
                    machine:orderIdle()
                else 
                    machine:orderRoaming(x, y)
                end
            end
    
    
    
        end
    end

    --Spawn mothership
    if size == 6 then
        mother = CpuShip():setCallSign(generateCallSign("UNREC-", nil)):setFaction("Machines"):setRotation(100):setTemplate("Machine Mothership"):setPosition(x, y):setScanned(true)

    end
end
