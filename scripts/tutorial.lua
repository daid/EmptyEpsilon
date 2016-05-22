--[[ The tutorial script looks a lot like a normal scenario script,
        except that it has access to the "tutorial" object.
        This object contains special functions to help explain the game.
--]]
require("utils.lua")

function init()
    --Create the player ship
    player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Phobos M3P")
    tutorial:setPlayerShip(player)

    tutorial:showMessage([[Welcome to the EmptyEpsilon tutorial.
Note that this tutorial is designed to give you a quick overview of the basic options for the game, but does not cover every single aspect.

Press next to continue...]], true)
    tutorial:onNext(function()
        tutorial:switchViewToMainScreen()
        tutorial:showMessage([[This is the main screen, which displays your ship and the surrounding space.
While you cannot move the ship from this screen, you can use it to visually identify objects.]], true)
        tutorial:onNext(function() startSequence(radarTutorial) end)
    end)
end

--[[ Assist function in creating tutorial sequences --]]
function startSequence(sequence)
    current_sequence = sequence
    current_index = 1
    runNextSequenceStep()
end

function runNextSequenceStep()
    local data = current_sequence[current_index]
    current_index = current_index + 1
    if data["message"] ~= nil then
        tutorial:showMessage(data["message"], data["finish_check_function"] == nil)
        if data["finish_check_function"] == nil then
            update = nil
            tutorial:onNext(runNextSequenceStep)
        else
            update = function(delta)
                if data["finish_check_function"]() then
                    runNextSequenceStep()
                end
            end
            tutorial:onNext(nil)
        end
    elseif data["run_function"] ~= nil then
        local has_next_step = current_index <= #current_sequence
        data["run_function"]()
        if has_next_step then
            runNextSequenceStep()
        end
    end
end

function createSequence()
    return {}
end

function addToSequence(sequence, data, data2)
    if type(data) == "string" then
        if data2 == nil then
            table.insert(sequence, {message = data})
        else
            table.insert(sequence, {message = data, finish_check_function = data2})
        end
    elseif type(data) == "function" then
        table.insert(sequence, {run_function = data})
    end
end

function resetPlayerShip()
    player:setJumpDrive(false)
    player:setWarpDrive(false)
    player:setImpulseMaxSpeed(1)
    player:setRotationMaxSpeed(1)
    for _, system in ipairs({"reactor", "beamweapons", "missilesystem", "maneuver", "impulse", "warp", "jumpdrive", "frontshield", "rearshield"}) do
        player:setSystemHealth(system, 1.0)
        player:setSystemHeat(system, 0.0)
        player:setSystemPower(system, 1.0)
        player:commandSetSystemPowerRequest(system, 1.0)
        player:setSystemCoolant(system, 0.0)
        player:commandSetSystemCoolantRequest(system, 0.0)
    end
    player:setPosition(0, 0)
    player:setRotation(0)
    player:commandImpulse(0)
    player:commandWarp(0)
    player:commandTargetRotation(0)
    player:commandSetShields(false)
    player:setWeaponStorageMax("homing", 0)
    player:setWeaponStorageMax("nuke", 0)
    player:setWeaponStorageMax("mine", 0)
    player:setWeaponStorageMax("emp", 0)
    player:setWeaponStorageMax("hvli", 0)
end

--[[ Radar explanation tutorial ]]

