#include "hvli.h"
#include "particleEffect.h"
#include "explosionEffect.h"

REGISTER_MULTIPLAYER_CLASS(HVLI, "HVLI");
HVLI::HVLI()
: MissileWeapon("HVLI", MissileWeaponData::getDataFor(MW_HVLI))
{
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
