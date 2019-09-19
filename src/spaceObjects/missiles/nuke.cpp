#include "nuke.h"
#include "particleEffect.h"
#include "spaceObjects/explosionEffect.h"
#include "pathPlanner.h"

REGISTER_MULTIPLAYER_CLASS(Nuke, "Nuke");
Nuke::Nuke()
: MissileWeapon("Nuke", MissileWeaponData::getDataFor(MW_Nuke))
{
    avoid_area_added = false;
}

void Nuke::explode()
{
    DamageInfo info(owner, DT_Kinetic, getPosition());
    SpaceObject::damageArea(getPosition(), category_modifier * blast_range, category_modifier * damage_at_edge, category_modifier * damage_at_center, info, getRadius());

    P<ExplosionEffect> e = new ExplosionEffect();
    e->setSize(category_modifier * blast_range);
    e->setPosition(getPosition());
    e->setOnRadar(true);
    e->setExplosionSound("sfx/nuke_explosion.wav");
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
    if(!avoid_area_added && data.lifetime / 1.5 > lifetime)
    {
        // We won't want to add the avoid area right away, since that would wreak havoc on the path planning 
        // Ships would try to avoid their own nukes, which is just really silly. 
        PathPlannerManager::getInstance()->addAvoidObject(this, 1000.f);
        avoid_area_added = true;
    }
}
