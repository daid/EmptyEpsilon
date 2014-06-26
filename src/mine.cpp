#include <SFML/OpenGL.hpp>
#include "mine.h"
#include "playerInfo.h"
#include "explosionEffect.h"

REGISTER_MULTIPLAYER_CLASS(Mine, "Mine");
Mine::Mine()
: SpaceObject(800, "Mine")
{
    triggered = false;
    triggerTimeout = triggerDelay;
    ejectTimeout = 0.0;
}

void Mine::draw3D()
{
    sf::Shader::bind(NULL);
    glColor3f(1, 1, 1);
    glBegin(GL_POINTS);
    glVertex3f(0, 0, 0);
    glEnd();
}

void Mine::draw3DTransparent()
{
}

void Mine::drawRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range)
{
    sf::Sprite objectSprite;
    textureManager.setTexture(objectSprite, "RadarBlip.png");
    objectSprite.setRotation(getRotation());
    objectSprite.setPosition(position);
    objectSprite.setScale(0.3, 0.3);
    window.draw(objectSprite);

    if (!mySpaceship && gameServer)
    {
        sf::CircleShape hitRadius(getRadius() * scale);
        hitRadius.setOrigin(getRadius() * scale, getRadius() * scale);
        hitRadius.setPosition(position);
        hitRadius.setFillColor(sf::Color::Transparent);
        if (triggered)
            hitRadius.setOutlineColor(sf::Color(255, 0, 0, 128));
        else
            hitRadius.setOutlineColor(sf::Color(255, 255, 255, 128));
        hitRadius.setOutlineThickness(3.0);
        window.draw(hitRadius);
    }
}

void Mine::update(float delta)
{
    if (ejectTimeout > 0.0)
    {
        ejectTimeout -= delta;
        setVelocity(sf::vector2FromAngle(getRotation()) * speed);
    }else{
        setVelocity(sf::Vector2f(0, 0));
    }
    if (!triggered)
        return;
    triggerTimeout -= delta;
    if (triggerTimeout <= 0)
    {
        explode();
    }
}

void Mine::collision(Collisionable* target)
{
    if (!gameServer || triggered || ejectTimeout > 0.0)
        return;
    P<SpaceObject> hitObject = P<Collisionable>(target);
    if (!hitObject || !hitObject->canBeTargeted())
        return;
    
    triggered = true;
}

void Mine::eject()
{
    ejectTimeout = ejectDelay;
}

void Mine::explode()
{
    PVector<Collisionable> hitList = CollisionManager::queryArea(getPosition() - sf::Vector2f(blastRange, blastRange), getPosition() + sf::Vector2f(blastRange, blastRange));
    foreach(Collisionable, c, hitList)
    {
        P<SpaceObject> obj = c;
        if (obj)
        {
            float dist = sf::length(getPosition() - obj->getPosition()) - obj->getRadius() - getRadius();
            if (dist < 0) dist = 0;
            if (dist < blastRange)
            {
                obj->takeDamage(damageAtCenter - (damageAtCenter - damageAtEdge) * dist / blastRange, getPosition(), DT_Kinetic);
            }
        }
    }

    P<ExplosionEffect> e = new ExplosionEffect();
    e->setSize(blastRange);
    e->setPosition(getPosition());
    destroy();
}
