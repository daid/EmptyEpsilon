#include <SFML/OpenGL.hpp>
#include "scanProbe.h"
#include "explosionEffect.h"
#include "main.h"

#include "scriptInterface.h"

/// A scan probe.
REGISTER_SCRIPT_SUBCLASS_NO_CREATE(ScanProbe, SpaceObject)
{
    /// Set the probe's speed. A value of 1000 = 1U/second.
    /// Probes move at a fixed rate of speed and ignore physics.
    /// Requires a float value. The default vaule is 1000.
    /// Example: probe:setSpeed(2000)
    REGISTER_SCRIPT_CLASS_FUNCTION(ScanProbe, setSpeed);
    /// Get the probe's speed. A value of 1000 = 1U/second.
    /// Returns a float value.
    /// Example: local speed = probe:getSpeed()
    REGISTER_SCRIPT_CLASS_FUNCTION(ScanProbe, getSpeed);
    /// Set the probe's remaining lifetime, in seconds.
    /// The default initial lifetime is 10 minutes.
    /// Example: probe:setLifetime(60 * 5)
    REGISTER_SCRIPT_CLASS_FUNCTION(ScanProbe, setLifetime);
    /// Get the probe's remaining lifetime.
    /// Example: local lifetime = probe:getLifetime()
    REGISTER_SCRIPT_CLASS_FUNCTION(ScanProbe, getLifetime);
    /// Set the probe's target coordinates.
    /// Example: probe:setTarget(1000, 5000)
    REGISTER_SCRIPT_CLASS_FUNCTION(ScanProbe, setTarget);
    /// Get the probe's target coordinates.
    /// Example: local targetX, targetY = probe:getTarget()
    REGISTER_SCRIPT_CLASS_FUNCTION(ScanProbe, getTarget);
    /// Get the probe's owner SpaceObject.
    /// Example: local owner_ship = probe:getOwner()
    REGISTER_SCRIPT_CLASS_FUNCTION(ScanProbe, getOwner);
    /// Callback when the probe arrives to its target coordinates.
    /// Passes the probe and position as arguments to the callback.
    /// Example: probe:onArrival(probeArrived)
    REGISTER_SCRIPT_CLASS_FUNCTION(ScanProbe, onArrival);
    /// Callback when the probe's lifetime expires.
    /// Passes the probe as an argument to the callback.
    /// Example: probe:onExpiration(probeExpired)
    REGISTER_SCRIPT_CLASS_FUNCTION(ScanProbe, onExpiration);
    /// Callback when the probe is destroyed by damage.
    /// Passes the probe and instigator as arguments to the callback.
    /// Example: probe:onDestruction(probeDestroyed)
    REGISTER_SCRIPT_CLASS_FUNCTION(ScanProbe, onDestruction);
}

REGISTER_MULTIPLAYER_CLASS(ScanProbe, "ScanProbe");
ScanProbe::ScanProbe()
: SpaceObject(100, "ScanProbe"),
  probe_speed(1000.0f)
{
    // Probe persists for 10 minutes.
    lifetime = 60 * 10;
    // Probe has not arrived yet.
    has_arrived = false;

    registerMemberReplication(&owner_id);
    registerMemberReplication(&target_position);
    registerMemberReplication(&lifetime, 60.0);

    // Give the probe a small electrical radar signature.
    setRadarSignatureInfo(0.0, 0.2, 0.0);

    // Randomly select a probe model.
    switch(irandom(1, 3))
    {
        case 1:
        {
            model_info.setData("SensorBuoyMKI");
            break;
        }
        case 2:
        {
            model_info.setData("SensorBuoyMKII");
            break;
        }
        default:
        {
            model_info.setData("SensorBuoyMKIII");
        }
    }

    // Assign a generic callsign.
    setCallSign(string(getMultiplayerId()) + "P");
}

// Due to a suspected compiler bug, this deconstructor must be explicitly
// defined.
ScanProbe::~ScanProbe()
{
}

