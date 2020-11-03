-- Name: Clash in Shangri-La (PVP)
-- Description: Since its creation, the Shangri-La station was governed by a multi-ethnic consortium that assured the station's independence across the conflicts that shook the sector.
---             However, the station's tranquility came to an abrupt end when most of the governing consortium's members were assassinated under a Exuari false flag operation.
---             Now the station is in a state of civil war, with infighting breaking out between warring factions. Both the neighboring Human Navy and Kraylor are worried that the breakdown
---             of order in Shangri-La could tilt the balance of power in their opponent's favor, and sent "peacekeepers" to shift the situation to their own advantage.
---             The Human Navy's HNS Gallipoli and Kraylor's Crusader Naa'Tvek face off in an all-out battle for Shangri-La.
-- Type: PvP

--- Scenario
--
-- TODO Consider to add HVLI resupply.
--
-- @script scenario_pvp

--- Initialize scenario.
function init()
    humanTroops = {}
    kraylorTroops = {}

    -- Stations
    shangri_la = SpaceStation():setPosition(10000, 10000):setTemplate("Large Station"):setFaction("Independent"):setRotation(random(0, 360)):setCallSign("Shangri-La"):setCommsFunction(shangrilaComms)

    human_shipyard = SpaceStation():setPosition(-7500, 15000):setTemplate("Small Station"):setFaction("Human Navy"):setRotation(random(0, 360)):setCallSign("Mobile Shipyard"):setCommsFunction(stationComms)
    CpuShip():setTemplate("Phobos T3"):setFaction("Human Navy"):setPosition(-8000, 16500):orderDefendTarget(human_shipyard):setScannedByFaction("Human Navy", true)
    CpuShip():setTemplate("Phobos T3"):setFaction("Human Navy"):setPosition(-6000, 13500):orderDefendTarget(human_shipyard):setScannedByFaction("Human Navy", true)
    CpuShip():setTemplate("Phobos T3"):setFaction("Human Navy"):setPosition(-7000, 14000):orderDefendTarget(human_shipyard):setScannedByFaction("Human Navy", true)
    CpuShip():setTemplate("Nirvana R5"):setFaction("Human Navy"):setPosition(-8000, 14000):orderDefendTarget(human_shipyard):setScannedByFaction("Human Navy", true)

    kraylor_shipyard = SpaceStation():setPosition(27500, 5000):setTemplate("Small Station"):setFaction("Kraylor"):setRotation(random(0, 360)):setCallSign("Forward Command"):setCommsFunction(stationComms)
    CpuShip():setTemplate("Phobos T3"):setFaction("Kraylor"):setPosition(29000, 5000):orderDefendTarget(kraylor_shipyard):setScannedByFaction("Kraylor", true)
    CpuShip():setTemplate("Phobos T3"):setFaction("Kraylor"):setPosition(25000, 5000):orderDefendTarget(kraylor_shipyard):setScannedByFaction("Kraylor", true)
    CpuShip():setTemplate("Phobos T3"):setFaction("Kraylor"):setPosition(27500, 6000):orderDefendTarget(kraylor_shipyard):setScannedByFaction("Kraylor", true)
    CpuShip():setTemplate("Nirvana R5"):setFaction("Kraylor"):setPosition(27000, 5000):orderDefendTarget(kraylor_shipyard):setScannedByFaction("Kraylor", true)

    -- Spawn players
    gallipoli = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis"):setPosition(-8500, 15000):setCallSign("HNS Gallipoli"):setScannedByFaction("Kraylor", false)
    crusader = PlayerSpaceship():setFaction("Kraylor"):setTemplate("Atlantis"):setPosition(26500, 5000):setCallSign("Crusader Naa'Tvek"):setScannedByFaction("Human Navy", false)

    -- Initialize timers
    time = 0
    wave_timer = 0
    troop_timer = 0
    kraylor_respawn = 0
    human_respawn = 0

    human_points = 0
    kraylor_points = 0

    -- Create terrain
    create(Asteroid, 20, 5000, 10000, 10000, 10000)
    create(VisualAsteroid, 10, 5000, 10000, 10000, 10000)
    create(Mine, 10, 5000, 10000, 10000, 10000)

    -- Brief the players
    human_shipyard:sendCommsMessage(gallipoli, [[Captain, it seems that the Kraylor are moving to take the Shangri-La station in sector F5!

Provide a spatial cover for while our troop transports board the station to reclaim it.

Good luck, and stay safe.]])

    kraylor_shipyard:sendCommsMessage(
        crusader,
        [[Greetings, Crusader.

Your mission is to secure the Shangri-La station in sector F5, as the feeble humans think it's theirs for the taking.

Support our glorious soldiers by preventing the heretics from harming our transports, and cleanse all enemy opposition!]]
    )

    -- Spawn the first wave
    human_transport = spawnTransport():setFaction("Human Navy"):setPosition(-7000, 15000):orderDock(shangri_la):setScannedByFaction("Human Navy", true)
    table.insert(humanTroops, human_transport)
    CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setPosition(-7000, 15500):orderDefendTarget(human_transport):setScannedByFaction("Human Navy", true)
    CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setPosition(-7000, 14500):orderDefendTarget(human_transport):setScannedByFaction("Human Navy", true)

    kraylor_transport = spawnTransport():setFaction("Kraylor"):setPosition(26500, 5000):orderDock(shangri_la):setScannedByFaction("Kraylor", true)
    table.insert(kraylorTroops, kraylor_transport)
    CpuShip():setTemplate("MT52 Hornet"):setFaction("Kraylor"):setPosition(26500, 5500):orderDefendTarget(kraylor_transport):setScannedByFaction("Kraylor", true)
    CpuShip():setTemplate("MT52 Hornet"):setFaction("Kraylor"):setPosition(26500, 4500):orderDefendTarget(kraylor_transport):setScannedByFaction("Kraylor", true)
