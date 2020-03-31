--[[                  Stations
These are templates for space stations that use
ShipTemplate and can behave more like ships. They can be
scanned, hacked, armed, and made playable.
----------------------------------------------------------]]

template = ShipTemplate():setName("Station (Small)"):setLocaleName(_("Station (Small)")):setModel("space_station_4"):setClass(_("Station"), _("Outpost"))
template:setPhysics(true, true)
template:setSpeed(0, 0, 0)
template:setSharesEnergyWithDocked(true)
template:setRepairDocked(true)
template:setRestocksScanProbes(true)
template:setDockClasses("Starfighter", "Frigate", "Corvette")
template:setDescription(_([[Stations of this size are often used as research outposts, listening stations, and security checkpoints. Crews turn over frequently in a small station's cramped accommodatations, but they are small enough to look like ships on many long-range sensors, and organized raiders sometimes take advantage of this by placing small stations in nebulae to serve as raiding bases. They are lightly shielded and vulnerable to swarming assaults.]]))
template:setHull(150)
template:setShields(300)
template:setRadarTrace("radartrace_smallstation.png")

variant = template:copy("Station (Medium)"):setLocaleName(_("Station (Medium)")):setModel("space_station_3"):setClass(_("Station"), _("Depot"))
variant:setDescription(_([[Large enough to accommodate small crews for extended periods of times, stations of this size are often trading posts, refuelling bases, mining operations, and forward military bases. While their shields are strong, concerted attacks by many ships can bring them down quickly.]]))
variant:setHull(400)
variant:setShields(800)
variant:setRadarTrace("radartrace_mediumstation.png")

variant = template:copy("Station (Large)"):setLocaleName(_("Station (Large)")):setModel("space_station_2"):setClass(_("Station"), _("Base"))
variant:setDescription(_([[These spaceborne communities often represent permanent bases in a sector. Stations of this size can be military installations, commercial hubs, deep-space settlements, and small shipyards. Only a concentrated attack can penetrate a large station's shields, and its hull can withstand all but the most powerful weaponry.]]))
variant:setHull(500)
variant:setShields(1000, 1000, 1000)
variant:setRadarTrace("radartrace_largestation.png")

variant = template:copy("Station (Huge)"):setLocaleName(_("Station (Huge)")):setModel("space_station_1"):setClass(_("Station"), _("Starbase"))
variant:setDockClasses("Starfighter", "Frigate", "Corvette", "Dreadnaught")
variant:setDescription(_([[The size of a sprawling town, stations at this scale represent a faction's center of spaceborne power in a region. They serve many functions at once and represent an extensive investment of time, money, and labor. A huge station's shields and thick hull can keep it intact long enough for reinforcements to arrive, even when faced with an ongoing siege or massive, perfectly coordinated assault.]]))
variant:setHull(800)
variant:setShields(1200, 1200, 1200, 1200)
variant:setRadarTrace("radartrace_hugestation.png")

variant = template:copy("Listening Post"):setLocaleName(_("Listening Post")):setType("playership")
variant:setDescription(_([[This small and lightly manned station has a specialized deep-space sensor array capable of scanning a 50U radius, as well as a comms relay station and probe launcher. With most of its powoer dedicated to its sensors, it has only a single turreted beam and one light shield generator.]]))
variant:setLongRangeRadarRange(50000.0);

--             ID, Arc, Dir,  Range, CycleTime, Dmg
variant:setBeam(0,  10,   0,  800.0,       3.0,   8)
--                         ID, Arc, Dir, Rot
variant:setBeamWeaponTurret(0, 360,   0, 0.5)

variant:setRepairCrewCount(1)

variant:addRoom(2, 0, 2, 1);
variant:addRoomSystem(1, 1, 2, 1, "BeamWeapons");
variant:addRoom(0, 2, 3, 2);
variant:addRoomSystem(1, 4, 2, 1, "Reactor");
variant:addRoom(2, 5, 2, 1);
variant:addRoom(3, 1, 3, 2);
variant:addRoomSystem(3, 3, 3, 2, "FrontShield");

variant:addDoor(2, 1, true)
variant:addDoor(1, 2, true)
variant:addDoor(1, 4, true)
variant:addDoor(2, 5, true)
variant:addDoor(3, 2, false)
variant:addDoor(4, 3, true)

variant = template:copy("Defense Platform"):setLocaleName(_("Defense Platform"))
variant:setSpeed(0, 0.5, 0)
variant:setDockClasses("Starfighter", "Frigate")
variant:setDescription(_([[This stationary defense platform operates like a station, with docking and resupply functions for smaller ships, but is armed with powerful beam weapons and can slowly rotate. Larger systems often use these platforms to resupply patrol ships.]]))
variant:setShields(120, 120, 120, 120, 120, 120)
--             ID, Arc, Dir,  Range, CycleTime, Dmg
variant:setBeam(0,  30,   0, 4000.0,       1.5, 20)
variant:setBeam(1,  30,  60, 4000.0,       1.5, 20)
variant:setBeam(2,  30, 120, 4000.0,       1.5, 20)
variant:setBeam(3,  30, 180, 4000.0,       1.5, 20)
variant:setBeam(4,  30, 240, 4000.0,       1.5, 20)
variant:setBeam(5,  30, 300, 4000.0,       1.5, 20)

