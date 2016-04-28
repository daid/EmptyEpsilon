--[[                  OLD ship templates
These are older ship templates, going to be replaced soon.
----------------------------------------------------------]]

--[[ Player ships --]]
template = ShipTemplate():setName("Player Cruiser"):setModel("battleship_destroyer_5_upgraded"):setType("playership")
template:setRadarTrace("radar_cruiser.png")
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 90, -15, 1000.0, 6.0, 10)
template:setBeam(1, 90,  15, 1000.0, 6.0, 10)
-- Setup 3 missile tubes. 2 forward at a slight angle, and 1 in the rear exclusive for mines.
template:setTubes(3, 8.0) -- Amount of torpedo tubes, and loading time of the tubes.
template:setTubeDirection(0, -5):weaponTubeDisallowMissle(0, "Mine")
template:setTubeDirection(1, 5):weaponTubeDisallowMissle(1, "Mine")
template:setTubeDirection(2, 180):setWeaponTubeExclusiveFor(2, "Mine")
template:setHull(200)
template:setShields(80, 80)
template:setSpeed(90, 10, 20)
template:setWarpSpeed(0)
template:setJumpDrive(true)
template:setCombatManeuver(400, 250)
template:setWeaponStorage("Homing", 12)
template:setWeaponStorage("Nuke", 4)
template:setWeaponStorage("Mine", 8)
template:setWeaponStorage("EMP", 6)

template:addRoomSystem(1, 0, 2, 1, "Maneuver");
template:addRoomSystem(1, 1, 2, 1, "BeamWeapons");
template:addRoom(2, 2, 2, 1);

template:addRoomSystem(0, 3, 1, 2, "RearShield");
template:addRoomSystem(1, 3, 2, 2, "Reactor");
template:addRoomSystem(3, 3, 2, 2, "Warp");
template:addRoomSystem(5, 3, 1, 2, "JumpDrive");
template:addRoom(6, 3, 2, 1);
template:addRoom(6, 4, 2, 1);
template:addRoomSystem(8, 3, 1, 2, "FrontShield");

template:addRoom(2, 5, 2, 1);
template:addRoomSystem(1, 6, 2, 1, "MissileSystem");
template:addRoomSystem(1, 7, 2, 1, "Impulse");

template:addDoor(1, 1, true);
template:addDoor(2, 2, true);
template:addDoor(3, 3, true);
template:addDoor(1, 3, false);
template:addDoor(3, 4, false);
template:addDoor(3, 5, true);
template:addDoor(2, 6, true);
template:addDoor(1, 7, true);
template:addDoor(5, 3, false);
template:addDoor(6, 3, false);
template:addDoor(6, 4, false);
template:addDoor(8, 3, false);
template:addDoor(8, 4, false);
 

--Airlock doors
--template:addDoor(2, 2, false);
--template:addDoor(2, 5, false);

template = ShipTemplate():setName("Player Missile Cr."):setModel("space_cruiser_4"):setType("playership")
template:setRadarTrace("radar_missile_cruiser.png")
--                  Arc, Dir, Range, CycleTime, Dmg
--Setup 7 tubes. 2 forward for any type of missile, and 2 on each side of the ship and 1 in the rear. The side tubes are exclusive for homing missiles. The rear is exclusive for mines.
template:setTubes(7, 8.0)
template:setTubeDirection(0,  0):weaponTubeDisallowMissle(0, "Mine")
template:setTubeDirection(1,  0):weaponTubeDisallowMissle(1, "Mine")
template:setTubeDirection(2, 90):setWeaponTubeExclusiveFor(2, "Homing")
template:setTubeDirection(3, 90):setWeaponTubeExclusiveFor(3, "Homing")
template:setTubeDirection(4,-90):setWeaponTubeExclusiveFor(4, "Homing")
template:setTubeDirection(5,-90):setWeaponTubeExclusiveFor(5, "Homing")
template:setTubeDirection(6,180):setWeaponTubeExclusiveFor(6, "Mine")
template:setHull(200)
template:setShields(110, 70)
template:setSpeed(60, 8, 15)
template:setCombatManeuver(450, 150)
template:setWarpSpeed(800)
template:setJumpDrive(false)
template:setCloaking(false)
template:setWeaponStorage("Homing", 30)
template:setWeaponStorage("Nuke", 8)
template:setWeaponStorage("Mine", 12)
template:setWeaponStorage("EMP", 10)

