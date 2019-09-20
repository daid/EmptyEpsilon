#ifndef HOMING_MISSLE_H
#define HOMING_MISSLE_H

#include "missileWeapon.h"

class HomingMissile : public MissileWeapon
{
public:
    HomingMissile();
    
    virtual void hitObject(P<SpaceObject> object);
};

#endif//HOMING_MISSLE_H
