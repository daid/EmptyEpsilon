#include "EMPMissile.h"
#include "particleEffect.h"
#include "spaceObjects/electricExplosionEffect.h"

REGISTER_MULTIPLAYER_CLASS(EMPMissile, "EMPMissile");
EMPMissile::EMPMissile()
: MissileWeapon("EMPMissile", MissileWeaponData::getDataFor(MW_EMP))
{
}

void EMPMissile::hitObject(P<SpaceObject> object)
{
    DamageInfo info(owner, DT_EMP, getPosition());
    SpaceObject::damageArea(getPosition(), category_modifier * blastRange, category_modifier * damageAtEdge, category_modifier * damageAtCenter, info, getRadius());

    P<ElectricExplosionEffect> e = new ElectricExplosionEffect();
    e->setSize(category_modifier * blastRange);
    e->setPosition(getPosition());
    e->setOnRadar(true);
}
