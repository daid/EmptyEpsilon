--- A BlackHole is a piece of space terrain that pulls all nearby entities within a 5U radius, including otherwise immobile entities like stations, toward its center.
--- An entity capable of taking damage is dealt an increasing amount of damage as it approaches the BlackHole's center.
--- Upon reaching the center, any entity is instantly destroyed even if it's otherwise incapable of taking damage.
--- AI behaviors avoid BlackHoles by a 2U margin.
--- In 3D space, a BlackHole resembles a black sphere with blue horizon.
--- The optional radius parameter specifies the radius of the BlackHole, default 5000
--- Example: black_hole = BlackHole():setPosition(1000,2000)
--- @type creation
function BlackHole(radius)
    radius = radius or 5000
    radius = math.max(0, radius)
    local e = createEntity()
    e.components = {
        transform = {},
        never_radar_blocked = {},
        gravity = {range=radius, damage=true},
        avoid_object = {range=radius*1.4},
        radar_signature = {gravity=0.9},
        radar_trace = {icon="radar/blackHole.png", min_size=0, max_size = 2048, radius=radius},
        billboard_render = {texture="blackHole3d.png", size=radius},
        warppostprocessor = { max_radius = radius, max_effect_strength=1 }
    }
    return e
end


--- A WormHole is a piece of space terrain that pulls all nearby entities within a 2.5U radius, including otherwise immobile entities like stations, toward its center.
--- Any entity that reaches its center is teleported to another point in space.
--- AI behaviors avoid WormHoles by a 0.5U margin.
--- The optional radius parameter specifies the radius of the WormHole, default 2500
--- Example: wormhole = WormHole():setPosition(1000,1000):setTargetPosition(10000,10000)
--- @type creation
function WormHole(radius)
    radius = radius or 2500
    radius = math.max(0, radius)
    local e = createEntity()
    e.components = {
        transform = {},
        never_radar_blocked = {},
        gravity = {range=radius, damage=false},
        avoid_object = {range=radius*1.2},
        radar_signature = {gravity=0.9},
        radar_trace = {icon="radar/wormHole.png", min_size=0, max_size=2048, radius=radius},
        billboard_render = {texture="wormHole3d.png", size=radius*2},
        glitchpostprocessor = { max_radius = radius, max_effect_strength=20}
    }
    return e
end

local Entity = getLuaEntityFunctionTable()
--- Sets the target teleportation coordinates for entities that pass through the center of this wormhole.
--- Avoid the default value of {0,0}, which should be treated as no destination.
--- Example: wormhole:setTargetPosition(10000,10000)
function Entity:setTargetPosition(x, y)
    if self.components.gravity then self.components.gravity.wormhole_target = {x, y} end
    return self
end
--- Returns the target teleportation coordinates for entities that pass through the center of this wormhole.
--- The default value of {0,0} should be treated as no destination.
--- Example: wormhole:getTargetPosition()
function Entity:getTargetPosition()
    if self.components.gravity then return self.components.gravity.wormhole_target end
    return nil
end
--- Defines a function to call when this WormHole teleports an entity.
--- Passes the WormHole object and the teleported entity.
--- Example:
--- -- Outputs teleportation details to the console window and logging file
--- wormhole:onTeleportation(function(this_wormhole,teleported_object) print(teleported_object:getCallSign() .. " teleported to " .. this_wormhole:getTargetPosition()) end)
function Entity:onTeleportation(callback)
    if self.components.gravity then self.components.gravity.on_teleportation = callback end
    return self
end
