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
    print("Player is at:", p.transform.position)

    c = CpuShip()
    c:setTemplate("Phobos T3"):setPosition(5000, 5000)

    s = SpaceStation()
    s:setTemplate("Small Station"):setPosition(-2000, -2000):setFaction("Human Navy")
end

function update(delta)
    -- No victory condition
end
