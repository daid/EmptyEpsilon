--[[                  Dreadnaught
Dreadnaughts are the latest ships.
They are so large and uncommon that every type is pretty much their own subclass.
They usually come with 6 or more shield sections, require a crew of 250+ to operate.

Think: Stardestroyer.
----------------------------------------------------------]]

template = ShipTemplate():setName("Odin"):setClass("Dreadnaught", "Odin"):setModel("space_station_2")
template:setDescription([[The Odin. A class of it's own really.
It is an idea so insane, that it had to work. Atleast that much have the people behind it been thinking.

What it is, it's a large scale space station, with as many guns and missiles strapped to it as possible. And, at it's core a jump drive. Never before has a jumpdrive at this scale been made. And most likely it never will be made again.
It requires 150 personel just to keep the jumpdrive running without going super critical. Powering it up requires 5 days. And a single jump costs enough resources to buy a small moon.

The whole tactic of this machine (as that's the only way to properly describe it) is to jump into an unsuspecting enemy, and destroy everything before they know what hit them. It's effective, destructive, and expensive.]])
template:setJumpDrive(true)
template:setTubes(16, 3.0)
template:setWeaponStorage("Homing", 1000)
for n=0,15 do
    template:setBeamWeapon(n, 90,  n * 22.5, 3200, 3, 10)
    template:setTubeDirection(n, n * 22.5)
end
template:setHull(2000)
template:setShields(1200, 1200, 1200, 1200, 1200, 1200)
template:setSpeed(0, 1, 0)
