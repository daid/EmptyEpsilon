#include <SFML/OpenGL.hpp>
#include "nuke.h"
#include "particleEffect.h"
#include "explosionEffect.h"

REGISTER_MULTIPLAYER_CLASS(Nuke, "Nuke");
Nuke::Nuke()
: SpaceObject(10, "Nuke")
{
    lifetime = totalLifetime;
    registerMemberReplication(&target_id);
}

void Nuke::draw3D()
{
}

void Nuke::draw3DTransparent()
{
}

void Nuke::drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range)
{
    if (long_range) return;

    sf::Sprite objectSprite;
    textureManager.setTexture(objectSprite, "RadarArrow.png");
    objectSprite.setRotation(getRotation());
    objectSprite.setPosition(position);
    objectSprite.setColor(sf::Color(255, 100, 32));
    objectSprite.setScale(0.6, 0.6);
    window.draw(objectSprite);
}

void Nuke::update(float delta)
{
    P<SpaceObject> target;
    if (game_server)
        target = game_server->getObjectById(target_id);
    else
        target = game_client->getObjectById(target_id);
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
        ParticleEngine::spawn(sf::Vector3f(getPosition().x, getPosition().y, 0), sf::Vector3f(getPosition().x, getPosition().y, 0), sf::Vector3f(1, 0.5, 0.5), sf::Vector3f(0, 0, 0), 8, 30, 5.0);
}

void Nuke::collision(Collisionable* target)
{
    if (!game_server)
        return;
    P<SpaceObject> hitObject = P<Collisionable>(target);
    if (!hitObject || hitObject == owner || !hitObject->canBeTargeted())
        return;

    SpaceObject::damageArea(getPosition(), blastRange, damageAtEdge, damageAtCenter, DT_Kinetic, getRadius());

    P<ExplosionEffect> e = new ExplosionEffect();
    e->setSize(blastRange);
    e->setPosition(getPosition());
    destroy();
}
