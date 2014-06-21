#include <SFML/OpenGL.hpp>
#include "homingMissile.h"

REGISTER_MULTIPLAYER_CLASS(HomingMissile, "HomingMissile");
HomingMissile::HomingMissile()
: SpaceObject(10, "HomingMissile")
{
    lifetime = totalLifetime;
    registerMemberReplication(&target_id);
}

void HomingMissile::draw3D()
{
    glBegin(GL_LINES);
    glVertex3f(0, 0, 0);
    glVertex3f(10, 0, 0);
    glEnd();
}

void HomingMissile::draw3DTransparent()
{
}

void HomingMissile::drawRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range)
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

void HomingMissile::update(float delta)
{
    P<SpaceObject> target;
    if (gameServer)
        target = gameServer->getObjectById(target_id);
    else
        target = gameClient->getObjectById(target_id);
    if (target)
    {
        float angleDiff = sf::angleDifference(getRotation(), sf::vector2ToAngle(target->getPosition() - getPosition()));
        
        if (angleDiff > 1.0)
            setAngularVelocity(turnSpeed);
        else if (angleDiff < -1.0)
            setAngularVelocity(turnSpeed * -1.0f);
        else
            setAngularVelocity(angleDiff * turnSpeed);
    }else{
        setAngularVelocity(0);
    }
    
    lifetime -= delta;
    if (lifetime < 0)
        destroy();
    setVelocity(sf::vector2FromAngle(getRotation()) * speed);
}

void HomingMissile::collision(Collisionable* target)
{
    if (!gameServer)
        return;
    P<SpaceObject> hitObject = P<Collisionable>(target);
    if (!hitObject || hitObject == owner)
        return;
    hitObject->takeDamage(20, getPosition(), DT_Kinetic);
    destroy();
}
