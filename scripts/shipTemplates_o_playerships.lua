-- Fighter
template = ShipTemplate():setName("Fighter F967"):setClass("Starfighter", "Interceptors"):setModel("WespeScoutYellow"):setType("playership")
template:setRadarTrace("radar_fighter.png")
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 40, -10, 1000.0, 6.0, 8)
template:setBeam(1, 40,  10, 1000.0, 6.0, 8)
template:setHull(60)
template:setShields(40)
template:setSpeed(40, 10, 20)
template:setCombatManeuver(600, 0)
template:setWarpSpeed(0)
template:setJumpDrive(false)
template:setCloaking(false)
template:setEnergyStorage(400)
template:setTubes(1, 10.0) -- Amount of torpedo tubes, loading time
template:setWeaponStorage("HVLI", 4)

template:addRoomSystem(3, 0, 1, 1, "Maneuver");

template:addDoor(0, 0, false);

-- Starcaller
template = ShipTemplate():setName("Scoutship S392"):setClass("Frigate", "Cruiser"):setModel("space_frigate_6"):setType("playership")
template:setRadarTrace("radar_cruiser.png")
template:setTubes(7, 8.0)
template:setTubeDirection(0,  0):weaponTubeDisallowMissle(0, "Mine")
template:setTubeDirection(1,  0):weaponTubeDisallowMissle(1, "Mine")
template:setTubeDirection(2, 90):setWeaponTubeExclusiveFor(2, "Homing")
template:setTubeDirection(3, 90):setWeaponTubeExclusiveFor(3, "Homing")
template:setTubeDirection(4,-90):setWeaponTubeExclusiveFor(4, "Homing")
template:setTubeDirection(5,-90):setWeaponTubeExclusiveFor(5, "Homing")
template:setTubeDirection(6,180):setWeaponTubeExclusiveFor(6, "Mine")
template:setHull(200)
template:setShields(110, 70)
template:setSpeed(30, 4, 8)
template:setCombatManeuver(450, 150)
template:setWarpSpeed(800)
template:setJumpDrive(false)
template:setCloaking(false)
template:setWeaponStorage("Homing", 30)
template:setWeaponStorage("Nuke", 8)
template:setWeaponStorage("Mine", 12)
template:setWeaponStorage("EMP", 10)

template:addRoomSystem(3, 0, 1, 1, "Maneuver");

template:addDoor(0, 0, false);


-- Odysseus
template = ShipTemplate():setName("Corvette C743"):setClass("Corvette", "Destroyer"):setModel("space_cruiser_4"):setType("playership")
template:setRadarTrace("radar_transport.png")
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 90, -15, 1000.0, 6.0, 10)
template:setBeam(1, 90,  15, 1000.0, 6.0, 10)
-- Setup 3 missile tubes. 2 forward at a slight angle, and 1 in the rear exclusive for mines.
template:setTubes(3, 8.0) -- Amount of torpedo tubes, and loading time of the tubes.
template:setTubeDirection(0, -5):weaponTubeDisallowMissle(0, "Mine")
template:setTubeDirection(1, 5):weaponTubeDisallowMissle(1, "Mine")
template:setTubeDirection(2, 180):setWeaponTubeExclusiveFor(2, "Mine")
template:setDockClasses("Starfighter", "Frigate")
template:setHull(200)
template:setShields(80, 80)
template:setSpeed(45, 4, 10)
template:setWarpSpeed(0)
template:setJumpDrive(true)
template:setCombatManeuver(400, 250)
template:setWeaponStorage("Homing", 12)
template:setWeaponStorage("Nuke", 4)
template:setWeaponStorage("Mine", 8)
template:setWeaponStorage("EMP", 6)

template:addRoomSystem(3, 0, 1, 1, "Maneuver");

template:addDoor(0, 0, false);
 