template:addRoomSystem(1, 0, 2, 1, "Maneuver");
template:addRoomSystem(1, 1, 2, 1, "BeamWeapons");
template:addRoom(2, 2, 2, 1);

template:addRoomSystem(0, 3, 1, 2, "RearShield");
template:addRoomSystem(1, 3, 2, 2, "Reactor");
template:addRoomSystem(3, 3, 2, 2, "Warp");
template:addRoomSystem(5, 3, 1, 2, "JumpDrive");
template:addRoom(6, 3, 2, 1);
template:addRoom(6, 4, 2, 1);
template:addRoomSystem(8, 3, 1, 2, "FrontShield");

template:addRoom(2, 5, 2, 1);
template:addRoomSystem(1, 6, 2, 1, "MissileSystem");
template:addRoomSystem(1, 7, 2, 1, "Impulse");

template:addDoor(1, 1, true);
template:addDoor(2, 2, true);
template:addDoor(3, 3, true);
template:addDoor(1, 3, false);
template:addDoor(3, 4, false);
template:addDoor(3, 5, true);
template:addDoor(2, 6, true);
template:addDoor(1, 7, true);
template:addDoor(5, 3, false);
template:addDoor(6, 3, false);
template:addDoor(6, 4, false);
template:addDoor(8, 3, false);
template:addDoor(8, 4, false);

template = ShipTemplate():setName("Player Fighter"):setModel("small_fighter_1"):setType("playership")
template:setRadarTrace("radar_fighter.png")
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 40, -10, 1000.0, 6.0, 8)
template:setBeam(1, 40,  10, 1000.0, 6.0, 8)
template:setHull(60)
template:setShields(40)
template:setSpeed(110, 20, 40)
template:setCombatManeuver(600, 0)
template:setWarpSpeed(0)
template:setJumpDrive(false)
template:setCloaking(false)
template:setEnergyStorage(400)
template:setTubes(1, 10.0) -- Amount of torpedo tubes, loading time
template:setWeaponStorage("HVLI", 4)

template:addRoomSystem(3, 0, 1, 1, "Maneuver");
template:addRoomSystem(1, 0, 2, 1, "BeamWeapons");

template:addRoomSystem(0, 1, 1, 2, "RearShield");
template:addRoomSystem(1, 1, 2, 2, "Reactor");
template:addRoomSystem(3, 1, 2, 1, "Warp");
template:addRoomSystem(3, 2, 2, 1, "JumpDrive");
template:addRoomSystem(5, 1, 1, 2, "FrontShield");

template:addRoomSystem(1, 3, 2, 1, "MissileSystem");
template:addRoomSystem(3, 3, 1, 1, "Impulse");

template:addDoor(2, 1, true);
template:addDoor(3, 1, true);
template:addDoor(1, 1, false);
template:addDoor(3, 1, false);
template:addDoor(3, 2, false);
template:addDoor(3, 3, true);
template:addDoor(2, 3, true);
template:addDoor(5, 1, false);
template:addDoor(5, 2, false);

