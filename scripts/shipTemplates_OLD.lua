--[[                  OLD ship templates
These are older ship templates, going to be replaced soon.
----------------------------------------------------------]]

----------------------Ktlitan ships
template = ShipTemplate():setName("Ktlitan Fighter"):setLocaleName(_("Ktlitan Fighter")):setModel("sci_fi_alien_ship_1")
template:setRadarTrace("radar_ktlitan_fighter.png")
template:setBeam(0, 60, 0, 1200.0, 4.0, 6)
template:setHull(70)
template:setSpeed(140, 30, 25)
template:setDefaultAI('fighter')	-- set fighter AI, which dives at the enemy, and then flies off, doing attack runs instead of "hanging in your face".

template = ShipTemplate():setName("Ktlitan Breaker"):setLocaleName(_("Ktlitan Breaker")):setModel("sci_fi_alien_ship_2")
template:setRadarTrace("radar_ktlitan_breaker.png")
template:setBeam(0, 40, 0, 800.0, 4.0, 6)
template:setBeam(1, 35,-15, 800.0, 4.0, 6)
template:setBeam(2, 35, 15, 800.0, 4.0, 6)
template:setTubes(1, 13.0) -- Amount of torpedo tubes, loading time
template:setWeaponStorage("HVLI", 5) --Only give this ship HVLI's
template:setHull(120)
template:setSpeed(100, 5, 25)

template = ShipTemplate():setName("Ktlitan Worker"):setLocaleName(_("Ktlitan Worker")):setModel("sci_fi_alien_ship_3")
template:setRadarTrace("radar_ktlitan_worker.png")
template:setBeam(0, 40, -90, 600.0, 4.0, 6)
template:setBeam(1, 40, 90, 600.0, 4.0, 6)
template:setHull(50)
template:setSpeed(100, 35, 25)

template = ShipTemplate():setName("Ktlitan Drone"):setLocaleName(_("Ktlitan Drone")):setModel("sci_fi_alien_ship_4")
template:setRadarTrace("radar_ktlitan_drone.png")
template:setBeam(0, 40, 0, 600.0, 4.0, 6)
template:setHull(30)
template:setSpeed(120, 10, 25)

template = ShipTemplate():setName("Ktlitan Feeder"):setLocaleName(_("Ktlitan Feeder")):setModel("sci_fi_alien_ship_5")
template:setRadarTrace("radar_ktlitan_feeder.png")
template:setBeam(0, 20, 0, 800.0, 4.0, 6)
template:setBeam(1, 35,-15, 600.0, 4.0, 6)
template:setBeam(2, 35, 15, 600.0, 4.0, 6)
template:setBeam(3, 20,-25, 600.0, 4.0, 6)
template:setBeam(4, 20, 25, 600.0, 4.0, 6)
template:setHull(150)
template:setSpeed(120, 8, 25)

template = ShipTemplate():setName("Ktlitan Scout"):setLocaleName(_("Ktlitan Scout")):setModel("sci_fi_alien_ship_6")
template:setRadarTrace("radar_ktlitan_scout.png")
template:setBeam(0, 40, 0, 600.0, 4.0, 6)
template:setHull(100)
template:setSpeed(150, 30, 25)

template = ShipTemplate():setName("Ktlitan Destroyer"):setLocaleName(_("Ktlitan Destroyer")):setModel("sci_fi_alien_ship_7")
template:setRadarTrace("radar_ktlitan_destroyer.png")
template:setBeam(0, 90, -15, 1000.0, 6.0, 10)
template:setBeam(1, 90,  15, 1000.0, 6.0, 10)
template:setHull(300)
template:setShields(50, 50, 50)
template:setTubes(3, 15.0) -- Amount of torpedo tubes
template:setSpeed(70, 5, 10)
template:setWeaponStorage("Homing", 25)
template:setDefaultAI('missilevolley')

template = ShipTemplate():setName("Ktlitan Queen"):setLocaleName(_("Ktlitan Queen")):setModel("sci_fi_alien_ship_8")
template:setRadarTrace("radar_ktlitan_queen.png")
template:setHull(350)
template:setShields(100, 100, 100)
template:setTubes(2, 15.0) -- Amount of torpedo tubes
template:setWeaponStorage("Nuke", 5)
template:setWeaponStorage("EMP", 5)
template:setWeaponStorage("Homing", 5)
