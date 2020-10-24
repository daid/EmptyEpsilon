#include <SFML/OpenGL.hpp>
#include "scanProbe.h"
#include "explosionEffect.h"
#include "main.h"

#include "scriptInterface.h"

/// A scan probe.
REGISTER_SCRIPT_SUBCLASS_NO_CREATE(ScanProbe, SpaceObject)
{
    // Callback when the probe's lifetime expires.
    // Returns the probe.
    // Example: probe:onExpiration(probeExpired)
    REGISTER_SCRIPT_CLASS_FUNCTION(ScanProbe, onExpiration);
    // Callback when the probe is destroyed by damage.
    // Returns the probe and instigator.
    // Example: probe:onDestruction(probeDestroyed)
    REGISTER_SCRIPT_CLASS_FUNCTION(ScanProbe, onDestruction);
}

REGISTER_MULTIPLAYER_CLASS(ScanProbe, "ScanProbe");
ScanProbe::ScanProbe()
: SpaceObject(100, "ScanProbe")
{
    lifetime = 60 * 10;

    registerMemberReplication(&owner_id);
    registerMemberReplication(&target_position);
    registerMemberReplication(&lifetime, 60.0);
    setRadarSignatureInfo(0.0, 0.2, 0.0);

    switch(irandom(1, 3))
    {
    case 1:
        model_info.setData("SensorBuoyMKI");
        break;
    case 2:
        model_info.setData("SensorBuoyMKII");
        break;
    default:
        model_info.setData("SensorBuoyMKIII");
        break;
    }

    setCallSign(string(getMultiplayerId()) + "P");
}

//due to a suspected compiler bug this deconstructor needs to be explicitly defined
ScanProbe::~ScanProbe()
{
}

void ScanProbe::update(float delta)
{
    lifetime -= delta;
    if (lifetime <= 0.0)
    {
        if (on_expiration.isSet())
            on_expiration.call(P<ScanProbe>(this));

        destroy();
    }
    if ((target_position - getPosition()) > getRadius())
    {
        sf::Vector2f v = normalize(target_position - getPosition());
        setPosition(getPosition() + v * delta * probe_speed);
    }
}

bool ScanProbe::canBeTargetedBy(P<SpaceObject> other)
{
    return (getTarget() - getPosition()) < getRadius();
}

void ScanProbe::takeDamage(float damage_amount, DamageInfo info)
{
    if (on_destruction.isSet())
    {
        on_destruction.call(P<ScanProbe>(this), P<SpaceObject>(info.instigator));
    }
    destroy();
}

void ScanProbe::drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range)
{
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
    if (!owner) return;

    setFactionId(owner->getFactionId());
    owner_id = owner->getMultiplayerId();
}

void ScanProbe::onDestruction(ScriptSimpleCallback callback)
{
    this->on_destruction = callback;
}

void ScanProbe::onExpiration(ScriptSimpleCallback callback)
{
    this->on_expiration = callback;
}
