-- Name: Helm
-- Description: [Station Tutorial]
--- -------------------
--- -Goes over controlling movement of the ship.
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
--- -For ships capable of performing combat maneuvers, the Helms screen includes special combat maneuver controls shown at the bottom right. Vertical movement rapidly increases the ship's forward speed above its maximum cruising speed, but generates lots of heat in the impulse engines. Horizontal movement moves the ship laterally but can quickly overheat the maneuvering system. Combat maneuvers can be exhausted but recharge over time.
---
--- Docking: 
--- -The Helms officer can dock with a friendly or neutral station (or in some cases, a larger ship) when it is within 1U. While docked, the ship can't engage its engines or fire weapons, but its energy recharges faster, repairs take less time, the ship's supply of probes is replenished, and the Relay officer can request missile weapon rearmament. The Helms officer is also responsible for undocking the ship.
---
--- Retrieving Objects: 
--- -The Helms officer is also responsible for piloting the ship into supply drops and other retrievable items to retrieve them.
-- Type: Tutorial

require("tutorial/00_all.lua")

function init()
    tutorial_list = {
        helmsTutorial,
        endOfTutorial
    }
    startTutorial()
end
