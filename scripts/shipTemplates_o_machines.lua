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



template = ShipTemplate():setName("Machine Cruiser"):setClass("Corvette", "Destroyer"):setModel("machine_frigate")
template:setRadarTrace("radar_transport.png")
template:setHull(500)
template:setShields(300, 300)
template:setSpeed(80, 2, 2)
template:setBeam(0, 40, 170, 1200.0, 6.0, 6)
template:setBeam(1, 40, 190, 1200.0, 6.0, 6)
template:setDefaultAI('missilevolley')



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