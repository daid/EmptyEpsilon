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
template = ShipTemplate():setName("Phobos T3"):setClass("Frigate", "Cruiser"):setModel("AtlasHeavyFighterYellow")
template:setDescription([[The Phobos T3, just like the Atlantis, is the workhorse of almost any navy. It's extremely easy to modify, which makes retro-fitting this ship a breeze. Its basic stats aren't impressive, but due to its modular nature, it's fairly easy to produce in large quantities.]])
template:setHull(70)
template:setShields(50, 40)
template:setSpeed(60, 10, 10)
template:setBeamWeapon(0, 90, -15, 1200, 8, 6)
template:setBeamWeapon(1, 90,  15, 1200, 8, 6)
template:setTubes(2, 60.0)
template:setWeaponStorage("HVLI", 20)
template:setWeaponStorage("Homing", 6)
template:setTubeDirection(0, -1)
template:setTubeDirection(1,  1)

variation = template:copy("Phobos M3"):setModel("AtlasHeavyFighterRed")
variation:setDescription([[The Phobos M3 is one of the most common variants of the Phobos T3. It adds a mine-laying tube, but the extra storage required for the mines slows this ship down slightly.]])
variation:setTubes(3, 60.0)
variation:setWeaponStorage("Mine", 6)
variation:setSpeed(55, 10, 10)
variation:weaponTubeDisallowMissle(0, "Mine"):weaponTubeDisallowMissle(1, "Mine")
variation:setTubeDirection(2,  180):setWeaponTubeExclusiveFor(2, "Mine")

variation = variation:copy("Phobos M3P"):setType("playership")
variation:setDescription([[Player variant of the Phobos M3, not as strong as the atlantis, but has front firing tubes, making it an easier to use ship in some scenarios.]])
variation:setShields(100, 100)
variation:setHull(200)
variation:setSpeed(80, 10, 20)
variation:setCombatManeuver(400, 250)
variation:setTubes(3, 10.0)
variation:setWeaponStorage("Homing", 10)
variation:setWeaponStorage("Nuke", 2)
variation:setWeaponStorage("Mine", 4)
variation:setWeaponStorage("EMP", 3)

variation:addRoomSystem(1, 0, 2, 1, "Maneuver");
variation:addRoomSystem(1, 1, 2, 1, "BeamWeapons");
variation:addRoom(2, 2, 2, 1);

variation:addRoomSystem(0, 3, 1, 2, "RearShield");
variation:addRoomSystem(1, 3, 2, 2, "Reactor");
variation:addRoomSystem(3, 3, 2, 2, "Warp");
variation:addRoomSystem(5, 3, 1, 2, "JumpDrive");
variation:addRoom(6, 3, 2, 1);
variation:addRoom(6, 4, 2, 1);
variation:addRoomSystem(8, 3, 1, 2, "FrontShield");

variation:addRoom(2, 5, 2, 1);
variation:addRoomSystem(1, 6, 2, 1, "MissileSystem");
variation:addRoomSystem(1, 7, 2, 1, "Impulse");

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

template = ShipTemplate():setName("Nirvana R5"):setClass("Frigate", "Cruiser: Anti-fighter"):setModel("small_frigate_5") -- TODO: Better 3D model selection
template:setDescription([[The Nirvana R5 is an anti-fighter cruiser. It has several rapid-firing, low-damage point-defense weapons to quickly take out starfighters.]])
template:setBeamWeapon(0, 90, -15, 1200, 3, 1)
template:setBeamWeapon(1, 90,  15, 1200, 3, 1)
template:setBeamWeapon(2, 90,  50, 1200, 3, 1)
template:setBeamWeapon(3, 90, -50, 1200, 3, 1)
template:setHull(70)
template:setShields(50, 40)
template:setSpeed(70, 12, 10)

variation = template:copy("Nirvana R5A")
variation:setDescription([[An improved version of the Nirvana R5 with faster turning speed and firing rates.]])
variation:setBeamWeapon(0, 90, -15, 1200, 2.9, 1)
variation:setBeamWeapon(1, 90,  15, 1200, 2.9, 1)
variation:setBeamWeapon(2, 90,  50, 1200, 2.9, 1)
variation:setBeamWeapon(3, 90, -50, 1200, 2.9, 1)
variation:setSpeed(70, 15, 10)

template = ShipTemplate():setName("Piranha F12"):setClass("Frigate", "Cruiser: Light Artillery"):setModel("HeavyCorvetteRed")
template:setDescription([[A light artillery cruiser, the Piranha F12 is the smallest ship to exclusively fire from broadside weapon tubes.]])
template:setHull(70)
template:setShields(30, 30)
template:setSpeed(40, 6, 8)
template:setTubes(6, 15.0)
template:setWeaponStorage("HVLI", 20)
template:setWeaponStorage("Homing", 6)
template:setTubeDirection(0, -90):setWeaponTubeExclusiveFor(0, "HVLI")
template:setTubeDirection(1, -90)
template:setTubeDirection(2, -90):setWeaponTubeExclusiveFor(2, "HVLI")
template:setTubeDirection(3,  90):setWeaponTubeExclusiveFor(3, "HVLI")
template:setTubeDirection(4,  90)
template:setTubeDirection(5,  90):setWeaponTubeExclusiveFor(5, "HVLI")

variation = template:copy("Piranha F12.M")
variation:setDescription([[This modified Piranha F12 is in all respects the same vessel except for special weapon tube modifications that allow it to fire nukes in addition to its normal loadout. However, these changes reduce its overall missile storage capacity.]])
variation:setWeaponStorage("HVLI", 10)
variation:setWeaponStorage("Homing", 4)
variation:setWeaponStorage("Nuke", 2)

variation = template:copy("Piranha F8")
variation:setDescription([[The first version of the Piranha was not popular due to its meager firepower and odd tube configuration. The result was a huge financial failure.]])
variation:setTubes(3, 12.0)
variation:setWeaponStorage("HVLI", 10)
variation:setWeaponStorage("Homing", 5)
variation:setTubeDirection(0,   0):setWeaponTubeExclusiveFor(0, "HVLI")
variation:setTubeDirection(1, -90)
variation:setTubeDirection(2,  90)

variation = template:copy("Piranha"):setType("playership")
variation:setDescription([[This combat-specialized Piranha F12 adds mine-laying tubes, combat maneuvering systems, and a jump drive.]])
variation:setHull(120)
variation:setShields(70, 70)
variation:setSpeed(60, 10, 8)
variation:setTubes(8, 8.0)
variation:setCombatManeuver(200, 150)
variation:setJumpDrive(true)
variation:setWeaponStorage("HVLI", 20)
variation:setWeaponStorage("Homing", 12)
variation:setWeaponStorage("Nuke", 6)
variation:setWeaponStorage("Mine", 8)
variation:weaponTubeAllowMissle(0, "Homing"):weaponTubeAllowMissle(2, "Homing")
variation:weaponTubeAllowMissle(3, "Homing"):weaponTubeAllowMissle(5, "Homing")
variation:setTubeDirection(6, 170):setWeaponTubeExclusiveFor(6, "Mine")
variation:setTubeDirection(7, 190):setWeaponTubeExclusiveFor(7, "Mine")

variation:setRepairCrewCount(2)
variation:addRoomSystem(0, 0, 1, 4, "RearShield")
variation:addRoom(1, 0, 1, 1)
variation:addRoomSystem(1, 1, 3, 2, "MissileSystem")
variation:addRoom(1, 3, 1, 1)

variation:addRoomSystem(2, 0, 2, 1, "Beamweapons")
variation:addRoomSystem(2, 3, 2, 1, "Maneuver")

variation:addRoomSystem(4, 0, 2, 1, "Warp")
variation:addRoomSystem(4, 3, 2, 1, "JumpDrive")
variation:addRoomSystem(5, 1, 1, 2, "Reactor")

variation:addRoom(6, 0, 1, 1)
variation:addRoomSystem(6, 1, 1, 2, "Impulse")
variation:addRoom(6, 3, 1, 1)

variation:addRoomSystem(7, 0, 1, 4, "FrontShield")

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

--Cruiser: stike craft (fast in/out)
template = ShipTemplate():setName("Stalker Q7"):setClass("Frigate", "Cruiser: Strike ship"):setModel("small_frigate_3")
template:setDescription([[The Stalker is a strike ship designed to swoop into battle, deal damage quickly, and get out fast. The Q7 model is fitted with a warp drive.]])
template:setHull(50)
template:setShields(80, 30, 30, 30)
template:setSpeed(70, 12, 12)
template:setWarpSpeed(700)
template:setBeam(0, 40,-5, 1000.0, 6.0, 6)
template:setBeam(1, 40, 5, 1000.0, 6.0, 6)

variation = template:copy("Stalker R7")
template:setDescription([[The Stalker is a strike ship designed to swoop into battle, deal damage quickly, and get out fast. The R7 model is fitted with a jump drive.]])
variation:setWarpSpeed(0)
variation:setJumpDrive(true)

template = ShipTemplate():setName("Ranus U"):setClass("Frigate", "Cruiser: Sniper"):setModel("MissileCorvetteGreen")
template:setDescription([[The Ranus U sniper is built to deal a large amounts of damage quickly and from a distance before escaping. It's the only basic frigate that carries nuclear weapons, even though it's also the smallest of all frigate-class ships.]])
template:setHull(30)
template:setShields(30, 5, 5)
template:setSpeed(50, 6, 20)
template:setTubes(3, 25.0)
template:weaponTubeDisallowMissle(1, "Nuke"):weaponTubeDisallowMissle(2, "Nuke")
template:setWeaponStorage("Homing", 6)
template:setWeaponStorage("Nuke", 2)

--Cruiser: tackler

template = ShipTemplate():setName("Flavia"):setClass("Frigate", "Light transport"):setModel("LightCorvetteGrey")
template:setRadarTrace("radar_tug.png")
template:setDescription([[Popular among traders and smugglers, the Flavia is a small cargo and passenger transport. It's cheaper than a freighter for small loads and short distances, and is often used to carry high-value cargo discreetly.]])
template:setHull(50)
template:setShields(50, 50)
template:setSpeed(30, 8, 10)

variation = template:copy("Flavia Falcon")
variation:setDescription([[The Flavia Falcon is a Flavia transport modified for faster flight, and adds rear-mounted lasers to keep enemies off its back.]])
variation:setSpeed(50, 8, 10)
variation:setBeam(0, 40, 170, 1200.0, 6.0, 6)
variation:setBeam(1, 40, 190, 1200.0, 6.0, 6)

variation = variation:copy("Flavia P.Falcon"):setType("playership")
variation:setDescription([[The Flavia P.Falcon has a nuclear-capable rear-facing weapon tube and a warp drive.]])
template:setHull(100)
template:setShields(70, 70)
variation:setSpeed(60, 10, 10)
variation:setWarpSpeed(500)
variation:setCombatManeuver(250, 150)
variation:setTubes(1, 20.0)
variation:setTubeDirection(0, 180)
variation:setWeaponStorage("HVLI", 5)
variation:setWeaponStorage("Homing", 3)
variation:setWeaponStorage("Mine", 1)
variation:setWeaponStorage("Nuke", 1)

variation:setRepairCrewCount(8)

variation:addRoom(1, 0, 6, 1)
variation:addRoom(1, 5, 6, 1)
variation:addRoomSystem(0, 1, 2, 2, "RearShield")
variation:addRoomSystem(0, 3, 2, 2, "MissileSystem")
variation:addRoomSystem(2, 1, 2, 2, "Beamweapons")
variation:addRoomSystem(2, 3, 2, 2, "Reactor")
variation:addRoomSystem(4, 1, 2, 2, "Warp")
variation:addRoomSystem(4, 3, 2, 2, "JumpDrive")
variation:addRoomSystem(6, 1, 2, 2, "Impulse")
variation:addRoomSystem(6, 3, 2, 2, "Maneuver")
variation:addRoomSystem(8, 2, 2, 2, "FrontShield")

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

--Support: mine layer
--Support: mine sweeper
--Support: science vessel
--Support: deep space recon
--Support: light repair
--Support: resupply
