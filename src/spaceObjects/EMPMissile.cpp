#include "EMPMissile.h"
#include "particleEffect.h"
#include "electricExplosionEffect.h"
#include "spaceship.h"

REGISTER_MULTIPLAYER_CLASS(EMPMissile, "EMPMissile");
EMPMissile::EMPMissile()
: MissileWeapon("EMPMissile", 500.0, sf::Color(100, 32, 255))
{
}

void EMPMissile::hitObject(P<SpaceObject> object)
{
    float damageAtEdge_modified = damageAtEdge;
    float damageAtCenter_modified = damageAtCenter;
    
    DamageInfo info(owner, DT_EMP, getPosition());
    
    if (P<SpaceShip>(owner))
    {
        damageAtEdge_modified *=   (P<SpaceShip>(owner))->weapon_damage_modifier[MW_EMP];
        damageAtCenter_modified *= (P<SpaceShip>(owner))->weapon_damage_modifier[MW_EMP];
    }
    
    SpaceObject::damageArea(getPosition(), blastRange, damageAtEdge_modified, damageAtCenter_modified, info, getRadius());

    P<ElectricExplosionEffect> e = new ElectricExplosionEffect();
    e->setSize(blastRange);
    e->setPosition(getPosition());
    e->setOnRadar(true);
}
