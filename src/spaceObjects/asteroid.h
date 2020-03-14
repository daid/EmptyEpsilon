#ifndef ASTEROID_H
#define ASTEROID_H

#include "spaceObject.h"

class Asteroid : public SpaceObject
{
public:
    float rotation_speed;
    float z;
    float size;
    int model_number;

    Asteroid();
    
    virtual void draw3D();

    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range) override;

    virtual void collide(Collisionable* target, float force) override;
    
    void setSize(float size);
    
    virtual string getExportLine() override { return "Asteroid():setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")"; }
};

class VisualAsteroid : public SpaceObject
{
public:
    float rotation_speed;
    float z;
    float size;
    int model_number;

    VisualAsteroid();

    virtual void draw3D();
    
    void setSize(float size);

    virtual string getExportLine() override { return "VisualAsteroid():setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")"; }
};

#endif//ASTEROID_H
