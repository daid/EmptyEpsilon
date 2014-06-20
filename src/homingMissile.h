#ifndef HOMING_MISSLE_H
#define HOMING_MISSLE_H

#include "spaceObject.h"

class HomingMissle : public SpaceObject, public Updatable
{
    const static float speed = 500.0f;
    const static float totalLifetime = 12.0f;
    
    int32_t target_id;
    float lifetime;
public:
    HomingMissle();

    virtual void draw3D();
    virtual void draw3DTransparent();
    virtual void drawRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range);
    virtual void update(float delta);
};

#endif//HOMING_MISSLE_H
