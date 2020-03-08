require("options.lua")
require(lang .. "/ships.lua")

--[[----------------------Destroyers----------------------]]

template = ShipTemplate():setName(atlantisX23):setClass(corvette, destroyer):setModel("battleship_destroyer_1_upgraded")
template:setDescription(atlantisDescription)
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
template:setWeaponStorage(hvli, 20)
template:setWeaponStorage(homing, 4)
template:setTubeDirection(0, -90)
template:setTubeDirection(1, -90)
template:setTubeDirection(2,  90)
template:setTubeDirection(3,  90)

variation = template:copy(atlantis):setType("playership")
variation:setDescription(atlantisDescription)
variation:setShields(200, 200)
variation:setHull(250)
variation:setSpeed(90, 10, 20)
variation:setCombatManeuver(400, 250)
variation:setBeam(2, 0, 0, 0, 0, 0)
variation:setWeaponStorage(homing, 12)
variation:setWeaponStorage(nuke, 4)
variation:setWeaponStorage(mine, 8)
variation:setWeaponStorage(emp, 6)
variation:setTubes(5, 8.0) -- Amount of torpedo tubes, and loading time of the tubes.
variation:weaponTubeDisallowMissle(0, mine):weaponTubeDisallowMissle(1, mine)
variation:weaponTubeDisallowMissle(2, mine):weaponTubeDisallowMissle(3, mine)
variation:setTubeDirection(4, 180):setWeaponTubeExclusiveFor(4, mine)

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

template = ShipTemplate():setName(starhammerII):setClass(corvette, destroyer):setModel("battleship_destroyer_4_upgraded")
template:setDescription(starhammerIIDescription)
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
template:setWeaponStorage(hvli, 20)
template:setWeaponStorage(homing, 4)
template:setWeaponStorage(emp, 2)
template:weaponTubeDisallowMissle(1, emp)

template = ShipTemplate():setName(crucible):setClass(corvette,popper):setModel("LaserCorvetteRed"):setType("playership")
template:setDescription(crucibleDescription)
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
template:setWeaponStorage(hvli, 24)
template:setWeaponStorage(homing, 8)
template:setWeaponStorage(emp, 6)
template:setWeaponStorage(nuke, 4)
template:setWeaponStorage(mine, 6)
template:setTubeDirection(0, 0)
template:setTubeSize(0, small)
template:setTubeDirection(1, 0)
template:setTubeDirection(2, 0)
template:setTubeSize(2, large)
template:setTubeDirection(3, -90)
template:setTubeDirection(4,  90)
template:setTubeDirection(5, 180)
template:setWeaponTubeExclusiveFor(0, hvli)
template:setWeaponTubeExclusiveFor(1, hvli)
template:setWeaponTubeExclusiveFor(2, hvli)
template:weaponTubeDisallowMissle(3, mine)
template:weaponTubeDisallowMissle(4, mine)
template:setWeaponTubeExclusiveFor(5, mine)

template:setRepairCrewCount(4)

template:addRoomSystem(2, 0, 2, 1, maneuver);
template:addRoomSystem(1, 1, 2, 1, beamWeapons);
template:addRoomSystem(0, 2, 3, 2, rearShield);
template:addRoomSystem(1, 4, 2, 1, reactor);
template:addRoomSystem(2, 5, 2, 1, warp);
template:addRoomSystem(3, 1, 3, 2, jumpDrive);
template:addRoomSystem(3, 3, 3, 2, frontShield);
template:addRoom(6, 2, 6, 2);
template:addRoomSystem(9, 1, 2, 1, missileSystem);
template:addRoomSystem(9, 4, 2, 1, impulse);

template:addDoor(2, 1, true)
template:addDoor(1, 2, true)
template:addDoor(1, 4, true)
template:addDoor(2, 5, true)
template:addDoor(3, 2, false)
template:addDoor(4, 3, true)
template:addDoor(6, 3, false)
template:addDoor(9, 2, true)
template:addDoor(10,4, true)

template = ShipTemplate():setName(maverick):setClass(corvette,gunner):setModel("LaserCorvetteGreen"):setType("playership")
template:setDescription(maverickDescription)
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
template:setWeaponStorage(hvli, 10)
template:setWeaponStorage(homing, 6)
template:setWeaponStorage(emp, 4)
template:setWeaponStorage(nuke, 2)
template:setWeaponStorage(mine, 2)
template:setTubeDirection(0, -90)
template:setTubeDirection(1,  90)
template:setTubeDirection(2, 180)
template:weaponTubeDisallowMissle(0, mine)
template:weaponTubeDisallowMissle(1, mine)
template:setWeaponTubeExclusiveFor(2, mine)

template:setRepairCrewCount(4)

template:addRoomSystem(2, 0, 2, 1, maneuver);
template:addRoomSystem(1, 1, 2, 1, beamWeapons);
template:addRoomSystem(0, 2, 3, 2, rearShield);
template:addRoomSystem(1, 4, 2, 1, reactor);
template:addRoomSystem(2, 5, 2, 1, warp);
template:addRoomSystem(3, 1, 3, 2, jumpDrive);
template:addRoomSystem(3, 3, 3, 2, frontShield);
template:addRoom(6, 2, 6, 2);
template:addRoomSystem(9, 1, 2, 1, missileSystem);
template:addRoomSystem(9, 4, 2, 1, impulse);

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

