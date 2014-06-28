#ifndef SPACE_STATION_H
#define SPACE_STATION_H

#include "engine.h"
#include "spaceObject.h"

class SpaceStation : public SpaceObject, public Updatable
{
public:
    SpaceStation();
    
    virtual void draw3D();
    virtual void update(float delta);
};

#endif//SPACE_SHIP_H
