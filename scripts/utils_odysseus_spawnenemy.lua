-- Name: Odysseus utils
-- Created by Ria B for Odysseus 2024

-- Enemy spawner
function spawnwave(size)
    onGMClick(function(x, y)
        spawn_wave(x, y, size)
        onGMClick(nil)
    end)

end


function spawn_wave(x, y, size)
    local heading = tostring(math.floor(angleHeading(odysseus, x, y)))
    odysseus:addToShipLog(string.format(_("shipLog", "EVA sector scanner alarm. Multiple incoming jumps detected from heading %d."), heading), "Red")

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
    if size == 4 or size == 5 or size == 6 then
        pMin = 10
        pMax = 15
    end

    pc = irandom(pMin, pMax)
    for n=1, pc do
        local r = irandom(0, 360)
        local distance = irandom(1000, 20000)
        x1 = x + math.cos(r / 180 * math.pi) * distance
        y1 = y + math.sin(r / 180 * math.pi) * distance
        CpuShip():setCallSign(generateCallSign("UNREC-", nil)):setFaction("Machines"):setTemplate("Machine Predator"):setPosition(x1, y1):orderRoaming(x, y)
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
    if size == 5 or size == 6 then
        sMin = 10
        sMax = 15
    end

    sc = irandom(sMin, sMax)
    for n=1, sc do

        local r = irandom(0, 360)
        local distance = irandom(3000, 20000)
        x1 = x + math.cos(r / 180 * math.pi) * distance
        y1 = y + math.sin(r / 180 * math.pi) * distance
        CpuShip():setCallSign(generateCallSign("MAC", nil)):setFaction("Machines"):setTemplate("Machine Stinger"):setPosition(x1, y1):orderRoaming(x, y)
    end

    --Spawn Reaper
    if size == 4 or size == 5 or size == 6 then
        if size == 4 then
            rMin = 1
            rMax = 2
        end
        if size == 5 or size == 6 then 
            rMin = 4
            rMax = 8
        end
        --randomize Reaper count
        rc = irandom(rMin, rMax)
        for n=1, rc do
            local r = irandom(0, 360)
            local distance = irandom(3000, 20000)
            x1 = x + math.cos(r / 180 * math.pi) * distance
            y1 = y + math.sin(r / 180 * math.pi) * distance    
            CpuShip():setCallSign(generateCallSign("MAC", nil)):setFaction("Machines"):setTemplate("Machine Reaper"):setPosition(x1, y1):orderRoaming(x, y)
        end
    end

    --Spawn mothership
    if size == 6 then
        CpuShip():setCallSign("Mothership"):setFaction("Machines"):setTemplate("Machine Mothership"):setPosition(x, y):orderRoaming(x, y):setRotation(100):setScanned(true)
    end
end
