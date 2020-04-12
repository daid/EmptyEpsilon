--[[                  OLD ship templates
These are older ship templates, going to be replaced soon.
----------------------------------------------------------]]

--[[ Player ships --]]
template = ShipTemplate():setName("Player Cruiser"):setLocaleName(_("Player Fighter")):setModel("battleship_destroyer_5_upgraded"):setType("playership")
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

template = ShipTemplate():setName("Player Missile Cr."):setLocaleName(_("Player Missile Cr.")):setModel("space_cruiser_4"):setType("playership")
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

template = ShipTemplate():setName("Player Fighter"):setLocaleName(_("Player Fighter")):setModel("small_fighter_1"):setType("playership")
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
template = ShipTemplate():setName("Tug"):setLocaleName(_("Tug")):setModel("space_tug")
template:setRadarTrace("radar_tug.png")
template:setHull(50)
template:setShields(20)
template:setSpeed(100, 10, 15)
template:setWeaponStorage("Homing", 5)
template:setWeaponStorage("Nuke", 1)
template:setWeaponStorage("Mine", 3)
template:setWeaponStorage("EMP", 2)
template:setDescription(_([[The tugboat is a reliable, but small and un-armed transport ship. Due to it's low cost, it is a favourite ship to teach the ropes to fledgeling captains, without risking friendly fire.]]))

--List of possible fighters --
-- Intercepter (anti fighter) -> High speed, low visibility, front beam weapons
-- Bomber (anti capital) -> Low speed, high visibility, high armor (for a fighter), high shields (for a fighter), multiple missiles
	-- Bomber mine

-- Mine ship -- 
variation = template:copy("Nautilus"):setLocaleName(_("Nautilus")):setType("playership"):setClass("Frigate","Mine Layer")
variation:setDescription(_("Small mine laying vessel with minimal armament, shields and hull"))
variation:setShields(60,60)
variation:setHull(100)
--                  Arc, Dir, Range, CycleTime, Dmg
variation:setBeam(0, 10,  35, 1000.0, 6.0, 6)
variation:setBeam(1, 10, -35, 1000.0, 6.0, 6)
--								Arc, Dir, Rotate speed
variation:setBeamWeaponTurret(0, 90,  35, 6)
variation:setBeamWeaponTurret(1, 90, -35, 6)
variation:setJumpDrive(true)
template:setEnergyStorage(800)
variation:setCombatManeuver(250,150)
variation:setTubes(3, 10.0)
variation:setTubeDirection(0, 180)
variation:setTubeDirection(1, 180)
variation:setTubeDirection(2, 180)
variation:setWeaponStorage("Mine", 12)
variation:setWeaponStorage("Homing", 0)
variation:setWeaponStorage("Nuke", 0)
variation:setWeaponStorage("EMP", 0)

variation:setRepairCrewCount(4)
--	(H)oriz, (V)ert	   HC,VC,HS,VS, system    (C)oordinate (S)ize
variation:addRoomSystem( 0, 1, 1, 2, "Impulse")
variation:addRoomSystem( 1, 0, 2, 1, "RearShield")
variation:addRoomSystem( 1, 1, 2, 2, "JumpDrive")
variation:addRoomSystem( 1, 3, 2, 1, "FrontShield")
variation:addRoomSystem( 3, 0, 2, 1, "Beamweapons")
variation:addRoomSystem( 3, 1, 3, 1, "Warp")
variation:addRoomSystem( 3, 2, 3, 1, "Reactor")
variation:addRoomSystem( 3, 3, 2, 1, "MissileSystem")
variation:addRoomSystem( 6, 1, 1, 2, "Maneuver")

-- (H)oriz, (V)ert H, V, true = horizontal
variation:addDoor( 1, 1, false)
variation:addDoor( 2, 1, true)
variation:addDoor( 1, 3, true)
variation:addDoor( 3, 2, false)
variation:addDoor( 4, 3, true)
variation:addDoor( 6, 1, false)
variation:addDoor( 4, 2, true)
variation:addDoor( 4, 1, true)

	
	
--[[ Enemy ship types --]]
-- Fighters are quick agile ships that do not do a lot of damage, but usually come in larger groups. They are easy to take out, but should not be underestimated.
template = ShipTemplate():setName("Fighter"):setLocaleName(_("Fighter")):setModel("small_fighter_1")
template:setRadarTrace("radar_fighter.png")
template:setDescription(_("Fighters are quick agile ships that do not do a lot of damage, but usually come in larger groups. They are easy to take out, but should not be underestimated."))
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
template = ShipTemplate():setName("Karnack"):setLocaleName(_("Karnack")):setModel("small_frigate_4"):setClass(_("Frigate"), _("Cruiser"))
template:setRadarTrace("radar_cruiser.png")
template:setDescription(_("Fabricated by: Repulse shipyards. Due to it's versatility, this ship has found wide adoptation in most factions. Most factions have extensively retrofitted these ships to suit their combat doctrines. Because it's an older model, most factions have been selling stripped versions. This practice has led to this ship becomming an all time favourite with smugglers and other civillian parties. However, they have used it's adaptable nature to re-fit them with (illegal) weaponry."))
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 60, -15, 1000.0, 6.0, 6)
template:setBeam(1, 60,  15, 1000.0, 6.0, 6)
template:setHull(60)
template:setShields(40, 40)
template:setSpeed(60, 6, 10)

-- Karnack Cruiser mark II
	-- Fabricated by: Repulse shipyards
	-- The sucessor to the widly sucesfull mark I Karnack cruiser. This ship has several notable improvements over the original ship, including better armor, slightly improved weaponry and customization by the shipyards. The latter improvement was the most requested feature by several factions once they realized that their old surplus mark I ships were used for less savoury purposes.

variation = template:copy("Cruiser"):setLocaleName(_("ship", "Karnack MK2"))
variation:setDescription(_("Fabricated by: Repulse shipyards. The sucessor to the widly sucesfull mark I Karnack cruiser. This ship has several notable improvements over the original ship, including better armor, slightly improved weaponry and customization by the shipyards. The latter improvement was the most requested feature by several factions once they realized that their old surplus mark I ships were used for less savoury purposes."))
--                  Arc, Dir, Range, CycleTime, Dmg
variation:setBeam(0, 90, -15, 1000.0, 6.0, 6)
variation:setBeam(1, 90,  15, 1000.0, 6.0, 6)
variation:setHull(70)

-- Polaris missle cruiser mark I
	-- Fabricated by: Repulse shipyards
	-- TODO
-- The missile cruiser is a long range missile firing platform. It cannot handle a lot of damage, but can do a lot of damage if not dealth with properly.
template = ShipTemplate():setName("Missile Cruiser"):setLocaleName(_("Missile Cruiser")):setModel("space_cruiser_4"):setClass(_("Frigate"), _("Cruiser: Missile"))
template:setRadarTrace("radar_missile_cruiser.png")
template:setDescription(_("Polaris missle cruiser mark I. Fabricated by: Repulse shipyards. This missile cruiser is a long range missile firing platform. It cannot handle a lot of damage, but can do a lot of damage if not dealt with properly."))
--                  Arc, Dir, Range, CycleTime, Dmg
template:setTubes(1, 25.0)
template:setHull(40)
template:setShields(50, 50)
template:setSpeed(45, 3, 10)
template:setWeaponStorage("Homing", 10)

-- The gunship is a ship equiped with a homing missile tube to do initial damage and then take out the enemy with 2 front firing beams. It's designed to quickly take out the enemies weaker then itself.
template = ShipTemplate():setName("Gunship"):setLocaleName(_("Gunship")):setModel("battleship_destroyer_4_upgraded"):setClass(_("Frigate"),_("subclass","Gunship"))
template:setRadarTrace("radar_adv_gunship.png")
template:setDescription(_("The gunship is a ship equiped with a homing missile tube to do initial damage and then take out the enemy with 2 front firing beams. It's designed to quickly take out the enemies weaker then itself."))
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 50,-15, 1000.0, 6.0, 8)
template:setBeam(1, 50, 15, 1000.0, 6.0, 8)
template:setTubes(1, 8.0) -- Amount of torpedo tubes
template:setHull(100)
template:setShields(100, 80, 80)
template:setSpeed(60, 5, 10)
template:setWeaponStorage("Homing", 4)

-- The advanced gunship is a ship equiped with 2 homing missiles to do initial damage and then take out the enemy with 2 front firing beams. It's designed to quickly take out the enemies weaker then itself.
variation = template:copy("Adv. Gunship"):setLocaleName(_("Adv. Gunship"))
variation:setDescription(_("The advanced gunship is a ship equiped with 2 homing missiles to do initial damage and then take out the enemy with 2 front firing beams. It's designed to quickly take out the enemies weaker then itself."))
variation:setTubes(2, 8.0) -- Amount of torpedo tubes

-- The Strikeship is a warp-drive equiped figher build for quick strikes, it's fast, it's agile, but does not do an extreme amount of damage, and lacks in rear shields.
template = ShipTemplate():setName("Strikeship"):setLocaleName(_("Strikeship")):setModel("small_frigate_3"):setClass(_("Starfighter"),_("subclass","Strike"))
template:setRadarTrace("radar_striker.png")
template:setDescription("The Strikeship is a warp-drive equipped figher build for quick strikes, it's fast, it's agile, but does not do an extreme amount of damage, and lacks in rear shields.")
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 40,-5, 1000.0, 6.0, 6)
template:setBeam(1, 40, 5, 1000.0, 6.0, 6)
template:setHull(100)
template:setShields(80, 30, 30, 30)
template:setSpeed(70, 12, 12)
template:setWarpSpeed(1000)

-- The Advanced Striker is a jump-drive equipped fighter build for quick strikes, it's slow but very agile, but does not do an extreme amount of damage, and lacks in shields. However, due to the jump drive, it's quick to get into the action.
template = ShipTemplate():setName("Adv. Striker"):setLocaleName(_("Adv. Striker")):setClass(_("Starfighter"),_("subclass", "Patrol")):setModel("dark_fighter_6")
template:setRadarTrace("radar_adv_striker.png")
template:setDescription(_("The Advanced Striker is a jump-drive equipped fighter build for quick strikes, it's slow but very agile, but does not do an extreme amount of damage, and lacks in shields. However, due to the jump drive, it's quick to get into the action."))
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 50,-15, 1000.0, 6.0, 6)
template:setBeam(1, 50, 15, 1000.0, 6.0, 6)
template:setHull(70)
template:setShields(50, 30)
template:setSpeed(45, 12, 15)
template:setJumpDrive(true)

