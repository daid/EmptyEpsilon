-- Name: The Edge-of-Space
-- Description: You command the Technician Cruiser Apollo, a repair ship on the border of dangerous space.
--- The Apollo is outfitted with minimal weapons as there is a cease-fire between the Human Navy and the neighboring Kraylor.
---- You are tasked with discovering the cause of damage on one of your deep space telescopes.
---
--- This scenario is played with exactly one player ship: the Atlantis Apollo.
-- Type: Mission
-- Author: Visjammer

--- Scenario
-- @script scenario_03_edgeofspace

--- Init is run when the scenario is started. Create your initial world.
function init()
    -- Create the main ship for the players.
    Player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis"):setPosition(12400, 18200):setCallSign("Apollo"):addReputationPoints(250.0)
    allowNewPlayerShips(false)

    -- Modify the default cruiser into a technical cruiser, which has less weapon power then the normal player cruiser.
    Player:setTypeName("Technician Cruiser")
    --                 # Arc, Dir, Range, CycleTime, Dmg
    Player:setBeamWeapon(0, 90, -25, 1000.0, 6.0, 10)
    Player:setBeamWeapon(1, 90, 25, 1000.0, 6.0, 10)
    Player:setWeaponTubeCount(1)
    Player:setWeaponTubeDirection(0, 0)
    Player:setWeaponStorageMax("Nuke", 0)
    Player:setWeaponStorageMax("Mine", 0)

    -- Create a "Technical Officer" entity hidden in sector Z81 to talk to Relay and prompt the Captain to give the order to return to Central Command. The position of this ship in relation to the Station Nirvana was intended to serve as a sort of timer for the inspection job.
    Technical_Officer = CpuShip():setFaction("Human Navy"):setTemplate("Flavia"):setCallSign("Technical Officer"):setPosition(1530000, 411000):orderIdle()
    Technical_Officer:setCommsScript("") -- Disable the comms script for the Technical Officer station (though really, they should never find it all the way out in sector Z81).
    -- Create a station called "Nirvana" for "Technical Officer" to approach. Surplus to requirements now but a good example of the crazy stuff a newbie might try.
    Nirvana = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setPosition(1530000, 412000):setCallSign("Nirvana")

    EOS_Station = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setPosition(60500, 42100):setCallSign("E.O.S Scope")
    EOS_Station:setCommsScript("") -- Disable the comms script for the EOS Scope station.
    Midspace_Station = SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setPosition(34643, 39301):setCallSign("Midspace Support")
    Central_Command = SpaceStation():setTemplate("Huge Station"):setFaction("Human Navy"):setPosition(14500, 19100):setCallSign("Central Command")
    Central_Command:setCommsScript("comms_station_scenario_03_central_command.lua")

    Kraylor_Eline = SpaceStation():setTemplate("Small Station"):setFaction("Kraylor"):setPosition(79200, 38800):setCallSign("K-Endline")
    Kraylor_Mline = SpaceStation():setTemplate("Large Station"):setFaction("Kraylor"):setPosition(101830, 26725):setCallSign("K-Midline")

    Science_Galileo = SpaceStation():setTemplate("Medium Station"):setFaction("Arlenians"):setPosition(11100, -49150):setCallSign("Galileo")

    -- Random-ass stations
    SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCallSign("DS7"):setPosition(-44177, 20762)
    SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCallSign("DS4"):setPosition(1632, 30619)
    SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCallSign("DS3"):setPosition(-9130, 10285)
    SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCallSign("DS2"):setPosition(-27987, 41095)

    Human_m1 = CpuShip():setFaction("Human Navy"):setTemplate("MT52 Hornet"):setCallSign("HM1"):setScanned(true):setPosition(31875, 38653):orderDefendLocation(31875, 38653)
    Human_m2 = CpuShip():setFaction("Human Navy"):setTemplate("MT52 Hornet"):setCallSign("HM2"):setScanned(true):setPosition(37493, 37185):orderDefendLocation(37493, 37185)
    Human_m3 = CpuShip():setFaction("Human Navy"):setTemplate("MT52 Hornet"):setCallSign("HM3"):setScanned(true):setPosition(35519, 42854):orderDefendLocation(35519, 42854)

    -- Nebula that hide the enemy station.
    Nebula():setPosition(52300, 42200)
    Nebula():setPosition(51300, 34200)
    Nebula():setPosition(48700, 30050)

    -- Random-ass nebulae
    Nebula():setPosition(49362, -18062)
    Nebula():setPosition(-915, 27349)
    Nebula():setPosition(-4159, 19240)
    Nebula():setPosition(-10484, -10439)
    Nebula():setPosition(21545, 64380)
    Nebula():setPosition(-33690, 17766)
    Nebula():setPosition(13626, 75799)
    Nebula():setPosition(-68463, 42333)
    Nebula():setPosition(-67320, 11857)
    Nebula():setPosition(-46273, 39476)
    Nebula():setPosition(-27368, 85952)
    Nebula():setPosition(-33654, -41667)

    -- Create 50 Asteroids
    for asteroid_counter = 1, 20 do
        Asteroid():setPosition(random(-10000, 20000), random(-22000, -15000))
        VisualAsteroid():setPosition(random(-10000, 20000), random(-22000, -15000))

        Asteroid():setPosition(random(12000, 40000), random(-25000, -18000))
        VisualAsteroid():setPosition(random(12000, 40000), random(-25000, -18000))

        Asteroid():setPosition(random(35000, 55000), random(-27000, -20000))
        VisualAsteroid():setPosition(random(35000, 55000), random(-27000, -20000))
    end

    -- Kraylor Endline ships protecting Eline until something happens
    kraylor_e1 = CpuShip():setFaction("Kraylor"):setTemplate("Phobos T3"):setPosition(80200, 39900):setCallSign("K-EC1"):orderStandGround()
    kraylor_e2 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setPosition(78200, 38000):setCallSign("K-EC2"):orderStandGround()
    kraylor_e3 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setPosition(78000, 37100):setCallSign("K-EF1"):orderStandGround()
    kraylor_e4 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setPosition(80200, 37900):setCallSign("K-EF2"):orderStandGround()

    -- Kraylor ships primed to attack Galileo
    kraylor_g1 = CpuShip():setFaction("Kraylor"):setTemplate("Phobos T3"):setScanned(true):setCallSign("K-Strike1"):setPosition(6273, -55399):orderIdle()
    kraylor_g2 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setScanned(true):setCallSign("K-Fi2"):setPosition(10922, -51749):orderIdle()
    kraylor_g3 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setScanned(true):setCallSign("K-Fi3"):setPosition(13948, -52838):orderIdle()

    -- Kraylor Midline ships protecting Mline
    kraylor_m1 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setCallSign("K-MF1"):setPosition(103710, 31493):orderStandGround()
    kraylor_m2 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setCallSign("K-MF2"):setPosition(97993, 22149):orderStandGround()
    kraylor_m3 = CpuShip():setFaction("Kraylor"):setTemplate("Atlantis X23"):setCallSign("K-MDFD"):setPosition(106363, 25218):orderStandGround()
    kraylor_m4 = CpuShip():setFaction("Kraylor"):setTemplate("Phobos T3"):setCallSign("K-MC001"):setPosition(104829, 21454):orderStandGround()

    -- Kraylor Nebula, that crazy maze with bad guys in it
    Nebula():setPosition(82515, 1149)
    Nebula():setPosition(88962, 3520)
    Nebula():setPosition(83108, -7966)
    Nebula():setPosition(94001, -4928)
    Nebula():setPosition(105264, -8633)
    Nebula():setPosition(85034, -16340)
    Nebula():setPosition(93704, -17970)
    Nebula():setPosition(106895, -18563)
    Nebula():setPosition(102523, -28715)
    Nebula():setPosition(111045, -27159)
    Nebula():setPosition(88591, -26566)
    Nebula():setPosition(83552, -35014)
    Nebula():setPosition(97594, -36092)
    Nebula():setPosition(84071, -44351)
    Nebula():setPosition(90666, -50798)
    Nebula():setPosition(98225, -52799)
    Nebula():setPosition(106598, -53095)
    Nebula():setPosition(113786, -48649)
    Nebula():setPosition(116158, -41164)
    Nebula():setPosition(118381, -32642)
    Mine():setPosition(92000, -5669)
    Mine():setPosition(104968, -7225)
    Mine():setPosition(84960, 1371)
    Mine():setPosition(81107, -4335)
    Mine():setPosition(85479, -9596)
    Mine():setPosition(85183, -17303)
    Mine():setPosition(93779, -17377)
    Mine():setPosition(91333, -25232)
    Mine():setPosition(86887, -23380)
    Mine():setPosition(83997, -29382)
    Mine():setPosition(86442, -34717)
    Mine():setPosition(80810, -35681)
    Mine():setPosition(104672, -13598)
    Mine():setPosition(109859, -18341)
    Mine():setPosition(106006, -20045)
    Mine():setPosition(108970, -25306)
    Mine():setPosition(113786, -25454)
    Mine():setPosition(115861, -31235)
    Mine():setPosition(102300, -29752)
    Mine():setPosition(99410, -31679)
    Mine():setPosition(96298, -33309)
    Mine():setPosition(99633, -36644)
    Mine():setPosition(96076, -38348)
    Mine():setPosition(118603, -38719)
    Mine():setPosition(115120, -41164)
    Mine():setPosition(119640, -32717)
    Mine():setPosition(116380, -47908)
    Mine():setPosition(111415, -50279)
    Mine():setPosition(107932, -54132)
    Mine():setPosition(98818, -51909)
    Mine():setPosition(91778, -48056)
    Mine():setPosition(91037, -52206)
    Mine():setPosition(85479, -47908)
    Mine():setPosition(86294, -43462)
    Mine():setPosition(82070, -40497)
    Mine():setPosition(96224, -3520)
    Mine():setPosition(101930, -6855)
    Mine():setPosition(107488, -9967)
    Mine():setPosition(105635, -27159)
    Mine():setPosition(113860, -29011)
    Mine():setPosition(116899, -35977)
    Mine():setPosition(85331, -26344)
    Mine():setPosition(107117, -1816)
    Mine():setPosition(96669, 852)
    Mine():setPosition(78661, -13598)
    Mine():setPosition(80292, -29752)
    Mine():setPosition(114231, -19304)
    Mine():setPosition(122605, -40794)
    Mine():setPosition(113194, -55392)
    Mine():setPosition(79402, -38867)
    Mine():setPosition(82218, -51242)
    Mine():setPosition(91704, -56874)
    Mine():setPosition(102374, -58356)
    CpuShip():setFaction("Kraylor"):setTemplate("Phobos T3"):setCallSign("K-SCN1"):setPosition(90940, -32988):orderDefendLocation(90940, -32988)
    CpuShip():setFaction("Kraylor"):setTemplate("Phobos T3"):setCallSign("K-SCN2"):setPosition(95243, -29693):orderDefendLocation(95243, -29693)
    CpuShip():setFaction("Kraylor"):setTemplate("Atlantis X23"):setCallSign("K-GDN1"):setPosition(105057, -46060):orderDefendLocation(105057, -46060)
    CpuShip():setFaction("Kraylor"):setTemplate("Atlantis X23"):setCallSign("K-GDN2"):setPosition(102474, -42231):orderDefendLocation(102474, -42231)
    CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setCallSign("K-EGF1"):setPosition(87826, -3182):orderDefendLocation(87826, -3182)
    Kraylor_hole = WormHole():setPosition(109190, -39762):setTargetPosition(-61730, 29490)

    -- Central Command sends us to investigate the issues with E.O.S. Scope.
    -- Expanded text to attempt to explain why Apollo is shuttling this data around physically
    Central_Command:sendCommsMessage(
        Player,
        _(
            [[Apollo, Come in.
Our Edge-of-space telescope has been experiencing malfunctions over the course of the past few days. We expect the cause to be a mechanical failure, but we want you to take a look.

The E.O.S Scope is right on the border of Kraylor space, so make sure to maintain contact and keep up long-range scans.

Dock with the E.O.S Scope and investigate the damage, then return to Central Command to report your findings. Transmission of this report via standard communications channels is considered too dangerous given the already delicate nature of our treaty with the Kraylor.

Reopen communications if you have any questions.]]
        )
    )

    Central_Command.mission_state = 1
    kraylor_threat = 0
    kraylor_warning = 0
    command_warning = 0
    inspection_init = 0
    inspection_progress = 0
    inspection_complete = 0
    tech_databanks = 0
    tech_stranded = 0
