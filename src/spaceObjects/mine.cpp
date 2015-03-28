#include <SFML/OpenGL.hpp>
#include "mine.h"
#include "playerInfo.h"
#include "particleEffect.h"
#include "explosionEffect.h"

#include "scriptInterface.h"

/// A mine object. Simple, effective, deadly.
REGISTER_SCRIPT_SUBCLASS(Mine, SpaceObject)
{
}

REGISTER_MULTIPLAYER_CLASS(Mine, "Mine");
Mine::Mine()
: SpaceObject(50, "Mine")
{
    setCollisionRadius(trigger_range);
    triggered = false;
    triggerTimeout = triggerDelay;
    ejectTimeout = 0.0;
    particleTimeout = 0.0;
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

void Mine::drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range)
{
    sf::Sprite objectSprite;
    textureManager.setTexture(objectSprite, "RadarBlip.png");
    objectSprite.setRotation(getRotation());
    objectSprite.setPosition(position);
    objectSprite.setScale(0.3, 0.3);
    window.draw(objectSprite);

    if (!my_spaceship && game_server)
    {
        sf::CircleShape hitRadius(trigger_range * scale);
        hitRadius.setOrigin(trigger_range * scale, trigger_range * scale);
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
    if (particleTimeout > 0)
    {
        particleTimeout -= delta;
    }else{
        sf::Vector3f pos = sf::Vector3f(getPosition().x, getPosition().y, 0);
        ParticleEngine::spawn(pos, pos + sf::Vector3f(random(-100, 100), random(-100, 100), random(-100, 100)), sf::Vector3f(1, 1, 1), sf::Vector3f(0, 0, 1), 30, 0, 10.0);
        particleTimeout = 0.4;
    }

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

void Mine::collide(Collisionable* target)
{
    if (!game_server || triggered || ejectTimeout > 0.0)
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
    DamageInfo info(DT_Kinetic, getPosition());
    SpaceObject::damageArea(getPosition(), blastRange, damageAtEdge, damageAtCenter, info, blastRange / 2.0);

    P<ExplosionEffect> e = new ExplosionEffect();
    e->setSize(blastRange);
    e->setPosition(getPosition());
    destroy();
}
