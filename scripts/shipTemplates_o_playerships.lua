-- Fighter
template = ShipTemplate():setName("Fighter F967"):setClass("Starfighter", "Interceptors"):setModel("eoc_fighter"):setType("playership")
template:setRadarTrace("radar_fighter.png")
--             Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 40, -10, 1000.0, 6.0, 8)
template:setHull(60)
template:setShields(500)
template:setSpeed(40, 10, 20)
template:setCombatManeuver(1200, 0)
template:setWarpSpeed(0)
template:setJumpDrive(false)
template:setCloaking(false)
template:setEnergyStorage(400)
template:setTubes(2, 4.0) -- Amount of torpedo tubes, loading time
template:setTubeDirection(0, 0)
template:setTubeDirection(1, 0)
template:setWeaponStorage("Homing", 250)
template:addRoomSystem(3, 0, 1, 1, "Maneuver");
template:addDoor(0, 0, false);

-- Starcaller
template = ShipTemplate():setName("Scoutship S392"):setClass("Frigate", "Cruiser"):setModel("eoc_frigate"):setType("playership")
template:setRadarTrace("radar_cruiser.png")
template:setTubes(7, 8.0)
template:setTubeDirection(2, 90)
template:setTubeDirection(3, 90)
template:setTubeDirection(4,-90)
template:setTubeDirection(5,-90)
template:setHull(200)
template:setShields(500, 500)
template:setSpeed(20, 4, 8)
template:setCombatManeuver(450, 150)
template:setWarpSpeed(800)
template:setJumpDrive(false)
template:setCloaking(false)
template:setEnergyStorage(400)
template:setWeaponStorage("Homing", 200)


template:addRoomSystem(3, 0, 1, 1, "Maneuver");


template:addDoor(0, 0, false);


-- Odysseus
template = ShipTemplate():setName("Corvette C743"):setClass("Corvette", "Destroyer"):setModel("eoc_odysseus"):setType("playership")
template:setRadarTrace("radar_transport.png")
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 0, -15, 1000.0, 6.0, 10)
template:setTubes(6, 8.0) -- Amount of torpedo tubes, and loading time of the tubes.
template:setTubeDirection(0, 0)
template:setTubeDirection(1, 0)
template:setTubeDirection(2, -45)
template:setTubeDirection(3, 45)
template:setTubeDirection(4, -180)
template:setTubeDirection(5, 180)


template:setDockClasses("Starfighter", "Frigate")
template:setHull(200)
template:setShields(500, 500)
template:setSpeed(15, 4, 10)
template:setWarpSpeed(0)
template:setJumpDrive(false)
template:setEnergyStorage(400)
template:setCombatManeuver(200, 100)
template:setWeaponStorage("Homing", 500)
template:setWeaponStorage("EMP", 500)

template:addRoomSystem(3, 0, 1, 1, "Maneuver");

template:addDoor(0, 0, false);

 