variation = template:copy("Striker"):setLocaleName(_("Striker")):setType("playership")
variation:setDescription(_("The Striker is the predecessor to the advanced striker, slow but agile, but does not do an extreme amount of damage, and lacks in shields"))
variation:setBeam(0, 10,-15, 1000.0, 6.0, 6)
variation:setBeam(1, 10, 15, 1000.0, 6.0, 6)
--								  Arc, Dir, Rotate speed
variation:setBeamWeaponTurret( 0, 100, -15, 6)
variation:setBeamWeaponTurret( 1, 100,  15, 6)
variation:setHull(120)
variation:setSpeed(45, 15, 30)
variation:setJumpDrive(false)
variation:setCombatManeuver(250, 150)
variation:setEnergyStorage(500)

variation:setRepairCrewCount(2)

variation:addRoomSystem(4,0,3,1,"RearShield")
variation:addRoomSystem(3,1,3,1,"MissileSystem")
variation:addRoomSystem(0,1,1,1,"Beamweapons")
variation:addRoomSystem(1,1,1,3,"Reactor")
variation:addRoomSystem(2,2,3,1,"Warp")
variation:addRoomSystem(5,2,4,1,"JumpDrive")
variation:addRoomSystem(0,3,1,1,"Impulse")
variation:addRoomSystem(3,3,3,1,"Maneuver")
variation:addRoomSystem(4,4,3,1,"FrontShield")

