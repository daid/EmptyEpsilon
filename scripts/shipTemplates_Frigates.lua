--[[----------------------FRIGATES--------------------------
Frigates are ships sized between starfighters and corvettes.
They require a crew from 3 to 20 people and encompass a wide
variety of roles, from personal transports and light
freighters to blockade runners and patrol ships.

Most have at least 2 shield sections; few have more than 4.
In rare cases, some frigates are designed (or modified) to
include jump or warp drives.

There are 3 frigate subclasses:

* Cruisers: Weaponized frigates can be fitted for a variety
    of combat roles.
* Light transport: Small transports, typically carrying
    fewer than 50 passengers in spartan conditions or a few
    diplomats in luxury. Depending on the role, some can be
    lightly armed.
* Support: Support frigates are simply frigate hulls fitted
    with whatever capability is needed, and can encompass
    anything from tugs to mine-layers and research vessels.
----------------------------------------------------------]]

--------------------------CRUISERS--------------------------

-------------------------Phobos T3--------------------------
template = ShipTemplate():setName("Phobos T3")
    template:setLocaleName(_("Phobos T3"))
    template:setClass(_("Frigate"), _("Cruiser"))
    template:setModel("AtlasHeavyFighterYellow")
    template:setDescription(_([[The Phobos T3, much like the Atlantis, is the workhorse of almost any navy. It's extremely easy to modify, which makes retro-fitting this ship a breeze. Its basic stats aren't impressive, but due to its modular nature, it's fairly easy to produce in large quantities.]]))
    template:setRadarTrace("radar_cruiser.png")

    -- Defenses
    template:setHull(70)
    template:setShields(50, 40)

    -- Maneuverability
    --   Impulse Forward, Turn, Acceleration
    template:setSpeed(60,   10, 10)
    -- Weapons
    --   Beams            ID, Arc, Bear,  Range, Cycle, Damage
    template:setBeamWeapon(0,  90,  -15, 1200.0,     8, 6)
    template:setBeamWeapon(1,  90,   15, 1200.0,     8, 6)
    --   Tubes    Count, Load Time
    template:setTubes(2, 60.0)
    --     Tube direction    ID, Bearing
    template:setTubeDirection(0, -1)
    template:setTubeDirection(1,  1)
    --     Tube weapon storage    Type, Count
    template:setWeaponStorage(  "HVLI", 20)
    template:setWeaponStorage("Homing",  6)

-------------------------Phobos M3--------------------------
variation = template:copy("Phobos M3")
    variation:setLocaleName(_("Phobos M3"))
    variation:setModel("AtlasHeavyFighterRed")
    variation:setDescription(_([[The Phobos M3 is one of the most common variants of the Phobos T3. It adds a mine-laying tube, but the extra storage required for the mines slows this ship down slightly.]]))

    -- Maneuverability
    --   Impulse  Forward, Turn, Acceleration
    variation:setSpeed(55,   10, 10)

    -- Weapons
    --   Tubes     Count, Load Time
    variation:setTubes(3, 60.0)
    --     Tube direction     ID, Bearing
    variation:setTubeDirection(2,  180)
    --     Tube specialization         ID, Type
    variation:weaponTubeDisallowMissle( 0, "Mine")
    variation:weaponTubeDisallowMissle( 1, "Mine")
    variation:setWeaponTubeExclusiveFor(2, "Mine")
    --     Tube weapon storage     Type, Count
    variation:setWeaponStorage(  "Mine", 6)

------------------Phobos M3P (player ship)------------------
variation = variation:copy("Phobos M3P")
    variation:setLocaleName(_("Phobos M3P"))
    variation:setType("playership")
    variation:setDescription(_([[A subvariant of the Phobos M3 with front-firing weapon tubes, more powerful impulse engines, and bolstered defenses.]]))

    -- Defenses
    variation:setHull(200)
    variation:setShields(100, 100)

    -- Maneuverability
    --   Impulse  Forward, Turn, Acceleration
    variation:setSpeed(80,   10, 20)
    --   Combat Maneuver      Boost, Strafe
    variation:setCombatManeuver(400, 250)

    -- Weapons
    --   Tubes     Count, Load Time
    variation:setTubes(3, 10.0)
    --     Tube weapon storage     Type, Count
    variation:setWeaponStorage("Homing", 10)
    variation:setWeaponStorage(  "Nuke",  2)
    variation:setWeaponStorage(  "Mine",  4)
    variation:setWeaponStorage(   "EMP",  3)

    -- Internal layout
    --   Rooms          Position  Size
    --                      X  Y  W  H  System
    variation:addRoomSystem(1, 0, 2, 1, "Maneuver");
    variation:addRoomSystem(1, 1, 2, 1, "BeamWeapons");
    variation:addRoom(      2, 2, 2, 1);

    variation:addRoomSystem(0, 3, 1, 2, "RearShield");
    variation:addRoomSystem(1, 3, 2, 2, "Reactor");
    variation:addRoomSystem(3, 3, 2, 2, "Warp");
    variation:addRoomSystem(5, 3, 1, 2, "JumpDrive");
    variation:addRoom(      6, 3, 2, 1);
    variation:addRoom(      6, 4, 2, 1);
    variation:addRoomSystem(8, 3, 1, 2, "FrontShield");

    variation:addRoom(      2, 5, 2, 1);
    variation:addRoomSystem(1, 6, 2, 1, "MissileSystem");
    variation:addRoomSystem(1, 7, 2, 1, "Impulse");
    --   Doors    Position
    --                X  Y  Horizontal?
    variation:addDoor(1, 1, true);
    variation:addDoor(2, 2, true);
    variation:addDoor(3, 3, true);
    variation:addDoor(1, 3, false);
    variation:addDoor(3, 4, false);
    variation:addDoor(3, 5, true);
    variation:addDoor(2, 6, true);
    variation:addDoor(1, 7, true);
    variation:addDoor(5, 3, false);
    variation:addDoor(6, 3, false);
    variation:addDoor(6, 4, false);
    variation:addDoor(8, 3, false);
    variation:addDoor(8, 4, false);

-------------------------Nirvana R5-------------------------
template = ShipTemplate():setName("Nirvana R5")
    template:setLocaleName(_("Nirvana R5"))
    template:setClass(_("Frigate"), _("Cruiser"))
    template:setModel("small_frigate_5") -- TODO: Better 3D model selection
    template:setDescription(_([[The Nirvana R5 is a relatively nimble frigate with several rapid-firing, low-damage point defense weapons to quickly take out starfighters.]]))
    template:setRadarTrace("radar_cruiser.png")

    -- Defenses
    template:setHull(70)
    template:setShields(50, 40)

    -- Maneuverability
    --   Impulse Forward, Turn, Acceleration
    template:setSpeed(70, 12, 10)

    -- Weapons
    --   Beams            ID, Arc, Bear,  Range, Cycle, Damage
    template:setBeamWeapon(0,  90,  -15, 1200.0,     3, 1)
    template:setBeamWeapon(1,  90,   15, 1200.0,     3, 1)
    template:setBeamWeapon(2,  90,   50, 1200.0,     3, 1)
    template:setBeamWeapon(3,  90,  -50, 1200.0,     3, 1)

------------------------Nirvana R5A-------------------------
variation = template:copy("Nirvana R5A")
    variation:setLocaleName(_("Nirvana R5A"))
    variation:setDescription(_([[An improved version of the Nirvana R5 with faster turning speed and firing rates.]]))

    -- Maneuverability
    --   Impulse  Forward, Turn, Acceleration
    variation:setSpeed(70, 15, 10)

    -- Weapons
    --   Beams            ID, Arc, Bear,  Range, Cycle, Damage
    variation:setBeamWeapon(0, 90,  -15, 1200.0,   2.9, 1)
    variation:setBeamWeapon(1, 90,   15, 1200.0,   2.9, 1)
    variation:setBeamWeapon(2, 90,   50, 1200.0,   2.9, 1)
    variation:setBeamWeapon(3, 90,  -50, 1200.0,   2.9, 1)

---------------------------Storm----------------------------
template = ShipTemplate():setName("Storm")
    template:setLocaleName(_("Storm"))
    template:setClass(_("Frigate"), _("Cruiser"))
    template:setModel("HeavyCorvetteYellow")
    template:setRadarTrace("radar_piranha.png")
    template:setDescription(_([[A heavy artillery cruiser, the Storm fires barrages of missiles from its forward-facing tubes. Its crews are trained in long-range stand-off tactics to make up for its lack of close-range firepower.]]))
    template:setDefaultAI("missilevolley")

    -- Defenses
    template:setHull(50)
    template:setShields(30, 30)

    -- Maneuverability
    --   Impulse Forward, Turn, Acceleration
    template:setSpeed(40,    6, 8)

    -- Weapons
    --   Beams            ID, Arc, Bear,  Range, Cycle, Damage
    template:setBeamWeapon(0,  60,    0, 1200.0,     3, 2)
    --   Tubes    Count, Load Time
    template:setTubes(5, 15.0)
    --     Tube direction    ID, Bearing
    template:setTubeDirection(0,  0)
    template:setTubeDirection(1, -1)
    template:setTubeDirection(2,  1)
    template:setTubeDirection(3, -2)
    template:setTubeDirection(4,  2)
    --     Tube weapon storage    Type, Count
    template:setWeaponStorage(  "HVLI", 15)
    template:setWeaponStorage("Homing", 15)

--------------------------Hathcock--------------------------
template = ShipTemplate():setName("Hathcock")
    template:setLocaleName(_("Hathcock"))
    template:setClass(_("Frigate"), _("Cruiser"))
    template:setModel("HeavyCorvetteGreen")
    template:setDescription(_([[The agile and versatile Hathcock has a long-range narrow beam weapon and some point-defense beams, as well as broadside missiles. Crews often dub it a "sniper" for its 1.4U-range, narrow-arc primary beam and nimble turn rate.]]))
    template:setRadarTrace("radar_piranha.png")
    template:setType("playership")

    -- Defenses
    template:setHull(120)
    template:setShields(70, 70)

    -- Maneuverability
    --   Impulse Forward, Turn, Acceleration
    template:setSpeed(50,   15, 8)
    --   Combat Maneuver     Boost, Strafe
    template:setCombatManeuver(200, 150)
    --   Long-range Propulsion
    template:setJumpDrive(true)

    -- Weapons
    --   Beams            ID, Arc, Bear,  Range, Cycle, Damage
    template:setBeamWeapon(0,   4,    0, 1400.0,   6.0, 4)
    template:setBeamWeapon(1,  20,    0, 1200.0,   6.0, 4)
    template:setBeamWeapon(2,  60,    0, 1000.0,   6.0, 4)
    template:setBeamWeapon(3,  90,    0,  800.0,   6.0, 4)
    --   Tubes    Count, Load Time
    template:setTubes(2, 15.0)
    --     Tube direction    ID, Bearing
    template:setTubeDirection(0, -90)
    template:setTubeDirection(1,  90)
    --     Tube weapon storage    Type, Count
    template:setWeaponStorage("Homing", 4)
    template:setWeaponStorage(  "Nuke", 1)
    template:setWeaponStorage(   "EMP", 2)
    template:setWeaponStorage(  "HVLI", 8)

    -- Internal layout
    --   Repair crew count
    template:setRepairCrewCount(2)
    --   Rooms         Position  Size
    --                     X  Y  W  H  System
    template:addRoomSystem(0, 0, 1, 4, "Reactor")
    template:addRoomSystem(1, 0, 1, 1, "JumpDrive")
    template:addRoomSystem(1, 3, 1, 1, "Warp")
    template:addRoomSystem(2, 0, 1, 1, "FrontShield")
    template:addRoomSystem(2, 3, 1, 1, "RearShield")
    template:addRoomSystem(3, 0, 1, 1, "MissileSystem")
    template:addRoomSystem(3, 3, 1, 1, "Impulse")
    template:addRoomSystem(3, 1, 2, 1, "Maneuver")
    template:addRoom(      3, 2, 2, 1)
    template:addRoomSystem(5, 1, 2, 2, "BeamWeapons")
    --   Doors   Position
    --               X  Y  Horizontal?
    template:addDoor(1, 0, false)
    template:addDoor(1, 3, false)
    template:addDoor(2, 0, false)
    template:addDoor(2, 3, false)
    template:addDoor(3, 0, false)
    template:addDoor(3, 3, false)
    template:addDoor(3, 3, true)
    template:addDoor(3, 2, true)
    template:addDoor(5, 1, false)

------------------------Piranha F12-------------------------
template = ShipTemplate():setName("Piranha F12")
    template:setLocaleName(_("Piranha F12"))
    template:setClass(_("Frigate"), _("Cruiser"))
    template:setModel("HeavyCorvetteRed")
    template:setRadarTrace("radar_piranha.png")
    template:setDescription(_([[A light artillery cruiser, the Piranha F12 is the smallest ship to exclusively fire from broadside weapon tubes.]]))

    -- Defenses
    template:setHull(70)
    template:setShields(30, 30)

    -- Maneuverability
    --   Impulse Forward, Turn, Acceleration
    template:setSpeed(40,    6, 8)

    -- Weapons
    --   Tubes    Count, Load Time
    template:setTubes(6, 15.0)
    --     Tube direction    ID, Bearing
    template:setTubeDirection(0, -90)
    template:setTubeDirection(1, -90)
    template:setTubeDirection(2, -90)
    template:setTubeDirection(3,  90)
    template:setTubeDirection(4,  90)
    template:setTubeDirection(5,  90)
    --     Tube size    ID, Size (small, medium, large)
    template:setTubeSize(0, "large")
    template:setTubeSize(2, "large")
    template:setTubeSize(3, "large")
    template:setTubeSize(5, "large")
    --     Tube specialization        ID, Type
    template:setWeaponTubeExclusiveFor(0, "HVLI")
    template:setWeaponTubeExclusiveFor(2, "HVLI")
    template:setWeaponTubeExclusiveFor(3, "HVLI")
    template:setWeaponTubeExclusiveFor(5, "HVLI")
    --     Tube weapon storage    Type, Count
    template:setWeaponStorage(  "HVLI", 20)
    template:setWeaponStorage("Homing", 6)

-----------------------Piranha F12.M------------------------
variation = template:copy("Piranha F12.M")
    variation:setLocaleName(_("Piranha F12.M"))
    variation:setDescription(_([[This modified Piranha F12 is in all respects the same vessel except for special weapon tube modifications that allow it to fire nukes in addition to its normal loadout. However, these changes reduce its overall missile storage capacity.]]))

    -- Weapons
    --     Tube weapon storage     Type, Count
    variation:setWeaponStorage(  "HVLI", 10)
    variation:setWeaponStorage("Homing",  4)
    variation:setWeaponStorage(  "Nuke",  2)

-------------------------Piranha F8-------------------------
variation = template:copy("Piranha F8")
    variation:setLocaleName(_("Piranha F8"))
    variation:setDescription(_([[The first version of the Piranha was not popular due to its meager firepower and odd tube configuration. The result was a huge financial failure.]]))
    -- Weapons
    --   Tubes     Count, Load Time
    variation:setTubes(3, 12.0)
    --     Tube direction     ID, Bearing
    variation:setTubeDirection(0,   0)
    variation:setTubeDirection(1, -90)
    variation:setTubeDirection(2,  90)
    --     Tube specialization         ID, Type
    variation:setWeaponTubeExclusiveFor(0, "HVLI")
    --     Tube weapon storage     Type, Count
    variation:setWeaponStorage(  "HVLI", 10)
    variation:setWeaponStorage("Homing",  5)

--------------------------Piranha---------------------------
variation = template:copy("Piranha")
    variation:setLocaleName(_("Piranha"))
    variation:setDescription(_([[This combat-specialized Piranha F12 adds mine-laying tubes, combat maneuvering systems, and a jump drive.]]))
    variation:setType("playership")

    -- Defenses
    variation:setHull(120)
    variation:setShields(70, 70)

    -- Maneuverability
    --   Impulse  Forward, Turn, Acceleration
    variation:setSpeed(60, 10, 8)
    --   Combat Maneuver      Boost, Strafe
    variation:setCombatManeuver(200, 150)
    --   Long-range Propulsion
    variation:setJumpDrive(true)

    -- Weapons
    --   Tubes     Count, Load Time
    variation:setTubes(8, 8.0)
    --     Tube direction     ID, Bearing
    variation:setTubeDirection(6, 170)
    variation:setTubeDirection(7, 190)
    --     Tube specialization         ID, Type
    variation:weaponTubeAllowMissle(    0, "Homing")
    variation:weaponTubeAllowMissle(    2, "Homing")
    variation:weaponTubeAllowMissle(    3, "Homing")
    variation:weaponTubeAllowMissle(    5, "Homing")
    variation:setWeaponTubeExclusiveFor(6, "Mine")
    variation:setWeaponTubeExclusiveFor(7, "Mine")
    --     Tube weapon storage     Type, Count
    variation:setWeaponStorage(  "HVLI", 20)
    variation:setWeaponStorage("Homing", 12)
    variation:setWeaponStorage(  "Nuke", 6)
    variation:setWeaponStorage(  "Mine", 8)

    -- Internal layout
    --   Repair crew count
    variation:setRepairCrewCount(2)
    --   Rooms          Position  Size
    --                      X  Y  W  H  System
    variation:addRoomSystem(0, 0, 1, 4, "RearShield")
    variation:addRoom(      1, 0, 1, 1)
    variation:addRoomSystem(1, 1, 3, 2, "MissileSystem")
    variation:addRoom(      1, 3, 1, 1)

    variation:addRoomSystem(2, 0, 2, 1, "BeamWeapons")
    variation:addRoomSystem(2, 3, 2, 1, "Maneuver")

    variation:addRoomSystem(4, 0, 2, 1, "Warp")
    variation:addRoomSystem(4, 3, 2, 1, "JumpDrive")
    variation:addRoomSystem(5, 1, 1, 2, "Reactor")

    variation:addRoom(      6, 0, 1, 1)
    variation:addRoomSystem(6, 1, 1, 2, "Impulse")
    variation:addRoom(      6, 3, 1, 1)

    variation:addRoomSystem(7, 0, 1, 4, "FrontShield")
    --   Doors    Position
    --                X  Y  Horizontal?
    variation:addDoor(1, 0, false)
    variation:addDoor(2, 0, false)
    variation:addDoor(4, 0, false)
    variation:addDoor(6, 0, false)
    variation:addDoor(7, 0, false)

    variation:addDoor(1, 1, true)
    variation:addDoor(1, 3, true)

    variation:addDoor(6, 1, true)
    variation:addDoor(6, 2, false)
    variation:addDoor(6, 3, true)

    variation:addDoor(1, 3, false)
    variation:addDoor(2, 3, false)
    variation:addDoor(4, 3, false)
    variation:addDoor(6, 3, false)
    variation:addDoor(7, 3, false)

-------------------------Stalker Q7-------------------------
template = ShipTemplate():setName("Stalker Q7")
    template:setLocaleName(_("Stalker Q7"))
    template:setClass(_("Frigate"), _("Cruiser"))
    template:setModel("small_frigate_3")
    template:setDescription(_([[The Stalker is a strike cruiser designed to swoop into battle, deal damage quickly, and get out fast. The Q7 model is fitted with a warp drive.]]))
    template:setRadarTrace("radar_cruiser.png")

    -- Defenses
    template:setHull(50)
    template:setShields(80, 30, 30, 30)
    -- Maneuverability
    --   Impulse Forward, Turn, Acceleration
    template:setSpeed(70, 12, 12)
    --   Long-range Propulsion
    --     Warp speed per factor
    template:setWarpSpeed(   700)

    -- Weapons
    --   Beams            ID, Arc, Bear,  Range, Cycle, Damage
    template:setBeamWeapon(0,  40,   -5, 1000.0,   6.0, 6)
    template:setBeamWeapon(1,  40,    5, 1000.0,   6.0, 6)

-------------------------Stalker R7-------------------------
variation = template:copy("Stalker R7")
    variation:setLocaleName(_("Stalker R7"))
    variation:setDescription(_([[The Stalker is a strike cruiser designed to swoop into battle, deal damage quickly, and get out fast. The R7 model is fitted with a jump drive.]]))
    --   Long-range Propulsion
    variation:setJumpDrive(true)
    --     Warp speed per factor
    variation:setWarpSpeed(    0)

--------------------------Ranus U---------------------------
template = ShipTemplate():setName("Ranus U")
    template:setLocaleName(_("Ranus U"))
    template:setClass(_("Frigate"), _("Cruiser"))
    template:setModel("MissileCorvetteGreen")
    template:setDescription(_([[The Ranus U sniper is built to deal large amounts of damage quickly and from a distance before escaping. It's the only basic frigate that carries nuclear weapons, even though it's also the smallest of all frigate-class ships.]]))
    template:setRadarTrace("radar_cruiser.png")

    -- Defenses
    template:setHull(30)
    template:setShields(30, 5, 5)
    -- Maneuverability
    --   Impulse Forward, Turn, Acceleration
    template:setSpeed(50,    6, 20)

    -- Weapons
    --   Tubes    Count, Load Time
    template:setTubes(3, 25.0)
    --     Tube specialization        ID, Type
    template:weaponTubeDisallowMissle( 1, "Nuke")
    template:weaponTubeDisallowMissle( 2, "Nuke")
    template:setWeaponStorage("Homing", 6)
    --     Tube weapon storage    Type, Count
    template:setWeaponStorage(  "Nuke", 2)

---------------------LIGHT TRANSPORTS----------------------

--------------------------Flavia---------------------------
template = ShipTemplate():setName("Flavia")
    template:setLocaleName(_("Flavia"))
    template:setClass(_("Frigate"), _("Light transport"))
    template:setModel("LightCorvetteGrey")
    template:setDescription(_([[Popular among traders and smugglers, the Flavia is a small cargo and passenger transport. It's cheaper than a freighter for small loads and short distances, and is often used to carry high-value cargo discreetly.]]))
    template:setRadarTrace("radar_tug.png")

    -- Defenses
    template:setHull(50)
    template:setShields(50, 50)

    -- Maneuverability
    --   Impulse Forward, Turn, Acceleration
    template:setSpeed(30,    8, 10)

-----------------------Flavia Falcon------------------------
variation = template:copy("Flavia Falcon")
    variation:setLocaleName(_("Flavia Falcon"))
    variation:setDescription(_([[The Flavia Falcon is a Flavia transport modified for faster flight, and adds rear-mounted lasers to keep enemies off its back.]]))

    -- Maneuverability
    --   Impulse  Forward, Turn, Acceleration
    variation:setSpeed(50, 8, 10)

    -- Weapons
    --   Beams             ID, Arc, Bear,  Range, Cycle, Damage
    variation:setBeamWeapon(0,  40,  170, 1200.0,   6.0, 6)
    variation:setBeamWeapon(1,  40,  190, 1200.0,   6.0, 6)

---------------Flavia P.Falcon (player ship)----------------
variation = variation:copy("Flavia P.Falcon")
    variation:setLocaleName(_("Flavia P.Falcon"))
    variation:setDescription(_([[The heavily (and in some sectors, illegally) modified Flavia P.Falcon has a nuclear-capable rear-facing weapon tube and a warp drive.]]))
    variation:setType("playership")

    -- Defenses
    variation:setHull(100)
    variation:setShields(70, 70)

    -- Maneuverability
    --   Impulse  Forward, Turn, Acceleration
    variation:setSpeed(60, 10, 10)
    --   Combat Maneuver      Boost, Strafe
    variation:setCombatManeuver(250, 150)
    --   Long-range Propulsion
    --     Warp speed per factor
    variation:setWarpSpeed(  500)
    -- Weapons
    --   Tubes     Count, Load Time
    variation:setTubes(1, 20.0)
    --     Tube direction     ID, Bearing
    variation:setTubeDirection(0, 180)
    --     Tube weapon storage     Type, Count
    variation:setWeaponStorage("Homing", 3)
    variation:setWeaponStorage(  "Nuke", 1)
    variation:setWeaponStorage(  "HVLI", 5)
    variation:setWeaponStorage(  "Mine", 1)

    -- Internal layout
    --   Repair crew count
    variation:setRepairCrewCount(8)
    --   Rooms          Position  Size
    --                      X  Y  W  H  System
    variation:addRoom(      1, 0, 6, 1)
    variation:addRoom(      1, 5, 6, 1)
    variation:addRoomSystem(0, 1, 2, 2, "RearShield")
    variation:addRoomSystem(0, 3, 2, 2, "MissileSystem")
    variation:addRoomSystem(2, 1, 2, 2, "BeamWeapons")
    variation:addRoomSystem(2, 3, 2, 2, "Reactor")
    variation:addRoomSystem(4, 1, 2, 2, "Warp")
    variation:addRoomSystem(4, 3, 2, 2, "JumpDrive")
    variation:addRoomSystem(6, 1, 2, 2, "Impulse")
    variation:addRoomSystem(6, 3, 2, 2, "Maneuver")
    variation:addRoomSystem(8, 2, 2, 2, "FrontShield")
    --   Doors    Position
    --                X  Y  Horizontal?
    variation:addDoor(1, 1, true)
    variation:addDoor(3, 1, true)
    variation:addDoor(4, 1, true)
    variation:addDoor(6, 1, true)

    variation:addDoor(4, 3, true)
    variation:addDoor(5, 3, true)

    variation:addDoor(8, 2, false)
    variation:addDoor(8, 3, false)

    variation:addDoor(1, 5, true)
    variation:addDoor(2, 5, true)
    variation:addDoor(5, 5, true)
    variation:addDoor(6, 5, true)

template = ShipTemplate():setName("Repulse"):setLocaleName(_("Repulse")):setClass(_("Frigate"), _("Armored Transport")):setModel("LightCorvetteRed"):setType("playership")
template:setRadarTrace("radar_tug.png")
template:setDescription("Jump/Turret version of Flavia Falcon")
template:setHull(120)
template:setShields(80, 80)
template:setSpeed(55, 9, 10)
--                 Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 10, 90, 1200.0, 6.0, 5)
template:setBeam(1, 10,-90, 1200.0, 6.0, 5)
--								Arc, Dir, Rotate speed
template:setBeamWeaponTurret(0, 200,  90, 5)
template:setBeamWeaponTurret(1, 200, -90, 5)
template:setJumpDrive(true)
template:setCombatManeuver(250,150)
template:setTubes(2, 20.0)
template:setTubeDirection(0, 0)
template:setTubeDirection(1, 180)
template:setWeaponStorage("HVLI", 6)
template:setWeaponStorage("Homing", 4)

template:setRepairCrewCount(8)
--	(H)oriz, (V)ert	   HC,VC,HS,VS, system    (C)oordinate (S)ize
template:addRoomSystem( 0, 1, 2, 4, "Impulse")
template:addRoomSystem( 2, 0, 2, 2, "RearShield")
template:addRoomSystem( 2, 2, 2, 2, "Warp")
template:addRoom( 2, 4, 2, 2)
template:addRoomSystem( 4, 1, 1, 4, "Maneuver")
template:addRoom( 5, 0, 2, 2)
template:addRoomSystem( 5, 2, 2, 2, "JumpDrive")
template:addRoomSystem( 5, 4, 2, 2, "BeamWeapons")
template:addRoomSystem( 7, 1, 3, 2, "Reactor")
template:addRoomSystem( 7, 3, 3, 2, "MissileSystem")
template:addRoomSystem(10, 2, 2, 2, "FrontShield")

template:addDoor( 2, 2, false)
template:addDoor( 2, 4, false)
template:addDoor( 3, 2, true)
template:addDoor( 4, 3, false)
template:addDoor( 5, 2, false)
template:addDoor( 5, 4, true)
template:addDoor( 7, 3, false)
template:addDoor( 7, 1, false)
template:addDoor( 8, 3, true)
template:addDoor(10, 2, false)

--Support: mine layer
--Support: mine sweeper
--Support: science vessel
--Support: deep space recon
--Support: light repair
--Support: resupply
