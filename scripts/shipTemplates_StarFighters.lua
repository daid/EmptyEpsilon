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
template:setDescription([[The MT52 Hornet is a basic interceptor found in many corners of the galaxy. It's easy to find spare parts for MT52s, not only because they are produced in large numbers, but also because they suffer high losses in combat.]])
template:setHull(30)
template:setShields(20)
template:setSpeed(120, 30, 25)
template:setDefaultAI('fighter')
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 30, 0, 700.0, 4.0, 2)

variation = template:copy("MU52 Hornet")
variation:setModel("WespeScoutRed")
variation:setDescription([[The MU52 Hornet is a new, upgraded version of the MT52. All of its systems are slightly improved over the MT52 model.]])
variation:setHull(35)
variation:setShields(22)
variation:setSpeed(125, 32, 25)
variation:setBeam(0, 30, 0, 900.0, 4.0, 2.5)

variation = variation:copy("MP52 Hornet"):setType("playership")
variation:setDescription([[The MP52 Hornet is a significantly upgraded version of MU52 Hornet, with nearly twice the hull strength, nearly three times the shielding, better acceleration, impulse boosters, and a second laser cannon.]])
variation:setHull(70)
variation:setShields(60)
variation:setSpeed(125, 32, 40)
variation:setCombatManeuver(600, 0)
variation:setBeam(0, 30, 5, 900.0, 4.0, 2.5)
variation:setBeam(1, 30,-5, 900.0, 4.0, 2.5)
variation:setEnergyStorage(400)

variation:setRepairCrewCount(1)
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
template:setRadarTrace("radar_cruiser.png")
template:setDescription([[The Adder line's fifth iteration proved to be a great success among pirates and law officers alike. It is cheap, fast, and easy to maintain, and it packs a decent punch.]])
template:setHull(50)
template:setShields(30)
template:setSpeed(80, 28, 25)
template:setBeam(0, 35, 0, 800, 5.0, 2.0)
template:setBeam(1, 70, 30, 600, 5.0, 2.0)
template:setBeam(2, 70, -35, 600, 5.0, 2.0)
template:setTubes(1, 15.0)
template:setWeaponStorage("HVLI", 4)

variation = template:copy("Adder MK4")
variation:setModel("AdlerLongRangeScoutBlue")
variation:setDescription([[The mark 4 Adder is a rare sight these days due to the success its successor, the mark 5 Adder, which often replaces this model. Its similar hull, however, means careless buyers are sometimes conned into buying mark 4 models disguised as the mark 5.]])
variation:setHull(40)
variation:setShields(20)
variation:setSpeed(60, 20, 20)
variation:setTubes(1, 20.0)
variation:setWeaponStorage("HVLI", 2)

variation = template:copy("Adder MK6")
variation:setModel("AdlerLongRangeScoutRed")
variation:setDescription([[The mark 6 Adder is a small upgrade compared to the highly successful mark 5 model. Since people still prefer the more familiar and reliable mark 5, the mark 6 has not seen the same level of success.]])
variation:setBeam(3, 35,180, 600, 6.0, 2.0)
variation:setWeaponStorage("HVLI", 8)

template = ShipTemplate():setName("WX-Lindworm"):setClass("Starfighter", "Bomber"):setModel("LindwurmFighterYellow")
template:setRadarTrace("radar_fighter.png")
template:setDescription([[The WX-Lindworm, or "Worm" as it's often called, is a bomber-class starfighter. While one of the least-shielded starfighters in active duty, the Worm's two launchers can pack quite a punch. Its goal is to fly in, destroy its target, and fly out or be destroyed.]])
template:setHull(50)
template:setShields(20)
template:setSpeed(50, 15, 25)
template:setTubes(3, 15.0)
template:setWeaponStorage("HVLI", 6)
template:setWeaponStorage("Homing", 1)
template:setTubeDirection(1, 1):setWeaponTubeExclusiveFor(1, "HVLI")
template:setTubeDirection(2,-1):setWeaponTubeExclusiveFor(2, "HVLI")