variation:addDoor(1,1,false)
variation:addDoor(1,3,false)
variation:addDoor(2,2,false)
variation:addDoor(5,2,false)
variation:addDoor(4,3,true)
variation:addDoor(5,2,true)
variation:addDoor(4,1,true)
variation:addDoor(5,4,true)


-- The Dreadnought is a flying fortress, it's slow, slow to turn, but packs a huge amount of beam weapons in the front. Taking it head-on is suicide.
template = ShipTemplate():setName("Dreadnought"):setLocaleName(_("ship","Dreadnought")):setModel("battleship_destroyer_1_upgraded"):setClass(_("class", "Dreadnought"),_("subclass","Assault"))
template:setRadarTrace("radar_dread.png")
template:setDescription(_("The Dreadnought is a flying fortress, it's slow, slow to turn, but packs a huge amount of beam weapons in the front. Taking it head-on is suicide."))
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
template = ShipTemplate():setName("Battlestation"):setLocaleName(_("Battlestation")):setModel("Ender Battlecruiser"):setClass(_("class", "Dreadnought"),_("Battlecruiser"))
template:setRadarTrace("radar_battleship.png")
template:setDescription(_("The battle station is a huge ship with many defensive features. It can be docked by smaller ships."))
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
template:setDockClasses("Starfighter", "Frigate", "Corvette")
template:setSharesEnergyWithDocked(true)

