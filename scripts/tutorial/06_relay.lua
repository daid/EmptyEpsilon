-- Name: Relay
-- Description: [Station Tutorial]
--- -------------------
--- -Goes over relay station.
---
--- [Station Info]
--- -------------------
--- Sector Map: 
--- -The Relay station can view a map of the sector, including space hazards and ships within short-range scanner range (5U). It can also see the short-range sensor data around other friendly ships and stations, potentially spotting distant ships before the science station does. The Relay officer cannot scan ships, however.
---
--- Probes: 
--- -The Relay officer can launch up to 8 high-speed probes to any point in the sector. These probes fly toward a location and transmit short-range sensor data to the ship for 10 minutes. Probes work inside nebulae, and thus are powerful tools when faced with an area blocked by nebula. The Relay officer can also link a probe's sensors to the Science station, which lets the Science officer scan ships within the probe's sensor range even if the probe is beyond the ship's long-range scanners. Probes cannot be retrieved and can be destroyed by enemies; your ship's stock of probes can be replenished only by docking at a station.
---
--- Waypoints: 
--- -The Relay officer can set waypoints around the sector. These waypoints appear on the Helms officer's short-range scanner and can guide the ship toward a destination or on a specific route through space. Waypoints are also necessary when requesting aid from friendly stations.
---
--- Communications: 
--- -The Relay officer can open communications with stations and other ships. Friendly ships hailed by the Relay officer can take orders, and friendly stations can dispatch backup and supply ships. While your ship is docked at a station, the Relay officer can request rearmament of the ship's missiles and mines. Some of these requests can cost some of your crew's reputation, which is also tracked by the Relay station.
-- Type: Tutorial
require("tutorial/00_all.lua")

function init()
    tutorial_list = {
        relayTutorial,
        endOfTutorial
    }
    startTutorial()
end
