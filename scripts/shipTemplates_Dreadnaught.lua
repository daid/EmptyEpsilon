require("options.lua")
require(lang .. "/ships.lua")

--[[                  Dreadnaught
Dreadnaughts are the largest ships.
They are so large and uncommon that every type is pretty much their own subclass.
They usually come with 6 or more shield sections, require a crew of 250+ to operate.

Think: Stardestroyer.
----------------------------------------------------------]]

template = ShipTemplate():setName(odin):setClass(dreadnaught, odin):setModel("Ender Battlecruiser")
template:setRadarTrace("radartrace_largestation.png")
template:setDescription(odinDescription)
template:setJumpDrive(true)
template:setTubes(16, 3.0)
template:setWeaponStorage(homing, 1000)
for n=0,15 do
    template:setBeamWeapon(n, 90,  n * 22.5, 3200, 3, 10)
    template:setTubeDirection(n, n * 22.5)
    template:setTubeSize(0, large)
end
template:setHull(2000)
template:setShields(1200, 1200, 1200, 1200, 1200, 1200)
template:setSpeed(0, 1, 0)
