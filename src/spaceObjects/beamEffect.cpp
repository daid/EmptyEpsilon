/*TODO
/// A BeamEffect is a beam weapon firing audio/visual effect that fades after its duration expires.
/// This is a cosmetic effect and does not deal damage on its own.
/// Example: beamfx = BeamEffect():setSource(player,0,0,0):setTarget(enemy,0,0,0)
REGISTER_SCRIPT_SUBCLASS_NAMED(BeamEffectLegacy, SpaceObject, "BeamEffect")
{
    /// Sets the BeamEffect's origin SpaceObject.
    /// Requires a 3D x/y/z vector positional offset relative to the object's origin point.
    /// Example: beamfx:setSource(0,0,0)
    //TODO: REGISTER_SCRIPT_CLASS_FUNCTION(BeamEffect, setSource);
    /// Sets the BeamEffect's target SpaceObject.
    /// Requires a 3D x/y/z vector positional offset relative to the object's origin point.
    /// Example: beamfx:setTarget(target,0,0,0)
    //TODO: REGISTER_SCRIPT_CLASS_FUNCTION(BeamEffect, setTarget);
    /// Sets the BeamEffect's texture.
    /// Valid values are filenames of PNG files relative to the resources/ directory.
    /// Defaults to "texture/beam_orange.png".
    /// Example: beamfx:setTexture("beam_blue.png")
    REGISTER_SCRIPT_CLASS_FUNCTION(BeamEffectLegacy, setTexture);
    /// Sets the BeamEffect's sound effect.
    /// Valid values are filenames of WAV files relative to the resources/ directory.
    /// Defaults to "sfx/laser_fire.wav".
    /// Example: beamfx:setBeamFireSound("sfx/hvli_fire.wav")
    REGISTER_SCRIPT_CLASS_FUNCTION(BeamEffectLegacy, setBeamFireSound);
    /// Sets the magnitude of the BeamEffect's sound effect.
    /// Defaults to 1.0.
    /// Larger values are louder and can be heard from larger distances.
    /// This value also affects the sound effect's pitch.
    /// Example: beamfx:setBeamFireSoundPower(0.5)
    REGISTER_SCRIPT_CLASS_FUNCTION(BeamEffectLegacy, setBeamFireSoundPower);
    /// Sets the BeamEffect's duration, in seconds.
    /// Defaults to 1.0.
    /// Example: beamfx:setDuration(1.5)
    REGISTER_SCRIPT_CLASS_FUNCTION(BeamEffectLegacy, setDuration);
    /// Defines whether the BeamEffect generates an impact ring on the target end.
    /// Defaults to true.
    /// Example: beamfx:setRing(false)
    REGISTER_SCRIPT_CLASS_FUNCTION(BeamEffectLegacy, setRing);
}
*/
