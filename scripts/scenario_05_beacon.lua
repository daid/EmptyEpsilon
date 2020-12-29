-- Name: Beacon of light series
-- Description: The beacon of light scenario, build from the series at EmptyEpsilon.org.
--- Near the far outpost of Orion-5, Kraylor attacks are increasing. A diplomat went missing, and your mission will start with recovering him.
---
--- This scenario is played with exactly one player ship: the Atlantis Epsilon.
-- Type: Mission

--- Scenario
-- @script scenario_05_beacon

--- Init is run when the scenario is started. Create your initial world.
function init()
    -- Create the main ship for the players.
    player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis")
    player:setPosition(22400, 18200):setCallSign("Epsilon")
    allowNewPlayerShips(false)

    research_station = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy")
    research_station:setPosition(23500, 16100):setCallSign("Research-1")
    main_station = SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy")
    main_station:setPosition(-25200, 32200):setCallSign("Orion-5")
    enemy_station = SpaceStation():setTemplate("Large Station"):setFaction("Exuari")
    enemy_station:setPosition(-45600, -15800):setCallSign("Omega")
    neutral_station = SpaceStation():setTemplate("Small Station"):setFaction("Independent")
    neutral_station:setPosition(9100, -35400):setCallSign("Refugee-X")

    -- Nebula that hide the enemy station.
    Nebula():setPosition(-43300, 2200)
    Nebula():setPosition(-34000, -700)
    Nebula():setPosition(-32000, -10000)
    Nebula():setPosition(-24000, -14300)
    Nebula():setPosition(-28600, -21900)

    -- Random nebulae in the system
    Nebula():setPosition(-8000, -38300)
    Nebula():setPosition(24000, -30700)
    Nebula():setPosition(42300, 3100)
    Nebula():setPosition(49200, 10700)
    Nebula():setPosition(3750, 31250)
    Nebula():setPosition(-39500, 18700)

    -- Create 50 Asteroids
    placeRandom(Asteroid, 50, -7500, -10000, -12500, 30000, 2000)
    placeRandom(VisualAsteroid, 50, -7500, -10000, -12500, 30000, 2000)

    -- Create the defense for the station
    CpuShip():setTemplate("Starhammer II"):setFaction("Exuari"):setPosition(-44000, -14000):orderDefendTarget(enemy_station)
    CpuShip():setTemplate("Phobos T3"):setFaction("Exuari"):setPosition(-47000, -14000):orderDefendTarget(enemy_station)
    enemy_dreadnought = CpuShip():setTemplate("Atlantis X23"):setFaction("Exuari")
    enemy_dreadnought:setPosition(-46000, -18000):orderDefendTarget(enemy_station)
    CpuShip():setTemplate("MT52 Hornet"):setFaction("Exuari"):setPosition(-46000, -18100):orderDefendTarget(enemy_dreadnought)
    CpuShip():setTemplate("MT52 Hornet"):setFaction("Exuari"):setPosition(-46000, -18200):orderDefendTarget(enemy_dreadnought)
    CpuShip():setTemplate("MT52 Hornet"):setFaction("Exuari"):setPosition(-46000, -18300):orderDefendTarget(enemy_dreadnought)

    transport_RT4 = CpuShip():setTemplate("Flavia"):setFaction("Human Navy"):setPosition(3750, 31250)
    transport_RT4:orderIdle():setCallSign("RT-4"):setCommsScript("")
    transport_RT4:setHull(1):setShieldsMax(1, 1)

    -- Small Exuari strike team, guarding RT-4 in the nebula at G5.
    exuari_RT4_guard1 = CpuShip():setTemplate("Adder MK5"):setFaction("Exuari"):setPosition(3550, 31250):setRotation(0)
    exuari_RT4_guard2 = CpuShip():setTemplate("Adder MK5"):setFaction("Exuari"):setPosition(3950, 31250):setRotation(180)
    exuari_RT4_guard1:orderIdle()
    exuari_RT4_guard2:orderIdle()

    -- Start off the mission by sending a transmission to the player
    research_station:sendCommsMessage(
        player,
        _(
            [[Epsilon, please come in?

We lost contact with our transport RT-4. RT-4 is a diplomatic transport ship, transporting the diplomat named J.J.Johnson. They where heading from our research station to Orion-5.

Last contact was before RT-4 entered the nebula at G5, the nebula is blocking our long range scans. So we're asking you to investigate and recover RT-4 if possible.]]
        )
    )
    -- Set the initial mission state
    mission_state = missionStartState
end

function missionStartState(delta)
    if distance(player, transport_RT4) < 5000 then
        exuari_RT4_guard1:orderRoaming()
        exuari_RT4_guard2:orderRoaming()
        mission_state = missionRT4UnderAttack
    end
end
function missionRT4UnderAttack(delta)
    if not transport_RT4:isValid() then
        -- RT-4 destroyed, send a transmission to the player, create a supply drop to indicate an escape pod.
        mission_state = missionRT4EscapeDropped
        transport_RT4_drop = SupplyDrop():setFaction("Human Navy"):setPosition(3750, 31250)
        transport_RT4_drop_time = 0.0
        research_station:sendCommsMessage(
            player,
            _([[RT-4 has been destroyed! But an escape pod is ejected from the ship.

Lifesigns detected in the pod, please pick up the pod to see if J.J.Johnson made it. His death would be a great blow to the peace negotiations in the region.]]) ..
                _([[
And destroy those Exuari scum while you are at it!]])
        )
    end
    if not exuari_RT4_guard1:isValid() and not exuari_RT4_guard2:isValid() then
        -- Not sure how you did it, but you managed to destroy the two Exauri's before they destroy RT4...
        transport_RT4:destroy()
        mission_state = missionRT4EscapeDropped
        transport_RT4_drop = SupplyDrop():setFaction("Human Navy"):setPosition(3750, 31250)
        transport_RT4_drop_time = 0.0
        research_station:sendCommsMessage(
            player,
            _([[RT-4 has been destroyed! But an escape pod is ejected from the ship.

Lifesigns detected in the pod, please pick up the pod to see if J.J.Johnson made it. His death would be a great blow to the peace negotiations in the region.]])
        )
    end
end
function missionRT4EscapeDropped(delta)
    transport_RT4_drop_time = transport_RT4_drop_time + delta
    if not transport_RT4_drop:isValid() then
        -- Escape pod picked up, stop the transport_RT4_drop_timer
        if transport_RT4_drop_time > 60 * 5 then
            -- Spend more then 5 minutes in the escape pod, the diplomat died.
            jjj_alive = false
            mission_state = missionRT4Died
            research_station:sendCommsMessage(player, _([[Sir Johnson seems to have suffocated. This is a great loss for our cause of global peace.

Please deliver his body back to Research-1. We will arrange for you to take over his mission.]]))
        else
            -- Diplomat lives, drop him off at Orion-5
            jjj_alive = true
            mission_state = missionRT4PickedUp
            research_station:sendCommsMessage(player, _([[Just received message that Sir Johnson is safely aboard your ship! Great job!

Please deliver the diplomat to Orion-5 in sector G3, do this by docking with the station.]]))
        end
    end
end
function missionRT4PickedUp(delta)
    if player:isDocked(main_station) then
        -- Docked and delivered the diplomat.
        if jjj_alive then
            main_station:sendCommsMessage(
                player,
                _([[J.J.Johnson thanks you for rescuing him.

He tells you about his mission.
]]) ..
                    _(
                        [[He just came back from a mission from the Refugee-X station. Which is a neutral station in the area, known to house anyone no matter their history.
Lately Refugee-X has been under attack by Exuari ships, and some criminals living there have offered to give themselves up in exchange for better protection of the station.

The officers at Orion-5 will gladly make this trade. And they ask you to retrieve the criminals for them at Refugee-X in sector D5.
To make sure Refugee-X is aware of your peaceful intentions, we have stripped you of Nukes and EMPs. You will get them back once you deliver the criminals.]]
                    )
            )
        else
            main_station:sendCommsMessage(
                player,
                _([[J.J.Johnson message towards Orion-5 is clear:
]]) ..
                    _(
                        [[He just came back from a mission from the Refugee-X station. Which is a neutral station in the area, known to house anyone no matter their history.
Lately Refugee-X has been under attack by Exuari ships, and some criminals living there have offered to give themselves up in exchange for better protection of the station.

The officers at Orion-5 will gladly make this trade. And they ask you to retrieve the criminals for them at Refugee-X in sector D5.
To make sure Refugee-X is aware of your peaceful intentions, we have stripped you of Nukes and EMPs. You will get them back once you deliver the criminals.]]
                    )
            )
        end
        player.old_nuke_max = player:getWeaponStorageMax("Nuke")
        player.old_emp_max = player:getWeaponStorageMax("EMP")
        player:setWeaponStorage("Nuke", 0)
        player:setWeaponStorage("EMP", 0)
        player:setWeaponStorageMax("Nuke", 0)
        player:setWeaponStorageMax("EMP", 0)

        mission_state = missionRetrieveCriminals
    end
end
function missionRT4Died(delta)
    if player:isDocked(research_station) then
        -- Docked and delivered the diplomat's body.

        research_station:sendCommsMessage(player, _([[Apperently, J.J.Johnson managed to send out a transmission with his mission details to Orion-5 before he passed away.

Head to Orion-5 to receive the details on his mission.]]))
        mission_state = missionRT4PickedUp
    end
end

function missionRetrieveCriminals(delta)
    if player:isDocked(neutral_station) then
        neutral_station:sendCommsMessage(
            player,
            _(
                [[Two tough looking criminals board your ship. They are already cuffed, and do not look too happy about the whole situation.
One of them is a human pirate, blind in one eye and has clearly seen his fair share of battles. The other is Exuari who hisses what you presume is a curse in their native language.

You are wondering how voluntary their exchange really is...

Head back to Orion-5 to deliver the criminals.]]
            )
        )
        mission_state = missionWaitForAmbush
    end
end
function missionWaitForAmbush(delta)
    if distance(player, main_station) < 50000 then
        -- We can jump to the Orion-5 station in 1 jump. So ambush the player!
        x, y = player:getPosition()
        WarpJammer():setFaction("Exuari"):setPosition(x - 2008, y + 2711)
        ambush_main = CpuShip():setFaction("Exuari"):setTemplate("Starhammer II"):setScanned(true):setPosition(x - 1667, y + 2611):setRotation(-80):orderAttack(player)
        ambush_side1 = CpuShip():setFaction("Exuari"):setTemplate("Nirvana R5"):setScanned(true):setPosition(x - 736, y + 2875):setRotation(-80):orderAttack(player)
        ambush_side2 = CpuShip():setFaction("Exuari"):setTemplate("Nirvana R5"):setScanned(true):setPosition(x - 2542, y + 2208):setRotation(-80):orderAttack(player)
        mission_state = missionAmbushed

        ambush_main:sendCommsMessage(player, _([[Sllaaami graa kully fartsy!

Your translator has difficulty translating the message. But it seems to come down to the fact that they want you dead and that your death will bring them great fun.]]))
    end
end
function missionAmbushed(delta)
    if player:isDocked(main_station) then
        local refilled = false
        if player.old_nuke_max ~= nil then
            player:setWeaponStorage("Nuke", player.old_nuke_max)
            player:setWeaponStorage("EMP", player.old_emp_max)
            player:setWeaponStorageMax("Nuke", player.old_nuke_max)
            player:setWeaponStorageMax("EMP", player.old_emp_max)
            player.old_nuke_max = nil
            refilled = true
        end
        if not ambush_main:isValid() and not ambush_side1:isValid() and not ambush_side2:isValid() then
            message =
                _(
                [[Good job on dealing with those Exuari scum. The criminals are safely in our custody now. We'll be sending out a protection detail for Refugee-X

We managed to extract some vital info from the Exuari. In the next transport convoy towards Research-1 a Exuari death squad is hiding in one of the ships. The transport detail is heading in from D7, seek them out and scan the ships to find the Exuari transport.
]]
            )
            if refilled then
                message = message .. _([[We have refitted your nukes and EMPs. ]]) .. _([[Awesome job on taking out the Exuari without those.]])
                refilled = false
            end
            main_station:sendCommsMessage(player, message)

            x, y = neutral_station:getPosition()
            CpuShip():setTemplate("Phobos T3"):setFaction("Human Navy"):setPosition(x - 1000, y - 1000):orderDefendTarget(neutral_station):setCommsScript("")
            CpuShip():setTemplate("Nirvana R5"):setFaction("Human Navy"):setPosition(x + 1000, y + 1000):orderDefendTarget(neutral_station):setCommsScript("")

            transports = {}
            for n = 1, 5 do
                table.insert(transports, CpuShip():setTemplate("Personnel Freighter 2"):setFaction("Independent"):setPosition(50000 + random(-10000, 10000), -30000 + random(-10000, 10000)))
            end
            transport_target = CpuShip():setTemplate("Personnel Freighter 2"):setFaction("Exuari"):setPosition(50000 + random(-10000, 10000), -30000 + random(-10000, 10000))

            mission_state = missionGotoTransport
        end
        if refilled then
            main_station:sendCommsMessage(player, _([[We have refitted your nukes and EMPs. ]]) .. _([[Now to get those Exuaris!]]))
        end
    end
end
function missionGotoTransport(delta)
    if distance(player, transport_target) < 30000 then
        main_station:sendCommsMessage(player, _([[Scan the transports to identify the Exuari one. When you have identified it, do NOT destroy it.

Target it's impulse engines with your beam weapons to halt it's progress.]]))
        for _, transport in ipairs(transports) do
            transport:orderDock(research_station)
        end
        transport_target:orderDock(research_station)
        mission_state = missionIdentifyTransport
    end
end
function missionIdentifyTransport(delta)
    if not transport_target:isValid() then
        -- TODO: What to do now?
        main_station:sendCommsMessage(player, _([[What the hell? I told you NOT to destroy the transport.]]))
        victory("Exuari")
    elseif transport_target:isFriendOrFoeIdentifiedBy(player) then
        main_station:sendCommsMessage(player, _([[Transport identified, take down their impulse engines so we can capture it.]]))
        mission_state = missionStopTransport
    end
end
function missionStopTransport(delta)
    if not transport_target:isValid() then
        -- TODO: What to do now?
        main_station:sendCommsMessage(player, _([[What the hell? I told you NOT to destroy the transport.]]))
        victory("Exuari")
    elseif transport_target:getSystemHealth("impulse") <= 0.0 then
        main_station:sendCommsMessage(player, _([[Ok, transport disabled. We'll be sending a recovery team. Defend the transport, the Exuari will most likely rather destroy it then let it fall in our hands.]]))
        transport_target:setFaction("Independent"):orderIdle():setCallSign(transport_target:getCallSign() .. "-CAP")
        transport_target:setImpulseMaxSpeed(70):setJumpDrive(true)
        mission_state = missionTransportWaitForRecovery
        mission_timer = 40

        local x, y = transport_target:getPosition()
        transport_recovery_team = CpuShip():setTemplate("Flavia"):setFaction("Human Navy"):setPosition(x - random(8000, 10000), y + random(8000, 10000))
        transport_recovery_team:setCallSign("RTRV"):setScanned(true)
        transport_recovery_team:orderFlyTowardsBlind(transport_target:getPosition()):setCommsScript("")
    end
end
function missionTransportWaitForRecovery(delta)
    if not transport_target:isValid() then
        main_station:sendCommsMessage(player, _([[What the hell? I told you NOT to destroy the transport.]]))
        victory("Exuari")
    -- TODO: What to do now?
    end
    mission_timer = mission_timer - delta
    if mission_timer < 0 then
        mission_timer = random(90, 120)

        local x, y = transport_target:getPosition()
        local distance = random(8000, 12000)
        local r = random(0, 360)
        x = x + math.cos(r / 180 * math.pi) * distance
        y = y + math.sin(r / 180 * math.pi) * distance
        CpuShip():setTemplate("MT52 Hornet"):setFaction("Exuari"):setPosition(x, y):orderAttack(player)
    end
    if distance(transport_recovery_team, transport_target) < 1000 then
        transport_target:orderDock(main_station)
        transport_recovery_team:orderDock(main_station)

        transport_recovery_team:sendCommsMessage(player, _([[Transporter recovery team coming in.

We succesfully captured the Exuari transport. Taking it back to Orion-5. Please head to Orion-5 for a debriefing.]]))
        mission_state = missionTransportDone
    end
end

function missionTransportDone(delta)
    if player:isDocked(main_station) then
        main_station:sendCommsMessage(player, _([[Thanks to captured Exuari death squad we now know the location of the Exuari base in the area.

Lead the assault on the Exuari base in sector E2, expect heavy resistance.]]))

        CpuShip():setTemplate("Phobos T3"):setFaction("Exuari"):setPosition(-44000, -14000):orderDefendTarget(enemy_station)
        CpuShip():setTemplate("Nirvana R5"):setFaction("Exuari"):setPosition(-47000, -14000):orderDefendTarget(enemy_station)
        CpuShip():setTemplate("Piranha F12"):setFaction("Exuari"):setPosition(-44500, -15000):orderDefendTarget(enemy_station)
        CpuShip():setTemplate("Ranus U"):setFaction("Exuari"):setPosition(-43000, -9000):orderAttack(player)
        mission_state = nil
    end
end

function update(delta)
    -- When the player ship, or the research station is destroyed, call it a victory for the Exuari
    if not player:isValid() or not research_station:isValid() or not main_station:isValid() then
        victory("Exuari")
        return
    end
    if not enemy_station:isValid() then
        victory("Human Navy")
        return
    end

    if mission_state ~= nil then
        mission_state(delta)
    end
end

function distance(obj1, obj2)
    local x1, y1 = obj1:getPosition()
    local x2, y2 = obj2:getPosition()
    local xd, yd = (x1 - x2), (y1 - y2)
    return math.sqrt(xd * xd + yd * yd)
end

--- Place random objects in a line, from point `x1`, `y1` to `x2`, `y2`
-- with a random distance of `random_amount`.
function placeRandom(object_type, amount, x1, y1, x2, y2, random_amount)
    for n = 1, amount do
        local f = random(0, 1)
        local x = x1 + (x2 - x1) * f
        local y = y1 + (y2 - y1) * f

        local r = random(0, 360)
        local distance = random(0, random_amount)
        x = x + math.cos(r / 180 * math.pi) * distance
        y = y + math.sin(r / 180 * math.pi) * distance

        object_type():setPosition(x, y)
    end
end
