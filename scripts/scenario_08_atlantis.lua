-- Name: Birth of the Atlantis
-- Description: You are the first crew of a new and improved version of the Atlantis space explorer.
--- You must check out ship systems and complete an initial mission.
-- Type: Mission

--[[Problems
no rep at start....
Unclear who to contact for first mission
jump ship under attack after first jump
not clear that you need to escape
warp scramblers not visible
nebula in kraylor defense line makes it unclear
jump jammers not always blocking jump?
--]]

require("utils.lua")

--[[
Rundown of the mission:
==Phase 1: Test ship systems.
* Ship starts docked to the station, with 0 power in all systems.
* Engineering has to power up all systems to 100%.
* After that, undocking is possible.
* After undocking, flying to the supply package to pick up missiles.
* Then test the jump drive to jump towards the weapons testing area.
* At the weapons testing area, science needs to scan two dummy ships before they can be destroyed.
* Destroy the two dummy ships, one can only be destroyed with missile weapons.
* Have relay open communications to the station for the next objective.
==Phase 2: Discovery
* You first mission will be to investigate a strange signal from a nebula.
* As the nebula is in the outer space regions, you'll have you use a jump carrier.
* The jump carrier delivers you to the edge of a nebulea cloud. There are a few kraylor ships here for you to fight.
* The objective is to find an artifact within the nebulea, and scan it. This is a tough scan (level 3)
* In these nebulea, you can also encounter ghost ships. Which are just lost single ships. As well as two "dud" artifacts that are not the source of the signal.
* When you scan the proper artifact, it gives you 4 readings in the description. Relay needs to pass these readings to the JC-88 or Shipyard before the mission continues.
* When this is done, the artifact becomes unstable, and becomes a wormhole that sucks in the player.
==Phase 3: Lost in enemy space...
* After the wormhole, the player finds himself in Kraylor space.
* There are warp jammers blocking you from jumping away. And these jammers are well defended. You'll need to navigate or fight you way out of this.
* I highly recommend navigating. Really. There is some code in place that makes all enemies attack if you engage the jammers.
* JC88 will be waiting for you outside of the defense line. He will take you back to the shipyard.
* At the shipyard you will hand in your data, and get your new objective.
==Phase 4: Nice transport you have there, would be bad if something would happen to it...
* At this point a transport will be created and flying around the forwards stations of the Kraylor defense line.
* Your task is to destroy this transport and secure it's cargo.
* Engaging it at one of the stations will call the whole Kraylor fleet on your ass. So engage the transport between stations.
* Attacking it between stations will still call a taskforce on your ass, so you need to make haste to secure the cargo and get out of there.
==Phase 5:...
--]]