void ScanProbe::setSpeed(float probe_speed)
{
    this->probe_speed = probe_speed > 0.0f ? probe_speed : 0.0f;
}

float ScanProbe::getSpeed()
{
    return this->probe_speed;
}

void ScanProbe::setLifetime(float lifetime)
{
    this->lifetime = lifetime > 0.0f ? lifetime : 0.0f;
}

float ScanProbe::getLifetime()
{
    return this->lifetime;
}

void ScanProbe::update(float delta)
{
    // Tick down lifetime until expiration, then destroy the probe.
    lifetime -= delta;

    if (lifetime <= 0.0)
    {
        // Fire the onExpiration callback, if set.
        if (on_expiration.isSet())
        {
            on_expiration.call(P<ScanProbe>(this));
        }

        destroy();
    }

    // The probe moves in a straight line to its destination, independent of
    // physics and at a fixed rate of speed.
    if ((target_position - getPosition()) > getRadius())
    {
        // The probe is in transit.
        has_arrived = false;
        sf::Vector2f v = normalize(target_position - getPosition());
        setPosition(getPosition() + v * delta * probe_speed);
        setHeading(vector2ToAngle(v) + 90.0f);
    }
    else if (!has_arrived)
    {
        // The probe arrived to its destination.
        has_arrived = true;

        // Fire the onArrival callback, if set.
        if (on_arrival.isSet())
        {
            on_arrival.call(P<ScanProbe>(this), getPosition().x, getPosition().y);
        }
    }
}

bool ScanProbe::canBeTargetedBy(P<SpaceObject> other)
{
    // The probe cannot be targeted until it reaches its destination.
    return (getTarget() - getPosition()) < getRadius();
}

void ScanProbe::takeDamage(float damage_amount, DamageInfo info)
{
    // Fire the onDestruction callback, if set. Pass the damage instigator if
    // there was one.
    if (on_destruction.isSet())
    {
        if (info.instigator)
        {
            on_destruction.call(P<ScanProbe>(this), P<SpaceObject>(info.instigator));
        }
        else
        {
            on_destruction.call(P<ScanProbe>(this));
        }
    }

    // Any amount of damage instantly destroys the probe.
    destroy();
}

void ScanProbe::drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range)
{
    // All probes use the same green icon on radar.
    sf::Sprite object_sprite;
    textureManager.setTexture(object_sprite, "ProbeBlip.png");
    object_sprite.setPosition(position);
    object_sprite.setColor(sf::Color(96, 192, 128));
    float size = 0.3;
    object_sprite.setScale(size, size);
    window.draw(object_sprite);
}

void ScanProbe::drawOnGMRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range)
{
    SpaceObject::drawOnGMRadar(window, position, scale, rotation, long_range);

    if (long_range)
    {
        // Draw a circle on the GM radar representing the probe's fixed 5U
        // radar radius.
        sf::CircleShape radar_radius(5000 * scale);
        radar_radius.setOrigin(5000 * scale, 5000 * scale);
        radar_radius.setPosition(position);
        radar_radius.setFillColor(sf::Color::Transparent);
        radar_radius.setOutlineColor(sf::Color(255, 255, 255, 64));
        radar_radius.setOutlineThickness(3.0);
        window.draw(radar_radius);
    }
}

void ScanProbe::setOwner(P<SpaceObject> owner)
{
    if (!owner)
    {
        return;
    }

    // Set the probe's faction and ship ownership based on the passed object.
    setFactionId(owner->getFactionId());
    owner_id = owner->getMultiplayerId();
}

void ScanProbe::onArrival(ScriptSimpleCallback callback)
{
    this->on_arrival = callback;
}

void ScanProbe::onDestruction(ScriptSimpleCallback callback)
{
    this->on_destruction = callback;
}

void ScanProbe::onExpiration(ScriptSimpleCallback callback)
{
    this->on_expiration = callback;
}
