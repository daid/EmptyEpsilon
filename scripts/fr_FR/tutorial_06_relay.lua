-- Name: Relay
-- Description: [Station Tutorial]
--- -------------------
--- -Goes over relay station.
---
--- [Station Info]
--- -------------------
--- Sector Map: 
--- -The Relay station can view a map of the sector, including space hazards and ships within short-range scanner range (5U). It can also see the short-range sensor data around other friendly ships and stations, potentially spotting distant ships before the science station does. The Relay officer cannot scan ships, however.
---
--- Probes: 
--- -The Relay officer can launch up to 8 high-speed probes to any point in the sector. These probes fly toward a location and transmit short-range sensor data to the ship for 10 minutes. Probes work inside nebulae, and thus are powerful tools when faced with an area blocked by nebula. The Relay officer can also link a probe's sensors to the Science station, which lets the Science officer scan ships within the probe's sensor range even if the probe is beyond the ship's long-range scanners. Probes cannot be retrieved and can be destroyed by enemies; your ship's stock of probes can be replenished only by docking at a station.
---
--- Waypoints: 
--- -The Relay officer can set waypoints around the sector. These waypoints appear on the Helms officer's short-range scanner and can guide the ship toward a destination or on a specific route through space. Waypoints are also necessary when requesting aid from friendly stations.
---
--- Communications: 
--- -The Relay officer can open communications with stations and other ships. Friendly ships hailed by the Relay officer can take orders, and friendly stations can dispatch backup and supply ships. While your ship is docked at a station, the Relay officer can request rearmament of the ship's missiles and mines. Some of these requests can cost some of your crew's reputation, which is also tracked by the Relay station.
-- Type: Basic
require("utils.lua")
require("options.lua")
require(lang .. "/ships.lua")
require(lang .. "/factions.lua")


function init()
    --Create the player ship
    player = PlayerSpaceship():setFaction(humanFaction):setTemplate(phobosM3P)
    tutorial:setPlayerShip(player)

    tutorial:showMessage([[Welcome to the EmptyEpsilon tutorial.
Note that this tutorial is designed to give you a quick overview of the basic options for the game, but does not cover every single aspect.

Press next to continue...]], true)
    tutorial_list = {
        relayTutorial
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
    prev_object = SpaceStation():setTemplate(mediumStation):setFaction(humanFaction):setPosition(3000, -15000)
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
addToSequence(relayTutorial, function() prev_object = CpuShip():setFaction(humanFaction):setTemplate(phobosT3):setPosition(20000, -20000):orderIdle():setCallSign("DMY-01"):setScanned(true) end)
addToSequence(relayTutorial, function() prev_object2 = CpuShip():setFaction(humanFaction):setTemplate(phobosT3):setPosition(-24000, 2500):orderIdle():setScanned(true) end)
addToSequence(relayTutorial, function() prev_object3 = CpuShip():setFaction(humanFaction):setTemplate(phobosT3):setPosition(-17000, -7500):orderIdle():setScanned(true) end)
addToSequence(relayTutorial, function() prev_object4 = CpuShip():setFaction(humanFaction):setTemplate(phobosT3):setPosition(5400, 7500):orderIdle():setScanned(false) end)
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

