--- A Zone is a polygonal area of space defined by a series of coordinates.
--- Although a Zone is a SpaceObject, it isn't affected by physics and isn't rendered in 3D.
--- Zones are drawn on GM, comms, and long-range radar screens, can have a text label, and can return whether a SpaceObject is within their bounds.
--- New Zones can't be created via the exec.lua HTTP API.
--- Example:
--- -- Defines a blue rectangular 200sqU zone labeled "Home" around 0,0
--- zone = Zone():setColor(0,0,255):setPoints(-100000,100000, -100000,-100000, 100000,-100000, 100000,100000):setLabel("Home")
function Zone()
    local e = createEntity()
    e.components = {
        transform = {},
        zone = {},
    }
    return e
end

local Entity = getLuaEntityFunctionTable()
--- Sets the corners of this Zone n-gon to x_1, y_1, x_2, y_2, ... x_n, y_n.
--- Positive x coordinates are right/"east" of the origin, and positive y coordinates are down/"south" of the origin in space.
--- Example: zone:setPoints(2000,0, 0,3000, -2000,0) -- defines a triangular zone
function Entity:setPoints(...)
    if self.components.zone then 
        local coords = {...}
        local points = {}
        for n=1,#coords,2 do
            table.insert(points, {coords[n], coords[n+1]})
        end
        self.components.zone.points = points
    end
    return self
end
--- Sets this Zone's color when drawn on radar.
--- Defaults to white (255,255,255).
--- Example: zone:setColor(255,140,0)
function Entity:setColor(r, g, b)
    if self.components.zone then self.components.zone.color = {r, g, b} end
    return self
end
--- Sets this Zone's text label, rendered at the zone's center point.
--- Example: zone:setLabel("Hostile space")
function Entity:setLabel(label)
    if self.components.zone then self.components.zone.label = label end
    return self
end
--- Returns this Zone's text label.
--- Example: zone:getLabel()
function Entity:getLabel()
    if self.components.zone then return self.components.zone.label end
    return ""
end
--- Returns whether the given SpaceObject is inside this Zone.
--- Example: zone:isInside(obj) -- returns true if `obj` is within the zone's bounds
function Entity:isInside()
    --TODO
    return false
end
