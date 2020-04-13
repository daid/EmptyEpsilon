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
    template:setWeaponStorage("Homing",  6)
    template:setWeaponStorage(  "HVLI", 20)

-----------------------Player Cruiser-----------------------
variation1 = template:copy("Player Cruiser")
	variation1:setLocaleName(_("Player Cruiser"))
	variation1:setModel("AtlasHeavyFighterWhite")
	variation1:setRadarTrace("radar_cruiser.png")
	variation1:setType("playership")

    -- Defenses
	variation1:setHull(200)
	variation1:setShields(80, 80)

    -- Maneuverability
    --   Impulse   Forward, Turn, Acceleration
	variation1:setSpeed(90,   10, 20)
    --   Combat Maneuver       Boost, Strafe
	variation1:setCombatManeuver(400, 250)
    --   Long-range propulsion
	variation1:setJumpDrive(true)

    -- Weapons
    --   Beams              ID, Arc, Bear,  Range, Cycle, Damage
    variation1:setBeamWeapon(0,  90,  -15, 1000.0,   6.0, 10)
	variation1:setBeamWeapon(1,  90,   15, 1000.0,   6.0, 10)
    --   Tubes      Count, Load Time
	variation1:setTubes(3, 8.0)
    --     Tube direction      ID, Bearing
	variation1:setTubeDirection(0,  -1)
	variation1:setTubeDirection(1,   1)
	variation1:setTubeDirection(2, 180)
    --     Tube specialization          ID, Type
	variation1:weaponTubeDisallowMissle( 0, "Mine")
	variation1:weaponTubeDisallowMissle( 1, "Mine")
	variation1:setWeaponTubeExclusiveFor(2, "Mine")
    --     Tube weapon storage      Type, Count
	variation1:setWeaponStorage("Homing", 12)
	variation1:setWeaponStorage(  "Nuke",  4)
	variation1:setWeaponStorage(   "EMP",  6)
	variation1:setWeaponStorage(  "Mine",  8)

    -- Internal layout
    --   Rooms           Position  Size
    --                       X  Y  W  H  System
	variation1:addRoomSystem(1, 0, 2, 1, "Maneuver");
	variation1:addRoomSystem(1, 1, 2, 1, "BeamWeapons");
	variation1:addRoom(      2, 2, 2, 1);

	variation1:addRoomSystem(0, 3, 1, 2, "RearShield");
	variation1:addRoomSystem(1, 3, 2, 2, "Reactor");
	variation1:addRoomSystem(3, 3, 2, 2, "Warp");
	variation1:addRoomSystem(5, 3, 1, 2, "JumpDrive");
	variation1:addRoom(	     6, 3, 2, 1);
	variation1:addRoom(	     6, 4, 2, 1);
	variation1:addRoomSystem(8, 3, 1, 2, "FrontShield");

	variation1:addRoom(	     2, 5, 2, 1);
	variation1:addRoomSystem(1, 6, 2, 1, "MissileSystem");
	variation1:addRoomSystem(1, 7, 2, 1, "Impulse");
    --   Doors     Position
    --                 X  Y  Horizontal?
	variation1:addDoor(1, 1, true);
	variation1:addDoor(2, 2, true);
	variation1:addDoor(3, 3, true);
	variation1:addDoor(1, 3, false);
	variation1:addDoor(3, 4, false);
	variation1:addDoor(3, 5, true);
	variation1:addDoor(2, 6, true);
	variation1:addDoor(1, 7, true);
	variation1:addDoor(5, 3, false);
	variation1:addDoor(6, 3, false);
	variation1:addDoor(6, 4, false);
	variation1:addDoor(8, 3, false);
	variation1:addDoor(8, 4, false);

-------------------------Phobos M3--------------------------
variation2 = template:copy("Phobos M3")
    variation2:setLocaleName(_("Phobos M3"))
    variation2:setModel("AtlasHeavyFighterRed")
    variation2:setDescription(_([[The Phobos M3 is one of the most common variants of the Phobos T3. It adds a mine-laying tube, but the extra storage required for the mines slows this ship down slightly.]]))

    -- Maneuverability
    --   Impulse   Forward, Turn, Acceleration
    variation2:setSpeed(55,   10, 10)

    -- Weapons
    --   Tubes      Count, Load Time
    variation2:setTubes(3, 60.0)
    --     Tube direction      ID, Bearing
    variation2:setTubeDirection(2,  180)
    --     Tube specialization          ID, Type
    variation2:weaponTubeDisallowMissle( 0, "Mine")
    variation2:weaponTubeDisallowMissle( 1, "Mine")
    variation2:setWeaponTubeExclusiveFor(2, "Mine")
    --     Tube weapon storage      Type, Count
    variation2:setWeaponStorage(  "Mine", 6)

