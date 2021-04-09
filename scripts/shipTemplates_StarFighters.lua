--[[               Starfighters
Starfighters are single to 3 person small ships. These are most commonly used as light firepower roles.
They are common in larger groups. And need a close by station or support ship, as they lack long time life support.
It's rare to see starfighters with more then 1 shield section.

One of the most well known starfighters at earth is the X-Wing.

Starfighters come in 3 subclasses:
* Interceptors: Fast, low on firepower, high on maneuverability
* Gunship: Equipped with more weapons, but hands in maneuverability because of it.
* Bomber: Slowest of all starfighters, but pack a large punch in a small package. Usually come without any lasers, but the larger bombers have been known to deliver nukes.
----------------------------------------------------------]]
template = ShipTemplate():setName("MT52 Hornet"):setLocaleName(_("ship", "MT52 Hornet")):setClass(_("class", "Starfighter"), _("subclass", "Interceptor")):setModel("WespeScoutYellow")
template:setRadarTrace("radar_fighter.png")
template:setDescription(_([[The MT52 Hornet is a basic interceptor found in many corners of the galaxy. It's easy to find spare parts for MT52s, not only because they are produced in large numbers, but also because they suffer high losses in combat.]]))
template:setHull(30)
template:setShields(20)
template:setSpeed(120, 30, 25)
template:setDefaultAI('fighter')
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 30, 0, 700.0, 4.0, 2)

variation = template:copy("MU52 Hornet"):setLocaleName(_("ship", "MU52 Hornet"))
variation:setModel("WespeScoutRed")
variation:setDescription(_([[The MU52 Hornet is a new, upgraded version of the MT52. All of its systems are slightly improved over the MT52 model.]]))
variation:setHull(35)
variation:setShields(22)
variation:setSpeed(125, 32, 25)
variation:setBeam(0, 30, 0, 900.0, 4.0, 2.5)

variation = variation:copy("MP52 Hornet"):setLocaleName(_("playerShip", "MP52 Hornet")):setType("playership")
variation:setDescription(_([[The MP52 Hornet is a significantly upgraded version of MU52 Hornet, with nearly twice the hull strength, nearly three times the shielding, better acceleration, impulse boosters, and a second laser cannon.]]))
variation:setImpulseSoundFile("sfx/engine_fighter.wav")
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

template = ShipTemplate():setName("Adder MK5"):setLocaleName(_("ship", "Adder MK5")):setClass(_("class", "Starfighter"), _("subclass", "Gunship")):setModel("AdlerLongRangeScoutYellow")
template:setRadarTrace("radar_fighter.png")
template:setDescription(_([[The Adder line's fifth iteration proved to be a great success among pirates and law officers alike. It is cheap, fast, and easy to maintain, and it packs a decent punch.]]))
template:setHull(50)
template:setShields(30)
template:setSpeed(80, 28, 25)
template:setBeam(0, 35, 0, 800, 5.0, 2.0)
template:setBeam(1, 70, 30, 600, 5.0, 2.0)
template:setBeam(2, 70,-30, 600, 5.0, 2.0)
template:setTubes(1, 15.0)
template:setTubeSize(0, "small")
template:setWeaponStorage("HVLI", 4)

variation = template:copy("Adder MK4"):setLocaleName(_("ship", "Adder MK4"))
variation:setModel("AdlerLongRangeScoutBlue")
variation:setDescription(_([[The mark 4 Adder is a rare sight these days due to the success its successor, the mark 5 Adder, which often replaces this model. Its similar hull, however, means careless buyers are sometimes conned into buying mark 4 models disguised as the mark 5.]]))
variation:setHull(40)
variation:setShields(20)
variation:setSpeed(60, 20, 20)
variation:setTubes(1, 20.0)
variation:setTubeSize(0, "small")
variation:setWeaponStorage("HVLI", 2)

var2 = variation:copy("Adder MK3"):setLocaleName(_("ship", "Adder MK3"))
var2:setDescription(_([[The Adder MK3 is one of the first of the Adder line to meet with some success. A large number of them were made before the manufacturer went through its first bankruptcy. There has been a recent surge of purchases of the Adder MK3 in the secondary market due to its low price and its similarity to subsequent models. Compared to the Adder MK4, the Adder MK3 has weaker shields and hull, but a faster turn speed]]))
var2:setHull(35)
var2:setShields(15)
var2:setSpeed(60, 35, 20)

variation = template:copy("Adder MK6"):setLocaleName(_("ship", "Adder MK6"))
variation:setModel("AdlerLongRangeScoutRed")
variation:setDescription(_([[The mark 6 Adder is a small upgrade compared to the highly successful mark 5 model. Since people still prefer the more familiar and reliable mark 5, the mark 6 has not seen the same level of success.]]))
variation:setBeam(3, 35,180, 600, 6.0, 2.0)
variation:setWeaponStorage("HVLI", 8)

var2 = variation:copy("Adder MK7"):setLocaleName(_("ship", "Adder MK7"))
var2:setModel("AdlerLongRangeScoutGreen")
var2:setDescription(_([[The release of the Adder Mark 7 sent the manufacturer into a second bankruptcy. They made improvements to the Mark 7 over the Mark 6 like stronger shields and longer beams, but the popularity of their previous models, especially the Mark 5, prevented them from raising the purchase price enough to recoup the development and manufacturing costs of the Mark 7]]))
var2:setShields(40)
var2:setBeam(0,	30,		0,	 900,	5.0,	2.0)

variation = template:copy("Adder MK8"):setLocaleName(_("ship", "Adder MK8"))
variation:setModel("AdlerLongRangeScoutGreen")
variation:setDescription(_([[New management after bankruptcy revisited their most popular Adder Mark 5 model with improvements: stronger shields, longer and stronger beams and a faster turn speed. Thus was born the Adder Mark 8 model. Targeted to the practical but nostalgic buyer who must purchase replacements for their Adder Mark 5 fleet]]))
variation:setShields(50)
variation:setSpeed(80, 30, 25)
variation:setBeam(0,	30,		0,	 900,	5.0,	2.3)

variation = template:copy("Adder MK9"):setLocaleName(_("ship", "Adder MK9"))
variation:setModel("AdlerLongRangeScoutRed")
variation:setDescription(_([[Hot on the heels of the Adder Mark 8 comes the Adder Mark 9. Still using the Adder Mark 5 as a base, the designers provided stronger shields, stronger, longer and faster beams, faster turn speed and for that extra special touch, two nuclear missiles. As their ad says, 'You'll feel better in an Adder Mark 9.']]))
variation:setShields(50)
variation:setBeam(0,	30,		0,	 900,	4.5,	2.5)
variation:setSpeed(80, 30, 25)
variation:setWeaponStorage("Nuke", 2)

template = ShipTemplate():setName("WX-Lindworm"):setLocaleName(_("ship", "WX-Lindworm")):setClass(_("class", "Starfighter"), _("subclass", "Bomber")):setModel("LindwurmFighterYellow")
template:setRadarTrace("radar_fighter.png")
template:setDescription(_([[The WX-Lindworm, or "Worm" as it's often called, is a bomber-class starfighter. While one of the least-shielded starfighters in active duty, the Worm's two launchers can pack quite a punch. Its goal is to fly in, destroy its target, and fly out or be destroyed.]]))
template:setHull(50)
template:setShields(20)
template:setSpeed(50, 15, 25)
template:setTubes(3, 15.0)
template:setWeaponStorage("HVLI", 6)
template:setWeaponStorage("Homing", 1)
template:setTubeSize(0, "small")
template:setTubeSize(1, "small")
template:setTubeSize(2, "small")
template:setTubeDirection(1, 1):setWeaponTubeExclusiveFor(1, "HVLI")
template:setTubeDirection(2,-1):setWeaponTubeExclusiveFor(2, "HVLI")

variation = template:copy("ZX-Lindworm"):setLocaleName(_("playerShip", "ZX-Lindworm")):setModel("LindwurmFighterBlue"):setType("playership")
variation:setHull(75)
variation:setShields(40)
variation:setSpeed(70, 15, 25)
variation:setTubes(3, 10.0)
variation:setTubeSize(0, "small")
variation:setTubeSize(1, "small")
variation:setTubeSize(2, "small")

variation:setWeaponStorage("HVLI", 12)
variation:setWeaponStorage("Homing", 3)
--                  Arc, Dir, Range, CycleTime, Dmg
variation:setBeam(0, 10, 180, 700, 6.0, 2)
--								  Arc, Dir, Rotate speed
variation:setBeamWeaponTurret( 0, 270, 180, 4)
variation:setCombatManeuver(250, 150)
variation:setEnergyStorage(400)

variation:setRepairCrewCount(1)
variation:addRoomSystem(0,0,1,3,"RearShield")
variation:addRoomSystem(1,1,3,1,"MissileSystem")
variation:addRoomSystem(4,1,2,1,"Beamweapons")
variation:addRoomSystem(3,2,2,1,"Reactor")
variation:addRoomSystem(2,3,2,1,"Warp")
variation:addRoomSystem(4,3,5,1,"JumpDrive")
variation:addRoomSystem(0,4,1,3,"Impulse")
variation:addRoomSystem(3,4,2,1,"Maneuver")
variation:addRoomSystem(1,5,3,1,"FrontShield")
variation:addRoom(4,5,2,1)

variation:addDoor(1,1,false)
variation:addDoor(1,5,false)
variation:addDoor(3,2,true)
variation:addDoor(4,2,true)
variation:addDoor(3,3,true)
variation:addDoor(4,3,true)
variation:addDoor(3,4,true)
variation:addDoor(4,4,true)
variation:addDoor(3,5,true)
variation:addDoor(4,5,true)

