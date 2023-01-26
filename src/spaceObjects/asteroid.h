#ifndef ASTEROID_H
#define ASTEROID_H

#include "spaceObject.h"

class Asteroid : public SpaceObject
{
public:
    Asteroid();

    virtual void collide(SpaceObject* target, float force) override;

    void setSize(float size);
    float getSize();

    virtual string getExportLine() override { return "Asteroid():setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")" + ":setSize(" + string(getSize(),0) + ")"; }
};

class VisualAsteroid : public SpaceObject
{
public:
    VisualAsteroid();

    void setSize(float size);
    float getSize();

    virtual string getExportLine() override { return "VisualAsteroid():setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")" ":setSize(" + string(getSize(),0) + ")"; }
};

#endif//ASTEROID_H
