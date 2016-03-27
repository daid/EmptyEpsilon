#include "hvli.h"
#include "particleEffect.h"
#include "explosionEffect.h"

REGISTER_MULTIPLAYER_CLASS(HVLI, "HVLI");
HVLI::HVLI()
: MissileWeapon("HVLI", 0.0, sf::Color(200, 200, 200))
{
    speed = speed * 2.0f;
    lifetime = lifetime / 2.0f;
    turnrate = 0;
}

void HVLI::hitObject(P<SpaceObject> object)
{
    DamageInfo info(owner, DT_Kinetic, getPosition());
    object->takeDamage(7, info);
    P<ExplosionEffect> e = new ExplosionEffect();
    e->setSize(20);
    e->setPosition(getPosition());
    e->setOnRadar(true);
}
