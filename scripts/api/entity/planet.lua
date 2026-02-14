--- A Planet is a spherical piece of space terrain that can orbit other SpaceObjects.
--- Each Planet has separate textures for its surface, atmosphere, and cloud layers.
--- Several planetary textures are included in the resources/planets/ directory.
--- Planets can collide with objects and run callback functions upon collisions.
--- Examples:
--- -- Creates a small planetary system with a sun, a planet orbiting the sun, and a moon orbiting the planet.
--- sun = Planet():setPosition(5000, 15000):setPlanetRadius(1000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0, 1.0, 1.0)
--- planet = Planet():setPosition(5000, 5000):setPlanetRadius(3000):setPlanetSurfaceTexture("planets/planet-1.png")
--- planet:setPlanetCloudTexture("planets/clouds-1.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.2, 0.2, 1.0):setOrbit(sun,40)
--- moon = Planet():setPosition(5000, 0):setPlanetRadius(1000):setPlanetSurfaceTexture("planets/moon-1.png"):setAxialRotationTime(20.0):setOrbit(planet,20)
--- @type creation
function Planet()
    local e = createEntity()
    e.components = {
        transform = {rotation=random(0, 360)},
        radar_signature = {gravity=0.5, biological=0.3},
        planet_render = {
            size=5000,
            cloud_size = 5200,
        },
        physics = {type="static", size=5000},
        never_radar_blocked = {}
    }
    return e
end

local Entity = getLuaEntityFunctionTable()
--- Sets this Planet's atmospheric effect color.
--- Example: planet:setPlanetAtmosphereColor(0.2,0.2,1.0) -- sets a blue atmosphere
function Entity:setPlanetAtmosphereColor(r, g, b)
    if self.components.planet_render then self.components.planet_render.atmosphere_color = {r, g, b} end
    return self
end
--- Sets this Planet's atmospheric effect texture.
--- Valid values are filenames of PNG files relative to the resources/ directory.
--- Optional; if defined, atmosphere textures should be transparent or translucent.
--- For stars, you can set an atmosphere texture such as planets/star-1.png with no surface texture.
--- Example: planet:setPlanetSurfaceTexture("planets/atmosphere.png")
function Entity:setPlanetAtmosphereTexture(texture)
    if self.components.planet_render then self.components.planet_render.atmosphere_texture = texture end
    return self
end
--- Sets this Planet's surface texture.
--- Valid values are filenames of PNG files relative to the resources/ directory.
--- Optional; if defined, surface textures should be opaque and use a 2:1-ratio equirectangular projection.
--- Example: planet:setPlanetSurfaceTexture("planets/planet-1.png")
function Entity:setPlanetSurfaceTexture(texture)
    if self.components.planet_render then self.components.planet_render.texture = texture end
    return self
end
--- Sets this Planet's cloud layer effect texture, which rotates independently of the planet.
--- Valid values are filenames of PNG files relative to the resources/ directory.
--- Optional; if defined, cloud layer textures should be transparent or translucent.
--- Example: planet:setPlanetCloudTexture("planets/cloud-1.png")
function Entity:setPlanetCloudTexture(texture)
    if self.components.planet_render then self.components.planet_render.cloud_texture = texture end
    return self
end
--- Returns this Planet's radius.
--- Example: planet:getPlanetRadius()
function Entity:getPlanetRadius()
    if self.components.planet_render then
        return self.components.planet_render.size
    end
    return 1000.0
end
--- Sets this Planet's radius, which also sets:
--- - its cloud radius to 1.05x this value
--- - its atmosphere radius to 1.2x this value
--- - its collision size to a function of this value and the planet's z-position
--- Defaults to 5000 (5U).
--- Example: planet:setPlanetRadius(2000)
function Entity:setPlanetRadius(size)
    local pr = self.components.planet_render
    if pr then
        pr.size = size
        pr.cloud_size = size*1.05
        pr.atmosphere_size = size*1.2
        if (pr.size * pr.size) > (pr.distance_from_movement_plane * pr.distance_from_movement_plane) then
            local collision_size = math.sqrt((pr.size * pr.size) - (pr.distance_from_movement_plane * pr.distance_from_movement_plane)) * 1.1;
            self.components.physics = {type="static", size=collision_size}
        else
            self.components.physics = nil
        end
    end
    return self
end
--- Sets this Planet's collision radius.
--- Defaults to a function of the Planet's radius and its z-position.
--- AI behaviors use this size to plot routes that try to avoid colliding with this Planet.
--- Example: planet:getCollisionSize()
function Entity:getCollisionSize()
    if self.components.physics then
        return self.components.physics.size
    end
    return 0.0
end
--- Sets this Planet's cloud radius, overriding Planet:setPlanetRadius().
--- Defaults to 1.05x this Planet's radius.
--- If this value isn't larger than the Planet's radius, the cloud layer won't be visible.
--- Example: planet:setPlanetCloudRadius(2500) -- sets this Planet's cloud radius to 2.5U
function Entity:setPlanetCloudRadius(radius)
    if self.components.planet_render then self.components.planet_render.cloud_size = radius end
    return self
end
--- Sets the z-position of this Planet, the distance by which it's offset above (positive) or below (negative) the movement plane.
--- This value also modifies the Planet's collision radius.
--- Defaults to 0.
--- Example: planet:setDistanceFromMovementPlane(-500) -- sets the planet 0.5U below the movement plane
function Entity:setDistanceFromMovementPlane(z)
    local pr = self.components.planet_render
    if pr then
        pr.distance_from_movement_plane = z
        if (pr.size * pr.size) > (pr.distance_from_movement_plane * pr.distance_from_movement_plane) then
            local collision_size = math.sqrt((pr.size * pr.size) - (pr.distance_from_movement_plane * pr.distance_from_movement_plane)) * 1.1;
            self.components.physics = {type="static", size=collision_size}
        else
            self.components.physics = nil
        end
    end
    return self
end
--- Sets this Planet's axial rotation time, seconds per full rotation.
--- Defaults to 0.
--- Example: planet:setAxialRotationTime(20)
function Entity:setAxialRotationTime(rotation_time)
    if rotation_time ~= 0.0 then
        self.components.spin = {rate=360.0/rotation_time}
    else
        self.components.spin = nil
    end
    return self
end
--- Sets a SpaceObject around which this SpaceObject orbits, as well as its orbital period in seconds. Setting time to 0 will stop movement, while still being locked in orbit.
--- An orbit can be cancelled by setting the target to nil
--- Example:
--- moon:setOrbit(planet, 20)
--- moon:setOrbit(nil) -- undo orbiting
function Entity:setOrbit(target, time)
    if target == nil then
        self.components.orbit = nil
        return self
    end
    local x0, y0 = self:getPosition()
    local x1, y1 = target:getPosition()
    local xd, yd = (x1 - x0), (y1 - y0)
    local distance = math.sqrt(xd * xd + yd * yd)
    self.components.orbit = {
        target = target,
        center = {x1, y1},
        distance = distance,
        time = time,
    }
    return self
end
