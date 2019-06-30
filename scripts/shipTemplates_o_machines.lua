template = ShipTemplate():setName("Machine Fighter"):setClass("Fighter", "Interceptor"):setModel("machine_fighter")
template:setRadarTrace("radar_fighter.png")
template:setHull(100)
template:setShields(300)
template:setSpeed(80, 15, 20)
template:setCombatManeuver(600, 0)
template:setBeam(0, 30, 5, 900.0, 4.0, 2.5)
template:setBeam(1, 30,-5, 900.0, 4.0, 2.5)
template:setEnergyStorage(400)
template:setDefaultAI('fighter')
template:setTubes(2, 6.0) -- Amount of torpedo tubes, loading time
template:setTubeDirection(0, 0)
template:setTubeDirection(1, 0)
template:setWeaponStorage("Homing", 250)




template = ShipTemplate():setName("Machine Cruiser"):setClass("Corvette", "Destroyer"):setModel("machine_frigate")
template:setRadarTrace("radar_transport.png")
template:setHull(500)
template:setShields(300, 300)
template:setSpeed(80, 2, 2)
template:setBeam(0, 40, 10, 1200.0, 6.0, 6)
template:setBeam(1, 40, -10, 1200.0, 6.0, 6)
template:setDefaultAI('missilevolley')
template:setTubes(6, 8.0) -- Amount of torpedo tubes, and loading time of the tubes.
template:setTubeDirection(0, 0)
template:setTubeDirection(1, 0)
template:setTubeDirection(2, -45)
template:setTubeDirection(3, 45)
template:setTubeDirection(4, -180)
template:setTubeDirection(5, 180)
template:setWeaponStorage("Homing", 500)
template:setWeaponStorage("EMP", 500)



template = ShipTemplate():setName("Machine Unknown"):setClass("Dreadnaught", "Odin"):setModel("machine_mother")
template:setRadarTrace("radar_dread.png")
template:setJumpDrive(true)
template:setTubes(16, 3.0)
template:setWeaponStorage("Homing", 1000)
for n=0,15 do
    template:setBeamWeapon(n, 90,  n * 22.5, 3200, 3, 10)
    template:setTubeDirection(n, n * 22.5)
end
template:setHull(2000)
template:setShields(1200, 1200, 1200, 1200, 1200, 1200)
template:setSpeed(50, 1, 0)
