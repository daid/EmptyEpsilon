--[[                  Stations
These are templates for space stations.
----------------------------------------------------------]]

template = ShipTemplate():setName("Small Station"):setModel("space_station_4"):setType("station")
template:setHull(150)
template:setShields(300)
template:setRadarTrace("radartrace_smallstation.png")

template = ShipTemplate():setName("Medium Station"):setModel("space_station_3"):setType("station")
template:setType("station")
template:setHull(400)
template:setShields(800)
template:setRadarTrace("radartrace_mediumstation.png")

template = ShipTemplate():setName("Large Station"):setModel("space_station_2"):setType("station")
template:setHull(500)
template:setShields(1000, 1000, 1000)
template:setRadarTrace("radartrace_largestation.png")

template = ShipTemplate():setName("Huge Station"):setModel("space_station_1"):setType("station")
template:setHull(800)
template:setShields(1200, 1200, 1200, 1200)
template:setRadarTrace("radartrace_hugestation.png")
