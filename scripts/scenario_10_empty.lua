-- Name: Empty space
-- Description: Empty scenario, no enemies, no friendlies. Can be used by a GM player to setup a scenario in the GM screen. The F5 key can be used to copy the current layout to the clipboard for use in scenario scripts.
-- Type: Development

--- Scenario
-- @script scenario_10_empty


function init()
    local a = Asteroid()
    a:setPosition(500, 1000)
    
    p = PlayerSpaceship()
    p:setTemplate("Atlantis")
    p:setPosition(0, 0)

    print("Print function from init.")
    print("Player is at:", p.components.transform.position)

    --c = CpuShip()
    --c:setTemplate("Phobos T3"):setPosition(5000, 5000)

    --s = SpaceStation()
    --s:setTemplate("Small Station"):setPosition(-2000, -2000):setFaction("Human Navy")
end


function hue_to_color(h)
    if h > 360 then h = h - 360 end
    local color = {0, 0, 0}
    local c = 1.0
    local x = 1.0 - math.abs(((h % 120) / 60) - 1.0);
    if h < 60 then color[1] = c; color[2] = x
    elseif h < 120 then color[1] = x; color[2] = c
    elseif h < 180 then color[2] = c; color[3] = x
    elseif h < 240 then color[2] = x; color[3] = c
    elseif h < 300 then color[1] = x; color[3] = c
    else color[1] = c; color[3] = x end
    return color
end

local hue = 0
function update(delta)
    hue = hue + delta * 60
    if hue > 360 then hue = hue - 360 end
    for n=1,#p.components.engine_emitter do
        p.components.engine_emitter[n].color = hue_to_color(hue + n * 60)
    end
    -- No victory condition
end
