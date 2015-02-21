#ifndef NUKE_H
#define NUKE_H

#include "missileWeapon.h"

class Nuke : public MissileWeapon
{
    const static float blastRange = 1000.0f;
    const static float damageAtCenter = 160.0f;
    const static float damageAtEdge = 30.0f;
public:
    Nuke();

    virtual void hitObject(P<SpaceObject> object);
};

#endif//NUKE_H

