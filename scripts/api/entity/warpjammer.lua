
--- A WarpJammer restricts the ability of any SpaceShips to use warp or jump drives within its radius.
--- WarpJammers can be targeted, damaged, and destroyed.
--- Example: jammer = WarpJammer():setPosition(1000,1000):setRange(10000):setHull(20)
function WarpJammer()
    local e = createEntity()
    e.hull = {max=50, current=50}
    e.warp_jammer = {range=7000}
    for k, v in pairs(__model_data["shield_generator"]) do
        if string.sub(1, 2) ~= "__" then
            self[k] = table.deepcopy(v)
        end
    end
end

local Entity = getLuaEntityFunctionTable()
--- Returns this WarpJammer's jamming range, represented on radar as a circle with jammer in the middle.
--- No warp/jump travel is possible within this radius.
--- Example: jammer:getRange()
function Entity:getRange()
    --TODO
    return self
end
--- Sets this WarpJammer's jamming radius.
--- No warp/jump travel is possible within this radius.
--- Defaults to 7000.0.
--- Example: jammer:setRange(10000) -- sets a 10U jamming radius 
function Entity:setRange()
    --TODO
    return self
end

--- Returns this WarpJammer's hull points.
--- Example: jammer:getHull()
function Entity:getHull()
    --TODO
    return self
end
--- Sets this WarpJammer's hull points.
--- Defaults to 50
--- Example: jammer:setHull(20)
function Entity:setHull()
    --TODO
    return self
end

--- Defines a function to call when this WarpJammer takes damage.
--- Passes the WarpJammer object and the damage instigator SpaceObject (or nil if none).
--- Example: jammer:onTakingDamage(function(this_jammer,instigator) print("Jammer damaged!") end)
function Entity:onTakingDamage()
    --TODO
    return self
end
--- Defines a function to call when the WarpJammer is destroyed by taking damage.
--- Passes the WarpJammer object and the damage instigator SpaceObject (or nil if none).
--- Example: jammer:onDestruction(function(this_jammer,instigator) print("Jammer destroyed!") end)
function Entity:onDestruction()
    --TODO
    return self
end
