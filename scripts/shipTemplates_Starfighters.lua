--[[--------------------STARFIGHTERS------------------------
Starfighters are small ships typically crewed by 1 to 3
people and feature high speed and maneuverability, light
firepower, thin defenses, and a lack of long-range
capabilities. Few have more than 1 shield section.

They are commonly deployed in large groups, and their lack
of extended life support forces them to rely on nearby space
stations or support ships.

There are 3 starfighter subclasses:

* Interceptors: Extremely fast and maneuverable, but with
    little offensive firepower and negligible defenses.
* Gunship: Equipped with more weapons and stouter defenses,
    at a cost of maneuverbility.
* Bomber: The slowest starfighters can pack a large punch.
    Most eschew lasers for missiles, and the largest bombers
    have been known to deliver ship-killing nukes.
----------------------------------------------------------]]

------------------------INTERCEPTORS------------------------

------------------------MT52 Hornet-------------------------
template = ShipTemplate():setName("MT52 Hornet")
    template:setLocaleName(_("MT52 Hornet"))
    template:setClass(_("Starfighter"), _("Interceptor"))
    template:setModel("WespeScoutYellow")
    template:setDescription(_([[The MT52 Hornet is a basic interceptor found in many corners of the galaxy. It's easy to find spare parts for MT52s, not only because they are produced in large numbers, but also because they suffer high losses in combat.]]))
    template:setRadarTrace("radar_fighter.png")
    template:setDefaultAI("fighter")

    -- Defenses
    template:setHull(30)
    template:setShields(20)

    -- Maneuverability
    --   Impulse Forward, Turn, Acceleration
    template:setSpeed(120,  30, 25)

    -- Weapons
    --   Beams            ID, Arc, Bear,  Range, Cycle, Damage
    template:setBeamWeapon(0,  30,    0,  700.0,   4.0, 2)

------------------------MU52 Hornet-------------------------
variation = template:copy("MU52 Hornet")
    variation:setLocaleName(_("MU52 Hornet"))
    variation:setModel("WespeScoutRed")
    variation:setDescription(_([[The MU52 Hornet is a new, upgraded version of the MT52. All of its systems are slightly improved over the MT52 model.]]))

    -- Defenses
    variation:setHull(35)
    variation:setShields(22)

    -- Maneuverability
    --   Impulse   Forward, Turn, Acceleration
    variation:setSpeed(125,   32, 25)

    -- Weapons
    --   Beams            ID, Arc, Bear,  Range, Cycle, Damage
    template:setBeamWeapon(0,  30,    0,  900.0,   4.0, 2.5)

-----------------MP52 Hornet (player ship)------------------
variation = variation:copy("MP52 Hornet")
    variation:setLocaleName(_("MP52 Hornet"))
    variation:setDescription(_([[The MP52 Hornet is a significantly upgraded version of MU52 Hornet, with nearly twice the hull strength, nearly three times the shielding, better acceleration, impulse boosters, and a second laser cannon.]]))
    variation:setImpulseSoundFile("sfx/engine_fighter.wav")
    variation:setType("playership")

    -- Capabilities
    variation:setEnergyStorage(400)

    -- Defenses
    variation:setHull(70)
    variation:setShields(60)

    -- Maneuverability
    --   Impulse   Forward, Turn, Acceleration
    variation:setSpeed(125,   32, 40)
    --   Combat Maneuver      Boost, Strafe
    variation:setCombatManeuver(600, 0)
    -- Weapons
    --   Beams             ID, Arc, Bear,  Range, Cycle, Damage
    variation:setBeamWeapon(0,  30,    5,  900.0,   4.0, 2.5)
    variation:setBeamWeapon(1,  30,   -5,  900.0,   4.0, 2.5)

    -- Internal layout
    --   Repair crew count
    variation:setRepairCrewCount(1)
    --   Rooms          Position  Size
    --                      X  Y  W  H  System
    variation:addRoomSystem(3, 0, 1, 1, "Maneuver");
    variation:addRoomSystem(1, 0, 2, 1, "BeamWeapons");

    variation:addRoomSystem(0, 1, 1, 2, "RearShield");
    variation:addRoomSystem(1, 1, 2, 2, "Reactor");
    variation:addRoomSystem(3, 1, 2, 1, "Warp");
    variation:addRoomSystem(3, 2, 2, 1, "JumpDrive");
    variation:addRoomSystem(5, 1, 1, 2, "FrontShield");

    variation:addRoomSystem(1, 3, 2, 1, "MissileSystem");
    variation:addRoomSystem(3, 3, 1, 1, "Impulse");
    --   Doors    Position
    --                X  Y  Horizontal?
    variation:addDoor(2, 1, true);
    variation:addDoor(3, 1, true);
    variation:addDoor(1, 1, false);
    variation:addDoor(3, 1, false);
    variation:addDoor(3, 2, false);
    variation:addDoor(3, 3, true);
    variation:addDoor(2, 3, true);
    variation:addDoor(5, 1, false);
    variation:addDoor(5, 2, false);

----------------MM52 Hornet (Player Fighter)----------------
variation = variation:copy("Player Fighter")
    variation:setLocaleName(_("MM52 Hornet"))
    variation:setModel("WespeScoutWhite")
    variation:setDescription(_([[The MM52 Hornet is a significantly upgraded version of MU52 Hornet, with nearly twice the hull strength and shielding, better acceleration, impulse boosters, 2 powerful laser cannons, and an HVLI tube. However, the extra arms significantly reduce its agility and put additional strain on its small reactor.]]))
    variation:setImpulseSoundFile("sfx/engine_fighter.wav")

    -- Defenses
    variation:setHull(60)
    variation:setShields(40)

    -- Maneuverability
    --   Impulse   Forward, Turn, Acceleration
    variation:setSpeed(110,   20, 40)
    --   Combat Maneuver      Boost, Strafe
    variation:setCombatManeuver(600, 0)

    -- Weapons
    --   Beams             ID, Arc, Bear,  Range, Cycle, Damage
    variation:setBeamWeapon(0,  40,  -10, 1000.0,   6.0, 8)
    variation:setBeamWeapon(1,  40,   10, 1000.0,   6.0, 8)
    --   Tubes     Count, Load Time
    variation:setTubes(1, 10.0)
    --     Tube weapon storage     Type, Count
    variation:setWeaponStorage(  "HVLI", 4)

------------------AF-7 Mosquito (Fighter)-------------------
template = ShipTemplate():setName("Fighter")
    template:setLocaleName(_("AF-7 Mosquito"))
    template:setClass(_("Starfighter"), _("Interceptor"))
    template:setModel("small_fighter_1")
    template:setDescription(_([[Mosquitos are cheap, agile harriers popular with raiders and backwater defense forces. While individually incapable of dealing significant damage and easily destroyed, they are fast and often deployed in large, swarming groups that should not be underestimated.]]))
    template:setRadarTrace("radar_fighter.png")
    template:setDefaultAI("fighter")

    -- Defenses
    template:setHull(30)
    template:setShields(30)

    -- Maneuverability
    --   Impulse  Forward, Turn, Acceleration
    template:setSpeed(120,   30, 25)

    -- Weapons
    --   Beams            ID, Arc, Bear,  Range, Cycle, Damage
    template:setBeamWeapon(0,  60,    0, 1000.0,   4.0, 4)

--------------------------GUNSHIPS--------------------------

-------------------------Adder MK5--------------------------
template = ShipTemplate():setName("Adder MK5")
    template:setLocaleName(_("Adder MK5"))
    template:setClass(_("Starfighter"), _("Gunship"))
    template:setModel("AdlerLongRangeScoutYellow")
    template:setDescription(_([[The Adder line's fifth iteration proved to be a great success among pirates and law officers alike. It is cheap, fast, and easy to maintain, and it packs a decent punch.]]))
    template:setRadarTrace("radar_fighter.png")

    -- Defenses
    template:setHull(50)
    template:setShields(30)

    -- Maneuverability
    --   Impulse Forward, Turn, Acceleration
     template:setSpeed(80,  28, 25)
    -- Weapons
    --   Beams            ID, Arc, Bear,  Range, Cycle, Damage
    template:setBeamWeapon(0,  35,    0,  800.0,   5.0, 2.0)
    template:setBeamWeapon(1,  70,   30,  600.0,   5.0, 2.0)
    template:setBeamWeapon(2,  70,  -35,  600.0,   5.0, 2.0)
    --   Tubes    Count, Load Time
    template:setTubes(1, 15.0)
    --     Tube size    ID, Size (small, medium, large)
    template:setTubeSize(0, "small")
    --     Tube weapon storage    Type, Count
    template:setWeaponStorage(  "HVLI", 4)

-------------------------Adder MK4--------------------------
variation = template:copy("Adder MK4")
    variation:setLocaleName(_("Adder MK4"))
    variation:setModel("AdlerLongRangeScoutBlue")
    variation:setDescription(_([[The mark 4 Adder is a rare sight these days due to the success its successor, the mark 5 Adder, which often replaces this model. Its similar hull, however, means careless buyers are sometimes conned into buying mark 4 models disguised as the mark 5.]]))

    -- Defenses
    variation:setHull(40)
    variation:setShields(20)

    -- Maneuverability
    --   Impulse  Forward, Turn, Acceleration
    variation:setSpeed(60, 20, 20)

    -- Weapons
    --   Tubes     Count, Load Time
    variation:setTubes(1, 20.0)
    --     Tube size     ID, Size (small, medium, large)
    variation:setTubeSize(0, "small")
    --     Tube weapon storage     Type, Count
    variation:setWeaponStorage(  "HVLI", 2)

-------------------------Adder MK6--------------------------
variation = template:copy("Adder MK6")
    variation:setLocaleName(_("Adder MK6"))
    variation:setModel("AdlerLongRangeScoutRed")
    variation:setDescription(_([[The mark 6 Adder is a small upgrade compared to the highly successful mark 5 model. Since people still prefer the more familiar and reliable mark 5, the mark 6 has not seen the same level of success.]]))

    -- Weapons
    --   Beams             ID, Arc, Bear,  Range, Cycle, Damage
    variation:setBeamWeapon(3,  35,  180,  600.0,   6.0, 2.0)
    --     Tube weapon storage     Type, Count
    variation:setWeaponStorage(  "HVLI", 8)

--------------------------BOMBERS---------------------------

------------------------WX-Lindworm-------------------------
template = ShipTemplate():setName("WX-Lindworm")
    template:setLocaleName(_("WX-Lindworm"))
    template:setClass(_("Starfighter"), _("Bomber"))
    template:setModel("LindwurmFighterYellow")
    template:setDescription(_([[The WX-Lindworm, or "Worm" as it's often called, is a bomber-class starfighter. While one of the least-shielded starfighters in active duty, the Worm's two launchers can pack quite a punch. Its goal is to fly in, destroy its target, and fly out or be destroyed.]]))
    template:setRadarTrace("radar_fighter.png")

    -- Defenses
    template:setHull(50)
    template:setShields(20)

    -- Maneuverability
    --   Impulse Forward, Turn, Acceleration
    template:setSpeed(50,   15, 25)

    -- Weapons
    --   Tubes    Count, Load Time
    template:setTubes(3, 15.0)
    --     Tube direction    ID, Bearing
    template:setTubeDirection(1, 1):setWeaponTubeExclusiveFor(1, "HVLI")
    template:setTubeDirection(2,-1):setWeaponTubeExclusiveFor(2, "HVLI")
    --     Tube size    ID, Size (small, medium, large)
    template:setTubeSize(0, "small")
    template:setTubeSize(1, "small")
    template:setTubeSize(2, "small")
    --     Tube weapon storage    Type, Count
    template:setWeaponStorage(  "HVLI", 6)
    template:setWeaponStorage("Homing", 1)

------------------------ZX-Lindworm-------------------------
variation = template:copy("ZX-Lindworm")
    variation:setLocaleName(_("ZX-Lindworm"))
    variation:setModel("LindwurmFighterBlue")
    variation:setType("playership")

    -- Capabilities
    variation:setEnergyStorage(400)

    -- Defenses
    variation:setHull(75)
    variation:setShields(40)

    -- Maneuverability
    --   Impulse  Forward, Turn, Acceleration
    variation:setSpeed(70,   15, 25)
    --   Combat Maneuver      Boost, Strafe
    variation:setCombatManeuver(250, 150)

    -- Weapons
    --   Beams             ID, Arc, Bear,  Range, Cycle, Damage
    variation:setBeamWeapon(0,  10,  180,  700.0,   6.0, 2)
    --   Beam turrets            ID, Arc, Dir, Rotation Speed
    variation:setBeamWeaponTurret(0, 270, 180, 4)
    --   Tubes     Count, Load Time
    variation:setTubes(3, 10.0)
    --     Tube weapon storage     Type, Count
    variation:setWeaponStorage(  "HVLI", 12)
    variation:setWeaponStorage("Homing",  3)

    -- Internal layout
    --   Repair crew count
    variation:setRepairCrewCount(1)
    --   Rooms          Position  Size
    --                      X  Y  W  H  System
    variation:addRoomSystem(0, 0, 1, 3, "RearShield")
    variation:addRoomSystem(1, 1, 3, 1, "MissileSystem")
    variation:addRoomSystem(4, 1, 2, 1, "Beamweapons")
    variation:addRoomSystem(3, 2, 2, 1, "Reactor")
    variation:addRoomSystem(2, 3, 2, 1, "Warp")
    variation:addRoomSystem(4, 3, 5, 1, "JumpDrive")
    variation:addRoomSystem(0, 4, 1, 3, "Impulse")
    variation:addRoomSystem(3, 4, 2, 1, "Maneuver")
    variation:addRoomSystem(1, 5, 3, 1, "FrontShield")
    variation:addRoom(      4, 5, 2, 1)
    --   Doors    Position
    --                X  Y  Horizontal?
    variation:addDoor(1, 1, false)
    variation:addDoor(1, 5, false)
    variation:addDoor(3, 2, true)
    variation:addDoor(4, 2, true)
    variation:addDoor(3, 3, true)
    variation:addDoor(4, 3, true)
    variation:addDoor(3, 4, true)
    variation:addDoor(4, 4, true)
    variation:addDoor(3, 5, true)
    variation:addDoor(4, 5, true)
