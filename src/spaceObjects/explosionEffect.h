#ifndef EXPLOSION_EFFECT_H
#define EXPLOSION_EFFECT_H

#include "spaceObject.h"
#include "glObjects.h"

class ExplosionEffect : public SpaceObject, public Updatable
{
    constexpr static float maxLifetime = 2.0;
    constexpr static int particleCount = 1000;

    float lifetime;
    float size;
    string explosion_sound;
    glm::vec3 particleDirections[particleCount];
    bool on_radar;
#if FEATURE_3D_RENDERING
    // Fit elements in a uint8 - at 4 vertices per quad, that's (256 / 4 =) 64 quads.
    static constexpr size_t max_quad_count = 64;
    static gl::Buffers<2> particlesBuffers;
#endif
public:
    ExplosionEffect();
    virtual ~ExplosionEffect();

#if FEATURE_3D_RENDERING
    virtual void draw3DTransparent();
#endif
    virtual void drawOnRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool longRange);
    virtual void update(float delta);

    void setSize(float size) { this->size = size; }
    void setExplosionSound(string sound) { this->explosion_sound = sound; }
    void setOnRadar(bool on_radar) { this->on_radar = on_radar; }
};

#endif//EXPLOSION_EFFECT_H
