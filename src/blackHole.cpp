#include "blackHole.h"
#include "pathPlanner.h"

#include "scriptInterface.h"
REGISTER_SCRIPT_SUBCLASS(BlackHole, SpaceObject)
{
}

REGISTER_MULTIPLAYER_CLASS(BlackHole, "BlackHole");
BlackHole::BlackHole()
: SpaceObject(5000, "BlackHole")
{
    update_delta = 0.0;
    PathPlanner::addAvoidObject(this, 7000);
}

void BlackHole::update(float delta)
{
    update_delta = delta;
}

void BlackHole::draw3D()
{
}

void BlackHole::drawRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range)
{
    sf::Sprite object_sprite;
    textureManager.setTexture(object_sprite, "RadarBlip.png");
    object_sprite.setRotation(getRotation());
    object_sprite.setPosition(position);
    float size = getRadius() * scale / object_sprite.getTextureRect().width * 2;
    object_sprite.setScale(size, size);
    object_sprite.setColor(sf::Color(64, 64, 255));
    window.draw(object_sprite);
    object_sprite.setColor(sf::Color(0, 0, 0));
    window.draw(object_sprite);
}

void BlackHole::collision(Collisionable* target)
{
    if (update_delta == 0.0)
        return;
    
    sf::Vector2f diff = getPosition() - target->getPosition();
    float distance = sf::length(diff);
    float force = (getRadius() * getRadius() * 50.0f) / (distance * distance);
    if (force > 10000.0)
    {
        force = 10000.0;
        if (isServer())
            target->destroy();
    }
    if (force > 100.0 && isServer())
    {
        P<SpaceObject> obj = P<Collisionable>(target);
        if (obj)
            obj->takeDamage(force * update_delta / 10.0f, getPosition(), DT_Kinetic);
    }
    target->setPosition(target->getPosition() + diff / distance * update_delta * force);
}
