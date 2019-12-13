#ifndef SPACE_STATION_H
#define SPACE_STATION_H

#include "shipTemplateBasedObject.h"
#include "spaceObjects/spaceship.h"

class SpaceStation : public ShipTemplateBasedObject
{
private:
    PVector<SpaceShip> docking_permission_list;

public:
    SpaceStation();
    
    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range);
    virtual bool canBeDockedBy(P<SpaceObject> obj);
    virtual void destroyedByDamage(DamageInfo& info);
    virtual void applyTemplateValues();
    virtual void addDockingPermission(P<SpaceObject> obj);
    virtual void removeDockingPermission(P<SpaceObject> obj);
    virtual bool hasDockingPermission(P<SpaceObject> obj);

    virtual string getExportLine();
};

#endif//SPACE_STATION_H
