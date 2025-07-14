--- An ExplosionEffect is a visual explosion used by nukes, homing missiles, ship destruction, and other similar events.
--- This is a cosmetic effect and does not deal damage on its own.
--- See also the ElectricExplosionEffect class for EMP missile effects.
--- Example: explosion = ExplosionEffect():setPosition(500,5000):setSize(20):setOnRadar(true)
function ExplosionEffect()
    local e = createEntity()
    e.components = {
        transform = {},
        explosion_effect = {size=1.0, radar=false},
        sfx = {sound="sfx/explosion.wav"},
    }
    return e
end

--- An ElectricExplosionEffect is a visual electrical explosion used by EMP missiles.
--- This is a cosmetic effect and does not deal damage on its own.
--- See also the ExplosionEffect class for conventional explosion effects.
--- Example: elec_explosion = ElectricExplosionEffect():setPosition(500,5000):setSize(20):setOnRadar(true)
function ElectricExplosionEffect()
    local e = createEntity()
    e.components = {
        transform = {},
        explosion_effect = {size=1.0, radar=false, electrical=true},
        sfx = {sound="sfx/emp_explosion.wav"},
    }
    return e
end

local Entity = getLuaEntityFunctionTable()
-- Defines whether to draw the ExplosionEffect on short-range radar.
-- Defaults to false.
-- Example: explosion:setOnRadar(true)
function Entity:setOnRadar(is_on_radar)
    if self.components.explosion_effect then self.components.explosion_effect.radar = is_on_radar end
    return self
end