end

--- Comms with independent station _Shangri-La_.
--
-- If players call Shangri-La, provide a status report
function shangrilaComms()
    setCommsMessage("Your faction's militia commander picks up:\nWhat can we do for you, Captain?")
    addCommsReply(
        "Give us a status report.",
        function()
            setCommsMessage("Here's the latest news from the front.\nHuman dominance: " .. human_points .. "\nKraylor dominance: " .. kraylor_points .. "\nTime elapsed: " .. time)
        end
    )
end

--- Comms for station(s).
--
-- If friendly players call a station, provide a status report and offer
-- reinforcements at a reputation cost.
function stationComms()
    if comms_source:isFriendly(comms_target) then
        if not comms_source:isDocked(comms_target) then
            setCommsMessage("A dispatcher responds:\nGreetings, Captain. If you want supplies, please dock with us.")
        else
            setCommsMessage("A dispatcher responds:\nGreetings, Captain. What can we do for you?")
        end

        addCommsReply(
            "I need a status report.",
            function()
                setCommsMessage("Here's the latest news from the front.\nHuman dominance: " .. human_points .. "\nKraylor dominance: " .. kraylor_points .. "\nTime elapsed: " .. time)
            end
        )

        addCommsReply(
            "Send in more troops. (100 reputation)",
            function()
                if not comms_source:takeReputationPoints(100) then
                    setCommsMessage("Not enough reputation.")
                    return
                end
                setCommsMessage("Aye, captain. We've deployed a squad with fighter escort to support the assault on Shangri-La.")
                if comms_target:getFaction() == "Kraylor" then
                    kraylor_transport = spawnTransport():setFaction("Kraylor"):setPosition(comms_target:getPosition()):orderDock(shangri_la):setScannedByFaction("Kraylor", true)
                    table.insert(kraylorTroops, kraylor_transport)
                    CpuShip():setTemplate("MT52 Hornet"):setFaction(comms_target:getFaction()):setPosition(comms_target:getPosition()):orderDefendTarget(kraylor_transport):setScannedByFaction(comms_source:getFaction(), true)
                else
                    human_transport = spawnTransport():setFaction("Human Navy"):setPosition(comms_target:getPosition()):orderDock(shangri_la):setScannedByFaction("Human Navy", true)
                    table.insert(humanTroops, human_transport)
                    CpuShip():setTemplate("MT52 Hornet"):setFaction(comms_target:getFaction()):setPosition(comms_target:getPosition()):orderDefendTarget(human_transport):setScannedByFaction(comms_source:getFaction(), true)
                end
                for n = 0, 1 do
                end
            end
        )

        addCommsReply(
            "We need some space-based firepower. (150 reputation)",
            function()
                if not comms_source:takeReputationPoints(150) then
                    setCommsMessage("Not enough reputation.")
                    return
                end
                setCommsMessage("Confirmed. We've dispatched a strike wing to support space superiority around Shangri-La.")
                strike_leader = CpuShip():setTemplate("Phobos T3"):setFaction(comms_target:getFaction()):setPosition(comms_target:getPosition()):orderDefendTarget(shangri_la):setScannedByFaction(comms_source:getFaction(), true)
                CpuShip():setTemplate("MU52 Hornet"):setFaction(comms_target:getFaction()):setPosition(comms_target:getPosition()):orderFlyFormation(strike_leader, -1000, 0):setScannedByFaction(comms_source:getFaction(), true)
                CpuShip():setTemplate("MU52 Hornet"):setFaction(comms_target:getFaction()):setPosition(comms_target:getPosition()):orderFlyFormation(strike_leader, 1000, 0):setScannedByFaction(comms_source:getFaction(), true)
            end
        )

        if comms_source:isDocked(comms_target) then
            addCommsReply("We need supplies.", supplyDialogue)
        end
    else
        setCommsMessage("We'll bring your destruction!")
    end
