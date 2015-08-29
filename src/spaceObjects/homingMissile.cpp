#include "homingMissile.h"
#include "particleEffect.h"
#include "explosionEffect.h"
#include "spaceship.h"

REGISTER_MULTIPLAYER_CLASS(HomingMissile, "HomingMissile");
HomingMissile::HomingMissile()
: MissileWeapon("HomingMissile", 1200.0, sf::Color(255, 200, 0))
{
}

void HomingMissile::hitObject(P<SpaceObject> object)
{
    float weapon_damage = damage;
    DamageInfo info(owner, DT_Kinetic, getPosition());
    
    if (P<SpaceShip>(owner))
        weapon_damage *= (P<SpaceShip>(owner))->weapon_damage_modifier[MW_Homing];
        
    LOG(DEBUG) << "Doing damage: " << weapon_damage;
    
    object->takeDamage(weapon_damage, info);
    P<ExplosionEffect> e = new ExplosionEffect();
    e->setSize(30);
    e->setPosition(getPosition());
    e->setOnRadar(true);
}
