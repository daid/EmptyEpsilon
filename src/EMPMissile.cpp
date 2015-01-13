#include <SFML/OpenGL.hpp>
#include "EMPMissile.h"
#include "particleEffect.h"
#include "electricExplosionEffect.h"

REGISTER_MULTIPLAYER_CLASS(EMPMissile, "EMPMissile");
EMPMissile::EMPMissile()
: SpaceObject(10, "EMPMissile")
{
    lifetime = total_lifetime;
    registerMemberReplication(&target_id);
}

void EMPMissile::draw3D()
{
}

void EMPMissile::draw3DTransparent()
{
}

void EMPMissile::drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range)
{
    if (long_range) return;

    sf::Sprite objectSprite;
    textureManager.setTexture(objectSprite, "RadarArrow.png"); //TODO; Hardcoded
    objectSprite.setRotation(getRotation());
    objectSprite.setPosition(position);
    objectSprite.setColor(sf::Color(100, 32, 255));
    objectSprite.setScale(0.6, 0.6);
    window.draw(objectSprite);
}

void EMPMissile::update(float delta)
{
    P<SpaceObject> target;
    if (game_server)
        target = game_server->getObjectById(target_id);
    else
        target = game_client->getObjectById(target_id);
    if (target)
    {
        float angle_diff = sf::angleDifference(getRotation(), sf::vector2ToAngle(target->getPosition() - getPosition()));

        if (angle_diff > 1.0)
            setAngularVelocity(turn_speed);
        else if (angle_diff < -1.0)
            setAngularVelocity(turn_speed * -1.0f);
        else
            setAngularVelocity(angle_diff * turn_speed);
    }else{
        setAngularVelocity(0);
    }

    if (delta > 0 && lifetime == total_lifetime)
        soundManager.playSound("missile_launch.wav", getPosition(), 200.0, 1.0);
    lifetime -= delta;
    if (lifetime < 0)
        destroy();
    setVelocity(sf::vector2FromAngle(getRotation()) * speed);

    if (delta > 0)
        ParticleEngine::spawn(sf::Vector3f(getPosition().x, getPosition().y, 0), sf::Vector3f(getPosition().x, getPosition().y, 0), sf::Vector3f(0.5, 0.5, 1), sf::Vector3f(0, 0, 0), 8, 30, 5.0);
}

void EMPMissile::collision(Collisionable* target)
{
    if (!game_server)
        return;
    P<SpaceObject> hitObject = P<Collisionable>(target);
    if (!hitObject || hitObject == owner || !hitObject->canBeTargeted())
        return;

    DamageInfo info(DT_EMP, getPosition());
    SpaceObject::damageArea(getPosition(), blastRange, damageAtEdge, damageAtCenter, info, getRadius());

    P<ElectricExplosionEffect> e = new ElectricExplosionEffect();
    e->setSize(blastRange);
    e->setPosition(getPosition());
    destroy();
}
