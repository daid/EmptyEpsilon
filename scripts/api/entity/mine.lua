
--- A Mine is an explosive weapon that detonates and deals kinetic damage when a SpaceObject collides with its trigger range.
--- Mines can be owned by factions but are triggered by SpaceObjects of any faction can trigger them.
--- Mines can be launched from a SpaceShip's weapon tube or added by a GM or scenario script.
--- When launched from a SpaceShip, the mine has an eject timeout, during which its trigger range is inactive.
--- In 3D views, mines are represented by a particle effect at the center of its trigger range.
--- To create objects with more complex collision mechanics, use an Artifact.
--- Example: mine = Mine():setPosition(1000,1000):onDestruction(this_mine, instigator) print("Tripped a mine!") end)
function Mine()
    local blast_range = 1000.0
    local e = createEntity()
    e.components.transform = {}
    e.components.radar_trace = {icon="radar/mine.png", min_size=10, max_size = 10}
    e.components.constant_particle_emitter = {interval=0.4, start_color={1, 1, 1}, end_color={0, 0, 1}, start_size=30.0, end_size=0.0, life_time=10.0}
    e.components.radar_signature = {electrical=0.05}
    e.components.avoid_object = {range=blast_range*1.2}
    e.components.physics = {type="sensor", size=blast_range*0.6}
    e.components.delayed_explode_on_touch = {delay=1.0, damage_at_center=160.0, damage_at_edge=30.0, blast_range=1000.0}
    return e
end

local Entity = getLuaEntityFunctionTable()
