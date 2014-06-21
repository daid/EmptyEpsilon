template = ShipTemplate():setName("Small Station"):setMesh("space_station_4.obj", "space_station_4_color.jpg", "space_station_4_specular.jpg", "space_station_4_illumination.jpg"):setScale(10)
template = ShipTemplate():setName("???"):setMesh("space_cruiser_4.obj", "space_cruiser_4_color.jpg", "space_cruiser_4_illumination.jpg", "space_cruiser_4_illumination.jpg"):setScale(3):setRadius(50)

template = ShipTemplate():setName("Player Cruiser"):setMesh("space_frigate_6.obj", "space_frigate_6_color.png", "space_frigate_6_specular.png", "space_frigate_6_illumination.png"):setScale(3):setRadius(50)
-- Visual positions of the beams (blender: Y, -X, Z)
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

template = ShipTemplate():setName("Fighter"):setMesh("small_fighter_1.obj", "small_fighter_1_color.jpg", "small_fighter_1_specular.jpg", "small_fighter_1_illumination.jpg"):setScale(1.5):setRadius(20)
-- Visual positions of the beams (blender: Y, -X, Z)
template:setBeamPosition(0, 0, 23, -1.8)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 60, 0, 1000.0, 4.0, 1)
template:setTubes(0) -- Amount of torpedo tubes
template:setHull(50)
template:setShields(30, 30)
template:setSpeed(100, 30)

template = ShipTemplate():setName("Cruiser"):setMesh("space_frigate_6.obj", "space_frigate_6_color.png", "space_frigate_6_specular.png", "space_frigate_6_illumination.png"):setScale(3):setRadius(50)
-- Visual positions of the beams (blender: Y, -X, Z)
template:setBeamPosition(0, -8, -1.6, -2)
template:setBeamPosition(1,  8, -1.6, -2)
template:setTubePosition(0, 0, 18, -3.5)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 90, -15, 1000.0, 6.0, 12)
template:setBeam(1, 90,  15, 1000.0, 6.0, 12)
template:setTubes(0) -- Amount of torpedo tubes
template:setHull(70)
template:setShields(40, 40)
template:setSpeed(40, 7)
