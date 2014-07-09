--[[ Stations --]]
template = ShipTemplate():setName("Small Station"):setMesh("space_station_4.model", "space_station_4_color.jpg", "space_station_4_specular.jpg", "space_station_4_illumination.jpg"):setScale(10)

--[[ Player ships --]]
template = ShipTemplate():setName("Player Cruiser"):setMesh("space_frigate_6.model", "space_frigate_6_color.png", "space_frigate_6_specular.png", "space_frigate_6_illumination.png"):setScale(6):setRadius(100)
-- Visual positions of the beams/missiletubes (blender: Y, -X, Z)
template:setBeamPosition(0, -8, -1.6, -2)
template:setBeamPosition(1,  8, -1.6, -2)
template:setTubePosition(0, 0, 18, -3.5)
template:setTubePosition(1, 0, 18, -3.5)
template:addEngineEmitor(0, -18, -1,  0.2, 0.2, 1.0, 4.0)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 90, -15, 1000.0, 6.0, 12)
template:setBeam(1, 90,  15, 1000.0, 6.0, 12)
template:setTubes(2, 8.0) -- Amount of torpedo tubes, and loading time of the tubes.
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

template = ShipTemplate():setName("Player Fighter"):setMesh("small_fighter_1.model", "small_fighter_1_color.jpg", "small_fighter_1_specular.jpg", "small_fighter_1_illumination.jpg"):setScale(4):setRadius(60)
-- Visual positions of the beams/missiletubes (blender: Y, -X, Z)
template:setBeamPosition(0, 0, 23, -1.8)
template:addEngineEmitor(0, -8, 0.5,  1.0, 0.2, 0.2, 1.0)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 40, -10, 1000.0, 6.0, 8)
template:setBeam(1, 40,  10, 1000.0, 6.0, 8)
template:setTubes(1, 10.0) -- Amount of torpedo tubes, loading time
template:setHull(40)
template:setShields(40, 40)
template:setSpeed(80, 20)
template:setWarpSpeed(1000)
template:setJumpDrive(false)
template:setCloaking(false)
template:setWeaponStorage("Homing", 4)
template:setWeaponStorage("EMP", 1)

template:addRoomSystem(3, 0, 1, 1, "Maneuver");
template:addRoomSystem(1, 0, 2, 1, "BeamWeapons");

template:addRoomSystem(0, 1, 1, 2, "RearShield");
template:addRoomSystem(1, 1, 2, 2, "Reactor");
template:addRoomSystem(3, 1, 2, 1, "Warp");
template:addRoomSystem(3, 2, 2, 1, "JumpDrive");
template:addRoomSystem(5, 1, 1, 2, "FrontShield");

template:addRoomSystem(1, 3, 2, 1, "MissileSystem");
template:addRoomSystem(3, 3, 1, 1, "Impulse");

template:addDoor(2, 1, true);
template:addDoor(3, 1, true);
template:addDoor(1, 1, false);
template:addDoor(3, 1, false);
template:addDoor(3, 2, false);
template:addDoor(3, 3, true);
template:addDoor(2, 3, true);
template:addDoor(5, 1, false);
template:addDoor(5, 2, false);

--[[ Neutral or special ship types --]]
--Tug, used for transport of small goods (like weapons)
template = ShipTemplate():setName("Tug"):setMesh("space_tug.model", "space_tug_color.jpg", "space_tug_illumination.jpg", "space_tug_illumination.jpg"):setScale(6):setRadius(80)
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
-- Fighters are quick agile ships that do not do a lot of damage, but usually come in larger groups. They are easy to take out, but should not be underestimated.
template = ShipTemplate():setName("Fighter"):setMesh("small_fighter_1.model", "small_fighter_1_color.jpg", "small_fighter_1_specular.jpg", "small_fighter_1_illumination.jpg"):setScale(3):setRadius(40)
-- Visual positions of the beams/missiletubes (blender: Y, -X, Z)
template:setBeamPosition(0, 0, 23, -1.8)
template:addEngineEmitor(0, -8, 0.5,  1.0, 0.2, 0.2, 1.0)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 60, 0, 1000.0, 4.0, 2)
template:setHull(30)
template:setShields(30, 30)
template:setSpeed(100, 30)

-- The cruiser is an average ship you can encounter, it has average shields, and average beams. It's pretty much average with nothing special.
template = ShipTemplate():setName("Cruiser"):setMesh("space_frigate_6.model", "space_frigate_6_color.png", "space_frigate_6_specular.png", "space_frigate_6_illumination.png"):setScale(6):setRadius(100)
-- Visual positions of the beams/missiletubes (blender: Y, -X, Z)
template:setBeamPosition(0, -8, -1.6, -2)
template:setBeamPosition(1,  8, -1.6, -2)
template:setTubePosition(0, 0, 18, -3.5)
template:addEngineEmitor(0, -18, -1,  0.2, 0.2, 1.0, 4.0)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 90, -15, 1000.0, 6.0, 3)
template:setBeam(1, 90,  15, 1000.0, 6.0, 3)
template:setHull(70)
template:setShields(40, 40)
template:setSpeed(40, 6)

-- The missile cruiser is a long range missile firing platform. It cannot handle a lot of damage, but can do a lot of damage if not dealth with properly.
template = ShipTemplate():setName("Missile Cruiser"):setMesh("space_cruiser_4.model", "space_cruiser_4_color.jpg", "space_cruiser_4_illumination.jpg", "space_cruiser_4_illumination.jpg"):setScale(8):setRadius(100)
-- Visual positions of the beams/missiletubes (blender: Y, -X, Z)
template:setTubePosition(0, -10, 2, -2.3)
template:setTubePosition(1,  10, 2, -2.3)
template:addEngineEmitor(-2.1500, -13, 0.3,  0.2, 0.2, 1.0, 2.0)
template:addEngineEmitor( 2.1500, -13, 0.3,  0.2, 0.2, 1.0, 2.0)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setTubes(1, 25.0)
template:setHull(40)
template:setShields(50, 50)
template:setSpeed(30, 3)
template:setWeaponStorage("Homing", 10)

