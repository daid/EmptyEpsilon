require("options.lua")
require(lang .. "/ships.lua")
require(lang .. "/factions.lua")

--[[               Chasseurs stellaires
Les chasseurs sont de petits vaisseaux de 1 ? 3 personnes. Ils sont le plus souvent utilis?s pour des r?les n?cessitant une puissance de feu l?g?re.
Ils sont courants dans les groupes plus importants. Ils ont besoin d'une station proche ou d'un vaisseau de soutien, car ils n'ont pas de syst?me de survie ? long terme.
Il est rare de voir des chasseurs avec plus d'une section de bouclier.

L'un des chasseurs les plus connus sur Terre est le X-Wing.

Les chasseurs stellaires sont divis?s en 3 sous-classes :
* Les intercepteurs : Rapides, peu puissants, tr?s maniables
* Canonnier : Dot? d'une plus grande puissance de feu, qui le rend moins maniable.
* Bombardier : Le plus lent de tous les chasseurs, mais avec une grande puissance de frappe. Ils sont g?n?ralement livr?s sans laser, mais les bombardiers de grande taille sont connus pour leur capacit? ? larguer des bombes nucl?aires.
----------------------------------------------------------]]
template = ShipTemplate():setName(hornetMT52):setClass(starfighter, interceptor):setModel("WespeScoutYellow")
template:setRadarTrace("radar_fighter.png")
template:setDescription(stalkerR7Description)
template:setHull(30)
template:setShields(20)
template:setSpeed(120, 30, 25)
template:setDefaultAI('fighter')
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 30, 0, 700.0, 4.0, 2)

variation = template:copy(hornetMU52)
variation:setModel("WespeScoutRed")
variation:setDescription(hornetMU52Description)
variation:setHull(35)
variation:setShields(22)
variation:setSpeed(125, 32, 25)
variation:setBeam(0, 30, 0, 900.0, 4.0, 2.5)

variation = variation:copy(hornetMP52):setType("playership")
variation:setDescription(hornetMP52Description)
variation:setHull(70)
variation:setShields(60)
variation:setSpeed(125, 32, 40)
variation:setCombatManeuver(600, 0)
variation:setBeam(0, 30, 5, 900.0, 4.0, 2.5)
variation:setBeam(1, 30,-5, 900.0, 4.0, 2.5)
variation:setEnergyStorage(400)

variation:setRepairCrewCount(1)
variation:addRoomSystem(3, 0, 1, 1, maneuver);
variation:addRoomSystem(1, 0, 2, 1, beamWeapons);

variation:addRoomSystem(0, 1, 1, 2, rearShield);
variation:addRoomSystem(1, 1, 2, 2, reactor);
variation:addRoomSystem(3, 1, 2, 1, warp);
variation:addRoomSystem(3, 2, 2, 1, jumpDrive);
variation:addRoomSystem(5, 1, 1, 2, frontShield);

variation:addRoomSystem(1, 3, 2, 1, missileSystem);
variation:addRoomSystem(3, 3, 1, 1, impulse);

variation:addDoor(2, 1, true);
variation:addDoor(3, 1, true);
variation:addDoor(1, 1, false);
variation:addDoor(3, 1, false);
variation:addDoor(3, 2, false);
variation:addDoor(3, 3, true);
variation:addDoor(2, 3, true);
variation:addDoor(5, 1, false);
variation:addDoor(5, 2, false);

template = ShipTemplate():setName(adderMK5):setClass(starfighter, gunner):setModel("AdlerLongRangeScoutYellow")
template:setRadarTrace("radar_fighter.png")
template:setDescription(adderMK5Description)
template:setHull(50)
template:setShields(30)
template:setSpeed(80, 28, 25)
template:setBeam(0, 35, 0, 800, 5.0, 2.0)
template:setBeam(1, 70, 30, 600, 5.0, 2.0)
template:setBeam(2, 70, -35, 600, 5.0, 2.0)
template:setTubes(1, 15.0)
template:setTubeSize(0, "small")
template:setWeaponStorage(hvli, 4)

variation = template:copy(adderMK4)
variation:setModel("AdlerLongRangeScoutBlue")
variation:setDescription(adderMK4Description)
variation:setHull(40)
variation:setShields(20)
variation:setSpeed(60, 20, 20)
variation:setTubes(1, 20.0)
variation:setTubeSize(0, "small")
variation:setWeaponStorage(hvli, 2)

variation = template:copy(adderMK6)
variation:setModel("AdlerLongRangeScoutRed")
variation:setDescription(adderMK6Description)
variation:setBeam(3, 35,180, 600, 6.0, 2.0)
variation:setWeaponStorage(hvli, 8)

template = ShipTemplate():setName(lindwormWX):setClass(starfighter, popper):setModel("LindwurmFighterYellow")
template:setRadarTrace("radar_fighter.png")
template:setDescription(lindwormWXDescription)
template:setHull(50)
template:setShields(20)
template:setSpeed(50, 15, 25)
template:setTubes(3, 15.0)
template:setWeaponStorage(hvli, 6)
template:setWeaponStorage(homing, 1)
template:setTubeSize(0, "small")
template:setTubeSize(1, "small")
template:setTubeSize(2, "small")
template:setTubeDirection(1, 1):setWeaponTubeExclusiveFor(1, hvli)
template:setTubeDirection(2,-1):setWeaponTubeExclusiveFor(2, hvli)

variation = template:copy(lindwormZX):setModel("LindwurmFighterBlue"):setType("playership")
variation:setHull(75)
variation:setShields(40)
variation:setSpeed(70, 15, 25)
variation:setTubes(3, 10.0)
variation:setTubeSize(0, "small")
variation:setTubeSize(1, "small")
variation:setTubeSize(2, "small")

variation:setWeaponStorage(hvli, 12)
variation:setWeaponStorage(homing, 3)
--                  Arc, Dir, Range, CycleTime, Dmg
variation:setBeam(0, 10, 180, 700, 6.0, 2)
--								  Arc, Dir, Rotate speed
variation:setBeamWeaponTurret( 0, 270, 180, 4)
variation:setCombatManeuver(250, 150)
variation:setEnergyStorage(400)

variation:setRepairCrewCount(1)
variation:addRoomSystem(0,0,1,3,rearShield)
variation:addRoomSystem(1,1,3,1,missileSystem)
variation:addRoomSystem(4,1,2,1,beamWeapons)
variation:addRoomSystem(3,2,2,1,reactor)
variation:addRoomSystem(2,3,2,1,warp)
variation:addRoomSystem(4,3,5,1,jumpDrive)
variation:addRoomSystem(0,4,1,3,impulse)
variation:addRoomSystem(3,4,2,1,maneuver)
variation:addRoomSystem(1,5,3,1,frontShield)
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