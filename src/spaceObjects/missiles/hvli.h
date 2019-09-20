#ifndef HVLI_H
#define HVLI_H

#include "missileWeapon.h"

/** High Velocity Lead Impactor.
    Missile weapon that does not home, but flies at higher speeds and fired in bursts.
*/
class HVLI : public MissileWeapon
{
public:
    HVLI();
    
    virtual void hitObject(P<SpaceObject> object);
};

#endif//HVLI_H