--[[ Neutral or special ship types --]]
--Tug, used for transport of small goods (like weapons)
template = ShipTemplate():setName("Tug"):setModel("space_tug")
template:setRadarTrace("radar_tug.png")
template:setHull(50)
template:setShields(20)
template:setSpeed(100, 10, 15)
template:setWeaponStorage("Homing", 5)
template:setWeaponStorage("Nuke", 1)
template:setWeaponStorage("Mine", 3)
template:setWeaponStorage("EMP", 2)
template:setDescription([[The tugboat is a reliable, but small and un-armed transport ship. Due to it's low cost, it is a favourite ship to teach the ropes to fledgeling captains, without risking friendly fire.]])

--List of possible fighters --
-- Intercepter (anti fighter) -> High speed, low visibility, front beam weapons
-- Bomber (anti capital) -> Low speed, high visibility, high armor (for a fighter), high shields (for a fighter), multiple missiles
	-- Bomber mine

-- Mine ship -- 
	-- deploys some mines (the ones that don't explode with a km blast radius) and use long range beam weapons to fight

--[[ Enemy ship types --]]
-- Fighters are quick agile ships that do not do a lot of damage, but usually come in larger groups. They are easy to take out, but should not be underestimated.
template = ShipTemplate():setName("Fighter"):setModel("small_fighter_1")
template:setRadarTrace("radar_fighter.png")
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 60, 0, 1000.0, 4.0, 4)
template:setHull(30)
template:setShields(30)
template:setSpeed(120, 30, 25)
template:setDefaultAI('fighter')	-- set fighter AI, which dives at the enemy, and then flies off, doing attack runs instead of "hanging in your face".

-- The cruiser is an average ship you can encounter, it has average shields, and average beams. It's pretty much average with nothing special.
-- Karnack cruiser mark I
	-- Fabricated by: Repulse shipyards
	-- Due to it's versitility, this ship has found wide adoptation in most factions. Most factions have extensively retrofitted these ships
	-- to suit their combat doctrines. Because it's an older model, most factions have been selling stripped versions. This practice has led to this ship becomming an all time favourite with smugglers and other civillian parties. However, they have used it's adaptable nature to re-fit them with (illigal) weaponry.

-- Karnack Cruiser mark II
	-- Fabricated by: Repulse shipyards
	-- The sucessor to the widly sucesfull mark I cruiser. This ship has several notable improvements over the original ship, including better armor, slightly improved weaponry and customization by the shipyards. The latter improvement was the most requested feature by several factions once they realized that their old surplus mark I ships were used for less savoury purposes.

template = ShipTemplate():setName("Cruiser"):setModel("small_frigate_4")
template:setRadarTrace("radar_cruiser.png")
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 90, -15, 1000.0, 6.0, 6)
template:setBeam(1, 90,  15, 1000.0, 6.0, 6)
template:setHull(70)
template:setShields(40, 40)
template:setSpeed(60, 6, 10)

-- Polaris missle cruiser mark I
	-- Fabricated by: Repulse shipyards
	-- TODO
-- The missile cruiser is a long range missile firing platform. It cannot handle a lot of damage, but can do a lot of damage if not dealth with properly.
template = ShipTemplate():setName("Missile Cruiser"):setModel("space_cruiser_4")
template:setRadarTrace("radar_missile_cruiser.png")
--                  Arc, Dir, Range, CycleTime, Dmg
template:setTubes(1, 25.0)
template:setHull(40)
template:setShields(50, 50)
template:setSpeed(45, 3, 10)
template:setWeaponStorage("Homing", 10)

-- The advanced gunship is a ship equiped with 2 homing missiles to do initial damage and then take out the enemy with 2 front firing beams. It's designed to quickly take out the enemies weaker then itself.
template = ShipTemplate():setName("Adv. Gunship"):setModel("battleship_destroyer_4_upgraded")
template:setRadarTrace("radar_adv_gunship.png")
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 50,-15, 1000.0, 6.0, 8)
template:setBeam(1, 50, 15, 1000.0, 6.0, 8)
template:setTubes(2, 8.0) -- Amount of torpedo tubes
template:setHull(100)
template:setShields(100, 80, 80)
template:setSpeed(60, 5, 10)
template:setWeaponStorage("Homing", 4)

-- The Strikeship is a warp-drive equiped figher build for quick strikes, it's fast, it's aggile, but does not do an extreme amount of damage, and lacks in rear shields.
template = ShipTemplate():setName("Strikeship"):setModel("small_frigate_3")
template:setRadarTrace("radar_striker.png")
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 40,-5, 1000.0, 6.0, 6)
template:setBeam(1, 40, 5, 1000.0, 6.0, 6)
template:setHull(100)
template:setShields(80, 30, 30, 30)
template:setSpeed(70, 12, 12)
template:setWarpSpeed(1000)

