require("options.lua")
require(lang .. "/ships.lua")
require(lang .. "/factions.lua")

--[[                  Stations
These are templates for space stations.
----------------------------------------------------------]]

template = ShipTemplate():setName(smallStation):setModel("space_station_4"):setType("station")
template:setDescription(smallStationDescription)
template:setHull(150)
template:setShields(300)
template:setRadarTrace("radartrace_smallstation.png")

template = ShipTemplate():setName(mediumStation):setModel("space_station_3"):setType("station")
template:setDescription(mediumStationDescription)
template:setHull(400)
template:setShields(800)
template:setRadarTrace("radartrace_mediumstation.png")

template = ShipTemplate():setName(largeStation):setModel("space_station_2"):setType("station")
template:setDescription(largeStationDescription)
template:setHull(500)
template:setShields(1000, 1000, 1000)
template:setRadarTrace("radartrace_largestation.png")

template = ShipTemplate():setName(hugeStation):setModel("space_station_1"):setType("station")
template:setDescription(hugeStationDescription)
template:setHull(800)
template:setShields(1200, 1200, 1200, 1200)
template:setRadarTrace("radartrace_hugestation.png")
