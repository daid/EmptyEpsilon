#include "EMPMissile.h"
#include "particleEffect.h"
#include "spaceObjects/electricExplosionEffect.h"
#include "pathPlanner.h"

REGISTER_MULTIPLAYER_CLASS(EMPMissile, "EMPMissile");
EMPMissile::EMPMissile()
: MissileWeapon("EMPMissile", MissileWeaponData::getDataFor(MW_EMP))
{
    avoid_area_added = false;
}

void EMPMissile::explode()
{
    DamageInfo info(owner, DT_EMP, getPosition());
    SpaceObject::damageArea(getPosition(), category_modifier * blast_range, category_modifier * damage_at_edge, category_modifier * damage_at_center, info, getRadius());

    P<ElectricExplosionEffect> e = new ElectricExplosionEffect();
    e->setSize(category_modifier * blast_range);
    e->setPosition(getPosition());
    e->setOnRadar(true);
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
    
    if(!avoid_area_added && data.lifetime / 1.5 > lifetime)
    {
        // We won't want to add the avoid area right away, since that would wreak havoc on the path planning 
        // Ships would try to avoid their own nukes, which is just really silly. 
        PathPlannerManager::getInstance()->addAvoidObject(this, 1000.f);
        avoid_area_added = true;
    }
}



