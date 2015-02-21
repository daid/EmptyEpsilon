#include <SFML/OpenGL.hpp>
#include "EMPMissile.h"
#include "particleEffect.h"
#include "electricExplosionEffect.h"

REGISTER_MULTIPLAYER_CLASS(EMPMissile, "EMPMissile");
EMPMissile::EMPMissile()
: MissileWeapon("EMPMissile", 400.0f, 50.0f, 12.0f, sf::Color(100, 32, 255))
{
}

void EMPMissile::hitObject(P<SpaceObject> object)
{
    DamageInfo info(DT_EMP, getPosition());
    SpaceObject::damageArea(getPosition(), blastRange, damageAtEdge, damageAtCenter, info, getRadius());

    P<ElectricExplosionEffect> e = new ElectricExplosionEffect();
    e->setSize(blastRange);
    e->setPosition(getPosition());
    destroy();
}
