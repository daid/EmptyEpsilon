--[[                  Dreadnaught
Dreadnaughts are the largest ships.
They are so large and uncommon that every type is pretty much their own subclass.
They usually come with 6 or more shield sections, require a crew of 250+ to operate.

Think: Stardestroyer.
----------------------------------------------------------]]

template = ShipTemplate():setName("Odin"):setClass("Dreadnaught", "Odin"):setModel("space_station_2")
template:setRadarTrace("radartrace_largestation.png")
template:setDescription([[The Odin is a "ship" so large and unique that it's almost a class of its own.

The ship is often nicknamed the "all-father", a name that aptly describes the many roles this ship can fulfill. It's both a supply station and an extremely heavily armored and shielded weapon station capable of annihilating small fleets on its own.

Odin's core contains the largest jump drive ever created. About 150 support crew are needed to operate the jump drive alone, and it takes 5 days of continuous operation to power it.

Due to the enormous cost of this dreadnaught, only the richest star systems are able to build and maintain ships like the Odin. 

This machine's primary tactic is to jump into an unsuspecting enemy system and destroy everything before they know what hit them. It's effective and destructive, but extremely expensive.]])
template:setDockClasses("Drone")
-- template:setJumpDrive(true)
template:setTubes(16, 3.0)
template:setWeaponStorage("Homing", 1000)
for n=0,15 do
    template:setBeamWeapon(n, 90,  n * 22.5, 3200, 3, 10)
    template:setTubeDirection(n, n * 22.5)
end
template:setHull(2000)
template:setShields(1200, 1200, 1200, 1200, 1200, 1200)
template:setSpeed(0, 1, 0)
