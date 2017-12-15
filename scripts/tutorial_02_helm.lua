-- Name: Helm
-- Description: [Station Tutorial]
--- -------------------
--- -Goes over controling movement of the ship.
---
--- [Station Info]
--- -------------------
--- Data: 
--- -In the upper-left corner, the Helms officer's screen displays the ship's energy (max is 1,000), current heading in degrees, and current speed in Units/minute. Below this data are two sliders.
---
--- Engines: 
--- -The left slider controls the impulse engines, from -100% (full reverse) to 0% (full stop) to 100% (full ahead). The right slider controls the ship's high-speed warp or instantly teleporting jump drives, if the ship is equipped with either.
--- -Setting a Heading: The Helms officer has a short-range radar. Pressing inside this radar sets the ship's heading in that direction. If the ship has beam weapons, the radar view includes those weapons' firing arcs to help the Helms officer keep targets in the Weapons officer's sights.
---
--- Jumping: 
--- -A jump drive teleports the ship across the specified distance along its current heading. The ship's impulse engines shut down, and after a countdown the ship disappears from its position and instantly reappears at its destination. Each jump consumes energy, with longer jumps consuming more energy. A standard jump takes 10 seconds to initiate, but depending on how much power is allocated to the drive (and how damaged it is), the time to power the jump might vary.
---
--- Warping: 
--- -A warp drive propels the ship straight ahead several times faster than impulse engines, but drain energy at a much faster rate. A warping ship can still collide with hazards like asteroids and mines, but a ship can enter warp very quickly for rapid escapes and advanced tactical maneuvers.
---
--- Combat Maneuvers: 
--- -For ships capable of performing combat maneuvers, the Helms screen includes up to two special sliders at the bottom right. The vertical slider rapidly increases the ship's forward speed above its maximum cruising speed, but generates lots of heat in the impulse engines and consumes energy quickly. The horizontal slider moves the ship laterally but can quickly overheat the maneuvering system. Combat maneuvers can be exhausted but recharge over time.
---
--- Docking: 
--- -The Helms officer can dock with a friendly or neutral station (or in some cases, a larger ship) when it is within 1U. While docked, the ship can't engage its engines or fire weapons, but its energy recharges faster, repairs take less time, the ship's supply of probes is replenished, and the Relay officer can request missile weapon rearmament. The Helms officer is also responsible for undocking the ship.
---
--- Retrieving Objects: 
--- -The Helms officer is also responsible for piloting the ship into supply drops and other retrievable items to retrieve them.
-- Type: Basic
require("utils.lua")
function init()
    --Create the player ship
    player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Phobos M3P")
    tutorial:setPlayerShip(player)

    tutorial:showMessage([[Welcome to the EmptyEpsilon tutorial.
Note that this tutorial is designed to give you a quick overview of the basic options for the game, but does not cover every single aspect.

Press next to continue...]], true)
    tutorial_list = {
        helmsTutorial
    }
    tutorial:onNext(function()
        tutorial_list_index = 1
        startSequence(tutorial_list[tutorial_list_index])
    end)
end

-- TODO: Need to refactor this region into a utility (*Need help LUA hates me)
--[[ Assist function in creating tutorial sequences --]]
function startSequence(sequence)
    current_sequence = sequence
    current_index = 1
    runNextSequenceStep()
end

function runNextSequenceStep()
    local data = current_sequence[current_index]
    current_index = current_index + 1
    if data == nil then
        tutorial_list_index = tutorial_list_index + 1
        if tutorial_list[tutorial_list_index] ~= nil then
            startSequence(tutorial_list[tutorial_list_index])
        else
            tutorial:finish()
        end
    elseif data["message"] ~= nil then
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
--End Region Tut Utils


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
addToSequence(helmsTutorial, function() prev_object = CpuShip():setFaction("Kraylor"):setTemplate("Flavia"):setPosition(-1500, 1500):orderIdle():setScanned(true):setHull(15):setShieldsMax(15) end)
addToSequence(helmsTutorial, function() player:commandSetTarget(prev_object) end)
addToSequence(helmsTutorial, [[Ok, there are just a few more things that you need to know.
Remember the beam weapons from the basics tutorial? As helms officer, it is your task to keep those beams on your target.
I've set up an stationary enemy ship as a target. Destroy it with your beam weapons. Note that at every shot, the corresponding firing arc will change color.]], function() return not prev_object:isValid() end)
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