-- The advanced gunship is a ship equiped with 2 homing missiles to do initial damage and then take out the enemy with 2 front firing beams. It's designed to quickly take out the enemies weaker then itself.
template = ShipTemplate():setName("Adv. Gunship"):setMesh("dark_fighter_6.model", "dark_fighter_6_color.png", "dark_fighter_6_specular.png", "dark_fighter_6_illumination.png"):setScale(7):setRadius(200)
-- Visual positions of the beams/missiletubes (blender: Y, -X, Z)
template:setBeamPosition(0,-28.2, 21, -2)
template:setBeamPosition(1, 28.2, 21, -2)
template:setTubePosition(0,-7.5, 11, -3)
template:setTubePosition(1, 7.5, 11, -3)
template:addEngineEmitor(-1.5, -28, -5,  1.0, 0.2, 0.2, 2.0)
template:addEngineEmitor( 1.5, -28, -5,  1.0, 0.2, 0.2, 2.0)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 50,-15, 1000.0, 6.0, 4)
template:setBeam(1, 50, 15, 1000.0, 6.0, 4)
template:setTubes(2, 8.0) -- Amount of torpedo tubes
template:setHull(100)
template:setShields(100, 80)
template:setSpeed(40, 5)
template:setWeaponStorage("Homing", 2)

-- The Strikeship is a warp-drive equiped figher build for quick strikes, it's fast, it's aggile, but does not do an extreme amount of damage, and lacks in rear shields.
template = ShipTemplate():setName("Strikeship"):setMesh("dark_fighter_6.model", "dark_fighter_6_color.png", "dark_fighter_6_specular.png", "dark_fighter_6_illumination.png"):setScale(5):setRadius(140)
-- Visual positions of the beams/missiletubes (blender: Y, -X, Z)
template:setBeamPosition(0,-28.2, 21, -2)
template:setBeamPosition(1, 28.2, 21, -2)
template:addEngineEmitor(-1.5, -28, -5,  1.0, 0.2, 0.2, 2.0)
template:addEngineEmitor( 1.5, -28, -5,  1.0, 0.2, 0.2, 2.0)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 40,-5, 1000.0, 6.0, 3)
template:setBeam(1, 40, 5, 1000.0, 6.0, 3)
template:setHull(100)
template:setShields(80, 30)
template:setSpeed(55, 12)
template:setWarpSpeed(1000)

-- The Adv. Striker is a jump-drive equiped figher build for quick strikes, it's slow but very aggile, but does not do an extreme amount of damage, and lacks in shields. However, due to the jump driver, it's quick to get into the action.
template = ShipTemplate():setName("Adv. Striker"):setMesh("dark_fighter_6.model", "dark_fighter_6_color.png", "dark_fighter_6_specular.png", "dark_fighter_6_illumination.png"):setScale(5):setRadius(140)
-- Visual positions of the beams/missiletubes (blender: Y, -X, Z)
template:setBeamPosition(0,-28.2, 21, -2)
template:setBeamPosition(1, 28.2, 21, -2)
template:addEngineEmitor(-1.5, -28, -5,  1.0, 0.2, 0.2, 2.0)
template:addEngineEmitor( 1.5, -28, -5,  1.0, 0.2, 0.2, 2.0)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 50,-15, 1000.0, 6.0, 3)
template:setBeam(1, 50, 15, 1000.0, 6.0, 3)
template:setHull(70)
template:setShields(50, 30)
template:setSpeed(30, 12)
template:setJumpDrive(true)

-- The Dreadnough is a flying fortress, it's slow, slow to turn, but packs a huge amount of beam weapons in the front. Taking it head-on is suicide.
template = ShipTemplate():setName("Dreadnought"):setMesh("space_cruiser_4.model", "space_cruiser_4_color.jpg", "space_cruiser_4_illumination.jpg", "space_cruiser_4_illumination.jpg"):setScale(16):setRadius(200)
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
template:setHull(70)
template:setShields(300, 300)
template:setSpeed(20, 1)


-- The weapons-platform is a stationary platform with beam-weapons. It's extremely slow to turn, but it's beam weapons do a huge amount of damage.
template = ShipTemplate():setName("Weapons platform"):setMesh("space_cruiser_4.model", "space_cruiser_4_color.jpg", "space_cruiser_4_illumination.jpg", "space_cruiser_4_illumination.jpg"):setScale(8):setRadius(100)
-- Visual positions of the beams/missiletubes (blender: Y, -X, Z)
template:setBeamPosition(0, -10, 2, -2.3)
template:setBeamPosition(1,  10, 2, -2.3)
template:setBeamPosition(2, -10, 2, -2.3)
template:setBeamPosition(3,  10, 2, -2.3)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 30,   0, 4000.0, 1.5, 10)
template:setBeam(1, 30,  60, 4000.0, 1.5, 10)
template:setBeam(2, 30, 120, 4000.0, 1.5, 10)
template:setBeam(3, 30, 180, 4000.0, 1.5, 10)
template:setBeam(4, 30, 240, 4000.0, 1.5, 10)
template:setBeam(5, 30, 300, 4000.0, 1.5, 10)
template:setHull(70)
template:setShields(120, 120)
template:setSpeed(0, 0.5)
