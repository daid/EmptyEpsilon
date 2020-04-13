--[[----------------------KTLITANS--------------------------
The Ktlitans are intelligent eight-legged creatures that
resemble Earth's arachnids. However, unlike most terrestrial
arachnids, the Ktlitans do not fight among themselves. Their
common, and only, goal is their species' survival.

Ktlitan ships have no class or subclass designation, but
instead are grouped by their roles within their hierarchy.
They do, however, share some common traits: they are fast,
lightly armed, lack long-range capabilities, and often have
little or no shielding.
----------------------------------------------------------]]

----------------------Ktlitan Fighter-----------------------
template = ShipTemplate():setName("Ktlitan Fighter")
	template:setLocaleName(_("Ktlitan Fighter"))
	template:setModel("sci_fi_alien_ship_1")
	template:setRadarTrace("radar_ktlitan_fighter.png")
	template:setDefaultAI("fighter")	-- set fighter AI, which dives at the enemy, and then flies off, doing attack runs instead of "hanging in your face"

    -- Defenses
	template:setHull(70)

    -- Maneuverability
    --   Impulse  Forward, Turn, Acceleration
	template:setSpeed(140,   30, 25)

    -- Weapons
    --   Beams            ID, Arc, Bear,  Range, Cycle, Damage
	template:setBeamWeapon(0,  60,    0, 1200.0,   4.0, 6)

----------------------Ktlitan Breaker-----------------------
template = ShipTemplate():setName("Ktlitan Breaker")
	template:setLocaleName(_("Ktlitan Breaker"))
	template:setModel("sci_fi_alien_ship_2")
	template:setRadarTrace("radar_ktlitan_breaker.png")

    -- Defenses
	template:setHull(120)

    -- Maneuverability
    --   Impulse  Forward, Turn, Acceleration
	template:setSpeed(100,    5, 25)

    -- Weapons
    --   Beams            ID, Arc, Bear,  Range, Cycle, Damage
	template:setBeamWeapon(0,  40,    0,  800.0,   4.0, 6)
	template:setBeamWeapon(1,  35,  -15,  800.0,   4.0, 6)
	template:setBeamWeapon(2,  35,   15,  800.0,   4.0, 6)
    --   Tubes    Count, Load Time
	template:setTubes(1, 13.0)
    --     Tube weapon storage    Type, Count
	template:setWeaponStorage(  "HVLI", 5)

-----------------------Ktlitan Worker-----------------------
template = ShipTemplate():setName("Ktlitan Worker")
	template:setLocaleName(_("Ktlitan Worker"))
	template:setModel("sci_fi_alien_ship_3")
	template:setRadarTrace("radar_ktlitan_worker.png")

    -- Defenses
	template:setHull(50)

    -- Maneuverability
    --   Impulse  Forward, Turn, Acceleration
	template:setSpeed(100, 35, 25)

    -- Weapons
    --   Beams            ID, Arc, Bear,  Range, Cycle, Damage
	template:setBeamWeapon(0,  40,  -90,  600.0,   4.0, 6)
	template:setBeamWeapon(1,  40,   90,  600.0,   4.0, 6)

-----------------------Ktlitan Drone------------------------
template = ShipTemplate():setName("Ktlitan Drone")
	template:setLocaleName(_("Ktlitan Drone"))
	template:setModel("sci_fi_alien_ship_4")
	template:setRadarTrace("radar_ktlitan_drone.png")

    -- Defenses
	template:setHull(30)

    -- Maneuverability
    --   Impulse  Forward, Turn, Acceleration
	template:setSpeed(120, 10, 25)

    -- Weapons
    --   Beams            ID, Arc, Bear,  Range, Cycle, Damage
	template:setBeamWeapon(0,  40,    0,  600.0,   4.0, 6)

-----------------------Ktlitan Feeder-----------------------
template = ShipTemplate():setName("Ktlitan Feeder")
	template:setLocaleName(_("Ktlitan Feeder"))
	template:setModel("sci_fi_alien_ship_5")
	template:setRadarTrace("radar_ktlitan_feeder.png")

    -- Defenses
	template:setHull(150)

    -- Maneuverability
	--   Impulse  Forward, Turn, Acceleration
	template:setSpeed(120,    8, 25)

    -- Weapons
    --   Beams            ID, Arc, Bear,  Range, Cycle, Damage
	template:setBeamWeapon(0,  20,    0,  800.0,   4.0, 6)
	template:setBeamWeapon(1,  35,  -15,  600.0,   4.0, 6)
	template:setBeamWeapon(2,  35,   15,  600.0,   4.0, 6)
	template:setBeamWeapon(3,  20,  -25,  600.0,   4.0, 6)
	template:setBeamWeapon(4,  20,   25,  600.0,   4.0, 6)

-----------------------Ktlitan Scout------------------------
template = ShipTemplate():setName("Ktlitan Scout")
	template:setLocaleName(_("Ktlitan Scout"))
	template:setModel("sci_fi_alien_ship_6")
	template:setRadarTrace("radar_ktlitan_scout.png")

    -- Defenses
	template:setHull(100)

    -- Maneuverability
	--   Impulse  Forward, Turn, Acceleration
	template:setSpeed(150,   30, 25)

    -- Weapons
    --   Beams            ID, Arc, Bear,  Range, Cycle, Damage
	template:setBeamWeapon(0,  40,    0,  600.0,   4.0, 6)

---------------------Ktlitan Destroyer----------------------
template = ShipTemplate():setName("Ktlitan Destroyer")
	template:setLocaleName(_("Ktlitan Destroyer"))
	template:setModel("sci_fi_alien_ship_7")
	template:setRadarTrace("radar_ktlitan_destroyer.png")
	template:setDefaultAI("missilevolley")

	-- Defenses
	template:setHull(300)
	template:setShields(50, 50, 50)

    -- Maneuverability
	--   Impulse Forward, Turn, Acceleration
	template:setSpeed(70,    5, 10)

    -- Weapons
    --   Beams            ID, Arc, Bear,  Range, Cycle, Damage
	template:setBeamWeapon(0,  90,  -15, 1000.0,   6.0, 10)
	template:setBeamWeapon(1,  90,   15, 1000.0,   6.0, 10)
    --   Tubes    Count, Load Time
	template:setTubes(3, 15.0)
    --     Tube weapon storage    Type, Count
	template:setWeaponStorage("Homing", 25)

-----------------------Ktlitan Queen------------------------
template = ShipTemplate():setName("Ktlitan Queen")
	template:setLocaleName(_("Ktlitan Queen"))
	template:setModel("sci_fi_alien_ship_8")
	template:setRadarTrace("radar_ktlitan_queen.png")
	template:setDefaultAI("missilevolley")

	-- Defenses
	template:setHull(350)
	template:setShields(100, 100, 100)

    -- Weapons
    --   Tubes    Count, Load Time
	template:setTubes(2, 15.0)
    --     Tube weapon storage    Type, Count
	template:setWeaponStorage("Homing", 5)
	template:setWeaponStorage(  "Nuke", 5)
	template:setWeaponStorage(   "EMP", 5)
