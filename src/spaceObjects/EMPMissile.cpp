#include "EMPMissile.h"
#include "particleEffect.h"
#include "electricExplosionEffect.h"

REGISTER_MULTIPLAYER_CLASS(EMPMissile, "EMPMissile");
EMPMissile::EMPMissile()
: MissileWeapon("EMPMissile", 500.0, sf::Color(100, 32, 255))
{
}

void EMPMissile::hitObject(P<SpaceObject> object)
{
    DamageInfo info(owner, DT_EMP, getPosition());
    SpaceObject::damageArea(getPosition(), blastRange, damageAtEdge, damageAtCenter, info, getRadius());

    P<ElectricExplosionEffect> e = new ElectricExplosionEffect();
    e->setSize(blastRange);
    e->setPosition(getPosition());
    e->setOnRadar(true);
}