-- Init is run when the scenario is started. Create your initial world
function init()
    -- Create the main ship for the players.
    player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis")
    allowNewPlayerShips(false)
	player:setPosition(25276, 133850):setCallSign("Atlantis-1"):setRotation(-90):commandTargetRotation(-90)
    for _, system in ipairs({"reactor", "beamweapons", "missilesystem", "maneuver", "impulse", "warp", "jumpdrive", "frontshield", "rearshield"}) do
        player:setSystemPower(system, 0.0)
        player:commandSetSystemPowerRequest(system, 0.0)
    end
    player:setWeaponStorage("Homing", 0)
    player:setWeaponStorage("Nuke", 0)
    player:setWeaponStorage("EMP", 0)
    player:setWeaponStorage("Mine", 0)
    player:setWeaponStorage("HVLI", 0)

    --Starting area
    shipyard_gamma = SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCallSign("Shipyard-Gamma"):setPosition(25276, 134550)
    shipyard_gamma:setCommsFunction(shipyardGammaComms)
    player:commandDock(shipyard_gamma)
	player:addReputationPoints(5)	--initial reputation
    supply_station_6 = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCallSign("Supply-6"):setPosition(14491, 126412)
    supply_station_6.comms_data = { --Do not allow supply drops or reinforcements from the supply station.
        services = {
            supplydrop = "none",
            reinforcements = "none",
        }
    }
    Nebula():setPosition(32953, 146374)
    Nebula():setPosition(4211, 129108)
    createObjectsOnLine(37351, 125310, 39870, 137224, 1000, Mine, 2, 90)
    CpuShip():setFaction("Human Navy"):setTemplate("Phobos T3"):setCallSign("D-2"):setScanned(true):setPosition(12419, 124184):orderDefendTarget(supply_station_6):setCommsScript("")
    CpuShip():setFaction("Human Navy"):setTemplate("Phobos T3"):setCallSign("D-3"):setScanned(true):setPosition(16104, 127943):orderDefendTarget(supply_station_6):setCommsScript("")

    createObjectsOnLine(6333, 135054, 12390, 148498, 700, Asteroid, 5, 100, 2000)
    createObjectsOnLine(12390, 148498, 27607, 149902, 700, Asteroid, 5, 100, 2000)
    createObjectsOnLine(6333, 135054, 12390, 148498, 700, VisualAsteroid, 5, 100, 2000)
    createObjectsOnLine(12390, 148498, 27607, 149902, 700, VisualAsteroid, 5, 100, 2000)

    Nebula():setPosition(13314, 108306)
    Nebula():setPosition(30851, 94744)
    Nebula():setPosition(37574, 112457)
    transport_f1 = CpuShip():setFaction("Human Navy"):setTemplate("Flavia"):setCallSign("F-1"):setScanned(true):setPosition(28521, 114945):orderIdle()
    transport_f1:setCommsScript("")

    target_dummy_1 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setCallSign("Dummy-1"):setPosition(29269, 109499):orderIdle():setRotation(random(0, 360))
    target_dummy_2 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setCallSign("Dummy-2"):setPosition(31032, 109822):orderIdle():setRotation(random(0, 360))
    target_dummy_1:setHullMax(1):setHull(1):setShieldsMax(300):setScanningParameters(1, 1):setCommsScript("")
    target_dummy_2:setHullMax(1):setHull(1):setShieldsMax(300):setScanningParameters(1, 1):setCommsScript("")

    jc88 = CpuShip():setFaction("Human Navy"):setTemplate("Jump Carrier"):setCallSign("JC-88"):setScanned(true):setPosition(18972, 135882):orderIdle()
    jc88:setCommsFunction(jc88Comms)

    --Sector B20
    CpuShip():setFaction("Kraylor"):setTemplate("WX-Lindworm"):setCallSign("S11"):setPosition(304666, -75558):orderDefendLocation(304666, -75558):setWeaponStorage("Homing", 0):setWeaponStorage("HVLI", 4)
    CpuShip():setFaction("Kraylor"):setTemplate("MU52 Hornet"):setCallSign("S10"):setPosition(306010, -74718):orderDefendLocation(306010, -74718)
    CpuShip():setFaction("Kraylor"):setTemplate("Adder MK5"):setCallSign("CCN8"):setPosition(304364, -74222):orderDefendLocation(304364, -74222):setWeaponStorage("HVLI", 3)
    b20_nebula_list = {}
    table.insert(b20_nebula_list, Nebula():setPosition(319259, -78069))
    table.insert(b20_nebula_list, Nebula():setPosition(321469, -70621))
    table.insert(b20_nebula_list, Nebula():setPosition(324743, -62928))
    table.insert(b20_nebula_list, Nebula():setPosition(335382, -61946))
    table.insert(b20_nebula_list, Nebula():setPosition(334809, -72258))
    table.insert(b20_nebula_list, Nebula():setPosition(325643, -88627))
    table.insert(b20_nebula_list, Nebula():setPosition(328671, -79788))
    table.insert(b20_nebula_list, Nebula():setPosition(315655, -85367))
    
    nebula = table.remove(b20_nebula_list, math.random(#b20_nebula_list))
    x, y = nebula:getPosition()
    b20_artifact = Artifact():setPosition(x + random(-1000, 1000), y + random(-1000, 1000))
    b20_artifact:setScanningParameters(3, 1)
    b20_artifact.nebula = nebula
    b20_artifact.beta_radiation = irandom(1, 10)
    b20_artifact.gravity_disruption = irandom(1, 10)
    b20_artifact.ionic_phase_shift = irandom(1, 10)
    b20_artifact.doppler_instability = irandom(1, 10)
    b20_artifact:setDescriptions("An odd object floating in space.", string.format([[Found it, this object is giving off strange readings.
Sensor readings:
Beta radiation: %i
Gravity disruption: %i
Ionic phase shift: %i
Doppler instability: %i]], b20_artifact.beta_radiation, b20_artifact.gravity_disruption, b20_artifact.ionic_phase_shift, b20_artifact.doppler_instability))

    x, y = table.remove(b20_nebula_list, math.random(#b20_nebula_list)):getPosition()
    b20_dummy_artifact_1 = Artifact():setPosition(x + random(-1000, 1000), y + random(-1000, 1000)):setDescriptions("An odd object floating in space.", "This object seems to be inert, and not giving any readings on your sensors. The actual object must be somewhere else.")
    b20_dummy_artifact_1:setScanningParameters(3, 1)

    x, y = table.remove(b20_nebula_list, math.random(#b20_nebula_list)):getPosition()
    b20_dummy_artifact_2 = Artifact():setPosition(x + random(-1000, 1000), y + random(-1000, 1000)):setDescriptions("An odd object floating in space.", "This object seems to be inert, and not giving any readings on your sensors. The actual object must be somewhere else.")
    b20_dummy_artifact_2:setScanningParameters(3, 1)

    x, y = table.remove(b20_nebula_list, math.random(#b20_nebula_list)):getPosition()
    CpuShip():setFaction("Ghosts"):setPosition(x + random(-1000, 1000), y + random(-1000, 1000)):setTemplate("Phobos T3"):orderDefendLocation(x, y)

    x, y = table.remove(b20_nebula_list, math.random(#b20_nebula_list)):getPosition()
    CpuShip():setFaction("Ghosts"):setPosition(x + random(-1000, 1000), y + random(-1000, 1000)):setTemplate("Piranha F12"):orderDefendLocation(x, y)

    x, y = table.remove(b20_nebula_list, math.random(#b20_nebula_list)):getPosition()
    CpuShip():setFaction("Ghosts"):setPosition(x + random(-1000, 1000), y + random(-1000, 1000)):setTemplate("Starhammer II"):orderDefendLocation(x, y)
    
    --kraylor defense line.
    kraylor_defense_line = {
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(7657, -264940),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(9915, -289620),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(1822, -287037),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(-6615, -285401),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(-18324, -283593),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(-24522, -276878),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(-28138, -268613),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(-23403, -256302),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(-11608, -254149),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(46849, -260262),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(35571, -254924),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(22312, -254063),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(10842, -255239),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(65015, -272745),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(60452, -263189),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(56664, -280494),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(48829, -284454),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(22915, -287381),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(36690, -287554),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(-34202, -259093),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(29547, -294816),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(54372, -255958)
    }
    kraylor_defense_line_ships = {}
    kraylor_defense_line_engaged = false
    for _, warp_jammer in ipairs(kraylor_defense_line) do
        x, y = warp_jammer:getPosition()
        ship = CpuShip():setFaction("Kraylor"):setPosition(x + random(-1000, 1000), y + random(-1000, 1000)):orderDefendLocation(x, y)
        if random(0, 100) < 20 then
            ship:setTemplate("Defense platform")
        elseif random(0, 100) < 50 then
            ship:setTemplate("Atlantis X23")
        else
            ship:setTemplate("Starhammer II")
        end
        table.insert(kraylor_defense_line_ships, ship)
        for n=1,3 do
            ship2 = CpuShip():setFaction("Kraylor"):setPosition(x + random(-1000, 1000), y + random(-1000, 1000)):orderDefendTarget(ship)
            if random(0, 100) < 50 then
                ship2:setTemplate("Phobos T3")
            elseif random(0, 100) < 20 then
                ship2:setTemplate("Piranha F12.M")
            else
                ship2:setTemplate("Piranha F12")
            end
            table.insert(kraylor_defense_line_ships, ship2)
        end
    end

    SpaceStation():setTemplate("Huge Station"):setFaction("Kraylor"):setPosition(32099, -291152)
    SpaceStation():setTemplate("Huge Station"):setFaction("Kraylor"):setPosition(-4252, -297462)
    SpaceStation():setTemplate("Huge Station"):setFaction("Kraylor"):setPosition(-27984, -262071)

    kraylor_forward_line = {
        SpaceStation():setTemplate("Small Station"):setFaction("Kraylor"):setPosition(-7278, -197898),
        SpaceStation():setTemplate("Large Station"):setFaction("Kraylor"):setPosition(-13839, -233328),
        SpaceStation():setTemplate("Large Station"):setFaction("Kraylor"):setPosition(29333, -240151),
        SpaceStation():setTemplate("Small Station"):setFaction("Kraylor"):setPosition(36681, -200260)
    }
    kraylor_transport = nil
    for _, station in ipairs(kraylor_forward_line) do
        x, y = station:getPosition()
        ship = CpuShip():setFaction("Kraylor"):setPosition(x + random(-1000, 1000), y + random(-1000, 1000)):orderDefendLocation(x, y)
        if random(0, 100) < 20 then
            ship:setTemplate("Defense platform")
        elseif random(0, 100) < 50 then
            ship:setTemplate("Atlantis X23")
        else
            ship:setTemplate("Starhammer II")
        end
        table.insert(kraylor_defense_line_ships, ship)
        for n=1,3 do
            ship2 = CpuShip():setFaction("Kraylor"):setPosition(x + random(-1000, 1000), y + random(-1000, 1000)):orderDefendTarget(ship)
            if random(0, 100) < 50 then
                ship2:setTemplate("Phobos T3")
            elseif random(0, 100) < 20 then
                ship2:setTemplate("Piranha F12.M")
            else
                ship2:setTemplate("Piranha F12")
            end
            table.insert(kraylor_defense_line_ships, ship2)
        end
    end
    
    Nebula():setPosition(-21914, -272098)
    Nebula():setPosition(44037, -290617)
    Nebula():setPosition(28814, -261708)
    Nebula():setPosition(-13477, -290103)
    Nebula():setPosition(4322, -257282)
    createObjectsOnLine(48975, -270452, 40024, -267982, 1000, Mine, 3, 90)
    createObjectsOnLine(20887, -271892, 22225, -282695, 1000, Mine, 3, 90)
    createObjectsOnLine(-12037, -278682, 55663, -258414, 1000, Asteroid, 4, 90, 10000)

    --Set the initial mission state
    mission_state = phase1MessagePowerup
    
    defeat_timeout = 2.0 --The defeat timeout means it takes 2 seconds before a defeat is actually done. This gives some missiles and explosions time to impact.
    
    --[[TEMP
    mission_state = phase2SeekArtifact
    player:setPosition(310000, -71000)
    for _, system in ipairs({"reactor", "beamweapons", "missilesystem", "maneuver", "impulse", "warp", "jumpdrive", "frontshield", "rearshield"}) do
        player:setSystemPower(system, 1.0)
        player:commandSetSystemPowerRequest(system, 1.0)
    end
    
    --TEMP
    mission_state = phase2WaitTillWormholeWarpedPlayer
    player:setPosition(30036, -270545)
    
    --TEMP
    mission_state = phase3ReportBackToShipyard
    player:setPosition(24000, 125000)
    --]]
end

function phase1MessagePowerup(delta)
    if delta > 0 then
        shipyard_gamma:sendCommsMessage(player, [[Come in Atlantis-1.
Good, your communication systems seems to be working.
As you well know, you are aboard the newest version of the Atlantis space explorer.
We will take you through a few quick tests to see if the ship is operating as expected.

First, have your engineer power up all systems to 100%, as you are currently in powered down mode.]])
        mission_state = phase1WaitForPowerup
    end
end

function phase1WaitForPowerup(delta)
    for _, system in ipairs({"reactor", "beamweapons", "missilesystem", "maneuver", "impulse", "frontshield", "rearshield"}) do
        if player:getSystemPower(system) < 1.0 then
            return
        end
    end
    --All system powered, give the next objective.
    shipyard_gamma:sendCommsMessage(player, [[Atlantis-1,
Good, we read all systems are go. You can safely undock now.
Head to sector K6, there is a supply drop there dropped by F-1. Pick this up to stock up on missile weapons.]])
    supply_drop = SupplyDrop():setFaction("Human Navy"):setPosition(29021, 114945):setEnergy(500):setWeaponStorage("Homing", 12):setWeaponStorage("Nuke", 4):setWeaponStorage("Mine", 8):setWeaponStorage("EMP", 6):setWeaponStorage("HVLI", 20)
    transport_f1:orderDock(supply_station_6)
	player:addReputationPoints(5)
    mission_state = phase1WaitForSupplyPickup
end

function phase1WaitForSupplyPickup(delta)
    --Keep the shields of the dummies charged.
    target_dummy_1:setShields(300)
    target_dummy_2:setShields(300)

    if not supply_drop:isValid() then
        shipyard_gamma:sendCommsMessage(player, [[Atlantis-1,
Ok, good. I see you are stocked up on missiles now.
There are two dummy ships in your near vicinity. Now, before we test your weapon systems, first we better ID the ships to make sure we do not destroy the wrong ships.
Have your science officer scan the Dummy-1 and Dummy-2 ships to properly identify them.]])
        mission_state = phase1ScanDummyShips
		player:addReputationPoints(5)
    end
end

function phase1ScanDummyShips(delta)
    --Keep the shields of the dummies charged. (Note, at this point, you could destroy them with nukes, which is why we keep the shields at 300)
    target_dummy_1:setShields(300)
    target_dummy_2:setShields(300)

    if target_dummy_1:isScannedBy(player) and target_dummy_2:isScannedBy(player) then
        shipyard_gamma:sendCommsMessage(player, [[Atlantis-1,
Perfect. They identify as Kraylor ships, as we put fake IDs in them. Now, take out Dummy-1 with your beam weapons. Use a homing missile to take out Dummy-2,
as the shields of Dummy-2 are configured so that your beam weapons will not penetrate them.]])
        mission_state = phase1DestroyDummyShips
        target_dummy_1:setShieldsMax(30)
        target_dummy_2:setShieldsMax(30)
		player:addReputationPoints(5)
    end
end

function phase1DestroyDummyShips(delta)
    if target_dummy_2:isValid() then
        --Keep the shield of Dummy-2 charged to 30, which means it can be taken out with a single blast from a homing missile or nuke, but not by beam weapons.
        target_dummy_2:setShields(30)
    end
    
    if not target_dummy_1:isValid() and not target_dummy_2:isValid() then
        shipyard_gamma:sendCommsMessage(player, [[Good, all weapons are operational.
Your ship seems to be in perfect operating condition.

Now, when you are ready to take on your first mission. Contact us.
(Feel free to dock with Supply-6 to resupply)]])
        mission_state = phase1WaitForContact
		player:addReputationPoints(5)
    end
end

function phase1WaitForContact(delta)
    --Wait for the shipyardGammaComms to handle this state.
end

--[[*********************************************************************--]]

function phase2WaitForJump(delta)
    if handleJumpCarrier(jc88, 24000, 125000, 310000, -71000, [[Hold on tight, heading for sector B20.]]) then
        --Good, continue.
        jc88:sendCommsMessage(player, [[Atlantis-1,
Here we are. B20. Looks like there are some lingering Kraylors here.
As we are outside of the no-fire zone, and we are at war with the Kraylor, you are free to take them out.

Report back when you have found the source of the odd sensor readings.]])
        mission_state = phase2SeekArtifact
    end
end

function phase2SeekArtifact(delta)
    if b20_artifact:isScannedBy(player) then
        mission_state = phase2ReportArtifactReadings
		player:addReputationPoints(5)
    end
end

function phase2ReportArtifactReadings(delta)
    --Readings will be reported in comms functions, so do nothing here.
end

function phase2WaitTillNearObject(delta)
    if distance(player, b20_artifact) < 2000 then
        phase2SpawnWormhole()
    end
end

function phase2WaitTillAwayFromObject(delta)
    if distance(player, b20_artifact) > 2000 and distance(player, b20_artifact) < 2200 then
        phase2SpawnWormhole()
    end
end

function phase2SpawnWormhole()
    jc88:sendCommsMessage(player, [[Atlantis-1? What is happening?
We are reading a huge gravity surge from your direction. Get the hell out of there.]])
    x, y = b20_artifact:getPosition()
    b20_artifact:explode()
    b20_artifact.nebula:destroy() --Remove the nebula, else it will get sucked into the wormhole. Now it just looks like the wormhole replaces the nebula.
    WormHole():setPosition(x, y):setTargetPosition(30036, -270545) --Wormhole to to ZR6

    --The explosion damages all systems, but makes sure the impulse, warp and jumpdrive are non-functional. This prevents the player from escaping the grasp of the wormhole.
    --We made sure we are around 2U of the wormhole before this function is called.
    player:setSystemHealth("reactor", player:getSystemHealth("reactor") - random(0.0, 0.5))
    player:setSystemHealth("beamweapons", player:getSystemHealth("beamweapons") - random(0.0, 0.5))
    player:setSystemHealth("maneuver", player:getSystemHealth("maneuver") - random(0.0, 0.5))
    player:setSystemHealth("missilesystem", player:getSystemHealth("missilesystem") - random(0.0, 0.5))
    player:setSystemHealth("impulse", player:getSystemHealth("impulse") - random(1.3, 1.5))
    player:setSystemHealth("warp", player:getSystemHealth("warp") - random(1.3, 1.5))
    player:setSystemHealth("jumpdrive", player:getSystemHealth("jumpdrive") - random(1.3, 1.5))
    player:setSystemHealth("frontshield", player:getSystemHealth("frontshield") - random(0.0, 0.5))
    player:setSystemHealth("rearshield", player:getSystemHealth("rearshield") - random(0.0, 0.5))
    
    mission_state = phase2WaitTillWormholeWarpedPlayer
end

function phase2WaitTillWormholeWarpedPlayer(delta)
    if distance(player, 30036, -270545) < 2000 then
        shipyard_gamma:sendCommsMessage(player, scrambleMessage([[Atlantis-1,
Come in. Come in.
We suddenly read that your position is behind the Kraylor defense line.
Do NOT engage the Kraylor. I repeat, DO NOT ENGAGE.]]))
        mission_state = phase3FindHoleInTheKraylorDefenseLine
    end
end

function phase3FindHoleInTheKraylorDefenseLine(delta)
	px, py = player:getPosition()
    if distance(player, -5000, -260000) < 10000 or py > -248000 or px > 75000 then
		if py > -248000 or px > 75000 then
			shipyard_gamma:sendCommsMessage(player, "Atlantis-1,\nFinally. We thought we lost you. You are not out of the woods yet.\nTry to get to sector ZU5. We are sending JC88 to get you.")
		else
			shipyard_gamma:sendCommsMessage(player, [[Atlantis-1,
Finally. We thought we lost you. You are not out of the woods yet. Search for a hole in the kraylor defenses.
Try to get to sector ZU5. We are sending JC88 to get you out of there.]])
		end
        jc88:orderFlyTowardsBlind(10000, -210000)
        mission_state = phase3EscapeTheKraylorDefenseLine
		player:addReputationPoints(5)
    end
end

function phase3EscapeTheKraylorDefenseLine(delta)
    if handleJumpCarrier(jc88, 10000, -210000, 24000, 125000, [[Hold on tight, heading for Shipyard-Gamma.]]) then
        --Good, continue.
        jc88:sendCommsMessage(player, [[Welcome home Atlantis-1.
Best dock with Supply-6 to recharge and restock.
Report back to Shipyard-Gamma for your mission report.]])
        mission_state = phase3ReportBackToShipyard
		player:addReputationPoints(5)
    end
end

function phase3ReportBackToShipyard(delta)
    --The shipyardGammaComms function will handle this state.
end

function phase3AnalizingData(delta)
    phase3AnalizingData_timeout = phase3AnalizingData_timeout - delta
    if phase3AnalizingData_timeout < 0.0 then
        shipyard_gamma:sendCommsMessage(player, [[Atlantis-1,
We've worked through the data you collected on the anomaly that collapsed into the wormhole.
There are traces of both Kraylor and Arlenian technology in there, which does not make any sense. While the Arlenians are a peaceful race,
the Kraylor are keen on trying to destroy the Arlenians.

We can only assume that the Kraylor stole some kind of advanced technology from the Arlenians.

Recently there has been a spike in Kraylor transports near the Kraylor defense line. We have reason to believe that these transports might carry more information regarding this technology.
We are tasking you to head back out to the Kraylor defense line, and destroy one of these transports. Take any cargo that might stay behind. It could provide valuable intel.

However, do NOT engage any of the Kraylor bases directly. You are not equipped to handle a full on assault.]])
        kraylor_transport = CpuShip():setFaction("Kraylor"):setTemplate("Flavia"):setCallSign("KHVT"):orderIdle()
        kraylor_transport:setCommsScript(""):setImpulseMaxSpeed(60)
        kraylor_transport.current_station = kraylor_forward_line[irandom(1, #kraylor_forward_line)]
        local x, y = kraylor_transport.current_station:getPosition()
        kraylor_transport:setPosition(x + random(-1000, 1000), y + random(-1000, 1000))
        kraylor_transport:orderDock(kraylor_transport.current_station)
        kraylor_transport.drop = nil
        mission_state = phase4JumpBackToKraylorLine
    end
end

--[[*********************************************************************--]]

function phase4JumpBackToKraylorLine(delta)
    if handleJumpCarrier(jc88, 24000, 125000, 10000, -210000, [[Hold on tight, heading for Kraylor defense line.]]) then
        --Good, continue.
        jc88:sendCommsMessage(player, [[We are here. Find the right moment to take out that transport, and grab the cargo and dock with us.
Expect heavy retaliation as soon as you attack the transport.]])
        mission_state = phase4DestroyTheTransport
    end
end

function phase4DestroyTheTransport(delta)
    if kraylor_transport:isValid() then
        if kraylor_transport:isDocked(kraylor_transport.current_station) then   
            kraylor_transport.current_station = kraylor_forward_line[irandom(1, #kraylor_forward_line)]
            kraylor_transport:orderDock(kraylor_transport.current_station)
        end
        kraylor_transport.x, kraylor_transport.y = kraylor_transport:getPosition()
        if kraylor_transport:getShieldLevel(0) < kraylor_transport:getShieldMax(0) or kraylor_transport:getShieldLevel(1) < kraylor_transport:getShieldMax(1) then
            --Transport is damaged, go on the full offense.
            putKraylorDefenseLineOnFullOffense()
        end
    elseif kraylor_transport.drop == nil then
        --Transport is destroyed, go on the full offense. (could be destroyed in 1 hit, so we do not see shield damage then)
        putKraylorDefenseLineOnFullOffense()
        kraylor_transport.drop = SupplyDrop():setFaction("Human Navy"):setPosition(kraylor_transport.x, kraylor_transport.y)
    elseif not kraylor_transport.drop:isValid() then
        jc88:sendCommsMessage(player, [[Get back here NOW. The whole Kraylor fleet is after you. Whatever you have, it is valuable.]])
        mission_state = phase4JumpBackToShipyard
		player:addReputationPoints(5)
    end
end

function phase4JumpBackToShipyard(delta)
    if handleJumpCarrier(jc88, 10000, -210000, 24000, 125000, [[Hold on tight, heading for Shipyard-Gamma.]]) then
        --Good, continue.
        shipyard_gamma:sendCommsMessage(player, [[Atlantis-1,
Perfect recovery. Seems like the transport was moving highly encrypted documents.
Dock with us, and we'll take a shot at cracking them.]])
        --Remove all the Kraylor ships from the game that where attacking the player. We no longer need them, and they could mess things up if they get the time to fly all the way to the shipyard.
        for _, ship in ipairs(kraylor_defense_line_ships) do
            if ship:isValid() then ship:destroy() end
        end
        mission_state = phase5DockWithShipyard
		player:addReputationPoints(5)
    end
end

--[[*********************************************************************--]]
function phase5DockWithShipyard(delta)
    if player:isDocked(shipyard_gamma) then
        shipyard_gamma:sendCommsMessage(player, [[Thanks. We are processing these documents right now.
Looks like the encryption is pretty advanced for Kraylor standards. However, the Kraylor do not excel at encryption.
So it will take some time to crack this, but it is not impossible.]])
        cracking_delay = 30
        mission_state = phase5Cracking1
    end
end

function phase5Cracking1(delta)
    if player:isCommsInactive() then
        cracking_delay = cracking_delay - delta
        if cracking_delay < 0.0 then
            shipyard_gamma:sendCommsMessage(player, [[We've cracked the first part of the documents.

It looks like the Kraylor stole some advanced jump drive technology from the Arlenians.
It has to do with something called a Heisenberg-Einstein bridge, by folding the space time fabric.

This seems to require particles with a negative mass. We're working on getting more information from these documents. They are a bit of a mess.]])
            cracking_delay = 30
            mission_state = phase5Cracking2
        end
    end
end

function phase5Cracking2(delta)
    if player:isCommsInactive() then
        cracking_delay = cracking_delay - delta
        if cracking_delay < 0.0 then
            shipyard_gamma:sendCommsMessage(player, [[More results from the decryption team.

The Arlenians managed to create these negative mass particles. However, the end result was extremely unstable, and could collapse into a black hole at any second.
A huge amount of power with specially formed magnetic fields is required to keep the particles stable.

In the end, they did manage to make long distance travel possible, by opening a rip in the space time fabric and sending specialized ships through this tear.

We'll keep you updated with more information.]])
            cracking_delay = 30
            mission_state = phase5Cracking3
        end
    end
end

function phase5Cracking3(delta)
    if player:isCommsInactive() then
        cracking_delay = cracking_delay - delta
        if cracking_delay < 0.0 then
            shipyard_gamma:sendCommsMessage(player, [[It looks like the Kraylor were watching these experiments and waiting for their moment to steal the end result.

According to these documents the Kraylor actually continued the experiments at sector D20, explaining the phenomenon you experienced there.

It does look like they were able to successfully prototype this into a working jump drive. However, the documents must have been scrambled here.
As they go from mentioning distances of 2000U to talking about troop counts and missile storage in insane amounts.]])
            cracking_delay = 30
            mission_state = phase5Cracking4
        end
    end
end

function phase5Cracking4(delta)
    if player:isCommsInactive() then
        cracking_delay = cracking_delay - delta
        if cracking_delay < 0.0 then
            shipyard_gamma:sendCommsMessage(player, [[We cracked the final piece of the puzzle.

This is insane. It is huge. We have the plans for some kind of massive battle station. The wormhole powered jump drive is at the center of this station.
It seems that the Kraylor are actually constructing some kind of large distance moving battle station equipped with an insane amount of firepower.

While the technology behind the wormhole jump drive isn't stable, the Kraylor are insane enough to do this, as it will give them a huge battle advantage.]])
            mission_state = phase5CrackingDone
        end
    end
end

function phase5CrackingDone(delta)
    if player:isCommsInactive() then
        shipyard_gamma:sendCommsMessage(player, [[Just detected a power surge.\nI T ' S   T H E   B A T T L E S T A T I O N ! !

All hands on deck. Man all stations, evacuate! Save what you can!]])
        odin = CpuShip():setFaction("Kraylor"):setTemplate("Odin"):setCallSign("Odin"):setScanned(true):setPosition(26900, 132872):orderAttack(shipyard_gamma)
        odin.target = shipyard_gamma
        WormHole():setPosition(23984, 126258):setTargetPosition(0, 0)
        mission_state = phase5OdinAttack
    end
end

function phase5OdinAttack(delta)
    if not odin:isValid() then  --WTF man, you get bonus points for this.
		globalMessage("Bonus points for actually destroying the battlestation")
        victory("Human Navy")
        return
    end
    if distance(player, odin) > 30000 then
        victory("Human Navy")
    end
    
    if not odin.target:isValid() then
        if shipyard_gamma:isValid() then
            odin.target = shipyard_gamma
			player:addReputationPoints(5)
        elseif supply_station_6:isValid() then
            odin.target = supply_station_6
			player:addReputationPoints(5)
        elseif jc88:isValid() then
            odin.target = jc88
			player:addReputationPoints(5)
        elseif player:isValid() then
            odin.target = player
			player:addReputationPoints(5)
        end
        if odin.target:isValid() then
            odin:orderAttack(odin.target)
            local x, y = odin.target:getPosition()
            odin:setPosition(x + random(-2000, 2000), y + random(-2000, 2000))
        end
    end
end

--[[*********************************************************************--]]
function shipyardGammaComms()
    if mission_state == phase3FindHoleInTheKraylorDefenseLine then
        return false
    end
    --comms_source
    --comms_target
    if mission_state == phase1WaitForContact then
        setCommsMessage([[Atlantis-1, all ready and set to go on your first mission?]])
        addCommsReply("Yes", function()
            setCommsMessage([[Good.
Your first mission will be to seek out odd readings coming from the nebula cloud in sector B20.
Your ship is not equipped to travel this distance by itself, so we have tasked the Jump carrier JC-88 to take you there.
Dock with JC-88 and it will handle the rest.]])
            mission_state = phase2WaitForJump
        end)
        addCommsReply("No", function()
            setCommsMessage([[Then hail us again when you are ready.]])
        end)
        return
    end
    if mission_state == phase2SeekArtifact or mission_state == phase2ReportArtifactReadings then
        artifactReportComms()
        return
    end
    if mission_state == phase3ReportBackToShipyard then
        setCommsMessage([[Atlantis-1,
We've downloaded all the data you collected thanks to the short range quantum entangled data communication radar.
We are working through the data right now. We will contact you when we have more details.]])
        mission_state = phase3AnalizingData
        phase3AnalizingData_timeout = 60.0
        return
    end
    
    setCommsMessage([[Good day Atlantis-1.
Please continue with your current objective.]])
end

function jc88Comms()
    if mission_state == phase3FindHoleInTheKraylorDefenseLine then
        return false
    end

    if mission_state == phase2SeekArtifact or mission_state == phase2ReportArtifactReadings then
        artifactReportComms()
        return
    end
    setCommsMessage([[Jump carrier JC-88 reporting in.
All system nominal.]])
end

function artifactReportComms()
    setCommsMessage([[Atlantis-1,
Did you find the source of the odd sensor readings?]])
    addCommsReply("Yes", function()
        setCommsMessage([[Great, as our sensor readings are inconclusive. Can you report back your readings to us?

First off, what is the beta radiation reading?]])
        for beta=1,10 do
            addCommsReply(beta, function()
                setCommsMessage([[Next up, what is your Ionic phase shift reading?]])
                for ionic=1,10 do
                    addCommsReply(ionic, function()
                        setCommsMessage([[Next up, what is your gravity disruption reading?]])
                        for gravity=1,10 do
                            addCommsReply(gravity, function()
                                setCommsMessage([[Finally, what is your reading on doppler instability?]])
                                for doppler=1,10 do
                                    addCommsReply(doppler, function()
                                        if b20_artifact.beta_radiation == beta and b20_artifact.gravity_disruption == gravity and b20_artifact.ionic_phase_shift == ionic and b20_artifact.doppler_instability == doppler then
                                            if distance(player, b20_artifact) < 2000 then
                                                setCommsMessage([[Are you sure? Those readings are really off the normal scale.
Please move away from it, as these readings show it is very unstable!]])
                                                mission_state = phase2WaitTillAwayFromObject
                                            else
                                                setCommsMessage([[Are you sure? Those readings are really off the normal scale.
Can you move closer to the object to see if you can improve those readings. The nebula might be interfering with your sensors.]])
                                                mission_state = phase2WaitTillNearObject
                                            end
                                        else
                                            setCommsMessage([[Are you sure? Can you double check this and get back to us. As this does not match with our readings.]])
                                        end
                                    end)
                                end
                            end)
                        end
                    end)
                end
            end)
        end
    end)
    addCommsReply("No", function()
        setCommsMessage([[Then continue looking for it.]])
    end)
end

function scrambleMessage(message)
    for n=1,7 do
        local pos = irandom(1, #message - 3)
        message = message:sub(0, pos) .. "---" .. message:sub(pos + 3)
    end
    for n=1,5 do
        local pos = irandom(1, #message - 1)
        message = message:sub(0, pos) .. "." .. message:sub(pos + 1)
    end
    for n=1,3 do
        local pos = irandom(1, #message - 1)
        message = message:sub(0, pos) .. "*" .. message:sub(pos + 1)
    end
    for n=1,3 do
        local pos = irandom(1, #message - 1)
        message = message:sub(0, pos) .. "$" .. message:sub(pos + 1)
    end
    message = [[(The transmission is loaded with static noise)
]] .. message
    return message
end

--[[ Assistance function to help with the details of the player using a jump carrier. --]]
jumping_state = 'wait_for_dock'
function handleJumpCarrier(jc, source_x, source_y, dest_x, dest_y, jumping_message)
    if jumping_state == 'wait_for_dock' then
        if player:isDocked(jc) then
            jc:orderFlyTowardsBlind(dest_x, dest_y)
            jc:sendCommsMessage(player, jumping_message)
            jumping_state = 'wait_for_jump'
        end
    elseif jumping_state == 'wait_for_jump' then
        if distance(jc, dest_x, dest_y) < 10000 then
            --We check for the player 1 tick later, as it can take a game tick for the player position to update as well.
            jumping_state = 'check_for_player'
        end
    elseif jumping_state == 'check_for_player' then
        jumping_state = 'wait_for_dock'
        if distance(player, dest_x, dest_y) < 10000 then
            --Good, continue.
            return true
        else
            --You idiot. JC-88 will fly back.
            jc88:orderFlyTowardsBlind(source_x, source_y)
            jc88:sendCommsMessage(player, [[Looks like the docking couplers detached prematurely.
This happens sometimes. I am on my way so we can try again.]])
        end
    end
    return false
end

function putKraylorDefenseLineOnFullOffense()
    if not kraylor_defense_line_engaged then
        for _, ship in ipairs(kraylor_defense_line_ships) do
            if ship:isValid() then
                ship:orderAttack(player)
            end
        end
        kraylor_defense_line_ships[1]:sendCommsMessage(player, [[Human intruder. Surrender yourself.]])
        kraylor_defense_line_engaged = true
    end
end

function update(delta)
    if not player:isValid() or (not jc88:isValid() and mission_state ~= phase5OdinAttack) then
        defeat_timeout = defeat_timeout - delta
        if defeat_timeout < 0.0 then
            victory("Kraylor")
            return
        end
    end
    
    --If the player enters the kraylor defense line, or engages a forward station, attack him full force.
    for _, warp_jammer in ipairs(kraylor_defense_line) do
        if distance(player, warp_jammer) < 6000 then
            putKraylorDefenseLineOnFullOffense()
        end
    end
    for _, station in ipairs(kraylor_forward_line) do
        if distance(player, station) < 3000 then
            putKraylorDefenseLineOnFullOffense()
        end
    end
    
    if mission_state ~= nil then
        mission_state(delta)
    end
end
