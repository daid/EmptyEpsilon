--- An Artifact is a configurable SpaceObject that can interact with other objects via collisions or scripting.
--- Use this to define arbitrary objects or collectible pickups in scenario scripts.
--- Example: artifact = Artifact():setModel("artifact6"):setSpin(0.5)
--- @type creation
function Artifact()
    local e = createEntity()
    e.components.transform = {rotation=random(0, 360)}

    local model_number = irandom(1, 8)
    e.components = {
        mesh_render = {
            mesh="mesh/Artifact" .. model_number .. ".obj",
            texture="texture/electric_sphere_texture.png",
            scale=3.0,
        },
        radar_trace = {
            icon="radar/blip.png",
            radius=120.0,
            rotate=false,
        },
        physics = {
            type="sensor", size=100
        },
    }
    return e
end

local Entity = getLuaEntityFunctionTable()
--- Sets the 3D model used for this artifact, by its ModelData name.
--- ModelData is defined in scripts/model_data.lua.
--- Defaults to a ModelData whose name starts with "artifact" and ends with a random number between 1 and 8.
--- Example: artifact:setModel("artifact6")
function Entity:setModel(model_name)
    for k, v in pairs(__model_data[model_name]) do
        if string.sub(1, 2) ~= "__" then
            self.components[k] = table.deepcopy(v)
        end
    end
    return self
end
--- Immediately destroys this artifact with a visual explosion.
--- Example: artifact:explode() -- artifact is destroyed
function Entity:explode()
    local e = ExplosionEffect()
    e:setSize(120)
    local x, y = self:getPosition()
    e:setPosition(x, y)
    self:destroy()
    return self
end
--- Defines whether this artifact can be picked up via collision.
--- The artifact is destroyed upon being picked up.
--- Defaults to false.
--- Example: artifact:allowPickup(true)
function Entity:allowPickup(allow)
    if allow then
        self.components.pickup = {}
    else
        self.components.pickup = nil
    end
    return self
end
--- Defines a function to call every tick when a SpaceObject is colliding with the artifact.
--- Passes the artifact and colliding SpaceObject to the called function.
--- Example: artifact:onCollision(function(artifact, collider) print("Collision occurred") end)
function Entity:onCollision(callback)
    self.components.collision_callback = {player=false, callback=callback}
    return self
end    
--- Defines a function to call every tick when a PlayerSpaceship is colliding with the artifact.
--- Passes the artifact and colliding PlayerSpaceship to the called function.
--- Example: artifact:onCollision(function(artifact, player) print("Collision occurred") end)
function Entity:onPlayerCollision(callback)
    self.components.collision_callback = {player=true, callback=callback}
    return self
end
--- Defines a function to call once when a PlayerSpaceship collides with the artifact and allowPickup is enabled.
--- Passes the artifact and colliding PlayerSpaceship to the called function.
--- Example: artifact:onPickUp(function(artifact, player) print("Artifact retrieved") end)
    --- Defines a function to call when a SpaceShip collides with the supply drop.
--- Passes the supply drop and the colliding ship (if it's a PlayerSpaceship) to the function.
--- Example: supply_drop:onPickUp(function(drop,ship) print("Supply drop picked up") end)
function Entity:onPickUp(callback)
    self.components.pickup = {callback = callback}
    return self
end
--- Alias of Artifact:onPickUp().
function Entity:onPickup(callback)
    return self:onPickUp(callback)
end
--- Defines whether the artifact rotates, and if so at what rotational velocity. (unit?)
--- For reference, normal asteroids spin at a rate between 0.1 and 0.8.
--- Example: artifact:setSpin(0.5)
function Entity:setSpin(spin)
    if spin ~= 0.0 then
        self.components.spin = {rate=spin}
    else
        self.components.spin = nil
    end
    return self
end
--- Sets the radar trace image for this artifact.
--- Optional. Defaults to "blip.png".
--- Valid values are filenames to PNG files relative to resources/radar/.
--- Example: artifact:setRadarTraceIcon("arrow.png") -- displays an arrow instead of a blip for this artifact
function Entity:setRadarTraceIcon(icon)
    if self.components.radar_trace then self.components.radar_trace.icon = "radar/" .. icon end    
    return self
end
--- Scales the radar trace for this artifact.
--- A value of 0 restores standard autoscaling relative to the artifact's radius.
--- Set to 1 to mimic ship traces.
--- Example: artifact:setRadarTraceScale(0.7)
function Entity:setRadarTraceScale(scale)
    if self.components.radar_trace then
        self.components.radar_trace.min_size = scale * 32
        self.components.radar_trace.max_size = scale * 32
    end
    return self
end
--- Sets the color of this artifact's radar trace.
--- Optional. Defaults to solid white (255,255,255)
--- Example: artifact:setRadarTraceColor(255,200,100) -- mimics an asteroid
function Entity:setRadarTraceColor(r, g, b)
    if self.components.radar_trace then
        self.components.radar_trace.color = {r, g, b, 255}
    end
    return self
end
