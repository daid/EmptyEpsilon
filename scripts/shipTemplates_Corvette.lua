--[[                  Corvette
Corvettes are the common large ships. Larger then a frigate, smaller then a dreadnaught.
They generally have 4 or more shield sections. Run with a crew of 20 to 250.
This class generally has jumpdrives or warpdrives. But lack the maneuverability that is seen in frigates.

They come in 3 different subclasses:
* Destroyer: Combat oriented ships. No science, no transport. Just death in a large package.
* Support: Large scale support roles. Drone carriers fall in this category. As well as mobile repair centers.
* Freighter: Large scale transport ships. Most common here are the jump freighters, using specialized jumpdrives to cross large distances with large amounts of cargo.
----------------------------------------------------------]]

--[[----------------------Destroyers----------------------]]

template = ShipTemplate():setName("Atlantis X23"):setLocaleName(_("Atlantis X23")):setClass(_("Corvette"), _("Destroyer")):setModel("battleship_destroyer_1_upgraded")
template:setDescription(_([[The Atlantis X23 is the smallest model of destroyer, and its combination of frigate-like size and corvette-like power makes it an excellent escort ship when defending larger ships against multiple smaller enemies. Because the Atlantis X23 is fitted with a jump drive, it can also serve as an intersystem patrol craft.]]))
template:setRadarTrace("radar_dread.png")
template:setHull(100)
template:setShields(200, 200, 200, 200)
template:setSpeed(30, 3.5, 5)
template:setJumpDrive(true)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0,100, -20, 1500.0, 6.0, 8)
template:setBeam(1,100,  20, 1500.0, 6.0, 8)
template:setBeam(2,100, 180, 1500.0, 6.0, 8)
template:setTubes(4, 10.0)
template:setWeaponStorage("HVLI", 20)
template:setWeaponStorage("Homing", 4)
template:setTubeDirection(0, -90)
template:setTubeDirection(1, -90)
template:setTubeDirection(2,  90)
template:setTubeDirection(3,  90)

variation = template:copy("Atlantis"):setLocaleName(_("Atlantis")):setType("playership")
variation:setDescription(_([[A refitted Atlantis X23 for more general tasks. The large shield system has been replaced with an advanced combat maneuvering systems and improved impulse engines. Its missile loadout is also more diverse. Mistaking the modified Atlantis for an Atlantis X23 would be a deadly mistake.]]))
variation:setShields(200, 200)
variation:setHull(250)
variation:setSpeed(90, 10, 20)
variation:setCombatManeuver(400, 250)
variation:setBeam(2, 0, 0, 0, 0, 0)
variation:setWeaponStorage("Homing", 12)
variation:setWeaponStorage("Nuke", 4)
variation:setWeaponStorage("Mine", 8)
variation:setWeaponStorage("EMP", 6)
variation:setTubes(5, 8.0) -- Amount of torpedo tubes, and loading time of the tubes.
variation:weaponTubeDisallowMissle(0, "Mine"):weaponTubeDisallowMissle(1, "Mine")
variation:weaponTubeDisallowMissle(2, "Mine"):weaponTubeDisallowMissle(3, "Mine")
variation:setTubeDirection(4, 180):setWeaponTubeExclusiveFor(4, "Mine")

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