radarTutorial = createSequence()
addToSequence(radarTutorial, function() tutorial:switchViewToLongRange() end)
addToSequence(radarTutorial, [[Welcome to the long-range radar. This radar can detect objects up to 30u from your ship, depicted at the radar's center. This radar allows you to quickly identify distant objects.]])
addToSequence(radarTutorial, function() prev_object = Asteroid():setPosition(5000, 0) end)
addToSequence(radarTutorial, [[To the right of your ship is a brown dot. This is an asteroid.
Asteroid impacts will damage your ship, so avoid hitting them.]])
addToSequence(radarTutorial, function() prev_object:destroy() end)
addToSequence(radarTutorial, function() prev_object = Mine():setPosition(5000, 0) end)
addToSequence(radarTutorial, [[The white dot is a mine. When you move near a mine, it explodes with a powerful 1u-radius blast. Striking a mine while your shields are down will surely destroy your ship.]])
addToSequence(radarTutorial, function() prev_object:destroy() end)
addToSequence(radarTutorial, function() prev_object = SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setPosition(5000, 0) end)
addToSequence(radarTutorial, function() prev_object2 = SpaceStation():setTemplate("Large Station"):setFaction("Independent"):setPosition(5000, 5000) end)
addToSequence(radarTutorial, function() prev_object3 = SpaceStation():setTemplate("Huge Station"):setFaction("Kraylor"):setPosition(5000, -5000) end)
addToSequence(radarTutorial, [[This large dot is a station. Stations can be several different sizes and belong to different factions. The dot's color indicates whether the station is friendly (green), neutral (light blue), or hostile (red).]])
addToSequence(radarTutorial, function() prev_object:destroy() end)
addToSequence(radarTutorial, function() prev_object2:destroy() end)
addToSequence(radarTutorial, function() prev_object3:destroy() end)
addToSequence(radarTutorial, function() prev_object = Nebula():setPosition(8000, 0) end)
addToSequence(radarTutorial, [[The rainbow-colored cloud is a nebula. Nebulae block long-range sensors, preventing ships from detecting what's inside of them at distances of more than 5u. Sensors also cannot detect objects behind nebulae.]])
addToSequence(radarTutorial, function() prev_object:destroy() end)
addToSequence(radarTutorial, function() prev_object = CpuShip():setFaction("Human Navy"):setTemplate("Phobos T3"):setPosition(5000, -2500):orderIdle():setScanned(true) end)
addToSequence(radarTutorial, function() prev_object2 = CpuShip():setFaction("Independent"):setTemplate("Phobos T3"):setPosition(5000, 2500):orderIdle():setScanned(true) end)
addToSequence(radarTutorial, function() prev_object3 = CpuShip():setFaction("Kraylor"):setTemplate("Phobos T3"):setPosition(5000, -7500):orderIdle():setScanned(true) end)
addToSequence(radarTutorial, function() prev_object4 = CpuShip():setFaction("Kraylor"):setTemplate("Phobos T3"):setPosition(5000, 7500):orderIdle():setScanned(false) end)
addToSequence(radarTutorial, [[Finally, these are ships. They look like you on radar, and their attitude toward you is reflected by the same colors as stations. In addition to green, blue, and red, ships of unknown attitude appear as gray objects.]])
addToSequence(radarTutorial, function() prev_object:destroy() end)
addToSequence(radarTutorial, function() prev_object2:destroy() end)
addToSequence(radarTutorial, function() prev_object3:destroy() end)
addToSequence(radarTutorial, function() prev_object4:destroy() end)
addToSequence(radarTutorial, [[Next, we will look at the short-range radar.]])
addToSequence(radarTutorial, function() tutorial:switchViewToTactical() end)
addToSequence(radarTutorial, [[The short-range radar can detect objects up to 5u from your ship. It also depicts the range of your own beam weapons.
Your ship has 2 beam weapons aimed forward. Each type of ship has different beam weapon layouts, with different ranges and locations.]])
addToSequence(radarTutorial, function() startSequence(helmsTutorial) end)

helmsTutorial = createSequence()
addToSequence(helmsTutorial, function()
    tutorial:switchViewToScreen(0)
    tutorial:setMessageToTopPosition()
    resetPlayerShip()
    player:setJumpDrive(false)
    player:setWarpDrive(false)
    player:setImpulseMaxSpeed(0);
    player:setRotationMaxSpeed(0);
end)
addToSequence(helmsTutorial, [[This is the helms screen.
As the helms officer, you command your ship's movement in space.]])
addToSequence(helmsTutorial, function() player:setImpulseMaxSpeed(90) end)
addToSequence(helmsTutorial, [[Your primary controls are your impulse engines and maneuvering thrusters.
Your impulse controls are on the left side of the screen.

Raise your impulse level to 100% to fly forward right now.]], function() return distance(player, 0, 0) > 1000 end)
addToSequence(helmsTutorial, function() player:setImpulseMaxSpeed(0):commandImpulse(0):setRotationMaxSpeed(10) end)
addToSequence(helmsTutorial, [[Good. You now know how to move forward.

I've disabled your impulse engine for now. Next, let's rotate your ship.
Rotating the ship is easy. Simply press a heading on the radar screen to rotate your ship in that direction.
Try rotating to heading 200 right now.]], function() return math.abs(player:getHeading() - 200) < 1.0 end)
addToSequence(helmsTutorial, function() player:setImpulseMaxSpeed(90) end)
addToSequence(helmsTutorial, function() prev_object = SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setPosition(0, -1500) end)
addToSequence(helmsTutorial, [[Excellent!

Next up: docking. Docking with a station recharges your energy, repairs your hull, and allows the relay officer to request weapon refills. It can also be important for other mission-related events.
To dock, maneuver within 1u of a station and press the "Request Dock" button, from which point docking is fully automated.
Maneuver to the nearby station and request permission to dock.]], function() return player:isDocked(prev_object) end)
addToSequence(helmsTutorial, [[Now that you are docked, your movement is locked. As helms officer, there is nothing else you can do but undock, so do that now.]], function() return not player:isDocked(prev_object) end)
addToSequence(helmsTutorial, function() prev_object:destroy() end)
addToSequence(helmsTutorial, function() prev_object = CpuShip():setFaction("Kraylor"):setTemplate("Flavia"):setPosition(-1500, 1500):orderIdle():setScanned(true) end)
addToSequence(helmsTutorial, function() player:commandSetTarget(prev_object) end)
addToSequence(helmsTutorial, [[Ok, there are just a few more things that you need to know.
Remember those beam weapons? As helms officer, is it your task to keep those beams on your target.
I've set up an stationary enemy ship as a target. Destroy it with your beam weapons.]], function() return not prev_object:isValid() end)
addToSequence(helmsTutorial, [[Aggression is not always the solution, but boy, it is fun!

On to the next task: moving long distances.
There are two methods of moving long distances quickly. Depending on your ship, you either have a warp drive or a jump drive.
The warp drive moves your ship at high speed, while the jump drive instantly teleports your ship a great distance.]])
addToSequence(helmsTutorial, function() player:setWarpDrive(true) end)
addToSequence(helmsTutorial, [[First, let us try the warp drive.

It functions like the impulse drive but only propels your ship forward, and consumes energy at a much faster rate.
Use the warp drive to move more than 30u away from this starting point.]], function() return distance(player, 0, 0) > 30000 end)
addToSequence(helmsTutorial, function() player:setWarpDrive(false):setJumpDrive(true):setPosition(0, 0) end)
addToSequence(helmsTutorial, [[Next, let us demonstrate the jump drive.

To use the jump drive, point your ship in the direction where you want to jump, configure a distance to jump, and then initiate it. The jump occurs 10 seconds after you initiate. Use the jump drive to jump more than 30u from this starting point, in any direction.]], function() return distance(player, 0, 0) > 30000 end)
addToSequence(helmsTutorial, [[Notice how your jump drive needs to recharge after use.

This covers the basics of the helms officer.]])
addToSequence(helmsTutorial, function() startSequence(weaponsTutorial) end)

weaponsTutorial = createSequence()
addToSequence(weaponsTutorial, function()
    tutorial:switchViewToScreen(1)
    tutorial:setMessageToTopPosition()
    resetPlayerShip()
    player:setJumpDrive(false)
    player:setWarpDrive(false)
    player:setImpulseMaxSpeed(0)
    player:setRotationMaxSpeed(0)
end)

addToSequence(weaponsTutorial, [[This is the weapons screen.
As the weapons officer, you are responsible for targeting beam weapons, loading and firing missile weapons, and controlling your shields.]])
addToSequence(weaponsTutorial, function() prev_object = CpuShip():setFaction("Kraylor"):setTemplate("Phobos T3"):setPosition(700, 0):setRotation(0):orderIdle():setScanned(true) end)
addToSequence(weaponsTutorial, [[Your most fundamental task is to target your ship's weapons.
Your beam weapons only fire at your selected target, and homing missiles travel toward your selected target.

Target the ship in front of you by pressing it.]], function() return player:getTarget() == prev_object end)
addToSequence(weaponsTutorial, [[Good! Notice that your beam weapons did not fire on this ship until you targeted it.

Next up: shield controls.]])
addToSequence(weaponsTutorial, function() prev_object:destroy() end)
addToSequence(weaponsTutorial, function() prev_object = CpuShip():setFaction("Kraylor"):setTemplate("Phobos T3"):setPosition(-700, 0):setRotation(0):orderAttack(player):setScanned(true) end)
addToSequence(weaponsTutorial, [[As you might notice, you are being shot at. Do not worry, you cannot die right now.

You are taking damage, however, so enable your shields to protect yourself.]], function()
    player:setHull(player:getHullMax())
    player:setSystemHealth("reactor", 1.0)
    player:setSystemHealth("beamweapons", 1.0)
    player:setSystemHealth("missilesystem", 1.0)
    player:setSystemHealth("maneuver", 1.0)
    player:setSystemHealth("impulse", 1.0)
    player:setSystemHealth("warp", 1.0)
    player:setSystemHealth("jumpdrive", 1.0)
    player:setSystemHealth("frontshield", 1.0)
    player:setSystemHealth("rearshield", 1.0)
    return player:getShieldLevel(1) < player:getShieldMax(1)
end)
addToSequence(weaponsTutorial, [[Shields protect your ship from direct damage, but they cost extra energy to maintain, can take only a limited amount of damage, and are slow to recharge. Eventually, this enemy's attacks will get through your shields.

Disable your shields to continue.]], function() return not player:getShieldsActive() end)
addToSequence(weaponsTutorial, function() prev_object:destroy() end)
addToSequence(weaponsTutorial, [[While only a single button, your shields are vital for survival. They protect against all kinds of damage, including beam weapons, missiles, asteroids, and mines, so make them one of your primary priorities.

Next up, the real fun starts: missile weapons.]])

addToSequence(weaponsTutorial, function()
    player:setWeaponStorageMax("homing", 1)
    player:setWeaponStorage("homing", 1)
    player:setWeaponTubeCount(1)
    prev_object = CpuShip():setFaction("Kraylor"):setTemplate("Flavia"):setPosition(3000, 0):setRotation(0):orderIdle():setScanned(true)
    prev_object:setHull(1):setShieldsMax(1) -- Make it die in 1 shot.
end)
addToSequence(weaponsTutorial, [[You have 1 homing missile in your missile storage now, and 1 weapon tube.
You can load this missile into your weapon tube. Depending on your ship type, you might have more types of missiles and more weapon tubes.

Load this homing missile into the weapon tube by selecting the homing missile, and then pressing the load button for this tube. Note that it takes some time to load missiles into tubes.]],
    function() return player:getWeaponTubeLoadType(0) == "homing" end)
addToSequence(weaponsTutorial, [[Great! Now fire this missile by clicking on the tube.]], function() return player:getWeaponTubeLoadType(0) == nil end)
addToSequence(weaponsTutorial, [[Missile away!]], function() return not prev_object:isValid() end)
addToSequence(weaponsTutorial, function() prev_object = CpuShip():setFaction("Kraylor"):setTemplate("Flavia"):setPosition(2000, -2000):setRotation(0):orderIdle():setScanned(true):setHull(1):setShieldsMax(1) end)
addToSequence(weaponsTutorial, function() tutorial:setMessageToBottomPosition() end)
addToSequence(weaponsTutorial, [[BOOM! That was just firing straight ahead, but you can also aim missiles.

First, unlock your aim by pressing the [Lock] button above the radar view.
Next, aim your missiles with the aiming dial surrounding the radar.
Point the aiming dial at the next ship, load a missile, and fire.]], function()
    if player:getWeaponStorage("homing") < 1 then
        player:setWeaponStorage("homing", 1)
    end
    return not prev_object:isValid()
end)
addToSequence(weaponsTutorial, function() prev_object = CpuShip():setFaction("Kraylor"):setTemplate("Flavia"):setPosition(-1550, -1900):setRotation(0):orderIdle():setScanned(true):setHull(1):setShieldsMax(1) end)
addToSequence(weaponsTutorial, [[Perfect aim!

The next ship is behind you. Target the ship by pressing it to guide your homing missiles toward your selected target.
While not necessary against a stationary target, this homing ability can make all the difference against a moving target.]], function()
    if player:getWeaponStorage("homing") < 1 then
        player:setWeaponStorage("homing", 1)
    end
    return not prev_object:isValid()
end)
addToSequence(weaponsTutorial, function() player:setWeaponStorage("homing", 0):setWeaponStorageMax("homing", 0) end)
addToSequence(weaponsTutorial, function() tutorial:setMessageToTopPosition() end)
addToSequence(weaponsTutorial, [[In addition to homing missiles, your ship might have nukes, EMPs, and mines. Nukes and EMPs have the same features as homing missiles, but have a 1u-radius blast and do much more damage. EMPs damage only shields, and thus are great for weakening heavily shielded enemies.]])
addToSequence(weaponsTutorial, function() startSequence(engineeringTutorial) end)

engineeringTutorial = createSequence()
addToSequence(engineeringTutorial, function()
    tutorial:switchViewToScreen(2)
    tutorial:setMessageToTopPosition()
    resetPlayerShip()
end)
addToSequence(engineeringTutorial, [[Welcome to engineering.
Engineering is split into two parts. The top part shows your ship's interior, including damage control teams stationed throughout.
The bottom part controls power and coolant levels of your ship's systems.]])
addToSequence(engineeringTutorial, function() player:setWarpDrive(true) end)
addToSequence(engineeringTutorial, function() player:setSystemHeat("warp", 0.8) end)
addToSequence(engineeringTutorial, [[First, we will explain your control over your ship's systems.
Each row on the bottom area of the screen represents one of your ship's system, and each system has a damage level, heat level, power level, and coolant level.

I've overheated your warp system. An overheating system can damage your ship. You can prevent this by putting coolant in your warp system. Select the warp system and increase the coolant slider.]], function() return player:getSystemHeat("warp") < 0.05 end)
addToSequence(engineeringTutorial, function() player:setSystemHeat("impulse", 0.8) end)
addToSequence(engineeringTutorial, [[I've also overheated the impulse system. As before, increase the system's coolant level to mitigate the effect. Note that the warp system's coolant level is automatically reduced to allow for coolant in the impulse system.

This is because you have a limited amount of coolant available to distribute this across your ship's systems.]], function() return player:getSystemHeat("impulse") < 0.05 end)
addToSequence(engineeringTutorial, [[Good! Next up: power levels.
You can manage each system's power level independently. Adding power to a system makes it perform more effectively, but also generates more heat, and thus requires coolant to prevent it from overheating and damaging the system.

Maximize the power to the front shield system.]], function() return player:getSystemPower("frontshield") > 2.5 end)
addToSequence(engineeringTutorial, [[The added power increases the amount of heat in the system.

Overpower the system until it overheats.]], function() return player:getSystemHealth("frontshield") < 0.5 end)
addToSequence(engineeringTutorial, function() player:setSystemPower("frontshield", 0.0) end)
addToSequence(engineeringTutorial, function() player:commandSetSystemPowerRequest("frontshield", 0.0) end)
addToSequence(engineeringTutorial, [[Note that as the system overheats, it takes damage. Because the system is damaged, it functions less effectively.

Systems can also take damage when your ship is hit while the shields are down.]])
addToSequence(engineeringTutorial, function() tutorial:setMessageToBottomPosition() end)
addToSequence(engineeringTutorial, [[In this top area, you see your damage control teams in your ship.]])
addToSequence(engineeringTutorial, [[The front shield system is damaged, as indicated by the color of this room's outline.

Select a damage control team from elsewhere on the ship by pressing it, then press on that room to initiate repairs.
(Repairs will take a while.)]], function() return player:getSystemHealth("frontshield") > 0.9 end)
addToSequence(engineeringTutorial, function() tutorial:setMessageToTopPosition() end)
addToSequence(engineeringTutorial, [[Good. Now you know your most important tasks. Next, we'll go over each system's function in detail.
Remember, each system performs better with more power, but performs less well when damaged. Your job is to keep vital systems running as well as you can.]])
addToSequence(engineeringTutorial, [[Reactor:

The reactor generates energy. Adding power to the reactor increases your energy generation rate.]])
addToSequence(engineeringTutorial, [[Beam Weapons:

Adding power to the beam weapons system increases their rate of fire, which causes them to do more damage.
Note that every beam you fire adds additional heat to the system.]])
addToSequence(engineeringTutorial, [[Missile System:

Increased missile system power lowers the reload time of weapon tubes.]])
addToSequence(engineeringTutorial, [[Maneuvering:

Increasing power to the maneuvering system allows the ship to turn faster. It also increases the recharge rate for the combat maneuvering system.]])
addToSequence(engineeringTutorial, [[Impulse Engines:

Adding power to the impulse engines increases your impulse flight speed.]])
addToSequence(engineeringTutorial, [[Warp Drive:

Adding power to the warp drive increases your warp drive flight speed.]])
addToSequence(engineeringTutorial, [[Jump Drive:

A higher-powered jump drive recharges faster and has a shorter delay before jumping.]])
addToSequence(engineeringTutorial, [[Shields:

Additional power in the shield system increases their rate of recharge, and decreases the amount of degradation your shields sustain when damaged.]])
addToSequence(engineeringTutorial, [[This concludes the overview of the engineering station. Be sure to keep your ship running in top condition!]])
addToSequence(engineeringTutorial, function() startSequence(scienceTutorial) end)

scienceTutorial = createSequence()
addToSequence(scienceTutorial, function()
    tutorial:switchViewToScreen(3)
    tutorial:setMessageToBottomPosition()
    resetPlayerShip()
end)
addToSequence(scienceTutorial, [[Welcome, science officer.

You are the eyes of the ship. Your job is to supply the captain with information. From your station, you can detect and scan objects at a range of up to 30u.]])
addToSequence(scienceTutorial, function() prev_object = SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setPosition(3000, -15000) end)
addToSequence(scienceTutorial, function() prev_object2 = CpuShip():setFaction("Human Navy"):setTemplate("Phobos T3"):setPosition(5000, -17000):orderIdle():setScanned(true) end)
addToSequence(scienceTutorial, [[On this radar, you can select objects to get information about them.
I've added a friendly ship and a station for you to examine. Select them and notice how much information you can observe.
Heading and distance are of particular importance, as without these, the helms officer will be jumping in the dark.]])
addToSequence(scienceTutorial, function() prev_object:destroy() end)
addToSequence(scienceTutorial, function() prev_object = CpuShip():setFaction("Kraylor"):setTemplate("Phobos T3"):setPosition(3000, -15000):orderIdle() end)
addToSequence(scienceTutorial, [[I've replaced the friendly station with an unknown ship. Once you select it, notice that you know nothing about this ship.
To learn about it, you must scan it. Scanning requires you to match your scanner's frequency bands to your target's.
Scan this ship now.]], function() return prev_object:isScannedBy(player) end)
addToSequence(scienceTutorial, [[Good. Notice that you now know this ship is unfriendly. It might have been a friendly or neutral ship as well, but until you scanned it, you do not know.]])
addToSequence(scienceTutorial, [[Note that you have less information about this ship than the friendly ship. You must perform a deep scan of this ship to acquire more information.
A deep scan takes more effort and requires you to align 2 different frequency bands simultaneously.
Deep scan the enemy now.]], function() return prev_object:isFullyScannedBy(player) end)
addToSequence(scienceTutorial, [[Excellent. Notice that this took more time and concentration than the simple scan, so be careful to perform deep scans only when necessary or you could run out of time.]])
addToSequence(scienceTutorial, function() prev_object:destroy() end)
addToSequence(scienceTutorial, function() prev_object2:destroy() end)
addToSequence(scienceTutorial, function() tutorial:setMessageToTopPosition() end)
addToSequence(scienceTutorial, [[Next to the long-range radar, the science station can also access the science database.

In this database, you can look up details on things like ship types, weapons, and other objects.]])
addToSequence(scienceTutorial, [[Remember, your job is to supply information. Knowing the location and status of other ships is vital to your captain.

Without your information, the crew is mostly blind.]])
addToSequence(scienceTutorial, function() startSequence(relayTutorial) end)

relayTutorial = createSequence()
addToSequence(relayTutorial, function()
    tutorial:switchViewToScreen(4)
    tutorial:setMessageToBottomPosition()
    resetPlayerShip()
end)
addToSequence(relayTutorial, [[Welcome to relay!

It is your job to communicate with stations and ships. You also have access to short-range radar data from friendly ships and stations, and can place navigational waypoints and launch scanning probes.]])
addToSequence(relayTutorial, [[Your first responsibility is to coordinate the ship's communications.

You can target any station or ship and attempt to communicate with it. Other ships can also attempt to contact you.]])
addToSequence(relayTutorial, function()
    prev_object = SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setPosition(3000, -15000)
    prev_object:setCommsFunction(function()
        setCommsMessage("You successfully opened communications. Congratulations.");
        addCommsReply("Tell me more!", function()
            setCommsMessage("Sorry, there's nothing more to tell you.")
        end)
        addCommsReply("Continue with the tutorial.", function()
            setCommsMessage("The tutorial will continue when you close communications with this station.")
        end)
    end)
end)
addToSequence(relayTutorial, [[Open communications with the station near you to continue the tutorial.]], function() return player:isCommsScriptOpen() end)
addToSequence(relayTutorial, function() tutorial:setMessageToTopPosition() end)
addToSequence(relayTutorial, [[Now finish your talk with the station.]], function() return not player:isCommsScriptOpen() end)
addToSequence(relayTutorial, function() tutorial:setMessageToBottomPosition() end)
addToSequence(relayTutorial, function() prev_object:destroy() end)
addToSequence(relayTutorial, [[Depending on the scenario, you might have different options when communicating with stations.
They might inform you about new objectives and your mission progress, ask for backup, or resupply your weapons. This is all part of your responsibilities as relay officer.]])
addToSequence(relayTutorial, function() prev_object = CpuShip():setFaction("Human Navy"):setTemplate("Phobos T3"):setPosition(20000, -20000):orderIdle():setCallSign("DMY-01"):setScanned(true) end)
addToSequence(relayTutorial, function() prev_object2 = CpuShip():setFaction("Human Navy"):setTemplate("Phobos T3"):setPosition(-24000, 2500):orderIdle():setScanned(true) end)
addToSequence(relayTutorial, function() prev_object3 = CpuShip():setFaction("Human Navy"):setTemplate("Phobos T3"):setPosition(-17000, -7500):orderIdle():setScanned(true) end)
addToSequence(relayTutorial, function() prev_object4 = CpuShip():setFaction("Human Navy"):setTemplate("Phobos T3"):setPosition(5400, 7500):orderIdle():setScanned(false) end)
addToSequence(relayTutorial, [[Your station also includes this radar map.

On this map, you can detect objects within 5u of all allied ships and stations. Everything else is invisible to you. This gives you a different view from the science officer, because you can scan the contents of nebulae.]])
addToSequence(relayTutorial, [[Finally, you control your ship's probes. Probes can expand your radar view. Launch a probe to the top right, toward the ship designated DMY-01.]], function()
    for _, obj in ipairs(getObjectsInRadius(20000, -20000, 5000)) do
        if obj.typeName == "ScanProbe" then
            return true
        end
    end
end)
addToSequence(relayTutorial, function() prev_object:destroy() end)
addToSequence(relayTutorial, function() prev_object2:destroy() end)
addToSequence(relayTutorial, function() prev_object3:destroy() end)
addToSequence(relayTutorial, function() prev_object4:destroy() end)
addToSequence(relayTutorial, [[Probes can expand your sensory capabilities beyond your normal range and explore nebulae. However, you have a limited supply of them and can't replenish them until you to dock with a station.]])
addToSequence(relayTutorial, function() tutorial:switchViewToMainScreen() end)
addToSequence(relayTutorial, [[This concludes the tutorial. While we have covered the basics, there are more advanced features in the game that you might discover.]])
addToSequence(relayTutorial, function() tutorial:finish() end)
