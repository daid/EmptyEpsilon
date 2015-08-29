#include "nuke.h"
#include "particleEffect.h"
#include "explosionEffect.h"
#include "spaceship.h"

REGISTER_MULTIPLAYER_CLASS(Nuke, "Nuke");
Nuke::Nuke()
: MissileWeapon("Nuke", 500.0, sf::Color(255, 100, 32))
{
}

void Nuke::hitObject(P<SpaceObject> object)
{
    float damageAtEdge_modified = damageAtEdge;
    float damageAtCenter_modified = damageAtCenter;
    
    DamageInfo info(owner, DT_Kinetic, getPosition());
    
    if (P<SpaceShip>(owner))
    {
        damageAtEdge_modified *=   (P<SpaceShip>(owner))->weapon_damage_modifier[MW_Nuke];
        damageAtCenter_modified *= (P<SpaceShip>(owner))->weapon_damage_modifier[MW_Nuke];
    }
    
    SpaceObject::damageArea(getPosition(), blastRange, damageAtEdge_modified, damageAtCenter_modified, info, getRadius());

    P<ExplosionEffect> e = new ExplosionEffect();
    e->setSize(blastRange);
    e->setPosition(getPosition());
    e->setOnRadar(true);
}
