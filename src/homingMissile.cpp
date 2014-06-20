#include <SFML/OpenGL.hpp>
#include "homingMissile.h"

REGISTER_MULTIPLAYER_CLASS(HomingMissle, "HomingMissile");
HomingMissle::HomingMissle()
: SpaceObject(2, "HomingMissile")
{
    lifetime = totalLifetime;
    registerMemberReplication(&target_id);
}

void HomingMissle::draw3D()
{
    glBegin(GL_LINES);
    glVertex3f(0, 0, 0);
    glVertex3f(2, 0, 0);
    glEnd();
}

void HomingMissle::draw3DTransparent()
{
}

void HomingMissle::drawRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range)
{
    if (long_range) return;

    sf::Sprite objectSprite;
    textureManager.setTexture(objectSprite, "RadarArrow.png");
    objectSprite.setRotation(getRotation());
    objectSprite.setPosition(position);
    objectSprite.setColor(sf::Color(255, 200, 0));
    objectSprite.setScale(0.5, 0.5);
    window.draw(objectSprite);
}

void HomingMissle::update(float delta)
{
    lifetime -= delta;
    if (lifetime < 0)
        destroy();
    setVelocity(sf::vector2FromAngle(getRotation()) * speed);
}
