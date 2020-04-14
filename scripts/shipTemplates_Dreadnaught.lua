--[[                  Dreadnought
Dreadnoughts are the largest ships.
They are so large and uncommon that every type is pretty much their own subclass.
They usually come with 6 or more shield sections, require a crew of 250+ to operate.

Think: Stardestroyer.
----------------------------------------------------------]]

template = ShipTemplate():setName("Odin"):setLocaleName(_("Odin")):setClass(_("class", "Dreadnought"), _("subclass","Odin")):setModel("space_station_2")
template:setRadarTrace("radartrace_largestation.png")
template:setDescription(_([[The Odin is a "ship" so large and unique that it's almost a class of its own.

The ship is often nicknamed the "all-father", a name that aptly describes the many roles this ship can fulfill. It's both a supply station and an extremely heavily armored and shielded weapon station capable of annihilating small fleets on its own.

Odin's core contains the largest jump drive ever created. About 150 support crew are needed to operate the jump drive alone, and it takes 5 days of continuous operation to power it.

Due to the enormous cost of this Dreadnought, only the richest star systems are able to build and maintain ships like the Odin.

This machine's primary tactic is to jump into an unsuspecting enemy system and destroy everything before they know what hit them. It's effective and destructive, but extremely expensive.]]))
template:setJumpDrive(true)
template:setTubes(16, 3.0)
template:setWeaponStorage("Homing", 1000)
for n=0,15 do
    template:setBeamWeapon(n, 90,  n * 22.5, 3200, 3, 10)
    template:setTubeDirection(n, n * 22.5)
    template:setTubeSize(0, "large")
end
template:setHull(2000)
template:setShields(1200, 1200, 1200, 1200, 1200, 1200)
template:setSpeed(0, 1, 0)

-- The battle station is a huge ship with many defensive features. It can be docked by smaller ships.
template = ShipTemplate():setName("Battlestation"):setLocaleName(_("Battlestation")):setModel("Ender Battlecruiser"):setClass(_("class", "Dreadnought"),_("Battlecruiser"))
template:setRadarTrace("radar_battleship.png")
template:setDescription(_("The battle station is a huge ship with many defensive features. It can be docked by smaller ships."))
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 120, -90, 2500.0, 6.1, 4)
template:setBeam(1, 120, -90, 2500.0, 6.0, 4)
template:setBeam(2, 120,  90, 2500.0, 6.1, 4)
template:setBeam(3, 120,  90, 2500.0, 6.0, 4)
template:setBeam(4, 120, -90, 2500.0, 5.9, 4)
template:setBeam(5, 120, -90, 2500.0, 6.2, 4)
template:setBeam(6, 120,  90, 2500.0, 5.9, 4)
template:setBeam(7, 120,  90, 2500.0, 6.2, 4)
template:setBeam(8, 120, -90, 2500.0, 6.1, 4)
template:setBeam(9, 120, -90, 2500.0, 6.0, 4)
template:setBeam(10, 120,  90, 2500.0, 6.1, 4)
template:setBeam(11, 120,  90, 2500.0, 6.0, 4)
template:setHull(100)
template:setShields(2500)
template:setSpeed(20, 1.5, 3)
template:setJumpDrive(true)
template:setDockClasses("Starfighter", "Frigate", "Corvette")
template:setSharesEnergyWithDocked(true)

variation = template:copy("Ender"):setType("playership")
--                  Arc, Dir, Range, CycleTime, Dmg
variation:setBeam(0, 10, -90, 2500.0, 6.1, 4)
variation:setBeam(1, 10, -90, 2500.0, 6.0, 4)
variation:setBeam(2, 10,  90, 2500.0, 5.8, 4)
variation:setBeam(3, 10,  90, 2500.0, 6.3, 4)
variation:setBeam(4, 10, -90, 2500.0, 5.9, 4)
variation:setBeam(5, 10, -90, 2500.0, 6.4, 4)
variation:setBeam(6, 10,  90, 2500.0, 5.7, 4)
variation:setBeam(7, 10,  90, 2500.0, 5.6, 4)
variation:setBeam(8, 10, -90, 2500.0, 6.6, 4)
variation:setBeam(9, 10, -90, 2500.0, 5.5, 4)
variation:setBeam(10, 10,  90, 2500.0, 6.5, 4)
variation:setBeam(11, 10,  90, 2500.0, 6.2, 4)
--								  Arc, Dir, Rotate speed
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
variation:setEnergyStorage(1200)
variation:setTubes(2, 8.0) -- Amount of torpedo tubes, loading time
variation:setWeaponStorage("Homing", 6)
variation:setWeaponStorage("Mine", 6)
variation:setTubeDirection(0, 0):setWeaponTubeExclusiveFor(0, "Homing")
variation:setTubeDirection(1, 180):setWeaponTubeExclusiveFor(1, "Mine")
variation:setShields(1200, 1200)
variation:setSpeed(30, 2, 6)
variation:setCombatManeuver(800, 500)

variation:setRepairCrewCount(8)

variation:addRoomSystem(0,1,2,4,"RearShield")
variation:addRoom(3,0,2,1)
variation:addRoomSystem(7,0,2,1,"Maneuver")
variation:addRoomSystem(11,0,2,1,"MissileSystem")
variation:addRoomSystem(2,1,4,2,"Reactor")
variation:addRoomSystem(6,1,4,2,"Warp")
variation:addRoom(10,1,4,2)
variation:addRoomSystem(14,2,2,2,"FrontShield")
variation:addRoomSystem(2,3,4,2,"Impulse")
variation:addRoomSystem(6,3,4,2,"JumpDrive")
variation:addRoom(10,3,4,2)
variation:addRoom(3,5,2,1)
variation:addRoom(7,5,2,1)
variation:addRoomSystem(11,5,2,1,"Beamweapons")

variation:addDoor(3,1,true)
variation:addDoor(7,1,true)
variation:addDoor(11,1,true)
variation:addDoor(2,2,false)
variation:addDoor(6,1,false)
variation:addDoor(10,2,false)
variation:addDoor(14,3,false)
variation:addDoor(10,4,false)
variation:addDoor(6,3,false)
variation:addDoor(8,3,true)
variation:addDoor(4,5,true)
variation:addDoor(8,5,true)
variation:addDoor(12,5,true)
