#include <SFML/OpenGL.hpp>
#include "Nuke.h"
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
    sf::Shader::bind(NULL);
    glColor3f(1, 1, 1);
    glBegin(GL_POINTS);
    glVertex3f(0, 0, 0);
    glEnd();
}

void Nuke::draw3DTransparent()
{
}

void Nuke::drawRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range)
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

void Nuke::collision(Collisionable* target)
{
    if (!gameServer)
        return;
    P<SpaceObject> hitObject = P<Collisionable>(target);
    if (!hitObject || hitObject == owner)
        return;
    PVector<Collisionable> hitList = CollisionManager::queryArea(getPosition() - sf::Vector2f(blastRange, blastRange), getPosition() + sf::Vector2f(blastRange, blastRange));
    foreach(Collisionable, c, hitList)
    {
        P<SpaceObject> obj = c;
        if (obj)
        {
            float dist = sf::length(getPosition() - obj->getPosition()) - obj->getRadius();
            if (dist < 0) dist = 0;
            if (dist < blastRange)
            {
                printf("Damage: %f\n", damageAtCenter - (damageAtCenter - damageAtEdge) * dist / blastRange);
                obj->takeDamage(damageAtCenter - (damageAtCenter - damageAtEdge) * dist / blastRange, getPosition(), DT_Kinetic);
            }
        }
    }

    P<ExplosionEffect> e = new ExplosionEffect();
    e->setSize(blastRange);
    e->setPosition(getPosition());
    destroy();
}
