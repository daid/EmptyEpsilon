-- Name: Engineering
-- Description: [Station Tutorial]
--- -------------------
--- -Goes over controling the power of each station and repairs.
---
--- [Station Info]
--- -------------------
---Power Management: 
--- -The Engineering officer can route power to systems by selecting a system and moving its power slider. Giving a system more power increases its output. For instance, an overpowered reactor produces more energy, overpowered shields reduce more damage and regenerate faster, and overpowered impulse engines increase its maximum speed. Overpowering a system (above 100%) also increases its heat generation and, except for the reactor, its energy draw. Underpowering a system (below 100%) likewise reduces heat output and energy draw.
---
---Coolant Management: 
--- -By adding coolant to a system, the Engineering officer can reduce its temperature and prevent the system from damaging the ship. The ship has an unlimited reseve of coolant, but a finite amount of coolant can be applied at any given time, so the Engineering officer must budget how much coolant each system can receive. A system's change in temperature is indicated by white arrows in the temperature column. The brighter an arrow is, the larger the trend.
---
---Repairs: 
--- -When systems are damaged by being shot, colliding with space hazards, or overheating, the Engineering officer can dispatch repair crews to the system for repairs. Each systems has a damage state between -100% to 100%. Systems below 100% function suboptimally, in much the same way as if they are underpowered. Once a system is at or below 0%, it completely stops functioning until it is repaired. Systems can be repaired by sending a repair crew to the room containing the system. Hull damage affects the entire ship, and docking at a station can repair it, but hull repairs progress very slowly.
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
        engineeringTutorial

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
(Repairs will take a while.)]], function() player:commandSetSystemPowerRequest("frontshield", 0.0) return player:getSystemHealth("frontshield") > 0.9 end)
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