template = ShipTemplate():setName("Starhammer II"):setLocaleName(_("Starhammer II")):setClass(_("Corvette"), _("Destroyer")):setModel("battleship_destroyer_4_upgraded")
template:setDescription(_([[Contrary to its predecessor, the Starhammer II lives up to its name. By resolving the original Starhammer's power and heat management issues, the updated model makes for a phenomenal frontal assault ship. Its low speed makes it difficult to position, but when in the right place at the right time, even the strongest shields can't withstand a Starhammer's assault for long.]]))
template:setRadarTrace("radar_dread.png")
template:setHull(200)
template:setShields(450, 350, 150, 150, 350)
template:setSpeed(35, 6, 10)
template:setJumpDrive(true)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 60, -10, 2000.0, 8.0, 11)
template:setBeam(1, 60,  10, 2000.0, 8.0, 11)
template:setBeam(2, 60, -20, 1500.0, 8.0, 11)
template:setBeam(3, 60,  20, 1500.0, 8.0, 11)
template:setTubes(2, 10.0)
template:setWeaponStorage("HVLI", 20)
template:setWeaponStorage("Homing", 4)
template:setWeaponStorage("EMP", 2)
template:weaponTubeDisallowMissle(1, "EMP")

template = ShipTemplate():setName("Crucible"):setLocaleName(_("Crucible")):setClass(_("Corvette"),_("Popper")):setModel("LaserCorvetteRed"):setType("playership")
template:setDescription(_("A number of missile tubes range around this ship. Beams were deemed lower priority, though they are still present. Stronger defenses than a frigate, but not as strong as the Atlantis"))
template:setRadarTrace("radar_laser.png")
template:setHull(160)
template:setShields(160,160)
template:setSpeed(80,15,40)
template:setCombatManeuver(400, 250)
template:setJumpDrive(false)
template:setWarpSpeed(750)
--                  Arc, Dir,  Range, CycleTime, Dmg
template:setBeam(0, 70, -30, 1000.0, 6.0, 5)
template:setBeam(1, 70,  30, 1000.0, 6.0, 5)
template:setTubes(6, 8.0)
template:setWeaponStorage("HVLI", 24)
template:setWeaponStorage("Homing", 8)
template:setWeaponStorage("EMP", 6)
template:setWeaponStorage("Nuke", 4)
template:setWeaponStorage("Mine", 6)
template:setTubeDirection(0, 0)
template:setTubeSize(0, "small")
template:setTubeDirection(1, 0)
template:setTubeDirection(2, 0)
template:setTubeSize(2, "large")
template:setTubeDirection(3, -90)
template:setTubeDirection(4,  90)
template:setTubeDirection(5, 180)
template:setWeaponTubeExclusiveFor(0, "HVLI")
template:setWeaponTubeExclusiveFor(1, "HVLI")
template:setWeaponTubeExclusiveFor(2, "HVLI")
template:weaponTubeDisallowMissle(3, "Mine")
template:weaponTubeDisallowMissle(4, "Mine")
template:setWeaponTubeExclusiveFor(5, "Mine")

template:setRepairCrewCount(4)

template:addRoomSystem(2, 0, 2, 1, "Maneuver");
template:addRoomSystem(1, 1, 2, 1, "BeamWeapons");
template:addRoomSystem(0, 2, 3, 2, "RearShield");
template:addRoomSystem(1, 4, 2, 1, "Reactor");
template:addRoomSystem(2, 5, 2, 1, "Warp");
template:addRoomSystem(3, 1, 3, 2, "JumpDrive");
template:addRoomSystem(3, 3, 3, 2, "FrontShield");
template:addRoom(6, 2, 6, 2);
template:addRoomSystem(9, 1, 2, 1, "MissileSystem");
template:addRoomSystem(9, 4, 2, 1, "Impulse");

template:addDoor(2, 1, true)
template:addDoor(1, 2, true)
template:addDoor(1, 4, true)
template:addDoor(2, 5, true)
template:addDoor(3, 2, false)
template:addDoor(4, 3, true)
template:addDoor(6, 3, false)
template:addDoor(9, 2, true)
template:addDoor(10,4, true)

template = ShipTemplate():setName("Maverick"):setLocaleName(_("Maverick")):setClass(_("Corvette"),_("Gunner")):setModel("LaserCorvetteGreen"):setType("playership")
template:setDescription(_("A number of beams bristle from various points on this gunner. Missiles were deemed lower priority, though they are still present. Stronger defenses than a frigate, but not as strong as the Atlantis"))
template:setRadarTrace("radar_laser.png")
template:setHull(160)
template:setShields(160,160)
template:setSpeed(80,15,40)
template:setCombatManeuver(400, 250)
template:setJumpDrive(false)
template:setWarpSpeed(800)
--                 Arc, Dir,  Range, CycleTime, Dmg
template:setBeam(0, 10,   0, 2000.0, 6.0, 6)
template:setBeam(1, 90, -20, 1500.0, 6.0, 8)
template:setBeam(2, 90,  20, 1500.0, 6.0, 8)
template:setBeam(3, 40, -70, 1000.0, 4.0, 6)
template:setBeam(4, 40,  70, 1000.0, 4.0, 6)
template:setBeam(5, 10, 180,  800.0, 6.0, 4)
--								Arc, Dir, Rotate speed
template:setBeamWeaponTurret(5, 180, 180, .5)
template:setTubes(3, 8.0)
template:setWeaponStorage("HVLI", 10)
template:setWeaponStorage("Homing", 6)
template:setWeaponStorage("EMP", 4)
template:setWeaponStorage("Nuke", 2)
template:setWeaponStorage("Mine", 2)
template:setTubeDirection(0, -90)
template:setTubeDirection(1,  90)
template:setTubeDirection(2, 180)
template:weaponTubeDisallowMissle(0, "Mine")
template:weaponTubeDisallowMissle(1, "Mine")
template:setWeaponTubeExclusiveFor(2, "Mine")

template:setRepairCrewCount(4)

template:addRoomSystem(2, 0, 2, 1, "Maneuver");
template:addRoomSystem(1, 1, 2, 1, "BeamWeapons");
template:addRoomSystem(0, 2, 3, 2, "RearShield");
template:addRoomSystem(1, 4, 2, 1, "Reactor");
template:addRoomSystem(2, 5, 2, 1, "Warp");
template:addRoomSystem(3, 1, 3, 2, "JumpDrive");
template:addRoomSystem(3, 3, 3, 2, "FrontShield");
template:addRoom(6, 2, 6, 2);
template:addRoomSystem(9, 1, 2, 1, "MissileSystem");
template:addRoomSystem(9, 4, 2, 1, "Impulse");

template:addDoor(2, 1, true)
template:addDoor(1, 2, true)
template:addDoor(1, 4, true)
template:addDoor(2, 5, true)
template:addDoor(3, 2, false)
template:addDoor(4, 3, true)
template:addDoor(6, 3, false)
template:addDoor(9, 2, true)
template:addDoor(10,4, true)



--[[-----------------------Support-----------------------]]

-- Defense Platform moved to Stations

--[[----------------------Freighters----------------------]]

for cnt=1,5 do
    template = ShipTemplate():setName("Personnel Freighter " .. cnt):setLocaleName(string.format(_("Personnel Freighter %d"), cnt)):setClass(_("Corvette"), _("Freighter")):setModel("transport_1_" .. cnt)
    template:setDescription(_([[These freighters are designed to transport armed troops, military support personnel, and combat gear.]]))
    template:setHull(100)
    template:setShields(50, 50)
    template:setSpeed(60 - 5 * cnt, 6, 10)
    template:setRadarTrace("radar_transport.png")
    
    if cnt > 2 then
        variation = template:copy("Personnel Jump Freighter " .. cnt):setLocaleName(string.format(_("Personnel Jump Freighter %d"), cnt))
        variation:setJumpDrive(true)
    end

    template = ShipTemplate():setName("Goods Freighter " .. cnt):setLocaleName(string.format(_("Goods Freighter %d"), cnt)):setClass(_("Corvette"), _("Freighter")):setModel("transport_2_" .. cnt)
    template:setDescription(_([[Cargo freighters haul large loads of cargo across long distances on impulse power. Their cargo bays include climate control and stabilization systems that keep the cargo in good condition.]]))
    template:setHull(100)
    template:setShields(50, 50)
    template:setSpeed(60 - 5 * cnt, 6, 10)
    template:setRadarTrace("radar_transport.png")
    
    if cnt > 2 then
        variation = template:copy("Goods Jump Freighter " .. cnt):setLocaleName(string.format(_("Goods Jump Freighter %d"), cnt))
        variation:setJumpDrive(true)
    end
    
    template = ShipTemplate():setName("Garbage Freighter " .. cnt):setLocaleName(string.format(_("Garbage Freighter %d"), cnt)):setClass(_("Corvette"), _("Freighter")):setModel("transport_3_" .. cnt)
    template:setDescription(_([[These freighters are specially designed to haul garbage and waste. They are fitted with a trash compactor and fewer stabilzation systems than cargo freighters.]]))
    template:setHull(100)
    template:setShields(50, 50)
    template:setSpeed(60 - 5 * cnt, 6, 10)
    template:setRadarTrace("radar_transport.png")
    
    if cnt > 2 then
        variation = template:copy("Garbage Jump Freighter " .. cnt):setLocaleName(string.format(_("Garbage Jump Freighter %d"), cnt))
        variation:setJumpDrive(true)
    end

    template = ShipTemplate():setName("Equipment Freighter " .. cnt):setLocaleName(string.format(_("Equipment Freighter %d"), cnt)):setClass(_("Corvette"), _("Freighter")):setModel("transport_4_" .. cnt)
    template:setDescription(_([[Equipment freighters have specialized environmental and stabilization systems to safely carry delicate machinery and complex instruments.]]))
    template:setHull(100)
    template:setShields(50, 50)
    template:setSpeed(60 - 5 * cnt, 6, 10)
    template:setRadarTrace("radar_transport.png")
    
    if cnt > 2 then
        variation = template:copy("Equipment Jump Freighter " .. cnt):setLocaleName(string.format(_("Equipment Jump Freighter %d"), cnt))
        variation:setJumpDrive(true)
    end

    template = ShipTemplate():setName("Fuel Freighter " .. cnt):setLocaleName(string.format(_("Fuel Freighter %d"), cnt)):setClass(_("Corvette"), _("Freighter")):setModel("transport_5_" .. cnt)
    template:setDescription(_([[Fuel freighters have massive tanks for hauling fuel, and delicate internal sensors that watch for any changes to their cargo's potentially volatile state.]]))
    template:setHull(100)
    template:setShields(50, 50)
    template:setSpeed(60 - 5 * cnt, 6, 10)
    template:setRadarTrace("radar_transport.png")
    
    if cnt > 2 then
        variation = template:copy("Fuel Jump Freighter " .. cnt):setLocaleName(string.format(_("Fuel Jump Freighter %d"), cnt))
        variation:setJumpDrive(true)
    end
end

template = ShipTemplate():setName("Jump Carrier"):setLocaleName(_("Jump Carrier")):setClass(_("Corvette"), _("Freighter")):setModel("transport_4_2")
template:setDescription(_([[The Jump Carrier is a specialized Freighter. It does not carry any cargo, as it's cargo bay is taken up by a specialized jump drive and the energy storage required to run this jump drive.
It is designed to carry other ships deep into space. So it has special docking parameters, allowing other ships to attach themselves to this ship.]]))
template:setHull(100)
template:setShields(50, 50)
template:setSpeed(50, 6, 10)
template:setRadarTrace("radar_transport.png")
template:setJumpDrive(true)
template:setJumpDriveRange(5000, 100 * 50000) -- The jump carrier can jump a 100x longer distance then normal jump drives.
template:setDockClasses("Starfighter", "Frigate", "Corvette")


variation = template:copy("Benedict"):setLocaleName(_("Benedict")):setType("playership"):setClass(_("Corvette"), _("Freighter/Carrier"))
variation:setDescription(_("Benedict is an improved version of the Jump Carrier"))
variation:setShields(70, 70)
variation:setHull(200)
variation:setSpeed(60, 6, 8)
--                  Arc, Dir, Range, CycleTime, Dmg
variation:setBeam(0, 10,   0, 1500.0, 6.0, 4)
variation:setBeam(1, 10, 180, 1500.0, 6.0, 4)
--                       Arc, Dir, Rotate speed
variation:setBeamWeaponTurret( 0, 90,   0, 6)
variation:setBeamWeaponTurret( 1, 90, 180, 6)
variation:setCombatManeuver(400, 250)
variation:setJumpDriveRange(5000, 90000) 

variation:setRepairCrewCount(6)
variation:addRoomSystem(3,0,2,3, "Reactor")
variation:addRoomSystem(3,3,2,3, "Warp")
variation:addRoomSystem(6,0,2,3, "JumpDrive")
variation:addRoomSystem(6,3,2,3, "MissileSystem")
variation:addRoomSystem(5,2,1,2, "Maneuver")
variation:addRoomSystem(2,2,1,2, "RearShield")
variation:addRoomSystem(0,1,2,4, "Beamweapons")
variation:addRoomSystem(8,2,1,2, "FrontShield")
variation:addRoomSystem(9,1,2,4, "Impulse")

variation:addDoor(3, 3, true)
variation:addDoor(6, 3, true)
variation:addDoor(5, 2, false)
variation:addDoor(6, 3, false)
variation:addDoor(3, 2, false)
variation:addDoor(2, 3, false)
variation:addDoor(8, 2, false)
variation:addDoor(9, 3, false)

var2 = variation:copy("Kiriya"):setLocaleName(_("Kiriya"))
var2:setDescription(_("Kiriya is an improved warp drive version of the Jump Carrier"))
--          Arc, Dir, Range, CycleTime, Dmg
var2:setBeam(0, 10,   0, 1500.0, 6.0, 4)
var2:setBeam(1, 10, 180, 1500.0, 6.0, 4)
--                      Arc, Dir, Rotate speed
var2:setBeamWeaponTurret( 0, 90,   0, 6)
var2:setBeamWeaponTurret( 1, 90, 180, 6)
var2:setJumpDrive(false)
var2:setWarpSpeed(750)
