#ifndef ELECTRIC_EXPLOSION_EFFECT_H
#define ELECTRIC_EXPLOSION_EFFECT_H

#include "spaceObject.h"

class ElectricExplosionEffect : public SpaceObject, public Updatable
{
    const static float maxLifetime = 4.0;
    const static int particleCount = 1000;
    
    float lifetime;
    float size;
    sf::Vector3f particleDirections[particleCount];
public:
    ElectricExplosionEffect();

    virtual void draw3DTransparent();
    virtual void update(float delta);
    
    void setSize(float size) { this->size = size; }
};

#endif//ELECTRIC_EXPLOSION_EFFECT_H

