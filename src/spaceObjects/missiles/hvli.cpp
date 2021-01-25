#include "hvli.h"
#include "particleEffect.h"
#include "spaceObjects/explosionEffect.h"

/// HVLI missile
REGISTER_SCRIPT_SUBCLASS(HVLI, MissileWeapon)
{
  //registered for typeName and creation
}

REGISTER_MULTIPLAYER_CLASS(HVLI, "HVLI");
HVLI::HVLI()
: MissileWeapon("HVLI", MissileWeaponData::getDataFor(MW_HVLI))
{
    setRadarSignatureInfo(0.1, 0.0, 0.0);
}

void HVLI::hitObject(P<SpaceObject> object)
{
    DamageInfo info(owner, DT_Kinetic, getPosition());
    float alive_for = MissileWeaponData::getDataFor(MW_HVLI).lifetime - lifetime;
    if (alive_for > 2.0)
        object->takeDamage(category_modifier * 6, info);
    else
        object->takeDamage(category_modifier * 6 * (alive_for / 2.0), info);
    P<ExplosionEffect> e = new ExplosionEffect();
    e->setSize(category_modifier * 20);
    e->setPosition(getPosition());
    e->setOnRadar(true);
    setRadarSignatureInfo(0.0, 0.0, 0.1);
}
