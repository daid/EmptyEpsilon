--[[ Stations --]]
template = ShipTemplate():setName("Small Station"):setMesh("space_station_4.obj", "space_station_4_color.jpg", "space_station_4_specular.jpg", "space_station_4_illumination.jpg"):setScale(10)

--[[ Player ships --]]
template = ShipTemplate():setName("Player Cruiser"):setMesh("space_frigate_6.obj", "space_frigate_6_color.png", "space_frigate_6_specular.png", "space_frigate_6_illumination.png"):setScale(3):setRadius(50)
-- Visual positions of the beams/missiletubes (blender: Y, -X, Z)
template:setBeamPosition(0, -8, -1.6, -2)
template:setBeamPosition(1,  8, -1.6, -2)
template:setTubePosition(0, 0, 18, -3.5)
template:setTubePosition(1, 0, 18, -3.5)
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

--[[ Neutral or special ship types --]]
--Tug, used for transport of small goods (like weapons)
template = ShipTemplate():setName("Tug"):setMesh("space_tug.obj", "space_tug_color.jpg", "space_tug_illumination.jpg", "space_tug_illumination.jpg"):setScale(3):setRadius(40)
template:setHull(50)
template:setShields(20, 20)
template:setSpeed(60, 6)
template:setWeaponStorage("Homing", 5)
template:setWeaponStorage("Nuke", 1)
template:setWeaponStorage("Mine", 3)
template:setWeaponStorage("EMP", 2)

--[[ Enemy ship types --]]
template = ShipTemplate():setName("Fighter"):setMesh("small_fighter_1.obj", "small_fighter_1_color.jpg", "small_fighter_1_specular.jpg", "small_fighter_1_illumination.jpg"):setScale(1.5):setRadius(20)
-- Visual positions of the beams/missiletubes (blender: Y, -X, Z)
template:setBeamPosition(0, 0, 23, -1.8)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 60, 0, 1000.0, 4.0, 2)
template:setTubes(0) -- Amount of torpedo tubes
template:setHull(50)
template:setShields(30, 30)
template:setSpeed(100, 30)

template = ShipTemplate():setName("Cruiser"):setMesh("space_frigate_6.obj", "space_frigate_6_color.png", "space_frigate_6_specular.png", "space_frigate_6_illumination.png"):setScale(3):setRadius(50)
-- Visual positions of the beams/missiletubes (blender: Y, -X, Z)
template:setBeamPosition(0, -8, -1.6, -2)
template:setBeamPosition(1,  8, -1.6, -2)
template:setTubePosition(0, 0, 18, -3.5)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 90, -15, 1000.0, 6.0, 4)
template:setBeam(1, 90,  15, 1000.0, 6.0, 4)
template:setTubes(0) -- Amount of torpedo tubes
template:setHull(70)
template:setShields(40, 40)
template:setSpeed(40, 7)

template = ShipTemplate():setName("Missile Cruiser"):setMesh("space_cruiser_4.obj", "space_cruiser_4_color.jpg", "space_cruiser_4_illumination.jpg", "space_cruiser_4_illumination.jpg"):setScale(4):setRadius(50)
-- Visual positions of the beams/missiletubes (blender: Y, -X, Z)
template:setTubePosition(0, -10, 2, -2.3)
template:setTubePosition(1,  10, 2, -2.3)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setTubes(2) -- Amount of torpedo tubes
template:setHull(70)
template:setShields(50, 50)
template:setSpeed(40, 6)
template:setWeaponStorage("Homing", 10)


template = ShipTemplate():setName("Adv. Gunship"):setMesh("dark_fighter_6.obj", "dark_fighter_6_color.png", "dark_fighter_6_specular.jpg", "dark_fighter_6_illumination.jpg"):setScale(3.5):setRadius(100)
-- Visual positions of the beams/missiletubes (blender: Y, -X, Z)
template:setBeamPosition(0,-28.2, 21, -2)
template:setBeamPosition(1, 28.2, 21, -2)
template:setTubePosition(0,-7.5, 11, -3)
template:setTubePosition(1, 7.5, 11, -3)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 40,-5, 1000.0, 6.0, 4)
template:setBeam(1, 40, 5, 1000.0, 6.0, 4)
template:setTubes(2) -- Amount of torpedo tubes
template:setHull(70)
template:setShields(100, 100)
template:setSpeed(50, 8)
template:setWeaponStorage("Homing", 6)


template = ShipTemplate():setName("Dreadnought"):setMesh("space_cruiser_4.obj", "space_cruiser_4_color.jpg", "space_cruiser_4_illumination.jpg", "space_cruiser_4_illumination.jpg"):setScale(8):setRadius(100)
-- Visual positions of the beams/missiletubes (blender: Y, -X, Z)
template:setBeamPosition(0, -10, 2, -2.3)
template:setBeamPosition(1,  10, 2, -2.3)
template:setBeamPosition(2, -10, 2, -2.3)
template:setBeamPosition(3,  10, 2, -2.3)
template:setTubePosition(0, -10, 2, -2.3)
template:setTubePosition(1,  10, 2, -2.3)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 90, -30, 1000.0, 6.0, 4)
template:setBeam(1, 90,  30, 1000.0, 6.0, 4)
template:setBeam(2,100, -60,  800.0, 6.0, 4)
template:setBeam(3,100,  60,  800.0, 6.0, 4)
template:setBeam(4, 30,   0, 1500.0, 6.0, 4)
template:setBeam(5,100, 180,  800.0, 6.0, 4)
template:setTubes(2) -- Amount of torpedo tubes
template:setHull(70)
template:setShields(300, 300)
template:setSpeed(40, 5)
template:setWeaponStorage("Homing", 20)
