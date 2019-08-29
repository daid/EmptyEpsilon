#include "nuke.h"
#include "particleEffect.h"
#include "spaceObjects/explosionEffect.h"

REGISTER_MULTIPLAYER_CLASS(Nuke, "Nuke");
Nuke::Nuke()
: MissileWeapon("Nuke", MissileWeaponData::getDataFor(MW_Nuke))
{
}

void Nuke::hitObject(P<SpaceObject> object)
{
    DamageInfo info(owner, DT_Kinetic, getPosition());
    SpaceObject::damageArea(getPosition(), category_modifier * blastRange, category_modifier * damageAtEdge, category_modifier * damageAtCenter, info, getRadius());

    P<ExplosionEffect> e = new ExplosionEffect();
    e->setSize(category_modifier * blastRange);
    e->setPosition(getPosition());
    e->setOnRadar(true);
    e->setExplosionSound("sfx/nuke_explosion.wav");
}