end

--- Comms supplyDialogue.
function supplyDialogue()
    setCommsMessage("What supplies do you need?")

    addCommsReply(
        "Do you have spare homing missiles for us? (2rep each)",
        function()
            if not comms_source:isDocked(comms_target) then
                setCommsMessage("You need to stay docked for that action.")
                return
            end
            if not comms_source:takeReputationPoints(2 * (comms_source:getWeaponStorageMax("Homing") - comms_source:getWeaponStorage("Homing"))) then
                setCommsMessage("Not enough reputation.")
                return
            end
            if comms_source:getWeaponStorage("Homing") >= comms_source:getWeaponStorageMax("Homing") then
                setCommsMessage("Sorry, captain, but you are fully stocked with homing missiles.")
                addCommsReply("Back", supplyDialogue)
            else
                comms_source:setWeaponStorage("Homing", comms_source:getWeaponStorageMax("Homing"))
                setCommsMessage("We've replenished up your homing missile supply.")
                addCommsReply("Back", supplyDialogue)
            end
        end
    )

    addCommsReply(
        "Please re-stock our mines. (2rep each)",
        function()
            if not comms_source:isDocked(comms_target) then
                setCommsMessage("You need to stay docked for that action.")
                return
            end
            if not comms_source:takeReputationPoints(2 * (comms_source:getWeaponStorageMax("Mine") - comms_source:getWeaponStorage("Mine"))) then
                setCommsMessage("Not enough reputation.")
                return
            end
            if comms_source:getWeaponStorage("Mine") >= comms_source:getWeaponStorageMax("Mine") then
                setCommsMessage("Captain, you already have all the mines you can fit in that ship.")
                addCommsReply("Back", supplyDialogue)
            else
                comms_source:setWeaponStorage("Mine", comms_source:getWeaponStorageMax("Mine"))
                setCommsMessage("These mines are yours.")
                addCommsReply("Back", supplyDialogue)
            end
        end
    )

    addCommsReply(
        "Can you supply us with some nukes? (15rep each)",
        function()
            if not comms_source:isDocked(comms_target) then
                setCommsMessage("You need to stay docked for that action.")
                return
            end
            if not comms_source:takeReputationPoints(15 * (comms_source:getWeaponStorageMax("Nuke") - comms_source:getWeaponStorage("Nuke"))) then
                setCommsMessage("Not enough reputation.")
                return
            end
            if comms_source:getWeaponStorage("Nuke") >= comms_source:getWeaponStorageMax("Nuke") then
                setCommsMessage("Your nukes are already charged and primed for destruction.")
                addCommsReply("Back", supplyDialogue)
            else
                comms_source:setWeaponStorage("Nuke", comms_source:getWeaponStorageMax("Nuke"))
                setCommsMessage("You are fully loaded and ready to explode things.")
                addCommsReply("Back", supplyDialogue)
            end
        end
    )

    addCommsReply(
        "Please re-stock our EMP missiles. (10rep each)",
        function()
            if not comms_source:isDocked(comms_target) then
                setCommsMessage("You need to stay docked for that action.")
                return
            end
            if not comms_source:takeReputationPoints(10 * (comms_source:getWeaponStorageMax("EMP") - comms_source:getWeaponStorage("EMP"))) then
                setCommsMessage("Not enough reputation.")
                return
            end
            if comms_source:getWeaponStorage("EMP") >= comms_source:getWeaponStorageMax("EMP") then
                setCommsMessage("All storage for EMP missiles is already full, captain.")
                addCommsReply("Back", supplyDialogue)
            else
                comms_source:setWeaponStorage("EMP", comms_source:getWeaponStorageMax("EMP"))
                setCommsMessage("We've recalibrated the electronics and fitted you with all the EMP missiles you can carry.")
                addCommsReply("Back", supplyDialogue)
            end
        end
    )

    addCommsReply("Back to main menu", stationComms)
end

