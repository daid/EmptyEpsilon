__default_station_faction = "Independent"

--- A SpaceStation is an immobile ship-like object that repairs, resupplies, and recharges ships that dock with it.
--- It sets several ShipTemplateBasedObject properties upon creation:
--- - Its default callsign begins with "DS".
--- - It restocks scan probes and CpuShip weapons by default.
--- - It uses the scripts/comms_station.lua comms script by default.
--- - When destroyed by damage, it awards or deducts a number of reputation points relative to its total shield strength and segments.
--- - Any non-hostile SpaceShip can dock with it by default.
--- @type creation
function SpaceStation()
    local e = createEntity()
    e.components = {
        transform = {rotation=random(0, 360)},
        callsign = {callsign=generateRandomCallSign("DS")},
        comms_receiver = {script="comms_station.lua"},
    }
    e:setFaction(__default_station_faction)
    return e
end
