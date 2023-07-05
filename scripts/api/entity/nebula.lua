
--- A Nebula is a piece of space terrain with a 5U radius that blocks long-range radar, but not short-range radar.
--- This hides any SpaceObjects inside of a Nebula, as well as SpaceObjects on the other side of its radar "shadow", from any SpaceShip outside of it.
--- Likewise, a SpaceShip fully inside of a nebula has effectively no long-range radar functionality.
--- In 3D space, a Nebula resembles a dense cloud of colorful gases.
--- Example: nebula = Nebula():setPosition(1000,2000)
function Nebula()
    local radius = 5000.0
    local e = createEntity()
    e.radar_signature = {gravity=0, electrical=0.8, biological=-1.0}
    e.transform = {rotation=random(0, 360)}
    e.radar_trace = {icon="Nebula" .. irandom(1, 3) .. ".png", min_size=0, max_size = 2048, radius=radius*1.5, blend_add=true}
    e.radar_block = {range=radius}
    e.never_radar_blocked = {}
    local render_info = {}
    local cloud_count = 32
    for n=1,cloud_count do
        local size = random(512, 1024 * 2)
        local dist = random(size / 2.0, radius - size)
        local angle = n * 360 / cloud_count
        local ox, oy = math.cos(angle / 180 * math.pi) * dist, math.sin(angle / 180 * math.pi) * dist
        render_info[n] = {size=size, texture="Nebula" .. irandom(1, 3) .. ".png", offset={ox, oy}}
    end
    e.nebula_renderer = render_info
    return e
end