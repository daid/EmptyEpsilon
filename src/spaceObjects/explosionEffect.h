#ifndef EXPLOSION_EFFECT_H
#define EXPLOSION_EFFECT_H

#include "spaceObject.h"

class ExplosionEffect : public SpaceObject, public Updatable
{
    constexpr static float maxLifetime = 2.0;
    constexpr static int particleCount = 1000;
    
    float lifetime;
    float size;
    sf::Vector3f particleDirections[particleCount];
public:
    ExplosionEffect();

    virtual void draw3DTransparent();
    virtual void update(float delta);
    
    void setSize(float size) { this->size = size; }
};

#endif//EXPLOSION_EFFECT_H
