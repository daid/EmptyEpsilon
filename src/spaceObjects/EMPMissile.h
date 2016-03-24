#ifndef EMP_MISSILE_H
#define EMP_MISSILE_H

#include "missileWeapon.h"

class EMPMissile : public MissileWeapon
{
    constexpr static float blastRange = 1000.0f;
    constexpr static float damageAtCenter = 160.0f;
    constexpr static float damageAtEdge = 30.0f;
public:
    EMPMissile();
    
    virtual void hitObject(P<SpaceObject> object);
};

#endif//NUKE_H