end

--- Update.
--
-- @param delta time delta in seconds
function update(delta)
    -- if you dead, you lose
    if not Player:isValid() then
        victory("Kraylor")
    end

    if not Central_Command:isValid() then
        victory("Kraylor")
    end

    if not EOS_Station:isValid() then
        victory("Kraylor")
    end

    if not Science_Galileo:isValid() then
        victory("Kraylor")
    end

    if Central_Command.mission_state == 1 then
        -- If K-Endline is destroyed at this stage Kraylor win
        if not Kraylor_Eline:isValid() then
            Central_Command:sendCommsMessage(Player, _([[Apollo, you've incited a war! What a disaster...]]))
            victory("Kraylor")
        end

        -- If the players get too close to K-Endline the station sends them a warning message
        if distance(Player, Kraylor_Eline) < 10000 and kraylor_warning == 0 then
            Kraylor_Eline:sendCommsMessage(Player, _([[A human Naval Cruiser encroaching on Kraylor space?

Be warned: if you venture near our Endline territory we will have no choice but to view your actions as hostile. Our indestructable fleet will make short work of you.]]))

            kraylor_warning = 1
        end

        -- When the players get within 40u of K-Endline they receive a message from Central Command telling them to be careful not to start a war.
        if distance(Player, Kraylor_Eline) < 40000 and command_warning == 0 then
            Central_Command:sendCommsMessage(Player, _([[Kraylor have their Endline station near our E.O.S Scope.

Do not confront them; we're not trying to start a war.]]))

            command_warning = 1
        end

        -- K-Endline warns the crew to behave themselves as the ship approaches EOS_Station (moved as I wanted to use docking event to trigger the Technical_Officer comms)
        if distance(Player, EOS_Station) < 5000 then
            if command_warning == 1 then
                if kraylor_threat == 0 then
                    Kraylor_Eline:sendCommsMessage(
                        Player,
                        _(
                            [[Attention Human Naval Vessel:

We have noted your expansion toward Kraylor Endline Territory. Know that even the slightest act of aggression will be met with a forceful purging of all Human ships and stations from our sector of space.

Do what maintanence you must while you are here, but know also that we consider your telescopic station to be a potential threat.]]
                        )
                    )

                    Central_Command.mission_state = 2
                    kraylor_threat = 1
                end
            end
        end
    end

    inspection_progress = inspection_progress + delta
    -- print(inspection_progress)  -- for Debugging

    -- When the Apollo is docked with EOS_Station a message is received from the Technical Officer advising that his team is beginning their inspection
    if Central_Command.mission_state == 2 then
        if Player:isDocked(EOS_Station) and inspection_init == 0 then
            globalMessage("Away Team in transit.")
            Technical_Officer:sendCommsMessage(Player, _([[We're beginning an inspection of the EOS Scope facility now.

This shouldn't take long.]]))
            inspection_init = 1 -- inspection has begun (Timer event is pretty fool-proof but better to have a flag preventing "Job Done" somehow triggering before inspection starts)
            inspection_progress = 0
        end
    end

    if Central_Command.mission_state == 2 then
        if Player:isDocked(EOS_Station) and inspection_init == 1 then
            if inspection_progress > 30 then
                if tech_databanks == 0 then
                    Technical_Officer:sendCommsMessage(Player, _([[It looks like the databanks are still in good working order.

We'll retrieve what we can.]]))
                    tech_databanks = 1
                end
            end
        end
    end

    -- Tech Officer complains about being left behind if the Apollo is not Docked since inspection began.
    if Central_Command.mission_state == 2 then
        if inspection_init == 1 then
            if inspection_complete == 0 then
                if inspection_progress > 50 then
                    if not Player:isDocked(EOS_Station) then
                        if tech_stranded == 0 then -- Without this the Technical Officer will always be harrassing the Apollo for pick-up once this event has triggered
                            Technical_Officer:sendCommsMessage(Player, _([[Is something wrong Apollo?

We're still in the facility.

Please dock so we can come aboard.]]))
                            tech_stranded = 1
                        end
                    end
                end
            end
        end
    end

    -- "Job Done" message to prompt the Captain to give the order to Undock and head back to Central Command after a pseudo-random time period.
    if Central_Command.mission_state == 2 then
        if Player:isDocked(EOS_Station) then -- If the ship is not docked, the Tech Officer will complain.
            if inspection_init == 1 and inspection_complete == 0 then
                if inspection_progress > 50 then
                    globalMessage("Away Team have returned.")
                    Technical_Officer:sendCommsMessage(
                        Player,
                        _([[Our inspection of the scope facility is complete. We were able to retrieve much of the data recorded over the past few days, though proper analysis will require an expert.

We should hurry back to Central Command with    this so they can begin work.]])
                    )

                    inspection_complete = 1 -- flag preventing continuous triggering of "Job Done" comms
                end
            end
        end
    end

    -- Report back to Central Command
    if Central_Command.mission_state == 2 then
        -- If K-Endline is destroyed at this stage Kraylor win
        if not Kraylor_Eline:isValid() then
            Central_Command:sendCommsMessage(Player, _([[Apollo, you've incited a war! What a disaster...]]))
            victory("Kraylor")
        end

        if Player:isDocked(Central_Command) then
            Central_Command:sendCommsMessage(
                Player,
                _(
                    [[It appears the damage was mechanical, but Kraylor ships in the area have been spotted in surveillance data you recovered from E.O.S Scope. It's possible this was sabotage.

Whatever the case, we need you to rendezvous with science station Galileo in sector C5. We've contracted with this Arlenian station to interperet and analyze the data retrieved from our various Scope stations.]]
                )
            )

            Central_Command.mission_state = 3
        end
    end

    -- Get up to Galileo station
    if Central_Command.mission_state == 3 then
        -- If K-Endline is destroyed at this stage Kraylor win
        if not Kraylor_Eline:isValid() then
            Central_Command:sendCommsMessage(Player, _([[Apollo, you've incited a war! What a disaster...]]))
            victory("Kraylor")
        end

        if distance(Player, Science_Galileo) < 30000 then
            Science_Galileo:sendCommsMessage(Player, _([[Distress Signal incoming from Galileo station:

Kraylor ships are in our vicinity, we have reason to believe they intend to attack us! Please, you are the only battle-ready ship near our sector. Assist us!]]))

            kraylor_g1:orderRoaming()
            kraylor_g2:orderRoaming()
            kraylor_g3:orderRoaming()

            Central_Command.mission_state = 4
        end
    end

    -- Save the Galileo station from the Kraylor ships!
    if Central_Command.mission_state == 4 then
        -- If K-Endline is destroyed at this stage Kraylor win
        if not Kraylor_Eline:isValid() then
            Central_Command:sendCommsMessage(Player, _([[Apollo, you've incited a war! What a disaster...]]))
            victory("Kraylor")
        end

        if not kraylor_g1:isValid() and not kraylor_g2:isValid() and not kraylor_g3:isValid() then
            Science_Galileo:sendCommsMessage(
                Player,
                _(
                    [[We don't know why Kraylor ships were attacking us. We had just recieved word that your ship was on its way with data from the Edge-of-space telescopic station when they began interrupting transmissions.

Thank you for defending our station. Please    dock with us and we'll be able to analyze the data from E.O.S Scope.]]
                )
            )

            Central_Command.mission_state = 5
        end
    end

    -- Dock with Galileo station
    if Central_Command.mission_state == 5 then
        if Player:isDocked(Science_Galileo) then
            Central_Command:sendCommsMessage(
                Player,
                _([[Apollo, come in!

Leave the E.O.S data with Galileo for now, we've confirmed reports that Kraylor are brazen enough to attack our E.O.S Scope directly! All available ships should converge on E.O.S territory in sector H8!

That means you, Apollo!]])
            )

            kraylor_e1:orderRoaming()
            kraylor_e2:orderRoaming()
            kraylor_e3:orderRoaming()
            kraylor_e4:orderRoaming()

            Human_m1:orderDefendLocation(60500, 42100)
            Human_m2:orderDefendLocation(60500, 42100)
            Human_m3:orderDefendLocation(60500, 42100)

            Central_Command.mission_state = 6
        end
    end

    -- Save the E.O.S Station from Kraylor scum! K-Endline is a valid target at last!
    if Central_Command.mission_state == 6 then
        if not kraylor_e1:isValid() and not kraylor_e2:isValid() and not kraylor_e3:isValid() and not kraylor_e4:isValid() then
            if Kraylor_Eline:isValid() then
                -- HM1 gives you the exciting news that K-Endline is a valid target at last!
                if Human_m1:isValid() then
                    Human_m1:sendCommsMessage(Player, _([[Apollo, HM1 here.

Central Command has no choice but to declare war. We're moving into Kraylor territory for our retaliation strike. Attack the Kraylor Endline station!]]))

                    kraylor_m1:orderRoaming()
                    kraylor_m2:orderRoaming()
                    kraylor_m3:orderRoaming()
                    kraylor_m4:orderRoaming()

                    Human_m1:orderFlyTowards(79200, 38800)
                    Human_m2:orderFlyTowards(79200, 38800)
                    Human_m3:orderFlyTowards(79200, 38800)

                    Central_Command.mission_state = 7
                end

                -- If HM1 died then Central Command gives the order to destroy K-Endline
                if not Human_m1:isValid() then
                    Central_Command:sendCommsMessage(Player, _([[Apollo, come in.

We have no choice but to declare war. Move into Kraylor territory and retaliate on their defenseless Endline station!]]))

                    kraylor_m1:orderRoaming()
                    kraylor_m2:orderRoaming()
                    kraylor_m3:orderRoaming()
                    kraylor_m4:orderRoaming()

                    Human_m1:orderFlyTowards(79200, 38800)
                    Human_m2:orderFlyTowards(79200, 38800)
                    Human_m3:orderFlyTowards(79200, 38800)

                    Central_Command.mission_state = 7
                end
            end

            -- Time for some sweet upgrades!
            if not Kraylor_Eline:isValid() then
                if not kraylor_m1:isValid() and not kraylor_m2:isValid() and not kraylor_m3:isValid() and not kraylor_m4:isValid() then
                    Central_Command:sendCommsMessage(
                        Player,
                        _(
                            [[Apollo, come in.

Our cease-fire with the Kraylor is at a bitter end, and aggression will only rise from here. It is imperative that our ships be equipped with all counter-measures necessary to keep them safe.

Dock with the E.O.S Scope. We are re-fitting your ship in preparation for times of war.]]
                        )
                    )

                    Human_m1:orderDefendLocation(31875, 38653)
                    Human_m2:orderDefendLocation(37493, 37185)
                    Human_m3:orderDefendLocation(35519, 42854)

                    Central_Command.mission_state = 9
                end

                -- Kraylor scum talk a big game considering they just lost K-Endline
                if kraylor_m1:isValid() or kraylor_m2:isValid() or kraylor_m3:isValid() or kraylor_m4:isValid() then
                    if Kraylor_Mline:isValid() then
                        Kraylor_Mline:sendCommsMessage(Player, _([[Broadcast on all Human Naval frequencies:

Human scum, we warned you to stay out of Kraylor territory!]]))

                        kraylor_m1:orderRoaming()
                        kraylor_m2:orderRoaming()
                        kraylor_m3:orderRoaming()
                        kraylor_m4:orderRoaming()

                        Human_m1:orderRoaming()
                        Human_m2:orderRoaming()
                        Human_m3:orderRoaming()

                        Central_Command.mission_state = 8
                    end

                    if not Kraylor_Mline:isValid() then
                        Central_Command:sendCommsMessage(Player, _([[Apollo, come in.

Our cease-fire with the Kraylor is at a bitter end. Destroy the remaining Kraylor ships threatening our E.O.S territory!]]))

                        kraylor_m1:orderRoaming()
                        kraylor_m2:orderRoaming()
                        kraylor_m3:orderRoaming()
                        kraylor_m4:orderRoaming()

                        Human_m1:orderRoaming()
                        Human_m2:orderRoaming()
                        Human_m3:orderRoaming()

                        Central_Command.mission_state = 8
                    end
                end
            end
        end
    end

    -- Time for some sweet upgrades!
    -- Retaliate on the Kraylor Endline station!
    if Central_Command.mission_state == 7 then
        if not Kraylor_Eline:isValid() then
            if not kraylor_m1:isValid() and not kraylor_m2:isValid() and not kraylor_m3:isValid() and not kraylor_m4:isValid() then
                Central_Command:sendCommsMessage(
                    Player,
                    _(
                        [[Apollo, come in.

Our cease-fire with the Kraylor is at a bitter end, and aggression will only rise from here. It is imperative that our ships be equipped with all counter-measures necessary to keep them safe.

Dock with the E.O.S Scope. We are re-fitting your ship in preparation for times of war.]]
                    )
                )

                Human_m1:orderDefendLocation(31875, 38653)
                Human_m2:orderDefendLocation(37493, 37185)
                Human_m3:orderDefendLocation(35519, 42854)

                Central_Command.mission_state = 9
            end

            if kraylor_m1:isValid() or kraylor_m2:isValid() or kraylor_m3:isValid() or kraylor_m4:isValid() then
                if Kraylor_Mline:isValid() then
                    Kraylor_Mline:sendCommsMessage(Player, _([[Broadcast on all Human Naval frequencies:

Human scum, we warned you to stay out of Kraylor territory!]]))

                    kraylor_m1:orderRoaming()
                    kraylor_m2:orderRoaming()
                    kraylor_m3:orderRoaming()
                    kraylor_m4:orderRoaming()

                    Human_m1:orderRoaming()
                    Human_m2:orderRoaming()
                    Human_m3:orderRoaming()

                    Central_Command.mission_state = 8
                end

                if not Kraylor_Mline:isValid() then
                    Central_Command:sendCommsMessage(Player, _([[Apollo, come in.

Our cease-fire with the Kraylor is at a bitter end. Destroy the remaining Kraylor ships threatening our E.O.S territory!]]))

                    kraylor_m1:orderRoaming()
                    kraylor_m2:orderRoaming()
                    kraylor_m3:orderRoaming()
                    kraylor_m4:orderRoaming()

                    Human_m1:orderRoaming()
                    Human_m2:orderRoaming()
                    Human_m3:orderRoaming()

                    Central_Command.mission_state = 8
                end
            end
        end
    end

    -- Destroy the remaining Kraylor ships!
    if Central_Command.mission_state == 8 then
        -- if kraylor_m3:isValid() and not kraylor_m1:isValid() and not kraylor_m2:isValid() and not kraylor_m4:isValid() then
        --    kraylor_m3:orderRoaming()
        -- end

        -- Time for some sweet upgrades!
        if not kraylor_m1:isValid() and not kraylor_m2:isValid() and not kraylor_m3:isValid() and not kraylor_m4:isValid() then
            Central_Command:sendCommsMessage(
                Player,
                _([[Apollo, come in.

Kraylor aggression will only rise from here. It is imperative that our ships be equipped with all counter-measures necessary to keep them safe.

Dock with the E.O.S Scope. We are re-fitting your ship in preparation for times of war.]])
            )

            Human_m1:orderDefendLocation(31875, 38653)
            Human_m2:orderDefendLocation(37493, 37185)
            Human_m3:orderDefendLocation(35519, 42854)

            Central_Command.mission_state = 9
        end
    end

    -- Dock at E.O.S to get re-fitted with weapons
    if Central_Command.mission_state == 9 then
        if Player:isDocked(EOS_Station) then
            -- Reconfigure the player ship into a Wartime Technician, which has more weapon capabilities then the Technical cruiser.
            Player:setTypeName("Wartime Technician")
            --                    # Arc, Dir, Range, CycleTime, Dmg
            Player:setBeamWeapon(0, 100, -20, 1000.0, 6.0, 10)
            Player:setBeamWeapon(1, 100, 20, 1000.0, 6.0, 10)
            Player:setBeamWeapon(2, 90, 180, 1000.0, 6.0, 10)
            Player:setWeaponTubeCount(3)
            Player:setWeaponTubeDirection(0, 0):weaponTubeDisallowMissle(0, "Mine")
            Player:setWeaponTubeDirection(1, 0):weaponTubeDisallowMissle(1, "Mine")
            Player:setWeaponTubeDirection(2, 180)
            Player:setWeaponTubeExclusiveFor(2, "Mine")
            Player:setWeaponStorageMax("Homing", 12)
            Player:setWeaponStorageMax("Nuke", 4)
            Player:setWeaponStorageMax("Mine", 8)
            Player:setWeaponStorageMax("EMP", 6)
            Player:setWeaponStorage("Homing", 12)
            Player:setWeaponStorage("Nuke", 4)
            Player:setWeaponStorage("Mine", 8)
            Player:setWeaponStorage("EMP", 6)

            Central_Command:sendCommsMessage(
                Player,
                _(
                    [[Science station Galileo has returned with their analysis of the E.O.S Scope data.

Edge-of-space sensors picked up on sparse signals from the super-nebula in Kraylor space that indicate they have some kind of wormhole. Intelligence suggests they intend to use it to infiltrate Human space and attack us where we are defenseless!

When your ship is finished being outfitted for war move up to the nebula, but be cautious. There may be traps.]]
                )
            )

            Central_Command.mission_state = 10
        end
    end

    -- Get to the wormhole!
    if Central_Command.mission_state == 10 then
        if distance(Player, Kraylor_hole) < 10000 then
            Central_Command:sendCommsMessage(
                Player,
                _([[Apollo come in!

Reports are coming in from core Human space that a massive Kraylor strike force is attacking! Get through that wormhole and attack from within their ranks to hold them off. We'll send all our available ships to converge there.]])
            )

            -- Let's get crazy up in here
            k01 = CpuShip():setFaction("Kraylor"):setTemplate("Phobos T3"):setCallSign("BR21"):setPosition(-50654, 32238):orderRoaming()
            k02 = CpuShip():setFaction("Kraylor"):setTemplate("Phobos T3"):setCallSign("UT64"):setPosition(-48368, 27476):orderRoaming()
            k03 = CpuShip():setFaction("Kraylor"):setTemplate("Phobos T3"):setCallSign("NC13"):setPosition(-34082, 40047):orderRoaming()
            k04 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setCallSign("CV45"):setPosition(-59606, 18904):orderRoaming()
            k05 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setCallSign("TI25"):setPosition(-43796, 43857):orderRoaming()
            k06 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setCallSign("IN16"):setPosition(-43796, 52428):orderRoaming()
            k07 = CpuShip():setFaction("Kraylor"):setTemplate("Piranha F12"):setCallSign("VA27"):setPosition(-58082, 31285):orderRoaming()
            k08 = CpuShip():setFaction("Kraylor"):setTemplate("Piranha F12"):setCallSign("CN78"):setPosition(-26082, 22333):orderRoaming()
            k09 = CpuShip():setFaction("Kraylor"):setTemplate("Atlantis X23"):setCallSign("AL92"):setPosition(-42273, 12238):orderRoaming()
            k10 = CpuShip():setFaction("Kraylor"):setTemplate("Starhammer II"):setCallSign("OH30"):setPosition(-26844, 48809):orderRoaming()
            k11 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setCallSign("SS11"):setPosition(-45320, 9381):orderRoaming()
            k12 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setCallSign("CS61"):setPosition(-40558, 8809):orderRoaming()
            k13 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setCallSign("JL33"):setPosition(-27796, 52428):orderRoaming()
            k14 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setCallSign("SQ50"):setPosition(-24368, 46143):orderRoaming()
            CpuShip():setFaction("Human Navy"):setScanned(true):setTemplate("MT52 Hornet"):setCallSign("BN53"):setPosition(-40654, 47095):orderRoaming()
            CpuShip():setFaction("Human Navy"):setScanned(true):setTemplate("MT52 Hornet"):setCallSign("VK68"):setPosition(-37796, 56619):orderRoaming()
            CpuShip():setFaction("Human Navy"):setScanned(true):setTemplate("MT52 Hornet"):setCallSign("XD37"):setPosition(-29987, 55476):orderRoaming()
            CpuShip():setFaction("Human Navy"):setScanned(true):setTemplate("MT52 Hornet"):setCallSign("CC31"):setPosition(-45796, 26143):orderRoaming()
            CpuShip():setFaction("Human Navy"):setScanned(true):setTemplate("MT52 Hornet"):setCallSign("CM29"):setPosition(-51892, 24047):orderRoaming()
            CpuShip():setFaction("Human Navy"):setScanned(true):setTemplate("MT52 Hornet"):setCallSign("SO40"):setPosition(-2939, 40619):orderRoaming()
            CpuShip():setFaction("Human Navy"):setScanned(true):setTemplate("MT52 Hornet"):setCallSign("VS41"):setPosition(2966, 45000):orderRoaming()
            -- CpuShip():setFaction("Human Navy"):setScanned(true):setTemplate("MT52 Hornet"):setCallSign("BR42"):setPosition(-12796, 16809):orderRoaming()
            -- CpuShip():setFaction("Human Navy"):setScanned(true):setTemplate("MT52 Hornet"):setCallSign("UTI43"):setPosition(-10463, 7476):orderRoaming()
            CpuShip():setFaction("Human Navy"):setScanned(true):setTemplate("Phobos T3"):setCallSign("CI44"):setPosition(-10368, 13571):orderRoaming()
            CpuShip():setFaction("Human Navy"):setScanned(true):setTemplate("Phobos T3"):setCallSign("NI15"):setPosition(-10368, 50143):orderRoaming()

            Human_m1:orderRoaming()
            Human_m2:orderRoaming()
            Human_m3:orderRoaming()

            Central_Command.mission_state = 11
        end
    end

    if Central_Command.mission_state == 11 then
        if
            not k01:isValid() and not k02:isValid() and not k03:isValid() and not k04:isValid() and not k05:isValid() and not k06:isValid() and not k07:isValid() and not k08:isValid() and not k09:isValid() and not k10:isValid() and not k11:isValid() and not k12:isValid() and not k13:isValid() and
                not k14:isValid()
         then
            victory("Human Navy")
        end
    end
end

--- Return distance of two objects.
function distance(obj1, obj2)
    x1, y1 = obj1:getPosition()
    x2, y2 = obj2:getPosition()
    xd, yd = (x1 - x2), (y1 - y2)
    return math.sqrt(xd * xd + yd * yd)
end
