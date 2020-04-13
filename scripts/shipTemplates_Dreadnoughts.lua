--[[--------------------DREADNOUGHTS------------------------
Dreadnoughts are the largest ships. They are so large and
uncommon that every type is pretty much their own subclass.
They usually have at least 6 shield sections and require a
crew of more than 250 to operate.
----------------------------------------------------------]]

----------------------------Odin----------------------------
template = ShipTemplate():setName("Odin")
    template:setLocaleName(_("Odin"))
    template:setClass(_("class", "Dreadnought"), _("subclass", "Odin"))template:setModel("space_station_2")
    template:setDescription(_([[The Odin is a "ship" so large and unique that it's almost a class of its own.

The ship is often nicknamed the "all-father", a name that aptly describes the many roles this ship can fulfill. It's both a supply station and an extremely heavily armored and shielded weapon station capable of annihilating small fleets on its own.

Odin's core contains the largest jump drive ever created. About 150 support crew are needed to operate the jump drive alone, and it takes 5 days of continuous operation to power it.

Due to the enormous cost of this Dreadnought, only the richest star systems are able to build and maintain ships like the Odin.

This machine's primary tactic is to jump into an unsuspecting enemy system and destroy everything before they know what hit them. It's effective and destructive, but extremely expensive.]]))
    template:setRadarTrace("radartrace_largestation.png")

    -- Defenses
    template:setHull(2000)
    template:setShields(1200, 1200, 1200, 1200, 1200, 1200)

    -- Maneuverability
    --   Impulse Forward, Turn, Acceleration
    template:setSpeed(0, 1, 0)
    --   Long-range Propulsion
    template:setJumpDrive(true)

    -- Weapons
    --   Tubes     Count, Load Time
    template:setTubes(16, 3.0)
    for n=0,15 do
        --   Beams            ID, Arc,  Bearing,  Range, Cycle, Damage
        template:setBeamWeapon(n,  90, n * 22.5, 3200.0,   3.0, 10)
        --     Tube direction    ID, Bearing
        template:setTubeDirection(n, n * 22.5)
        --     Tube size    ID, Size (small, medium, large)
        template:setTubeSize(0, "large")
    end
    --     Tube weapon storage    Type, Count
    template:setWeaponStorage("Homing", 1000)

