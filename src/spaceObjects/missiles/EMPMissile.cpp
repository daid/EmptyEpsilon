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
    SpaceObject::damageArea(getPosition(), category_modifier * blast_range, category_modifier * damage_at_edge, category_modifier * damage_at_center, info, getRadius());

    P<ElectricExplosionEffect> e = new ElectricExplosionEffect();
    e->setSize(category_modifier * blast_range);
    e->setPosition(getPosition());
    e->setOnRadar(true);
}
