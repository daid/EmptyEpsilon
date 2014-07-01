#include <SFML/OpenGL.hpp>
#include "EMPMissile.h"
#include "particleEffect.h"
#include "electricExplosionEffect.h"

REGISTER_MULTIPLAYER_CLASS(EMPMissile, "EMPMissile");
EMPMissile::EMPMissile()
: SpaceObject(10, "EMPMissile")
{
    lifetime = totalLifetime;
    registerMemberReplication(&target_id);
}

void EMPMissile::draw3D()
{
    sf::Shader::bind(NULL);
    glColor3f(1, 1, 1);
    glBegin(GL_POINTS);
    glVertex3f(0, 0, 0);
    glEnd();
}

void EMPMissile::draw3DTransparent()
{
}

void EMPMissile::drawRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range)
{
    if (long_range) return;

    sf::Sprite objectSprite;
    textureManager.setTexture(objectSprite, "RadarArrow.png");
    objectSprite.setRotation(getRotation());
    objectSprite.setPosition(position);
    objectSprite.setColor(sf::Color(100, 32, 255));
    objectSprite.setScale(0.6, 0.6);
    window.draw(objectSprite);
}

void EMPMissile::update(float delta)
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
    
    if (delta > 0 && lifetime == totalLifetime)
        soundManager.playSound("missile_launch.wav", getPosition(), 200.0, 1.0);
    lifetime -= delta;
    if (lifetime < 0)
        destroy();
    setVelocity(sf::vector2FromAngle(getRotation()) * speed);

    if (delta > 0)
        ParticleEngine::spawn(sf::Vector3f(getPosition().x, getPosition().y, 0), sf::Vector3f(getPosition().x, getPosition().y, 0), sf::Vector3f(1, 1, 1), sf::Vector3f(0, 0, 0), 5, 20, 5.0);
}

void EMPMissile::collision(Collisionable* target)
{
    if (!gameServer)
        return;
    P<SpaceObject> hitObject = P<Collisionable>(target);
    if (!hitObject || hitObject == owner || !hitObject->canBeTargeted())
        return;
    
    SpaceObject::damageArea(getPosition(), blastRange, damageAtEdge, damageAtCenter, DT_EMP, getRadius());

    P<ElectricExplosionEffect> e = new ElectricExplosionEffect();
    e->setSize(blastRange);
    e->setPosition(getPosition());
    destroy();
}
