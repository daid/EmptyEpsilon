#ifndef NUKE_H
#define NUKE_H

#include "spaceObject.h"

class Nuke : public SpaceObject, public Updatable
{
    const static float speed = 400.0f;
    const static float turnSpeed = 50.0f;
    const static float totalLifetime = 12.0f;
    const static float blastRange = 1000.0f;
    const static float damageAtCenter = 160.0f;
    const static float damageAtEdge = 30.0f;
    
    float lifetime;
public:
    P<SpaceObject> owner; //Only valid on server.
    int32_t target_id;

    Nuke();

    virtual void draw3D();
    virtual void draw3DTransparent();
    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range);
    virtual void update(float delta);
    
    virtual void collision(Collisionable* target);
    virtual void takeDamage(float damageAmount, DamageInfo& info) { if (info.type != DT_Kinetic) destroy(); }
};

#endif//NUKE_H

