#ifndef SPACE_STATION_H
#define SPACE_STATION_H

#include "spaceObjects/spaceship.h"
#include "shipTemplateBasedObject.h"

class SpaceStation : public SpaceShip
{
public:
    SpaceStation();
    
    virtual bool canBeDockedBy(P<SpaceObject> obj);
    virtual void destroyedByDamage(DamageInfo& info);
    virtual void applyTemplateValues();

    virtual string getExportLine();
};

#endif//SPACE_STATION_H
