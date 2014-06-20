template = ShipTemplate():setName("small-station"):setMesh("space_station_4.obj", "space_station_4_color.jpg", "space_station_4_specular.jpg", "space_station_4_illumination.jpg"):setScale(10)
template = ShipTemplate():setName("player-cruiser"):setMesh("space_frigate_6.obj", "space_frigate_6_color.png", "space_frigate_6_specular.png", "space_frigate_6_illumination.png"):setScale(3)
-- Visual positions of the beams
template:setBeamPosition(0, -8, -1.6, -2)
template:setBeamPosition(1,  8, -1.6, -2)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 90, -15, 1000.0, 6.0, 12)
template:setBeam(1, 90,  15, 1000.0, 6.0, 12)
template:setTubes(2) -- Amount of torpedo tubes
template:setShields(80, 80)
template:setSpeed(600, 10)
template:setWarpSpeed(1000)
template:setJumpDrive(false)
template:setCloaking(false)
template:setWeaponStorage("Homing", 8)
template:setWeaponStorage("Nuke", 2)
template:setWeaponStorage("Mine", 6)
template:setWeaponStorage("EMP", 4)

template = ShipTemplate():setName("fighter"):setMesh("small_fighter_1.obj", "small_fighter_1_color.jpg", "small_fighter_1_specular.jpg", "small_fighter_1_illumination.jpg"):setScale(3)
