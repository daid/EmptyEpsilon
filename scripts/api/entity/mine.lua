
--- A Mine is an explosive weapon that detonates and deals kinetic damage when a SpaceObject collides with its trigger range.
--- Mines can be owned by factions but are triggered by SpaceObjects of any faction can trigger them.
--- Mines can be launched from a SpaceShip's weapon tube or added by a GM or scenario script.
--- When launched from a SpaceShip, the mine has an eject timeout, during which its trigger range is inactive.
--- In 3D views, mines are represented by a particle effect at the center of its trigger range.
--- To create objects with more complex collision mechanics, use an Artifact.
--- Example: mine = Mine():setPosition(1000,1000):onDestruction(this_mine, instigator) print("Tripped a mine!") end)
function Mine()
    local e = createEntity()
    e.transform = {}
    --TODO
    return e
end

local Entity = getLuaEntityFunctionTable()

function Entity:getOwner()
    --TODO
end

function Entity:onDestruction(callback)
    --TODO
    return self
end
