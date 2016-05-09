--[[               Starfighters
Starfighters are single to 3 person small ships. These are most commonly used as light firepower roles.
They are common in larger groups. And need a close by station or support ship, as they lack long time life support.
It's rare to see starfighters with more then 1 shield section.

One of the most well known starfighters at earth is the X-Wing.

Starfighters come in 3 subclasses:
* Interceptors: Fast, low on firepower, high on manouverability
* Gunship: Equiped with more weapons, but hands in maneuverbility because of it.
* Bomber: Slowest of all starfighters, but pack a large punch in a small package. Usually come without any lasers, but the largers bombers have been known to deliver nukes.
----------------------------------------------------------]]
template = ShipTemplate():setName("MT52 Hornet"):setClass("Starfighter", "Interceptor"):setModel("WespeScoutYellow")
template:setRadarTrace("radar_fighter.png")
template:setDescription([[The MT52 hornet is a basic interceptor found in many corners of the galaxy.
It is easy to find spare parts of this ship. Not only because they are produced in high numbers.
Also because they suffer high losses in combat.]])
template:setHull(30)
template:setShields(20)
template:setSpeed(120, 30, 25)
template:setDefaultAI('fighter')
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 30, 0, 1000.0, 4.0, 2)

variation = template:copy("MU52 Hornet")
variation:setModel("WespeScoutRed")
variation:setDescription([[Upgraded version of the MT52 Hornet. Very new model.]])
variation:setHull(35)
variation:setShields(22)
variation:setSpeed(125, 32, 25)
variation:setBeam(0, 30, 0, 1100.0, 4.0, 2.5)

variation = variation:copy("MP52 Hornet"):setType("playership")
variation:setDescription([[Upgraded version of the upgraded MU52 Hornet. Specially for players.]])
variation:setSpeed(125, 32, 40)
variation:setCombatManeuver(600, 0)
variation:setBeam(0, 30, 5, 1100.0, 4.0, 2.5)
variation:setBeam(1, 30,-5, 1100.0, 4.0, 2.5)
variation:setEnergyStorage(400)

variation:addRoomSystem(3, 0, 1, 1, "Maneuver");
variation:addRoomSystem(1, 0, 2, 1, "BeamWeapons");

variation:addRoomSystem(0, 1, 1, 2, "RearShield");
variation:addRoomSystem(1, 1, 2, 2, "Reactor");
variation:addRoomSystem(3, 1, 2, 1, "Warp");
variation:addRoomSystem(3, 2, 2, 1, "JumpDrive");
variation:addRoomSystem(5, 1, 1, 2, "FrontShield");

variation:addRoomSystem(1, 3, 2, 1, "MissileSystem");
variation:addRoomSystem(3, 3, 1, 1, "Impulse");

variation:addDoor(2, 1, true);
variation:addDoor(3, 1, true);
variation:addDoor(1, 1, false);
variation:addDoor(3, 1, false);
variation:addDoor(3, 2, false);
variation:addDoor(3, 3, true);
variation:addDoor(2, 3, true);
variation:addDoor(5, 1, false);
variation:addDoor(5, 2, false);

template = ShipTemplate():setName("Adder MK5"):setClass("Starfighter", "Gunship"):setModel("AdlerLongRangeScoutYellow")
template:setDescription([[The fifth iteration of the Adder proved to be a large success with pirates and law officers.
It is cheap, easy to maintain, packs a decent punch, fast.]])
template:setHull(50)
template:setShields(30)
template:setSpeed(80, 28, 25)
template:setBeam(0, 35, -0, 1200, 5.0, 2.0)
template:setBeam(1, 70, 30, 1000, 5.0, 2.0)
template:setBeam(2, 70, -35, 1000, 5.0, 2.0)
template:setTubes(1, 15.0)
template:setWeaponStorage("HVLI", 10)

variation = template:copy("Adder MK4")
variation:setModel("AdlerLongRangeScoutBlue")
variation:setDescription([[The mark 4 Adder is a rare sight these days. Due to the high success of the mark 5 Adder, the mark 4 is often replaced.
In general, the mark 4 is seen as the retarded version of a mark 5. And sometimes mark 4 ships are being sold as mark 5 to the careless buyer.]])
variation:setHull(40)
variation:setShields(20)
variation:setSpeed(60, 20, 20)
variation:setTubes(1, 20.0)
variation:setWeaponStorage("HVLI", 8)

variation = template:copy("Adder MK6")
variation:setModel("AdlerLongRangeScoutRed")
variation:setDescription([[The mark 6 adder is a small upgrade compared to the highly successful mark 5 Adder.
Due to the large success of the mark 5, the mark 6 has not seen much market penetration, as people prefer the reliable and well known mark 5.]])
variation:setBeam(3, 35,180, 600, 6.0, 2.0)
variation:setWeaponStorage("HVLI", 12)

template = ShipTemplate():setName("WX-Lindworm"):setClass("Starfighter", "Bomber"):setModel("LindwurmFighterYellow")
template:setDescription([[Not your typical lindworm.
A bomber class starfighter. While one of the least shielded starfighters in active duty, the WX-Lindworm, or Worm as it is often called, can pack quite a punch.
It's goal is, fly in, destroy or be destroyed, and fly out.]])
template:setHull(50)
template:setShields(20)
template:setSpeed(50, 15, 25)
template:setTubes(3, 15.0)
template:setWeaponStorage("HVLI", 6)
template:setWeaponStorage("Homing", 1)
template:setTubeDirection(1, -1):setWeaponTubeExclusiveFor(1, "HVLI")
template:setTubeDirection(2,  1):setWeaponTubeExclusiveFor(2, "HVLI")
