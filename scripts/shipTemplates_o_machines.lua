template = ShipTemplate():setName("Machine Fighter"):setClass("Fighter", "Interceptor"):setModel("machine_fighter")
template:setRadarTrace("radar_fighter.png")
template:setHull(30)
template:setShields(30)
template:setSpeed(110, 15, 20)
template:setCombatManeuver(600, 0)
template:setBeam(0, 30, 0, 800.0, 2.0, 4)
template:setEnergyStorage(400)
template:setDefaultAI('fighter')
template:setTubes(1, 8.0) -- Amount of torpedo tubes, loading time
template:setTubeDirection(0, 0)
template:setWeaponStorage("Homing", 250)

template = ShipTemplate():setName("Machine Cruiser"):setClass("Corvette", "Destroyer"):setModel("machine_frigate")
template:setRadarTrace("radar_transport.png")
template:setHull(300)
template:setShields(250, 250)
template:setSpeed(60, 5, 5)
template:setBeam(0, 30, 10, 1500.0, 6.0, 20)
template:setBeam(1, 30, -10, 1500.0, 6.0, 20)
template:setBeam(2, 30, -140, 1200.0, 6.0, 15)
template:setBeam(3, 30, 140, 1200.0, 6.0, 15)
-- template:setDefaultAI('missilevolley')
template:setTubes(5, 8.0) -- Amount of torpedo tubes, and loading time of the tubes.
template:setTubeDirection(0, 0)
template:setTubeDirection(1, -45)
template:setTubeDirection(2, 45)
template:setTubeDirection(3, 120)
template:setTubeDirection(4, -120)
template:setWeaponStorage("Homing", 200)
template:setWeaponStorage("EMP", 20)

template = ShipTemplate():setName("Machine Frigate"):setClass("Frigate", "Cruiser"):setModel("machine_cruiser")
template:setRadarTrace("radar_dread.png")
template:setHull(1200)
template:setShields(800, 800, 800, 800)
template:setSpeed(40, 2, 2)
template:setBeam(0, 10, 0, 3000.0, 6.0, 50)
template:setBeam(1, 30, 15, 1500.0, 6.0, 30)
template:setBeam(2, 30, -15, 1500.0, 6.0, 30)
template:setBeam(3, 40, -140, 1200.0, 6.0, 15)
template:setBeam(4, 40, 140, 1200.0, 6.0, 15)
template:setBeam(5, 30, 180, 1000.0, 6.0, 10)
-- template:setDefaultAI('missilevolley')
template:setTubes(10, 4.0) -- Amount of torpedo tubes, and loading time of the tubes.
template:setTubeDirection(0, 5)
template:setTubeDirection(1, -5)
template:setTubeDirection(2, -15)
template:setTubeDirection(3, 15)
template:setTubeDirection(4, -45)
template:setTubeDirection(5, 45)
template:setTubeDirection(6, -90)
template:setTubeDirection(7, 90)
template:setTubeDirection(8, -120)
template:setTubeDirection(9, 120)
template:setWeaponStorage("Homing", 500)
template:setWeaponStorage("EMP", 20)









template = ShipTemplate():setName("Machine Mothership"):setClass("Dreadnaught", "Odin"):setModel("machine_mother")
template:setRadarTrace("radartrace_hugestation.png")
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
