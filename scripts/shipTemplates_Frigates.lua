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
template:setDescription([[The Phobos T3, just like the Atlantis, is the working horse of almost any navy. It's extremely easy to modify, which makes retro-fitting this ship a breeze. It's basic stats aren't all that impressive, but due to it's modular nature, it's fairly easy to produce in large quantities.]])
template:setHull(70)
template:setShields(50, 40)
template:setSpeed(60, 10, 10)
template:setBeamWeapon(0, 90, -15, 1200, 8, 6)
template:setBeamWeapon(1, 90,  15, 1200, 8, 6)
template:setTubes(2, 10.0)
template:setWeaponStorage("HVLI", 20)
template:setWeaponStorage("Homing", 6)
template:setTubeDirection(0, -1)
template:setTubeDirection(1,  1)

variation = template:copy("Phobos M3"):setModel("AtlasHeavyFighterRed")
variation:setDescription([[The Phonos M3 is one of the most comon variants on the Phonos T3. An extra mine tube was added to the ship. The extra storage space required for the mines does make this ship slightly slower.]])
variation:setTubes(3, 10.0)
variation:setWeaponStorage("Mine", 6)
variation:setSpeed(55, 10, 10)
variation:weaponTubeDisallowMissle(0, "Mine"):weaponTubeDisallowMissle(1, "Mine")
variation:setTubeDirection(2,  180):setWeaponTubeExclusiveFor(2, "Mine")

variation = variation:copy("Phobos M3P"):setType("playership")
variation:setDescription([[Player variant of the Phobos M3, not as strong as the atlantis, but has front firing tubes, making it an easier to use ship in some scenarios.]])
variation:setShields(100, 100)
variation:setHull(150)
variation:setSpeed(80, 10, 20)
variation:setCombatManeuver(400, 250)
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

template = ShipTemplate():setName("Nirvana R5"):setClass("Frigate", "Cruiser: Anti Starfighter"):setModel("small_frigate_5") -- TODO: Better 3D model selection
template:setDescription([[The Nirvana R5 is an anti fighter cruiser. It has a large amount of fast firing, low damage point-defense weapons to quickly take out starfighters.]])
template:setBeamWeapon(0, 90, -15, 1200, 3, 1)
template:setBeamWeapon(1, 90,  15, 1200, 3, 1)
template:setBeamWeapon(2, 90,  50, 1200, 3, 1)
template:setBeamWeapon(3, 90, -50, 1200, 3, 1)
template:setHull(70)
template:setShields(50, 40)
template:setSpeed(70, 12, 10)

variation = template:copy("Nirvana R5A")
variation:setDescription([[Advanced version of the Nirvana R5. Faster turning speed and slightly more fire power]])
variation:setBeamWeapon(0, 90, -15, 1200, 2.9, 1)
variation:setBeamWeapon(1, 90,  15, 1200, 2.9, 1)
variation:setBeamWeapon(2, 90,  50, 1200, 2.9, 1)
variation:setBeamWeapon(3, 90, -50, 1200, 2.9, 1)
variation:setSpeed(70, 15, 10)

template = ShipTemplate():setName("Piranha F12"):setClass("Frigate", "Cruiser: Light Artillery"):setModel("HeavyCorvetteRed")
template:setDescription([[Light artillery cruiser, smallest ship that is an exclusive broadside type ship.]])
template:setHull(70)
template:setShields(30, 30)
template:setSpeed(40, 6, 8)
template:setTubes(6, 12.0)
template:setWeaponStorage("HVLI", 20)
template:setWeaponStorage("Homing", 6)
template:setTubeDirection(0, -90):setWeaponTubeExclusiveFor(0, "HVLI")
template:setTubeDirection(1, -90)
template:setTubeDirection(2, -90):setWeaponTubeExclusiveFor(2, "HVLI")
template:setTubeDirection(3,  90):setWeaponTubeExclusiveFor(3, "HVLI")
template:setTubeDirection(4,  90)
template:setTubeDirection(5,  90):setWeaponTubeExclusiveFor(5, "HVLI")

variation = template:copy("Piranha F12.M")
variation:setDescription([[Modified F12 Piranha. In all aspects the same, except that it has made special modifications to fire Nukes next to the normal loadout. This does lower the overal missile storage.]])
variation:setWeaponStorage("HVLI", 10)
variation:setWeaponStorage("Homing", 4)
variation:setWeaponStorage("Nuke", 2)

variation = template:copy("Piranha F8")
variation:setDescription([[First version of the Piranha that was sold. Not popular due to the low amount of firepower, and the odd tube configuration. A huge financial failure.]])
variation:setTubes(3, 12.0)
variation:setWeaponStorage("HVLI", 10)
variation:setWeaponStorage("Homing", 5)
variation:setTubeDirection(0,   0):setWeaponTubeExclusiveFor(0, "HVLI")
variation:setTubeDirection(1, -90)
variation:setTubeDirection(2,  90)

variation = template:copy("Piranha"):setType("playership")
variation:setDescription([[Modified F12 Piranha. Improved for advanced usage scenarios. Player specific]])
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
template:setDescription([[A strike ship, fast in, fast out. Quick damage and be gone again. The Q7 model is fit with a warpdrive.]])
template:setHull(50)
template:setShields(80, 30, 30, 30)
template:setSpeed(70, 12, 12)
template:setWarpSpeed(700)
template:setBeam(0, 40,-5, 1000.0, 6.0, 6)
template:setBeam(1, 40, 5, 1000.0, 6.0, 6)

variation = template:copy("Stalker R7")
variation:setDescription([[A strike ship, fast in, fast out. Quick damage and be gone again. The R7 model is fit with a jumpdrive.]])
variation:setWarpSpeed(0)
variation:setJumpDrive(true)

template = ShipTemplate():setName("Ranus U"):setClass("Frigate", "Cruiser: Sniper"):setModel("MissileCorvetteGreen")
template:setDescription([[The sniper is intended to fly in, deal a quick large amount of damage from a distance, and head off again. It's the only basic frigate that carries nukes. Of all frigates, this is the smalles one.]])
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
template:setDescription([[Small goods or person transport. Cheaper then a freighter, usually used when high value or small amounts of cargo needs to be transported]])
template:setHull(50)
template:setShields(50, 50)
template:setSpeed(30, 8, 10)

variation = template:copy("Flavia Falcon")
variation:setDescription([[The Flavia Falcon is a modified Flavia transport, this transport contains modifications for faster flight and rear mounted lasers to keep enemies off it's back.]])
variation:setSpeed(50, 8, 10)
variation:setBeam(0, 40, 170, 1200.0, 6.0, 6)
variation:setBeam(1, 40, 190, 1200.0, 6.0, 6)

variation = variation:copy("Flavia P.Falcon"):setType("playership")
variation:setDescription([[Flavia Falcon for player usage. Can be used in scenarios where the players have to transport stuff, has more advanced rear facing defences then the normal Flavia Falcon]])
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
