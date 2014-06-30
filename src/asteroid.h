#ifndef ASTEROID_H
#define ASTEROID_H

#include "spaceObject.h"

class Asteroid : public SpaceObject
{
public:
    Asteroid();

    virtual void draw3D();
    virtual void drawRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range);
    
    virtual void collision(Collisionable* target);
};

#endif//ASTEROID_H
