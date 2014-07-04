--[[ Stations --]]
template = ShipTemplate():setName("Small Station"):setMesh("space_station_4.obj", "space_station_4_color.jpg", "space_station_4_specular.jpg", "space_station_4_illumination.jpg"):setScale(10)

--[[ Player ships --]]
template = ShipTemplate():setName("Player Cruiser"):setMesh("space_frigate_6.obj", "space_frigate_6_color.png", "space_frigate_6_specular.png", "space_frigate_6_illumination.png"):setScale(6):setRadius(100)
-- Visual positions of the beams/missiletubes (blender: Y, -X, Z)
template:setBeamPosition(0, -8, -1.6, -2)
template:setBeamPosition(1,  8, -1.6, -2)
template:setTubePosition(0, 0, 18, -3.5)
template:setTubePosition(1, 0, 18, -3.5)
template:addEngineEmitor(0, -18, -1,  0.2, 0.2, 1.0, 4.0)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 90, -15, 1000.0, 6.0, 12)
template:setBeam(1, 90,  15, 1000.0, 6.0, 12)
template:setTubes(2) -- Amount of torpedo tubes
template:setHull(70)
template:setShields(80, 80)
template:setSpeed(60, 10)
template:setWarpSpeed(0)
template:setJumpDrive(true)
template:setCloaking(false)
template:setWeaponStorage("Homing", 8)
template:setWeaponStorage("Nuke", 2)
template:setWeaponStorage("Mine", 6)
template:setWeaponStorage("EMP", 4)

template:addRoomSystem(1, 0, 2, 1, "Maneuver");
template:addRoomSystem(1, 1, 2, 1, "BeamWeapons");
template:addRoom(2, 2, 2, 1);

template:addRoomSystem(0, 3, 1, 2, "RearShield");
template:addRoomSystem(1, 3, 2, 2, "Reactor");
template:addRoomSystem(3, 3, 2, 2, "Warp");
template:addRoomSystem(5, 3, 1, 2, "JumpDrive");
template:addRoom(6, 3, 2, 1);
template:addRoom(6, 4, 2, 1);
template:addRoomSystem(8, 3, 1, 2, "FrontShield");

template:addRoom(2, 5, 2, 1);
template:addRoomSystem(1, 6, 2, 1, "MissileSystem");
template:addRoomSystem(1, 7, 2, 1, "Impulse");

template:addDoor(1, 1, true);
template:addDoor(2, 2, true);
template:addDoor(3, 3, true);
template:addDoor(1, 3, false);
template:addDoor(3, 4, false);
template:addDoor(3, 5, true);
template:addDoor(2, 6, true);
template:addDoor(1, 7, true);
template:addDoor(5, 3, false);
template:addDoor(6, 3, false);
template:addDoor(6, 4, false);
template:addDoor(8, 3, false);
template:addDoor(8, 4, false);

--[[ Neutral or special ship types --]]
--Tug, used for transport of small goods (like weapons)
template = ShipTemplate():setName("Tug"):setMesh("space_tug.obj", "space_tug_color.jpg", "space_tug_illumination.jpg", "space_tug_illumination.jpg"):setScale(6):setRadius(80)
template:addEngineEmitor(-2.1500, -13, 0.3,  0.2, 0.2, 1.0, 2.0)
template:addEngineEmitor( 2.1500, -13, 0.3,  0.2, 0.2, 1.0, 2.0)
template:setHull(50)
template:setShields(20, 20)
template:setSpeed(60, 6)
template:setWeaponStorage("Homing", 5)
template:setWeaponStorage("Nuke", 1)
template:setWeaponStorage("Mine", 3)
template:setWeaponStorage("EMP", 2)

--[[ Enemy ship types --]]
template = ShipTemplate():setName("Fighter"):setMesh("small_fighter_1.obj", "small_fighter_1_color.jpg", "small_fighter_1_specular.jpg", "small_fighter_1_illumination.jpg"):setScale(3):setRadius(40)
-- Visual positions of the beams/missiletubes (blender: Y, -X, Z)
template:setBeamPosition(0, 0, 23, -1.8)
template:addEngineEmitor(0, -8, 0.5,  1.0, 0.2, 0.2, 1.0)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 60, 0, 1000.0, 4.0, 2)
template:setTubes(0) -- Amount of torpedo tubes
template:setHull(50)
template:setShields(30, 30)
template:setSpeed(100, 30)

