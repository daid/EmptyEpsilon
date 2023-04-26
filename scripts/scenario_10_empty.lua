-- Name: Empty space
-- Description: Empty scenario, no enemies, no friendlies. Can be used by a GM player to setup a scenario in the GM screen. The F5 key can be used to copy the current layout to the clipboard for use in scenario scripts.
-- Type: Development

--- Scenario
-- @script scenario_10_empty

function Asteroid()
    local e = createEntity()
    e.transform = {rotation=random(0, 360)}
    e.radar_signature = {gravity=0.05}
    local z = random(-50, 50)
    local size = random(110, 130)

    local model_number = irandom(1, 10)
    e.mesh_render = {
        mesh="Astroid_" .. model_number .. ".model",
        mesh_offset={0, 0, z},
        texture="Astroid_" .. model_number .. "_d.png",
        specular_texture="Astroid_" .. model_number .. "_s.png",
        scale=size,
    }
    e.physics = {type="Sensor", size=size}
    e.radar_trace = {
        icon="radar/blip.png",
        radius=size,
        color={255, 200, 100, 255},
        --TODO: flags="LongRange",
    }
    e.spin={rate=random(0.1, 0.8)}
    e.avoid_object={range=size*2}
    e.explode_on_touch={damage_at_center=35, damage_at_edge=35,blast_range=size}
    return e
end

function PlayerSpaceship()
    local e = createEntity()
    local size = 300
    e.transform = {rotation=random(0, 360)}
    e.callsign = {callsign="Player"}
    e.typename = {type_name="Atlantis"}
    --ShipTemplateBasedObject
    e.long_range_radar = {}
    e.hull = {}
    e.shields = {{level=100,max=100}, {level=50,max=50}}
    e.radar_trace = {
        icon="radar/dread.png",
        radius=size*0.8,
        max_size=1024,
        --TODO: flags="Rotate | LongRange | ColorByFaction",
    }
    --e.docking_bay = {}
    e.docking_port = {}
    e.share_short_range_radar = {}
    e.mesh_render = {
        mesh="small_fighter_1.model",
        mesh_offset={0, 0, 0},
        texture="small_fighter_1_color.jpg",
        specular_texture="small_fighter_1_specular.jpg",
        illumination_texture="small_fighter_1_illumination.jpg",
        scale=3.0,
    }
    e.engine_emitter = {}
    e.physics = {type="dynamic", size=size}
    
    --SpaceShip
    --e.radar_trace.flags = e.radar_trace.flags | ArrowIfNotScanned
    e.shields.frequency = irandom(0, 20);
    e.beam_weapons = {}
    e.reactor = {}
    e.impulse_engine = {}
    e.maneuvering_thrusters = {}
    e.combat_maneuvering_thrusters = {}
    e.warp_drive = {}
    e.jump_drive = {}
    e.missile_tubes = {}
    
    --PlayerSpaceShip
    --TODO: Set scan state for each faction
    --TODO: Faction
    --TODO: Repair crew + InternalRooms
    e.coolant = {}
    e.self_destruct = {}
    e.science_scanner = {}
    e.scan_probe_launcher = {}
    e.hacking_device = {}
    e.player_control = {}
    
    return e
end


function init()
    local a = Asteroid()
    a.transform = {position={500, 1000}}
    
    local p = PlayerSpaceship()
    p.transform = {position={5000, 5000}}
end

function update(delta)
    -- No victory condition
end
