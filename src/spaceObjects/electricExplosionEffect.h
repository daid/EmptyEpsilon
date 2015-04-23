#ifndef ELECTRIC_EXPLOSION_EFFECT_H
#define ELECTRIC_EXPLOSION_EFFECT_H

#include "spaceObject.h"

class ElectricExplosionEffect : public SpaceObject, public Updatable
{
    constexpr static float maxLifetime = 4.0;
    constexpr static int particleCount = 1000;
    
    float lifetime;
    float size;
    sf::Vector3f particleDirections[particleCount];
    bool on_radar;
public:
    ElectricExplosionEffect();

    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool longRange);
    virtual void draw3DTransparent();
    virtual void update(float delta);
    
    void setSize(float size) { this->size = size; }
    void setOnRadar(bool on_radar) { this->on_radar = on_radar; }
};

#endif//ELECTRIC_EXPLOSION_EFFECT_H

