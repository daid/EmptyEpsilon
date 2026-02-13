--- A BeamEffect is a beam weapon firing audio/visual effect that fades after its duration expires.
--- This is a cosmetic effect and does not deal damage on its own.
--- Example: beamfx = BeamEffect():setSource(player,0,0,0):setTarget(enemy,0,0,0)
function BeamEffect()
    local e = createEntity()
    e.components = {
        transform = {},
        beam_effect = {beam_texture = "texture/beam_orange.png"},
    }
    return e
end

local Entity = getLuaEntityFunctionTable()
--- Sets the BeamEffect's origin entity.
--- Requires a 3D x/y/z vector positional offset relative to the object's origin point.
--- Example: beamfx:setSource(source, 0,0,0)
function Entity:setSource(source, x, y, z)
    if self.components.beam_effect then
        self.components.beam_effect.source = source
        self.components.beam_effect.source_offset = {x, y, z}
    end
    return self
end
--- Sets the BeamEffect's texture.
--- Valid values are filenames of PNG files relative to the resources/ directory.
--- Defaults to "texture/beam_orange.png".
--- Example: beamfx:setTexture("beam_blue.png")
function Entity:setTexture(texture)
    if self.components.beam_effect then
        self.components.beam_effect.beam_texture = texture
    end
    return self
end
--- [NOT YET IMPLEMENTED]
--- Intended to set the BeamEffect's sound effect.
--- Valid values are filenames of WAV files relative to the resources/ directory.
--- Defaults to "sfx/laser_fire.wav".
--- Example: beamfx:setBeamFireSound("sfx/hvli_fire.wav")
function Entity:setBeamFireSound()
    --TODO
    return self
end
--- [NOT YET IMPLEMENTED]
--- Intended to set the magnitude of the BeamEffect's sound effect.
--- Defaults to 1.0.
--- Larger values are louder and can be heard from larger distances.
--- This value also affects the sound effect's pitch.
--- Example: beamfx:setBeamFireSoundPower(0.5)
function Entity:setBeamFireSoundPower(level)
    --TODO
    return self
end
--- Sets the BeamEffect's duration, in seconds.
--- Defaults to 1.0.
--- Example: beamfx:setDuration(1.5)
function Entity:setDuration(duration)
    if self.components.beam_effect then
        self.components.beam_effect.lifetime = duration
    end
    return self
end
--- Defines whether the BeamEffect generates an impact ring on the target end.
--- Defaults to true.
--- Example: beamfx:setRing(false)
function Entity:setRing(enabled)
    if self.components.beam_effect then
        self.components.beam_effect.fire_ring = enabled
    end
    return self
end
