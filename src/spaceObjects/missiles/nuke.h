#ifndef NUKE_H
#define NUKE_H

#include "missileWeapon.h"

class Nuke : public MissileWeapon
{
    constexpr static float blast_range = 1000.0f;
    constexpr static float damage_at_center = 160.0f;
    constexpr static float damage_at_edge = 30.0f;
public:
    Nuke();

    virtual void hitObject(P<SpaceObject> object);
};

#endif//NUKE_H
