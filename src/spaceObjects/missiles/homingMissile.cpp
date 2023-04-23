/*
/// A HomingMissile is a nimble MissileWeapon that pursues a target and, upon explosion, deals a base of 35 kinetic damage to its target.
/// It inherits functions and behaviors from its parent MissileWeapon class.
/// Missiles can be fired by SpaceShips or created by scripts, and their damage and blast radius can be modified by missile size.
/// Example: homing_missile = HomingMissile:setPosition(1000,1000):setTarget(enemy):setLifetime(40):setMissileSize("large")
REGISTER_SCRIPT_SUBCLASS(HomingMissile, MissileWeapon)
{
  //registered for typeName and creation
}

REGISTER_MULTIPLAYER_CLASS(HomingMissile, "HomingMissile");
HomingMissile::HomingMissile()
: MissileWeapon("HomingMissile", MissileWeaponData::getDataFor(MW_Homing))
{
    setRadarSignatureInfo(0.0, 0.1, 0.2);
}

void HomingMissile::hitObject(P<SpaceObject> object)
{
    DamageInfo info(owner, DamageType::Kinetic, getPosition());
    object->takeDamage(category_modifier * 35, info);
    P<ExplosionEffect> e = new ExplosionEffect();
    e->setSize(category_modifier * 30);
    e->setPosition(getPosition());
    e->setOnRadar(true);
    e->setRadarSignatureInfo(0.0, 0.0, 0.5);
}
*/