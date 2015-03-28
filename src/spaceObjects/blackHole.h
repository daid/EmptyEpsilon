#ifndef BLACK_HOLE_H
#define BLACK_HOLE_H

#include "spaceObject.h"

class BlackHole : public SpaceObject, public Updatable
{
    float update_delta;
public:
    BlackHole();

    virtual void update(float delta);

    virtual void draw3D();
    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range);

    virtual bool canHideInNebula() { return false; }

    virtual void collide(Collisionable* target);
};

#endif//BLACK_HOLE_H
