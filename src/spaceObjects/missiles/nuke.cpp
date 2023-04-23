/*
/// A HomingMissile is a MissileWeapon that pursues a target and, upon explosion, deals a base of 30-160 kinetic damage to all SpaceObjects within its 1U base blast radius.
/// It inherits functions and behaviors from its parent MissileWeapon class.
/// Missiles can be fired by SpaceShips or created by scripts, and their damage and blast radius can be modified by missile size.
/// AI behaviors attempt to avoid EMPMissiles.
/// Example: nuke_missile = Nuke:setPosition(1000,1000):setTarget(enemy):setLifetime(40):setMissileSize("large")
REGISTER_SCRIPT_SUBCLASS(Nuke, MissileWeapon)
{
  //registered for typeName and creation
}

REGISTER_MULTIPLAYER_CLASS(Nuke, "Nuke");
Nuke::Nuke()
: MissileWeapon("Nuke", MissileWeaponData::getDataFor(MW_Nuke))
{
    avoid_area_added = false;
    setRadarSignatureInfo(0.0, 0.7, 0.1);
}

void Nuke::explode()
{
    DamageInfo info(owner, DamageType::Kinetic, getPosition());
    DamageSystem::damageArea(getPosition(), category_modifier * blast_range, category_modifier * damage_at_edge, category_modifier * damage_at_center, info, 10.0f);

    P<ExplosionEffect> e = new ExplosionEffect();
    e->setSize(category_modifier * blast_range);
    e->setPosition(getPosition());
    e->setOnRadar(true);
    e->setExplosionSound("sfx/nuke_explosion.wav");
    setRadarSignatureInfo(0.0, 0.7, 1.0);
}

void Nuke::hitObject(P<SpaceObject> object)
{
    explode();
}

void Nuke::lifeEnded()
{
    explode();
}

void Nuke::update(float delta)
{
    MissileWeapon::update(delta);
    if(!avoid_area_added && data.lifetime / 1.5f > lifetime)
    {
        // We won't want to add the avoid area right away, since that would wreak havoc on the path planning 
        // Ships would try to avoid their own nukes, which is just really silly. 
        entity.getOrAddComponent<AvoidObject>().range = 1000.0f;
        avoid_area_added = true;
    }
}
*/