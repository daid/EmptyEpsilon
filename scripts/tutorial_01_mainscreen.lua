-- Name: Captian (Main Screen / Radar)
-- Description: [Station Tutorial]
--- -------------------
--- -This goes over the basics of map awareness and radar systems. 
---
--- [Station Info]
--- -------------------
--- Without direct control of the ship, the Captain keeps the crew focused on their goal and makes tactical decisions in combat. 
--- The ship's main screen should be set up on a large monitor or projector so that all players can track their ship's status.
--- 
--- The Captain's tasks include:
--- -Planning the next actions
--- -Co-ordinating combat tactics
--- -Preventing mutiny
--- -Setting priorities
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
        mainscreenTutorial,
		radarTutorial
    }
    tutorial:onNext(function()
        tutorial_list_index = 1
        startSequence(tutorial_list[tutorial_list_index],tutorial)
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

--[[ Radar explanation tutorial ]]
mainscreenTutorial = createSequence()
addToSequence(mainscreenTutorial, function() tutorial:switchViewToMainScreen() end)
addToSequence(mainscreenTutorial, [[This is the main screen, which displays your ship and the surrounding space.
While you cannot move the ship from this screen, you can use it to visually identify objects.]])

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
endOfTutorial = createSequence()
addToSequence(endOfTutorial, function() tutorial:switchViewToMainScreen() end)
addToSequence(endOfTutorial, [[This concludes main screen and radar tutorial. While we have covered the basics, there are more advanced features in the game that you might discover.]])