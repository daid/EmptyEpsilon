#ifndef MINE_H
#define MINE_H

#include "spaceObject.h"

class Mine : public SpaceObject, public Updatable
{
    const static float speed = -600.0f;
    const static float blastRange = 1000.0f;
    const static float trigger_range = 600.0f;
    const static float ejectDelay = 2.0f;
    const static float triggerDelay = 1.0f;
    const static float damageAtCenter = 160.0f;
    const static float damageAtEdge = 30.0f;
    
public:
    bool triggered;       //Only valid on server.
    float triggerTimeout; //Only valid on server.
    float ejectTimeout;   //Only valid on server.
    float particleTimeout;

    Mine();

    virtual void draw3D();
    virtual void draw3DTransparent();
    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range);
    virtual void update(float delta);
    
    virtual void collision(Collisionable* target);
    void eject();
    void explode();
};

#endif//NUKE_H

