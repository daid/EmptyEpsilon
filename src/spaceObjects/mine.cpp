#include "main.h"
#include "mine.h"
#include "playerInfo.h"
#include "particleEffect.h"
#include "explosionEffect.h"
#include "pathPlanner.h"

#include "scriptInterface.h"

/// A mine object. Simple, effective, deadly.
REGISTER_SCRIPT_SUBCLASS(Mine, SpaceObject)
{
  // Set a function that will be called if the mine explodes.
  // First argument is the mine, second argument is the mine's owner/instigator (or nil).
  REGISTER_SCRIPT_CLASS_FUNCTION(Mine, onDestruction);
}

REGISTER_MULTIPLAYER_CLASS(Mine, "Mine");
Mine::Mine()
: SpaceObject(50, "Mine"), data(MissileWeaponData::getDataFor(MW_Mine))
{
    setCollisionRadius(trigger_range);
    triggered = false;
    triggerTimeout = triggerDelay;
    ejectTimeout = 0.0;
    particleTimeout = 0.0;
    setRadarSignatureInfo(0.0, 0.05, 0.0);

    PathPlannerManager::getInstance()->addAvoidObject(this, trigger_range * 1.2f);
}

void Mine::draw3D()
{
}

void Mine::draw3DTransparent()
{
}

void Mine::drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range)
{
    sf::Sprite objectSprite;
    textureManager.setTexture(objectSprite, "RadarBlip.png");
    objectSprite.setRotation(getRotation());
    objectSprite.setPosition(position);
    objectSprite.setScale(0.3, 0.3);
    window.draw(objectSprite);
}

void Mine::drawOnGMRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range)
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
        setVelocity(sf::vector2FromAngle(getRotation()) * data.speed);
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

void Mine::collide(Collisionable* target, float force)
{
    if (!game_server || triggered || ejectTimeout > 0.0)
        return;
    P<SpaceObject> hitObject = P<Collisionable>(target);
    if (!hitObject || !hitObject->canBeTargetedBy(nullptr))
        return;

    triggered = true;
}

void Mine::eject()
{
    ejectTimeout = data.lifetime;
}

void Mine::explode()
{
    DamageInfo info(owner, DT_Kinetic, getPosition());
    SpaceObject::damageArea(getPosition(), blastRange, damageAtEdge, damageAtCenter, info, blastRange / 2.0);

    P<ExplosionEffect> e = new ExplosionEffect();
    e->setSize(blastRange);
    e->setPosition(getPosition());
    e->setOnRadar(true);
    e->setRadarSignatureInfo(0.0, 0.0, 0.2);

    if (on_destruction.isSet())
    {
        on_destruction.call(P<Mine>(this), P<SpaceObject>(info.instigator));
    }
    destroy();
}

void Mine::onDestruction(ScriptSimpleCallback callback)
{
    this->on_destruction = callback;
}
