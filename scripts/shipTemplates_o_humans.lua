
-- Fighter
template = ShipTemplate():setName("Fighter F975"):setClass("Starfighter", "Interceptor"):setModel("eoc_fighter")
template:setRadarTrace("radar_fighter.png")
template:setHull(30)
template:setShields(500)
template:setSpeed(30, 15, 13)
template:setDefaultAI('fighter')
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 30, 0, 700.0, 4.0, 2)


-- Scoutship

template = ShipTemplate():setName("Scoutship S342"):setClass("Frigate", "Cruiser"):setModel("eoc_frigate")
template:setRadarTrace("radar_cruiser")
template:setHull(70)
template:setShields(500, 500, 500, 500)
template:setSpeed(20, 5, 5)
template:setBeamWeapon(0, 90, -15, 1200, 8, 6)
template:setBeamWeapon(1, 90,  15, 1200, 8, 6)
template:setTubes(2, 60.0)
template:setWeaponStorage("HVLI", 20)
template:setWeaponStorage("Homing", 6)
template:setTubeDirection(0, -1)
template:setTubeDirection(1,  1)



template = ShipTemplate():setName("Scoutship S835"):setClass("Frigate", "Cruiser"):setModel("eoc_frigate")
template:setRadarTrace("radar_cruiser")
template:setShields(500, 500, 500, 500)
template:setHull(200)
template:setSpeed(20, 5, 10)
template:setCombatManeuver(400, 250)
template:setTubes(3, 10.0)
template:setWeaponStorage("Homing", 10)
template:setWeaponStorage("EMP", 3)

-- Cargoship

template = ShipTemplate():setName("Cargoship T842"):setClass("Frigate", "Cruiser"):setModel("eoc_frigate")
template:setRadarTrace("radar_cruiser")
template:setHull(70)
template:setShields(500, 500, 500, 500)
template:setSpeed(15, 5, 5)
template:setBeamWeapon(0, 90, -15, 1200, 8, 6)
template:setBeamWeapon(1, 90,  15, 1200, 8, 6)
template:setTubes(2, 60.0)
template:setWeaponStorage("HVLI", 20)
template:setWeaponStorage("Homing", 6)
template:setTubeDirection(0, -1)
template:setTubeDirection(1,  1)

-- Cruiser
template = ShipTemplate():setName("Cruiser C753"):setClass("Corvette", "Destroyer"):setModel("eoc_frigate")
template:setRadarTrace("radar_transport.png")
template:setHull(50)
template:setShields(500, 500, 500, 500)
template:setSpeed(15, 4, 5)
template:setBeam(0, 40, 170, 1200.0, 6.0, 6)
template:setBeam(1, 40, 190, 1200.0, 6.0, 6)



--Corvette
template = ShipTemplate():setName("Corvette C754"):setClass("Corvette", "Destroyer"):setModel("small_frigate_5")
template:setRadarTrace("radar_transport.png")
template:setHull(50)
template:setShields(200, 200, 200, 200)
template:setSpeed(10, 6, 6)
template:setWarpSpeed(700)
template:setBeam(0, 40,-5, 1000.0, 6.0, 6)
template:setBeam(1, 40, 5, 1000.0, 6.0, 6)
template:setDefaultAI('missilevolley')



template = ShipTemplate():setName("Corvette C348"):setClass("Corvette", "Destroyer"):setModel("small_frigate_5")
template:setRadarTrace("radar_transport.png")
template:setHull(50)
template:setShields(500, 500, 500, 500)
template:setSpeed(10, 6, 6)
template:setWarpSpeed(700)
template:setBeam(0, 40,-5, 1000.0, 6.0, 6)
template:setBeam(1, 40, 5, 1000.0, 6.0, 6)




template = ShipTemplate():setName("Cruiser C243"):setClass("Corvette", "Destroyer"):setModel("small_frigate_5")
template:setRadarTrace("radar_transport.png")
template:setHull(50)
template:setShields(500, 500, 500, 500)
template:setSpeed(10, 4, 5)
template:setDefaultAI('missilevolley')



--BattleCruiser
template = ShipTemplate():setName("Battlecruiser B952"):setClass("Corvette", "Freighters"):setModel("battleship_destroyer_4_upgraded")
template:setRadarTrace("radar_battleship.png")
template:setHull(200)
template:setShields(500, 500, 500, 500, 500, 500, 500, 500)
template:setSpeed(5, 3, 5)
template:setJumpDrive(true)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 60, -10, 2000.0, 8.0, 11)
template:setBeam(1, 60,  10, 2000.0, 8.0, 11)
template:setBeam(2, 60, -20, 1500.0, 8.0, 11)
template:setBeam(3, 60,  20, 1500.0, 8.0, 11)
template:setTubes(2, 10.0)
template:setWeaponStorage("HVLI", 20)
template:setWeaponStorage("Homing", 4)
template:setWeaponStorage("EMP", 2)
template:weaponTubeDisallowMissle(1, "EMP")
template:setDefaultAI('missilevolley')



-- Space station
template = ShipTemplate():setName("Medium station"):setModel("space_station_2")
template:setRadarTrace("radartrace_mediumstation.png")
template:setSpeed(0, 0, 0)
template:setDockClasses("Starfighter")
template:setHull(400)
template:setShields(800)