-- The weapons-platform is a stationary platform with beam-weapons. It's extremely slow to turn, but it's beam weapons do a huge amount of damage.
-- Smaller ships can dock to this platform to re-supply.
template = ShipTemplate():setName(defensePlateform):setClass(corvette, support):setModel("space_station_4")
template:setDescription(defensePlateformDescription)
template:setRadarTrace("radartrace_smallstation.png")
template:setHull(150)
template:setShields(120, 120, 120, 120, 120, 120)
template:setSpeed(0, 0.5, 0)
template:setDockClasses("Starfighter", frigate)
--               Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 30,   0, 4000.0, 1.5, 20)
template:setBeam(1, 30,  60, 4000.0, 1.5, 20)
template:setBeam(2, 30, 120, 4000.0, 1.5, 20)
template:setBeam(3, 30, 180, 4000.0, 1.5, 20)
template:setBeam(4, 30, 240, 4000.0, 1.5, 20)
template:setBeam(5, 30, 300, 4000.0, 1.5, 20)

--[[----------------------Freighters----------------------]]

for cnt=1,5 do
    template = ShipTemplate():setName(personnelFreighter .. " " .. cnt):setClass(corvette, freighter):setModel("transport_1_" .. cnt)
    template:setDescription(personnelFreighterDescription)
    template:setHull(100)
    template:setShields(50, 50)
    template:setSpeed(60 - 5 * cnt, 6, 10)
    template:setRadarTrace("radar_transport.png")
    
    if cnt > 2 then
        variation = template:copy(personnelJumpFreighter .. " " .. cnt)
        variation:setJumpDrive(true)
    end

    template = ShipTemplate():setName(goodsFreighter .. " " .. cnt):setClass(corvette, freighter):setModel("transport_2_" .. cnt)
    template:setDescription(goodsFreighterDescription)
    template:setHull(100)
    template:setShields(50, 50)
    template:setSpeed(60 - 5 * cnt, 6, 10)
    template:setRadarTrace("radar_transport.png")
    
    if cnt > 2 then
        variation = template:copy(goodsJumpFreighter .. " " .. cnt)
        variation:setJumpDrive(true)
    end
    
    template = ShipTemplate():setName(garbageFreighter .. " " .. cnt):setClass(corvette, freighter):setModel("transport_3_" .. cnt)
    template:setDescription(garbageFreighterDescription)
    template:setHull(100)
    template:setShields(50, 50)
    template:setSpeed(60 - 5 * cnt, 6, 10)
    template:setRadarTrace("radar_transport.png")
    
    if cnt > 2 then
        variation = template:copy(garbageJumpFreighter .. " " .. cnt)
        variation:setJumpDrive(true)
    end

    template = ShipTemplate():setName(equipmentFreighter .. " " .. cnt):setClass(corvette, freighter):setModel("transport_4_" .. cnt)
    template:setDescription(equipmentFreighterDescription)
    template:setHull(100)
    template:setShields(50, 50)
    template:setSpeed(60 - 5 * cnt, 6, 10)
    template:setRadarTrace("radar_transport.png")
    
    if cnt > 2 then
        variation = template:copy(equipmentJumpFreighter .. " " .. cnt)
        variation:setJumpDrive(true)
    end

    template = ShipTemplate():setName(fuelFreighter .. " " .. cnt):setClass(corvette, freighter):setModel("transport_5_" .. cnt)
    template:setDescription(fuelFreighterDescription)
    template:setHull(100)
    template:setShields(50, 50)
    template:setSpeed(60 - 5 * cnt, 6, 10)
    template:setRadarTrace("radar_transport.png")
    
    if cnt > 2 then
        variation = template:copy(fuelJumpFreighter .. " " .. cnt)
        variation:setJumpDrive(true)
    end
end

template = ShipTemplate():setName(jumpCarrier):setClass(corvette, freighter .. "/" .. carrier):setModel("transport_4_2")
template:setDescription(jumpCarrierDescription)
template:setHull(100)
template:setShields(50, 50)
template:setSpeed(50, 6, 10)
template:setRadarTrace("radar_transport.png")
template:setJumpDrive(true)
template:setJumpDriveRange(5000, 100 * 50000) -- The jump carrier can jump a 100x longer distance then normal jump drives.
template:setDockClasses(starfighter, frigate, corvette)


variation = template:copy(benedict):setType("playership"):setClass(corvette, freighter .. "/" .. carrier)
variation:setDescription(benedictDescription)
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
variation:addRoomSystem(3,0,2,3, reactor)
variation:addRoomSystem(3,3,2,3, warp)
variation:addRoomSystem(6,0,2,3, jumpDrive)
variation:addRoomSystem(6,3,2,3, missileSystem)
variation:addRoomSystem(5,2,1,2, maneuver)
variation:addRoomSystem(2,2,1,2, rearShield)
variation:addRoomSystem(0,1,2,4, beamWeapons)
variation:addRoomSystem(8,2,1,2, frontShield)
variation:addRoomSystem(9,1,2,4, impulse)

variation:addDoor(3, 3, true)
variation:addDoor(6, 3, true)
variation:addDoor(5, 2, false)
variation:addDoor(6, 3, false)
variation:addDoor(3, 2, false)
variation:addDoor(2, 3, false)
variation:addDoor(8, 2, false)
variation:addDoor(9, 3, false)

var2 = variation:copy(kiriya)
var2:setDescription(kiriyaDescription)
--          Arc, Dir, Range, CycleTime, Dmg
var2:setBeam(0, 10,   0, 1500.0, 6.0, 4)
var2:setBeam(1, 10, 180, 1500.0, 6.0, 4)
--                      Arc, Dir, Rotate speed
var2:setBeamWeaponTurret( 0, 90,   0, 6)
var2:setBeamWeaponTurret( 1, 90, 180, 6)
var2:setJumpDrive(false)
var2:setWarpSpeed(750)
