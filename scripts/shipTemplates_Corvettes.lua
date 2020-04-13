--[[----------------------CORVETTES-------------------------
Corvettes are common large ships, larger than frigates and
smaller than dreadnoughts. They generally have at least 4
shield sections and operate with a crew of 20 to 250.

Ships of this class generally have jump or warp drives, but
lack the maneuverability of frigates.

There are 3 corvette subclasses:

* Destroyers: Combat-oriented corvettes. No science, no
    transport, just death in a large package.
* Support: Large-scale support roles. Drone carriers and
    mobile repair centers fall in this category.
* Freighters: Large-scale transport ships. The most common
    freighters are jump freighters, which use specialized
    jump drives to cross large distances with large amounts
    of cargo.
----------------------------------------------------------]]

-------------------------DESTROYERS-------------------------

------------------------Atlantis X23------------------------
template = ShipTemplate():setName("Atlantis X23")
    template:setLocaleName(_("Atlantis X23"))
    template:setClass(_("Corvette"), _("Destroyer"))
    template:setModel("battleship_destroyer_1_upgraded")
    template:setDescription(_([[The Atlantis X23 is the smallest model of destroyer, and its combination of frigate-like size and corvette-like power makes it an excellent escort ship when defending larger ships against multiple smaller enemies. Because the Atlantis X23 is fitted with a jump drive, it can also serve as an intersystem patrol craft.]]))
    template:setRadarTrace("radar_dread.png")

    -- Defenses
    template:setHull(100)
    template:setShields(200, 200, 200, 200)

    -- Maneuverability
    --   Impulse Forward, Turn, Acceleration
    template:setSpeed(30,  3.5, 5)
    template:setJumpDrive(true)

    -- Weapons
    --   Beams            ID, Arc, Bear,  Range, Cycle, Damage
    template:setBeamWeapon(0, 100,  -20, 1500.0,   6.0, 8)
    template:setBeamWeapon(1, 100,   20, 1500.0,   6.0, 8)
    template:setBeamWeapon(2, 100,  180, 1500.0,   6.0, 8)
    --   Tubes    Count, Load Time
    template:setTubes(4, 10.0)
    --     Tube direction    ID, Bearing
    template:setTubeDirection(0, -90)
    template:setTubeDirection(1, -90)
    template:setTubeDirection(2,  90)
    template:setTubeDirection(3,  90)
    --     Tube weapon storage    Type, Count
    template:setWeaponStorage("Homing",  4)
    template:setWeaponStorage(  "HVLI", 20)

-------------------Atlantis (player ship)-------------------
variation = template:copy("Atlantis")
    variation:setLocaleName(_("Atlantis"))
    variation:setDescription(_([[A refitted Atlantis X23 for more general tasks. The large shield system has been replaced with an advanced combat maneuvering system and improved impulse engines. Its missile loadout is also more diverse. Mistaking the modified Atlantis for an Atlantis X23 would be a deadly mistake.]]))
    variation:setType("playership")

    -- Defenses
    variation:setHull(250)
    variation:setShields(200, 200)

    -- Maneuverability
    --   Impulse  Forward, Turn, Acceleration
    variation:setSpeed(90,   10, 20)
    --   Combat Maneuver      Boost, Strafe
    variation:setCombatManeuver(400, 250)

    -- Weapons
    --   Beams             ID, Arc, Bear,  Range, Cycle, Damage
    variation:setBeamWeapon(2,   0,    0,      0,     0, 0)
    --   Tubes     Count, Load Time
    variation:setTubes(5, 8.0)
    --     Tube direction     ID, Bearing
    variation:setTubeDirection(4, 180)
    --     Tube specialization         ID, Type
    variation:weaponTubeDisallowMissle( 0, "Mine")
    variation:weaponTubeDisallowMissle( 1, "Mine")
    variation:weaponTubeDisallowMissle( 2, "Mine")
    variation:weaponTubeDisallowMissle( 3, "Mine")
    variation:setWeaponTubeExclusiveFor(4, "Mine")
    --     Tube weapon storage     Type, Count
    variation:setWeaponStorage("Homing", 12)
    variation:setWeaponStorage(  "Nuke",  4)
    variation:setWeaponStorage(   "EMP",  6)
    variation:setWeaponStorage(  "Mine",  8)

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

