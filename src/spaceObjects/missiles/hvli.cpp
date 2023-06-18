#include "hvli.h"
#include "particleEffect.h"
#include "spaceObjects/explosionEffect.h"

/// An HVLI is a high-velocity lead impactor, a fancy name for an unguided bullet MissileWeapon that deals kinetic damage upon impact.
/// Damage is reduced if the HVLI has been alive for less than 2 seconds.
/// It inherits functions and behaviors from its parent MissileWeapon class.
/// Missiles can be fired by SpaceShips or created by scripts, and their damage and blast radius can be modified by missile size.
/// Example: hvli = HVLI:setPosition(1000,1000):setRotation(90):setLifetime(40):setMissileSize("large")
REGISTER_SCRIPT_SUBCLASS(HVLI, MissileWeapon)
{
  //registered for typeName and creation
}

REGISTER_MULTIPLAYER_CLASS(HVLI, "HVLI");
HVLI::HVLI()
: MissileWeapon("HVLI", MissileWeaponData::getDataFor(MW_HVLI))
{
    setRadarSignatureInfo(0.1f, 0.0f, 0.0f);
    setCollisionBox({10, 30}); // Make it a bit harder to the HVLI to phase trough smaller enemies
}

void HVLI::hitObject(P<SpaceObject> object)
{
    DamageInfo info(owner, DT_Kinetic, getPosition());
    float alive_for = MissileWeaponData::getDataFor(MW_HVLI).lifetime - lifetime;
    if (alive_for > 2.0f)
        object->takeDamage(category_modifier * 10.0f, info);
    else
        object->takeDamage(category_modifier * 10.0f * (alive_for / 2.0f), info);
    P<ExplosionEffect> e = new ExplosionEffect();
    e->setSize(category_modifier * 20.0f);
    e->setPosition(getPosition());
    e->setOnRadar(true);
    setRadarSignatureInfo(0.0f, 0.0f, 0.1f);
}
