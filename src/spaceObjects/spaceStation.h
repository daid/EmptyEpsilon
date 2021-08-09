#ifndef SPACE_STATION_H
#define SPACE_STATION_H

#include "shipTemplateBasedObject.h"

class SpaceStation : public ShipTemplateBasedObject
{
public:
    SpaceStation();

    virtual void drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range);
    virtual bool canBeDockedBy(P<SpaceObject> obj);
    virtual void destroyedByDamage(DamageInfo& info);
    virtual void applyTemplateValues();

    virtual string getExportLine();
};

#endif//SPACE_STATION_H
