--[[----------------------STATIONS--------------------------
Space stations are permanent, stationary installations, from
small outposts to massive starbases. Ships can dock at
stations to recharge energy and restock weapons.
----------------------------------------------------------]]

template = ShipTemplate():setName("Small Station")
    template:setLocaleName(_("Small Station"))
    template:setModel("space_station_4")
    template:setDescription(_([[Stations of this size are often used as research outposts, listening stations, and security checkpoints. Crews turn over frequently in a small station's cramped accommodatations, but they are small enough to look like ships on many long-range sensors, and organized raiders sometimes take advantage of this by placing small stations in nebulae to serve as raiding bases. They are lightly shielded and vulnerable to swarming assaults.]]))
    template:setRadarTrace("radartrace_smallstation.png")
    template:setType("station")

    -- Defenses
    template:setHull(150)
    template:setShields(300)

template = ShipTemplate():setName("Medium Station")
    template:setLocaleName(_("Medium Station"))
    template:setModel("space_station_3")
    template:setDescription(_([[Large enough to accommodate small crews for extended periods of times, stations of this size are often trading posts, refuelling bases, mining operations, and forward military bases. While their shields are strong, concerted attacks by many ships can bring them down quickly.]]))
    template:setRadarTrace("radartrace_mediumstation.png")
    template:setType("station")

    -- Defenses
    template:setHull(400)
    template:setShields(800)

template = ShipTemplate():setName("Large Station")
    template:setLocaleName(_("Large Station"))
    template:setModel("space_station_2")
    template:setDescription(_([[These spaceborne communities often represent permanent bases in a sector. Stations of this size can be military installations, commercial hubs, deep-space settlements, and small shipyards. Only a concentrated attack can penetrate a large station's shields, and its hull can withstand all but the most powerful weaponry.]]))
    template:setRadarTrace("radartrace_largestation.png")
    template:setType("station")

    -- Defenses
    template:setHull(500)
    template:setShields(1000, 1000, 1000)

template = ShipTemplate():setName("Huge Station")
    template:setLocaleName(_("Huge Station"))
    template:setModel("space_station_1")
    template:setDescription(_([[The size of a sprawling town, stations at this scale represent a faction's center of spaceborne power in a region. They serve many functions at once and represent an extensive investment of time, money, and labor. A huge station's shields and thick hull can keep it intact long enough for reinforcements to arrive, even when faced with an ongoing siege or massive, perfectly coordinated assault.]]))
    template:setRadarTrace("radartrace_hugestation.png")
    template:setType("station")

    -- Defenses
    template:setHull(800)
    template:setShields(1200, 1200, 1200, 1200)
