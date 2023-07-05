--- A BlackHole is a piece of space terrain that pulls all nearby SpaceObjects within a 5U radius, including otherwise immobile objects like SpaceStations, toward its center.
--- A SpaceObject capable of taking damage is dealt an increasing amount of damage as it approaches the BlackHole's center.
--- Upon reaching the center, any SpaceObject is instantly destroyed even if it's otherwise incapable of taking damage.
--- AI behaviors avoid BlackHoles by a 2U margin.
--- In 3D space, a BlackHole resembles a black sphere with blue horizon.
--- Example: black_hole = BlackHole():setPosition(1000,2000)
function BlackHole()
    local e = createEntity()
    e.never_radar_blocked = {}
    e.gravity = {range=5000, damage=true}
    e.avoid_object = {range=7000}
    e.radar_signature = {gravity=0.9}
    e.radar_trace = {icon="radar/blackHole.png", min_size=0, max_size = 2048, radius=5000}
    return e
end