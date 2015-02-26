#include <SFML/OpenGL.hpp>
#include "homingMissile.h"
#include "particleEffect.h"
#include "explosionEffect.h"

REGISTER_MULTIPLAYER_CLASS(HomingMissile, "HomingMissile");
HomingMissile::HomingMissile()
: MissileWeapon("HomingMissile", 500.0, sf::Color(255, 200, 0))
{
}

void HomingMissile::hitObject(P<SpaceObject> object)
{
    DamageInfo info(DT_Kinetic, getPosition());
    object->takeDamage(35, info);
    P<ExplosionEffect> e = new ExplosionEffect();
    e->setSize(30);
    e->setPosition(getPosition());
}