-- The Adv. Striker is a jump-drive equiped figher build for quick strikes, it's slow but very aggile, but does not do an extreme amount of damage, and lacks in shields. However, due to the jump driver, it's quick to get into the action.
template = ShipTemplate():setName("Adv. Striker"):setModel("dark_fighter_6")
template:setRadarTrace("radar_adv_striker.png")
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 50,-15, 1000.0, 6.0, 6)
template:setBeam(1, 50, 15, 1000.0, 6.0, 6)
template:setHull(70)
template:setShields(50, 30)
template:setSpeed(45, 12, 15)
template:setJumpDrive(true)

-- The Dreadnough is a flying fortress, it's slow, slow to turn, but packs a huge amount of beam weapons in the front. Taking it head-on is suicide.
template = ShipTemplate():setName("Dreadnought"):setModel("battleship_destroyer_1_upgraded")
template:setRadarTrace("radar_dread.png")
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 90, -25, 1500.0, 6.0, 8)
template:setBeam(1, 90,  25, 1500.0, 6.0, 8)
template:setBeam(2,100, -60, 1000.0, 6.0, 8)
template:setBeam(3,100,  60, 1000.0, 6.0, 8)
template:setBeam(4, 30,   0, 2000.0, 6.0, 8)
template:setBeam(5,100, 180, 1200.0, 6.0, 8)
template:setHull(70)
template:setShields(300, 300, 300, 300, 300)
template:setSpeed(30, 1.5, 5)

-- The battle station is a huge ship with many defensive features. It can be docked by smaller ships.
template = ShipTemplate():setName("Battlestation"):setModel("Ender Battlecruiser")
template:setRadarTrace("radar_battleship.png")
template:setSizeClass(11)
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

-- The weapons-platform is a stationary platform with beam-weapons. It's extremely slow to turn, but it's beam weapons do a huge amount of damage.
template = ShipTemplate():setName("Weapons platform"):setModel("space_cruiser_4")
template:setRadarTrace("radar_missile_cruiser.png")
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 30,   0, 4000.0, 1.5, 20)
template:setBeam(1, 30,  60, 4000.0, 1.5, 20)
template:setBeam(2, 30, 120, 4000.0, 1.5, 20)
template:setBeam(3, 30, 180, 4000.0, 1.5, 20)
template:setBeam(4, 30, 240, 4000.0, 1.5, 20)
template:setBeam(5, 30, 300, 4000.0, 1.5, 20)
template:setHull(70)
template:setShields(120, 120, 120, 120, 120, 120)
template:setSpeed(0, 0.5, 0)

-- Blockade runner is a reasonably fast, high shield, slow on weapons ship designed to break trough defence lines and deliver goods.
template = ShipTemplate():setName("Blockade Runner"):setModel("battleship_destroyer_3_upgraded")
template:setRadarTrace("radar_blockade.png")
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 60, -15, 1000.0, 6.0, 8)
template:setBeam(1, 60,  15, 1000.0, 6.0, 8)
template:setBeam(2, 25,  170, 1000.0, 6.0, 8)
template:setBeam(3, 25,  190, 1000.0, 6.0, 8)
template:setHull(70)
template:setShields(100, 150)
template:setSpeed(60, 15, 25)

