template = ShipTemplate():setName("small-station"):setMesh("space_station_4.obj", "space_station_4_color.jpg", "space_station_4_specular.jpg", "space_station_4_illumination.jpg"):setScale(10)

template = ShipTemplate():setName("scout"):setMesh("space_frigate_6.obj", "space_frigate_6_color.png", "space_frigate_6_specular.png", "space_frigate_6_illumination.png"):setScale(3)
template:setBeamPosition(0, -8, -1.6, -2)
template:setBeamPosition(1,  8, -1.6, -2)

template = ShipTemplate():setName("fighter"):setMesh("small_fighter_1.obj", "small_fighter_1_color.jpg", "small_fighter_1_specular.jpg", "small_fighter_1_illumination.jpg"):setScale(3)
