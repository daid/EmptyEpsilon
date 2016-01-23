#include <SFML/OpenGL.hpp>
#include "scanProbe.h"
#include "explosionEffect.h"
#include "main.h"

#include "scriptInterface.h"

REGISTER_MULTIPLAYER_CLASS(ScanProbe, "ScanProbe");
ScanProbe::ScanProbe()
: SpaceObject(100, "ScanProbe")
{
    lifetime = 60 * 10;

    registerMemberReplication(&owner_id);
    registerMemberReplication(&target_position);
    registerMemberReplication(&lifetime, 60.0);
}

void ScanProbe::update(float delta)
{
    lifetime -= delta;
    if (lifetime <= 0.0)
        destroy();
    if ((target_position - getPosition()) > getRadius())
    {
        sf::Vector2f v = normalize(target_position - getPosition());
        setPosition(getPosition() + v * delta * probe_speed);
    }
}

void ScanProbe::drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range)
{
    sf::Sprite object_sprite;
    textureManager.setTexture(object_sprite, "ProbeBlip.png");
    object_sprite.setPosition(position);
    object_sprite.setColor(sf::Color(96, 192, 128));
    float size = 0.3;
    object_sprite.setScale(size, size);
    window.draw(object_sprite);
}

void ScanProbe::setOwner(P<SpaceObject> owner)
{
    if (!owner) return;

    setFaction("Independent");
    owner_id = owner->getMultiplayerId();
}
