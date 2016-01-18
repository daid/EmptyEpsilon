--[[ The tutorial script looks a lot like a normal scenario script.
        Except that it has access to the "tutorial" object.
        This object contains special functions to help explaining the game.
--]]

function init()
    --Create the player ship
    player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Player Cruiser")
    tutorial:setPlayerShip(player)
    tutorial:onNext(function() onNext() end)
    
    tutorial:showMessage([[Welcome to the EmptyEpsilon tutorial.

Press next to continue...]], true)
    onNext = function()
        tutorial:switchViewToMainScreen()
        tutorial:showMessage([[What you see now is the main screen. Here you see your own ship and the world around you.
There is no direction interaction available on this screen. But it allows for visual identification of objects.]], true)
        onNext = startRadarTutorial
    end
end

function startRadarTutorial()
    tutorial:switchViewToLongRange()
    tutorial:showMessage([[Welcome to the long range radar. This radar can see up to 30km from your ship.
At the center you see your own ship. This radar quickly allows you to identify different objects.]], true)
    onNext = function()
        prev_object = Asteroid():setPosition(5000, 0)
        tutorial:showMessage([[Right of your own ship, you see a brown dot. This is an asteroid.
Asteroids should be avoided, as they damage your ship if you fly into them.]], true)
        onNext = function()
            prev_object:destroy()
            prev_object = Mine():setPosition(5000, 0)
            tutorial:showMessage([[The white dot is a mine. Mines trigger when you are close, and then explode with a 1km blast radius. They do a lot of damage. Flying into one without shields will surely kill you.]], true)
            onNext = function()
                prev_object:destroy()
                prev_object = SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setPosition(5000, 0)
                prev_object2 = SpaceStation():setTemplate("Large Station"):setFaction("Independent"):setPosition(5000, 5000)
                prev_object3 = SpaceStation():setTemplate("Huge Station"):setFaction("Kraylor"):setPosition(5000, -5000)
                tutorial:showMessage([[This large dot is a station. Stations come in different size and can belong to different factions. The color indicates if the station is friendly (green), neutral (light blue) or enemy (red)]], true)
                onNext = function()
                    prev_object:destroy()
                    prev_object2:destroy()
                    prev_object3:destroy()
                    prev_object = Nebula():setPosition(8000, 0)
                    tutorial:showMessage([[The rainbow colored cloud is a nebula. Nebulea block long range sensors. So you cannot see inside of them when you are more then 5km away from them, and you cannot see behind it.]], true)
                    onNext = function()
                        prev_object:destroy()
                        prev_object = CpuShip():setFaction("Human Navy"):setTemplate("Cruiser"):setPosition(5000, -2500):orderIdle():setScanned(true)
                        prev_object2 = CpuShip():setFaction("Independent"):setTemplate("Cruiser"):setPosition(5000, 2500):orderIdle():setScanned(true)
                        prev_object3 = CpuShip():setFaction("Kraylor"):setTemplate("Cruiser"):setPosition(5000, -7500):orderIdle():setScanned(true)
                        prev_object4 = CpuShip():setFaction("Kraylor"):setTemplate("Cruiser"):setPosition(5000, 7500):orderIdle():setScanned(false)
                        tutorial:showMessage([[Finally we have ships. They look like you, and come in the same colors as the stations. Except for the 4th one. This one is grey, meaning you do not know if they are enemy or friendly.]], true)
                        onNext = function()
                            prev_object:destroy()
                            prev_object2:destroy()
                            prev_object3:destroy()
                            prev_object4:destroy()
                            tutorial:showMessage([[Next we will look at the short range radar.]], true)
                            onNext = function()
                                tutorial:switchViewToTactical()
                                tutorial:showMessage([[The short range radar will see up to 5km. You also see the range of your own beam weapons.
Your current ship has 2 beam weapons aimed to the front. Different ships will have different beam weapon layouts, with different ranges and locations.]], true)
                                onNext = startWeaponsTutorial--startHelmsTutorial
                            end
                        end
                    end
                end
            end
        end
    end
end

