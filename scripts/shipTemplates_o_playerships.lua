-- Fighter
template = ShipTemplate():setName("Fighter F967"):setClass("Starfighter", "Interceptors"):setModel("eoc_fighter"):setType("playership")
template:setRadarTrace("radar_fighter.png")
--             Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 30, 0, 1200.0, 2.0, 30)
template:setHull(200)
template:setShields(400)
template:setSpeed(80, 20, 40)
template:setCombatManeuver(600, 150)
template:setWarpSpeed(0)
template:setJumpDrive(false)
template:setCloaking(false)
template:setEnergyStorage(400)
template:setTubes(2, 10.0) -- Amount of torpedo tubes, loading time
template:setTubeDirection(0, 0)
template:setTubeDirection(1, 0)
template:setWeaponStorage("Homing", 250)

template:setRepairCrewCount(0)
--	(H)oriz, (V)ert	   HC,VC,HS,VS, system    (C)oordinate (S)ize
template:addRoomSystem( 0, 1, 1, 2, "Impulse")
template:addRoomSystem( 1, 0, 2, 1, "RearShield")
template:addRoomSystem( 1, 1, 2, 2, "JumpDrive")
template:addRoomSystem( 1, 3, 2, 1, "FrontShield")
template:addRoomSystem( 3, 0, 2, 1, "Beamweapons")
template:addRoomSystem( 3, 1, 3, 1, "Warp")
template:addRoomSystem( 3, 2, 3, 1, "Reactor")
template:addRoomSystem( 3, 3, 2, 1, "MissileSystem")
template:addRoomSystem( 6, 1, 1, 2, "Maneuver")

-- (H)oriz, (V)ert H, V, true = horizontal
template:addDoor( 1, 1, false)
template:addDoor( 2, 1, true)
template:addDoor( 1, 3, true)
template:addDoor( 3, 2, false)
template:addDoor( 4, 3, true)
template:addDoor( 6, 1, false)
template:addDoor( 4, 2, true)
template:addDoor( 4, 1, true)


-- Starcaller
template = ShipTemplate():setName("Scoutship S392"):setClass("Frigate", "Cruiser"):setModel("eoc_frigate"):setType("playership")
template:setRadarTrace("radar_striker.png")
--             Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 30, 0, 1500.0, 4.0, 50)
template:setTubes(4, 8.0)
template:setTubeDirection(0, 0)
template:setTubeDirection(1, 0)
template:setTubeDirection(2, 45)
template:setTubeDirection(3,-45)
template:setHull(200)
template:setShields(300, 300)
template:setSpeed(30, 10, 10)
template:setCombatManeuver(300, 50)
template:setJumpDrive(false)
template:setCloaking(false)
template:setEnergyStorage(600)
template:setWeaponStorage("Homing", 250)


template:setRepairCrewCount(0)
--	(H)oriz, (V)ert	   HC,VC,HS,VS, system    (C)oordinate (S)ize
template:addRoomSystem( 0, 1, 1, 2, "Impulse")
template:addRoomSystem( 1, 0, 2, 1, "RearShield")
template:addRoomSystem( 1, 1, 2, 2, "JumpDrive")
template:addRoomSystem( 1, 3, 2, 1, "FrontShield")
template:addRoomSystem( 3, 0, 2, 1, "Beamweapons")
template:addRoomSystem( 3, 1, 3, 1, "Warp")
template:addRoomSystem( 3, 2, 3, 1, "Reactor")
template:addRoomSystem( 3, 3, 2, 1, "MissileSystem")
template:addRoomSystem( 6, 1, 1, 2, "Maneuver")

-- (H)oriz, (V)ert H, V, true = horizontal
template:addDoor( 1, 1, false)
template:addDoor( 2, 1, true)
template:addDoor( 1, 3, true)
template:addDoor( 3, 2, false)
template:addDoor( 4, 3, true)
template:addDoor( 6, 1, false)
template:addDoor( 4, 2, true)
template:addDoor( 4, 1, true)



-- Odysseus
template = ShipTemplate():setName("Corvette C743"):setClass("Corvette", "Destroyer"):setModel("eoc_odysseus"):setType("playership")
template:setRadarTrace("radar_transport.png")
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 40, 0, 2000.0, 4.0, 100)
template:setTubes(6, 8.0) -- Amount of torpedo tubes, and loading time of the tubes.
template:setTubeDirection(0, 0)
template:setTubeDirection(1, 0)
template:setTubeDirection(2, -35)
template:setTubeDirection(3, 35)
template:setTubeDirection(4, -160)
template:setTubeDirection(5, 160)
-- template:setDockClasses("Starfighter", "Frigate")
template:setHull(400)
template:setShields(600, 600)
template:setSpeed(20, 8, 10)
template:setWarpSpeed(0)
template:setJumpDrive(false)
template:setEnergyStorage(1000)
template:setCombatManeuver(500, 150)
template:setWeaponStorage("Homing", 500)
template:setWeaponStorage("EMP", 500)

template:setRepairCrewCount(0)
--	(H)oriz, (V)ert	   HC,VC,HS,VS, system    (C)oordinate (S)ize
template:addRoomSystem( 4, 0, 2, 1, "Impulse")
template:addRoomSystem( 4, 6, 2, 1, "Impulse")
template:addRoomSystem( 6, 0, 2, 1, "Maneuver")
template:addRoomSystem( 6, 6, 2, 1, "Maneuver")
template:addRoomSystem( 5, 1, 2, 1, "RearShield")
template:addRoomSystem( 5, 5, 2, 1, "RearShield")
template:addRoomSystem( 4, 2, 4, 3, "Reactor")
template:addRoomSystem( 2, 2, 2, 3, "MissileSystem")
template:addRoomSystem( 1, 2, 1, 3, "FrontShield")
template:addRoomSystem( 0, 2, 1, 3, "Beamweapons")
















--
