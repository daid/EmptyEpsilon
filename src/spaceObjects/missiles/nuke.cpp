#include "nuke.h"
#include "particleEffect.h"
#include "spaceObjects/explosionEffect.h"

REGISTER_MULTIPLAYER_CLASS(Nuke, "Nuke");
Nuke::Nuke()
: MissileWeapon("Nuke", MissileWeaponData::getDataFor(MW_Nuke))
{
    setRadarSignatureInfo(0.0, 0.7, 0.1);
}

void Nuke::hitObject(P<SpaceObject> object)
{
    DamageInfo info(owner, DT_Kinetic, getPosition());
    SpaceObject::damageArea(getPosition(), category_modifier * blast_range, category_modifier * damage_at_edge, category_modifier * damage_at_center, info, getRadius());

    P<ExplosionEffect> e = new ExplosionEffect();
    e->setSize(category_modifier * blast_range);
    e->setPosition(getPosition());
    e->setOnRadar(true);
    e->setExplosionSound("sfx/nuke_explosion.wav");
    setRadarSignatureInfo(0.0, 0.7, 1.0);
}
