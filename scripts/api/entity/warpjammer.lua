
--- A WarpJammer restricts the ability of any SpaceShips to use warp or jump drives within its radius.
--- WarpJammers can be targeted, damaged, and destroyed.
--- Example: jammer = WarpJammer():setPosition(1000,1000):setRange(10000):setHull(20)
--- @type creation
function WarpJammer()
    local e = createEntity()
    e.components = {
        transform = {rotation=random(0, 360)},
        hull = {max=50, current=50},
        warp_jammer = {range=7000},
        radar_trace = {
            icon="radar/blip.png",
            radius=120.0,
            rotate=false,
            color_by_faction=true,
        },
        physics = {type="static",size=300},
    }
    for k, v in pairs(__model_data["shield_generator"]) do
        if string.sub(k, 1, 2) ~= "__" then
            e.components[k] = table.deepcopy(v)
        end
    end
    return e
end

local Entity = getLuaEntityFunctionTable()
--- Returns this WarpJammer's jamming range, represented on radar as a circle with jammer in the middle.
--- No warp/jump travel is possible within this radius.
--- Example: jammer:getRange()
function Entity:getRange()
    if self.warp_jammer then return self.warp_jammer.range end
    return 0
end
--- Sets this WarpJammer's jamming radius.
--- No warp/jump travel is possible within this radius.
--- Defaults to 7000.0.
--- Example: jammer:setRange(10000) -- sets a 10U jamming radius 
function Entity:setRange(range)
    if self.warp_jammer then self.warp_jammer.range = range end
    return self
end
