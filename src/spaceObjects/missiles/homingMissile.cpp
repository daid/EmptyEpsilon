#include "homingMissile.h"
#include "particleEffect.h"
#include "spaceObjects/explosionEffect.h"

REGISTER_MULTIPLAYER_CLASS(HomingMissile, "HomingMissile");
HomingMissile::HomingMissile()
: MissileWeapon("HomingMissile", MissileWeaponData::getDataFor(MW_Homing))
{
}

void HomingMissile::hitObject(P<SpaceObject> object)
{
    DamageInfo info(owner, DT_Kinetic, getPosition());
    object->takeDamage(category_modifier * 35, info);
    P<ExplosionEffect> e = new ExplosionEffect();
    e->setSize(category_modifier * 30);
    e->setPosition(getPosition());
    e->setOnRadar(true);
}