----------------------Ktlitan ships
template = ShipTemplate():setName("Ktlitan Fighter"):setModel("sci_fi_alien_ship_1")
template:setRadarTrace("radar_ktlitan_fighter.png")
template:setBeam(0, 60, 0, 1200.0, 4.0, 6)
template:setHull(70)
template:setSpeed(140, 30, 25)
template:setDefaultAI('fighter')	-- set fighter AI, which dives at the enemy, and then flies off, doing attack runs instead of "hanging in your face".

template = ShipTemplate():setName("Ktlitan Breaker"):setModel("sci_fi_alien_ship_2")
template:setRadarTrace("radar_ktlitan_breaker.png")
template:setBeam(0, 40, 0, 800.0, 4.0, 6)
template:setBeam(1, 35,-15, 800.0, 4.0, 6)
template:setBeam(2, 35, 15, 800.0, 4.0, 6)
template:setTubes(1, 13.0) -- Amount of torpedo tubes, loading time
template:setWeaponStorage("HVLI", 5) --Only give this ship HVLI's
template:setHull(120)
template:setSpeed(100, 5, 25)

template = ShipTemplate():setName("Ktlitan Worker"):setModel("sci_fi_alien_ship_3")
template:setRadarTrace("radar_ktlitan_worker.png")
template:setBeam(0, 40, -90, 600.0, 4.0, 6)
template:setBeam(1, 40, 90, 600.0, 4.0, 6)
template:setHull(50)
template:setSpeed(100, 35, 25)

template = ShipTemplate():setName("Ktlitan Drone"):setModel("sci_fi_alien_ship_4")
template:setRadarTrace("radar_ktlitan_drone.png")
template:setBeam(0, 40, 0, 600.0, 4.0, 6)
template:setHull(30)
template:setSpeed(120, 10, 25)

template = ShipTemplate():setName("Ktlitan Feeder"):setModel("sci_fi_alien_ship_5")
template:setRadarTrace("radar_ktlitan_feeder.png")
template:setBeam(0, 20, 0, 800.0, 4.0, 6)
template:setBeam(1, 35,-15, 600.0, 4.0, 6)
template:setBeam(2, 35, 15, 600.0, 4.0, 6)
template:setBeam(3, 20,-25, 600.0, 4.0, 6)
template:setBeam(4, 20, 25, 600.0, 4.0, 6)
template:setHull(150)
template:setSpeed(120, 8, 25)

template = ShipTemplate():setName("Ktlitan Scout"):setModel("sci_fi_alien_ship_6")
template:setRadarTrace("radar_ktlitan_scout.png")
template:setBeam(0, 40, 0, 600.0, 4.0, 6)
template:setHull(100)
template:setSpeed(150, 30, 25)

template = ShipTemplate():setName("Ktlitan Destroyer"):setModel("sci_fi_alien_ship_7")
template:setRadarTrace("radar_ktlitan_destroyer.png")
template:setBeam(0, 90, -15, 1000.0, 6.0, 10)
template:setBeam(1, 90,  15, 1000.0, 6.0, 10)
template:setHull(300)
template:setShields(50, 50, 50)
template:setTubes(3, 15.0) -- Amount of torpedo tubes
template:setSpeed(70, 5, 10)
template:setWeaponStorage("Homing", 25)
template:setDefaultAI('missilevolley')

template = ShipTemplate():setName("Ktlitan Queen"):setModel("sci_fi_alien_ship_8")
template:setRadarTrace("radar_ktlitan_queen.png")
template:setHull(350)
template:setShields(100, 100, 100)
template:setTubes(2, 15.0) -- Amount of torpedo tubes
template:setWeaponStorage("Nuke", 5)
template:setWeaponStorage("EMP", 5)
template:setWeaponStorage("Homing", 5)

for type=1,5 do
    for cnt=1,5 do
        template = ShipTemplate():setName("Transport" .. type .. "x" .. cnt):setModel("transport_" .. type .. "_" .. cnt)
        template:setHull(100)
        template:setShields(50, 50)
        template:setSpeed(60 - 5 * cnt, 6, 10)
        template:setRadarTrace("radar_transport.png")
    end
end
