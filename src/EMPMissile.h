#ifndef EMP_MISSILE_H
#define EMP_MISSILE_H

#include "spaceObject.h"

class EMPMissile : public SpaceObject, public Updatable
{
    const static float speed = 400.0f;
    const static float turn_speed = 50.0f;
    const static float total_lifetime = 12.0f;
    const static float blastRange = 1000.0f;
    const static float damageAtCenter = 160.0f;
    const static float damageAtEdge = 30.0f;

    float lifetime;
public:
    P<SpaceObject> owner; //Only valid on server.
    int32_t target_id;

    EMPMissile();

    virtual void draw3D();
    virtual void draw3DTransparent();
    virtual void drawRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range);
    virtual void update(float delta);

    virtual void collision(Collisionable* target);
    virtual void takeDamage(float damageAmount, sf::Vector2f damageLocation, EDamageType type) { if (type == DT_EMP) destroy(); }
};

#endif//NUKE_H