variation = template:copy("Ender"):setType("playership")
--                  Arc, Dir, Range, CycleTime, Dmg
variation:setBeam(0, 10, -90, 2500.0, 6.1, 4)
variation:setBeam(1, 10, -90, 2500.0, 6.0, 4)
variation:setBeam(2, 10,  90, 2500.0, 5.8, 4)
variation:setBeam(3, 10,  90, 2500.0, 6.3, 4)
variation:setBeam(4, 10, -90, 2500.0, 5.9, 4)
variation:setBeam(5, 10, -90, 2500.0, 6.4, 4)
variation:setBeam(6, 10,  90, 2500.0, 5.7, 4)
variation:setBeam(7, 10,  90, 2500.0, 5.6, 4)
variation:setBeam(8, 10, -90, 2500.0, 6.6, 4)
variation:setBeam(9, 10, -90, 2500.0, 5.5, 4)
variation:setBeam(10, 10,  90, 2500.0, 6.5, 4)
variation:setBeam(11, 10,  90, 2500.0, 6.2, 4)
--								  Arc, Dir, Rotate speed
variation:setBeamWeaponTurret( 0, 120, -90, 6)
variation:setBeamWeaponTurret( 1, 120, -90, 6)
variation:setBeamWeaponTurret( 2, 120,  90, 6)
variation:setBeamWeaponTurret( 3, 120,  90, 6)
variation:setBeamWeaponTurret( 4, 120, -90, 6)
variation:setBeamWeaponTurret( 5, 120, -90, 6)
variation:setBeamWeaponTurret( 6, 120,  90, 6)
variation:setBeamWeaponTurret( 7, 120,  90, 6)
variation:setBeamWeaponTurret( 8, 120, -90, 6)
variation:setBeamWeaponTurret( 9, 120, -90, 6)
variation:setBeamWeaponTurret(10, 120,  90, 6)
variation:setBeamWeaponTurret(11, 120,  90, 6)
variation:setEnergyStorage(1200)
variation:setTubes(2, 8.0) -- Amount of torpedo tubes, loading time
variation:setWeaponStorage("Homing", 6)
variation:setWeaponStorage("Mine", 6)
variation:setTubeDirection(0, 0):setWeaponTubeExclusiveFor(0, "Homing")
variation:setTubeDirection(1, 180):setWeaponTubeExclusiveFor(1, "Mine")
variation:setShields(1200, 1200)
variation:setSpeed(30, 2, 6)
variation:setCombatManeuver(800, 500)

