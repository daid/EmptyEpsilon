#ifndef NUKE_H
#define NUKE_H

#include "missileWeapon.h"

class Nuke : public MissileWeapon
{
    constexpr static float blast_range = 1000.0f;
    constexpr static float damage_at_center = 160.0f;
    constexpr static float damage_at_edge = 30.0f;
    bool avoid_area_added;
public:
    Nuke();

    void hitObject(P<SpaceObject> object) override;
    void explode();
    void lifeEnded() override;
    
    void update(float delta) override;
};

#endif//NUKE_H