--- Update.
function update(delta)
    -- Increment timers
    time = time + delta
    wave_timer = wave_timer + delta
    troop_timer = troop_timer + delta

    -- If the Gallipoli is destroyed ...
    if (not gallipoli:isValid()) then
        -- ... and 20 seconds have passed, spawn the Heinlein.
        if human_respawn > 20 then
            -- Otherwise, increment the respawn timer.
            gallipoli = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis"):setPosition(-8500, 15000):setCallSign("HNS Heinlein"):setScannedByFaction("Kraylor", false)
        else
            human_respawn = human_respawn + delta
        end
    end

    -- Ditto for the Crusader.
    if (not crusader:isValid()) then
        if kraylor_respawn > 20 then
            crusader = PlayerSpaceship():setFaction("Kraylor"):setTemplate("Atlantis"):setPosition(19000, -14500):setCallSign("Crusader Elak'raan"):setScannedByFaction("Human Navy", false)
        else
            kraylor_respawn = kraylor_respawn + delta
        end
    end

    -- Increment reputation for both sides.
    gallipoli:addReputationPoints(delta * 0.3)
    crusader:addReputationPoints(delta * 0.3)

    -- If a faction has no station or flagship, it loses.
    -- If a faction scores 50 points, it wins.
    if ((not gallipoli:isValid()) and (not human_shipyard:isValid())) or kraylor_points > 50 then
        victory("Kraylor")
    end

    if ((not crusader:isValid()) and (not kraylor_shipyard:isValid())) or human_points > 50 then
        victory("Human Navy")
    end

    -- If either flagship is destroyed, its opponent gains a reputation bonus, and
    -- its opponent's faction gains victory points.
    if (not gallipoli:isValid()) then
        kraylor_shipyard:sendCommsMessage(crusader, [[Well done, Crusader!

The pathetic Human flagship has been disabled. Go for the victory!]])
        crusader:addReputationPoints(50)
        kraylor_points = kraylor_points + 5
        human_respawn = 0
    end

    if (not crusader:isValid()) then
        human_shipyard:sendCommsMessage(gallipoli, [[Good job, Captain!

With the Kraylor flagship out of the way, we can land the final blow!]])
        gallipoli:addReputationPoints(50)
        human_points = human_points + 5
        krayor_respawn = 0
    end

    -- Every 150 seconds, spawn a troop transport and 2 fighters as escorts for
    -- each faction.
    if wave_timer > 150 and (human_shipyard:isValid()) then
        line = random(0, 20) * 500
        human_transport = spawnTransport():setFaction("Human Navy"):setPosition(-7000, 5000 + line):orderDock(shangri_la):setScannedByFaction("Human Navy", true)
        table.insert(humanTroops, human_transport)
        CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setPosition(-7000, 5500 + line):orderDefendTarget(human_transport):setScannedByFaction("Human Navy", true)
        CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setPosition(-7000, 4500 + line):orderDefendTarget(human_transport):setScannedByFaction("Human Navy", true)

        line = random(0, 20) * 500
        kraylor_transport = spawnTransport():setFaction("Kraylor"):setPosition(27000, -5000 + line):orderDock(shangri_la):setScannedByFaction("Kraylor", true)
        table.insert(kraylorTroops, kraylor_transport)
        CpuShip():setTemplate("MT52 Hornet"):setFaction("Kraylor"):setPosition(27000, -5500 + line):orderDefendTarget(kraylor_transport):setScannedByFaction("Kraylor", true)
        CpuShip():setTemplate("MT52 Hornet"):setFaction("Kraylor"):setPosition(27000, -4500 + line):orderDefendTarget(kraylor_transport):setScannedByFaction("Kraylor", true)

        wave_timer = 0
    end

    -- Count transports. Every 10 seconds, awward 1 point per transport docked
    -- with Shangri-La.
    if troop_timer > 10 then
        for _, transport in ipairs(kraylorTroops) do
            if transport:isValid() and transport:isDocked(shangri_la) then
                kraylor_points = kraylor_points + 1
            end
        end

        for _, transport in ipairs(humanTroops) do
            if transport:isValid() and transport:isDocked(shangri_la) then
                human_points = human_points + 1
            end
        end

        troop_timer = 0
    end

    -- If Shangri-La is destroyed, nobody wins.
    if (not shangri_la:isValid()) then
        victory("Independents")
    end
end

--- Spawn a troop transport.
function spawnTransport()
    ship = CpuShip():setTemplate("Personnel Freighter 2")
    ship:setHullMax(100):setHull(100)
    ship:setShieldsMax(50, 50):setShields(50, 50)
    ship:setImpulseMaxSpeed(100):setRotationMaxSpeed(10)
    return ship
end

--- Create amount of object_type, at a distance between dist_min and dist_max
-- around the point (x0, y0)
function create(object_type, amount, dist_min, dist_max, x0, y0)
    for n = 1, amount do
        local r = random(0, 360)
        local distance = random(dist_min, dist_max)
        x = x0 + math.cos(r / 180 * math.pi) * distance
        y = y0 + math.sin(r / 180 * math.pi) * distance
        object_type():setPosition(x, y)
    end
end
