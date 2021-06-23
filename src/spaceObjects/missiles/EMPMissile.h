#ifndef EMP_MISSILE_H
#define EMP_MISSILE_H

#include "missileWeapon.h"

class EMPMissile : public MissileWeapon
{
    constexpr static float blast_range = 1000.0f;
    constexpr static float damage_at_center = 160.0f;
    constexpr static float damage_at_edge = 30.0f;
    bool avoid_area_added;
public:
    EMPMissile();

    void hitObject(P<SpaceObject> object) override;
    void explode();
    void lifeEnded() override;
    void update(float delta) override;
};

#endif//EMP_MISSILE_H
