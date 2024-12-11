--- An Asteroid is an inert piece of space terrain.
--- Upon collision with another SpaceObject, it deals damage and is destroyed.
--- It has a default rotation speed, random z-offset, and model, and AI behaviors attempt to avoid hitting them.
--- To create a customizable object with more complex actions upon collisions, use an Artifact or SupplyDrop.
--- For a purely decorative asteroid positioned outside of the movement plane, use a VisualAsteroid.
--- Example: asteroid = Asteroid():setSize(150):setPosition(1000,2000)
--- @type creation
function Asteroid()
    local z = random(-50, 50)
    local size = random(110, 130)

    local model_number = irandom(1, 10)
    local e = createEntity()
    e.components = {
        transform = {rotation=random(0, 360)},
        radar_signature = {gravity=0.05},
        mesh_render = {
            mesh="Astroid_" .. model_number .. ".model",
            mesh_offset={0, 0, z},
            texture="Astroid_" .. model_number .. "_d.png",
            specular_texture="Astroid_" .. model_number .. "_s.png",
            scale=size,
        },
        physics = {type="Sensor", size=size},
        radar_trace = {
            icon="radar/blip.png",
            radius=size,
            color={255, 200, 100, 255},
            rotate=false,
        },
        spin={rate=random(0.1, 0.8)},
        avoid_object={range=size*2},
        explode_on_touch={damage_at_center=35, damage_at_edge=35,blast_range=size},
    }
    return e
end

function VisualAsteroid()
    local z = random(300, 800);
    if random(0, 100) < 50 then z = -z end
    local size = random(110, 130)
    local e = createEntity()
    local model_number = irandom(1, 10)
    e.components = {
        transform = {rotation=random(0, 360)},
        radar_signature = {gravity=0.05},

        mesh_render = {
            mesh="Astroid_" .. model_number .. ".model",
            mesh_offset={0, 0, z},
            texture="Astroid_" .. model_number .. "_d.png",
            specular_texture="Astroid_" .. model_number .. "_s.png",
            scale=size,
        },
        spin={rate=random(0.1, 0.8)},
    }
    return e
end

local Entity = getLuaEntityFunctionTable()
--- Sets this Asteroid's radius.
--- Defaults to a random value between 110 and 130.
--- Example: asteroid:setSize(150)
function Entity:setSize(radius)
    local comp = self.components
    if comp.physics then comp.physics.size=radius end
    if comp.mesh_render then comp.mesh_render.scale=radius end
    if comp.avoid_object then comp.avoid_object.range=radius*2 end
    return self
end
--- Returns this Asteroid's radius.
--- Example: asteroid:getSize()
function Entity:getSize()
    local comp = self.components
    if comp.physics then return comp.physics.size end
    if comp.mesh_render then return comp.mesh_render.scale end
    return 100.0
end
