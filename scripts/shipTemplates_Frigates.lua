require("options.lua")
require(lang .. "/ships.lua")

--[[                  Frigates
Frigates are 1 size up from starfighters. They require a crew from 3 to 20 people.
Think, Firefly, millennium falcon, slave I (Boba fett's ship).

They generally have 2 or more shield sections, but hardly ever more than 4.

This class of ships is normally not fitted with jump or warp drives. But in some cases ships are modified to include these, or for certain roles it is build in.

They are divided in 3 different sub-classes:
* Cruiser: Weaponized frigates, focused on combat. These come in various roles.
* Light transport: Small transports, like transporting up to 50 soldiers in spartan conditions or a few diplomats in luxury. Depending on the role can have some weaponry.
* Support: Support types come in many variaties. They are simply a frigate hull fitted with whatever was needed. Anything from mine-layers to science vessels.
----------------------------------------------------------]]
template = ShipTemplate():setName(phobosT3):setClass(frigate, cruiser):setModel("AtlasHeavyFighterYellow")
template:setRadarTrace("radar_cruiser.png")
template:setDescription(phobosT3Description)
template:setHull(70)
template:setShields(50, 40)
template:setSpeed(60, 10, 10)
template:setBeamWeapon(0, 90, -15, 1200, 8, 6)
template:setBeamWeapon(1, 90,  15, 1200, 8, 6)
template:setTubes(2, 60.0)
template:setWeaponStorage(hvli, 20)
template:setWeaponStorage(homing, 6)
template:setTubeDirection(0, -1)
template:setTubeDirection(1,  1)

variation = template:copy(phobosM3):setModel("AtlasHeavyFighterRed")
variation:setDescription(phobosM3Description)
variation:setTubes(3, 60.0)
variation:setWeaponStorage(mine, 6)
variation:setSpeed(55, 10, 10)
variation:weaponTubeDisallowMissle(0, mine):weaponTubeDisallowMissle(1, mine)
variation:setTubeDirection(2,  180):setWeaponTubeExclusiveFor(2, mine)

variation = variation:copy(phobosM3P):setType("playership")
variation:setDescription(phobosM3PDescription)
variation:setShields(100, 100)
variation:setHull(200)
variation:setSpeed(80, 10, 20)
variation:setCombatManeuver(400, 250)
variation:setTubes(3, 10.0)
variation:setWeaponStorage(homing, 10)
variation:setWeaponStorage(nuke, 2)
variation:setWeaponStorage(mine, 4)
variation:setWeaponStorage(emp, 3)

variation:addRoomSystem(1, 0, 2, 1, maneuver);
variation:addRoomSystem(1, 1, 2, 1, beamWeapons);
variation:addRoom(2, 2, 2, 1);

variation:addRoomSystem(0, 3, 1, 2, rearShield);
variation:addRoomSystem(1, 3, 2, 2, reactor);
variation:addRoomSystem(3, 3, 2, 2, warp);
variation:addRoomSystem(5, 3, 1, 2, jumpDrive);
variation:addRoom(6, 3, 2, 1);
variation:addRoom(6, 4, 2, 1);
variation:addRoomSystem(8, 3, 1, 2, frontShield);

variation:addRoom(2, 5, 2, 1);
variation:addRoomSystem(1, 6, 2, 1, missileSystem);
variation:addRoomSystem(1, 7, 2, 1, impulse);

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
 
--Airlock doors
--variation:addDoor(2, 2, false);
--variation:addDoor(2, 5, false);

template = ShipTemplate():setName(nirvanaR5):setClass(frigate, cruiser .. " : " .. antiFighter):setModel("small_frigate_5") -- TODO: Better 3D model selection
template:setRadarTrace("radar_cruiser.png")
template:setDescription(nirvanaR5Description)
template:setBeamWeapon(0, 90, -15, 1200, 3, 1)
template:setBeamWeapon(1, 90,  15, 1200, 3, 1)
template:setBeamWeapon(2, 90,  50, 1200, 3, 1)
template:setBeamWeapon(3, 90, -50, 1200, 3, 1)
template:setHull(70)
template:setShields(50, 40)
template:setSpeed(70, 12, 10)

variation = template:copy(nirvanaR5A)
variation:setDescription(nirvanaR5ADescription)
variation:setBeamWeapon(0, 90, -15, 1200, 2.9, 1)
variation:setBeamWeapon(1, 90,  15, 1200, 2.9, 1)
variation:setBeamWeapon(2, 90,  50, 1200, 2.9, 1)
variation:setBeamWeapon(3, 90, -50, 1200, 2.9, 1)
variation:setSpeed(70, 15, 10)

template = ShipTemplate():setName(storm):setClass(frigate, cruiser .. " : " .. heavyArtillery):setModel("HeavyCorvetteYellow")	--Yellow, Green, Blue, White, Red
template:setRadarTrace("radar_piranha.png")
template:setDescription(stormDescription)
template:setBeamWeapon(0, 60, 0, 1200, 3, 2)
template:setHull(50)
template:setShields(30, 30)
template:setSpeed(40, 6, 8)
template:setTubes(5, 15.0)
template:setWeaponStorage(hvli, 15)
template:setWeaponStorage(homing, 15)
template:setTubeDirection(0,  0)
template:setTubeDirection(1, -1)
template:setTubeDirection(2,  1)
template:setTubeDirection(3, -2)
template:setTubeDirection(4,  2)
template:setDefaultAI('missilevolley')

template = ShipTemplate():setName(hathcock):setClass(frigate, cruiser .. " : " .. heavyArtillery):setModel("HeavyCorvetteGreen"):setType("playership")
template:setRadarTrace("radar_piranha.png")
template:setDescription(hathcockDescription)
--						Arc, Dir, Range, CycleTime, Dmg
template:setBeamWeapon(0, 4,   0, 1400.0, 6.0, 4)
template:setBeamWeapon(1,20,   0, 1200.0, 6.0, 4)
template:setBeamWeapon(2,60,   0, 1000.0, 6.0, 4)
template:setBeamWeapon(3,90,   0,  800.0, 6.0, 4)
template:setHull(120)
template:setShields(70, 70)
template:setSpeed(50, 15, 8)
template:setTubes(2, 15.0)
template:setCombatManeuver(200, 150)
template:setJumpDrive(true)
template:setWeaponStorage(hvli, 8)
template:setWeaponStorage(homing, 4)
template:setWeaponStorage(emp, 2)
template:setWeaponStorage(nuke, 1)
template:setTubeDirection(0, -90)
template:setTubeDirection(1,  90)

template:setRepairCrewCount(2)
--	(H)oriz, (V)ert	   HC,VC,HS,VS, system    (C)oordinate (S)ize
template:addRoomSystem( 0, 0, 1, 4, reactor)
template:addRoomSystem( 1, 0, 1, 1, jumpDrive)
template:addRoomSystem( 1, 3, 1, 1, warp)
template:addRoomSystem( 2, 0, 1, 1, frontShield)
template:addRoomSystem( 2, 3, 1, 1, rearShield)
template:addRoomSystem( 3, 0, 1, 1, missileSystem)
template:addRoomSystem( 3, 3, 1, 1, impulse)
template:addRoomSystem( 3, 1, 2, 1, maneuver)
template:addRoom( 3, 2, 2, 1)
template:addRoomSystem( 5, 1, 2, 2, beamWeapons)

--(H)oriz, (V)ert H, V, true = horizontal
template:addDoor( 1, 0, false)
template:addDoor( 1, 3, false)
template:addDoor( 2, 0, false)
template:addDoor( 2, 3, false)
template:addDoor( 3, 0, false)
template:addDoor( 3, 3, false)
template:addDoor( 3, 3, true)
template:addDoor( 3, 2, true)
template:addDoor( 5, 1, false)


template = ShipTemplate():setName(piranhaF12):setClass(frigate, cruiser .. " : " .. lightArtillery):setModel("HeavyCorvetteRed")
template:setRadarTrace("radar_piranha.png")
template:setDescription(piranhaF12Description)
template:setHull(70)
template:setShields(30, 30)
template:setSpeed(40, 6, 8)
template:setTubes(6, 15.0)
template:setWeaponStorage(hvli, 20)
template:setWeaponStorage(homing, 6)
template:setTubeDirection(0, -90):setWeaponTubeExclusiveFor(0, hvli)
template:setTubeDirection(1, -90)
template:setTubeDirection(2, -90):setWeaponTubeExclusiveFor(2, hvli)
template:setTubeDirection(3,  90):setWeaponTubeExclusiveFor(3, hvli)
template:setTubeDirection(4,  90)
template:setTubeDirection(5,  90):setWeaponTubeExclusiveFor(5, hvli)

template:setTubeSize(0, "large")
template:setTubeSize(2, "large")
template:setTubeSize(3, "large")
template:setTubeSize(5, "large")


variation = template:copy(piranhaF12M)
variation:setDescription(piranhaF12MDescription)
variation:setWeaponStorage(hvli, 10)
variation:setWeaponStorage(homing, 4)
variation:setWeaponStorage(nuke, 2)

variation = template:copy(piranhaF8)
variation:setDescription(piranhaF8Description)
variation:setTubes(3, 12.0)
variation:setWeaponStorage(hvli, 10)
variation:setWeaponStorage(homing, 5)
variation:setTubeDirection(0,   0):setWeaponTubeExclusiveFor(0, hvli)
variation:setTubeDirection(1, -90)
variation:setTubeDirection(2,  90)

variation = template:copy(piranha):setType("playership")
variation:setDescription(piranhaDescription)
variation:setHull(120)
variation:setShields(70, 70)
variation:setSpeed(60, 10, 8)
variation:setTubes(8, 8.0)
variation:setCombatManeuver(200, 150)
variation:setJumpDrive(true)
variation:setWeaponStorage(hvli, 20)
variation:setWeaponStorage(homing, 12)
variation:setWeaponStorage(nuke, 6)
variation:setWeaponStorage(mine, 8)
variation:weaponTubeAllowMissle(0, homing):weaponTubeAllowMissle(2, homing)
variation:weaponTubeAllowMissle(3, homing):weaponTubeAllowMissle(5, homing)
variation:setTubeDirection(6, 170):setWeaponTubeExclusiveFor(6, mine)
variation:setTubeDirection(7, 190):setWeaponTubeExclusiveFor(7, mine)

variation:setRepairCrewCount(2)
variation:addRoomSystem(0, 0, 1, 4, rearShield)
variation:addRoom(1, 0, 1, 1)
variation:addRoomSystem(1, 1, 3, 2, missileSystem)
variation:addRoom(1, 3, 1, 1)

variation:addRoomSystem(2, 0, 2, 1, beamWeapons)
variation:addRoomSystem(2, 3, 2, 1, maneuver)

variation:addRoomSystem(4, 0, 2, 1, warp)
variation:addRoomSystem(4, 3, 2, 1, jumpDrive)
variation:addRoomSystem(5, 1, 1, 2, reactor)

variation:addRoom(6, 0, 1, 1)
variation:addRoomSystem(6, 1, 1, 2, impulse)
variation:addRoom(6, 3, 1, 1)

variation:addRoomSystem(7, 0, 1, 4, frontShield)

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

--Cruiser: strike craft (fast in/out)
template = ShipTemplate():setName(stalkerQ7):setClass(frigate, cruiser .. " : " .. strikeShip):setModel("small_frigate_3")
template:setRadarTrace("radar_cruiser.png")
template:setDescription(stalkerQ7Description)
template:setHull(50)
template:setShields(80, 30, 30, 30)
template:setSpeed(70, 12, 12)
template:setWarpSpeed(700)
template:setBeam(0, 40,-5, 1000.0, 6.0, 6)
template:setBeam(1, 40, 5, 1000.0, 6.0, 6)

variation = template:copy(stalkerR7)
variation:setDescription(stalkerR7Description)
variation:setWarpSpeed(0)
variation:setJumpDrive(true)

template = ShipTemplate():setName(ranusU):setClass(frigate, cruiser .. " : " .. sniper):setModel("MissileCorvetteGreen")
template:setRadarTrace("radar_cruiser.png")
template:setDescription(ranusUDescription)
template:setHull(30)
template:setShields(30, 5, 5)
template:setSpeed(50, 6, 20)
template:setTubes(3, 25.0)
template:weaponTubeDisallowMissle(1, nuke):weaponTubeDisallowMissle(2, nuke)
template:setWeaponStorage(homing, 6)
template:setWeaponStorage(nuke, 2)

--Cruiser: tackler

template = ShipTemplate():setName(flavia):setClass(frigate, lightTransport):setModel("LightCorvetteGrey")
template:setRadarTrace("radar_tug.png")
template:setDescription(flaviaDescription)
template:setHull(50)
template:setShields(50, 50)
template:setSpeed(30, 8, 10)

variation = template:copy(flaviaFalcon)
variation:setDescription(flaviaFalconDescription)
variation:setSpeed(50, 8, 10)
variation:setBeam(0, 40, 170, 1200.0, 6.0, 6)
variation:setBeam(1, 40, 190, 1200.0, 6.0, 6)

variation = variation:copy(flaviaPFalcon):setType("playership")
variation:setDescription(flaviaPFalconDescription)
variation:setHull(100)
variation:setShields(70, 70)
variation:setSpeed(60, 10, 10)
variation:setWarpSpeed(500)
variation:setCombatManeuver(250, 150)
variation:setTubes(1, 20.0)
variation:setTubeDirection(0, 180)
variation:setWeaponStorage(hvli, 5)
variation:setWeaponStorage(homing, 3)
variation:setWeaponStorage(mine, 1)
variation:setWeaponStorage(nuke, 1)

variation:setRepairCrewCount(8)

variation:addRoom(1, 0, 6, 1)
variation:addRoom(1, 5, 6, 1)
variation:addRoomSystem(0, 1, 2, 2, rearShield)
variation:addRoomSystem(0, 3, 2, 2, missileSystem)
variation:addRoomSystem(2, 1, 2, 2, beamWeapons)
variation:addRoomSystem(2, 3, 2, 2, reactor)
variation:addRoomSystem(4, 1, 2, 2, warp)
variation:addRoomSystem(4, 3, 2, 2, jumpDrive)
variation:addRoomSystem(6, 1, 2, 2, impulse)
variation:addRoomSystem(6, 3, 2, 2, maneuver)
variation:addRoomSystem(8, 2, 2, 2, frontShield)

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

template = ShipTemplate():setName(repulse):setClass(frigate, armoredTransport):setModel("LightCorvetteRed"):setType("playership")
template:setRadarTrace("radar_tug.png")
template:setDescription(repulseDescription)
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
template:setWeaponStorage(hvli, 6)
template:setWeaponStorage(homing, 4)

template:setRepairCrewCount(8)
--	(H)oriz, (V)ert	   HC,VC,HS,VS, system    (C)oordinate (S)ize
template:addRoomSystem( 0, 1, 2, 4, impulse)
template:addRoomSystem( 2, 0, 2, 2, rearShield)
template:addRoomSystem( 2, 2, 2, 2, warp)
template:addRoom( 2, 4, 2, 2)
template:addRoomSystem( 4, 1, 1, 4, maneuver)
template:addRoom( 5, 0, 2, 2)
template:addRoomSystem( 5, 2, 2, 2, jumpDrive)
template:addRoomSystem( 5, 4, 2, 2, beamWeapons)
template:addRoomSystem( 7, 1, 3, 2, reactor)
template:addRoomSystem( 7, 3, 3, 2, missileSystem)
template:addRoomSystem(10, 2, 2, 2, frontShield)

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