function startHelmsTutorial()
    tutorial:switchViewToScreen(0)
    player:setJumpDrive(false)
    player:setWarpDrive(false)
    player:setImpulseMaxSpeed(0);
    player:setRotationMaxSpeed(0);
    tutorial:showMessage([[This is the helms screen.
The helms officer is in command of the movement of your ship. Your basic task is to move the ship around in space.]], true)
    onNext = function()
        tutorial:showMessage([[Your primary controls are your impulse engines and maneuvering.
Your impulse controls are on the left side of the screen.

Raise your impulse level to 100% to fly forwards right now.]], false)
        player:setImpulseMaxSpeed(90);
        update = function(delta)
            x, y = player:getPosition()
            if math.sqrt(x * x + y * y) > 1000 then
                tutorial:showMessage([[Good. You now know how to move forwards.

I've disabled your impulse engine for now. Next we look at rotating your ship.
Rotating the ship is easy, just press anywhere on the radar screen to rotate to that heading.
Try rotating to heading 200 right now.]], false)
                player:commandImpulse(0)
                player:setImpulseMaxSpeed(0);
                player:setRotationMaxSpeed(10);
                update = function(delta)
                    if math.abs(player:getHeading() - 200) < 1.0 then
                        player:setRotationMaxSpeed(10);
                        player:setImpulseMaxSpeed(90);
                        prev_object = SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setPosition(0, -1500)
                        tutorial:showMessage([[Excelent!

Next up. Docking. Docking is important, as being docked with a station will recharge your energy, and allows the relay officer to request weapon refills. It can also be important for other mission related events.
To dock, get within 1km of a station, and press the "Request Dock" button. Docking is fully automated after that.
Dock with the nearby station now.]], false)
                        update = function(delta)
                            if player:isDocked(prev_object) then
                                tutorial:showMessage([[Now that you are docked, movement is locked. As helms officer there is nothing else you can do.
So undock now.]], false)
                                update = function(delta)
                                    if not player:isDocked(prev_object) then
                                        prev_object:destroy()
                                        prev_object = CpuShip():setFaction("Kraylor"):setTemplate("Tug"):setPosition(-1500, 1500):orderIdle():setScanned(true)
                                        player:commandSetTarget(prev_object)
                                        tutorial:showMessage([[Ok, just a few extra things that you need to know.
Remember those beam weapons? As helms officer is it your task to keep those beams on your target.
I've setup an stationary enemy ship as target. Destroy it with your beam weapons.]], false)
                                        update = function(delta)
                                            if not prev_object:isValid() then
                                                update = nil
                                                tutorial:showMessage([[Aggression is not always the solution. But boy it is fun.

On to the next task. Moving long distances.
To move long distances there are two methods. Depending on your ship you can have a warp drive, or a jump drive.
The warp drive moves your ship at high speed. The jump drive instantly teleports your ship a great distance.]], true)
                                                onNext = function()
                                                    player:setWarpDrive(true)
                                                    tutorial:showMessage([[First, let us try the warp drive.

It works almost the same as the impulse drive, but can only move forwards. However, much faster at a greater energy use.
Use the warp drive to move at least 30km away from your starting point.]], false)
                                                    update = function(delta)
                                                        x, y = player:getPosition()
                                                        if math.sqrt(x * x + y * y) > 30000 then
                                                            player:setWarpDrive(false)
                                                            player:setJumpDrive(true)
                                                            player:setPosition(0, 0)
                                                            tutorial:showMessage([[Now. That was the warp drive. Next up, the jump drive.

The jump drive you need to configure a distance you want to jump. And then you need to initiate it. You jump into the direction where your ship is pointing at the time of which the jump actually happens.
Use the jump drive to jump at least 30km from your start point, in any direction.]], false)
                                                            update = function(delta)
                                                                x, y = player:getPosition()
                                                                if math.sqrt(x * x + y * y) > 30000 then
                                                                    update = nil
                                                                    tutorial:showMessage([[Notice how your jump drive needs to re-charge after use.

This covers the basics of the helms officer.]], true)
                                                                    onNext = startWeaponsTutorial
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function startWeaponsTutorial()
    tutorial:switchViewToScreen(1)
    player:setPosition(0, 0)
    player:setJumpDrive(false)
    player:setWarpDrive(false)
    player:setImpulseMaxSpeed(0)
    player:setRotationMaxSpeed(0)
    player:setRotation(0)
    player:commandTargetRotation(0)
    player:setWeaponStorageMax("homing", 0)
    player:setWeaponStorageMax("nuke", 0)
    player:setWeaponStorageMax("mine", 0)
    player:setWeaponStorageMax("emp", 0)
    
    tutorial:showMessage([[This is the weapons screen.
The weapons officer controls the weapon systems of your ship. As weapons officer you are responsible for setting the target for your beam weapons. Loading and firing missile weapons, and control if the shields are up or down.]], true)
    onNext = function()
        prev_object = CpuShip():setFaction("Kraylor"):setTemplate("Cruiser"):setPosition(700, 0):setRotation(0):orderIdle():setScanned(true)
        tutorial:showMessage([[First most, your most important task is setting targets.
Setting a target is important because your beam weapons will only fire on your selected target. And missiles will home towards your selected target.

Target the ship in front of you right now. You do this by pressing on it.]], false)
        update = function(delta)
            if player:getTarget() == prev_object then
                update = nil
                tutorial:showMessage([[Good, notice that your beam weapons did not fire on this ship till you targeted it.

Next up, shield controls.]], true)
                onNext = function()
                    prev_object:destroy()
                    prev_object = CpuShip():setFaction("Kraylor"):setTemplate("Cruiser"):setPosition(-700, 0):setRotation(0):orderAttack(player):setScanned(true)
                    tutorial:showMessage([[Now, as you might notice, you are being shot at. Do not worry, you cannot die right now.

But you are taking damage. So enable your shields to protect yourself.]], false)
                    update = function(delta)
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
                        if player:getShieldLevel(1) < player:getShieldMax(1) then
                            tutorial:showMessage([[Shields protect your ship from direct damage. But they cost extra energy to keep up.
They also have a limited amount of damage they can take. And take a long time to recharge. So, eventually, this enemy will get trough your shields.

Disable your shields again to continue.]], false)
                            update = function(delta)
                                if not player:getShieldsActive() then
                                    update = nil
                                    prev_object:destroy()
                                    tutorial:showMessage([[While only a single button. Your shields are vital for survival. They protect against all kinds of damage, beam weapons, missiles, astroids, mines. So see them as your primary priority.

Next up, the real fun starts. Missile weapons.]], true)
                                    onNext = weaponsMissileTutorial
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function weaponsMissileTutorial()
    player:setWeaponStorageMax("homing", 1)
    player:setWeaponStorage("homing", 1)
    player:setWeaponTubeCount(1)
    prev_object = CpuShip():setFaction("Kraylor"):setTemplate("Tug"):setPosition(3000, 0):setRotation(0):orderIdle():setScanned(true)
    prev_object:setHull(1):setShieldsMax(1) -- Make it die in 1 shot.
    tutorial:showMessage([[Now, you have 1 homing missile in your missile storage now.
You can load this missile into a weapon tube. Currently you have 1 weapon tube. But depending on your ship type you can have more.

Load this homing missile into the missile tube by first selecting the homing missile, and then press the load button for this tube. Note that it will take some time to load missiles into tubes.]], false)
    update = function(delta)
        if player:getWeaponTubeLoadType(0) == "homing" then
            tutorial:showMessage([[Great. You can now fire this missile by clicking on the tube.]], false)
            update = function(delta)
                if player:getWeaponTubeLoadType(0) == nil then
                    tutorial:showMessage([[Missile away!]], false)
                    update = function(delta)
                        if not prev_object:isValid() then
                            prev_object = CpuShip():setFaction("Kraylor"):setTemplate("Tug"):setPosition(2000, -2000):setRotation(0):orderIdle():setScanned(true)
                            prev_object:setHull(1):setShieldsMax(1) -- Make it die in 1 shot.
                            tutorial:setMessageToBottomPosition()
                            tutorial:showMessage([[BOOM! That was just straight firing. But you can also aim missiles.

First, unlock the missile aiming by pressing the [lock] button above the radar view.
Next, you can aim your missiles with the aiming dial around the radar.
Use this to destroy the next ship.]], false)
                            update = function(delta)
                                if player:getWeaponStorage("homing") < 1 then
                                    player:setWeaponStorage("homing", 1)
                                end
                                if not prev_object:isValid() then
                                    prev_object = CpuShip():setFaction("Kraylor"):setTemplate("Tug"):setPosition(-1550, -1900):setRotation(0):orderIdle():setScanned(true)
                                    prev_object:setHull(1):setShieldsMax(1) -- Make it die in 1 shot.
                                    tutorial:showMessage([[Perfect aim!

The next ship is behind you. You need to target it first, because homing missiles will home in on your selected target.
While not extremely helpful on a stationary target. It can make all the difference on a moving target.]], false)
                                    update = function(delta)
                                        if player:getWeaponStorage("homing") < 1 then
                                            player:setWeaponStorage("homing", 1)
                                        end
                                        if not prev_object:isValid() then
                                            update = nil
                                            tutorial:showMessage([[Next to homing missiles, you have Nukes, EMPs and Mines. Nukes and EMPs fire the same as homing missiles. But have a 1km blast radius, and do a lot of damage. EMPs only damage shields, and thus are great to initial damage enemies with lots of shielding.]], false)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
