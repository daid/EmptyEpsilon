
--- A ScanProbe deploys a short-range radar with a limited lifetime at a high speed to a specific point.
--- ScanProbes can be targeted and destroyed by hostiles.
--- It's typically launched by the relay officer and can be linked to the science radar, but can also be created by scripts.
--- PlayerSpaceships have a limited stock of ScanProbes typically replenished automatically when docked to a SpaceStation or SpaceShip with the ScanProbe restocking feature enabled.
--- Example: probe = ScanProbe():setSpeed(1500):setLifetime(60 * 30):setTarget(10000,10000):onArrival(function() print("Probe arrived!") end)
function ScanProbe()
    local e = createEntity()
    --TODO: e.move_to = {speed=1000, target=??}
    --TODO: e.allow_radar_link = {owner=??}
    --TODO: e.faction = ???
    setRadarSignatureInfo(0.0, 0.2, 0.0);
    --TODO: setCallSign(string(getMultiplayerId()) + "P");
    e.components = {
        lifetime = {lifetime=60*10},
        radar_trace = {
            icon="radar/probe.png",
            min_size=10.0,
            max_size=10.0,
            color={96, 192, 128, 255},
            rotate=false,
        },
        hull = {max=1, current=1},
        share_short_range_radar = {},
    }
    local model = "SensorBuoyMKI"
    local idx = irandom(1, 3)
    if idx == 2 then model = "SensorBuoyMKII" end
    if idx == 3 then model = "SensorBuoyMKIII" end
    for k, v in pairs(__model_data[model]) do
        if string.sub(1, 2) ~= "__" then
            e.components[k] = table.deepcopy(v)
        end
    end
    return e
end

local Entity = getLuaEntityFunctionTable()
--- Sets this ScanProbe's speed.
--- Probes move at a fixed rate of speed and ignore collisions and physics while moving.
--- Defaults to 1000 (1U/second).
--- Example: probe:setSpeed(2000)
function Entity:setSpeed(speed)
    --TODO
    return self
end
--- Returns this ScanProbe's speed.
--- Example: probe:getSpeed()
function Entity:getSpeed()
    --TODO
    return self
end
--- Sets this ScanProbe's remaining lifetime, in seconds.
--- Defaults to 600 seconds (10 minutes).
--- Example: probe:setLifetime(60 * 5) -- sets the lifetime to 5 minutes
function Entity:setLifetime(lifetime)
    --TODO
    return self
end
--- Returns this ScanProbe's remaining lifetime.
--- Example: probe:getLifetime()
function Entity:getLifetime()
    --TODO
    return self
end
--- Sets this ScanProbe's target coordinates.
--- If the probe has reached its target, ScanProbe:setTarget() moves it again toward the new target coordinates.
--- Example: probe:setTarget(1000,5000)
function Entity:setTarget()
    --TODO
    return self
end
--- Sets this ScanProbe's owner SpaceObject.
--- Example: probe:setOwner(owner)
function Entity:setOwner(owner)
    if self.components.allow_radar_link then self.components.allow_radar_link.owner = owner end
    if owner and owner:isValid() and owner.components.faction then
        self.components.faction.entity = owner.components.faction.entity
    else
        self.components.faction = nil
    end
    return self
end
--- Defines a function to call when this ScanProbe arrives to its target coordinates.
--- Passes the probe and position as arguments to the function.
--- Example: probe:onArrival(function(this_probe, coords) print("Probe arrived!") end)
function Entity:onArrival()
    --TODO
    return self
end
--- Defines a function to call when this ScanProbe's lifetime expires.
--- Passes the probe as an argument to the function.
--- Example: probe:onExpiration(function(this_probe) print("Probe expired!") end)
function Entity:onExpiration()
    --TODO
    return self
end
