--[[ The tutorial script looks a lot like a normal scenario script.
        Except that it has access to the "tutorial" object.
        This object contains special functions to help explaining the game.
--]]

function init()
    --Create the player ship
    player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Player Cruiser")
    tutorial:setPlayerShip(player)
    
    tutorial:showMessage([[Welcome to the EmptyEpsilon tutorial.
Note that this tutorial is designed to give you a quick overview of the basic options for the game, but does not cover every single aspect.

Press next to continue...]], true)
    tutorial:onNext(function()
        tutorial:switchViewToMainScreen()
        tutorial:showMessage([[What you see now is the main screen. Here you see your own ship and the world around you.
There is no direction interaction available on this screen. But it allows for visual identification of objects.]], true)
        startSequence(radarTutorial)
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
        player:commandSetSystemPower(system, 1.0)
        player:commandSetSystemCoolant(system, 0.0)
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
end

--[[ Radar explination tutorial ]]

radarTutorial = createSequence()
addToSequence(radarTutorial, function() tutorial:switchViewToLongRange() end)
addToSequence(radarTutorial, [[Welcome to the long range radar. This radar can see up to 30km from your ship.
At the center you see your own ship. This radar quickly allows you to identify different objects.]])
addToSequence(radarTutorial, function() prev_object = Asteroid():setPosition(5000, 0) end)
addToSequence(radarTutorial, [[Right of your own ship, you see a brown dot. This is an asteroid.
Asteroids should be avoided, as they damage your ship if you fly into them.]])
addToSequence(radarTutorial, function() prev_object:destroy() end)
addToSequence(radarTutorial, function() prev_object = Mine():setPosition(5000, 0) end)
addToSequence(radarTutorial, [[The white dot is a mine. Mines trigger when you are close, and then explode with a 1km blast radius. They do a lot of damage. Flying into one without shields will surely kill you.]])
addToSequence(radarTutorial, function() prev_object:destroy() end)
addToSequence(radarTutorial, function() prev_object = SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setPosition(5000, 0) end)
addToSequence(radarTutorial, function() prev_object2 = SpaceStation():setTemplate("Large Station"):setFaction("Independent"):setPosition(5000, 5000) end)
addToSequence(radarTutorial, function() prev_object3 = SpaceStation():setTemplate("Huge Station"):setFaction("Kraylor"):setPosition(5000, -5000) end)
addToSequence(radarTutorial, [[This large dot is a station. Stations come in different size and can belong to different factions. The color indicates if the station is friendly (green), neutral (light blue) or enemy (red)]])
addToSequence(radarTutorial, function() prev_object:destroy() end)
addToSequence(radarTutorial, function() prev_object2:destroy() end)
addToSequence(radarTutorial, function() prev_object3:destroy() end)
addToSequence(radarTutorial, function() prev_object = Nebula():setPosition(8000, 0) end)
addToSequence(radarTutorial, [[The rainbow colored cloud is a nebula. Nebulea block long range sensors. So you cannot see inside of them when you are more then 5km away from them, and you cannot see behind it.]])
addToSequence(radarTutorial, function() prev_object:destroy() end)
addToSequence(radarTutorial, function() prev_object = CpuShip():setFaction("Human Navy"):setTemplate("Cruiser"):setPosition(5000, -2500):orderIdle():setScanned(true) end)
addToSequence(radarTutorial, function() prev_object2 = CpuShip():setFaction("Independent"):setTemplate("Cruiser"):setPosition(5000, 2500):orderIdle():setScanned(true) end)
addToSequence(radarTutorial, function() prev_object3 = CpuShip():setFaction("Kraylor"):setTemplate("Cruiser"):setPosition(5000, -7500):orderIdle():setScanned(true) end)
addToSequence(radarTutorial, function() prev_object4 = CpuShip():setFaction("Kraylor"):setTemplate("Cruiser"):setPosition(5000, 7500):orderIdle():setScanned(false) end)
addToSequence(radarTutorial, [[Finally we have ships. They look like you, and come in the same colors as the stations. Except for the 4th one. This one is grey, meaning you do not know if they are enemy or friendly.]])
addToSequence(radarTutorial, function() prev_object:destroy() end)
addToSequence(radarTutorial, function() prev_object2:destroy() end)
addToSequence(radarTutorial, function() prev_object3:destroy() end)
addToSequence(radarTutorial, function() prev_object4:destroy() end)
addToSequence(radarTutorial, [[Next we will look at the short range radar.]])
addToSequence(radarTutorial, function() tutorial:switchViewToTactical() end)
addToSequence(radarTutorial, [[The short range radar will see up to 5km. You also see the range of your own beam weapons.
Your current ship has 2 beam weapons aimed to the front. Different ships will have different beam weapon layouts, with different ranges and locations.]])
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
The helms officer is in command of the movement of your ship. Your basic task is to move the ship around in space.]])
addToSequence(helmsTutorial, function() player:setImpulseMaxSpeed(90) end)
addToSequence(helmsTutorial, [[Your primary controls are your impulse engines and maneuvering.
Your impulse controls are on the left side of the screen.

Raise your impulse level to 100% to fly forwards right now.]], function() x, y = player:getPosition() return math.sqrt(x * x + y * y) > 1000 end)
addToSequence(helmsTutorial, function() player:setImpulseMaxSpeed(0):commandImpulse(0):setRotationMaxSpeed(10) end)
addToSequence(helmsTutorial, [[Good. You now know how to move forwards.

I've disabled your impulse engine for now. Next we look at rotating your ship.
Rotating the ship is easy, just press anywhere on the radar screen to rotate to that heading.
Try rotating to heading 200 right now.]], function() return math.abs(player:getHeading() - 200) < 1.0 end)
addToSequence(helmsTutorial, function() player:setImpulseMaxSpeed(90) end)
addToSequence(helmsTutorial, function() prev_object = SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setPosition(0, -1500) end)
addToSequence(helmsTutorial, [[Excelent!

Next up. Docking. Docking is important, as being docked with a station will recharge your energy, repairs your hull and allows the relay officer to request weapon refills. It can also be important for other mission related events.
To dock, get within 1km of a station, and press the "Request Dock" button. Docking is fully automated after that.
Dock with the nearby station now.]], function() return player:isDocked(prev_object) end)
addToSequence(helmsTutorial, [[Now that you are docked, movement is locked. As helms officer there is nothing else you can do.
So undock now.]], function() return not player:isDocked(prev_object) end)
addToSequence(helmsTutorial, function() prev_object:destroy() end)
addToSequence(helmsTutorial, function() prev_object = CpuShip():setFaction("Kraylor"):setTemplate("Tug"):setPosition(-1500, 1500):orderIdle():setScanned(true) end)
addToSequence(helmsTutorial, function() player:commandSetTarget(prev_object) end)
addToSequence(helmsTutorial, [[Ok, just a few extra things that you need to know.
Remember those beam weapons? As helms officer is it your task to keep those beams on your target.
I've setup an stationary enemy ship as target. Destroy it with your beam weapons.]], function() return not prev_object:isValid() end)
addToSequence(helmsTutorial, [[Aggression is not always the solution. But boy it is fun.

On to the next task. Moving long distances.
To move long distances there are two methods. Depending on your ship you can have a warp drive, or a jump drive.
The warp drive moves your ship at high speed. The jump drive instantly teleports your ship a great distance.]])
addToSequence(helmsTutorial, function() player:setWarpDrive(true) end)
addToSequence(helmsTutorial, [[First, let us try the warp drive.

It works almost the same as the impulse drive, but can only move forwards. However, much faster at a greater energy use.
Use the warp drive to move at least 30km away from your starting point.]], function() x, y = player:getPosition() return math.sqrt(x * x + y * y) > 30000 end)
addToSequence(helmsTutorial, function() player:setWarpDrive(false):setJumpDrive(true):setPosition(0, 0) end)
addToSequence(helmsTutorial, [[Now. That was the warp drive. Next up, the jump drive.

The jump drive you need to configure a distance you want to jump. And then you need to initiate it. You jump into the direction where your ship is pointing at the time of which the jump actually happens.
Use the jump drive to jump at least 30km from your start point, in any direction.]], function() x, y = player:getPosition() return math.sqrt(x * x + y * y) > 30000 end)
addToSequence(helmsTutorial, [[Notice how your jump drive needs to re-charge after use.

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
The weapons officer controls the weapon systems of your ship. As weapons officer you are responsible for setting the target for your beam weapons. Loading and firing missile weapons, and control if the shields are up or down.]])
addToSequence(weaponsTutorial, function() prev_object = CpuShip():setFaction("Kraylor"):setTemplate("Cruiser"):setPosition(700, 0):setRotation(0):orderIdle():setScanned(true) end)
addToSequence(weaponsTutorial, [[First most, your most important task is setting targets.
Setting a target is important because your beam weapons will only fire on your selected target. And missiles will home towards your selected target.

Target the ship in front of you right now. You do this by pressing on it.]], function() return player:getTarget() == prev_object end)
addToSequence(weaponsTutorial, [[Good, notice that your beam weapons did not fire on this ship till you targeted it.

Next up, shield controls.]])
addToSequence(weaponsTutorial, function() prev_object:destroy() end)
addToSequence(weaponsTutorial, function() prev_object = CpuShip():setFaction("Kraylor"):setTemplate("Cruiser"):setPosition(-700, 0):setRotation(0):orderAttack(player):setScanned(true) end)
addToSequence(weaponsTutorial, [[Now, as you might notice, you are being shot at. Do not worry, you cannot die right now.

But you are taking damage. So enable your shields to protect yourself.]], function()
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
addToSequence(weaponsTutorial, [[Shields protect your ship from direct damage. But they cost extra energy to keep up.
They also have a limited amount of damage they can take. And take a long time to recharge. So, eventually, this enemy will get trough your shields.

Disable your shields again to continue.]], function() return not player:getShieldsActive() end)
addToSequence(weaponsTutorial, function() prev_object:destroy() end)
addToSequence(weaponsTutorial, [[While only a single button. Your shields are vital for survival. They protect against all kinds of damage, beam weapons, missiles, astroids, mines. So see them as your primary priority.

Next up, the real fun starts. Missile weapons.]])

addToSequence(weaponsTutorial, function()
    player:setWeaponStorageMax("homing", 1)
    player:setWeaponStorage("homing", 1)
    player:setWeaponTubeCount(1)
    prev_object = CpuShip():setFaction("Kraylor"):setTemplate("Tug"):setPosition(3000, 0):setRotation(0):orderIdle():setScanned(true)
    prev_object:setHull(1):setShieldsMax(1) -- Make it die in 1 shot.
end)
addToSequence(weaponsTutorial, [[Now, you have 1 homing missile in your missile storage now.
You can load this missile into a weapon tube. Currently you have 1 weapon tube. But depending on your ship type you can have more.

Load this homing missile into the missile tube by first selecting the homing missile, and then press the load button for this tube. Note that it will take some time to load missiles into tubes.]],
    function() return player:getWeaponTubeLoadType(0) == "homing" end)
addToSequence(weaponsTutorial, [[Great. You can now fire this missile by clicking on the tube.]], function() return player:getWeaponTubeLoadType(0) == nil end)
addToSequence(weaponsTutorial, [[Missile away!]], function() return not prev_object:isValid() end)
addToSequence(weaponsTutorial, function() prev_object = CpuShip():setFaction("Kraylor"):setTemplate("Tug"):setPosition(2000, -2000):setRotation(0):orderIdle():setScanned(true):setHull(1):setShieldsMax(1) end)
addToSequence(weaponsTutorial, function() tutorial:setMessageToBottomPosition() end)
addToSequence(weaponsTutorial, [[BOOM! That was just straight firing. But you can also aim missiles.

First, unlock the missile aiming by pressing the [lock] button above the radar view.
Next, you can aim your missiles with the aiming dial around the radar.
Use this to destroy the next ship.]], function()
    if player:getWeaponStorage("homing") < 1 then
        player:setWeaponStorage("homing", 1)
    end
    return not prev_object:isValid()
end)
addToSequence(weaponsTutorial, function() prev_object = CpuShip():setFaction("Kraylor"):setTemplate("Tug"):setPosition(-1550, -1900):setRotation(0):orderIdle():setScanned(true):setHull(1):setShieldsMax(1) end)
addToSequence(weaponsTutorial, [[Perfect aim!

The next ship is behind you. You need to target it first, because homing missiles will home in on your selected target.
While not extremely helpful on a stationary target. It can make all the difference on a moving target.]], function()
    if player:getWeaponStorage("homing") < 1 then
        player:setWeaponStorage("homing", 1)
    end
    return not prev_object:isValid()
end)
addToSequence(weaponsTutorial, function() player:setWeaponStorage("homing", 0):setWeaponStorageMax("homing", 0) end)
addToSequence(weaponsTutorial, function() tutorial:setMessageToTopPosition() end)
addToSequence(weaponsTutorial, [[Next to homing missiles, you have Nukes, EMPs and Mines. Nukes and EMPs fire the same as homing missiles. But have a 1km blast radius, and do a lot of damage. EMPs only damage shields, and thus are great to initial damage enemies with lots of shielding.]])
addToSequence(weaponsTutorial, function() startSequence(engineeringTutorial) end)

engineeringTutorial = createSequence()
addToSequence(engineeringTutorial, function() 
    tutorial:switchViewToScreen(2)
    tutorial:setMessageToTopPosition()
    resetPlayerShip()
end)
addToSequence(engineeringTutorial, [[Welcome to engineering.
Engineering is split into two parts. The top part shows the interior of your ship, and has damage control teams walking around.
The bottom part controls power and coolant levels of different ship systems.]])
addToSequence(engineeringTutorial, function() player:setSystemHeat("warp", 0.8) end)
addToSequence(engineeringTutorial, [[We will go over the power and coolant systems first.
Each row on the bottom area of the screen represents 1 system that you can put extra power in and control the coolant level.
Each system has a damage level, heat level, power level and coolant level.

I've overheated your warp system, you can fix this by putting coolant in your warp system. Select the warp system and increase the coolant slider.]], function() return player:getSystemHeat("warp") < 0.05 end)
addToSequence(engineeringTutorial, function() player:setSystemHeat("impulse", 0.8) end)
addToSequence(engineeringTutorial, [[I've also overheated the impulse system now. Do the same to fix this. Note that the coolant from the warp system is removed to allow for coolant in the impulse system.

This is because you have a limited amount of coolant available in your ship. You will have to distribute this over your systems.]], function() return player:getSystemHeat("impulse") < 0.05 end)
addToSequence(engineeringTutorial, [[Good.
Next up, power levels. You can increase and lower the power level of each system. This causes the system to run more or less effective. If more power is put into a system it will generate more heat, and thus will require coolant at a certain point.
If a system overheats, it will get damage. But let us focus on power first.

Increase the power of the front shield system to max.]], function() return player:getSystemPower("frontshield") > 2.5 end)
addToSequence(engineeringTutorial, [[As you will notice, the added power in the shield system will increase the amount of heat in the system.

Now wait till the system is overheating.]], function() return player:getSystemHealth("beamweapons") < 0.5 end)
addToSequence(engineeringTutorial, function() player:commandSetSystemPower("beamweapons", 0.0) end)
addToSequence(engineeringTutorial, [[Note that because of the overheating system, your system took damage. Because the system is damage, it will function less effectively.

Systems can also be damaged because your ship gets hit while the shields are down.]])
addToSequence(engineeringTutorial, function() tutorial:setMessageToBottomPosition() end)
addToSequence(engineeringTutorial, [[In this top area you see your damage control teams in your ship.]])
addToSequence(engineeringTutorial, [[The front shield system is damaged, indicated by the color of this room.

Select a damage control team, and send it to that room to initiate repairs.]], function() return player:getSystemHealth("beamweapons") > 0.9 end)
addToSequence(engineeringTutorial, function() tutorial:setMessageToTopPosition() end)
addToSequence(engineeringTutorial, [[Good. Now you know your most important tasks. Next we'll go over each system in detail.
Remember, each system will function better with more power in it, but less well when it is damaged. Your task is keeping vital systems running as good as you can.]])
addToSequence(engineeringTutorial, [[Reactor:

The reactor generates energy. More power in the reactor will increase your energy generation.]])
addToSequence(engineeringTutorial, [[Beam Weapons:

Increasing beam power will increase the fire rate of the beam weapons. Which in effect will cause you to do more damage.
Note that every beam fire will put some extra heat into the system that needs to be cooled down.]])
addToSequence(engineeringTutorial, [[Missile System:

Increase missile weapon power will lower the reload time of missile tubes.]])
addToSequence(engineeringTutorial, [[Maneuvering:

Increasing power in the maneuvering system will allow the ship to turn faster. It will also increase the speed of which the combat maneuvering charge reloads.]])
addToSequence(engineeringTutorial, [[Impulse Engines:

More power in the impulse engines will increase your flight speed on impulse engines.]])
addToSequence(engineeringTutorial, [[Warp drive:

Increased warp drive power will increase your warp drive flight speed.]])
addToSequence(engineeringTutorial, [[Jump drive:

The jump drive will charge faster, and will have less delay before jumping when there is more power in the jump drive.]])
addToSequence(engineeringTutorial, [[Shields:

More power in the shield system will increase the recharge rate of shields, and also decrease the amount of shield damage sustained.]])
addToSequence(engineeringTutorial, [[This concludes the basis of the engineering station. Be sure to keep your ship running in top condition!]])
addToSequence(weaponsTutorial, function() startSequence(scienceTutorial) end)

scienceTutorial = createSequence()
addToSequence(scienceTutorial, function()
    tutorial:switchViewToScreen(3)
    tutorial:setMessageToBottomPosition()
    resetPlayerShip()
end)
addToSequence(scienceTutorial, [[Welcome science officer.

You are the eyes of the ship. Your job is to supply the captain with information. As you can see, you can see up to 30km with this radar.]])
addToSequence(scienceTutorial, function() prev_object = SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setPosition(3000, -15000) end)
addToSequence(scienceTutorial, function() prev_object2 = CpuShip():setFaction("Human Navy"):setTemplate("Cruiser"):setPosition(5000, -17000):orderIdle():setScanned(true) end)
addToSequence(scienceTutorial, [[On this radar, you can select objects to get information about them.
I've added a friendly ship, and a station for you to look at. Select them and notice how much information you have about these.
Especially heading and distance are of great importance, as without these, the helms officer will be jumping in the dark.]])
addToSequence(scienceTutorial, function() prev_object:destroy() end)
addToSequence(scienceTutorial, function() prev_object = CpuShip():setFaction("Kraylor"):setTemplate("Cruiser"):setPosition(3000, -15000):orderIdle() end)
addToSequence(scienceTutorial, [[I've replaced the friendly station with an unknown ship. As you select it, you will notice that you do not know anything about this ship.
To learn about it, you need to scan it. Scanning requires you to match up frequency bands of your scanner with your target.
Scan this ship now.]], function() return prev_object:isScanned() end)
addToSequence(scienceTutorial, [[Good. Notice that you now know this ship is an enemy. But it could have been a friendly or neutral ship as well.
Until you scan it, you do not know.]])
addToSequence(scienceTutorial, [[Also note that you have less information on this ship then on the friendly ship. To get all the information, you need to do a deep scan of this ship.
A deep scan takes more effort, and requires you to line up two frequency bands at the same time.
Deep scan the enemy now.]], function() return prev_object:isFullyScanned() end)
addToSequence(scienceTutorial, [[Excelent. Notice that this took you a lot more time then the simple scan.

So plan carefully to only deep scan what is really needed. Or you could be running low on time.]])
addToSequence(scienceTutorial, function() prev_object:destroy() end)
addToSequence(scienceTutorial, function() prev_object2:destroy() end)
addToSequence(scienceTutorial, function() tutorial:setMessageToTopPosition() end)
addToSequence(scienceTutorial, [[Next to the long range radar, the science station also has access to the science database.

In this database you can lookup details on ship types, as well as other information.]])
addToSequence(scienceTutorial, [[Remember, your job is to supply information. Knowning which ships are where and what their status is, is of vital importance for your captain.

Without your info, the crew is mostly blind.]])
addToSequence(scienceTutorial, function() startSequence(relayTutorial) end)

relayTutorial = createSequence()
addToSequence(relayTutorial, function()
    tutorial:switchViewToScreen(4)
    tutorial:setMessageToBottomPosition()
    resetPlayerShip()
end)
addToSequence(relayTutorial, [[Welcome to relay!

It is your job to handle all communications with other ships as well as stations. Next to that, you have short range radars around any friendly ship or station, place waypoints. And can send out scanning probes.]])
addToSequence(relayTutorial, [[Your first task is communications.

You can target any station or ship and attempt to communicate with it. And at times, ships can even contact you.]])
