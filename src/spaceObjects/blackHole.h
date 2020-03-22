#ifndef BLACK_HOLE_H
#define BLACK_HOLE_H

#include "spaceObject.h"

class BlackHole : public SpaceObject, public Updatable
{
    float update_delta;
public:
    BlackHole();

    virtual void update(float delta) override;

#if FEATURE_3D_RENDERING
    virtual void draw3DTransparent() override;
#endif
    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range) override;

    virtual bool canHideInNebula()  override { return false; }

    virtual void collide(Collisionable* target, float force) override;

    virtual string getExportLine() override { return "BlackHole():setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")"; }
};

#endif//BLACK_HOLE_H
