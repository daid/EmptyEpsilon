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
--- -A powerful, stationary explosive that detonates when a ship moves to within 0.6U of it. The explosion damages all objects within a 1U radius.
--- Beam Weapons: 
--- -The location and range of beam weapons are indicated by red firing arcs originating from the players' ship. After the Weapons officer selects a target, the ship's beam weapons will automatically fire at that target when it is inside a beam's firing arc. The officer can use the frequency selectors at the bottom right, along with data about a target's shield frequencies provided by the Science officer, to remodulate beams to a frequency that deals more damage. Note that you can change the beam frequency instantaneously.
--- -Beam weapons fire at a target's hull by default, but the Weapons officer can also target specific subsystems to disable an enemy. If you simply wish to destroy an enemy, however, it's best left on hull.
---
--- Shields: The Weapons officer is responsible for activating the ship's shields and modulating their frequency. It might be tempting to keep the shields up at all times, but they drain significantly more power when active. Certain shield frequencies are especially resistant to certain beam frequencies, which can also be detected in targets by the Science officer. Unlike beam weapons, however, remodulating the shields' frequency brings them offline for several seconds and leaves the ship temporarily defenseless.
-- Type: Tutorial

require("tutorial/00_all.lua")

function init()
    tutorial_list = {
        weaponsTutorial,
        endOfTutorial
    }
    startTutorial()
end
