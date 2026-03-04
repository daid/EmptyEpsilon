require("utils.lua")

--- A HomingMissile is a missile that pursues a target and deals kinetic damage on impact.
--- Homing missiles can be fired via weapon tubes or created directly by scripts.
--- Example: missile = HomingMissile():setHomingTarget(getPlayerShip(-1)):setPosition(1000, 1000):setRotation(90)
--- @type creation
function HomingMissile()
    local e = createEntity()
    e.components = {
        transform = {},
        physics = {
            type = "sensor",
            size = {10, 30}
        },
        missile_flight = {speed = 200.0},
        missile_homing = {
            turn_rate = 10.0,
            range = 1200.0,
            target_angle = 0.0
        },
        explode_on_touch = {
            damage_at_center = 35.0,
            damage_at_edge = 5.0,
            blast_range = 30.0,
            explosion_sfx = "sfx/explosion.wav"
        },
        lifetime = {lifetime = 27.0},
        constant_particle_emitter = {},
        radar_trace = {
            icon = "radar/missile.png",
            min_size = 16,
            max_size = 16,
            rotate = true,
            color = {255, 200, 0, 255}
        },
        radar_signature = {
            electrical = 0.1,
            biological = 0.2
        }
    }
    return e
end

--- An HVLI (High-Velocity Lead Impactor) is an unguided kinetic missile.
--- HVLIs can be fired via weapon tubes or created directly by scripts.
--- Example: hvli = HVLI():setPosition(1000, 1000):setRotation(90)
--- @type creation
function HVLI()
    local e = createEntity()
    e.components = {
        transform = {},
        physics = {
            type = "sensor",
            size = {10, 30}
        },
        missile_flight = {speed = 500.0},
        explode_on_touch = {
            damage_at_center = 10.0,
            damage_at_edge = 10.0,
            blast_range = 20.0,
            explosion_sfx = "sfx/explosion.wav"
        },
        lifetime = {lifetime = 13.5},
        constant_particle_emitter = {},
        radar_trace = {
            icon = "radar/missile.png",
            min_size = 16,
            max_size = 16,
            rotate = true,
            color = {200, 200, 200, 255}
        },
        radar_signature = {gravity = 0.1}
    }
    return e
end

--- An EMPMissile is a homing missile with a large blast range that deals significant EMP area damage on impact or timeout.
--- AI behaviors attempt to avoid EMPMissiles.
--- EMPMissiles can be fired via weapon tubes or created directly by scripts.
--- Example: emp = EMPMissile():setPosition(1000, 1000):setRotation(90)
--- @type creation
function EMPMissile()
    local e = createEntity()
    e.components = {
        transform = {},
        physics = {
            type = "sensor",
            size = {10, 30}
        },
        missile_flight = {speed = 200.0},
        missile_homing = {
            turn_rate = 10.0,
            range = 500.0,
            target_angle = 0.0
        },
        explode_on_touch = {
            damage_at_center = 160.0,
            damage_at_edge = 30.0,
            blast_range = 1000.0,
            damage_type = "emp",
            explosion_sfx = "sfx/emp_explosion.wav"
        },
        explode_on_timeout = {},
        lifetime = {lifetime = 27.0},
        constant_particle_emitter = {},
        radar_trace = {
            icon = "radar/missile.png",
            min_size = 16,
            max_size = 16,
            rotate = true,
            color = {100, 32, 255, 255}
        },
        radar_signature = {electrical = 1.0}
    }
    return e
end

--- An Nuke is a homing missile with a large blast range that deals significant kinetic area damage on impact or timeout.
--- AI behaviors attempt to avoid Nukes.
--- Nukes can be fired via weapon tubes or created directly by scripts.
--- Example: nuke = Nuke():setPosition(1000, 1000):setRotation(90)
--- @type creation
function Nuke()
    local e = createEntity()
    e.components = {
        transform = {},
        physics = {
            type = "sensor",
            size = {10, 30}
        },
        missile_flight = {speed = 200.0},
        missile_homing = {
            turn_rate = 10.0,
            range = 500.0,
            target_angle = 0.0
        },
        explode_on_touch = {
            damage_at_center = 160.0,
            damage_at_edge = 30.0,
            blast_range = 1000.0,
            explosion_sfx = "sfx/nuke_explosion.wav"
        },
        explode_on_timeout = {},
        delayed_avoid_object = {
            delay = 10.0,
            range = 1000.0
        },
        lifetime = {lifetime = 27.0},
        constant_particle_emitter = {},
        radar_trace = {
            icon = "radar/missile.png",
            min_size = 16,
            max_size = 16,
            rotate = true,
            color = {255, 100, 32, 255}
        },
        radar_signature = {
            electrical = 0.7,
            biological = 0.1
        }
    }
    return e
end

local Entity = getLuaEntityFunctionTable()

--- Set the target entity for this homing missile.
--- Example: homing:setHomingTarget(player)
function Entity:setHomingTarget(target_entity)
    if self.components.missile_homing and target_entity and target_entity:isValid() then
        self.components.missile_homing.target = target_entity
        self.components.missile_homing.target_angle = angleRotation(self, target_entity)
    end
    return self
end