------------------------Dreadnought-------------------------
template = ShipTemplate():setName("Dreadnought")
    template:setLocaleName(_("ship", "Dreadnought"))
    template:setClass(_("class", "Dreadnought"), _("subclass", "Assault"))
    template:setModel("battleship_destroyer_1_upgraded")
    template:setDescription(_([[The Dreadnought is a flying fortress. It's slow, but packs many strong beam weapons in the front. Taking it head-on is suicide.]]))
    template:setRadarTrace("radar_dread.png")

    -- Defenses
    template:setHull(70)
    template:setShields(300, 300, 300, 300, 300)
    -- Maneuverability
    --   Impulse Forward, Turn, Acceleration
    template:setSpeed(30,  1.5, 5)

    -- Weapons
    --   Beams            ID, Arc, Bear,  Range, Cycle, Damage
    template:setBeamWeapon(0,  90,  -25, 1500.0,   6.0, 8)
    template:setBeamWeapon(1,  90,   25, 1500.0,   6.0, 8)
    template:setBeamWeapon(2, 100,  -60, 1000.0,   6.0, 8)
    template:setBeamWeapon(3, 100,   60, 1000.0,   6.0, 8)
    template:setBeamWeapon(4,  30,    0, 2000.0,   6.0, 8)
    template:setBeamWeapon(5, 100,  180, 1200.0,   6.0, 8)

-----------------------Battlestation------------------------
template = ShipTemplate():setName("Battlestation")
    template:setLocaleName(_("Battlestation"))
    template:setModel("Ender Battlecruiser")
    template:setClass(_("class", "Dreadnought"), _("Battlecruiser"))
    template:setDescription(_([[The battlestation is a huge ship with many defensive features. It can be docked by smaller ships.]]))
    template:setRadarTrace("radar_battleship.png")

    -- Capabilities
    template:setDockClasses("Starfighter", "Frigate", "Corvette")
    template:setSharesEnergyWithDocked(true)

    -- Defenses
    template:setHull(100)
    template:setShields(2500)

    -- Maneuverability
    --   Impulse Forward, Turn, Acceleration
    template:setSpeed(20,  1.5, 3)
    template:setJumpDrive(true)

    -- Weapons
    --   Beams             ID, Arc, Bear,  Range, Cycle, Damage
    template:setBeamWeapon( 0, 120,  -90, 2500.0,   6.0, 4)
    template:setBeamWeapon( 1, 120,  -90, 2500.0,   6.0, 4)
    template:setBeamWeapon( 2, 120,   90, 2500.0,   6.0, 4)
    template:setBeamWeapon( 3, 120,   90, 2500.0,   6.0, 4)
    template:setBeamWeapon( 4, 120,  -90, 2500.0,   6.0, 4)
    template:setBeamWeapon( 5, 120,  -90, 2500.0,   6.0, 4)
    template:setBeamWeapon( 6, 120,   90, 2500.0,   6.0, 4)
    template:setBeamWeapon( 7, 120,   90, 2500.0,   6.0, 4)
    template:setBeamWeapon( 8, 120,  -90, 2500.0,   6.0, 4)
    template:setBeamWeapon( 9, 120,  -90, 2500.0,   6.0, 4)
    template:setBeamWeapon(10, 120,   90, 2500.0,   6.0, 4)
    template:setBeamWeapon(11, 120,   90, 2500.0,   6.0, 4)

--------------------Ender (player ship)---------------------
variation = template:copy("Ender")
    variation:setType("playership")

    -- Capabilities
    variation:setEnergyStorage(1200)

    -- Defenses
    variation:setShields(1200, 1200)

    -- Maneuverability
    --   Impulse  Forward, Turn, Acceleration
    variation:setSpeed(30,    2, 6)
    --   Combat Maneuver      Boost, Strafe
    variation:setCombatManeuver(800, 500)

    -- Weapons
    --   Beams              ID, Arc, Bear,  Range, Cycle, Damage
    variation:setBeamWeapon( 0,  10,  -90, 2500.0,   6.0, 4)
    variation:setBeamWeapon( 1,  10,  -90, 2500.0,   6.0, 4)
    variation:setBeamWeapon( 2,  10,   90, 2500.0,   6.0, 4)
    variation:setBeamWeapon( 3,  10,   90, 2500.0,   6.0, 4)
    variation:setBeamWeapon( 4,  10,  -90, 2500.0,   6.0, 4)
    variation:setBeamWeapon( 5,  10,  -90, 2500.0,   6.0, 4)
    variation:setBeamWeapon( 6,  10,   90, 2500.0,   6.0, 4)
    variation:setBeamWeapon( 7,  10,   90, 2500.0,   6.0, 4)
    variation:setBeamWeapon( 8,  10,  -90, 2500.0,   6.0, 4)
    variation:setBeamWeapon( 9,  10,  -90, 2500.0,   6.0, 4)
    variation:setBeamWeapon(10,  10,   90, 2500.0,   6.0, 4)
    variation:setBeamWeapon(11,  10,   90, 2500.0,   6.0, 4)
    --     Beam turrets           ID, Arc, Dir, Rotation Speed
    variation:setBeamWeaponTurret( 0, 120, -90, 6)
    variation:setBeamWeaponTurret( 1, 120, -90, 6)
    variation:setBeamWeaponTurret( 2, 120,  90, 6)
    variation:setBeamWeaponTurret( 3, 120,  90, 6)
    variation:setBeamWeaponTurret( 4, 120, -90, 6)
    variation:setBeamWeaponTurret( 5, 120, -90, 6)
    variation:setBeamWeaponTurret( 6, 120,  90, 6)
    variation:setBeamWeaponTurret( 7, 120,  90, 6)
    variation:setBeamWeaponTurret( 8, 120, -90, 6)
    variation:setBeamWeaponTurret( 9, 120, -90, 6)
    variation:setBeamWeaponTurret(10, 120,  90, 6)
    variation:setBeamWeaponTurret(11, 120,  90, 6)
    --   Tubes     Count, Load Time
    variation:setTubes(2, 8.0)
    --     Tube direction     ID, Bearing
    variation:setTubeDirection(0, 0)
    variation:setTubeDirection(1, 180)
    --     Tube specialization         ID, Type
    variation:setWeaponTubeExclusiveFor(0, "Homing")
    variation:setWeaponTubeExclusiveFor(1, "Mine")
    --     Tube weapon storage     Type, Count
    variation:setWeaponStorage("Homing", 6)
    variation:setWeaponStorage(  "Mine", 6)

    -- Internal layout
    --   Repair crew count
    variation:setRepairCrewCount(8)
    --   Rooms           Position  Size
    --                       X  Y  W  H  System
    variation:addRoomSystem( 0, 1, 2, 4, "RearShield")
    variation:addRoom(       3, 0, 2, 1)
    variation:addRoomSystem( 7, 0, 2, 1, "Maneuver")
    variation:addRoomSystem(11, 0, 2, 1, "MissileSystem")
    variation:addRoomSystem( 2, 1, 4, 2, "Reactor")
    variation:addRoomSystem( 6, 1, 4, 2, "Warp")
    variation:addRoom(      10, 1, 4, 2)
    variation:addRoomSystem(14, 2, 2, 2, "FrontShield")
    variation:addRoomSystem( 2, 3, 4, 2, "Impulse")
    variation:addRoomSystem( 6, 3, 4, 2, "JumpDrive")
    variation:addRoom(      10, 3, 4, 2)
    variation:addRoom(       3, 5, 2, 1)
    variation:addRoom(       7, 5, 2, 1)
    variation:addRoomSystem(11, 5, 2, 1, "BeamWeapons")
    --   Doors     Position
    --                 X  Y  Horizontal?
    variation:addDoor( 3, 1, true)
    variation:addDoor( 7, 1, true)
    variation:addDoor(11, 1, true)
    variation:addDoor( 2, 2, false)
    variation:addDoor( 6, 1, false)
    variation:addDoor(10, 2, false)
    variation:addDoor(14, 3, false)
    variation:addDoor(10, 4, false)
    variation:addDoor( 6, 3, false)
    variation:addDoor( 8, 3, true)
    variation:addDoor( 4, 5, true)
    variation:addDoor( 8, 5, true)
    variation:addDoor(12, 5, true)