variation:setRepairCrewCount(8)

variation:addRoomSystem(0,1,2,4,"RearShield")
variation:addRoom(3,0,2,1)
variation:addRoomSystem(7,0,2,1,"Maneuver")
variation:addRoomSystem(11,0,2,1,"MissileSystem")
variation:addRoomSystem(2,1,4,2,"Reactor")
variation:addRoomSystem(6,1,4,2,"Warp")
variation:addRoom(10,1,4,2)
variation:addRoomSystem(14,2,2,2,"FrontShield")
variation:addRoomSystem(2,3,4,2,"Impulse")
variation:addRoomSystem(6,3,4,2,"JumpDrive")
variation:addRoom(10,3,4,2)
variation:addRoom(3,5,2,1)
variation:addRoom(7,5,2,1)
variation:addRoomSystem(11,5,2,1,"Beamweapons")

variation:addDoor(3,1,true)
variation:addDoor(7,1,true)
variation:addDoor(11,1,true)
variation:addDoor(2,2,false)
variation:addDoor(6,1,false)
variation:addDoor(10,2,false)
variation:addDoor(14,3,false)
variation:addDoor(10,4,false)
variation:addDoor(6,3,false)
variation:addDoor(8,3,true)
variation:addDoor(4,5,true)
variation:addDoor(8,5,true)
variation:addDoor(12,5,true)

-- The weapons-platform is a stationary platform with beam-weapons. It's extremely slow to turn, but it's beam weapons do a huge amount of damage.
template = ShipTemplate():setName("Weapons platform"):setLocaleName(_("Weapons platform")):setModel("space_cruiser_4")
template:setRadarTrace("radar_missile_cruiser.png")
template:setDescription(_("The weapons-platform is a stationary platform with beam-weapons. It's extremely slow to turn, but it's beam weapons do a huge amount of damage."))
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

-- Blockade runner is a reasonably fast, high shield, slow on weapons ship designed to break through defense lines and deliver goods.
template = ShipTemplate():setName("Blockade Runner"):setLocaleName(_("Blockade Runner")):setModel("battleship_destroyer_3_upgraded"):setClass(_("Frigate"),_("High Punch"))
template:setRadarTrace("radar_blockade.png")
template:setDescription(_("Blockade runner is a reasonably fast, high shield, slow on weapons ship designed to break through defense lines and deliver goods."))
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 60, -15, 1000.0, 6.0, 8)
template:setBeam(1, 60,  15, 1000.0, 6.0, 8)
template:setBeam(2, 25,  170, 1000.0, 6.0, 8)
template:setBeam(3, 25,  190, 1000.0, 6.0, 8)
template:setHull(70)
template:setShields(100, 150)
template:setSpeed(60, 15, 25)

----------------------Ktlitan ships
template = ShipTemplate():setName("Ktlitan Fighter"):setLocaleName(_("Ktlitan Fighter")):setModel("sci_fi_alien_ship_1")
template:setRadarTrace("radar_ktlitan_fighter.png")
template:setBeam(0, 60, 0, 1200.0, 4.0, 6)
template:setHull(70)
template:setSpeed(140, 30, 25)
template:setDefaultAI('fighter')	-- set fighter AI, which dives at the enemy, and then flies off, doing attack runs instead of "hanging in your face".