-----------------------Starhammer II------------------------
template = ShipTemplate():setName("Starhammer II")
    template:setLocaleName(_("Starhammer II"))
    template:setClass(_("Corvette"), _("Destroyer"))
    template:setModel("battleship_destroyer_4_upgraded")
    template:setDescription(_([[Contrary to its predecessor, the Starhammer II lives up to its name. By resolving the original Starhammer's power and heat management issues, the updated model makes for a phenomenal frontal assault ship. Its low speed makes it difficult to position, but when in the right place at the right time, even the strongest shields can't withstand a Starhammer's assault for long.]]))
    template:setRadarTrace("radar_dread.png")

    -- Defenses
    template:setHull(200)
    template:setShields(450, 350, 150, 150, 350)

    -- Maneuverability
    --   Impulse Forward, Turn, Acceleration
    template:setSpeed(35, 6, 10)
    --   Long-range propulsion
    template:setJumpDrive(true)
    -- Weapons
    --   Beams            ID, Arc, Bear,  Range, Cycle, Damage
    template:setBeamWeapon(0,  60,  -10, 2000.0,   8.0, 11)
    template:setBeamWeapon(1,  60,   10, 2000.0,   8.0, 11)
    template:setBeamWeapon(2,  60,  -20, 1500.0,   8.0, 11)
    template:setBeamWeapon(3,  60,   20, 1500.0,   8.0, 11)
    --   Tubes    Count, Load Time
    template:setTubes(2, 10.0)
    --     Tube specialization        ID, Type
    template:weaponTubeDisallowMissle( 1, "EMP")
    --     Tube weapon storage    Type, Count
    template:setWeaponStorage(  "HVLI", 20)
    template:setWeaponStorage("Homing",  4)
    template:setWeaponStorage(   "EMP",  2)

--------------------------Crucible--------------------------
template = ShipTemplate():setName("Crucible")
    template:setLocaleName(_("Crucible"))
    template:setClass(_("Corvette"), _("Destroyer"))
    template:setModel("LaserCorvetteRed")
    template:setDescription(_([[The Crucible is a "popper" (vernacular for popping enemies in the face with HVLIs) that features several missile tubes positioned around its hull. Beams were deemed a lower priority, though they are still present. Its defenses are stronger than most frigates, but not as strong as the Atlantis.]]))
    template:setRadarTrace("radar_laser.png")
    template:setType("playership")

    -- Defenses
    template:setHull(160)
    template:setShields(160, 160)

    -- Maneuverability
    --   Impulse Forward, Turn, Acceleration
    template:setSpeed(80, 15, 40)
    --   Combat Maneuver     Boost, Strafe
    template:setCombatManeuver(400, 250)
    --   Long-range propulsion
    template:setJumpDrive(false)
    --     Warp speed per factor
    template:setWarpSpeed(   750)
    -- Weapons
    --   Beams            ID, Arc, Bear,  Range, Cycle, Damage
    template:setBeamWeapon(0,  70,  -30, 1000.0,   6.0, 5)
    template:setBeamWeapon(1,  70,   30, 1000.0,   6.0, 5)
    --   Tubes    Count, Load Time
    template:setTubes(6, 8.0)
    --     Tube direction    ID, Bearing
    template:setTubeDirection(0, 0)
    template:setTubeDirection(1, 0)
    template:setTubeDirection(2, 0)
    template:setTubeDirection(3, -90)
    template:setTubeDirection(4,  90)
    template:setTubeDirection(5, 180)
    --     Tube size    ID, Size (small, medium, large)
    template:setTubeSize(0, "small")
    template:setTubeSize(2, "large")
    --     Tube specialization        ID, Type
    template:setWeaponTubeExclusiveFor(0, "HVLI")
    template:setWeaponTubeExclusiveFor(1, "HVLI")
    template:setWeaponTubeExclusiveFor(2, "HVLI")
    template:weaponTubeDisallowMissle( 3, "Mine")
    template:weaponTubeDisallowMissle( 4, "Mine")
    template:setWeaponTubeExclusiveFor(5, "Mine")
    --     Tube weapon storage    Type, Count
    template:setWeaponStorage("Homing",  8)
    template:setWeaponStorage(  "Nuke",  4)
    template:setWeaponStorage(   "EMP",  6)
    template:setWeaponStorage(  "HVLI", 24)
    template:setWeaponStorage(  "Mine",  6)

    -- Internal layout
    --   Repair crew count
    template:setRepairCrewCount(4)
    --   Rooms         Position  Size
    --                     X  Y  W  H  System
    template:addRoomSystem(2, 0, 2, 1, "Maneuver");
    template:addRoomSystem(1, 1, 2, 1, "BeamWeapons");
    template:addRoomSystem(0, 2, 3, 2, "RearShield");
    template:addRoomSystem(1, 4, 2, 1, "Reactor");
    template:addRoomSystem(2, 5, 2, 1, "Warp");
    template:addRoomSystem(3, 1, 3, 2, "JumpDrive");
    template:addRoomSystem(3, 3, 3, 2, "FrontShield");
    template:addRoom(      6, 2, 6, 2);
    template:addRoomSystem(9, 1, 2, 1, "MissileSystem");
    template:addRoomSystem(9, 4, 2, 1, "Impulse");
    --   Doors    Position
    --               X  Y  Horizontal?
    template:addDoor(2, 1, true)
    template:addDoor(1, 2, true)
    template:addDoor(1, 4, true)
    template:addDoor(2, 5, true)
    template:addDoor(3, 2, false)
    template:addDoor(4, 3, true)
    template:addDoor(6, 3, false)
    template:addDoor(9, 2, true)
    template:addDoor(10,4, true)

--------------------------Maverick--------------------------
template = ShipTemplate():setName("Maverick")
    template:setLocaleName(_("Maverick"))
    template:setClass(_("Corvette"), _("Destroyer"))
    template:setModel("LaserCorvetteGreen")
    template:setDescription(_([[Mavericks are often called "gunners" for the large number of beams that bristle from its hull. Missiles were deemed a lower priority, though they are still present. Its defenses are stronger than most frigates, but not as strong as the Atlantis.]]))
    template:setRadarTrace("radar_laser.png")
    template:setType("playership")

    -- Defenses
    template:setHull(160)
    template:setShields(160, 160)

    -- Maneuverability
    --   Impulse Forward, Turn, Acceleration
    template:setSpeed(80, 15, 40)
    --   Combat Maneuver     Boost, Strafe
    template:setCombatManeuver(400, 250)
    --   Long-range propulsion
    template:setJumpDrive(false)
    --     Warp speed per factor
    template:setWarpSpeed(   800)

    -- Weapons
    --   Beams            ID, Arc, Bear,  Range, Cycle, Damage
    template:setBeamWeapon(0,  10,    0, 2000.0,   6.0, 6)
    template:setBeamWeapon(1,  90,  -20, 1500.0,   6.0, 8)
    template:setBeamWeapon(2,  90,   20, 1500.0,   6.0, 8)
    template:setBeamWeapon(3,  40,  -70, 1000.0,   4.0, 6)
    template:setBeamWeapon(4,  40,   70, 1000.0,   4.0, 6)
    template:setBeamWeapon(5,  10,  180,  800.0,   6.0, 4)
    --   Beam turrets           ID, Arc, Dir, Rotation Speed
    template:setBeamWeaponTurret(5, 180, 180, 0.5)
    --   Tubes    Count, Load Time
    template:setTubes(3, 8.0)
    --     Tube direction    ID, Bearing
    template:setTubeDirection(0, -90)
    template:setTubeDirection(1,  90)
    template:setTubeDirection(2, 180)
    --     Tube specialization        ID, Type
    template:weaponTubeDisallowMissle( 0, "Mine")
    template:weaponTubeDisallowMissle( 1, "Mine")
    template:setWeaponTubeExclusiveFor(2, "Mine")
    --     Tube weapon storage    Type, Count
    template:setWeaponStorage("Homing",  6)
    template:setWeaponStorage(  "Nuke",  2)
    template:setWeaponStorage(   "EMP",  4)
    template:setWeaponStorage(  "HVLI", 10)
    template:setWeaponStorage(  "Mine",  2)

    -- Internal layout
    --   Repair crew count
    template:setRepairCrewCount(4)
    --   Rooms         Position  Size
    --                     X  Y  W  H  System
    template:addRoomSystem(2, 0, 2, 1, "Maneuver");
    template:addRoomSystem(1, 1, 2, 1, "BeamWeapons");
    template:addRoomSystem(0, 2, 3, 2, "RearShield");
    template:addRoomSystem(1, 4, 2, 1, "Reactor");
    template:addRoomSystem(2, 5, 2, 1, "Warp");
    template:addRoomSystem(3, 1, 3, 2, "JumpDrive");
    template:addRoomSystem(3, 3, 3, 2, "FrontShield");
    template:addRoom(      6, 2, 6, 2);
    template:addRoomSystem(9, 1, 2, 1, "MissileSystem");
    template:addRoomSystem(9, 4, 2, 1, "Impulse");
    --   Doors     Position
    --                X  Y  Horizontal?
    template:addDoor( 2, 1, true)
    template:addDoor( 1, 2, true)
    template:addDoor( 1, 4, true)
    template:addDoor( 2, 5, true)
    template:addDoor( 3, 2, false)
    template:addDoor( 4, 3, true)
    template:addDoor( 6, 3, false)
    template:addDoor( 9, 2, true)
    template:addDoor(10, 4, true)

-------------------Player Missile Cruiser-------------------
template = ShipTemplate():setName("Player Missile Cr.")
	template:setLocaleName(_("Player Missile Cr."))
    template:setClass(_("Corvette"), _("Destroyer"))
	template:setModel("space_cruiser_4")
	template:setRadarTrace("radar_missile_cruiser.png")
	template:setType("playership")

    -- Defenses
	template:setHull(200)
	template:setShields(110, 70)

    -- Maneuverability
    --   Impulse Forward, Turn, Acceleration
	template:setSpeed(60,    8, 15)
    --   Combat Maneuver     Boost, Strafe
	template:setCombatManeuver(450, 150)
    --   Long-range Propulsion
    --     Warp speed per factor
	template:setWarpSpeed(   800)

	-- Weapons
    --   Tubes    Count, Load Time
	template:setTubes(7, 8.0)
    --     Tube direction    ID, Bearing
	template:setTubeDirection(0,   0)
	template:setTubeDirection(1,   0)
	template:setTubeDirection(2,  90)
	template:setTubeDirection(3,  90)
	template:setTubeDirection(4, -90)
	template:setTubeDirection(5, -90)
	template:setTubeDirection(6, 180)
    --     Tube specialization        ID, Type
	template:weaponTubeDisallowMissle( 0, "Mine")
	template:weaponTubeDisallowMissle( 1, "Mine")
	template:setWeaponTubeExclusiveFor(2, "Homing")
	template:setWeaponTubeExclusiveFor(3, "Homing")
	template:setWeaponTubeExclusiveFor(4, "Homing")
	template:setWeaponTubeExclusiveFor(5, "Homing")
	template:setWeaponTubeExclusiveFor(6, "Mine")
    --     Tube weapon storage    Type, Count
	template:setWeaponStorage("Homing", 30)
	template:setWeaponStorage("Nuke", 8)
	template:setWeaponStorage("EMP", 10)
	template:setWeaponStorage("Mine", 12)

    -- Internal layout
    --   Rooms         Position  Size
    --                     X  Y  W  H  System
	template:addRoomSystem(1, 0, 2, 1, "Maneuver");
	template:addRoomSystem(1, 1, 2, 1, "BeamWeapons");
	template:addRoom(      2, 2, 2, 1);

	template:addRoomSystem(0, 3, 1, 2, "RearShield");
	template:addRoomSystem(1, 3, 2, 2, "Reactor");
	template:addRoomSystem(3, 3, 2, 2, "Warp");
	template:addRoomSystem(5, 3, 1, 2, "JumpDrive");
	template:addRoom(      6, 3, 2, 1);
	template:addRoom(      6, 4, 2, 1);
	template:addRoomSystem(8, 3, 1, 2, "FrontShield");

	template:addRoom(      2, 5, 2, 1);
	template:addRoomSystem(1, 6, 2, 1, "MissileSystem");
	template:addRoomSystem(1, 7, 2, 1, "Impulse");
    --   Doors   Position
    --               X  Y  Horizontal?
	template:addDoor(1, 1, true);
	template:addDoor(2, 2, true);
	template:addDoor(3, 3, true);
	template:addDoor(1, 3, false);
	template:addDoor(3, 4, false);
	template:addDoor(3, 5, true);
	template:addDoor(2, 6, true);
	template:addDoor(1, 7, true);
	template:addDoor(5, 3, false);
	template:addDoor(6, 3, false);
	template:addDoor(6, 4, false);
	template:addDoor(8, 3, false);
	template:addDoor(8, 4, false);

---------------------------SUPPORT--------------------------

----------------------Weapons platform----------------------
template = ShipTemplate():setName("Weapons platform")
    template:setLocaleName(_("Weapons platform"))
    template:setClass(_("Corvette"), _("subclass", "Support"))
    template:setModel("space_cruiser_4")
    template:setDescription(_([[Stationary weapons platforms are armed with powerful beam weapons and can slowly rotate.]]))
    template:setRadarTrace("radar_missile_cruiser.png")

    -- Defenses
    template:setHull(70)
    template:setShields(120, 120, 120, 120, 120, 120)

    -- Maneuverability
    --   Impulse Forward, Turn, Acceleration
    template:setSpeed( 0,  0.5, 0)

    -- Weapons
    --   Beams            ID, Arc, Bear,  Range, Cycle, Damage
    template:setBeamWeapon(0,  30,    0, 4000.0,   1.5, 20)
    template:setBeamWeapon(1,  30,   60, 4000.0,   1.5, 20)
    template:setBeamWeapon(2,  30,  120, 4000.0,   1.5, 20)
    template:setBeamWeapon(3,  30,  180, 4000.0,   1.5, 20)
    template:setBeamWeapon(4,  30,  240, 4000.0,   1.5, 20)
    template:setBeamWeapon(5,  30,  300, 4000.0,   1.5, 20)

----------------------Defense platform----------------------
variation = template:copy("Defense platform")
    variation:setLocaleName(_("Defense platform"))
    variation:setModel("space_station_4")
    variation:setDescription(_([[Stationary defense platforms operate like space stations, with docking and resupply functions, but are armed with powerful beam weapons and can slowly rotate. Larger systems often use these platforms to resupply patrol ships.]]))
    variation:setRadarTrace("radartrace_smallstation.png")

    -- Capabilities
    variation:setDockClasses("Starfighter", "Frigate")

    -- Defenses
    variation:setHull(150)

----------------------Jump carriers----------------------
template = ShipTemplate():setName("Jump Carrier")
    template:setLocaleName(_("Jump Carrier"))
    template:setClass(_("Corvette"), _("Support"))
    template:setModel("transport_4_2")
    template:setDescription(_([[Jump carriers can ferry other ships deep into space via its specialized jump drive capable of jumps up to 100 times farther than typical jump drives, and its vast energy storage. It also has special docking parameters that allow other ships to attach themselves to its hull.]]))
    template:setRadarTrace("radar_transport.png")

    -- Capabilities
    template:setDockClasses("Starfighter", "Frigate", "Corvette")

    -- Defenses
    template:setHull(100)
    template:setShields(50, 50)

    -- Maneuverability
    --   Impulse Forward, Turn, Acceleration
    template:setSpeed(50,    6, 10)
    --   Long-range propulsion
    template:setJumpDrive(true)
    --     Jump range       Minimum, Maximum
    template:setJumpDriveRange(5000, 5000000)

--------------------------Benedict--------------------------
variation = template:copy("Benedict")
    variation:setLocaleName(_("Benedict"))
    variation:setClass(_("Corvette"), _("Support"))
    variation:setDescription(_([[The Benedict is a combat jump carrier with stronger defenses and limited weaponry, but these capabilities cost it the standard jump carrier's tremendous jump range.]]))
    variation:setType("playership")

    -- Defenses
    variation:setHull(200)
    variation:setShields(70, 70)

    -- Maneuverability
    --   Impulse  Forward, Turn, Acceleration
    variation:setSpeed(60,    6, 8)
    --   Combat Maneuver      Boost, Strafe
    variation:setCombatManeuver(400, 250)
    variation:setJumpDriveRange(5000, 90000)

    -- Weapons
    --   Beams             ID, Arc, Bear,  Range, Cycle, Damage
    variation:setBeamWeapon(0,  10,    0, 1500.0,   6.0, 4)
    variation:setBeamWeapon(1,  10,  180, 1500.0,   6.0, 4)
    --   Beam turrets            ID, Arc, Dir, Rotation Speed
    variation:setBeamWeaponTurret( 0, 90,   0, 6)
    variation:setBeamWeaponTurret( 1, 90, 180, 6)

    -- Internal layout
    --   Repair crew count
    variation:setRepairCrewCount(6)
    --   Rooms          Position  Size
    --                      X  Y  W  H  System
    variation:addRoomSystem(3, 0, 2, 3, "Reactor")
    variation:addRoomSystem(3, 3, 2, 3, "Warp")
    variation:addRoomSystem(6, 0, 2, 3, "JumpDrive")
    variation:addRoomSystem(6, 3, 2, 3, "MissileSystem")
    variation:addRoomSystem(5, 2, 1, 2, "Maneuver")
    variation:addRoomSystem(2, 2, 1, 2, "RearShield")
    variation:addRoomSystem(0, 1, 2, 4, "Beamweapons")
    variation:addRoomSystem(8, 2, 1, 2, "FrontShield")
    variation:addRoomSystem(9, 1, 2, 4, "Impulse")

    --   Doors    Position
    --                X  Y  Horizontal?
    variation:addDoor(3, 3, true)
    variation:addDoor(6, 3, true)
    variation:addDoor(5, 2, false)
    variation:addDoor(6, 3, false)
    variation:addDoor(3, 2, false)
    variation:addDoor(2, 3, false)
    variation:addDoor(8, 2, false)
    variation:addDoor(9, 3, false)

---------------------------Kiriya---------------------------
variation2 = variation:copy("Kiriya")
    variation2:setLocaleName(_("Kiriya"))
    variation2:setDescription(_([[The Kiriya is a Benedict combat jump carrier refitted with a warp drive.]]))

    -- Maneuverability
    --   Long-range Propulsion
    variation2:setJumpDrive(false)
    --     Warp speed per factor
    variation2:setWarpSpeed(750)

-------------------------FREIGHTERS-------------------------

for cnt=1,5 do
    ------------------Personnel freighters------------------
    template = ShipTemplate():setName("Personnel Freighter " .. cnt)
        template:setLocaleName(string.format(_("Personnel Freighter %d"), cnt))
        template:setClass(_("Corvette"), _("Freighter"))
        template:setModel("transport_1_" .. cnt)
        template:setDescription(_([[Personnel freighters are designed to transport armed troops, military support personnel, and combat gear.]]))
        template:setRadarTrace("radar_transport.png")

        -- Defenses
        template:setHull(100)
        template:setShields(50, 50)

        -- Maneuverability
        --   Impulse           Forward, Turn, Acceleration
        template:setSpeed(60 - 5 * cnt,    6, 10)

    if cnt > 2 then
        variation = template:copy("Personnel Jump Freighter " .. cnt)
            variation:setLocaleName(string.format(_("Personnel Jump Freighter %d"), cnt))
            --   Long-range propulsion
            variation:setJumpDrive(true)
    end

    --------------------Goods freighters--------------------
    template = ShipTemplate():setName("Goods Freighter " .. cnt)
        template:setLocaleName(string.format(_("Goods Freighter %d"), cnt))
        template:setClass(_("Corvette"), _("Freighter"))
        template:setModel("transport_2_" .. cnt)
        template:setDescription(_([[Cargo freighters haul large loads of cargo across long distances. Their cargo bays include climate control and stabilization systems that keep the cargo in good condition.]]))
        template:setRadarTrace("radar_transport.png")

        -- Defenses
        template:setHull(100)
        template:setShields(50, 50)

        -- Maneuverability
        --   Impulse           Forward, Turn, Acceleration
        template:setSpeed(60 - 5 * cnt,    6, 10)

    if cnt > 2 then
        variation = template:copy("Goods Jump Freighter " .. cnt)
            variation:setLocaleName(string.format(_("Goods Jump Freighter %d"), cnt))
            --   Long-range propulsion
            variation:setJumpDrive(true)
    end

    -------------------Garbage freighters-------------------
    template = ShipTemplate():setName("Garbage Freighter " .. cnt)
        template:setLocaleName(string.format(_("Garbage Freighter %d"), cnt))
        template:setClass(_("Corvette"), _("Freighter"))
        template:setModel("transport_3_" .. cnt)
        template:setDescription(_([[Garbage freighters are specially designed to haul waste. They are fitted with a trash compactor and fewer stabilzation systems than cargo freighters.]]))
        template:setRadarTrace("radar_transport.png")

        -- Defenses
        template:setHull(100)
        template:setShields(50, 50)

        -- Maneuverability
        --   Impulse Forward, Turn, Acceleration
        template:setSpeed(60 - 5 * cnt, 6, 10)

    if cnt > 2 then
        variation = template:copy("Garbage Jump Freighter " .. cnt)
            variation:setLocaleName(string.format(_("Garbage Jump Freighter %d"), cnt))
            --   Long-range propulsion
            variation:setJumpDrive(true)
    end

    ------------------Equipment freighters------------------
    template = ShipTemplate():setName("Equipment Freighter " .. cnt)
        template:setLocaleName(string.format(_("Equipment Freighter %d"), cnt))
        template:setClass(_("Corvette"), _("Freighter"))
        template:setModel("transport_4_" .. cnt)
        template:setDescription(_([[Equipment freighters have specialized environmental and stabilization systems to safely carry delicate machinery and complex instruments.]]))
        template:setRadarTrace("radar_transport.png")

        -- Defenses
        template:setHull(100)
        template:setShields(50, 50)

        -- Maneuverability
        --   Impulse Forward, Turn, Acceleration
        template:setSpeed(60 - 5 * cnt, 6, 10)

    if cnt > 2 then
        variation = template:copy("Equipment Jump Freighter " .. cnt)
            variation:setLocaleName(string.format(_("Equipment Jump Freighter %d"), cnt))
            --   Long-range propulsion
            variation:setJumpDrive(true)
    end

    --------------------Fuel freighters---------------------
    template = ShipTemplate():setName("Fuel Freighter " .. cnt)
        template:setLocaleName(string.format(_("Fuel Freighter %d"), cnt))
        template:setClass(_("Corvette"), _("Freighter"))
        template:setModel("transport_5_" .. cnt)
        template:setDescription(_([[Fuel freighters have massive tanks for hauling fuel, and delicate internal sensors that watch for any changes to their cargo's potentially volatile state.]]))
        template:setRadarTrace("radar_transport.png")

        -- Defenses
        template:setHull(100)
        template:setShields(50, 50)

        -- Maneuverability
        --   Impulse Forward, Turn, Acceleration
        template:setSpeed(60 - 5 * cnt, 6, 10)

    if cnt > 2 then
        variation = template:copy("Fuel Jump Freighter " .. cnt)
            variation:setLocaleName(string.format(_("Fuel Jump Freighter %d"), cnt))
            --   Long-range propulsion
            variation:setJumpDrive(true)
    end
end
