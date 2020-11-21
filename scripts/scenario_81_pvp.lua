-- Name: Clash in Shangri-La (PVP)
-- Description: Since its creation, the Shangri-La station was governed by a multi-ethnic consortium that assured the station's independence across the conflicts that shook the sector.
---             However, the station's tranquility came to an abrupt end when most of the governing consortium's members were assassinated under a Exuari false flag operation.
---             Now the station is in a state of civil war, with infighting breaking out between warring factions.
---             Both the neighboring Human Navy and Kraylor are worried that the breakdown of order in Shangri-La could tilt the balance of power in their opponent's favor, and sent "peacekeepers" to shift the situation to their own advantage.
---             The Human Navy's HNS Gallipoli and Kraylor's Crusader Naa'Tvek face off in an all-out battle for Shangri-La.
-- Type: PvP

--- Scenario
--
-- @script scenario_pvp

-- global variables in this scenario

-- independent station
local shangri_la

-- for Human Navy and Kraylor
local gallipoli
local crusader

local shipyard_human
local shipyard_kraylor

local troops_human
local troops_kraylor

local respawn_human
local respawn_kraylor

local points_human
local points_kraylor

-- time
local time
local wave_timer
local troop_timer

--- Initialize scenario.
function init()
    troops_human = {}
    troops_kraylor = {}

    -- Stations
    shangri_la = SpaceStation():setPosition(10000, 10000):setTemplate("Large Station"):setFaction("Independent"):setRotation(random(0, 360)):setCallSign("Shangri-La"):setCommsFunction(shangrilaComms)

    do
        local faction = "Human Navy"
        shipyard_human = SpaceStation():setPosition(-7500, 15000):setTemplate("Small Station"):setFaction(faction):setRotation(random(0, 360)):setCallSign("Mobile Shipyard"):setCommsFunction(stationComms)
        CpuShip():setTemplate("Phobos T3"):setFaction(faction):setPosition(-8000, 16500):orderDefendTarget(shipyard_human):setScannedByFaction(faction, true)
        CpuShip():setTemplate("Phobos T3"):setFaction(faction):setPosition(-6000, 13500):orderDefendTarget(shipyard_human):setScannedByFaction(faction, true)
        CpuShip():setTemplate("Phobos T3"):setFaction(faction):setPosition(-7000, 14000):orderDefendTarget(shipyard_human):setScannedByFaction(faction, true)
        CpuShip():setTemplate("Nirvana R5"):setFaction(faction):setPosition(-8000, 14000):orderDefendTarget(shipyard_human):setScannedByFaction(faction, true)
    end

    do
        local faction = "Kraylor"
        shipyard_kraylor = SpaceStation():setPosition(27500, 5000):setTemplate("Small Station"):setFaction(faction):setRotation(random(0, 360)):setCallSign("Forward Command"):setCommsFunction(stationComms)
        CpuShip():setTemplate("Phobos T3"):setFaction(faction):setPosition(29000, 5000):orderDefendTarget(shipyard_kraylor):setScannedByFaction(faction, true)
        CpuShip():setTemplate("Phobos T3"):setFaction(faction):setPosition(25000, 5000):orderDefendTarget(shipyard_kraylor):setScannedByFaction(faction, true)
        CpuShip():setTemplate("Phobos T3"):setFaction(faction):setPosition(27500, 6000):orderDefendTarget(shipyard_kraylor):setScannedByFaction(faction, true)
        CpuShip():setTemplate("Nirvana R5"):setFaction(faction):setPosition(27000, 5000):orderDefendTarget(shipyard_kraylor):setScannedByFaction(faction, true)
    end

    -- Spawn players
    gallipoli = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis"):setPosition(-8500, 15000):setCallSign("HNS Gallipoli"):setScannedByFaction("Kraylor", false)
    crusader = PlayerSpaceship():setFaction("Kraylor"):setTemplate("Atlantis"):setPosition(26500, 5000):setCallSign("Crusader Naa'Tvek"):setScannedByFaction("Human Navy", false)

    -- Initialize timers
    time = 0
    wave_timer = 0
    troop_timer = 0
    respawn_human = 0
    respawn_kraylor = 0

    points_human = 0
    points_kraylor = 0

    -- Create terrain
    create(Asteroid, 20, 5000, 10000, 10000, 10000)
    create(VisualAsteroid, 10, 5000, 10000, 10000, 10000)
    create(Mine, 10, 5000, 10000, 10000, 10000)

    -- Brief the players
    shipyard_human:sendCommsMessage(gallipoli, [[Captain, it seems that the Kraylor are moving to take the Shangri-La station in sector F5!

Provide a spatial cover for while our troop transports board the station to reclaim it.

Good luck, and stay safe.]])

    shipyard_kraylor:sendCommsMessage(
        crusader,
        [[Greetings, Crusader.

Your mission is to secure the Shangri-La station in sector F5, as the feeble humans think it's theirs for the taking.

Support our glorious soldiers by preventing the heretics from harming our transports, and cleanse all enemy opposition!]]
    )

    -- Spawn the first wave
    do
        local faction = "Human Navy"
        local transport = spawnTransport():setFaction(faction):setPosition(-7000, 15000):orderDock(shangri_la):setScannedByFaction(faction, true)
        table.insert(troops_human, transport)
        CpuShip():setTemplate("MT52 Hornet"):setFaction(faction):setPosition(-7000, 15500):orderDefendTarget(transport):setScannedByFaction(faction, true)
        CpuShip():setTemplate("MT52 Hornet"):setFaction(faction):setPosition(-7000, 14500):orderDefendTarget(transport):setScannedByFaction(faction, true)
    end

    do
        local faction = "Kraylor"
        local transport = spawnTransport():setFaction(faction):setPosition(26500, 5000):orderDock(shangri_la):setScannedByFaction(faction, true)
        table.insert(troops_kraylor, transport)
        CpuShip():setTemplate("MT52 Hornet"):setFaction(faction):setPosition(26500, 5500):orderDefendTarget(transport):setScannedByFaction(faction, true)
        CpuShip():setTemplate("MT52 Hornet"):setFaction(faction):setPosition(26500, 4500):orderDefendTarget(transport):setScannedByFaction(faction, true)
    end
