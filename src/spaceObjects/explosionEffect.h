#ifndef EXPLOSION_EFFECT_H
#define EXPLOSION_EFFECT_H

#include "spaceObject.h"
#include "glObjects.h"

class ExplosionEffect : public SpaceObject, public Updatable
{
    constexpr static float maxLifetime = 2.f;
    constexpr static int particleCount = 1000;

    float lifetime;
    float size;
    string explosion_sound;
    glm::vec3 particleDirections[particleCount];
    bool on_radar;
    // Fit elements in a uint8 - at 4 vertices per quad, that's (256 / 4 =) 64 quads.
    static constexpr size_t max_quad_count = particleCount * 4;
    gl::Buffers<2> particlesBuffers{ gl::Unitialized{} };
public:
    ExplosionEffect();
    virtual ~ExplosionEffect();

    virtual void draw3DTransparent() override;
    virtual void drawOnRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool longRange) override;
    virtual void update(float delta) override;

    void setSize(float size) { this->size = size; }
    void setExplosionSound(string sound) { this->explosion_sound = sound; }
    void setOnRadar(bool on_radar) { this->on_radar = on_radar; }
private:
    void initializeParticles();
};

#endif//EXPLOSION_EFFECT_H
