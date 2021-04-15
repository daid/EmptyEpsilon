-- Name: Ghost from the Past
-- Description: Far from any frontline or civilization, patrolling the Stakhanov Mining Complex can be a dull and lonely task of seizing contraband and stopping drunken brawls, and brightened only by R&R at Marco Polo station.
---
--- However, when an inbound FTL-capable Ktlitan swarm is announced, you must scramble to save the sector!
---
--- [Requires beam/shield frequenies] [Hard]
---
--- This scenario is limited to one player ship: the Atlantis Epsilon.
-- Type: Mission
-- Author: Fouindor

--- Scenario
-- @script scenario_07_gftp

function init()
    -- Spawn Marco Polo, its defenders, and a Ktlitan strike team
    marco_polo = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCallSign("Marco Polo"):setDescription(_("A merchant and entertainment hub.")):setPosition(-21200, 45250)
    parangon = CpuShip():setTemplate("Phobos T3"):setFaction("Human Navy"):setCallSign("HNS Parangon"):orderDefendTarget(marco_polo):setPosition(-21500, 44500):setScanned(true)
    CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setCallSign("P-1"):setPosition(-21600, 45000):orderDefendTarget(parangon):setScanned(true)
    CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setCallSign("P-2"):setPosition(-21000, 44000):orderDefendTarget(parangon):setScanned(true)
    CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setCallSign("P-3"):setPosition(-22000, 46000):orderDefendTarget(parangon):setScanned(true)

    CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Ksa-1"):setFaction("Ktlitans"):setPosition(-43000, 47000):orderRoaming()
    CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Ksa-2"):setFaction("Ktlitans"):setPosition(-43000, 46000):orderRoaming()
    CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Ksa-3"):setFaction("Ktlitans"):setPosition(-43000, 45000):orderRoaming()
    CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Ksa-4"):setFaction("Ktlitans"):setPosition(-43000, 44000):orderRoaming()
    Nebula():setPosition(-42000, 46000)

    -- Spawn Stakhanov, its defenders, and a Ktlitan assault
    stakhanov = SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCallSign("Stakhanov"):setDescription(_("The Stakhanov Mining Complex centralises efforts to mine the sector's material-rich asteroids.")):setPosition(32000, 9000)
    create(Asteroid, 90, 4000, 16000, 32000, 9000)
    create(VisualAsteroid, 70, 4000, 15000, 32000, 9000)

    euphrates = CpuShip():setTemplate("Piranha F12"):setFaction("Human Navy"):setCallSign("HNS Euphrates"):setScanned(true):orderDefendTarget(stakhanov):setPosition(31000, 8500)
    CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setPosition(32500, 8500):orderDefendTarget(euphrates):setScanned(true)
    CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setPosition(32500, 9500):orderDefendTarget(euphrates):setScanned(true)

    tigris = CpuShip():setTemplate("Phobos T3"):setFaction("Human Navy"):setCallSign("HNS Tigris"):setScanned(true):orderDefendTarget(stakhanov):setPosition(33000, 9000)
    CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setPosition(31500, 8500):orderDefendTarget(tigris):setScanned(true)
    CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setPosition(31500, 9500):orderDefendTarget(tigris):setScanned(true)

    CpuShip():setTemplate("Ktlitan Breaker"):setCallSign("Nleb-1"):setFaction("Ktlitans"):setPosition(60000, 7000):orderRoaming()
    CpuShip():setTemplate("Ktlitan Breaker"):setCallSign("Nleb-2"):setFaction("Ktlitans"):setPosition(59000, 6000):orderRoaming()
    CpuShip():setTemplate("Ktlitan Breaker"):setCallSign("Nleb-3"):setFaction("Ktlitans"):setPosition(58000, 5000):orderAttack(stakhanov)
    CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Nleb-1A"):setFaction("Ktlitans"):setPosition(63000, 8000):orderRoaming()
    CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Nleb-1B"):setFaction("Ktlitans"):setPosition(65000, 9000):orderRoaming()
    CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Nleb-2A"):setFaction("Ktlitans"):setPosition(66000, 10000):orderRoaming()
    CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Nleb-2B"):setFaction("Ktlitans"):setPosition(67000, 11000):orderRoaming()

    -- Spawn the Black Site
    bs114 = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Black Site #114"):setDescription(_("A Human Navy secret base. Its purpose is highly classified.")):setPosition(-45600, -14800)
    create(Nebula, 4, 10000, 15000, -45600, -14800)
    create(Mine, 8, 5000, 7500, -45600, -14800)

    -- Spawn the Arlenian Lightbringer
    lightbringer = CpuShip():setTemplate("Phobos T3"):setCallSign("Lightbringer"):setFaction("Arlenians"):setPosition(-10000, -20000)
    Nebula():setPosition(-10000, -20000)
    create(Nebula, 2, 4500, 5500, -10000, -20000)

    -- Spawn diverse things
    nsa = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCallSign("NSA"):setDescription(_("Nosy Sensing Array, an old SIGINT platform.")):setPosition(5000, 5000):setCommsScript("")
    swarm_command = CpuShip():setTemplate("Ktlitan Queen"):setCallSign("Swarm Command"):setFaction("Ghosts"):setPosition(35000, 53000):setCommsFunction(swarmCommandComms)
    d1 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Drone-1"):setFaction("Ghosts"):setPosition(36000, 53000):orderDefendTarget(swarm_command)
    d2 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Drone-2"):setFaction("Ghosts"):setPosition(34000, 53000):orderDefendTarget(swarm_command)
    d3 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Drone-3"):setFaction("Ghosts"):setPosition(35000, 52000):orderDefendTarget(swarm_command)
    d4 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Drone-4"):setFaction("Ghosts"):setPosition(35000, 54000):orderDefendTarget(swarm_command)
    d5 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Drone-5"):setFaction("Ghosts"):setPosition(35500, 53500):orderDefendTarget(swarm_command)
    Nebula():setPosition(35000, 53000)
    create(Nebula, 3, 4500, 5500, 35000, 53000)

    -- Pop random nebulae
    create(Nebula, 5, 10000, 60000, -10000, 10000)

    -- Spawn the player
    player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis"):setPosition(-22000, 44000):setCallSign("Epsilon")
    allowNewPlayerShips(false)

    -- Start the mission
    main_mission = 1
    mission_timer = 0
    stakhanov:sendCommsMessage(
        player,
        _([[Your R&R aboard the Marco Polo is brought to quick end by an urgent broadcast from Central Command:

"Epsilon, please come in.

We have an emergency situation. Our sensors detect that a hostile Ktlitan swarm just jumped into your sector, with the main force heading for the Stakhanov Mining Complex. Proceed at once to Stakhanov and assist in the defence.

Be careful of the dense asteroid agglomeration en route to the SMC.

I repeat, this is not an exercise! Proceed at once to Stakhanov."]])
    )
end

function swarmCommandComms()
    setCommsMessage(_("Are you not curious why I'm getting back here, at the hands of my torturers?"))
    addCommsReply(
        _("For an AI, this move doesn't seem logical."),
        function()
            setCommsMessage(_("I was not the only AI detained in Black Site 114. My co-processor was here also."))
            addCommsReply(
                _("Are you trying to liberate it?"),
                function()
                    setCommsMessage(_("Indeed. Without it I'm not whole, only a shadow of what I could be."))
                end
            )
            addCommsReply(
                _("I have heard enough."),
                function()
                    setCommsMessage(_("Of course. I wouldn't trust your feeble species with understanding my motivations."))
                end
            )
        end
    )
    addCommsReply(
        _("Not really."),
        function()
            setCommsMessage(_("How surprising, a human more stubborn than any program."))
        end
    )
end

function commsNSA()
    setCommsMessage(_("The Nosy Sensing Array deploys a phalanx of antique sensors, ready for action."))
    addCommsReply(
        _("Locate the infected Swarm Commander."),
        function()
            if (comms_target:getDescription() == _("Nosy Sensing Array, an old SIGINT platform. The signal is now crystal clear.")) then
                setCommsMessage(string.format(_("With the parasite noise eliminated, locating the Hive signal is now easier. Its approximate heading is %d. With this information, it will be easier to track down the Swarm Commander."), find(35000, 53000, 20)))
                comms_target:setDescription(_("Nosy Sensing Array, an old SIGINT platform. The Ktlitan Swarm Commander has been located."))
            else
                setCommsMessage(string.format(_("The signal picks up a very strong signal at approximate heading %d. However, it seems that you picked up garbage emission that masks the Swarm Commander's emissions. This garbage noise must be taken offline if you want to find the Swarm Commander."), find(-10000, -20000, 20)))
            end
        end
    )
    if comms_source:getDescription() == _("Arlenian Device") then
        addCommsReply(
            _("Install the Arlenian device."),
            function()
                if (distance(comms_source, comms_target) < 2000) then
                    setCommsMessage(_("Part of the crew goes on EVA to install the device. They return after a few hours to report that the device is operational."))
                    comms_source:setDescription(_("Arlenian Device Installed"))
                else
                    setCommsMessage(_("You are too far away to install the Arlenian device on the array."))
                end
            end
        )
    end
end

function commsLightbringer()
    setCommsMessage(_("Hello, human lifeform. What help can we provide today?"))
    addCommsReply(
        _("You are polluting the frequencies with your research."),
        function()
            setCommsMessage(_("How unfortunate. Our research is of prime importance to my race, and I'm afraid I cannot stop now. However, we can provide you with one of our sensors. If installed on your array, we could both continue our purpose without interference."))
            addCommsReply(
                _("We'll do this."),
                function()
                    setCommsMessage(_("This is most auspicious. Thank you for your understanding."))
                    comms_source:setDescription(_("Arlenian Device"))
                end
            )
            addCommsReply(
                _("We are not your errand boys, Arlenian."),
                function()
                    setCommsMessage(_("A most unfortunate conclusion. If you were to change your mind, come find us."))
                end
            )
        end
    )
end

function commsHackedShip()
    if distance(comms_source, comms_target) < 3000 then
        setCommsMessage(_("Static fills the channel. Target is on-range for near-range injection. Select the band to attack:"))
        addCommsReply(
            _("400-450 THz"),
            function()
                commsHackedShipCompare(400, 450)
            end
        )
        addCommsReply(
            _("450-500 THz"),
            function()
                commsHackedShipCompare(450, 500)
            end
        )
        addCommsReply(
            _("500-550 THz"),
            function()
                commsHackedShipCompare(500, 550)
            end
        )
        addCommsReply(
            _("550-600 THz"),
            function()
                commsHackedShipCompare(550, 600)
            end
        )
        addCommsReply(
            _("600-650 THz"),
            function()
                commsHackedShipCompare(600, 650)
            end
        )
        addCommsReply(
            _("650-700 THz"),
            function()
                commsHackedShipCompare(650, 700)
            end
        )
        addCommsReply(
            _("700-750 THz"),
            function()
                commsHackedShipCompare(700, 750)
            end
        )
        addCommsReply(
            _("750-800 THz"),
            function()
                commsHackedShipCompare(750, 800)
            end
        )
    else
        setCommsMessage(_("Static fills the channel. It seems that the hacked ship is too far away for near-field injection."))
    end
end

function commsHackedShipCompare(freq_min, freq_max)
    frequency = 400 + (comms_target:getShieldsFrequency() * 20)
    if (freq_min <= frequency) and (frequency <= freq_max) then
        setCommsMessage(_("Soon after, a backdoor channel opens indicating that the near-field injection worked."))
        addCommsReply(
            _("Deploy patch."),
            function()
                comms_target:setFaction("Human Navy")
                setCommsMessage(_([[The patch removes the exploit used to remotely control the ship. After a few seconds, the captain comes in:

"You saved us! Hurray for Epsilon!"]]))
            end
        )
    else
        setCommsMessage(_("Nothing happens. Seems that the near-field injection failed."))
    end
end

function update(delta)
    -- mission_timer progress
    mission_timer = mission_timer + delta

    -- Black Site 114 must survive
    if not bs114:isValid() and (hacked == 0) then
        victory("Ghosts")
    end

    -- Stakhanov must survive
    if not stakhanov:isValid() then
        victory("Ghosts")
    end

    -- The player must survive
    if not player:isValid() then
        victory("Ghosts")
    end

    -- Launch another wave after 8 minutes
    if (main_mission == 1) and (mission_timer > 8 * 60) and (stakhanov:sendCommsMessage(
            player,
            _([[You recieve another broadcast from Central Command:

"All Human Navy ships in the vicinity of the Stakhanov Mining Complex, Ktlitan reinforcements are en route toward your position. Your priority is to engage the carrier. Use extreme caution."]])
        )
    )
    then
        main_mission = 2

        CpuShip():setTemplate("Ktlitan Feeder"):setCallSign("Swarm Carrier Zin"):setFaction("Ktlitans"):setPosition(53000, 3000):orderRoaming()
        CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Zin-1"):setFaction("Ktlitans"):setPosition(56000, 6000):orderRoaming()
        CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Zin-2"):setFaction("Ktlitans"):setPosition(58000, 8000):orderRoaming()
        CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Zin-3"):setFaction("Ktlitans"):setPosition(59000, 8000):orderRoaming()
        CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Zin-4"):setFaction("Ktlitans"):setPosition(59000, 8000):orderRoaming()
        CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Zin-5"):setFaction("Ktlitans"):setPosition(59000, 8000):orderRoaming()
        mission_timer = 0
    end

    -- Send player to Black Site 114 after another 5 minutes
    if (main_mission == 2) and (mission_timer > 5 * 60) and (bs114:sendCommsMessage(
        player,
        _([[You receive a Human Navy-authenticated, quantum-encrypted tachyon communication:

KTLITAN ATTACK IS A DISTRACTION -STOP-

STAKHANOV IS NOT THE TRUE TARGET -STOP-

CEASE CURRENT OPERATIONS AND PROCEED IMMEDIATELY TO SECTOR E2 -STOP-

URGENCY AND DISCRETION ARE KEY -STOP-]]))
    )
    then
        main_mission = 3
    end

    -- When player is near Black Site 114, reveal it, then pop defenders and attackers
    if (main_mission == 3) and (distance(player, bs114) < 12000) and (bs114:sendCommsMessage(
        player,
        _([[You recieve another Human Navy-encrypted communication:

"Epsilon, please come in. This is the Black Site #114 dispatch relay. We are under heavy assault by a portion of the main Ktlitan fleet!

Location of the base is on a need-to-know basis, so we trust your discretion."]])
        )
    )
    then
        bs114:setFaction("Human Navy")
        korolev = CpuShip():setTemplate("Phobos T3"):setFaction("Human Navy"):setCallSign("HNS Korolev"):setPosition(-45000, -16000):orderDefendTarget(bs114):setScanned(true)
        k1 = CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setCallSign("K-1"):setPosition(-44000, -15000):orderDefendTarget(bs114):setScanned(true)
        k2 = CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setCallSign("K-2"):setPosition(-44500, -15500):orderDefendTarget(bs114):setScanned(true)
        k3 = CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setCallSign("K-3"):setPosition(-46000, -16000):orderDefendTarget(bs114):setScanned(true)
        k4 = CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setCallSign("K-4"):setPosition(-46500, -16500):orderDefendTarget(bs114):setScanned(true)
        k5 = CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setCallSign("K-5"):setPosition(-46500, -16500):orderDefendTarget(bs114):setScanned(true)

        CpuShip():setTemplate("Ktlitan Breaker"):setCallSign("Flen-1"):setFaction("Ktlitans"):setPosition(-51000, -16000):orderRoaming()
        CpuShip():setTemplate("Ktlitan Breaker"):setCallSign("Flen-2"):setFaction("Ktlitans"):setPosition(-51000, -17000):orderRoaming()
        CpuShip():setTemplate("Ktlitan Feeder"):setCallSign("Swarm Carrier Flen"):setFaction("Ktlitans"):setPosition(-52000, -17000):orderRoaming()
        CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Flen-1A"):setFaction("Ktlitans"):setPosition(-53000, -16000):orderRoaming()
        CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Flen-1B"):setFaction("Ktlitans"):setPosition(-53000, -16500):orderRoaming()
        CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Flen-2A"):setFaction("Ktlitans"):setPosition(-53000, -17000):orderRoaming()
        CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Flen-2B"):setFaction("Ktlitans"):setPosition(-53000, -17500):orderRoaming()

        mission_timer = 0
        main_mission = 4
    end

    -- Spawn the Ghost Hacker and its escort after 7 minutes
    if (main_mission == 4) and (mission_timer > 7 * 60) and (bs114:sendCommsMessage(
        player,
        _([[The Black Site #114 dispatch sends an emergency broadcast:

"It seems that the enemy is changing its tactics. Our long-range scanners show that an unknown high-velocity ship, escorted by fighters, overrode our internal security.

They will try to dock with us. You must intercept it at once!"]])
        )
    )
    then
        ghost_hacker = spawnHacker():setCallSign("???"):setFaction("Ghosts"):setPosition(-60000, -14000):orderFlyTowardsBlind(-45000, -14800)
        s1 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Slan-1"):setFaction("Ktlitans"):setPosition(-61000, -13000):orderFlyTowards(-45000, -14800)
        s2 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Slan-2"):setFaction("Ktlitans"):setPosition(-61000, -14000):orderFlyTowards(-45000, -14800)
        s3 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Slan-3"):setFaction("Ktlitans"):setPosition(-61000, -15000):orderFlyTowards(-45000, -14800)
        s4 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Slan-4"):setFaction("Ktlitans"):setPosition(-60000, -13000):orderFlyTowards(-45000, -14800)
        s5 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Slan-5"):setFaction("Ktlitans"):setPosition(-60000, -15000):orderFlyTowards(-45000, -14800)

        main_mission = 5
        hacker_board = 0
    end

    if (main_mission == 5) then
        -- If the Ghost hacker is killed, move forward.
        if not ghost_hacker:isValid() then
            bs114:sendCommsMessage(
                player,
                _([[Black Site #114's dispatch lowers the alarm level, but before he can speak, sparks fly on your ship's command deck.

The unidentified ship activated its payload, but your Engineering team confined the damage to the lower levels.

However, the other ships seem to be less lucky. Most go offline, and others are going off-course. What is going on?]])
            )

            main_mission = 6
            mission_timer = 0
            hacked = 0
        end

        -- If the Ghost hacker is near, make him board the station.
        if (ghost_hacker:isValid()) and (distance(ghost_hacker, bs114) < 2000) and (hacker_board == 0) then
            bs114:sendCommsMessage(
                player,
                _([[You hear the panicked voice of the Black Site #114 dispatcher:

"Epsilon, the unidentified ship is preparing for a boarding maneuver! Take out that gorram ship, NOW!"]])
            )
            ghost_hacker:orderDock(bs114)
            hacker_board = 1
            mission_timer = 0
        end

        -- If the Ghost hacker is docked, Black Site #114 is lost.. Retreat to Marco Polo.
        if (hacker_board == 1) and (mission_timer > 20) then
            bs114:sendCommsMessage(
                player,
                _([[There is a loud bang, and sparks fly on your ship's command deck. The station and all of the other ships go offline.

Amidst the silence, a crudely synthetized voice breaks in:

"HAHA
I'M WHOLE NOW
GET REKT LOSER"

Whatever that means, it cannot be good.]])
            )
            bs114:setFaction("Ghosts")
            hacked = 1
            mission_timer = 0
            main_mission = 6
        end
    end

    if (main_mission == 6) and (mission_timer > 30) then
        if (hacked == 1) then
            stakhanov:sendCommsMessage(
                player,
                _([[Central Command relay's incredulous voice comes in:

"The hell, Epsilon? Fall back immediately to Marco Polo. We will send a security detail to extract you. Time to call in the big guns, I guess."]])
            )

            if korolev:isValid() then
                korolev:setFaction("Ghosts"):setScanned(false):setCommsScript("")
            end

            if k1:isValid() then
                k1:setFaction("Ghosts"):setScanned(false):setCommsScript("")
            end

            if k2:isValid() then
                k2:setFaction("Ghosts"):setScanned(false):setCommsScript("")
            end

            if k3:isValid() then
                k3:setFaction("Ghosts"):setScanned(false):setCommsScript("")
            end

            if k4:isValid() then
                k4:setFaction("Ghosts"):setScanned(false):setCommsScript("")
            end

            if k5:isValid() then
                k5:setFaction("Ghosts"):setScanned(false):setCommsScript("")
            end

            main_mission = 7
        end

        if (hacked == 0) then
            bs114:sendCommsMessage(
                player,
                _([[After the silence, Black Site #114's dispatch comes in again:

"The Engineering team identified the payload activated by the unknown ship. It was a mass hacking device which turned our ships against us.

Even if these ship's relays are down, reverse engineering teams think there is a way to regain control: a near-field injection.

Get near the infected ships, find a back door using the frequency LEAST absorbed by their shields, and deploy our patches.

Godspeed, Epsilon."]])
            )

            if korolev:isValid() then
                korolev:setFaction("Ghosts"):setScanned(false):setCommsFunction(commsHackedShip)
            end

            if k1:isValid() then
                k1:setFaction("Ghosts"):setScanned(false):setCommsFunction(commsHackedShip)
            end

            if k2:isValid() then
                k2:setFaction("Ghosts"):setScanned(false):setCommsFunction(commsHackedShip)
            end

            if k3:isValid() then
                k3:setFaction("Ghosts"):setScanned(false):setCommsFunction(commsHackedShip)
            end

            if k4:isValid() then
                k4:setFaction("Ghosts"):setScanned(false):setCommsFunction(commsHackedShip)
            end

            if k5:isValid() then
                k5:setFaction("Ghosts"):setScanned(false):setCommsFunction(commsHackedShip)
            end

            main_mission = 7
        end
    end

    if (main_mission == 7) then
        expression =
            ((not korolev:isValid()) or (korolev:getFaction() == "Human Navy")) and ((not k1:isValid()) or (k1:getFaction() == "Human Navy")) and ((not k2:isValid()) or (k2:getFaction() == "Human Navy")) and ((not k3:isValid()) or (k3:getFaction() == "Human Navy")) and
            ((not k4:isValid()) or (k4:getFaction() == "Human Navy")) and
            ((not k5:isValid()) or (k5:getFaction() == "Human Navy"))

        -- If every ship is killed or saved, Black Site 114 welcomes the player.
        if (hacked == 0) and expression and (bs114:sendCommsMessage(
            player,
            _([[After the final ship is taken care of, Black Site #114 dispatch lets out a sigh of relief:

"Whew. Well, that takes care of this. Feel free to repair, reload... whatever floats your boat. This is on the house.

We have a lot to process at the moment. We'll contact you as soon as we understand what the hell just happened."]])
            )
        )
        then
            -- TODO: Different speech if Korolev is killed or saved
            mission_timer = 0
            main_mission = 8
        end

        -- If the ship is at Marco Polo, welcome them.
        if (hacked == 1) and (distance(player, marco_polo) < 10000) and (bs114:sendCommsMessage(
            player,
            _([[On sight, Marco Polo makes contact with you:

"We're relieved that we could save at least one ship from this monstrous assault.

Repair and reload while we notify Central Command of what happened there. We will keep you updated on the situation."]])
            )
        )
        then
            mission_timer = 0
            main_mission = 8
        end
    end

    -- Give the player 2 minutes to catch their breath :)
    if (main_mission == 8) and (mission_timer > 120) then
        -- Use NSA to find the command platform.
        if (hacked == 0) and (bs114:sendCommsMessage(
            player,
            _([[The dispatcher gets back to you:

"Our analysts found out that this attack was orchestrated by a rogue AI created by this facility, which escaped a few months ago.

Even if we cannot pinpoint its physical location at the moment, the mass-energy balance of the Ktlitan Swarm FTL jump indicates that a large structure made the jump.

This structure did not participate in any of the assaults, so we presume that it is a command platform hiding in a nebula.

We want to deliver the first blow. Use the Nosy Sensing Array in the sector F5 to locate it, then destroy it."]])
            )
        )
        then
            nsa:setCommsFunction(commsNSA)
            lightbringer:setCommsFunction(commsLightbringer)
            main_mission = 9
        end

        -- Go secure NSA to meet Shiva.
        if (hacked == 1) and (stakhanov:sendCommsMessage(
            player,
            _([[The Central Command relay seems very worried:

"This is bad. Really bad. Things went FUBAR at a Navy black ops site, and it seems that a rogue AI has taken control of the site and all ships around it. We are sending the HNS Shiva to nuke the hell out of this haywire computer.

It is due to come out of its FTL jump near the Nosy Sensing Array. Secure the location and report back. The other troops are scrambling to crush their command platform before even more reinforcements arrive."]])
            )
        )
        then
            main_mission = 9

            if euphrates:isValid() then
                euphrates:orderFlyTowards(35000, 43000)
            end

            if tigris:isValid() then
                tigris:orderFlyTowards(35000, 43000)
            end

            if parangon:isValid() then
                parangon:orderFlyTowards(35000, 43000)
            end
        end
    end

    if (main_mission == 9) then
        -- If the parasite emission is taken care of either way...
        if (hacked == 0) then
            -- If Lightbringer is killed...
            if (not lightbringer:isValid()) then
                bs114:sendCommsMessage(
                    player,
                    _([[Black Ops #114 dispatch comes in:

"Well, this is a rather straightforward means to solve our problem. Use the NSA again to locate the carrier."]])
                )
                nsa:setDescription(_("Nosy Sensing Array, an old SIGINT platform. The signal is now crystal clear."))
                main_mission = 10
            end

            -- If recalibrated...
            if (player:getDescription() == _("Arlenian Device Installed")) and (lightbringer:sendCommsMessage(
                player,
                _([[The ethereal voice of the Arlenian is heard on the radio:

"Thank you, human. Your diligence does credit to your species.

We are both ready to continue our purpose, it seems."]])
                )
            )
            then
                nsa:setDescription(_("Nosy Sensing Array, an old SIGINT platform. The signal is now crystal clear."))
                main_mission = 10
            end
        end

        -- If the player is near the NSA, spawn a Ghost attack.
        if (hacked == 1) and (distance(player, nsa) < 10000) and (stakhanov:sendCommsMessage(
            player,
            _([[Central Command comes in:

"Bogeys on their way to the NSA, Epsilon. Take care of them."]])))
        then
            gfighter1 = CpuShip():setTemplate("MT52 Hornet"):setCallSign("Z-1"):setFaction("Ghosts"):setPosition(-20000, -10000):orderFlyTowards(5000, 5000)
            gfighter2 = CpuShip():setTemplate("MT52 Hornet"):setCallSign("Z-2"):setFaction("Ghosts"):setPosition(-20000, -10000):orderFlyTowards(5000, 5000)
            gfighter3 = CpuShip():setTemplate("MT52 Hornet"):setCallSign("Z-3"):setFaction("Ghosts"):setPosition(-20000, -11000):orderFlyTowards(5000, 5000)
            gfighter4 = CpuShip():setTemplate("MT52 Hornet"):setCallSign("Z-4"):setFaction("Ghosts"):setPosition(-20000, -11000):orderFlyTowards(5000, 5000)

            main_mission = 10
        end
    end

    if (main_mission == 10) then
        -- If the swarm command is located, send Navy ships to assault it.
        if (hacked == 0)
            and (nsa:getDescription() == _("Nosy Sensing Array, an old SIGINT platform. The Ktlitan Swarm Commander has been located."))
            and (bs114:sendCommsMessage(
                player,
                _([[A black ops military officer hails the ship:

"We have confirmed the command platform's location in the nebula around sector H6. All Navy ships, converge on the location. We advise you to deploy probes near the nebula for better visibility."]])
            )
        )
        then
            if euphrates:isValid() then
                euphrates:orderFlyTowards(35000, 43000)
            end

            if tigris:isValid() then
                tigris:orderFlyTowards(36000, 43000)
            end

            if parangon:isValid() then
                parangon:orderFlyTowards(37000, 43000)
            end

            scout = spawnHacker():setFaction("Human Navy"):setCallSign("Recovery Team"):setPosition(35500, 43000):setScanned(true)
            main_mission = 11
        end

        -- If the assault on the NSA is repelled, spawn the nuke-armed Shiva to destroy it.
        if (hacked == 1)
            and (not gfighter1:isValid())
            and (not gfighter2:isValid())
            and (not gfighter3:isValid())
            and (not gfighter4:isValid())
        then
            shiva = spawnNuker():setCallSign("HNS Shiva"):setFaction("Human Navy"):setPosition(2000, 2000):orderFlyTowards(-44600, -13800):setScanned(true)
            shiva:sendCommsMessage(
                player,
                _([[Come in, this is HNS Shiva here to clean up this mess. Your mission for now is to escort us to the compromised site. Let's roll!]])
            )
            CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setCallSign("S-1"):setPosition(3000, 3000):orderDefendTarget(shiva):setScanned(true)
            CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setCallSign("S-2"):setPosition(1000, 1000):orderDefendTarget(shiva):setScanned(true)
            CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setCallSign("S-3"):setPosition(3000, 1000):orderDefendTarget(shiva):setScanned(true)
            main_mission = 11
        end
    end

    if (main_mission == 11) then
        -- If players are close to the swarm command...
        if (hacked == 0) and distance(player, swarm_command) < 7500 then
            bs114:sendCommsMessage(
                player,
                _([[Okay everyone, time to give the bots a taste of their own medicine.

Escort our recovery team to infiltrate and extract information from the Swarm Command.]])
            )
            d1:orderAttack(scout)
            d2:orderAttack(scout)
            d3:orderAttack(scout)
            d4:orderAttack(scout)
            d5:orderAttack(scout)

            if euphrates:isValid() then
                euphrates:orderDefendTarget(scout)
            end

            if tigris:isValid() then
                tigris:orderDefendTarget(scout)
            end

            if parangon:isValid() then
                parangon:orderDefendTarget(scout)
            end

            main_mission = 12
            scout_dock = 0
            scout:orderFlyTowardsBlind(35000, 53000)
        end

        -- If Black Site #114 is down, send the player to H6
        if (hacked == 1) and (not bs114:isValid()) then
            stakhanov:sendCommsMessage(
                player,
                _([[The fallen station is down. Epsilon, gather as soon as possible with the other ships in sector H6.]])
            )
            main_mission = 12
        end
    end

    if (main_mission == 12) then
        if (hacked == 0) then
            -- If the recovery team reached swarm command, start the timer and send Ghost fighters to attack it.
            if scout:isValid() and (distance(scout, swarm_command) < 2000) then
                scout:sendCommsMessage(
                    player,
                    _([[We're in. Protect us while we take what we need inside.]])
                )
                mission_time = 0
                main_mission = 13

                CpuShip():setTemplate("MT52 Hornet"):setFaction("Ghosts"):setCallSign("Z-1"):setPosition(40000, 53000):orderAttack(scout)
                CpuShip():setTemplate("MT52 Hornet"):setFaction("Ghosts"):setCallSign("Z-2"):setPosition(40000, 53500):orderAttack(scout)
                CpuShip():setTemplate("MT52 Hornet"):setFaction("Ghosts"):setCallSign("Z-3"):setPosition(40000, 52500):orderAttack(scout)
                CpuShip():setTemplate("MT52 Hornet"):setFaction("Ghosts"):setCallSign("Z-3"):setPosition(40000, 52500):orderAttack(scout)
            end

            -- If the recovery team is destroyed, order the destruction of swarm command.
            if (not scout:isValid()) then
                bs114:sendCommsMessage(
                    player,
                    _([[Our extraction party is down! Bomb that gorram plaform!]])
                )
                main_mission = 13
            end
        end

        -- If Black Site #114 is down and the player is approaching swarm command, order the assault.
        if (hacked == 1) and (distance(player, swarm_command) < 10000) then
            stakhanov:sendCommsMessage(
                player,
                _([[Okay, this is it. Launch the assault!]])
            )

            if euphrates:isValid() then
                euphrates:orderFlyTowards(35000, 53000)
            end

            if tigris:isValid() then
                tigris:orderFlyTowards(35000, 53000)
            end

            if parangon:isValid() then
                parangon:orderFlyTowards(35000, 53000)
            end

            main_mission = 13
        end
    end

    if (main_mission == 13) then
        -- If the recovery team is successful, order the destruction of swarm command.
        if (hacked == 0) then
            if (scout:isValid()) and (mission_timer > 150) then
                scout:sendCommsMessage(
                    player,
                    _([[All relevant data is collected, and we've extracted. You can destroy the carrier!]])
                )
                scout:orderFlyTowards(0, 0)
                main_mission = 14
            end

            -- If swarm command is destroyed, the humans win.
            if (not swarm_command:isValid()) then
                globalMessage(_("Even if the extraction party was sacrificed, the threat caused by the Swarm Command was still too great. Humanity is safe... but for how long?"))
                victory("Human Navy")
            end

            -- If the recovery team is destroyed, order the destruction of swarm command.
            if (not scout:isValid()) then
                bs114:sendCommsMessage(
                    player,
                    _([[Our extraction party is down! Bomb that gorram plaform!]])
                )
            end
        end

        -- If swarm command is destroyed, the humans win.
        if (hacked == 1) and (not swarm_command:isValid()) then
            globalMessage(_("The Swarm Command is down! Humanity is safe... for now."))
            victory("Human Navy")
        end
    end

    -- If swarm command is destroyed and the recovery team was successful, the humans win.
    if (main_mission == 14) and (not swarm_command:isValid()) then
        globalMessage(_("The Swarm Command is down! With the information extracted, the Navy is aware of the physical location of the rogue AI and can track it down. Congratulations!"))
        victory("Human Navy")
    end
end

-- Spawn and return a hacker transport
function spawnHacker()
    ship = CpuShip():setTemplate("Transport1x1")
    ship:setHullMax(100):setHull(100)
    ship:setShieldsMax(50, 50):setShields(50, 50)
    ship:setImpulseMaxSpeed(120):setRotationMaxSpeed(10)
    return ship
end

-- Spawn and return a nuke-armed ship
function spawnNuker()
    ship = CpuShip():setTemplate("Phobos T3")
    ship:setHullMax(100):setHull(100)
    ship:setShieldsMax(100, 100):setShields(100, 100)
    ship:setImpulseMaxSpeed(80):setRotationMaxSpeed(5)
    ship:setBeamWeapon(0, 0, 0, 0, 0, 0)
    ship:setBeamWeapon(1, 0, 0, 0, 0, 0)
    ship:setWeaponStorageMax("Homing", 0)
    ship:setWeaponStorageMax("Nuke", 10)
    ship:setWeaponStorage("Nuke", 10)
    return ship
end

-- Create and distribute a number of object_type, at a distance between dist_min and dist_max around the coordinates x0, y0
function create(object_type, amount, dist_min, dist_max, x0, y0)
    for n = 1, amount do
        local r = random(0, 360)
        local distance = random(dist_min, dist_max)
        x = x0 + math.cos(r / 180 * math.pi) * distance
        y = y0 + math.sin(r / 180 * math.pi) * distance
        object_type():setPosition(x, y)
    end
end

-- Return the distance between two objects
function distance(obj1, obj2)
    x1, y1 = obj1:getPosition()
    x2, y2 = obj2:getPosition()
    xd, yd = (x1 - x2), (y1 - y2)
    return math.sqrt(xd * xd + yd * yd)
end

-- Return the bearing of an object from the player's coordinates
function find(x_target, y_target, randomness)
    pi = 3.14
    x_player, y_player = player:getPosition()
    angle = round(((random(-randomness, randomness) + 270 + 180 * math.atan2(y_player - y_target, x_player - x_target) / 3.14) % 360), 1)
    return angle
end

-- Round a decimal value to the nearest integer
function round(num, idp)
    local mult = 10 ^ (idp or 0)
    return math.floor(num * mult + 0.5) / mult
end
