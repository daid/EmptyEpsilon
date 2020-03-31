--[[                  Stations
These are templates for space stations.
----------------------------------------------------------]]

template = ShipTemplate():setName("Small Station"):setModel("space_station_4"):setType("station")
template:setDescription([[Stations of this size are often used as research outposts, listening stations, and security checkpoints. Crews turn over frequently in a small station's cramped accommodatations, but they are small enough to look like ships on many long-range sensors, and organized raiders sometimes take advantage of this by placing small stations in nebulae to serve as raiding bases. They are lightly shielded and vulnerable to swarming assaults.]])
template:setSpeed(0, 0, 0)
template:setHull(150)
template:setShields(300)
template:setRadarTrace("radartrace_smallstation.png")

template = ShipTemplate():setName("Medium Station"):setModel("space_station_3"):setType("station")
template:setDescription([[Large enough to accommodate small crews for extended periods of times, stations of this size are often trading posts, refuelling bases, mining operations, and forward military bases. While their shields are strong, concerted attacks by many ships can bring them down quickly.]])

variant = template:copy("Defense platform"):setLocaleName(_("Defense platform")):setModel("space_station_4"):setType("station")
variant:setDescription(_([[This stationary defense platform operates like a station, with docking and resupply functions, but is armed with powerful beam weapons and can slowly rotate. Larger systems often use these platforms to resupply patrol ships.]]))
variant:setSpeed(0, 0.5, 0)
variant:setHull(150)
variant:setShields(120, 120, 120, 120, 120, 120)
variant:setDockClasses("Starfighter", "Frigate")
--              ID, Arc, Dir,  Range, CycleTime, Dmg
variant:setBeam(0,  30,   0, 4000.0,       1.5,  20)
variant:setBeam(1,  30,  60, 4000.0,       1.5,  20)
variant:setBeam(2,  30, 120, 4000.0,       1.5,  20)
variant:setBeam(3,  30, 180, 4000.0,       1.5,  20)
variant:setBeam(4,  30, 240, 4000.0,       1.5,  20)
variant:setBeam(5,  30, 300, 4000.0,       1.5,  20)

template = ShipTemplate():setName("Medium Station"):setLocaleName(_("Medium Station")):setModel("space_station_3"):setType("station")
template:setDescription(_([[Large enough to accommodate small crews for extended periods of times, stations of this size are often trading posts, refuelling bases, mining operations, and forward military bases. While their shields are strong, concerted attacks by many ships can bring them down quickly.]]))
template:setSpeed(0, 0, 0)
template:setHull(400)
template:setShields(800)
template:setRadarTrace("radartrace_mediumstation.png")

template = ShipTemplate():setName("Large Station"):setModel("space_station_2"):setType("station")
template:setDescription([[These spaceborne communities often represent permanent bases in a sector. Stations of this size can be military installations, commercial hubs, deep-space settlements, and small shipyards. Only a concentrated attack can penetrate a large station's shields, and its hull can withstand all but the most powerful weaponry.]])
template:setSpeed(0, 0, 0)
template:setHull(500)
template:setShields(1000, 1000, 1000)
template:setRadarTrace("radartrace_largestation.png")

template = ShipTemplate():setName("Huge Station"):setModel("space_station_1"):setType("station")
template:setDescription([[The size of a sprawling town, stations at this scale represent a faction's center of spaceborne power in a region. They serve many functions at once and represent an extensive investment of time, money, and labor. A huge station's shields and thick hull can keep it intact long enough for reinforcements to arrive, even when faced with an ongoing siege or massive, perfectly coordinated assault.]])
template:setSpeed(0, 0, 0)
template:setHull(800)
template:setShields(1200, 1200, 1200, 1200)
template:setRadarTrace("radartrace_hugestation.png")
