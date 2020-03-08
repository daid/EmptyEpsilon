-- Name: Weapons
-- Description: [Station Tutorial]
--- -------------------
--- -Goes over weapon controls
---
--- [Station Info]
--- -------------------
--- Data: 
--- -In the upper-left corner, the Weapons officer's screen displays the ship's energy (max is 1,000), and the strength of its front and rear shields.
---
--- Targeting:
--- -To fire beam weapons and target guided missile weapons, the Weapons officer can select ships on the screen's short-range radar.
---
--- Missiles:
--- -Missiles are one of a ship's most destructive weapons. Before a missile can be fired, the Weapons officer selects it, then selects one of the weapon tubes to load it. Loading and unloading weapon tubes takes time. Mines are also loaded into a special type of weapon tube. Weapon tubes face a specific direction, and some ships only have tubes on certain sides of a ship, making cooperation with the helms officer's maneuvers especially important.
--- -To fire a missile, the Weapons officer presses a loaded missile tube. Except for HVLIs, missiles home in on any target selected by the Weapons officer. Otherwise, the missile is dumb-fired and flies in a straight line from its tube. The Weapons officer can choose to lock the tube's aim onto a target or click the Lock button to the top right of the radar to manually angle a shot.
---
--- Weapon Types:
--- Homing: 
--- -A simple, high-speed missile with a small warhead.
--- Nuke: 
--- -A powerful homing missile that deals tremendous damage to all ships within 1U of its detonation.
--- Electromagentic Pulse (EMP): 
--- -A homing missile that deals powerful damage to the shields of all ships within 1U of detonation, but doesn't damage physical systems or hulls.
--- High-velocity Lead Impactor (HVLI): 
--- -A group of 5 simple lead slugs fired in a single burst at extremely high velocity. These bolts don't home in on an enemy target.
--- Mine: 
--- -A powerful, stationary explosive that detonates when a ship moves to within 1U of it. The explosion damages all objects within a 1U radius.
--- Beam Weapons: 
--- -The location and range of beam weapons are indicated by red firing arcs originating from the players' ship. After the Weapons officer selects a target, the ship's beam weapons will automatically fire at that target when it is inside a beam's firing arc. The officer can use the frequency selectors at the bottom right, along with data about a target's shield frequencies provided by the Science officer, to remodulate beams to a frequency that deals more damage. Note that you can change the beam frequency instantaneously.
--- -Beam weapons fire at a target's hull by default, but the Weapons officer can also target specific subsystems to disable an enemy. If you simply wish to destroy an enemy, however, it's best left on hull.
---
--- Shields: The Weapons officer is responsible for activating the ship's shields and modulating their frequency. It might be tempting to keep the shields up at all times, but they drain significantly more power when active. Certain shield frequencies are especially resistant to certain beam frequencies, which can also be detected in targets by the Science officer. Unlike beam weapons, however, remodulating the shields' frequency brings them offline for several seconds and leaves the ship temporarily defenseless.
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
        weaponsTutorial
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
addToSequence(weaponsTutorial, function() prev_object = CpuShip():setFaction(kraylorFaction):setTemplate(hornetMT52):setPosition(700, 0):setRotation(0):orderIdle():setScanned(true) end)
addToSequence(weaponsTutorial, [[Your most fundamental task is to target your ship's weapons.
Your beam weapons only fire at your selected target, and homing missiles travel toward your selected target.

Target the ship in front of you by pressing it.]], function() return player:getTarget() == prev_object end)
addToSequence(weaponsTutorial, [[Good! Notice that your beam weapons did not fire on this ship until you targeted it.

Next up: shield controls.]])
addToSequence(weaponsTutorial, function() prev_object:destroy() end)
addToSequence(weaponsTutorial, function() prev_object = CpuShip():setFaction(kraylorFaction):setTemplate(hornetMT52):setPosition(-700, 0):setRotation(0):orderAttack(player):setScanned(true) end)
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
    prev_object = CpuShip():setFaction(kraylorFaction):setTemplate(flavia):setPosition(3000, 0):setRotation(0):orderIdle():setScanned(true)
    prev_object:setHull(1):setShieldsMax(1) -- Make it die in 1 shot.
end)
addToSequence(weaponsTutorial, [[You have 1 homing missile in your missile storage now, and 1 weapon tube.
You can load this missile into your weapon tube. Depending on your ship type, you might have more types of missiles and more weapon tubes.

Load this homing missile into the weapon tube by selecting the homing missile, and then pressing the load button for this tube. Note that it takes some time to load missiles into tubes.]],
    function() return player:getWeaponTubeLoadType(0) == "homing" end)
addToSequence(weaponsTutorial, [[Great! Now fire this missile by clicking on the tube.]], function() return player:getWeaponTubeLoadType(0) == nil end)
addToSequence(weaponsTutorial, [[Missile away!]], function() return not prev_object:isValid() end)
addToSequence(weaponsTutorial, function() prev_object = CpuShip():setFaction(kraylorFaction):setTemplate(flavia):setPosition(2000, -2000):setRotation(0):orderIdle():setScanned(true):setHull(1):setShieldsMax(1) end)
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
addToSequence(weaponsTutorial, function() prev_object = CpuShip():setFaction(kraylorFaction):setTemplate(flavia):setPosition(-1550, -1900):setRotation(0):orderIdle():setScanned(true):setHull(1):setShieldsMax(1) end)
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