template = ShipTemplate():setName("Cruiser"):setMesh("space_frigate_6.obj", "space_frigate_6_color.png", "space_frigate_6_specular.png", "space_frigate_6_illumination.png"):setScale(6):setRadius(100)
-- Visual positions of the beams/missiletubes (blender: Y, -X, Z)
template:setBeamPosition(0, -8, -1.6, -2)
template:setBeamPosition(1,  8, -1.6, -2)
template:setTubePosition(0, 0, 18, -3.5)
template:addEngineEmitor(0, -18, -1,  0.2, 0.2, 1.0, 4.0)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 90, -15, 1000.0, 6.0, 4)
template:setBeam(1, 90,  15, 1000.0, 6.0, 4)
template:setTubes(0) -- Amount of torpedo tubes
template:setHull(70)
template:setShields(40, 40)
template:setSpeed(40, 7)

template = ShipTemplate():setName("Missile Cruiser"):setMesh("space_cruiser_4.obj", "space_cruiser_4_color.jpg", "space_cruiser_4_illumination.jpg", "space_cruiser_4_illumination.jpg"):setScale(8):setRadius(100)
-- Visual positions of the beams/missiletubes (blender: Y, -X, Z)
template:setTubePosition(0, -10, 2, -2.3)
template:setTubePosition(1,  10, 2, -2.3)
template:addEngineEmitor(-2.1500, -13, 0.3,  0.2, 0.2, 1.0, 2.0)
template:addEngineEmitor( 2.1500, -13, 0.3,  0.2, 0.2, 1.0, 2.0)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setTubes(1) -- Amount of torpedo tubes
template:setHull(70)
template:setShields(50, 50)
template:setSpeed(40, 6)
template:setWeaponStorage("Homing", 10)


template = ShipTemplate():setName("Adv. Gunship"):setMesh("dark_fighter_6.obj", "dark_fighter_6_color.png", "dark_fighter_6_specular.png", "dark_fighter_6_illumination.png"):setScale(7):setRadius(200)
-- Visual positions of the beams/missiletubes (blender: Y, -X, Z)
template:setBeamPosition(0,-28.2, 21, -2)
template:setBeamPosition(1, 28.2, 21, -2)
template:setTubePosition(0,-7.5, 11, -3)
template:setTubePosition(1, 7.5, 11, -3)
template:addEngineEmitor(-1.5, -28, -5,  1.0, 0.2, 0.2, 2.0)
template:addEngineEmitor( 1.5, -28, -5,  1.0, 0.2, 0.2, 2.0)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 40,-5, 1000.0, 6.0, 4)
template:setBeam(1, 40, 5, 1000.0, 6.0, 4)
template:setTubes(2) -- Amount of torpedo tubes
template:setHull(100)
template:setShields(100, 100)
template:setSpeed(50, 8)
template:setWeaponStorage("Homing", 2)


template = ShipTemplate():setName("Dreadnought"):setMesh("space_cruiser_4.obj", "space_cruiser_4_color.jpg", "space_cruiser_4_illumination.jpg", "space_cruiser_4_illumination.jpg"):setScale(16):setRadius(200)
-- Visual positions of the beams/missiletubes (blender: Y, -X, Z)
template:setBeamPosition(0, -10, 2, -2.3)
template:setBeamPosition(1,  10, 2, -2.3)
template:setBeamPosition(2, -10, 2, -2.3)
template:setBeamPosition(3,  10, 2, -2.3)
template:setTubePosition(0, -10, 2, -2.3)
template:setTubePosition(1,  10, 2, -2.3)
template:addEngineEmitor(-2.1500, -13, 0.3,  0.2, 0.2, 1.0, 2.0)
template:addEngineEmitor( 2.1500, -13, 0.3,  0.2, 0.2, 1.0, 2.0)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 90, -25, 1500.0, 6.0, 4)
template:setBeam(1, 90,  25, 1500.0, 6.0, 4)
template:setBeam(2,100, -60, 1000.0, 6.0, 4)
template:setBeam(3,100,  60, 1000.0, 6.0, 4)
template:setBeam(4, 30,   0, 2000.0, 6.0, 4)
template:setBeam(5,100, 180, 1200.0, 6.0, 4)
template:setTubes(0) -- Amount of torpedo tubes
template:setHull(70)
template:setShields(300, 300)
template:setSpeed(20, 1)
