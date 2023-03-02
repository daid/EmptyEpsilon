#include "EMPMissile.h"
#include "particleEffect.h"
#include "spaceObjects/electricExplosionEffect.h"
#include "pathPlanner.h"

/// An EMPMissile is an electromagnetic pulse MissileWeapon that pursues a target and, upon explosion, deals a base of 30-160 EMP damage to shields within its 1U base blast radius.
/// It inherits functions and behaviors from its parent MissileWeapon class.
/// Missiles can be fired by SpaceShips or created by scripts, and their damage and blast radius can be modified by missile size.
/// AI behaviors attempt to avoid EMPMissiles.
/// Example: emp_missile = EMPMissile:setPosition(1000,1000):setTarget(enemy):setLifetime(40):setMissileSize("large")
REGISTER_SCRIPT_SUBCLASS(EMPMissile, MissileWeapon)
{
  //registered for typeName and creation
}
REGISTER_MULTIPLAYER_CLASS(EMPMissile, "EMPMissile");
EMPMissile::EMPMissile()
: MissileWeapon("EMPMissile", MissileWeaponData::getDataFor(MW_EMP))
{
    avoid_area_added = false;
    setRadarSignatureInfo(0.0, 0.5, 0.1);
}

void EMPMissile::explode()
{
    DamageInfo info(owner, DamageType::EMP, getPosition());
    DamageSystem::damageArea(getPosition(), category_modifier * blast_range, category_modifier * damage_at_edge, category_modifier * damage_at_center, info, 10.0f);

    P<ElectricExplosionEffect> e = new ElectricExplosionEffect();
    e->setSize(category_modifier * blast_range);
    e->setPosition(getPosition());
    e->setOnRadar(true);
    e->setRadarSignatureInfo(0.0, 1.0, 0.0);
}


void EMPMissile::hitObject(P<SpaceObject> object)
{
    explode();
}

void EMPMissile::lifeEnded()
{
    explode();
}
    
void EMPMissile::update(float delta)
{
    MissileWeapon::update(delta);
    
    if(!avoid_area_added && data.lifetime / 1.5f > lifetime)
    {
        // We won't want to add the avoid area right away, since that would wreak havoc on the path planning 
        // Ships would try to avoid their own nukes, which is just really silly. 
        PathPlannerManager::getInstance()->addAvoidObject(this, 1000.f);
        avoid_area_added = true;
    }
}



