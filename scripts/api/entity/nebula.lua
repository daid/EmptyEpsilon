
--- A Nebula is a piece of space terrain with a 5U radius that blocks long-range radar, but not short-range radar.
--- This hides any SpaceObjects inside of a Nebula, as well as SpaceObjects on the other side of its radar "shadow", from any SpaceShip outside of it.
--- Likewise, a SpaceShip fully inside of a nebula has effectively no long-range radar functionality.
--- In 3D space, a Nebula resembles a dense cloud of colorful gases.
--- Example: nebula = Nebula():setPosition(1000,2000)
--- @type creation
function Nebula(radius)
    local radius = 5000.0
    local e = createEntity()
    e.components.radar_signature = {gravity=0, electrical=0.8, biological=-1.0}
    e.components.transform = {rotation=random(0, 360)}
    e.components.radar_trace = {icon="radar/nebula.png" .. irandom(1, 4) .. ".png", min_size=0, max_size = 9999999, radius=radius*1.15, blend_add=true}
    e.components.radar_block = {range=radius}
    e.components.never_radar_blocked = {}
    
    local render_info = {}
    local cloud_count = irandom(24, 48)
    local golden_angle = 137.508 -- degrees, 360°/φ²
    local min_size = 1024 -- size at outer edge
    local max_size = min_size*5 -- size at center
    
    for n=1,cloud_count do
        -- Golden spiral arrangement
        local angle = (n - 1) * golden_angle
        local t = (n - 1) / (cloud_count - 1) -- progression from 0 (center) to 1 (edge)
        local spiral_radius = math.sqrt(t) * (radius * 0.7)
        
        -- Size decreases from center to edge, ending at 512
        local size = min_size + (max_size - min_size) * (1 - t)
        
        local ox = math.cos(angle / 180 * math.pi) * spiral_radius
        local oy = math.sin(angle / 180 * math.pi) * spiral_radius
        
        render_info[n] = {size=size, texture="Nebula" .. irandom(1, 3) .. ".png", offset={ox, oy}}
    end
    
    e.components.nebula_renderer = render_info
    e.components.nebula_renderer.render_range = 20000
    return e
end