------------------Phobos M3P (player ship)------------------
variation3 = variation2:copy("Phobos M3P")
    variation3:setLocaleName(_("Phobos M3P"))
    variation3:setDescription(_([[A subvariant of the Phobos M3 with front-firing weapon tubes, more powerful impulse engines, and bolstered defenses.]]))
    variation3:setType("playership")

    -- Defenses
    variation3:setHull(200)
    variation3:setShields(100, 100)

    -- Maneuverability
    --   Impulse   Forward, Turn, Acceleration
    variation3:setSpeed(80,   10, 20)
    --   Combat Maneuver       Boost, Strafe
    variation3:setCombatManeuver(400, 250)

    -- Weapons
    --   Tubes      Count, Load Time
    variation3:setTubes(3, 10.0)
    --     Tube weapon storage      Type, Count
    variation3:setWeaponStorage("Homing", 10)
    variation3:setWeaponStorage(  "Nuke",  2)
    variation3:setWeaponStorage(   "EMP",  3)
    variation3:setWeaponStorage(  "Mine",  4)

    -- Internal layout
    --   Rooms           Position  Size
    --                       X  Y  W  H  System
    variation3:addRoomSystem(1, 0, 2, 1, "Maneuver");
    variation3:addRoomSystem(1, 1, 2, 1, "BeamWeapons");
    variation3:addRoom(      2, 2, 2, 1);

    variation3:addRoomSystem(0, 3, 1, 2, "RearShield");
    variation3:addRoomSystem(1, 3, 2, 2, "Reactor");
    variation3:addRoomSystem(3, 3, 2, 2, "Warp");
    variation3:addRoomSystem(5, 3, 1, 2, "JumpDrive");
    variation3:addRoom(      6, 3, 2, 1);
    variation3:addRoom(      6, 4, 2, 1);
    variation3:addRoomSystem(8, 3, 1, 2, "FrontShield");

    variation3:addRoom(      2, 5, 2, 1);
    variation3:addRoomSystem(1, 6, 2, 1, "MissileSystem");
    variation3:addRoomSystem(1, 7, 2, 1, "Impulse");
    --   Doors     Position
    --                 X  Y  Horizontal?
    variation3:addDoor(1, 1, true);
    variation3:addDoor(2, 2, true);
    variation3:addDoor(3, 3, true);
    variation3:addDoor(1, 3, false);
    variation3:addDoor(3, 4, false);
    variation3:addDoor(3, 5, true);
    variation3:addDoor(2, 6, true);
    variation3:addDoor(1, 7, true);
    variation3:addDoor(5, 3, false);
    variation3:addDoor(6, 3, false);
    variation3:addDoor(6, 4, false);
    variation3:addDoor(8, 3, false);
    variation3:addDoor(8, 4, false);

-------------------Karnack MK1 (Karnack)--------------------
template = ShipTemplate():setName("Karnack")
	template:setLocaleName(_("Karnack MK1"))
	template:setClass(_("Frigate"), _("Cruiser"))
	template:setModel("small_frigate_4")
	template:setDescription(_([[Fabricated by Repulse shipyards, the mark I Karnack cruiser is a versatile ship adopted widely across most factions. Most have extensively retrofitted these ships to suit their combat doctrines. Because the Karnack is an older hull style, most factions also sell stripped versions that are popular with smugglers and other civillian parties, who have used its adaptable nature to re-fit them with (often illegal) weaponry.]]))
	template:setRadarTrace("radar_cruiser.png")

	-- Defenses
	template:setHull(60)
	template:setShields(40, 40)

    -- Maneuverability
    --   Impulse Forward, Turn, Acceleration
	template:setSpeed(60,    6, 10)

    -- Weapons
    --   Beams            ID, Arc, Bear,  Range, Cycle, Damage
	template:setBeamWeapon(0,  60,  -15, 1000.0,   6.0, 6)
	template:setBeamWeapon(1,  60,   15, 1000.0,   6.0, 6)

