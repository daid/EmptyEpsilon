
--- A SpaceStation is an immobile ship-like object that repairs, resupplies, and recharges ships that dock with it.
--- It sets several ShipTemplateBasedObject properties upon creation:
--- - Its default callsign begins with "DS".
--- - It restocks scan probes and CpuShip weapons by default.
--- - It uses the scripts/comms_station.lua comms script by default.
--- - When destroyed by damage, it awards or deducts a number of reputation points relative to its total shield strength and segments.
--- - Any non-hostile SpaceShip can dock with it by default.
function SpaceStation()
    local e = createEntity()
    e.components.transform = {rotation=random(0, 360)}
    return e
end