template = ShipTemplate():setName("Ktlitan Breaker"):setLocaleName(_("Ktlitan Breaker")):setModel("sci_fi_alien_ship_2")
template:setRadarTrace("radar_ktlitan_breaker.png")
template:setBeam(0, 40, 0, 800.0, 4.0, 6)
template:setBeam(1, 35,-15, 800.0, 4.0, 6)
template:setBeam(2, 35, 15, 800.0, 4.0, 6)
template:setTubes(1, 13.0) -- Amount of torpedo tubes, loading time
template:setWeaponStorage("HVLI", 5) --Only give this ship HVLI's
template:setHull(120)
template:setSpeed(100, 5, 25)

template = ShipTemplate():setName("Ktlitan Worker"):setLocaleName(_("Ktlitan Worker")):setModel("sci_fi_alien_ship_3")
template:setRadarTrace("radar_ktlitan_worker.png")
template:setBeam(0, 40, -90, 600.0, 4.0, 6)
template:setBeam(1, 40, 90, 600.0, 4.0, 6)
template:setHull(50)
template:setSpeed(100, 35, 25)

template = ShipTemplate():setName("Ktlitan Drone"):setLocaleName(_("Ktlitan Drone")):setModel("sci_fi_alien_ship_4")
template:setRadarTrace("radar_ktlitan_drone.png")
template:setBeam(0, 40, 0, 600.0, 4.0, 6)
template:setHull(30)
template:setSpeed(120, 10, 25)

template = ShipTemplate():setName("Ktlitan Feeder"):setLocaleName(_("Ktlitan Feeder")):setModel("sci_fi_alien_ship_5")
template:setRadarTrace("radar_ktlitan_feeder.png")
template:setBeam(0, 20, 0, 800.0, 4.0, 6)
template:setBeam(1, 35,-15, 600.0, 4.0, 6)
template:setBeam(2, 35, 15, 600.0, 4.0, 6)
template:setBeam(3, 20,-25, 600.0, 4.0, 6)
template:setBeam(4, 20, 25, 600.0, 4.0, 6)
template:setHull(150)
template:setSpeed(120, 8, 25)

template = ShipTemplate():setName("Ktlitan Scout"):setLocaleName(_("Ktlitan Scout")):setModel("sci_fi_alien_ship_6")
template:setRadarTrace("radar_ktlitan_scout.png")
template:setBeam(0, 40, 0, 600.0, 4.0, 6)
template:setHull(100)
template:setSpeed(150, 30, 25)

template = ShipTemplate():setName("Ktlitan Destroyer"):setLocaleName(_("Ktlitan Destroyer")):setModel("sci_fi_alien_ship_7")
template:setRadarTrace("radar_ktlitan_destroyer.png")
template:setBeam(0, 90, -15, 1000.0, 6.0, 10)
template:setBeam(1, 90,  15, 1000.0, 6.0, 10)
template:setHull(300)
template:setShields(50, 50, 50)
template:setTubes(3, 15.0) -- Amount of torpedo tubes
template:setSpeed(70, 5, 10)
template:setWeaponStorage("Homing", 25)
template:setDefaultAI('missilevolley')

template = ShipTemplate():setName("Ktlitan Queen"):setLocaleName(_("Ktlitan Queen")):setModel("sci_fi_alien_ship_8")
template:setRadarTrace("radar_ktlitan_queen.png")
template:setHull(350)
template:setShields(100, 100, 100)
template:setTubes(2, 15.0) -- Amount of torpedo tubes
template:setWeaponStorage("Nuke", 5)
template:setWeaponStorage("EMP", 5)
template:setWeaponStorage("Homing", 5)

for type=1,5 do
    for cnt=1,5 do
        template = ShipTemplate():setName("Transport" .. type .. "x" .. cnt):setLocaleName(string.format(_("Transport %dx%d"), type, cnt)):setModel("transport_" .. type .. "_" .. cnt)
        template:setHull(100)
        template:setShields(50, 50)
        template:setSpeed(60 - 5 * cnt, 6, 10)
        template:setRadarTrace("radar_transport.png")
    end
end
