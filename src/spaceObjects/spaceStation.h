#ifndef SPACE_STATION_H
#define SPACE_STATION_H

#include "spaceObjects/spaceship.h"
#include "shipTemplateBasedObject.h"

class SpaceStation : public SpaceShip
{
public:
    SpaceStation();
    
    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range);
    virtual bool canBeDockedBy(P<SpaceObject> obj);
    virtual void destroyedByDamage(DamageInfo& info);
    virtual void applyTemplateValues();

    virtual string getExportLine();
};

#endif//SPACE_STATION_H