------------------------Karnack MK2-------------------------
variation = template:copy("Cruiser")
	variation:setLocaleName(_("ship", "Karnack MK2"))
	variation:setDescription(_([[Fabricated by Repulse shipyards, the mark II Karnack cruiser made several notable improvements over its wildly popular predecessor, including better armor, slightly improved weaponry, and further customization by the shipyards. The latter improvement was the most requested feature by several factions once they realized that their old surplus mark I ships were used for less savoury purposes.]]))

    -- Defenses
	variation:setHull(70)

    -- Weapons
    --   Beams            ID, Arc, Bear,  Range, Cycle, Damage
    variation:setBeamWeapon(0, 90,  -15, 1000.0,   6.0, 6)
	variation:setBeamWeapon(1, 90,   15, 1000.0,   6.0, 6)

------------------------Polaris MK1-------------------------
template = ShipTemplate():setName("Missile Cruiser")
	template:setLocaleName(_("Polaris MK1"))
	template:setClass(_("Frigate"), _("Cruiser"))
	template:setModel("space_cruiser_4")
	template:setDescription(_([[The mark I Polaris missle cruiser, fabricated by Repulse shipyards, is a long-range missile platform. While it can't absorb much damage, it can deal a lot if not dealt with properly.]]))
	template:setRadarTrace("radar_missile_cruiser.png")
    template:setDefaultAI("missilevolley")

	-- Defenses
	template:setHull(40)
	template:setShields(50, 50)

    -- Maneuverability
    --   Impulse Forward, Turn, Acceleration
	template:setSpeed(45, 3, 10)

	-- Weapons
    --   Tubes    Count, Load Time
	template:setTubes(1, 25.0)
    --     Tube weapon storage    Type, Count
	template:setWeaponStorage("Homing", 10)

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

-------------------Hathcock (player ship)-------------------
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

-------------------Piranha (player ship)--------------------
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
    variation:setWeaponStorage("Homing", 12)
    variation:setWeaponStorage(  "Nuke", 6)
    variation:setWeaponStorage(  "HVLI", 20)
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
    template:setDescription(_([[The Ranus U sniper is built to deal large amounts of damage quickly and from a distance before escaping. It's the only mainstream frigate that carries nuclear weapons, even though it's also the smallest of all frigate-class ships.]]))
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
    --     Tube weapon storage    Type, Count
    template:setWeaponStorage("Homing", 6)
    template:setWeaponStorage(  "Nuke", 2)

--------------------------Gunship---------------------------
template = ShipTemplate():setName("Gunship")
	template:setLocaleName(_("Gunship"))
	template:setClass(_("Frigate"), _("subclass", "Cruiser"))
    template:setDescription(_([[The gunship is equipped with a homing missile tube to do initial damage to a target, and 2 front-firing beams to finish it off. It's designed to quickly take out the enemies weaker then itself.]]))
)	template:setModel("battleship_destroyer_4_upgraded")
	template:setRadarTrace("radar_adv_gunship.png")

    -- Defenses
	template:setHull(100)
	template:setShields(100, 80, 80)

    -- Maneuverability
    --   Impulse Forward, Turn, Acceleration
	template:setSpeed(60,    5, 10)

    -- Weapons
    --   Beams            ID, Arc, Bear,  Range, Cycle, Damage
	template:setBeamWeapon(0,  50,  -15, 1000.0,   6.0, 8)
	template:setBeamWeapon(1,  50,   15, 1000.0,   6.0, 8)
    --   Tubes    Count, Load Time
	template:setTubes(1, 8.0) -- Amount of torpedo tubes
    --     Tube weapon storage    Type, Count
	template:setWeaponStorage("Homing", 4)

------------------------Adv. Gunship------------------------
variation = template:copy("Adv. Gunship")
    variation:setDescription(_([[The advanced gunship is equipped with 2 homing missile tubes to do initial damage to a target, and 2 front-firing beams to finish it off. It's designed to quickly take out the enemies weaker then itself.]]))
	variation:setLocaleName(_("Adv. Gunship"))

	-- Weapons
    --   Tubes     Count, Load Time
	variation:setTubes(2, 8.0)

-------------------------Strikeship-------------------------
template = ShipTemplate():setName("Strikeship")
	template:setLocaleName(_("Strikeship"))
	template:setClass(_("Frigate"), _("subclass", "Cruiser"))
	template:setModel("small_frigate_3")
	template:setDescription(_([[The strikeship is a warp drive-equipped frigate built for quick long-range strikes. It's fast and agile, but doesn't do an extreme amount of damage and is vulnerable to attacks from its sides and rear.]]))
	template:setRadarTrace("radar_striker.png")

    -- Defenses
	template:setHull(100)
	template:setShields(80, 30, 30, 30)

    -- Maneuverability
    --   Impulse Forward, Turn, Acceleration
	template:setSpeed(70, 12, 12)
    --   Long-range Propulsion
    --     Warp speed per factor
	template:setWarpSpeed(  1000)

    -- Weapons
    --   Beams            ID, Arc, Bear,  Range, Cycle, Damage
    template:setBeamWeapon(0,  40,   -5, 1000.0,   6.0, 6)
	template:setBeamWeapon(1,  40,    5, 1000.0,   6.0, 6)

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
    variation:setSpeed(50,    8, 10)

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

---------------Repulse (player ship)----------------
variation = template:copy("Repulse")
    variation:setLocaleName(_("Repulse"))
    variation:setModel("LightCorvetteRed")
    variation:setDescription(_([[The Repulse is an armored transport version of the Flavia Falcon that employs a jump drive and turreted beam weapons.]]))
    variation:setType("playership")

    -- Defenses
    variation:setHull(120)
    variation:setShields(80, 80)

    -- Maneuverability
    --   Impulse  Forward, Turn, Acceleration
    variation:setSpeed(55,    9, 10)
    --   Combat Maneuver      Boost, Strafe
    variation:setCombatManeuver(250, 150)
    --   Long-range Propulsion
    variation:setJumpDrive(true)

    -- Weapons
    --   Beams             ID, Arc, Bear,  Range, Cycle, Damage
    variation:setBeamWeapon(0,  10,   90, 1200.0,   6.0, 5)
    variation:setBeamWeapon(1,  10,  -90, 1200.0,   6.0, 5)
    --     Beam turrets          ID, Arc, Dir, Rotation Speed
    variation:setBeamWeaponTurret(0, 200,  90, 5)
    variation:setBeamWeaponTurret(1, 200, -90, 5)
    --   Tubes     Count, Load Time
    variation:setTubes(2, 20.0)
    --     Tube direction     ID, Bearing
    variation:setTubeDirection(0, 0)
    variation:setTubeDirection(1, 180)
    --     Tube weapon storage     Type, Count
    variation:setWeaponStorage(  "HVLI", 6)
    variation:setWeaponStorage("Homing", 4)

    -- Internal layout
    --   Repair crew count
    variation:setRepairCrewCount(8)
    --   Rooms           Position  Size
    --                       X  Y  W  H  System
    variation:addRoomSystem( 0, 1, 2, 4, "Impulse")
    variation:addRoomSystem( 2, 0, 2, 2, "RearShield")
    variation:addRoomSystem( 2, 2, 2, 2, "Warp")
    variation:addRoom(       2, 4, 2, 2)
    variation:addRoomSystem( 4, 1, 1, 4, "Maneuver")
    variation:addRoom(       5, 0, 2, 2)
    variation:addRoomSystem( 5, 2, 2, 2, "JumpDrive")
    variation:addRoomSystem( 5, 4, 2, 2, "BeamWeapons")
    variation:addRoomSystem( 7, 1, 3, 2, "Reactor")
    variation:addRoomSystem( 7, 3, 3, 2, "MissileSystem")
    variation:addRoomSystem(10, 2, 2, 2, "FrontShield")
    --   Doors     Position
    --                 X  Y  Horizontal?
    variation:addDoor( 2, 2, false)
    variation:addDoor( 2, 4, false)
    variation:addDoor( 3, 2, true)
    variation:addDoor( 4, 3, false)
    variation:addDoor( 5, 2, false)
    variation:addDoor( 5, 4, true)
    variation:addDoor( 7, 3, false)
    variation:addDoor( 7, 1, false)
    variation:addDoor( 8, 3, true)
    variation:addDoor(10, 2, false)

----------------------Blockade Runner-----------------------
template = ShipTemplate():setName("Blockade Runner")
template:setLocaleName(_("Blockade Runner"))
template:setClass(_("Frigate"), _("Light transport"))
template:setModel("battleship_destroyer_3_upgraded")
template:setDescription(_([[Blockade runners are reasonably fast, highly shielded transport ships designed to break through blockades and defensive lines in order to deliver goods and harry defensive installations.]]))
template:setRadarTrace("radar_blockade.png")

-- Defenses
template:setHull(70)
template:setShields(100, 150)

-- Maneuverability
--   Impulse Forward, Turn, Acceleration
template:setSpeed(60,   15, 25)

-- Weapons
--   Beams            ID, Arc, Bear,  Range, Cycle, Damage
template:setBeamWeapon(0,  60,  -15, 1000.0,   6.0, 8)
template:setBeamWeapon(1,  60,   15, 1000.0,   6.0, 8)
template:setBeamWeapon(2,  25,  170, 1000.0,   6.0, 8)
template:setBeamWeapon(3,  25,  190, 1000.0,   6.0, 8)

--------------------------SUPPORT---------------------------

----------------------------Tug-----------------------------
template = ShipTemplate():setName("Tug")
	template:setLocaleName(_("Tug"))
	template:setClass(_("Frigate"), _("Support"))
	template:setModel("space_tug")
	template:setDescription(_([[The tugboat is a reliable, but small and unarmed transport ship. Due to its low cost, it is a favourite ship to teach the ropes to fledgling captains without risking friendly fire.]]))
	template:setRadarTrace("radar_tug.png")

	-- Capabilities
	template:setEnergyStorage(800)

	-- Defenses
	template:setHull(50)
	template:setShields(20)

    -- Maneuverability
    --   Impulse  Forward, Turn, Acceleration
	template:setSpeed(100,   10, 15)

-------------------Nautilus (player ship)-------------------
variation = template:copy("Nautilus")
	variation:setLocaleName(_("Nautilus"))
	variation:setDescription(_([[The Nautilus is a swift, small, jump-capable minelayer with minimal armaments and shields.]]))
	variation:setType("playership")

	-- Defenses
	variation:setHull(100)
	variation:setShields(60, 60)

    -- Maneuverability
    --   Combat Maneuver      Boost, Strafe
	variation:setCombatManeuver(250, 150)
	--   Long-range Propulsion
	variation:setJumpDrive(true)

    -- Weapons
    --   Beams             ID, Arc, Bear,  Range, Cycle, Damage
	variation:setBeamWeapon(0,  10,   35, 1000.0,   6.0, 6)
	variation:setBeamWeapon(1,  10,  -35, 1000.0,   6.0, 6)
    --     Beam turrets          ID, Arc, Dir, Rotation Speed
	variation:setBeamWeaponTurret(0,  90,  35, 6)
	variation:setBeamWeaponTurret(1,  90, -35, 6)
    --   Tubes    Count, Load Time
	variation:setTubes(3, 10.0)
    --     Tube direction     ID, Bearing
	variation:setTubeDirection(0, 180)
	variation:setTubeDirection(1, 180)
	variation:setTubeDirection(2, 180)
	--     Tube weapon storage     Type, Count
	variation:setWeaponStorage(  "Mine", 12)

    -- Internal layout
    --   Repair crew count
	variation:setRepairCrewCount(4)
    --   Rooms          Position  Size
    --                      X  Y  W  H  System
	variation:addRoomSystem(0, 1, 1, 2, "Impulse")
	variation:addRoomSystem(1, 0, 2, 1, "RearShield")
	variation:addRoomSystem(1, 1, 2, 2, "JumpDrive")
	variation:addRoomSystem(1, 3, 2, 1, "FrontShield")
	variation:addRoomSystem(3, 0, 2, 1, "BeamWeapons")
	variation:addRoomSystem(3, 1, 3, 1, "Warp")
	variation:addRoomSystem(3, 2, 3, 1, "Reactor")
	variation:addRoomSystem(3, 3, 2, 1, "MissileSystem")
	variation:addRoomSystem(6, 1, 1, 2, "Maneuver")
    --   Doors    Position
    --                X  Y  Horizontal?
	variation:addDoor(1, 1, false)
	variation:addDoor(2, 1, true)
	variation:addDoor(1, 3, true)
	variation:addDoor(3, 2, false)
	variation:addDoor(4, 3, true)
	variation:addDoor(6, 1, false)
	variation:addDoor(4, 2, true)
	variation:addDoor(4, 1, true)

--Support: mine sweeper
--Support: science vessel
--Support: deep space recon
--Support: light repair
--Support: resupply
