-- Name: Science
-- Description: [Station Tutorial]
--- -------------------
--- -Goes over science station.
---
--- [Station Info]
--- -------------------
--- Long-range Radar: 
--- -The Science station has a long-range radar that can locate ships and objects at a distance of up to 25U. The Science officer's most important task is to report the sector's status and any changes within it. On the edge of the radar are colored bands of signal interference that can vaguely suggest the presence of objects or space hazards even further from the ship, but it's up to the Science officer to interpret them.
---
--- Scanning: 
--- -You can scan ships to get more information about them. The Science officer must align two of the ship's scanning frequencies with a target to complete the scan. Most ships are unknown (gray) to your crew at the start of a scenario and must be scanned before they can be identified as a friend (green), foe (red), or neutral (blue). A scan also identifies the ship's type, which the Science officer can use to identify its capabilities in the station's database.
---
--- Deep Scans: 
--- -A second, more difficult scan yields more information about the ship, including its shield and beam frequencies. The Science officer must align both the frequency and modulation of each scan type to complete a deep scan. The helms and weapons screen can also see the firing arcs of deep-scanned ships, which help them guide your ship from being shot by their beams.
---
--- Nebulae: 
--- -Nebulae block the ship's long-range scanner. The Science officer cannot see what's inside or behind them, and while in a nebula the ship's radars cannot detect what's outside of it. These traits make nebulae ideal places to hide for repairs or stage an ambush. To avoid surprises around nebulae, relay information about where you can and cannot see objects to both the Captain and the Relay officer.
---
--- Probe View: 
--- -The Relay officer can launch probes and link one to the Science station. The Science officer can view the probe's short-range sensor data to scan ships within its range, even if the probe is far from the ship's long-range scanners or in a nebula.
---
--- Database: 
--- -The Science officer can access the ship's database of all known ships, as well as data about weapons and space hazards. This can be vital when assessing a ship's capabilities without a deep scan, or for help navigating a black hole, wormhole, or other anomaly.
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
        scienceTutorial
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