end

--- Compile and return status report.
--
-- @treturn string the status report
function getStatusReport()
    return table.concat(
        {
            "Here's the latest news from the front.",
            string.format("Human dominance: %d", points_human),
            string.format("Kraylor dominance: %d", points_kraylor),
            string.format("Time elapsed: %.0f", time)
        },
        "\n"
    )
end

--- Comms with independent station _Shangri-La_.
--
-- If players call Shangri-La, provide a status report
function shangrilaComms()
    setCommsMessage("Your faction's militia commander picks up:\nWhat can we do for you, Captain?")
    addCommsReply(
        "Give us a status report.",
        function()
            setCommsMessage(getStatusReport())
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
                setCommsMessage(getStatusReport())
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
                if comms_target:getFaction() == "Human Navy" then
                    local transport = spawnTransport():setFaction("Human Navy"):setPosition(comms_target:getPosition()):orderDock(shangri_la):setScannedByFaction("Human Navy", true)
                    table.insert(troops_human, transport)
                    CpuShip():setTemplate("MT52 Hornet"):setFaction(comms_target:getFaction()):setPosition(comms_target:getPosition()):orderDefendTarget(transport):setScannedByFaction(comms_source:getFaction(), true)
                elseif comms_target:getFaction() == "Kraylor" then
                    local transport = spawnTransport():setFaction("Kraylor"):setPosition(comms_target:getPosition()):orderDock(shangri_la):setScannedByFaction("Kraylor", true)
                    table.insert(troops_kraylor, transport)
                    CpuShip():setTemplate("MT52 Hornet"):setFaction(comms_target:getFaction()):setPosition(comms_target:getPosition()):orderDefendTarget(transport):setScannedByFaction(comms_source:getFaction(), true)
                else
                    -- Can usually not happen. Do nothing.
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
                local strike_leader = CpuShip():setTemplate("Phobos T3"):setFaction(comms_target:getFaction()):setPosition(comms_target:getPosition()):orderDefendTarget(shangri_la):setScannedByFaction(comms_source:getFaction(), true)
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

--- Add reply.
function addCommsReplySupply(args)
    local price = args.price
    local missile_type = args.missile_type
    addCommsReply(
        string.format(args.request .. " (%d rep each)", price),
        function()
            if not comms_source:isDocked(comms_target) then
                setCommsMessage("You need to stay docked for that action.")
                return
            end
            if not comms_source:takeReputationPoints(price * (comms_source:getWeaponStorageMax(missile_type) - comms_source:getWeaponStorage(missile_type))) then
                setCommsMessage("Not enough reputation.")
                return
            end
            if comms_source:getWeaponStorage(missile_type) >= comms_source:getWeaponStorageMax(missile_type) then
                setCommsMessage(args.reply_full)
                addCommsReply("Back", supplyDialogue)
            else
                comms_source:setWeaponStorage(missile_type, comms_source:getWeaponStorageMax(missile_type))
                setCommsMessage(args.reply_filled)
                addCommsReply("Back", supplyDialogue)
            end
        end
    )
end

--- Comms supplyDialogue.
function supplyDialogue()
    setCommsMessage("What supplies do you need?")

    addCommsReplySupply {
        missile_type = "Homing",
        price = 2,
        request = "Do you have spare homing missiles for us?",
        reply_full = "Sorry, captain, but you are fully stocked with homing missiles.",
        reply_filled = "We've replenished up your homing missile supply."
    }

    addCommsReplySupply {
        missile_type = "Mine",
        price = 2,
        request = "Please re-stock our mines.",
        reply_full = "Captain, you already have all the mines you can fit in that ship.",
        reply_filled = "These mines are yours."
    }

    addCommsReplySupply {
        missile_type = "Nuke",
        price = 15,
        request = "Can you supply us with some nukes?",
        reply_full = "Your nukes are already charged and primed for destruction.",
        reply_filled = "You are fully loaded and ready to explode things."
    }

    addCommsReplySupply {
        missile_type = "EMP",
        price = 10,
        request = "Please re-stock our EMP missiles.",
        reply_full = "All storage for EMP missiles is already full, captain.",
        reply_filled = "We've recalibrated the electronics and fitted you with all the EMP missiles you can carry."
    }

    addCommsReplySupply {
        missile_type = "HVLI",
        price = 2,
        request = "Can you restock us with HVLI?",
        reply_full = "Sorry, captain, but you are fully stocked with HVLIs.",
        reply_filled = "We've replenished up your HVLI supply."
    }

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
        if respawn_human > 20 then
            -- ... and 20 seconds have passed, spawn the Heinlein.
            gallipoli = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis"):setPosition(-8500, 15000):setCallSign("HNS Heinlein"):setScannedByFaction("Kraylor", false)
        else
            -- Otherwise, increment the respawn timer.
            respawn_human = respawn_human + delta
        end
    end

    -- Ditto for the Crusader.
    if (not crusader:isValid()) then
        if respawn_kraylor > 20 then
            crusader = PlayerSpaceship():setFaction("Kraylor"):setTemplate("Atlantis"):setPosition(19000, -14500):setCallSign("Crusader Elak'raan"):setScannedByFaction("Human Navy", false)
        else
            respawn_kraylor = respawn_kraylor + delta
        end
    end

    -- Increment reputation for both sides.
    gallipoli:addReputationPoints(delta * 0.3)
    crusader:addReputationPoints(delta * 0.3)

    -- If a faction has no station or flagship, it loses.
    -- If a faction scores 50 points, it wins.
    if ((not gallipoli:isValid()) and (not shipyard_human:isValid())) or points_kraylor > 50 then
        victory("Kraylor")
    end

    if ((not crusader:isValid()) and (not shipyard_kraylor:isValid())) or points_human > 50 then
        victory("Human Navy")
    end

    -- If either flagship is destroyed, its opponent gains a reputation bonus, and
    -- its opponent's faction gains victory points.
    if (not gallipoli:isValid()) then
        shipyard_kraylor:sendCommsMessage(crusader, [[Well done, Crusader!

The pathetic Human flagship has been disabled. Go for the victory!]])
        crusader:addReputationPoints(50)
        points_kraylor = points_kraylor + 5
        respawn_human = 0
    end

    if (not crusader:isValid()) then
        shipyard_human:sendCommsMessage(gallipoli, [[Good job, Captain!

With the Kraylor flagship out of the way, we can land the final blow!]])
        gallipoli:addReputationPoints(50)
        points_human = points_human + 5
        respawn_kraylor = 0
    end

    -- Every 150 seconds, spawn a troop transport and 2 fighters as escorts for
    -- each faction.
    if wave_timer > 150 and (shipyard_human:isValid()) then
        do
            local faction = "Human Navy"
            local line = random(0, 20) * 500
            local transport = spawnTransport():setFaction(faction):setPosition(-7000, 5000 + line):orderDock(shangri_la):setScannedByFaction(faction, true)
            table.insert(troops_human, transport)
            CpuShip():setTemplate("MT52 Hornet"):setFaction(faction):setPosition(-7000, 5500 + line):orderDefendTarget(transport):setScannedByFaction(faction, true)
            CpuShip():setTemplate("MT52 Hornet"):setFaction(faction):setPosition(-7000, 4500 + line):orderDefendTarget(transport):setScannedByFaction(faction, true)
        end

        do
            local faction = "Kraylor"
            local line = random(0, 20) * 500
            local transport = spawnTransport():setFaction(faction):setPosition(27000, -5000 + line):orderDock(shangri_la):setScannedByFaction(faction, true)
            table.insert(troops_kraylor, transport)
            CpuShip():setTemplate("MT52 Hornet"):setFaction(faction):setPosition(27000, -5500 + line):orderDefendTarget(transport):setScannedByFaction(faction, true)
            CpuShip():setTemplate("MT52 Hornet"):setFaction(faction):setPosition(27000, -4500 + line):orderDefendTarget(transport):setScannedByFaction(faction, true)
        end

        wave_timer = 0
    end

    -- Count transports. Every 10 seconds, award 1 point per transport docked
    -- with Shangri-La.
    if troop_timer > 10 then
        for _, transport in ipairs(troops_kraylor) do
            if transport:isValid() and transport:isDocked(shangri_la) then
                points_kraylor = points_kraylor + 1
            end
        end

        for _, transport in ipairs(troops_human) do
            if transport:isValid() and transport:isDocked(shangri_la) then
                points_human = points_human + 1
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
--
-- @treturn CpuShip
function spawnTransport()
    local ship = CpuShip():setTemplate("Personnel Freighter 2")
    ship:setHullMax(100):setHull(100)
    ship:setShieldsMax(50, 50):setShields(50, 50)
    ship:setImpulseMaxSpeed(100):setRotationMaxSpeed(10)
    return ship
end

--- Create `amount` of `object_type`, at a distance between `dist_min` and `dist_max`
-- around the center `(cx, cy)`.
function create(object_type, amount, dist_min, dist_max, cx, cy)
    for _ = 1, amount do
        local phi = random(0, 2 * math.pi)
        local distance = random(dist_min, dist_max)
        local x = cx + math.cos(phi) * distance
        local y = cy + math.sin(phi) * distance
        object_type():setPosition(x, y)
    end
end
